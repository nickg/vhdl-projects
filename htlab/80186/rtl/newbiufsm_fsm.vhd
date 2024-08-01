-------------------------------------------------------------------------------
--  HTL80186 - CPU core                                                      --
--  Copyright (C) 2002-2013 HT-LAB                                           --
--                                                                           --
--  Web          : http://www.ht-lab.com                                     --
--  Contact      : support@ht-lab.com                                        --
--  Sales        : sales@ht-lab.com                                          --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Please review the terms of the license agreement before using this file.  --
-- If you are not an authorized user, please destroy this source code file   --
-- and notify HT-Lab immediately that you inadvertently received an un-      --
-- authorized copy.                                                          --
-------------------------------------------------------------------------------
-- Project       : HTL80186                                                  --
-- Module        : newbiufsm                                                 --
-- Library       : I80186                                                    --
--                                                                           --
-- Version       : 1.0  05/21/02   Created HT-LAB                            --
--               : 1.1  22/09/13   Removed spurious sERROR state             --
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY newbiufsm IS
   PORT(
      bhe_s        : IN     std_logic;
      bus8         : IN     std_logic;
      clk          : IN     std_logic;
      flush_coming : IN     std_logic;
      flush_req    : IN     std_logic;
      halt         : IN     std_logic;
      hold         : IN     std_logic;
      irq_req      : IN     std_logic;
      irq_type     : IN     std_logic_vector ( 3 DOWNTO 0 );
      memio        : IN     std_logic;
      oddword      : IN     std_logic;
      opc_req      : IN     std_logic;
      read_req     : IN     std_logic;
      ready        : IN     std_logic;
      regcnt       : IN     std_logic_vector ( 3 DOWNTO 0 );
      regnbok      : IN     std_logic;
      reset        : IN     std_logic;
      write_req    : IN     std_logic;
      ale          : OUT    std_logic;
      bhe          : OUT    std_logic;
      biustat      : OUT    std_logic_vector (2 DOWNTO 0);
      flush_ack    : OUT    std_logic;
      hlda         : OUT    std_logic;
      inta         : OUT    std_logic;
      irq_ack      : OUT    std_logic;
      irq_clr      : OUT    std_logic;
      irq_cycle2   : OUT    std_logic;
      opc_ack      : OUT    std_logic;
      rdn          : OUT    std_logic;
      rw_ack       : OUT    std_logic;
      rw_cycle     : OUT    std_logic;
      rw_cycle2    : OUT    std_logic;
      wr_mdbus     : OUT    std_logic;
      wrn          : OUT    std_logic;
      wrq          : OUT    std_logic
   );

-- Declarations

END newbiufsm ;


ARCHITECTURE fsm OF newbiufsm IS

   -- Architecture Declarations
   signal twocycle : std_logic;
   signal QFULL5_C : std_logic_vector(3 downto 0);
   signal QFULL3_C : std_logic_vector(3 downto 0);

   TYPE STATE_TYPE IS (
      sReset1,
      sT1,
      sT2,
      sT4,
      sT3,
      sFlush,
      sRead,
      sRdT2,
      sRdT3,
      sRdT4,
      sWrite,
      sWrT2,
      sWrT3,
      sWrT4,
      sACK,
      sIDLE,
      sHold,
      sHLDT4,
      sIRQT1,
      sIRQT2,
      sIRQT3,
      sIRQT4,
      sERROR,
      sReset2,
      sHLDA,
      sHLT2,
      sHLTIR,
      sHLT,
      sRead2,
      sWrite2,
      sIRQT12
   );

   -- Declare current and next state signals
   SIGNAL current_state : STATE_TYPE;
   SIGNAL next_state : STATE_TYPE;

   -- Declare any pre-registered internal signals
   SIGNAL bhe_cld : std_logic ;
   SIGNAL inta_cld : std_logic ;
   SIGNAL irq_cycle2_cld : std_logic ;
   SIGNAL rdn_cld : std_logic ;
   SIGNAL rw_cycle_cld : std_logic ;
   SIGNAL rw_cycle2_cld : std_logic ;
   SIGNAL wrn_cld : std_logic ;

