-- ZPU
--
-- Copyright 2004-2008 oharboe - ?yvind Harboe - oyvind.harboe@zylin.com
-- Copyright 2008 alvieboy - ?lvaro Lopes - alvieboy@alvie.com
-- 
-- The FreeBSD license
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above
--    copyright notice, this list of conditions and the following
--    disclaimer in the documentation and/or other materials
--    provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE ZPU PROJECT ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
-- PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
-- ZPU PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
-- INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
-- OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
-- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
-- STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation
-- are those of the authors and should not be interpreted as representing
-- official policies, either expressed or implied, of the ZPU Project.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.zpu_config.all;
use work.zpupkg.all;


-- mem_writeEnable - set to '1' for a single cycle to send off a write request.
--                   mem_write is valid only while mem_writeEnable='1'.
-- mem_readEnable - set to '1' for a single cycle to send off a read request.
-- 
-- mem_busy - It is illegal to send off a read/write request when mem_busy='1'.
--            Set to '0' when mem_read  is valid after a read request.
--            If it goes to '1'(busy), it is on the cycle after mem_read/writeEnable
--            is '1'.
-- mem_addr - address for read/write request
-- mem_read - read data. Valid only on the cycle after mem_busy='0' after 
--            mem_readEnable='1' for a single cycle.
-- mem_write - data to write
-- mem_writeMask - set to '1' for those bits that are to be written to memory upon
--                 write request
-- break - set to '1' when CPU hits break instruction
-- interrupt - set to '1' until interrupts are cleared by CPU. 




entity zpu_core is
  port (
    clk                 : in  std_logic;
    reset               : in  std_logic;
    enable              : in  std_logic;
    in_mem_busy         : in  std_logic;
    mem_read            : in  std_logic_vector(wordSize-1 downto 0);
    mem_write           : out std_logic_vector(wordSize-1 downto 0);
    out_mem_addr        : out std_logic_vector(maxAddrBitIncIO downto 0);
    out_mem_writeEnable : out std_logic;
    out_mem_readEnable  : out std_logic;
    mem_writeMask       : out std_logic_vector(wordBytes-1 downto 0);
    interrupt           : in  std_logic;
    break               : out std_logic
    );
end zpu_core;


