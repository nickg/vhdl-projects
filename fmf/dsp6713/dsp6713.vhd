--------------------------------------------------------------------------------
--  File Name: dsp6713.vhd
--------------------------------------------------------------------------------
-- Copyright (C) 2005 Free Model Foundry; http://www.FreeModelFoundry.com
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License version 2 as
--  published by the Free Software Foundation.
--
--  MODIFICATION HISTORY:
--
--  version: |  author:     | mod date: | changes made:
--    V0.1    M.Radmanovic   03 Sep 22    Inital release
--    V0.2    M.Radmanovic   03 Oct 02    Added EMIF
--    V0.4    M.Radmanovic   05 Dec 13    Added McASP1, fixed coding style
--------------------------------------------------------------------------------
--  PART DESCRIPTION:
--
--  Library:    PROC
--  Technology: CMOS
--  Part:       DSP6713
--
--  Description: Floating Point Digital Signal Processor
--------------------------------------------------------------------------------
LIBRARY IEEE;   USE IEEE.std_logic_1164.ALL;
                USE IEEE.VITAL_timing.ALL;
                USE IEEE.VITAL_primitives.ALL;
                USE STD.textio.ALL;

LIBRARY FMF;    USE FMF.gen_utils.ALL;
                USE FMF.conversions.ALL;

--------------------------------------------------------------------------------
-- ENTITY DECLARATION
--------------------------------------------------------------------------------
ENTITY dsp6713 IS
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
        command_file_name   : STRING    := "none";
        -- time to auto-start CPU
        cpu_autostart_time  : TIME      := 0 us;
        -- For FMF SDF technology file usage
        TimingModel         : STRING    := DefaultTimingModel
    );
    PORT (
        CLKIN           : IN    std_logic := 'H';
        CLKOUT2         : INOUT std_logic := 'L';
        CLKOUT3         : OUT   std_logic := 'L';
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
        ECLKOUT         : OUT   std_logic := 'L';
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
    ATTRIBUTE VITAL_LEVEL0 of dsp6713 : ENTITY IS TRUE;
END dsp6713;

--------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
--------------------------------------------------------------------------------
ARCHITECTURE vhdl_behavioral of dsp6713 IS
    ATTRIBUTE VITAL_LEVEL0 of vhdl_behavioral : ARCHITECTURE IS TRUE;

    CONSTANT PartID           : STRING := "dsp6713";

    SIGNAL CLKIN_ipd           : std_ulogic := 'U';
    SIGNAL CLKMODE0_ipd        : std_ulogic := 'U';
    SIGNAL CLKOUT2_ipd         : std_ulogic := 'U';
    SIGNAL TMS_ipd             : std_ulogic := 'U';
    SIGNAL TDI_ipd             : std_ulogic := 'U';
    SIGNAL TCK_ipd             : std_ulogic := 'U';
    SIGNAL TRSTNeg_ipd         : std_ulogic := 'U';
    SIGNAL EMU0_ipd            : std_ulogic := 'U';
    SIGNAL EMU1_ipd            : std_ulogic := 'U';
    SIGNAL EMU2_ipd            : std_ulogic := 'U';
    SIGNAL EMU3_ipd            : std_ulogic := 'U';
    SIGNAL EMU4_ipd            : std_ulogic := 'U';
    SIGNAL EMU5_ipd            : std_ulogic := 'U';
    SIGNAL RESETNeg_ipd        : std_ulogic := 'U';
    SIGNAL NMI_ipd             : std_ulogic := 'U';
    SIGNAL EXTINT4_ipd         : std_ulogic := 'U';
    SIGNAL EXTINT5_ipd         : std_ulogic := 'U';
    SIGNAL EXTINT6_ipd         : std_ulogic := 'U';
    SIGNAL EXTINT7_ipd         : std_ulogic := 'U';
    SIGNAL HINTNeg_ipd         : std_ulogic := 'U';
    SIGNAL HCNTL1_ipd          : std_ulogic := 'U';
    SIGNAL HCNTL0_ipd          : std_ulogic := 'U';
    SIGNAL HHWIL_ipd           : std_ulogic := 'U';
    SIGNAL HR_ipd              : std_ulogic := 'U';
    SIGNAL HD0_ipd             : std_ulogic := 'U';
    SIGNAL HD1_ipd             : std_ulogic := 'U';
    SIGNAL HD2_ipd             : std_ulogic := 'U';
    SIGNAL HD3_ipd             : std_ulogic := 'U';
    SIGNAL HD4_ipd             : std_ulogic := 'U';
    SIGNAL HD5_ipd             : std_ulogic := 'U';
    SIGNAL HD6_ipd             : std_ulogic := 'U';
    SIGNAL HD7_ipd             : std_ulogic := 'U';
    SIGNAL HD8_ipd             : std_ulogic := 'U';
    SIGNAL HD9_ipd             : std_ulogic := 'U';
    SIGNAL HD10_ipd            : std_ulogic := 'U';
    SIGNAL HD11_ipd            : std_ulogic := 'U';
    SIGNAL HD12_ipd            : std_ulogic := 'U';
    SIGNAL HD13_ipd            : std_ulogic := 'U';
    SIGNAL HD14_ipd            : std_ulogic := 'U';
    SIGNAL HD15_ipd            : std_ulogic := 'U';
    SIGNAL HASNeg_ipd          : std_ulogic := 'U';
    SIGNAL HCSNeg_ipd          : std_ulogic := 'U';
    SIGNAL HDS1Neg_ipd         : std_ulogic := 'U';
    SIGNAL HDS2Neg_ipd         : std_ulogic := 'U';
    SIGNAL HRDYNeg_ipd         : std_ulogic := 'U';
    SIGNAL HOLDNeg_ipd         : std_ulogic := 'U';
    SIGNAL ECLKIN_ipd          : std_ulogic := 'U';
    SIGNAL ARDY_ipd            : std_ulogic := 'U';
    SIGNAL ED0_ipd             : std_ulogic := 'U';
    SIGNAL ED1_ipd             : std_ulogic := 'U';
    SIGNAL ED2_ipd             : std_ulogic := 'U';
    SIGNAL ED3_ipd             : std_ulogic := 'U';
    SIGNAL ED4_ipd             : std_ulogic := 'U';
    SIGNAL ED5_ipd             : std_ulogic := 'U';
    SIGNAL ED6_ipd             : std_ulogic := 'U';
    SIGNAL ED7_ipd             : std_ulogic := 'U';
    SIGNAL ED8_ipd             : std_ulogic := 'U';
    SIGNAL ED9_ipd             : std_ulogic := 'U';
    SIGNAL ED10_ipd            : std_ulogic := 'U';
    SIGNAL ED11_ipd            : std_ulogic := 'U';
    SIGNAL ED12_ipd            : std_ulogic := 'U';
    SIGNAL ED13_ipd            : std_ulogic := 'U';
    SIGNAL ED14_ipd            : std_ulogic := 'U';
    SIGNAL ED15_ipd            : std_ulogic := 'U';
    SIGNAL ED16_ipd            : std_ulogic := 'U';
    SIGNAL ED17_ipd            : std_ulogic := 'U';
    SIGNAL ED18_ipd            : std_ulogic := 'U';
    SIGNAL ED19_ipd            : std_ulogic := 'U';
    SIGNAL ED20_ipd            : std_ulogic := 'U';
    SIGNAL ED21_ipd            : std_ulogic := 'U';
    SIGNAL ED22_ipd            : std_ulogic := 'U';
    SIGNAL ED23_ipd            : std_ulogic := 'U';
    SIGNAL ED24_ipd            : std_ulogic := 'U';
    SIGNAL ED25_ipd            : std_ulogic := 'U';
    SIGNAL ED26_ipd            : std_ulogic := 'U';
    SIGNAL ED27_ipd            : std_ulogic := 'U';
    SIGNAL ED28_ipd            : std_ulogic := 'U';
    SIGNAL ED29_ipd            : std_ulogic := 'U';
    SIGNAL ED30_ipd            : std_ulogic := 'U';
    SIGNAL ED31_ipd            : std_ulogic := 'U';
    SIGNAL TINP1_ipd           : std_ulogic := 'U';
    SIGNAL TOUT1_ipd           : std_ulogic := 'U';
    SIGNAL TINP0_ipd           : std_ulogic := 'U';
    SIGNAL TOUT0_ipd           : std_ulogic := 'U';
    SIGNAL CLKS1_ipd           : std_ulogic := 'U';
    SIGNAL CLKR1_ipd           : std_ulogic := 'U';
    SIGNAL CLKX1_ipd           : std_ulogic := 'U';
    SIGNAL DR1_ipd             : std_ulogic := 'U';
    SIGNAL DX1_ipd             : std_ulogic := 'U';
    SIGNAL FSR1_ipd            : std_ulogic := 'U';
    SIGNAL FSX1_ipd            : std_ulogic := 'U';
    SIGNAL CLKS0_ipd           : std_ulogic := 'U';
    SIGNAL CLKR0_ipd           : std_ulogic := 'U';
    SIGNAL CLKX0_ipd           : std_ulogic := 'U';
    SIGNAL DR0_ipd             : std_ulogic := 'U';
    SIGNAL DX0_ipd             : std_ulogic := 'U';
    SIGNAL FSR0_ipd            : std_ulogic := 'U';
    SIGNAL FSX0_ipd            : std_ulogic := 'U';
    SIGNAL SCL0_ipd            : std_ulogic := 'U';
    SIGNAL SDA0_ipd            : std_ulogic := 'U';

    SIGNAL CLKIN_nwv           : UX01 := 'U';
    SIGNAL CLKMODE0_nwv        : UX01 := 'U';
    SIGNAL CLKOUT2_nwv         : UX01 := 'U';
    SIGNAL TMS_nwv             : UX01 := 'U';
    SIGNAL TDI_nwv             : UX01 := 'U';
    SIGNAL TCK_nwv             : UX01 := 'U';
    SIGNAL TRSTNeg_nwv         : UX01 := 'U';
    SIGNAL EMU0_nwv            : UX01 := 'U';
    SIGNAL EMU1_nwv            : UX01 := 'U';
    SIGNAL EMU2_nwv            : UX01 := 'U';
    SIGNAL EMU3_nwv            : UX01 := 'U';
    SIGNAL EMU4_nwv            : UX01 := 'U';
    SIGNAL EMU5_nwv            : UX01 := 'U';
    SIGNAL RESETNeg_nwv        : UX01 := 'U';
    SIGNAL NMI_nwv             : UX01 := 'U';
    SIGNAL EXTINT4_nwv         : UX01 := 'U';
    SIGNAL EXTINT5_nwv         : UX01 := 'U';
    SIGNAL EXTINT6_nwv         : UX01 := 'U';
    SIGNAL EXTINT7_nwv         : UX01 := 'U';
    SIGNAL HINTNeg_nwv         : UX01 := 'U';
    SIGNAL HCNTL1_nwv          : UX01 := 'U';
    SIGNAL HCNTL0_nwv          : UX01 := 'U';
    SIGNAL HHWIL_nwv           : UX01 := 'U';
    SIGNAL HR_nwv              : UX01 := 'U';
    SIGNAL HD0_nwv             : UX01 := 'U';
    SIGNAL HD1_nwv             : UX01 := 'U';
    SIGNAL HD2_nwv             : UX01 := 'U';
    SIGNAL HD3_nwv             : UX01 := 'U';
    SIGNAL HD4_nwv             : UX01 := 'U';
    SIGNAL HD5_nwv             : UX01 := 'U';
    SIGNAL HD6_nwv             : UX01 := 'U';
    SIGNAL HD7_nwv             : UX01 := 'U';
    SIGNAL HD8_nwv             : UX01 := 'U';
    SIGNAL HD9_nwv             : UX01 := 'U';
    SIGNAL HD10_nwv            : UX01 := 'U';
    SIGNAL HD11_nwv            : UX01 := 'U';
    SIGNAL HD12_nwv            : UX01 := 'U';
    SIGNAL HD13_nwv            : UX01 := 'U';
    SIGNAL HD14_nwv            : UX01 := 'U';
    SIGNAL HD15_nwv            : UX01 := 'U';
    SIGNAL HASNeg_nwv          : UX01 := 'U';
    SIGNAL HCSNeg_nwv          : UX01 := 'U';
    SIGNAL HDS1Neg_nwv         : UX01 := 'U';
    SIGNAL HDS2Neg_nwv         : UX01 := 'U';
    SIGNAL HRDYNeg_nwv         : UX01 := 'U';
    SIGNAL HOLDNeg_nwv         : UX01 := 'U';
    SIGNAL ECLKIN_nwv          : UX01 := 'U';
    SIGNAL ARDY_nwv            : UX01 := 'U';
    SIGNAL ED0_nwv             : UX01 := 'U';
    SIGNAL ED1_nwv             : UX01 := 'U';
    SIGNAL ED2_nwv             : UX01 := 'U';
    SIGNAL ED3_nwv             : UX01 := 'U';
    SIGNAL ED4_nwv             : UX01 := 'U';
    SIGNAL ED5_nwv             : UX01 := 'U';
    SIGNAL ED6_nwv             : UX01 := 'U';
    SIGNAL ED7_nwv             : UX01 := 'U';
    SIGNAL ED8_nwv             : UX01 := 'U';
    SIGNAL ED9_nwv             : UX01 := 'U';
    SIGNAL ED10_nwv            : UX01 := 'U';
    SIGNAL ED11_nwv            : UX01 := 'U';
    SIGNAL ED12_nwv            : UX01 := 'U';
    SIGNAL ED13_nwv            : UX01 := 'U';
    SIGNAL ED14_nwv            : UX01 := 'U';
    SIGNAL ED15_nwv            : UX01 := 'U';
    SIGNAL ED16_nwv            : UX01 := 'U';
    SIGNAL ED17_nwv            : UX01 := 'U';
    SIGNAL ED18_nwv            : UX01 := 'U';
    SIGNAL ED19_nwv            : UX01 := 'U';
    SIGNAL ED20_nwv            : UX01 := 'U';
    SIGNAL ED21_nwv            : UX01 := 'U';
    SIGNAL ED22_nwv            : UX01 := 'U';
    SIGNAL ED23_nwv            : UX01 := 'U';
    SIGNAL ED24_nwv            : UX01 := 'U';
    SIGNAL ED25_nwv            : UX01 := 'U';
    SIGNAL ED26_nwv            : UX01 := 'U';
    SIGNAL ED27_nwv            : UX01 := 'U';
    SIGNAL ED28_nwv            : UX01 := 'U';
    SIGNAL ED29_nwv            : UX01 := 'U';
    SIGNAL ED30_nwv            : UX01 := 'U';
    SIGNAL ED31_nwv            : UX01 := 'U';
    SIGNAL TINP1_nwv           : UX01 := 'U';
    SIGNAL TOUT1_nwv           : UX01 := 'U';
    SIGNAL TINP0_nwv           : UX01 := 'U';
    SIGNAL TOUT0_nwv           : UX01 := 'U';
    SIGNAL CLKS1_nwv           : UX01 := 'U';
    SIGNAL CLKR1_nwv           : UX01 := 'U';
    SIGNAL CLKX1_nwv           : UX01 := 'U';
    SIGNAL DR1_nwv             : UX01 := 'U';
    SIGNAL DX1_nwv             : UX01 := 'U';
    SIGNAL FSR1_nwv            : UX01 := 'U';
    SIGNAL FSX1_nwv            : UX01 := 'U';
    SIGNAL CLKS0_nwv           : UX01 := 'U';
    SIGNAL CLKR0_nwv           : UX01 := 'U';
    SIGNAL CLKX0_nwv           : UX01 := 'U';
    SIGNAL DR0_nwv             : UX01 := 'U';
    SIGNAL DX0_nwv             : UX01 := 'U';
    SIGNAL FSR0_nwv            : UX01 := 'U';
    SIGNAL FSX0_nwv            : UX01 := 'U';
    SIGNAL SCL0_nwv            : UX01 := 'U';
    SIGNAL SDA0_nwv            : UX01 := 'U';

BEGIN

    ----------------------------------------------------------------------------
    -- Wire Delays
    ----------------------------------------------------------------------------
    WireDelay : BLOCK
    BEGIN

        w_1 : VitalWireDelay (CLKIN_ipd, CLKIN, tipd_CLKIN);
        w_2 : VitalWireDelay (CLKOUT2_ipd, CLKOUT2, tipd_CLKOUT2);
        w_4 : VitalWireDelay (CLKMODE0_ipd, CLKMODE0, tipd_CLKMODE0);
        w_8 : VitalWireDelay (TMS_ipd, TMS, tipd_TMS);
        w_10 : VitalWireDelay (TDI_ipd, TDI, tipd_TDI);
        w_11 : VitalWireDelay (TCK_ipd, TCK, tipd_TCK);
        w_12 : VitalWireDelay (TRSTNeg_ipd, TRSTNeg, tipd_TRSTNeg);
        w_13 : VitalWireDelay (EMU0_ipd, EMU0, tipd_EMU0);
        w_14 : VitalWireDelay (EMU1_ipd, EMU1, tipd_EMU1);
        w_15 : VitalWireDelay (EMU2_ipd, EMU2, tipd_EMU2);
        w_16 : VitalWireDelay (EMU3_ipd, EMU3, tipd_EMU3);
        w_17 : VitalWireDelay (EMU4_ipd, EMU4, tipd_EMU4);
        w_18 : VitalWireDelay (EMU5_ipd, EMU5, tipd_EMU5);
        w_19 : VitalWireDelay (RESETNeg_ipd, RESETNeg, tipd_RESETNeg);
        w_20 : VitalWireDelay (NMI_ipd, NMI, tipd_NMI);
        w_21 : VitalWireDelay (EXTINT4_ipd, EXTINT4, tipd_EXTINT4);
        w_22 : VitalWireDelay (EXTINT5_ipd, EXTINT5, tipd_EXTINT5);
        w_23 : VitalWireDelay (EXTINT6_ipd, EXTINT6, tipd_EXTINT6);
        w_24 : VitalWireDelay (EXTINT7_ipd, EXTINT7, tipd_EXTINT7);
        w_25 : VitalWireDelay (HINTNeg_ipd,HINTNeg,tipd_HINTNeg);
        w_26 : VitalWireDelay (HCNTL1_ipd, HCNTL1, tipd_HCNTL1);
        w_27 : VitalWireDelay (HCNTL0_ipd, HCNTL0, tipd_HCNTL0);
        w_28 : VitalWireDelay (HHWIL_ipd, HHWIL, tipd_HHWIL);
        w_29 : VitalWireDelay (HR_ipd, HR, tipd_HR);
        w_30 : VitalWireDelay (HD0_ipd, HD0, tipd_HD0);
        w_31 : VitalWireDelay (HD1_ipd, HD1, tipd_HD1);
        w_32 : VitalWireDelay (HD2_ipd, HD2, tipd_HD2);
        w_33 : VitalWireDelay (HD3_ipd, HD3, tipd_HD3);
        w_34 : VitalWireDelay (HD4_ipd, HD4, tipd_HD4);
        w_35 : VitalWireDelay (HD5_ipd, HD5, tipd_HD5);
        w_36 : VitalWireDelay (HD6_ipd, HD6, tipd_HD6);
        w_37 : VitalWireDelay (HD7_ipd, HD7, tipd_HD7);
        w_38 : VitalWireDelay (HD8_ipd, HD8, tipd_HD8);
        w_39 : VitalWireDelay (HD9_ipd, HD9, tipd_HD9);
        w_40 : VitalWireDelay (HD10_ipd, HD10, tipd_HD10);
        w_41 : VitalWireDelay (HD11_ipd, HD11, tipd_HD11);
        w_42 : VitalWireDelay (HD12_ipd, HD12, tipd_HD12);
        w_43 : VitalWireDelay (HD13_ipd, HD13, tipd_HD13);
        w_44 : VitalWireDelay (HD14_ipd, HD14, tipd_HD14);
        w_45 : VitalWireDelay (HD15_ipd, HD15, tipd_HD15);
        w_46 : VitalWireDelay (HASNeg_ipd, HASNeg, tipd_HASNeg);
        w_47 : VitalWireDelay (HCSNeg_ipd, HCSNeg, tipd_HCSNeg);
        w_48 : VitalWireDelay (HDS1Neg_ipd, HDS1Neg, tipd_HDS1Neg);
        w_49 : VitalWireDelay (HDS2Neg_ipd, HDS2Neg, tipd_HDS2Neg);
        w_50 : VitalWireDelay (HRDYNeg_ipd,HRDYNeg,tipd_HRDYNeg);
        w_60 : VitalWireDelay (HOLDNeg_ipd, HOLDNeg, tipd_HOLDNeg);
        w_62 : VitalWireDelay (ECLKIN_ipd, ECLKIN, tipd_ECLKIN);
        w_67 : VitalWireDelay (ARDY_ipd, ARDY, tipd_ARDY);
        w_88 : VitalWireDelay (ED0_ipd, ED0, tipd_ED0);
        w_89 : VitalWireDelay (ED1_ipd, ED1, tipd_ED1);
        w_90 : VitalWireDelay (ED2_ipd, ED2, tipd_ED2);
        w_91 : VitalWireDelay (ED3_ipd, ED3, tipd_ED3);
        w_92 : VitalWireDelay (ED4_ipd, ED4, tipd_ED4);
        w_93 : VitalWireDelay (ED5_ipd, ED5, tipd_ED5);
        w_94 : VitalWireDelay (ED6_ipd, ED6, tipd_ED6);
        w_95 : VitalWireDelay (ED7_ipd, ED7, tipd_ED7);
        w_96 : VitalWireDelay (ED8_ipd, ED8, tipd_ED8);
        w_97 : VitalWireDelay (ED9_ipd, ED9, tipd_ED9);
        w_98 : VitalWireDelay (ED10_ipd, ED10, tipd_ED10);
        w_99 : VitalWireDelay (ED11_ipd, ED11, tipd_ED11);
        w_100 : VitalWireDelay (ED12_ipd, ED12, tipd_ED12);
        w_101 : VitalWireDelay (ED13_ipd, ED13, tipd_ED13);
        w_102 : VitalWireDelay (ED14_ipd, ED14, tipd_ED14);
        w_103 : VitalWireDelay (ED15_ipd, ED15, tipd_ED15);
        w_104 : VitalWireDelay (ED16_ipd, ED16, tipd_ED16);
        w_105 : VitalWireDelay (ED17_ipd, ED17, tipd_ED17);
        w_106 : VitalWireDelay (ED18_ipd, ED18, tipd_ED18);
        w_107 : VitalWireDelay (ED19_ipd, ED19, tipd_ED19);
        w_108 : VitalWireDelay (ED20_ipd, ED20, tipd_ED20);
        w_109 : VitalWireDelay (ED21_ipd, ED21, tipd_ED21);
        w_110 : VitalWireDelay (ED22_ipd, ED22, tipd_ED22);
        w_111 : VitalWireDelay (ED23_ipd, ED23, tipd_ED23);
        w_112 : VitalWireDelay (ED24_ipd, ED24, tipd_ED24);
        w_113 : VitalWireDelay (ED25_ipd, ED25, tipd_ED25);
        w_114 : VitalWireDelay (ED26_ipd, ED26, tipd_ED26);
        w_115 : VitalWireDelay (ED27_ipd, ED27, tipd_ED27);
        w_116 : VitalWireDelay (ED28_ipd, ED28, tipd_ED28);
        w_117 : VitalWireDelay (ED29_ipd, ED29, tipd_ED29);
        w_118 : VitalWireDelay (ED30_ipd, ED30, tipd_ED30);
        w_119 : VitalWireDelay (ED31_ipd, ED31, tipd_ED31);
        w_121 : VitalWireDelay (TINP1_ipd, TINP1, tipd_TINP1);
        w_122 : VitalWireDelay (TOUT1_ipd, TOUT1, tipd_TOUT1);
        w_123 : VitalWireDelay (TINP0_ipd, TINP0, tipd_TINP0);
        w_124 : VitalWireDelay (TOUT0_ipd, TOUT0, tipd_TOUT0);
        w_125 : VitalWireDelay (CLKS1_ipd, CLKS1, tipd_CLKS1);
        w_126 : VitalWireDelay (CLKR1_ipd, CLKR1, tipd_CLKR1);
        w_127 : VitalWireDelay (CLKX1_ipd, CLKX1, tipd_CLKX1);
        w_128 : VitalWireDelay (DR1_ipd, DR1, tipd_DR1);
        w_129 : VitalWireDelay (DX1_ipd, DX1, tipd_DX1);
        w_130 : VitalWireDelay (FSR1_ipd, FSR1, tipd_FSR1);
        w_131 : VitalWireDelay (FSX1_ipd, FSX1, tipd_FSX1);
        w_132 : VitalWireDelay (CLKS0_ipd, CLKS0, tipd_CLKS0);
        w_133 : VitalWireDelay (CLKR0_ipd, CLKR0, tipd_CLKR0);
        w_134 : VitalWireDelay (CLKX0_ipd, CLKX0, tipd_CLKX0);
        w_135 : VitalWireDelay (DR0_ipd, DR0, tipd_DR0);
        w_136 : VitalWireDelay (DX0_ipd, DX0, tipd_DX0);
        w_137 : VitalWireDelay (FSR0_ipd, FSR0, tipd_FSR0);
        w_138 : VitalWireDelay (FSX0_ipd, FSX0, tipd_FSX0);
        w_139 : VitalWireDelay (SCL0_ipd, SCL0, tipd_SCL0);
        w_140 : VitalWireDelay (SDA0_ipd, SDA0, tipd_SDA0);

    END BLOCK;

    CLKIN_nwv           <= To_UX01(CLKIN_ipd);
    CLKOUT2_nwv         <= To_UX01(CLKOUT2_ipd);
    CLKMODE0_nwv        <= To_UX01(CLKMODE0_ipd);
    TMS_nwv             <= To_UX01(TMS_ipd);
    TDI_nwv             <= To_UX01(TDI_ipd);
    TCK_nwv             <= To_UX01(TCK_ipd);
    TRSTNeg_nwv         <= To_UX01(TRSTNeg_ipd);
    EMU0_nwv            <= To_UX01(EMU0_ipd);
    EMU1_nwv            <= To_UX01(EMU1_ipd);
    EMU2_nwv            <= To_UX01(EMU2_ipd);
    EMU3_nwv            <= To_UX01(EMU3_ipd);
    EMU4_nwv            <= To_UX01(EMU4_ipd);
    EMU5_nwv            <= To_UX01(EMU5_ipd);
    RESETNeg_nwv        <= To_UX01(RESETNeg_ipd);
    NMI_nwv             <= To_UX01(NMI_ipd);
    EXTINT4_nwv         <= To_UX01(EXTINT4_ipd);
    EXTINT5_nwv         <= To_UX01(EXTINT5_ipd);
    EXTINT6_nwv         <= To_UX01(EXTINT6_ipd);
    EXTINT7_nwv         <= To_UX01(EXTINT7_ipd);
    HINTNeg_nwv         <= To_UX01(HINTNeg_ipd);
    HCNTL1_nwv          <= To_UX01(HCNTL1_ipd);
    HCNTL0_nwv          <= To_UX01(HCNTL0_ipd);
    HHWIL_nwv           <= To_UX01(HHWIL_ipd);
    HR_nwv              <= To_UX01(HR_ipd);
    HD0_nwv             <= To_UX01(HD0_ipd);
    HD1_nwv             <= To_UX01(HD1_ipd);
    HD2_nwv             <= To_UX01(HD2_ipd);
    HD3_nwv             <= To_UX01(HD3_ipd);
    HD4_nwv             <= To_UX01(HD4_ipd);
    HD5_nwv             <= To_UX01(HD5_ipd);
    HD6_nwv             <= To_UX01(HD6_ipd);
    HD7_nwv             <= To_UX01(HD7_ipd);
    HD8_nwv             <= To_UX01(HD8_ipd);
    HD9_nwv             <= To_UX01(HD9_ipd);
    HD10_nwv            <= To_UX01(HD10_ipd);
    HD11_nwv            <= To_UX01(HD11_ipd);
    HD12_nwv            <= To_UX01(HD12_ipd);
    HD13_nwv            <= To_UX01(HD13_ipd);
    HD14_nwv            <= To_UX01(HD14_ipd);
    HD15_nwv            <= To_UX01(HD15_ipd);
    HASNeg_nwv          <= To_UX01(HASNeg_ipd);
    HCSNeg_nwv          <= To_UX01(HCSNeg_ipd);
    HDS1Neg_nwv         <= To_UX01(HDS1Neg_ipd);
    HDS2Neg_nwv         <= To_UX01(HDS2Neg_ipd);
    HRDYNeg_nwv         <= To_UX01(HRDYNeg_ipd);
    HOLDNeg_nwv         <= To_UX01(HOLDNeg_ipd);
    ECLKIN_nwv          <= To_UX01(ECLKIN_ipd);
    ARDY_nwv            <= To_UX01(ARDY_ipd);
    ED0_nwv             <= To_UX01(ED0_ipd);
    ED1_nwv             <= To_UX01(ED1_ipd);
    ED2_nwv             <= To_UX01(ED2_ipd);
    ED3_nwv             <= To_UX01(ED3_ipd);
    ED4_nwv             <= To_UX01(ED4_ipd);
    ED5_nwv             <= To_UX01(ED5_ipd);
    ED6_nwv             <= To_UX01(ED6_ipd);
    ED7_nwv             <= To_UX01(ED7_ipd);
    ED8_nwv             <= To_UX01(ED8_ipd);
    ED9_nwv             <= To_UX01(ED9_ipd);
    ED10_nwv            <= To_UX01(ED10_ipd);
    ED11_nwv            <= To_UX01(ED11_ipd);
    ED12_nwv            <= To_UX01(ED12_ipd);
    ED13_nwv            <= To_UX01(ED13_ipd);
    ED14_nwv            <= To_UX01(ED14_ipd);
    ED15_nwv            <= To_UX01(ED15_ipd);
    ED16_nwv            <= To_UX01(ED16_ipd);
    ED17_nwv            <= To_UX01(ED17_ipd);
    ED18_nwv            <= To_UX01(ED18_ipd);
    ED19_nwv            <= To_UX01(ED19_ipd);
    ED20_nwv            <= To_UX01(ED20_ipd);
    ED21_nwv            <= To_UX01(ED21_ipd);
    ED22_nwv            <= To_UX01(ED22_ipd);
    ED23_nwv            <= To_UX01(ED23_ipd);
    ED24_nwv            <= To_UX01(ED24_ipd);
    ED25_nwv            <= To_UX01(ED25_ipd);
    ED26_nwv            <= To_UX01(ED26_ipd);
    ED27_nwv            <= To_UX01(ED27_ipd);
    ED28_nwv            <= To_UX01(ED28_ipd);
    ED29_nwv            <= To_UX01(ED29_ipd);
    ED30_nwv            <= To_UX01(ED30_ipd);
    ED31_nwv            <= To_UX01(ED31_ipd);
    TINP1_nwv           <= To_UX01(TINP1_ipd);
    TOUT1_nwv           <= To_UX01(TOUT1_ipd);
    TINP0_nwv           <= To_UX01(TINP0_ipd);
    TOUT0_nwv           <= To_UX01(TOUT0_ipd);
    CLKS1_nwv           <= To_UX01(CLKS1_ipd);
    CLKR1_nwv           <= To_UX01(CLKR1_ipd);
    CLKX1_nwv           <= To_UX01(CLKX1_ipd);
    DR1_nwv             <= To_UX01(DR1_ipd);
    DX1_nwv             <= To_UX01(DX1_ipd);
    FSR1_nwv            <= To_UX01(FSR1_ipd);
    FSX1_nwv            <= To_UX01(FSX1_ipd);
    CLKS0_nwv           <= To_UX01(CLKS0_ipd);
    CLKR0_nwv           <= To_UX01(CLKR0_ipd);
    CLKX0_nwv           <= To_UX01(CLKX0_ipd);
    DR0_nwv             <= To_UX01(DR0_ipd);
    DX0_nwv             <= To_UX01(DX0_ipd);
    FSR0_nwv            <= To_UX01(FSR0_ipd);
    FSX0_nwv            <= To_UX01(FSX0_ipd);
    SCL0_nwv            <= To_UX01(SCL0_ipd);
    SDA0_nwv            <= To_UX01(SDA0_ipd);

    ----------------------------------------------------------------------------
    -- Main Behavior Block
    ----------------------------------------------------------------------------
    Behavior: BLOCK

        PORT (
            CLKIN          : IN    std_ulogic := 'H';
            CLKOUT2In      : IN    std_logic  := 'Z';
            CLKOUT2Out     : OUT   std_logic  := '0';
            CLKOUT3        : OUT   std_logic  := '0';
            CLKMODE0       : IN    std_ulogic := 'H';
            RESETNeg       : IN    std_ulogic := 'H';
            NMI            : IN    std_ulogic := '0';
            EXTINT4        : IN    std_ulogic := 'H';
            EXTINT5        : IN    std_ulogic := 'H';
            EXTINT6        : IN    std_ulogic := 'H';
            EXTINT7        : IN    std_ulogic := 'H';
            EXTINT4Out     : OUT   std_ulogic := 'Z';
            EXTINT5Out     : OUT   std_ulogic := 'Z';
            EXTINT6Out     : OUT   std_ulogic := 'Z';
            EXTINT7Out     : OUT   std_ulogic := 'Z';
            HINTNeg        : OUT   std_logic  := 'H';
            HINTNegIn      : IN    std_ulogic := 'H';
            HCNTL          : IN    std_logic_vector(1 downto 0)
                                                    := (others => 'H');
            HCNTLOut       : OUT   std_logic_vector(1 downto 0)
                                                    := (others => 'Z');
            HHWIL          : IN    std_ulogic := 'U';
            HHWILOut       : OUT   std_ulogic := 'Z';
            HR             : IN    std_ulogic := 'U';
            HROut          : OUT   std_ulogic := 'Z';
            HASNeg         : IN    std_ulogic := 'U';
            HASNegOut      : OUT   std_ulogic := 'Z';
            HCSNeg         : IN    std_ulogic := 'U';
            HCSNegOut      : OUT   std_ulogic := 'Z';
            HDS1Neg        : IN    std_ulogic := 'U';
            HDS1NegOut     : OUT   std_ulogic := 'Z';
            HDS2Neg        : IN    std_ulogic := 'U';
            HDS2NegOut     : OUT   std_ulogic := 'Z';
            HRDYNeg        : OUT   std_ulogic := 'Z';
            HRDYNegIn      : IN    std_ulogic := 'U';
            HDOut          : OUT   std_logic_vector(15 downto 0)
                                                     := (others => 'Z');
            HDIn           : IN    std_logic_vector(15 downto 0)
                                                     := (others => 'U');
            CE3Neg         : OUT   std_ulogic := 'H';
            CE2Neg         : OUT   std_ulogic := 'H';
            CE1Neg         : OUT   std_ulogic := 'H';
            CE0Neg         : OUT   std_ulogic := 'H';
            BE3Neg         : OUT   std_ulogic := 'H';
            BE2Neg         : OUT   std_ulogic := 'H';
            BE1Neg         : OUT   std_ulogic := 'H';
            BE0Neg         : OUT   std_ulogic := 'H';
            HOLDANeg       : OUT   std_ulogic := 'H';
            HOLDNeg        : IN    std_ulogic := 'H';
            BUSREQ         : OUT   std_ulogic := 'H';
            ECLKIN         : IN    std_ulogic := '0';
            ECLKOUT        : OUT   std_ulogic := '0';
            SDCASNeg       : OUT   std_ulogic := '0';
            SDRASNeg       : OUT   std_ulogic := '0';
            SDWENeg        : OUT   std_ulogic := '0';
            ARDY           : IN    std_ulogic := 'H';
            EA             : OUT   std_logic_vector(21 downto 2)
                                                     := (others => 'H');
            EDOut          : OUT   std_logic_vector(31 downto 0)
                                                     := (others => 'H');
            EDIn           : IN    std_logic_vector(31 downto 0)
                                                     := (others => 'H');
            TOUT1Out       : OUT   std_ulogic := '0';
            TOUT1In        : IN    std_ulogic := 'H';
            TOUT0Out       : OUT   std_ulogic := '0';
            TOUT0In        : IN    std_ulogic := 'H';
            TINP1In        : IN    std_ulogic := '0';
            TINP1Out       : OUT   std_ulogic := '0';
            TINP0Out       : OUT   std_ulogic := '0';
            TINP0In        : IN    std_ulogic := '0';
            CLKS1In        : IN    std_ulogic := '0';
            CLKS1Out       : OUT   std_ulogic := '0';
            CLKS0In        : IN    std_ulogic := '0';
            CLKS0Out       : OUT   std_ulogic := 'Z';
            CLKR1In        : IN    std_ulogic := '0';
            CLKR1Out       : OUT   std_ulogic := '0';
            CLKX1In        : IN    std_ulogic := '0';
            CLKX1Out       : OUT   std_ulogic := '0';
            CLKR0In        : IN    std_ulogic := '0';
            CLKR0Out       : OUT   std_ulogic := '0';
            CLKX0In        : IN    std_ulogic := '0';
            CLKX0Out       : OUT   std_ulogic := '0';
            DR1In          : IN    std_ulogic := 'H';
            DR1Out         : OUT   std_ulogic := 'H';
            DX1In          : IN    std_ulogic := 'H';
            DX1Out         : OUT   std_ulogic := 'H';
            DR0In          : IN    std_ulogic := 'H';
            DR0Out         : OUT   std_ulogic := 'H';
            DX0In          : IN    std_ulogic := 'H';
            DX0Out         : OUT   std_ulogic := 'H';
            FSR1In         : IN    std_ulogic := '0';
            FSR1Out        : OUT   std_ulogic := '0';
            FSX1In         : IN    std_ulogic := '0';
            FSX1Out        : OUT   std_ulogic := '0';
            FSR0In         : IN    std_ulogic := '0';
            FSR0Out        : OUT   std_ulogic := '0';
            FSX0In         : IN    std_ulogic := '0';
            FSX0Out        : OUT   std_ulogic := '0';
            SCL0In         : IN    std_ulogic := '0';
            SCL0Out        : OUT   std_ulogic := '0';
            SDA0In         : IN    std_ulogic := '0';
            SDA0Out        : OUT   std_ulogic := '0'
        );
        PORT MAP (
            CLKIN => CLKIN_nwv,
            CLKOUT2In => CLKOUT2_nwv,
            CLKOUT2Out => CLKOUT2,
            CLKOUT3 => CLKOUT3,
            CLKMODE0 => CLKMODE0_nwv,
            RESETNeg => RESETNeg_nwv,
            NMI => NMI_nwv,
            EXTINT4 => EXTINT4_nwv,
            EXTINT5 => EXTINT5_nwv,
            EXTINT6 => EXTINT6_nwv,
            EXTINT7 => EXTINT7_nwv,
            EXTINT4Out => EXTINT4,
            EXTINT5Out => EXTINT5,
            EXTINT6Out => EXTINT6,
            EXTINT7Out => EXTINT7,
            HINTNeg => HINTNeg,
            HINTNegIn => HINTNeg_nwv,
            HCNTL(1) => HCNTL1_nwv,
            HCNTL(0) => HCNTL0_nwv,
            HCNTLOut(1) => HCNTL1,
            HCNTLOut(0) => HCNTL0,
            HHWIL => HHWIL_nwv,
            HHWILOut => HHWIL,
            HR => HR_nwv,
            HROut => HR,
            HASNeg => HASNeg_nwv,
            HASNegOut => HASNeg,
            HCSNeg => HCSNeg_nwv,
            HCSNegOut => HCSNeg,
            HDS1Neg => HDS1Neg_nwv,
            HDS1NegOut => HDS1Neg,
            HDS2Neg => HDS2Neg_nwv,
            HDS2NegOut => HDS2Neg,
            HRDYNeg => HRDYNeg,
            HRDYNegIn => HRDYNeg_nwv,
            HDOut(15) => HD15,
            HDOut(14) => HD14,
            HDOut(13) => HD13,
            HDOut(12) => HD12,
            HDOut(11) => HD11,
            HDOut(10) => HD10,
            HDOut(9) => HD9,
            HDOut(8) => HD8,
            HDOut(7) => HD7,
            HDOut(6) => HD6,
            HDOut(5) => HD5,
            HDOut(4) => HD4,
            HDOut(3) => HD3,
            HDOut(2) => HD2,
            HDOut(1) => HD1,
            HDOut(0) => HD0,
            HDIn(15) => HD15_nwv,
            HDIn(14) => HD14_nwv,
            HDIn(13) => HD13_nwv,
            HDIn(12) => HD12_nwv,
            HDIn(11) => HD11_nwv,
            HDIn(10) => HD10_nwv,
            HDIn(9) => HD9_nwv,
            HDIn(8) => HD8_nwv,
            HDIn(7) => HD7_nwv,
            HDIn(6) => HD6_nwv,
            HDIn(5) => HD5_nwv,
            HDIn(4) => HD4_nwv,
            HDIn(3) => HD3_nwv,
            HDIn(2) => HD2_nwv,
            HDIn(1) => HD1_nwv,
            HDIn(0) => HD0_nwv,
            CE3Neg => CE3Neg,
            CE2Neg => CE2Neg,
            CE1Neg => CE1Neg,
            CE0Neg => CE0Neg,
            BE3Neg => BE3Neg,
            BE2Neg => BE2Neg,
            BE1Neg => BE1Neg,
            BE0Neg => BE0Neg,
            HOLDANeg => HOLDANeg,
            HOLDNeg => HOLDNeg_nwv,
            BUSREQ => BUSREQ,
            ECLKIN => ECLKIN_nwv,
            ECLKOUT => ECLKOUT,
            SDCASNeg => SDCASNeg,
            SDRASNeg => SDRASNeg,
            SDWENeg => SDWENeg,
            ARDY => ARDY_nwv,
            EA(21) => EA21,
            EA(20) => EA20,
            EA(19) => EA19,
            EA(18) => EA18,
            EA(17) => EA17,
            EA(16) => EA16,
            EA(15) => EA15,
            EA(14) => EA14,
            EA(13) => EA13,
            EA(12) => EA12,
            EA(11) => EA11,
            EA(10) => EA10,
            EA(9) => EA9,
            EA(8) => EA8,
            EA(7) => EA7,
            EA(6) => EA6,
            EA(5) => EA5,
            EA(4) => EA4,
            EA(3) => EA3,
            EA(2) => EA2,
            EDOut(31) => ED31,
            EDOut(30) => ED30,
            EDOut(29) => ED29,
            EDOut(28) => ED28,
            EDOut(27) => ED27,
            EDOut(26) => ED26,
            EDOut(25) => ED25,
            EDOut(24) => ED24,
            EDOut(23) => ED23,
            EDOut(22) => ED22,
            EDOut(21) => ED21,
            EDOut(20) => ED20,
            EDOut(19) => ED19,
            EDOut(18) => ED18,
            EDOut(17) => ED17,
            EDOut(16) => ED16,
            EDOut(15) => ED15,
            EDOut(14) => ED14,
            EDOut(13) => ED13,
            EDOut(12) => ED12,
            EDOut(11) => ED11,
            EDOut(10) => ED10,
            EDOut(9) => ED9,
            EDOut(8) => ED8,
            EDOut(7) => ED7,
            EDOut(6) => ED6,
            EDOut(5) => ED5,
            EDOut(4) => ED4,
            EDOut(3) => ED3,
            EDOut(2) => ED2,
            EDOut(1) => ED1,
            EDOut(0) => ED0,
            EDIn(31) => ED31_nwv,
            EDIn(30) => ED30_nwv,
            EDIn(29) => ED29_nwv,
            EDIn(28) => ED28_nwv,
            EDIn(27) => ED27_nwv,
            EDIn(26) => ED26_nwv,
            EDIn(25) => ED25_nwv,
            EDIn(24) => ED24_nwv,
            EDIn(23) => ED23_nwv,
            EDIn(22) => ED22_nwv,
            EDIn(21) => ED21_nwv,
            EDIn(20) => ED20_nwv,
            EDIn(19) => ED19_nwv,
            EDIn(18) => ED18_nwv,
            EDIn(17) => ED17_nwv,
            EDIn(16) => ED16_nwv,
            EDIn(15) => ED15_nwv,
            EDIn(14) => ED14_nwv,
            EDIn(13) => ED13_nwv,
            EDIn(12) => ED12_nwv,
            EDIn(11) => ED11_nwv,
            EDIn(10) => ED10_nwv,
            EDIn(9) => ED9_nwv,
            EDIn(8) => ED8_nwv,
            EDIn(7) => ED7_nwv,
            EDIn(6) => ED6_nwv,
            EDIn(5) => ED5_nwv,
            EDIn(4) => ED4_nwv,
            EDIn(3) => ED3_nwv,
            EDIn(2) => ED2_nwv,
            EDIn(1) => ED1_nwv,
            EDIn(0) => ED0_nwv,
            TOUT1In => TOUT1_nwv,
            TOUT1Out => TOUT1,
            TOUT0In => TOUT0_nwv,
            TOUT0Out => TOUT0,
            TINP1In => TINP1_nwv,
            TINP1Out => TINP1,
            TINP0In => TINP0_nwv,
            TINP0Out => TINP0,
            CLKS1In => CLKS1_nwv,
            CLKS1Out => CLKS1,
            CLKS0In => CLKS0_nwv,
            CLKS0Out => CLKS0,
            CLKR1In => CLKR1_nwv,
            CLKR1Out => CLKR1,
            CLKR0In => CLKR0_nwv,
            CLKR0Out => CLKR0,
            CLKX1In => CLKX1_nwv,
            CLKX1Out => CLKX1,
            CLKX0In => CLKX0_nwv,
            CLKX0Out => CLKX0,
            DR1In => DR1_nwv,
            DR1Out => DR1,
            DR0In => DR0_nwv,
            DR0Out => DR0,
            DX1In => DX1_nwv,
            DX1Out => DX1,
            DX0In => DX0_nwv,
            DX0Out => DX0,
            FSR1In => FSR1_nwv,
            FSR1Out => FSR1,
            FSR0In => FSR0_nwv,
            FSR0Out => FSR0,
            FSX1In => FSX1_nwv,
            FSX1Out => FSX1,
            FSX0In => FSX0_nwv,
            FSX0Out => FSX0
        );

    -- Type definitions
    TYPE Reg32 IS ARRAY (1 downto 0) OF std_logic_vector(15 downto 0);
    TYPE halfaddr IS ARRAY (1 downto 0) OF NATURAL;
    TYPE ByteMem IS ARRAY (0 to 65535) OF NATURAL RANGE  0 TO 255;
    TYPE twobitreg IS ARRAY (1 downto 0) OF UX01;
    TYPE memoryspace IS (CE0, CE1, CE2, CE3);
    TYPE r_w IS (read, write);
    TYPE WordMem IS ARRAY (15 downto 0) OF NATURAL RANGE  0 TO 255;
    TYPE cpuop_type IS (NOP, WR, RD, MV);

    -- zero delayed outputs and bidirectional ports
    -- (func. sec. uses these signals instead of
    --  actual outputs and bidirectional ports),
    -- actual outputs are assigned in Path Delay Section

    SIGNAL clk3           : std_ulogic := '0';
    SIGNAL CPUclk         : std_ulogic := '0';
    SIGNAL CPUclk2        : std_ulogic := '0';
    SIGNAL SYSCLK3        : std_ulogic := '0';
    SIGNAL SYSCLK2X       : std_ulogic := '0';
    SIGNAL SYSCLK2R       : std_ulogic := '0';
    --McASP1
    SIGNAL AUXCLK         : std_ulogic := '0';
    SIGNAL AUXDIVX        : std_ulogic := '0';
    SIGNAL AUXDIVR        : std_ulogic := '0';
    SIGNAL XCLKDIV        : std_ulogic := '0';
    SIGNAL flagdiv        : BOOLEAN := false;
    SIGNAL XCLK           : std_ulogic := '0';
    SIGNAL RCLK           : std_ulogic := '0';
    SIGNAL AHCLKXTmp      : std_ulogic := '0';
    SIGNAL AHCLKRTmp      : std_ulogic := '0';
    SIGNAL RCLKDIV        : std_ulogic := '0';
    SIGNAL FSX1_int       : std_ulogic := '0';
    SIGNAL FSR1_int       : std_ulogic := '0';
    SIGNAL XRDY01_RD      : std_ulogic := '0';
    SIGNAL RRDY01_RD      : std_ulogic := '0';
    SIGNAL XRDY11_RD      : std_ulogic := '0';
    SIGNAL RRDY11_RD      : std_ulogic := '0';
    SIGNAL XRDY21_RD      : std_ulogic := '0';
    SIGNAL RRDY21_RD      : std_ulogic := '0';
    SIGNAL XRDY31_RD      : std_ulogic := '0';
    SIGNAL RRDY31_RD      : std_ulogic := '0';
    SIGNAL XRDY41_RD      : std_ulogic := '0';
    SIGNAL RRDY41_RD      : std_ulogic := '0';
    SIGNAL XRDY51_RD      : std_ulogic := '0';
    SIGNAL RRDY51_RD      : std_ulogic := '0';
    SIGNAL XRDY61_RD      : std_ulogic := '0';
    SIGNAL RRDY61_RD      : std_ulogic := '0';
    SIGNAL XRDY71_RD      : std_ulogic := '0';
    SIGNAL RRDY71_RD      : std_ulogic := '0';
    SIGNAL XUNDERN1_flag  : std_ulogic := '0';
    SIGNAL ROVERN1_flag   : std_ulogic := '0';
    SIGNAL XSYNC1_RD      : std_ulogic := '0';
    SIGNAL RSYNC1_RD      : std_ulogic := '0';
    SIGNAL RCKFAIL1_RD    : std_ulogic := '0';
    SIGNAL XCKFAIL1_RD    : std_ulogic := '0';
    SIGNAL ACLKX1Out_zd   : std_ulogic := '0';
    SIGNAL ACLKR1Out_int  : std_ulogic := '0';

    SIGNAL ECLK_int       : std_ulogic := '0';
    SIGNAL SDCASNeg_int   : std_ulogic := 'Z';
    SIGNAL HSTROBENeg     : std_ulogic := '0';
    SIGNAL HSTROB_int     : std_ulogic := '0';
    SIGNAL HRDYNeg_int    : std_ulogic := 'L';
    SIGNAL RESET_int      : UX01 := '1';
    SIGNAL HPI_EN         : std_ulogic := '1';
    SIGNAL HPIrd          : std_ulogic := 'U';
    SIGNAL HPIDacc        : std_ulogic := '0';
    SIGNAL HPI_flag       : std_ulogic := '0';
    SIGNAL HDOut_zd       : std_logic_vector(15 downto 0) := (others => 'U');
    SIGNAL PERIOD         : time := 70 ns;
    SIGNAL PERIODX        : time := 70 ns;
    SIGNAL PERIODR        : time := 70 ns;
    SIGNAL PeriodAUX      : time := 70 ns;
    SIGNAL PeriodAUXR     : time := 70 ns;
    SIGNAL PeriodHXCLK    : time := 70 ns;
    SIGNAL PeriodHRCLK    : time := 70 ns;
    SIGNAL PeriodDiv      : time := 70 ns;
    SIGNAL PeriodDivR     : time := 70 ns;
    SIGNAL EPERIOD        : time := 10 ns;    -- ECLKIN period
    SIGNAL PERIODOUT3     : time := 70 ns;
    SIGNAL PERIODSYS1     : time := 70 ns;
    SIGNAL PERIODSYS2     : time := 70 ns;
    SIGNAL PERIODSYS3     : time := 70 ns;
    SIGNAL EDOut_zd       : std_logic_vector (31 downto 0);
    SIGNAL DMAOUTaddr     : std_logic_vector (30 downto 0);
    SIGNAL DMAINaddr      : std_logic_vector (30 downto 0);
    SIGNAL EA_zd          : std_logic_vector (21 downto 2);
    SIGNAL BootReg        : twobitreg;
    SIGNAL counter0       : boolean := false;
    SIGNAL DMAburst       : boolean := false;
    SIGNAL DSPclear       : boolean := false;
    SIGNAL Booting        : boolean := false;
    SIGNAL BootDone       : boolean := false;
    SIGNAL MSpace         : memoryspace;        -- external memory interface
    SIGNAL DMARDY         : UX01 := '0';        -- EDMA to EMIF semiphore
    SIGNAL EMRDY          : UX01 := '0';        -- EMIF to EDMA semiphore
    SIGNAL EMDVALID       : UX01 := '0';        -- EMIF to EDMA data valid
    SIGNAL EADDR          : NATURAL;            -- address to EMIF
    SIGNAL EDATA          : WordMem;            -- 32-bit data from EMIF
    SIGNAL DMADATA        : WordMem;            -- 32-bit data from EDMA
    SIGNAL EMdir          : r_w;                -- EMIF direction (r/w)
    SIGNAL DMAdone        : UX01 := '1';        -- EDMA to CPU semiphore
    SIGNAL CPUrdy         : UX01 := '0';        -- CPU to EDMA semiphore
    SIGNAL CPUaddr        : halfaddr;           -- address to EDMA
    SIGNAL CPUdata        : WordMem;            -- 32-bit data from CPU
    SIGNAL RDdata         : WordMem;            -- 32-bit data to CPU
    SIGNAL CPUop          : cpuop_type;         -- CPU intruction to EDMA
    SIGNAL SDRMinit_tmp   : UX01;
    SIGNAL TRCval         : NATURAL;            -- value of TRC reg
    SIGNAL TCLval         : NATURAL;            -- value of TCL reg
    SIGNAL TRCDval        : NATURAL;            -- value of TRCD reg
    SIGNAL SDBSZval       : NATURAL;            -- value of SDBSZ reg
    SIGNAL SDRSZval       : NATURAL;            -- value of SDRSZ reg
    SIGNAL SDCSZval       : NATURAL;            -- value of SDCSZ reg
    SIGNAL Burst_Size     : NATURAL := 1;       -- length of burst
    SIGNAL CPUsize        : NATURAL;            -- length of burst

    SIGNAL HPIA    : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL HPIC    : Reg32 := ("UUUUUUUUUUUU1UUU","0000000000001000");
    SIGNAL HPIDin  : Reg32;
    SIGNAL HPIDout : Reg32;

    SIGNAL ER      : Reg32;
    SIGNAL EER     : Reg32;
    SIGNAL EVENT   : Reg32;

    --McBSP
    SIGNAL CLKR_int       : std_logic;
    SIGNAL CLKX_int       : std_logic;
    SIGNAL FSR_int        : std_logic;
    SIGNAL FSX_INT        : std_logic;
    SIGNAL FSG            : std_logic := '0';
    SIGNAL CLKG           : std_logic := '0';
    SIGNAL DRXtoXSR_clk   : std_logic := '0';
    SIGNAL CLKSRG         : std_logic;
    SIGNAL XRDY_RD        : std_logic := '0';
    SIGNAL XSYNCERR_RD    : std_logic := '0';
    SIGNAL XEMPTYNeg_RD   : std_logic := '0';
    SIGNAL XINT           : std_logic;
    SIGNAL RRDY_RD        : std_logic := '0';
    SIGNAL RSYNCERR_RD    : std_logic := '0';
    SIGNAL RFULL_RD       : std_logic := '0';
    SIGNAL RINT           : std_logic;
    SIGNAL STOP_sig       : std_logic := '0';
    SIGNAL XRDY_sig       : std_logic := '0';
    SIGNAL XSLAVE_clk     : std_logic := '0';
    SIGNAL CLKXslave_mod  : std_logic := '0';
    SIGNAL XELIN          : Natural;
    SIGNAL RELIN          : Natural;
    SIGNAL flag           : Natural := 0;
    SIGNAL RCOUNTER       : Natural;
    SIGNAL XCOUNTER       : Natural;

    -- EMIF registers

    SIGNAL GBLCTL  : Reg32 := ("0000000000001001","0010000001111100");
    SIGNAL CE3CTL  : Reg32 := ("1111111111111111","1111111100000011");
    SIGNAL CE2CTL  : Reg32 := ("1111111111111111","1111111100000011");
    SIGNAL CE1CTL  : Reg32 := ("1111111111111111","1111111100000011");
    SIGNAL CE0CTL  : Reg32 := ("1111111111111111","1111111100000011");
    SIGNAL SDCTL   : Reg32 := ("0000001001001000","1111000000000000");
    SIGNAL SDTIM   : Reg32 := ("0000000001011101","1100010111011100");
    SIGNAL SDEXT   : Reg32 := ("0000000000010111","0101111100111111");

    -- PLL registers

    SIGNAL PLLPID      : Reg32 := ("0000000000000001","0000100000000001");
    SIGNAL PLLCSR      : Reg32 := ("0000000000000000","0000000001001000");
    SIGNAL PLLMCR      : Reg32 := ("0000000000000000","0000000000000111");
    SIGNAL PLLDIV0     : Reg32 := ("0000000000000000","1000000000000000");
    SIGNAL PLLDIV1     : Reg32 := ("0000000000000000","1000000000000000");
    SIGNAL PLLDIV2     : Reg32 := ("0000000000000000","1000000000000001");
    SIGNAL PLLDIV3     : Reg32 := ("0000000000000000","1000000000000001");
    SIGNAL OSCDIV1     : Reg32 := ("0000000000000000","1000000000000111");

    -- Device Configuration Register
    SIGNAL DEVCFG      : Reg32 := ("0000000000000000","0000000000000000");

    -- McBSP0 registers

    SIGNAL RSR0        : STD_LOGIC_VECTOR (31 downto 0)
                                        :="00000000000000000000000000000000";
    SIGNAL RBR0        : STD_LOGIC_VECTOR (31 downto 0)
                                        :="00000000000000000000000000000000";
    SIGNAL XSR0        : STD_LOGIC_VECTOR (31 downto 0)
                                        :="00000000000000000000000000000000";
    SIGNAL DRR0        : STD_LOGIC_VECTOR (31 downto 0)
                                        :="00000000000000000000000000000000";
    SIGNAL DXR0        : STD_LOGIC_VECTOR (31 downto 0)
                                        :="00000000000000000000000000000000";
    -- serial port control register
    SIGNAL SPCR0       : Reg32 := ("0000000000000000","0000000000000000");
    -- pin control register
    SIGNAL PCR0        : Reg32 := ("0000000000000000","0000000000000000");
    -- receive control register
    SIGNAL RCR0        : Reg32 := ("0000000000000000","0000000000000000");
    -- transmit control register
    SIGNAL XCR0        : Reg32 := ("0000000000000000","0000000000000000");
    -- sample rate generator register
    SIGNAL SRGR0       : Reg32 := ("0000000000000000","0000000000000000");
    -- multichanel control register
    SIGNAL MCR0        : Reg32 := ("0000000000000000","0000000000000000");
    -- receive channel enable register
    SIGNAL RCER0       : Reg32 := ("0000000000000000","0000000000000000");
    -- transmit channel enable register
    SIGNAL XCER0       : Reg32 := ("0000000000000000","0000000000000000");

    -- McBSP1 registers

    SIGNAL RSR1        : STD_LOGIC_VECTOR (31 downto 0)
                                        :="00000000000000000000000000000000";
    SIGNAL RBR1        : STD_LOGIC_VECTOR (31 downto 0)
                                        :="00000000000000000000000000000000";
    SIGNAL XSR1        : STD_LOGIC_VECTOR (31 downto 0)
                                        :="00000000000000000000000000000000";
    SIGNAL DRR1        : STD_LOGIC_VECTOR (31 downto 0)
                                        :="00000000000000000000000000000000";
    SIGNAL DXR1        : STD_LOGIC_VECTOR (31 downto 0)
                                        :="00000000000000000000000000000000";
    -- serial port control register
    SIGNAL SPCR1       : Reg32 := ("0000000000000000","0000000000000000");
    -- pin control register
    SIGNAL PCR1        : Reg32 := ("0000000000000000","0000000000000000");
    -- receive control register
    SIGNAL RCR1        : Reg32 := ("0000000000000000","0000000000000000");
    -- transmit control register
    SIGNAL XCR1        : Reg32 := ("0000000000000000","0000000000000000");
    -- sample rate generator register
    SIGNAL SRGR1       : Reg32 := ("0000000000000000","0000000000000000");
    -- multichanel control register
    SIGNAL MCR1        : Reg32 := ("0000000000000000","0000000000000000");
    -- receive channel enable register
    SIGNAL RCER1       : Reg32 := ("0000000000000000","0000000000000000");
    -- transmit channel enable register
    SIGNAL XCER1       : Reg32 := ("0000000000000000","0000000000000000");

    -- Timer registers

    SIGNAL Timer0CTL   : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL Timer0PRD   : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL Timer0CNT   : Reg32 := ("0000000000000000","0000000000000000");

    SIGNAL Timer1CTL   : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL Timer1PRD   : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL Timer1CNT   : Reg32 := ("0000000000000000","0000000000000000");

    -- McASP1 Registers

    SIGNAL RBUF01              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RBUF11              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RBUF21              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RBUF31              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RBUF41              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RBUF51              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RBUF61              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RBUF71              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XBUF01              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XBUF11              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XBUF21              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XBUF31              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XBUF41              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XBUF51              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XBUF61              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XBUF71              : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XSR01               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XSR11               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XSR21               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XSR31               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XSR41               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XSR51               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XSR61               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XSR71               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RSR01               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RSR11               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RSR21               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RSR31               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RSR41               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RSR51               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RSR61               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RSR71               : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";

    -- pin function register
    SIGNAL PFUNC1      : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    -- pin direction register
    SIGNAL PDIR1       : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    -- global control register
    SIGNAL GBLCTL1     : Reg32 := ("0000000000000000","0000001000000000");
    -- digital loop-back control register
    SIGNAL AMUTE1Reg   : Reg32 := ("0000000000000000","0000000000000000");
    -- digital loop-back control register
    SIGNAL DLBCTL1     : Reg32 := ("0000000000000000","0000000000000000");
    -- DIT mode control register
    SIGNAL DITCTL1     : Reg32 := ("0000000000000000","0000000000000000");
    -- global control register
    SIGNAL R3GBLCTL1    : Reg32 := ("0000000000000000","0000000000000000");
    -- receiver mask register
    SIGNAL RMASK1      : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    -- receiver format register
    SIGNAL RFMT1       : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL AFSRCTL1    : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL ACLKRCTL1   : Reg32 := ("0000000000000000","0000000000100000");
    SIGNAL AHCLKRCTL1  : Reg32 := ("0000000000000000","1000000000000000");
    SIGNAL RTDM1       : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL RINTCTL1    : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL RSTAT1      : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL RSLOT1      : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL RCLKCHK1    : Reg32 := ("0000000000000000","0000000000000000");
    -- global control register
    SIGNAL XGBLCTL1    : Reg32 := ("0000000000000000","0000000000000000");
    -- transmit mask register
    SIGNAL XMASK1      : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    -- transmit format register
    SIGNAL XFMT1       : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL AFSXCTL1    : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL ACLKXCTL1   : Reg32 := ("0000000000000000","0000000000100000");
    SIGNAL AHCLKXCTL1  : Reg32 := ("0000000000000000","1000000000000000");
    SIGNAL XTDM1       : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL XINTCTL1    : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL XSTAT1      : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL XSLOT1      : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL XCLKCHK1    : Reg32 := ("0000000000000000","0000000000000000");
    -- serializer control registers
    SIGNAL SRCTL01     : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL SRCTL11     : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL SRCTL21     : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL SRCTL31     : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL SRCTL41     : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL SRCTL51     : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL SRCTL61     : Reg32 := ("0000000000000000","0000000000000000");
    SIGNAL SRCTL71     : Reg32 := ("0000000000000000","0000000000000000");
    -- DIT  Channel Status Registers
    SIGNAL DITCSRA0    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITCSRA1    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITCSRA2    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITCSRA3    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITCSRA4    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITCSRA5    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITCSRB0    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITCSRB1    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITCSRB2    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITCSRB3    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITCSRB4    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITCSRB5    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    -- DIT  Channel User Data Registers
    SIGNAL DITUDRA0    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITUDRA1    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITUDRA2    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITUDRA3    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITUDRA4    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITUDRA5    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITUDRB0    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITUDRB1    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITUDRB2    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITUDRB3    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITUDRB4    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";
    SIGNAL DITUDRB5    : std_logic_vector (31 downto 0)
                                     :="00000000000000000000000000000000";

    -- Internal memory
    SIGNAL L2Mem       : ByteMem;

    -- multipexed pins
    ALIAS AXR1Out0         : std_ulogic IS HROut;
    ALIAS AXR1In0          : std_ulogic IS HR;
    ALIAS AXR1Out7         : std_ulogic IS HDOut(1);
    ALIAS AXR1In7          : std_ulogic IS HDIn(1);
    ALIAS AXR1Out4         : std_ulogic IS HDOut(0);
    ALIAS AXR1In4          : std_ulogic IS HDIn(0);
    ALIAS AXR1Out1         : std_ulogic IS HCNTLOut(1);
    ALIAS AXR1In1          : std_ulogic IS HCNTL(1);
    ALIAS AXR1Out3         : std_ulogic IS HCNTLOut(0);
    ALIAS AXR1In3          : std_ulogic IS HCNTL(0);
    ALIAS AXR1Out6         : std_ulogic IS HDS1NegOut;
    ALIAS AXR1In6          : std_ulogic IS HDS1Neg;
    ALIAS AXR1Out5         : std_ulogic IS HDS2NegOut;
    ALIAS AXR1In5          : std_ulogic IS HDS2Neg;
    ALIAS AXR1Out2         : std_ulogic IS HCSNegOut;
    ALIAS AXR1In2          : std_ulogic IS HCSNeg;
    ALIAS AHCLKR1Out       : std_ulogic IS HDOut(6);
    ALIAS AHCLKR1In        : std_ulogic IS HDIn(6);
    ALIAS AHCLKX1Out       : std_ulogic IS HDOut(5);
    ALIAS AHCLKX1In        : std_ulogic IS HDIn(5);
    ALIAS AMUTE1           : std_ulogic IS HDOut(3);
    ALIAS AFSX1Out         : std_ulogic IS HDOut(2);
    ALIAS AFSX1In          : std_ulogic IS HDIn(2);
    ALIAS AFSR1Out         : std_ulogic IS HHWILOut;
    ALIAS AFSR1In          : std_ulogic IS HHWIL;
    ALIAS ACLKR1Out        : std_ulogic IS HRDYNeg;
    ALIAS ACLKR1In         : std_ulogic IS HRDYNegIn;
    ALIAS ACLKX1Out        : std_ulogic IS HASNegOut;
    ALIAS ACLKX1In         : std_ulogic IS HASNeg;
    ALIAS AMUTEIN1         : std_ulogic IS EXTINT4;

    ALIAS HWOB       : std_ulogic IS HPIC(0)(0);
    ALIAS DSPINT     : std_ulogic IS HPIC(0)(1);
    ALIAS HINT       : std_ulogic IS HPIC(0)(2);
    ALIAS HRDY       : std_ulogic IS HPIC(0)(3);
    ALIAS FETCH      : std_ulogic IS HPIC(0)(4);
    ALIAS PLLEN      : std_ulogic IS PLLCSR(0)(0);
    ALIAS PLLRST     : std_ulogic IS PLLCSR(0)(3);
    ALIAS PLLM       : std_logic_vector(4 downto 0) IS PLLMCR(0)(4 downto 0);
    ALIAS DIV0       : std_logic_vector(4 downto 0) IS PLLDIV0(0)(4 downto 0);
    ALIAS DIV0EN     : std_ulogic IS PLLDIV0(0)(15);
    ALIAS DIV1       : std_logic_vector(4 downto 0) IS PLLDIV1(0)(4 downto 0);
    ALIAS DIV1EN     : std_ulogic IS PLLDIV1(0)(15);
    ALIAS DIV2       : std_logic_vector(4 downto 0) IS PLLDIV2(0)(4 downto 0);
    ALIAS DIV2EN     : std_ulogic IS PLLDIV2(0)(15);
    ALIAS DIV3       : std_logic_vector(4 downto 0) IS PLLDIV3(0)(4 downto 0);
    ALIAS DIV3EN     : std_ulogic IS PLLDIV3(0)(15);
    ALIAS ODIV1      : std_logic_vector(4 downto 0) IS OSCDIV1(0)(4 downto 0);
    ALIAS ODIV1EN    : std_ulogic IS OSCDIV1(0)(15);
    ALIAS CLK2EN     : std_ulogic IS GBLCTL(0)(3);
    ALIAS EKEN       : std_ulogic IS GBLCTL(0)(5);
    ALIAS EKSRC      : std_ulogic IS DEVCFG(0)(4);
    ALIAS NOHOLD     : std_ulogic IS GBLCTL(0)(7);
    ALIAS HOLDAbit   : std_ulogic IS GBLCTL(0)(8);
    ALIAS HOLDbit    : std_ulogic IS GBLCTL(0)(9);
    ALIAS SDRMinit   : std_ulogic IS SDCTL(1)(8);
    ALIAS RFEN       : std_ulogic IS SDCTL(1)(9);
    ALIAS SDBSZ      : std_ulogic IS SDCTL(1)(14);
    ALIAS SDRSZ    : std_logic_vector(1 downto 0) IS SDCTL(1)(13 downto 12);
    ALIAS SDCSZ    : std_logic_vector(1 downto 0) IS SDCTL(1)(11 downto 10);
    ALIAS TCL      : std_ulogic IS SDEXT(0)(0);
    ALIAS TRC      : std_logic_vector(3 downto 0) IS SDCTL(0)(15 downto 12);
    ALIAS TRP      : std_logic_vector(3 downto 0) IS SDCTL(1)(3 downto 0);
    ALIAS TRCD     : std_logic_vector(3 downto 0) IS SDCTL(1)(7 downto 4);
    ALIAS REFPER   : std_logic_vector(11 downto 0) IS SDTIM(0)(11 downto 0);
    ALIAS XRFR     : std_logic_vector(1 downto 0) IS SDTIM(1)(9 downto 8);
    ALIAS SDINT    : std_ulogic IS ER(0)(3);

    ALIAS BootMode4  : std_ulogic IS HDIn(4);
    ALIAS BootMode3  : std_ulogic IS HDIn(3);
    ALIAS CE0mtype   : std_logic_vector(3 downto 0) IS CE0CTL(0)(7 downto 4);
    ALIAS CE1mtype   : std_logic_vector(3 downto 0) IS CE1CTL(0)(7 downto 4);
    ALIAS CE2mtype   : std_logic_vector(3 downto 0) IS CE2CTL(0)(7 downto 4);
    ALIAS CE3mtype   : std_logic_vector(3 downto 0) IS CE3CTL(0)(7 downto 4);

    --McBSP0

    ALIAS FRSTNeg     : std_ulogic IS SPCR0(1)(7);
    ALIAS GRSTNeg     : std_ulogic IS SPCR0(1)(6);
    ALIAS XINTM       : std_logic_vector(1 downto 0) IS SPCR0(1)(5 downto 4);
    ALIAS XSYNCERR    : std_ulogic IS SPCR0(1)(3);
    ALIAS XEMPTYNeg   : std_ulogic IS SPCR0(1)(2);
    ALIAS XRDY        : std_ulogic IS SPCR0(1)(1);
    ALIAS XRSTNeg     : std_ulogic IS SPCR0(1)(0);
    ALIAS DLB         : std_ulogic IS SPCR0(0)(15);
    ALIAS RJUST       : std_logic_vector(1 downto 0) IS SPCR0(0)(14 downto 13);
    ALIAS CLKSTP      : std_logic_vector(1 downto 0) IS SPCR0(0)(12 downto 11);
    ALIAS DXENA       : std_ulogic is SPCR0(0)(7);
    ALIAS RINTM       : std_logic_vector(1 downto 0) IS SPCR0(0)(5 downto 4);
    ALIAS RSYNCERR    : std_ulogic IS SPCR0(0)(3);
    ALIAS RFULL       : std_ulogic IS SPCR0(0)(2);
    ALIAS RRDY        : std_ulogic IS SPCR0(0)(1);
    ALIAS RRSTNeg     : std_ulogic IS SPCR0(0)(0);
    SIGNAL XRDY_t     : std_logic := '1';

    ALIAS XIOEN       : std_ulogic IS PCR0(0)(13);
    ALIAS RIOEN       : std_ulogic IS PCR0(0)(12);
    ALIAS FSXM        : std_ulogic IS PCR0(0)(11);
    ALIAS FSRM        : std_ulogic IS PCR0(0)(10);
    ALIAS CLKXM       : std_ulogic IS PCR0(0)(9);
    ALIAS CLKRM       : std_ulogic IS PCR0(0)(8);
    ALIAS CLKS0_STAT  : std_ulogic IS PCR0(0)(6);
    ALIAS DX0_STAT    : std_ulogic IS PCR0(0)(5);
    ALIAS DR0_STAT    : std_ulogic IS PCR0(0)(4);
    ALIAS FSXP        : std_ulogic IS PCR0(0)(3);
    ALIAS FSRP        : std_ulogic IS PCR0(0)(2);
    ALIAS CLKXP       : std_ulogic IS PCR0(0)(1);
    ALIAS CLKRP       : std_ulogic IS PCR0(0)(0);

    ALIAS RPHASE      : std_ulogic IS RCR0(1)(15);
    ALIAS RFRLEN2     : std_logic_vector (6 downto 0) IS RCR0(1)(14 downto 8);
    ALIAS RWDLEN2     : std_logic_vector (2 downto 0) IS RCR0(1)(7 downto 5);
    ALIAS RCOMPAD     : std_logic_vector (1 downto 0) IS RCR0(1)(4 downto 3);
    ALIAS RFIG        : std_ulogic IS RCR0(1)(2);
    ALIAS RDATDLY     : std_logic_vector (1 downto 0) IS RCR0(1)(1 downto 0);
    ALIAS RFRLEN1     : std_logic_vector (6 downto 0) IS RCR0(0)(14 downto 8);
    ALIAS RWDLEN1     : std_logic_vector (2 downto 0) IS RCR0(0)(7 downto 5);
    ALIAS RWDREVRS    : std_ulogic IS RCR0(0)(4);

    ALIAS XPHASE      : std_ulogic IS XCR0(1)(15);
    ALIAS XFRLEN2     : std_logic_vector (6 downto 0) IS XCR0(1)(14 downto 8);
    ALIAS XWDLEN2     : std_logic_vector (2 downto 0) IS XCR0(1)(7 downto 5);
    ALIAS XCOMPAD     : std_logic_vector (1 downto 0) IS XCR0(1)(4 downto 3);
    ALIAS XFIG        : std_ulogic IS XCR0(1)(2);
    ALIAS XDATDLY     : std_logic_vector (1 downto 0) IS XCR0(1)(1 downto 0);
    ALIAS XFRLEN1     : std_logic_vector (6 downto 0) IS XCR0(0)(14 downto 8);
    ALIAS XWDLEN1     : std_logic_vector (2 downto 0) IS XCR0(0)(7 downto 5);
    ALIAS XWDREVRS    : std_ulogic IS XCR0(0)(4);

    ALIAS GSYNC       : std_ulogic IS SRGR0(1)(15);
    ALIAS CLKSP       : std_ulogic IS SRGR0(1)(14);
    ALIAS CLKSM       : std_ulogic IS SRGR0(1)(13);
    ALIAS FSGM        : std_ulogic IS SRGR0(1)(12);
    ALIAS FPER        : std_logic_vector (11 downto 0) IS SRGR0(1)(11 downto 0);
    ALIAS FWID        : std_logic_vector (7 downto 0) IS SRGR0(0)(15 downto 8);
    ALIAS CLKGDV      : std_logic_vector (7 downto 0) IS SRGR0(0)(7 downto 0);

    ALIAS XMCME       : std_ulogic IS MCR0(1)(9);
    ALIAS XPBBLK      : std_logic_vector (1 downto 0) IS MCR0(1) (8 downto 7);
    ALIAS XPABLK      : std_logic_vector (1 downto 0) IS MCR0(1) (6 downto 5);
    ALIAS XCBLK       : std_logic_vector (2 downto 0) IS MCR0(1) (4 downto 2);
    ALIAS XMCM        : std_logic_vector (1 downto 0) IS MCR0(1) (1 downto 0);
    ALIAS RMCME       : std_ulogic IS MCR0(0)(9);
    ALIAS RPBBLK      : std_logic_vector (1 downto 0) IS MCR0(0) (8 downto 7);
    ALIAS RPABLK      : std_logic_vector (1 downto 0) IS MCR0(0) (6 downto 5);
    ALIAS RCBLK       : std_logic_vector (2 downto 0) IS MCR0(0) (4 downto 2);
    ALIAS RMCM        : std_ulogic IS MCR0(0) (0);

    -- McASP1
    ALIAS XFRST1     : std_ulogic IS GBLCTL1(0)(12);
    ALIAS XSMRST1    : std_ulogic IS GBLCTL1(0)(11);
    ALIAS XSRCLR1    : std_ulogic IS GBLCTL1(0)(10);
    ALIAS XHCLKRST1  : std_ulogic IS GBLCTL1(0)(9);
    ALIAS XCLKRST1   : std_ulogic IS GBLCTL1(0)(8);
    ALIAS RFRST1     : std_ulogic IS GBLCTL1(0)(4);
    ALIAS RSMRST1    : std_ulogic IS GBLCTL1(0)(3);
    ALIAS RSRCLR1    : std_ulogic IS GBLCTL1(0)(2);
    ALIAS RHCLKRST1  : std_ulogic IS GBLCTL1(0)(1);
    ALIAS RCLKRST1   : std_ulogic IS GBLCTL1(0)(0);
    ALIAS XCKFAIL1   : std_ulogic IS AMUTE1Reg(0)(10);
    ALIAS RCKFAIL1   : std_ulogic IS AMUTE1Reg(0)(9);
    ALIAS XSYNCERR1  : std_ulogic IS AMUTE1Reg(0)(8);
    ALIAS RSYNCERR1  : std_ulogic IS AMUTE1Reg(0)(7);
    ALIAS XUNDRN1    : std_ulogic IS AMUTE1Reg(0)(6);
    ALIAS ROVRN1     : std_ulogic IS AMUTE1Reg(0)(5);
    ALIAS INSTAT1    : std_ulogic IS AMUTE1Reg(0)(4);
    ALIAS INEN1      : std_ulogic IS AMUTE1Reg(0)(3);
    ALIAS INPOL1     : std_ulogic IS AMUTE1Reg(0)(2);
    ALIAS MUTEN1    : std_logic_vector (1 downto 0) IS
                      AMUTE1Reg(0) (1 downto 0);
    ALIAS MODE1     : std_logic_vector (1 downto 0) IS DLBCTL1(0) (3 downto 2);
    ALIAS ORD1      : std_ulogic IS DLBCTL1(0)(1);
    ALIAS DLBEN1    : std_ulogic IS DLBCTL1(0)(0);
    ALIAS VB1       : std_ulogic IS DLBCTL1(0)(3);
    ALIAS VA1       : std_ulogic IS DLBCTL1(0)(2);
    ALIAS DITEN1    : std_ulogic IS DITCTL1(0)(0);
    ALIAS RDATDLY1  : std_logic_vector (1 downto 0) IS RFMT1(1) (1 downto 0);
    ALIAS RRVRS1    : std_ulogic IS RFMT1(0)(15);
    ALIAS RPAD1     : std_logic_vector (1 downto 0) IS RFMT1(0) (14 downto 13);
    ALIAS RPBIT1    : std_logic_vector (4 downto 0) IS RFMT1(0) (12 downto 8);
    ALIAS RSSZ1     : std_logic_vector (3 downto 0) IS RFMT1(0) (7 downto 4);
    ALIAS RBUSEL1   : std_ulogic IS RFMT1(0)(3);
    ALIAS RROT1     : std_logic_vector (2 downto 0) IS RFMT1(0) (2 downto 0);
    ALIAS RMOD1    : std_logic_vector (8 downto 0) IS AFSRCTL1(0) (15 downto 7);
    ALIAS FRWID1    : std_ulogic IS AFSRCTL1(0)(4);
    ALIAS FSRM1     : std_ulogic IS AFSRCTL1(0)(1);
    ALIAS FSRP1     : std_ulogic IS AFSRCTL1(0)(0);
    ALIAS CLKRP1    : std_ulogic IS ACLKRCTL1(0)(7);
    ALIAS CLKRM1    : std_ulogic IS ACLKRCTL1(0)(5);
    ALIAS CLKRDIV1 : std_logic_vector (4 downto 0) IS ACLKRCTL1(0) (4 downto 0);
    ALIAS HCLKRM1   : std_ulogic IS AHCLKRCTL1(0)(15);
    ALIAS HCLKRP1   : std_ulogic IS AHCLKRCTL1(0)(14);
    ALIAS HCLKRDIV1 : std_logic_vector (11 downto 0) IS
                      AHCLKRCTL1(0) (11 downto 0);
    ALIAS RSTAFRM1  : std_ulogic IS RINTCTL1(0)(7);
    ALIAS RDATAINT1 : std_ulogic IS RINTCTL1(0)(5);
    ALIAS RLASTINT1 : std_ulogic IS RINTCTL1(0)(4);
    ALIAS RFAILINT1 : std_ulogic IS RINTCTL1(0)(2);
    ALIAS RSYNINT1  : std_ulogic IS RINTCTL1(0)(1);
    ALIAS ROVRNINT1 : std_ulogic IS RINTCTL1(0)(0);
    ALIAS RERR1     : std_ulogic IS RSTAT1(1)(8);
    ALIAS RSTRTFRM1 : std_ulogic IS RSTAT1(0)(6);
    ALIAS RDATA1    : std_ulogic IS RSTAT1(0)(5);
    ALIAS RLAST1    : std_ulogic IS RSTAT1(0)(4);
    ALIAS RTDMSLOT1 : std_ulogic IS RSTAT1(0)(3);
    ALIAS RCKFL1    : std_ulogic IS RSTAT1(0)(2);
    ALIAS RSYNC1    : std_ulogic IS RSTAT1(0)(1);
    ALIAS ROVERN1   : std_ulogic IS RSTAT1(0)(0);
    ALIAS RSLOTCNT1 : std_logic_vector (9 downto 0) IS RSLOT1(0) (9 downto 0);
    ALIAS RCNT1    : std_logic_vector (8 downto 0) IS RCLKCHK1(1) (15 downto 7);
    ALIAS RMAX1    : std_logic_vector (7 downto 0) IS RCLKCHK1(1) (7 downto 0);
    ALIAS RMIN1    : std_logic_vector (7 downto 0) IS RCLKCHK1(0) (15 downto 8);
    ALIAS RPS1     : std_logic_vector (3 downto 0) IS RCLKCHK1(0) (3 downto 0);
    ALIAS XDATDLY1  : std_logic_vector (1 downto 0) IS XFMT1(1) (1 downto 0);
    ALIAS XRVRS1    : std_ulogic IS XFMT1(0)(15);
    ALIAS XPAD1     : std_logic_vector (1 downto 0) IS XFMT1(0) (14 downto 13);
    ALIAS XPBIT1    : std_logic_vector (4 downto 0) IS XFMT1(0) (12 downto 8);
    ALIAS XSSZ1     : std_logic_vector (3 downto 0) IS XFMT1(0) (7 downto 4);
    ALIAS XBUSEL1   : std_ulogic IS XFMT1(0)(3);
    ALIAS XROT1     : std_logic_vector (2 downto 0) IS XFMT1(0) (2 downto 0);
    ALIAS XMOD1    : std_logic_vector (8 downto 0) IS AFSXCTL1(0) (15 downto 7);
    ALIAS FXWID1    : std_ulogic IS AFSXCTL1(0)(4);
    ALIAS FSXM1     : std_ulogic IS AFSXCTL1(0)(1);
    ALIAS FSXP1     : std_ulogic IS AFSXCTL1(0)(0);
    ALIAS CLKXP1    : std_ulogic IS ACLKXCTL1(0)(7);
    ALIAS ASYNC1    : std_ulogic IS ACLKXCTL1(0)(6);
    ALIAS CLKXM1    : std_ulogic IS ACLKXCTL1(0)(5);
    ALIAS CLKXDIV1 : std_logic_vector (4 downto 0) IS ACLKXCTL1(0) (4 downto 0);
    ALIAS HCLKXM1   : std_ulogic IS AHCLKXCTL1(0)(15);
    ALIAS HCLKXP1   : std_ulogic IS AHCLKXCTL1(0)(14);
    ALIAS HCLKXDIV1 : std_logic_vector (11 downto 0) IS
                      AHCLKXCTL1(0) (11 downto 0);
    ALIAS XSTAFRM1  : std_ulogic IS XINTCTL1(0)(7);
    ALIAS XDATAINT1 : std_ulogic IS XINTCTL1(0)(5);
    ALIAS XLASTINT1 : std_ulogic IS XINTCTL1(0)(4);
    ALIAS XFAILINT1 : std_ulogic IS XINTCTL1(0)(2);
    ALIAS XSYNINT1  : std_ulogic IS XINTCTL1(0)(1);
    ALIAS XUNDRINT1 : std_ulogic IS XINTCTL1(0)(0);
    ALIAS XERR1     : std_ulogic IS XSTAT1(1)(8);
    ALIAS XSTRTFRM1 : std_ulogic IS XSTAT1(0)(6);
    ALIAS XDATA1    : std_ulogic IS XSTAT1(0)(5);
    ALIAS XLAST1    : std_ulogic IS XSTAT1(0)(4);
    ALIAS XTDMSLOT1 : std_ulogic IS XSTAT1(0)(3);
    ALIAS XCKFL1    : std_ulogic IS XSTAT1(0)(2);
    ALIAS XSYNC1    : std_ulogic IS XSTAT1(0)(1);
    ALIAS XUNDERN1  : std_ulogic IS XSTAT1(0)(0);
    ALIAS XSLOTCNT1 : std_logic_vector (9 downto 0) IS XSLOT1(0) (9 downto 0);
    ALIAS XCNT1    : std_logic_vector (8 downto 0) IS XCLKCHK1(1) (15 downto 7);
    ALIAS XMAX1    : std_logic_vector (7 downto 0) IS XCLKCHK1(1) (7 downto 0);
    ALIAS XMIN1    : std_logic_vector (7 downto 0) IS XCLKCHK1(0) (15 downto 8);
    ALIAS XCKFAILSW1 : std_ulogic IS XCLKCHK1(0)(7);
    ALIAS XPS1     : std_logic_vector (3 downto 0) IS XCLKCHK1(0) (3 downto 0);
    ALIAS RRDY01    : std_ulogic IS SRCTL01(0)(5);
    ALIAS XRDY01    : std_ulogic IS SRCTL01(0)(4);
    ALIAS DISMOD01  : std_logic_vector (1 downto 0) IS SRCTL01(0) (3 downto 2);
    ALIAS SRMOD01   : std_logic_vector (1 downto 0) IS SRCTL01(0) (1 downto 0);
    ALIAS RRDY11    : std_ulogic IS SRCTL11(0)(5);
    ALIAS XRDY11    : std_ulogic IS SRCTL11(0)(4);
    ALIAS DISMOD11  : std_logic_vector (1 downto 0) IS SRCTL11(0) (3 downto 2);
    ALIAS SRMOD11   : std_logic_vector (1 downto 0) IS SRCTL11(0) (1 downto 0);
    ALIAS RRDY21    : std_ulogic IS SRCTL21(0)(5);
    ALIAS XRDY21    : std_ulogic IS SRCTL21(0)(4);
    ALIAS DISMOD21  : std_logic_vector (1 downto 0) IS SRCTL21(0) (3 downto 2);
    ALIAS SRMOD21   : std_logic_vector (1 downto 0) IS SRCTL21(0) (1 downto 0);
    ALIAS RRDY31    : std_ulogic IS SRCTL31(0)(5);
    ALIAS XRDY31    : std_ulogic IS SRCTL31(0)(4);
    ALIAS DISMOD31  : std_logic_vector (1 downto 0) IS SRCTL31(0) (3 downto 2);
    ALIAS SRMOD31   : std_logic_vector (1 downto 0) IS SRCTL31(0) (1 downto 0);
    ALIAS RRDY41    : std_ulogic IS SRCTL41(0)(5);
    ALIAS XRDY41    : std_ulogic IS SRCTL41(0)(4);
    ALIAS DISMOD41  : std_logic_vector (1 downto 0) IS SRCTL41(0) (3 downto 2);
    ALIAS SRMOD41   : std_logic_vector (1 downto 0) IS SRCTL41(0) (1 downto 0);
    ALIAS RRDY51    : std_ulogic IS SRCTL51(0)(5);
    ALIAS XRDY51    : std_ulogic IS SRCTL51(0)(4);
    ALIAS DISMOD51  : std_logic_vector (1 downto 0) IS SRCTL51(0) (3 downto 2);
    ALIAS SRMOD51   : std_logic_vector (1 downto 0) IS SRCTL51(0) (1 downto 0);
    ALIAS RRDY61    : std_ulogic IS SRCTL61(0)(5);
    ALIAS XRDY61    : std_ulogic IS SRCTL61(0)(4);
    ALIAS DISMOD61  : std_logic_vector (1 downto 0) IS SRCTL61(0) (3 downto 2);
    ALIAS SRMOD61   : std_logic_vector (1 downto 0) IS SRCTL61(0) (1 downto 0);
    ALIAS RRDY71    : std_ulogic IS SRCTL71(0)(5);
    ALIAS XRDY71    : std_ulogic IS SRCTL71(0)(4);
    ALIAS DISMOD71  : std_logic_vector (1 downto 0) IS SRCTL71(0) (3 downto 2);
    ALIAS SRMOD71   : std_logic_vector (1 downto 0) IS SRCTL71(0) (1 downto 0);

    BEGIN

        HSTROBENeg <= (NOT(HDS1Neg XOR HDS2Neg)) OR HCSNeg;
        HSTROB_int <= HSTROBENeg AND HASNeg;
        HRDYNeg <= HRDYNeg_int WHEN HPI_EN = '1' ELSE ACLKR1Out_int;
        ECLKOUT <= ECLK_int;
        SDCASNeg <= SDCASNeg_int;
        TRCval <= to_nat(TRC);
        TCLval <= to_nat(TCL) + 2;
        TRCDval <= to_nat(TRCD);
        WITH SDBSZ SELECT
            SDBSZval <= 1 WHEN '0',
                        2 WHEN '1',
                        0 WHEN OTHERS;
        WITH SDCSZ SELECT
            SDCSZval <= 9 WHEN "00",
                        8 WHEN "01",
                        10 WHEN "10",
                        0 WHEN OTHERS;
        WITH SDRSZ SELECT
            SDRSZval <= 11 WHEN "00",
                        12 WHEN "01",
                        13 WHEN "10",
                        0 WHEN OTHERS;

        EVENT(0) <= ER(0) AND EER(0);

    PLL: PROCESS(CLKIN, RESET_int, CLKMODE0)

    VARIABLE Previous     : Time := 0 ns;
    VARIABLE TmpPer       : Time := 0 ns;
    VARIABLE PERIODRef    : Time := 0 ns;
    VARIABLE PERIODInt    : Time := 0 ns;
    VARIABLE PeriodOut    : Time := 0 ns;
    VARIABLE div          : NATURAL := 0;
    VARIABLE divider      : NATURAL := 0;
    VARIABLE mul          : NATURAL := 0;

    -- Timing Check Variables
    VARIABLE PD_CLKIN       : VitalPeriodDataType := VitalPeriodDataInit;
    VARIABLE Pviol_CLKIN    : X01 := '0';

    VARIABLE Violation      : X01 := '0';

    BEGIN
    ----------------------------------------------------------------------------
    -- Timing Check Section
    ----------------------------------------------------------------------------

    IF  (TimingChecksOn) THEN

        VitalPeriodPulseCheck (
          TestSignal      =>  CLKIN,
          TestSignalName  =>  "CLKIN",
          Period          =>  tperiod_CLKIN_PLLEN_EQ_1_posedge,
          PulseWidthLow   =>  0.4 * TmpPer,
          PulseWidthHigh  =>  0.4 * TmpPer,
          PeriodData      =>  PD_CLKIN,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Pviol_CLKIN,
          HeaderMsg       =>  InstancePath & PartID,
          CheckEnabled    =>  CLKMODE0 = '1' AND RESETNeg = '1'
                                AND PLLEN = '1');

        VitalPeriodPulseCheck (
          TestSignal      =>  CLKIN,
          TestSignalName  =>  "CLKIN",
          Period          =>  tperiod_CLKIN_PLLEN_EQ_0_posedge,
          PulseWidthLow   =>  0.4 * TmpPer,
          PulseWidthHigh  =>  0.4 * TmpPer,
          PeriodData      =>  PD_CLKIN,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Pviol_CLKIN,
          HeaderMsg       =>  InstancePath & PartID,
          CheckEnabled    =>  CLKMODE0 = '1' AND RESETNeg = '1'
                                AND PLLEN = '0');

        Violation := Pviol_CLKIN;

    END IF;

    ----------------------------------------------------------------------------
    -- Functionality section
    ----------------------------------------------------------------------------

    IF CLKMODE0 = '1' THEN
        AUXCLK <= CLKIN;
        IF rising_edge(CLKIN) THEN
            TmpPer := NOW - Previous;
            IF TmpPer > 0 ns THEN
                PERIOD <= TmpPer/2;
                PERIODInt := TmpPer/2;
            END IF;
            Previous := NOW;
        END IF;
        IF RESET_int = '1' THEN
            div := to_nat(ODIV1) + 1;
            PERIODOUT3 <= PeriodInt * div;
            IF PLLEN = '1' THEN
               div := to_nat(DIV0) + 1;
                PeriodRef := PeriodInt * div;
                mul := to_nat(PLLM);
                PeriodOut := PeriodRef/mul;
            ELSE
                PeriodOut := PeriodInt;
            END IF;
            div := to_nat(DIV1) + 1;
            PERIODSYS1 <= PeriodInt * div;
            PERIODSYS2 <= PeriodInt * div * 2;
            divider := to_nat(XPS1) + 1;
            PERIODX <= PeriodInt * div * 2 * divider;
            divider := to_nat(RPS1) + 1;
            PERIODR <= PeriodInt * div * 2 * divider;
            div := to_nat(DIV3) + 1;
            PERIODSYS3 <= PeriodInt * div;
        ELSE
            PERIODOUT3 <= PeriodInt * 8;
            PERIODSYS1 <= PeriodInt * 8;
            PERIODSYS2 <= PeriodInt * 8;
            PERIODX <= PeriodInt * 8;
            PERIODR <= PeriodInt * 8;
            PERIODSYS3 <= PeriodInt * 8;
        END IF;
    ELSE
        PERIODOUT3 <= 0 ns;
        PERIOD <= 0 ns;
        PERIODSYS1 <= 0 ns;
        PERIODSYS2 <= 0 ns;
        PERIODX <= 0 ns;
        PERIODR <= 0 ns;
        PERIODSYS3 <= 0 ns;
    END IF;

    END PROCESS PLL;

    CLKOUTP3 : PROCESS

    BEGIN
        IF PERIODOUT3 /= 0 ns THEN
            WAIT FOR PERIODOUT3;
            clk3 <= not(clk3);
            WAIT FOR PERIODOUT3;
            clk3 <= not(clk3);
        ELSE
            clk3 <= '1';
            WAIT;
        END IF;
    END PROCESS CLKOUTP3;

    SYSOUT3 : PROCESS

    BEGIN
        IF PERIODSYS3 /= 0 ns THEN
            WAIT FOR PERIODSYS3;
            SYSCLK3 <= not(SYSCLK3);
            WAIT FOR PERIODSYS3;
            SYSCLK3 <= not(SYSCLK3);
        ELSE
            SYSCLK3 <= '1';
            WAIT;
        END IF;
    END PROCESS SYSOUT3;

    SYSOUT1 : PROCESS

   BEGIN
       IF PERIODSYS1 /= 0 ns THEN
           WAIT FOR PERIODSYS1;
           CPUclk <= not(CPUclk);
           WAIT FOR PERIODSYS1;
           CPUclk <= not(CPUclk);
       ELSE
           CPUclk <= '1';
           WAIT;
       END IF;
   END PROCESS SYSOUT1;

    SYSOUT2 : PROCESS

    BEGIN
        IF PERIODSYS2 /= 0 ns THEN
            WAIT FOR PERIODSYS2;
            CPUclk2 <= not(CPUclk2);
            WAIT FOR PERIODSYS2;
            CPUclk2 <= not(CPUclk2);
        ELSE
            CPUclk2 <= '1';
            WAIT;
        END IF;
    END PROCESS SYSOUT2;

    SYSOUTR : PROCESS

    BEGIN
        IF PERIODR /= 0 ns THEN
            WAIT FOR PERIODR;
            SYSCLK2R <= not(SYSCLK2R);
            WAIT FOR PERIODR;
            SYSCLK2R <= not(SYSCLK2R);
        ELSE
            SYSCLK2R <= '1';
            WAIT;
        END IF;
    END PROCESS SYSOUTR;

    SYSOUTX : PROCESS

    BEGIN
        IF PERIODX /= 0 ns THEN
            WAIT FOR PERIODX;
            SYSCLK2X <= not(SYSCLK2X);
            WAIT FOR PERIODX;
            SYSCLK2X <= not(SYSCLK2X);
        ELSE
            SYSCLK2X <= '1';
            WAIT;
        END IF;
    END PROCESS SYSOUTX;

    DIVX : PROCESS

    BEGIN
        IF Period /= 0 ns THEN
            WAIT FOR PeriodAUX;
            AUXDIVX <= not(AUXDIVX);
            WAIT FOR PeriodAUX;
            AUXDIVX <= not(AUXDIVX);
        ELSE
            AUXDIVX <= '1';
            WAIT;
        END IF;
    END PROCESS DIVX;

    DIVR : PROCESS

    BEGIN
        IF Period /= 0 ns THEN
            WAIT FOR PeriodAUXR;
            AUXDIVR <= not(AUXDIVR);
            WAIT FOR PeriodAUXR;
            AUXDIVR <= not(AUXDIVR);
        ELSE
            AUXDIVR <= '1';
            WAIT;
        END IF;
    END PROCESS DIVR;

    XDIV : PROCESS
        VARIABLE SynchCLK : BOOLEAN := FALSE;
    BEGIN
        IF PERIOD /= 0 ns THEN
            IF NOT SynchCLK THEN
                XCLKDIV <= not(XCLKDIV);
            ELSE
                XCLKDIV <= AHCLKXTmp;
                SynchCLK := FALSE;
            END IF;
            WAIT UNTIL PeriodDiv'EVENT FOR PeriodDiv;
            IF PeriodDiv'Event THEN
                SynchCLK := TRUE;
            END IF;
        ELSE
            XCLKDIV <= '1';
            WAIT;
        END IF;
    END PROCESS XDIV;

    RDIV : PROCESS
        VARIABLE SynchCLK : BOOLEAN := FALSE;
    BEGIN
        IF PERIOD /= 0 ns THEN
            IF NOT SynchCLK THEN
                RCLKDIV <= not(RCLKDIV);
            ELSE
                RCLKDIV <= AHCLKRTmp;
                SynchCLK := FALSE;
            END IF;
            WAIT UNTIL PeriodDivR'EVENT FOR PeriodDivR;
            IF PeriodDivR'Event THEN
                SynchCLK := TRUE;
            END IF;
        ELSE
            RCLKDIV <= '1';
            WAIT;
        END IF;
    END PROCESS RDIV;

    CLKOUTPUT : PROCESS(clk3, CLKIN, RESETNeg)

    VARIABLE reset_cnt    : NATURAL RANGE 0 to 511;
    -- Functionality Results Variables
    VARIABLE CLKOUT2_zd   : std_ulogic;
    VARIABLE CLKOUT3_zd   : std_ulogic;

    -- Output Glitch Detection Variables
    VARIABLE CLKOUT2_GlitchData   : VitalGlitchDataType;
    VARIABLE CLKOUT3_GlitchData   : VitalGlitchDataType;

    -- Timing Check Variables

    VARIABLE PD_RESETNeg    : VitalPeriodDataType := VitalPeriodDataInit;
    VARIABLE Pviol_RESETNeg : X01 := '0';

    VARIABLE Violation      : X01 := '0';

    BEGIN
    ----------------------------------------------------------------------------
    -- Timing Check Section
    ----------------------------------------------------------------------------

    IF  (TimingChecksOn) THEN

        VitalPeriodPulseCheck (
          TestSignal      =>  RESETNeg,
          TestSignalName  =>  "RESETNeg",
          PulseWidthLow   =>  tpw_RESETNeg_negedge,
          PeriodData      =>  PD_RESETNeg,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Pviol_RESETNeg,
          HeaderMsg       =>  InstancePath & PartID,
          CheckEnabled    =>  TRUE );

        Violation := Pviol_RESETNeg;

    END IF;

    ----------------------------------------------------------------------------
    -- Functionality section
    ----------------------------------------------------------------------------

        IF RESETNeg = '1' THEN
            IF CLK2EN = '1' AND DIV2EN = '1' AND (PLLEN = '0' OR
               (PLLEN = '1' AND DIV0EN = '1')) THEN
                CLKOUT2_zd := CPUclk2;
            ELSE
                CLKOUT2_zd := '1';
            END IF;
            IF ODIV1EN = '1' THEN
                CLKOUT3_zd := clk3;
            ELSE
                CLKOUT3_zd := '1';
            END IF;
        END IF;

        IF RESETNeg = '0' THEN
            reset_cnt := 511;
            RESET_int <= '0';
        ELSIF rising_edge(CLKIN) AND RESETNeg = '1' AND reset_cnt > 0 THEN
            reset_cnt := reset_cnt - 1;
            IF reset_cnt = 0 THEN
                RESET_int <= '1';
            END IF;
        END IF;

        ------------------------------------------------------------------------
        -- Path Delay Section
        ------------------------------------------------------------------------

        VitalPathDelay01 (
            OutSignal       => CLKOUT2Out,
            OutSignalName   => "CLKOUT2",
            OutTemp         => CLKOUT2_zd,
            GlitchData      => CLKOUT2_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => CPUclk2'LAST_EVENT,
                      PathDelay         => tpd_CLKIN_CLKOUT2,
                      PathCondition     => TRUE)
            )
        );

        VitalPathDelay01 (
            OutSignal       => CLKOUT3,
            OutSignalName   => "CLKOUT3",
            OutTemp         => CLKOUT3_zd,
            GlitchData      => CLKOUT3_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => clk3'LAST_EVENT,
                      PathDelay         => tpd_CLKIN_CLKOUT3,
                      PathCondition     => TRUE)
            )
        );

    END PROCESS CLKOUTPUT;

    ECLK : PROCESS(ECLKIN, SYSCLK3)

    VARIABLE Previous     : Time := 0 ns;

    -- Timing Check Variables
    VARIABLE PD_ECLKIN       : VitalPeriodDataType := VitalPeriodDataInit;
    VARIABLE Pviol_ECLKIN    : X01 := '0';

    VARIABLE Violation       : X01 := '0';

    -- Functionality Results Variables
    VARIABLE ECLKOUT_zd   : std_ulogic;

    -- Output Glitch Detection Variables
    VARIABLE ECLKOUT_GlitchData   : VitalGlitchDataType;

    BEGIN

    ----------------------------------------------------------------------------
    -- Timing Check Section                                                   --
    ----------------------------------------------------------------------------

    IF  (TimingChecksOn) THEN

        VitalPeriodPulseCheck (
          TestSignal      =>  ECLKIN,
          TestSignalName  =>  "ECLKIN",
          Period          =>  tperiod_ECLKIN_posedge,
          PulseWidthLow   =>  tpw_ECLKIN_negedge,
          PulseWidthHigh  =>  tpw_ECLKIN_posedge,
          PeriodData      =>  PD_ECLKIN,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Pviol_ECLKIN,
          HeaderMsg       =>  InstancePath & PartID,
          CheckEnabled    =>  TRUE );

        Violation := Pviol_ECLKIN;
    END IF;

    IF rising_edge(ECLKIN) AND RESETNeg = '0' THEN
        EPERIOD <= NOW - Previous;
        Previous := NOW;
    END IF;

    IF EKEN = '1' THEN
        IF EKSRC = '1' THEN
            ECLKOUT_zd := ECLKIN;
        ELSE
            ECLKOUT_zd := SYSCLK3;
        END IF;
    ELSE
        ECLKOUT_zd := '0';
    END IF;

    ------------------------------------------------------------------------
    -- Path Delay Section
    ------------------------------------------------------------------------
        VitalPathDelay01 (
            OutSignal       => ECLK_int,
            OutSignalName   => "ECLKOUT",
            OutTemp         => ECLKOUT_zd,
            GlitchData      => ECLKOUT_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLKIN'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_ECLKOUT,
                      PathCondition     => TRUE)
            )
        );

    END PROCESS ECLK;

    ----------------------------------------------------------------------------
    -- EMIF
    ----------------------------------------------------------------------------

    EMIF : PROCESS(ECLK_int, ARDY, EDIn, HOLDNeg, RESET_int, DMARDY, SDRMinit,
                   SDCASNeg_int)

    TYPE init_state_type IS (inactive, dcab, refresh, mrs);
    TYPE mem_type IS (sync, async);
    TYPE busy_type IS ARRAY(3 downto 0) OF BOOLEAN;
    TYPE sdram_cmd_type IS (none, actv, deac, read, wrt);
    TYPE sdram_state IS (inactive, activating, active, deactivating, writing,
             reading);
    TYPE opbank_type IS
        RECORD
            CE    : memoryspace;
            BADDR : INTEGER;
            BNK   : NATURAL RANGE 0 TO 3;
            DIR   : r_w;
            STATE : sdram_state;
            PEND  : BOOLEAN;
        END RECORD;
    TYPE opbank_array IS ARRAY(3 downto 0) OF opbank_type;

    -- Registers
    VARIABLE sdram_ctl     : Reg32;
    VARIABLE sdram_timg    : Reg32;

    VARIABLE opbanks       : opbank_array;
    VARIABLE sdram_cmd     : sdram_cmd_type;
    VARIABLE cur_mem       : mem_type;
    VARIABLE sdram_acc     : BOOLEAN := false;
    VARIABLE reset_cnt     : NATURAL RANGE 0 to 3;
    VARIABLE romboot       : BOOLEAN;
    VARIABLE init_sdram    : BOOLEAN;
    VARIABLE refr_sdram    : BOOLEAN := false;
    VARIABLE init_state    : init_state_type;
    VARIABLE bank          : NATURAL RANGE 0 to 3;
    VARIABLE row           : NATURAL;
    VARIABLE burst_len     : NATURAL RANGE 0 to 4;
    VARIABLE strob_xtnd    : BOOLEAN := false;
    VARIABLE strob_delayed : BOOLEAN := false;
    VARIABLE sbsramclk     : NATURAL RANGE 0 to 6;

    -- Timing Check Variables
    VARIABLE Tviol_ARDY_ECLKOUT : X01 := '0';
    VARIABLE TD_ARDY_ECLKOUT    : VitalTimingDataType;

    VARIABLE PD_ARDY         : VitalPeriodDataType := VitalPeriodDataInit;
    VARIABLE Pviol_ARDY      : X01 := '0';

    VARIABLE Tviol_ED0_ECLKOUT   : X01 := '0';
    VARIABLE TD_ED0_ECLKOUT      : VitalTimingDataType;

    VARIABLE Tviol_ED0_SDCASNeg  : X01 := '0';
    VARIABLE TD_ED0_SDCASNeg     : VitalTimingDataType;

    VARIABLE Violation          : X01 := '0';

    VARIABLE EA_int        : std_logic_vector(21 downto 2);
    VARIABLE cur_mtype     : std_logic_vector(3 downto 0);
    VARIABLE byte_cnt      : NATURAL RANGE 0 TO 3 := 0;
    VARIABLE max_byte_cnt  : NATURAL RANGE 0 TO 3 := 0;
    VARIABLE word_cnt      : NATURAL RANGE 0 TO 4 := 0;
    VARIABLE max_word_cnt  : NATURAL RANGE 0 TO 4 := 0;
    VARIABLE wo            : NATURAL RANGE 0 TO 20 := 0;   -- word offset
    VARIABLE TA_time       : NATURAL RANGE 0 TO 4 := 0;
    VARIABLE cur_TA        : NATURAL RANGE 0 TO 4 := 0;    -- TA in current CE
    VARIABLE hold_time     : INTEGER RANGE -1 TO 8 := 0;
    VARIABLE cur_hold      : NATURAL RANGE 0 TO 4 := 0;    -- hold in cur CE
    VARIABLE clk_cnt       : NATURAL RANGE 0 TO 16 := 0;
    VARIABLE ref_cnt       : NATURAL RANGE 0 TO 8 := 0;
    VARIABLE setup_time    : NATURAL RANGE 0 TO 16 := 0;
    VARIABLE cur_setup     : NATURAL RANGE 0 TO 16 := 0;  -- setup in cur CE
    VARIABLE strobe_time   : NATURAL RANGE 0 TO 64 := 0;
    VARIABLE cur_strobe    : NATURAL RANGE 0 TO 64 := 0;  -- strobe in cur CE
    VARIABLE addr_int      : NATURAL;
    VARIABLE counter       : NATURAL := 1500;
    VARIABLE rperiod       : NATURAL;
    VARIABLE bootfini      : BOOLEAN;
    VARIABLE ce0sdram      : BOOLEAN;
    VARIABLE ce1sdram      : BOOLEAN;
    VARIABLE ce2sdram      : BOOLEAN;
    VARIABLE ce3sdram      : BOOLEAN;
    VARIABLE hold          : BOOLEAN := false;
    VARIABLE sdrm_prsnt    : BOOLEAN;
    VARIABLE sdram_deact   : BOOLEAN;
    VARIABLE refresh_started : BOOLEAN;
    VARIABLE ce_busy       : busy_type;

    -- Functionality Results Variables
    VARIABLE BE3Neg_zd     : std_ulogic;
    VARIABLE BE2Neg_zd     : std_ulogic;
    VARIABLE BE1Neg_zd     : std_ulogic;
    VARIABLE BE0Neg_zd     : std_ulogic;
    VARIABLE SDCASNeg_zd   : std_ulogic;
    VARIABLE SDRASNeg_zd   : std_ulogic;
    VARIABLE SDWENeg_zd    : std_ulogic;
    VARIABLE HOLDANeg_zd   : std_ulogic;
    VARIABLE BUSREQ_zd     : std_ulogic;
    VARIABLE CE_zd         : std_ulogic_vector(3 downto 0);

    -- Output Glitch Detection Variables
    VARIABLE BE3Neg_GlitchData   : VitalGlitchDataType;
    VARIABLE BE2Neg_GlitchData   : VitalGlitchDataType;
    VARIABLE BE1Neg_GlitchData   : VitalGlitchDataType;
    VARIABLE BE0Neg_GlitchData   : VitalGlitchDataType;
    VARIABLE CE3Neg_GlitchData   : VitalGlitchDataType;
    VARIABLE CE2Neg_GlitchData   : VitalGlitchDataType;
    VARIABLE CE1Neg_GlitchData   : VitalGlitchDataType;
    VARIABLE CE0Neg_GlitchData   : VitalGlitchDataType;
    VARIABLE SDCASNeg_GlitchData : VitalGlitchDataType;
    VARIABLE SDRASNeg_GlitchData : VitalGlitchDataType;
    VARIABLE SDWENeg_GlitchData  : VitalGlitchDataType;
    VARIABLE HOLDANeg_GlitchData : VitalGlitchDataType;
    VARIABLE BUSREQ_GlitchData   : VitalGlitchDataType;

    PROCEDURE openbank (VARIABLE row  : NATURAL;
                       VARIABLE bank  : NATURAL;
                       SIGNAL acc_dir : r_w;
                       SIGNAL MSpace  : memoryspace)
    IS

    VARIABLE already_open : boolean;

    BEGIN
        already_open := false;
        FOR i IN 0 TO 3 LOOP            -- is bank already open?
            IF opbanks(i).STATE /= inactive THEN
                IF opbanks(i).CE = MSpace THEN
                    IF opbanks(i).BNK = bank THEN
                        IF opbanks(i).BADDR = row THEN
                            already_open := true;
                            opbanks(i).PEND := true;
                            opbanks(i).DIR := acc_dir;
                            IF opbanks(i).STATE = active THEN
                                IF opbanks(i).DIR = read THEN
                                    opbanks(i).STATE := reading;
                                ELSE
                                    opbanks(i).STATE := writing;
                                END IF;
                            END IF;
                            exit;
                        ELSE
                            opbanks(i).STATE := deactivating;
                            opbanks(i).PEND := true;
                            already_open := true;
                            exit;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END LOOP;

        IF not already_open THEN
            FOR i IN 0 TO 3 LOOP
                IF opbanks(i).STATE = inactive THEN
                    sdram_cmd := actv;
                    already_open := true;
                    opbanks(i).BADDR := row;
                    opbanks(i).DIR := acc_dir;
                    opbanks(i).PEND := true;
                    opbanks(i).STATE := activating;
                    opbanks(i).CE := MSpace;
                    exit;
                END IF;
            END LOOP;
        END IF;
    END openbank;

    BEGIN

    ----------------------------------------------------------------------------
    -- Timing Check Section
    ----------------------------------------------------------------------------

    IF  (TimingChecksOn) THEN

        VitalSetupHoldCheck (
          TestSignal      =>  ARDY,
          TestSignalName  => "ARDY",
          RefSignal       =>  ECLK_int,
          RefSignalName   =>  "ECLK_int",
          SetupHigh       =>  tsetup_ARDY_ECLKOUT,
          SetupLow        =>  tsetup_ARDY_ECLKOUT,
          HoldHigh        =>  thold_ARDY_ECLKOUT,
          HoldLow         =>  thold_ARDY_ECLKOUT,
          CheckEnabled    =>  TRUE,
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_ARDY_ECLKOUT,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_ARDY_ECLKOUT );

        VitalSetupHoldCheck (
          TestSignal      =>  EDIn,
          TestSignalName  => "ED",
          RefSignal       =>  ECLK_int,
          RefSignalName   =>  "ECLK_int",
          SetupHigh       =>  tsetup_ED0_ECLKOUT,
          SetupLow        =>  tsetup_ED0_ECLKOUT,
          HoldHigh        =>  thold_ED0_ECLKOUT,
          HoldLow         =>  thold_ED0_ECLKOUT,
          CheckEnabled    =>  cur_mem = sync,
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_ED0_ECLKOUT,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_ED0_ECLKOUT );

        VitalSetupHoldCheck (
          TestSignal      =>  EDIn,
          TestSignalName  => "ED",
          RefSignal       =>  SDCASNeg_int,
          RefSignalName   =>  "SDCASNeg",
          SetupHigh       =>  tsetup_ED0_SDCASNeg,
          SetupLow        =>  tsetup_ED0_SDCASNeg,
          HoldHigh        =>  thold_ED0_SDCASNeg,
          HoldLow         =>  thold_ED0_SDCASNeg,
          CheckEnabled    =>  cur_mem = async,
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_ED0_SDCASNeg,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_ED0_SDCASNeg );

        VitalPeriodPulseCheck (
          TestSignal      =>  ARDY,
          TestSignalName  =>  "ARDY",
          PulseWidthHigh  =>  EPERIOD,
          PeriodData      =>  PD_ARDY,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Pviol_ARDY,
          HeaderMsg       =>  InstancePath & PartID,
          CheckEnabled    =>  TRUE );

        Violation := Tviol_ARDY_ECLKOUT OR Tviol_ED0_ECLKOUT OR Pviol_ARDY OR
                     Tviol_ED0_SDCASNeg;
    END IF;

    ----------------------------------------------------------------------------
    -- Functionality section                                                  --
    ----------------------------------------------------------------------------

    IF HOLDNeg'event AND NOHOLD = '0' THEN
        CASE HOLDbit IS
            WHEN '0' =>
                IF HOLDNeg = '0' THEN
                    hold := true;
                ELSE
                    hold := false;
                END IF;
            WHEN '1' =>
                IF HOLDNeg = '1' THEN
                    hold := true;
                ELSE
                    hold := false;
                END IF;
            WHEN others =>   -- error
                null;
        END CASE;
    END IF;

    IF RESETNeg = '0' THEN
        EA_zd <= (others => 'Z');
        EDOut_zd <= (others => 'Z');
        BE3Neg_zd := 'Z';
        BE2Neg_zd := 'Z';
        BE1Neg_zd := 'Z';
        BE0Neg_zd := 'Z';
        CE_zd     := "ZZZZ";
        SDCASNeg_zd := 'Z';
        SDRASNeg_zd := 'Z';
        SDWENeg_zd := 'Z';
        HOLDANeg_zd := '1';
        BUSREQ_zd := '0';
    END IF;

    IF rising_edge(RESET_int) THEN
        BE3Neg_zd := 'H';
        BE2Neg_zd := 'H';
        BE1Neg_zd := 'H';
        BE0Neg_zd := 'H';
        CE_zd     := "HHHH";
        SDCASNeg_zd := 'H';
        SDRASNeg_zd := 'H';
        SDWENeg_zd := 'H';
    END IF;

    IF rising_edge(RESET_int) THEN
        CASE BootReg IS
            WHEN "00" =>    -- HPI
                romboot := false;
            WHEN "01" =>    -- 8-bit ROM
                romboot := true;
                max_byte_cnt := 3;
            WHEN "10" =>    -- 16-bit ROM
                romboot := true;
                max_byte_cnt := 1;
            WHEN "11" =>    -- 32-bit ROM
                romboot := true;
                max_byte_cnt := 0;
            WHEN others =>    -- error
                null;
        END CASE;
    END IF;

    IF rising_edge(DMARDY) AND not BootDone THEN
        IF romboot THEN
            cur_mtype := CE1mtype;
            cur_mem := async;
            cur_TA := to_nat(CE1CTL(0)(15 downto 14));
            cur_strobe := to_nat(CE1CTL(0)(13 downto 8));
            cur_hold := to_nat(CE1CTL(0)(2 downto 0));
            cur_setup := to_nat(CE1CTL(1)(3 downto 0));
            EMRDY <= '0';
            EMDVALID <= '0';
            CASE cur_mtype IS
                WHEN "0000" =>      -- 8-bit ROM
                    IF EADDR > 255 THEN
                        Bootfini := true;
                    ELSE
                        addr_int := EADDR * 4;
                        Bootfini := false;
                    END IF;
                WHEN "0001" =>      -- 16-bit ROM
                    IF EADDR > 255 THEN
                        Bootfini := true;
                    ELSE
                        addr_int := EADDR * 2;
                        Bootfini := false;
                    END IF;
                WHEN "0010" =>      -- 32-bit ROM
                    IF EADDR > 255 THEN
                        Bootfini := true;
                    ELSE
                        addr_int := EADDR;
                        Bootfini := false;
                    END IF;
                WHEN others =>    -- error
                    null;
            END CASE;
            EA_int := to_slv(addr_int,20);
            IF EADDR = 0 THEN
                EA_zd <= EA_int;
            END IF;
            TA_time := 0;
            hold_time := 0;
            setup_time := 0;
            strobe_time := 0;
            BootDone <= Bootfini;
            EMRDY <= '1';
        ELSE
            BootDone <= true;
        END IF;
    END IF;

    IF rising_edge(DMARDY) AND BootDone THEN
        CASE MSpace IS
            WHEN CE0 =>
                cur_mtype := CE0mtype;
                IF cur_mtype = "0000" OR cur_mtype = "0001" OR
                        cur_mtype = "0010" OR cur_mtype = "0011" THEN
                    cur_TA := to_nat(CE0CTL(0)(15 downto 14));
                    cur_mem := async;
                    IF EMdir = read THEN
                        cur_strobe := to_nat(CE0CTL(0)(13 downto 8));
                        cur_hold := to_nat(CE0CTL(0)(2 downto 0));
                        cur_setup := to_nat(CE0CTL(1)(3 downto 0));
                    ELSE
                        cur_strobe := to_nat(CE0CTL(1)(11 downto 6));
                        cur_hold := to_nat(CE0CTL(1)(5 downto 4));
                        cur_setup := to_nat(CE0CTL(1)(15 downto 12));
                    END IF;
                END IF;
            WHEN CE1 =>
                cur_mtype := CE1mtype;
                IF cur_mtype = "0000" OR cur_mtype = "0001" OR
                        cur_mtype = "0010" OR cur_mtype = "0011" THEN
                    cur_TA := to_nat(CE1CTL(0)(15 downto 14));
                    cur_mem := async;
                    IF EMdir = read THEN
                        cur_strobe := to_nat(CE1CTL(0)(13 downto 8));
                        cur_hold := to_nat(CE1CTL(0)(2 downto 0));
                        cur_setup := to_nat(CE1CTL(1)(3 downto 0));
                    ELSE
                        cur_strobe := to_nat(CE1CTL(1)(11 downto 6));
                        cur_hold := to_nat(CE1CTL(1)(5 downto 4));
                        cur_setup := to_nat(CE1CTL(1)(15 downto 12));
                    END IF;
                END IF;
            WHEN CE2 =>
                cur_mtype := CE2mtype;
                IF cur_mtype = "0000" OR cur_mtype = "0001" OR
                        cur_mtype = "0010" OR cur_mtype = "0011" THEN
                    cur_TA := to_nat(CE2CTL(0)(15 downto 14));
                    cur_mem := async;
                    IF EMdir = read THEN
                        cur_strobe := to_nat(CE2CTL(0)(13 downto 8));
                        cur_hold := to_nat(CE2CTL(0)(2 downto 0));
                        cur_setup := to_nat(CE2CTL(1)(3 downto 0));
                    ELSE
                        cur_strobe := to_nat(CE2CTL(1)(11 downto 6));
                        cur_hold := to_nat(CE2CTL(1)(5 downto 4));
                        cur_setup := to_nat(CE2CTL(1)(15 downto 12));
                    END IF;
                END IF;
            WHEN CE3 =>
                cur_mtype := CE3mtype;
                IF cur_mtype = "0000" OR cur_mtype = "0001" OR
                        cur_mtype = "0010" OR cur_mtype = "0011" THEN
                    cur_TA := to_nat(CE3CTL(0)(15 downto 14));
                    cur_mem := async;
                    IF EMdir = read THEN
                        cur_strobe := to_nat(CE3CTL(0)(13 downto 8));
                        cur_hold := to_nat(CE3CTL(0)(2 downto 0));
                        cur_setup := to_nat(CE3CTL(1)(3 downto 0));
                    ELSE
                        cur_strobe := to_nat(CE3CTL(1)(11 downto 6));
                        cur_hold := to_nat(CE3CTL(1)(5 downto 4));
                        cur_setup := to_nat(CE3CTL(1)(15 downto 12));
                    END IF;
                END IF;
        END CASE;
        addr_int := EADDR;
        IF cur_mtype = "0000" OR cur_mtype = "1000" THEN  -- 8-bit
            EA_int := to_slv(addr_int,20);
        ELSIF cur_mtype = "0001" OR cur_mtype = "1001" OR
               cur_mtype = "1011" THEN                    -- 16-bit
            EA_int := to_slv(addr_int/2,20);
        ELSE                                              -- 32-bit
            EA_int := to_slv(addr_int/4,20);
        END IF;
        max_word_cnt := Burst_Size;
        EMRDY <= '0';
        EMDVALID <= '0';
    END IF;

    IF rising_edge(ECLK_int) AND RESET_int = '1' AND DMARDY = '1' AND
                   not BootDone THEN
        IF EMdir = read THEN
            IF TA_time = 0 THEN
                CASE cur_mtype IS
                    WHEN "0000" =>      -- 8-bit ROM
                        CE_zd(0) := '0';
                    WHEN "0001" =>      -- 16-bit ROM
                        CE_zd(2) := '0';
                    WHEN "0010" =>      -- 32-bit ROM
                        CE_zd(3) := '0';
                    WHEN others =>    -- error
                        null;
                END CASE;
                EA_zd <= EA_int;
                SDRASNeg_zd := '0';
                EDOut_zd <= (others => 'Z');
            END IF;

            IF hold_time = cur_hold THEN
                SDRASNeg_zd := '1';
                CASE cur_mtype IS
                    WHEN "0000" =>      -- 8-bit ROM
                        CE_zd(0) := '1';
                    WHEN "0001" =>      -- 16-bit ROM
                        CE_zd(2) := '1';
                    WHEN "0010" =>      -- 32-bit ROM
                        CE_zd(3) := '1';
                    WHEN others =>    -- error
                        null;
                END CASE;
            END IF;

            IF strobe_time = cur_strobe THEN
                SDCASNeg_zd := '1';
                IF cur_mtype = "0000" THEN
                    EDATA(byte_cnt) <= to_nat(EDIn(7 downto 0));
                ELSIF cur_mtype = "0001" THEN
                    EDATA(byte_cnt*2) <= to_nat(EDIn(7 downto 0));
                    EDATA(byte_cnt*2 + 1) <= to_nat(EDIn(15 downto 7));
                ELSIF cur_mtype = "0010" THEN
                    EDATA(3) <= to_nat(EDIn(31 downto 24));
                    EDATA(2) <= to_nat(EDIn(23 downto 16));
                    EDATA(1) <= to_nat(EDIn(15 downto 8));
                    EDATA(0) <= to_nat(EDIn(7 downto 0));
                END IF;
            ELSIF setup_time = cur_setup THEN
                SDCASNeg_zd := '0';
            END IF;

            IF setup_time <= cur_setup THEN
                setup_time := setup_time + 1;
            ELSIF strobe_time <= cur_strobe THEN
                strobe_time := strobe_time + 1;
            ELSIF hold_time < cur_hold THEN
                hold_time := hold_time + 1;
            ELSIF TA_time <= cur_TA THEN
                TA_time := TA_time + 1;
            END IF;

            IF TA_time = cur_TA THEN
                TA_time := 0;
                hold_time := 0;
                setup_time := 0;
                strobe_time := 0;
                IF byte_cnt = max_byte_cnt THEN
                    EMRDY <= '1';
                    EMDVALID <= '1';
                    byte_cnt := 0;
                ELSE
                    byte_cnt := byte_cnt + 1;
                    EA_int := to_slv(addr_int + byte_cnt,20);
                END IF;
            END IF;
        END IF;
    END IF;

    IF rising_edge(SDRMinit) THEN
        IF (CE0MTYPE = "0011") OR (CE0MTYPE = "1000") OR
           (CE0MTYPE = "1001") THEN
            ce0sdram := true;
        END IF;
        IF (CE1MTYPE = "0011") OR (CE1MTYPE = "1000") OR
           (CE1MTYPE = "1001") THEN
            ce1sdram := true;
        END IF;
        IF (CE2MTYPE = "0011") OR (CE2MTYPE = "1000") OR
           (CE2MTYPE = "1001") THEN
            ce2sdram := true;
        END IF;
        IF (CE3MTYPE = "0011") OR (CE3MTYPE = "1000") OR
           (CE3MTYPE = "1001") THEN
            ce3sdram := true;
        END IF;
        IF ce0sdram OR ce1sdram OR ce2sdram OR ce3sdram THEN
            init_sdram := true;
            init_state := dcab;
            sdrm_prsnt := true;
        ELSE
            init_sdram := false;
            SDRMinit_tmp <= '0';
        END IF;
    END IF;

    -- SDRAM init state machine
    IF rising_edge(ECLK_int) AND init_sdram AND not HOLD THEN
        IF (init_state /= inactive) OR not ((ce_busy(0) OR ce_busy(1) OR
                ce_busy(2) OR ce_busy(3))) THEN
            CASE init_state IS
                WHEN dcab =>
                    IF clk_cnt = 0 THEN
                        IF ce0sdram THEN
                            CE_zd(0) := '0';
                            ce_busy(0) := true;
                        END IF;
                        IF ce1sdram THEN
                            CE_zd(1) := '0';
                            ce_busy(1) := true;
                        END IF;
                        IF ce2sdram THEN
                            CE_zd(2) := '0';
                            ce_busy(2) := true;
                        END IF;
                        IF ce3sdram THEN
                            CE_zd(3) := '0';
                            ce_busy(3) := true;
                        END IF;
                        SDRASNeg_zd := '0';
                        SDWENeg_zd := '0';
                        EA_zd <= "00000001000000000000";
                        EA_zd(12) <= '1';
                        clk_cnt := 1;
                        EMRDY <= '0';
                    ELSE
                        CE_zd := "1111";
                        SDRASNeg_zd := '1';
                        SDWENeg_zd := '1';
                        EA_zd <= (others => 'X');
                        clk_cnt := 0;
                        init_state := refresh;
                    END IF;
                WHEN refresh =>
                    IF clk_cnt = 0 THEN
                        IF ce0sdram THEN
                            CE_zd(0) := '0';
                        END IF;
                        IF ce1sdram THEN
                            CE_zd(1) := '0';
                        END IF;
                        IF ce2sdram THEN
                            CE_zd(2) := '0';
                        END IF;
                        IF ce3sdram THEN
                            CE_zd(3) := '0';
                        END IF;
                        SDRASNeg_zd := '0';
                        SDCASNeg_zd := '0';
                        EA_zd <= "00000000000000000000";
                        clk_cnt := 1;
                    ELSIF clk_cnt < TRCval THEN
                        CE_zd := "1111";
                        SDRASNeg_zd := '1';
                        SDCASNeg_zd := '1';
                        EA_zd <= (others => 'X');
                        clk_cnt := clk_cnt + 1;
                    ELSE
                        clk_cnt := 0;
                        ref_cnt := ref_cnt + 1;
                    END IF;
                    IF ref_cnt > 7 THEN
                        init_state := mrs;
                        ref_cnt := 0;
                    END IF;
                WHEN mrs =>
                    IF clk_cnt = 0 THEN
                        IF ce0sdram THEN
                            CE_zd(0) := '0';
                        END IF;
                        IF ce1sdram THEN
                            CE_zd(1) := '0';
                        END IF;
                        IF ce2sdram THEN
                            CE_zd(2) := '0';
                        END IF;
                        IF ce3sdram THEN
                            CE_zd(3) := '0';
                        END IF;
                        IF TCL = '1' THEN
                            EA_zd <= "00000000000000110010";
                        ELSE
                            EA_zd <= "00000000000000100010";
                        END IF;
                        SDRASNeg_zd := '0';
                        SDCASNeg_zd := '0';
                        SDWENeg_zd := '0';
                        clk_cnt := 1;
                    ELSIF clk_cnt = 1 THEN
                        CE_zd := "1111";
                        ce_busy := (others => false);
                        SDRASNeg_zd := '1';
                        SDCASNeg_zd := '1';
                        SDWENeg_zd := '1';
                        EA_zd <= (others => 'X');
                        clk_cnt := 2;
                    ELSE
                        init_sdram := false;
                        init_state := inactive;
                        EMRDY <= '1';
                        clk_cnt := 0;
                   END IF;
                WHEN inactive =>   -- should never get here
                    null;
            END CASE;
            SDRMinit_tmp <= '0';
            rperiod := to_nat(REFPER);
        END IF;
    END IF;

    -- refresh counter
    IF rising_edge(ECLK_int) AND RESETNeg = '1' THEN
        IF counter = 0 THEN
            counter0 <= true;
            counter := rperiod;
            IF RFEN = '1' THEN
                refr_sdram := true;
            END IF;
        ELSE
            counter := counter - 1;
            counter0 <= false;
        END IF;
        IF refr_sdram AND sdrm_prsnt AND not init_sdram  THEN
            IF not ((ce_busy(0) OR ce_busy(1) OR ce_busy(2) OR ce_busy(3))) OR
             refresh_started THEN
                IF sdram_deact THEN
                    IF clk_cnt = 0 THEN
                        IF ce0sdram THEN
                            CE_zd(0) := '0';
                        END IF;
                        IF ce1sdram THEN
                            CE_zd(1) := '0';
                        END IF;
                        IF ce2sdram THEN
                            CE_zd(2) := '0';
                        END IF;
                        IF ce3sdram THEN
                            CE_zd(3) := '0';
                        END IF;
                        SDRASNeg_zd := '0';
                        SDCASNeg_zd := '0';
                        EA_zd <= "00000000000000000000";
                        clk_cnt := 1;
                    ELSIF clk_cnt < TRCval THEN
                        CE_zd := "1111";
                        SDRASNeg_zd := '1';
                        SDCASNeg_zd := '1';
                        EA_zd <= (others => 'X');
                        clk_cnt := clk_cnt + 1;
                    ELSE
                        clk_cnt := 0;
                        ref_cnt := ref_cnt + 1;
                    END IF;
                    IF ref_cnt > (to_nat(XRFR) + 1) THEN
                        sdram_deact := false;
                        refr_sdram := false;
                        ce_busy := (false, false, false, false);
                        refresh_started := false;
                        ref_cnt := 0;
                        EMRDY <= '1';
                    END IF;
                ELSE
                    IF clk_cnt = 0 THEN
                        IF ce0sdram THEN
                            ce_busy(0) := true;
                            refresh_started := true;
                            EMRDY <= '0';
                            EMDVALID <= '0';
                            CE_zd(0) := '0';
                        END IF;
                        IF ce1sdram THEN
                            ce_busy(1) := true;
                            refresh_started := true;
                            EMRDY <= '0';
                            EMDVALID <= '0';
                            CE_zd(1) := '0';
                        END IF;
                        IF ce2sdram THEN
                            ce_busy(2) := true;
                            refresh_started := true;
                            EMRDY <= '0';
                            EMDVALID <= '0';
                            CE_zd(2) := '0';
                        END IF;
                        IF ce3sdram THEN
                            ce_busy(3) := true;
                            refresh_started := true;
                            EMRDY <= '0';
                            EMDVALID <= '0';
                            CE_zd(3) := '0';
                        END IF;
                        SDRASNeg_zd := '0';
                        SDWENeg_zd := '0';
                        EA_zd <= "00000001000000000000";
                        EA_zd(12) <= '1';
                        clk_cnt := 1;
                    ELSE
                        CE_zd := "1111";
                        SDRASNeg_zd := '1';
                        SDWENeg_zd := '1';
                        EA_zd <= (others => 'X');
                        clk_cnt := 0;
                        sdram_deact := true;
                        FOR i IN 0 TO 3 LOOP       -- set all banks to inactive
                            opbanks(i).STATE := inactive;
                        END LOOP;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;

    IF rising_edge(ECLK_int) AND RESET_int = '1' AND DMARDY = '1' AND
                   BootDone AND not refresh_started THEN
        CASE cur_mtype IS
            WHEN "0000" =>   -- 8-bit asynch
                cur_mem := async;
                max_byte_cnt := 3;

                IF strobe_time = cur_strobe AND not strob_xtnd THEN
                    hold_time := hold_time + 1;
                END IF;
                IF setup_time <= cur_setup THEN
                   setup_time := setup_time + 1;
                ELSIF strobe_time <= cur_strobe THEN
                    IF not strob_xtnd THEN
                        strobe_time := strobe_time + 1;
                    END IF;
                ELSIF hold_time <= cur_hold THEN
                    hold_time := hold_time + 1;
                ELSIF TA_time <= cur_TA THEN
                    TA_time := TA_time + 1;
                END IF;

                IF EMdir = read THEN
                    IF TA_time = 0 THEN
                        CE_zd(memoryspace'pos(MSpace)) := '0';
                        ce_busy(memoryspace'pos(MSpace)) := true;
                        EA_zd <= EA_int;
                        SDRASNeg_zd := '0';
                        EDOut_zd <= (others => 'Z');
                    END IF;

                    IF strobe_time = cur_strobe THEN
                        wo := word_cnt * 4;
                        IF ARDY = '1' AND not strob_xtnd THEN
                            SDCASNeg_zd := '1';
                            EDATA(wo + byte_cnt) <= to_nat(EDIn(7 downto 0));
                            strob_xtnd := false;
                            hold_time := 0;
                            strob_xtnd := false;
                        ELSIF ARDY = '1' AND strob_xtnd THEN
                            EDATA(wo + byte_cnt) <= to_nat(EDIn(7 downto 0));
                            strob_xtnd := false;
                            strob_xtnd := false;
                            hold_time := -1;
                        ELSE
                            strob_xtnd := true;
                        END IF;
                    ELSIF (setup_time = cur_setup + 1) AND (hold_time = 0) THEN
                        SDCASNeg_zd := '0';
                    END IF;

                    IF strobe_time >= cur_strobe AND hold_time = cur_hold
                            AND not strob_xtnd THEN
                        wo := word_cnt * 4;
                        EA_int := to_slv(addr_int + wo + byte_cnt,20);
                        IF byte_cnt = max_byte_cnt THEN
                            byte_cnt := 0;
                            word_cnt := word_cnt + 1;
                            hold_time := 0;
                            setup_time := 0;
                            strobe_time := 0;
                            IF word_cnt >= max_word_cnt THEN
                                word_cnt := 0;
                                CE_zd(memoryspace'pos(MSpace)) := '1';
                                ce_busy(memoryspace'pos(MSpace)) := false;
                                EMRDY <= '1';
                                EMDVALID <= '1';
                                SDRASNeg_zd := '1';
                            END IF;
                        ELSE
                            byte_cnt := byte_cnt + 1;
                            EA_int := to_slv(addr_int + wo + byte_cnt,20);
                            EA_zd <= EA_int;
                            setup_time := 1;
                            strobe_time := 0;
                            hold_time := 0;
                        END IF;
                    END IF;

                    IF strobe_time > cur_strobe THEN
                        SDCASNeg_zd := '1';
                    END IF;

                ELSE
                    IF TA_time = 0 THEN
                        wo := word_cnt * 4;
                        CE_zd(memoryspace'pos(MSpace)) := '0';
                        ce_busy(memoryspace'pos(MSpace)) := true;
                        EA_zd <= EA_int;
                        EDOut_zd(7 downto 0)<= to_slv(DMADATA(wo+byte_cnt),8);
                    END IF;

                    IF strobe_time >= cur_strobe THEN
                        IF (ARDY = '1' AND not strob_xtnd) OR
                                strob_delayed THEN
                            SDWENeg_zd := '1';
                            IF hold_time = cur_hold THEN
                                IF byte_cnt = max_byte_cnt THEN
                                    byte_cnt := 0;
                                    word_cnt := word_cnt + 1;
                                    hold_time := 0;
                                    setup_time := 0;
                                    strobe_time := 0;
                                    strob_delayed := false;
                                    IF word_cnt >= max_word_cnt THEN
                                        word_cnt := 0;
                                        CE_zd(memoryspace'pos(MSpace)) := '1';
                                        ce_busy(memoryspace'pos(MSpace)):=false;
                                        EDOut_zd(7 downto 0) <= (others => 'Z');
                                        EMRDY <= '1';
                                        EMDVALID <= '1';
                                    END IF;
                                ELSE
                                    byte_cnt := byte_cnt + 1;
                                    EA_int := to_slv(addr_int+wo+byte_cnt,20);
                                    EA_zd <= EA_int;
                                    setup_time := 1;
                                    strobe_time := 0;
                                    hold_time := 0;
                                    strob_delayed := false;
                                END IF;
                            END IF;
                            strob_xtnd := false;
                        ELSIF ARDY = '1' AND strob_xtnd THEN
                            strob_xtnd := false;
                            strob_delayed := true;
                        ELSE
                            strob_xtnd := true;
                            hold_time := -1;
                        END IF;
                    ELSIF setup_time = cur_setup + 1 THEN
                        SDWENeg_zd := '0';
                    END IF;
                END IF;

                IF TA_time = cur_TA THEN
                    TA_time := 0;
                    hold_time := 0;
                    setup_time := 0;
                    strobe_time := 0;
                END IF;

            WHEN "0001" =>   -- 16-bit asynch
                max_byte_cnt := 2;
                cur_mem := async;

        IF strobe_time = cur_strobe AND not strob_xtnd THEN
            hold_time := hold_time + 1;
        END IF;
                IF setup_time <= cur_setup THEN
                   setup_time := setup_time + 1;
                ELSIF strobe_time <= cur_strobe THEN
                    IF not strob_xtnd THEN
                        strobe_time := strobe_time + 1;
                    END IF;
                ELSIF hold_time <= cur_hold THEN
                    hold_time := hold_time + 1;
                ELSIF TA_time <= cur_TA THEN
                    TA_time := TA_time + 1;
                END IF;

                IF EMdir = read THEN
                    IF TA_time = 0 THEN
                        CE_zd(memoryspace'pos(MSpace)) := '0';
                        ce_busy(memoryspace'pos(MSpace)) := true;
                        EA_zd <= EA_int;
                        SDRASNeg_zd := '0';
                        EDOut_zd <= (others => 'Z');
                    END IF;

                    IF strobe_time = cur_strobe THEN
                        wo := word_cnt * 4;
                        IF ARDY = '1' AND not strob_xtnd THEN
                            SDCASNeg_zd := '1';
                            EDATA(wo + byte_cnt) <= to_nat(EDIn(7 downto 0));
                            EDATA(wo+byte_cnt+1) <= to_nat(EDIn(15 downto 8));
                            strob_xtnd := false;
                            hold_time := 0;
                            strob_xtnd := false;
                        ELSIF ARDY = '1' AND strob_xtnd THEN
                            EDATA(wo + byte_cnt) <= to_nat(EDIn(7 downto 0));
                            EDATA(wo+byte_cnt+1) <= to_nat(EDIn(15 downto 8));
                            strob_xtnd := false;
                            hold_time := -1;
                        ELSE
                            strob_xtnd := true;
                        END IF;
                    ELSIF (setup_time = cur_setup + 1) AND (hold_time = 0) THEN
                        SDCASNeg_zd := '0';
                    END IF;

                    IF strobe_time >= cur_strobe AND hold_time = cur_hold
                            AND not strob_xtnd THEN
                        wo := word_cnt * 4;
                        EA_int := to_slv((addr_int + wo + byte_cnt)/2,20);
                        IF byte_cnt = max_byte_cnt THEN
                            byte_cnt := 0;
                            word_cnt := word_cnt + 1;
                            hold_time := 0;
                            setup_time := 0;
                            strobe_time := 0;
                            IF word_cnt >= max_word_cnt THEN
                                word_cnt := 0;
                                SDRASNeg_zd := '1';
                                CE_zd(memoryspace'pos(MSpace)) := '1';
                                ce_busy(memoryspace'pos(MSpace)) := false;
                                EMRDY <= '1';
                                EMDVALID <= '1';
                            END IF;
                        ELSE
                            byte_cnt := byte_cnt + 2;
                            EA_int := to_slv((addr_int + wo + byte_cnt)/2,20);
                            EA_zd <= EA_int;
                            setup_time := 1;
                            strobe_time := 0;
                            hold_time := 0;
                        END IF;
                    END IF;

                    IF strobe_time > cur_strobe THEN
                        SDCASNeg_zd := '1';
                    END IF;

                ELSE
                    IF TA_time = 0 THEN
                        wo := word_cnt * 4;
                        CE_zd(memoryspace'pos(MSpace)) := '0';
                        ce_busy(memoryspace'pos(MSpace)) := true;
                        EA_zd <= EA_int;
                        EDOut_zd(15 downto 8)
                                 <= to_slv(DMADATA(wo + byte_cnt + 1),8);
                        EDOut_zd(7 downto 0) <= to_slv(DMADATA(wo+byte_cnt),8);
                    END IF;

                    IF strobe_time >= cur_strobe THEN
                        IF (ARDY = '1' AND not strob_xtnd) OR
                            strob_delayed THEN
                            SDWENeg_zd := '1';
                            IF hold_time = cur_hold THEN
                                IF byte_cnt = max_byte_cnt THEN
                                    byte_cnt := 0;
                                    word_cnt := word_cnt + 1;
                                    hold_time := 0;
                                    setup_time := 0;
                                    strobe_time := 0;
                                    strob_delayed := false;
                                    IF word_cnt >= max_word_cnt THEN
                                        word_cnt := 0;
                                        CE_zd(memoryspace'pos(MSpace)) := '1';
                                        ce_busy(memoryspace'pos(MSpace)):=false;
                                        EDOut_zd(15 downto 0) <= (others =>'Z');
                                        EMRDY <= '1';
                                        EMDVALID <= '1';
                                    END IF;
                                ELSE
                                    byte_cnt := byte_cnt + 2;
                                    EA_int :=
                                        to_slv((addr_int + wo + byte_cnt)/2,20);
                                    EA_zd <= EA_int;
                                    setup_time := 1;
                                    strobe_time := 0;
                                    hold_time := 0;
                                    strob_delayed := false;
                                END IF;
                            END IF;
                            strob_xtnd := false;
                        ELSIF ARDY = '1' AND strob_xtnd THEN
                            strob_xtnd := false;
                            strob_delayed := true;
                        ELSE
                            strob_xtnd := true;
                            hold_time := -1;
                        END IF;
                    ELSIF setup_time = cur_setup + 1 THEN
                        SDWENeg_zd := '0';
                    END IF;
                END IF;

                IF TA_time = cur_TA THEN
                    TA_time := 0;
                    hold_time := 0;
                    setup_time := 0;
                    strobe_time := 0;
                END IF;

            WHEN "0010" =>   -- 32-bit asynch
                cur_mem := async;

                IF strobe_time = cur_strobe AND not strob_xtnd THEN
                    hold_time := hold_time + 1;
                END IF;
                IF setup_time <= cur_setup THEN
                   setup_time := setup_time + 1;
                ELSIF strobe_time <= cur_strobe THEN
                    IF not strob_xtnd THEN
                        strobe_time := strobe_time + 1;
                    END IF;
                ELSIF hold_time <= cur_hold THEN
                    hold_time := hold_time + 1;
                ELSIF TA_time <= cur_TA THEN
                    TA_time := TA_time + 1;
                END IF;

                IF EMdir = read THEN
                    IF TA_time = 0 THEN
                        CE_zd(memoryspace'pos(MSpace)) := '0';
                        ce_busy(memoryspace'pos(MSpace)) := true;
                        EA_zd <= EA_int;
                        SDRASNeg_zd := '0';
                        EDOut_zd <= (others => 'Z');
                    END IF;

                    IF strobe_time = cur_strobe THEN
                        wo := word_cnt * 4;
                        IF ARDY = '1' AND not strob_xtnd THEN
                            SDCASNeg_zd := '1';
                            EDATA(wo + byte_cnt) <= to_nat(EDIn(7 downto 0));
                            EDATA(wo + byte_cnt + 1)
                                  <= to_nat(EDIn(15 downto 8));
                            EDATA(wo + byte_cnt + 2)
                                  <= to_nat(EDIn(23 downto 16));
                            EDATA(wo + byte_cnt + 3)
                                  <= to_nat(EDIn(31 downto 24));
                            hold_time := 0;
                            strob_xtnd := false;
                            word_cnt := word_cnt + 1;
                        ELSIF ARDY = '1' AND strob_xtnd THEN
                            EDATA(wo + byte_cnt) <= to_nat(EDIn(7 downto 0));
                            EDATA(wo + byte_cnt + 1)
                                  <= to_nat(EDIn(15 downto 8));
                            EDATA(wo + byte_cnt + 2)
                                  <= to_nat(EDIn(23 downto 16));
                            EDATA(wo + byte_cnt + 3)
                                  <= to_nat(EDIn(31 downto 24));
                            strob_xtnd := false;
                            hold_time := -1;
                            word_cnt := word_cnt + 1;
                        ELSE
                            strob_xtnd := true;
                        END IF;
                    ELSIF (setup_time = cur_setup + 1) AND (hold_time = 0) THEN
                        SDCASNeg_zd := '0';
                    END IF;

                    IF strobe_time >= cur_strobe AND hold_time >= cur_hold
                           AND not strob_xtnd THEN
                        strobe_time := 0;
                        hold_time := 0;
                        wo := word_cnt * 4;
                        EA_int := to_slv((addr_int + wo)/4,20);
                        IF word_cnt >= max_word_cnt THEN
                            word_cnt := 0;
                            CE_zd(memoryspace'pos(MSpace)) := '1';
                            SDRASNeg_zd := '1';
                            SDCASNeg_zd := '1';
                            ce_busy(memoryspace'pos(MSpace)) := false;
                            EMRDY <= '1';
                            EMDVALID <= '1';
                            setup_time := 0;
                        ELSE
                            setup_time := 1;
                            EA_zd <= EA_int;
                        END IF;
                    END IF;

                    IF strobe_time > cur_strobe THEN
                        SDCASNeg_zd := '1';
                    END IF;

                ELSE
                    IF TA_time = 0 THEN
                        wo := word_cnt * 4;
                        CE_zd(memoryspace'pos(MSpace)) := '0';
                        ce_busy(memoryspace'pos(MSpace)) := true;
                        EA_zd <= EA_int;
                        EDOut_zd(31 downto 24)
                                 <= to_slv(DMADATA(wo + byte_cnt + 3),8);
                        EDOut_zd(23 downto 16)
                                 <= to_slv(DMADATA(wo + byte_cnt + 2),8);
                        EDOut_zd(15 downto 8)
                                 <= to_slv(DMADATA(wo + byte_cnt + 1),8);
                        EDOut_zd(7 downto 0)
                                 <= to_slv(DMADATA(wo + byte_cnt),8);
                    END IF;

                    IF strobe_time >= cur_strobe THEN
                        IF (ARDY = '1' AND not strob_xtnd) OR
                                 strob_delayed THEN
                            SDWENeg_zd := '1';
                            IF hold_time = cur_hold THEN
                                word_cnt := word_cnt + 1;
                                wo := word_cnt * 4;
                                hold_time := 0;
                                strobe_time := 0;
                                EA_int := to_slv((addr_int + wo)/4,20);
                                strob_delayed := false;
                                IF word_cnt >= max_word_cnt THEN
                                    EMRDY <= '1';
                                    EMDVALID <= '1';
                                    word_cnt := 0;
                                    CE_zd(memoryspace'pos(MSpace)) := '1';
                                    ce_busy(memoryspace'pos(MSpace)) := false;
                                    EDOut_zd(31 downto 0)   <= (others => 'Z');
                                    setup_time := 0;
                                ELSE
                                    setup_time := 1;
                                    EA_zd <= EA_int;
                                    EDOut_zd(31 downto 24)
                                       <= to_slv(DMADATA(wo + byte_cnt + 3),8);
                                    EDOut_zd(23 downto 16)
                                       <= to_slv(DMADATA(wo + byte_cnt + 2),8);
                                    EDOut_zd(15 downto 8)
                                       <= to_slv(DMADATA(wo + byte_cnt + 1),8);
                                    EDOut_zd(7 downto 0)
                                       <= to_slv(DMADATA(wo + byte_cnt),8);
                                END IF;
                            END IF;
                            strob_xtnd := false;
                        ELSIF ARDY = '1' AND strob_xtnd THEN
                            strob_xtnd := false;
                            strob_delayed := true;
                        ELSE
                            strob_xtnd := true;
                            hold_time := -1;
                        END IF;
                    ELSIF setup_time = cur_setup + 1 THEN
                        SDWENeg_zd := '0';
                    END IF;
                END IF;

                IF TA_time = cur_TA THEN
                    TA_time := 0;
                    hold_time := 0;
                    setup_time := 0;
                    strobe_time := 0;
                END IF;

            WHEN "0011" =>   -- 32-bit SDRAM
                cur_mem := sync;
                row := to_nat(DMAOUTaddr(SDRSZval+SDCSZval downto SDCSZval));
                bank := to_nat(DMAOUTaddr(SDRSZval+SDCSZval downto
                (SDRSZval+SDCSZval) - (SDBSZval - 1)));
                openbank(row, bank, EMdir, MSpace);
                burst_len := Burst_Size;
                ce_busy(memoryspace'pos(MSpace)) := true;
            WHEN "0100" =>   -- 32-bit SBSRAM
                cur_mem := sync;
                IF EMdir = read THEN
                    IF sbsramclk = 0 THEN
                        CE_zd(memoryspace'pos(MSpace)) := '0';
                        ce_busy(memoryspace'pos(MSpace)) := true;
                        EA_zd <= EA_int;
                        BE3Neg_zd := '0';
                        BE2Neg_zd := '0';
                        BE1Neg_zd := '0';
                        BE0Neg_zd := '0';
                        SDCASNeg_zd := '0';
                        sbsramclk := 1;
                    ELSIF sbsramclk = 1 THEN
                        SDRASNeg_zd := '0';
                        SDCASNeg_zd := '1';
                        sbsramclk := 2;
                        IF not DMAburst THEN
                            BE3Neg_zd := '1';
                            BE2Neg_zd := '1';
                            BE1Neg_zd := '1';
                            BE0Neg_zd := '1';
                        END IF;
                    ELSIF sbsramclk = 2 THEN
                        sbsramclk := 3;
                    ELSIF sbsramclk = 3 THEN
                        EDATA(0) <= to_nat(EDIn(7 downto 0));
                        EDATA(1) <= to_nat(EDIn(15 downto 8));
                        EDATA(2) <= to_nat(EDIn(23 downto 16));
                        EDATA(3) <= to_nat(EDIn(31 downto 24));
                        sbsramclk := 4;
                    ELSIF sbsramclk = 5 THEN
                        CE_zd(memoryspace'pos(MSpace)) := '1';
                        SDCASNeg_zd := '0';
                        EA_zd <= (others => 'X');
                        IF DMAburst THEN
                            EDATA(0) <= to_nat(EDIn(7 downto 0));
                            EDATA(1) <= to_nat(EDIn(15 downto 8));
                            EDATA(2) <= to_nat(EDIn(23 downto 16));
                            EDATA(3) <= to_nat(EDIn(31 downto 24));
                        END IF;
                        sbsramclk := 6;
                    ELSIF sbsramclk < 6 THEN
                        IF DMAburst THEN
                            EDATA(0) <= to_nat(EDIn(7 downto 0));
                            EDATA(1) <= to_nat(EDIn(15 downto 8));
                            EDATA(2) <= to_nat(EDIn(23 downto 16));
                            EDATA(3) <= to_nat(EDIn(31 downto 24));
                        END IF;
                        sbsramclk := sbsramclk + 1;
                    ELSE
                        IF DMAburst THEN
                            EDATA(0) <= to_nat(EDIn(7 downto 0));
                            EDATA(1) <= to_nat(EDIn(15 downto 8));
                            EDATA(2) <= to_nat(EDIn(23 downto 16));
                            EDATA(3) <= to_nat(EDIn(31 downto 24));
                        END IF;
                        SDRASNeg_zd := '1';
                        SDCASNeg_zd := '1';
                        EMRDY <= '1';
                        EMDVALID <= '1';
                        ce_busy(memoryspace'pos(MSpace)) := false;
                        sbsramclk := 0;
                    END IF;
                ELSE
                    IF sbsramclk = 0 THEN
                        CE_zd(memoryspace'pos(MSpace)) := '0';
                        ce_busy(memoryspace'pos(MSpace)) := true;
                        EA_zd <= EA_int;
                        EDOut_zd(31 downto 24) <= to_slv(DMADATA(3),8);
                        EDOut_zd(23 downto 16) <= to_slv(DMADATA(2),8);
                        EDOut_zd(15 downto 8)  <= to_slv(DMADATA(1),8);
                        EDOut_zd(7 downto 0)   <= to_slv(DMADATA(0),8);
                        BE3Neg_zd := '0';
                        BE2Neg_zd := '0';
                        BE1Neg_zd := '0';
                        BE0Neg_zd := '0';
                        SDCASNeg_zd := '0';
                        SDWENeg_zd := '0';
                        sbsramclk := 1;
                    ELSIF sbsramclk = 1 THEN
                        SDCASNeg_zd := '1';
                        EDOut_zd(31 downto 24) <= to_slv(DMADATA(3),8);
                        EDOut_zd(23 downto 16) <= to_slv(DMADATA(2),8);
                        EDOut_zd(15 downto 8)  <= to_slv(DMADATA(1),8);
                        EDOut_zd(7 downto 0)   <= to_slv(DMADATA(0),8);
                        sbsramclk := 2;
                        IF not DMAburst THEN
                            BE3Neg_zd := '1';
                            BE2Neg_zd := '1';
                            BE1Neg_zd := '1';
                            BE0Neg_zd := '1';
                        END IF;
                    ELSIF sbsramclk < 4 THEN
                        EDOut_zd(31 downto 24) <= to_slv(DMADATA(3),8);
                        EDOut_zd(23 downto 16) <= to_slv(DMADATA(2),8);
                        EDOut_zd(15 downto 8)  <= to_slv(DMADATA(1),8);
                        EDOut_zd(7 downto 0)   <= to_slv(DMADATA(0),8);
                        sbsramclk := sbsramclk + 1;
                    ELSIF sbsramclk = 4 THEN
                        SDCASNeg_zd := '0';
                        SDWENeg_zd := '1';
                        EDOut_zd(31 downto 0) <= (others => 'Z');
                        EA_zd <= (others => 'X');
                        CE_zd(memoryspace'pos(MSpace)) := '1';
                        sbsramclk := sbsramclk + 1;
                    ELSE
                        SDCASNeg_zd := '1';
                        EMRDY <= '1';
                        EMDVALID <= '1';
                        ce_busy(memoryspace'pos(MSpace)) := false;
                        sbsramclk := 0;
                    END IF;
                END IF;
            WHEN "1000" =>   -- 8-bit SDRAM
                cur_mem := sync;
                null;
            WHEN "1001" =>   -- 16-bit SDRAM
                cur_mem := sync;
                null;
            WHEN "1010" =>   -- 8-bit SBRAM
                cur_mem := sync;
                null;
            WHEN "1011" =>   -- 16-bit SBRAM
                cur_mem := sync;
                null;
            WHEN others =>   -- reserved
                null;
        END CASE;
    END IF;

    IF rising_edge(ECLK_int) AND RESET_int = '1' AND DMARDY = '1' AND
                   BootDone AND sdrm_prsnt THEN
        banks : FOR bnk IN 0 TO 3 LOOP
        IF opbanks(bnk).PEND THEN
            CASE opbanks(bnk).STATE IS
                WHEN inactive =>
                    null;
                WHEN active =>
                    null;
                WHEN activating =>
                    IF clk_cnt = 0 THEN
                        CE_zd(memoryspace'pos(opbanks(bnk).CE)) := '0';
                        EA_zd(SDBSZval+SDRSZval+1 downto 2)
                             <= DMAOUTaddr(SDBSZval+SDRSZval+SDCSZval+1
                             downto SDCSZval+2);
                        SDRASNeg_zd := '0';
                        clk_cnt := 1;
                    ELSIF clk_cnt <= TRCDval THEN
                        CE_zd(memoryspace'pos(opbanks(bnk).CE)) := '1';
                        EA_zd <= (others => 'X');
                        SDRASNeg_zd := '1';
                        clk_cnt := clk_cnt + 1;
                    ELSE
                        sdram_cmd := none;
                        clk_cnt := 0;
                        opbanks(bnk).STATE := active;
                    END IF;
                WHEN deactivating =>
                    IF clk_cnt = 0 THEN
                        CE_zd(memoryspace'pos(opbanks(bnk).CE)) := '0';
                        EA_zd(SDBSZval+SDRSZval+1 downto 2)
                             <= DMAOUTaddr(SDBSZval+SDRSZval+SDCSZval+1
                             downto SDCSZval+2);
                        SDRASNeg_zd := '0';
                        SDCASNeg_zd := '1';
                        SDWENeg_zd := '0';
                        clk_cnt := 1;
                    ELSIF clk_cnt <= TRCDval THEN
                        CE_zd(memoryspace'pos(opbanks(bnk).CE)) := '1';
                        EA_zd <= (others => 'X');
                        EDOut_zd <= (others => 'Z');
                        SDRASNeg_zd := '1';
                        SDWENeg_zd := '1';
                        clk_cnt := clk_cnt + 1;
                    ELSE
                        sdram_cmd := none;
                        clk_cnt := 0;
                        opbanks(bnk).STATE := inactive;
                        openbank(row, bank, EMdir, MSpace);
                    END IF;
                WHEN writing =>
                    IF clk_cnt = 0 THEN
                        CE_zd(memoryspace'pos(opbanks(bnk).CE)) := '0';
                        EA_zd(SDBSZval+SDRSZval+1 downto SDRSZval+1)
                              <= DMAOUTaddr(SDBSZval+SDRSZval+SDCSZval+1
                              downto SDRSZval+SDCSZval+1);
                        EA_zd(SDCSZval+1 downto 2)
                              <= DMAOUTaddr(SDCSZval+1 downto 2);
                        EA_zd(12) <= '0';
                        EDOut_zd(31 downto 24)   <= to_slv(DMADATA(3),8);
                        EDOut_zd(23 downto 16)   <= to_slv(DMADATA(2),8);
                        EDOut_zd(15 downto 8)   <= to_slv(DMADATA(1),8);
                        EDOut_zd(7 downto 0)   <= to_slv(DMADATA(0),8);
                        SDCASNeg_zd := '0';
                        SDWENeg_zd := '0';
                        BE3Neg_zd := '0';
                        BE2Neg_zd := '0';
                        BE1Neg_zd := '0';
                        BE0Neg_zd := '0';
                        clk_cnt := 1;
                    ELSIF clk_cnt < burst_len THEN
                        wo := clk_cnt * 4;
                        CE_zd(memoryspace'pos(opbanks(bnk).CE)) := '1';
                        SDCASNeg_zd := '1';
                        SDWENeg_zd := '1';
                        EDOut_zd(31 downto 24)   <= to_slv(DMADATA(wo + 3),8);
                        EDOut_zd(23 downto 16)   <= to_slv(DMADATA(wo + 2),8);
                        EDOut_zd(15 downto 8)   <= to_slv(DMADATA(wo + 1),8);
                        EDOut_zd(7 downto 0)   <= to_slv(DMADATA(wo + 0),8);
                        clk_cnt := clk_cnt + 1;
                    ELSIF clk_cnt = burst_len THEN
                        CE_zd(memoryspace'pos(opbanks(bnk).CE)) := '1';
                        SDCASNeg_zd := '1';
                        SDWENeg_zd := '1';
                        BE3Neg_zd := '1';
                        BE2Neg_zd := '1';
                        BE1Neg_zd := '1';
                        BE0Neg_zd := '1';
                        EA_zd <= (others => 'X');
                        EDOut_zd <= (others => 'Z');
                        wo := 0;
                        clk_cnt := clk_cnt + 1;
                    ELSIF clk_cnt > 4 THEN
                        clk_cnt := 0;
                        wo := 0;
                        EMRDY <= '1';
                        EMDVALID <= '1';
                        opbanks(bnk).STATE := active;
                        opbanks(bnk).PEND := false;
                        ce_busy(memoryspace'pos(MSpace)) := false;
                    ELSE
                        clk_cnt := clk_cnt + 1;
                    END IF;
                WHEN reading =>
                    IF clk_cnt = 0 THEN
                        CE_zd(memoryspace'pos(opbanks(bnk).CE)) := '0';
                        EA_zd(SDBSZval+SDRSZval+1 downto SDRSZval+1)
                              <= DMAOUTaddr(SDBSZval+SDRSZval+SDCSZval+1
                              downto SDRSZval+SDCSZval+1);
                        EA_zd(SDCSZval+1 downto 2)
                              <= DMAOUTaddr(SDCSZval+1 downto 2);
                        EA_zd(12) <= '0';
                        SDCASNeg_zd := '0';
                        BE3Neg_zd := '0';
                        BE2Neg_zd := '0';
                        BE1Neg_zd := '0';
                        BE0Neg_zd := '0';
                        clk_cnt := 1;
                        wo := 0;
                    ELSIF clk_cnt <= 1 THEN
                        CE_zd(memoryspace'pos(opbanks(bnk).CE)) := '1';
                        EA_zd <= (others => 'X');
                        SDCASNeg_zd := '1';
                        clk_cnt := clk_cnt + 1;
                    ELSIF clk_cnt >= (burst_len + TCLval + 1) THEN
                        EMRDY <= '1';
                        EMDVALID <= '1';
                        clk_cnt := 0;
                        wo := 0;
                        opbanks(bnk).STATE := active;
                        opbanks(bnk).PEND := false;
                        ce_busy(memoryspace'pos(MSpace)) := false;
                    ELSIF clk_cnt > TCLval THEN
                        EDATA(wo + 0) <= to_nat(EDIn(7 downto 0));
                        EDATA(wo + 1) <= to_nat(EDIn(15 downto 8));
                        EDATA(wo + 2) <= to_nat(EDIn(23 downto 16));
                        EDATA(wo + 3) <= to_nat(EDIn(31 downto 24));
                        clk_cnt := clk_cnt + 1;
                        wo := wo + 4;
                    ELSIF clk_cnt > burst_len THEN
                        BE3Neg_zd := '1';
                        BE2Neg_zd := '1';
                        BE1Neg_zd := '1';
                        BE0Neg_zd := '1';
                        clk_cnt := clk_cnt + 1;
                    ELSE
                        clk_cnt := clk_cnt + 1;
                    END IF;
            END CASE;
        END IF;
        END LOOP banks;
    END IF;

        ------------------------------------------------------------------------
        -- Path Delay Section
        ------------------------------------------------------------------------
        VitalPathDelay01Z (
            OutSignal       => BUSREQ,
            OutSignalName   => "BUSREQ",
            OutTemp         => BUSREQ_zd,
            GlitchData      => BUSREQ_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_BUSREQ,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        VitalPathDelay01Z (
            OutSignal       => HOLDANeg,
            OutSignalName   => "HOLDANeg",
            OutTemp         => HOLDANeg_zd,
            GlitchData      => HOLDANeg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_HOLDANeg,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        VitalPathDelay01Z (
            OutSignal       => SDCASNeg_int,
            OutSignalName   => "SDCASNeg",
            OutTemp         => SDCASNeg_zd,
            GlitchData      => SDCASNeg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_SDCASNeg,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        VitalPathDelay01Z (
            OutSignal       => SDRASNeg,
            OutSignalName   => "SDRASNeg",
            OutTemp         => SDRASNeg_zd,
            GlitchData      => SDRASNeg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_SDRASNeg,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        VitalPathDelay01Z (
            OutSignal       => SDWENeg,
            OutSignalName   => "SDWENeg",
            OutTemp         => SDWENeg_zd,
            GlitchData      => SDWENeg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_SDWENeg,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        VitalPathDelay01Z (
            OutSignal       => BE3Neg,
            OutSignalName   => "BE3Neg",
            OutTemp         => BE3Neg_zd,
            GlitchData      => BE3Neg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_BE0Neg,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        VitalPathDelay01Z (
            OutSignal       => BE2Neg,
            OutSignalName   => "BE2Neg",
            OutTemp         => BE2Neg_zd,
            GlitchData      => BE2Neg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_BE0Neg,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        VitalPathDelay01Z (
            OutSignal       => BE1Neg,
            OutSignalName   => "BE1Neg",
            OutTemp         => BE1Neg_zd,
            GlitchData      => BE1Neg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_BE0Neg,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        VitalPathDelay01Z (
            OutSignal       => BE0Neg,
            OutSignalName   => "BE0Neg",
            OutTemp         => BE0Neg_zd,
            GlitchData      => BE0Neg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_BE0Neg,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        VitalPathDelay01Z (
            OutSignal       => CE3Neg,
            OutSignalName   => "CE3Neg",
            OutTemp         => CE_zd(3),
            GlitchData      => CE3Neg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_CE0Neg,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        VitalPathDelay01Z (
            OutSignal       => CE2Neg,
            OutSignalName   => "CE2Neg",
            OutTemp         => CE_zd(2),
            GlitchData      => CE2Neg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_CE0Neg,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        VitalPathDelay01Z (
            OutSignal       => CE1Neg,
            OutSignalName   => "CE1Neg",
            OutTemp         => CE_zd(1),
            GlitchData      => CE1Neg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_CE0Neg,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        VitalPathDelay01Z (
            OutSignal       => CE0Neg,
            OutSignalName   => "CE0Neg",
            OutTemp         => CE_zd(0),
            GlitchData      => CE0Neg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_CE0Neg,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

    END PROCESS EMIF;

    ----------------------------------------------------------------------------
    -- EDMA
    ----------------------------------------------------------------------------
    EDMA : PROCESS(FETCH, EVENT, CPUclk2, HPIDacc, HCSNeg, Booting, EMRDY,
                   RESETNeg, RESET_int, SDRMinit_tmp, CPUrdy, EMDVALID,
                   XRDY_sig, XRDY_t, XRDY, DRXtoXSR_clk, XRDY_RD, XSYNCERR_RD,
                   XEMPTYNeg_RD, RSYNCERR_RD, RRDY_RD, RFULL_RD, XRDY01_RD,
                   XUNDERN1_flag,ROVERN1_flag, XSYNC1_RD, RSYNC1_RD, RRDY01_RD,
                   XCKFAIL1_RD, RCKFAIL1_RD, XRDY11_RD, XRDY21_RD, XRDY31_RD,
                   XRDY41_RD, XRDY51_RD, XRDY61_RD, XRDY71_RD, RRDY11_RD,
                   RRDY21_RD, RRDY31_RD, RRDY41_RD, RRDY51_RD, RRDY61_RD,
                   RRDY71_RD)

       TYPE xferdest_type IS (hpi, cpu, mem);
        TYPE xferphase_type IS (read, write);

        VARIABLE hrdy_cnt      : NATURAL;
        VARIABLE hrdy_lmt      : NATURAL := 17;
        VARIABLE hrdy_noglitch : BOOLEAN;
        VARIABLE mv_loop       : BOOLEAN := false;
        VARIABLE startaddr     : NATURAL;
        VARIABLE bankaddr      : NATURAL;
        VARIABLE destbank      : NATURAL;
        VARIABLE deststart     : NATURAL;
        VARIABLE word_addr     : NATURAL;
        VARIABLE byte_addr     : NATURAL;
        VARIABLE word_cnt      : NATURAL;
        VARIABLE word_cnt_wrt  : NATURAL;
        VARIABLE word_num      : NATURAL;
        VARIABLE loop_cnt      : NATURAL;
        VARIABLE loop_cnt_wrt  : NATURAL;
        VARIABLE addrword      : std_logic_vector(31 downto 0);
        VARIABLE srcaddr       : std_logic_vector(31 downto 0);
        VARIABLE destaddr      : std_logic_vector(31 downto 0);
        VARIABLE regtmpa       : std_logic_vector(31 downto 0);
        VARIABLE regtmp        : Reg32;
        VARIABLE XBUFTmp       : std_logic_vector(31 downto 0);
        VARIABLE XTemp         : std_logic_vector(31 downto 0);
        VARIABLE RBUFTmp       : std_logic_vector(31 downto 0);
        VARIABLE RTemp         : std_logic_vector(31 downto 0);
        VARIABLE xbit          : NATURAL;
        VARIABLE rbit          : NATURAL;
        VARIABLE rotate        : NATURAL;
        VARIABLE rotater       : NATURAL;
        VARIABLE zerobit       : std_logic;
        VARIABLE xferdest      : xferdest_type;
        VARIABLE xferphase     : xferphase_type;

    BEGIN

    IF falling_edge(HCSNeg) THEN
        HRDY <= '0';
    END IF;

    IF (Booting'EVENT AND Booting = true) AND (BootReg /= "00") THEN
        word_addr := 0;
    END IF;

    IF falling_edge(EMRDY) THEN
        DMAdone <= '0';
    ELSIF rising_edge(EMRDY) THEN
        DMAdone <= '1';
    END IF;

    IF rising_edge(EMDVALID) THEN
        DMARDY <= '0';
        IF word_cnt_wrt = 0 THEN
            DMAdone <= '1';
        END IF;
        IF Booting THEN
            byte_addr := word_addr * 4;
            L2Mem(byte_addr - 1) <= EDATA(3);
            L2Mem(byte_addr - 2) <= EDATA(2);
            L2Mem(byte_addr - 3) <= EDATA(1);
            L2Mem(byte_addr - 4) <= EDATA(0);
        ELSE
            HRDY <= '1';
            IF EMdir = read THEN
                IF xferdest = hpi THEN
                    HPIDout(0)(7 downto 0)  <= to_slv(EDATA(0),8);
                    HPIDout(0)(15 downto 8) <= to_slv(EDATA(1),8);
                    HPIDout(1)(7 downto 0)  <= to_slv(EDATA(2),8);
                    HPIDout(1)(15 downto 8) <= to_slv(EDATA(3),8);
                    HPI_flag <= '1';
                ELSIF xferdest = cpu THEN
                    RDdata(0) <= EDATA(0);
                    RDdata(1) <= EDATA(1);
                    RDdata(2) <= EDATA(2);
                    RDdata(3) <= EDATA(3);
                ELSIF xferdest = mem THEN
                    DMADATA <= EDATA;
                    EMdir <= write;
                    xferphase := write;
                END IF;
            END IF;
        END IF;
    END IF;

    IF (Booting'EVENT AND Booting = false) THEN
        DMARDY <= '0';
    END IF;

    IF rising_edge(RESET_int) THEN
        CASE BootReg IS
            WHEN "00" =>    -- HPI
                DMARDY <= '1';
            WHEN others =>    -- error
                null;
        END CASE;
    END IF;

-- McBSP
    IF rising_edge (XRDY_RD) THEN
        XRDY_t <= '1';
    END IF;

    IF STOP_sig = '1'  THEN
        XRDY <= '1';
        XRDY_sig <= '1';
    ELSE
        IF XRDY_sig = '1' THEN
            XRDY_sig <= '0' after 40 ns;
        ELSE
            XRDY <= XRDY_t;
        END IF;
    END IF;

    IF rising_edge(XSYNCERR_RD) THEN
        XSYNCERR <= '1' , '0' AFTER 20 ns;
    END IF;

    IF rising_edge(XEMPTYNeg_RD) THEN
        XEMPTYNeg <= '0';
    END IF;

    IF rising_edge(DRXtoXSR_clk) THEN
        XEMPTYNeg <= '1';
    END IF;

    IF rising_edge(RSYNCERR_RD) THEN
        RSYNCERR <= '1' , '0' AFTER 20 ns;
    END IF;

    IF rising_edge(RRDY_RD) THEN
        RRDY <= '1';
    END IF;

    IF rising_edge(RFULL_RD) THEN
        RFULL <= '1';
    END IF;

    -- McASP1
    IF rising_edge(XRDY01_RD) THEN
        XRDY01 <= '1';
    END IF;

    IF rising_edge(XRDY11_RD) THEN
        XRDY11 <= '1';
    END IF;

    IF rising_edge(XRDY21_RD) THEN
        XRDY21 <= '1';
    END IF;

    IF rising_edge(XRDY31_RD) THEN
        XRDY31 <= '1';
    END IF;

    IF rising_edge(XRDY41_RD) THEN
        XRDY41 <= '1';
    END IF;

    IF rising_edge(XRDY51_RD) THEN
        XRDY51 <= '1';
    END IF;

    IF rising_edge(XRDY61_RD) THEN
        XRDY61 <= '1';
    END IF;

    IF rising_edge(XRDY71_RD) THEN
        XRDY71 <= '1';
    END IF;

    IF rising_edge(RRDY01_RD) THEN
        RRDY01 <= '1';
    END IF;

    IF rising_edge(RRDY11_RD) THEN
        RRDY11 <= '1';
    END IF;

    IF rising_edge(RRDY21_RD) THEN
        RRDY21 <= '1';
    END IF;

    IF rising_edge(RRDY31_RD) THEN
        RRDY31 <= '1';
    END IF;

    IF rising_edge(RRDY41_RD) THEN
        RRDY41 <= '1';
    END IF;

    IF rising_edge(RRDY51_RD) THEN
        RRDY51 <= '1';
    END IF;

    IF rising_edge(RRDY61_RD) THEN
        RRDY61 <= '1';
    END IF;

    IF rising_edge(RRDY71_RD) THEN
        RRDY71 <= '1';
    END IF;

    IF rising_edge(XUNDERN1_flag) THEN
        XUNDERN1 <= '1';
    END IF;
    IF rising_edge(ROVERN1_flag) THEN
        ROVERN1 <= '1';
    END IF;

    IF rising_edge(XSYNC1_RD) THEN
        XSYNC1 <= '1';
    END IF;

    IF rising_edge(RSYNC1_RD) THEN
        RSYNC1 <= '1';
    END IF;

    IF rising_edge(RCKFAIL1_RD) THEN
        RCKFL1 <= '1';
    END IF;

    IF rising_edge(XCKFAIL1_RD) THEN
        XCKFL1 <= '1';
    END IF;

    IF RESETNeg = '1' AND XRSTNeg = '0' AND XIOEN = '1' THEN
        IF CLKXM = '0' THEN
            CLKXP <= CLKX0In;
        END IF;
        IF FSXM = '0' THEN
            FSXP <= FSX0In;
        END IF;
    END IF;

    IF RESETNeg = '1' AND RRSTNeg = '0' AND RIOEN = '1' THEN
        IF CLKRM = '0'  THEN
            CLKRP <= CLKR0In;
        END IF;
        IF FSRM = '0'  THEN
            FSRP <= FSR0In;
        END IF;
        DR0_STAT  <= DR0;
    END IF;

    IF RESETNeg = '1' AND RRSTNeg = '0' AND RIOEN = '1' AND
       XRSTNeg = '0' AND XIOEN = '1' THEN
        CLKS0_STAT <= CLKS0;
    END IF;

    IF CPUclk2'EVENT THEN
        IF (bankaddr < 16#3000#) THEN
            IF to_nat(HCNTL) = 2 THEN
                hrdy_cnt := hrdy_cnt + 2;
            ELSE
                hrdy_cnt := hrdy_cnt + 1;
            END IF;
            IF hrdy_cnt >= hrdy_lmt THEN
                hrdy_cnt := 0;
                HRDY <= '1';
            END IF;
        ELSIF (bankaddr > 16#7FFF#) AND HCNTL /= "01" THEN
            IF EMDVALID = '1' OR (EMRDY = '1' AND HPIDacc = '0') THEN
                IF hstrob_int = '0' THEN
                    hrdy_cnt := 0;
                    HRDY <= '1';
                END IF;
                IF HRDY = '0' THEN
                    hrdy_cnt := hrdy_cnt + 1;
                END IF;
            END IF;
        END IF;
        IF EMRDY = '1' AND HCNTL = "01" THEN
            HRDY <= '1';
        END IF;
        IF (Booting = true) AND (BootReg /= "00") AND DMARDY = '0' THEN
            EADDR <= word_addr;
            DMARDY <= '1';
            word_addr := word_addr + 1;
            EMdir <= read;
        END IF;
        IF counter0 THEN
            SDINT <= '1';
        END IF;
    END IF;

    IF rising_edge(HPIDacc) THEN
        bankaddr := to_nat(HPIA(1));
        startaddr := to_nat(HPIA(0));
        addrword := HPIA(1) & HPIA(0);
        IF HPIrd = '1' THEN               -- read
            xferdest := hpi;
            IF bankaddr < 16#0004# THEN          -- L2 memory
                HPIDout(0)(7 downto 0) <= to_slv(L2Mem(startaddr),8);
                HPIDout(0)(15 downto 8) <= to_slv(L2Mem(startaddr + 1),8);
                HPIDout(1)(7 downto 0) <= to_slv(L2Mem(startaddr + 2),8);
                HPIDout(1)(15 downto 8) <= to_slv(L2Mem(startaddr + 3),8);
                HPI_flag <= '1';
            ELSIF bankaddr < 16#0180# THEN     -- reseved
                ASSERT false
                    REPORT "attempt to read from reserved address space"
                    SEVERITY warning;
            ELSIF bankaddr = 16#0180# THEN     -- EMIF registers
                IF startaddr = 0 THEN     -- EMIF global control reg
                    HPIDout <= GBLCTL;
                ELSIF startaddr = 16#04# THEN --EMIF CE space control reg 1
                    HPIDout <= CE1CTL;
                ELSIF startaddr = 16#08# THEN --EMIF CE space control reg 0
                    HPIDout <= CE0CTL;
                ELSIF startaddr = 16#0C# THEN
                    ASSERT false
                        REPORT "attempt to read from reserved address space"
                        SEVERITY warning;
                ELSIF startaddr = 16#10# THEN --EMIF CE space control reg 2
                    HPIDout <= CE2CTL;
                ELSIF startaddr = 16#14# THEN --EMIF CE space control reg 3
                    HPIDout <= CE3CTL;
                ELSIF startaddr = 16#18# THEN --EMIF SDRAM control reg
                    HPIDout <= SDCTL;
                ELSIF startaddr = 16#1C# THEN --EMIF SDRAM timing reg
                    HPIDout <= SDTIM;
                ELSIF startaddr = 16#20# THEN --EMIF SDRAM extension reg
                    HPIDout <= SDEXT;
                END IF;
                HPI_flag <= '1';
            ELSIF bankaddr < 16#0186# THEN     -- L2 memory registers
                ASSERT false
                    REPORT "attempt to read from L2 memory registers"
                    SEVERITY warning;
                HPI_flag <= '1';
            ELSIF bankaddr < 16#0188# THEN     -- reseved
                ASSERT false
                    REPORT "attempt to read from reserved address space"
                    SEVERITY warning;
            ELSIF bankaddr = 16#0188# THEN     -- HPI registers
                IF startaddr = 0 THEN
                    HPIDout <= HPIC;
                END IF;
                HPI_flag <= '1';
            ELSIF bankaddr = 16#018C# THEN  --MsBSP0 registers
                IF startaddr = 16#00# THEN
                    HPIDout(0) <= DRR0(15 downto 0);
                    HPIDout(1) <= DRR0(31 downto 16);
                ELSIF startaddr = 16#08# THEN
                    HPIDout <= SPCR0;
                ELSIF startaddr = 16#0C# THEN
                    HPIDout <= RCR0;
                ELSIF startaddr = 16#10# THEN
                    HPIDout <= XCR0;
                ELSIF startaddr = 16#14# THEN
                    HPIDout <= SRGR0;
                ELSIF startaddr = 16#18# THEN
                    HPIDout <= MCR0;
                ELSIF startaddr = 16#1C# THEN
                    HPIDout <= RCER0;
                ELSIF startaddr = 16#20# THEN
                    HPIDout <= XCER0;
                ELSIF startaddr = 16#24# THEN
                HPIDout <= PCR0;
                END IF;
                HPI_flag <= '1';
            ELSIF bankaddr = 16#0190# THEN  --MsBSP1 registers
                IF startaddr = 16#00# THEN
                    HPIDout(0) <= DRR1(15 downto 0);
                    HPIDout(1) <= DRR1(31 downto 16);
                ELSIF startaddr = 16#08# THEN
                    HPIDout <= SPCR1;
                ELSIF startaddr = 16#0C# THEN
                    HPIDout <= RCR1;
                ELSIF startaddr = 16#10# THEN
                    HPIDout <= XCR1;
                ELSIF startaddr = 16#14# THEN
                    HPIDout <= SRGR1;
                ELSIF startaddr = 16#18# THEN
                    HPIDout <= MCR1;
                ELSIF startaddr = 16#1C# THEN
                    HPIDout <= RCER1;
                ELSIF startaddr = 16#20# THEN
                    HPIDout <= XCER1;
                ELSIF startaddr = 16#24# THEN
                HPIDout <= PCR1;
                END IF;
                HPI_flag <= '1';
            ELSIF bankaddr = 16#0194# THEN      -- Timer0 registers
                IF startaddr = 0 THEN
                    HPIDout <= Timer0CTL;
                ELSIF startaddr = 16#04# THEN
                    HPIDout <= Timer0PRD;
                ELSIF startaddr = 16#08# THEN
                   HPIDout <= Timer0CNT;
                END IF;
                HPI_flag <= '1';
            ELSIF bankaddr = 16#0198# THEN      -- Timer1 registers
                IF startaddr = 0 THEN
                    HPIDout <= Timer1CTL;
                ELSIF startaddr = 16#04# THEN
                    HPIDout <= Timer1PRD;
                ELSIF startaddr = 16#08# THEN
                    HPIDout <= Timer1CNT;
                 END IF;
                 HPI_flag <= '1';
            ELSIF bankaddr > 16#BFFF# THEN     -- reserved
                ASSERT false
                    REPORT "attempt to read from reserved address space"
                    SEVERITY warning;
            ELSIF bankaddr > 16#7FFF# THEN     -- external memory CEX
                IF bankaddr > 16#AFFF# THEN     -- external memory CE3
                    MSpace <= CE3;
                ELSIF bankaddr > 16#9FFF# THEN     -- external memory CE2
                    MSpace <= CE2;
                ELSIF bankaddr > 16#8FFF# THEN     -- external memory CE1
                    MSpace <= CE1;
                ELSE                            -- external memory CE0
                    MSpace <= CE0;
                END IF;
                EMdir <= read;
                EADDR <= To_Nat(addrword(27 downto 0));
                DMAOUTaddr <= addrword(30 downto 0);
                DMARDY <= '1';
                DMAburst <= false;
                Burst_Size <= 1;
            END IF;
        ELSE    --write
           IF bankaddr < 16#0004# THEN          -- L2 memory
                L2Mem(startaddr) <= to_nat(HPIDin(0)(7 downto 0));
                L2Mem(startaddr + 1) <= to_nat(HPIDin(0)(15 downto 8));
                L2Mem(startaddr + 2) <= to_nat(HPIDin(1)(7 downto 0));
                L2Mem(startaddr + 3) <= to_nat(HPIDin(1)(15 downto 8));
            ELSIF bankaddr < 16#0180# THEN     -- reseved
                ASSERT false
                    REPORT "attempt to write to reserved address space"
                    SEVERITY warning;
            ELSIF bankaddr = 16#0180# THEN     -- EMIF registers
                IF startaddr = 0 THEN     -- EMIF global control reg
                    GBLCTL <= HPIDin;
                ELSIF startaddr = 16#04# THEN --EMIF CE space control reg 1
                    CE1CTL <= HPIDin;
                ELSIF startaddr = 16#08# THEN --EMIF CE space control reg 0
                    CE0CTL <= HPIDin;
                ELSIF startaddr = 16#10# THEN --EMIF CE space control reg 2
                    CE2CTL <= HPIDin;
                ELSIF startaddr = 16#14# THEN --EMIF CE space control reg 3
                    CE3CTL <= HPIDin;
                ELSIF startaddr = 16#18# THEN --EMIF SDRAM control reg
                    SDCTL <= HPIDin;
                ELSIF startaddr = 16#1C# THEN --EMIF SDRAM timing reg
                    SDTIM <= HPIDin;
                ELSIF startaddr = 16#20# THEN --EMIFASDRAM extension reg
                    SDEXT <= HPIDin;
                END IF;
            ELSIF bankaddr < 16#0186# THEN     -- L2 memory registers
                ASSERT false
                    REPORT "attempt to write to L2 memory registers"
                    SEVERITY warning;
            ELSIF bankaddr < 16#0188# THEN     -- reseved
                ASSERT false
                    REPORT "attempt to write to reserved address space"
                    SEVERITY warning;
            ELSIF bankaddr = 16#0188# THEN     -- HPI registers
                ASSERT false
                    REPORT "attempt to write to HPI registers"
                    SEVERITY warning;
            ELSIF bankaddr = 16#018C# THEN  --MsBSP0 registers
                IF startaddr = 16#04# THEN
                    DXR0 <= (HPIDin(1) & HPIDin(0));
                    XRDY_t <= '0';
                ELSIF startaddr = 16#08# THEN
                    SPCR0 <= HPIDin;
                ELSIF startaddr = 16#0C# THEN
                    RCR0 <= HPIDin;
                ELSIF startaddr = 16#10# THEN
                    XCR0 <= HPIDin;
                ELSIF startaddr = 16#14# THEN
                    SRGR0 <= HPIDin;
                ELSIF startaddr = 16#18# THEN
                    MCR0 <= HPIDin;
                ELSIF startaddr = 16#1C# THEN
                    RCER0 <= HPIDin;
                ELSIF startaddr = 16#20# THEN
                    XCER0 <= HPIDin;
                ELSIF startaddr = 16#24# THEN
                    PCR0 <= HPIDin;
                END IF;
            ELSIF bankaddr = 16#0190# THEN  --MsBSP1 registers
                IF startaddr = 16#04# THEN
                    DXR1 <= (HPIDin(1) & HPIDin(0));
                ELSIF startaddr = 16#08# THEN
                    SPCR1 <= HPIDin;
                ELSIF startaddr = 16#0C# THEN
                    RCR1 <= HPIDin;
                ELSIF startaddr = 16#10# THEN
                    XCR1 <= HPIDin;
                ELSIF startaddr = 16#14# THEN
                    SRGR1 <= HPIDin;
                ELSIF startaddr = 16#18# THEN
                    MCR1 <= HPIDin;
                ELSIF startaddr = 16#1C# THEN
                    RCER1 <= HPIDin;
                ELSIF startaddr = 16#20# THEN
                    XCER1 <= HPIDin;
                ELSIF startaddr = 16#24# THEN
                    PCR1 <= HPIDin;
                END IF;
            ELSIF bankaddr = 16#0194# THEN      -- Timer0 registers
                IF startaddr = 0 THEN
                    Timer0CTL <= HPIDin;
                ELSIF startaddr = 16#04# THEN
                    Timer0PRD <= HPIDin;
                END IF;
            ELSIF bankaddr = 16#0198# THEN      -- Timer1 registers
                IF startaddr = 0 THEN
                    Timer1CTL <= HPIDin;
                ELSIF startaddr = 16#04# THEN
                    Timer1PRD <= HPIDin;
                END IF;
            ELSIF bankaddr = 16#01B7# THEN      -- PLL registers
                IF startaddr = 16#C000# THEN
                    PLLPID <= HPIDin;
                ELSIF startaddr = 16#C100# THEN
                    PLLCSR <= HPIDin;
                ELSIF startaddr = 16#C110# THEN
                    PLLMCR <= HPIDin;
                ELSIF startaddr = 16#C114# THEN
                    PLLDIV0 <= HPIDin;
                ELSIF startaddr = 16#C118# THEN
                    PLLDIV1 <= HPIDin;
                ELSIF startaddr = 16#C11C# THEN
                    PLLDIV2 <= HPIDin;
                ELSIF startaddr = 16#C120# THEN
                    PLLDIV3 <= HPIDin;
                ELSIF startaddr = 16#C124# THEN
                    OSCDIV1 <= HPIDin;
                END IF;
            ELSIF bankaddr > 16#BFFF# THEN     -- reserved
                ASSERT false
                    REPORT "attempt to write to reserved address space"
                    SEVERITY warning;
            ELSIF bankaddr > 16#7FFF# THEN      -- EMIF
                IF bankaddr > 16#AFFF# THEN     -- external memory CE3
                    MSpace <= CE3;
                ELSIF bankaddr > 16#9FFF# THEN     -- external memory CE2
                    MSpace <= CE2;
                ELSIF bankaddr > 16#8FFF# THEN     -- external memory CE1
                    MSpace <= CE1;
                ELSE                            -- external memory CE0
                    MSpace <= CE0;
                END IF;
                EMdir <= write;
                EADDR <= to_nat(addrword(27 downto 0));
                DMAOUTaddr <= addrword(30 downto 0);
                DMADATA(0) <= to_nat(HPIDin(0)(7 downto 0));
                DMADATA(1) <= to_nat(HPIDin(0)(15 downto 8));
                DMADATA(2) <= to_nat(HPIDin(1)(7 downto 0));
                DMADATA(3) <= to_nat(HPIDin(1)(15 downto 8));
                DMARDY <= '1';
                DMAburst <= false;
            END IF;
        END IF;
    ELSIF (rising_edge(RESETNeg)) THEN
        BootReg <= BootMode4 & BootMode3;
        GBLCTL <= ("0000000000000000","0011011001111001");
        CE3CTL <= ("1111111111111111","1111111100100011");
        CE2CTL <= ("1111111111111111","1111111100100011");
        CE1CTL <= ("1111111111111111","1111111100100011");
        CE0CTL <= ("1111111111111111","1111111100100011");
        SDCTL  <= ("0000001001001000","1111000000000000");
        SDTIM  <= ("0000000001011101","1100010111011100");
        SDEXT  <= ("0000000000011011","1101111110011111");
        OSCDIV1(0) <= "1000000000000111";
        OSCDIV1(1) <= "0000000000000000";
        PLLCSR(0) <= "0000000000001000";
        PLLCSR(1) <= "0000000000000000";
        PLLMCR(0) <= "0000000000000111";
        PLLMCR(1) <= "0000000000000000";
        PLLDIV0(0) <= "1000000000000000";
        PLLDIV0(1) <= "0000000000000000";
        PLLDIV1(0) <= "1000000000000000";
        PLLDIV1(1) <= "0000000000000000";
        PLLDIV2(0) <= "1000000000000001";
        PLLDIV2(1) <= "0000000000000000";
        PLLDIV3(0) <= "1000000000000001";
        PLLDIV3(1) <= "0000000000000000";
    ELSIF falling_edge(SDRMinit_tmp) THEN
        SDRMinit <= '0';
        SDRMinit_tmp <= '1';
    END IF;

    IF rising_edge(RESET_int) THEN
        CASE BootReg IS
            WHEN "00" =>    -- HPI
                IF HDIn(14) = '1' THEN
                    HPI_EN <= '1';-- HPI enable
                ELSE
                    HPI_EN <= '0';-- McASP1 enable
                END IF;
            WHEN "01" =>    -- 8-bit ROM
                CE1mtype <= "0000";
            WHEN "10" =>    -- 16-bit ROM
                CE1mtype <= "0001";
            WHEN "11" =>    -- 32-bit ROM
                CE1mtype <= "0010";
            WHEN others =>    -- error
                null;
        END CASE;
    END IF;

    IF falling_edge(HPIDacc) THEN
        HPI_flag <= '0';
    END IF;

    IF rising_edge(CPUrdy) THEN
        CASE cpuop IS
        WHEN NOP =>
            DMAdone <= '0';
        WHEN WR =>
            DMAdone <= '0';
            bankaddr := CPUaddr(1);
            startaddr := CPUaddr(0);
            addrword(31 downto 16) := to_slv(CPUaddr(1),16);
            addrword(15 downto 0) := to_slv(CPUaddr(0),16);
            IF bankaddr < 16#0004# THEN          -- write to L2 memory
                L2Mem(startaddr) <= CPUdata(0);
                L2Mem(startaddr + 1) <= CPUdata(1);
                L2Mem(startaddr + 2) <= CPUdata(2);
                L2Mem(startaddr + 3) <= CPUdata(3);
                DMAdone <= TRANSPORT '1' AFTER 2 ns;
            ELSIF bankaddr < 16#180# THEN     -- reserved
                ASSERT false
                    REPORT "attempt to write to reserved address space"
                    SEVERITY warning;
                DMAdone <= TRANSPORT '1' AFTER 2 ns;
            ELSIF bankaddr = 16#0180# THEN     -- EMIF registers
                regtmp(1) := to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                regtmp(0) := to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                IF startaddr = 0 THEN     -- EMIF global control reg
                    GBLCTL <= regtmp;
                ELSIF startaddr = 16#04# THEN --EMIF CE space control reg 1
                    CE1CTL <= regtmp;
                ELSIF startaddr = 16#08# THEN --EMIF CE space control reg 0
                    CE0CTL <= regtmp;
                ELSIF startaddr = 16#10# THEN --EMIF CE space control reg 2
                    CE2CTL <= regtmp;
                ELSIF startaddr = 16#14# THEN --EMIF CE space control reg 3
                    CE3CTL <= regtmp;
                ELSIF startaddr = 16#18# THEN --EMIF SDRAM control reg
                    SDCTL <= regtmp;
                ELSIF startaddr = 16#1C# THEN --EMIF SDRAM timing reg
                    SDTIM <= regtmp;
                ELSIF startaddr = 16#20# THEN --EMIFASDRAM extension reg
                    SDEXT <= regtmp;
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 5 ns;
            ELSIF bankaddr < 16#0186# THEN     -- L2 memory registers
                ASSERT false
                    REPORT "attempt to write to L2 memory registers"
                    SEVERITY warning;
                DMAdone <= TRANSPORT '1' AFTER 5 ns;
            ELSIF bankaddr < 16#0188# THEN     -- reseved
                ASSERT false
                    REPORT "attempt to write to reserved address space"
                    SEVERITY warning;
                DMAdone <= TRANSPORT '1' AFTER 5 ns;
            ELSIF bankaddr = 16#0188# THEN     -- HPI registers
                ASSERT false
                    REPORT "attempt to write to HPI registers"
                    SEVERITY warning;
                DMAdone <= TRANSPORT '1' AFTER 5 ns;
            ELSIF bankaddr = 16#018C# THEN  --MsBSP0 registers
                regtmp(1) := to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                regtmp(0) := to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                IF startaddr = 16#04# THEN
                    IF STOP_sig = '0' THEN
                       DXR0 <= (regtmp(1) & regtmp(0));
                    END IF;
                    XRDY_t <= '0';
                ELSIF startaddr = 16#08# THEN
                    SPCR0 <= regtmp;
                ELSIF startaddr = 16#0C# THEN
                    RCR0 <= regtmp;
                ELSIF startaddr = 16#10# THEN
                    XCR0 <= regtmp;
                ELSIF startaddr = 16#14# THEN
                    SRGR0 <= regtmp;
                ELSIF startaddr = 16#18# THEN
                    MCR0 <= regtmp;
                ELSIF startaddr = 16#1C# THEN
                    RCER0 <= regtmp;
                ELSIF startaddr = 16#20# THEN
                    XCER0 <= regtmp;
                ELSIF startaddr = 16#24# THEN
                    PCR0 <= regtmp;
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 5 ns;
            ELSIF bankaddr = 16#0190# THEN  --MsBSP1 registers
                regtmp(1) := to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                regtmp(0) := to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                IF startaddr = 16#04# THEN
                    DXR1 <= (regtmp(1) & regtmp(0));
                ELSIF startaddr = 16#08# THEN
                    SPCR1 <= regtmp;
                ELSIF startaddr = 16#0C# THEN
                    RCR1 <= regtmp;
                ELSIF startaddr = 16#10# THEN
                    XCR1 <= regtmp;
                ELSIF startaddr = 16#14# THEN
                    SRGR1 <= regtmp;
                ELSIF startaddr = 16#18# THEN
                    MCR1 <= regtmp;
                ELSIF startaddr = 16#1C# THEN
                    RCER1 <= regtmp;
                ELSIF startaddr = 16#20# THEN
                    XCER1 <= regtmp;
                ELSIF startaddr = 16#24# THEN
                    PCR1 <= regtmp;
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 5 ns;
            ELSIF bankaddr = 16#0194# THEN      -- Timer0 registers
                regtmp(1) := to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                regtmp(0) := to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                IF startaddr = 0 THEN
                    Timer0CTL <= regtmp;
                ELSIF startaddr = 16#04# THEN
                    Timer0PRD <= regtmp;
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 5 ns;
            ELSIF bankaddr = 16#0198# THEN      -- Timer1 registers
                regtmp(1) := to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                regtmp(0) := to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                IF startaddr = 0 THEN
                    Timer1CTL <= regtmp;
                ELSIF startaddr = 16#04# THEN
                    Timer1PRD <= regtmp;
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 5 ns;
            ELSIF bankaddr = 16#01B5# THEN --McASP1 registers
                regtmp(1) := to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                regtmp(0) := to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                regtmpa := to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8) &
                           to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                CASE XROT1 IS
                    WHEN "000" =>
                        rotate := 0;
                    WHEN "001" =>
                        rotate := 4;
                    WHEN "010" =>
                        rotate := 8;
                    WHEN "011" =>
                        rotate := 12;
                    WHEN "100" =>
                        rotate := 16;
                    WHEN "101" =>
                        rotate := 20;
                    WHEN "110" =>
                        rotate := 24;
                    WHEN "111" =>
                        rotate := 28;
                    WHEN others =>
                        null;
                END CASE;
                IF startaddr = 16#0044# THEN
                    GBLCTL1(1) <= to_slv(CPUdata(3),8)&to_slv(CPUdata(2),8);
                    GBLCTL1(0) <= to_slv(CPUdata(1),8)&to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#0014# THEN
                    PDIR1 <= regtmpa;
                ELSIF startaddr = 16#004C# THEN
                    DLBCTL1(1) <= to_slv(CPUdata(3),8)&to_slv(CPUdata(2),8);
                    DLBCTL1(0) <= to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#0050# THEN
                    DITCTL1(1) <= to_slv(CPUdata(3),8)&to_slv(CPUdata(2),8);
                    DITCTL1(0) <= to_slv(CPUdata(1),8)&to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#0064# THEN
                    RMASK1 <= regtmpa;
                ELSIF startaddr = 16#0068# THEN
                    RFMT1(1) <= to_slv(CPUdata(3),8)&to_slv(CPUdata(2),8);
                    RFMT1(0) <= to_slv(CPUdata(1),8)&to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#006C# THEN
                    AFSRCTL1(1) <= to_slv(CPUdata(3),8)&to_slv(CPUdata(2),8);
                    AFSRCTL1(0) <= to_slv(CPUdata(1),8)&to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#0070# THEN
                    ACLKRCTL1(1) <= to_slv(CPUdata(3),8)& to_slv(CPUdata(2),8);
                    ACLKRCTL1(0) <= to_slv(CPUdata(1),8)&to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#0074# THEN
                    AHCLKRCTL1(1) <= to_slv(CPUdata(3),8)&to_slv(CPUdata(2),8);
                    AHCLKRCTL1(0) <= to_slv(CPUdata(1),8)&to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#0078# THEN
                    RTDM1 <= regtmpa;
                ELSIF startaddr = 16#00A4# THEN
                    XMASK1 <= regtmpa;
                ELSIF startaddr = 16#00A8# THEN
                    XFMT1(1) <= to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                    XFMT1(0) <= to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#00AC# THEN
                    AFSXCTL1(1) <= to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                    AFSXCTL1(0) <= to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#00B0# THEN
                    ACLKXCTL1(1) <= to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                    ACLKXCTL1(0) <= to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#00B4# THEN
                    AHCLKXCTL1(1) <= to_slv(CPUdata(3),8)&to_slv(CPUdata(2),8);
                    AHCLKXCTL1(0) <= to_slv(CPUdata(1),8)&to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#00B8# THEN
                    XTDM1 <= regtmpa;
                ELSIF startaddr = 16#0100# THEN
                    DITCSRA0 <= regtmpa;
                ELSIF startaddr = 16#0104# THEN
                    DITCSRA1 <= regtmpa;
                ELSIF startaddr = 16#0108# THEN
                    DITCSRA2 <= regtmpa;
                ELSIF startaddr = 16#010C# THEN
                    DITCSRA3 <= regtmpa;
                ELSIF startaddr = 16#0110# THEN
                    DITCSRA4 <= regtmpa;
                ELSIF startaddr = 16#0114# THEN
                    DITCSRA5 <= regtmpa;
                ELSIF startaddr = 16#0118# THEN
                    DITCSRB0 <= regtmpa;
                ELSIF startaddr = 16#011C# THEN
                    DITCSRB1 <= regtmpa;
                ELSIF startaddr = 16#0120# THEN
                    DITCSRB2 <= regtmpa;
                ELSIF startaddr = 16#0124# THEN
                    DITCSRB3 <= regtmpa;
                ELSIF startaddr = 16#0128# THEN
                    DITCSRB4 <= regtmpa;
                ELSIF startaddr = 16#012C# THEN
                    DITCSRB5 <= regtmpa;
                ELSIF startaddr = 16#0130# THEN
                    DITUDRA0 <= regtmpa;
                ELSIF startaddr = 16#0134# THEN
                    DITUDRA1 <= regtmpa;
                ELSIF startaddr = 16#0138# THEN
                    DITUDRA2 <= regtmpa;
                ELSIF startaddr = 16#013C# THEN
                    DITUDRA3 <= regtmpa;
                ELSIF startaddr = 16#0140# THEN
                    DITUDRA4 <= regtmpa;
                ELSIF startaddr = 16#0144# THEN
                    DITUDRA5 <= regtmpa;
                ELSIF startaddr = 16#0148# THEN
                    DITUDRB0 <= regtmpa;
                ELSIF startaddr = 16#014C# THEN
                    DITUDRB1 <= regtmpa;
                ELSIF startaddr = 16#0150# THEN
                    DITUDRB2 <= regtmpa;
                ELSIF startaddr = 16#0154# THEN
                    DITUDRB3 <= regtmpa;
                ELSIF startaddr = 16#0158# THEN
                    DITUDRB4 <= regtmpa;
                ELSIF startaddr = 16#015C# THEN
                    DITUDRB5 <= regtmpa;
                ELSIF startaddr = 16#0180# THEN
                    SRCTL01(1) <= to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                    SRCTL01(0) <= to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#0184# THEN
                    SRCTL11(1) <= to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                    SRCTL11(0) <= to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#0188# THEN
                    SRCTL21(1) <= to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                    SRCTL21(0) <= to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#018C# THEN
                    SRCTL31(1) <= to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                    SRCTL31(0) <= to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#0190# THEN
                    SRCTL41(1) <= to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                    SRCTL41(0) <= to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#0194# THEN
                    SRCTL51(1) <= to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                    SRCTL51(0) <= to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#0198# THEN
                    SRCTL61(1) <= to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                    SRCTL61(0) <= to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#019C# THEN
                    SRCTL71(1) <= to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                    SRCTL71(0) <= to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                ELSIF startaddr = 16#0200# AND XBUSEL1 = '1' THEN
                    XBUFTmp := regtmpa;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XBUFTmp(i) := '0';
                                WHEN "01" =>
                                    XBUFTmp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XBUFTmp(i) := regtmpa(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUF01(i) <= XBUFTmp(31 - i);
                        END LOOP;
                    ELSE
                        XBUF01 <= XBUFTmp;
                    END IF;
                    XRDY01 <= '0';
                ELSIF startaddr = 16#0204# AND XBUSEL1 = '1' THEN
                    XBUFTmp := regtmpa;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XBUFTmp(i) := '0';
                                WHEN "01" =>
                                    XBUFTmp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XBUFTmp(i) := regtmpa(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUF11(i) <= XBUFTmp(31 - i);
                        END LOOP;
                    ELSE
                        XBUF11 <= XBUFTmp;
                    END IF;
                    XRDY11 <= '0';
                ELSIF startaddr = 16#0208# AND XBUSEL1 = '1' THEN
                    XBUFTmp := regtmpa;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XBUFTmp(i) := '0';
                                WHEN "01" =>
                                    XBUFTmp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XBUFTmp(i) := regtmpa(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUF21(i) <= XBUFTmp(31 - i);
                        END LOOP;
                    ELSE
                        XBUF21 <= XBUFTmp;
                    END IF;
                    XRDY21 <= '0';
                ELSIF startaddr = 16#020C# AND XBUSEL1 = '1' THEN
                    XBUFTmp := regtmpa;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XBUFTmp(i) := '0';
                                WHEN "01" =>
                                    XBUFTmp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XBUFTmp(i) := regtmpa(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUF31(i) <= XBUFTmp(31 - i);
                        END LOOP;
                    ELSE
                        XBUF31 <= XBUFTmp;
                    END IF;
                    XRDY31 <= '0';
                ELSIF startaddr = 16#0210# AND XBUSEL1 = '1' THEN
                    XBUFTmp := regtmpa;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XBUFTmp(i) := '0';
                                WHEN "01" =>
                                    XBUFTmp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XBUFTmp(i) := regtmpa(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUF41(i) <= XBUFTmp(31 - i);
                        END LOOP;
                    ELSE
                        XBUF41 <= XBUFTmp;
                    END IF;
                    XRDY41 <= '0';
                ELSIF startaddr = 16#0214# AND XBUSEL1 = '1' THEN
                    XBUFTmp := regtmpa;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XBUFTmp(i) := '0';
                                WHEN "01" =>
                                    XBUFTmp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XBUFTmp(i) := regtmpa(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUF51(i) <= XBUFTmp(31 - i);
                        END LOOP;
                    ELSE
                        XBUF51 <= XBUFTmp;
                    END IF;
                    XRDY51 <= '0';
                ELSIF startaddr = 16#0218# AND XBUSEL1 = '1' THEN
                    XBUFTmp := regtmpa;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XBUFTmp(i) := '0';
                                WHEN "01" =>
                                    XBUFTmp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XBUFTmp(i) := regtmpa(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUF61(i) <= XBUFTmp(31 - i);
                        END LOOP;
                    ELSE
                        XBUF61 <= XBUFTmp;
                    END IF;
                    XRDY61 <= '0';
                ELSIF startaddr = 16#021C# AND XBUSEL1 = '1' THEN
                    XBUFTmp := regtmpa;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XBUFTmp(i) := '0';
                                WHEN "01" =>
                                    XBUFTmp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XBUFTmp(i) := regtmpa(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUF71(i) <= XBUFTmp(31 - i);
                        END LOOP;
                    ELSE
                        XBUF71 <= XBUFTmp;
                    END IF;
                    XRDY71 <= '0';
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 5 ns;
            ELSIF bankaddr = 16#01B7# THEN      -- PLL registers
                regtmp(1) := to_slv(CPUdata(3),8) & to_slv(CPUdata(2),8);
                regtmp(0) := to_slv(CPUdata(1),8) & to_slv(CPUdata(0),8);
                IF startaddr = 16#C000# THEN
                    PLLPID <= regtmp;
                ELSIF startaddr = 16#C100# THEN
                    PLLCSR <= regtmp;
                ELSIF startaddr = 16#C110# THEN
                    PLLMCR <= regtmp;
                ELSIF startaddr = 16#C114# THEN
                    PLLDIV0 <= regtmp;
                ELSIF startaddr = 16#C118# THEN
                    PLLDIV1 <= regtmp;
                ELSIF startaddr = 16#C11C# THEN
                    PLLDIV2 <= regtmp;
                ELSIF startaddr = 16#C120# THEN
                    PLLDIV3 <= regtmp;
                ELSIF startaddr = 16#C124# THEN
                    OSCDIV1 <= regtmp;
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 5 ns;
            ELSIF bankaddr > 16#BFFF# THEN     -- reserved
                ASSERT false
                    REPORT "attempt to write to reserved address space"
                    SEVERITY warning;
                DMAdone <= TRANSPORT '1' AFTER 5 ns;
            ELSIF bankaddr > 16#7FFF# THEN      -- EMIF
                IF bankaddr > 16#AFFF# THEN     -- external memory CE3
                    MSpace <= CE3;
                ELSIF bankaddr > 16#9FFF# THEN     -- external memory CE2
                    MSpace <= CE2;
                ELSIF bankaddr > 16#8FFF# THEN     -- external memory CE1
                    MSpace <= CE1;
                ELSE                            -- external memory CE0
                    MSpace <= CE0;
                END IF;
                EMdir <= write;
                EADDR <= To_Nat(addrword(27 downto 0));
                DMAOUTaddr <= addrword(30 downto 0);
                DMADATA(0) <= CPUdata(0);
                DMADATA(1) <= CPUdata(1);
                DMADATA(2) <= CPUdata(2);
                DMADATA(3) <= CPUdata(3);
                DMARDY <= '1';
                DMAburst <= false;
            END IF;
        WHEN RD =>
            DMAdone <= '0';
            xferdest := cpu;
            bankaddr := CPUaddr(1);
            startaddr := CPUaddr(0);
            addrword(31 downto 16) := to_slv(CPUaddr(1),16);
            addrword(15 downto 0) := to_slv(CPUaddr(0),16);
            IF bankaddr < 16#0004# THEN          -- L2 memory
                RDdata(0) <= L2Mem(startaddr);
                RDdata(1) <= L2Mem(startaddr + 1);
                RDdata(2) <= L2Mem(startaddr + 2);
                RDdata(3) <= L2Mem(startaddr + 3);
                DMAdone <= TRANSPORT '1' AFTER 2 ns;
            ELSIF bankaddr <16#0180# THEN     -- reserved
                ASSERT false
                REPORT "attempt to read from reserved address space"
                SEVERITY warning;
                DMAdone <= TRANSPORT '1' AFTER 2 ns;
            ELSIF bankaddr = 16#0180# THEN     -- EMIF registers
                IF startaddr = 16#00# THEN     -- EMIF global control reg
                    RDdata(0) <= to_nat(GBLCTL(0)(7 downto 0));
                    RDdata(1) <= to_nat(GBLCTL(0)(15 downto 8));
                    RDdata(2) <= to_nat(GBLCTL(1)(7 downto 0));
                    RDdata(3) <= to_nat(GBLCTL(1)(15 downto 8));
                ELSIF startaddr = 16#04# THEN     -- EMIF CE space control reg 1
                    RDdata(0) <= to_nat(CE1CTL(0)(7 downto 0));
                    RDdata(1) <= to_nat(CE1CTL(0)(15 downto 8));
                    RDdata(2) <= to_nat(CE1CTL(1)(7 downto 0));
                    RDdata(3) <= to_nat(CE1CTL(1)(15 downto 8));
                ELSIF startaddr = 16#08# THEN     -- EMIF CE space control reg 0
                    RDdata(0) <= to_nat(CE0CTL(0)(7 downto 0));
                    RDdata(1) <= to_nat(CE0CTL(0)(15 downto 8));
                    RDdata(2) <= to_nat(CE0CTL(1)(7 downto 0));
                    RDdata(3) <= to_nat(CE0CTL(1)(15 downto 8));
                ELSIF startaddr = 16#10# THEN    -- EMIF CE space control reg 2
                    RDdata(0) <= to_nat(CE2CTL(0)(7 downto 0));
                    RDdata(1) <= to_nat(CE2CTL(0)(15 downto 8));
                    RDdata(2) <= to_nat(CE2CTL(1)(7 downto 0));
                    RDdata(3) <= to_nat(CE2CTL(1)(15 downto 8));
                ELSIF startaddr = 16#14# THEN    -- EMIF CE space control reg 3
                    RDdata(0) <= to_nat(CE3CTL(0)(7 downto 0));
                    RDdata(1) <= to_nat(CE3CTL(0)(15 downto 8));
                    RDdata(2) <= to_nat(CE3CTL(1)(7 downto 0));
                    RDdata(3) <= to_nat(CE3CTL(1)(15 downto 8));
                ELSIF startaddr = 16#18# THEN    -- EMIF SDRAM control reg
                    RDdata(0) <= to_nat(SDCTL(0)(7 downto 0));
                    RDdata(1) <= to_nat(SDCTL(0)(15 downto 8));
                    RDdata(2) <= to_nat(SDCTL(1)(7 downto 0));
                    RDdata(3) <= to_nat(SDCTL(1)(15 downto 8));
                ELSIF startaddr = 16#1C# THEN    -- EMIF SDRAM timing reg
                    RDdata(0) <= to_nat(SDTIM(0)(7 downto 0));
                    RDdata(1) <= to_nat(SDTIM(0)(15 downto 8));
                    RDdata(2) <= to_nat(SDTIM(1)(7 downto 0));
                    RDdata(3) <= to_nat(SDTIM(1)(15 downto 8));
                ELSIF startaddr = 16#20# THEN    -- EMIF SDRAM extension reg
                    RDdata(0) <= to_nat(SDEXT(0)(7 downto 0));
                    RDdata(1) <= to_nat(SDEXT(0)(15 downto 8));
                    RDdata(2) <= to_nat(SDEXT(1)(7 downto 0));
                    RDdata(3) <= to_nat(SDEXT(1)(15 downto 8));
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 5 ns;
            ELSIF bankaddr <16#018C# THEN     -- reserved
                ASSERT false
                REPORT "attempt to read from reserved address space"
                SEVERITY warning;
                DMAdone <= TRANSPORT '1' AFTER 2 ns;
            ELSIF bankaddr = 16#018C# THEN  -- MsBSP0 registers
                IF startaddr = 16#00# THEN
                    RDdata(0) <= to_nat(DRR0(7 downto 0));
                    RDdata(1) <= to_nat(DRR0(15 downto 8));
                    RDdata(2) <= to_nat(DRR0(23 downto 16));
                    RDdata(3) <= to_nat(DRR0(31 downto 24));
                    RRDY <= '0';
                ELSIF startaddr = 16#08# THEN
                    RDdata(0) <= to_nat(SPCR0(0)(7 downto 0));
                    RDdata(1) <= to_nat(SPCR0(0)(15 downto 8));
                    RDdata(2) <= to_nat(SPCR0(1)(7 downto 0));
                    RDdata(3) <= to_nat(SPCR0(1)(15 downto 8));
                ELSIF startaddr = 16#0C# THEN
                    RDdata(0) <= to_nat(RCR0(0)(7 downto 0));
                    RDdata(1) <= to_nat(RCR0(0)(15 downto 8));
                    RDdata(2) <= to_nat(RCR0(1)(7 downto 0));
                    RDdata(3) <= to_nat(RCR0(1)(15 downto 8));
                ELSIF startaddr = 16#10# THEN
                    RDdata(0) <= to_nat(XCR0(0)(7 downto 0));
                    RDdata(1) <= to_nat(XCR0(0)(15 downto 8));
                    RDdata(2) <= to_nat(XCR0(1)(7 downto 0));
                    RDdata(3) <= to_nat(XCR0(1)(15 downto 8));
                ELSIF startaddr = 16#14# THEN
                    RDdata(0) <= to_nat(SRGR0(0)(7 downto 0));
                    RDdata(1) <= to_nat(SRGR0(0)(15 downto 8));
                    RDdata(2) <= to_nat(SRGR0(1)(7 downto 0));
                    RDdata(3) <= to_nat(SRGR0(1)(15 downto 8));
                ELSIF startaddr = 16#18# THEN
                    RDdata(0) <= to_nat(MCR0(0)(7 downto 0));
                    RDdata(1) <= to_nat(MCR0(0)(15 downto 8));
                    RDdata(2) <= to_nat(MCR0(1)(7 downto 0));
                    RDdata(3) <= to_nat(MCR0(1)(15 downto 8));
                ELSIF startaddr = 16#1C# THEN
                    RDdata(0) <= to_nat(RCER0(0)(7 downto 0));
                    RDdata(1) <= to_nat(RCER0(0)(15 downto 8));
                    RDdata(2) <= to_nat(RCER0(1)(7 downto 0));
                    RDdata(3) <= to_nat(RCER0(1)(15 downto 8));
                ELSIF startaddr = 16#20# THEN
                    RDdata(0) <= to_nat(XCER0(0)(7 downto 0));
                    RDdata(1) <= to_nat(XCER0(0)(15 downto 8));
                    RDdata(2) <= to_nat(XCER0(1)(7 downto 0));
                    RDdata(3) <= to_nat(XCER0(1)(15 downto 8));
                ELSIF startaddr = 16#24# THEN
                    RDdata(0) <= to_nat(PCR0(0)(7 downto 0));
                    RDdata(1) <= to_nat(PCR0(0)(15 downto 8));
                    RDdata(2) <= to_nat(PCR0(1)(7 downto 0));
                    RDdata(3) <= to_nat(PCR0(1)(15 downto 8));
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 2 ns;
            ELSIF bankaddr = 16#0190# THEN  -- MsBSP1 registers
                IF startaddr = 16#00# THEN
                    RDdata(0) <= to_nat(DRR1(7 downto 0));
                    RDdata(1) <= to_nat(DRR1(15 downto 8));
                    RDdata(2) <= to_nat(DRR1(23 downto 16));
                    RDdata(3) <= to_nat(DRR1(31 downto 24));
                ELSIF startaddr = 16#08# THEN
                    RDdata(0) <= to_nat(SPCR1(0)(7 downto 0));
                    RDdata(1) <= to_nat(SPCR1(0)(15 downto 8));
                    RDdata(2) <= to_nat(SPCR1(1)(7 downto 0));
                    RDdata(3) <= to_nat(SPCR1(1)(15 downto 8));
                ELSIF startaddr = 16#0C# THEN
                    RDdata(0) <= to_nat(RCR1(0)(7 downto 0));
                    RDdata(1) <= to_nat(RCR1(0)(15 downto 8));
                    RDdata(2) <= to_nat(RCR1(1)(7 downto 0));
                    RDdata(3) <= to_nat(RCR1(1)(15 downto 8));
                ELSIF startaddr = 16#10# THEN
                    RDdata(0) <= to_nat(XCR1(0)(7 downto 0));
                    RDdata(1) <= to_nat(XCR1(0)(15 downto 8));
                    RDdata(2) <= to_nat(XCR1(1)(7 downto 0));
                    RDdata(3) <= to_nat(XCR1(1)(15 downto 8));
                ELSIF startaddr = 16#14# THEN
                    RDdata(0) <= to_nat(SRGR1(0)(7 downto 0));
                    RDdata(1) <= to_nat(SRGR1(0)(15 downto 8));
                    RDdata(2) <= to_nat(SRGR1(1)(7 downto 0));
                    RDdata(3) <= to_nat(SRGR1(1)(15 downto 8));
                ELSIF startaddr = 16#18# THEN
                    RDdata(0) <= to_nat(MCR1(0)(7 downto 0));
                    RDdata(1) <= to_nat(MCR1(0)(15 downto 8));
                    RDdata(2) <= to_nat(MCR1(1)(7 downto 0));
                    RDdata(3) <= to_nat(MCR1(1)(15 downto 8));
                ELSIF startaddr = 16#1C# THEN
                    RDdata(0) <= to_nat(RCER1(0)(7 downto 0));
                    RDdata(1) <= to_nat(RCER1(0)(15 downto 8));
                    RDdata(2) <= to_nat(RCER1(1)(7 downto 0));
                    RDdata(3) <= to_nat(RCER1(1)(15 downto 8));
                ELSIF startaddr = 16#20# THEN
                    RDdata(0) <= to_nat(XCER1(0)(7 downto 0));
                    RDdata(1) <= to_nat(XCER1(0)(15 downto 8));
                    RDdata(2) <= to_nat(XCER1(1)(7 downto 0));
                    RDdata(3) <= to_nat(XCER1(1)(15 downto 8));
                ELSIF startaddr = 16#24# THEN
                    RDdata(0) <= to_nat(PCR1(0)(7 downto 0));
                    RDdata(1) <= to_nat(PCR1(0)(15 downto 8));
                    RDdata(2) <= to_nat(PCR1(1)(7 downto 0));
                    RDdata(3) <= to_nat(PCR1(1)(15 downto 8));
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 2 ns;
            ELSIF bankaddr = 16#0194# THEN     -- Timer0 registers
                IF startaddr = 0 THEN       -- CTL
                    RDdata(0) <= to_nat(Timer0CTL(0)(7 downto 0));
                    RDdata(1) <= to_nat(Timer0CTL(0)(15 downto 8));
                    RDdata(2) <= to_nat(Timer0CTL(1)(7 downto 0));
                    RDdata(3) <= to_nat(Timer0CTL(1)(15 downto 8));
                ELSIF startaddr = 16#04# THEN    -- PRD
                    RDdata(0) <= to_nat(Timer0PRD(0)(7 downto 0));
                    RDdata(1) <= to_nat(Timer0PRD(0)(15 downto 8));
                    RDdata(2) <= to_nat(Timer0PRD(1)(7 downto 0));
                    RDdata(3) <= to_nat(Timer0PRD(1)(15 downto 8));
                ELSIF startaddr = 16#08# THEN   -- CNT
                    RDdata(0) <= to_nat(Timer0CNT(0)(7 downto 0));
                    RDdata(1) <= to_nat(Timer0CNT(0)(15 downto 8));
                    RDdata(2) <= to_nat(Timer0CNT(1)(7 downto 0));
                    RDdata(3) <= to_nat(Timer0CNT(1)(15 downto 8));
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 2 ns;
            ELSIF bankaddr = 16#0198# THEN     -- Timer1 registers
                IF startaddr = 0 THEN       -- CTL
                    RDdata(0) <= to_nat(Timer1CTL(0)(7 downto 0));
                    RDdata(1) <= to_nat(Timer1CTL(0)(15 downto 8));
                    RDdata(2) <= to_nat(Timer1CTL(1)(7 downto 0));
                    RDdata(3) <= to_nat(Timer1CTL(1)(15 downto 8));
                ELSIF startaddr = 16#04# THEN    -- PRD
                    RDdata(0) <= to_nat(Timer1PRD(0)(7 downto 0));
                    RDdata(1) <= to_nat(Timer1PRD(0)(15 downto 8));
                    RDdata(2) <= to_nat(Timer1PRD(1)(7 downto 0));
                    RDdata(3) <= to_nat(Timer1PRD(1)(15 downto 8));
                ELSIF startaddr = 16#08# THEN   -- CNT
                    RDdata(0) <= to_nat(Timer1CNT(0)(7 downto 0));
                    RDdata(1) <= to_nat(Timer1CNT(0)(15 downto 8));
                    RDdata(2) <= to_nat(Timer1CNT(1)(7 downto 0));
                    RDdata(3) <= to_nat(Timer1CNT(1)(15 downto 8));
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 2 ns;
            ELSIF bankaddr = 16#01B5# THEN --McASP1 registers
                CASE XROT1 IS
                    WHEN "000" =>
                        rotate := 0;
                    WHEN "001" =>
                        rotate := 4;
                    WHEN "010" =>
                        rotate := 8;
                    WHEN "011" =>
                        rotate := 12;
                    WHEN "100" =>
                        rotate := 16;
                    WHEN "101" =>
                        rotate := 20;
                    WHEN "110" =>
                        rotate := 24;
                    WHEN "111" =>
                        rotate := 28;
                    WHEN others =>
                        null;
                END CASE;
                CASE RROT1 IS
                    WHEN "000" =>
                        rotater := 0;
                    WHEN "001" =>
                        rotater := 4;
                    WHEN "010" =>
                        rotater := 8;
                    WHEN "011" =>
                        rotater := 12;
                    WHEN "100" =>
                        rotater := 16;
                    WHEN "101" =>
                        rotater := 20;
                    WHEN "110" =>
                        rotater := 24;
                    WHEN "111" =>
                        rotater := 28;
                    WHEN others =>
                        null;
                END CASE;
                IF startaddr = 16#0044# THEN
                    RDdata(0) <= to_nat(GBLCTL1(0)(7 downto 0));
                    RDdata(1) <= to_nat(GBLCTL1(0)(15 downto 8));
                    RDdata(2) <= to_nat(GBLCTL1(1)(7 downto 0));
                    RDdata(3) <= to_nat(GBLCTL1(1)(15 downto 8));
                ELSIF startaddr = 16#00B0# THEN
                    RDdata(0) <= to_nat(ACLKXCTL1(0)(7 downto 0));
                    RDdata(1) <= to_nat(ACLKXCTL1(0)(15 downto 8));
                    RDdata(2) <= to_nat(ACLKXCTL1(1)(7 downto 0));
                    RDdata(3) <= to_nat(ACLKXCTL1(1)(15 downto 8));
                ELSIF startaddr = 16#0200# AND XBUSEL1 = '1' THEN
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUFTmp(i) := XBUF01(31 - i);
                        END LOOP;
                    ELSE
                        XBUFTmp := XBUF01;
                    END IF;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    XTemp := XBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XTemp(i) := '0';
                                WHEN "01" =>
                                    XTemp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XTemp(i) := XBUFTmp(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(XTemp(7 downto 0));
                    RDdata(1) <= to_nat(XTemp(15 downto 8));
                    RDdata(2) <= to_nat(XTemp(23 downto 16));
                    RDdata(3) <= to_nat(XTemp(31 downto 24));
                ELSIF startaddr = 16#0204# AND XBUSEL1 = '1' THEN
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUFTmp(i) := XBUF11(31 - i);
                        END LOOP;
                    ELSE
                        XBUFTmp := XBUF11;
                    END IF;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    XTemp := XBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XTemp(i) := '0';
                                WHEN "01" =>
                                    XTemp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XTemp(i) := XBUFTmp(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(XTemp(7 downto 0));
                    RDdata(1) <= to_nat(XTemp(15 downto 8));
                    RDdata(2) <= to_nat(XTemp(23 downto 16));
                    RDdata(3) <= to_nat(XTemp(31 downto 24));
                ELSIF startaddr = 16#0208# AND XBUSEL1 = '1' THEN
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUFTmp(i) := XBUF21(31 - i);
                        END LOOP;
                    ELSE
                        XBUFTmp := XBUF21;
                    END IF;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    XTemp := XBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XTemp(i) := '0';
                                WHEN "01" =>
                                    XTemp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XTemp(i) := XBUFTmp(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(XTemp(7 downto 0));
                    RDdata(1) <= to_nat(XTemp(15 downto 8));
                    RDdata(2) <= to_nat(XTemp(23 downto 16));
                    RDdata(3) <= to_nat(XTemp(31 downto 24));
                ELSIF startaddr = 16#020C# AND XBUSEL1 = '1' THEN
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUFTmp(i) := XBUF31(31 - i);
                        END LOOP;
                    ELSE
                        XBUFTmp := XBUF31;
                    END IF;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    XTemp := XBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XTemp(i) := '0';
                                WHEN "01" =>
                                    XTemp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XTemp(i) := XBUFTmp(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(XTemp(7 downto 0));
                    RDdata(1) <= to_nat(XTemp(15 downto 8));
                    RDdata(2) <= to_nat(XTemp(23 downto 16));
                    RDdata(3) <= to_nat(XTemp(31 downto 24));
                ELSIF startaddr = 16#0210# AND XBUSEL1 = '1' THEN
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUFTmp(i) := XBUF41(31 - i);
                        END LOOP;
                    ELSE
                        XBUFTmp := XBUF41;
                    END IF;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    XTemp := XBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XTemp(i) := '0';
                                WHEN "01" =>
                                    XTemp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XTemp(i) := XBUFTmp(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(XTemp(7 downto 0));
                    RDdata(1) <= to_nat(XTemp(15 downto 8));
                    RDdata(2) <= to_nat(XTemp(23 downto 16));
                    RDdata(3) <= to_nat(XTemp(31 downto 24));
                ELSIF startaddr = 16#0214# AND XBUSEL1 = '1' THEN
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUFTmp(i) := XBUF51(31 - i);
                        END LOOP;
                    ELSE
                        XBUFTmp := XBUF51;
                    END IF;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    XTemp := XBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XTemp(i) := '0';
                                WHEN "01" =>
                                    XTemp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XTemp(i) := XBUFTmp(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(XTemp(7 downto 0));
                    RDdata(1) <= to_nat(XTemp(15 downto 8));
                    RDdata(2) <= to_nat(XTemp(23 downto 16));
                    RDdata(3) <= to_nat(XTemp(31 downto 24));
                ELSIF startaddr = 16#0218# AND XBUSEL1 = '1' THEN
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUFTmp(i) := XBUF61(31 - i);
                        END LOOP;
                    ELSE
                        XBUFTmp := XBUF61;
                    END IF;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    XTemp := XBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XTemp(i) := '0';
                                WHEN "01" =>
                                    XTemp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XTemp(i) := XBUFTmp(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(XTemp(7 downto 0));
                    RDdata(1) <= to_nat(XTemp(15 downto 8));
                    RDdata(2) <= to_nat(XTemp(23 downto 16));
                    RDdata(3) <= to_nat(XTemp(31 downto 24));
                ELSIF startaddr = 16#021C# AND XBUSEL1 = '1' THEN
                    IF XRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            XBUFTmp(i) := XBUF71(31 - i);
                        END LOOP;
                    ELSE
                        XBUFTmp := XBUF71;
                    END IF;
                    FOR I IN (rotate - 1) DOWNTO 0 LOOP
                        zerobit := XBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            XBUFTmp(i - 1) := XBUFTmp(i);
                        END LOOP;
                        XBUFTmp(31) := zerobit;
                    END LOOP;
                    XTemp := XBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF XMASK1(i) = '0' THEN
                            CASE XPAD1 IS
                                WHEN "00" =>
                                    XTemp(i) := '0';
                                WHEN "01" =>
                                    XTemp(i) := '1';
                                WHEN "10" =>
                                    xbit := to_nat(XPBIT1);
                                    XTemp(i) := XBUFTmp(xbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(XTemp(7 downto 0));
                    RDdata(1) <= to_nat(XTemp(15 downto 8));
                    RDdata(2) <= to_nat(XTemp(23 downto 16));
                    RDdata(3) <= to_nat(XTemp(31 downto 24));
                ELSIF startaddr = 16#0280# AND RBUSEL1 = '1' THEN
                    IF RRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            RBUFTmp(i) := RBUF01(31 - i);
                        END LOOP;
                    ELSE
                        RBUFTmp := RBUF01;
                    END IF;
                    FOR I IN (rotater - 1) DOWNTO 0 LOOP
                        zerobit := RBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            RBUFTmp(i - 1) := RBUFTmp(i);
                        END LOOP;
                        RBUFTmp(31) := zerobit;
                    END LOOP;
                    RTemp := RBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF RMASK1(i) = '0' THEN
                            CASE RPAD1 IS
                                WHEN "00" =>
                                    RTemp(i) := '0';
                                WHEN "01" =>
                                    RTemp(i) := '1';
                                WHEN "10" =>
                                    rbit := to_nat(RPBIT1);
                                    RTemp(i) := RBUFTmp(rbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(RTemp(7 downto 0));
                    RDdata(1) <= to_nat(RTemp(15 downto 8));
                    RDdata(2) <= to_nat(RTemp(23 downto 16));
                    RDdata(3) <= to_nat(RTemp(31 downto 24));
                    RRDY01 <= '0';
                ELSIF startaddr = 16#0284# AND RBUSEL1 = '1' THEN
                    IF RRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            RBUFTmp(i) := RBUF11(31 - i);
                        END LOOP;
                    ELSE
                        RBUFTmp := RBUF11;
                    END IF;
                    FOR I IN (rotater - 1) DOWNTO 0 LOOP
                        zerobit := RBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            RBUFTmp(i - 1) := RBUFTmp(i);
                        END LOOP;
                        RBUFTmp(31) := zerobit;
                    END LOOP;
                    RTemp := RBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF RMASK1(i) = '0' THEN
                            CASE RPAD1 IS
                                WHEN "00" =>
                                    RTemp(i) := '0';
                                WHEN "01" =>
                                    RTemp(i) := '1';
                                WHEN "10" =>
                                    rbit := to_nat(RPBIT1);
                                    RTemp(i) := RBUFTmp(rbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(RTemp(7 downto 0));
                    RDdata(1) <= to_nat(RTemp(15 downto 8));
                    RDdata(2) <= to_nat(RTemp(23 downto 16));
                    RDdata(3) <= to_nat(RTemp(31 downto 24));
                    RRDY11 <= '0';
                ELSIF startaddr = 16#0288# AND RBUSEL1 = '1' THEN
                    IF RRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            RBUFTmp(i) := RBUF21(31 - i);
                        END LOOP;
                    ELSE
                        RBUFTmp := RBUF21;
                    END IF;
                    FOR I IN (rotater - 1) DOWNTO 0 LOOP
                        zerobit := RBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            RBUFTmp(i - 1) := RBUFTmp(i);
                        END LOOP;
                        RBUFTmp(31) := zerobit;
                    END LOOP;
                    RTemp := RBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF RMASK1(i) = '0' THEN
                            CASE RPAD1 IS
                                WHEN "00" =>
                                    RTemp(i) := '0';
                                WHEN "01" =>
                                    RTemp(i) := '1';
                                WHEN "10" =>
                                    rbit := to_nat(RPBIT1);
                                    RTemp(i) := RBUFTmp(rbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(RTemp(7 downto 0));
                    RDdata(1) <= to_nat(RTemp(15 downto 8));
                    RDdata(2) <= to_nat(RTemp(23 downto 16));
                    RDdata(3) <= to_nat(RTemp(31 downto 24));
                    RRDY21 <= '0';
                ELSIF startaddr = 16#028C# AND RBUSEL1 = '1' THEN
                    IF RRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            RBUFTmp(i) := RBUF31(31 - i);
                        END LOOP;
                    ELSE
                        RBUFTmp := RBUF31;
                    END IF;
                    FOR I IN (rotater - 1) DOWNTO 0 LOOP
                        zerobit := RBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            RBUFTmp(i - 1) := RBUFTmp(i);
                        END LOOP;
                        RBUFTmp(31) := zerobit;
                    END LOOP;
                    RTemp := RBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF RMASK1(i) = '0' THEN
                            CASE RPAD1 IS
                                WHEN "00" =>
                                    RTemp(i) := '0';
                                WHEN "01" =>
                                    RTemp(i) := '1';
                                WHEN "10" =>
                                    rbit := to_nat(RPBIT1);
                                    RTemp(i) := RBUFTmp(rbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(RTemp(7 downto 0));
                    RDdata(1) <= to_nat(RTemp(15 downto 8));
                    RDdata(2) <= to_nat(RTemp(23 downto 16));
                    RDdata(3) <= to_nat(RTemp(31 downto 24));
                    RRDY31 <= '0';
                ELSIF startaddr = 16#0290# AND RBUSEL1 = '1' THEN
                    IF RRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            RBUFTmp(i) := RBUF41(31 - i);
                        END LOOP;
                    ELSE
                        RBUFTmp := RBUF41;
                    END IF;
                    FOR I IN (rotater - 1) DOWNTO 0 LOOP
                        zerobit := RBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            RBUFTmp(i - 1) := RBUFTmp(i);
                        END LOOP;
                        RBUFTmp(31) := zerobit;
                    END LOOP;
                    RTemp := RBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF RMASK1(i) = '0' THEN
                            CASE RPAD1 IS
                                WHEN "00" =>
                                    RTemp(i) := '0';
                                WHEN "01" =>
                                    RTemp(i) := '1';
                                WHEN "10" =>
                                    rbit := to_nat(RPBIT1);
                                    RTemp(i) := RBUFTmp(rbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(RTemp(7 downto 0));
                    RDdata(1) <= to_nat(RTemp(15 downto 8));
                    RDdata(2) <= to_nat(RTemp(23 downto 16));
                    RDdata(3) <= to_nat(RTemp(31 downto 24));
                    RRDY41 <= '0';
                ELSIF startaddr = 16#0294# AND RBUSEL1 = '1' THEN
                    IF RRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            RBUFTmp(i) := RBUF51(31 - i);
                        END LOOP;
                    ELSE
                        RBUFTmp := RBUF51;
                    END IF;
                    FOR I IN (rotater - 1) DOWNTO 0 LOOP
                        zerobit := RBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            RBUFTmp(i - 1) := RBUFTmp(i);
                        END LOOP;
                        RBUFTmp(31) := zerobit;
                    END LOOP;
                    RTemp := RBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF RMASK1(i) = '0' THEN
                            CASE RPAD1 IS
                                WHEN "00" =>
                                    RTemp(i) := '0';
                                WHEN "01" =>
                                    RTemp(i) := '1';
                                WHEN "10" =>
                                    rbit := to_nat(RPBIT1);
                                    RTemp(i) := RBUFTmp(rbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(RTemp(7 downto 0));
                    RDdata(1) <= to_nat(RTemp(15 downto 8));
                    RDdata(2) <= to_nat(RTemp(23 downto 16));
                    RDdata(3) <= to_nat(RTemp(31 downto 24));
                    RRDY51 <= '0';
                ELSIF startaddr = 16#0298# AND RBUSEL1 = '1' THEN
                    IF RRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            RBUFTmp(i) := RBUF61(31 - i);
                        END LOOP;
                    ELSE
                        RBUFTmp := RBUF61;
                    END IF;
                    FOR I IN (rotater - 1) DOWNTO 0 LOOP
                        zerobit := RBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            RBUFTmp(i - 1) := RBUFTmp(i);
                        END LOOP;
                        RBUFTmp(31) := zerobit;
                    END LOOP;
                    RTemp := RBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF RMASK1(i) = '0' THEN
                            CASE RPAD1 IS
                                WHEN "00" =>
                                    RTemp(i) := '0';
                                WHEN "01" =>
                                    RTemp(i) := '1';
                                WHEN "10" =>
                                    rbit := to_nat(RPBIT1);
                                    RTemp(i) := RBUFTmp(rbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(RTemp(7 downto 0));
                    RDdata(1) <= to_nat(RTemp(15 downto 8));
                    RDdata(2) <= to_nat(RTemp(23 downto 16));
                    RDdata(3) <= to_nat(RTemp(31 downto 24));
                    RRDY61 <= '0';
                ELSIF startaddr = 16#029C# AND RBUSEL1 = '1' THEN
                    IF RRVRS1 = '1' THEN
                        FOR I IN 0 TO 31 LOOP
                            RBUFTmp(i) := RBUF71(31 - i);
                        END LOOP;
                    ELSE
                        RBUFTmp := RBUF71;
                    END IF;
                    FOR I IN (rotater - 1) DOWNTO 0 LOOP
                        zerobit := RBUFTmp(0);
                        FOR I IN 1 TO 31 LOOP
                            RBUFTmp(i - 1) := RBUFTmp(i);
                        END LOOP;
                        RBUFTmp(31) := zerobit;
                    END LOOP;
                    RTemp := RBUFTmp;
                    FOR I IN 31 DOWNTO 0 LOOP
                        IF RMASK1(i) = '0' THEN
                            CASE RPAD1 IS
                                WHEN "00" =>
                                    RTemp(i) := '0';
                                WHEN "01" =>
                                    RTemp(i) := '1';
                                WHEN "10" =>
                                    rbit := to_nat(RPBIT1);
                                    RTemp(i) := RBUFTmp(rbit);
                                WHEN others =>
                                    null;
                            END CASE;
                        END IF;
                    END LOOP;
                    RDdata(0) <= to_nat(RTemp(7 downto 0));
                    RDdata(1) <= to_nat(RTemp(15 downto 8));
                    RDdata(2) <= to_nat(RTemp(23 downto 16));
                    RDdata(3) <= to_nat(RTemp(31 downto 24));
                    RRDY71 <= '0';
                END IF;
                DMAdone <= TRANSPORT '1' AFTER 2 ns;
            ELSIF bankaddr > 16#BFFF# THEN     -- reserved
                ASSERT false
                REPORT "attempt to read from reserved address space"
                SEVERITY warning;
                DMAdone <= TRANSPORT '1' AFTER 2 ns;
            ELSIF bankaddr > 16#7FFF# THEN     -- EMIF
                IF bankaddr > 16#AFFF# THEN     -- external memory CE3
                    MSpace <= CE3;
                ELSIF bankaddr > 16#9FFF# THEN     -- external memory CE2
                    MSpace <= CE2;
                ELSIF bankaddr > 16#8FFF# THEN     -- external memory CE1
                    MSpace <= CE1;
                ELSE                            -- external memory CE0
                    MSpace <= CE0;
                END IF;
                EMdir <= read;
                EADDR <= To_Nat(addrword(27 downto 0));
                DMAOUTaddr <= addrword(30 downto 0);
                DMARDY <= '1';
                DMAburst <= false;
            END IF;
        WHEN MV => -- memory move
            xferdest := mem;
            bankaddr := CPUaddr(1);
            startaddr := CPUaddr(0);
            srcaddr(31 downto 16) := to_slv(CPUaddr(1),16);
            srcaddr(15 downto 0) := to_slv(CPUaddr(0),16);
            destaddr(31 downto 24) := to_slv(CPUdata(3),8);
            destaddr(23 downto 16) := to_slv(CPUdata(2),8);
            destaddr(15 downto 8) := to_slv(CPUdata(1),8);
            destaddr(7 downto 0) := to_slv(CPUdata(0),8);
            destbank := to_nat(destaddr(31 downto 16));
            deststart := to_nat(destaddr(15 downto 0));
            word_cnt := CPUsize;
            word_cnt_wrt := CPUsize;
            xferphase := read;
            mv_loop := true;
        END CASE;
    END IF;

    END PROCESS EDMA;

    ----------------------------------------------------------------------------
    -- Host Port Interface
    ----------------------------------------------------------------------------
    HPI : PROCESS(HCSNeg, HDS1Neg, HDS2Neg, HASNeg, HDIn, HHWIL, HCNTL, HR,
                  HSTROBENeg, HSTROB_int, HPIC, HPI_flag, HPIDacc, RESET_int,
                  DSPclear, HRDY, HPI_EN, AUXCLK, AHCLKXTmp, XCLKDIV, XCLK,
                  RCLK, FSX1_int, FSR1_int, AMUTEIN1, ROVERN1, RSYNC1, XSYNC1,
                  XUNDERN1, AHCLKX1In, AHCLKR1In, SYSCLK2R, SYSCLK2X, XCKFL1,
                  RCKFL1, AHCLKRTmp)

    VARIABLE halfword    : UX01 := '0';           -- registered HHWIL
    VARIABLE read        : UX01;                  -- registered HR
    VARIABLE cntl_sel    : NATURAL RANGE 0 to 3;  -- registered HCNTL
    VARIABLE HPIA_tmp    : NATURAL;

    VARIABLE FSX         : std_ulogic := '0';
    VARIABLE FSXTmp      : std_ulogic := '0';
    VARIABLE FSR         : std_ulogic := '0';
    VARIABLE AMUTEIN_int : std_ulogic := '0';
    VARIABLE div         : NATURAL := 0;
    VARIABLE divr        : NATURAL := 0;
    VARIABLE Previous    : Time := 0 ns;
    VARIABLE PreviousR   : Time := 0 ns;
    VARIABLE fsxcnt      : NATURAL := 0;
    VARIABLE fsrcnt      : NATURAL := 0;
    VARIABLE slotsize    : NATURAL := 0;
    VARIABLE slotsizer   : NATURAL := 0;
    VARIABLE fsxsize     : NATURAL := 0;
    VARIABLE fsrsize     : NATURAL := 0;
    VARIABLE mode        : NATURAL := 0;
    VARIABLE moder       : NATURAL := 0;
    VARIABLE bitcnt0     : NATURAL := 0;
    VARIABLE slotcnt0    : NATURAL := 0;
    VARIABLE bitcnt1     : NATURAL := 0;
    VARIABLE slotcnt1    : NATURAL := 0;
    VARIABLE bitcnt2     : NATURAL := 0;
    VARIABLE slotcnt2    : NATURAL := 0;
    VARIABLE bitcnt3     : NATURAL := 0;
    VARIABLE slotcnt3    : NATURAL := 0;
    VARIABLE bitcnt4     : NATURAL := 0;
    VARIABLE slotcnt4    : NATURAL := 0;
    VARIABLE bitcnt5     : NATURAL := 0;
    VARIABLE slotcnt5    : NATURAL := 0;
    VARIABLE bitcnt6     : NATURAL := 0;
    VARIABLE slotcnt6    : NATURAL := 0;
    VARIABLE bitcnt7     : NATURAL := 0;
    VARIABLE slotcnt7    : NATURAL := 0;
    VARIABLE framecnt0   : NATURAL := 0;
    VARIABLE framecnt1   : NATURAL := 0;
    VARIABLE framecnt2   : NATURAL := 0;
    VARIABLE framecnt3   : NATURAL := 0;
    VARIABLE framecnt4   : NATURAL := 0;
    VARIABLE framecnt5   : NATURAL := 0;
    VARIABLE framecnt6   : NATURAL := 0;
    VARIABLE framecnt7   : NATURAL := 0;
    VARIABLE bitcntr0    : NATURAL := 0;
    VARIABLE slotcntr0   : NATURAL := 0;
    VARIABLE bitcntr1    : NATURAL := 0;
    VARIABLE slotcntr1   : NATURAL := 0;
    VARIABLE bitcntr2    : NATURAL := 0;
    VARIABLE slotcntr2   : NATURAL := 0;
    VARIABLE bitcntr3    : NATURAL := 0;
    VARIABLE slotcntr3   : NATURAL := 0;
    VARIABLE bitcntr4    : NATURAL := 0;
    VARIABLE slotcntr4   : NATURAL := 0;
    VARIABLE bitcntr5    : NATURAL := 0;
    VARIABLE slotcntr5   : NATURAL := 0;
    VARIABLE bitcntr6    : NATURAL := 0;
    VARIABLE slotcntr6   : NATURAL := 0;
    VARIABLE bitcntr7    : NATURAL := 0;
    VARIABLE slotcntr7   : NATURAL := 0;
    VARIABLE delayx      : NATURAL := 0;
    VARIABLE syncxcnt    : NATURAL := 0;
    VARIABLE syncxcnt1   : NATURAL := 0;
    VARIABLE syncxcnt2   : NATURAL := 0;
    VARIABLE syncxcnt3   : NATURAL := 0;
    VARIABLE syncxcnt4   : NATURAL := 0;
    VARIABLE syncxcnt5   : NATURAL := 0;
    VARIABLE syncxcnt6   : NATURAL := 0;
    VARIABLE syncxcnt7   : NATURAL := 0;
    VARIABLE delayr      : NATURAL := 0;
    VARIABLE syncrcnt    : NATURAL := 0;
    VARIABLE syncrcnt1   : NATURAL := 0;
    VARIABLE syncrcnt2   : NATURAL := 0;
    VARIABLE syncrcnt3   : NATURAL := 0;
    VARIABLE syncrcnt4   : NATURAL := 0;
    VARIABLE syncrcnt5   : NATURAL := 0;
    VARIABLE syncrcnt6   : NATURAL := 0;
    VARIABLE syncrcnt7   : NATURAL := 0;
    VARIABLE xhcnt       : NATURAL := 0;
    VARIABLE rhcnt       : NATURAL := 0;
    VARIABLE mastercntr  : NATURAL := 0;
    VARIABLE mastercntx  : NATURAL := 0;
    VARIABLE beginfrx    : BOOLEAN := false;
    VARIABLE beginfrr    : BOOLEAN := false;
    VARIABLE startflagx  : BOOLEAN := false;
    VARIABLE startflagx1 : BOOLEAN := false;
    VARIABLE startflagx2 : BOOLEAN := false;
    VARIABLE startflagx3 : BOOLEAN := false;
    VARIABLE startflagx4 : BOOLEAN := false;
    VARIABLE startflagx5 : BOOLEAN := false;
    VARIABLE startflagx6 : BOOLEAN := false;
    VARIABLE startflagx7 : BOOLEAN := false;
    VARIABLE startburstx : BOOLEAN := false;
    VARIABLE startburstx1 : BOOLEAN := false;
    VARIABLE startburstx2 : BOOLEAN := false;
    VARIABLE startburstx3 : BOOLEAN := false;
    VARIABLE startburstx4 : BOOLEAN := false;
    VARIABLE startburstx5 : BOOLEAN := false;
    VARIABLE startburstx6 : BOOLEAN := false;
    VARIABLE startburstx7 : BOOLEAN := false;
    VARIABLE startflagr1 : BOOLEAN := false;
    VARIABLE startflagr2 : BOOLEAN := false;
    VARIABLE startflagr3 : BOOLEAN := false;
    VARIABLE startflagr4 : BOOLEAN := false;
    VARIABLE startflagr5 : BOOLEAN := false;
    VARIABLE startflagr6 : BOOLEAN := false;
    VARIABLE startflagr7 : BOOLEAN := false;
    VARIABLE startflagr  : BOOLEAN := false;
    VARIABLE startburstr : BOOLEAN := false;
    VARIABLE startburstr1 : BOOLEAN := false;
    VARIABLE startburstr2 : BOOLEAN := false;
    VARIABLE startburstr3 : BOOLEAN := false;
    VARIABLE startburstr4 : BOOLEAN := false;
    VARIABLE startburstr5 : BOOLEAN := false;
    VARIABLE startburstr6 : BOOLEAN := false;
    VARIABLE startburstr7 : BOOLEAN := false;
    VARIABLE transmit    : BOOLEAN := false;
    VARIABLE transmit1   : BOOLEAN := false;
    VARIABLE transmit2   : BOOLEAN := false;
    VARIABLE transmit3   : BOOLEAN := false;
    VARIABLE transmit4   : BOOLEAN := false;
    VARIABLE transmit5   : BOOLEAN := false;
    VARIABLE transmit6   : BOOLEAN := false;
    VARIABLE transmit7   : BOOLEAN := false;
    VARIABLE receive     : BOOLEAN := false;
    VARIABLE receive1    : BOOLEAN := false;
    VARIABLE receive2    : BOOLEAN := false;
    VARIABLE receive3    : BOOLEAN := false;
    VARIABLE receive4    : BOOLEAN := false;
    VARIABLE receive5    : BOOLEAN := false;
    VARIABLE receive6    : BOOLEAN := false;
    VARIABLE receive7    : BOOLEAN := false;
    VARIABLE Comparex    : BOOLEAN := false;
    VARIABLE Comparer    : BOOLEAN := false;
    VARIABLE subframe0   : std_ulogic := '0';
    VARIABLE subframe1   : std_ulogic := '0';
    VARIABLE subframe2   : std_ulogic := '0';
    VARIABLE subframe3   : std_ulogic := '0';
    VARIABLE subframe4   : std_ulogic := '0';
    VARIABLE subframe5   : std_ulogic := '0';
    VARIABLE subframe6   : std_ulogic := '0';
    VARIABLE subframe7   : std_ulogic := '0';
    VARIABLE XSR01Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE XSR11Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE XSR21Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE XSR31Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE XSR41Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE XSR51Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE XSR61Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE XSR71Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE RSR01Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE RSR11Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE RSR21Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE RSR31Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE RSR41Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE RSR51Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE RSR61Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE RSR71Tmp    : std_logic_vector(31 downto 0)
                            := (others => '0');
    VARIABLE TMPReg1     : std_logic_vector(27 downto 0);
    VARIABLE TMPReg2     : std_logic_vector(27 downto 0);
    VARIABLE TMPReg3     : std_logic_vector(27 downto 0);
    VARIABLE TMPReg4     : std_logic_vector(27 downto 0);
    VARIABLE TMPReg5     : std_logic_vector(27 downto 0);
    VARIABLE TMPReg6     : std_logic_vector(27 downto 0);
    VARIABLE TMPReg7     : std_logic_vector(27 downto 0);
    VARIABLE TMPReg      : std_logic_vector(27 downto 0);
    VARIABLE TmpReg56    : std_logic_vector(55 downto 0);
    VARIABLE Tmp1Reg56   : std_logic_vector(55 downto 0);
    VARIABLE Tmp2Reg56   : std_logic_vector(55 downto 0);
    VARIABLE Tmp3Reg56   : std_logic_vector(55 downto 0);
    VARIABLE Tmp4Reg56   : std_logic_vector(55 downto 0);
    VARIABLE Tmp5Reg56   : std_logic_vector(55 downto 0);
    VARIABLE Tmp6Reg56   : std_logic_vector(55 downto 0);
    VARIABLE Tmp7Reg56   : std_logic_vector(55 downto 0);
    VARIABLE Reg64       : std_logic_vector(63 downto 0);
    VARIABLE Reg1        : std_logic_vector(63 downto 0);
    VARIABLE Reg2        : std_logic_vector(63 downto 0);
    VARIABLE Reg3        : std_logic_vector(63 downto 0);
    VARIABLE Reg4        : std_logic_vector(63 downto 0);
    VARIABLE Reg5        : std_logic_vector(63 downto 0);
    VARIABLE Reg6        : std_logic_vector(63 downto 0);
    VARIABLE Reg7        : std_logic_vector(63 downto 0);

    -- Timing Check Variables
    VARIABLE Tviol_HCNTL_HASNeg         : X01 := '0';
    VARIABLE TD_HCNTL_HASNeg            : VitalTimingDataType;

    VARIABLE Tviol_HR_HASNeg            : X01 := '0';
    VARIABLE TD_HR_HASNeg               : VitalTimingDataType;

    VARIABLE Tviol_HHWIL_HASNeg         : X01 := '0';
    VARIABLE TD_HHWIL_HASNeg            : VitalTimingDataType;

    VARIABLE Tviol_HCNTL_HSTROBENeg     : X01 := '0';
    VARIABLE TD_HCNTL_HSTROBENeg        : VitalTimingDataType;

    VARIABLE Tviol_HR_HSTROBENeg        : X01 := '0';
    VARIABLE TD_HR_HSTROBENeg           : VitalTimingDataType;

    VARIABLE Tviol_HHWIL_HSTROBENeg     : X01 := '0';
    VARIABLE TD_HHWIL_HSTROBENeg        : VitalTimingDataType;

    VARIABLE Tviol_HDIn_HSTROBENeg      : X01 := '0';
    VARIABLE TD_HDIn_HSTROBENeg         : VitalTimingDataType;

    VARIABLE Tviol_HSTROBENeg_HRDYNeg   : X01 := '0';
    VARIABLE TD_HSTROBENeg_HRDYNeg      : VitalTimingDataType;

    VARIABLE Tviol_AXR1In0_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR1In0_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR10_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR10_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR1In1_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR1In1_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR11_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR11_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR1In2_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR1In2_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR12_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR12_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR1In3_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR1In3_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR13_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR13_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR1In4_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR1In4_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR14_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR14_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR1In5_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR1In5_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR15_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR15_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR1In6_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR1In6_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR16_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR16_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR1In7_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR1In7_ACLKR1      : VitalTimingDataType;

    VARIABLE Tviol_AXR17_ACLKR1   : X01 := '0';
    VARIABLE TD_AXR17_ACLKR1      : VitalTimingDataType;

    VARIABLE PD_HSTROBENeg        : VitalPeriodDataType := VitalPeriodDataInit;
    VARIABLE Pviol_HSTROBENeg     : X01 := '0';

    VARIABLE PD_ACLKR1In    : VitalPeriodDataType := VitalPeriodDataInit;
    VARIABLE Pviol_ACLKR1In : X01 := '0';

    VARIABLE PD_ACLKX1In    : VitalPeriodDataType := VitalPeriodDataInit;
    VARIABLE Pviol_ACLKX1In : X01 := '0';

    VARIABLE PD_AHCLKX1In   : VitalPeriodDataType := VitalPeriodDataInit;
    VARIABLE Pviol_AHCLKX1In : X01 := '0';

    VARIABLE PD_AHCLKR1In   : VitalPeriodDataType := VitalPeriodDataInit;
    VARIABLE Pviol_AHCLKR1In : X01 := '0';

    VARIABLE Violation               : X01 := '0';

    -- Functionality Results Variables
    VARIABLE HRDYNeg_zd      : std_ulogic := 'U';
    VARIABLE HINTNeg_zd      : std_ulogic := 'U';
    VARIABLE AXR1Out0_zd     : std_ulogic := 'U';
    VARIABLE AXR1Out1_zd     : std_ulogic := 'U';
    VARIABLE AXR1Out2_zd     : std_ulogic := 'U';
    VARIABLE AXR1Out3_zd     : std_ulogic := 'U';
    VARIABLE AXR1Out4_zd     : std_ulogic := 'U';
    VARIABLE AXR1Out5_zd     : std_ulogic := 'U';
    VARIABLE AXR1Out6_zd     : std_ulogic := 'U';
    VARIABLE AXR1Out7_zd     : std_ulogic := 'U';
    -- Output Glitch Detection Variables
    VARIABLE HRDYNeg_GlitchData   : VitalGlitchDataType;
    VARIABLE HINTNeg_GlitchData   : VitalGlitchDataType;
    VARIABLE AXR1Out0_GlitchData  : VitalGlitchDataType;
    VARIABLE AXR1Out1_GlitchData  : VitalGlitchDataType;
    VARIABLE AXR1Out2_GlitchData  : VitalGlitchDataType;
    VARIABLE AXR1Out3_GlitchData  : VitalGlitchDataType;
    VARIABLE AXR1Out4_GlitchData  : VitalGlitchDataType;
    VARIABLE AXR1Out5_GlitchData  : VitalGlitchDataType;
    VARIABLE AXR1Out6_GlitchData  : VitalGlitchDataType;
    VARIABLE AXR1Out7_GlitchData  : VitalGlitchDataType;

    BEGIN

    ----------------------------------------------------------------------------
    -- Timing Check Section
    ----------------------------------------------------------------------------

    IF  (TimingChecksOn) THEN

        VitalSetupHoldCheck (
          TestSignal      =>  HCNTL,
          TestSignalName  => "HCNTL",
          RefSignal       =>  HASNeg,
          RefSignalName   =>  "HASNeg",
          SetupHigh       =>  tsetup_HR_HASNeg,
          SetupLow        =>  tsetup_HR_HASNeg,
          HoldHigh        =>  thold_HR_HASNeg,
          HoldLow         =>  thold_HR_HASNeg,
          CheckEnabled    =>  HPI_EN = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_HCNTL_HASNeg ,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_HCNTL_HASNeg );

        VitalSetupHoldCheck (
          TestSignal      =>  HR,
          TestSignalName  => "HR",
          RefSignal       =>  HASNeg,
          RefSignalName   =>  "HASNeg",
          SetupHigh       =>  tsetup_HR_HASNeg,
          SetupLow        =>  tsetup_HR_HASNeg,
          HoldHigh        =>  thold_HR_HASNeg,
          HoldLow         =>  thold_HR_HASNeg,
          CheckEnabled    =>  HPI_EN = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_HR_HASNeg ,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_HR_HASNeg );

        VitalSetupHoldCheck (
          TestSignal      =>  HHWIL,
          TestSignalName  => "HHWIL",
          RefSignal       =>  HASNeg,
          RefSignalName   =>  "HASNeg",
          SetupHigh       =>  tsetup_HR_HASNeg,
          SetupLow        =>  tsetup_HR_HASNeg,
          HoldHigh        =>  thold_HR_HASNeg,
          HoldLow         =>  thold_HR_HASNeg,
          CheckEnabled    =>  HPI_EN = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_HHWIL_HASNeg ,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_HHWIL_HASNeg );

        VitalSetupHoldCheck (
          TestSignal      =>  HCNTL,
          TestSignalName  => "HCNTL",
          RefSignal       =>  HSTROBENeg,
          RefSignalName   =>  "HSTROBENeg",
          SetupHigh       =>  tsetup_HR_HCSNeg,
          SetupLow        =>  tsetup_HR_HCSNeg,
          HoldHigh        =>  thold_HR_HCSNeg,
          HoldLow         =>  thold_HR_HCSNeg,
          CheckEnabled    =>  HPI_EN = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_HCNTL_HSTROBENeg ,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_HCNTL_HSTROBENeg );

        VitalSetupHoldCheck (
          TestSignal      =>  HR,
          TestSignalName  => "HR",
          RefSignal       =>  HSTROBENeg,
          RefSignalName   =>  "HSTROBENeg",
          SetupHigh       =>  tsetup_HR_HCSNeg,
          SetupLow        =>  tsetup_HR_HCSNeg,
          HoldHigh        =>  thold_HR_HCSNeg,
          HoldLow         =>  thold_HR_HCSNeg,
          CheckEnabled    =>  HPI_EN = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_HR_HSTROBENeg ,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_HR_HSTROBENeg );

        VitalSetupHoldCheck (
          TestSignal      =>  HHWIL,
          TestSignalName  => "HHWIL",
          RefSignal       =>  HSTROBENeg,
          RefSignalName   =>  "HSTROBENeg",
          SetupHigh       =>  tsetup_HR_HCSNeg,
          SetupLow        =>  tsetup_HR_HCSNeg,
          HoldHigh        =>  thold_HR_HCSNeg,
          HoldLow         =>  thold_HR_HCSNeg,
          CheckEnabled    =>  HPI_EN = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_HHWIL_HSTROBENeg ,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_HHWIL_HSTROBENeg );

        VitalSetupHoldCheck (
          TestSignal      =>  HDIn,
          TestSignalName  => "HDIn",
          RefSignal       =>  HSTROBENeg,
          RefSignalName   =>  "HSTROBENeg",
          SetupHigh       =>  tsetup_HD0_HCSNeg,
          SetupLow        =>  tsetup_HD0_HCSNeg,
          HoldHigh        =>  thold_HD0_HCSNeg,
          HoldLow         =>  thold_HD0_HCSNeg,
          CheckEnabled    =>  HPI_EN = '1',
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_HDIn_HSTROBENeg ,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_HDIn_HSTROBENeg );

        VitalSetupHoldCheck (
          TestSignal      =>  HSTROBENeg,
          TestSignalName  => "HSTROBENeg",
          RefSignal       =>  HRDYNeg_int,
          RefSignalName   =>  "HRDYNeg_int",
          HoldLow         =>  thold_HCSNeg_HRDYNeg,
          CheckEnabled    =>  HPI_EN = '1',
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_HSTROBENeg_HRDYNeg ,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_HSTROBENeg_HRDYNeg );

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In0,
          TestSignalName  => "AXR1IN0",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '1'
                              AND SRMOD01 = "10" AND CLKRM = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR1In0_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR1In0_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In0,
          TestSignalName  => "AXR1IN0",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '0'
                              AND SRMOD01 = "10" AND CLKRM = '1',
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR10_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR10_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In1,
          TestSignalName  => "AXR1IN1",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '1'
                              AND SRMOD11 = "10" AND CLKRM = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR1In1_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR1In1_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In1,
          TestSignalName  => "AXR1IN1",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '0'
                              AND SRMOD11 = "10" AND CLKRM = '1',
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR11_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR11_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In2,
          TestSignalName  => "AXR1IN2",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '1'
                              AND SRMOD21 = "10" AND CLKRM = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR1In2_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR1In2_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In2,
          TestSignalName  => "AXR1IN2",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '0'
                              AND SRMOD21 = "10" AND CLKRM = '1',
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR12_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR12_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In3,
          TestSignalName  => "AXR1IN3",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '1'
                              AND SRMOD31 = "10" AND CLKRM = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR1In3_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR1In3_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In3,
          TestSignalName  => "AXR1IN3",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '0'
                              AND SRMOD31 = "10" AND CLKRM = '1',
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR13_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR13_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In4,
          TestSignalName  => "AXR1IN4",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '1'
                              AND SRMOD41 = "10" AND CLKRM = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR1In4_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR1In4_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In4,
          TestSignalName  => "AXR1IN4",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '0'
                              AND SRMOD41 = "10" AND CLKRM = '1',
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR14_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR14_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In5,
          TestSignalName  => "AXR1IN5",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '1'
                              AND SRMOD51 = "10" AND CLKRM = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR1In5_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR1In5_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In5,
          TestSignalName  => "AXR1IN5",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '0'
                              AND SRMOD51 = "10" AND CLKRM = '1',
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR15_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR15_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In6,
          TestSignalName  => "AXR1IN6",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '1'
                              AND SRMOD61 = "10" AND CLKRM = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR1In6_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR1In6_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In6,
          TestSignalName  => "AXR1IN6",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '0'
                              AND SRMOD61 = "10" AND CLKRM = '1',
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR16_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR16_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In7,
          TestSignalName  => "AXR1IN7",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '1'
                              AND SRMOD71 = "10" AND CLKRM = '1',
          RefTransition   =>  '\',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR1In7_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR1In7_ACLKR1);

        VitalSetupHoldCheck (
          TestSignal      =>  AXR1In7,
          TestSignalName  => "AXR1IN7",
          RefSignal       =>  ACLKR1In,
          RefSignalName   =>  "ACLKR1",
          SetupHigh       =>  tsetup_AXR1In_ACLKR1,
          SetupLow        =>  tsetup_AXR1In_ACLKR1,
          HoldHigh        =>  thold_AXR1In_ACLKR1,
          HoldLow         =>  thold_AXR1In_ACLKR1,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRP1 = '0'
                              AND SRMOD71 = "10" AND CLKRM = '1',
          RefTransition   =>  '/',
          HeaderMsg       =>  InstancePath & PartID,
          TimingData      =>  TD_AXR17_ACLKR1,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Tviol_AXR17_ACLKR1);

        VitalPeriodPulseCheck (
          TestSignal      =>  HSTROBENeg,
          TestSignalName  =>  "HSTROBENeg",
          PulseWidthLow   =>  4 * PERIODSYS1,
          PulseWidthHigh  =>  4 * PERIODSYS1,
          PeriodData      =>  PD_HSTROBENeg,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Pviol_HSTROBENeg,
          HeaderMsg       =>  InstancePath & PartID,
          CheckEnabled    =>  HPI_EN = '1' );

        VitalPeriodPulseCheck (
          TestSignal      =>  AHCLKR1In,
          TestSignalName  =>  "AHCLKR1",
          Period          =>  tperiod_AHCLKR1_posedge,
          PulseWidthLow   =>  tpw_AHCLKR1_negedge,
          PulseWidthHigh  =>  tpw_AHCLKR1_posedge,
          PeriodData      =>  PD_AHCLKR1In,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Pviol_AHCLKR1In,
          HeaderMsg       =>  InstancePath & PartID,
          CheckEnabled    =>  HPI_EN = '0' AND HCLKRM1 = '0');

        VitalPeriodPulseCheck (
          TestSignal      =>  AHCLKX1In,
          TestSignalName  =>  "AHCLKX1",
          Period          =>  tperiod_AHCLKX1_posedge,
          PulseWidthLow   =>  tpw_AHCLKX1_negedge,
          PulseWidthHigh  =>  tpw_AHCLKX1_posedge,
          PeriodData      =>  PD_AHCLKX1In,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Pviol_AHCLKX1In,
          HeaderMsg       =>  InstancePath & PartID,
          CheckEnabled    =>  HPI_EN = '0' AND HCLKXM1 = '0');

        VitalPeriodPulseCheck (
          TestSignal      =>  ACLKX1In,
          TestSignalName  =>  "ACLKX1",
          Period          =>  tperiod_ACLKX1_posedge,
          PulseWidthLow   =>  tpw_ACLKX1_negedge,
          PulseWidthHigh  =>  tpw_ACLKX1_posedge,
          PeriodData      =>  PD_ACLKX1In,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Pviol_ACLKX1In,
          HeaderMsg       =>  InstancePath & PartID,
          CheckEnabled    =>  HPI_EN = '0' AND CLKXM1 = '0');

        VitalPeriodPulseCheck (
          TestSignal      =>  ACLKR1In,
          TestSignalName  =>  "ACLKR1",
          Period          =>  tperiod_ACLKR1_posedge,
          PulseWidthLow   =>  tpw_ACLKR1_negedge,
          PulseWidthHigh  =>  tpw_ACLKR1_posedge,
          PeriodData      =>  PD_ACLKR1In,
          XOn             =>  XOn,
          MsgOn           =>  MsgOn,
          Violation       =>  Pviol_ACLKR1In,
          HeaderMsg       =>  InstancePath & PartID,
          CheckEnabled    =>  HPI_EN = '0' AND CLKRM1 = '0');

        Violation := Tviol_HCNTL_HASNeg OR
                     Tviol_HR_HASNeg OR Tviol_HHWIL_HASNeg OR
                     Tviol_HCNTL_HSTROBENeg OR
                     Tviol_HR_HSTROBENeg OR Tviol_HHWIL_HSTROBENeg OR
                     Pviol_HSTROBENeg OR Tviol_HSTROBENeg_HRDYNeg OR
                     Pviol_AHCLKR1In OR Pviol_AHCLKX1In OR Pviol_ACLKX1In
                     OR Pviol_ACLKR1In OR Tviol_AXR10_ACLKR1 OR
                     Tviol_AXR1In0_ACLKR1;
    END IF;

    ----------------------------------------------------------------------------
    -- Functionality section                                                  --
    ----------------------------------------------------------------------------
    IF HPI_EN = '1' THEN -- HPI enable

        IF falling_edge(HASNeg) THEN
            cntl_sel := to_nat(HCNTL);
            halfword := HHWIL;
            HPIrd    <= HR;
        END IF;

        IF falling_edge(HSTROB_int) THEN
            IF (HASNeg = '1') THEN
                cntl_sel := to_nat(HCNTL);
                halfword := HHWIL;
                HPIrd    <= HR;
                read     := HR;
            END IF;
        END IF;

        IF (falling_edge(HSTROB_int) OR rising_edge(HPI_flag)) THEN
            CASE cntl_sel IS
                WHEN 0 =>
                    IF read = '1' THEN  -- read
                        HDOut_zd <= HPIC(0);  -- 2 half words must be the same
                        HDOut_zd(4) <= '0'; -- FETCH bit is always read as '0'
                    END IF;
                WHEN 1 =>
                    IF read = '1' THEN  -- read
                        IF (halfword = '0') THEN   -- 1st half word
                            IF (HWOB = '1') THEN   -- LSB
                                HDOut_zd <= HPIA(0);
                            ELSE                   -- MSB
                                HDOut_zd <= HPIA(1);
                            END IF;
                        ELSE                       -- 2nd half word
                            IF (HWOB = '1') THEN   -- MSB
                                HDOut_zd <= HPIA(1);
                            ELSE                   -- LSB
                                HDOut_zd <= HPIA(0);
                            END IF;
                        END IF;
                    END IF;
                WHEN 2 =>
                    IF read = '1' THEN  -- read
                        IF HPI_flag = '0' THEN
                            HPIDacc <= '1';
                        ELSE                       -- 2nd half word
                            IF (halfword = '0') THEN   -- 1st half word
                                IF (HWOB = '1') THEN   -- LSB
                                    HDOut_zd <= HPIDout(0);
                                ELSE                   -- MSB
                                    HDOut_zd <= HPIDout(1);
                                END IF;
                            ELSE                       -- 2nd half word
                                IF (HWOB = '1') THEN   -- MSB
                                    HDOut_zd <= HPIDout(1);
                                ELSE                   -- LSB
                                    HDOut_zd <= HPIDout(0);
                                END IF;
                                HPIDacc <= '0';
                            END IF;
                        END IF;
                    END IF;
                WHEN 3 =>
                    IF read = '1' THEN  -- read
                        IF HPI_flag = '0' THEN
                            HPIDacc <= '1';
                        ELSE                       -- 2nd half word
                            IF (halfword = '0') THEN   -- 1st half word
                                IF (HWOB = '1') THEN   -- LSB
                                    HDOut_zd <= HPIDout(0);
                                ELSE                   -- MSB
                                    HDOut_zd <= HPIDout(1);
                                END IF;
                            ELSE                       -- 2nd half word
                                IF (HWOB = '1') THEN   -- MSB
                                    HDOut_zd <= HPIDout(1);
                                ELSE                   -- LSB
                                    HDOut_zd <= HPIDout(0);
                                END IF;
                                HPIDacc <= '0';
                            END IF;
                        END IF;
                    END IF;
            END CASE;
        END IF;

        IF rising_edge(HSTROB_int) THEN
            CASE cntl_sel IS
                WHEN 0 =>
                    IF read = '0' THEN  -- write
                        IF (halfword = '0') THEN   -- 1st half word
                            HWOB <= HDIn(0);
                            IF HDIn(1) = '1' THEN
                                DSPINT <= '1';
                            END IF;
                            IF HDIn(2) = '1' THEN
                                HINT <= '0';
                            END IF;
                            HPIC(0)(15 downto 4) <= HDIn(15 downto 4);
                        ELSE                       -- 2nd half word
                            HPIC(1) <= HPIC(0);
                        END IF;
                    ELSE                -- read
                        HDOut_zd <= (others => 'Z');
                    END IF;
                WHEN 1 =>
                    IF read = '0' THEN  -- write
                        IF (halfword = '0') THEN   -- 1st half word
                            IF (HWOB = '1') THEN   -- LSB
                                HPIA(0) <= HDIn;
                            ELSE                   -- MSB
                                HPIA(1) <= HDIn;
                            END IF;
                        ELSE                       -- 2nd half word
                            IF (HWOB = '1') THEN   -- MSB
                                HPIA(1) <= HDIn;
                            ELSE                   -- LSB
                                HPIA(0) <= HDIn;
                            END IF;
                        END IF;
                    ELSE                -- read
                        HDOut_zd <= (others => 'Z');
                    END IF;
                WHEN 2 =>
                    IF read = '0' THEN  -- write
                        IF (halfword = '0') THEN   -- 1st half word
                            IF (HWOB = '1') THEN   -- LSB
                                HPIDin(0) <= HDIn;
                            ELSE                   -- MSB
                                HPIDin(1) <= HDIn;
                            END IF;
                        ELSE                       -- 2nd half word
                            IF (HWOB = '1') THEN   -- MSB
                                HPIDin(1) <= HDIn;
                            ELSE                   -- LSB
                                HPIDin(0) <= HDIn;
                            END IF;
                            HPIDacc <= '1', '0' AFTER 2 ns;
                        END IF;
                    ELSE                -- read
                        HDOut_zd <= (others => 'Z');
                    END IF;
                WHEN 3 =>
                    IF read = '0' THEN  -- write
                        IF (halfword = '0') THEN   -- 1st half word
                            IF (HWOB = '1') THEN   -- LSB
                                HPIDin(0) <= HDIn;
                            ELSE                   -- MSB
                                HPIDin(1) <= HDIn;
                            END IF;
                        ELSE                       -- 2nd half word
                            IF (HWOB = '1') THEN   -- MSB
                                HPIDin(1) <= HDIn;
                            ELSE                   -- LSB
                                HPIDin(0) <= HDIn;
                            END IF;
                            HPIDacc <= '1', '0' AFTER 2 ns;
                        END IF;
                    ELSE                -- read
                        HDOut_zd <= (others => 'Z');
                    END IF;
            END CASE;
        END IF;

        IF falling_edge(HPIDacc) AND cntl_sel = 2 THEN
            HPIA_tmp := to_nat(HPIA(0)) + 4;   -- autoincrement
            HPIA(0) <= to_slv(HPIA_tmp, 16);
            IF HPIA_tmp < 3 THEN               -- carry
                HPIA_tmp := to_nat(HPIA(1)) + 1;
                HPIA(1) <= to_slv(HPIA_tmp, 16);
            END IF;
        END IF;

        IF DSPclear THEN
            DSPINT <= '0';
        END IF;

        IF rising_edge(RESET_int) THEN
            Booting <= true;
        ELSIF BootDone THEN
            Booting <= false;
        END IF;

        IF RESET_int = '0' THEN
            HDOut_zd <= (others => 'Z');
            HRDYNeg_zd := not HCSNeg;
            HINTNeg_zd := '1';
        ELSE
            IF HCSNeg = '1' THEN
                HRDYNeg_zd := '0';
            ELSIF halfword = '1' THEN
                HRDYNeg_zd := '0';
            ELSE
                HRDYNeg_zd := not HRDY;
            END IF;
            HINTNeg_zd := not HINT;
        END IF;

    ELSE -- McSAP1 enabled
        -- transmit clock generator
        IF CLKXM1 = '1' THEN

            IF XHCLKRST1 = '1' THEN
                div := to_nat(HCLKXDIV1) + 1;
                PeriodAUX <= PERIOD * div;
            END IF;

            IF HCLKXM1 = '1' THEN
                IF HCLKXP1 = '1' THEN
                    AHCLKXTmp <= not(AUXDIVX);
                ELSE
                    AHCLKXTmp <= AUXDIVX;
                END IF;
                AHCLKX1Out <= AUXDIVX;
            ELSE
                IF HCLKXP1 = '1' THEN
                    AHCLKXTmp <= not(AHCLKX1In);
                ELSE
                    AHCLKXTmp <= AHCLKX1In;
                END IF;
                AHCLKX1Out <= 'Z';
            END IF;

            IF rising_edge(AHCLKXTmp) THEN
                PeriodHXCLK <= NOW - Previous;
                Previous := NOW;
            END IF;

            IF XCLKRST1 = '1' AND rising_edge(AHCLKXTmp) THEN
                div := to_nat(CLKXDIV1) + 1;
                PeriodDiv <= PeriodHXCLK/2 * div;
            ELSIF XCLKRST1 = '1' AND rising_edge(AHCLKXTmp) THEN
                PeriodDiv <= PeriodHXCLK/2;
            END IF;

            IF CLKXP1 = '1' THEN
                XCLK <= not(XCLKDIV);
            ELSE
                XCLK <= XCLKDIV;
            END IF;

            ACLKX1Out <= XCLKDIV;
            ACLKX1Out_zd <= XCLKDIV;

        ELSE
            IF CLKXP1 = '1' THEN
                XCLK <= not(ACLKX1In);
            ELSE
                XCLK <= ACLKX1In;
            END IF;
            ACLKX1Out <= 'Z';
            ACLKX1Out_zd <= 'Z';
        END IF;

        -- receive clock generator
        IF CLKRM1 = '1' THEN

            IF RHCLKRST1 = '1' THEN
                divr := to_nat(HCLKRDIV1) + 1;
                PeriodAUXR <= PERIOD * divr;
            END IF;

            IF HCLKRM1 = '1' THEN
                IF HCLKRP1 = '1' THEN
                    AHCLKRTmp <= not(AUXDIVR);
                ELSE
                    AHCLKRTmp <= AUXDIVR;
                END IF;
                AHCLKR1Out <= AUXDIVR;
            ELSE
                IF HCLKRP1 = '1' THEN
                    AHCLKRTmp <= not(AHCLKR1In);
                ELSE
                    AHCLKRTmp <= AHCLKR1In;
                END IF;
                AHCLKR1Out <= 'Z';
            END IF;

            IF rising_edge(AHCLKRTmp) THEN
                PeriodHRCLK <= NOW - PreviousR;
                PreviousR := NOW;
            END IF;

            IF RCLKRST1 = '1' AND rising_edge(AHCLKRTmp) THEN
                divr := to_nat(CLKRDIV1) + 1;
                PeriodDivR <= PeriodHRCLK/2 * divr;
            ELSIF RCLKRST1 = '0' AND rising_edge(AHCLKRTmp) THEN
                PeriodDivR <= PeriodHRCLK/2;
            END IF;

            IF ASYNC1 = '1' THEN
                IF CLKRP1 = '1' THEN
                    RCLK <= not(RCLKDIV);
                ELSE
                    RCLK <= RCLKDIV;
                END IF;
            ELSE
                RCLK <= XCLK;
            END IF;
            ACLKR1Out_int <= RCLKDIV;

        ELSE
            IF ASYNC1 = '1' THEN
                IF CLKRP1 = '1' THEN
                    RCLK <= not(ACLKR1In);
                ELSE
                    RCLK <= ACLKR1In;
                END IF;
            ELSE
                RCLK <= XCLK;
            END IF;
            ACLKR1Out_int <= 'Z';
        END IF;

        -- transmit frame sync generator
        IF XFRST1 = '1' THEN -- enable frame generator
            IF FSXM1 = '1' THEN -- internal

                mode := to_nat(XMOD1);
                CASE XSSZ1 IS
                    WHEN "0011" =>
                        slotsize := 8;
                    WHEN "0101" =>
                        slotsize := 12;
                    WHEN "0111" =>
                        slotsize := 16;
                    WHEN "1001" =>
                        slotsize := 20;
                    WHEN "1011" =>
                        slotsize := 24;
                    WHEN "1101" =>
                        slotsize := 28;
                    WHEN "1111" =>
                        slotsize := 32;
                    WHEN others =>
                        null;
                END CASE;
                fsxsize := slotsize * mode;
                IF DITEN1 = '1' AND mode = 384 THEN
                    fsxsize := fsxsize * 2;
                END IF;
                IF mode = 0 THEN -- burst
                    IF XSRCLR1 = '1' THEN
                        IF SRMOD01 = "01" AND XRDY01 = '1' THEN
                            beginfrx := false;
                        ELSIF SRMOD11 = "01" AND XRDY11 = '1' THEN
                            beginfrx := false;
                        ELSIF SRMOD21 = "01" AND XRDY21 = '1' THEN
                            beginfrx := false;
                        ELSIF SRMOD31 = "01" AND XRDY31 = '1' THEN
                            beginfrx := false;
                        ELSIF SRMOD41 = "01" AND XRDY41 = '1' THEN
                            beginfrx := false;
                        ELSIF SRMOD51 = "01" AND XRDY51 = '1' THEN
                            beginfrx := false;
                        ELSIF SRMOD61 = "01" AND XRDY61 = '1' THEN
                            beginfrx := false;
                        ELSIF SRMOD71 = "01" AND XRDY71 = '1' THEN
                            beginfrx := false;
                        ELSE
                            beginfrx := true;
                        END IF;
                    END IF;
                    IF rising_edge(XCLK) THEN
                        IF fsxcnt = 0 THEN
                            IF beginfrx = true THEN
                                FSX := '1';
                                fsxcnt := slotsize;
                                beginfrx := false;
                            END IF;
                        ELSE
                            fsxcnt := fsxcnt - 1;
                        END IF;
                        IF fsxcnt = slotsize -1 THEN
                            FSX := '0';
                        END IF;
                    END IF;
                ELSE -- TDM
                    IF rising_edge(XCLK) THEN
                        IF fsxcnt = 0 THEN
                            FSX := '1';
                            fsxcnt := 1;
                        ELSIF fsxcnt = 1 AND FXWID1 = '0' THEN
                            fsxcnt := fsxcnt + 1;
                            FSX := '0';
                        ELSIF fsxcnt = slotsize AND FXWID1 = '1' THEN
                            fsxcnt := fsxcnt + 1;
                            FSX := '0';
                        ELSIF fsxcnt = fsxsize - 1 THEN
                            fsxcnt := 0;
                        ELSE
                            fsxcnt := fsxcnt + 1;
                        END IF;
                    END IF;
                END IF;

                FSXTmp := FSX;
                IF FSXP1 = '1' THEN
                    FSX1_int <= not(FSX);
                    AFSX1Out <= not(FSX);
                ELSE
                    FSX1_int <= FSX;
                    AFSX1Out <= FSX;
                END IF;

            ELSE -- external

                mode := to_nat(XMOD1);
                CASE XSSZ1 IS
                    WHEN "0011" =>
                        slotsize := 8;
                    WHEN "0101" =>
                        slotsize := 12;
                    WHEN "0111" =>
                        slotsize := 16;
                    WHEN "1001" =>
                        slotsize := 20;
                    WHEN "1011" =>
                        slotsize := 24;
                    WHEN "1101" =>
                        slotsize := 28;
                    WHEN "1111" =>
                        slotsize := 32;
                    WHEN others =>
                        null;
                END CASE;
                FSXTmp := AFSX1In;
                IF FSXP1 = '1' THEN
                    FSX1_int <= not(AFSX1In);
                ELSE
                    FSX1_int <= AFSX1In;
                END IF;
                AFSX1Out <= 'Z';

            END IF;
        ELSE
            fsxcnt := 0;
            transmit := false;
            transmit1 := false;
            transmit2 := false;
            transmit3 := false;
            transmit4 := false;
            transmit5 := false;
            transmit6 := false;
            transmit7 := false;
            receive := false;
            receive1 := false;
            receive2 := false;
            receive3 := false;
            receive4 := false;
            receive5 := false;
            receive6 := false;
            receive7 := false;
        END IF;

        -- receive frame sync generator
        IF RFRST1 = '1' THEN -- enable frame generator
            IF FSRM1 = '1' THEN -- internal

                moder := to_nat(RMOD1);
                CASE RSSZ1 IS
                    WHEN "0011" =>
                        slotsizer := 8;
                    WHEN "0101" =>
                        slotsizer := 12;
                    WHEN "0111" =>
                        slotsizer := 16;
                    WHEN "1001" =>
                        slotsizer := 20;
                    WHEN "1011" =>
                        slotsizer := 24;
                    WHEN "1101" =>
                        slotsizer := 28;
                    WHEN "1111" =>
                        slotsizer := 32;
                    WHEN others =>
                        null;
                END CASE;
                fsrsize := slotsizer * moder;
                IF moder = 0 THEN -- burst
                    IF RSRCLR1 = '1' THEN
                        IF SRMOD01 = "10" AND RRDY01 = '1' THEN
                            beginfrr := false;
                        ELSIF SRMOD11 = "10" AND RRDY11 = '1' THEN
                            beginfrr := false;
                        ELSIF SRMOD21 = "10" AND RRDY21 = '1' THEN
                            beginfrr := false;
                        ELSIF SRMOD31 = "10" AND RRDY31 = '1' THEN
                            beginfrr := false;
                        ELSIF SRMOD41 = "10" AND RRDY41 = '1' THEN
                            beginfrr := false;
                        ELSIF SRMOD51 = "10" AND RRDY51 = '1' THEN
                            beginfrr := false;
                        ELSIF SRMOD61 = "10" AND RRDY61 = '1' THEN
                            beginfrr := false;
                        ELSIF SRMOD71 = "10" AND RRDY71 = '1' THEN
                            beginfrr := false;
                        ELSE
                            beginfrr := true;
                        END IF;
                    END IF;
                    IF rising_edge(RCLK) THEN
                        IF fsrcnt = 0 THEN
                            IF beginfrr = true THEN
                                FSR := '1';
                                fsrcnt := slotsizer;
                                beginfrr := false;
                            END IF;
                        ELSE
                            fsrcnt := fsrcnt - 1;
                        END IF;
                        IF fsrcnt = slotsizer -1 THEN
                            FSR := '0';
                        END IF;
                    END IF;
                ELSE -- TDM
                    IF rising_edge(RCLK) THEN
                        IF fsrcnt = 0 THEN
                            FSR := '1';
                            fsrcnt := 1;
                        ELSIF fsrcnt = 1 AND FRWID1 = '0' THEN
                            fsrcnt := fsrcnt + 1;
                            FSR := '0';
                        ELSIF fsrcnt = slotsizer AND FRWID1 = '1' THEN
                            fsrcnt := fsrcnt + 1;
                            FSR := '0';
                        ELSIF fsrcnt = fsrsize - 1 THEN
                            fsrcnt := 0;
                        ELSE
                            fsrcnt := fsrcnt + 1;
                        END IF;
                    END IF;
                END IF;

                IF FSRP1 = '1' THEN
                    AFSR1Out <= not(FSR);
                ELSE
                    AFSR1Out <= FSR;
                END IF;

                IF ASYNC1 = '1' THEN
                    IF FSRP1 = '1' THEN
                        FSR1_int <= not(FSR);
                    ELSE
                        FSR1_int <= FSR;
                    END IF;
                ELSE
                    IF FSRP1 = '1' THEN
                        FSR1_int <= not(FSXTmp);
                    ELSE
                        FSR1_int <= FSXTmp;
                    END IF;
                END IF;

            ELSE -- external

                moder := to_nat(RMOD1);
                CASE RSSZ1 IS
                    WHEN "0011" =>
                        slotsizer := 8;
                    WHEN "0101" =>
                        slotsizer := 12;
                    WHEN "0111" =>
                        slotsizer := 16;
                    WHEN "1001" =>
                        slotsizer := 20;
                    WHEN "1011" =>
                        slotsizer := 24;
                    WHEN "1101" =>
                        slotsizer := 28;
                    WHEN "1111" =>
                        slotsizer := 32;
                    WHEN others =>
                        null;
                END CASE;
                IF ASYNC1 = '1' THEN
                    IF FSRP1 = '1' THEN
                        FSR1_int <= not(AFSR1In);
                    ELSE
                        FSR1_int <= AFSR1In;
                    END IF;
                ELSE
                    IF FSRP1 = '1' THEN
                        FSR1_int <= not(FSXTmp);
                    ELSE
                        FSR1_int <= FSXTmp;
                    END IF;
                END IF;
                AFSR1Out <= 'Z';

            END IF;
        ELSE
            fsrcnt := 0;
        END IF;

        --transmit clock failure
        IF HCLKXM1 = '0' THEN
            IF rising_edge(AHCLKX1In) THEN
                xhcnt := xhcnt + 1;
                IF xhcnt = 31 THEN
                    xhcnt := 0;
                    Comparex := true;
                    XCNT1 <= to_slv(mastercntx, 8);
                END IF;
            END IF;
        END IF;

        IF Comparex = true THEN
            IF mastercntx < to_nat(XMIN1) OR mastercntx > to_nat(XMAX1) THEN
                XCKFAIL1_RD <= '1', '0' AFTER 10 ns;
            END IF;
            mastercntx := 0;
            Comparex := false;
        END IF;

        IF rising_edge(SYSCLK2X) THEN
            mastercntx := mastercntx + 1;
        END IF;

        --receive clock failure
        IF HCLKRM1 = '0' THEN
            IF rising_edge(AHCLKR1In) THEN
                rhcnt := rhcnt + 1;
                IF rhcnt = 31 THEN
                    rhcnt := 0;
                    Comparer := true;
                    RCNT1 <= to_slv(mastercntr, 8);
                END IF;
            END IF;
        END IF;

        IF Comparer = true THEN
            IF mastercntr < to_nat(RMIN1) OR mastercntr > to_nat(RMAX1) THEN
                RCKFAIL1_RD <= '1', '0' AFTER 10 ns;
            END IF;
            mastercntr := 0;
            Comparer := false;
        END IF;

        IF rising_edge(SYSCLK2R) THEN
            mastercntr := mastercntr + 1;
        END IF;

        IF (rising_edge(FSX1_int) AND FSXP1 = '0') OR
           (falling_edge(FSX1_int) AND FSXP1 = '1') THEN
            startflagx := true;
            startflagx1 := true;
            startflagx2 := true;
            startflagx3 := true;
            startflagx4 := true;
            startflagx5 := true;
            startflagx6 := true;
            startflagx7 := true;
            IF transmit = true OR syncxcnt > 0 THEN
                XSYNC1_RD <= '1', '0' AFTER 10 ns;
                syncxcnt := 0;
            END IF;
            transmit := true;
            transmit1 := true;
            transmit2 := true;
            transmit3 := true;
            transmit4 := true;
            transmit5 := true;
            transmit6 := true;
            transmit7 := true;
        END IF;

        IF (rising_edge(FSR1_int) AND FSRP1 = '0') OR
           (falling_edge(FSR1_int) AND FSRP1 = '1') THEN
            startflagr := true;
            startflagr1 := true;
            startflagr2 := true;
            startflagr3 := true;
            startflagr4 := true;
            startflagr5 := true;
            startflagr6 := true;
            startflagr7 := true;
            IF receive = true OR syncrcnt > 0 THEN
                RSYNC1_RD <= '1', '0' AFTER 10 ns;
                syncrcnt := 0;
            END IF;
            receive := true;
            receive1 := true;
            receive2 := true;
            receive3 := true;
            receive4 := true;
            receive5 := true;
            receive6 := true;
            receive7 := true;
        END IF;

        delayx := to_nat(XDATDLY1);
        delayr := to_nat(RDATDLY1);

        --serializer0
        CASE SRMOD01 IS
            WHEN "00" => -- inactive serializer
                IF DISMOD01 = "00" THEN
                    AXR1Out0_zd := 'Z';
                ELSIF DISMOD01 = "10" THEN
                    AXR1Out0_zd := '0';
                ELSIF DISMOD01 = "11" THEN
                    AXR1Out0_zd := '1';
                END IF;
            WHEN "01" => -- serializer is transmitter
                IF XSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(0) = '0' AND PDIR1(0) = '1' THEN
                        IF DISMOD01 = "00" THEN
                            AXR1Out0_zd := 'Z';
                        ELSIF DISMOD01 = "10" THEN
                            AXR1Out0_zd := '0';
                        ELSIF DISMOD01 = "11" THEN
                            AXR1Out0_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF XSRCLR1 = '1' THEN -- transmit serializers are active
                        IF (rising_edge(XCLK) AND transmit = true) OR
                           (rising_edge(FSX1_int) AND FSXP1 = '0') OR
                           (falling_edge(FSX1_int) AND FSXP1 = '1') THEN

                            IF mode = 0 AND DITEN1 = '0' THEN -- burst
                                IF delayx = 0 AND startflagx = true THEN
                                    bitcnt0 := 0;
                                    startflagx := false;
                                    startburstx := true;
                                    XSR01 <= XBUF01;
                                    XSR01Tmp := XBUF01;
                                    IF XRDY01 = '1' THEN
                                        XUNDERN1_flag <= '1', '0' AFTER 10 ns;
                                        XSR01Tmp := (others => '0');
                                    END IF;
                                    XRDY01_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 1 AND startflagx = true AND
                                      bitcnt0 = 1 THEN
                                    bitcnt0 := 0;
                                    startflagx := false;
                                    startburstx := true;
                                    XSR01 <= XBUF01;
                                    XSR01Tmp := XBUF01;
                                    IF XRDY01 = '1' THEN
                                        XUNDERN1_flag <= '1', '0' AFTER 10 ns;
                                        XSR01Tmp := (others => '0');
                                    END IF;
                                    XRDY01_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 2 AND startflagx = true AND
                                      bitcnt0 = 2 THEN
                                    bitcnt0 := 0;
                                    startflagx := false;
                                    startburstx := true;
                                    XSR01 <= XBUF01;
                                    XSR01Tmp := XBUF01;
                                    IF XRDY01 = '1' THEN
                                        XUNDERN1_flag <= '1', '0' AFTER 10 ns;
                                        XSR01Tmp := (others => '0');
                                    END IF;
                                    XRDY01_RD <= '1', '0' AFTER 10 ns;
                                END IF;
                                IF startburstx = true THEN
                                    AXR1Out0_zd := XSR01Tmp(bitcnt0);
                                END IF;
                                bitcnt0 := bitcnt0 + 1;
                                IF bitcnt0 = slotsize THEN
                                    startburstx := false;
                                    bitcnt0 := 0;
                                    transmit := false;
                                END IF;

                            ELSIF DITEN1 = '1' AND mode = 384 THEN -- DIT

                                IF startflagx = true THEN
                                    startflagx := false;
                                    XSR01 <= XBUF01;
                                    XSR01Tmp := XBUF01;
                                    TMPReg(23 downto 0) :=
                                    XSR01Tmp(23 downto 0);
                                    TMPReg(24) := VA1;
                                    TMPReg(25) := DITCSRA0(0);
                                    TMPReg(26) := DITUDRA0(0);
                                    TMPReg(27) := '0';
                                    IF TMPReg(0) = '0' THEN
                                        TmpReg56(0) := '1';
                                        TmpReg56(1) := '1';
                                    ELSE
                                        TmpReg56(0) := '1';
                                        TmpReg56(1) := '0';
                                    END IF;
                                    FOR I IN 1 TO 27 LOOP
                                        IF TmpReg56(2*i - 1) = '0' THEN
                                            IF TMPReg (i) = '0' THEN
                                                TmpReg56(2*i) := '1';
                                                TmpReg56 (2*i + 1) := '1';
                                             ELSE
                                                TmpReg56(2*i) := '1';
                                                TmpReg56(2*i + 1) := '0';
                                            END IF;
                                        ELSE
                                            IF TMPReg(i) = '0' THEN
                                                TmpReg56(2*i) := '0';
                                                TmpReg56(2*i + 1) := '0';
                                             ELSE
                                                TmpReg56(2*i) := '0';
                                                TmpReg56(2*i + 1) := '1';
                                            END IF;
                                        END IF;
                                    END LOOP;
                                    Reg64 := TmpReg56 & "11101000";
                                    XRDY01_RD <= '1', '0' AFTER 10 ns;
                                    slotcnt0 := 0;
                                    framecnt0 := 0;
                                    subframe0 := '0';
                                    bitcnt0 := 0;
                                END IF;
                                AXR1Out0_zd := Reg64(bitcnt0);
                                bitcnt0 := bitcnt0 + 1;
                                IF bitcnt0 = 64 THEN
                                    XSR01 <= XBUF01;
                                    XSR01Tmp := XBUF01;
                                    IF subframe0 = '0' THEN
                                        subframe0 := '1';
                                        TMPReg(23 downto 0) :=
                                        XSR01Tmp(23 downto 0);
                                        TMPReg(24) := VB1;
                                        IF framecnt0 > 159 THEN
                                            TMPReg(25) :=
                                            DITCSRB5(framecnt0 - 160);
                                            TMPReg(26) :=
                                            DITUDRB5(framecnt0 - 160);
                                        ELSIF framecnt0 > 127 THEN
                                            TMPReg(25) :=
                                            DITCSRB4(framecnt0 - 128);
                                            TMPReg(26) :=
                                            DITUDRB4(framecnt0 - 128);
                                        ELSIF framecnt0 > 95 THEN
                                            TMPReg(25) :=
                                            DITCSRB3(framecnt0 - 96);
                                            TMPReg(26) :=
                                            DITUDRB3(framecnt0 - 96);
                                        ELSIF framecnt0 > 63 THEN
                                            TMPReg(25) :=
                                            DITCSRB2(framecnt0 - 64);
                                            TMPReg(26) :=
                                            DITUDRB2(framecnt0 - 64);
                                        ELSIF framecnt0 > 31 THEN
                                            TMPReg(25) :=
                                            DITCSRB1(framecnt0 - 32);
                                            TMPReg(26) :=
                                            DITUDRB1(framecnt0 - 32);
                                        ELSE
                                            TMPReg(25) :=
                                            DITCSRB0(framecnt0);
                                            TMPReg(26) :=
                                            DITUDRB0(framecnt0);
                                        END IF;
                                        TMPReg(27) := '0';
                                        IF TMPReg(0) = '0' THEN
                                            TmpReg56(0) := '1';
                                            TmpReg56(1) := '1';
                                        ELSE
                                            TmpReg56(0) := '1';
                                            TmpReg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF TmpReg56(2*i - 1) = '0' THEN
                                                IF TMPReg(i) = '0' THEN
                                                    TmpReg56(2*i) := '1';
                                                    TmpReg56(2*i + 1) := '1';
                                                ELSE
                                                    TmpReg56(2*i) := '1';
                                                    TmpReg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg(i) = '0' THEN
                                                    TmpReg56(2*i) := '0';
                                                    TmpReg56(2*i + 1) := '0';
                                                ELSE
                                                    TmpReg56(2*i) := '0';
                                                    TmpReg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg64 := TmpReg56 & "11100100";
                                        XRDY01_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF slotcnt0 /= 383 THEN
                                        subframe0 := '0';
                                        framecnt0 := framecnt0 +1;
                                        IF framecnt0 = 192 THEN
                                            framecnt0 := 0;
                                            bitcnt0 := 0;
                                            slotcnt0 := 0;
                                            transmit := false;
                                        END IF;
                                        TMPReg(23 downto 0) :=
                                        XSR01Tmp(23 downto 0);
                                        TMPReg(24) := VA1;
                                        IF framecnt0 > 159 THEN
                                            TMPReg(25) :=
                                            DITCSRA5(framecnt0 - 160);
                                            TMPReg(26) :=
                                            DITUDRA5(framecnt0 - 160);
                                        ELSIF framecnt0 > 127 THEN
                                            TMPReg(25) :=
                                            DITCSRA4(framecnt0 - 128);
                                            TMPReg(26) :=
                                            DITUDRA4(framecnt0 - 128);
                                        ELSIF framecnt0 > 95 THEN
                                            TMPReg(25) :=
                                            DITCSRA3(framecnt0 - 96);
                                            TMPReg(26) :=
                                            DITUDRA3(framecnt0 - 96);
                                        ELSIF framecnt0 > 63 THEN
                                            TMPReg(25) :=
                                            DITCSRA2(framecnt0 - 64);
                                            TMPReg(26) :=
                                            DITUDRA2(framecnt0 - 64);
                                        ELSIF framecnt0 > 31 THEN
                                            TMPReg(25) :=
                                            DITCSRA1(framecnt0 - 32);
                                            TMPReg(26) :=
                                            DITUDRA1(framecnt0 - 32);
                                        ELSE
                                            TMPReg(25) :=
                                            DITCSRA0(framecnt0);
                                            TMPReg(26) :=
                                            DITUDRA0(framecnt0);
                                        END IF;
                                        TMPReg(27) := '0';
                                        IF TMPReg(0) = '0' THEN
                                            TmpReg56(0) := '1';
                                            TmpReg56(1) := '1';
                                        ELSE
                                            TmpReg56(0) := '1';
                                            TmpReg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF TmpReg56(2*i - 1) = '0' THEN
                                                IF TMPReg(i) = '0' THEN
                                                    TmpReg56(2*i) := '1';
                                                    TmpReg56(2*i + 1) := '1';
                                                ELSE
                                                    TmpReg56(2*i) := '1';
                                                    TmpReg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg(i) = '0' THEN
                                                    TmpReg56(2*i) := '0';
                                                    TmpReg56(2*i + 1) := '0';
                                                ELSE
                                                    TmpReg56(2*i) := '0';
                                                    TmpReg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg64 := TmpReg56 & "11100010";
                                        XRDY01_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    bitcnt0 := 0;
                                    slotcnt0 := slotcnt0 +1;
                                END IF;

                            ELSIF DITEN1 = '0' THEN -- TDM

                                IF XTDM1(slotcnt0) = '1' THEN --active slot
                                    IF delayx = 0 AND startflagx = true THEN
                                        startflagx := false;
                                        XSR01 <= XBUF01;
                                        XSR01Tmp := XBUF01;
                                        bitcnt0 := 0;
                                        slotcnt0 := 0;
                                        IF XRDY01 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR01Tmp := (others => '0');
                                        END IF;
                                        XRDY01_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF delayx = 1 AND startflagx = true THEN
                                        startflagx := false;
                                        bitcnt0 := slotsize - 1;
                                        slotcnt0 := mode - 1;
                                    ELSIF delayx = 2 AND startflagx = true THEN
                                        startflagx := false;
                                        bitcnt0 := slotsize - 2;
                                        slotcnt0 := mode - 1;
                                    END IF;
                                    AXR1Out0_zd := XSR01Tmp(bitcnt0);
                                    XSLOTCNT1 <= to_slv(slotcnt0,10);
                                    bitcnt0 := bitcnt0 + 1;
                                    IF delayx = 0 AND slotcnt0 = (mode - 1)
                                       AND bitcnt0 = slotsize THEN
                                        transmit := false;
                                    ELSIF delayx = 1 AND slotcnt0 = (mode - 1)
                                          AND bitcnt0 = (slotsize - 1) THEN
                                        transmit := false;
                                    ELSIF delayx = 2 AND slotcnt0 = (mode - 1)
                                          AND bitcnt0 = (slotsize - 2) THEN
                                        transmit := false;
                                    END IF;
                                    IF bitcnt0 = slotsize THEN
                                       IF not(slotcnt0 = mode - 1 AND
                                          delayx = 0) THEN
                                            slotcnt0 := slotcnt0 + 1;
                                            bitcnt0 := 0;
                                            XSR01 <= XBUF01;
                                            XSR01Tmp := XBUF01;
                                            IF XRDY01 = '1' THEN
                                                XUNDERN1_flag <=
                                                '1', '0' AFTER 10 ns;
                                                XSR01Tmp := (others => '0');
                                            END IF;
                                            XRDY01_RD <= '1', '0' AFTER 10 ns;
                                        END IF;
                                    END IF;
                                    IF slotcnt0 = mode THEN
                                        slotcnt0 := 0;
                                        bitcnt0 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD01 = "00" THEN
                                        AXR1Out0_zd := 'Z';
                                    ELSIF DISMOD01 = "10" THEN
                                        AXR1Out0_zd := '0';
                                    ELSIF DISMOD01 = "11" THEN
                                        AXR1Out0_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF rising_edge(XCLK) AND transmit = false THEN
                            syncxcnt := syncxcnt + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN "10" => -- serializer is receiver
                IF RSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(0) = '0' AND PDIR1(0) = '1' THEN
                        IF DISMOD01 = "00" THEN
                            AXR1Out0_zd := 'Z';
                        ELSIF DISMOD01 = "10" THEN
                            AXR1Out0_zd := '0';
                        ELSIF DISMOD01 = "11" THEN
                            AXR1Out0_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF RSRCLR1 = '1' THEN -- receive serializers are active
                        IF falling_edge(RCLK) AND receive = true THEN

                            IF moder = 0 THEN -- burst
                                IF delayr = 0 AND startflagr = true THEN
                                    bitcntr0 := 0;
                                    startflagr := false;
                                    startburstr := true;
                                ELSIF delayr = 1 AND startflagr = true AND
                                      bitcntr0 = 1 THEN
                                    bitcntr0 := 0;
                                    startflagr := false;
                                    startburstr := true;
                                ELSIF delayr = 2 AND startflagr = true AND
                                      bitcntr0 = 2 THEN
                                    bitcntr0 := 0;
                                    startflagr := false;
                                    startburstr := true;
                                END IF;
                                IF startburstr = true THEN
                                    RSR01Tmp(bitcntr0) := AXR1In0;
                                END IF;
                                bitcntr0 := bitcntr0 + 1;
                                IF bitcntr0 = slotsizer THEN
                                    startburstr := false;
                                    bitcntr0 := 0;
                                    receive := false;
                                    RSR01 <= RSR01Tmp;
                                    RBUF01 <= RSR01Tmp;
                                    RRDY01_RD <= '1', '0' AFTER 10 ns;
                                END IF;

                            ELSE -- TDM

                                IF RTDM1(slotcntr0) = '1' THEN --active slot
                                    IF delayr = 0 AND startflagr = true THEN
                                        startflagr := false;
                                        bitcntr0 := 0;
                                        slotcntr0 := 0;
                                    ELSIF delayr = 1 AND startflagr = true THEN
                                        startflagr := false;
                                        bitcntr0 := slotsizer - 1;
                                        slotcntr0 := moder - 1;
                                    ELSIF delayr = 2 AND startflagr = true THEN
                                        startflagr := false;
                                        bitcntr0 := slotsizer - 2;
                                        slotcntr0 := moder - 1;
                                    END IF;
                                    IF DLBEN1 = '1' AND ASYNC1 = '0' AND
                                       MODE1 = "01" AND mode < 33 AND
                                       ORD1 = '0' THEN
                                        IF mode > 1 THEN -- Loopback mode
                                            RSR01Tmp(bitcntr0) := AXR1Out1_zd;
                                        END IF;
                                    ELSE
                                        RSR01Tmp(bitcntr0) := AXR1In0;
                                    END IF;
                                    RSLOTCNT1 <= to_slv(slotcntr0,10);
                                    bitcntr0 := bitcntr0 + 1;
                                    IF delayr = 0 AND slotcntr0 = (moder - 1)
                                       AND bitcntr0 = slotsizer THEN
                                        receive := false;
                                    ELSIF delayr = 1 AND slotcntr0 = (moder - 1)
                                          AND bitcntr0 = (slotsizer - 1) THEN
                                        receive := false;
                                    ELSIF delayr = 2 AND slotcntr0 = (moder - 1)
                                          AND bitcntr0 = (slotsizer - 2) THEN
                                        receive := false;
                                    END IF;
                                    IF bitcntr0 = slotsizer THEN
                                        slotcntr0 := slotcntr0 + 1;
                                        bitcntr0 := 0;
                                        RSR01 <= RSR01Tmp;
                                        RBUF01 <= RSR01Tmp;
                                        IF RRDY01 = '1' THEN
                                            ROVERN1_flag <='1', '0' AFTER 10 ns;
                                        END IF;
                                        RRDY01_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    IF slotcntr0 = moder THEN
                                        slotcntr0 := 0;
                                        bitcntr0 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD01 = "00" THEN
                                        AXR1Out0_zd := 'Z';
                                    ELSIF DISMOD01 = "10" THEN
                                        AXR1Out0_zd := '0';
                                    ELSIF DISMOD01 = "11" THEN
                                        AXR1Out0_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF falling_edge(RCLK) AND receive = false THEN
                            syncrcnt := syncrcnt + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN others =>
                null;
        END CASE;

        --serializer1
        CASE SRMOD11 IS
            WHEN "00" => -- inactive serializer
                IF DISMOD11 = "00" THEN
                    AXR1Out1_zd := 'Z';
                ELSIF DISMOD11 = "10" THEN
                    AXR1Out1_zd := '0';
                ELSIF DISMOD11 = "11" THEN
                    AXR1Out1_zd := '1';
                END IF;
            WHEN "01" => -- serializer is transmitter
                IF XSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(1) = '0' AND PDIR1(1) = '1' THEN
                        IF DISMOD11 = "00" THEN
                            AXR1Out1_zd := 'Z';
                        ELSIF DISMOD11 = "10" THEN
                            AXR1Out1_zd := '0';
                        ELSIF DISMOD11 = "11" THEN
                            AXR1Out1_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF XSRCLR1 = '1' THEN -- transmit serializers are active
                        IF (rising_edge(XCLK) AND transmit1 = true) OR
                           (rising_edge(FSX1_int) AND FSXP1 = '0') OR
                           (falling_edge(FSX1_int) AND FSXP1 = '1') THEN

                            IF mode = 0 AND DITEN1 = '0' THEN -- burst
                                IF delayx = 0 AND startflagx1 = true THEN
                                    bitcnt1 := 0;
                                    startflagx1 := false;
                                    startburstx1 := true;
                                    XSR11 <= XBUF11;
                                    XSR11Tmp := XBUF11;
                                    IF XRDY11 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR11Tmp := (others => '0');
                                        END IF;
                                    XRDY11_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 1 AND startflagx1 = true AND
                                      bitcnt1 = 1 THEN
                                    bitcnt1 := 0;
                                    startflagx1 := false;
                                    startburstx1 := true;
                                    XSR11 <= XBUF11;
                                    XSR11Tmp := XBUF11;
                                    IF XRDY11 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR11Tmp := (others => '0');
                                        END IF;
                                    XRDY11_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 2 AND startflagx1 = true AND
                                      bitcnt1 = 2 THEN
                                    bitcnt1 := 0;
                                    startflagx1 := false;
                                    startburstx1 := true;
                                    XSR11 <= XBUF11;
                                    XSR11Tmp := XBUF11;
                                    IF XRDY11 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR11Tmp := (others => '0');
                                        END IF;
                                    XRDY11_RD <= '1', '0' AFTER 10 ns;
                                END IF;
                                IF startburstx1 = true THEN
                                    AXR1Out1_zd := XSR11Tmp(bitcnt1);
                                END IF;
                                bitcnt1 := bitcnt1 + 1;
                                IF bitcnt1 = slotsize THEN
                                    startburstx1 := false;
                                    bitcnt1 := 0;
                                    transmit1 := false;
                                END IF;

                            ELSIF DITEN1 = '1' AND mode = 384 THEN -- DIT

                                IF startflagx1 = true THEN
                                    startflagx1 := false;
                                    XSR11 <= XBUF11;
                                    XSR11Tmp := XBUF11;
                                    TMPReg1(23 downto 0) :=
                                    XSR11Tmp(23 downto 0);
                                    TMPReg1(24) := VA1;
                                    TMPReg1(25) := DITCSRA0(0);
                                    TMPReg1(26) := DITUDRA0(0);
                                    TMPReg1(27) := '0';
                                    IF TMPReg1(0) = '0' THEN
                                        Tmp1Reg56(0) := '1';
                                        Tmp1Reg56(1) := '1';
                                    ELSE
                                        Tmp1Reg56(0) := '1';
                                        Tmp1Reg56(1) := '0';
                                    END IF;
                                    FOR I IN 1 TO 27 LOOP
                                        IF Tmp1Reg56(2*i - 1) = '0' THEN
                                            IF TMPReg1(i) = '0' THEN
                                                Tmp1Reg56(2*i) := '1';
                                                Tmp1Reg56 (2*i + 1) := '1';
                                             ELSE
                                                Tmp1Reg56(2*i) := '1';
                                                Tmp1Reg56(2*i + 1) := '0';
                                            END IF;
                                        ELSE
                                            IF TMPReg1(i) = '0' THEN
                                                Tmp1Reg56(2*i) := '0';
                                                Tmp1Reg56(2*i + 1) := '0';
                                             ELSE
                                                Tmp1Reg56(2*i) := '0';
                                                Tmp1Reg56(2*i + 1) := '1';
                                            END IF;
                                        END IF;
                                    END LOOP;
                                    Reg1 := Tmp1Reg56 & "11101000";
                                    XRDY11_RD <= '1', '0' AFTER 10 ns;
                                    slotcnt1 := 0;
                                    framecnt1 := 0;
                                    subframe1 := '0';
                                    bitcnt1 := 0;
                                END IF;
                                AXR1Out1_zd := Reg1(bitcnt1);
                                bitcnt1 := bitcnt1 + 1;
                                IF bitcnt1 = 64 THEN
                                    XSR11 <= XBUF11;
                                    XSR11Tmp := XBUF11;
                                    IF subframe1 = '0' THEN
                                        subframe1 := '1';
                                        TMPReg1(23 downto 0) :=
                                        XSR11Tmp(23 downto 0);
                                        TMPReg1(24) := VB1;
                                        IF framecnt1 > 159 THEN
                                            TMPReg1(25) :=
                                            DITCSRB5(framecnt1 - 160);
                                            TMPReg1(26) :=
                                            DITUDRB5(framecnt1 - 160);
                                        ELSIF framecnt1 > 127 THEN
                                            TMPReg1(25) :=
                                            DITCSRB4(framecnt1 - 128);
                                            TMPReg1(26) :=
                                            DITUDRB4(framecnt1 - 128);
                                        ELSIF framecnt1 > 95 THEN
                                            TMPReg1(25) :=
                                            DITCSRB3(framecnt1 - 96);
                                            TMPReg1(26) :=
                                            DITUDRB3(framecnt1 - 96);
                                        ELSIF framecnt1 > 63 THEN
                                            TMPReg1(25) :=
                                            DITCSRB2(framecnt1 - 64);
                                            TMPReg1(26) :=
                                            DITUDRB2(framecnt1 - 64);
                                        ELSIF framecnt1 > 31 THEN
                                            TMPReg1(25) :=
                                            DITCSRB1(framecnt1 - 32);
                                            TMPReg1(26) :=
                                            DITUDRB1(framecnt1 - 32);
                                        ELSE
                                            TMPReg1(25) :=
                                            DITCSRB0(framecnt1);
                                            TMPReg1(26) :=
                                            DITUDRB0(framecnt1);
                                        END IF;
                                        TMPReg1(27) := '0';
                                        IF TMPReg1(0) = '0' THEN
                                            Tmp1Reg56(0) := '1';
                                            Tmp1Reg56(1) := '1';
                                        ELSE
                                            Tmp1Reg56(0) := '1';
                                            Tmp1Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp1Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg1(i) = '0' THEN
                                                    Tmp1Reg56(2*i) := '1';
                                                    Tmp1Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp1Reg56(2*i) := '1';
                                                    Tmp1Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg1(i) = '0' THEN
                                                    Tmp1Reg56(2*i) := '0';
                                                    Tmp1Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp1Reg56(2*i) := '0';
                                                    Tmp1Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg1 := Tmp1Reg56 & "11100100";
                                        XRDY11_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF slotcnt1 /= 383 THEN
                                        subframe1 := '0';
                                        framecnt1 := framecnt1 +1;
                                        IF framecnt1 = 192 THEN
                                            framecnt1 := 0;
                                            bitcnt1 := 0;
                                            slotcnt1 := 0;
                                            transmit1 := false;
                                        END IF;
                                        TMPReg1(23 downto 0) :=
                                        XSR11Tmp(23 downto 0);
                                        TMPReg1(24) := VA1;
                                        IF framecnt1 > 159 THEN
                                            TMPReg1(25) :=
                                            DITCSRA5(framecnt1 - 160);
                                            TMPReg1(26) :=
                                            DITUDRA5(framecnt1 - 160);
                                        ELSIF framecnt1 > 127 THEN
                                            TMPReg1(25) :=
                                            DITCSRA4(framecnt1 - 128);
                                            TMPReg1(26) :=
                                            DITUDRA4(framecnt1 - 128);
                                        ELSIF framecnt1 > 95 THEN
                                            TMPReg1(25) :=
                                            DITCSRA3(framecnt1 - 96);
                                            TMPReg1(26) :=
                                            DITUDRA3(framecnt1 - 96);
                                        ELSIF framecnt1 > 63 THEN
                                            TMPReg1(25) :=
                                            DITCSRA2(framecnt1 - 64);
                                            TMPReg1(26) :=
                                            DITUDRA2(framecnt1 - 64);
                                        ELSIF framecnt1 > 31 THEN
                                            TMPReg1(25) :=
                                            DITCSRA1(framecnt1 - 32);
                                            TMPReg1(26) :=
                                            DITUDRA1(framecnt1 - 32);
                                        ELSE
                                            TMPReg1(25) :=
                                            DITCSRA0(framecnt1);
                                            TMPReg1(26) :=
                                            DITUDRA0(framecnt1);
                                        END IF;
                                        TMPReg1(27) := '0';
                                        IF TMPReg1(0) = '0' THEN
                                            Tmp1Reg56(0) := '1';
                                            Tmp1Reg56(1) := '1';
                                        ELSE
                                            Tmp1Reg56(0) := '1';
                                            Tmp1Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp1Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg1(i) = '0' THEN
                                                    Tmp1Reg56(2*i) := '1';
                                                    Tmp1Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp1Reg56(2*i) := '1';
                                                    Tmp1Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg1(i) = '0' THEN
                                                    Tmp1Reg56(2*i) := '0';
                                                    Tmp1Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp1Reg56(2*i) := '0';
                                                    Tmp1Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg1 := Tmp1Reg56 & "11100010";
                                        XRDY11_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    bitcnt1 := 0;
                                    slotcnt1 := slotcnt1 +1;
                                END IF;

                            ELSIF DITEN1 = '0' THEN -- TDM

                                IF XTDM1(slotcnt1) = '1' THEN --active slot
                                    IF delayx = 0 AND startflagx1 = true THEN
                                        startflagx1 := false;
                                        XSR11 <= XBUF11;
                                        XSR11Tmp := XBUF11;
                                        bitcnt1 := 0;
                                        slotcnt1 := 0;
                                        IF XRDY11 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR11Tmp := (others => '0');
                                        END IF;
                                        XRDY11_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF delayx = 1 AND startflagx1 = true THEN
                                        startflagx1 := false;
                                        bitcnt1 := slotsize - 1;
                                        slotcnt1 := mode - 1;
                                    ELSIF delayx = 2 AND startflagx1 = true THEN
                                        startflagx1 := false;
                                        bitcnt1 := slotsize - 2;
                                        slotcnt1 := mode - 1;
                                    END IF;
                                    AXR1Out1_zd := XSR11Tmp(bitcnt1);
                                    XSLOTCNT1 <= to_slv(slotcnt1,10);
                                    bitcnt1 := bitcnt1 + 1;
                                    IF delayx = 0 AND slotcnt1 = (mode - 1)
                                       AND bitcnt1 = slotsize THEN
                                        transmit1 := false;
                                    ELSIF delayx = 1 AND slotcnt1 = (mode - 1)
                                          AND bitcnt1 = (slotsize - 1) THEN
                                        transmit1 := false;
                                    ELSIF delayx = 2 AND slotcnt1 = (mode - 1)
                                          AND bitcnt1 = (slotsize - 2) THEN
                                        transmit1 := false;
                                    END IF;
                                    IF bitcnt1 = slotsize THEN
                                       IF not(slotcnt1 = mode - 1 AND
                                          delayx = 0) THEN
                                            slotcnt1 := slotcnt1 + 1;
                                            bitcnt1 := 0;
                                            XSR11 <= XBUF11;
                                            XSR11Tmp := XBUF11;
                                            IF XRDY11 = '1' THEN
                                                XUNDERN1_flag <=
                                                '1', '0' AFTER 10 ns;
                                                XSR11Tmp := (others => '0');
                                            END IF;
                                            XRDY11_RD <= '1', '0' AFTER 10 ns;
                                        END IF;
                                    END IF;
                                    IF slotcnt1 = mode THEN
                                        slotcnt1 := 0;
                                        bitcnt1 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD11 = "00" THEN
                                        AXR1Out1_zd := 'Z';
                                    ELSIF DISMOD11 = "10" THEN
                                        AXR1Out1_zd := '0';
                                    ELSIF DISMOD11 = "11" THEN
                                        AXR1Out1_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF rising_edge(XCLK) AND transmit = false THEN
                            syncxcnt1 := syncxcnt1 + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN "10" => -- serializer is receiver
                IF RSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(1) = '0' AND PDIR1(1) = '1' THEN
                        IF DISMOD11 = "00" THEN
                            AXR1Out1_zd := 'Z';
                        ELSIF DISMOD11 = "10" THEN
                            AXR1Out1_zd := '0';
                        ELSIF DISMOD11 = "11" THEN
                            AXR1Out1_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF RSRCLR1 = '1' THEN -- receive serializers are active
                        IF falling_edge(RCLK) AND receive1 = true THEN

                            IF moder = 0 THEN -- burst
                                IF delayr = 0 AND startflagr1 = true THEN
                                    startflagr1 := false;
                                    startburstr1 := true;
                                    bitcntr1 := 0;
                                ELSIF delayr = 1 AND startflagr1 = true AND
                                      bitcntr1 = 1 THEN
                                    bitcntr1 := 0;
                                    startflagr1 := false;
                                    startburstr1 := true;
                                ELSIF delayr = 2 AND startflagr1 = true AND
                                      bitcntr1 = 2 THEN
                                    bitcntr1 := 0;
                                    startflagr1 := false;
                                    startburstr1 := true;
                                END IF;
                                IF startburstr1 = true THEN
                                    RSR11Tmp(bitcntr1) := AXR1In1;
                                END IF;
                                bitcntr1 := bitcntr1 + 1;
                                IF bitcntr1 = slotsizer THEN
                                    startburstr1 := false;
                                    bitcntr1 := 0;
                                    receive1 := false;
                                    RSR11 <= RSR11Tmp;
                                    RBUF11 <= RSR11Tmp;
                                    RRDY11_RD <= '1', '0' AFTER 10 ns;
                                END IF;

                            ELSE -- TDM

                                IF RTDM1(slotcntr1) = '1' THEN --active slot
                                    IF delayr = 0 AND startflagr1 = true THEN
                                        startflagr1 := false;
                                        bitcntr1 := 0;
                                        slotcntr1 := 0;
                                    ELSIF delayr = 1 AND startflagr1 = true THEN
                                        startflagr1 := false;
                                        bitcntr1 := slotsizer - 1;
                                        slotcntr1 := moder - 1;
                                    ELSIF delayr = 2 AND startflagr1 = true THEN
                                        startflagr1 := false;
                                        bitcntr1 := slotsizer - 2;
                                        slotcntr1 := moder - 1;
                                    END IF;
                                    IF DLBEN1 = '1' AND ASYNC1 = '0' AND
                                       MODE1 = "01" AND mode < 33 AND
                                       ORD1 = '1' THEN
                                        IF mode > 1 THEN -- Loopback mode
                                            RSR11Tmp(bitcntr1) := AXR1Out0_zd;
                                        END IF;
                                    ELSE
                                        RSR11Tmp(bitcntr1) := AXR1In1;
                                    END IF;
                                    RSLOTCNT1 <= to_slv(slotcntr1,10);
                                    bitcntr1 := bitcntr1 + 1;
                                    IF delayr = 0 AND slotcntr1 = (moder - 1)
                                       AND bitcntr1 = slotsizer THEN
                                        receive1 := false;
                                    ELSIF delayr = 1 AND slotcntr1 = (moder - 1)
                                          AND bitcntr1 = (slotsizer - 1) THEN
                                        receive1 := false;
                                    ELSIF delayr = 2 AND slotcntr1 = (moder - 1)
                                          AND bitcntr1 = (slotsizer - 2) THEN
                                        receive1 := false;
                                    END IF;
                                    IF bitcntr1 = slotsizer THEN
                                        slotcntr1 := slotcntr1 + 1;
                                        bitcntr1 := 0;
                                        RSR11 <= RSR11Tmp;
                                        RBUF11 <= RSR11Tmp;
                                        IF RRDY11 = '1' THEN
                                            ROVERN1_flag <=
                                                    '1', '0' AFTER 10 ns;
                                        END IF;
                                        RRDY11_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    IF slotcntr1 = moder THEN
                                        slotcntr1 := 0;
                                        bitcntr1 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD11 = "00" THEN
                                        AXR1Out1_zd := 'Z';
                                    ELSIF DISMOD11 = "10" THEN
                                        AXR1Out1_zd := '0';
                                    ELSIF DISMOD11 = "11" THEN
                                        AXR1Out1_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF falling_edge(RCLK) AND receive1 = false THEN
                            syncrcnt1 := syncrcnt1 + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN others =>
                null;
        END CASE;

        --serializer2
        CASE SRMOD21 IS
            WHEN "00" => -- inactive serializer
                IF DISMOD21 = "00" THEN
                    AXR1Out2_zd := 'Z';
                ELSIF DISMOD21 = "10" THEN
                    AXR1Out2_zd := '0';
                ELSIF DISMOD21 = "11" THEN
                    AXR1Out2_zd := '1';
                END IF;
            WHEN "01" => -- serializer is transmitter
                IF XSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(2) = '0' AND PDIR1(2) = '1' THEN
                        IF DISMOD21 = "00" THEN
                            AXR1Out2_zd := 'Z';
                        ELSIF DISMOD21 = "10" THEN
                            AXR1Out2_zd := '0';
                        ELSIF DISMOD21 = "11" THEN
                            AXR1Out2_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF XSRCLR1 = '1' THEN -- transmit serializers are active
                        IF (rising_edge(XCLK) AND transmit2 = true) OR
                           (rising_edge(FSX1_int) AND FSXP1 = '0') OR
                           (falling_edge(FSX1_int) AND FSXP1 = '1') THEN

                            IF mode = 0 AND DITEN1 = '0' THEN -- burst
                                IF delayx = 0 AND startflagx2 = true THEN
                                    bitcnt2 := 0;
                                    startflagx2 := false;
                                    startburstx2 := true;
                                    XSR21 <= XBUF21;
                                    XSR21Tmp := XBUF21;
                                    IF XRDY21 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR21Tmp := (others => '0');
                                        END IF;
                                    XRDY21_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 1 AND startflagx2 = true AND
                                      bitcnt2 = 1 THEN
                                    bitcnt2 := 0;
                                    startflagx2 := false;
                                    startburstx2 := true;
                                    XSR21 <= XBUF21;
                                    XSR21Tmp := XBUF21;
                                    IF XRDY21 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR21Tmp := (others => '0');
                                        END IF;
                                    XRDY21_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 2 AND startflagx2 = true AND
                                      bitcnt2 = 2 THEN
                                    bitcnt2 := 0;
                                    startflagx2 := false;
                                    startburstx2 := true;
                                    XSR21 <= XBUF21;
                                    XSR21Tmp := XBUF21;
                                    IF XRDY21 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR21Tmp := (others => '0');
                                        END IF;
                                    XRDY21_RD <= '1', '0' AFTER 10 ns;
                                END IF;
                                IF startburstx2 = true THEN
                                    AXR1Out2_zd := XSR21Tmp(bitcnt2);
                                END IF;
                                bitcnt2 := bitcnt2 + 1;
                                IF bitcnt2 = slotsize THEN
                                    startburstx2 := false;
                                    bitcnt2 := 0;
                                    transmit2 := false;
                                END IF;

                            ELSIF DITEN1 = '1' AND mode = 384 THEN -- DIT

                                IF startflagx2 = true THEN
                                    startflagx2 := false;
                                    XSR21 <= XBUF21;
                                    XSR21Tmp := XBUF21;
                                    TMPReg2(23 downto 0) :=
                                    XSR21Tmp(23 downto 0);
                                    TMPReg2(24) := VA1;
                                    TMPReg2(25) := DITCSRA0(0);
                                    TMPReg2(26) := DITUDRA0(0);
                                    TMPReg2(27) := '0';
                                    IF TMPReg2(0) = '0' THEN
                                        Tmp2Reg56(0) := '1';
                                        Tmp2Reg56(1) := '1';
                                    ELSE
                                        Tmp2Reg56(0) := '1';
                                        Tmp2Reg56(1) := '0';
                                    END IF;
                                    FOR I IN 1 TO 27 LOOP
                                        IF Tmp2Reg56(2*i - 1) = '0' THEN
                                            IF TMPReg2(i) = '0' THEN
                                                Tmp2Reg56(2*i) := '1';
                                                Tmp2Reg56 (2*i + 1) := '1';
                                             ELSE
                                                Tmp2Reg56(2*i) := '1';
                                                Tmp2Reg56(2*i + 1) := '0';
                                            END IF;
                                        ELSE
                                            IF TMPReg2(i) = '0' THEN
                                                Tmp2Reg56(2*i) := '0';
                                                Tmp2Reg56(2*i + 1) := '0';
                                             ELSE
                                                Tmp2Reg56(2*i) := '0';
                                                Tmp2Reg56(2*i + 1) := '1';
                                            END IF;
                                        END IF;
                                    END LOOP;
                                    Reg2 := Tmp2Reg56 & "11101000";
                                    XRDY21_RD <= '1', '0' AFTER 10 ns;
                                    slotcnt2 := 0;
                                    framecnt2 := 0;
                                    subframe2 := '0';
                                    bitcnt2 := 0;
                                END IF;
                                AXR1Out2_zd := Reg2(bitcnt2);
                                bitcnt2 := bitcnt2 + 1;
                                IF bitcnt2 = 64 THEN
                                    XSR21 <= XBUF21;
                                    XSR21Tmp := XBUF21;
                                    IF subframe2 = '0' THEN
                                        subframe2 := '1';
                                        TMPReg2(23 downto 0) :=
                                        XSR21Tmp(23 downto 0);
                                        TMPReg2(24) := VB1;
                                        IF framecnt2 > 159 THEN
                                            TMPReg2(25) :=
                                            DITCSRB5(framecnt2 - 160);
                                            TMPReg2(26) :=
                                            DITUDRB5(framecnt2 - 160);
                                        ELSIF framecnt2 > 127 THEN
                                            TMPReg2(25) :=
                                            DITCSRB4(framecnt2 - 128);
                                            TMPReg2(26) :=
                                            DITUDRB4(framecnt2 - 128);
                                        ELSIF framecnt2 > 95 THEN
                                            TMPReg2(25) :=
                                            DITCSRB3(framecnt2 - 96);
                                            TMPReg2(26) :=
                                            DITUDRB3(framecnt2 - 96);
                                        ELSIF framecnt2 > 63 THEN
                                            TMPReg2(25) :=
                                            DITCSRB2(framecnt2 - 64);
                                            TMPReg2(26) :=
                                            DITUDRB2(framecnt2 - 64);
                                        ELSIF framecnt2 > 31 THEN
                                            TMPReg2(25) :=
                                            DITCSRB1(framecnt2 - 32);
                                            TMPReg2(26) :=
                                            DITUDRB1(framecnt2 - 32);
                                        ELSE
                                            TMPReg2(25) :=
                                            DITCSRB0(framecnt2);
                                            TMPReg2(26) :=
                                            DITUDRB0(framecnt2);
                                        END IF;
                                        TMPReg2(27) := '0';
                                        IF TMPReg2(0) = '0' THEN
                                            Tmp2Reg56(0) := '1';
                                            Tmp2Reg56(1) := '1';
                                        ELSE
                                            Tmp2Reg56(0) := '1';
                                            Tmp2Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp2Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg2(i) = '0' THEN
                                                    Tmp2Reg56(2*i) := '1';
                                                    Tmp2Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp2Reg56(2*i) := '1';
                                                    Tmp2Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg2(i) = '0' THEN
                                                    Tmp2Reg56(2*i) := '0';
                                                    Tmp2Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp2Reg56(2*i) := '0';
                                                    Tmp2Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg2 := Tmp2Reg56 & "11100100";
                                        XRDY21_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF slotcnt2 /= 383 THEN
                                        subframe2 := '0';
                                        framecnt2 := framecnt2 +1;
                                        IF framecnt2 = 192 THEN
                                            framecnt2 := 0;
                                            bitcnt2 := 0;
                                            slotcnt2 := 0;
                                            transmit2 := false;
                                        END IF;
                                        TMPReg2(23 downto 0) :=
                                        XSR21Tmp(23 downto 0);
                                        TMPReg2(24) := VA1;
                                        IF framecnt2 > 159 THEN
                                            TMPReg2(25) :=
                                            DITCSRA5(framecnt2 - 160);
                                            TMPReg2(26) :=
                                            DITUDRA5(framecnt2 - 160);
                                        ELSIF framecnt2 > 127 THEN
                                            TMPReg2(25) :=
                                            DITCSRA4(framecnt2 - 128);
                                            TMPReg2(26) :=
                                            DITUDRA4(framecnt2 - 128);
                                        ELSIF framecnt2 > 95 THEN
                                            TMPReg2(25) :=
                                            DITCSRA3(framecnt2 - 96);
                                            TMPReg2(26) :=
                                            DITUDRA3(framecnt2 - 96);
                                        ELSIF framecnt2 > 63 THEN
                                            TMPReg2(25) :=
                                            DITCSRA2(framecnt2 - 64);
                                            TMPReg2(26) :=
                                            DITUDRA2(framecnt2 - 64);
                                        ELSIF framecnt2 > 31 THEN
                                            TMPReg2(25) :=
                                            DITCSRA1(framecnt2 - 32);
                                            TMPReg2(26) :=
                                            DITUDRA1(framecnt2 - 32);
                                        ELSE
                                            TMPReg2(25) :=
                                            DITCSRA0(framecnt2);
                                            TMPReg2(26) :=
                                            DITUDRA0(framecnt2);
                                        END IF;
                                        TMPReg2(27) := '0';
                                        IF TMPReg2(0) = '0' THEN
                                            Tmp2Reg56(0) := '1';
                                            Tmp2Reg56(1) := '1';
                                        ELSE
                                            Tmp2Reg56(0) := '1';
                                            Tmp2Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp2Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg2(i) = '0' THEN
                                                    Tmp2Reg56(2*i) := '1';
                                                    Tmp2Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp2Reg56(2*i) := '1';
                                                    Tmp2Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg2(i) = '0' THEN
                                                    Tmp2Reg56(2*i) := '0';
                                                    Tmp2Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp2Reg56(2*i) := '0';
                                                    Tmp2Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg2 := Tmp2Reg56 & "11100010";
                                        XRDY21_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    bitcnt2 := 0;
                                    slotcnt2 := slotcnt2 +1;
                                END IF;

                            ELSIF DITEN1 = '0' THEN -- TDM

                                IF XTDM1(slotcnt2) = '1' THEN --active slot
                                    IF delayx = 0 AND startflagx2 = true THEN
                                        startflagx2 := false;
                                        XSR21 <= XBUF21;
                                        XSR21Tmp := XBUF21;
                                        bitcnt2 := 0;
                                        slotcnt2 := 0;
                                        IF XRDY21 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR21Tmp := (others => '0');
                                        END IF;
                                        XRDY21_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF delayx = 1 AND startflagx2 = true THEN
                                        startflagx2 := false;
                                        bitcnt2 := slotsize - 1;
                                        slotcnt2 := mode - 1;
                                    ELSIF delayx = 2 AND startflagx2 = true THEN
                                        startflagx2 := false;
                                        bitcnt2 := slotsize - 2;
                                        slotcnt2 := mode - 1;
                                    END IF;
                                    AXR1Out2_zd := XSR21Tmp(bitcnt2);
                                    XSLOTCNT1 <= to_slv(slotcnt2,10);
                                    bitcnt2 := bitcnt2 + 1;
                                    IF delayx = 0 AND slotcnt2 = (mode - 1)
                                       AND bitcnt2 = slotsize THEN
                                        transmit2 := false;
                                    ELSIF delayx = 1 AND slotcnt2 = (mode - 1)
                                          AND bitcnt2 = (slotsize - 1) THEN
                                        transmit2 := false;
                                    ELSIF delayx = 2 AND slotcnt2 = (mode - 1)
                                          AND bitcnt2 = (slotsize - 2) THEN
                                        transmit2 := false;
                                    END IF;
                                    IF bitcnt2 = slotsize THEN
                                       IF not(slotcnt2 = mode - 1 AND
                                          delayx = 0) THEN
                                            slotcnt2 := slotcnt2 + 1;
                                            bitcnt2 := 0;
                                            XSR21 <= XBUF21;
                                            XSR21Tmp := XBUF21;
                                            IF XRDY21 = '1' THEN
                                                XUNDERN1_flag <=
                                                       '1', '0' AFTER 10 ns;
                                                XSR21Tmp := (others => '0');
                                            END IF;
                                            XRDY21_RD <= '1', '0' AFTER 10 ns;
                                        END IF;
                                    END IF;
                                    IF slotcnt2 = mode THEN
                                        slotcnt2 := 0;
                                        bitcnt2 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD21 = "00" THEN
                                        AXR1Out2_zd := 'Z';
                                    ELSIF DISMOD21 = "10" THEN
                                        AXR1Out2_zd := '0';
                                    ELSIF DISMOD21 = "11" THEN
                                        AXR1Out2_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF rising_edge(XCLK) AND transmit2 = false THEN
                            syncxcnt2 := syncxcnt2 + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN "10" => -- serializer is receiver
                IF RSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(2) = '0' AND PDIR1(2) = '1' THEN
                        IF DISMOD21 = "00" THEN
                            AXR1Out2_zd := 'Z';
                        ELSIF DISMOD21 = "10" THEN
                            AXR1Out2_zd := '0';
                        ELSIF DISMOD21 = "11" THEN
                            AXR1Out2_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF RSRCLR1 = '1' THEN -- receive serializers are active
                        IF falling_edge(RCLK) AND receive2 = true THEN

                            IF moder = 0 THEN -- burst
                                IF delayr = 0 AND startflagr2 = true THEN
                                    bitcntr2 := 0;
                                    startflagr2 := false;
                                    startburstr2 := true;
                                ELSIF delayr = 1 AND startflagr2 = true AND
                                      bitcntr2 = 1 THEN
                                    bitcntr2 := 0;
                                    startflagr2 := false;
                                    startburstr2 := true;
                                ELSIF delayr = 2 AND startflagr2 = true AND
                                      bitcntr2 = 2 THEN
                                    bitcntr2 := 0;
                                    startflagr2 := false;
                                    startburstr2 := true;
                                END IF;
                                IF startburstr2 = true THEN
                                    RSR01Tmp(bitcntr2) := AXR1In2;
                                END IF;
                                bitcntr2 := bitcntr2 + 1;
                                IF bitcntr2 = slotsizer THEN
                                    startburstr2 := false;
                                    bitcntr2 := 0;
                                    receive2 := false;
                                    RSR21 <= RSR21Tmp;
                                    RBUF21 <= RSR21Tmp;
                                    RRDY21_RD <= '1', '0' AFTER 10 ns;
                                END IF;

                            ELSE -- TDM

                                IF RTDM1(slotcntr2) = '1' THEN --active slot
                                    IF delayr = 0 AND startflagr2 = true THEN
                                        startflagr2 := false;
                                        bitcntr2 := 0;
                                        slotcntr2 := 0;
                                    ELSIF delayr = 1 AND startflagr2 = true THEN
                                        startflagr2 := false;
                                        bitcntr2 := slotsizer - 1;
                                        slotcntr2 := moder - 1;
                                    ELSIF delayr = 2 AND startflagr2 = true THEN
                                        startflagr2 := false;
                                        bitcntr2 := slotsizer - 2;
                                        slotcntr2 := moder - 1;
                                    END IF;
                                    IF DLBEN1 = '1' AND ASYNC1 = '0' AND
                                       MODE1 = "01" AND mode < 33 AND
                                       ORD1 = '0' THEN
                                        IF mode > 1 THEN -- Loopback mode
                                            RSR21Tmp(bitcntr2) := AXR1Out3_zd;
                                        END IF;
                                    ELSE
                                        RSR21Tmp(bitcntr2) := AXR1In2;
                                    END IF;
                                    RSLOTCNT1 <= to_slv(slotcntr2,10);
                                    bitcntr2 := bitcntr2 + 1;
                                    IF delayr = 0 AND slotcntr2 = (moder - 1)
                                       AND bitcntr2 = slotsizer THEN
                                        receive2 := false;
                                    ELSIF delayr = 1 AND slotcntr2 = (moder - 1)
                                          AND bitcntr2 = (slotsizer - 1) THEN
                                        receive2 := false;
                                    ELSIF delayr = 2 AND slotcntr2 = (moder - 1)
                                          AND bitcntr2 = (slotsizer - 2) THEN
                                        receive2 := false;
                                    END IF;
                                    IF bitcntr2 = slotsizer THEN
                                        slotcntr2 := slotcntr2 + 1;
                                        bitcntr2 := 0;
                                        RSR21 <= RSR21Tmp;
                                        RBUF21 <= RSR21Tmp;
                                        IF RRDY21 = '1' THEN
                                            ROVERN1_flag <=
                                                     '1', '0' AFTER 10 ns;
                                        END IF;
                                        RRDY21_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    IF slotcntr2 = moder THEN
                                        slotcntr2 := 0;
                                        bitcntr2 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD21 = "00" THEN
                                        AXR1Out2_zd := 'Z';
                                    ELSIF DISMOD21 = "10" THEN
                                        AXR1Out2_zd := '0';
                                    ELSIF DISMOD21 = "11" THEN
                                        AXR1Out2_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF falling_edge(RCLK) AND receive2 = false THEN
                            syncrcnt2 := syncrcnt2 + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN others =>
                null;
        END CASE;

        --serializer3
        CASE SRMOD31 IS
            WHEN "00" => -- inactive serializer
                IF DISMOD31 = "00" THEN
                    AXR1Out3_zd := 'Z';
                ELSIF DISMOD31 = "10" THEN
                    AXR1Out3_zd := '0';
                ELSIF DISMOD31 = "11" THEN
                    AXR1Out3_zd := '1';
                END IF;
            WHEN "01" => -- serializer is transmitter
                IF XSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(3) = '0' AND PDIR1(3) = '1' THEN
                        IF DISMOD31 = "00" THEN
                            AXR1Out3_zd := 'Z';
                        ELSIF DISMOD31 = "10" THEN
                            AXR1Out3_zd := '0';
                        ELSIF DISMOD31 = "11" THEN
                            AXR1Out3_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF XSRCLR1 = '1' THEN -- transmit serializers are active
                        IF (rising_edge(XCLK) AND transmit3 = true) OR
                           (rising_edge(FSX1_int) AND FSXP1 = '0') OR
                           (falling_edge(FSX1_int) AND FSXP1 = '1') THEN

                            IF mode = 0 AND DITEN1 = '0' THEN -- burst
                                IF delayx = 0 AND startflagx3 = true THEN
                                    bitcnt3 := 0;
                                    startflagx3 := false;
                                    startburstx3 := true;
                                    XSR31 <= XBUF31;
                                    XSR31Tmp := XBUF31;
                                    IF XRDY31 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR31Tmp := (others => '0');
                                        END IF;
                                    XRDY31_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 1 AND startflagx3 = true AND
                                      bitcnt3 = 1 THEN
                                    bitcnt3 := 0;
                                    startflagx3 := false;
                                    startburstx3 := true;
                                    XSR31 <= XBUF31;
                                    XSR31Tmp := XBUF31;
                                    IF XRDY31 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR31Tmp := (others => '0');
                                        END IF;
                                    XRDY31_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 2 AND startflagx3 = true AND
                                      bitcnt3 = 2 THEN
                                    bitcnt3 := 0;
                                    startflagx3 := false;
                                    startburstx3 := true;
                                    XSR31 <= XBUF31;
                                    XSR31Tmp := XBUF31;
                                    IF XRDY31 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR31Tmp := (others => '0');
                                        END IF;
                                    XRDY31_RD <= '1', '0' AFTER 10 ns;
                                END IF;
                                IF startburstx3 = true THEN
                                    AXR1Out3_zd := XSR31Tmp(bitcnt3);
                                END IF;
                                bitcnt3 := bitcnt3 + 1;
                                IF bitcnt3 = slotsize THEN
                                    startburstx3 := false;
                                    bitcnt3 := 0;
                                    transmit3 := false;
                                END IF;

                            ELSIF DITEN1 = '1' AND mode = 384 THEN -- DIT

                                IF startflagx3 = true THEN
                                    startflagx3 := false;
                                    XSR31 <= XBUF31;
                                    XSR31Tmp := XBUF31;
                                    TMPReg3(23 downto 0) :=
                                    XSR31Tmp(23 downto 0);
                                    TMPReg3(24) := VA1;
                                    TMPReg3(25) := DITCSRA0(0);
                                    TMPReg3(26) := DITUDRA0(0);
                                    TMPReg3(27) := '0';
                                    IF TMPReg3(0) = '0' THEN
                                        Tmp3Reg56(0) := '1';
                                        Tmp3Reg56(1) := '1';
                                    ELSE
                                        Tmp3Reg56(0) := '1';
                                        Tmp3Reg56(1) := '0';
                                    END IF;
                                    FOR I IN 1 TO 27 LOOP
                                        IF Tmp3Reg56(2*i - 1) = '0' THEN
                                            IF TMPReg3(i) = '0' THEN
                                                Tmp3Reg56(2*i) := '1';
                                                Tmp3Reg56 (2*i + 1) := '1';
                                             ELSE
                                                Tmp3Reg56(2*i) := '1';
                                                Tmp3Reg56(2*i + 1) := '0';
                                            END IF;
                                        ELSE
                                            IF TMPReg3(i) = '0' THEN
                                                Tmp3Reg56(2*i) := '0';
                                                Tmp3Reg56(2*i + 1) := '0';
                                             ELSE
                                                Tmp3Reg56(2*i) := '0';
                                                Tmp3Reg56(2*i + 1) := '1';
                                            END IF;
                                        END IF;
                                    END LOOP;
                                    Reg3 := Tmp3Reg56 & "11101000";
                                    XRDY31_RD <= '1', '0' AFTER 10 ns;
                                    slotcnt3 := 0;
                                    framecnt3 := 0;
                                    subframe3 := '0';
                                    bitcnt3 := 0;
                                END IF;
                                AXR1Out3_zd := Reg3(bitcnt3);
                                bitcnt3 := bitcnt3 + 1;
                                IF bitcnt3 = 64 THEN
                                    XSR31 <= XBUF31;
                                    XSR31Tmp := XBUF31;
                                    IF subframe3 = '0' THEN
                                        subframe3 := '1';
                                        TMPReg3(23 downto 0) :=
                                        XSR31Tmp(23 downto 0);
                                        TMPReg3(24) := VB1;
                                        IF framecnt3 > 159 THEN
                                            TMPReg3(25) :=
                                            DITCSRB5(framecnt3 - 160);
                                            TMPReg3(26) :=
                                            DITUDRB5(framecnt3 - 160);
                                        ELSIF framecnt3 > 127 THEN
                                            TMPReg3(25) :=
                                            DITCSRB4(framecnt3 - 128);
                                            TMPReg3(26) :=
                                            DITUDRB4(framecnt3 - 128);
                                        ELSIF framecnt3 > 95 THEN
                                            TMPReg3(25) :=
                                            DITCSRB3(framecnt3 - 96);
                                            TMPReg3(26) :=
                                            DITUDRB3(framecnt3 - 96);
                                        ELSIF framecnt3 > 63 THEN
                                            TMPReg3(25) :=
                                            DITCSRB2(framecnt3 - 64);
                                            TMPReg3(26) :=
                                            DITUDRB2(framecnt3 - 64);
                                        ELSIF framecnt3 > 31 THEN
                                            TMPReg3(25) :=
                                            DITCSRB1(framecnt3 - 32);
                                            TMPReg3(26) :=
                                            DITUDRB1(framecnt3 - 32);
                                        ELSE
                                            TMPReg3(25) :=
                                            DITCSRB0(framecnt3);
                                            TMPReg3(26) :=
                                            DITUDRB0(framecnt3);
                                        END IF;
                                        TMPReg3(27) := '0';
                                        IF TMPReg3(0) = '0' THEN
                                            Tmp3Reg56(0) := '1';
                                            Tmp3Reg56(1) := '1';
                                        ELSE
                                            Tmp3Reg56(0) := '1';
                                            Tmp3Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp3Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg3(i) = '0' THEN
                                                    Tmp3Reg56(2*i) := '1';
                                                    Tmp3Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp3Reg56(2*i) := '1';
                                                    Tmp3Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg3(i) = '0' THEN
                                                    Tmp3Reg56(2*i) := '0';
                                                    Tmp3Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp3Reg56(2*i) := '0';
                                                    Tmp3Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg3 := Tmp3Reg56 & "11100100";
                                        XRDY31_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF slotcnt3 /= 383 THEN
                                        subframe3 := '0';
                                        framecnt3 := framecnt3 +1;
                                        IF framecnt3 = 192 THEN
                                            framecnt3 := 0;
                                            bitcnt3 := 0;
                                            slotcnt3 := 0;
                                            transmit3 := false;
                                        END IF;
                                        TMPReg3(23 downto 0) :=
                                        XSR31Tmp(23 downto 0);
                                        TMPReg3(24) := VA1;
                                        IF framecnt3 > 159 THEN
                                            TMPReg3(25) :=
                                            DITCSRA5(framecnt3 - 160);
                                            TMPReg3(26) :=
                                            DITUDRA5(framecnt3 - 160);
                                        ELSIF framecnt3 > 127 THEN
                                            TMPReg3(25) :=
                                            DITCSRA4(framecnt3 - 128);
                                            TMPReg3(26) :=
                                            DITUDRA4(framecnt3 - 128);
                                        ELSIF framecnt3 > 95 THEN
                                            TMPReg3(25) :=
                                            DITCSRA3(framecnt3 - 96);
                                            TMPReg3(26) :=
                                            DITUDRA3(framecnt3 - 96);
                                        ELSIF framecnt3 > 63 THEN
                                            TMPReg3(25) :=
                                            DITCSRA2(framecnt3 - 64);
                                            TMPReg3(26) :=
                                            DITUDRA2(framecnt3 - 64);
                                        ELSIF framecnt3 > 31 THEN
                                            TMPReg3(25) :=
                                            DITCSRA1(framecnt3 - 32);
                                            TMPReg3(26) :=
                                            DITUDRA1(framecnt3 - 32);
                                        ELSE
                                            TMPReg3(25) :=
                                            DITCSRA0(framecnt3);
                                            TMPReg3(26) :=
                                            DITUDRA0(framecnt3);
                                        END IF;
                                        TMPReg3(27) := '0';
                                        IF TMPReg3(0) = '0' THEN
                                            Tmp3Reg56(0) := '1';
                                            Tmp3Reg56(1) := '1';
                                        ELSE
                                            Tmp3Reg56(0) := '1';
                                            Tmp3Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp3Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg3(i) = '0' THEN
                                                    Tmp3Reg56(2*i) := '1';
                                                    Tmp3Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp3Reg56(2*i) := '1';
                                                    Tmp3Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg3(i) = '0' THEN
                                                    Tmp3Reg56(2*i) := '0';
                                                    Tmp3Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp3Reg56(2*i) := '0';
                                                    Tmp3Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg3 := Tmp3Reg56 & "11100010";
                                        XRDY31_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    bitcnt3 := 0;
                                    slotcnt3 := slotcnt3 +1;
                                END IF;

                            ELSIF DITEN1 = '0' THEN -- TDM

                                IF XTDM1(slotcnt3) = '1' THEN --active slot
                                    IF delayx = 0 AND startflagx3 = true THEN
                                        startflagx3 := false;
                                        XSR31 <= XBUF31;
                                        XSR31Tmp := XBUF31;
                                        bitcnt3 := 0;
                                        slotcnt3 := 0;
                                        IF XRDY31 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR31Tmp := (others => '0');
                                        END IF;
                                        XRDY31_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF delayx = 1 AND startflagx3 = true THEN
                                        startflagx3 := false;
                                        bitcnt3 := slotsize - 1;
                                        slotcnt3 := mode - 1;
                                    ELSIF delayx = 2 AND startflagx3 = true THEN
                                        startflagx3 := false;
                                        bitcnt3 := slotsize - 2;
                                        slotcnt3 := mode - 1;
                                    END IF;
                                    AXR1Out3_zd := XSR31Tmp(bitcnt3);
                                    XSLOTCNT1 <= to_slv(slotcnt3,10);
                                    bitcnt3 := bitcnt3 + 1;
                                    IF delayx = 0 AND slotcnt3 = (mode - 1)
                                       AND bitcnt3 = slotsize THEN
                                        transmit3 := false;
                                    ELSIF delayx = 1 AND slotcnt3 = (mode - 1)
                                          AND bitcnt3 = (slotsize - 1) THEN
                                        transmit3 := false;
                                    ELSIF delayx = 2 AND slotcnt3 = (mode - 1)
                                          AND bitcnt3 = (slotsize - 2) THEN
                                        transmit3 := false;
                                    END IF;
                                    IF bitcnt3 = slotsize THEN
                                        IF not(slotcnt2 = mode - 1 AND
                                          delayx = 0) THEN
                                            slotcnt3 := slotcnt3 + 1;
                                            bitcnt3 := 0;
                                            XSR31 <= XBUF31;
                                            XSR31Tmp := XBUF31;
                                            IF XRDY31 = '1' THEN
                                                XUNDERN1_flag <=
                                                       '1', '0' AFTER 10 ns;
                                                XSR31Tmp := (others => '0');
                                            END IF;
                                            XRDY31_RD <= '1', '0' AFTER 10 ns;
                                        END IF;
                                    END IF;
                                    IF slotcnt3 = mode THEN
                                        slotcnt3 := 0;
                                        bitcnt3 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD31 = "00" THEN
                                        AXR1Out3_zd := 'Z';
                                    ELSIF DISMOD31 = "10" THEN
                                        AXR1Out3_zd := '0';
                                    ELSIF DISMOD31 = "11" THEN
                                        AXR1Out3_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF rising_edge(XCLK) AND transmit3 = false THEN
                            syncxcnt3 := syncxcnt3 + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN "10" => -- serializer is receiver
                IF RSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(3) = '0' AND PDIR1(3) = '1' THEN
                        IF DISMOD31 = "00" THEN
                            AXR1Out3_zd := 'Z';
                        ELSIF DISMOD31 = "10" THEN
                            AXR1Out3_zd := '0';
                        ELSIF DISMOD31 = "11" THEN
                            AXR1Out3_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF RSRCLR1 = '1' THEN -- receive serializers are active
                        IF falling_edge(RCLK) AND receive3 = true THEN

                            IF moder = 0 THEN -- burst
                                IF delayr = 0 AND startflagr3 = true THEN
                                    bitcntr3 := 0;
                                    startflagr3 := false;
                                    startburstr3 := true;
                                ELSIF delayr = 1 AND startflagr3 = true AND
                                      bitcntr3 = 1 THEN
                                    bitcntr3 := 0;
                                    startflagr3 := false;
                                    startburstr3 := true;
                                ELSIF delayr = 2 AND startflagr3 = true AND
                                      bitcntr3 = 2 THEN
                                    bitcntr3 := 0;
                                    startflagr3 := false;
                                    startburstr3 := true;
                                END IF;
                                IF startburstr3 = true THEN
                                    RSR31Tmp(bitcntr3) := AXR1In3;
                                END IF;
                                bitcntr3 := bitcntr3 + 1;
                                IF bitcntr3 = slotsizer THEN
                                    startburstr3 := false;
                                    bitcntr3 := 0;
                                    receive3 := false;
                                    RSR31 <= RSR31Tmp;
                                    RBUF31 <= RSR31Tmp;
                                    RRDY31_RD <= '1', '0' AFTER 10 ns;
                                END IF;

                            ELSE -- TDM

                                IF RTDM1(slotcntr3) = '1' THEN --active slot
                                    IF delayr = 0 AND startflagr3 = true THEN
                                        startflagr3 := false;
                                        bitcntr3 := 0;
                                        slotcntr3 := 0;
                                    ELSIF delayr = 1 AND startflagr3 = true THEN
                                        startflagr3 := false;
                                        bitcntr3 := slotsizer - 1;
                                        slotcntr3 := moder - 1;
                                    ELSIF delayr = 2 AND startflagr3 = true THEN
                                        startflagr3 := false;
                                        bitcntr3 := slotsizer - 2;
                                        slotcntr3 := moder - 1;
                                    END IF;
                                    IF DLBEN1 = '1' AND ASYNC1 = '0' AND
                                       MODE1 = "01" AND mode < 33 AND
                                       ORD1 = '1' THEN
                                        IF mode > 1 THEN -- Loopback mode
                                            RSR31Tmp(bitcntr3) := AXR1Out2_zd;
                                        END IF;
                                    ELSE
                                        RSR31Tmp(bitcntr3) := AXR1In3;
                                    END IF;
                                    RSLOTCNT1 <= to_slv(slotcntr3,10);
                                    bitcntr3 := bitcntr3 + 1;
                                    IF delayr = 0 AND slotcntr3 = (moder - 1)
                                       AND bitcntr3 = slotsizer THEN
                                        receive3 := false;
                                    ELSIF delayr = 1 AND slotcntr3 = (moder - 1)
                                          AND bitcntr3 = (slotsizer - 1) THEN
                                        receive3 := false;
                                    ELSIF delayr = 2 AND slotcntr3 = (moder - 1)
                                          AND bitcntr3 = (slotsizer - 2) THEN
                                        receive3 := false;
                                    END IF;
                                    IF bitcntr3 = slotsizer THEN
                                        slotcntr3 := slotcntr3 + 1;
                                        bitcntr3 := 0;
                                        RSR31 <= RSR31Tmp;
                                        RBUF31 <= RSR31Tmp;
                                        IF RRDY31 = '1' THEN
                                            ROVERN1_flag <=
                                                    '1', '0' AFTER 10 ns;
                                        END IF;
                                        RRDY31_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    IF slotcntr3 = moder THEN
                                        slotcntr3 := 0;
                                        bitcntr3 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD31 = "00" THEN
                                        AXR1Out3_zd := 'Z';
                                    ELSIF DISMOD31 = "10" THEN
                                        AXR1Out3_zd := '0';
                                    ELSIF DISMOD31 = "11" THEN
                                        AXR1Out3_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF falling_edge(RCLK) AND receive3 = false THEN
                            syncrcnt3 := syncrcnt3 + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN others =>
                null;
        END CASE;

        --serializer4
        CASE SRMOD41 IS
            WHEN "00" => -- inactive serializer
                IF DISMOD41 = "00" THEN
                    AXR1Out4_zd := 'Z';
                ELSIF DISMOD41 = "10" THEN
                    AXR1Out4_zd := '0';
                ELSIF DISMOD41 = "11" THEN
                    AXR1Out4_zd := '1';
                END IF;
            WHEN "01" => -- serializer is transmitter
                IF XSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(4) = '0' AND PDIR1(4) = '1' THEN
                        IF DISMOD41 = "00" THEN
                            AXR1Out4_zd := 'Z';
                        ELSIF DISMOD41 = "10" THEN
                            AXR1Out4_zd := '0';
                        ELSIF DISMOD41 = "11" THEN
                            AXR1Out4_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF XSRCLR1 = '1' THEN -- transmit serializers are active
                        IF (rising_edge(XCLK) AND transmit4 = true) OR
                           (rising_edge(FSX1_int) AND FSXP1 = '0') OR
                           (falling_edge(FSX1_int) AND FSXP1 = '1') THEN

                            IF mode = 0 AND DITEN1 = '0' THEN -- burst
                                IF delayx = 0 AND startflagx4 = true THEN
                                    bitcnt4 := 0;
                                    startflagx4 := false;
                                    startburstx4 := true;
                                    XSR41 <= XBUF41;
                                    XSR41Tmp := XBUF41;
                                    IF XRDY41 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR41Tmp := (others => '0');
                                        END IF;
                                    XRDY41_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 1 AND startflagx4 = true AND
                                      bitcnt4 = 1 THEN
                                    bitcnt4 := 0;
                                    startflagx4 := false;
                                    startburstx4 := true;
                                    XSR41 <= XBUF41;
                                    XSR41Tmp := XBUF41;
                                    IF XRDY41 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR41Tmp := (others => '0');
                                        END IF;
                                    XRDY41_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 2 AND startflagx4 = true AND
                                      bitcnt4 = 2 THEN
                                    bitcnt4 := 0;
                                    startflagx4 := false;
                                    startburstx4 := true;
                                    XSR41 <= XBUF41;
                                    XSR41Tmp := XBUF41;
                                    IF XRDY41 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR41Tmp := (others => '0');
                                        END IF;
                                    XRDY41_RD <= '1', '0' AFTER 10 ns;
                                END IF;
                                IF startburstx4 = true THEN
                                    AXR1Out4_zd := XSR41Tmp(bitcnt4);
                                END IF;
                                bitcnt4 := bitcnt4 + 1;
                                IF bitcnt4 = slotsize THEN
                                    startburstx4 := false;
                                    bitcnt4 := 0;
                                    transmit4 := false;
                                END IF;

                            ELSIF DITEN1 = '1' AND mode = 384 THEN -- DIT

                                IF startflagx4 = true THEN
                                    startflagx4 := false;
                                    XSR41 <= XBUF01;
                                    XSR41Tmp := XBUF41;
                                    TMPReg4(23 downto 0) :=
                                    XSR41Tmp(23 downto 0);
                                    TMPReg4(24) := VA1;
                                    TMPReg4(25) := DITCSRA0(0);
                                    TMPReg4(26) := DITUDRA0(0);
                                    TMPReg4(27) := '0';
                                    IF TMPReg4(0) = '0' THEN
                                        Tmp4Reg56(0) := '1';
                                        Tmp4Reg56(1) := '1';
                                    ELSE
                                        Tmp4Reg56(0) := '1';
                                        Tmp4Reg56(1) := '0';
                                    END IF;
                                    FOR I IN 1 TO 27 LOOP
                                        IF Tmp4Reg56(2*i - 1) = '0' THEN
                                            IF TMPReg4(i) = '0' THEN
                                                Tmp4Reg56(2*i) := '1';
                                                Tmp4Reg56 (2*i + 1) := '1';
                                             ELSE
                                                Tmp4Reg56(2*i) := '1';
                                                Tmp4Reg56(2*i + 1) := '0';
                                            END IF;
                                        ELSE
                                            IF TMPReg4(i) = '0' THEN
                                                Tmp4Reg56(2*i) := '0';
                                                Tmp4Reg56(2*i + 1) := '0';
                                             ELSE
                                                Tmp4Reg56(2*i) := '0';
                                                Tmp4Reg56(2*i + 1) := '1';
                                            END IF;
                                        END IF;
                                    END LOOP;
                                    Reg4 := Tmp4Reg56 & "11101000";
                                    XRDY41_RD <= '1', '0' AFTER 10 ns;
                                    slotcnt4 := 0;
                                    framecnt4 := 0;
                                    subframe4 := '0';
                                    bitcnt4 := 0;
                                END IF;
                                AXR1Out4_zd := Reg4(bitcnt4);
                                bitcnt4 := bitcnt4 + 1;
                                IF bitcnt4 = 64 THEN
                                    XSR41 <= XBUF41;
                                    XSR41Tmp := XBUF41;
                                    IF subframe4 = '0' THEN
                                        subframe4 := '1';
                                        TMPReg4(23 downto 0) :=
                                        XSR41Tmp(23 downto 0);
                                        TMPReg4(24) := VB1;
                                        IF framecnt4 > 159 THEN
                                            TMPReg4(25) :=
                                            DITCSRB5(framecnt4 - 160);
                                            TMPReg4(26) :=
                                            DITUDRB5(framecnt4 - 160);
                                        ELSIF framecnt4 > 127 THEN
                                            TMPReg4(25) :=
                                            DITCSRB4(framecnt4 - 128);
                                            TMPReg4(26) :=
                                            DITUDRB4(framecnt4 - 128);
                                        ELSIF framecnt4 > 95 THEN
                                            TMPReg4(25) :=
                                            DITCSRB3(framecnt4 - 96);
                                            TMPReg4(26) :=
                                            DITUDRB3(framecnt4 - 96);
                                        ELSIF framecnt4 > 63 THEN
                                            TMPReg4(25) :=
                                            DITCSRB2(framecnt4 - 64);
                                            TMPReg4(26) :=
                                            DITUDRB2(framecnt4 - 64);
                                        ELSIF framecnt4 > 31 THEN
                                            TMPReg4(25) :=
                                            DITCSRB1(framecnt4 - 32);
                                            TMPReg4(26) :=
                                            DITUDRB1(framecnt4 - 32);
                                        ELSE
                                            TMPReg4(25) :=
                                            DITCSRB0(framecnt4);
                                            TMPReg4(26) :=
                                            DITUDRB0(framecnt4);
                                        END IF;
                                        TMPReg4(27) := '0';
                                        IF TMPReg4(0) = '0' THEN
                                            Tmp4Reg56(0) := '1';
                                            Tmp4Reg56(1) := '1';
                                        ELSE
                                            Tmp4Reg56(0) := '1';
                                            Tmp4Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp4Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg4(i) = '0' THEN
                                                    Tmp4Reg56(2*i) := '1';
                                                    Tmp4Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp4Reg56(2*i) := '1';
                                                    Tmp4Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg4(i) = '0' THEN
                                                    Tmp4Reg56(2*i) := '0';
                                                    Tmp4Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp4Reg56(2*i) := '0';
                                                    Tmp4Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg4 := Tmp4Reg56 & "11100100";
                                        XRDY41_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF slotcnt4 /= 383 THEN
                                        subframe4 := '0';
                                        framecnt4 := framecnt4 +1;
                                        IF framecnt4 = 192 THEN
                                            framecnt4 := 0;
                                            bitcnt4 := 0;
                                            slotcnt4 := 0;
                                            transmit4 := false;
                                        END IF;
                                        TMPReg4(23 downto 0) :=
                                        XSR41Tmp(23 downto 0);
                                        TMPReg4(24) := VA1;
                                        IF framecnt4 > 159 THEN
                                            TMPReg4(25) :=
                                            DITCSRA5(framecnt4 - 160);
                                            TMPReg4(26) :=
                                            DITUDRA5(framecnt4 - 160);
                                        ELSIF framecnt4 > 127 THEN
                                            TMPReg4(25) :=
                                            DITCSRA4(framecnt4 - 128);
                                            TMPReg4(26) :=
                                            DITUDRA4(framecnt4 - 128);
                                        ELSIF framecnt4 > 95 THEN
                                            TMPReg4(25) :=
                                            DITCSRA3(framecnt4 - 96);
                                            TMPReg4(26) :=
                                            DITUDRA3(framecnt4 - 96);
                                        ELSIF framecnt4 > 63 THEN
                                            TMPReg4(25) :=
                                            DITCSRA2(framecnt4 - 64);
                                            TMPReg4(26) :=
                                            DITUDRA2(framecnt4 - 64);
                                        ELSIF framecnt4 > 31 THEN
                                            TMPReg4(25) :=
                                            DITCSRA1(framecnt4 - 32);
                                            TMPReg4(26) :=
                                            DITUDRA1(framecnt4 - 32);
                                        ELSE
                                            TMPReg4(25) :=
                                            DITCSRA0(framecnt4);
                                            TMPReg4(26) :=
                                            DITUDRA0(framecnt4);
                                        END IF;
                                        TMPReg4(27) := '0';
                                        IF TMPReg4(0) = '0' THEN
                                            Tmp4Reg56(0) := '1';
                                            Tmp4Reg56(1) := '1';
                                        ELSE
                                            Tmp4Reg56(0) := '1';
                                            Tmp4Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp4Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg4(i) = '0' THEN
                                                    Tmp4Reg56(2*i) := '1';
                                                    Tmp4Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp4Reg56(2*i) := '1';
                                                    Tmp4Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg4(i) = '0' THEN
                                                    Tmp4Reg56(2*i) := '0';
                                                    Tmp4Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp4Reg56(2*i) := '0';
                                                    Tmp4Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg4 := Tmp4Reg56 & "11100010";
                                        XRDY41_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    bitcnt4 := 0;
                                    slotcnt4 := slotcnt4 +1;
                                END IF;

                            ELSIF DITEN1 = '0' THEN -- TDM

                                IF XTDM1(slotcnt4) = '1' THEN --active slot
                                    IF delayx = 0 AND startflagx4 = true THEN
                                        startflagx4 := false;
                                        XSR41 <= XBUF41;
                                        XSR41Tmp := XBUF41;
                                        bitcnt4 := 0;
                                        slotcnt4 := 0;
                                        IF XRDY41 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR41Tmp := (others => '0');
                                        END IF;
                                        XRDY41_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF delayx = 1 AND startflagx4 = true THEN
                                        startflagx4 := false;
                                        bitcnt4 := slotsize - 1;
                                        slotcnt4 := mode - 1;
                                    ELSIF delayx = 2 AND startflagx4 = true THEN
                                        startflagx4 := false;
                                        bitcnt4 := slotsize - 2;
                                        slotcnt4 := mode - 1;
                                    END IF;
                                    AXR1Out4_zd := XSR41Tmp(bitcnt4);
                                    XSLOTCNT1 <= to_slv(slotcnt4,10);
                                    bitcnt4 := bitcnt4 + 1;
                                    IF delayx = 0 AND slotcnt4 = (mode - 1)
                                       AND bitcnt4 = slotsize THEN
                                        transmit4 := false;
                                    ELSIF delayx = 1 AND slotcnt4 = (mode - 1)
                                          AND bitcnt4 = (slotsize - 1) THEN
                                        transmit4 := false;
                                    ELSIF delayx = 2 AND slotcnt4 = (mode - 1)
                                          AND bitcnt4 = (slotsize - 2) THEN
                                        transmit4 := false;
                                    END IF;
                                    IF bitcnt4 = slotsize THEN
                                       IF not(slotcnt4 = mode - 1 AND
                                          delayx = 0) THEN
                                            slotcnt4 := slotcnt4 + 1;
                                            bitcnt4 := 0;
                                            XSR41 <= XBUF41;
                                            XSR41Tmp := XBUF41;
                                            IF XRDY41 = '1' THEN
                                                XUNDERN1_flag <=
                                                '1', '0' AFTER 10 ns;
                                                XSR41Tmp := (others => '0');
                                            END IF;
                                            XRDY41_RD <= '1', '0' AFTER 10 ns;
                                        END IF;
                                    END IF;
                                    IF slotcnt4 = mode THEN
                                        slotcnt4 := 0;
                                        bitcnt4 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD41 = "00" THEN
                                        AXR1Out4_zd := 'Z';
                                    ELSIF DISMOD41 = "10" THEN
                                        AXR1Out4_zd := '0';
                                    ELSIF DISMOD41 = "11" THEN
                                        AXR1Out4_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF rising_edge(XCLK) AND transmit4 = false THEN
                            syncxcnt := syncxcnt + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN "10" => -- serializer is receiver
                IF RSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(4) = '0' AND PDIR1(4) = '1' THEN
                        IF DISMOD41 = "00" THEN
                            AXR1Out4_zd := 'Z';
                        ELSIF DISMOD41 = "10" THEN
                            AXR1Out4_zd := '0';
                        ELSIF DISMOD41 = "11" THEN
                            AXR1Out4_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF RSRCLR1 = '1' THEN -- receive serializers are active
                        IF falling_edge(RCLK) AND receive4 = true THEN

                            IF moder = 0 THEN -- burst
                                IF delayr = 0 AND startflagr4 = true THEN
                                    bitcntr4 := 0;
                                    startflagr4 := false;
                                    startburstr4 := true;
                                ELSIF delayr = 1 AND startflagr4 = true AND
                                      bitcntr4 = 1 THEN
                                    bitcntr4 := 0;
                                    startflagr4 := false;
                                    startburstr4 := true;
                                ELSIF delayr = 2 AND startflagr4 = true AND
                                      bitcntr4 = 2 THEN
                                    bitcntr4 := 0;
                                    startflagr4 := false;
                                    startburstr4 := true;
                                END IF;
                                IF startburstr4 = true THEN
                                    RSR41Tmp(bitcntr4) := AXR1In4;
                                END IF;
                                bitcntr4 := bitcntr4 + 1;
                                IF bitcntr4 = slotsizer THEN
                                    startburstr4 := false;
                                    bitcntr4 := 0;
                                    receive4 := false;
                                    RSR41 <= RSR41Tmp;
                                    RBUF41 <= RSR41Tmp;
                                    RRDY41_RD <= '1', '0' AFTER 10 ns;
                                END IF;

                            ELSE -- TDM

                                IF RTDM1(slotcntr4) = '1' THEN --active slot
                                    IF delayr = 0 AND startflagr4 = true THEN
                                        startflagr4 := false;
                                        bitcntr4 := 0;
                                        slotcntr4 := 0;
                                    ELSIF delayr = 1 AND startflagr4 = true THEN
                                        startflagr4 := false;
                                        bitcntr4 := slotsizer - 1;
                                        slotcntr4 := moder - 1;
                                    ELSIF delayr = 2 AND startflagr4 = true THEN
                                        startflagr4 := false;
                                        bitcntr4 := slotsizer - 2;
                                        slotcntr4 := moder - 1;
                                    END IF;
                                    IF DLBEN1 = '1' AND ASYNC1 = '0' AND
                                       MODE1 = "01" AND mode < 33 AND
                                       ORD1 = '0' THEN
                                        IF mode > 1 THEN -- Loopback mode
                                            RSR41Tmp(bitcntr4) := AXR1Out5_zd;
                                        END IF;
                                    ELSE
                                        RSR41Tmp(bitcntr4) := AXR1In4;
                                    END IF;
                                    RSLOTCNT1 <= to_slv(slotcntr4,10);
                                    bitcntr4 := bitcntr4 + 1;
                                    IF delayr = 0 AND slotcntr0 = (moder - 1)
                                       AND bitcntr4 = slotsizer THEN
                                        receive4 := false;
                                    ELSIF delayr = 1 AND slotcntr4 = (moder - 1)
                                          AND bitcntr4 = (slotsizer - 1) THEN
                                        receive4 := false;
                                    ELSIF delayr = 2 AND slotcntr4 = (moder - 1)
                                          AND bitcntr4 = (slotsizer - 2) THEN
                                        receive4 := false;
                                    END IF;
                                    IF bitcntr4 = slotsizer THEN
                                        slotcntr4 := slotcntr4 + 1;
                                        bitcntr4 := 0;
                                        RSR41 <= RSR41Tmp;
                                        RBUF41 <= RSR41Tmp;
                                        IF RRDY41 = '1' THEN
                                            ROVERN1_flag <=
                                                     '1', '0' AFTER 10 ns;
                                        END IF;
                                        RRDY41_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    IF slotcntr4 = moder THEN
                                        slotcntr4 := 0;
                                        bitcntr4 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD41 = "00" THEN
                                        AXR1Out4_zd := 'Z';
                                    ELSIF DISMOD41 = "10" THEN
                                        AXR1Out4_zd := '0';
                                    ELSIF DISMOD41 = "11" THEN
                                        AXR1Out4_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF falling_edge(RCLK) AND receive4 = false THEN
                            syncrcnt := syncrcnt + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN others =>
                null;
        END CASE;

        --serializer5
        CASE SRMOD51 IS
            WHEN "00" => -- inactive serializer
                IF DISMOD51 = "00" THEN
                    AXR1Out5_zd := 'Z';
                ELSIF DISMOD51 = "10" THEN
                    AXR1Out5_zd := '0';
                ELSIF DISMOD51 = "11" THEN
                    AXR1Out5_zd := '1';
                END IF;
            WHEN "01" => -- serializer is transmitter
                IF XSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(5) = '0' AND PDIR1(5) = '1' THEN
                        IF DISMOD51 = "00" THEN
                            AXR1Out5_zd := 'Z';
                        ELSIF DISMOD51 = "10" THEN
                            AXR1Out5_zd := '0';
                        ELSIF DISMOD51 = "11" THEN
                            AXR1Out5_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF XSRCLR1 = '1' THEN -- transmit serializers are active
                        IF (rising_edge(XCLK) AND transmit5 = true) OR
                           (rising_edge(FSX1_int) AND FSXP1 = '0') OR
                           (falling_edge(FSX1_int) AND FSXP1 = '1') THEN

                            IF mode = 0 AND DITEN1 = '0' THEN -- burst
                                IF delayx = 0 AND startflagx5 = true THEN
                                    bitcnt5 := 0;
                                    startflagx5 := false;
                                    startburstx5 := true;
                                    XSR51 <= XBUF51;
                                    XSR51Tmp := XBUF51;
                                    IF XRDY51 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR51Tmp := (others => '0');
                                        END IF;
                                    XRDY51_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 1 AND startflagx5 = true AND
                                      bitcnt5 = 1 THEN
                                    bitcnt5 := 0;
                                    startflagx5 := false;
                                    startburstx5 := true;
                                    XSR51 <= XBUF51;
                                    XSR51Tmp := XBUF51;
                                    IF XRDY51 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR51Tmp := (others => '0');
                                        END IF;
                                    XRDY51_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 2 AND startflagx5 = true AND
                                      bitcnt5 = 2 THEN
                                    bitcnt5 := 0;
                                    startflagx5 := false;
                                    startburstx5 := true;
                                    XSR51 <= XBUF51;
                                    XSR51Tmp := XBUF51;
                                    IF XRDY51 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR51Tmp := (others => '0');
                                        END IF;
                                    XRDY51_RD <= '1', '0' AFTER 10 ns;
                                END IF;
                                IF startburstx5 = true THEN
                                    AXR1Out5_zd := XSR51Tmp(bitcnt5);
                                END IF;
                                bitcnt5 := bitcnt5 + 1;
                                IF bitcnt5 = slotsize THEN
                                    startburstx5 := false;
                                    bitcnt5 := 0;
                                    transmit5 := false;
                                END IF;

                            ELSIF DITEN1 = '1' AND mode = 384 THEN -- DIT

                                IF startflagx5 = true THEN
                                    startflagx5 := false;
                                    XSR51 <= XBUF51;
                                    XSR51Tmp := XBUF51;
                                    TMPReg5(23 downto 0) :=
                                    XSR51Tmp(23 downto 0);
                                    TMPReg5(24) := VA1;
                                    TMPReg5(25) := DITCSRA0(0);
                                    TMPReg5(26) := DITUDRA0(0);
                                    TMPReg5(27) := '0';
                                    IF TMPReg5(0) = '0' THEN
                                        Tmp5Reg56(0) := '1';
                                        Tmp5Reg56(1) := '1';
                                    ELSE
                                        Tmp5Reg56(0) := '1';
                                        Tmp5Reg56(1) := '0';
                                    END IF;
                                    FOR I IN 1 TO 27 LOOP
                                        IF Tmp5Reg56(2*i - 1) = '0' THEN
                                            IF TMPReg5(i) = '0' THEN
                                                Tmp5Reg56(2*i) := '1';
                                                Tmp5Reg56 (2*i + 1) := '1';
                                             ELSE
                                                Tmp5Reg56(2*i) := '1';
                                                Tmp5Reg56(2*i + 1) := '0';
                                            END IF;
                                        ELSE
                                            IF TMPReg5(i) = '0' THEN
                                                Tmp5Reg56(2*i) := '0';
                                                Tmp5Reg56(2*i + 1) := '0';
                                             ELSE
                                                Tmp5Reg56(2*i) := '0';
                                                Tmp5Reg56(2*i + 1) := '1';
                                            END IF;
                                        END IF;
                                    END LOOP;
                                    Reg5 := Tmp5Reg56 & "11101000";
                                    XRDY51_RD <= '1', '0' AFTER 10 ns;
                                    slotcnt5 := 0;
                                    framecnt5 := 0;
                                    subframe5 := '0';
                                    bitcnt5 := 0;
                                END IF;
                                AXR1Out5_zd := Reg5(bitcnt5);
                                bitcnt5 := bitcnt5 + 1;
                                IF bitcnt5 = 64 THEN
                                    XSR51 <= XBUF51;
                                    XSR51Tmp := XBUF51;
                                    IF subframe5 = '0' THEN
                                        subframe5 := '1';
                                        TMPReg5(23 downto 0) :=
                                        XSR51Tmp(23 downto 0);
                                        TMPReg5(24) := VB1;
                                        IF framecnt5 > 159 THEN
                                            TMPReg5(25) :=
                                            DITCSRB5(framecnt5 - 160);
                                            TMPReg5(26) :=
                                            DITUDRB5(framecnt5 - 160);
                                        ELSIF framecnt5 > 127 THEN
                                            TMPReg5(25) :=
                                            DITCSRB4(framecnt5 - 128);
                                            TMPReg5(26) :=
                                            DITUDRB4(framecnt5 - 128);
                                        ELSIF framecnt5 > 95 THEN
                                            TMPReg5(25) :=
                                            DITCSRB3(framecnt5 - 96);
                                            TMPReg5(26) :=
                                            DITUDRB3(framecnt5 - 96);
                                        ELSIF framecnt5 > 63 THEN
                                            TMPReg5(25) :=
                                            DITCSRB2(framecnt5 - 64);
                                            TMPReg5(26) :=
                                            DITUDRB2(framecnt5 - 64);
                                        ELSIF framecnt5 > 31 THEN
                                            TMPReg5(25) :=
                                            DITCSRB1(framecnt5 - 32);
                                            TMPReg5(26) :=
                                            DITUDRB1(framecnt5 - 32);
                                        ELSE
                                            TMPReg5(25) :=
                                            DITCSRB0(framecnt5);
                                            TMPReg5(26) :=
                                            DITUDRB0(framecnt5);
                                        END IF;
                                        TMPReg5(27) := '0';
                                        IF TMPReg5(0) = '0' THEN
                                            Tmp5Reg56(0) := '1';
                                            Tmp5Reg56(1) := '1';
                                        ELSE
                                            Tmp5Reg56(0) := '1';
                                            Tmp5Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp5Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg5(i) = '0' THEN
                                                    Tmp5Reg56(2*i) := '1';
                                                    Tmp5Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp5Reg56(2*i) := '1';
                                                    Tmp5Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg5(i) = '0' THEN
                                                    Tmp5Reg56(2*i) := '0';
                                                    Tmp5Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp5Reg56(2*i) := '0';
                                                    Tmp5Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg5 := Tmp5Reg56 & "11100100";
                                        XRDY51_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF slotcnt5 /= 383 THEN
                                        subframe5 := '0';
                                        framecnt5 := framecnt5 +1;
                                        IF framecnt5 = 192 THEN
                                            framecnt5 := 0;
                                            bitcnt5 := 0;
                                            slotcnt5 := 0;
                                            transmit5 := false;
                                        END IF;
                                        TMPReg5(23 downto 0) :=
                                        XSR51Tmp(23 downto 0);
                                        TMPReg5(24) := VA1;
                                        IF framecnt5 > 159 THEN
                                            TMPReg5(25) :=
                                            DITCSRA5(framecnt5 - 160);
                                            TMPReg5(26) :=
                                            DITUDRA5(framecnt5 - 160);
                                        ELSIF framecnt5 > 127 THEN
                                            TMPReg5(25) :=
                                            DITCSRA4(framecnt5 - 128);
                                            TMPReg5(26) :=
                                            DITUDRA4(framecnt5 - 128);
                                        ELSIF framecnt5 > 95 THEN
                                            TMPReg5(25) :=
                                            DITCSRA3(framecnt5 - 96);
                                            TMPReg5(26) :=
                                            DITUDRA3(framecnt5 - 96);
                                        ELSIF framecnt5 > 63 THEN
                                            TMPReg5(25) :=
                                            DITCSRA2(framecnt5 - 64);
                                            TMPReg5(26) :=
                                            DITUDRA2(framecnt5 - 64);
                                        ELSIF framecnt5 > 31 THEN
                                            TMPReg5(25) :=
                                            DITCSRA1(framecnt5 - 32);
                                            TMPReg5(26) :=
                                            DITUDRA1(framecnt5 - 32);
                                        ELSE
                                            TMPReg5(25) :=
                                            DITCSRA0(framecnt5);
                                            TMPReg5(26) :=
                                            DITUDRA0(framecnt5);
                                        END IF;
                                        TMPReg5(27) := '0';
                                        IF TMPReg5(0) = '0' THEN
                                            Tmp5Reg56(0) := '1';
                                            Tmp5Reg56(1) := '1';
                                        ELSE
                                            Tmp5Reg56(0) := '1';
                                            Tmp5Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp5Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg5(i) = '0' THEN
                                                    Tmp5Reg56(2*i) := '1';
                                                    Tmp5Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp5Reg56(2*i) := '1';
                                                    Tmp5Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg5(i) = '0' THEN
                                                    Tmp5Reg56(2*i) := '0';
                                                    Tmp5Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp5Reg56(2*i) := '0';
                                                    Tmp5Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg5 := Tmp5Reg56 & "11100010";
                                        XRDY51_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    bitcnt5 := 0;
                                    slotcnt5 := slotcnt0 +1;
                                END IF;

                            ELSIF DITEN1 = '0' THEN -- TDM

                                IF XTDM1(slotcnt5) = '1' THEN --active slot
                                    IF delayx = 0 AND startflagx5 = true THEN
                                        startflagx5 := false;
                                        XSR51 <= XBUF51;
                                        XSR51Tmp := XBUF51;
                                        bitcnt5 := 0;
                                        slotcnt5 := 0;
                                        IF XRDY51 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR51Tmp := (others => '0');
                                        END IF;
                                        XRDY51_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF delayx = 1 AND startflagx5 = true THEN
                                        startflagx5 := false;
                                        bitcnt5 := slotsize - 1;
                                        slotcnt5 := mode - 1;
                                    ELSIF delayx = 2 AND startflagx5 = true THEN
                                        startflagx5 := false;
                                        bitcnt5 := slotsize - 2;
                                        slotcnt5 := mode - 1;
                                    END IF;
                                    AXR1Out5_zd := XSR51Tmp(bitcnt5);
                                    XSLOTCNT1 <= to_slv(slotcnt5,10);
                                    bitcnt5 := bitcnt5 + 1;
                                    IF delayx = 0 AND slotcnt5 = (mode - 1)
                                       AND bitcnt5 = slotsize THEN
                                        transmit5 := false;
                                    ELSIF delayx = 1 AND slotcnt5 = (mode - 1)
                                          AND bitcnt5 = (slotsize - 1) THEN
                                        transmit5 := false;
                                    ELSIF delayx = 2 AND slotcnt5 = (mode - 1)
                                          AND bitcnt5 = (slotsize - 2) THEN
                                        transmit5 := false;
                                    END IF;
                                    IF bitcnt5 = slotsize THEN
                                       IF not(slotcnt5 = mode - 1 AND
                                          delayx = 0) THEN
                                            slotcnt5 := slotcnt5 + 1;
                                            bitcnt5 := 0;
                                            XSR51 <= XBUF51;
                                            XSR51Tmp := XBUF51;
                                            IF XRDY51 = '1' THEN
                                                XUNDERN1_flag <=
                                                '1', '0' AFTER 10 ns;
                                                XSR51Tmp := (others => '0');
                                            END IF;
                                            XRDY51_RD <= '1', '0' AFTER 10 ns;
                                        END IF;
                                    END IF;
                                    IF slotcnt5 = mode THEN
                                        slotcnt5 := 0;
                                        bitcnt5 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD51 = "00" THEN
                                        AXR1Out5_zd := 'Z';
                                    ELSIF DISMOD51 = "10" THEN
                                        AXR1Out5_zd := '0';
                                    ELSIF DISMOD51 = "11" THEN
                                        AXR1Out5_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF rising_edge(XCLK) AND transmit5 = false THEN
                            syncxcnt := syncxcnt + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN "10" => -- serializer is receiver
                IF RSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(5) = '0' AND PDIR1(5) = '1' THEN
                        IF DISMOD51 = "00" THEN
                            AXR1Out5_zd := 'Z';
                        ELSIF DISMOD51 = "10" THEN
                            AXR1Out5_zd := '0';
                        ELSIF DISMOD51 = "11" THEN
                            AXR1Out5_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF RSRCLR1 = '1' THEN -- receive serializers are active
                        IF falling_edge(RCLK) AND receive5 = true THEN

                            IF moder = 0 THEN -- burst
                                IF delayr = 0 AND startflagr5 = true THEN
                                    bitcntr5 := 0;
                                    startflagr5 := false;
                                    startburstr5 := true;
                                ELSIF delayr = 1 AND startflagr5 = true AND
                                      bitcntr5 = 1 THEN
                                    bitcntr5 := 0;
                                    startflagr5 := false;
                                    startburstr5 := true;
                                ELSIF delayr = 2 AND startflagr5 = true AND
                                      bitcntr5 = 2 THEN
                                    bitcntr5 := 0;
                                    startflagr5 := false;
                                    startburstr5 := true;
                                END IF;
                                IF startburstr5 = true THEN
                                    RSR51Tmp(bitcntr5) := AXR1In5;
                                END IF;
                                bitcntr5 := bitcntr5 + 1;
                                IF bitcntr5 = slotsizer THEN
                                    startburstr5 := false;
                                    bitcntr5 := 0;
                                    receive5 := false;
                                    RSR51 <= RSR51Tmp;
                                    RBUF51 <= RSR51Tmp;
                                    RRDY51_RD <= '1', '0' AFTER 10 ns;
                                END IF;

                            ELSE -- TDM

                                IF RTDM1(slotcntr5) = '1' THEN --active slot
                                    IF delayr = 0 AND startflagr5 = true THEN
                                        startflagr5 := false;
                                        bitcntr5 := 0;
                                        slotcntr5 := 0;
                                    ELSIF delayr = 1 AND startflagr5 = true THEN
                                        startflagr5 := false;
                                        bitcntr5 := slotsizer - 1;
                                        slotcntr5 := moder - 1;
                                    ELSIF delayr = 2 AND startflagr5 = true THEN
                                        startflagr5 := false;
                                        bitcntr5 := slotsizer - 2;
                                        slotcntr5 := moder - 1;
                                    END IF;
                                    IF DLBEN1 = '1' AND ASYNC1 = '0' AND
                                       MODE1 = "01" AND mode < 33 AND
                                       ORD1 = '0' THEN
                                        IF mode > 1 THEN -- Loopback mode
                                            RSR51Tmp(bitcntr5) := AXR1Out4_zd;
                                        END IF;
                                    ELSE
                                        RSR51Tmp(bitcntr5) := AXR1In5;
                                    END IF;
                                    RSLOTCNT1 <= to_slv(slotcntr5,10);
                                    bitcntr5 := bitcntr5 + 1;
                                    IF delayr = 0 AND slotcntr5 = (moder - 1)
                                       AND bitcntr5 = slotsizer THEN
                                        receive5 := false;
                                    ELSIF delayr = 1 AND slotcntr5 = (moder - 1)
                                          AND bitcntr5 = (slotsizer - 1) THEN
                                        receive5 := false;
                                    ELSIF delayr = 2 AND slotcntr5 = (moder - 1)
                                          AND bitcntr5 = (slotsizer - 2) THEN
                                        receive5 := false;
                                    END IF;
                                    IF bitcntr5 = slotsizer THEN
                                        slotcntr5 := slotcntr5 + 1;
                                        bitcntr5 := 0;
                                        RSR51 <= RSR51Tmp;
                                        RBUF51 <= RSR51Tmp;
                                        IF RRDY51 = '1' THEN
                                            ROVERN1_flag <=
                                                     '1', '0' AFTER 10 ns;
                                        END IF;
                                        RRDY51_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    IF slotcntr5 = moder THEN
                                        slotcntr5 := 0;
                                        bitcntr5 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD51 = "00" THEN
                                        AXR1Out5_zd := 'Z';
                                    ELSIF DISMOD51 = "10" THEN
                                        AXR1Out5_zd := '0';
                                    ELSIF DISMOD51 = "11" THEN
                                        AXR1Out5_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF falling_edge(RCLK) AND receive5 = false THEN
                            syncrcnt := syncrcnt + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN others =>
                null;
        END CASE;

        --serializer6
        CASE SRMOD61 IS
            WHEN "00" => -- inactive serializer
                IF DISMOD61 = "00" THEN
                    AXR1Out6_zd := 'Z';
                ELSIF DISMOD61 = "10" THEN
                    AXR1Out6_zd := '0';
                ELSIF DISMOD61 = "11" THEN
                    AXR1Out6_zd := '1';
                END IF;
            WHEN "01" => -- serializer is transmitter
                IF XSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(6) = '0' AND PDIR1(6) = '1' THEN
                        IF DISMOD61 = "00" THEN
                            AXR1Out6_zd := 'Z';
                        ELSIF DISMOD61 = "10" THEN
                            AXR1Out6_zd := '0';
                        ELSIF DISMOD61 = "11" THEN
                            AXR1Out6_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF XSRCLR1 = '1' THEN -- transmit serializers are active
                        IF (rising_edge(XCLK) AND transmit6 = true) OR
                           (rising_edge(FSX1_int) AND FSXP1 = '0') OR
                           (falling_edge(FSX1_int) AND FSXP1 = '1') THEN

                            IF mode = 0 AND DITEN1 = '0' THEN -- burst
                                IF delayx = 0 AND startflagx6 = true THEN
                                    bitcnt6 := 0;
                                    startflagx6 := false;
                                    startburstx6 := true;
                                    XSR61 <= XBUF61;
                                    XSR61Tmp := XBUF61;
                                    IF XRDY61 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR61Tmp := (others => '0');
                                        END IF;
                                    XRDY61_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 1 AND startflagx6 = true AND
                                      bitcnt6 = 1 THEN
                                    bitcnt6 := 0;
                                    startflagx6 := false;
                                    startburstx6 := true;
                                    XSR61 <= XBUF61;
                                    XSR61Tmp := XBUF61;
                                    IF XRDY61 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR61Tmp := (others => '0');
                                        END IF;
                                    XRDY61_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 2 AND startflagx6 = true AND
                                      bitcnt6 = 2 THEN
                                    bitcnt6 := 0;
                                    startflagx6 := false;
                                    startburstx6 := true;
                                    XSR61 <= XBUF61;
                                    XSR61Tmp := XBUF61;
                                    IF XRDY61 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR61Tmp := (others => '0');
                                        END IF;
                                    XRDY61_RD <= '1', '0' AFTER 10 ns;
                                END IF;
                                IF startburstx6 = true THEN
                                    AXR1Out6_zd := XSR61Tmp(bitcnt6);
                                END IF;
                                bitcnt6 := bitcnt6 + 1;
                                IF bitcnt6 = slotsize THEN
                                    startburstx6 := false;
                                    bitcnt6 := 0;
                                    transmit6 := false;
                                END IF;

                            ELSIF DITEN1 = '1' AND mode = 384 THEN -- DIT

                                IF startflagx6 = true THEN
                                    startflagx6 := false;
                                    XSR61 <= XBUF61;
                                    XSR61Tmp := XBUF61;
                                    TMPReg6(23 downto 0) :=
                                    XSR61Tmp(23 downto 0);
                                    TMPReg6(24) := VA1;
                                    TMPReg6(25) := DITCSRA0(0);
                                    TMPReg6(26) := DITUDRA0(0);
                                    TMPReg6(27) := '0';
                                    IF TMPReg6(0) = '0' THEN
                                        Tmp6Reg56(0) := '1';
                                        Tmp6Reg56(1) := '1';
                                    ELSE
                                        Tmp6Reg56(0) := '1';
                                        Tmp6Reg56(1) := '0';
                                    END IF;
                                    FOR I IN 1 TO 27 LOOP
                                        IF Tmp6Reg56(2*i - 1) = '0' THEN
                                            IF TMPReg6(i) = '0' THEN
                                                Tmp6Reg56(2*i) := '1';
                                                Tmp6Reg56 (2*i + 1) := '1';
                                             ELSE
                                                Tmp6Reg56(2*i) := '1';
                                                Tmp6Reg56(2*i + 1) := '0';
                                            END IF;
                                        ELSE
                                            IF TMPReg6(i) = '0' THEN
                                                Tmp6Reg56(2*i) := '0';
                                                Tmp6Reg56(2*i + 1) := '0';
                                             ELSE
                                                Tmp6Reg56(2*i) := '0';
                                                Tmp6Reg56(2*i + 1) := '1';
                                            END IF;
                                        END IF;
                                    END LOOP;
                                    Reg6 := Tmp6Reg56 & "11101000";
                                    XRDY61_RD <= '1', '0' AFTER 10 ns;
                                    slotcnt6 := 0;
                                    framecnt6 := 0;
                                    subframe6 := '0';
                                    bitcnt6 := 0;
                                END IF;
                                AXR1Out6_zd := Reg6(bitcnt6);
                                bitcnt6 := bitcnt6 + 1;
                                IF bitcnt6 = 64 THEN
                                    XSR61 <= XBUF61;
                                    XSR61Tmp := XBUF61;
                                    IF subframe6 = '0' THEN
                                        subframe6 := '1';
                                        TMPReg6(23 downto 0) :=
                                        XSR61Tmp(23 downto 0);
                                        TMPReg6(24) := VB1;
                                        IF framecnt6 > 159 THEN
                                            TMPReg6(25) :=
                                            DITCSRB5(framecnt6 - 160);
                                            TMPReg6(26) :=
                                            DITUDRB5(framecnt6 - 160);
                                        ELSIF framecnt6 > 127 THEN
                                            TMPReg6(25) :=
                                            DITCSRB4(framecnt6 - 128);
                                            TMPReg6(26) :=
                                            DITUDRB4(framecnt6 - 128);
                                        ELSIF framecnt6 > 95 THEN
                                            TMPReg6(25) :=
                                            DITCSRB3(framecnt6 - 96);
                                            TMPReg6(26) :=
                                            DITUDRB3(framecnt6 - 96);
                                        ELSIF framecnt6 > 63 THEN
                                            TMPReg6(25) :=
                                            DITCSRB2(framecnt6 - 64);
                                            TMPReg6(26) :=
                                            DITUDRB2(framecnt6 - 64);
                                        ELSIF framecnt6 > 31 THEN
                                            TMPReg6(25) :=
                                            DITCSRB1(framecnt6 - 32);
                                            TMPReg6(26) :=
                                            DITUDRB1(framecnt6 - 32);
                                        ELSE
                                            TMPReg6(25) :=
                                            DITCSRB0(framecnt6);
                                            TMPReg6(26) :=
                                            DITUDRB0(framecnt6);
                                        END IF;
                                        TMPReg6(27) := '0';
                                        IF TMPReg6(0) = '0' THEN
                                            Tmp6Reg56(0) := '1';
                                            Tmp6Reg56(1) := '1';
                                        ELSE
                                            Tmp6Reg56(0) := '1';
                                            Tmp6Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp6Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg6(i) = '0' THEN
                                                    Tmp6Reg56(2*i) := '1';
                                                    Tmp6Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp6Reg56(2*i) := '1';
                                                    Tmp6Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg6(i) = '0' THEN
                                                    Tmp6Reg56(2*i) := '0';
                                                    Tmp6Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp6Reg56(2*i) := '0';
                                                    Tmp6Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg6 := Tmp6Reg56 & "11100100";
                                        XRDY61_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF slotcnt6 /= 383 THEN
                                        subframe6 := '0';
                                        framecnt6 := framecnt6 +1;
                                        IF framecnt6 = 192 THEN
                                            framecnt6 := 0;
                                            bitcnt6 := 0;
                                            slotcnt6 := 0;
                                            transmit6 := false;
                                        END IF;
                                        TMPReg6(23 downto 0) :=
                                        XSR61Tmp(23 downto 0);
                                        TMPReg6(24) := VA1;
                                        IF framecnt6 > 159 THEN
                                            TMPReg6(25) :=
                                            DITCSRA5(framecnt6 - 160);
                                            TMPReg6(26) :=
                                            DITUDRA5(framecnt6 - 160);
                                        ELSIF framecnt6 > 127 THEN
                                            TMPReg6(25) :=
                                            DITCSRA4(framecnt6 - 128);
                                            TMPReg6(26) :=
                                            DITUDRA4(framecnt6 - 128);
                                        ELSIF framecnt6 > 95 THEN
                                            TMPReg6(25) :=
                                            DITCSRA3(framecnt6 - 96);
                                            TMPReg6(26) :=
                                            DITUDRA3(framecnt6 - 96);
                                        ELSIF framecnt6 > 63 THEN
                                            TMPReg6(25) :=
                                            DITCSRA2(framecnt6 - 64);
                                            TMPReg6(26) :=
                                            DITUDRA2(framecnt6 - 64);
                                        ELSIF framecnt6 > 31 THEN
                                            TMPReg6(25) :=
                                            DITCSRA1(framecnt6 - 32);
                                            TMPReg6(26) :=
                                            DITUDRA1(framecnt6 - 32);
                                        ELSE
                                            TMPReg6(25) :=
                                            DITCSRA0(framecnt6);
                                            TMPReg6(26) :=
                                            DITUDRA0(framecnt6);
                                        END IF;
                                        TMPReg6(27) := '0';
                                        IF TMPReg6(0) = '0' THEN
                                            Tmp6Reg56(0) := '1';
                                            Tmp6Reg56(1) := '1';
                                        ELSE
                                            Tmp6Reg56(0) := '1';
                                            Tmp6Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp6Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg6(i) = '0' THEN
                                                    Tmp6Reg56(2*i) := '1';
                                                    Tmp6Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp6Reg56(2*i) := '1';
                                                    Tmp6Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg6(i) = '0' THEN
                                                    Tmp6Reg56(2*i) := '0';
                                                    Tmp6Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp6Reg56(2*i) := '0';
                                                    Tmp6Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg6 := Tmp6Reg56 & "11100010";
                                        XRDY61_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    bitcnt6 := 0;
                                    slotcnt6 := slotcnt6 +1;
                                END IF;

                            ELSIF DITEN1 = '0' THEN -- TDM

                                IF XTDM1(slotcnt6) = '1' THEN --active slot
                                    IF delayx = 0 AND startflagx6 = true THEN
                                        startflagx6 := false;
                                        XSR61 <= XBUF61;
                                        XSR61Tmp := XBUF61;
                                        bitcnt6 := 0;
                                        slotcnt6 := 0;
                                        IF XRDY61 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR61Tmp := (others => '0');
                                        END IF;
                                        XRDY61_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF delayx = 1 AND startflagx6 = true THEN
                                        startflagx6 := false;
                                        bitcnt6 := slotsize - 1;
                                        slotcnt6 := mode - 1;
                                    ELSIF delayx = 2 AND startflagx6 = true THEN
                                        startflagx6 := false;
                                        bitcnt6 := slotsize - 2;
                                        slotcnt6 := mode - 1;
                                    END IF;
                                    AXR1Out6_zd := XSR61Tmp(bitcnt6);
                                    XSLOTCNT1 <= to_slv(slotcnt6,10);
                                    bitcnt6 := bitcnt6 + 1;
                                    IF delayx = 0 AND slotcnt6 = (mode - 1)
                                       AND bitcnt6 = slotsize THEN
                                        transmit6 := false;
                                    ELSIF delayx = 1 AND slotcnt6 = (mode - 1)
                                          AND bitcnt6 = (slotsize - 1) THEN
                                        transmit6 := false;
                                    ELSIF delayx = 2 AND slotcnt6 = (mode - 1)
                                          AND bitcnt6 = (slotsize - 2) THEN
                                        transmit6 := false;
                                    END IF;
                                    IF bitcnt6 = slotsize THEN
                                       IF not(slotcnt6 = mode - 1 AND
                                          delayx = 0) THEN
                                            slotcnt6 := slotcnt6 + 1;
                                            bitcnt6 := 0;
                                            XSR61 <= XBUF61;
                                            XSR61Tmp := XBUF61;
                                            IF XRDY61 = '1' THEN
                                                XUNDERN1_flag <=
                                                '1', '0' AFTER 10 ns;
                                                XSR61Tmp := (others => '0');
                                            END IF;
                                            XRDY61_RD <= '1', '0' AFTER 10 ns;
                                        END IF;
                                    END IF;
                                    IF slotcnt6 = mode THEN
                                        slotcnt6 := 0;
                                        bitcnt6 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD61 = "00" THEN
                                        AXR1Out6_zd := 'Z';
                                    ELSIF DISMOD61 = "10" THEN
                                        AXR1Out6_zd := '0';
                                    ELSIF DISMOD61 = "11" THEN
                                        AXR1Out6_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF rising_edge(XCLK) AND transmit6 = false THEN
                            syncxcnt := syncxcnt + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN "10" => -- serializer is receiver
                IF RSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(6) = '0' AND PDIR1(6) = '1' THEN
                        IF DISMOD61 = "00" THEN
                            AXR1Out6_zd := 'Z';
                        ELSIF DISMOD61 = "10" THEN
                            AXR1Out6_zd := '0';
                        ELSIF DISMOD61 = "11" THEN
                            AXR1Out6_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF RSRCLR1 = '1' THEN -- receive serializers are active
                        IF falling_edge(RCLK) AND receive6 = true THEN

                            IF moder = 0 THEN -- burst
                                IF delayr = 0 AND startflagr6 = true THEN
                                    bitcntr6 := 0;
                                    startflagr6 := false;
                                    startburstr6 := true;
                                ELSIF delayr = 1 AND startflagr6 = true AND
                                      bitcntr6 = 1 THEN
                                    bitcntr6 := 0;
                                    startflagr6 := false;
                                    startburstr6 := true;
                                ELSIF delayr = 2 AND startflagr6 = true AND
                                      bitcntr6 = 2 THEN
                                    bitcntr6 := 0;
                                    startflagr6 := false;
                                    startburstr6 := true;
                                END IF;
                                IF startburstr6 = true THEN
                                    RSR61Tmp(bitcntr6) := AXR1In6;
                                END IF;
                                bitcntr6 := bitcntr6 + 1;
                                IF bitcntr6 = slotsizer THEN
                                    startburstr6 := false;
                                    bitcntr6 := 0;
                                    receive6 := false;
                                    RSR61 <= RSR61Tmp;
                                    RBUF61 <= RSR61Tmp;
                                    RRDY61_RD <= '1', '0' AFTER 10 ns;
                                END IF;

                            ELSE -- TDM

                                IF RTDM1(slotcntr6) = '1' THEN --active slot
                                    IF delayr = 0 AND startflagr6 = true THEN
                                        startflagr6 := false;
                                        bitcntr6 := 0;
                                        slotcntr6 := 0;
                                    ELSIF delayr = 1 AND startflagr6 = true THEN
                                        startflagr6 := false;
                                        bitcntr6 := slotsizer - 1;
                                        slotcntr6 := moder - 1;
                                    ELSIF delayr = 2 AND startflagr6 = true THEN
                                        startflagr6 := false;
                                        bitcntr6 := slotsizer - 2;
                                        slotcntr6 := moder - 1;
                                    END IF;
                                    IF DLBEN1 = '1' AND ASYNC1 = '0' AND
                                       MODE1 = "01" AND mode < 33 AND
                                       ORD1 = '0' THEN
                                        IF mode > 1 THEN -- Loopback mode
                                            RSR61Tmp(bitcntr6) := AXR1Out7_zd;
                                        END IF;
                                    ELSE
                                        RSR61Tmp(bitcntr6) := AXR1In6;
                                    END IF;
                                    RSLOTCNT1 <= to_slv(slotcntr6,10);
                                    bitcntr6 := bitcntr6 + 1;
                                    IF delayr = 0 AND slotcntr6 = (moder - 1)
                                       AND bitcntr6 = slotsizer THEN
                                        receive6 := false;
                                    ELSIF delayr = 1 AND slotcntr6 = (moder - 1)
                                          AND bitcntr6 = (slotsizer - 1) THEN
                                        receive6 := false;
                                    ELSIF delayr = 2 AND slotcntr6 = (moder - 1)
                                          AND bitcntr6 = (slotsizer - 2) THEN
                                        receive6 := false;
                                    END IF;
                                    IF bitcntr6 = slotsizer THEN
                                        slotcntr6 := slotcntr6 + 1;
                                        bitcntr6 := 0;
                                        RSR61 <= RSR61Tmp;
                                        RBUF61 <= RSR61Tmp;
                                        IF RRDY61 = '1' THEN
                                            ROVERN1_flag <=
                                                    '1', '0' AFTER 10 ns;
                                        END IF;
                                        RRDY61_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    IF slotcntr6 = moder THEN
                                        slotcntr6 := 0;
                                        bitcntr6 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD61 = "00" THEN
                                        AXR1Out6_zd := 'Z';
                                    ELSIF DISMOD61 = "10" THEN
                                        AXR1Out6_zd := '0';
                                    ELSIF DISMOD61 = "11" THEN
                                        AXR1Out6_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF falling_edge(RCLK) AND receive6 = false THEN
                            syncrcnt := syncrcnt + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN others =>
                null;
        END CASE;

        --serializer7
        CASE SRMOD71 IS
            WHEN "00" => -- inactive serializer
                IF DISMOD71 = "00" THEN
                    AXR1Out7_zd := 'Z';
                ELSIF DISMOD71 = "10" THEN
                    AXR1Out7_zd := '0';
                ELSIF DISMOD71 = "11" THEN
                    AXR1Out7_zd := '1';
                END IF;
            WHEN "01" => -- serializer is transmitter
                IF XSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(7) = '0' AND PDIR1(7) = '1' THEN
                        IF DISMOD71 = "00" THEN
                            AXR1Out7_zd := 'Z';
                        ELSIF DISMOD71 = "10" THEN
                            AXR1Out7_zd := '0';
                        ELSIF DISMOD71 = "11" THEN
                            AXR1Out7_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF XSRCLR1 = '1' THEN -- transmit serializers are active
                        IF (rising_edge(XCLK) AND transmit7 = true) OR
                           (rising_edge(FSX1_int) AND FSXP1 = '0') OR
                           (falling_edge(FSX1_int) AND FSXP1 = '1') THEN

                            IF mode = 0 AND DITEN1 = '0' THEN -- burst
                                IF delayx = 0 AND startflagx7 = true THEN
                                    bitcnt7 := 0;
                                    startflagx7 := false;
                                    startburstx7 := true;
                                    XSR71 <= XBUF71;
                                    XSR71Tmp := XBUF71;
                                    IF XRDY71 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR71Tmp := (others => '0');
                                        END IF;
                                    XRDY71_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 1 AND startflagx7 = true AND
                                      bitcnt7 = 1 THEN
                                    bitcnt7 := 0;
                                    startflagx7 := false;
                                    startburstx7 := true;
                                    XSR71 <= XBUF71;
                                    XSR71Tmp := XBUF71;
                                    IF XRDY71 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR71Tmp := (others => '0');
                                        END IF;
                                    XRDY71_RD <= '1', '0' AFTER 10 ns;
                                ELSIF delayx = 2 AND startflagx7 = true AND
                                      bitcnt7 = 2 THEN
                                    bitcnt7 := 0;
                                    startflagx7 := false;
                                    startburstx7 := true;
                                    XSR71 <= XBUF71;
                                    XSR71Tmp := XBUF71;
                                    IF XRDY71 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR71Tmp := (others => '0');
                                        END IF;
                                    XRDY71_RD <= '1', '0' AFTER 10 ns;
                                END IF;
                                IF startburstx7 = true THEN
                                    AXR1Out7_zd := XSR71Tmp(bitcnt7);
                                END IF;
                                bitcnt7 := bitcnt7 + 1;
                                IF bitcnt7 = slotsize THEN
                                    startburstx7 := false;
                                    bitcnt7 := 0;
                                    transmit7 := false;
                                END IF;

                            ELSIF DITEN1 = '1' AND mode = 384 THEN -- DIT

                                IF startflagx7 = true THEN
                                    startflagx7 := false;
                                    XSR71 <= XBUF71;
                                    XSR71Tmp := XBUF71;
                                    TMPReg7(23 downto 0) :=
                                    XSR71Tmp(23 downto 0);
                                    TMPReg7(24) := VA1;
                                    TMPReg7(25) := DITCSRA0(0);
                                    TMPReg7(26) := DITUDRA0(0);
                                    TMPReg7(27) := '0';
                                    IF TMPReg7(0) = '0' THEN
                                        Tmp7Reg56(0) := '1';
                                        Tmp7Reg56(1) := '1';
                                    ELSE
                                        Tmp7Reg56(0) := '1';
                                        Tmp7Reg56(1) := '0';
                                    END IF;
                                    FOR I IN 1 TO 27 LOOP
                                        IF Tmp7Reg56(2*i - 1) = '0' THEN
                                            IF TMPReg7(i) = '0' THEN
                                                Tmp7Reg56(2*i) := '1';
                                                Tmp7Reg56 (2*i + 1) := '1';
                                             ELSE
                                                Tmp7Reg56(2*i) := '1';
                                                Tmp7Reg56(2*i + 1) := '0';
                                            END IF;
                                        ELSE
                                            IF TMPReg7(i) = '0' THEN
                                                Tmp7Reg56(2*i) := '0';
                                                Tmp7Reg56(2*i + 1) := '0';
                                             ELSE
                                                Tmp7Reg56(2*i) := '0';
                                                Tmp7Reg56(2*i + 1) := '1';
                                            END IF;
                                        END IF;
                                    END LOOP;
                                    Reg7 := Tmp7Reg56 & "11101000";
                                    XRDY71_RD <= '1', '0' AFTER 10 ns;
                                    slotcnt7 := 0;
                                    framecnt7 := 0;
                                    subframe7 := '0';
                                    bitcnt7 := 0;
                                END IF;
                                AXR1Out7_zd := Reg7(bitcnt7);
                                bitcnt7 := bitcnt7 + 1;
                                IF bitcnt7 = 64 THEN
                                    XSR71 <= XBUF71;
                                    XSR71Tmp := XBUF71;
                                    IF subframe7 = '0' THEN
                                        subframe7 := '1';
                                        TMPReg7(23 downto 0) :=
                                        XSR71Tmp(23 downto 0);
                                        TMPReg7(24) := VB1;
                                        IF framecnt7 > 159 THEN
                                            TMPReg7(25) :=
                                            DITCSRB5(framecnt7 - 160);
                                            TMPReg7(26) :=
                                            DITUDRB5(framecnt7 - 160);
                                        ELSIF framecnt7 > 127 THEN
                                            TMPReg7(25) :=
                                            DITCSRB4(framecnt7 - 128);
                                            TMPReg7(26) :=
                                            DITUDRB4(framecnt7 - 128);
                                        ELSIF framecnt7 > 95 THEN
                                            TMPReg7(25) :=
                                            DITCSRB3(framecnt7 - 96);
                                            TMPReg7(26) :=
                                            DITUDRB3(framecnt7 - 96);
                                        ELSIF framecnt7 > 63 THEN
                                            TMPReg7(25) :=
                                            DITCSRB2(framecnt7 - 64);
                                            TMPReg7(26) :=
                                            DITUDRB2(framecnt7 - 64);
                                        ELSIF framecnt7 > 31 THEN
                                            TMPReg7(25) :=
                                            DITCSRB1(framecnt7 - 32);
                                            TMPReg7(26) :=
                                            DITUDRB1(framecnt7 - 32);
                                        ELSE
                                            TMPReg7(25) :=
                                            DITCSRB0(framecnt7);
                                            TMPReg7(26) :=
                                            DITUDRB0(framecnt7);
                                        END IF;
                                        TMPReg7(27) := '0';
                                        IF TMPReg7(0) = '0' THEN
                                            Tmp7Reg56(0) := '1';
                                            Tmp7Reg56(1) := '1';
                                        ELSE
                                            Tmp7Reg56(0) := '1';
                                            Tmp7Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp7Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg7(i) = '0' THEN
                                                    Tmp7Reg56(2*i) := '1';
                                                    Tmp7Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp7Reg56(2*i) := '1';
                                                    Tmp7Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg7(i) = '0' THEN
                                                    Tmp7Reg56(2*i) := '0';
                                                    Tmp7Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp7Reg56(2*i) := '0';
                                                    Tmp7Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg7 := Tmp7Reg56 & "11100100";
                                        XRDY71_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF slotcnt7 /= 383 THEN
                                        subframe7 := '0';
                                        framecnt7 := framecnt7 +1;
                                        IF framecnt7 = 192 THEN
                                            framecnt7 := 0;
                                            bitcnt7 := 0;
                                            slotcnt7 := 0;
                                            transmit7 := false;
                                        END IF;
                                        TMPReg7(23 downto 0) :=
                                        XSR71Tmp(23 downto 0);
                                        TMPReg7(24) := VA1;
                                        IF framecnt7 > 159 THEN
                                            TMPReg7(25) :=
                                            DITCSRA5(framecnt7 - 160);
                                            TMPReg7(26) :=
                                            DITUDRA5(framecnt7 - 160);
                                        ELSIF framecnt7 > 127 THEN
                                            TMPReg7(25) :=
                                            DITCSRA4(framecnt7 - 128);
                                            TMPReg7(26) :=
                                            DITUDRA4(framecnt7 - 128);
                                        ELSIF framecnt7 > 95 THEN
                                            TMPReg7(25) :=
                                            DITCSRA3(framecnt7 - 96);
                                            TMPReg7(26) :=
                                            DITUDRA3(framecnt7 - 96);
                                        ELSIF framecnt7 > 63 THEN
                                            TMPReg7(25) :=
                                            DITCSRA2(framecnt7 - 64);
                                            TMPReg7(26) :=
                                            DITUDRA2(framecnt7 - 64);
                                        ELSIF framecnt7 > 31 THEN
                                            TMPReg7(25) :=
                                            DITCSRA1(framecnt7 - 32);
                                            TMPReg7(26) :=
                                            DITUDRA1(framecnt7 - 32);
                                        ELSE
                                            TMPReg7(25) :=
                                            DITCSRA0(framecnt7);
                                            TMPReg7(26) :=
                                            DITUDRA0(framecnt7);
                                        END IF;
                                        TMPReg7(27) := '0';
                                        IF TMPReg7(0) = '0' THEN
                                            Tmp7Reg56(0) := '1';
                                            Tmp7Reg56(1) := '1';
                                        ELSE
                                            Tmp7Reg56(0) := '1';
                                            Tmp7Reg56(1) := '0';
                                        END IF;
                                        FOR I IN 1 TO 27 LOOP
                                            IF Tmp7Reg56(2*i - 1) = '0' THEN
                                                IF TMPReg7(i) = '0' THEN
                                                    Tmp7Reg56(2*i) := '1';
                                                    Tmp7Reg56(2*i + 1) := '1';
                                                ELSE
                                                    Tmp7Reg56(2*i) := '1';
                                                    Tmp7Reg56(2*i + 1) := '0';
                                                END IF;
                                            ELSE
                                                IF TMPReg7(i) = '0' THEN
                                                    Tmp7Reg56(2*i) := '0';
                                                    Tmp7Reg56(2*i + 1) := '0';
                                                ELSE
                                                    Tmp7Reg56(2*i) := '0';
                                                    Tmp7Reg56(2*i + 1) := '1';
                                                END IF;
                                            END IF;
                                        END LOOP;
                                        Reg7 := Tmp7Reg56 & "11100010";
                                        XRDY71_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    bitcnt7 := 0;
                                    slotcnt7 := slotcnt7 +1;
                                END IF;

                            ELSIF DITEN1 = '0' THEN -- TDM

                                IF XTDM1(slotcnt7) = '1' THEN --active slot
                                    IF delayx = 0 AND startflagx7 = true THEN
                                        startflagx7 := false;
                                        XSR71 <= XBUF71;
                                        XSR71Tmp := XBUF71;
                                        bitcnt7 := 0;
                                        slotcnt7 := 0;
                                        IF XRDY71 = '1' THEN
                                            XUNDERN1_flag <=
                                                   '1', '0' AFTER 10 ns;
                                            XSR71Tmp := (others => '0');
                                        END IF;
                                        XRDY71_RD <= '1', '0' AFTER 10 ns;
                                    ELSIF delayx = 1 AND startflagx7 = true THEN
                                        startflagx7 := false;
                                        bitcnt7 := slotsize - 1;
                                        slotcnt7 := mode - 1;
                                    ELSIF delayx = 2 AND startflagx7 = true THEN
                                        startflagx7 := false;
                                        bitcnt7 := slotsize - 2;
                                        slotcnt7 := mode - 1;
                                    END IF;
                                    AXR1Out7_zd := XSR71Tmp(bitcnt7);
                                    XSLOTCNT1 <= to_slv(slotcnt7,10);
                                    bitcnt7 := bitcnt7 + 1;
                                    IF delayx = 0 AND slotcnt7 = (mode - 1)
                                       AND bitcnt7 = slotsize THEN
                                        transmit7 := false;
                                    ELSIF delayx = 1 AND slotcnt7 = (mode - 1)
                                          AND bitcnt7 = (slotsize - 1) THEN
                                        transmit7 := false;
                                    ELSIF delayx = 2 AND slotcnt7 = (mode - 1)
                                          AND bitcnt7 = (slotsize - 2) THEN
                                        transmit7 := false;
                                    END IF;
                                    IF bitcnt7 = slotsize THEN
                                       IF not(slotcnt7 = mode - 1 AND
                                          delayx = 0) THEN
                                            slotcnt7 := slotcnt7 + 1;
                                            bitcnt7 := 0;
                                            XSR71 <= XBUF71;
                                            XSR71Tmp := XBUF71;
                                            IF XRDY71 = '1' THEN
                                                XUNDERN1_flag <=
                                                '1', '0' AFTER 10 ns;
                                                XSR71Tmp := (others => '0');
                                            END IF;
                                            XRDY71_RD <= '1', '0' AFTER 10 ns;
                                        END IF;
                                    END IF;
                                    IF slotcnt7 = mode THEN
                                        slotcnt7 := 0;
                                        bitcnt7 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD71 = "00" THEN
                                        AXR1Out7_zd := 'Z';
                                    ELSIF DISMOD71 = "10" THEN
                                        AXR1Out7_zd := '0';
                                    ELSIF DISMOD71 = "11" THEN
                                        AXR1Out7_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF rising_edge(XCLK) AND transmit7 = false THEN
                            syncxcnt := syncxcnt + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN "10" => -- serializer is receiver
                IF RSMRST1 = '0' THEN -- state machine is in reset
                    IF PFUNC1(7) = '0' AND PDIR1(7) = '1' THEN
                        IF DISMOD71 = "00" THEN
                            AXR1Out7_zd := 'Z';
                        ELSIF DISMOD71 = "10" THEN
                            AXR1Out7_zd := '0';
                        ELSIF DISMOD71 = "11" THEN
                            AXR1Out7_zd := '1';
                        END IF;
                    END IF;
                ELSE -- state machine is active
                    IF RSRCLR1 = '1' THEN -- receive serializers are active
                        IF falling_edge(RCLK) AND receive7 = true THEN

                            IF moder = 0 THEN -- burst
                                IF delayr = 0 AND startflagr7 = true THEN
                                    bitcntr7 := 0;
                                    startflagr7 := false;
                                    startburstr7 := true;
                                ELSIF delayr = 1 AND startflagr7 = true AND
                                      bitcntr7 = 1 THEN
                                    bitcntr7 := 0;
                                    startflagr7 := false;
                                    startburstr7 := true;
                                ELSIF delayr = 2 AND startflagr7 = true AND
                                      bitcntr7 = 2 THEN
                                    bitcntr7 := 0;
                                    startflagr7 := false;
                                    startburstr7 := true;
                                END IF;
                                IF startburstr7 = true THEN
                                    RSR71Tmp(bitcntr7) := AXR1In7;
                                END IF;
                                bitcntr7 := bitcntr7 + 1;
                                IF bitcntr7 = slotsizer THEN
                                    startburstr7 := false;
                                    bitcntr7 := 0;
                                    receive7 := false;
                                    RSR71 <= RSR71Tmp;
                                    RBUF71 <= RSR71Tmp;
                                    RRDY71_RD <= '1', '0' AFTER 10 ns;
                                END IF;

                            ELSE -- TDM

                                IF RTDM1(slotcntr7) = '1' THEN --active slot
                                    IF delayr = 0 AND startflagr7 = true THEN
                                        startflagr7 := false;
                                        bitcntr7 := 0;
                                        slotcntr7 := 0;
                                    ELSIF delayr = 1 AND startflagr7 = true THEN
                                        startflagr7 := false;
                                        bitcntr7 := slotsizer - 1;
                                        slotcntr7 := moder - 1;
                                    ELSIF delayr = 2 AND startflagr7 = true THEN
                                        startflagr7 := false;
                                        bitcntr7 := slotsizer - 2;
                                        slotcntr7 := moder - 1;
                                    END IF;
                                    IF DLBEN1 = '1' AND ASYNC1 = '0' AND
                                       MODE1 = "01" AND mode < 33 AND
                                       ORD1 = '0' THEN
                                        IF mode > 1 THEN -- Loopback mode
                                            RSR71Tmp(bitcntr7) := AXR1Out6_zd;
                                        END IF;
                                    ELSE
                                        RSR71Tmp(bitcntr7) := AXR1In7;
                                    END IF;
                                    RSLOTCNT1 <= to_slv(slotcntr7,10);
                                    bitcntr7 := bitcntr7 + 1;
                                    IF delayr = 0 AND slotcntr7 = (moder - 1)
                                       AND bitcntr7 = slotsizer THEN
                                        receive7 := false;
                                    ELSIF delayr = 1 AND slotcntr7 = (moder - 1)
                                          AND bitcntr7 = (slotsizer - 1) THEN
                                        receive7 := false;
                                    ELSIF delayr = 2 AND slotcntr0 = (moder - 1)
                                          AND bitcntr0 = (slotsizer - 2) THEN
                                        receive7 := false;
                                    END IF;
                                    IF bitcntr7 = slotsizer THEN
                                        slotcntr7 := slotcntr7 + 1;
                                        bitcntr7 := 0;
                                        RSR71 <= RSR71Tmp;
                                        RBUF71 <= RSR71Tmp;
                                        IF RRDY71 = '1' THEN
                                            ROVERN1_flag <=
                                                     '1', '0' AFTER 10 ns;
                                        END IF;
                                        RRDY71_RD <= '1', '0' AFTER 10 ns;
                                    END IF;
                                    IF slotcntr7 = moder THEN
                                        slotcntr7 := 0;
                                        bitcntr7 := 0;
                                    END IF;
                                ELSE -- inactive TDM slot
                                    IF DISMOD71 = "00" THEN
                                        AXR1Out7_zd := 'Z';
                                    ELSIF DISMOD71 = "10" THEN
                                        AXR1Out7_zd := '0';
                                    ELSIF DISMOD71 = "11" THEN
                                        AXR1Out7_zd := '1';
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF falling_edge(RCLK) AND receive7 = false THEN
                            syncrcnt := syncrcnt + 1;
                        END IF;
                    END IF;
                END IF;
            WHEN others =>
                null;
        END CASE;

        -- Audio Mute
        IF INPOL1 = '1' THEN
            AMUTEIN_int := not(AMUTEIN1);
        ELSE
            AMUTEIN_int := AMUTEIN1;
        END IF;

        IF PFUNC1(25) = '0' THEN
            IF (AMUTEIN_int = '1' AND INEN1 = '1') OR
               (ROVRN1 = '1' AND ROVERN1 = '1') OR
               (XUNDRN1 = '1' AND XUNDERN1 = '1') OR
               (RSYNCERR1 = '1' AND RSYNC1 = '1') OR
               (XSYNCERR1 = '1' AND XSYNC1 = '1') OR
               (RCKFAIL1 = '1' AND RCKFL1 = '1') OR
               (XCKFAIL1 = '1' AND XCKFL1 = '1') THEN
                IF MUTEN1 = "00" THEN
                    AMUTE1 <= 'Z';
                ELSIF MUTEN1 = "01" THEN
                    AMUTE1 <= '1';
                ELSIF MUTEN1 = "10" THEN
                    AMUTE1 <= '0';
                END IF;
            END IF;
        END IF;

    END IF;

    ----------------------------------------------------------------------------
    -- Path Delay Section
    ----------------------------------------------------------------------------
        VitalPathDelay01 (
            OutSignal       => HRDYNeg_int,
            OutSignalName   => "HRDYNeg",
            OutTemp         => HRDYNeg_zd,
            GlitchData      => HRDYNeg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => HCSNeg'LAST_EVENT,
                      PathDelay         => tpd_HCSNeg_HRDYNeg,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '1'),
                1 => (InputChangeTime   => HSTROB_int'LAST_EVENT,
                      PathDelay         => tpd_HSTROB_HRDYNeg,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '1'),
                2 => (InputChangeTime   => HASNeg'LAST_EVENT,
                      PathDelay         => tpd_HASNeg_HRDYNeg,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '1'),
                3 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => ((4 * PERIOD),(4 * PERIOD)),
                      PathCondition     => RESETNeg = '0' AND
                                           HPI_EN = '1'),
                4 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => ((8 * PERIOD),(8 * PERIOD)),
                      PathCondition     => RESETNeg = '1' AND
                                           HPI_EN = '1')
            )
        );

        VitalPathDelay01 (
            OutSignal       => HINTNeg,
            OutSignalName   => "HINTNeg",
            OutTemp         => HINTNeg_zd,
            GlitchData      => HINTNeg_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => HCSNeg'LAST_EVENT,
                      PathDelay         => (1 ns, 1 ns),
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => ((4 * PERIOD),(4 * PERIOD)),
                      PathCondition     => RESETNeg = '0' AND
                                           HPI_EN = '1'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => ((8 * PERIOD),(8 * PERIOD)),
                      PathCondition     => RESETNeg = '1' AND
                                           HPI_EN = '1')
            )
        );

        VitalPathDelay01 (
            OutSignal       => AXR1Out0,
            OutSignalName   => "AXR0",
            OutTemp         => AXR1Out0_zd,
            GlitchData      => AXR1Out0_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ACLKX1In'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1EXT_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD01 = "01"
                                           AND CLKXM1 = '0'),
                1 => (InputChangeTime   => ACLKX1Out_zd'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD01 = "01"
                                           AND CLKXM1 = '1')
            )
        );

        VitalPathDelay01 (
            OutSignal       => AXR1Out1,
            OutSignalName   => "AXR1",
            OutTemp         => AXR1Out1_zd,
            GlitchData      => AXR1Out1_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ACLKX1In'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1EXT_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD11 = "01"
                                           AND CLKXM1 = '0'),
                1 => (InputChangeTime   => ACLKX1Out_zd'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD11 = "01"
                                           AND CLKXM1 = '1')
            )
        );

        VitalPathDelay01 (
            OutSignal       => AXR1Out2,
            OutSignalName   => "AXR2",
            OutTemp         => AXR1Out2_zd,
            GlitchData      => AXR1Out2_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ACLKX1In'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1EXT_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD21 = "01"
                                           AND CLKXM1 = '0'),
                1 => (InputChangeTime   => ACLKX1Out_zd'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD21 = "01"
                                           AND CLKXM1 = '1')
            )
        );

        VitalPathDelay01 (
            OutSignal       => AXR1Out3,
            OutSignalName   => "AXR3",
            OutTemp         => AXR1Out3_zd,
            GlitchData      => AXR1Out3_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ACLKX1In'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1EXT_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD31 = "01"
                                           AND CLKXM1 = '0'),
                1 => (InputChangeTime   => ACLKX1Out_zd'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD31 = "01"
                                           AND CLKXM1 = '1')
            )
        );

        VitalPathDelay01 (
            OutSignal       => AXR1Out4,
            OutSignalName   => "AXR4",
            OutTemp         => AXR1Out4_zd,
            GlitchData      => AXR1Out4_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ACLKX1In'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1EXT_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD41 = "01"
                                           AND CLKXM1 = '0'),
                1 => (InputChangeTime   => ACLKX1Out_zd'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD41 = "01"
                                           AND CLKXM1 = '1')
            )
        );

        VitalPathDelay01 (
            OutSignal       => AXR1Out5,
            OutSignalName   => "AXR5",
            OutTemp         => AXR1Out5_zd,
            GlitchData      => AXR1Out5_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ACLKX1In'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1EXT_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD51 = "01"
                                           AND CLKXM1 = '0'),
                1 => (InputChangeTime   => ACLKX1Out_zd'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD51 = "01"
                                           AND CLKXM1 = '1')
            )
        );

        VitalPathDelay01 (
            OutSignal       => AXR1Out6,
            OutSignalName   => "AXR6",
            OutTemp         => AXR1Out6_zd,
            GlitchData      => AXR1Out6_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ACLKX1In'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1EXT_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD61 = "01"
                                           AND CLKXM1 = '0'),
                1 => (InputChangeTime   => ACLKX1Out_zd'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD61 = "01"
                                           AND CLKXM1 = '1')
            )
        );

        VitalPathDelay01 (
            OutSignal       => AXR1Out7,
            OutSignalName   => "AXR7",
            OutTemp         => AXR1Out7_zd,
            GlitchData      => AXR1Out7_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ACLKX1In'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1EXT_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD71 = "01"
                                           AND CLKXM1 = '0'),
                1 => (InputChangeTime   => ACLKX1Out_zd'LAST_EVENT,
                      PathDelay         => tpd_ACLKX1_AXR,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '0' AND SRMOD71 = "01"
                                           AND CLKXM1 = '1')
            )
        );

    END PROCESS HPI;

    ----------------------------------------------------------------------------
    -- CPU Process
    ----------------------------------------------------------------------------

    CPU : PROCESS(RESET_int, BootDone, CPUclk2, DSPINT, DMAdone)

    TYPE write_arg_type IS
        RECORD
            op          : NATURAL;
            destHAddr   : NATURAL;
            destLAddr   : NATURAL;
            Data3       : NATURAL;
            Data2       : NATURAL;
            Data1       : NATURAL;
            Data0       : NATURAL;
            MvLen       : NATURAL;
        END RECORD;

    TYPE inst_store IS ARRAY(0 to 4095) OF write_arg_type;

    FILE command_file  : text IS IN command_file_name;
    VARIABLE cpu_run   : BOOLEAN := false;
    VARIABLE auto_lock : BOOLEAN := false;
    VARIABLE write_arg : write_arg_type;
    VARIABLE buf       : line;
    VARIABLE inst      : inst_store;
    VARIABLE ind       : NATURAL := 0;
    VARIABLE inst_cnt  : NATURAL := 0;
    VARIABLE nop_cnt   : NATURAL := 0;
    VARIABLE mv_cnt    : NATURAL := 0;

    BEGIN
    IF cpu_autostart_time > 0 ns AND
               NOW > cpu_autostart_time AND not auto_lock THEN
        cpu_run := true;
        auto_lock := true;
    END IF;

    IF falling_edge(DSPINT) THEN
        DSPclear <= false;
    END IF;

    IF rising_edge(DSPINT) THEN
        DSPclear <= true;
        cpu_run := not cpu_run;
    END IF;

    IF falling_edge(RESET_int) THEN   -- Read Vector File
        ind := 0;
        WHILE (not ENDFILE (command_file)) LOOP
            READLINE (command_file, buf);
            IF buf(1) = '#' OR buf(1) = ' ' THEN
                NEXT;
            END IF;
            write_arg.op        := b(buf(1 to 2));
            write_arg.destHAddr := h(buf(4 to 7));
            write_arg.destLAddr := h(buf(9 to 12));
            write_arg.Data3     := h(buf(14 to 15));
            write_arg.Data2     := h(buf(16 to 17));
            write_arg.Data1     := h(buf(19 to 20));
            write_arg.Data0     := h(buf(21 to 22));
            IF write_arg.op = 3 THEN
                write_arg.MvLen     := h(buf(24 to 27));
            END IF;
            inst(ind) := write_arg;
            ind := ind + 1;
        END LOOP;
    END IF;

    IF rising_edge(CPUclk2) AND cpu_run AND DMAdone = '1' AND
                 inst_cnt < ind THEN -- run vectors
        IF nop_cnt = 0 THEN
            write_arg := inst(inst_cnt);
            CPUaddr(1) <= write_arg.destHAddr;
            CPUaddr(0) <= write_arg.destLAddr;
            CPUdata(3) <= write_arg.Data3;
            CPUdata(2) <= write_arg.Data2;
            CPUdata(1) <= write_arg.Data1;
            CPUdata(0) <= write_arg.Data0;
            CPUsize <= write_arg.MvLen;
            CASE write_arg.op IS
                WHEN 0 =>    -- NOP
                    inst_cnt := inst_cnt + 1;
                    nop_cnt := write_arg.Data0;
                    ASSERT false
                        REPORT "executing " & to_hex_str(write_arg.Data0) &
                               "nop(s)"
                    SEVERITY note;
                WHEN 1 =>    -- WR
                    IF not((write_arg.destHAddr = 16#018C# AND
                       write_arg.destLAddr = 16#0004# AND XRDY_t = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#0200# AND XRDY01 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#0204# AND XRDY11 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#0208# AND XRDY21 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#020C# AND XRDY31 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#0210# AND XRDY41 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#0214# AND XRDY51 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#0218# AND XRDY61 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#021C# AND XRDY71 = '0')) THEN
                        CPUop <= WR;
                        CPUrdy <= '1';
                        inst_cnt := inst_cnt + 1;
                        ASSERT false
                            REPORT "write addr=" &
                                    to_hex_str(write_arg.destHAddr) &
                                    to_hex_str(write_arg.destLAddr) & " data=" &
                                    to_hex_str(write_arg.Data3) &
                                    to_hex_str(write_arg.Data2) &
                                    to_hex_str(write_arg.Data1) &
                                    to_hex_str(write_arg.Data0)
                            SEVERITY note;
                    END IF;
                WHEN 2 =>    -- RD
                    IF not((write_arg.destHAddr = 16#018C# AND
                       write_arg.destLAddr = 16#0000# AND RRDY = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#0280# AND RRDY01 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#0284# AND RRDY11 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#0288# AND RRDY21 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#028C# AND RRDY31 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#0290# AND RRDY41 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#0294# AND RRDY51 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#0298# AND RRDY61 = '0') OR
                       (write_arg.destHAddr = 16#01B5# AND
                       write_arg.destLAddr = 16#029C# AND RRDY71 = '0')) THEN
                        CPUop <= RD;
                        CPUrdy <= '1';
                        inst_cnt := inst_cnt + 1;
                        ASSERT false
                            REPORT "read addr=" &
                                    to_hex_str(write_arg.destHAddr) &
                                    to_hex_str(write_arg.destLAddr) & " data=" &
                                    to_hex_str(write_arg.Data3) &
                                    to_hex_str(write_arg.Data2) &
                                    to_hex_str(write_arg.Data1) &
                                    to_hex_str(write_arg.Data0)
                            SEVERITY note;
                    END IF;
                WHEN 3 =>    -- MV
                    CPUop <= MV;
                    CPUrdy <= '1';
                    inst_cnt := inst_cnt + 1;
                    mv_cnt := write_arg.MvLen;
                    ASSERT false
                        REPORT "move from_addr=" &
                                to_hex_str(write_arg.destHAddr) &
                                to_hex_str(write_arg.destLAddr) & " to_addr=" &
                                to_hex_str(write_arg.Data3) &
                                to_hex_str(write_arg.Data2) &
                                to_hex_str(write_arg.Data1) &
                                to_hex_str(write_arg.Data0)
                                & " block size=" & to_hex_str(write_arg.MvLen)
                    SEVERITY note;
                WHEN others =>    -- END
                    cpu_run := false;
                    inst_cnt := 0;
            END CASE;
        ELSE
            nop_cnt := nop_cnt - 1;
        END IF;
    END IF;

    IF falling_edge(DMAdone) THEN
        CPUrdy <= '0';
    END IF;

    IF rising_edge(DMAdone) THEN
        IF CPUop = RD THEN
            ASSERT RDdata = CPUdata
                REPORT "Read " & to_hex_str(RDdata(3)) & to_hex_str(RDdata(2))
                    & to_hex_str(RDdata(1)) & to_hex_str(RDdata(0)) &
                    " expected " & to_hex_str(CPUdata(3)) &
                    to_hex_str(CPUdata(2))
                    & to_hex_str(CPUdata(1)) & to_hex_str(CPUdata(0))
                SEVERITY error;
        END IF;
    END IF;

    END PROCESS CPU;

    ----------------------------------------------------------------------------
    -- McBSP
    ----------------------------------------------------------------------------
    McBSP : PROCESS(XRDY_t, CLKX_INT, CLKR_int,FSX_INT, FSR_INT, XRDY,
                    XSLAVE_clk, CLKR0In, CLKX0In, FSR0In, FSX0In, CLKSRG, CLKS0,
                    CLKG, CPUclk, DR0, RRDY)
       -- Timing Check Variable

        VARIABLE PD_CLKR0          : VitalPeriodDataType := VitalPeriodDataInit;
        VARIABLE Pviol_CLKR0       : X01 := '0';

        VARIABLE PD_CLKX0          : VitalPeriodDataType := VitalPeriodDataInit;
        VARIABLE Pviol_CLKX0       : X01 := '0';

        VARIABLE PD_CLKR0int       : VitalPeriodDataType := VitalPeriodDataInit;
        VARIABLE Pviol_CLKR0int    : X01 := '0';

        VARIABLE PD_CLKX0int       : VitalPeriodDataType := VitalPeriodDataInit;
        VARIABLE Pviol_CLKX0int    : X01 := '0';

        VARIABLE Tviol_FSR0_CLKR0     : X01 := '0';
        VARIABLE TD_FSR0_CLKR0        : VitalTimingDataType;

        VARIABLE Tviol_FSR0_CLKRINT   : X01 := '0';
        VARIABLE TD_FSR0_CLKRINT      : VitalTimingDataType;

        VARIABLE Tviol_FSR0_CLKS0     : X01 := '0';
        VARIABLE TD_FSR0_CLKS0        : VitalTimingDataType;

        VARIABLE Tviol_DR0_CLKR0      : X01 := '0';
        VARIABLE TD_DR0_CLKR0         : VitalTimingDataType;

        VARIABLE Tviol_DR0_CLKRINT    : X01 := '0';
        VARIABLE TD_DR0_CLKRINT       : VitalTimingDataType;

        VARIABLE Tviol_FSX0_CLKX0     : X01 := '0';
        VARIABLE TD_FSX0_CLKX0        : VitalTimingDataType;

        VARIABLE Tviol_FSX0_CLKXINT   : X01 := '0';
        VARIABLE TD_FSX0_CLKXINT      : VitalTimingDataType;

        VARIABLE Violation            : X01 := '0';

        TYPE STATE     IS (act, inact);
        TYPE cnt       IS ARRAY(1 downto 0) of Natural;
        TYPE RRCER     IS ARRAY(1 downto 0) of std_logic_vector (15 downto 0);
        TYPE XCER_temp IS ARRAY(1 downto 0) of std_logic_vector (15 downto 0);
        VARIABLE DXR_XSR_flag          : Boolean := false;
        VARIABLE wskip_flag            : Boolean := false;
        VARIABLE XINVERS_flag          : Boolean := false;
        VARIABLE McWRITE_flag          : Boolean := false;
        VARIABLE XSECONDFR_flag        : Boolean := false;
        VARIABLE RSR_to_RBR            : Boolean := false;
        VARIABLE RBR_to_DRR_flag       : Boolean := false;
        VARIABLE RFULL_flag            : Boolean := false;
        VARIABLE RSYNCERR_flag         : Boolean := false;
        VARIABLE McRIDE_flag           : Boolean := false;
        VARIABLE RSECONDFR_flag        : Boolean := false;
        VARIABLE RRDY_flag             : Boolean := false;
        VARIABLE START_FLAG            : Boolean := true;
        VARIABLE Fflag                 : Boolean := false;
        VARIABLE WSTART_flag           : Boolean := false;
        VARIABLE WEND_flag             : Boolean := false;
        VARIABLE XWRITE_flag           : Boolean := false;
        VARIABLE XBLOCK_flag           : Boolean := true;
        VARIABLE RFLAG                 : Boolean := false;
        VARIABLE XSYNC_flag            : Boolean := false;
        VARIABLE XRDYrd_flag           : Boolean := false;
        VARIABLE parity_flag           : Boolean := true;
        VARIABLE XDATLY00_flag         : Boolean := false;
        VARIABLE CLKG_start            : Boolean := true;
        VARIABLE RINVERS_flag          : Boolean := false;
        VARIABLE stpclk_falg           : Boolean := true;
        VARIABLE GSYNC_flag            : Boolean := false;
        VARIABLE FSRstart_flag         : Boolean := false;
        VARIABLE FSXstart_flag         : Boolean := false;
        VARIABLE FSRsync_flag          : Boolean  := false;
        VARIABLE SECOND_frame_mc       : Boolean  := false;

        VARIABLE XBOUNDARY1            : Natural;
        VARIABLE XBOUNDARY2            : Natural;
        VARIABLE XBOUNDARY3            : Natural;
        VARIABLE XBOUNDARY4            : Natural;
        VARIABLE XBOUNDARY5            : Natural;
        VARIABLE XBOUNDARY6            : Natural;
        VARIABLE XWD_in_FR             : Natural;
        VARIABLE XPHASE_mark           : Natural;
        VARIABLE XCOUNT                : Natural;
        VARIABLE XDELAY                : Natural;
        VARIABLE XPHASE_NUM            : Natural;
        VARIABLE XWORD_cnt1            : Natural;
        VARIABLE XWORD_cnt2            : Natural;
        VARIABLE SYNCER_clks           : Natural :=0;
        VARIABLE CLKgdv_cnt            : Natural :=0;
        VARIABLE Fcnt                  : Natural :=1;
        VARIABLE CLKXcount             : Natural :=0;
        VARIABLE RPHASE_mark           : Natural;
        VARIABLE RCOUNT                : Natural;
        VARIABLE RDELAY                : Natural;
        VARIABLE RBOUNDARY1            : Natural;
        VARIABLE RBOUNDARY2            : Natural;
        VARIABLE RBOUNDARY3            : Natural;
        VARIABLE RBOUNDARY4            : Natural;
        VARIABLE RBOUNDARY5            : Natural;
        VARIABLE RBOUNDARY6            : Natural;
        VARIABLE RWD_in_FR             : Natural;
        VARIABLE RPHASE_numb           : Natural;
        VARIABLE RWORD_cnt1            : Natural;
        VARIABLE RWORD_cnt2            : Natural;
        VARIABLE XCER_numb             : Natural;
        VARIABLE XWORD_temp            : Natural;
        VARIABLE RCER_numb             : Natural;
        VARIABLE xdel_fsr_flag         : Integer := 0;
        VARIABLE STPINT                : Integer := 20;

        VARIABLE XPERIOD               : Time := 0 ns;
        VARIABLE XPREVIOUS             : Time := 0 ns;
        VARIABLE CLKS_pre              : Time := 0 ns;
        VARIABLE CLKS_per              : Time := 0 ns;
         VARIABLE RPERIOD              : Time := 0 ns;
        VARIABLE RPREVIOUS             : Time := 0 ns;

        VARIABLE CLKG_temp             : std_logic;
        VARIABLE FSTemp                : std_logic;
        VARIABLE CLKTemp               : std_logic;
        VARIABLE XSRtemp2              : std_logic_vector(31 downto 0);
        VARIABLE XCERE_FULL            : std_logic_vector (127 downto 0);
        VARIABLE RCERE_full            : std_logic_vector (127 downto 0);
        VARIABLE XSRtemp               : std_logic_vector (31 downto 0)
                                        :="00000000000000000000000000000000";

        VARIABLE XCER_temp1            : XCER_temp;
        VARIABLE XFRAME_numb           : cnt;
        VARIABLE XWORD_num             : cnt;
        VARIABLE RFRAME_numb           : cnt;
        VARIABLE RWORD_numb            : cnt;
        VARIABLE XRST_state            : state;
        VARIABLE RRST_state            : state;
        VARIABLE GRST_state            : state;
        VARIABLE RCER_temp1            : RRCER;
        VARIABLE RSTATE                : STATE := inact;
        VARIABLE XSTATE                : STATE := inact;

       VARIABLE DX0_GlitchData        : VitalGlitchDataType;
       VARIABLE FSX0Out_GlitchData    : VitalGlitchDataType;
       VARIABLE FSR0Out_GlitchData    : VitalGlitchDataType;
       VARIABLE CLKX0Out_GlitchData   : VitalGlitchDataType;
       VARIABLE CLKR0Out_GlitchData   : VitalGlitchDataType;
       VARIABLE FSXINT_GlitchData     : VitalGlitchDataType;
       VARIABLE FSRINT_GlitchData     : VitalGlitchDataType;
       VARIABLE CLKXINT_GlitchData    : VitalGlitchDataType;
       VARIABLE CLKRINT_GlitchData    : VitalGlitchDataType;

       VARIABLE DX0_zd          : STD_ULOGIC := 'X';
       VARIABLE FSXINT_zd       : STD_ULOGIC := 'X';
       VARIABLE FSRINT_zd       : STD_ULOGIC := 'X';
       VARIABLE CLKXINT_zd      : STD_ULOGIC := 'X';
       VARIABLE CLKRINT_zd      : STD_ULOGIC := 'X';
       VARIABLE fsx0out_zd      : STD_ULOGIC := 'X';
       VARIABLE fsr0out_zd      : STD_ULOGIC := 'X';
       VARIABLE CLKX0out_zd     : STD_ULOGIC := 'X';
       VARIABLE CLKR0out_zd     : STD_ULOGIC := 'X';
       VARIABLE DX0_zd1         : STD_ULOGIC := 'X';

       BEGIN

    ----------------------------------------------------------------------------
    -- Timing Check Section
    ----------------------------------------------------------------------------

       IF  (TimingChecksOn) THEN

        VitalPeriodPulseCheck (
               TestSIGNAL      =>  CLKR0In,
               TestSIGNALName  =>  "CLKR0",
               Period          =>  4*PERIOD,
               PulseWidthLow   =>  2*PERIOD - 1 ns ,
               PulseWidthHigh  =>  2*PERIOD - 1 ns,
               PeriodData      =>  PD_CLKR0,
               XOn             =>  XOn,
               MsgOn           =>  MsgOn,
               HeaderMsg       =>  InstancePath & PartID,
               CheckEnabled    =>  (CLKRM = '0' AND DLB = '0') OR
                (CLKRM = '1' AND CLKSM = '1' AND DLB = '0'),
               Violation       =>  Pviol_CLKR0
               );

        VitalPeriodPulseCheck (
               TestSIGNAL      =>  CLKX0In,
               TestSIGNALName  =>  "CLKX0",
               Period          =>  4*PERIOD,
               PulseWidthLow   =>  2*PERIOD - 1 ns,
               PulseWidthHigh  =>  2*PERIOD - 1 ns,
               PeriodData      =>  PD_CLKX0,
               XOn             =>  XOn,
               MsgOn           =>  MsgOn,
               HeaderMsg       =>  InstancePath & PartID,
               CheckEnabled    =>  CLKXM = '0' OR (CLKXM = '1' AND CLKSM = '1'),
               Violation       =>  Pviol_CLKX0
                );

        VitalPeriodPulseCheck (
               TestSIGNAL      =>  CLKR_int,
               TestSIGNALName  =>  "CLKR0intgenerate",
               Period          =>  4*PERIOD,
               PulseWidthLow   =>  2*PERIOD - 1 ns,
               PulseWidthHigh  =>  2*PERIOD - 1 ns,
               PeriodData      =>  PD_CLKR0int,
               XOn             =>  XOn,
               MsgOn           =>  MsgOn,
               HeaderMsg       =>  InstancePath & PartID,
               CheckEnabled    =>  CLKRM = '1' AND DLB = '0',
               Violation       =>  Pviol_CLKR0int
               );

        VitalPeriodPulseCheck (
               TestSIGNAL      =>  CLKX_int,
               TestSIGNALName  =>  "CLKX0generate",
               Period          =>  4*PERIOD,
               PulseWidthLow   =>  2*PERIOD - 1 ns,
               PulseWidthHigh  =>  2*PERIOD - 1 ns,
               PeriodData      =>  PD_CLKX0int,
               XOn             =>  XOn,
               MsgOn           =>  MsgOn,
               HeaderMsg       =>  InstancePath & PartID,
               CheckEnabled    =>  CLKXM = '1',
               Violation       =>  Pviol_CLKX0int
               );

        VitalSetupHoldCheck (
               TestSIGNAL      =>  FSR0In,
               TestSIGNALName  =>  "FSR0",
               RefSIGNAL       =>  CLKR_int,
               RefSIGNALName   =>  "CLKR0",
               SetupHigh       =>  tsetup_FSR_CLKR,
               SetupLow        =>  tsetup_FSR_CLKR,
               HoldHigh        =>  thold_FSR_CLKR,
               HoldLow         =>  thold_FSR_CLKR,
               CheckEnabled    =>  (CLKRM = '0' AND FSRM = '0' AND DLB = '0') OR
                                   (CLKXM = '0' AND FSXM = '0' AND DLB = '1' AND
                                   FSR0In /= FSR0Out_zd),
               RefTransition   =>  '\',
               HeaderMsg       =>  InstancePath & PartID,
               TimingData      =>  TD_FSR0_CLKR0,
               XOn             =>  XOn,
               MsgOn           =>  MsgOn,
               Violation       =>  Tviol_FSR0_CLKR0 );

        VitalSetupHoldCheck (
               TestSIGNAL      =>  FSR0In,
               TestSIGNALName  =>  "FSR0",
               RefSIGNAL       =>  CLKR_int,
               RefSIGNALName   =>  "CLKR0int",
               SetupHigh       =>  9 ns,
               SetupLow        =>  9 ns,
               HoldHigh        =>  6 ns,
               HoldLow         =>  6 ns,
               CheckEnabled    =>  ((CLKRM = '1' AND FSRM= '0' AND DLB = '0') OR
                                   (CLKXM = '1' AND FSXM='0' AND DLB = '1')) AND
                                   FSR0In /= FSR0Out_zd,
               RefTransition   =>  '\',
               HeaderMsg       =>  InstancePath & PartID,
               TimingData      =>  TD_FSR0_CLKRINT,
               XOn             =>  XOn,
               MsgOn           =>  MsgOn,
               Violation       =>  Tviol_FSR0_CLKRINT );

        VitalSetupHoldCheck (
               TestSIGNAL      =>  FSR0In,
               TestSIGNALName  =>  "FSX0",
               RefSIGNAL       =>  CLKS0,
               RefSIGNALName   =>  "CLKS0",
               SetupHigh       =>  4 ns,
               SetupLow        =>  4 ns,
               HoldHigh        =>  4 ns,
               HoldLow         =>  4 ns,
               CheckEnabled    =>  GSYNC = '1' AND CLKSM='0' AND FSRM = '1' AND
                                   FSR0In /= FSR0Out_zd,
               RefTransition   =>  '\',
               HeaderMsg       =>  InstancePath & PartID,
               TimingData      =>  TD_FSR0_CLKS0,
               XOn             =>  XOn,
               MsgOn           =>  MsgOn,
               Violation       =>  Tviol_FSR0_CLKS0 );

        VitalSetupHoldCheck (
               TestSIGNAL      =>  FSX0In,
               TestSIGNALName  =>  "FSX0",
               RefSIGNAL       =>  CLKX_int,
               RefSIGNALName   =>  "CLKX0",
               SetupHigh       =>  tsetup_FSX_CLKX,
               SetupLow        =>  tsetup_FSX_CLKX,
               HoldHigh        =>  thold_FSX_CLKX,
               HoldLow         =>  thold_FSX_CLKX,
               CheckEnabled    =>  CLKXM = '0' AND FSXM = '0' ,
               RefTransition   =>  '\',
               HeaderMsg       =>  InstancePath & PartID,
               TimingData      =>  TD_FSX0_CLKX0,
               XOn             =>  XOn,
               MsgOn           =>  MsgOn,
               Violation       =>  Tviol_FSX0_CLKX0 );

        VitalSetupHoldCheck (
               TestSIGNAL      =>  FSX0In,
               TestSIGNALName  =>  "FSX0",
               RefSIGNAL       =>  CLKX_int,
               RefSIGNALName   =>  "CLKX0int",
               SetupHigh       =>  9 ns,
               SetupLow        =>  9 ns,
               HoldHigh        =>  6 ns,
               HoldLow         =>  6 ns,
               CheckEnabled    =>  CLKXM = '1' AND FSXM = '0' ,
               RefTransition   =>  '\',
               HeaderMsg       =>  InstancePath & PartID,
               TimingData      =>  TD_FSX0_CLKXINT,
               XOn             =>  XOn,
               MsgOn           =>  MsgOn,
               Violation       =>  Tviol_FSX0_CLKXINT );

        VitalSetupHoldCheck (
               TestSIGNAL      =>  DR0,
               TestSIGNALName  =>  "DR0",
               RefSIGNAL       =>  CLKR_int,
               RefSIGNALName   =>  "CLKR",
               SetupHigh       =>  tsetup_DR_CLKR,
               SetupLow        =>  tsetup_DR_CLKR,
               HoldHigh        =>  thold_DR_CLKR,
               HoldLow         =>  thold_DR_CLKR,
               CheckEnabled    =>  (CLKRM = '0' AND DLB = '0') OR
                                   (CLKXM = '0' AND DLB = '1'),
               RefTransition   =>  '\',
               HeaderMsg       =>  InstancePath & PartID,
               TimingData      =>  TD_DR0_CLKR0,
               XOn             =>  XOn,
               MsgOn           =>  MsgOn,
               Violation       =>  Tviol_DR0_CLKR0 );

        VitalSetupHoldCheck (
               TestSIGNAL      =>  DR0,
               TestSIGNALName  =>  "DR0",
               RefSIGNAL       =>  CLKX_int,
               RefSIGNALName   =>  "CLKint",
               SetupHigh       =>  8 ns,
               SetupLow        =>  8 ns,
               HoldHigh        =>  3 ns,
               HoldLow         =>  3 ns,
               CheckEnabled    =>  (CLKRM = '1' AND DLB = '0') OR
                                                (CLKXM = '1' AND DLB = '1'),
               RefTransition   =>  '\',
               HeaderMsg       =>  InstancePath & PartID,
               TimingData      =>  TD_DR0_CLKRINT,
               XOn             =>  XOn,
               MsgOn           =>  MsgOn,
               Violation       =>  Tviol_DR0_CLKRINT );

         Violation := Pviol_CLKR0 OR Pviol_CLKX0
                      OR Tviol_FSR0_CLKR0 OR Tviol_FSR0_CLKRINT
                      OR Tviol_DR0_CLKR0 OR Tviol_DR0_CLKRINT
                      OR Tviol_FSX0_CLKX0 OR Tviol_FSX0_CLKXINT
                      OR Pviol_CLKR0int OR Pviol_CLKX0int OR Tviol_FSR0_CLKS0 ;

       END IF;
    ----------------------------------------------------------------------------
    -- Functionality section
    ----------------------------------------------------------------------------

        IF RESETNeg = '0' OR GRSTNeg = '0' THEN
            GRST_state := act;
            XCOUNT := 0;
        END IF;

        IF RESETNEG = '1' AND GRSTNEG = '1' THEN
            GRST_state := inact;
        END IF;

        IF GRST_state = inact THEN
            IF (rising_edge(FSR0In) AND FSRP = '0') OR
               (falling_edge(FSR0In) AND FSRP = '1') THEN
                FSRsync_flag := true;
            END IF;

            IF (falling_edge(FSR0In) AND FSRP = '0') OR
               (rising_edge(FSR0In) AND FSRP = '1') THEN
                FSRsync_flag := false;
            END IF;

            IF FSRsync_flag = true AND GSYNC = '1' AND CLKSM = '0' AND
                ((falling_edge(CLKS0) AND CLKSP = '1') OR
                    (rising_edge(CLKS0) AND CLKSP = '0')) THEN -- for resynch
                FSRsync_flag := false;
                SYNCER_clks :=1;
            END IF;

            IF (rising_edge(CLKX_int) OR rising_edge (XSLAVE_clk)) AND
               CLKSTP(1) = '1' AND CLKXM = '0' THEN
                CLKXcount := CLKXcount +1;
                IF CLKXcount = 8  THEN
                    XSLAVE_clk <= '1' after  xperiod ;
                END IF;
                IF CLKXcount = 9 THEN
                    XSLAVE_clk <= '0' after  xperiod/2 ;
                END IF;
            END IF;

            IF CLKXM = '0' THEN
                CLKXINT_zd := CLKX0In XOR CLKXP;
                CLKX0Out_zd  := 'Z';
                CLKTemp := CLKX0In XOR CLKXP;
                IF CLKSTP = "11" THEN
                    CLKXINT_zd := NOT (CLKX0In XOR CLKXP);
                END IF;
            ELSE
                CLKXINT_zd := CLKG;
                IF CLKSTP(1) = '1' AND STPint > 16 THEN
                    CLKX0Out_zd := CLKXP;
                ELSE
                    IF CLKSTP(1) = '1' THEN
                        IF CLKSTP(0) = '0' THEN
                            CLKX0Out_zd := CLKXP XOR (CLKG AND (NOT XIOEN));
                        ELSE
                            CLKX0Out_zd := CLKXP XOR (CLKG AND (NOT XIOEN));
                        END IF;
                    ELSE
                        CLKX0Out_zd := CLKXP XOR (CLKG AND (NOT XIOEN));
                    END IF;
                END IF;
                CLKTemp := CLKG;
            END IF;

            IF DLB='0' THEN
                IF CLKRM = '0' THEN
                    CLKRINT_zd := CLKR0In XOR CLKRP;
                    IF CLKSTP = "11" THEN
                        CLKRINT_zd := NOT CLKRINT_zd;
                    END IF;
                    CLKR0Out_zd := 'Z';
                ELSE
                    CLKRINT_zd := CLKG;
                    CLKR0Out_zd := CLKRP XOR (CLKG AND ( NOT RIOEN));
                END IF;
            ELSE
                CLKRINT_zd := CLKTemp;
                IF CLKRM = '1' THEN
                    CLKR0Out_zd := CLKRP XOR (CLKTemp AND (NOT RIOEN));
                ELSE
                    CLKR0Out_zd := 'Z';
                END IF;
            END IF;

            IF FSXM='0' THEN
                IF CLKSTP(1) = '0' THEN
                    FSTemp := FSX0In XOR FSXP;
                    FSXINT_zd := FSX0In XOR FSXP;
                    FSX0Out_zd :='Z';
                END IF;
                IF CLKSTP(1) = '1' AND CLKXM = '0' THEN
                    FSXINT_zd := not FSX0In;
                    FSX0Out_zd :='Z';
                END IF;
            ELSE
                IF FSGM = '0' THEN
                    FSTemp := DRXtoXSR_clk;
                    FSXINT_zd := DRXtoXSR_clk;
                ELSE
                    FSTemp := FSG;
                    FSXINT_Zd := FSG;
                END IF;
                FSX0Out_zd := FSXP XOR (FSTemp AND (NOT XIOEN));
                IF FSXM = '1' AND CLKXM = '1' AND CLKSTP (1) = '1' THEN
                    IF CLKSTP(0) = '0' THEn
                        IF STPINT > 17 THEN
                            FSX0Out_zd := '1';
                        ELSE
                            FSX0Out_zd := '0';
                        END IF;
                    ELSE
                        IF STPINT > 18 THEN
                            FSX0Out_zd := '1';
                        ELSE
                            FSX0Out_zd := '0';
                        END IF;
                    END IF;
                END IF;
            END IF;

            IF DLB='0' THEN
                IF FSRM = '0' THEN
                    FSRINT_zd := FSR0In XOR FSRP;
                    FSR0Out_zd := 'Z';
                ELSE
                    FSRINT_zd := FSG;
                    IF GSYNC = '0' THEN
                        FSR0Out_zd := FSRP XOR (FSG AND ( NOT RIOEN));
                    ELSE
                        FSR0Out_zd := 'Z';
                    END IF;
                END IF;
            ELSE
                FSRINT_zd := FSTemp;
                IF FSRM = '1' AND GSYNC= '0' THEN
                    FSR0Out_zd := FSRP XOR (FSTemp AND (NOT RIOEN));
                ELSE
                    FSR0Out_zd := 'Z';
                END IF;
            END IF;

            IF CLKSTP(1) = '1' THEN
                FSRINT_zd := FSXINT_zd;
                CLKRINT_zd := CLKXINT_zd ;
            END IF;

            IF CLKSM='0' THEN
                CLKSRG <= CLKS0 XOR CLKSP;
            ELSE
                CLKSRG <= CPUclk2;
            END IF;

            IF rising_edge (fsx_int) THEN
                stpclk_falg := true;
            END IF;

            IF CLKSRG'event THEN
                IF SYNCER_clks = 1 THEN
                    CLKG <= '1';
                    CLKgdv_cnt := 0;
                    SYNCER_clks := 0;
                    FSG <= '1';
                    Fcnt := 1;
                    Fflag := true;
                    parity_flag := true;
                    GSYNC_flag := true;
                END IF;
                IF (CLKgdv_cnt > to_nat(CLKGDV)) THEN
                    IF CLKG_start = true THEN
                        CLKG <= CLKSRG;
                        CLKG_start := false;
                    ELSE
                        CLKG <= NOT CLKG ;
                    END IF;
                    CLKG_temp := NOT CLKG;
                    CLKS_per := NOW - CLKS_pre;
                    CLKS_pre := NOW;
                    IF stpclk_falg = true THEN
                        stpint := 0;
                        stpclk_falg := false;
                    END IF;
                    stpint := stpint +1;
                    CLKgdv_cnt := 0;
                    IF GSYNC = '0' OR GSYNC_flag = true THEN
                        IF CLKG = '0' THEN
                            IF (Fflag = true) THEN
                                IF (Fcnt = to_nat(FWID)+1) THEN
                                    FSG <= '0';
                                    Fflag := NOT Fflag;
                                    Fcnt:=0;
                                    GSYNC_flag := false;
                                END IF;
                            ELSE
                                IF (Fcnt = to_nat(Fper)-to_nat(Fwid)) THEN
                                    FSG <= '1';
                                    Fflag := NOT Fflag;
                                    Fcnt :=0;
                                END IF;
                            END IF;
                            Fcnt := Fcnt+1;
                            IF GSYNC = '0' THEN
                                IF FPER = "000000000000" THEN
                                    Fcnt := 0;
                                    FSG <= '0';
                                END IF;
                                IF  (to_nat(Fper) < to_nat(Fwid)) THEN
                                    Fcnt := 0;
                                    FSG <= '0';
                                END IF;
                                IF (Fcnt > to_nat(Fper)) THEN
                                    Fcnt := 0;
                                    FSG <= '0';
                                END IF;
                            END IF;
                        END IF;
                    ELSE
                        Fcnt := 0;
                        null;
                    END IF;
                END IF;
                CLKgdv_cnt:=CLKgdv_cnt+1;
            END IF;
         END IF;

        IF  RESETNeg = '0' OR XRSTNeg = '0' THEN
            XRST_state := act;
            XCOUNT := 0;
        END IF;

        IF RESETNEG = '1' AND XRSTNEG = '1' THEN
            XRST_state := inact;
        END IF;

        IF XRST_state = inact THEN

            IF rising_edge(FSX_int) THEN
               FSXstart_flag := true;
            END IF;

            IF falling_edge(FSX_int) THEN
               FSXstart_flag := false;
            END IF;

            IF falling_edge(CLKX_int) AND FSXstart_flag = true THEN
                IF XSTATE = act AND XFIG = '0' THEN -- restart the transfer
                    XSYNC_flag := true;
                    XCOUNT := XCOUNT - XWORD_cnt1 + XWORD_num(XPHASE_mark) ;
                    XWORD_cnt1 := XWORD_num(XPHASE_mark)-1;
                    DXR_XSR_flag  := true;
                    XDATLY00_flag := true;
                END IF;
            END IF;

            IF (falling_edge(CLKX_int) AND FSXstart_flag = true) OR
               (rising_edge(FSX_int) AND XDATDLY = "00") THEN -- activating
                IF XSTATE = inact  THEN
                    XFRAME_numb(0) := to_nat(XFRLEN1)+1;
                    XFRAME_numb(1) := to_nat(XFRLEN2)+1;
                    IF XPHASE = '0' THEN
                        XPHASE_NUM := 0;
                    ELSE
                        XPHASE_NUM := 1;
                    END IF;
                    CASE XWDLEN1 IS
                        WHEN "000" =>
                            XWORD_num(0) := 8;
                        WHEN "001" =>
                            XWORD_num(0) := 12;
                        WHEN "010" =>
                            XWORD_num(0) := 16;
                        WHEN "011" =>
                            XWORD_num(0) := 20;
                        WHEN "100" =>
                            XWORD_num(0) := 24;
                        WHEN "101" =>
                            XWORD_num(0) := 32;
                        WHEN others =>
                            null;
                    END CASE;
                    CASE XWDLEN2 IS
                        WHEN "000" =>
                            XWORD_num(1) := 8;
                        WHEN "001" =>
                            XWORD_num(1) := 12;
                        WHEN "010" =>
                            XWORD_num(1) := 16;
                        WHEN "011" =>
                            XWORD_num(1) := 20;
                        WHEN "100" =>
                            XWORD_num(1) := 24;
                        WHEN "101"  =>
                            XWORD_num(1) := 32;
                        WHEN others =>
                            null;
                    END CASE;
                    CASE XDATDLY IS
                        WHEN "00" =>
                            XDELAY := 0;
                            xdel_fsr_flag := 1;
                        WHEN "01" =>
                            XDELAY := 0;
                        WHEN "10" =>
                            XDELAY := 1;
                        WHEN others =>
                            null;
                    END CASE;
                    CASE XPABLK IS
                        WHEN "00" =>
                            XBOUNDARY1 := 0;
                            XBOUNDARY2 := 15;
                        WHEN "01" =>
                            XBOUNDARY1 := 32;
                            XBOUNDARY2 := 47;
                        WHEN "10" =>
                            XBOUNDARY1 := 64;
                            XBOUNDARY2 := 79;
                        WHEN others =>
                            XBOUNDARY1 := 96;
                            XBOUNDARY2 := 111;
                    END CASE;
                    CASE XPBBLK IS
                        WHEN "00" =>
                            XBOUNDARY3 := 16;
                            XBOUNDARY4 := 31;
                        WHEN "01" =>
                            XBOUNDARY3 := 48;
                            XBOUNDARY4 := 63;
                        WHEN "10" =>
                            XBOUNDARY3 := 80;
                            XBOUNDARY4 := 95;
                        WHEN others =>
                            XBOUNDARY3 := 112;
                            XBOUNDARY4 := 127;
                    END CASE;
                    CASE XCBLK IS
                        WHEN "000" =>
                            XBOUNDARY5 := 0;
                            XBOUNDARY6 := 15;
                        WHEN "001" =>
                            XBOUNDARY5 := 16;
                            XBOUNDARY6 := 31;
                        WHEN "010" =>
                            XBOUNDARY5 := 32;
                            XBOUNDARY6 := 47;
                        WHEN "011" =>
                            XBOUNDARY5 := 48;
                            XBOUNDARY6 := 63;
                        WHEN "100" =>
                            XBOUNDARY5 := 64;
                            XBOUNDARY6 := 79;
                        WHEN "101" =>
                            XBOUNDARY5 := 80;
                            XBOUNDARY6 := 95;
                        WHEN "110" =>
                            XBOUNDARY5 := 96;
                            XBOUNDARY6 := 111;
                        WHEN others =>
                            XBOUNDARY5 := 112;
                            XBOUNDARY6 := 127;
                    END CASE;
                    IF XDATDLY = "00" AND CLKX_int = '0' AND CLKXM = '0' THEN
                        wskip_flag := true;
                    ELSE
                        wskip_flag :=false;
                    END IF;
                    FSXstart_flag := false;
                    CLKXcount := 0;
                    XCER_temp1(0) := XCER0(0);
                    XCER_temp1(1) := XCER0(1);
                    SECOND_frame_mc := true;
                    XCOUNT := XFRAME_numb(0) * XWORD_num(0)
                              + XPHASE_NUM * XFRAME_numb(1) * XWORD_num(1) ;
                    XWORD_cnt1 := XWORD_num(0);
                    XWORD_cnt2 :=  0;
                    XSTATE := act;
                    XWD_in_FR := 0;
                    XSECONDFR_flag := false;
                    IF XMCME = '0' THEN
                        XCERE_FULL (XBOUNDARY2 DOWNTO XBOUNDARY1) := XCER0(0);
                        XCERE_FULL (XBOUNDARY4 DOWNTO XBOUNDARY3) := XCER0(1);
                        XCERE_FULL (XBOUNDARY6 DOWNTO XBOUNDARY5)
                                                            :=  (others => '1');
                    END IF;
                    IF XMCME = '0' AND XMCM ="11" THEN
                        XCERE_FULL (RBOUNDARY2 DOWNTO RBOUNDARY1) := XCER0(0);
                        XCERE_FULL (RBOUNDARY4 DOWNTO RBOUNDARY3) := XCER0(1);
                        XCERE_FULL (RBOUNDARY6 DOWNTO RBOUNDARY5)
                                                            :=  (others => '1');
                    END IF;
                    DXR_XSR_flag := false;
                    XWORD_temp := XWORD_num(0);
                    wstart_flag := true;
                    wend_flag := true;
                    XDATLY00_flag := true;
                    XBLOCK_flag := true;
                    xwrite_flag := false;
                    IF XCOMPAD = "01" AND XWDREVRS = '1' THEN
                        XINVERS_flag := true;
                    ELSE
                        XINVERS_flag := false;
                    END IF;
                    IF XWORD_num(XPHASE_mark) = 32 AND XINVERS_flag = true THEN
                        FOR i IN 0 TO 31 LOOP
                            XSRtemp(i) := XSR0(31 - i);
                        END LOOP;
                    END IF;
                END IF;
            END IF;

             XCOUNTER <= RWORD_cnt2;

            IF XPHASE_NUM = 0 THEN
                XPHASE_mark := 0;
            ELSE
                IF (XCOUNT > XFRAME_numb(1) * XWORD_num(1)) THEN
                    XPHASE_mark := 0;
                ELSE
                    IF (XSECONDFR_flag = false) THEN
                        XSECONDFR_flag := true;
                        XWD_in_FR := 0;
                        XWORD_cnt2 :=0;
                        XWORD_temp := XWORD_temp + XWORD_num(1) - XWORD_num(0);
                        XWORD_cnt1 := XWORD_cnt1 + XWORD_num(1) - XWORD_num(0);
                    END IF;
                    XPHASE_mark := 1;
               END IF;
            END IF;

            IF  XMCM ="01" OR XMCM = "10" THEN
                IF XCERE_FULL(XWD_in_FR) ='1' THEN
                    McWRITE_flag := true;
                ELSE
                    McWRITE_flag := false;
                END IF;
            END IF;

            IF rising_edge(CLKX_int) OR (rising_edge(FSX_int) AND
               XDATDLY = "00" AND XDATLY00_flag = true)
               OR rising_edge (XSLAVE_clk) THEN
                XDATLY00_flag := false;
                XPERIOD := NOW - XPREVIOUS;
                XPREVIOUS := NOW;

                IF (XCOUNT > 0) THEN
                    IF DXR_XSR_flag = true THEN
                        IF XSYNC_flag = true THEN
                            XSYNCERR_RD <= '1', '0' AFTER 20 ns;
                            XSYNC_flag := false;
                            XSR0 <= XSRtemp2;
                            XSRtemp := XSRtemp2;
                        ELSE
                            IF XWORD_num(XPHASE_mark) = 32 AND
                               XINVERS_flag = true THEN
                                FOR i IN 0 TO 31 LOOP
                                    XSRtemp(i) := DXR0(31 - i);
                                END LOOP;
                            ELSE
                                XSRtemp := DXR0;
                            END IF;
                            IF XRDY = '0' THEN
                                DRXtoXSR_clk <= '1', '0' after XPERIOD ;
                            END IF;
                            XSR0 <= XSRtemp;
                            XSRtemp2 := XSRtemp;
                            XRDYrd_flag := true;
                            IF XWD_in_FR /= 127 THEN
                                IF (XCERE_FULL(XWD_in_FR + 1) ='0'
                                   AND XMCM = "01") THEN
                                    STOP_sig <= '1';
                                ELSE
                                    STOP_sig <= '0' after 20 ns;
                                END IF;
                            END IF;
                            IF  XWD_in_FR = 127 OR
                               (XCOUNT < XWORD_num(XPHASE_mark) + 3) THEN
                                STOP_sig <= '0' after 20 ns;
                            END IF;
                            IF XPHASE_num = 1 AND
                             (XCOUNT<XFRAME_numb(1)*XWORD_num(1)+XWORD_num(0)+3)
                              AND SECOND_frame_mc = TRUE AND XMCM = "01" THEN
                                SECOND_frame_mc := false;
                                IF XCERE_FULL(0) = '1' THEN
                                    STOP_sig <= '0' after 20 ns;
                                ELSE
                                    STOP_sig <= '1';
                                END IF;
                            END IF;
                            IF McWRITE_flag = false AND XMCM = "01" THEN
                                null;
                            ELSE
                                IF XRDY = '1' THEN
                                    XEMPTYNeg_RD <= '1' , '0' after 60 ns;
                                END IF;
                            END IF;
                        END IF;
                        DXR_XSR_flag := false;
                        IF McWRITE_flag = true OR XMCM ="00" THEN
                            DX0_zd := XSRtemp(XWORD_temp-1);
                        ELSE
                            DX0_zd := 'Z';
                        END IF;
                        XCOUNT := XCOUNT -1;
                    ELSE
                        IF (XCOUNT>0) THEN
                            IF (XDELAY = 0) THEN
                                IF XMCM = "00" OR McWRITE_flag = true THEN
                                    IF wstart_flag =  true THEN
                                        wstart_flag := false;
                                    ELSE
                                        IF wskip_flag = false  THEN
                                            XSRtemp (XWORD_temp-1 downto 0) :=
                                            XSRtemp (XWORD_temp-2 downto 0)&'0';
                                        ELSE
                                            wskip_flag := false;
                                        END IF;
                                    END IF;
                                    DX0_zd := XSRtemp (XWORD_temp-1);
                                    XSR0 <= XSRtemp;
                                    IF wskip_flag = false THEN
                                        XWORD_cnt1:=XWORD_cnt1-1;
                                    END IF;
                                    IF wskip_flag = true THEN
                                        XCOUNT := XCOUNT +1;
                                    END IF;
                                    IF XWORD_cnt1 = 0 THEN
                                        XWORD_cnt1 := XWORD_num(XPHASE_mark)-1;
                                        XWORD_temp := XWORD_num(XPHASE_mark);
                                        DXR_XSR_flag:=true;
                                        XWD_in_FR := XWD_in_FR +1;
                                        XWORD_cnt2 := XWORD_cnt2  +1;
                                        IF XWORD_cnt2 = 16 THEN
                                            XWORD_cnt2 :=0;
                                        END IF;
                                    END IF;
                                ELSE
                                    DX0_zd := 'Z';
                                END IF;
                                IF (XMCM = "01" OR XMCM = "10") AND
                                    McWRITE_flag = false THEN
                                    IF wstart_flag = true THEN
                                        null;
                                        wstart_flag := false;
                                    END IF;
                                    XWORD_cnt1:=XWORD_cnt1 - 1;
                                    IF XWORD_cnt1= 0 THEN
                                       XWORD_cnt1 := XWORD_num(XPHASE_mark) - 1;
                                       XWORD_temp := XWORD_num(XPHASE_mark);
                                       DXR_XSR_flag := true;
                                       XWD_in_FR := XWD_in_FR +1;
                                       XWORD_cnt2 := XWORD_cnt2 +1;
                                       IF XWORD_cnt2 = 16 THEN
                                            XWORD_cnt2 := 0;
                                       END IF;
                                    END IF;
                                END IF;
                            ELSE
                                XDELAY := XDELAY - 1;
                                XCOUNT := XCOUNT + 1;
                            END IF;
                            XCOUNT := XCOUNT - 1;
                        END IF;
                    END IF;
                ELSE
                    DX0_zd := 'Z';
                    IF wend_flag = true THEN
                        XSRtemp := DXR0;
                        IF XRDY = '0' THEN
                            DRXtoXSR_clk <= '1', '0' after XPERIOD;
                        ELSE
                            XBLOCK_flag := false;
                        END IF;
                        XSR0 <= XSRtemp;
                        XSRtemp2 := XSRtemp;
                        XRDYrd_flag := true;
                        wend_flag := false;
                        IF XRDY = '1' THEN
                            XEMPTYNeg_RD <= '1' , '0' after 60 ns;
                        END IF;
                    END IF;
                    XSTATE := inact;
                END IF;
            END IF;

            IF falling_edge(XRDY_t) AND XSTATE = inact
               AND START_FLAG = true THEN
                xwrite_flag := true;
                START_flag := false;
            END IF;

            IF falling_edge (XRDY) AND XSTATE = inact
               AND XBLOCK_flag = false THEN
                xwrite_flag := true;
                XBLOCK_flag := true;
            END IF;

            IF (rising_edge (CLKX_int) OR rising_edge (XSLAVE_clk))
               AND xwrite_flag = true  AND XSTATE = inact THEN
                XSR0 <= DXR0;
                xwrite_flag := false;
                XSRtemp := DXR0;
                IF XRDY = '0' THEN
                    DRXtoXSR_clk <= '1', '0' after XPERIOD;
                END IF;
                XRDYrd_flag := true;
            END IF;

            IF (falling_edge( clkx_int ) OR falling_edge(XSLAVE_clk))
               AND XRDYrd_flag = true THEN
                XRDYrd_flag := false;
                XRDY_RD <= '1' , '0' after 20 ns;
            END IF;

            CASE XINTm IS
                WHEN "00" =>
                    XINT <= XRDY;
                WHEN "01" =>
                    IF XWORD_cnt2 = 0 THEN
                        XINT <= '1', '0' after 4 * XPERIOD;
                    END IF;
                WHEN "10" =>
                    XINT <= FSX_INT;
                WHEN others =>
                    XINT <= XSYNCERR;
            END CASE;

            IF XMCM = "11" AND McRIDE_flag = true THEN
                DX0_zd := DX0_zd1;
            END IF;
        ELSE
            IF RESETNeg = '1' AND XIOEN = '1' THEN
                IF CLKXM = '0' THEN
                    CLKX0Out_zd := 'Z';
                ELSE
                    CLKX0Out_zd := CLKXP;
                END IF;
                IF FSXM = '0' THEN
                    FSX0Out_zd := 'Z';
                ELSE
                    FSX0Out_zd := FSXP;
                END IF;
                DX0_zd := DX0_STAT;
            ELSE
                FSX0Out_zd := 'Z';
                CLKX0Out_zd := 'Z';
                DX0_zd := 'Z';
            END IF;
        END IF;

        IF RESETNeg = '0'  OR RRSTNeg = '0' THEN
            RRST_state := act;
            RCOUNT := 0;
        END IF;

        IF RESETNEG = '1' AND RRSTNEG = '1' THEN
            RRST_state := inact;
        END IF;

        IF RRST_STATE = inact THEN

            IF rising_edge(fsr_int) THEN
               FSRstart_flag := true;
            END IF;

            IF falling_edge (fsr_int) THEN
               FSRstart_flag := false;
            END IF;

            IF (falling_edge (CLKR_int) AND FSRstart_flag = true) THEN
                IF RSTATE = act AND RFIG = '0' THEN
                    RSYNCERR_flag := true;
                    RCOUNT := RCOUNT - RWORD_cnt1 + RWORD_numb(RPHASE_mark);
                    RWORD_cnt1 := RWORD_numb(RPHASE_mark);
                    RDELAY := 1;
                    FSRstart_flag := false;
                END IF;
            END IF;

            IF (falling_edge (CLKR_int) AND FSRstart_flag = true) THEN
                IF RSTATE = inact THEN
                    RFRAME_numb(0) := to_nat(rfrlen1) + 1;
                    RFRAME_numb(1) := to_nat(rfrlen2) + 1;
                    IF RPHASE = '0' THEN
                        RPHASE_numb := 0;
                    ELSE
                        RPHASE_numb := 1;
                    END IF;
                    CASE RWDLEN1 IS
                        WHEN "000" =>
                            RWORD_numb(0) := 8;
                        WHEN "001" =>
                            RWORD_numb(0) := 12;
                        WHEN "010" =>
                            RWORD_numb(0) := 16;
                        WHEN "011" =>
                            RWORD_numb(0) := 20;
                        WHEN "100" =>
                            RWORD_numb(0) := 24;
                        WHEN "101" =>
                            RWORD_numb(0) := 32;
                        WHEN others =>
                            null;
                    END CASE;
                    CASE RWDLEN2 IS
                        WHEN "000" =>
                            RWORD_numb(1) := 8;
                        WHEN "001" =>
                            RWORD_numb(1) := 12;
                        WHEN "010" =>
                            RWORD_numb(1) := 16;
                        WHEN "011" =>
                            RWORD_numb(1) := 20;
                        WHEN "100" =>
                            RWORD_numb(1) := 24;
                        WHEN "101" =>
                            RWORD_numb(1) := 32;
                        WHEN others =>
                            null;
                    END CASE;
                    CASE RDATDLY IS
                        WHEN "00" =>
                            RDELAY := 0;
                        WHEN "01" =>
                            RDELAY := 1;
                        WHEN "10" =>
                            RDELAY := 2;
                        WHEN others =>
                            null;
                    END CASE;
                    CASE RPABLK IS
                        WHEN "00" =>
                            RBOUNDARY1 := 0;
                            RBOUNDARY2 := 15;
                        WHEN "01" =>
                            RBOUNDARY1 := 32;
                            RBOUNDARY2 := 47;
                        WHEN "10" =>
                            RBOUNDARY1 := 64;
                            RBOUNDARY2 := 79;
                        WHEN others =>
                            RBOUNDARY1 := 96;
                            RBOUNDARY2 := 111;
                    END CASE;
                    CASE RPBBLK IS
                        WHEN "00" =>
                            RBOUNDARY3 := 16;
                            RBOUNDARY4 := 31;
                        WHEN "01" =>
                            RBOUNDARY3 := 48;
                            RBOUNDARY4 := 63;
                        WHEN "10" =>
                            RBOUNDARY3 := 80;
                            RBOUNDARY4 := 95;
                        WHEN others =>
                            RBOUNDARY3 := 112;
                            RBOUNDARY4 := 127;
                    END CASE;
                    CASE RCBLK IS
                        WHEN "000" =>
                            RBOUNDARY5 := 0;
                            RBOUNDARY6 := 15;
                        WHEN "001" =>
                            RBOUNDARY5 := 16;
                            RBOUNDARY6 := 31;
                        WHEN "010" =>
                            RBOUNDARY5 := 32;
                            RBOUNDARY6 := 47;
                        WHEN "011" =>
                            RBOUNDARY5 := 48;
                            RBOUNDARY6 := 63;
                        WHEN "100" =>
                            RBOUNDARY5 := 64;
                            RBOUNDARY6 := 79;
                        WHEN "101" =>
                            RBOUNDARY5 := 80;
                            RBOUNDARY6 := 95;
                        WHEN "110" =>
                            RBOUNDARY5 := 96;
                            RBOUNDARY6 := 111;
                        WHEN others =>
                            RBOUNDARY5 := 112;
                            RBOUNDARY6 := 127;
                    END CASE;
                    RCER_temp1(0) := RCER0(0);
                    RCER_temp1(1) := RCER0(1);
                    RCOUNT := RFRAME_numb(0) * RWORD_numb(0) +
                              RPHASE_numb * (RFRAME_numb(1) * RWORD_numb(1) );
                    RSTATE := act;
                    RWORD_cnt1 := RWORD_numb(0);
                    RWORD_cnt2 :=  0;
                    FSRstart_flag := false;
                    RWD_in_FR := 0;
                    RSECONDFR_flag := false;
                    RFLAG := false;
                    IF RCOMPAD = "01" AND RWDREVRS = '1' THEN
                        RINVERS_flag := true;
                    ELSE
                        RINVERS_flag := false;
                    END IF;
                END IF;
            END IF;

            RCOUNTER <= RWD_in_FR;

            IF RPHASE_numb = 0 THEN
                RPHASE_mark := 0;
            ELSE
                IF (RCOUNT > RFRAME_numb(1) * RWORD_numb(1)) THEN
                    RPHASE_mark:=0;
                ELSE
                    IF (RSECONDFR_flag = false) THEN
                        RWORD_cnt1 := RWORD_cnt1 + RWORD_numb(1)-RWORD_numb(0);
                        RWD_in_FR := 0;
                        RWORD_cnt2 :=0;
                        RSECONDFR_flag := true;
                    END IF;
                    RFLAG := true;
                END IF;
            END IF;

            IF (RMCM = '1' AND RMCMe= '0') OR ( XMCM = "11" AND RMCMe='0') THEN
                IF (RWD_in_FR >= RBOUNDARY1 AND RWD_in_FR <= RBOUNDARY2) OR
                    (RWD_in_FR >= RBOUNDARY3 AND RWD_in_FR <= RBOUNDARY4 )
                OR (RWD_in_FR >= RBOUNDARY5 AND RWD_in_FR <= RBOUNDARY6 ) THEN
                    RCER_numb :=0;
                    IF (RWD_in_FR >= RBOUNDARY3 AND RWD_in_FR<=RBOUNDARY4) THEN
                        RCER_numb:=1;
                    END IF;
                    IF RCER_temp1(RCER_numb)(RWORD_cnt2) = '1' THEN
                        McRIDE_flag := true;
                    ELSE
                        McRIDE_flag := false;
                    END IF;
                    IF (RWD_in_FR >= RBOUNDARY5 AND RWD_in_FR<=RBOUNDARY6) THEN
                        McRIDE_flag := true;
                    END IF;
                ELSE
                    McRIDE_flag := false;
                END IF;
            END IF;

            IF (RMCM = '1' AND RMCMe = '1') OR (XMCM="11" AND RMCMe = '1') THEN
                IF RCERE_full(RWD_in_FR) ='1' THEN
                    McRIDE_flag := true;
                ELSE
                    McRIDE_flag := false;
                END IF;
            END IF;

            IF rising_edge(CLKR_int) OR rising_edge (XSLAVE_clk) THEN
                IF RSR_to_RBR = true THEN
                    IF RFULL_flag = true THEN
                        RFULL_RD <= '1', '0' after 10 ns;
                    ELSE
                        CASE RJUST IS
                            WHEN "00" =>
                                RBR0 <= (others => '0');
                                RBR0 (RWORD_numb(RPHASE_mark) - 1 downto 0)
                                <= RSR0 (RWORD_numb(RPHASE_mark) - 1 downto 0);
                            WHEN "01" =>
                                RBR0 <= (others => '1');
                                RBR0 (RWORD_numb(RPHASE_mark) - 1 downto 0)
                                <= RSR0 (RWORD_numb(RPHASE_mark)-1 downto 0);
                            WHEN "10" =>
                                RBR0 <= (others => '0');
                                RBR0 (31 downto 31 - RWORD_numb(RPHASE_mark)+1)
                                <= RSR0 (RWORD_numb(RPHASE_mark) - 1 downto 0);
                            WHEN others =>
                                null;
                        END CASE;
                    END IF;
                    IF RSECONDFR_flag =  true THEN
                        RPHASE_mark := 1;
                    END  IF;
                    IF RFLAG = true THEN
                        RPHASE_mark := 1;
                    END IF;
                    RSR_to_RBR := false;
                    RBR_to_DRR_flag := true;
                END IF;
            END IF;

            IF rising_edge(CLKR_int) THEN
                IF RSYNCERR_flag = true THEN
                    RSYNCERR_RD <= '1' , '0' after 20 ns;
                    RSYNCERR_flag := false;
                END IF;
            END IF;

            IF falling_edge(CLKR_int) OR falling_edge (XSLAVE_clk) THEN
                RPERIOD := NOW - RPREVIOUS;
                RPREVIOUS := NOW;
                IF (RCOUNT>0) THEN
                    IF (RDELAY = 0) THEN
                        IF (RMCM = '0' AND XMCM /= "11")
                           OR McRIDE_flag = true THEN
                            IF DLB = '0' THEN
                                RSR0 <= RSR0(30 downto 0) & DR0;
                            ELSE
                                RSR0 <= RSR0(30 downto 0) & DX0_zd;
                            END IF;
                            DX0_zd1 := DR0;
                            RWORD_cnt1:=RWORD_cnt1-1;
                            IF RWORD_cnt1=0 THEN
                                RWORD_cnt1 := RWORD_numb(RPHASE_mark);
                                RSR_to_RBR:=true;
                                RWD_in_FR := RWD_in_FR + 1;
                                RWORD_cnt2 := RWORD_cnt2  + 1;
                                IF RWORD_cnt2 = 16 THEN
                                    RWORD_cnt2 := 0;
                                END IF;
                            END IF;
                        END IF;
                        IF (RMCM = '1' OR XMCM = "11" )
                           AND McRIDE_flag = false THEN
                            RWORD_cnt1:=RWORD_cnt1 - 1;
                            IF RWORD_cnt1 = 0 THEN
                                RWORD_cnt1 := RWORD_numb(RPHASE_mark);
                                RWD_in_FR := RWD_in_FR + 1;
                                RWORD_cnt2 := RWORD_cnt2 + 1;
                                IF RWORD_cnt2 = 16 THEN
                                    RWORD_cnt2 := 0;
                                END IF;
                            END IF;
                        END IF;
                    ELSE
                        RDELAY := RDELAY - 1;
                        RCOUNT := RCOUNT + 1;
                    END IF;
                    RCOUNT := RCOUNT - 1;
                ELSE
                    RSTATE := inact;
                END IF;
            END IF;

            IF falling_edge(RRDY) AND RBR_to_DRR_flag = true THEN
                RRDY_flag := true;
            END IF;

            IF (falling_edge(CLKR_int) OR falling_edge(XSLAVE_clk))
               AND RRDY_flag = true THEN
                RRDY_flag := false;
                DRR0 <= RBR0;
                RRDY_RD <= '1', '0' after 20 ns;
                RBR_to_DRR_flag := false;
                RFULL_flag := false;
            END IF;

            IF (falling_edge(CLKR_int) OR falling_edge (XSLAVE_clk)) AND
               RBR_to_DRR_flag = true AND RRDY = '0' THEN
                DRR0 <= RBR0;
                IF RWORD_numb(XPHASE_mark) = 32 AND RINVERS_flag = true THEN
                    FOR i IN 0 TO 31 LOOP
                        DRR0(i) <= RBR0(31 - i);
                    END LOOP;
                END IF;
                RBR_to_DRR_flag := false;
                RRDY_RD <= '1' , '0' after 20 ns;
            END IF;

            IF (falling_edge(CLKR_int) OR falling_edge(XSLAVE_clk)) AND
               RBR_to_DRR_flag = true AND  RRDY = '1'  THEN
                RFULL_flag := true; -- za rful
            END IF;

            CASE RINTM is
                WHEN "00" =>
                    RINT <= RRDY;
                WHEN "01" =>
                    IF RWORD_cnt2 = 0 THEN
                       RINT <= '1' , '0' after 4 * RPERIOD;
                    END IF;
                WHEN "10" =>
                    RINT <= FSR_int;
                WHEN others =>
                    RINT <= RSYNCERR;
            END CASE;
        ELSE
            IF RESETNeg = '1' AND RIOEN = '1'THEN
                IF CLKRM = '0' THEN
                    CLKR0Out_zd := 'Z';
                ELSE
                    CLKR0Out_zd := CLKRP;
                END IF;
                IF FSRM = '0' THEN
                    FSR0Out_zd := 'Z';
                ELSE
                    CLKR0Out_zd := CLKRP;
                END IF;
            ELSE
                 FSR0Out_zd := 'Z';
                 CLKR0Out_zd := 'Z';
            END IF;
        END IF;

        ------------------------------------------------------------------------
           -- Path Delay Section
        ------------------------------------------------------------------------

        VitalPathDelay01 (
           OutSIGNAL       => CLKR_int,
           OutSIGNALName   => "CLKR_int",
           OutTemp         => CLKRINT_zd,
           GlitchData      => CLKRINT_GlitchData,
           XOn             => XOn,
           MsgOn           => MsgOn,
           Paths           => (
               0 => (InputChangeTIME   => CLKR0In'Last_Event,
                     PathDelay         => (0 ns, 0 ns ),
                     PathCondition     => RESETNeg = '1'AND CLKRM = '0'
                                                                AND DLB = '0'),
               1 => (InputChangeTIME   => CLKX0In'Last_Event,
                     PathDelay         => (0 ns, 0 ns ),
                     PathCondition     => RESETNeg = '1'AND CLKXM = '0'
                                                                AND DLB = '1'),
               2 => (InputChangeTIME   => CLKS0'Last_Event,
                     PathDelay         => (5 ns, 5 ns ),
                     PathCondition     => RESETNeg = '1' AND GRSTNeg = '1'
                                          AND CLKRM = '1' AND DLB = '0'),
               3 => (InputChangeTIME   =>  CLKS0'Last_Event ,
                      PathDelay         => (5 ns, 5 ns ),
                      PathCondition     => RESETNeg = '1' AND GRSTNeg = '1'
                                           AND CLKXM = '1' AND DLB = '1')
           )
        );

        VitalPathDelay01 (
            OutSIGNAL       => CLKX_int,
            OutSIGNALName   => "CLKX_int",
            OutTemp         => CLKXINT_zd,
            GlitchData      => CLKXINT_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTIME   => CLKX0In'Last_Event,
                      PathDelay         => (0 ns, 0 ns ),
                      PathCondition     => RESETNeg = '1'AND CLKXM = '0'),
                1 => (InputChangeTIME   => CLKS0'Last_Event ,
                      PathDelay         => (5 ns, 5 ns ),
                      PathCondition     => RESETNeg = '1' AND GRSTNeg = '1'
                                           AND CLKXM = '1')
            )
        );

        VitalPathDelay01 (
            OutSIGNAL       => FSR_int,
            OutSIGNALName   => "FSR_int",
            OutTemp         => FSRINT_zd,
            GlitchData      => FSRINT_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTIME   => FSR0In'Last_Event,
                      PathDelay         => (0 ns, 0 ns ),
                      PathCondition     => RESETNeg = '1' AND FSRM = '0'
                                                                AND DLB = '0'),
                1 => (InputChangeTIME   => FSX0In'Last_Event,
                      PathDelay         => (0 ns, 0 ns ),
                      PathCondition     => RESETNeg = '1'AND FSXM = '0'
                                                                AND DLB = '1'),
                2 => (InputChangeTIME   => CLKS0'Last_Event,
                      PathDelay         => (7 ns, 7 ns ),
                      PathCondition     => RESETNeg = '1' AND GRSTNeg = '1'
                                           AND FSRM = '1' AND DLB = '0')
            )
        );

        VitalPathDelay01 (
            OutSIGNAL       => FSX_int,
            OutSIGNALName   => "FSX_int",
            OutTemp         => FSXINT_zd,
            GlitchData      => FSXINT_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                 0 => (InputChangeTIME   => FSX0In'Last_Event,
                       PathDelay         => (0 ns, 0 ns ),
                       PathCondition     => RESETNeg = '1'AND FSXM = '0' ),
                 1 => (InputChangeTIME   => CLKS0'Last_Event,
                       PathDelay         => (7 ns, 7 ns ),
                       PathCondition     => RESETNeg = '1' AND GRSTNeg = '1'
                                            AND FSXM = '1' AND CLKXM = '1')
            )
       );

          VitalPathDelay01 (
            OutSIGNAL       => CLKR0Out,
            OutSIGNALName   => "CLKR0Out",
            OutTemp         => CLKR0Out_zd,
            GlitchData      => CLKR0Out_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                  0 => (InputChangeTIME   => CLKS0'Last_Event,
                        PathDelay         => tpd_CLKS_CLKR,
                        PathCondition     => RESETNeg = '1' AND GRSTNeg = '1'
                            AND CLKRM = '1' AND DLB = '0'AND RIOEN = '0'),
                  1 => (InputChangeTIME   => CLKS0'Last_Event,
                       PathDelay          => tpd_CLKS_CLKR,
                       PathCondition      => RESETNeg = '1' AND GRSTNeg = '1'
                                             AND CLKXM = '1' AND DLB ='1'
                                             AND XIOEN = '0')
            )
       );

          VitalPathDelay01 (
            OutSIGNAL       => CLKX0Out,
            OutSIGNALName   => "CLKXOut",
            OutTemp         => CLKX0Out_zd,
            GlitchData      => CLKX0Out_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTIME   => CLKS0'Last_Event,
                      PathDelay         => tpd_CLKS_CLKX,
                      PathCondition     => RESETNeg = '1' AND GRSTNeg = '1'
                            AND CLKXM = '1' AND XIOEN = '0' AND CLKSTP /= "11")
            )
       );

        VitalPathDelay01 (
            OutSIGNAL       => FSR0Out,
            OutSIGNALName   => "FSROut",
            OutTemp         => FSR0Out_zd,
            GlitchData      => FSR0Out_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                 0 => (InputChangeTIME   => CLKS0'Last_Event,
                       PathDelay         => (5 ns, 5 ns ),
                       PathCondition     => RESETNeg = '1' AND GRSTNeg = '1'
                                AND FSRM = '1' AND DLB='0' AND RIOEN = '0')
            )
       );

          VitalPathDelay01 (
            OutSIGNAL       => FSX0Out,
            OutSIGNALName   => "FSXOut",
            OutTemp         => FSX0Out_zd,
            GlitchData      => FSX0Out_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                 0 => (InputChangeTIME   => CLKS0'Last_Event,
                       PathDelay         => (5 ns, 5 ns ),
                       PathCondition     => RESETNeg = '1' AND GRSTNeg = '1'
                                            AND FSXM = '1'  AND XIOEN = '0')
            )
       );

    VitalPathDelay01Z (
           OutSIGNAL       => DX0,
           OutSIGNALName   => "DX0",
           OutTemp         => DX0_zd,
           GlitchData      => DX0_GlitchData,
           XOn             => XOn,
           MsgOn           => MsgOn,
           Paths           => (
                 0 => (InputChangeTIME   => CLKX_int'last_event,
                       PathDelay         => VitalExtendToFillDelay(5 ns),
                       PathCondition     => XRSTNeg = '1' AND RESETNeg = '1'
                                              AND CLKXM = '0' AND DXENA = '0'),
                 1 => (InputChangeTIME   => CLKX_int'last_event,
                       PathDelay         => VitalExtendToFillDelay(3 ns),
                       PathCondition     => XRSTNeg = '1' AND RESETNeg = '1'
                                            AND CLKXM = '1' AND DXENA = '0'),
                 2 => (InputChangeTIME   => FSX_int'last_event,
                       PathDelay         => VitalExtendToFillDelay(5 ns),
                       PathCondition     => XRSTNeg = '1' AND RESETNeg = '1'
                       AND xdel_fsr_flag = 1 AND DXENA = '0'AND FSXM = '0'),
                 3 =>  (InputChangeTIME  => FSX_int'last_event,
                       PathDelay         => VitalExtendToFillDelay(2 ns),
                       PathCondition     => XRSTNeg = '1' AND RESETNeg = '1'
                       AND  xdel_fsr_flag = 1 AND DXENA = '0' AND FSXM = '1'),
                 4 => (InputChangeTIME   => CLKX_int'last_event,
                       PathDelay         => (5 ns, 5 ns, 5 ns, 5 ns + 2*PERIOD,
                                                        5 ns, 5 ns + 2*PERIOD),
                       PathCondition     =>  XRSTNeg = '1' AND RESETNeg = '1'
                                              AND CLKXM = '0' AND DXENA = '1'),
                 5 => (InputChangeTIME   => CLKX_int'last_event,
                       PathDelay         => (5 ns, 5 ns, 5 ns, 5 ns + 2*PERIOD,
                                                        5 ns, 5 ns + 2*PERIOD),
                       PathCondition     => XRSTNeg = '1' AND RESETNeg = '1'
                                                AND CLKXM = '1' AND DXENA = '1')
           )
       );

    END PROCESS McBSP;

    EAPathDelay_Gen : FOR i IN EA'range GENERATE
        PROCESS(EA_zd(i))
            VARIABLE EA_GlitchData : VitalGlitchDataType;

        BEGIN
        VitalPathDelay01Z (
            OutSignal       => EA(i),
            OutSignalName   => "EA",
            OutTemp         => EA_zd(i),
            GlitchData      => EA_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_EA2,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );

        END PROCESS;

   END GENERATE EAPathDelay_Gen;

    EDPathDelay_Gen : FOR i IN EDOut'range GENERATE
        PROCESS(EDOut_zd(i))
            VARIABLE EDOut_GlitchData : VitalGlitchDataType;

        BEGIN
        VitalPathDelay01Z (
            OutSignal       => EDOut(i),
            OutSignalName   => "ED",
            OutTemp         => EDOut_zd(i),
            GlitchData      => EDOUT_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => ECLK_int'LAST_EVENT,
                      PathDelay         => tpd_ECLKIN_ED0,
                      PathCondition     => RESET_int = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD + 3 * EPERIOD),
                      PathCondition     => RESETNeg = '0'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (6 * PERIOD + 4 * EPERIOD),
                      PathCondition     => RESETNeg = '1')
            )
        );
        END PROCESS;
   END GENERATE EDPathDelay_Gen;

    HDPathDelay_Gen : FOR i IN HDOut'range GENERATE
        PROCESS(HDOut_zd(i))
            VARIABLE HDOut_GlitchData : VitalGlitchDataType;

        BEGIN
        VitalPathDelay01Z (
            OutSignal       => HDOut(i),
            OutSignalName   => "HD",
            OutTemp         => HDOut_zd(i),
            GlitchData      => HDOUT_GlitchData,
            XOn             => XOn,
            MsgOn           => MsgOn,
            Paths           => (
                0 => (InputChangeTime   => HSTROB_int'LAST_EVENT,
                      PathDelay         => tpd_HCSNeg_HD0,
                      PathCondition     => RESET_int = '1' AND
                                           HPI_EN = '1'),
                1 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD),
                      PathCondition     => RESETNeg = '0' AND
                                           HPI_EN = '1'),
                2 => (InputChangeTime   => RESETNeg'LAST_EVENT,
                      PathDelay         => VitalExtendToFillDelay
                                               (4 * PERIOD),
                      PathCondition     => RESETNeg = '1' AND
                                           HPI_EN = '1')
            )
        );
        END PROCESS;
   END GENERATE HDPathDelay_Gen;

    END BLOCK;
END vhdl_behavioral;
