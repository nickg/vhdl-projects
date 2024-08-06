-------------------------------------------------------------------------------
--                                                                           --
--  AES86 - VHDL 128bits AES IP Core                                         --
--                                                                           --
--  AES86 is released as open-source under the GNU GPL license. This means   --
--  that designs based on AES86 must be distributed in full source code      --
--  under the same license.                                                  --
--                                                                           --
-------------------------------------------------------------------------------
--																			 --
--  This library is free software; you can redistribute it and/or            --
--  modify it under the terms of the GNU Lesser General Public               --
--  License as published by the Free Software Foundation; either             --
--  version 2.1 of the License, or (at your option) any later version.       --
--                                                                           --
--  This library is distributed in the hope that it will be useful,          --
--  but WITHOUT ANY WARRANTY; without even the implied warranty of           --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        --
--  Lesser General Public License for more details.                          --
--                                                                           --
--  Full details of the license can be found in the file "copying.txt".      --
--                                                                           --
--  You should have received a copy of the GNU Lesser General Public         --
--  License along with this library; if not, write to the Free Software      --
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA  --
--                                                                           --
-------------------------------------------------------------------------------
--
-- VHDL Entity AES_Web_lib.AES_cpu_top_tester.behaviour
--
-- Created: by - Hans 22/05/2005
--
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;
LIBRARY std;
USE std.TEXTIO.ALL;
LIBRARY AES_WEB_LIB;
USE AES_WEB_LIB.AES_pack.ALL;

-- LIBRARY modelsim_lib;
-- USE modelsim_lib.util.ALL;

ENTITY AES_cpu_top_tester IS
   GENERIC( 
      FULL_TEST : integer                      := 1;
      TESTS     : std_logic_vector(3 downto 0) := "1000"
   );
   PORT( 
      clk    : IN     std_logic;
      int    : IN     std_logic;
      resetn : IN     std_logic;
      addr   : OUT    std_logic_vector (6 DOWNTO 0);
      csn    : OUT    std_logic;
      rdn    : OUT    std_logic;
      wen    : OUT    std_logic;
      dbus   : INOUT  std_logic_vector (7 DOWNTO 0)
   );

-- Declarations

END AES_cpu_top_tester ;

--
ARCHITECTURE behaviour OF AES_cpu_top_tester IS

signal key_s : std_logic_vector(127 downto 0);
signal dout_s: std_logic_vector(127 downto 0);
signal temp_s: std_logic_vector(127 downto 0);
signal data_s: std_logic_vector(7 downto 0);

signal IV_s  : std_logic_vector(127 downto 0);          -- Used for MTI Signalspy

