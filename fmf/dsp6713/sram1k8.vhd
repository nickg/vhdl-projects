--------------------------------------------------------------------------------
--  File Name: sram1k8.vhd
--------------------------------------------------------------------------------
--  Copyright (C) 1998, 1999 Free Model Foundry
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License version 2 as
--  published by the Free Software Foundation.
--
--  MODIFICATION HISTORY:
--
--  version: |  author:  | mod date: | changes made:
--    V1.0     R. Steele   98 SEP 12   Initial release
--    V1.1     R. Munden   99 JAN 14   fixed bug in timingchecks
--
--------------------------------------------------------------------------------
--  PART DESCRIPTION:
--
--  Library:     MEM
--  Technology:  not ECL
--  Part:        SRAM1K8
--
--  Description: 1K X 8 SRAM
--------------------------------------------------------------------------------
LIBRARY IEEE;   USE IEEE.std_logic_1164.ALL;
                USE IEEE.vital_timing.ALL;
                USE IEEE.vital_primitives.ALL;

LIBRARY FMF;    USE FMF.gen_utils.ALL;
                USE FMF.conversions.ALL;
                USE WORK.conpack.all;

--------------------------------------------------------------------------------
-- ENTITY DECLARATION
--------------------------------------------------------------------------------
ENTITY sram1k8 IS
    GENERIC (
        -- tipd delays: interconnect path delays
        tipd_OENeg          : VitalDelayType01 := VitalZeroDelay01;
        tipd_WENeg          : VitalDelayType01 := VitalZeroDelay01;
        tipd_CENeg          : VitalDelayType01 := VitalZeroDelay01;
        tipd_CE             : VitalDelayType01 := VitalZeroDelay01;
        tipd_D0             : VitalDelayType01 := VitalZeroDelay01;
        tipd_D1             : VitalDelayType01 := VitalZeroDelay01;
        tipd_D2             : VitalDelayType01 := VitalZeroDelay01;
        tipd_D3             : VitalDelayType01 := VitalZeroDelay01;
        tipd_D4             : VitalDelayType01 := VitalZeroDelay01;
        tipd_D5             : VitalDelayType01 := VitalZeroDelay01;
        tipd_D6             : VitalDelayType01 := VitalZeroDelay01;
        tipd_D7             : VitalDelayType01 := VitalZeroDelay01;
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
    ATTRIBUTE VITAL_LEVEL0 of sram1k8 : ENTITY IS TRUE;
END sram1k8;

--------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
--------------------------------------------------------------------------------
ARCHITECTURE vhdl_behavioral of sram1k8 IS
    ATTRIBUTE VITAL_LEVEL0 of vhdl_behavioral : ARCHITECTURE IS TRUE;

    ----------------------------------------------------------------------------
    -- Note that this style of model departs significantly from the original
    -- intent of the VITAL spec.  The timing checks section does not generate
    -- any 'X' values for output results since the array only stores integer
    -- values.  So, to check for timing errors one will have to monitor the
    -- warning messages closely.  Also, the path delay procedures are included
    -- in their own processes which are generated as a function of data width.
    -- This method together with the behavior block aids in reducing coding
    -- by converting the address bus and data bus to vectors.  Scalars on the
    -- input ports is necessary for backannotation of wire delays.
    ----------------------------------------------------------------------------

    CONSTANT partID         : STRING := "SRAM 1K X 8";
    CONSTANT MaxData        : NATURAL := 255;
    CONSTANT TotalLOC       : NATURAL := 1023;
    CONSTANT HiAbit         : NATURAL := 9;
    CONSTANT HiDbit         : NATURAL := 7;
    CONSTANT DataWidth      : NATURAL := 8;

    SIGNAL D0_ipd           : std_ulogic := 'X';
    SIGNAL D1_ipd           : std_ulogic := 'X';
    SIGNAL D2_ipd           : std_ulogic := 'X';
    SIGNAL D3_ipd           : std_ulogic := 'X';
    SIGNAL D4_ipd           : std_ulogic := 'X';
    SIGNAL D5_ipd           : std_ulogic := 'X';
    SIGNAL D6_ipd           : std_ulogic := 'X';
    SIGNAL D7_ipd           : std_ulogic := 'X';

    SIGNAL A0_ipd           : std_ulogic := 'X';
    SIGNAL A1_ipd           : std_ulogic := 'X';
    SIGNAL A2_ipd           : std_ulogic := 'X';
    SIGNAL A3_ipd           : std_ulogic := 'X';
    SIGNAL A4_ipd           : std_ulogic := 'X';
    SIGNAL A5_ipd           : std_ulogic := 'X';
    SIGNAL A6_ipd           : std_ulogic := 'X';
    SIGNAL A7_ipd           : std_ulogic := 'X';
    SIGNAL A8_ipd           : std_ulogic := 'X';
    SIGNAL A9_ipd           : std_ulogic := 'X';

    SIGNAL OENeg_ipd        : std_ulogic := 'X';
    SIGNAL WENeg_ipd        : std_ulogic := 'X';
    SIGNAL CENeg_ipd        : std_ulogic := 'X';
    SIGNAL CE_ipd           : std_ulogic := 'X';


BEGIN
    ----------------------------------------------------------------------------
    -- Wire Delays
    ----------------------------------------------------------------------------
    WireDelay : BLOCK
    BEGIN

        w_1: VitalWireDelay (OENeg_ipd, OENeg, tipd_OENeg);
        w_2: VitalWireDelay (WENeg_ipd, WENeg, tipd_WENeg);
        w_3: VitalWireDelay (CENeg_ipd, CENeg, tipd_CENeg);
        w_4: VitalWireDelay (CE_ipd, CE, tipd_CE);
        w_5: VitalWireDelay (D0_ipd, D0, tipd_D0);
        w_6: VitalWireDelay (D1_ipd, D1, tipd_D1);
        w_7: VitalWireDelay (D2_ipd, D2, tipd_D2);
        w_8: VitalWireDelay (D3_ipd, D3, tipd_D3);
        w_9: VitalWireDelay (D4_ipd, D4, tipd_D4);
        w_10: VitalWireDelay (D5_ipd, D5, tipd_D5);
        w_11: VitalWireDelay (D6_ipd, D6, tipd_D6);
        w_12: VitalWireDelay (D7_ipd, D7, tipd_D7);
        w_13: VitalWireDelay (A0_ipd, A0, tipd_A0);
        w_14: VitalWireDelay (A1_ipd, A1, tipd_A1);
        w_15: VitalWireDelay (A2_ipd, A2, tipd_A2);
        w_16: VitalWireDelay (A3_ipd, A3, tipd_A3);
        w_17: VitalWireDelay (A4_ipd, A4, tipd_A4);
        w_18: VitalWireDelay (A5_ipd, A5, tipd_A5);
        w_19: VitalWireDelay (A6_ipd, A6, tipd_A6);
        w_20: VitalWireDelay (A7_ipd, A7, tipd_A7);
        w_21: VitalWireDelay (A8_ipd, A8, tipd_A8);
        w_22: VitalWireDelay (A9_ipd, A9, tipd_A9);

    END BLOCK;

    ----------------------------------------------------------------------------
    -- Main Behavior Block
    ----------------------------------------------------------------------------
    Behavior: BLOCK

        PORT (
            AddressIn       : IN    std_logic_vector(HiAbit downto 0);
            DataIn          : IN    std_logic_vector(HiDbit downto 0);
            DataOut         : OUT   std_logic_vector(HiDbit downto 0);
            OENegIn         : IN    std_ulogic := 'X';
            WENegIn         : IN    std_ulogic := 'X';
            CENegIn         : IN    std_ulogic := 'X';
            CEIn            : IN    std_ulogic := 'X'
        );
        PORT MAP (
            DataOut(0) =>  D0,
            DataOut(1) =>  D1,
            DataOut(2) =>  D2,
            DataOut(3) =>  D3,
            DataOut(4) =>  D4,
            DataOut(5) =>  D5,
            DataOut(6) =>  D6,
            DataOut(7) =>  D7,
            DataIn(0) =>  D0_ipd,
            DataIn(1) =>  D1_ipd,
            DataIn(2) =>  D2_ipd,
            DataIn(3) =>  D3_ipd,
            DataIn(4) =>  D4_ipd,
            DataIn(5) =>  D5_ipd,
            DataIn(6) =>  D6_ipd,
            DataIn(7) =>  D7_ipd,
            AddressIn(0) => A0_ipd,
            AddressIn(1) => A1_ipd,
            AddressIn(2) => A2_ipd,
            AddressIn(3) => A3_ipd,
            AddressIn(4) => A4_ipd,
            AddressIn(5) => A5_ipd,
            AddressIn(6) => A6_ipd,
            AddressIn(7) => A7_ipd,
            AddressIn(8) => A8_ipd,
            AddressIn(9) => A9_ipd,
            OENegIn => OENeg_ipd,
            WENegIn => WENeg_ipd,
            CENegIn => CENeg_ipd,
            CEIn    => CE_ipd
--          CEIn    => OPEN
        );

        SIGNAL D_zd     : std_logic_vector(HiDbit DOWNTO 0);

    BEGIN
        ------------------------------------------------------------------------
        -- Behavior Process
        ------------------------------------------------------------------------
        Behavior : PROCESS (OENegIn, WENegIn, CENegIn, CEIn, AddressIn, DataIn)

            -- Timing Check Variables
            VARIABLE Tviol_D0_WENeg: X01 := '0';
            VARIABLE TD_D0_WENeg   : VitalTimingDataType;

            VARIABLE Tviol_D0_CENeg: X01 := '0';
            VARIABLE TD_D0_CENeg   : VitalTimingDataType;

            VARIABLE Pviol_WENeg   : X01 := '0';
            VARIABLE PD_WENeg      : VitalPeriodDataType := VitalPeriodDataInit;

            -- Memory array declaration
            TYPE MemStore IS ARRAY (0 to TotalLOC) OF NATURAL
                             RANGE  0 TO MaxData;

            -- Functionality Results Variables
            VARIABLE Violation  : X01 := '0';
            VARIABLE DataDrive  : std_logic_vector(HiDbit DOWNTO 0)
                                   := (OTHERS => 'X');
            VARIABLE DataTemp   : NATURAL RANGE 0 TO MaxData  := 0;
            VARIABLE Location   : NATURAL RANGE 0 TO TotalLOC := 0;
            VARIABLE MemData    : const := constarray;

            -- No Weak Values Variables
            VARIABLE OENeg_nwv   : UX01 := 'X';
            VARIABLE WENeg_nwv   : UX01 := 'X';
            VARIABLE CENeg_nwv   : UX01 := 'X';
            VARIABLE CE_nwv      : UX01 := 'X';

        BEGIN
            OENeg_nwv   := To_UX01 (s => OENegIn);
            WENeg_nwv   := To_UX01 (s => WENegIn);
            CENeg_nwv   := To_UX01 (s => CENegIn);
            CE_nwv      := To_UX01 (s => CEIn);
--          CE_nwv      := '1';

            --------------------------------------------------------------------
            -- Timing Check Section
            --------------------------------------------------------------------
            IF (TimingChecksOn) THEN

                VitalSetupHoldCheck (
                    TestSignal      => DataIn,
                    TestSignalName  => "Data",
                    RefSignal       => WENeg,
                    RefSignalName   => "WENeg",
                    SetupHigh       => tsetup_D0_WENeg,
                    SetupLow        => tsetup_D0_WENeg,
                    HoldHigh        => thold_D0_WENeg,
                    HoldLow         => thold_D0_WENeg,
                    CheckEnabled    => (CENeg ='0' and CE ='1'and OENeg ='1'),
                    RefTransition   => '/',
                    HeaderMsg       => InstancePath & PartID,
                    TimingData      => TD_D0_WENeg,
                    XOn             => XOn,
                    MsgOn           => MsgOn,
                    Violation       => Tviol_D0_WENeg );

                VitalSetupHoldCheck (
                    TestSignal      => DataIn,
                    TestSignalName  => "Data",
                    RefSignal       => CENeg,
                    RefSignalName   => "CENeg",
                    SetupHigh       => tsetup_D0_CENeg,
                    SetupLow        => tsetup_D0_CENeg,
                    HoldHigh        => thold_D0_CENeg,
                    HoldLow         => thold_D0_CENeg,
                    CheckEnabled    => (WENeg ='0' and OENeg ='1'),
                    RefTransition   => '/',
                    HeaderMsg       => InstancePath & PartID,
                    TimingData      => TD_D0_CENeg,
                    XOn             => XOn,
                    MsgOn           => MsgOn,
                    Violation       => Tviol_D0_CENeg );


                VitalPeriodPulseCheck (
                    TestSignal      =>  WENegIn,
                    TestSignalName  =>  "WENeg",
                    PulseWidthLow   =>  tpw_WENeg_negedge,
                    PeriodData      =>  PD_WENeg,
                    XOn             =>  XOn,
                    MsgOn           =>  MsgOn,
                    Violation       =>  Pviol_WENeg,
                    HeaderMsg       =>  InstancePath & PartID,
                    CheckEnabled    =>  TRUE );

                Violation := Pviol_WENeg OR Tviol_D0_WENeg OR Tviol_D0_CENeg;

                ASSERT Violation = '0'
                    REPORT InstancePath & partID & ": simulation may be" &
                           " inaccurate due to timing violations"
                    SEVERITY SeverityMode;

            END IF; -- Timing Check Section

            --------------------------------------------------------------------
            -- Functional Section
            --------------------------------------------------------------------
            DataDrive := (OTHERS => 'Z');

            IF (CE_nwv = '1' AND CENeg_nwv = '0') THEN
                IF (OENeg_nwv = '0' OR WENeg_nwv = '0') THEN

                    Location := To_Nat(AddressIn);

                    IF (OENeg_nwv = '0' AND WENeg_nwv = '1') THEN
                        DataTemp  := MemData(Location);
                        DataDrive := To_slv(DataTemp, DataWidth);
                    ELSE
                        DataTemp := To_Nat(DataIn);
                        MemData(Location) := DataTemp;
                    END IF;
                END IF;
            END IF;

            --------------------------------------------------------------------
            -- Output Section
            --------------------------------------------------------------------
            D_zd <= DataDrive;

        END PROCESS;

        ------------------------------------------------------------------------
        -- Path Delay Processes generated as a function of data width
        ------------------------------------------------------------------------
        DataOut_Width : FOR i IN HiDbit DOWNTO 0 GENERATE
            DataOut_Delay : PROCESS (D_zd(i))
                VARIABLE D_GlitchData:VitalGlitchDataArrayType(HiDbit Downto 0);
            BEGIN
                VitalPathDelay01Z (
                    OutSignal       => DataOut(i),
                    OutSignalName   => "Data",
                    OutTemp         => D_zd(i),
                    Mode            => OnEvent,
                    GlitchData      => D_GlitchData(i),
                    Paths           => (
                        0 => (InputChangeTime => OENeg_ipd'LAST_EVENT,
                              PathDelay       => tpd_OENeg_D0,
                              PathCondition   => TRUE),
                        1 => (InputChangeTime => CENeg_ipd'LAST_EVENT,
                              PathDelay       => tpd_CENeg_D0,
                              PathCondition   => TRUE),
                        2 => (InputChangeTime => AddressIn(0)'LAST_EVENT,
                              PathDelay => VitalExtendToFillDelay(tpd_A0_D0),
                              PathCondition   => TRUE),
                        3 => (InputChangeTime => AddressIn(1)'LAST_EVENT,
                              PathDelay => VitalExtendToFillDelay(tpd_A0_D0),
                              PathCondition   => TRUE),
                        4 => (InputChangeTime => AddressIn(2)'LAST_EVENT,
                              PathDelay => VitalExtendToFillDelay(tpd_A0_D0),
                              PathCondition   => TRUE),
                        5 => (InputChangeTime => AddressIn(3)'LAST_EVENT,
                              PathDelay => VitalExtendToFillDelay(tpd_A0_D0),
                              PathCondition   => TRUE),
                        6 => (InputChangeTime => AddressIn(4)'LAST_EVENT,
                              PathDelay => VitalExtendToFillDelay(tpd_A0_D0),
                              PathCondition   => TRUE),
                        7 => (InputChangeTime => AddressIn(5)'LAST_EVENT,
                              PathDelay => VitalExtendToFillDelay(tpd_A0_D0),
                              PathCondition   => TRUE),
                        8 => (InputChangeTime => AddressIn(6)'LAST_EVENT,
                              PathDelay => VitalExtendToFillDelay(tpd_A0_D0),
                              PathCondition   => TRUE),
                        9 => (InputChangeTime => AddressIn(7)'LAST_EVENT,
                              PathDelay => VitalExtendToFillDelay(tpd_A0_D0),
                              PathCondition   => TRUE),
                       10 => (InputChangeTime => AddressIn(8)'LAST_EVENT,
                              PathDelay => VitalExtendToFillDelay(tpd_A0_D0),
                              PathCondition   => TRUE),
                       11 => (InputChangeTime => AddressIn(9)'LAST_EVENT,
                              PathDelay => VitalExtendToFillDelay(tpd_A0_D0),
                              PathCondition   => TRUE)
                    )
                );

            END PROCESS;
        END GENERATE;

    END BLOCK;
END vhdl_behavioral;
