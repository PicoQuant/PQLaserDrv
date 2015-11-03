//-----------------------------------------------------------------------------
//
//      Sepia2_Def.h
//
//-----------------------------------------------------------------------------
//
//  symbols used by SEPIA2_LIB
//
//-----------------------------------------------------------------------------
//  HISTORY:
//
//  apo  22.12.05   release of the library interface
//
//  apo  12.02.07   introduced SML Multilaser Module (V1.0.2.0)
//
//  apo  02.12.09   introduced SWM Pulsar Waveform Module (V1.0.2.1)
//                  changed SEPIA2OBJECT_SLT to 0x42
//
//  apo  24.02.14   raised library version number to 1.1.0.x (V1.1.0.293)
//
//  apo  25.02.14   now the version number identifies the configuration 
//                    x86 vs. x64 (V1.1.xx.294)
//
//-----------------------------------------------------------------------------
//

#ifndef   __SEPIA2_DEF_H__
  #define __SEPIA2_DEF_H__

  #ifdef _WIN64
    #define LIB_VERSION_REFERENCE                      "1.1.64.*" // this is the part to compare with, but ignore the asterisk
  #else
    #define LIB_VERSION_REFERENCE                      "1.1.32.*" // this is the part to compare with, but ignore the asterisk
  #endif

  #define LIB_VERSION_REFERENCE_COMPLEN                7

  #define FW_VERSION_REFERENCE                         "1.05"

  #ifndef   SEPIA2_MAX_USB_DEVICES
    #define SEPIA2_MAX_USB_DEVICES                     8
  #endif // SEPIA2_MAX_USB_DEVICES

  #define SEPIA2_SOM_BURSTCHANNEL_COUNT                8

  #define SEPIA2_RESTART                               1
  #define SEPIA2_NO_RESTART                            0

  #define SEPIA2_LASER_LOCKED                          1
  #define SEPIA2_LASER_UNLOCKED                        0

  #define SEPIA2_PRIMARY_MODULE                        1
  #define SEPIA2_SECONDARY_MODULE                      0

  #define SEPIA2_SLM_PULSE_MODE                        1
  #define SEPIA2_SLM_CW_MODE                           0

  #define SEPIA2_SML_PULSE_MODE                        1
  #define SEPIA2_SML_CW_MODE                           0

  #define SEPIA2_SOM_INVERSE_SYNC_MASK                 1
  #define SEPIA2_SOM_STANDARD_SYNC_MASK                0


  #define SEPIA2_USB_STRDECR_LEN                     256
  #define SEPIA2_VERSIONINFO_LEN                      11    // "1.1.xx.nnn\0" where xx is either 32 or 64 and nnn is the SVN build number
  #define SEPIA2_ERRSTRING_LEN                        64
  #ifndef SEPIA2_FW_ERRCOND_LEN
    #define SEPIA2_FW_ERRCOND_LEN                     55
  #endif
  #define SEPIA2_FW_ERRPHASE_LEN                      24
  #define SEPIA2_SERIALNUMBER_LEN                     13
  #define SEPIA2_PRODUCTMODEL_LEN                     33
  #define SEPIA2_MODULETYPESTRING_LEN                 55
  #define SEPIA2_SLM_FREQ_TRIGMODE_LEN                28
  #define SEPIA2_SLM_HEADTYPE_LEN                     18
  #define SEPIA2_SOM_FREQ_TRIGMODE_LEN                32
  #define SEPIA2_SWS_MODULETYPE_MAXLEN                20
  #define SEPIA2_SWS_MODULESTATE_MAXLEN               20
  //
  //                                                         //              bit  7         6         5     4    3      2..0
  //      SepiaObjTyp                                        //                   L module  secondary            S
  //           -                                             //                   /         /         laser osc  /      typecnt
  //   construction table                                    //                   H backpl  primary              L or F
  //
  #define SEPIA2OBJECT_FRMS                            0xC0  // 1 1 00  0 000     backplane primary   no    no   small
  #define SEPIA2OBJECT_FRML                            0xC8  // 1 1 00  1 000     backplane primary   no    no   large
  #define SEPIA2OBJECT_FRXS                            0x80  // 1 0 00  0 000     backplane secondary no    no   small
  #define SEPIA2OBJECT_FRXL                            0x88  // 1 0 00  1 000     backplane secondary no    no   large
  #define SEPIA2OBJECT_SCM                             0x40  // 0 1 00  0 000     module    primary   no    no   d.c.          // for Sepia II Controller Modules
  #define SEPIA2OBJECT_SCX                             0x41  // 0 1 00  0 001     module    primary   no    no   d.c.          // for simulation
  #define SEPIA2OBJECT_SLT                             0x42  // 0 1 00  0 010     module    primary   no    no   d.c.          // for test
  #define SEPIA2OBJECT_SWM                             0x43  // 0 1 00  0 011     module    primary   no    no   d.c.          // for PULSAR Waveform Modules
  #define SEPIA2OBJECT_SWS                             0x44  // 0 1 00  0 100     module    primary   no    no   d.c.          // for Solea  Wavelength Selectors
  #define SEPIA2OBJECT_SPM                             0x45  // 0 1 00  0 101     module    primary   no    no   d.c.          // for Solea  Pumpcontrol Modules
  #define SEPIA2OBJECT_LMP                             0x46  // 0 1 00  0 110     module    primary   no    no   d.c.          // Laser test site
  #define SEPIA2OBJECT_SOM                             0x50  // 0 1 01  0 000     module    primary   no    yes  d.c.   0-7    // for Sepia II Oscillator Modules
  #define SEPIA2OBJECT_SOMD                            0x51  // 0 1 01  0 001     module    primary   no    yes  d.c.   0-7    // for Sepia II Oscillator Modules with Delay
  #define SEPIA2OBJECT_SML                             0x60  // 0 1 10  0 000     module    primary   yes   no   d.c.   0-7    // for Sepia II Multi Laser Modules
  #define SEPIA2OBJECT_SLM                             0x70  // 0 1 11  0 000     module    primary   yes   yes  d.c.          // for Sepia II Laser Modules
  #define SEPIA2OBJECT_SSM                             0x71  // 0 1 11  0 001     module    primary   yes   yes  d.c.          // for Solea  Seed Modules
  #define SEPIA2OBJECT_LHS                             0x20  // 0 0 10  0 000     module    secondary yes   no   slow   0-7
  #define SEPIA2OBJECT_LHF                             0x28  // 0 0 10  1 000     module    secondary yes   no   fast
  #define SEPIA2OBJECT_LH_                             0x29  // 0 0 10  1 001     module    secondary yes   no   fast
  #define SEPIA2OBJECT_FAIL                            0xFF

  #define SEPIA2_SLM_FREQ_80MHZ                        0
  #define SEPIA2_SLM_FREQ_40MHZ                        1
  #define SEPIA2_SLM_FREQ_20MHZ                        2
  #define SEPIA2_SLM_FREQ_10MHZ                        3
  #define SEPIA2_SLM_FREQ_5MHZ                         4
  #define SEPIA2_SLM_FREQ_2_5MHZ                       5
  #define SEPIA2_SLM_TRIGMODE_RAISING                  6
  #define SEPIA2_SLM_TRIGMODE_FALLING                  7
  #define SEPIA2_SLM_FREQ_TRIGMODE_COUNT               8


  #define SEPIA2_SLM_HEADTYPE_FAILURE                  0
  #define SEPIA2_SLM_HEADTYPE_LED                      1
  #define SEPIA2_SLM_HEADTYPE_LASER                    2
  #define SEPIA2_SLM_HEADTYPE_NONE                     3
  #define SEPIA2_SLM_HEADTYPE_COUNT                    4


  #define SEPIA2_SML_HEADTYPE_FAILURE                  0
  #define SEPIA2_SML_HEADTYPE_4_LEDS                   1
  #define SEPIA2_SML_HEADTYPE_4_LASERS                 2
  #define SEPIA2_SML_HEADTYPE_COUNT                    3


  #ifndef SEPIA2_SOM_TRIGGERLEVEL_STEP
    #define SEPIA2_SOM_TRIGGERLEVEL_STEP              20 // in mV
    #define SEPIA2_SOM_TRIGGERLEVEL_HALFSTEP           (SEPIA2_SOM_TRIGGERLEVEL_STEP / 2)
  #endif
  #define SEPIA2_SOM_TRIGMODE_RAISING                  0
  #define SEPIA2_SOM_TRIGMODE_FALLING                  1
  #define SEPIA2_SOM_INT_OSC_A                         2
  #define SEPIA2_SOM_INT_OSC_B                         3
  #define SEPIA2_SOM_INT_OSC_C                         4
  #define SEPIA2_SOM_FREQ_TRIGMODE_COUNT               5

  #define SEPIA2_SWM_CURVES_COUNT                      2
  #define SEPIA2_SWM_TIMEBASE_RANGES_COUNT             3
  //
  #define SEPIA2_SWM_UI_TABIDX_RESOLUTION              0
  #define SEPIA2_SWM_UI_TABIDX_MIN_USERVALUE           1
  #define SEPIA2_SWM_UI_TABIDX_MAX_USERVALUE           2
  #define SEPIA2_SWM_UI_TABIDX_USER_RESOLUTION         3
  #define SEPIA2_SWM_UI_TABIDX_MAX_AMPLITUDE           4
  #define SEPIA2_SWM_UI_TABIDX_MAX_SLEWRATE            5
  #define SEPIA2_SWM_UI_TABIDX_EXP_RAMP_EFFECT         6
  #define SEPIA2_SWM_UI_TABIDX_TIMEBASERANGES_COUNT    7
  #define SEPIA2_SWM_UI_TABIDX_PULSEDATA_COUNT         8
  #define SEPIA2_SWM_UI_TABIDX_RAMPDATA_COUNT          9
  #define SEPIA2_SWM_UI_TABIDX_DELAYDATA_TB0_COUNT    10
  #define SEPIA2_SWM_UI_TABIDX_DELAYDATA_TB1_COUNT    11
  #define SEPIA2_SWM_UI_TABIDX_DELAYDATA_TB2_COUNT    12

  typedef union {
    unsigned long   ul;
    struct {
      unsigned short  BuildNr;
      byte            VersMin;
      byte            VersMaj;
      }               v;
  } T_Module_FWVers;
  typedef T_Module_FWVers* T_ptrModule_FWVersion;

  #ifndef _SPM_TYPES_DEFINED_
    #define _SPM_TYPES_DEFINED_

    #define SEPIA2_SPM_PUMPCTRLFUNC_SAMPLECOUNT        6
    #define SEPIA2_SPM_TEMPERATURE_SENSORCOUNT         6
    #define SEPIA2_SPM_UPTIME_POWERCLASSES            10

    typedef union {
      struct {
        word wFreqADC  [SEPIA2_SPM_PUMPCTRLFUNC_SAMPLECOUNT];
        word wPump1Cur [SEPIA2_SPM_PUMPCTRLFUNC_SAMPLECOUNT];
        word wPump2Cur [SEPIA2_SPM_PUMPCTRLFUNC_SAMPLECOUNT];
        word wPump3Cur [SEPIA2_SPM_PUMPCTRLFUNC_SAMPLECOUNT];
      } p;
      word wArr [4 * SEPIA2_SPM_PUMPCTRLFUNC_SAMPLECOUNT];
    } T_SPM_PumpCtrlParams;
    typedef T_SPM_PumpCtrlParams* T_ptrSPM_PumpCtrlParams;

    typedef union {
      word wT [SEPIA2_SPM_TEMPERATURE_SENSORCOUNT];
      struct {
        word wT_Pump1;
        word wT_Pump2;
        word wT_Pump3;
        word wT_Pump4;
        word wT_FiberStack;
        word wT_AuxAdjust;
      } Temperatures;
    } T_SPM_Temperatures;
    typedef T_SPM_Temperatures* T_ptrSPM_Temperatures;

    typedef union {
      dword dwUT [SEPIA2_SPM_UPTIME_POWERCLASSES];
      struct {
        dword dwUT_01;
        dword dwUT_02;
        dword dwUT_03;
        dword dwUT_04;
        dword dwUT_05;
        dword dwUT_06;
        dword dwUT_07;
        dword dwUT_08;
        dword dwUT_09;
        dword dwUT_10;
      } UpTimeTable;
    } T_SPM_UpTimePowerTable;
    typedef T_SPM_UpTimePowerTable* T_ptrSPM_UpTimePowerTable;

    typedef struct {
      T_SPM_Temperatures Temperatures;
      word               wOverAllCurrent;
      word               wOptionalSensor1;
      word               wOptionalSensor2;
    } T_SPM_SensorData;
    typedef T_SPM_SensorData* T_ptrSPM_SensorData;

  #endif // _SPM_TYPES_DEFINED_

  #ifndef _SCM_TYPES_DEFINED_
    #define _SCM_TYPES_DEFINED_

    #define   SEPIA2_SCM_VOLTAGE_5V_POSITIVE_POWERSUPPLY   0
    #define   SEPIA2_SCM_VOLTAGE_5V_NEGATIVE_POWERSUPPLY   1
    #define   SEPIA2_SCM_VOLTAGE_5V_POSITIVE_ON_BUS        2
    #define   SEPIA2_SCM_VOLTAGE_5V_NEGATIVE_ON_BUS        3
    #define   SEPIA2_SCM_VOLTAGE_28V_POSITIVE_POWERSUPPLY  4
    #define   SEPIA2_SCM_VOLTAGE_28V_POSITIVE_ON_BUS       5
    #define   SEPIA2_SCM_VOLTAGE_28V_POSITIVE_BEHIND_FUSE  6
    //
    #define   MAX_VOLTAGES                                 8
    #define   ACT_VOLTAGES                                 7

    #define   SEPIA2_SCM_VOLTAGE_EMPTY_READ                0xFFFFu
    #define   SEPIA2_SCM_VOLTAGE_VALUE_MASK                0xFFF0u
    #define   SEPIA2_SCM_VOLTAGE_28V_OFF_MAXIMUM_READ      0x1180u  // 2,97 V   // 0x0920u   // 1,55 V
    #define   SEPIA2_SCM_VOLTAGE_NOISY_BITS                2
    #define   SEPIA2_SCM_VOLTAGE_INPNAME_MAXLEN            20


    typedef struct {// T_VoltageRanges
      word  wADCControl  [MAX_VOLTAGES];
      word  wMinVoltage  [MAX_VOLTAGES];
      word  wMaxVoltage  [MAX_VOLTAGES];
      float fADCScale    [MAX_VOLTAGES];
      float fADCOffset   [MAX_VOLTAGES];
      byte  bIsBipolar   [MAX_VOLTAGES];
      char  cADCInpNam   [MAX_VOLTAGES][SEPIA2_SCM_VOLTAGE_INPNAME_MAXLEN];
    } T_VoltageRanges;
    typedef T_VoltageRanges* T_ptrVoltageRanges;

  #endif // _SCM_TYPES_DEFINED_

  #ifndef _SWS_TYPES_DEFINED_
    #define _SWS_TYPES_DEFINED_

    typedef struct {
      short           iMaxVelocity;     // [탎teps/s]
      short           iMinVelocity;     // [탎teps/s]
      short           iStandByCur;      // [mA]
      short           iActiveCur;       // [mA]
      short           iDefaultPos;      // [탎teps]
      short           iUpperPos;        // [탎teps] may be > iPosCount
      short           iLowerPos;        // [탎teps] may be < 0 
      short           iIndexSearchDir;  // 0 = forward; else = backward
      short           iPosCount;        // [탎teps], i.e. <iStepsCount> * <iStepMode>
      short           iStepMode;        // (1, 2, 4, 8)
    } T_SWS_MotorData;
    typedef T_SWS_MotorData* T_ptrSWS_MotorData;

    typedef union {
      T_SWS_MotorData md;
      short           data [ sizeof(T_SWS_MotorData) / sizeof(short) ];
    } T_SWS_AbstractMotorData;
    typedef T_SWS_AbstractMotorData* T_ptrSWS_AbstractMotorData;

    typedef struct {
      byte            ModuleID;
      byte            MotorNr;
      short           MotorPos;
    } T_SWS_MotorPos;
    typedef T_SWS_MotorPos* T_ptrSWS_MotorPos;

    typedef struct {
      T_SWS_MotorPos  SledgePos;        // [ModId, MotNr, 탎teps] sledge module, motor; and filter position on sledge
      long            WL_MinUpperValue; // [pm]
      long            WL_MaxUpperValue; // [pm]
      long            WL_MinLowerValue; // [pm]
      long            WL_MaxLowerValue; // [pm]
    } T_SWS_FilterDscr;
    typedef T_SWS_FilterDscr* T_ptrSWS_FilterDscr;

    typedef struct {
      double          dfA6;
      double          dfA5;
      double          dfA4;
      double          dfA3;
      double          dfA2;
      double          dfA1;
      double          dfA0;
    } T_SWS_FltParams;

    typedef union {
      double          dfAi [sizeof(T_SWS_FltParams) / sizeof(double)]; // polynomial approximation parameter array
      qword           qwAi [sizeof(T_SWS_FltParams) / sizeof(qword)];  // helper for swapping
      T_SWS_FltParams sfp;
    } T_SWS_FilterData;
    typedef T_SWS_FilterData* T_ptrSWS_FilterData;

    typedef struct {
      T_SWS_FilterDscr fdscr;
      T_SWS_FilterData fdata_u;
      T_SWS_FilterData fdata_l;
    } T_SWS_Filter;
    typedef T_SWS_Filter* T_ptrSWS_Filter;

  #endif // _SWS_TYPES_DEFINED_

#endif // __SEPIA2_DEF_H__