BEGIN
    
    -- ------------------------------------------------------------------------------
    -- -- Modelsim Signalspy process to mirror internal IV register to testbench 
    -- ------------------------------------------------------------------------------
    -- process
        -- begin
            -- init_signal_spy("/aes_cpu_top_tb/i0/i8/iv_reg","IV_s",1);
            -- wait;
    -- end process;

    process

        procedure write_dma_cycle(                          -- write length_p bytes to AES core   
            signal addr_p : in std_logic_vector(6 downto 0);-- Port Address
            signal dbus_p : in std_logic_vector(127 downto 0);
            signal length_p : in integer) is 
            variable count_v:integer:=0;            
            begin 
                ------------------------------------------------------------------------------
                -- Write 16+1 bytes 
                ------------------------------------------------------------------------------
                for i in 0 to length_p-1 loop
                
                    wait until rising_edge(clk);                -- sync to first rising edge
                    wait for 10 ns;
                    addr <= addr_p + CONV_STD_LOGIC_VECTOR(i,7);
                    wait for 10 ns;
                    csn <= '0';
                    wait until rising_edge(clk);                    
                    wait for 5 ns;
                    wen <= '0';
                    wait until rising_edge(clk);    
                    wait for 5 ns;
                    if (i<16) then
                        dbus <= dbus_p(((i+1)*8)-1 downto i*8);
                    else 
                        dbus <= X"00"; -- dummy write to trigger action
                    end if;
                    wait until rising_edge(clk);               
                    wait for 5 ns;
                    wen     <= '1';
                    csn     <= '1'; 
                    addr    <= (others => '1');
                    dbus    <= (others => 'Z'); 
                    wait for 0 ns;                              
                end loop;                                                                       
        end write_dma_cycle;

        procedure write_reg(                        -- write byte to AES register   
            signal addr_p : in std_logic_vector(6 downto 0);-- Port Address
            signal dbus_p : in std_logic_vector(7 downto 0)) is 
            begin 
                wait until rising_edge(clk);                -- sync to first rising edge
                wait for 10 ns;
                addr <= addr_p;
                wait for 10 ns;
                csn <= '0';
                wait until rising_edge(clk);                    
                wait for 5 ns;
                wen <= '0';
                wait until rising_edge(clk);    
                wait for 5 ns;
                dbus <= dbus_p; 
                wait until rising_edge(clk);               
                wait for 5 ns;
                wen     <= '1';
                csn     <= '1'; 
                addr    <= (others => '1');
                dbus    <= (others => 'Z'); 
                wait for 0 ns;                                                                                      
        end write_reg;

        procedure read_reg(                         -- Read AES register   
            signal addr_p : in std_logic_vector(6 downto 0);-- Port Address
            signal dbus_p : out std_logic_vector(7 downto 0)) is 
            begin 
                wait until rising_edge(clk);                -- sync to first rising edge
                wait for 10 ns;
                addr <= addr_p;
                wait for 10 ns;
                csn <= '0';
                wait until rising_edge(clk);                    
                wait for 5 ns;
                rdn <= '0';
                wait until rising_edge(clk);    
                wait for 5 ns;
                dbus_p <= dbus; 
                wait until rising_edge(clk);               
                wait for 5 ns;
                rdn     <= '1';
                csn     <= '1'; 
                addr    <= (others => '1');
                dbus    <= (others => 'Z'); 
                wait for 0 ns;                                                                                      
        end read_reg;

        procedure read_dma_cycle(                           -- Read 16 bytes from AES core   
            signal addr_p : in std_logic_vector(6 downto 0);-- Port Address
            signal dbus_p : out std_logic_vector(127 downto 0)) is 
            variable count_v:integer:=0;            
            begin 
                ------------------------------------------------------------------------------
                -- Write 16 bytes 
                ------------------------------------------------------------------------------
                for i in 0 to 15 loop
                
                    wait until rising_edge(clk);                -- sync to first rising edge
                    wait for 10 ns;
                    addr <= addr_p + CONV_STD_LOGIC_VECTOR(i,7);
                    wait for 10 ns;
                    csn <= '0';
                    wait until rising_edge(clk);                    
                    wait for 5 ns;
                    rdn <= '0';
                    wait until rising_edge(clk);    
                    wait for 5 ns;
                    dbus_p(((i+1)*8)-1 downto i*8)<= dbus;      -- Read from databus and store in vector
                    wait until rising_edge(clk);               
                    wait for 5 ns;
                    rdn     <= '1';
                    csn     <= '1'; 
                    addr    <= (others => '1');
                    dbus    <= (others => 'Z'); 
                    wait for 0 ns;                              
                end loop;                                                                       
        end read_dma_cycle;


        variable L : line; -- used for monitor

          begin     
                       
            wait for 10 ns;
            
            wen     <= '1';
            rdn     <= '1';
            csn     <= '1'; 
            dbus    <= (others => 'Z');

            wait until rising_edge(resetn);
            wait until rising_edge(clk);

            write(L,string'(""));
            writeline(output,L);  
            write(L,string'("Note: This testbench may take several hours to complete on a fast PC!"));  
            writeline(output,L);
            write(L,string'("Note: To complete the full test, the AES core is iterated 16 million times!"));    
            writeline(output,L);

            -- ***********************************************************************************
            -- First Test ECB encrypt mode, 4 million interations through the core
            -- ***********************************************************************************
            if (TESTS(0)='1') then
                
            key_s   <= (others => '0');
            dout_s  <= (others => '0');

            write(L,string'("****** Test1 : Start Monte Carlo AES Encrypt ******"));
            writeline(output,L);


            for i in 0 to TEST_ITERATIONS(FULL_TEST) loop   -- 399
            
                data_s <= X"05";                            -- Enable DKEY_Valid!! Interrupts
                write_reg(WR_CTRL_ADDR,data_s);
                write_dma_cycle(WR_KEY_ADDR, key_s,WR_FRAME_TRIGGER);-- Write Key data

                wait until rising_edge(int);                -- Wait for interrupt
                read_reg(RD_STATUS_ADDR,data_s);            -- Read Status Register to clear interrupt

                write(L,string'("I="));                     -- Display Iteration number
                write(L,i);         
                writeline(output,L);

                write(L,string'("Key="));                   -- Display input key
                write(L,std_to_hex(key_s));
                writeline(output,L);

                write(L,string'("PT="));                    -- Display input data
                write(L,std_to_hex(dout_s));                    
                writeline(output,L);

                for j in 0 to 9999 loop                     -- 9999 
                
                    data_s <= X"09";                        -- Enable Data_Valid Interrupts
                    write_reg(WR_CTRL_ADDR,data_s);

                    write_dma_cycle(WR_ENC_ADDR, dout_s,WR_FRAME_TRIGGER);-- Write Encrypt data and start process
                    
                    wait until rising_edge(int);            -- Wait for interrupt
                    read_reg(RD_STATUS_ADDR,data_s);        -- Clear interrupt

                    read_dma_cycle(RD_OUT_ADDR, dout_s);    -- Read Results

                end loop;
                        
                write(L,string'("CT="));                    -- Write Encrypted data
                write(L,std_to_hex(dout_s));                    
                writeline(output,L);

                key_s <= key_s XOR dout_s;                  -- Next XOR the key and output result
            
            end loop;


            if (dout_s=TEST1_RESULTS(FULL_TEST)) then 
                write(L,string'("************ Test Passed Successfully *************"));
                writeline(output,L);
                write(L,string'(""));
                writeline(output,L);
            else
                write(L,string'("************* ECB Encrypt Test Failed!!! ***************"));
                writeline(output,L);
                write(L,string'("Expected Results: CT="));
                write(L,std_to_hex(TEST1_RESULTS(FULL_TEST)));
                writeline(output,L);
                assert false report "Test failed" severity Failure;
            end if;

            end if;         -- TESTS(0)

            -- ***********************************************************************************
            -- Second Test ECB decrypt mode, 4 million interations through the core
            -- ***********************************************************************************
            if (TESTS(1)='1') then

            key_s   <= (others => '0');
            dout_s  <= (others => '0');

            write(L,string'("****** Test2 : Start Monte Carlo AES Decrypt ******"));
            writeline(output,L);

            for i in 0 to TEST_ITERATIONS(FULL_TEST) loop   -- 399
            
                data_s <= X"05";                            -- Enable DKEY_Valid Interrupts
                write_reg(WR_CTRL_ADDR,data_s);

                write_dma_cycle(WR_KEY_ADDR, key_s,WR_FRAME_TRIGGER);-- Write Key data

                wait until rising_edge(int);                -- Wait for interrupt
                read_reg(RD_STATUS_ADDR,data_s);            -- Read Status Register to clear interrupt

                write(L,string'("I="));
                write(L,i);                                 -- Display Iteration number
                writeline(output,L);

                write(L,string'("Key="));                   -- Display input key
                write(L,std_to_hex(key_s));
                writeline(output,L);

                write(L,string'("CT="));                    -- Display input data
                write(L,std_to_hex(dout_s));                    
                writeline(output,L);
                            
                for j in 0 to 9999 loop                     -- 9999 
                
                    data_s <= X"09";                        -- Enable Data_Valid Interrupts
                    write_reg(WR_CTRL_ADDR,data_s);

                    write_dma_cycle(WR_DEC_ADDR, dout_s,WR_FRAME_TRIGGER);-- Write Decrypt data and start process
                    
                    wait until rising_edge(int);            -- Wait for interrupt
                    read_reg(RD_STATUS_ADDR,data_s);        -- Clear interrupt

                    read_dma_cycle(RD_OUT_ADDR, dout_s);    -- Read Results

                end loop;
                        
                write(L,string'("PT="));                    -- Write Decrypted data
                write(L,std_to_hex(dout_s));                    
                writeline(output,L);
                          
                key_s <= key_s XOR dout_s;                  -- Next XOR the key and output result 
           
            end loop;


            if (dout_s=TEST2_RESULTS(FULL_TEST)) then 
                write(L,string'("************ Test Passed Successfully *************"));
                writeline(output,L);
                write(L,string'(""));
                writeline(output,L);
            else
                write(L,string'("************* ECB Decrypt Test Failed!!! ***************"));
                writeline(output,L);
                write(L,string'("Expected Results: PT="));
                write(L,std_to_hex(TEST2_RESULTS(FULL_TEST)));
                writeline(output,L);
                assert false report "Test failed" severity Failure;
            end if;

            end if;         -- TESTS(1)


            -- ***********************************************************************************
            -- Third Test CBC Encrypt mode, 4 million interations through the core
            -- ***********************************************************************************
            if (TESTS(2)='1') then
            
            key_s   <= (others => '0');
            dout_s  <= (others => '0');
            temp_s  <= (others => '0');

            write(L,string'("****** Test3 : Start Monte Carlo CBC Encrypt ******"));
            writeline(output,L);

            write_dma_cycle(WR_IV_ADDR, key_s,WR_FRAME);    -- Clear IV block                

            for i in 0 to TEST_ITERATIONS(FULL_TEST) loop   -- 399
            
                data_s <= X"15";                            -- Enable DKEY_Valid!! Interrupts& CBC mode
                write_reg(WR_CTRL_ADDR,data_s);
                write_dma_cycle(WR_KEY_ADDR, key_s,WR_FRAME_TRIGGER); -- write key

                wait until rising_edge(int);                -- Wait for Key ready interrupt
                read_reg(RD_STATUS_ADDR,data_s);

                write(L,string'("I="));write(L,i);          -- Display Iteration number
                writeline(output,L);

                write(L,string'("Key="));                   -- Display input key
                write(L,std_to_hex(key_s));
                writeline(output,L);

                write(L,string'("IV="));                    -- Display IV register (requires MTI signalspy)
                write(L,std_to_hex(IV_s));
                writeline(output,L);

                write(L,string'("PT="));                    -- Display input data
                write(L,std_to_hex(dout_s));                    
                writeline(output,L);
                                            
                for j in 0 to 9999 loop                     -- 9999 
                
                    data_s <= X"19";                        -- Enable Data_Valid Interrupts & CBC mode
                    write_reg(WR_CTRL_ADDR,data_s);

                    write_dma_cycle(WR_ENC_ADDR, dout_s,WR_FRAME_TRIGGER);  -- Write plaintext data and start process
                    
                    wait until rising_edge(int);            -- Wait for interrupt
                    read_reg(RD_STATUS_ADDR,data_s);

                    dout_s <= temp_s;
                    read_dma_cycle(RD_OUT_ADDR, temp_s);    -- Read Cipher text Results

                end loop;
                        
                write(L,string'("CT="));                    -- Write cipher text
                write(L,std_to_hex(temp_s));                    
                writeline(output,L);
                          
                -- Next XOR the key and output result -> load new key
                -- Data out -> Data in
                key_s <= key_s XOR temp_s;

            end loop;


            if (temp_s=TEST3_RESULTS(FULL_TEST)) then 
                write(L,string'("************ Test Passed Successfully *************"));
                writeline(output,L);
                write(L,string'(""));
                writeline(output,L);
            else
                write(L,string'("************* CBC Encrypt Test Failed!!! ***************"));
                writeline(output,L);
                write(L,string'("Expected Results: CT="));
                write(L,std_to_hex(TEST3_RESULTS(FULL_TEST)));
                writeline(output,L);
                assert false report "Test failed" severity Failure;
            end if;

            end if;         -- TESTS(2)


            -- ***********************************************************************************
            -- Fourth Test CBC decrypt mode, 4 million interations through the core
            -- ***********************************************************************************
            if (TESTS(3)='1') then

            key_s   <= (others => '0');
            dout_s  <= (others => '0');

            write(L,string'("****** Test4 : Start Monte Carlo CBC Decrypt ******"));
            writeline(output,L);

            write_dma_cycle(WR_IV_ADDR, key_s,WR_FRAME);    -- Clear IV block                

            for i in 0 to TEST_ITERATIONS(FULL_TEST) loop   -- 399
            
                data_s <= X"15";                            -- Enable DKEY_Valid Interrupts
                write_reg(WR_CTRL_ADDR,data_s);
                write_dma_cycle(WR_KEY_ADDR, key_s,WR_FRAME_TRIGGER);  -- write key

                wait until rising_edge(int);                -- Wait for Key ready interrupt
                read_reg(RD_STATUS_ADDR,data_s);

                write(L,string'("I="));write(L,i);          -- Display Iteration number
                writeline(output,L);

                write(L,string'("Key="));                   -- Display input key
                write(L,std_to_hex(key_s));
                writeline(output,L);

                write(L,string'("CT="));                    -- Display input data
                write(L,std_to_hex(dout_s));                    
                writeline(output,L);
                            
                for j in 0 to 9999 loop                     -- 9999 
                
                    data_s <= X"19";                        -- Enable Data_Valid Interrupts & CBC mode
                    write_reg(WR_CTRL_ADDR,data_s);

                    write_dma_cycle(WR_DEC_ADDR, dout_s,WR_FRAME_TRIGGER);  -- Write Decrypt data and start process

                    wait until rising_edge(int);            -- Wait for interrupt
                    read_reg(RD_STATUS_ADDR,data_s);

                    read_dma_cycle(RD_OUT_ADDR, dout_s);    -- Read Results

                end loop;
                        
                write(L,string'("PT="));                    -- Write Decrypted data
                write(L,std_to_hex(dout_s));                    
                writeline(output,L);
                          
                -- Next XOR the key and output result -> load new key
                -- Data out -> Data in
                key_s <= key_s XOR dout_s;

            end loop;

            if (dout_s=TEST4_RESULTS(FULL_TEST)) then 
                write(L,string'("************ Test Passed Successfully *************"));
                writeline(output,L);
                write(L,string'(""));
                writeline(output,L);
            else
                write(L,string'("************* CBC Decrypt Test Failed!!! ***************"));
                writeline(output,L);
                write(L,string'("Expected Results: PT="));
                write(L,std_to_hex(TEST4_RESULTS(FULL_TEST)));
                writeline(output,L);
                assert false report "Test failed" severity Failure;
            end if;

            end if;         -- TESTS(3)


            assert false report "*** END OF TEST ***" severity Failure;
      end process;
END ARCHITECTURE behaviour;
