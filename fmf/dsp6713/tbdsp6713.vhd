--------------------------------------------------------------------------------
--  File Name: tbdsp6713.vhd
--------------------------------------------------------------------------------
-- Copyright (C) 2005 Free Model Foundry; http://www.FreeModelFoundry.com
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License version 2 as
-- published by the Free Software Foundation.
--
--  MODIFICATION HISTORY:
--
--  version: |   author:    | mod date: | changes made:
--    V1.0     M.Radmanovic  03 Sep 26   Initial release
--    V1.1     M.Radmanovic  05 Dec 13   Added tests for McASP1,
--                                       added tests for rom8, rom16 and rom32
--                                       boot, Fixed coding style
--------------------------------------------------------------------------------
--  Note:
-- Warning occurs :attempt to read from reserved address space,
-- in order to test HPI read.
-- Way of booting is determined with a procedure parameter - boot(hpi),
-- boot(rom8), boot(rom16), boot(rom32).
-- Peripheral pin selection is determined with a HD[14] pin (HPI_EN).
--
--------------------------------------------------------------------------------
-- dsp6713 Test Bench
--------------------------------------------------------------------------------

LIBRARY IEEE;   USE IEEE.std_logic_1164.ALL;
                USE IEEE.VITAL_timing.ALL;
                USE IEEE.VITAL_primitives.ALL;

                USE STD.textio.ALL;

LIBRARY FMF;    USE FMF.gen_utils.ALL;
                USE FMF.conversions.ALL;

ENTITY tbdsp6713 IS END;