BEGIN

   -----------------------------------------------------------------
   clocked_proc : PROCESS (
      clk,
      reset
   )
   -----------------------------------------------------------------
   BEGIN
      IF (reset = '1') THEN
         current_state <= sReset1;
         -- Default Reset Values
         bhe_cld <= '0';
         inta_cld <= '1';
         irq_cycle2_cld <= '0';
         rdn_cld <= '1';
         rw_cycle_cld <= '0';
         rw_cycle2_cld <= '0';
         wrn_cld <= '1';
         twocycle <= '0';
      ELSIF (clk'EVENT AND clk = '1') THEN
         current_state <= next_state;

         -- Combined Actions
         CASE current_state IS
            WHEN sT1 =>
               rdn_cld<='0';
            WHEN sT4 =>
               rdn_cld<='1';
               IF (hold='1') THEN
               ELSIF (read_req='1') THEN
                  rw_cycle_cld<='1';
                  bhe_cld<=bhe_s;
               ELSIF (write_req='1') THEN
                  rw_cycle_cld<='1';
                  bhe_cld<=bhe_s;
               END IF;
            WHEN sFlush =>
               rdn_cld<='1';
            WHEN sRead =>
                rdn_cld<='0';
               if (oddword='1') then
                   twocycle<='1';
               end if;
            WHEN sRdT4 =>
               rdn_cld<='1';
               IF (twocycle='1') THEN
                  rw_cycle2_cld<='1';
                  bhe_cld<='1';
               ELSIF (twocycle='0' AND hold='1') THEN
                  rw_cycle_cld<='0';
                  rw_cycle2_cld<='0';
                  bhe_cld<='0';
               ELSIF (halt='1') THEN
               ELSIF ((twocycle='0' AND regcnt>QFULL5_C)
                      OR flush_coming='1' OR
                      halt='1') THEN
                  rw_cycle_cld<='0';
                  rw_cycle2_cld<='0';
                  bhe_cld<='0';
               ELSE
                  rw_cycle_cld<='0';
                  rw_cycle2_cld<='0';
                  bhe_cld<='0';
               END IF;
            WHEN sWrite =>
               if (oddword='1') then
                  twocycle<='1';
               end if;
            -- WRN not asserted until T2
            WHEN sWrT2 =>
               wrn_cld<='0';
            WHEN sWrT4 =>
               wrn_cld<='1';
               IF (twocycle='1') THEN
                  rw_cycle2_cld<='1';
                  bhe_cld<='1';
               ELSIF (twocycle='0' AND hold='1') THEN
                  rw_cycle_cld<='0';
                  rw_cycle2_cld<='0';
                  bhe_cld<='0';
               ELSIF (halt='1') THEN
               ELSIF ((twocycle='0' AND regcnt>QFULL5_C)
                      OR flush_coming='1' OR
                      halt='1') THEN
                  rw_cycle_cld<='0';
                  rw_cycle2_cld<='0';
                  bhe_cld<='0';
               ELSE
                  rw_cycle_cld<='0';
                  rw_cycle2_cld<='0';
                  bhe_cld<='0';
               END IF;
            WHEN sIDLE =>
               IF (hold='1') THEN
               ELSIF (halt='1') THEN
               ELSIF (flush_req='1') THEN
               ELSIF (irq_req='1' and opc_req='1') THEN
               ELSIF (regnbok='1' and opc_req='1') THEN
               ELSIF (read_req='1') THEN
                  rw_cycle_cld<='1';
                  bhe_cld<=bhe_s;
               ELSIF (write_req='1') THEN
                  rw_cycle_cld<='1';
                  bhe_cld<=bhe_s;
               END IF;
            WHEN sHLDT4 =>
               IF (read_req='1') THEN
                  rw_cycle_cld<='1';
                  bhe_cld<=bhe_s;
               ELSIF (write_req='1') THEN
                  rw_cycle_cld<='1';
                  bhe_cld<=bhe_s;
               END IF;
            WHEN sIRQT1 =>
               if irq_type="1111" then inta_cld<='0'; twocycle<='1';
               end if;
            WHEN sIRQT4 =>
               inta_cld<='1';
               IF (twocycle='1') THEN
                  irq_cycle2_cld<='1';
               ELSIF (twocycle='0' AND
                      write_req='1') THEN
                  --irq_cycle_cld<='0';
                  irq_cycle2_cld<='0';
                  rw_cycle_cld<='1';
                  bhe_cld<=bhe_s;
               END IF;
            WHEN sRead2 =>
                rdn_cld<='0';
               twocycle<='0';
            WHEN sWrite2 =>
               twocycle<='0';
            WHEN sIRQT12 =>
               if irq_type="1111" then inta_cld<='0'; end if;
               twocycle<='0';
            WHEN OTHERS =>
               NULL;
         END CASE;
      END IF;
   END PROCESS clocked_proc;

   -----------------------------------------------------------------
   nextstate_proc : PROCESS (
      QFULL3_C,
      QFULL5_C,
      current_state,
      flush_coming,
      flush_req,
      halt,
      hold,
      irq_req,
      irq_type,
      memio,
      opc_req,
      read_req,
      ready,
      regcnt,
      regnbok,
      twocycle,
      write_req
   )
   -----------------------------------------------------------------
   BEGIN
      -- Default Assignment
      ale <= '0';
      biustat <= (others => '1');
      flush_ack <= '0';
      hlda <= '0';
      irq_ack <= '0';
      irq_clr <= '0';
      opc_ack <= '0';
      rw_ack <= '0';
      wr_mdbus <= '0';
      wrq <= '0';

      -- Combined Actions
      CASE current_state IS
         WHEN sReset1 =>
            next_state <= sReset2;
         WHEN sT1 =>
            ale<='1';
            if (regnbok='1' and opc_req='1') then
               opc_ack<='1';
            end if;
            biustat<="100";
            next_state <= sT2;
         WHEN sT2 =>
            if (regnbok='1' and
              opc_req='1') then
               opc_ack<='1';
            end if;
            biustat<="100";
            next_state <= sT3;
         WHEN sT4 =>
            wrq<='1';
            IF (hold='1') THEN
               next_state <= sHold;
            ELSIF (read_req='1') THEN
               biustat<=memio&"01";
               next_state <= sRead;
            ELSIF (write_req='1') THEN
               biustat<=memio&"10";
               next_state <= sWrite;
            ELSIF (halt='1') THEN
               biustat<="011";
               next_state <= sHLT;
            ELSIF (flush_req='1') THEN
               next_state <= sFlush;
            ELSIF (irq_req='1' and opc_req='1') THEN
               if irq_type="1111" then biustat<="000";
               else biustat<="111";
               end if;
               --irq_cycle_cld<='1';
               next_state <= sIRQT1;
            ELSIF (regcnt<=QFULL3_C AND
                   flush_coming='0') THEN
               biustat<="100";
               next_state <= sT1;
            ELSE
               next_state <= sIDLE;
            END IF;
         WHEN sT3 =>
            if (regnbok='1' AND opc_req='1' AND
             flush_req='0' AND ready='1') then
                opc_ack<='1';
            end if;
            IF (flush_req='1') THEN
               next_state <= sFlush;
            ELSIF (ready='1') THEN
               next_state <= sT4;
            ELSE
               next_state <= sT3;
            END IF;
         WHEN sFlush =>
            flush_ack<='1';
            IF (halt='1') THEN
               biustat<="011";
               next_state <= sHLT;
            ELSE
               biustat<="100";
               next_state <= sT1;
            END IF;
         WHEN sRead =>
            ale<='1';
            biustat<=memio&"01";
            next_state <= sRdT2;
         WHEN sRdT2 =>
            biustat<=memio&"01";
            next_state <= sRdT3;
         WHEN sRdT3 =>
            IF (ready='1') THEN
               next_state <= sRdT4;
            ELSE
               next_state <= sRdT3;
            END IF;
         WHEN sRdT4 =>
              wr_mdbus<='1';
            if (twocycle='0') then
               rw_ack<='1';
            end if;
            biustat<=memio&"01";
            IF (twocycle='1') THEN
               next_state <= sRead2;
            ELSIF (twocycle='0' AND hold='1') THEN
               biustat<="111";
               next_state <= sHold;
--            ELSIF (halt='1') THEN 		-- Corrected for Version 1.1
--               next_state <= sERROR;
            ELSIF ((twocycle='0' AND regcnt>QFULL5_C)
                   OR flush_coming='1' OR
                   halt='1') THEN
               biustat<="111";
               next_state <= sIDLE;
            ELSE
               biustat<="100";
               next_state <= sT1;
            END IF;
         WHEN sWrite =>
            ale<='1';
            biustat<=memio&"10";
            next_state <= sWrT2;
         -- WRN not asserted until T2
         WHEN sWrT2 =>
            biustat<=memio&"10";
            next_state <= sWrT3;
         WHEN sWrT3 =>
            -- ver1.3
            if (twocycle='0' AND ready='1') then
               rw_ack<='1';
            end if;
            IF (ready='1') THEN
               next_state <= sWrT4;
            ELSE
               next_state <= sWrT3;
            END IF;
         WHEN sWrT4 =>
            biustat<=memio&"10";
            IF (twocycle='1') THEN
               next_state <= sWrite2;
            ELSIF (twocycle='0' AND hold='1') THEN
               biustat<="111";
               next_state <= sHold;
--            ELSIF (halt='1') THEN 	-- Corrected for Version 1.1
--               next_state <= sERROR;
            ELSIF ((twocycle='0' AND regcnt>QFULL5_C)
                   OR flush_coming='1' OR
                   halt='1') THEN
               biustat<="111";
               next_state <= sIDLE;
            ELSE
               biustat<="100";
               next_state <= sT1;
            END IF;
         WHEN sACK =>
            next_state <= sIDLE;
         WHEN sIDLE =>
            IF (hold='1') THEN
               next_state <= sHold;
            ELSIF (halt='1') THEN
               biustat<="011";
               next_state <= sHLT;
            ELSIF (flush_req='1') THEN
               next_state <= sFlush;
            ELSIF (irq_req='1' and opc_req='1') THEN
               if irq_type="1111" then
                  biustat<="000";
               else  biustat<="111";
               end if;
               next_state <= sIRQT1;
            ELSIF (regnbok='1' and opc_req='1') THEN
               opc_ack<='1';
               next_state <= sACK;
            ELSIF (read_req='1') THEN
               biustat<=memio&"01";
               next_state <= sRead;
            ELSIF (write_req='1') THEN
               biustat<=memio&"10";
               next_state <= sWrite;
            ELSIF (regcnt<=QFULL5_C AND
                   flush_coming='0') THEN
               biustat<="100";
               next_state <= sT1;
            ELSE
               next_state <= sIDLE;
            END IF;
         WHEN sHold =>
            if (regnbok='1' and opc_req='1') then
             opc_ack <= '1'; --ver 1.4
            end if;
            next_state <= sHLDA;
         WHEN sHLDT4 =>
            if (regnbok='1' and opc_req='1') then
               opc_ack <= '1'; --ver 1.4
            end if;
            IF (read_req='1') THEN
               biustat<=memio&"01";
               next_state <= sRead;
            ELSIF (write_req='1') THEN
               biustat<=memio&"10";
               next_state <= sWrite;
            ELSIF (flush_req='1') THEN
               next_state <= sFlush;
            ELSIF (halt='1') THEN
               biustat<="011";
               next_state <= sHLT;
            ELSIF (regcnt>QFULL5_C OR
                   flush_coming='1') THEN
               next_state <= sIDLE;
            ELSE
               biustat<="100";
               next_state <= sT1;
            END IF;
         WHEN sIRQT1 =>
            irq_ack<='1';
            if irq_type="1111" then biustat<="000";
            ale<='1';
            else biustat<="111"; end if;
            next_state <= sIRQT2;
         WHEN sIRQT2 =>
            if irq_type="1111" then biustat<="000";
            else biustat<="111";
            end if;
            next_state <= sIRQT3;
         WHEN sIRQT3 =>
            IF (ready='1') THEN
               next_state <= sIRQT4;
            ELSE
               next_state <= sIRQT3;
            END IF;
         WHEN sIRQT4 =>
            if twocycle='0' then
               irq_clr<='1';
            end if;
            if irq_type="1111" then biustat<="000";
            else biustat<="111";
            end if;
            IF (twocycle='1') THEN
               biustat<="000";
               next_state <= sIRQT12;
            ELSIF (twocycle='0' AND
                   write_req='1') THEN
               biustat<=memio&"10";
               next_state <= sWrite;
            ELSE
               next_state <= sERROR;
            END IF;
         WHEN sERROR =>
            assert FALSE
            report "*** BUS Interface Error ***"
            severity failure;
            next_state <= sERROR;
         WHEN sReset2 =>
            biustat<="100";
            next_state <= sT1;
         WHEN sHLDA =>
            hlda<='1';
            if (regnbok='1' and opc_req='1') then
               opc_ack <= '1';  --ver 1.4
            end if;
            IF (hold='0') THEN
               next_state <= sHLDT4;
            ELSE
               next_state <= sHLDA;
            END IF;
         WHEN sHLT2 =>
            biustat<="011";
            IF (hold='1') THEN
               next_state <= sHold;
            ELSIF (irq_req='1' and opc_req='1') THEN
               biustat<="111";
               next_state <= sHLTIR;
            ELSE
               next_state <= sHLT2;
            END IF;
         WHEN sHLTIR =>
            biustat<="111";
            if irq_type="1111" then
               biustat<="000";
            else  biustat<="111";
            end if;
            --irq_cycle_cld<='1';
            next_state <= sIRQT1;
         WHEN sHLT =>
            biustat<="011";
            ale<='1';
            next_state <= sHLT2;
         WHEN sRead2 =>
            ale<='1';
            biustat<=memio&"01";
            next_state <= sRdT2;
         WHEN sWrite2 =>
            ale<='1';
            biustat<=memio&"10";
            next_state <= sWrT2;
         WHEN sIRQT12 =>
            if irq_type="1111" then biustat<="000";
            else biustat<="111"; end if;
            next_state <= sIRQT2;
         WHEN OTHERS =>
            next_state <= sReset1;
      END CASE;
   END PROCESS nextstate_proc;

   -- Concurrent Statements
   -- Clocked output assignments
   bhe <= bhe_cld;
   inta <= inta_cld;
   irq_cycle2 <= irq_cycle2_cld;
   rdn <= rdn_cld;
   rw_cycle <= rw_cycle_cld;
   rw_cycle2 <= rw_cycle2_cld;
   wrn <= wrn_cld;
   ---------------------------------------------------------------
   -- 186 queue is full when regcnt>5 (req 2 free bytes)
   -- 188 queue is full when regcnt>6
   ---------------------------------------------------------------
   QFULL5_C <= "0101" when bus8='0' else "0110";
   QFULL3_C <= "0011" when bus8='0' else "0101"; -- Prior to a queue write
END fsm;