architecture behave of zpu_core is

  type InsnType is (
    Insn_AddTop,
    Insn_Dup,
    Insn_DupStackB,
    Insn_Pop,
    Insn_PopDown,
    Insn_Add,
    Insn_Or,
    Insn_And,
    Insn_Store,
    Insn_AddSP,
    Insn_Shift,
    Insn_Nop,
    Insn_Im,
    Insn_LoadSP,
    Insn_StoreSP,
    Insn_Emulate,
    Insn_Load,
    Insn_PushSP,
    Insn_PopPC,
    Insn_PopPCrel,
    Insn_Not,
    Insn_Flip,
    Insn_PopSP,
    Insn_Neqbranch,
    Insn_Eq,
    Insn_Loadb,
    Insn_Mult,
    Insn_Lessthan,
    Insn_Lessthanorequal,
    Insn_Ulessthanorequal,
    Insn_Ulessthan,
    Insn_PushSPadd,
    Insn_Call,
    Insn_CallPCrel,
    Insn_Sub,
    Insn_Break,
    Insn_Storeb,
    Insn_InsnFetch
    );

  type StateType is (
    State_Load2,
    State_Popped,
    State_LoadSP2,
    State_LoadSP3,
    State_AddSP2,
    State_Fetch,
    State_Execute,
    State_Decode,
    State_Decode2,
    State_Resync,

    State_StoreSP2,
    State_Resync2,
    State_Resync3,
    State_Loadb2,
    State_Storeb2,
    State_Mult2,
    State_Mult3,
    State_Mult5,
    State_Mult4,
    State_BinaryOpResult2,
    State_BinaryOpResult,
    State_Idle,
    State_Interrupt
    ); 


  signal pc                  : unsigned(maxAddrBitIncIO downto 0);
  signal sp                  : unsigned(maxAddrBitIncIO downto minAddrBit);
  signal incSp               : unsigned(maxAddrBitIncIO downto minAddrBit);
  signal incIncSp            : unsigned(maxAddrBitIncIO downto minAddrBit);
  signal decSp               : unsigned(maxAddrBitIncIO downto minAddrBit);
  signal stackA              : unsigned(wordSize-1 downto 0);
  signal binaryOpResult      : unsigned(wordSize-1 downto 0);
  signal binaryOpResult2     : unsigned(wordSize-1 downto 0);
  signal multResult2         : unsigned(wordSize-1 downto 0);
  signal multResult3         : unsigned(wordSize-1 downto 0);
  signal multResult          : unsigned(wordSize-1 downto 0);
  signal multA               : unsigned(wordSize-1 downto 0);
  signal multB               : unsigned(wordSize-1 downto 0);
  signal stackB              : unsigned(wordSize-1 downto 0);
  signal idim_flag           : std_logic;
  signal busy                : std_logic;
  signal mem_writeEnable     : std_logic;
  signal mem_readEnable      : std_logic;
  signal mem_addr            : std_logic_vector(maxAddrBitIncIO downto minAddrBit);
  signal mem_delayAddr       : std_logic_vector(maxAddrBitIncIO downto minAddrBit);
  signal mem_delayReadEnable : std_logic;
  --
  signal inInterrupt         : std_logic;
  --
  signal decodeWord          : std_logic_vector(wordSize-1 downto 0);
  --
  --
  signal state               : StateType;
  signal insn                : InsnType;
  type   InsnArray is array(0 to wordBytes-1) of InsnType;
  signal decodedOpcode       : InsnArray;
  --
  type   OpcodeArray is array(0 to wordBytes-1) of std_logic_vector(7 downto 0);
  --
  signal opcode              : OpcodeArray;



  signal begin_inst        : std_logic;
  signal trace_opcode      : std_logic_vector(7 downto 0);
  signal trace_pc          : std_logic_vector(maxAddrBitIncIO downto 0);
  signal trace_sp          : std_logic_vector(maxAddrBitIncIO downto minAddrBit);
  signal trace_topOfStack  : std_logic_vector(wordSize-1 downto 0);
  signal trace_topOfStackB : std_logic_vector(wordSize-1 downto 0);

-- state machine.