ARCHITECTURE test_1 of tbdsp6713 IS

    CONSTANT ClkIn_cycle   : TIME := 28 ns;
    CONSTANT EClk_cycle    : TIME := 10 ns;
    CONSTANT ClkIn_width   : TIME := ClkIn_cycle/2;
    CONSTANT EClk_width    : TIME := EClk_cycle/2;

    COMPONENT dsp6713
        GENERIC (
        -- tipd delays: interconnect path delays
        tipd_CLKIN               : VitalDelayType01 := VitalZeroDelay01;
        tipd_CLKOUT2             : VitalDelayType01 := VitalZeroDelay01;
        tipd_CLKMODE0            : VitalDelayType01 := VitalZeroDelay01;
        tipd_TMS                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_TDI                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_TCK                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_TRSTNeg             : VitalDelayType01 := VitalZeroDelay01;
        tipd_EMU0                : VitalDelayType01 := VitalZeroDelay01;
        tipd_EMU1                : VitalDelayType01 := VitalZeroDelay01;
        tipd_EMU2                : VitalDelayType01 := VitalZeroDelay01;
        tipd_EMU3                : VitalDelayType01 := VitalZeroDelay01;
        tipd_EMU4                : VitalDelayType01 := VitalZeroDelay01;
        tipd_EMU5                : VitalDelayType01 := VitalZeroDelay01;
        tipd_RESETNeg            : VitalDelayType01 := VitalZeroDelay01;
        tipd_NMI                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_EXTINT4             : VitalDelayType01 := VitalZeroDelay01;
        tipd_EXTINT5             : VitalDelayType01 := VitalZeroDelay01;
        tipd_EXTINT6             : VitalDelayType01 := VitalZeroDelay01;
        tipd_EXTINT7             : VitalDelayType01 := VitalZeroDelay01;
        tipd_HCNTL1              : VitalDelayType01 := VitalZeroDelay01;
        tipd_HINTNeg             : VitalDelayType01 := VitalZeroDelay01;
        tipd_HCNTL0              : VitalDelayType01 := VitalZeroDelay01;
        tipd_HHWIL               : VitalDelayType01 := VitalZeroDelay01;
        tipd_HR                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD0                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD1                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD2                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD3                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD4                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD5                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD6                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD7                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD8                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD9                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD10                : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD11                : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD12                : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD13                : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD14                : VitalDelayType01 := VitalZeroDelay01;
        tipd_HD15                : VitalDelayType01 := VitalZeroDelay01;
        tipd_HASNeg              : VitalDelayType01 := VitalZeroDelay01;
        tipd_HCSNeg              : VitalDelayType01 := VitalZeroDelay01;
        tipd_HDS1Neg             : VitalDelayType01 := VitalZeroDelay01;
        tipd_HDS2Neg             : VitalDelayType01 := VitalZeroDelay01;
        tipd_HRDYNeg             : VitalDelayType01 := VitalZeroDelay01;
        tipd_HOLDNeg             : VitalDelayType01 := VitalZeroDelay01;
        tipd_ECLKIN              : VitalDelayType01 := VitalZeroDelay01;
        tipd_ARDY                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED0                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED1                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED2                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED3                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED4                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED5                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED6                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED7                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED8                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED9                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED10                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED11                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED12                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED13                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED14                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED15                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED16                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED17                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED18                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED19                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED20                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED21                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED22                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED23                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED24                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED25                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED26                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED27                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED28                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED29                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED30                : VitalDelayType01 := VitalZeroDelay01;
        tipd_ED31                : VitalDelayType01 := VitalZeroDelay01;
        tipd_TINP1               : VitalDelayType01 := VitalZeroDelay01;
        tipd_TOUT1              : VitalDelayType01 := VitalZeroDelay01;
        tipd_TINP0               : VitalDelayType01 := VitalZeroDelay01;
        tipd_TOUT0              : VitalDelayType01 := VitalZeroDelay01;
        tipd_CLKS1               : VitalDelayType01 := VitalZeroDelay01;
        tipd_CLKR1               : VitalDelayType01 := VitalZeroDelay01;
        tipd_CLKX1               : VitalDelayType01 := VitalZeroDelay01;
        tipd_DX1                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DR1                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_FSR1                : VitalDelayType01 := VitalZeroDelay01;
        tipd_FSX1                : VitalDelayType01 := VitalZeroDelay01;
        tipd_CLKS0               : VitalDelayType01 := VitalZeroDelay01;
        tipd_CLKR0               : VitalDelayType01 := VitalZeroDelay01;
        tipd_CLKX0               : VitalDelayType01 := VitalZeroDelay01;
        tipd_DX0                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DR0                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_FSR0                : VitalDelayType01 := VitalZeroDelay01;
        tipd_FSX0                : VitalDelayType01 := VitalZeroDelay01;
        tipd_SCL0                : VitalDelayType01 := VitalZeroDelay01;
        tipd_SDA0                : VitalDelayType01 := VitalZeroDelay01;
        -- tpd delays
        tpd_ECLKIN_ECLKOUT       : VitalDelayType01 := UnitDelay01;
        tpd_HCSNeg_HRDYNeg       : VitalDelayType01 := UnitDelay01;
        tpd_HASNeg_HRDYNeg       : VitalDelayType01 := UnitDelay01;
        tpd_HSTROB_HRDYNeg      : VitalDelayType01 := UnitDelay01;
        tpd_CLKIN_CLKOUT2        : VitalDelayType01 := UnitDelay01;
        tpd_CLKIN_CLKOUT3        : VitalDelayType01 := UnitDelay01;
        tpd_HCSNeg_HD0           : VitalDelayType01Z := UnitDelay01Z;
        tpd_ECLKIN_BUSREQ        : VitalDelayType01Z := UnitDelay01Z;
        tpd_ECLKIN_HOLDANeg      : VitalDelayType01Z := UnitDelay01Z;
        tpd_ECLKIN_CE0Neg        : VitalDelayType01Z := UnitDelay01Z;
        tpd_ECLKIN_BE0Neg        : VitalDelayType01Z := UnitDelay01Z;
        tpd_ECLKIN_SDCASNeg      : VitalDelayType01Z := UnitDelay01Z;
        tpd_ECLKIN_SDRASNeg      : VitalDelayType01Z := UnitDelay01Z;
        tpd_ECLKIN_SDWENeg       : VitalDelayType01Z := UnitDelay01Z;
        tpd_ECLKIN_EA2           : VitalDelayType01Z := UnitDelay01Z;
        tpd_ECLKIN_ED0           : VitalDelayType01Z := UnitDelay01Z;
        tpd_CLKS_CLKR            : VitalDelayType01 := UnitDelay01;
        tpd_CLKS_CLKX            : VitalDelayType01 := UnitDelay01;
        tpd_ACLKX1_AXR           : VitalDelayType01 := UnitDelay01;
        tpd_ACLKX1EXT_AXR        : VitalDelayType01 := UnitDelay01;
        -- tpw values: pulse widths
        tpw_ECLKIN_negedge       : VitalDelayType := UnitDelay;
        tpw_ECLKIN_posedge       : VitalDelayType := UnitDelay;
        tpw_RESETNeg_negedge     : VitalDelayType := UnitDelay;
        tpw_AHCLKR1_negedge      : VitalDelayType := UnitDelay;
        tpw_AHCLKR1_posedge      : VitalDelayType := UnitDelay;
        tpw_AHCLKX1_negedge      : VitalDelayType := UnitDelay;
        tpw_AHCLKX1_posedge      : VitalDelayType := UnitDelay;
        tpw_ACLKR1_negedge       : VitalDelayType := UnitDelay;
        tpw_ACLKR1_posedge       : VitalDelayType := UnitDelay;
        tpw_ACLKX1_negedge       : VitalDelayType := UnitDelay;
        tpw_ACLKX1_posedge       : VitalDelayType := UnitDelay;
        -- tperiod min (calculated as 1/max freq)
        tperiod_ECLKIN_posedge   : VitalDelayType := UnitDelay;
        tperiod_CLKIN_PLLEN_EQ_0_posedge    : VitalDelayType := UnitDelay;
        tperiod_CLKIN_PLLEN_EQ_1_posedge    : VitalDelayType := UnitDelay;
        tperiod_AHCLKR1_posedge  : VitalDelayType := UnitDelay;
        tperiod_AHCLKX1_posedge  : VitalDelayType := UnitDelay;
        tperiod_ACLKR1_posedge   : VitalDelayType := UnitDelay;
        tperiod_ACLKX1_posedge   : VitalDelayType := UnitDelay;
        -- tsetup values: setup times
        tsetup_ARDY_ECLKOUT      : VitalDelayType := UnitDelay;
        tsetup_ED0_ECLKOUT       : VitalDelayType := UnitDelay;
        tsetup_ED0_SDCASNeg      : VitalDelayType := UnitDelay;
        tsetup_HR_HASNeg         : VitalDelayType := UnitDelay;
        tsetup_HR_HCSNeg         : VitalDelayType := UnitDelay;
        tsetup_HD0_HCSNeg        : VitalDelayType := UnitDelay;
        tsetup_FSR_CLKR          : VitalDelayType := UnitDelay;
        tsetup_FSX_CLKX          : VitalDelayType := UnitDelay;
        tsetup_DR_CLKR           : VitalDelayType := UnitDelay;
        tsetup_AXR1In_ACLKR1     : VitalDelayType := UnitDelay;
        -- thold values: hold times
        thold_ARDY_ECLKOUT       : VitalDelayType := UnitDelay;
        thold_ED0_ECLKOUT        : VitalDelayType := UnitDelay;
        thold_ED0_SDCASNeg       : VitalDelayType := UnitDelay;
        thold_HR_HCSNeg          : VitalDelayType := UnitDelay;
        thold_HR_HASNeg          : VitalDelayType := UnitDelay;
        thold_HD0_HCSNeg         : VitalDelayType := UnitDelay;
        thold_HCSNeg_HRDYNeg     : VitalDelayType := UnitDelay;
        thold_FSR_CLKR           : VitalDelayType := UnitDelay;
        thold_FSX_CLKX           : VitalDelayType := UnitDelay;
        thold_DR_CLKR            : VitalDelayType := UnitDelay;
        thold_AXR1In_ACLKR1     : VitalDelayType := UnitDelay;
        -- generic control parameters
        InstancePath        : STRING    := DefaultInstancePath;
        TimingChecksOn      : BOOLEAN   := DefaultTimingChecks;
        MsgOn               : BOOLEAN   := DefaultMsgOn;
        XOn                 : BOOLEAN   := DefaultXon;
        -- command file to be loaded
        command_file_name   : STRING    := "dsp6713.vec";
        -- time to auto-start CPU
        cpu_autostart_time  : TIME      := 0 ns;
        -- For FMF SDF technology file usage
        TimingModel         : STRING    := DefaultTimingModel
    );
    PORT (
        CLKIN           : IN    std_logic := 'H';
        CLKOUT2         : INOUT std_logic := 'H';
        CLKOUT3         : OUT   std_logic := 'H';
        CLKMODE0        : IN    std_logic := 'H';
        TMS             : IN    std_logic := 'H';
        TDO             : OUT   std_logic := 'H';
        TDI             : IN    std_logic := 'H';
        TCK             : IN    std_logic := 'H';
        TRSTNeg         : IN    std_logic := 'L';
        EMU0            : INOUT std_logic := 'H';
        EMU1            : INOUT std_logic := 'H';
        EMU2            : INOUT std_logic := 'H';
        EMU3            : INOUT std_logic := 'H';
        EMU4            : INOUT std_logic := 'H';
        EMU5            : INOUT std_logic := 'H';
        RESETNeg        : IN    std_logic := 'H';
        NMI             : IN    std_logic := 'L';
        EXTINT4         : INOUT std_logic := 'H';
        EXTINT5         : INOUT std_logic := 'H';
        EXTINT6         : INOUT std_logic := 'H';
        EXTINT7         : INOUT std_logic := 'H';
        HINTNeg         : INOUT std_logic := 'H';
        HCNTL1          : INOUT std_logic := 'H';
        HCNTL0          : INOUT std_logic := 'H';
        HHWIL           : INOUT std_logic := 'H';
        HR              : INOUT std_logic := 'H';
        HD0             : INOUT std_logic := 'H';
        HD1             : INOUT std_logic := 'H';
        HD2             : INOUT std_logic := 'H';
        HD3             : INOUT std_logic := 'H';
        HD4             : INOUT std_logic := 'L';
        HD5             : INOUT std_logic := 'H';
        HD6             : INOUT std_logic := 'H';
        HD7             : INOUT std_logic := 'H';
        HD8             : INOUT std_logic := 'H';
        HD9             : INOUT std_logic := 'H';
        HD10            : INOUT std_logic := 'H';
        HD11            : INOUT std_logic := 'H';
        HD12            : INOUT std_logic := 'H';
        HD13            : INOUT std_logic := 'H';
        HD14            : INOUT std_logic := 'H';
        HD15            : INOUT std_logic := 'H';
        HASNeg          : INOUT std_logic := 'H';
        HCSNeg          : INOUT std_logic := 'H';
        HDS1Neg         : INOUT std_logic := 'H';
        HDS2Neg         : INOUT std_logic := 'H';
        HRDYNeg         : INOUT std_logic := 'H';
        CE3Neg          : OUT   std_logic := 'H';
        CE2Neg          : OUT   std_logic := 'H';
        CE1Neg          : OUT   std_logic := 'H';
        CE0Neg          : OUT   std_logic := 'H';
        BE0Neg          : OUT   std_logic := 'H';
        BE1Neg          : OUT   std_logic := 'H';
        BE2Neg          : OUT   std_logic := 'H';
        BE3Neg          : OUT   std_logic := 'H';
        HOLDANeg        : OUT   std_logic := 'H';
        HOLDNeg         : IN    std_logic := 'H';
        BUSREQ          : OUT   std_logic := 'H';
        ECLKIN          : IN    std_logic := 'L';
        ECLKOUT         : OUT   std_logic := 'H';
        SDCASNeg        : OUT   std_logic := 'H';
        SDRASNeg        : OUT   std_logic := 'H';
        SDWENeg         : OUT   std_logic := 'H';
        ARDY            : IN    std_logic := 'H';
        EA2             : OUT   std_logic := 'H';
        EA3             : OUT   std_logic := 'H';
        EA4             : OUT   std_logic := 'H';
        EA5             : OUT   std_logic := 'H';
        EA6             : OUT   std_logic := 'H';
        EA7             : OUT   std_logic := 'H';
        EA8             : OUT   std_logic := 'H';
        EA9             : OUT   std_logic := 'H';
        EA10            : OUT   std_logic := 'H';
        EA11            : OUT   std_logic := 'H';
        EA12            : OUT   std_logic := 'H';
        EA13            : OUT   std_logic := 'H';
        EA14            : OUT   std_logic := 'H';
        EA15            : OUT   std_logic := 'H';
        EA16            : OUT   std_logic := 'H';
        EA17            : OUT   std_logic := 'H';
        EA18            : OUT   std_logic := 'H';
        EA19            : OUT   std_logic := 'H';
        EA20            : OUT   std_logic := 'H';
        EA21            : OUT   std_logic := 'H';
        ED0             : INOUT std_logic := 'H';
        ED1             : INOUT std_logic := 'H';
        ED2             : INOUT std_logic := 'H';
        ED3             : INOUT std_logic := 'H';
        ED4             : INOUT std_logic := 'H';
        ED5             : INOUT std_logic := 'H';
        ED6             : INOUT std_logic := 'H';
        ED7             : INOUT std_logic := 'H';
        ED8             : INOUT std_logic := 'H';
        ED9             : INOUT std_logic := 'H';
        ED10            : INOUT std_logic := 'H';
        ED11            : INOUT std_logic := 'H';
        ED12            : INOUT std_logic := 'H';
        ED13            : INOUT std_logic := 'H';
        ED14            : INOUT std_logic := 'H';
        ED15            : INOUT std_logic := 'H';
        ED16            : INOUT std_logic := 'H';
        ED17            : INOUT std_logic := 'H';
        ED18            : INOUT std_logic := 'H';
        ED19            : INOUT std_logic := 'H';
        ED20            : INOUT std_logic := 'H';
        ED21            : INOUT std_logic := 'H';
        ED22            : INOUT std_logic := 'H';
        ED23            : INOUT std_logic := 'H';
        ED24            : INOUT std_logic := 'H';
        ED25            : INOUT std_logic := 'H';
        ED26            : INOUT std_logic := 'H';
        ED27            : INOUT std_logic := 'H';
        ED28            : INOUT std_logic := 'H';
        ED29            : INOUT std_logic := 'H';
        ED30            : INOUT std_logic := 'H';
        ED31            : INOUT std_logic := 'H';
        TOUT1           : INOUT std_logic := 'L';
        TINP1           : INOUT std_logic := 'L';
        TOUT0           : INOUT std_logic := 'L';
        TINP0           : INOUT std_logic := 'L';
        CLKS1           : INOUT std_logic := 'L';
        CLKR1           : INOUT std_logic := 'L';
        CLKX1           : INOUT std_logic := 'L';
        DR1             : INOUT std_logic := 'H';
        DX1             : INOUT std_logic := 'H';
        FSR1            : INOUT std_logic := 'L';
        FSX1            : INOUT std_logic := 'L';
        CLKS0           : INOUT std_logic := 'L';
        CLKR0           : INOUT std_logic := 'L';
        CLKX0           : INOUT std_logic := 'L';
        DR0             : INOUT std_logic := 'H';
        DX0             : INOUT std_logic := 'H';
        SCL0            : INOUT std_logic := 'H';
        SDA0            : INOUT std_logic := 'H';
        FSR0            : INOUT std_logic := 'L';
        FSX0            : INOUT std_logic := 'L'
    );
    END COMPONENT;

    COMPONENT sram1k8
    GENERIC (
        -- tipd delays: interconnect path delays
        tipd_OENeg          : VitalDelayType01 := VitalZeroDelay01;
        tipd_WENeg          : VitalDelayType01 := VitalZeroDelay01;
        tipd_CENeg          : VitalDelayType01 := (2 ns, 2 ns);
        tipd_CE             : VitalDelayType01 := VitalZeroDelay01;
        tipd_D0             : VitalDelayType01 := VitalZeroDelay01;
        tipd_A0             : VitalDelayType01 := VitalZeroDelay01;
        tipd_A1             : VitalDelayType01 := VitalZeroDelay01;
        tipd_A2             : VitalDelayType01 := VitalZeroDelay01;
        tipd_A3             : VitalDelayType01 := VitalZeroDelay01;
        tipd_A4             : VitalDelayType01 := VitalZeroDelay01;
        tipd_A5             : VitalDelayType01 := VitalZeroDelay01;
        tipd_A6             : VitalDelayType01 := VitalZeroDelay01;
        tipd_A7             : VitalDelayType01 := VitalZeroDelay01;
        tipd_A8             : VitalDelayType01 := VitalZeroDelay01;
        tipd_A9             : VitalDelayType01 := VitalZeroDelay01;
        -- tpd delays
        tpd_OENeg_D0                    : VitalDelayType01Z := UnitDelay01Z;
        tpd_CENeg_D0                    : VitalDelayType01Z := UnitDelay01Z;
        tpd_A0_D0                       : VitalDelayType01  := UnitDelay01;
        -- tpw values: pulse widths
        tpw_WENeg_negedge               : VitalDelayType    := UnitDelay;
        tpw_WENeg_posedge               : VitalDelayType    := UnitDelay;
        -- tsetup values: setup times
        tsetup_D0_WENeg                 : VitalDelayType    := UnitDelay;
        tsetup_D0_CENeg                 : VitalDelayType    := UnitDelay;
        -- thold values: hold times
        thold_D0_WENeg                  : VitalDelayType    := UnitDelay;
        thold_D0_CENeg                  : VitalDelayType    := UnitDelay;
        -- generic control parameters
        InstancePath        : STRING    := DefaultInstancePath;
        TimingChecksOn      : BOOLEAN   := DefaultTimingChecks;
        MsgOn               : BOOLEAN   := DefaultMsgOn;
        XOn                 : BOOLEAN   := DefaultXOn;
        SeverityMode        : SEVERITY_LEVEL := WARNING;
        -- For FMF SDF technology file usage
        TimingModel         : STRING    := DefaultTimingModel
    );
    PORT (
        A0              : IN    std_logic := 'X';
        A1              : IN    std_logic := 'X';
        A2              : IN    std_logic := 'X';
        A3              : IN    std_logic := 'X';
        A4              : IN    std_logic := 'X';
        A5              : IN    std_logic := 'X';
        A6              : IN    std_logic := 'X';
        A7              : IN    std_logic := 'X';
        A8              : IN    std_logic := 'X';
        A9              : IN    std_logic := 'X';

        D0              : INOUT std_logic := 'X';
        D1              : INOUT std_logic := 'X';
        D2              : INOUT std_logic := 'X';
        D3              : INOUT std_logic := 'X';
        D4              : INOUT std_logic := 'X';
        D5              : INOUT std_logic := 'X';
        D6              : INOUT std_logic := 'X';
        D7              : INOUT std_logic := 'X';

        OENeg           : IN    std_logic := 'X';
        WENeg           : IN    std_logic := 'X';
        CENeg           : IN    std_logic := 'X';
        CE              : IN    std_logic := 'X'
    );
    END COMPONENT;

    COMPONENT sram1k16
    GENERIC (
        tipd_CENeg          : VitalDelayType01 := (2 ns, 2 ns)
        );
    PORT (
        A0              : IN    std_logic := 'X';
        A1              : IN    std_logic := 'X';
        A2              : IN    std_logic := 'X';
        A3              : IN    std_logic := 'X';
        A4              : IN    std_logic := 'X';
        A5              : IN    std_logic := 'X';
        A6              : IN    std_logic := 'X';
        A7              : IN    std_logic := 'X';
        A8              : IN    std_logic := 'X';
        A9              : IN    std_logic := 'X';

        D0              : INOUT std_logic := 'X';
        D1              : INOUT std_logic := 'X';
        D2              : INOUT std_logic := 'X';
        D3              : INOUT std_logic := 'X';
        D4              : INOUT std_logic := 'X';
        D5              : INOUT std_logic := 'X';
        D6              : INOUT std_logic := 'X';
        D7              : INOUT std_logic := 'X';
        D8              : INOUT std_logic := 'X';
        D9              : INOUT std_logic := 'X';
        D10             : INOUT std_logic := 'X';
        D11             : INOUT std_logic := 'X';
        D12             : INOUT std_logic := 'X';
        D13             : INOUT std_logic := 'X';
        D14             : INOUT std_logic := 'X';
        D15             : INOUT std_logic := 'X';

        OENeg           : IN    std_logic := 'X';
        WENeg           : IN    std_logic := 'X';
        CENeg           : IN    std_logic := 'X';
        CE              : IN    std_logic := 'X'
    );
    END COMPONENT;

    COMPONENT km416s4030
        GENERIC (
        -- tipd delays: interconnect path delays
        tipd_BA0                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_BA1                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQML                : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQMU                : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ0                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ1                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ2                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ3                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ4                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ5                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ6                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ7                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ8                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ9                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ10                : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ11                : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ12                : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ13                : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ14                : VitalDelayType01 := VitalZeroDelay01;
        tipd_DQ15                : VitalDelayType01 := VitalZeroDelay01;
        tipd_CLK                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_CKE                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_A0                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A1                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A2                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A3                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A4                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A5                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A6                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A7                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A8                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A9                  : VitalDelayType01 := VitalZeroDelay01;
        tipd_A10                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_A11                 : VitalDelayType01 := VitalZeroDelay01;
        tipd_WENeg               : VitalDelayType01 := VitalZeroDelay01;
        tipd_RASNeg              : VitalDelayType01 := VitalZeroDelay01;
        tipd_CSNeg               : VitalDelayType01 := VitalZeroDelay01;
        tipd_CASNeg              : VitalDelayType01 := VitalZeroDelay01;
        -- tpd delays
        tpd_CLK_DQ2              : VitalDelayType01Z := UnitDelay01Z;
        tpd_CLK_DQ3              : VitalDelayType01Z := UnitDelay01Z;
        -- tpw values: pulse widths
        tpw_CLK_posedge          : VitalDelayType    := UnitDelay;
        tpw_CLK_negedge          : VitalDelayType    := UnitDelay;
        -- tsetup values: setup times
        tsetup_DQ0_CLK           : VitalDelayType    := UnitDelay;
        -- thold values: hold times
        thold_DQ0_CLK            : VitalDelayType    := UnitDelay;
        -- tperiod_min: minimum clock period  1/max freq
        tperiod_CLK_posedge      : VitalDelayType    := UnitDelay;
        -- tdevice values: values for internal delays
        tdevice_REF              : VitalDelayType    := UnitDelay;
        tdevice_TRC              : VitalDelayType    := UnitDelay;
        tdevice_TRCD             : VitalDelayType    := UnitDelay;
        tdevice_TRP              : VitalDelayType    := UnitDelay;
        tdevice_TRCAR            : VitalDelayType    := UnitDelay;
        tdevice_TWR              : VitalDelayType    := 15 ns;
        tdevice_TRAS             : VitalDelayType01  := (60 ns, 120_000 ns);
        -- tpowerup: Power up initialization time. Data sheets say 100 us.
        -- May be shortened during simulation debug.
        tpowerup            : TIME      := 10 us;
        -- generic control parameters
        InstancePath        : STRING    := DefaultInstancePath;
        TimingChecksOn      : BOOLEAN   := DefaultTimingChecks;
        MsgOn               : BOOLEAN   := DefaultMsgOn;
        XOn                 : BOOLEAN   := DefaultXon;
        SeverityMode        : SEVERITY_LEVEL := WARNING;
        mem_file_name       : STRING    := "km416s4030.mem";

        -- For FMF SDF technology file usage
        TimingModel         : STRING    := DefaultTimingModel
    );

        PORT (
        BA0             : IN    std_logic := 'U';
        BA1             : IN    std_logic := 'U';
        DQML            : IN    std_logic := 'U';
        DQMU            : IN    std_logic := 'U';
        DQ0             : INOUT std_logic := 'U';
        DQ1             : INOUT std_logic := 'U';
        DQ2             : INOUT std_logic := 'U';
        DQ3             : INOUT std_logic := 'U';
        DQ4             : INOUT std_logic := 'U';
        DQ5             : INOUT std_logic := 'U';
        DQ6             : INOUT std_logic := 'U';
        DQ7             : INOUT std_logic := 'U';
        DQ8             : INOUT std_logic := 'U';
        DQ9             : INOUT std_logic := 'U';
        DQ10            : INOUT std_logic := 'U';
        DQ11            : INOUT std_logic := 'U';
        DQ12            : INOUT std_logic := 'U';
        DQ13            : INOUT std_logic := 'U';
        DQ14            : INOUT std_logic := 'U';
        DQ15            : INOUT std_logic := 'U';
        CLK             : IN    std_logic := 'U';
        CKE             : IN    std_logic := 'U';
        A0              : IN    std_logic := 'U';
        A1              : IN    std_logic := 'U';
        A2              : IN    std_logic := 'U';
        A3              : IN    std_logic := 'U';
        A4              : IN    std_logic := 'U';
        A5              : IN    std_logic := 'U';
        A6              : IN    std_logic := 'U';
        A7              : IN    std_logic := 'U';
        A8              : IN    std_logic := 'U';
        A9              : IN    std_logic := 'U';
        A10             : IN    std_logic := 'U';
        A11             : IN    std_logic := 'U';
        WENeg           : IN    std_logic := 'U';
        RASNeg          : IN    std_logic := 'U';
        CSNeg           : IN    std_logic := 'U';
        CASNeg          : IN    std_logic := 'U'
    );
    END COMPONENT;

    for all : dsp6713 use entity WORK.dsp6713(VHDL_BEHAVIORAL);
    for all : sram1k8 use entity WORK.sram1k8(VHDL_BEHAVIORAL);
    for all : km416s4030 use entity WORK.km416s4030(VHDL_BEHAVIORAL);
    for all : sram1k16 use entity WORK.sram1k16(VHDL_BEHAVIORAL);

    TYPE Test_type IS (HPI_init,
                       boot_hpi,
                       boot_rom8,
                       boot_rom16,
                       boot_rom32,
                       HPID_write,
                       HPID_read,
                       HPIDa_write,
                       HPIDa_read,
                       HPI_write_thru,
                       HPI_read_thru,
                       HPI_sdram_write_thru,
                       HPI_sdram_read_thru,
                       CPU_start,
                       end_test
                     );

    SIGNAL T_CLKIN           : std_logic := 'X';
    SIGNAL T_CLKOUT2         : std_logic := 'X';
    SIGNAL T_CLKOUT3         : std_logic := 'X';
    SIGNAL T_CLKMODE0        : std_logic := 'X';
    SIGNAL T_TMS             : std_logic := 'X';
    SIGNAL T_TDO             : std_logic := 'X';
    SIGNAL T_TDI             : std_logic := 'X';
    SIGNAL T_TCK             : std_logic := 'X';
    SIGNAL T_TRSTNeg         : std_logic := 'X';
    SIGNAL T_EMU5            : std_logic := 'X';
    SIGNAL T_EMU4            : std_logic := 'X';
    SIGNAL T_EMU3            : std_logic := 'X';
    SIGNAL T_EMU2            : std_logic := 'X';
    SIGNAL T_EMU1            : std_logic := 'X';
    SIGNAL T_EMU0            : std_logic := 'X';
    SIGNAL T_RESETNeg        : std_logic := 'X';
    SIGNAL T_NMI             : std_logic := 'L';
    SIGNAL T_EXTINT7         : std_logic := 'X';
    SIGNAL T_EXTINT6         : std_logic := 'X';
    SIGNAL T_EXTINT5         : std_logic := 'X';
    SIGNAL T_EXTINT4         : std_logic := 'X';
    SIGNAL T_HINTNeg         : std_logic := 'Z';
    SIGNAL T_HCNTL1          : std_logic := 'H';
    SIGNAL T_HCNTL0          : std_logic := 'H';
    SIGNAL T_HHWIL           : std_logic := 'Z';
    SIGNAL T_HR              : std_logic := 'Z';
    SIGNAL T_HASNeg          : std_logic := 'H';
    SIGNAL T_HCSNeg          : std_logic := 'H';
    SIGNAL T_HDS1Neg         : std_logic := 'H';
    SIGNAL T_HDS2Neg         : std_logic := 'H';
    SIGNAL T_HRDYNeg         : std_logic := 'Z';
    SIGNAL T_HD              : std_logic_vector(15 downto 0) := (others => 'Z');
    SIGNAL T_CE3Neg         : std_logic := 'X';
    SIGNAL T_CE2Neg         : std_logic := 'X';
    SIGNAL T_CE1Neg         : std_logic := 'X';
    SIGNAL T_CE0Neg         : std_logic := 'X';
    SIGNAL T_BE0Neg         : std_logic := 'X';
    SIGNAL T_BE1Neg         : std_logic := 'X';
    SIGNAL T_BE2Neg         : std_logic := 'X';
    SIGNAL T_BE3Neg         : std_logic := 'X';
    SIGNAL T_HOLDANeg       : std_logic := 'X';
    SIGNAL T_HOLDNeg        : std_logic := 'X';
    SIGNAL T_BUSREQ         : std_logic := 'X';
    SIGNAL T_ECLKIN         : std_logic := 'X';
    SIGNAL T_ECLKOUT        : std_logic := 'X';
    SIGNAL T_SDCASNeg       : std_logic := 'X';
    SIGNAL T_SDRASNeg       : std_logic := 'X';
    SIGNAL T_SDWENeg        : std_logic := 'X';
    SIGNAL T_ARDY           : std_logic := '1';
    SIGNAL T_EA             : std_logic_vector(21 downto 2) := (others => 'Z');
    SIGNAL T_ED             : std_logic_vector(31 downto 0) := (others => 'Z');
    SIGNAL T_TOUT1          : std_logic := 'X';
    SIGNAL T_TINP1          : std_logic := 'X';
    SIGNAL T_TOUT0          : std_logic := 'X';
    SIGNAL T_TINP0          : std_logic := 'X';
    SIGNAL T_CLKS1          : std_logic := 'X';
    SIGNAL T_CLKR1          : std_logic := 'X';
    SIGNAL T_CLKX1          : std_logic := 'X';
    SIGNAL T_DR1            : std_logic := 'X';
    SIGNAL T_DX1            : std_logic := 'X';
    SIGNAL T_FSR1           : std_logic := 'X';
    SIGNAL T_FSX1           : std_logic := 'X';
    SIGNAL T_CLKS0          : std_logic := 'Z';
    SIGNAL T_CLKR0          : std_logic := 'X';
    SIGNAL T_CLKX0          : std_logic := 'X';
    SIGNAL T_DR0            : std_logic := 'X';
    SIGNAL T_DX0            : std_logic := 'X';
    SIGNAL T_FSR0           : std_logic := 'X';
    SIGNAL T_FSX0           : std_logic := 'X';
    SIGNAL T_SCL0           : std_logic := 'X';
    SIGNAL T_SDA0           : std_logic := 'X';
    SIGNAL T_ROM8           : std_logic := '0';
    SIGNAL T_ROM16          : std_logic := '0';
    SIGNAL T_ROM32          : std_logic := '0';
    SIGNAL T_SBSRAM         : std_logic := '0';
    SIGNAL T_ROMOR          : std_logic := '0';
    SIGNAL ONE              : std_logic := '1';
    SIGNAL ZERO             : std_logic := '0';
    SIGNAL FSenable         : Boolean := false;
    SIGNAL CLK_mode         : std_logic := '0';
    SIGNAL CLK_external     : std_logic := '0';
    SIGNAL CLK_block        : std_logic := '0';
    SIGNAL test             : Test_type;
    --multiplexed pins
    ALIAS T_AXR01              : std_logic IS T_HR;
    ALIAS T_ACLKX1            : std_logic IS T_HASNeg;
    ALIAS T_AFSX1             : std_logic IS T_HD(2);
    ALIAS T_AXR11             : std_logic IS T_HCNTL1;
    ALIAS T_AXR21             : std_logic IS T_HCSNeg;
    ALIAS T_AXR31             : std_logic IS T_HCNTL0;

    SHARED VARIABLE CLK_EN  : BOOLEAN := TRUE;