begin


  traceFileGenerate :
  if Generate_Trace generate
    trace_file : trace port map (
      clk        => clk,
      begin_inst => begin_inst,
      pc         => trace_pc,
      opcode     => trace_opcode,
      sp         => trace_sp,
      memA       => trace_topOfStack,
      memB       => trace_topOfStackB,
      busy       => busy,
      intsp      => (others => 'U')
      );
  end generate;


  -- the memory subsystem will tell us one cycle later whether or 
  -- not it is busy
  out_mem_writeEnable                             <= mem_writeEnable;
  out_mem_readEnable                              <= mem_readEnable;
  out_mem_addr(maxAddrBitIncIO downto minAddrBit) <= mem_addr;
  out_mem_addr(minAddrBit-1 downto 0)             <= (others => '0');

  incSp    <= sp + 1;
  incIncSp <= sp + 2;
  decSp    <= sp - 1;


  opcodeControl : process(clk, reset)
    variable tOpcode        : std_logic_vector(OpCode_Size-1 downto 0);
    variable spOffset       : unsigned(4 downto 0);
    variable tSpOffset      : unsigned(4 downto 0);
    variable nextPC         : unsigned(maxAddrBitIncIO downto 0);
    variable tNextInsn      : InsnType;
    variable tDecodedOpcode : InsnArray;
    variable tMultResult    : unsigned(wordSize*2-1 downto 0);
  begin
    if reset = '1' then
      state <= State_Idle;
      break <= '0';
      sp    <= unsigned(spStart(maxAddrBitIncIO downto minAddrBit));

      pc              <= (others => '0');
      idim_flag       <= '0';
      begin_inst      <= '0';
      inInterrupt     <= '0';
      mem_writeEnable <= '0';
      mem_readEnable  <= '0';
      multA           <= (others => '0');
      multB           <= (others => '0');
      mem_writeMask   <= (others => '1');
    elsif rising_edge(clk) then
      -- we must multiply unconditionally to get pipelined multiplication
      tMultResult := multA * multB;
      multResult3 <= multResult2;
      multResult2 <= multResult;
      multResult  <= tMultResult(wordSize-1 downto 0);


      binaryOpResult2 <= binaryOpResult;  -- pipeline a bit.


      multA <= (others => DontCareValue);
      multB <= (others => DontCareValue);


      mem_addr        <= (others => DontCareValue);
      mem_readEnable  <= '0';
      mem_writeEnable <= '0';
      mem_write       <= (others => DontCareValue);

      if (mem_writeEnable = '1') and (mem_readEnable = '1') then
        report "read/write collision" severity failure;
      end if;




      spOffset(4)          := not opcode(to_integer(pc(byteBits-1 downto 0)))(4);
      spOffset(3 downto 0) := unsigned(opcode(to_integer(pc(byteBits-1 downto 0)))(3 downto 0));
      nextPC               := pc + 1;

      -- prepare trace snapshot
      trace_opcode      <= opcode(to_integer(pc(byteBits-1 downto 0)));
      trace_pc          <= std_logic_vector(pc);
      trace_sp          <= std_logic_vector(sp);
      trace_topOfStack  <= std_logic_vector(stackA);
      trace_topOfStackB <= std_logic_vector(stackB);
      begin_inst        <= '0';

      if (interrupt = '0') then
        -- Interrupt ended, we can serve ISR again
        inInterrupt <= '0';
      end if;

      case state is

        when State_Idle =>
          if enable = '1' then
            state <= State_Resync;
          end if;
          -- Initial state of ZPU, fetch top of stack + first instruction 

        when State_Resync =>
          if in_mem_busy = '0' then
            mem_addr       <= std_logic_vector(sp);
            mem_readEnable <= '1';
            state          <= State_Resync2;
          end if;

        when State_Resync2 =>
          if in_mem_busy = '0' then
            stackA         <= unsigned(mem_read);
            mem_addr       <= std_logic_vector(incSp);
            mem_readEnable <= '1';
            state          <= State_Resync3;
          end if;

        when State_Resync3 =>
          if in_mem_busy = '0' then
            stackB         <= unsigned(mem_read);
            mem_addr       <= std_logic_vector(pc(maxAddrBitIncIO downto minAddrBit));
            mem_readEnable <= '1';
            state          <= State_Decode;
          end if;

        when State_Decode =>
          if in_mem_busy = '0' then
            decodeWord <= mem_read;
            state      <= State_Decode2;
            -- Do not recurse into ISR while interrupt line is active
            if interrupt = '1' and inInterrupt = '0' and idim_flag = '0' then
              -- We got an interrupt, execute interrupt instead of next instruction
              inInterrupt                      <= '1';
              sp                               <= decSp;
              mem_writeEnable                  <= '1';
              mem_addr                         <= std_logic_vector(incSp);
              mem_write                        <= std_logic_vector(stackB);
              stackA                           <= (others => DontCareValue);
              stackA(maxAddrBitIncIO downto 0) <= pc;
              stackB                           <= stackA;
              pc                               <= to_unsigned(32, maxAddrBitIncIO+1);
              state                            <= State_Interrupt;
            end if; -- interrupt
          end if; -- in_mem_busy

        when State_Interrupt =>
          if in_mem_busy = '0' then
            mem_addr       <= std_logic_vector(pc(maxAddrBitIncIO downto minAddrBit));
            mem_readEnable <= '1';
            state          <= State_Decode;
            report "ZPU jumped to interrupt!" severity note;
          end if;

        when State_Decode2 =>
          -- decode 4 instructions in parallel
          for i in 0 to wordBytes-1 loop
            tOpcode := decodeWord((wordBytes-1-i+1)*8-1 downto (wordBytes-1-i)*8);

            tSpOffset(4)          := not tOpcode(4);
            tSpOffset(3 downto 0) := unsigned(tOpcode(3 downto 0));

            opcode(i) <= tOpcode;
            if (tOpcode(7 downto 7) = OpCode_Im) then
              tNextInsn := Insn_Im;
            elsif (tOpcode(7 downto 5) = OpCode_StoreSP) then
              if tSpOffset = 0 then
                tNextInsn := Insn_Pop;
              elsif tSpOffset = 1 then
                tNextInsn := Insn_PopDown;
              else
                tNextInsn := Insn_StoreSP;
              end if;
            elsif (tOpcode(7 downto 5) = OpCode_LoadSP) then
              if tSpOffset = 0 then
                tNextInsn := Insn_Dup;
              elsif tSpOffset = 1 then
                tNextInsn := Insn_DupStackB;
              else
                tNextInsn := Insn_LoadSP;
              end if;
            elsif (tOpcode(7 downto 5) = OpCode_Emulate) then
              tNextInsn := Insn_Emulate;
              if tOpcode(5 downto 0) = OpCode_Neqbranch then
                tNextInsn := Insn_Neqbranch;
              elsif tOpcode(5 downto 0) = OpCode_Eq then
                tNextInsn := Insn_Eq;
              elsif tOpcode(5 downto 0) = OpCode_Lessthan then
                tNextInsn := Insn_Lessthan;
              elsif tOpcode(5 downto 0) = OpCode_Lessthanorequal then
                --tNextInsn :=Insn_Lessthanorequal;
              elsif tOpcode(5 downto 0) = OpCode_Ulessthan then
                tNextInsn := Insn_Ulessthan;
              elsif tOpcode(5 downto 0) = OpCode_Ulessthanorequal then
                --tNextInsn :=Insn_Ulessthanorequal;
              elsif tOpcode(5 downto 0) = OpCode_Loadb then
                tNextInsn := Insn_Loadb;
              elsif tOpcode(5 downto 0) = OpCode_Mult then
                tNextInsn := Insn_Mult;
              elsif tOpcode(5 downto 0) = OpCode_Storeb then
                tNextInsn := Insn_Storeb;
              elsif tOpcode(5 downto 0) = OpCode_Pushspadd then
                tNextInsn := Insn_PushSPadd;
              elsif tOpcode(5 downto 0) = OpCode_Callpcrel then
                tNextInsn := Insn_CallPCrel;
              elsif tOpcode(5 downto 0) = OpCode_Call then
                --tNextInsn :=Insn_Call;
              elsif tOpcode(5 downto 0) = OpCode_Sub then
                tNextInsn := Insn_Sub;
              elsif tOpcode(5 downto 0) = OpCode_PopPCRel then
                --tNextInsn :=Insn_PopPCrel;
              end if;
            elsif (tOpcode(7 downto 4) = OpCode_AddSP) then
              if tSpOffset = 0 then
                tNextInsn := Insn_Shift;
              elsif tSpOffset = 1 then
                tNextInsn := Insn_AddTop;
              else
                tNextInsn := Insn_AddSP;
              end if;
            else
              case tOpcode(3 downto 0) is
                when OpCode_Nop =>
                  tNextInsn := Insn_Nop;
                when OpCode_PushSP =>
                  tNextInsn := Insn_PushSP;
                when OpCode_PopPC =>
                  tNextInsn := Insn_PopPC;
                when OpCode_Add =>
                  tNextInsn := Insn_Add;
                when OpCode_Or =>
                  tNextInsn := Insn_Or;
                when OpCode_And =>
                  tNextInsn := Insn_And;
                when OpCode_Load =>
                  tNextInsn := Insn_Load;
                when OpCode_Not =>
                  tNextInsn := Insn_Not;
                when OpCode_Flip =>
                  tNextInsn := Insn_Flip;
                when OpCode_Store =>
                  tNextInsn := Insn_Store;
                when OpCode_PopSP =>
                  tNextInsn := Insn_PopSP;
                when others =>
                  tNextInsn := Insn_Break;

              end case; -- tOpcode(3 downto 0)
            end if; -- tOpcode
            tDecodedOpcode(i) := tNextInsn;
            
          end loop; -- 0 to wordBytes-1

          insn <= tDecodedOpcode(to_integer(pc(byteBits-1 downto 0)));

          -- once we wrap, we need to fetch
          tDecodedOpcode(0) := Insn_InsnFetch;

          decodedOpcode <= tDecodedOpcode;
          state         <= State_Execute;



          -- Each instruction must:
          --
          -- 1. set idim_flag
          -- 2. increase PC if applicable
          -- 3. set next state if appliable
          -- 4. do it's operation
          
        when State_Execute =>
          insn <= decodedOpcode(to_integer(nextPC(byteBits-1 downto 0)));

          case insn is

            when Insn_InsnFetch =>
              state <= State_Fetch;

            when Insn_Im =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '1';
                pc         <= pc + 1;

                if idim_flag = '1' then
                  stackA(wordSize-1 downto 7) <= stackA(wordSize-8 downto 0);
                  stackA(6 downto 0)          <= unsigned(opcode(to_integer(pc(byteBits-1 downto 0)))(6 downto 0));
                else
                  mem_writeEnable <= '1';
                  mem_addr        <= std_logic_vector(incSp);
                  mem_write       <= std_logic_vector(stackB);
                  stackB          <= stackA;
                  sp              <= decSp;
                  for i in wordSize-1 downto 7 loop
                    stackA(i) <= opcode(to_integer(pc(byteBits-1 downto 0)))(6);
                  end loop;
                  stackA(6 downto 0) <= unsigned(opcode(to_integer(pc(byteBits-1 downto 0)))(6 downto 0));
                end if; -- idim_flag
              end if; -- in_mem_busy

            when Insn_StoreSP =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                state      <= State_StoreSP2;

                mem_writeEnable <= '1';
                mem_addr        <= std_logic_vector(sp+spOffset);
                mem_write       <= std_logic_vector(stackA);
                stackA          <= stackB;
                sp              <= incSp;
              end if;

              
            when Insn_LoadSP =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                state      <= State_LoadSP2;

                sp              <= decSp;
                mem_writeEnable <= '1';
                mem_addr        <= std_logic_vector(incSp);
                mem_write       <= std_logic_vector(stackB);
              end if;

            when Insn_Emulate =>
              if in_mem_busy = '0' then
                begin_inst                       <= '1';
                idim_flag                        <= '0';
                sp                               <= decSp;
                mem_writeEnable                  <= '1';
                mem_addr                         <= std_logic_vector(incSp);
                mem_write                        <= std_logic_vector(stackB);
                stackA                           <= (others => DontCareValue);
                stackA(maxAddrBitIncIO downto 0) <= pc + 1;
                stackB                           <= stackA;

                -- The emulate address is:
                --        98 7654 3210
                -- 0000 00aa aaa0 0000
                pc             <= (others => '0');
                pc(9 downto 5) <= unsigned(opcode(to_integer(pc(byteBits-1 downto 0)))(4 downto 0));
                state          <= State_Fetch;
              end if; -- in_mem_busy

            when Insn_CallPCrel =>
              if in_mem_busy = '0' then
                begin_inst                       <= '1';
                idim_flag                        <= '0';
                stackA                           <= (others => DontCareValue);
                stackA(maxAddrBitIncIO downto 0) <= pc + 1;

                pc    <= pc + stackA(maxAddrBitIncIO downto 0);
                state <= State_Fetch;
              end if;

            when Insn_Call =>
              if in_mem_busy = '0' then
                begin_inst                       <= '1';
                idim_flag                        <= '0';
                stackA                           <= (others => DontCareValue);
                stackA(maxAddrBitIncIO downto 0) <= pc + 1;
                pc                               <= stackA(maxAddrBitIncIO downto 0);
                state                            <= State_Fetch;
              end if;

            when Insn_AddSP =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                state      <= State_AddSP2;

                mem_readEnable <= '1';
                mem_addr       <= std_logic_vector(sp+spOffset);
              end if;

            when Insn_PushSP =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                pc         <= pc + 1;

                sp                                        <= decSp;
                stackA                                    <= (others => '0');
                stackA(maxAddrBitIncIO downto minAddrBit) <= sp;
                stackB                                    <= stackA;
                mem_writeEnable                           <= '1';
                mem_addr                                  <= std_logic_vector(incSp);
                mem_write                                 <= std_logic_vector(stackB);
              end if;

            when Insn_PopPC =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                pc         <= stackA(maxAddrBitIncIO downto 0);
                sp         <= incSp;

                mem_writeEnable <= '1';
                mem_addr        <= std_logic_vector(incSp);
                mem_write       <= std_logic_vector(stackB);
                state           <= State_Resync;
              end if;

            when Insn_PopPCrel =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                pc         <= stackA(maxAddrBitIncIO downto 0) + pc;
                sp         <= incSp;

                mem_writeEnable <= '1';
                mem_addr        <= std_logic_vector(incSp);
                mem_write       <= std_logic_vector(stackB);
                state           <= State_Resync;
              end if;

            when Insn_Add =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                stackA     <= stackA + stackB;

                mem_readEnable <= '1';
                mem_addr       <= std_logic_vector(incIncSp);
                sp             <= incSp;
                state          <= State_Popped;
              end if;

            when Insn_Sub =>
              if in_mem_busy = '0' then
                begin_inst     <= '1';
                idim_flag      <= '0';
                binaryOpResult <= stackB - stackA;
                state          <= State_BinaryOpResult;
              end if;

            when Insn_Pop =>
              if in_mem_busy = '0' then
                begin_inst     <= '1';
                idim_flag      <= '0';
                mem_addr       <= std_logic_vector(incIncSp);
                mem_readEnable <= '1';
                sp             <= incSp;
                stackA         <= stackB;
                state          <= State_Popped;
              end if;

            when Insn_PopDown =>
              if in_mem_busy = '0' then
                                        -- PopDown leaves top of stack unchanged
                begin_inst     <= '1';
                idim_flag      <= '0';
                mem_addr       <= std_logic_vector(incIncSp);
                mem_readEnable <= '1';
                sp             <= incSp;
                state          <= State_Popped;
              end if;

            when Insn_Or =>
              if in_mem_busy = '0' then
                begin_inst     <= '1';
                idim_flag      <= '0';
                stackA         <= stackA or stackB;
                mem_readEnable <= '1';
                mem_addr       <= std_logic_vector(incIncSp);
                sp             <= incSp;
                state          <= State_Popped;
              end if;

            when Insn_And =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';

                stackA         <= stackA and stackB;
                mem_readEnable <= '1';
                mem_addr       <= std_logic_vector(incIncSp);
                sp             <= incSp;
                state          <= State_Popped;
              end if;

            when Insn_Eq =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';

                binaryOpResult <= (others => '0');
                if (stackA = stackB) then
                  binaryOpResult(0) <= '1';
                end if;
                state <= State_BinaryOpResult;
              end if;

            when Insn_Ulessthan =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';

                binaryOpResult <= (others => '0');
                if (stackA < stackB) then
                  binaryOpResult(0) <= '1';
                end if;
                state <= State_BinaryOpResult;
              end if;

            when Insn_Ulessthanorequal =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';

                binaryOpResult <= (others => '0');
                if (stackA     <= stackB) then
                  binaryOpResult(0) <= '1';
                end if;
                state <= State_BinaryOpResult;
              end if;

            when Insn_Lessthan =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';

                binaryOpResult <= (others => '0');
                if (signed(stackA) < signed(stackB)) then
                  binaryOpResult(0) <= '1';
                end if;
                state <= State_BinaryOpResult;
              end if;

            when Insn_Lessthanorequal =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';

                binaryOpResult     <= (others => '0');
                if (signed(stackA) <= signed(stackB)) then
                  binaryOpResult(0) <= '1';
                end if;
                state <= State_BinaryOpResult;
              end if;

            when Insn_Load =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                state      <= State_Load2;

                mem_addr       <= std_logic_vector(stackA(maxAddrBitIncIO downto minAddrBit));
                mem_readEnable <= '1';
              end if;

            when Insn_Dup =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                pc         <= pc + 1;

                sp              <= decSp;
                stackB          <= stackA;
                mem_write       <= std_logic_vector(stackB);
                mem_addr        <= std_logic_vector(incSp);
                mem_writeEnable <= '1';
              end if;

            when Insn_DupStackB =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                pc         <= pc + 1;

                sp              <= decSp;
                stackA          <= stackB;
                stackB          <= stackA;
                mem_write       <= std_logic_vector(stackB);
                mem_addr        <= std_logic_vector(incSp);
                mem_writeEnable <= '1';
              end if;

            when Insn_Store =>
              if in_mem_busy = '0' then
                begin_inst      <= '1';
                idim_flag       <= '0';
                pc              <= pc + 1;
                mem_addr        <= std_logic_vector(stackA(maxAddrBitIncIO downto minAddrBit));
                mem_write       <= std_logic_vector(stackB);
                mem_writeEnable <= '1';
                sp              <= incIncSp;
                state           <= State_Resync;
              end if;

            when Insn_PopSP =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                pc         <= pc + 1;

                mem_write       <= std_logic_vector(stackB);
                mem_addr        <= std_logic_vector(incSp);
                mem_writeEnable <= '1';
                sp              <= stackA(maxAddrBitIncIO downto minAddrBit);
                state           <= State_Resync;
              end if;

            when Insn_Nop =>
              begin_inst <= '1';
              idim_flag  <= '0';
              pc         <= pc + 1;

            when Insn_Not =>
              begin_inst <= '1';
              idim_flag  <= '0';
              pc         <= pc + 1;

              stackA     <= not stackA;

            when Insn_Flip =>
              begin_inst <= '1';
              idim_flag  <= '0';
              pc         <= pc + 1;

              for i in 0 to wordSize-1 loop
                stackA(i) <= stackA(wordSize-1-i);
              end loop;

            when Insn_AddTop =>
              begin_inst <= '1';
              idim_flag  <= '0';
              pc         <= pc + 1;

              stackA     <= stackA + stackB;

            when Insn_Shift =>
              begin_inst <= '1';
              idim_flag  <= '0';
              pc         <= pc + 1;

              stackA(wordSize-1 downto 1) <= stackA(wordSize-2 downto 0);
              stackA(0)                   <= '0';

            when Insn_PushSPadd =>
              begin_inst <= '1';
              idim_flag  <= '0';
              pc         <= pc + 1;

              stackA                                    <= (others => '0');
              stackA(maxAddrBitIncIO downto minAddrBit) <= stackA(maxAddrBitIncIO-minAddrBit downto 0)+sp;

            when Insn_Neqbranch =>
              -- branches are almost always taken as they form loops
              begin_inst <= '1';
              idim_flag  <= '0';
              sp         <= incIncSp;
              if (stackB /= 0) then
                pc <= stackA(maxAddrBitIncIO downto 0) + pc;
              else
                pc <= pc + 1;
              end if;
              -- need to fetch stack again.                           
              state <= State_Resync;

            when Insn_Mult =>
              begin_inst <= '1';
              idim_flag  <= '0';

              multA <= stackA;
              multB <= stackB;
              state <= State_Mult2;

            when Insn_Break =>
              report "Break instruction encountered" severity failure;
              break <= '1';

            when Insn_Loadb =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                state      <= State_Loadb2;

                mem_addr       <= std_logic_vector(stackA(maxAddrBitIncIO downto minAddrBit));
                mem_readEnable <= '1';
              end if;

            when Insn_Storeb =>
              if in_mem_busy = '0' then
                begin_inst <= '1';
                idim_flag  <= '0';
                state      <= State_Storeb2;

                mem_addr       <= std_logic_vector(stackA(maxAddrBitIncIO downto minAddrBit));
                mem_readEnable <= '1';
              end if;
              
            when others =>
              sp    <= (others => DontCareValue);
              report "Illegal instruction" severity failure;
              break <= '1';

          end case; -- insn/State_Execute


        when State_StoreSP2 =>
          if in_mem_busy = '0' then
            mem_addr       <= std_logic_vector(incSp);
            mem_readEnable <= '1';
            state          <= State_Popped;
          end if;

        when State_LoadSP2 =>
          if in_mem_busy = '0' then
            state          <= State_LoadSP3;
            mem_readEnable <= '1';
            mem_addr       <= std_logic_vector(sp+spOffset+1);
          end if;

        when State_LoadSP3 =>
          if in_mem_busy = '0' then
            pc     <= pc + 1;
            state  <= State_Execute;
            stackB <= stackA;
            stackA <= unsigned(mem_read);
          end if;

        when State_AddSP2 =>
          if in_mem_busy = '0' then
            pc     <= pc + 1;
            state  <= State_Execute;
            stackA <= stackA + unsigned(mem_read);
          end if;

        when State_Load2 =>
          if in_mem_busy = '0' then
            stackA <= unsigned(mem_read);
            pc     <= pc + 1;
            state  <= State_Execute;
          end if;

        when State_Loadb2 =>
          if in_mem_busy = '0' then
            stackA             <= (others => '0');
            stackA(7 downto 0) <= unsigned(mem_read(((wordBytes-1-to_integer(stackA(byteBits-1 downto 0)))*8+7) downto (wordBytes-1-to_integer(stackA(byteBits-1 downto 0)))*8));
            pc                 <= pc + 1;
            state              <= State_Execute;
          end if;

        when State_Storeb2 =>
          if in_mem_busy = '0' then
            mem_addr                                                                                                                              <= std_logic_vector(stackA(maxAddrBitIncIO downto minAddrBit));
            mem_write                                                                                                                             <= mem_read;
            mem_write(((wordBytes-1-to_integer(stackA(byteBits-1 downto 0)))*8+7) downto (wordBytes-1-to_integer(stackA(byteBits-1 downto 0)))*8) <= std_logic_vector(stackB(7 downto 0));
            mem_writeEnable                                                                                                                       <= '1';
            pc                                                                                                                                    <= pc + 1;
            sp                                                                                                                                    <= incIncSp;
            state                                                                                                                                 <= State_Resync;
          end if;

        when State_Fetch =>
          if in_mem_busy = '0' then
            mem_addr       <= std_logic_vector(pc(maxAddrBitIncIO downto minAddrBit));
            mem_readEnable <= '1';
            state          <= State_Decode;
          end if;

        when State_Mult2 =>
          state <= State_Mult3;

        when State_Mult3 =>
          state <= State_Mult4;

        when State_Mult4 =>
          state <= State_Mult5;

        when State_Mult5 =>
          if in_mem_busy = '0' then
            stackA         <= multResult3;
            mem_readEnable <= '1';
            mem_addr       <= std_logic_vector(incIncSp);
            sp             <= incSp;
            state          <= State_Popped;
          end if;

        when State_BinaryOpResult =>
          state <= State_BinaryOpResult2;

        when State_BinaryOpResult2 =>
          mem_readEnable <= '1';
          mem_addr       <= std_logic_vector(incIncSp);
          sp             <= incSp;
          stackA         <= binaryOpResult2;
          state          <= State_Popped;

        when State_Popped =>
          if in_mem_busy = '0' then
            pc     <= pc + 1;
            stackB <= unsigned(mem_read);
            state  <= State_Execute;
          end if;

        when others =>
          sp    <= (others => DontCareValue);
          report "Illegal state" severity failure;
          break <= '1';

      end case; -- state
    end if; -- clk'event
  end process;



end behave;