BEGIN
    -- Functional Component
    dsp6713_1 : dsp6713
        GENERIC MAP(
            -- tipd delays: interconnect path delays
            tipd_CLKIN => VitalZeroDelay01,
            tipd_CLKOUT2 => VitalZeroDelay01,
            tipd_CLKMODE0 => VitalZeroDelay01,
            tipd_TMS => VitalZeroDelay01,
            tipd_TDI => VitalZeroDelay01,
            tipd_TCK => VitalZeroDelay01,
            tipd_TRSTNeg => VitalZeroDelay01,
            tipd_EMU0 => VitalZeroDelay01,
            tipd_EMU1 => VitalZeroDelay01,
            tipd_EMU2 => VitalZeroDelay01,
            tipd_EMU3 => VitalZeroDelay01,
            tipd_EMU4 => VitalZeroDelay01,
            tipd_EMU5 => VitalZeroDelay01,
            tipd_RESETNeg => VitalZeroDelay01,
            tipd_NMI => VitalZeroDelay01,
            tipd_EXTINT4 => VitalZeroDelay01,
            tipd_EXTINT5 => VitalZeroDelay01,
            tipd_EXTINT6 => VitalZeroDelay01,
            tipd_EXTINT7 => VitalZeroDelay01,
            tipd_HCNTL1 => VitalZeroDelay01,
            tipd_HCNTL0 => VitalZeroDelay01,
            tipd_HINTNeg => VitalZeroDelay01,
            tipd_HHWIL => VitalZeroDelay01,
            tipd_HR => VitalZeroDelay01,
            tipd_HD0 => VitalZeroDelay01,
            tipd_HD1 => VitalZeroDelay01,
            tipd_HD2 => VitalZeroDelay01,
            tipd_HD3 => VitalZeroDelay01,
            tipd_HD4 => VitalZeroDelay01,
            tipd_HD5 => VitalZeroDelay01,
            tipd_HD6 => VitalZeroDelay01,
            tipd_HD7 => VitalZeroDelay01,
            tipd_HD8 => VitalZeroDelay01,
            tipd_HD9 => VitalZeroDelay01,
            tipd_HD10 => VitalZeroDelay01,
            tipd_HD11 => VitalZeroDelay01,
            tipd_HD12 => VitalZeroDelay01,
            tipd_HD13 => VitalZeroDelay01,
            tipd_HD14 => VitalZeroDelay01,
            tipd_HD15 => VitalZeroDelay01,
            tipd_HASNeg => VitalZeroDelay01,
            tipd_HCSNeg => VitalZeroDelay01,
            tipd_HDS1Neg => VitalZeroDelay01,
            tipd_HDS2Neg => VitalZeroDelay01,
            tipd_HRDYNeg => VitalZeroDelay01,
            tipd_HOLDNeg => VitalZeroDelay01,
            tipd_ECLKIN => VitalZeroDelay01,
            tipd_ARDY => VitalZeroDelay01,
            tipd_ED0 => VitalZeroDelay01,
            tipd_ED1 => VitalZeroDelay01,
            tipd_ED2 => VitalZeroDelay01,
            tipd_ED3 => VitalZeroDelay01,
            tipd_ED4 => VitalZeroDelay01,
            tipd_ED5 => VitalZeroDelay01,
            tipd_ED6 => VitalZeroDelay01,
            tipd_ED7 => VitalZeroDelay01,
            tipd_ED8 => VitalZeroDelay01,
            tipd_ED9 => VitalZeroDelay01,
            tipd_ED10 => VitalZeroDelay01,
            tipd_ED11 => VitalZeroDelay01,
            tipd_ED12 => VitalZeroDelay01,
            tipd_ED13 => VitalZeroDelay01,
            tipd_ED14 => VitalZeroDelay01,
            tipd_ED15 => VitalZeroDelay01,
            tipd_ED16 => VitalZeroDelay01,
            tipd_ED17 => VitalZeroDelay01,
            tipd_ED18 => VitalZeroDelay01,
            tipd_ED19 => VitalZeroDelay01,
            tipd_ED20 => VitalZeroDelay01,
            tipd_ED21 => VitalZeroDelay01,
            tipd_ED22 => VitalZeroDelay01,
            tipd_ED23 => VitalZeroDelay01,
            tipd_ED24 => VitalZeroDelay01,
            tipd_ED25 => VitalZeroDelay01,
            tipd_ED26 => VitalZeroDelay01,
            tipd_ED27 => VitalZeroDelay01,
            tipd_ED28 => VitalZeroDelay01,
            tipd_ED29 => VitalZeroDelay01,
            tipd_ED30 => VitalZeroDelay01,
            tipd_ED31 => VitalZeroDelay01,
            tipd_TINP1 => VitalZeroDelay01,
            tipd_TOUT1 => VitalZeroDelay01,
            tipd_TINP0 => VitalZeroDelay01,
            tipd_TOUT0 => VitalZeroDelay01,
            tipd_CLKS1 => VitalZeroDelay01,
            tipd_CLKR1 => VitalZeroDelay01,
            tipd_CLKX1 => VitalZeroDelay01,
            tipd_DR1 => VitalZeroDelay01,
            tipd_DX1 => VitalZeroDelay01,
            tipd_DX0 => VitalZeroDelay01,
            tipd_FSR1 => VitalZeroDelay01,
            tipd_FSX1 => VitalZeroDelay01,
            tipd_CLKS0 => VitalZeroDelay01,
            tipd_CLKR0 => VitalZeroDelay01,
            tipd_CLKX0 => VitalZeroDelay01,
            tipd_DR0 => VitalZeroDelay01,
            tipd_FSR0 => VitalZeroDelay01,
            tipd_FSX0 => VitalZeroDelay01,
            tipd_SCL0 => VitalZeroDelay01,
            tipd_SDA0 => VitalZeroDelay01,
            -- tpd delays
            tpd_CLKIN_CLKOUT2 => UnitDelay01,
            tpd_CLKIN_CLKOUT3 => UnitDelay01,
            tpd_ECLKIN_ECLKOUT => UnitDelay01,
            tpd_HCSNeg_HRDYNeg => UnitDelay01,
            tpd_HASNeg_HRDYNeg => UnitDelay01,
            tpd_HSTROB_HRDYNeg => UnitDelay01,
            tpd_ECLKIN_BUSREQ => UnitDelay01Z,
            tpd_ECLKIN_HOLDANeg => UnitDelay01Z,
            tpd_ECLKIN_CE0Neg => UnitDelay01Z,
            tpd_ECLKIN_BE0Neg => UnitDelay01Z,
            tpd_ECLKIN_SDCASNeg => UnitDelay01Z,
            tpd_ECLKIN_SDRASNeg => UnitDelay01Z,
            tpd_ECLKIN_SDWENeg => UnitDelay01Z,
            tpd_ECLKIN_EA2 => UnitDelay01Z,
            tpd_ECLKIN_ED0 => UnitDelay01Z,
            tpd_CLKS_CLKR => UnitDelay01,
            tpd_CLKS_CLKX => UnitDelay01,
            tpd_ACLKX1_AXR => UnitDelay01,
            tpd_ACLKX1EXT_AXR => UnitDelay01,
            -- tpw values: pulse widths
            tpw_ECLKIN_negedge => UnitDelay,
            tpw_ECLKIN_posedge => UnitDelay,
            tpw_RESETNeg_negedge => UnitDelay,
            tpw_AHCLKR1_negedge => UnitDelay,
            tpw_AHCLKR1_posedge => UnitDelay,
            tpw_AHCLKX1_negedge => UnitDelay,
            tpw_AHCLKX1_posedge => UnitDelay,
            tpw_ACLKR1_negedge => UnitDelay,
            tpw_ACLKR1_posedge => UnitDelay,
            tpw_ACLKX1_negedge => UnitDelay,
            tpw_ACLKX1_posedge => UnitDelay,
            -- tperiod min (calculated as 1/max freq)
            tperiod_CLKIN_PLLEN_EQ_0_posedge => UnitDelay,
            tperiod_CLKIN_PLLEN_EQ_1_posedge => UnitDelay,
            tperiod_ECLKIN_posedge => UnitDelay,
            tperiod_AHCLKR1_posedge => UnitDelay,
            tperiod_AHCLKX1_posedge => UnitDelay,
            tperiod_ACLKR1_posedge => UnitDelay,
            tperiod_ACLKX1_posedge => UnitDelay,
            -- tsetup values: setup times
            tsetup_HR_HCSNeg => UnitDelay,
            tsetup_HR_HASNeg => UnitDelay,
            tsetup_HD0_HCSNeg => UnitDelay,
            tsetup_ARDY_ECLKOUT => UnitDelay,
            tsetup_ED0_ECLKOUT => UnitDelay,
            tsetup_ED0_SDCASNeg => UnitDelay,
            tsetup_FSR_CLKR => UnitDelay,
            tsetup_FSX_CLKX => UnitDelay,
            tsetup_DR_CLKR => UnitDelay,
            tsetup_AXR1In_ACLKR1 => UnitDelay,
            -- thold values: hold times
            thold_HR_HCSNeg => UnitDelay,
            thold_HR_HASNeg => UnitDelay,
            thold_HD0_HCSNeg => UnitDelay,
            thold_HCSNeg_HRDYNeg => UnitDelay,
            thold_ARDY_ECLKOUT => UnitDelay,
            thold_ED0_ECLKOUT => UnitDelay,
            thold_ED0_SDCASNeg => UnitDelay,
            thold_FSR_CLKR => UnitDelay,
            thold_FSX_CLKX => UnitDelay,
            thold_DR_CLKR => UnitDelay,
            thold_AXR1In_ACLKR1 => UnitDelay,
            -- generic control parameters
            InstancePath => DefaultInstancePath,
            TimingChecksOn => true,
            MsgOn => DefaultMsgOn,
            XOn => DefaultXon,
            -- command file to be loaded
            command_file_name => "dsp6713.vec",
            -- time to auto-start CPU
            cpu_autostart_time => 6 ms,
            -- For FMF SDF technology file usage
            TimingModel => "TMS320C6713PYPA167"
    )
        PORT MAP(
        CLKIN          => T_CLKIN,
        CLKOUT2        => T_CLKOUT2,
        CLKOUT3        => T_CLKOUT3,
        CLKMODE0       => T_CLKMODE0,
        TMS            => T_TMS,
        TDO            => T_TDO,
        TDI            => T_TDI,
        TCK            => T_TCK,
        TRSTNeg        => T_TRSTNeg,
        EMU0           => T_EMU0,
        EMU1           => T_EMU1,
        EMU2           => T_EMU2,
        EMU3           => T_EMU3,
        EMU4           => T_EMU4,
        EMU5           => T_EMU5,
        RESETNeg       => T_RESETNeg,
        NMI            => T_NMI,
        EXTINT4        => T_EXTINT4,
        EXTINT5        => T_EXTINT5,
        EXTINT6        => T_EXTINT6,
        EXTINT7        => T_EXTINT7,
        HINTNeg        => T_HINTNeg,
        HCNTL1         => T_HCNTL1,
        HCNTL0         => T_HCNTL0,
        HHWIL          => T_HHWIL,
        HR             => T_HR,
        HD0            => T_HD(0),
        HD1            => T_HD(1),
        HD2            => T_HD(2),
        HD3            => T_HD(3),
        HD4            => T_HD(4),
        HD5            => T_HD(5),
        HD6            => T_HD(6),
        HD7            => T_HD(7),
        HD8            => T_HD(8),
        HD9            => T_HD(9),
        HD10           => T_HD(10),
        HD11           => T_HD(11),
        HD12           => T_HD(12),
        HD13           => T_HD(13),
        HD14           => T_HD(14),
        HD15           => T_HD(15),
        HASNeg         => T_HASNeg,
        HCSNeg         => T_HCSNeg,
        HDS1Neg        => T_HDS1Neg,
        HDS2Neg        => T_HDS2Neg,
        HRDYNeg        => T_HRDYNeg,
        CE3Neg         => T_CE3Neg,
        CE2Neg         => T_CE2Neg,
        CE1Neg         => T_CE1Neg,
        CE0Neg         => T_CE0Neg,
        BE0Neg         => T_BE0Neg,
        BE1Neg         => T_BE1Neg,
        BE2Neg         => T_BE2Neg,
        BE3Neg         => T_BE3Neg,
        HOLDANeg       => T_HOLDANeg,
        HOLDNeg        => T_HOLDNeg,
        BUSREQ         => T_BUSREQ,
        ECLKIN         => T_ECLKIN,
        ECLKOUT        => T_ECLKOUT,
        SDCASNeg       => T_SDCASNeg,
        SDRASNeg       => T_SDRASNeg,
        SDWENeg        => T_SDWENeg,
        ARDY           => T_ARDY,
        EA2            => T_EA(2),
        EA3            => T_EA(3),
        EA4            => T_EA(4),
        EA5            => T_EA(5),
        EA6            => T_EA(6),
        EA7            => T_EA(7),
        EA8            => T_EA(8),
        EA9            => T_EA(9),
        EA10           => T_EA(10),
        EA11           => T_EA(11),
        EA12           => T_EA(12),
        EA13           => T_EA(13),
        EA14           => T_EA(14),
        EA15           => T_EA(15),
        EA16           => T_EA(16),
        EA17           => T_EA(17),
        EA18           => T_EA(18),
        EA19           => T_EA(19),
        EA20           => T_EA(20),
        EA21           => T_EA(21),
        ED0            => T_ED(0),
        ED1            => T_ED(1),
        ED2            => T_ED(2),
        ED3            => T_ED(3),
        ED4            => T_ED(4),
        ED5            => T_ED(5),
        ED6            => T_ED(6),
        ED7            => T_ED(7),
        ED8            => T_ED(8),
        ED9            => T_ED(9),
        ED10           => T_ED(10),
        ED11           => T_ED(11),
        ED12           => T_ED(12),
        ED13           => T_ED(13),
        ED14           => T_ED(14),
        ED15           => T_ED(15),
        ED16           => T_ED(16),
        ED17           => T_ED(17),
        ED18           => T_ED(18),
        ED19           => T_ED(19),
        ED20           => T_ED(20),
        ED21           => T_ED(21),
        ED22           => T_ED(22),
        ED23           => T_ED(23),
        ED24           => T_ED(24),
        ED25           => T_ED(25),
        ED26           => T_ED(26),
        ED27           => T_ED(27),
        ED28           => T_ED(28),
        ED29           => T_ED(29),
        ED30           => T_ED(30),
        ED31           => T_ED(31),
        TOUT1          => T_TOUT1,
        TINP1          => T_TINP1,
        TOUT0          => T_TOUT0,
        TINP0          => T_TINP0,
        CLKS1          => T_CLKS1,
        CLKR1          => T_CLKR1,
        CLKX1          => T_CLKX1,
        DR1            => T_DR1,
        DX1            => T_DX1,
        FSR1           => T_FSR1,
        FSX1           => T_FSX1,
        CLKS0          => T_CLKS0,
        CLKR0          => T_CLKR0,
        CLKX0          => T_CLKX0,
        DR0            => T_DR0,
        DX0            => T_DX0,
        FSR0           => T_FSR0,
        FSX0           => T_FSX0,
        SCL0           => T_SCL0,
        SDA0           => T_SDA0
        );

    sram_1 : sram1k8
        PORT MAP(
        A0        => T_EA(2),
        A1        => T_EA(3),
        A2        => T_EA(4),
        A3        => T_EA(5),
        A4        => T_EA(6),
        A5        => T_EA(7),
        A6        => T_EA(8),
        A7        => T_EA(9),
        A8        => T_EA(10),
        A9        => T_EA(11),
        D0        => T_ED(0),
        D1        => T_ED(1),
        D2        => T_ED(2),
        D3        => T_ED(3),
        D4        => T_ED(4),
        D5        => T_ED(5),
        D6        => T_ED(6),
        D7        => T_ED(7),
        OENeg     => T_SDRASNeg,
        WENeg     => T_SDWENeg,
        CENeg     => T_CE0Neg,
        CE        => T_ROM8
        );

    sram_2 : sram1k16
        PORT MAP(
        A0        => T_EA(2),
        A1        => T_EA(3),
        A2        => T_EA(4),
        A3        => T_EA(5),
        A4        => T_EA(6),
        A5        => T_EA(7),
        A6        => T_EA(8),
        A7        => T_EA(9),
        A8        => T_EA(10),
        A9        => T_EA(11),
        D0        => T_ED(0),
        D1        => T_ED(1),
        D2        => T_ED(2),
        D3        => T_ED(3),
        D4        => T_ED(4),
        D5        => T_ED(5),
        D6        => T_ED(6),
        D7        => T_ED(7),
        D8        => T_ED(8),
        D9        => T_ED(9),
        D10       => T_ED(10),
        D11       => T_ED(11),
        D12       => T_ED(12),
        D13       => T_ED(13),
        D14       => T_ED(14),
        D15       => T_ED(15),
        OENeg     => T_SDRASNeg,
        WENeg     => T_SDWENeg,
        CENeg     => T_ROMOR,
        CE        => T_ROM16
        );

    sram_3 : sram1k16
        PORT MAP(
        A0        => T_EA(2),
        A1        => T_EA(3),
        A2        => T_EA(4),
        A3        => T_EA(5),
        A4        => T_EA(6),
        A5        => T_EA(7),
        A6        => T_EA(8),
        A7        => T_EA(9),
        A8        => T_EA(10),
        A9        => T_EA(11),
        D0        => T_ED(16),
        D1        => T_ED(17),
        D2        => T_ED(18),
        D3        => T_ED(19),
        D4        => T_ED(20),
        D5        => T_ED(21),
        D6        => T_ED(22),
        D7        => T_ED(23),
        D8        => T_ED(24),
        D9        => T_ED(25),
        D10       => T_ED(26),
        D11       => T_ED(27),
        D12       => T_ED(28),
        D13       => T_ED(29),
        D14       => T_ED(30),
        D15       => T_ED(31),
        OENeg     => T_SDRASNeg,
        WENeg     => T_SDWENeg,
        CENeg     => T_CE3Neg,
        CE        => T_ROM32
        );

    -- Functional Component
    km416s4030_1 : km416s4030
        GENERIC MAP(
            -- tdevice values: values for internal delays
            tdevice_REF => 15_625 ns,
            tdevice_TRC => 90 ns,
            tdevice_TRCD => 30 ns,
            tdevice_TRP => 30 ns,
            tdevice_TRCAR => 90 ns,
            tdevice_TWR => 15 ns,
            tdevice_TRAS => (60 ns, 120_000 ns),
            -- tpowerup: Power up initialization time. Data sheets say 100 us.
            -- May be shortened during simulation debug.
            tpowerup => 10 us,
            -- generic control parameters
            InstancePath => DefaultInstancePath,
            TimingChecksOn => True,
            MsgOn => DefaultMsgOn,
            XOn => DefaultXon,
            SeverityMode => WARNING,
            -- memory file to be loaded
            mem_file_name => "km416s4030.mem",
            -- For FMF SDF technology file usage
            TimingModel => "MT48LC4M16A2TG-10"
        )

        PORT MAP(
        BA0            => T_EA(14),
        BA1            => T_EA(15),
        DQML           => T_BE0Neg,
        DQMU           => T_BE1Neg,
        DQ0            => T_ED(0),
        DQ1            => T_ED(1),
        DQ2            => T_ED(2),
        DQ3            => T_ED(3),
        DQ4            => T_ED(4),
        DQ5            => T_ED(5),
        DQ6            => T_ED(6),
        DQ7            => T_ED(7),
        DQ8            => T_ED(8),
        DQ9            => T_ED(9),
        DQ10           => T_ED(10),
        DQ11           => T_ED(11),
        DQ12           => T_ED(12),
        DQ13           => T_ED(13),
        DQ14           => T_ED(14),
        DQ15           => T_ED(15),
        CLK            => T_ECLKOUT,
        CKE            => ONE,
        A0             => T_EA(2),
        A1             => T_EA(3),
        A2             => T_EA(4),
        A3             => T_EA(5),
        A4             => T_EA(6),
        A5             => T_EA(7),
        A6             => T_EA(8),
        A7             => T_EA(9),
        A8             => T_EA(10),
        A9             => T_EA(11),
        A10            => T_EA(12),
        A11            => T_EA(13),
        WENeg          => T_SDWENeg,
        RASNeg         => T_SDRASNeg,
        CSNeg          => T_CE1Neg,
        CASNeg         => T_SDCASNeg
        );

    -- Functional Component
    km416s4030_2 : km416s4030
        GENERIC MAP(
            -- tdevice values: values for internal delays
            tdevice_REF => 15_625 ns,
            tdevice_TRC => 90 ns,
            tdevice_TRCD => 30 ns,
            tdevice_TRP => 30 ns,
            tdevice_TRCAR => 90 ns,
            tdevice_TWR => 15 ns,
            tdevice_TRAS => (60 ns, 120_000 ns),
            -- tpowerup: Power up initialization time. Data sheets say 100 us.
            -- May be shortened during simulation debug.
            tpowerup => 10 us,
            -- generic control parameters
            InstancePath => DefaultInstancePath,
            TimingChecksOn => True,
            MsgOn => DefaultMsgOn,
            XOn => DefaultXon,
            SeverityMode => WARNING,
            mem_file_name => "km416s4030.mem",
            -- For FMF SDF technology file usage
            TimingModel => "MT48LC4M16A2TG-10"
        )

        PORT MAP(
        BA0            => T_EA(14),
        BA1            => T_EA(15),
        DQML           => T_BE2Neg,
        DQMU           => T_BE3Neg,
        DQ0            => T_ED(16),
        DQ1            => T_ED(17),
        DQ2            => T_ED(18),
        DQ3            => T_ED(19),
        DQ4            => T_ED(20),
        DQ5            => T_ED(21),
        DQ6            => T_ED(22),
        DQ7            => T_ED(23),
        DQ8            => T_ED(24),
        DQ9            => T_ED(25),
        DQ10           => T_ED(26),
        DQ11           => T_ED(27),
        DQ12           => T_ED(28),
        DQ13           => T_ED(29),
        DQ14           => T_ED(30),
        DQ15           => T_ED(31),
        CLK            => T_ECLKOUT,
        CKE            => ONE,
        A0             => T_EA(2),
        A1             => T_EA(3),
        A2             => T_EA(4),
        A3             => T_EA(5),
        A4             => T_EA(6),
        A5             => T_EA(7),
        A6             => T_EA(8),
        A7             => T_EA(9),
        A8             => T_EA(10),
        A9             => T_EA(11),
        A10            => T_EA(12),
        A11            => T_EA(13),
        WENeg          => T_SDWENeg,
        RASNeg         => T_SDRASNeg,
        CSNeg          => T_CE1Neg,
        CASNeg         => T_SDCASNeg
        );

    T_BE0Neg <= 'H';
    T_BE1Neg <= 'H';
    T_BE2Neg <= 'H';
    T_BE3Neg <= 'H';
    T_CE0Neg <= 'H';
    T_CE1Neg <= 'H';
    T_CE2Neg <= 'H';
    T_CE3Neg <= 'H';
    T_ROMOR <= T_CE2Neg AND T_CE3Neg;

ClockIn : PROCESS
BEGIN
    IF CLK_EN THEN
        T_CLKIN <= '0', '1' AFTER ClkIn_width;
        WAIT FOR ClkIn_cycle;
    ELSE
        WAIT;
    END IF;
END PROCESS ClockIn;

EClockIn : PROCESS
BEGIN
    IF CLK_EN THEN
        T_ECLKIN <= '0', '1' AFTER EClk_width;
        WAIT FOR EClk_cycle;
    ELSE
        WAIT;
    END IF;
END PROCESS EClockIn;

Stim: PROCESS

    TYPE HPIreg_type IS (HPIC,
                         HPIA,
                         HPIDa,
                         HPID
                       );

    TYPE HPI_op IS (HPIWrite0,
                    HPIWrite1,
                    HPIWrite2,
                    HPIRead0,
                    HPIRead1,
                    HPIRead2
                  );

    TYPE HPI_command_type IS
                   (write0_hpic,
                    write0_hpia,
                    write0_hpida,
                    write0_hpid,
                    read0_hpic,
                    read0_hpia,
                    read0_hpida,
                    read0_hpid,
                    write1_hpic,
                    write1_hpia,
                    write1_hpida,
                    write1_hpid,
                    read1_hpic,
                    read1_hpia,
                    read1_hpida,
                    read1_hpid
                  );

    TYPE boot_type IS
             (hpi,
              rom8,
              rom16,
              rom32
              );

    VARIABLE HPI_command : HPI_command_type;
    VARIABLE boot_src : boot_type;

    PROCEDURE HPI
        (HPIreg : IN HPIreg_type;
         OP     : IN HPI_op;
         HData1 : IN NATURAL := 0;
         HData0 : IN NATURAL := 0;
         XData1 : IN NATURAL := 0;
         XData0 : IN NATURAL := 0)
    IS
        VARIABLE HD1 : std_logic_vector(15 downto 0);
        VARIABLE HD0 : std_logic_vector(15 downto 0);
    BEGIN
        CASE OP IS
            WHEN HPIWrite0 =>
                HD1 := to_slv(HData1,16);
                HD0 := to_slv(HData0,16);
                T_HASNeg <= 'H';
                T_HDS2Neg <= 'H';
                T_HCSNeg <= 'L' AFTER 2 ns;
                CASE HPIreg IS
                    WHEN HPIC =>
                        T_HCNTL0 <= 'L' AFTER 8 ns;
                        T_HCNTL1 <= 'L' AFTER 8 ns;
                        HPI_command := write0_hpic;
                    WHEN HPIA =>
                        T_HCNTL0 <= 'H' AFTER 8 ns;
                        T_HCNTL1 <= 'L' AFTER 8 ns;
                        HPI_command := write0_hpia;
                    WHEN HPIDa =>
                        T_HCNTL0 <= 'L' AFTER 8 ns;
                        T_HCNTL1 <= 'H' AFTER 8 ns;
                        HPI_command := write0_hpida;
                    WHEN HPID =>
                        T_HCNTL0 <= 'H' AFTER 8 ns;
                        T_HCNTL1 <= 'H' AFTER 8 ns;
                        HPI_command := write0_hpid;
                END CASE;
                T_HR <= 'L' AFTER 8 ns;
                T_HHWIL <= 'L' AFTER 8 ns, 'H' AFTER 45 ns;
                WAIT FOR 14 ns;
                T_HDS1Neg <= 'L';
                WAIT FOR 10 ns;
                IF T_HRDYNeg = '1' THEN
                    WAIT UNTIL T_HRDYNeg = '0';
                END IF;
                T_HD <= HD0(15 downto 0);
                WAIT FOR 46 ns;
                T_HDS1Neg <= 'H';
                WAIT FOR 3 ns;
                T_HD <= (OTHERS => 'Z');
                WAIT FOR 56 ns;
                T_HDS1Neg <= 'L';
                WAIT FOR 20 ns;
                T_HR <= 'H';
                T_HD <= HD1(15 downto 0);
                T_HCNTL0 <= 'H';
                T_HCNTL1 <= 'H';
                WAIT FOR 36 ns;
                T_HDS1Neg <= 'H';
                WAIT FOR 3 ns;
                T_HD <= (OTHERS => 'Z');
                T_HCSNeg <= 'H';

            WHEN HPIWrite1 =>
                HD1 := to_slv(HData1,16);
                HD0 := to_slv(HData0,16);
                T_HASNeg <= 'H';
                T_HDS2Neg <= 'H';
                T_HCSNeg <= 'L' AFTER 2 ns;
                CASE HPIreg IS
                    WHEN HPIC =>
                        T_HCNTL0 <= 'L' AFTER 8 ns;
                        T_HCNTL1 <= 'L' AFTER 8 ns;
                        HPI_command := write0_hpic;
                    WHEN HPIA =>
                        T_HCNTL0 <= 'H' AFTER 8 ns;
                        T_HCNTL1 <= 'L' AFTER 8 ns;
                        HPI_command := write0_hpia;
                    WHEN HPIDa =>
                        T_HCNTL0 <= 'L' AFTER 8 ns;
                        T_HCNTL1 <= 'H' AFTER 8 ns;
                        HPI_command := write0_hpida;
                    WHEN HPID =>
                        T_HCNTL0 <= 'H' AFTER 8 ns;
                        T_HCNTL1 <= 'H' AFTER 8 ns;
                        HPI_command := write0_hpid;
                END CASE;
                T_HR <= 'L' AFTER 8 ns;
                T_HHWIL <= 'L' AFTER 8 ns, 'H' AFTER 45 ns;
                WAIT FOR 14 ns;
                T_HASNeg <= 'L';
                WAIT FOR 4 ns;
                T_HDS1Neg <= 'L';
                WAIT FOR 6 ns;
                T_HASNeg <= 'H';
                IF T_HRDYNeg = '1' THEN
                    WAIT UNTIL T_HRDYNeg = '0';
                END IF;
                T_HD <= HD0(15 downto 0);
                WAIT FOR 50 ns;
                T_HDS1Neg <= 'H';
                WAIT FOR 3 ns;
                T_HD <= (OTHERS => 'Z');
                WAIT FOR 56 ns;
                T_HASNeg <= 'L';
                WAIT FOR 4 ns;
                T_HDS1Neg <= 'L';
                WAIT FOR 1 ns;
                T_HASNeg <= 'H';
                WAIT FOR 20 ns;
                T_HR <= 'H';
                T_HD <= HD1(15 downto 0);
                T_HCNTL0 <= 'H';
                T_HCNTL1 <= 'H';
                WAIT FOR 36 ns;
                T_HDS1Neg <= 'H';
                WAIT FOR 3 ns;
                T_HD <= (OTHERS => 'Z');
                T_HCSNeg <= 'H';

            WHEN HPIWrite2 =>
                HD1 := to_slv(HData1,16);
                HD0 := to_slv(HData0,16);
                T_HASNeg <= 'H';
                T_HDS2Neg <= 'H';
                T_HCSNeg <= 'L' AFTER 2 ns;
                CASE HPIreg IS
                    WHEN HPIC =>
                        T_HCNTL0 <= 'L' AFTER 8 ns;
                        T_HCNTL1 <= 'L' AFTER 8 ns;
                        HPI_command := write0_hpic;
                    WHEN HPIA =>
                        T_HCNTL0 <= 'H' AFTER 8 ns;
                        T_HCNTL1 <= 'L' AFTER 8 ns;
                        HPI_command := write0_hpia;
                    WHEN HPIDa =>
                        T_HCNTL0 <= 'L' AFTER 8 ns;
                        T_HCNTL1 <= 'H' AFTER 8 ns;
                        HPI_command := write0_hpida;
                    WHEN HPID =>
                        T_HCNTL0 <= 'H' AFTER 8 ns;
                        T_HCNTL1 <= 'H' AFTER 8 ns;
                        HPI_command := write0_hpid;
                END CASE;
                T_HR <= 'L' AFTER 8 ns;
                T_HHWIL <= 'L' AFTER 8 ns, 'H' AFTER 45 ns;
                WAIT FOR 14 ns;
                T_HDS1Neg <= 'L';
                WAIT FOR 10 ns;
                T_ARDY <= 'L', 'H' AFTER 997 ns;
                IF T_HRDYNeg = '1' THEN
                    WAIT UNTIL T_HRDYNeg = '0';
                END IF;
                T_HD <= HD0(15 downto 0);
                WAIT FOR 46 ns;
                T_HDS1Neg <= 'H';
                WAIT FOR 3 ns;
                T_HD <= (OTHERS => 'Z');
                WAIT FOR 56 ns;
                T_HDS1Neg <= 'L';
                WAIT FOR 20 ns;
                T_HR <= 'H';
                T_HD <= HD1(15 downto 0);
                T_HCNTL0 <= 'H';
                T_HCNTL1 <= 'H';
                WAIT FOR 36 ns;
                T_HDS1Neg <= 'H';
                WAIT FOR 3 ns;
                T_HD <= (OTHERS => 'Z');
                T_HCSNeg <= 'H';

            WHEN HPIRead0 =>
                T_HASNeg <= 'H';
                T_HDS2Neg <= 'H';
                T_HCSNeg <= 'L' AFTER 2 ns;
                CASE HPIreg IS
                    WHEN HPIC =>
                        T_HCNTL0 <= 'L' AFTER 8 ns;
                        T_HCNTL1 <= 'L' AFTER 8 ns;
                        HPI_command := read0_hpic;
                    WHEN HPIA =>
                        T_HCNTL0 <= 'H' AFTER 8 ns;
                        T_HCNTL1 <= 'L' AFTER 8 ns;
                        HPI_command := read0_hpia;
                    WHEN HPIDa =>
                        T_HCNTL0 <= 'L' AFTER 8 ns;
                        T_HCNTL1 <= 'H' AFTER 8 ns;
                        HPI_command := read0_hpida;
                    WHEN HPID =>
                        T_HCNTL0 <= 'H' AFTER 8 ns;
                        T_HCNTL1 <= 'H' AFTER 8 ns;
                        HPI_command := read0_hpid;
                END CASE;
                T_HR <= 'H';
                T_HHWIL <= 'L' AFTER 8 ns, 'H' AFTER 45 ns;
                WAIT FOR 14 ns;
                T_HDS1Neg <= 'L';
                WAIT FOR 10 ns;
                IF T_HRDYNeg = '1' THEN
                    WAIT UNTIL T_HRDYNeg = '0';
                END IF;
                WAIT FOR 46 ns;
                ASSERT T_HD = to_slv(XData0, 16)
                    REPORT "expected " & to_hex_str(XData0) &
                           ", got " & to_hex_str(T_HD)
                    SEVERITY error;
                T_HDS1Neg <= 'H';
                WAIT FOR 56 ns;
                T_HDS1Neg <= 'L';
                WAIT FOR 14 ns;
                T_HCNTL0 <= 'H';
                T_HCNTL1 <= 'H';
                WAIT FOR 44 ns;
                ASSERT T_HD = to_slv(XData1, 16)
                    REPORT "expected " & to_hex_str(XData1) &
                           ", got " & to_hex_str(T_HD)
                    SEVERITY error;
                T_HDS1Neg <= 'H';
                WAIT FOR 14 ns;
                T_HCSNeg <= 'H';

            WHEN HPIRead1 =>
                T_HASNeg <= 'H';
                T_HDS2Neg <= 'H';
                T_HCSNeg <= 'L' AFTER 2 ns;
                CASE HPIreg IS
                    WHEN HPIC =>
                        T_HCNTL0 <= 'L' AFTER 8 ns;
                        T_HCNTL1 <= 'L' AFTER 8 ns;
                        HPI_command := read1_hpic;
                    WHEN HPIA =>
                        T_HCNTL0 <= 'H' AFTER 8 ns;
                        T_HCNTL1 <= 'L' AFTER 8 ns;
                        HPI_command := read1_hpia;
                    WHEN HPIDa =>
                        T_HCNTL0 <= 'L' AFTER 8 ns;
                        T_HCNTL1 <= 'H' AFTER 8 ns;
                        HPI_command := read1_hpida;
                    WHEN HPID =>
                        T_HCNTL0 <= 'H' AFTER 8 ns;
                        T_HCNTL1 <= 'H' AFTER 8 ns;
                        HPI_command := read1_hpid;
                END CASE;
                T_HR <= 'H';
                T_HHWIL <= 'L' AFTER 8 ns, 'H' AFTER 45 ns;
                WAIT FOR 14 ns;
                T_HASNeg <= 'L';
                WAIT FOR 4 ns;
                T_HDS1Neg <= 'L';
                WAIT FOR 10 ns;
                T_HASNeg <= 'H';
                IF T_HRDYNeg = '1' THEN
                    WAIT UNTIL T_HRDYNeg = '0';
                END IF;
                ASSERT T_HD = to_slv(XData0, 16)
                    REPORT "expected " & to_hex_str(XData0) &
                           ", got " & to_hex_str(T_HD)
                    SEVERITY error;
                WAIT FOR 46 ns;
                T_HDS1Neg <= 'H';
                WAIT FOR 55 ns;
                T_HASNeg <= 'L';
                WAIT FOR 4 ns;
                T_HDS1Neg <= 'L';
                WAIT FOR 1 ns;
                T_HASNeg <= 'H';
                WAIT FOR 14 ns;
                T_HCNTL0 <= 'H';
                T_HCNTL1 <= 'H';
                WAIT FOR 42 ns;
                ASSERT T_HD = to_slv(XData1, 16)
                    REPORT "expected " & to_hex_str(XData1) &
                           ", got " & to_hex_str(T_HD)
                    SEVERITY error;
                T_HDS1Neg <= 'H';
                WAIT FOR 14 ns;
                T_HCSNeg <= 'H';

            WHEN HPIRead2 =>
                T_HASNeg <= 'H';
                T_HDS2Neg <= 'H';
                T_HCSNeg <= 'L' AFTER 2 ns;
                CASE HPIreg IS
                    WHEN HPIC =>
                        T_HCNTL0 <= 'L' AFTER 8 ns;
                        T_HCNTL1 <= 'L' AFTER 8 ns;
                        HPI_command := read0_hpic;
                    WHEN HPIA =>
                        T_HCNTL0 <= 'H' AFTER 8 ns;
                        T_HCNTL1 <= 'L' AFTER 8 ns;
                        HPI_command := read0_hpia;
                    WHEN HPIDa =>
                        T_HCNTL0 <= 'L' AFTER 8 ns;
                        T_HCNTL1 <= 'H' AFTER 8 ns;
                        HPI_command := read0_hpida;
                    WHEN HPID =>
                        T_HCNTL0 <= 'H' AFTER 8 ns;
                        T_HCNTL1 <= 'H' AFTER 8 ns;
                        HPI_command := read0_hpid;
                END CASE;
                T_HR <= 'H';
                T_HHWIL <= 'L' AFTER 8 ns, 'H' AFTER 45 ns;
                WAIT FOR 14 ns;
                T_HDS1Neg <= 'L';
                T_ARDY <= 'L', 'H' AFTER 982 ns;
                WAIT FOR 10 ns;
                IF T_HRDYNeg = '1' THEN
                    WAIT UNTIL T_HRDYNeg = '0';
                END IF;
                WAIT FOR 46 ns;
                ASSERT T_HD = to_slv(XData0, 16)
                    REPORT "expected " & to_hex_str(XData0) &
                           ", got " & to_hex_str(T_HD)
                    SEVERITY error;
                T_HDS1Neg <= 'H';
                WAIT FOR 56 ns;
                T_HDS1Neg <= 'L';
                WAIT FOR 14 ns;
                T_HCNTL0 <= 'H';
                T_HCNTL1 <= 'H';
                WAIT FOR 44 ns;
                ASSERT T_HD = to_slv(XData1, 16)
                    REPORT "expected " & to_hex_str(XData1) &
                           ", got " & to_hex_str(T_HD)
                    SEVERITY error;
                T_HDS1Neg <= 'H';
                WAIT FOR 14 ns;
                T_HCSNeg <= 'H';

        END CASE;

    END HPI;

    PROCEDURE BOOT
        (boot_src : boot_type)
    IS
    BEGIN
        CASE boot_src IS
            WHEN hpi =>
                T_HD(4) <= 'L';
                T_HD(3) <= 'L';
                WAIT FOR 200 ns;
                T_RESETNeg <= 'H';
                WAIT FOR 15 us;
                HPI(HPIC, HPIWrite0, 1, 1);
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0008#); -- CESCR0
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#80F8#, 16#C803#); -- MTYPE=8-bit async
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0004#); -- CESCR1
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#0000#, 16#0030#); -- MTYPE=32-bit SDRAM
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0010#); -- CESCR2
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#80F8#, 16#C813#); -- MTYPE=16-bit async
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0014#); -- CESCR3
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#80F8#, 16#C823#); -- MTYPE=32-bit async
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#001C#); -- SDRMTR
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#0010#, 16#061A#); -- for KM416S4030
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0020#); -- SDRMXR
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#0005#, 16#4541#); -- for KM416S4030
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0018#); -- SDRMCR
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#5511#, 16#6000#); -- for KM416S4030
                WAIT FOR 1000 ns;
                T_ROM8 <= 'H', 'L' AFTER 40 us;
                T_ROM16 <= 'H' AFTER 40 us, 'L' AFTER 50 us;
                T_ROM32 <= 'L';
            WHEN rom8 =>
                T_RESETNeg <= '0';
                T_HD(4) <= 'L';
                T_HD(3) <= 'H';
                WAIT FOR 100 ns;
                T_RESETNeg <= 'H';
                T_ROM8 <= 'H';
                T_ROM16 <= 'H';
                T_ROM32 <= 'L';

                WAIT FOR 5000000 ns;
                HPI(HPIC, HPIWrite0, 1, 1);
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0008#); -- CESCR0
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#80F8#, 16#C803#); -- MTYPE=8-bit async
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0004#); -- CESCR1
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#0000#, 16#0030#); -- MTYPE=32-bit SDRAM
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0010#); -- CESCR2
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#80F8#, 16#C813#); -- MTYPE=16-bit async
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0014#); -- CESCR3
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#80F8#, 16#C823#); -- MTYPE=32-bit async
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#001C#); -- SDRMTR
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#0010#, 16#061A#); -- for KM416S4030
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0020#); -- SDRMXR
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#0005#, 16#4541#); -- for KM416S4030
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0018#); -- SDRMCR
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#5511#, 16#6000#); -- for KM416S4030
                WAIT FOR 1000 ns;
            WHEN rom16 =>
                T_RESETNeg <= '0';
                T_HD(4) <= 'H';
                T_HD(3) <= 'L';
                WAIT FOR 100 ns;
                T_RESETNeg <= 'H';
                T_ROM8 <= 'L';
                T_ROM16 <= 'H';
                T_ROM32 <= 'L';

                WAIT FOR 5000000 ns;
                HPI(HPIC, HPIWrite0, 1, 1);
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0008#); -- CESCR0
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#80F8#, 16#C803#); -- MTYPE=8-bit async
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0004#); -- CESCR1
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#0000#, 16#0030#); -- MTYPE=32-bit SDRAM
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0010#); -- CESCR2
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#80F8#, 16#C813#); -- MTYPE=16-bit async
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0014#); -- CESCR3
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#80F8#, 16#C823#); -- MTYPE=32-bit async
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#001C#); -- SDRMTR
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#0010#, 16#061A#); -- for KM416S4030
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0020#); -- SDRMXR
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#0005#, 16#4541#); -- for KM416S4030
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0018#); -- SDRMCR
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#5511#, 16#6000#); -- for KM416S4030
                WAIT FOR 1000 ns;
            WHEN rom32 =>
                T_RESETNeg <= '0';
                T_HD(4) <= 'H';
                T_HD(3) <= 'H';
                WAIT FOR 100 ns;
                T_RESETNeg <= 'H';
                T_ROM8 <= 'L';
                T_ROM16 <= 'H';
                T_ROM32 <= 'H';

                WAIT FOR 5000000 ns;
                HPI(HPIC, HPIWrite0, 1, 1);
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0008#); -- CESCR0
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#80F8#, 16#C803#); -- MTYPE=8-bit async
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0004#); -- CESCR1
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#0000#, 16#0030#); -- MTYPE=32-bit SDRAM
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0010#); -- CESCR2
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#80F8#, 16#C813#); -- MTYPE=16-bit async
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0014#); -- CESCR3
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#80F8#, 16#C823#); -- MTYPE=32-bit async
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#001C#); -- SDRMTR
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#0010#, 16#061A#); -- for KM416S4030
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0020#); -- SDRMXR
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#0005#, 16#4541#); -- for KM416S4030
                WAIT FOR 100 ns;
                HPI(HPIA, HPIWrite0, 16#0180#, 16#0018#); -- SDRMCR
                WAIT FOR 100 ns;
                HPI(HPID, HPIWrite0, 16#5511#, 16#6000#); -- for KM416S4030
                WAIT FOR 1000 ns;
        END CASE;
    END BOOT;

    BEGIN
        T_RESETNeg <= '0';
        T_CLKMODE0 <= 'H';

        -- to set HPI_EN High(HPI enabled, McASP1 disabled) uncomment this line
        T_HD(14) <= 'H';

        -- to set HPI_EN Low(HPI disabled, McASP1 enabled) uncomment this line
--        T_HD(14) <= 'L';

        WAIT FOR 94 ns;
        IF T_HD(14) = 'H' THEN
            test <= boot_hpi;
            -- set way of booting: hpi, rom8, rom16 or rom32
            BOOT(hpi);
--            BOOT(rom8);
--            BOOT(rom16);
--            BOOT(rom32);

            test <= HPID_write;
            HPI(HPIA, HPIWrite0, 0, 0);
            WAIT FOR 100 ns;
            HPI(HPID, HPIWrite0, 16#0002#, 16#0005#);
            WAIT FOR 100 ns;
            HPI(HPIA, HPIWrite0, 0, 4);
            WAIT FOR 100 ns;
            HPI(HPID, HPIWrite0, 16#0102#, 16#0206#);
            WAIT FOR 100 ns;
            HPI(HPIC, HPIWrite0, 0, 0);
            WAIT FOR 100 ns;

            test <= HPID_read;
            HPI(HPIA, HPIWrite0, 0, 0);
            WAIT FOR 100 ns;
            HPI(HPID, HPIRead0, 0, 0, 16#0005#, 16#0002#);
            WAIT FOR 100 ns;
            HPI(HPIA, HPIWrite0, 4, 0);
            WAIT FOR 100 ns;
            HPI(HPID, HPIRead0, 0, 0, 16#0206#, 16#0102#);
            WAIT FOR 100 ns;
            HPI(HPIA, HPIRead0, 0, 0, 16#0004#, 16#0000#);
            WAIT FOR 100 ns;
            HPI(HPIC, HPIRead0, 0, 0, 8, 0);
            WAIT FOR 100 ns;

            test <= HPIDa_write;
            HPI(HPIA, HPIWrite0, 0, 0);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIWrite0, 16#0001#, 16#0007#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIWrite0, 16#0002#, 16#0005#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIWrite0, 16#0003#, 16#0003#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIWrite1, 16#0004#, 16#0001#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIWrite1, 16#0005#, 16#000F#);
            WAIT FOR 100 ns;

            test <= HPIDa_read;
            HPI(HPIA, HPIWrite0, 0, 0);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#0001#, 16#0007#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#0002#, 16#0005#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#0003#, 16#0003#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead1, 0, 0, 16#0004#, 16#0001#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead1, 0, 0, 16#0005#, 16#000F#);
            WAIT FOR 100 ns;

            test <= HPIDa_read;  -- read control registers
            HPI(HPIA, HPIWrite0, 0, 16#0180#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#3679#, 16#0000#);  -- global cntl
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#0030#, 16#0000#);  -- CE1
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#C803#, 16#80F8#);  -- CE0
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#C803#, 16#80F8#);  -- reserved
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#C813#, 16#80F8#);  -- CE2
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#C823#, 16#80F8#);  -- CE3
            WAIT FOR 100 ns;

            T_ARDY <= '1';
            T_ROM8 <= 'H';
            test <= HPI_write_thru;                    -- 8-bit asynch
            HPI(HPIA, HPIWrite0, 16#0000#, 16#8001#);  -- CE0
            WAIT FOR 200 ns;
            HPI(HPIDa, HPIWrite0, 16#1234#, 16#5678#);
            WAIT FOR 5 us;
            HPI(HPIDa, HPIWrite2, 16#FFFE#, 16#FDFC#);
            WAIT FOR 6 us;

            test <= HPI_read_thru;                     -- 8-bit asynch
            HPI(HPIA, HPIWrite0, 16#0000#, 16#8001#);  -- CE0
            WAIT FOR 200 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#1234#, 16#5678#);
            WAIT FOR 5 us;
            HPI(HPIDa, HPIRead2, 0, 0, 16#FFFE#, 16#FDFC#);
            WAIT FOR 6 us;

            test <= HPI_write_thru;                    -- 16-bit asynch
            HPI(HPIA, HPIWrite0, 16#0000#, 16#A001#);  -- CE2
            WAIT FOR 200 ns;
            HPI(HPIDa, HPIWrite2, 16#FFFE#, 16#FFFD#);
            WAIT FOR 2 us;

            T_ROM8 <= 'L';

            test <= HPI_read_thru;                     -- 16-bit asynch
            HPI(HPIA, HPIWrite0, 16#0000#, 16#A001#);  -- CE2
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#FFFE#, 16#FFFD#);
            WAIT FOR 100 ns;

            test <= HPI_sdram_write_thru;              -- 32-bit SDRAM
            HPI(HPIA, HPIWrite0, 16#0000#, 16#9000#);  -- CE1
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIWrite0, 16#5FF0#, 16#FFFF#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIWrite0, 16#5FF0#, 16#FFFE#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIWrite0, 16#5FF0#, 16#FFFD#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIWrite0, 16#5FF0#, 16#FFFC#);
            WAIT FOR 100 ns;

            test <= HPI_sdram_read_thru;               -- 32-bit SDRAM
            HPI(HPIA, HPIWrite0, 16#0000#, 16#9000#);  -- CE1
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#5FF0#, 16#FFFF#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#5FF0#, 16#FFFE#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#5FF0#, 16#FFFD#);
            WAIT FOR 100 ns;
            HPI(HPIDa, HPIRead0, 0, 0, 16#5FF0#, 16#FFFC#);
            WAIT FOR 100 ns;

            test <= CPU_start;

            WAIT FOR 2250 ns;
            FSenable <= true;

            WAIT FOR 6 ms;

            -- turn off clocks to stop simulation
            HPI(HPIA, HPIWrite0, 16#C124#, 16#01B7#); -- PLL
            WAIT FOR 100 ns;
            HPI(HPID, HPIWrite0, 16#0007#, 16#0000#); -- OD1V1EN
            WAIT FOR 100 ns;
            HPI(HPIA, HPIWrite0, 16#0000#, 16#0180#); -- GBLCTL
            WAIT FOR 100 ns;
            HPI(HPID, HPIWrite0, 16#3459#, 16#0000#); -- EKEN
            WAIT FOR 100 ns;

            T_CLKMODE0 <= 'L';
            CLK_EN := false;
            CLK_mode <= '1';
            test <= end_test;
            WAIT FOR 100 ns;
            ASSERT false
                REPORT " end test "
                SEVERITY note;
        ELSE
            T_HD(4) <= 'L';
            T_HD(3) <= 'L';
            WAIT FOR 200 ns;
            T_RESETNeg <= 'H';
            WAIT FOR 79700 ns;
            test <= CPU_start;
            WAIT FOR 5700 ns;
            T_AFSX1 <= '0';
            CLK_external <= '1';
            T_AFSX1 <= '0';
            WAIT FOR 1000 ns;
            WAIT UNTIL T_ACLKX1 = '1';
            T_AFSX1 <= '1';
            WAIT FOR 80 ns;
            T_AFSX1 <= '0';
            WAIT FOR 1200 ns;
            WAIT UNTIL T_ACLKX1 = '1';
            T_AFSX1 <= '1';
            WAIT FOR 80 ns;
            T_AFSX1 <= '0';
            WAIT FOR 1300 ns;
            WAIT UNTIL T_ACLKX1 = '1';
            T_AFSX1 <= '1';
            WAIT FOR 80 ns;
            T_AFSX1 <= '0';
            WAIT FOR 1400 ns;
            WAIT UNTIL T_ACLKX1 = '1';
            T_AFSX1 <= '1';
            WAIT FOR 80 ns;
            T_AFSX1 <= '0';
            WAIT FOR 1200 ns;
            T_AFSX1 <= 'Z';

            WAIT FOR 2200 us;

            T_CLKMODE0 <= 'L';
            CLK_EN := false;
            CLK_mode <= '1';
            test <= end_test;
            WAIT FOR 100 ns;
            ASSERT false
                REPORT " end test "
                SEVERITY note;
       END IF;

        WAIT;
    END PROCESS stim;

-- multiplexed pins, uncomment these lines if HPI_EN set Low
--T_AXR11 <= T_AXR01;
--T_AXR31 <= T_AXR21;

CLKX1EXT  : PROCESS
BEGIN
    IF CLK_external = '1' THEN
        T_ACLKX1 <= '1';
        WAIT FOR 40 ns;
        T_ACLKX1 <= '0';
        WAIT FOR 40 ns;
    ELSE
        T_ACLKX1  <= 'Z';
        WAIT;
    END IF;
END PROCESS;

CLKX1  : PROCESS
BEGIN
    IF CLK_mode = '0' THEN
        T_CLKS0 <= '1';
        WAIT FOR 30 ns;
        T_CLKS0 <= '0';
        WAIT FOR 30 ns;
    ELSE
        T_CLKS0  <= 'Z';
        WAIT;
    END IF;
END PROCESS;

CLKR0_PROC : PROCESS
BEGIN
    IF CLK_mode = '0' THEN
        T_CLKR0 <= '0';
        WAIT FOR  45 ns;
        T_CLKR0 <= '1';
        WAIT FOR  45 ns;
    ELSE
        T_CLKR0  <= 'Z';
        WAIT;
    END IF;
END PROCESS;

CLKX0_PROC : PROCESS
BEGIN
    IF CLK_mode = '0' THEN
        T_CLKX0  <= '0';
        WAIT FOR 45 ns;
        T_CLKX0  <= '1';
        IF CLK_block = '1' THEN
            T_CLKX0 <= '0';
        END IF;
        WAIT FOR 45 ns;
    ELSE
        T_CLKX0 <= 'Z';
        WAIT;
    END IF;
END PROCESS;

T_DR0 <= T_DX0;

FS_PROCESS : PROCESS
BEGIN

    T_FSR0 <= '0';
    T_FSX0 <= '0';

    WAIT UNTIL FSenable = true;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSX0 <= '1', '0' AFTER 90 ns;
    T_FSR0 <= '1', '0' AFTER 90 ns;

    WAIT FOR 1450 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 1500 ns;
    WAIT UNTIL T_CLKX0 ='1';
    WAIT FOR 5 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 1420 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 3940 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 4050 ns;
    WAIT UNTIL T_CLKX0 = '1'; --sending multiframe
    WAIT FOR 5 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 6860 ns;        --FOR RFIG i XFIG
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 1510 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 3435 ns;
    WAIT FOR 1965 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 1350 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 1260 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;               --  xempty on END
    T_FSR0 <= '1' , '0' AFTER 90 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 1260 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;             -- FOR RFULL avoided
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 1260 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 1260 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;                -- FOR RFULL
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 1260 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 2260 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 6650 ns; -- multichanel frame
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT FOR 35460 ns;
    WAIT UNTIL T_CLKX0 = '1';
    WAIT FOR 5 ns;
    T_FSX0 <= '1' , '0' AFTER 90 ns;
    T_FSR0 <= '1' , '0' AFTER 90 ns;

    WAIT;
END PROCESS;

END test_1;
