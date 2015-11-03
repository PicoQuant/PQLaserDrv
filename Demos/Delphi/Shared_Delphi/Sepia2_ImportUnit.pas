//-----------------------------------------------------------------------------
//
//      Sepia2_ImportUnit.pas
//
//-----------------------------------------------------------------------------
//
//  Exports the Sepia 2  functions from Sepia2_lib.dll  V1.1.<xx>.<nnn>
//    <xx>  = 32: Sepia2_Lib for x86 target architecture;
//    <xx>  = 64: Sepia2_Lib for x64 target architecture;
//    <nnn> = SVN build number
//
//-----------------------------------------------------------------------------
//  HISTORY:
//
//  apo  26.01.06   derived from Sepia2_lib.dll
//
//  apo  12.02.07   introduced SML Multilaser Module (V1.0.2.0)
//
//  apo  02.12.09   introduced SWM Pulsar Waveform Module (V1.0.2.1)
//
//  apo  12.10.12   introduced Solea SSM seed-laser module,
//                    Solea SWS wavelength selector module (V1.0.3.x)
//
//  apo  12.06.13   introduced Solea SPM pump control module (V1.0.3.x)
//
//  apo  03.01.14   additional error codes for Solea SWS Module (V1.0.3.x)
//
//  apo  26.02.14   raised library version to 1.1 due to API changes
//                    on the device open interfaces
//                    (new parameter strProductModel)
//                  encoded bitwidth of target architecture into
//                    version field 'MinorHighWord', e.g.:
//                    V1.1.32.293 or V1.1.64.293, respectively
//
//  apo  08.07.14   additional error codes for SOMD Module (V1.1.xx.336)
//
//-----------------------------------------------------------------------------
//

unit Sepia2_ImportUnit;

interface

  const
    STR_LIB_NAME                                = 'Sepia2_Lib.dll';

    {$ifdef __x64__}
      LIB_VERSION_REFERENCE                     = '1.1.64.';       // minor low word (SVN-build) may be ignored
    {$else}
      LIB_VERSION_REFERENCE                     = '1.1.32.';       // minor low word (SVN-build) may be ignored
    {$endif}
    LIB_VERSION_COMPLEN                         =     7;

    FW_VERSION_REFERENCE                        = '1.05';

    MILLISECONDS_PER_DAY                        =  86400000;

    SEPIA2_MAX_USB_DEVICES                      =     8;

    SEPIA2_SCM_MAX_VOLTAGES                     =     8;
    SEPIA2_SCM_VOLTAGE_5V_POSITIVE_POWERSUPPLY  =     0;
    SEPIA2_SCM_VOLTAGE_5V_NEGATIVE_POWERSUPPLY  =     1;
    SEPIA2_SCM_VOLTAGE_5V_POSITIVE_ON_BUS       =     2;
    SEPIA2_SCM_VOLTAGE_5V_NEGATIVE_ON_BUS       =     3;
    SEPIA2_SCM_VOLTAGE_28V_POSITIVE_POWERSUPPLY =     4;
    SEPIA2_SCM_VOLTAGE_28V_POSITIVE_ON_BUS      =     5;
    SEPIA2_SCM_VOLTAGE_28V_POSITIVE_BEHIND_FUSE =     6;
    SEPIA2_SCM_VOLTAGE_28V_OFF_MAXIMUM_READ     =     2.97;

    SEPIA2_RESTART                              =     true;
    SEPIA2_NO_RESTART                           =     false;

    SEPIA2_LASER_LOCKED                         =     true;
    SEPIA2_LASER_UNLOCKED                       =     false;

    SEPIA2_PRIMARY_MODULE                       =     true;
    SEPIA2_SECONDARY_MODULE                     =     false;

    SEPIA2_SLM_PULSE_MODE                       =     true;
    SEPIA2_SLM_CW_MODE                          =     false;

    SEPIA2_SML_PULSE_MODE                       =     true;
    SEPIA2_SML_CW_MODE                          =     false;

    SEPIA2_SOM_INVERSE_SYNC_MASK                =     true;
    SEPIA2_SOM_STANDARD_SYNC_MASK               =     false;

    SEPIA2_SPM_TRANSFERDIR_RAM2FLASH            =     true;
    SEPIA2_SPM_TRANSFERDIR_FLASH2RAM            =     false;

    SEPIA2_SPM_FRAM_WRITE_PROTECTED             =     true;
    SEPIA2_SPM_FRAM_WRITE_ENABLED               =     false;

    SEPIA2_SPM_FIBERAMPLIFIER_FAILURE           =     true;
    SEPIA2_SPM_FIBERAMPLIFIER_OK                =     false;

    SEPIA2_SPM_CONTROLMODE_MANUAL               =     true;
    SEPIA2_SPM_CONTROLMODE_AUTOMATIC            =     false;

    SEPIA2_SPM_PUMPSTATE_ECOMODE                =     true;
    SEPIA2_SPM_PUMPSTATE_BOOSTMODE              =     false;

    SEPIA2_SPM_PUMPMODE_DYNAMIC                 =     true;
    SEPIA2_SPM_PUMPMODE_STATIC                  =     false;

    SEPIA2_SPM_OT_RESETREASON_FIBER_CHANGE      =     true;
    SEPIA2_SPM_OT_RESETREASON_DELIVERY          =     false;

    SEPIA2_USB_STRDECR_LEN                      =   255;
    SEPIA2_VERSIONINFO_LEN                      =     8;
    SEPIA2_ERRSTRING_LEN                        =    64;
    SEPIA2_FW_ERRCOND_LEN                       =    55;
    SEPIA2_FW_ERRPHASE_LEN                      =    24;
    SEPIA2_SERIALNUMBER_LEN                     =    12;
    SEPIA2_PRODUCTMODEL_LEN                     =    32;
    SEPIA2_COM_FW_MAGIC_LEN                     =     8;
    SEPIA2_COM_MODULETYPE_LEN                   =     4;  // style:  'SCM ', 'SOM ', 'SLM ', ...
    SEPIA2_COM_MODULETYPESTRING_LEN             =    55;  // style:  'primary module,   type SCM 828', ...
    SEPIA2_SCM_VOLTAGE_INPNAME_LEN              =    20;
    SEPIA2_SLM_FREQ_TRIGMODE_LEN                =    28;
    SEPIA2_SLM_HEADTYPE_LEN                     =    18;
    SEPIA2_SOM_FREQ_TRIGMODE_LEN                =    32;
    SEPIA2_SWM_FREQ_TRIGMODE_LEN                =    32;
    SEPIA2_SWS_MODULETYPE_LEN                   =    20;
    SEPIA2_SWS_MODULESTATE_LEN                  =    20;
    SEPIA2_SWS_MOTORNAME_LEN                    =    16;
    SEPIA2_SSM_FREQ_TRIGMODE_LEN                =    16;
  //
  //
  //                                                      //               bit 7         6         5     4    3      2..0
  //      SepiaObjTyp                                     //               L   module    secondary            S
  //           -                                          //                   /         /         laser osc  /      typecnt
  //   construction table                                 //               H   backpl    primary              L or F
  //                                                         7 6 54  3 210
    {$Z1} // values are byte
    SEPIA2OBJECT_LHS                            =   $20;  // 0 0 10  0 000     module    secondary yes   no   slow   0-7    // Laser Head       (slow, i.e. <= 40MHz)
    SEPIA2OBJECT_LHF                            =   $28;  // 0 0 10  1 000     module    secondary yes   no   fast   0-7    // Laser Head       (fast, i.e. >  40MHz)
    SEPIA2OBJECT_LH_                            =   $29;  // 0 0 10  1 000     module    secondary yes   no   fast          // Diode/Laser Head (fast, i.e. >  40MHz)
    SEPIA2OBJECT_SCM                            =   $40;  // 0 1 00  0 000     module    primary   no    no   d.c.          // for Sepia II: Controller Modules (Safety Board)
    SEPIA2OBJECT_SLC                            =   $41;  // 0 1 00  0 001     module    primary   no    no   d.c.          // for Solea: Laser Coupler (i.e. SWS without filters)
    SEPIA2OBJECT_SLT                            =   $42;  // 0 1 00  0 010     module    primary   no    no   d.c.          // for Module Commissioning Site: Voltage Meter Module
    SEPIA2OBJECT_SWM                            =   $43;  // 0 1 00  0 011     module    primary   no    no   d.c.          // for PPL 400: Waveform Shaper Modules
    SEPIA2OBJECT_SWS                            =   $44;  // 0 1 00  0 100     module    primary   no    no   d.c.          // for Solea: Wavelength Selector Modules
    SEPIA2OBJECT_SPM                            =   $45;  // 0 1 00  0 101     module    primary   no    no   d.c.          // for Solea: Pumpcontrol Modules
    SEPIA2OBJECT_LMP1                           =   $46;  // 0 1 00  0 110     module    primary   no    no   small         // for Laser Test Site: Metermodule w. Shuttercontrol
    SEPIA2OBJECT_LMP8                           =   $4E;  // 0 1 00  1 110     module    primary   no    no   large         // for Laser Test Site: Eightfold Metermodule
    SEPIA2OBJECT_SOM                            =   $50;  // 0 1 01  0 000     module    primary   no    yes  d.c.   0-7    // for Sepia II: Oscillator Module
    SEPIA2OBJECT_SOMD                           =   $51;  // 0 1 01  0 001     module    primary   no    yes  d.c.   0-7    // for Sepia II: Oscillator Module with Delay Option
    SEPIA2OBJECT_SML                            =   $60;  // 0 1 10  0 000     module    primary   yes   no   d.c.   0-7    // for Sepia II: Multi-Laser Module
    SEPIA2OBJECT_VCL                            =   $61;  // 0 1 10  0 000     module    primary   yes   no   d.c.   0-7    // for PPL 400: Voltage Controlled Laser Module
    SEPIA2OBJECT_SLM                            =   $70;  // 0 1 11  0 000     module    primary   yes   yes  d.c.          // for Sepia II: Laser Driver Module
    SEPIA2OBJECT_SSM                            =   $71;  // 0 1 11  0 001     module    primary   yes   yes  d.c.          // for Solea: Seed Laser Module
    SEPIA2OBJECT_FRXS                           =   $80;  // 1 0 00  0 000     backplane secondary no    no   small         // Extension Frame small
    SEPIA2OBJECT_FRXL                           =   $88;  // 1 0 00  1 000     backplane secondary no    no   large         // Extension Frame large
    SEPIA2OBJECT_FRMS                           =   $C0;  // 1 1 00  0 000     backplane primary   no    no   small         // Main Frame small
    SEPIA2OBJECT_FRML                           =   $C8;  // 1 1 00  1 000     backplane primary   no    no   large         // Main Frame large
    SEPIA2OBJECT_FAIL                           =   $FF;

    SEPIA2_SLM_FREQ_TRIGMODE_COUNT              =     8;
    SEPIA2_SLM_HEADTYPE_COUNT                   =     4;

    {$Z1} // values are byte
    SEPIA2_SOM_AUX_IN_ENABLE_SEQUENCER_FREERUN  =     0;
    SEPIA2_SOM_AUX_IN_ENABLE_SEQUENCER_ON_HIGH  =     1;
    SEPIA2_SOM_AUX_IN_ENABLE_SEQUENCER_ON_LOW   =     2;
    SEPIA2_SOM_AUX_IN_DISABLE_SEQUENCER         =     3;

    SEPIA2_SOM_BURSTCHANNEL_COUNT               =     8;

    SEPIA2_SOM_FREQ_TRIGMODE_COUNT              =     5;
    SEPIA2_SOM_TRIGGERLEVEL_STEP                =    20; // in mV
    SEPIA2_SOM_TRIGGERLEVEL_HALFSTEP            =     (SEPIA2_SOM_TRIGGERLEVEL_STEP div 2);

    SEPIA2_SPM_PUMPCTRLFUNC_SAMPLECOUNT         =     6;
    SEPIA2_SPM_TEMPERATURE_SENSORCOUNT          =     6;
    SEPIA2_SPM_UPTIME_POWERCLASSES              =    10;

    {$Z2} // values are SmallInt (Delphi), i.e. short (C)
    SEPIA2_SPM_STATE_READY                      = $0000; // Module bereit
    SEPIA2_SPM_STATE_INIT                       = $0001; // Module Initialisierung
    SEPIA2_SPM_STATE_BUSY                       = $0002; // Motoren aktiv
    SEPIA2_SPM_STATE_ERROR                      = $0010; // Error info pending
    SEPIA2_SPM_STATE_UPDATING_FW                = $0020; // Firmware update running
    SEPIA2_SPM_STATE_FRAM_WRITEPROTECTED        = $0040; // FRAM write protected on adresses > $1800
    //
    SEPIA2_SPM_STATEMASK_NOT_FUNCTIONAL         = $0013; // OK wenn READY or WAVELENGTH or BANDWIDTH
    SEPIA2_SPM_STATEMASK_ILLEGAL_STATES         = $FF8C;

    {$Z2} // values are SmallInt (Delphi), i.e. short (C)
    SEPIA2_SWS_STATE_READY                      = $0000; // Module bereit
    SEPIA2_SWS_STATE_INIT                       = $0001; // Module Initialisierung
    SEPIA2_SWS_STATE_BUSY                       = $0002; // Motoren aktiv
    SEPIA2_SWS_STATE_WAVELENGTH                 = $0004; // Wavelength wurde gesetzt
    SEPIA2_SWS_STATE_BANDWIDTH                  = $0008; // Bandwidth wurde gesetzt
    SEPIA2_SWS_STATE_ERROR                      = $0010; // Error info pending
    SEPIA2_SWS_STATE_UPDATING_FW                = $0020; // Firmware update running
    SEPIA2_SWS_STATE_FRAM_WRITEPROTECTED        = $0040; // FRAM write protected on adresses > $1800
    SEPIA2_SWS_STATE_CALIBRATING                = $0080; // Calibration mode
    SEPIA2_SWS_STATE_GUIRANGES                  = $0100; // firmware knows GUI ranges
    //
    SEPIA2_SWS_STATEMASK_NOT_FUNCTIONAL         = $0013; // OK wenn READY or WAVELENGTH or BANDWIDTH
    SEPIA2_SWS_STATEMASK_ILLEGAL_STATES         = $FE00;

  type

    {$Z1} // values are byte
    TSepia2_SLM_TrigModes = (
      SEPIA2_SLM_FREQ_80MHZ,
      SEPIA2_SLM_FREQ_40MHZ,
      SEPIA2_SLM_FREQ_20MHZ,
      SEPIA2_SLM_FREQ_10MHZ,
      SEPIA2_SLM_FREQ_5MHZ,
      SEPIA2_SLM_FREQ_2_5MHZ,
      SEPIA2_SLM_EXT_TRIG_RAISING,
      SEPIA2_SLM_EXT_TRIG_FALLING);

    TSepia2_SLM_HeadTypes = (
      SEPIA2_SLM_HEADTYPE_FAILURE,
      SEPIA2_SLM_HEADTYPE_LED,
      SEPIA2_SLM_HEADTYPE_LASER,
      SEPIA2_SLM_HEADTYPE_NONE);

    TSepia2_SOM_TrigModes = (
      SEPIA2_SOM_EXT_TRIG_RAISING,
      SEPIA2_SOM_EXT_TRIG_FALLING,
      SEPIA2_SOM_INT_OSC_A,
      SEPIA2_SOM_INT_OSC_B,
      SEPIA2_SOM_INT_OSC_C);

    T_SepiaModules_FWVersion = record
      case boolean of
        true:  (ulVersion : Cardinal);
        false: (
                 Build    : word;
                 VersMin  : byte;
                 VersMax  : byte;
               );
    end;

    TFW_Discriminator = record
      FW_Version    : T_SepiaModules_FWVersion;
      cModuleType   : array [0..SEPIA2_COM_MODULETYPE_LEN-1] of AnsiChar;
      cFWMagic      : array [0..SEPIA2_COM_FW_MAGIC_LEN-1] of AnsiChar;
      dwReserve1    : LongWord;
      dwReserve2    : LongWord;
      dwReserve3    : LongWord;
      wReserve1     : word;
      wCRC          : word;
    end;
    TPtr_FW_Discriminator = ^TFW_Discriminator;


  var
    strLibVersion      : string;
    bSepia2ImportLibOK : Boolean;


  // ---  library functions  ----------------------------------------------------

  function SEPIA2_LIB_DecodeError             (iErrCode: integer; var cErrorString: string) : integer;
  function SEPIA2_LIB_GetVersion              (var cLibVersion: string) : integer;
  function SEPIA2_LIB_IsRunningOnWine         (var bIsRunningOnWine : boolean) : integer;

  // ---  USB functions  --------------------------------------------------------

  function SEPIA2_USB_OpenDevice              (iDevIdx: integer; var cProductModel: string; var cSerialNumber: string) : integer;
  function SEPIA2_USB_CloseDevice             (iDevIdx: integer) : integer;
  function SEPIA2_USB_GetStrDescriptor        (iDevIdx: integer; var cDescriptor: string) : integer;
  function SEPIA2_USB_OpenGetSerNumAndClose   (iDevIdx: integer; var cProductModel: string; var cSerialNumber: string) : integer;

  // ---  firmware functions  ---------------------------------------------------

  function SEPIA2_FWR_DecodeErrPhaseName      (iErrPhase: integer; var cErrorPhase: string) : integer;
  function SEPIA2_FWR_GetVersion              (iDevIdx: integer;   var cFWVersion: string) : integer;
  function SEPIA2_FWR_GetLastError            (iDevIdx: integer;   var iErrCode, iPhase, iLocation, iSlot: integer; var cCondition: string) : integer;
  function SEPIA2_FWR_GetModuleMap            (iDevIdx: integer; bPerformRestart: boolean; var iModuleCount: integer) : integer;
  function SEPIA2_FWR_GetModuleInfoByMapIdx   (iDevIdx, iMapIdx: integer; var iSlotId: integer; var bIsPrimary, bIsBackPlane, bHasUptimeCounter: boolean) : integer;
  function SEPIA2_FWR_GetUptimeInfoByMapIdx   (iDevIdx, iMapIdx: integer; var dwMainPowerUp, dwActivePowerUp, dwScaledPowerUp: cardinal) : integer;
  function SEPIA2_FWR_FreeModuleMap           (iDevIdx: integer) : integer;

  // ---  common module functions  ----------------------------------------------

  function SEPIA2_COM_DecodeModuleType        (iModuleType: integer; var cModuleType: string) : integer;
  function SEPIA2_COM_DecodeModuleTypeAbbr    (iModuleType: integer; var cModuleTypeAbbr: string) : integer;
  function SEPIA2_COM_HasSecondaryModule      (iDevIdx, iSlotId: integer; var bHasSecondary: boolean) : integer;
  function SEPIA2_COM_GetModuleType           (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var iModuleType: integer) : integer;
  function SEPIA2_COM_GetSerialNumber         (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var cSerialNumber: string) : integer;
  function SEPIA2_COM_GetPresetInfo           (iDevIdx, iSlotId: integer; bGetPrimary: boolean; iPresetNr: integer; var bPresetIsSet: boolean; var cPresetMemo: string) : integer;
  function SEPIA2_COM_RecallPreset            (iDevIdx, iSlotId: integer; bGetPrimary: boolean; iPresetNr: integer) : integer;
  function SEPIA2_COM_SaveAsPreset            (iDevIdx, iSlotId: integer; bSetPrimary: boolean; iPresetNr: integer; const cPresetMemo: string) : integer;
  function SEPIA2_COM_IsWritableModule        (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var bIsWritable: boolean) : integer;
  function SEPIA2_COM_UpdateModuleData        (iDevIdx, iSlotId: integer; bSetPrimary: boolean; cFileName: string) : integer;

  // ---  SCM 828 functions  ----------------------------------------------------

  function SEPIA2_SCM_GetPowerAndLaserLEDS    (iDevIdx, iSlotId: integer;  var bPowerLED,   bLaserActiveLED: boolean) : integer;
  function SEPIA2_SCM_GetLaserLocked          (iDevIdx, iSlotId: integer;  var bLocked:     boolean) : integer;
  function SEPIA2_SCM_GetLaserSoftLock        (iDevIdx, iSlotId: integer;  var bSoftLocked: boolean) : integer;
  function SEPIA2_SCM_SetLaserSoftLock        (iDevIdx, iSlotId: integer;      bSoftLocked: boolean) : integer;

  // ---  SLM 828 functions  ----------------------------------------------------

  function SEPIA2_SLM_DecodeFreqTrigMode        (iFreq: integer; var cFreqTrigMode: string) : integer;
  function SEPIA2_SLM_DecodeHeadType            (iHeadType: integer; var cHeadType: string) : integer;
  //
  function SEPIA2_SLM_GetParameters             (iDevIdx, iSlotId: integer; var iFreq: integer; var bPulseMode: boolean; var iHead: integer; var byteIntensity: byte) : integer;
  // deprecated  : SEPIA2_SLM_GetParameters;
  // use instead : SEPIA2_SLM_GetIntensityFineStep, SEPIA2_SLM_GetPulseParameters
  //
  function SEPIA2_SLM_SetParameters             (iDevIdx, iSlotId, iFreq: integer; bPulseMode: boolean; byteIntensity: byte) : integer;
  // deprecated  : SEPIA2_SLM_SetParameters;
  // use instead : SEPIA2_SLM_SetIntensityFineStep, SEPIA2_SLM_SetPulseParameters
  //
  function SEPIA2_SLM_GetIntensityFineStep      (iDevIdx, iSlotId: integer; var wIntensity: word) : integer;
  function SEPIA2_SLM_SetIntensityFineStep      (iDevIdx, iSlotId: integer; wIntensity: word) : integer;
  function SEPIA2_SLM_GetPulseParameters        (iDevIdx, iSlotId: integer; var iFreq: integer; var bPulseMode: boolean; var iHeadType: integer) : integer;
  function SEPIA2_SLM_SetPulseParameters        (iDevIdx, iSlotId: integer; iFreq: integer; bPulseMode: boolean) : integer;

  // ---  SML 828 functions  ----------------------------------------------------

  function SEPIA2_SML_DecodeHeadType            (iHeadType: integer; var cHeadType: string) : integer;
  function SEPIA2_SML_GetParameters             (iDevIdx, iSlotId: integer; var bPulseMode: boolean; var iHead: integer; var byteIntensity: byte) : integer;
  function SEPIA2_SML_SetParameters             (iDevIdx, iSlotId: integer; bPulseMode: boolean; byteIntensity: byte) : integer;

  // ---  SOM 828 functions  ----------------------------------------------------

const
  SEPIA2_API_SOM_SEQUENCER_CTRL_FREE_RUN        : byte = (0);
  SEPIA2_API_SOM_SEQUENCER_CTRL_RUN_ON_HIGH     : byte = (1);
  SEPIA2_API_SOM_SEQUENCER_CTRL_RUN_ON_LOW      : byte = (2);
  SEPIA2_API_SOM_SEQUENCER_DISABLED             : byte = (3);
  SEPIA2_API_SOM_AUXOUT_DISABLED                : byte = (0);
  SEPIA2_API_SOM_AUXOUT_SEQUENCER_IDXPULSE      : byte = (1);


  function SEPIA2_SOM_DecodeFreqTrigMode        (iDevIdx, iSlotId, iFreqTrigIdx: integer; var cFreqTrigMode: string) : integer;
  function SEPIA2_SOM_GetFreqTrigMode           (iDevIdx, iSlotId: integer; var iFreqTrigIdx: integer) : integer;
  function SEPIA2_SOM_SetFreqTrigMode           (iDevIdx, iSlotId, iFreqTrigIdx: integer) : integer;
  function SEPIA2_SOM_GetTriggerRange           (iDevIdx, iSlotId: integer; var iMilliVoltLow, iMilliVoltHigh: integer) : integer;
  function SEPIA2_SOM_GetTriggerLevel           (iDevIdx, iSlotId: integer; var iMilliVolt: integer) : integer;
  function SEPIA2_SOM_SetTriggerLevel           (iDevIdx, iSlotId, iMilliVolt: integer) : integer;
  function SEPIA2_SOM_GetOutNSyncEnable         (iDevIdx, iSlotId: integer; var byteOutEnable, byteSyncEnable: byte; var bSyncInverse: boolean) : integer;
  function SEPIA2_SOM_SetOutNSyncEnable         (iDevIdx, iSlotId: integer; byteOutEnable, byteSyncEnable: byte; bSyncInverse: boolean) : integer;
  function SEPIA2_SOM_GetBurstLengthArray       (iDevIdx, iSlotId: integer; var lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8: longint) : integer;
  function SEPIA2_SOM_SetBurstLengthArray       (iDevIdx, iSlotId: integer; lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8: longint) : integer;
  function SEPIA2_SOM_GetBurstValues            (iDevIdx, iSlotId: integer; var wDivider: word; var bytePreSync, byteSyncMask: byte) : integer;
  function SEPIA2_SOM_SetBurstValues            (iDevIdx, iSlotId: integer; wDivider: word; bytePreSync, byteSyncMask: byte) : integer;
  function SEPIA2_SOM_DecodeAUXINSequencerCtrl  (iDevIdx, iSlotId: integer; iAuxInCtrl: integer; var cSequencerCtrl: string) : integer;
  function SEPIA2_SOM_GetAUXIOSequencerCtrl     (iDevIdx, iSlotId: integer; var bAUXOutEnable: boolean; var byteAUXInSequencerCtrl: byte) : integer;
  function SEPIA2_SOM_SetAUXIOSequencerCtrl     (iDevIdx, iSlotId: integer; bAUXOutEnable: boolean; byteAUXInSequencerCtrl: byte) : integer;


  // ---  SWM 828 (PPL 400) functions  -------------------------------------------

  function SEPIA2_SWM_DecodeRangeIdx            (iDevIdx, iSlotId: integer; iRangeIdx: integer; var iUpperLimit: integer) : integer;
  function SEPIA2_SWM_GetUIConstants            (iDevIdx, iSlotId: integer; var byteTBIdxCount: byte; var wMaxAmplitude, wMaxSlewRate, wExpRampEffect, wMinUserValue, wMaxUserValue, wUserResolution: word) : integer;
  function SEPIA2_SWM_GetCurveParams            (iDevIdx, iSlotId: integer; iCurveIdx: integer; var byteTBIdx: byte; var wPAPml, wRRPml, wPSPml, wRSPml, wWSPml: word) : integer;
  function SEPIA2_SWM_SetCurveParams            (iDevIdx, iSlotId: integer; iCurveIdx: integer;     byteTBIdx: byte;     wPAPml, wRRPml, wPSPml, wRSPml, wWSPml: word) : integer;
  function SEPIA2_SWM_GetCalTableVal            (iDevIdx, iSlotId: integer; cTableName: string;     byteTabRow, byteTabCol: byte; var wValue: word) : integer;

  // ---  Solea SPM functions  --------------------------------------------------

  type

    T_SPM_PumpCtrlParams = record
      case boolean of
        true:  (
          wArr          : array [0 .. 4 * SEPIA2_SPM_PUMPCTRLFUNC_SAMPLECOUNT - 1] of word;
        );
        false: (
          wFreqADC      : array [0 ..     SEPIA2_SPM_PUMPCTRLFUNC_SAMPLECOUNT - 1] of word;
          wPump1Cur     : array [0 ..     SEPIA2_SPM_PUMPCTRLFUNC_SAMPLECOUNT - 1] of word;
          wPump2Cur     : array [0 ..     SEPIA2_SPM_PUMPCTRLFUNC_SAMPLECOUNT - 1] of word;
          wPump3Cur     : array [0 ..     SEPIA2_SPM_PUMPCTRLFUNC_SAMPLECOUNT - 1] of word;
        );
    end;

    T_SPM_PumpCtrlParamSet = array [boolean] of T_SPM_PumpCtrlParams;

    T_SPM_Temperatures = record
      case boolean of
        true:  (
          wT            : array [0 ..     SEPIA2_SPM_TEMPERATURE_SENSORCOUNT  - 1] of word;
        );
        false: (
          T_Pump1,
          T_Pump2,
          T_Pump3,
          T_Pump4,
          T_FiberStack,
          T_AuxAdjust   : word;
        );
    end;

    T_SPM_SensorData = record
      Temperatures     : T_SPM_Temperatures;
      wOverAllCurrent  : word;
      wOptionalSensor1 : word;
      wOptionalSensor2 : word;
    end;

    T_SPM_UpTimePowerTable = record
      case boolean of
        true:  (
          dwUT     : array [0 ..     SEPIA2_SPM_UPTIME_POWERCLASSES  - 1] of Cardinal;
        );
        false: (
          dwUT_01,
          dwUT_02,
          dwUT_03,
          dwUT_04,
          dwUT_05,
          dwUT_06,
          dwUT_07,
          dwUT_08,
          dwUT_09,
          dwUT_10  : Cardinal;
        );
    end;

    T_SPM_UpTimePowerTables = array [boolean] of T_SPM_UpTimePowerTable;


  function SEPIA2_SPM_DecodeModuleState         (wModuleState: word;        var cModuleState: string) : integer;
  function SEPIA2_SPM_GetFWVersion              (iDevIdx, iSlotId: integer; var FWVersion: T_SepiaModules_FWVersion) : integer;
  function SEPIA2_SPM_GetManualPumpCurrent      (iDevIdx, iSlotId: integer; var wPumpCurrent1, wPumpCurrent2, wPumpCurrent3: word) : integer;
  function SEPIA2_SPM_GetControlMode            (iDevIdx, iSlotId: integer; var bManualMode: boolean) : integer;
  function SEPIA2_SPM_GetPumpCtrlParams         (iDevIdx, iSlotId: integer; bIsPumpStateEco: boolean; var PumpCtrlParams: T_SPM_PumpCtrlParams) : integer;
  function SEPIA2_SPM_GetPhotoDiodeCurrents     (iDevIdx, iSlotId: integer; var iPhDCurrent1, iPhDCurrent2, iPhDCurrent3: integer) : integer;
  function SEPIA2_SPM_GetPumpCurrents           (iDevIdx, iSlotId: integer; var iPumpCurrent1, iPumpCurrent2, iPumpCurrent3: integer) : integer;
  function SEPIA2_SPM_GetSensorData             (iDevIdx, iSlotId: integer; var SensorData: T_SPM_SensorData) : integer;
  function SEPIA2_SPM_GetTemperatureAdjust      (iDevIdx, iSlotId: integer; var Temperatures: T_SPM_Temperatures) : integer;
  function SEPIA2_SPM_GetUpTimePowerTable       (iDevIdx, iSlotId: integer; bIsPumpStateEco: boolean; var UpTimePwrTable: T_SPM_UpTimePowerTable) : integer;
  function SEPIA2_SPM_GetStatusError            (iDevIdx, iSlotId: integer; var wModuleState: word; var iErrorCode: SmallInt) : integer;
  function SEPIA2_SPM_UpdateFirmware            (iDevIdx, iSlotId: integer; cFileName: string) : integer;
  function SEPIA2_SPM_SetFRAMWriteProtect       (iDevIdx, iSlotId: integer; bWriteProtect: boolean) : integer;
  function SEPIA2_SPM_GetFiberAmplifierFail     (iDevIdx, iSlotId: integer; var bFiberAmpFail: boolean) : integer;
  function SEPIA2_SPM_ResetFiberAmplifierFail   (iDevIdx, iSlotId: integer; bFiberAmpFail: boolean) : integer;
  function SEPIA2_SPM_GetPumpPowerState         (iDevIdx, iSlotId: integer; var bIsPumpStateEco, bIsPumpModeDynamic: boolean) : integer;
  function SEPIA2_SPM_SetPumpPowerState         (iDevIdx, iSlotId: integer; bIsPumpStateEco, bIsPumpModeDynamic: boolean) : integer;
  function SEPIA2_SPM_GetOperationTimers        (iDevIdx, iSlotId: integer; var dwMainPwrSw_Counter, dwUT_OverAll, dwUT_SinceDelivery, dwUT_SinceFibChg  : Cardinal) : integer;


  // ---  Solea SWS functions  --------------------------------------------------

  function SEPIA2_SWS_DecodeModuleType          (iModuleType:  integer;     var cModuleType: string) : integer;
  function SEPIA2_SWS_DecodeModuleState         (wModuleState: word;        var cModuleState: string) : integer;
  function SEPIA2_SWS_GetModuleType             (iDevIdx, iSlotId: integer; var iModuleType: integer) : integer;
  function SEPIA2_SWS_GetStatusError            (iDevIdx, iSlotId: integer; var wModuleState: word; var iErrorCode: SmallInt) : integer;
  function SEPIA2_SWS_GetParamRanges            (iDevIdx, iSlotId: integer; var ulUpperWL, ulLowerWL, ulIncrWL, ulPPMToggleWL, ulUpperBW, ulLowerBW, ulIncrBW: Cardinal; var iUpperAtten, iLowerAtten, iIncrAtten: integer) : integer;
  function SEPIA2_SWS_GetParameters             (iDevIdx, iSlotId: integer; var ulWaveLength, ulBandwidth: Cardinal) : integer;
  function SEPIA2_SWS_SetParameters             (iDevIdx, iSlotId: integer; ulWaveLength, ulBandwidth: Cardinal) : integer;
  function SEPIA2_SWS_GetIntensity              (iDevIdx, iSlotId: integer; var ulIntensRaw: Cardinal; var fIntensity: Single) : integer;
  function SEPIA2_SWS_GetFWVersion              (iDevIdx, iSlotId: integer; var FWVersion: T_SepiaModules_FWVersion) : integer;
  function SEPIA2_SWS_UpdateFirmware            (iDevIdx, iSlotId: integer; cFileName: string) : integer;
  function SEPIA2_SWS_SetFRAMWriteProtect       (iDevIdx, iSlotId: integer; bWriteProtect: boolean) : integer;
  function SEPIA2_SWS_GetBeamPos                (iDevIdx, iSlotId: integer; var iBeamPosV, iBeamPosH: integer) : integer;
  function SEPIA2_SWS_SetBeamPos                (iDevIdx, iSlotId: integer; iBeamPosV, iBeamPosH: integer) : integer;
  function SEPIA2_SWS_SetCalibrationMode        (iDevIdx, iSlotId: integer; bCalibrationMode: boolean) : integer;
  function SEPIA2_SWS_GetCalTableSize           (iDevIdx, iSlotId: integer; var wWLIdxCount, wBWIdxCount: word) : integer;
  function SEPIA2_SWS_GetCalPointInfo           (iDevIdx, iSlotId: integer; iWLIdx, iBWIdx: integer; var ulWaveLength, ulBandWidth: Cardinal; var iBeamPosV, iBeamPosH: integer) : integer;
  function SEPIA2_SWS_SetCalPointValues         (iDevIdx, iSlotId: integer; iWLIdx, iBWIdx, iBeamPosV, iBeamPosH: integer) : integer;
  function SEPIA2_SWS_SetCalTableSize           (iDevIdx, iSlotId: integer; wWLIdxCount, wBWIdxCount: word; bInit: boolean) : integer;

  // ---  Solea SSM functions  --------------------------------------------------

  function SEPIA2_SSM_DecodeFreqTrigMode        (iDevIdx, iSlotId: integer; iFreqTrigIdx: integer; var cFreqTrigMode: string; var iMainFreq: integer; var bEnableTrigLvl: boolean) : integer;
  function SEPIA2_SSM_GetTrigLevelRange         (iDevIdx, iSlotId: integer; var iUpperTrigLevel, iLowerTrigLevel, iTrigLevelResol: integer) : integer;
  function SEPIA2_SSM_GetTriggerData            (iDevIdx, iSlotId: integer; var iFreqTrigIdx, iTrigLevel: integer) : integer;
  function SEPIA2_SSM_SetTriggerData            (iDevIdx, iSlotId: integer; iFreqTrigIdx, iTrigLevel: integer) : integer;
  function SEPIA2_SSM_GetFRAMWriteProtect       (iDevIdx, iSlotId: integer; var bWriteProtect: boolean) : integer;
  function SEPIA2_SSM_SetFRAMWriteProtect       (iDevIdx, iSlotId: integer; bWriteProtect: boolean) : integer;

  procedure DebugOut (const iDir : Integer; const strIn : string; iRetVal : integer = 0); overload;
  procedure DebugOut (const iDir : Integer; const strIn : string; cAdditionalStr : string); overload;

  var
    bActiveDebugOut : boolean;

implementation

  uses
    WinApi.Windows,
    System.SysUtils, System.StrUtils, System.Math,
    Sepia2_ErrorCodes;

  const
    SEPIA2_API_SPM_TRANSFERDIR_RAM2FLASH            = byte(1);
    SEPIA2_API_SPM_TRANSFERDIR_FLASH2RAM            = byte(0);

    SEPIA2_API_SPM_FRAM_WRITE_PROTECTED             = byte(1);
    SEPIA2_API_SPM_FRAM_WRITE_ENABLED               = byte(0);

    SEPIA2_API_SPM_CONTROLMODE_MANUAL               = byte(1);
    SEPIA2_API_SPM_CONTROLMODE_AUTOMATIC            = byte(0);

    SEPIA2_API_SPM_FIBERAMPLIFIER_FAILURE           = byte(1);
    SEPIA2_API_SPM_FIBERAMPLIFIER_OK                = byte(0);

    SEPIA2_API_SPM_PUMPSTATE_ECOMODE                = byte(1);
    SEPIA2_API_SPM_PUMPSTATE_BOOSTMODE              = byte(0);

    SEPIA2_API_SPM_PUMPMODE_DYNAMIC                 = byte(1);
    SEPIA2_API_SPM_PUMPMODE_STATIC                  = byte(0);

    SEPIA2_API_SPM_OT_RESETREASON_FIBER_CHANGE      = byte(1);
    SEPIA2_API_SPM_OT_RESETREASON_DELIVERY          = byte(0);

  var
    iRet    : integer;
    strTemp : string;

  type
    T_SEPIA2_LIB_GetVersion                = function (pcLibVersion: pAnsiChar) : integer; stdcall;
    T_SEPIA2_LIB_IsRunningOnWine           = function (var byteIsRunningOnWine: byte) : integer; stdcall;
    T_SEPIA2_LIB_DecodeError               = function (iErrCode: integer; pcErrorString: pAnsiChar) : integer; stdcall;
    T_SEPIA2_USB_OpenDevice                = function (iDevIdx: integer; pcProductModel: pAnsiChar; pcSerialNumber: pAnsiChar) : integer; stdcall;
    T_SEPIA2_USB_CloseDevice               = function (iDevIdx: integer) : integer; stdcall;
    T_SEPIA2_USB_GetStrDescriptor          = function (iDevIdx: integer; pcDescriptor: pAnsiChar) : integer; stdcall;
    T_SEPIA2_USB_OpenGetSerNumAndClose     = function (iDevIdx: integer; pcProductModel: pAnsiChar; pcSerialNumber: pAnsiChar) : integer; stdcall;

    T_SEPIA2_FWR_GetVersion                = function (iDevIdx: integer; pcFWVersion: pAnsiChar) : integer; stdcall;
    T_SEPIA2_FWR_GetLastError              = function (iDevIdx: integer; var iErrCode, iPhase, iLocation, iSlot: integer; pcCondition: pAnsiChar) : integer; stdcall;
    T_SEPIA2_FWR_DecodeErrPhaseName        = function (iErrPhase: integer; pcErrorPhase: pAnsiChar) : integer; stdcall;
    T_SEPIA2_FWR_GetModuleMap              = function (iDevIdx, iPerformRestart: integer; var iModuleCount: integer) : integer; stdcall;
    T_SEPIA2_FWR_GetModuleInfoByMapIdx     = function (iDevIdx, iMapIdx: integer; var iSlotId: integer; var byteIsPrimary, byteIsBackPlane, byteHasUptimeCounter: byte) : integer; stdcall;
    T_SEPIA2_FWR_GetUptimeInfoByMapIdx     = function (iDevIdx, iMapIdx: integer; var dwMainPowerUp, dwActivePowerUp, dwScaledPowerUp: cardinal) : integer; stdcall;
    T_SEPIA2_FWR_FreeModuleMap             = function (iDevIdx: integer) : integer; stdcall;

    T_SEPIA2_COM_DecodeModuleType          = function (iModuleType: integer; pcModuleType: pAnsiChar) : integer; stdcall;
    T_SEPIA2_COM_DecodeModuleTypeAbbr      = function (iModuleType: integer; pcModuleTypeAbbr: pAnsiChar) : integer; stdcall;
    T_SEPIA2_COM_HasSecondaryModule        = function (iDevIdx, iSlotId: integer; var iHasSecondary: integer) : integer; stdcall;
    T_SEPIA2_COM_GetModuleType             = function (iDevIdx, iSlotId, iGetPrimary: integer; var iModuleType: integer) : integer; stdcall;
    T_SEPIA2_COM_GetSerialNumber           = function (iDevIdx, iSlotId, iGetPrimary: integer; pcSerialNumber: pAnsiChar) : integer; stdcall;
    T_SEPIA2_COM_GetPresetInfo             = function (iDevIdx, iSlotId, iGetPrimary, iPresetNr: integer; var byteIsSet: byte; pcPresetMemo: pAnsiChar) : integer; stdcall;
    T_SEPIA2_COM_RecallPreset              = function (iDevIdx, iSlotId, iGetPrimary, iPresetNr: integer) : integer; stdcall;
    T_SEPIA2_COM_SaveAsPreset              = function (iDevIdx, iSlotId, iSetPrimary, iPresetNr: integer; pcPresetMemo: pAnsiChar) : integer; stdcall;
    T_SEPIA2_COM_IsWritableModule          = function (iDevIdx, iSlotId, iGetPrimary: integer; var byteIsWritable: byte) : integer; stdcall;
    T_SEPIA2_COM_UpdateModuleData          = function (iDevIdx, iSlotId, iSetPrimary: integer; pcFileName: pAnsiChar) : integer; stdcall;

    T_SEPIA2_SCM_GetPowerAndLaserLEDS      = function (iDevIdx, iSlotId: integer; var bytePowerLED, byteLaserActiveLED: byte) : integer; stdcall;
    T_SEPIA2_SCM_GetLaserLocked            = function (iDevIdx, iSlotId: integer; var byteLocked: byte) : integer; stdcall;
    T_SEPIA2_SCM_GetLaserSoftLock          = function (iDevIdx, iSlotId: integer; var byteSoftLocked: byte) : integer; stdcall;
    T_SEPIA2_SCM_SetLaserSoftLock          = function (iDevIdx, iSlotId: integer; byteSoftLocked: byte) : integer; stdcall;

    T_SEPIA2_SLM_DecodeFreqTrigMode        = function (iFreq: integer; pcFreqTrigMode: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SLM_DecodeHeadType            = function (iHeadType: integer; pcHeadType: pAnsiChar) : integer; stdcall;
    //
    T_SEPIA2_SLM_GetParameters             = function (iDevIdx, iSlotId: integer; var iFreq: integer; var bytePulseMode: byte; var iHead: integer; var byteIntensity: byte) : integer; stdcall;
    // deprecated  : SEPIA2_SLM_GetParameters;
    // use instead : SEPIA2_SLM_GetIntensityFineStep, SEPIA2_SLM_GetPulseParameters
    T_SEPIA2_SLM_SetParameters             = function (iDevIdx, iSlotId, iFreq: integer; bytePulseMode, byteIntensity: byte) : integer; stdcall;
    // deprecated  : SEPIA2_SLM_SetParameters;
    // use instead : SEPIA2_SLM_SetIntensityFineStep, SEPIA2_SLM_SetPulseParameters
    //
    T_SEPIA2_SLM_GetIntensityFineStep      = function (iDevIdx, iSlotId: integer; var wIntensity: word) : integer; stdcall;
    T_SEPIA2_SLM_SetIntensityFineStep      = function (iDevIdx, iSlotId, wIntensity: word) : integer; stdcall;
    T_SEPIA2_SLM_GetPulseParameters        = function (iDevIdx, iSlotId: integer; var iFreq: integer; var bytePulseMode: byte; var iHeadType: integer) : integer; stdcall;
    T_SEPIA2_SLM_SetPulseParameters        = function (iDevIdx, iSlotId, iFreq: integer; bytePulseMode: byte) : integer; stdcall;

    T_SEPIA2_SML_DecodeHeadType            = function (iHeadType: integer; pcHeadType: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SML_GetParameters             = function (iDevIdx, iSlotId: integer; var bytePulseMode: byte; var iHead: integer; var byteIntensity: byte) : integer; stdcall;
    T_SEPIA2_SML_SetParameters             = function (iDevIdx, iSlotId, bytePulseMode, byteIntensity: byte) : integer; stdcall;

    T_SEPIA2_SOM_DecodeFreqTrigMode        = function (iDevIdx, iSlotId, iFreqTrigIdx: integer; pcFreqTrigMode: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SOM_GetFreqTrigMode           = function (iDevIdx, iSlotId: integer; var iFreqTrigIdx: integer) : integer; stdcall;
    T_SEPIA2_SOM_SetFreqTrigMode           = function (iDevIdx, iSlotId, iFreqTrigIdx: integer) : integer; stdcall;
    T_SEPIA2_SOM_GetTriggerRange           = function (iDevIdx, iSlotId: integer; var iMilliVoltLow, iMilliVoltHigh: integer) : integer; stdcall;
    T_SEPIA2_SOM_GetTriggerLevel           = function (iDevIdx, iSlotId: integer; var iMilliVolt: integer) : integer; stdcall;
    T_SEPIA2_SOM_SetTriggerLevel           = function (iDevIdx, iSlotId, iMilliVolt: integer) : integer; stdcall;
    T_SEPIA2_SOM_GetBurstValues            = function (iDevIdx, iSlotId: integer; var byteDivider, bytePreSync, byteSyncMask: byte) : integer; stdcall;
    T_SEPIA2_SOM_SetBurstValues            = function (iDevIdx, iSlotId: integer; byteDivider, bytePreSync, byteSyncMask: byte) : integer; stdcall;
    T_SEPIA2_SOM_GetBurstLengthArray       = function (iDevIdx, iSlotId: integer; var lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8: longint) : integer; stdcall;
    T_SEPIA2_SOM_SetBurstLengthArray       = function (iDevIdx, iSlotId: integer; lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8: longint) : integer; stdcall;
    T_SEPIA2_SOM_GetOutNSyncEnable         = function (iDevIdx, iSlotId: integer; var byteOutEnable, byteSyncEnable, byteSyncInverse: byte) : integer; stdcall;
    T_SEPIA2_SOM_SetOutNSyncEnable         = function (iDevIdx, iSlotId: integer; byteOutEnable, byteSyncEnable, byteSyncInverse: byte) : integer; stdcall;
    T_SEPIA2_SOM_DecodeAUXINSequencerCtrl  = function (byteAuxInCtrl: byte; pcSequencerCtrl: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SOM_GetAUXIOSequencerCtrl     = function (iDevIdx, iSlotId: integer; var byteAUXOutEnable, byteAUXInSequencerCtrl: byte) : integer; stdcall;
    T_SEPIA2_SOM_SetAUXIOSequencerCtrl     = function (iDevIdx, iSlotId: integer; byteAUXOutEnable, byteAUXInSequencerCtrl: byte) : integer; stdcall;

    T_SEPIA2_SWM_DecodeRangeIdx            = function (iDevIdx, iSlotId: integer; iRangeIdx: integer; var iUpperLimit: integer) : integer; stdcall;
    T_SEPIA2_SWM_GetUIConstants            = function (iDevIdx, iSlotId: integer; var byteTBIdxCount: byte; var wMaxAmplitude, wMaxSlewRate, wExpRampEffect, wMinUserValue, wMaxUserValue, wUserResolution: word) : integer; stdcall;
    T_SEPIA2_SWM_GetCurveParams            = function (iDevIdx, iSlotId: integer; iCurveIdx: integer; var byteTBIdx: byte; var wPAPml, wRRPml, wPSPml, wRSPml, wWSPml: word) : integer; stdcall;
    T_SEPIA2_SWM_SetCurveParams            = function (iDevIdx, iSlotId: integer; iCurveIdx: integer;     byteTBIdx: byte;     wPAPml, wRRPml, wPSPml, wRSPml, wWSPml: word) : integer; stdcall;
    T_SEPIA2_SWM_GetCalTableVal            = function (iDevIdx, iSlotId: integer; pcTableName: pAnsiChar; byteTabRow, byteTabCol: byte; var wValue: word) : integer; stdcall;

    T_SEPIA2_SPM_DecodeModuleState         = function (wModuleState: Word; pcModuleState: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SPM_GetFWVersion              = function (iDevIdx, iSlotId: integer; var ulFWVersion: Cardinal) : integer; stdcall;
    T_SEPIA2_SPM_GetManualPumpCurrent      = function (iDevIdx, iSlotId: integer; var wPumpCurrent1, wPumpCurrent2, wPumpCurrent3: word) : integer; stdcall;
    T_SEPIA2_SPM_GetControlMode            = function (iDevIdx, iSlotId: integer; var byteManualMode: byte) : integer; stdcall;
    T_SEPIA2_SPM_GetPumpCtrlParams         = function (iDevIdx, iSlotId: integer; bytePumpState: byte; var PumpCtrlParams: T_SPM_PumpCtrlParams) : integer; stdcall;
    T_SEPIA2_SPM_GetPhotoDiodeCurrents     = function (iDevIdx, iSlotId: integer; var iPhDCurrent1, iPhDCurrent2, iPhDCurrent3: integer) : integer; stdcall;
    T_SEPIA2_SPM_GetPumpCurrents           = function (iDevIdx, iSlotId: integer; var iPumpCurrent1, iPumpCurrent2, iPumpCurrent3: integer) : integer; stdcall;
    T_SEPIA2_SPM_GetSensorData             = function (iDevIdx, iSlotId: integer; var SensorData : T_SPM_SensorData) : integer; stdcall;
    T_SEPIA2_SPM_GetTemperatureAdjust      = function (iDevIdx, iSlotId: integer; var Temperatures : T_SPM_Temperatures) : integer; stdcall;
    T_SEPIA2_SPM_GetUpTimePowerTable       = function (iDevIdx, iSlotId: integer; bytePumpState: byte; var UpTimePwrTable: T_SPM_UpTimePowerTable) : integer; stdcall;
    T_SEPIA2_SPM_GetStatusError            = function (iDevIdx, iSlotId: integer; var wModuleState: word; var iErrorCode: SmallInt) : integer; stdcall;
    T_SEPIA2_SPM_UpdateFirmware            = function (iDevIdx, iSlotId: integer; pcFileName: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SPM_SetFRAMWriteProtect       = function (iDevIdx, iSlotId: integer; byteWriteProtect: byte) : integer; stdcall;
    T_SEPIA2_SPM_GetFiberAmplifierFail     = function (iDevIdx, iSlotId: integer; var byteFiberAmpFail: byte) : integer; stdcall;
    T_SEPIA2_SPM_ResetFiberAmplifierFail   = function (iDevIdx, iSlotId: integer; byteFiberAmpFail: byte) : integer; stdcall;
    T_SEPIA2_SPM_GetPumpPowerState         = function (iDevIdx, iSlotId: integer; var bytePumpState, bytePumpMode: byte) : integer; stdcall;
    T_SEPIA2_SPM_SetPumpPowerState         = function (iDevIdx, iSlotId: integer; bytePumpState, bytePumpMode: byte) : integer; stdcall;
    T_SEPIA2_SPM_GetOperationTimers        = function (iDevIdx, iSlotId: integer; var dwMainPwrSw_Counter, dwUT_OverAll, dwUT_SinceDelivery, dwUT_SinceFibChg : Cardinal) : integer; stdcall;

    T_SEPIA2_SWS_DecodeModuleType          = function (iModuleType: integer; pcModuleType: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SWS_DecodeModuleState         = function (wModuleState: Word; pcModuleState: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SWS_GetModuleType             = function (iDevIdx, iSlotId: integer; var iModuleType: integer) : integer; stdcall;
    T_SEPIA2_SWS_GetStatusError            = function (iDevIdx, iSlotId: integer; var wModuleState: word; var iErrorCode: SmallInt) : integer; stdcall;
    T_SEPIA2_SWS_GetParamRanges            = function (iDevIdx, iSlotId: integer; var ulUpperWL, ulLowerWL, ulIncrWL, ulPPMToggleWL, ulUpperBW, ulLowerBW, ulIncrBW: Cardinal; var iUpperAtten, iLowerAtten, iIncrAtten: integer) : integer; stdcall;
    T_SEPIA2_SWS_GetParameters             = function (iDevIdx, iSlotId: integer; var ulWaveLength, ulBandwidth: Cardinal) : integer; stdcall;
    T_SEPIA2_SWS_SetParameters             = function (iDevIdx, iSlotId: integer; ulWaveLength, ulBandwidth: Cardinal) : integer; stdcall;
    T_SEPIA2_SWS_GetIntensity              = function (iDevIdx, iSlotId: integer; var ulIntensRaw: Cardinal; var fIntensity: Single) : integer; stdcall;
    T_SEPIA2_SWS_GetFWVersion              = function (iDevIdx, iSlotId: integer; var ulFWVersion: Cardinal) : integer; stdcall;
    T_SEPIA2_SWS_UpdateFirmware            = function (iDevIdx, iSlotId: integer; pcFileName: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SWS_SetFRAMWriteProtect       = function (iDevIdx, iSlotId: integer; byteWriteProtect: byte) : integer; stdcall;
    T_SEPIA2_SWS_GetBeamPos                = function (iDevIdx, iSlotId: integer; var iBeamPosV, iBeamPosH: SmallInt) : integer; stdcall;
    T_SEPIA2_SWS_SetBeamPos                = function (iDevIdx, iSlotId: integer; iBeamPosV, iBeamPosH: SmallInt) : integer; stdcall;
    T_SEPIA2_SWS_SetCalibrationMode        = function (iDevIdx, iSlotId: integer; byteCalibrationMode: byte) : integer; stdcall;
    T_SEPIA2_SWS_GetCalTableSize           = function (iDevIdx, iSlotId: integer; var wWLIdxCount, wBWIdxCount: word) : integer; stdcall;
    T_SEPIA2_SWS_GetCalPointInfo           = function (iDevIdx, iSlotId: integer; iWLIdx, iBWIdx: SmallInt; var ulWaveLength, ulBandWidth: Cardinal; var iBeamPosV, iBeamPosH: SmallInt) : integer; stdcall;
    T_SEPIA2_SWS_SetCalPointValues         = function (iDevIdx, iSlotId: integer; iWLIdx, iBWIdx, iBeamPosV, iBeamPosH: SmallInt) : integer; stdcall;

    T_SEPIA2_SWS_SetCalTableSize           = function (iDevIdx, iSlotId: integer; wWLIdxCount, wBWIdxCount: word; byteInit: byte) : integer; stdcall;

    T_SEPIA2_SSM_DecodeFreqTrigMode        = function (iDevIdx, iSlotId: integer; iFreqTrigIdx: integer; pcFreqTrigMode: pAnsiChar; var iMainFreq: integer; var byteEnableTrigLvl: byte) : integer; stdcall;
    T_SEPIA2_SSM_GetTrigLevelRange         = function (iDevIdx, iSlotId: integer; var iUpperTrigLevel, iLowerTrigLevel, iTrigLevelResol: integer) : integer; stdcall;
    T_SEPIA2_SSM_GetTriggerData            = function (iDevIdx, iSlotId: integer; var iFreqTrigIdx, iTrigLevel: integer) : integer; stdcall;
    T_SEPIA2_SSM_SetTriggerData            = function (iDevIdx, iSlotId: integer; iFreqTrigIdx, iTrigLevel: integer) : integer; stdcall;
    T_SEPIA2_SSM_GetFRAMWriteProtect       = function (iDevIdx, iSlotId: integer; var byteWriteProtect: byte) : integer; stdcall;
    T_SEPIA2_SSM_SetFRAMWriteProtect       = function (iDevIdx, iSlotId: integer; byteWriteProtect: byte) : integer; stdcall;



  const
    TEMPVAR_LENGTH = 1025;

  var
    pcTmpVal1                             : pAnsiChar;
    pcTmpVal2                             : pAnsiChar;
    hdlDLL                                : THandle;

    _SEPIA2_LIB_GetVersion                : T_SEPIA2_LIB_GetVersion;
    _SEPIA2_LIB_IsRunningOnWine           : T_SEPIA2_LIB_IsRunningOnWine;
    _SEPIA2_LIB_DecodeError               : T_SEPIA2_LIB_DecodeError;

    _SEPIA2_USB_OpenDevice                : T_SEPIA2_USB_OpenDevice;
    _SEPIA2_USB_CloseDevice               : T_SEPIA2_USB_CloseDevice;
    _SEPIA2_USB_GetStrDescriptor          : T_SEPIA2_USB_GetStrDescriptor;
    _SEPIA2_USB_OpenGetSerNumAndClose     : T_SEPIA2_USB_OpenGetSerNumAndClose;

    _SEPIA2_FWR_GetVersion                : T_SEPIA2_FWR_GetVersion;
    _SEPIA2_FWR_GetLastError              : T_SEPIA2_FWR_GetLastError;
    _SEPIA2_FWR_DecodeErrPhaseName        : T_SEPIA2_FWR_DecodeErrPhaseName;
    _SEPIA2_FWR_GetModuleMap              : T_SEPIA2_FWR_GetModuleMap;
    _SEPIA2_FWR_GetModuleInfoByMapIdx     : T_SEPIA2_FWR_GetModuleInfoByMapIdx;
    _SEPIA2_FWR_GetUptimeInfoByMapIdx     : T_SEPIA2_FWR_GetUptimeInfoByMapIdx;
    _SEPIA2_FWR_FreeModuleMap             : T_SEPIA2_FWR_FreeModuleMap;

    _SEPIA2_COM_DecodeModuleType          : T_SEPIA2_COM_DecodeModuleType;
    _SEPIA2_COM_DecodeModuleTypeAbbr      : T_SEPIA2_COM_DecodeModuleTypeAbbr;
    _SEPIA2_COM_HasSecondaryModule        : T_SEPIA2_COM_HasSecondaryModule;
    _SEPIA2_COM_GetModuleType             : T_SEPIA2_COM_GetModuleType;
    _SEPIA2_COM_GetSerialNumber           : T_SEPIA2_COM_GetSerialNumber;
    _SEPIA2_COM_GetPresetInfo             : T_SEPIA2_COM_GetPresetInfo;
    _SEPIA2_COM_RecallPreset              : T_SEPIA2_COM_RecallPreset;
    _SEPIA2_COM_SaveAsPreset              : T_SEPIA2_COM_SaveAsPreset;
    _SEPIA2_COM_IsWritableModule          : T_SEPIA2_COM_IsWritableModule;
    _SEPIA2_COM_UpdateModuleData          : T_SEPIA2_COM_UpdateModuleData;

    _SEPIA2_SCM_GetPowerAndLaserLEDS      : T_SEPIA2_SCM_GetPowerAndLaserLEDS;
    _SEPIA2_SCM_GetLaserLocked            : T_SEPIA2_SCM_GetLaserLocked;
    _SEPIA2_SCM_GetLaserSoftLock          : T_SEPIA2_SCM_GetLaserSoftLock;
    _SEPIA2_SCM_SetLaserSoftLock          : T_SEPIA2_SCM_SetLaserSoftLock;

    _SEPIA2_SLM_DecodeFreqTrigMode        : T_SEPIA2_SLM_DecodeFreqTrigMode;
    _SEPIA2_SLM_DecodeHeadType            : T_SEPIA2_SLM_DecodeHeadType;
    //
    _SEPIA2_SLM_GetParameters             : T_SEPIA2_SLM_GetParameters;
    // deprecated  : SEPIA2_SLM_GetParameters;
    // use instead : SEPIA2_SLM_GetIntensityFineStep, SEPIA2_SLM_GetPulseParameters
    _SEPIA2_SLM_SetParameters             : T_SEPIA2_SLM_SetParameters;
    // deprecated  : SEPIA2_SLM_SetParameters;
    // use instead : SEPIA2_SLM_SetIntensityFineStep, SEPIA2_SLM_SetPulseParameters
    //
    _SEPIA2_SLM_GetIntensityFineStep      : T_SEPIA2_SLM_GetIntensityFineStep;
    _SEPIA2_SLM_SetIntensityFineStep      : T_SEPIA2_SLM_SetIntensityFineStep;
    _SEPIA2_SLM_GetPulseParameters        : T_SEPIA2_SLM_GetPulseParameters;
    _SEPIA2_SLM_SetPulseParameters        : T_SEPIA2_SLM_SetPulseParameters;

    _SEPIA2_SML_DecodeHeadType            : T_SEPIA2_SML_DecodeHeadType;
    _SEPIA2_SML_GetParameters             : T_SEPIA2_SML_GetParameters;
    _SEPIA2_SML_SetParameters             : T_SEPIA2_SML_SetParameters;

    _SEPIA2_SOM_DecodeFreqTrigMode        : T_SEPIA2_SOM_DecodeFreqTrigMode;
    _SEPIA2_SOM_GetFreqTrigMode           : T_SEPIA2_SOM_GetFreqTrigMode;
    _SEPIA2_SOM_SetFreqTrigMode           : T_SEPIA2_SOM_SetFreqTrigMode;
    _SEPIA2_SOM_GetTriggerRange           : T_SEPIA2_SOM_GetTriggerRange;
    _SEPIA2_SOM_GetTriggerLevel           : T_SEPIA2_SOM_GetTriggerLevel;
    _SEPIA2_SOM_SetTriggerLevel           : T_SEPIA2_SOM_SetTriggerLevel;
    _SEPIA2_SOM_GetBurstValues            : T_SEPIA2_SOM_GetBurstValues;
    _SEPIA2_SOM_SetBurstValues            : T_SEPIA2_SOM_SetBurstValues;
    _SEPIA2_SOM_GetBurstLengthArray       : T_SEPIA2_SOM_GetBurstLengthArray;
    _SEPIA2_SOM_SetBurstLengthArray       : T_SEPIA2_SOM_SetBurstLengthArray;
    _SEPIA2_SOM_GetOutNSyncEnable         : T_SEPIA2_SOM_GetOutNSyncEnable;
    _SEPIA2_SOM_SetOutNSyncEnable         : T_SEPIA2_SOM_SetOutNSyncEnable;
    _SEPIA2_SOM_DecodeAUXINSequencerCtrl  : T_SEPIA2_SOM_DecodeAUXINSequencerCtrl;
    _SEPIA2_SOM_GetAUXIOSequencerCtrl     : T_SEPIA2_SOM_GetAUXIOSequencerCtrl;
    _SEPIA2_SOM_SetAUXIOSequencerCtrl     : T_SEPIA2_SOM_SetAUXIOSequencerCtrl;

    _SEPIA2_SWM_DecodeRangeIdx            : T_SEPIA2_SWM_DecodeRangeIdx;
    _SEPIA2_SWM_GetUIConstants            : T_SEPIA2_SWM_GetUIConstants;
    _SEPIA2_SWM_GetCurveParams            : T_SEPIA2_SWM_GetCurveParams;
    _SEPIA2_SWM_SetCurveParams            : T_SEPIA2_SWM_SetCurveParams;
    _SEPIA2_SWM_GetCalTableVal            : T_SEPIA2_SWM_GetCalTableVal;

    _SEPIA2_SPM_DecodeModuleState         : T_SEPIA2_SPM_DecodeModuleState;
    _SEPIA2_SPM_GetFWVersion              : T_SEPIA2_SPM_GetFWVersion;
    _SEPIA2_SPM_GetManualPumpCurrent      : T_SEPIA2_SPM_GetManualPumpCurrent;
    _SEPIA2_SPM_GetControlMode            : T_SEPIA2_SPM_GetControlMode;
    _SEPIA2_SPM_GetPumpCtrlParams         : T_SEPIA2_SPM_GetPumpCtrlParams;
    _SEPIA2_SPM_GetPhotoDiodeCurrents     : T_SEPIA2_SPM_GetPhotoDiodeCurrents;
    _SEPIA2_SPM_GetPumpCurrents           : T_SEPIA2_SPM_GetPumpCurrents;
    _SEPIA2_SPM_GetSensorData             : T_SEPIA2_SPM_GetSensorData;
    _SEPIA2_SPM_GetTemperatureAdjust      : T_SEPIA2_SPM_GetTemperatureAdjust;
    _SEPIA2_SPM_GetUpTimePowerTable       : T_SEPIA2_SPM_GetUpTimePowerTable;
    _SEPIA2_SPM_GetStatusError            : T_SEPIA2_SPM_GetStatusError;
    _SEPIA2_SPM_UpdateFirmware            : T_SEPIA2_SPM_UpdateFirmware;
    _SEPIA2_SPM_SetFRAMWriteProtect       : T_SEPIA2_SPM_SetFRAMWriteProtect;
    _SEPIA2_SPM_GetFiberAmplifierFail     : T_SEPIA2_SPM_GetFiberAmplifierFail;
    _SEPIA2_SPM_ResetFiberAmplifierFail   : T_SEPIA2_SPM_ResetFiberAmplifierFail;
    _SEPIA2_SPM_GetPumpPowerState         : T_SEPIA2_SPM_GetPumpPowerState;
    _SEPIA2_SPM_SetPumpPowerState         : T_SEPIA2_SPM_SetPumpPowerState;
    _SEPIA2_SPM_GetOperationTimers        : T_SEPIA2_SPM_GetOperationTimers;

    _SEPIA2_SWS_DecodeModuleType          : T_SEPIA2_SWS_DecodeModuleType;
    _SEPIA2_SWS_DecodeModuleState         : T_SEPIA2_SWS_DecodeModuleState;
    _SEPIA2_SWS_GetModuleType             : T_SEPIA2_SWS_GetModuleType;
    _SEPIA2_SWS_GetStatusError            : T_SEPIA2_SWS_GetStatusError;
    _SEPIA2_SWS_GetParamRanges            : T_SEPIA2_SWS_GetParamRanges;
    _SEPIA2_SWS_GetParameters             : T_SEPIA2_SWS_GetParameters;
    _SEPIA2_SWS_SetParameters             : T_SEPIA2_SWS_SetParameters;
    _SEPIA2_SWS_GetIntensity              : T_SEPIA2_SWS_GetIntensity;
    _SEPIA2_SWS_GetFWVersion              : T_SEPIA2_SWS_GetFWVersion;
    _SEPIA2_SWS_UpdateFirmware            : T_SEPIA2_SWS_UpdateFirmware;
    _SEPIA2_SWS_SetFRAMWriteProtect       : T_SEPIA2_SWS_SetFRAMWriteProtect;
    _SEPIA2_SWS_GetBeamPos                : T_SEPIA2_SWS_GetBeamPos;
    _SEPIA2_SWS_SetBeamPos                : T_SEPIA2_SWS_SetBeamPos;
    _SEPIA2_SWS_SetCalibrationMode        : T_SEPIA2_SWS_SetCalibrationMode;
    _SEPIA2_SWS_GetCalTableSize           : T_SEPIA2_SWS_GetCalTableSize;
    _SEPIA2_SWS_SetCalTableSize           : T_SEPIA2_SWS_SetCalTableSize;
    _SEPIA2_SWS_GetCalPointInfo           : T_SEPIA2_SWS_GetCalPointInfo;
    _SEPIA2_SWS_SetCalPointValues         : T_SEPIA2_SWS_SetCalPointValues;

    _SEPIA2_SSM_DecodeFreqTrigMode        : T_SEPIA2_SSM_DecodeFreqTrigMode;
    _SEPIA2_SSM_GetTrigLevelRange         : T_SEPIA2_SSM_GetTrigLevelRange;
    _SEPIA2_SSM_GetTriggerData            : T_SEPIA2_SSM_GetTriggerData;
    _SEPIA2_SSM_SetTriggerData            : T_SEPIA2_SSM_SetTriggerData;
    _SEPIA2_SSM_GetFRAMWriteProtect       : T_SEPIA2_SSM_GetFRAMWriteProtect;
    _SEPIA2_SSM_SetFRAMWriteProtect       : T_SEPIA2_SSM_SetFRAMWriteProtect;



  procedure DebugOut (const iDir : Integer; const strIn : string; iRetVal : integer = 0);
  {$ifdef __CALL_DEBUGOUT__}
    var
      strDir : string;
  {$endif}
  begin
    {$ifdef __CALL_DEBUGOUT__}
      if bActiveDebugOut
      then begin
        case iDir of
          1 : strDir := ' --> ';
          0 : strDir := ' <-- ';
          else
              strDir := '   - ';
        end;
        OutputDebugString (PWideChar (Format ('PQLaserDrv:%s%s%s', [strDir, strIn, ifthen (iRetVal <> 0, ' => ' + IntToStr (iRetVal), '')])));
      end;
    {$endif}
  end;  // DebugOut (const iDir : Integer; const strIn : string; iRetVal : integer = 0);


  procedure DebugOut (const iDir : Integer; const strIn : string; cAdditionalStr : string);
  {$ifdef __CALL_DEBUGOUT__}
    var
      strDir : string;
  {$endif}
  begin
    {$ifdef __CALL_DEBUGOUT__}
      if bActiveDebugOut
      then begin
        case iDir of
          1 : strDir := ' --> ';
          0 : strDir := ' <-- ';
          else
              strDir := '   - ';
        end;
        OutputDebugString (PWideChar (Format ('PQLaserDrv:%s%s%s', [strDir, strIn, ifthen (length(cAdditionalStr) > 0, ' ' + cAdditionalStr, '')])));
      end;
    {$endif}
  end;  // DebugOut (const iDir : Integer; const strIn : string; cAdditionalStr : string);

  function SEPIA2_LIB_GetVersion (var cLibVersion: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_LIB_GetVersion';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_LIB_GetVersion (pcTmpVal1);
    cLibVersion := string(pcTmpVal1);
    SEPIA2_LIB_GetVersion := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_LIB_GetVersion


  function SEPIA2_LIB_IsRunningOnWine (var bIsRunningOnWine: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    byteIsRunningOnWine : byte;
  begin
    strFkt  := 'SEPIA2_LIB_IsRunningOnWine';
    DebugOut (1, strFkt);
    iRetVal           := _SEPIA2_LIB_IsRunningOnWine (byteIsRunningOnWine);
    bIsRunningOnWine  := (byteIsRunningOnWine <> 0);
    SEPIA2_LIB_IsRunningOnWine := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_LIB_IsRunningOnWine


  function SEPIA2_LIB_DecodeError (iErrCode: integer; var cErrorString: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_LIB_DecodeError';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_LIB_DecodeError (iErrCode, pcTmpVal1);
    cErrorString := string (pcTmpVal1);
    SEPIA2_LIB_DecodeError := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_LIB_DecodeError


  function SEPIA2_USB_OpenDevice (iDevIdx: integer; var cProductModel: string; var cSerialNumber: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    strPM   : AnsiString;
    strSN   : AnsiString;
  begin
    strFkt  := 'SEPIA2_USB_OpenDevice';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    if (Length (cProductModel) > 0)
    then begin
      strPM := AnsiString (trim (cProductModel));
      StrCopy (pcTmpVal1, PAnsiChar(strPM));
    end;
    FillChar(pcTmpVal2^, TEMPVAR_LENGTH, #0);
    if (Length (cSerialNumber) > 0)
    then begin
      strSN := AnsiString (trim (cSerialNumber));
      StrCopy (pcTmpVal2, PAnsiChar(strSN));
    end;
    iRetVal := _SEPIA2_USB_OpenDevice (iDevIdx, pcTmpVal1, pcTmpVal2);
    cProductModel := string (pcTmpVal1);
    cSerialNumber := string (pcTmpVal2);
    SEPIA2_USB_OpenDevice := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_USB_OpenDevice


  function SEPIA2_USB_CloseDevice (iDevIdx: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_USB_CloseDevice';
    DebugOut (1, strFkt);
    iRetVal :=  _SEPIA2_USB_CloseDevice (iDevIdx);
    SEPIA2_USB_CloseDevice :=  iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_USB_CloseDevice


  function SEPIA2_USB_GetStrDescriptor (iDevIdx: integer; var cDescriptor: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_USB_GetStrDescriptor';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_USB_GetStrDescriptor (iDevIdx, pcTmpVal1);
    cDescriptor := string(pcTmpVal1);
    SEPIA2_USB_GetStrDescriptor := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_USB_GetStrDescriptor


  function SEPIA2_USB_OpenGetSerNumAndClose (iDevIdx: integer; var cProductModel: string; var cSerialNumber: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    strPM   : AnsiString;
    strSN   : AnsiString;
  begin
    strFkt  := 'SEPIA2_USB_OpenGetSerNumAndClose';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    if (Length (cProductModel) > 0)
    then begin
      strPM := AnsiString (cProductModel);
      StrCopy (pcTmpVal1, PAnsiChar(strPM));
    end;
    FillChar(pcTmpVal2^, TEMPVAR_LENGTH, #0);
    if (Length (cSerialNumber) > 0)
    then begin
      strSN := AnsiString (cSerialNumber);
      StrCopy (pcTmpVal2, PAnsiChar(strSN));
    end;
    iRetVal := _SEPIA2_USB_OpenGetSerNumAndClose (iDevIdx, pcTmpVal1, pcTmpVal2);
    cProductModel := string(pcTmpVal1);
    cSerialNumber := string(pcTmpVal2);
    SEPIA2_USB_OpenGetSerNumAndClose := iRetVal;
    DebugOut (-1, strFkt + ' returns cProductModel = ', '"' + cProductModel + '"');
    DebugOut (-1, strFkt + ' returns cSerialNumber = ', '"' + cSerialNumber + '"');
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_USB_OpenDevice


  function SEPIA2_FWR_GetVersion (iDevIdx: integer; var cFWVersion: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_FWR_GetVersion';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_FWR_GetVersion (iDevIdx, pcTmpVal1);
    cFWVersion := string(pcTmpVal1);
    SEPIA2_FWR_GetVersion := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_GetVersion


  function SEPIA2_FWR_GetLastError (iDevIdx: integer; var iErrCode, iPhase, iLocation, iSlot: integer; var cCondition: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_FWR_GetLastError';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_FWR_GetLastError (iDevIdx, iErrCode, iPhase, iLocation, iSlot, pcTmpVal1);
    cCondition := string(pcTmpVal1);
    SEPIA2_FWR_GetLastError := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_GetLastError


  function SEPIA2_FWR_DecodeErrPhaseName (iErrPhase: integer; var cErrorPhase: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_FWR_DecodeErrPhaseName';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_FWR_DecodeErrPhaseName (iErrPhase, pcTmpVal1);
    cErrorPhase := string(pcTmpVal1);
    SEPIA2_FWR_DecodeErrPhaseName := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_DecodeErrPhaseName


  function SEPIA2_FWR_GetModuleMap (iDevIdx: integer; bPerformRestart: boolean; var iModuleCount: integer) : integer;
  var
    iRetVal         : integer;
    strFkt          : string;
    iPerformRestart : integer;
  begin
    strFkt  := 'SEPIA2_FWR_GetModuleMap';
    DebugOut (1, strFkt);
    iPerformRestart := ifthen (bPerformRestart, 1, 0);
    iRetVal := _SEPIA2_FWR_GetModuleMap (iDevIdx, iPerformRestart, iModuleCount);
    SEPIA2_FWR_GetModuleMap := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_GetModuleMap


  function SEPIA2_FWR_GetModuleInfoByMapIdx (iDevIdx, iMapIdx: integer; var iSlotId: integer; var bIsPrimary, bIsBackPlane, bHasUptimeCounter: boolean) : integer;
  var
    iRetVal              : integer;
    strFkt               : string;
    byteIsPrimary        : byte;
    byteIsBackPlane      : byte;
    byteHasUptimeCounter : byte;
  begin
    strFkt  := 'SEPIA2_FWR_GetModuleInfoByMapIdx';
    DebugOut (1, strFkt);
    iRetVal           := _SEPIA2_FWR_GetModuleInfoByMapIdx (iDevIdx, iMapIdx, iSlotId, byteIsPrimary, byteIsBackPlane, byteHasUptimeCounter);
    bIsPrimary        := (byteIsPrimary <> 0);
    bIsBackPlane      := (byteIsBackPlane <> 0);
    bHasUptimeCounter := (byteHasUptimeCounter <> 0);
    SEPIA2_FWR_GetModuleInfoByMapIdx := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_GetModuleInfoByMapIdx


  function SEPIA2_FWR_GetUptimeInfoByMapIdx (iDevIdx, iMapIdx: integer; var dwMainPowerUp, dwActivePowerUp, dwScaledPowerUp: cardinal) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_FWR_GetUptimeInfoByMapIdx';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_FWR_GetUptimeInfoByMapIdx (iDevIdx, iMapIdx, dwMainPowerUp, dwActivePowerUp, dwScaledPowerUp);
    SEPIA2_FWR_GetUptimeInfoByMapIdx := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_GetUptimeInfoByMapIdx


  function SEPIA2_FWR_FreeModuleMap (iDevIdx: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_FWR_FreeModuleMap';
    DebugOut (1, strFkt);
    iRetVal :=  _SEPIA2_FWR_FreeModuleMap (iDevIdx);
    SEPIA2_FWR_FreeModuleMap := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_FreeModuleMap


  function SEPIA2_COM_DecodeModuleType (iModuleType: integer; var cModuleType: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_COM_DecodeModuleType';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_COM_DecodeModuleType (iModuleType, pcTmpVal1);
    cModuleType := string(pcTmpVal1);
    SEPIA2_COM_DecodeModuleType := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_DecodeModuleType


  function SEPIA2_COM_DecodeModuleTypeAbbr (iModuleType: integer; var cModuleTypeAbbr: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_COM_DecodeModuleTypeAbbr';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_COM_DecodeModuleTypeAbbr (iModuleType, pcTmpVal1);
    cModuleTypeAbbr := string(pcTmpVal1);
    SEPIA2_COM_DecodeModuleTypeAbbr := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_DecodeModuleTypeAbbr


  function SEPIA2_COM_HasSecondaryModule (iDevIdx, iSlotId: integer; var bHasSecondary: boolean) : integer;
  var
    iRetVal       : integer;
    strFkt        : string;
    iHasSecondary : integer;
  begin
    strFkt  := 'SEPIA2_COM_HasSecondaryModule';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_HasSecondaryModule (iDevIdx, iSlotId, iHasSecondary);
    bHasSecondary := (iHasSecondary <> 0);
    SEPIA2_COM_HasSecondaryModule := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_HasSecondaryModule


  function SEPIA2_COM_GetModuleType (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var iModuleType: integer) : integer;
  // here we have to consider a special treatment for the iSlotId:
  // iSlotId = -1        means:    "module type of the backplane" (i.e. the Sepia2 frame as a whole)
  var
    iRetVal     : integer;
    strFkt      : string;
    iGetPrimary : integer;
  begin
    strFkt  := 'SEPIA2_COM_GetModuleType';
    DebugOut (1, strFkt);
    iGetPrimary := ifthen (bGetPrimary, 1, 0);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, iGetPrimary, iModuleType);
    SEPIA2_COM_GetModuleType := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_GetModuleType


  function SEPIA2_COM_GetSerialNumber (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var cSerialNumber: string) : integer;
  var
    iRetVal    : integer;
    strFkt     : string;
    iGetPrimary: integer;
  begin
    strFkt  := 'SEPIA2_COM_GetSerialNumber';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iGetPrimary := ifthen (bGetPrimary, 1, 0);
    iRetVal := _SEPIA2_COM_GetSerialNumber (iDevIdx, iSlotId, iGetPrimary, pcTmpVal1);
    cSerialNumber := string(pcTmpVal1);
    SEPIA2_COM_GetSerialNumber := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_GetSerialNumber


  function SEPIA2_COM_GetPresetInfo (iDevIdx, iSlotId: integer; bGetPrimary: boolean; iPresetNr: integer; var bPresetIsSet: boolean; var cPresetMemo: string) : integer;
  var
    iRetVal         : integer;
    strFkt          : string;
    iGetPrimary     : integer;
    bytePresetIsSet : byte;
  begin
    strFkt  := 'SEPIA2_COM_GetPresetInfo';
    DebugOut (1, strFkt);
    iGetPrimary := ifthen (bGetPrimary, 1, 0);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_COM_GetPresetInfo (iDevIdx, iSlotId, iGetPrimary, iPresetNr, bytePresetIsSet, pcTmpVal1);
    cPresetMemo := string(pcTmpVal1);
    bPresetIsSet := (bytePresetIsSet <> 0);
    SEPIA2_COM_GetPresetInfo := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_GetPresetInfo


  function SEPIA2_COM_RecallPreset (iDevIdx, iSlotId: integer; bGetPrimary: boolean; iPresetNr: integer) : integer;
  var
    iRetVal     : integer;
    strFkt      : string;
    iGetPrimary : integer;
  begin
    strFkt  := 'SEPIA2_COM_RecallPreset';
    DebugOut (1, strFkt);
    iGetPrimary := ifthen (bGetPrimary, 1, 0);
    iRetVal := _SEPIA2_COM_RecallPreset (iDevIdx, iSlotId, iGetPrimary, iPresetNr);
    SEPIA2_COM_RecallPreset := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_RecallPreset


  function SEPIA2_COM_SaveAsPreset (iDevIdx, iSlotId: integer; bSetPrimary: boolean; iPresetNr: integer; const cPresetMemo: string) : integer;
  var
    iRetVal         : integer;
    strFkt          : string;
    iSetPrimary     : integer;
  begin
    strFkt  := 'SEPIA2_COM_SaveAsPreset';
    DebugOut (1, strFkt);
    iSetPrimary := ifthen (bSetPrimary, 1, 0);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    StrCopy (pcTmpVal1, PAnsiChar (@AnsiString(cPresetMemo + #0)[1]));
    iRetVal := _SEPIA2_COM_SaveAsPreset (iDevIdx, iSlotId, iSetPrimary, iPresetNr, pcTmpVal1);
    SEPIA2_COM_SaveAsPreset := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_SaveAsPreset


  function SEPIA2_COM_IsWritableModule (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var bIsWritable: boolean) : integer;
  var
    iRetVal        : integer;
    strFkt         : string;
    iGetPrimary    : integer;
    byteIsWritable : byte;
  begin
    strFkt  := 'SEPIA2_COM_IsWritableModule';
    DebugOut (1, strFkt);
    iGetPrimary := ifthen (bGetPrimary, 1, 0);
    iRetVal := _SEPIA2_COM_IsWritableModule (iDevIdx, iSlotId, iGetPrimary, byteIsWritable);
    SEPIA2_COM_IsWritableModule := iRetVal;
    bIsWritable := (byteIsWritable <> 0);
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_IsWritableModule


  function SEPIA2_COM_UpdateModuleData (iDevIdx, iSlotId: integer; bSetPrimary: boolean; cFileName: string) : integer;
  var
    iRetVal     : integer;
    strFkt      : string;
    strTemp     : AnsiString;
    iSetPrimary : integer;
  begin
    strFkt  := 'SEPIA2_COM_UpdateModuleData';
    DebugOut (1, strFkt);
    iSetPrimary := ifthen (bSetPrimary, 1, 0);
    strTemp := AnsiString (cFileName);
    iRetVal := _SEPIA2_COM_UpdateModuleData (iDevIdx, iSlotId, iSetPrimary, PAnsiChar (strTemp));
    SEPIA2_COM_UpdateModuleData := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_UpdateModuleData


  function SEPIA2_SCM_GetPowerAndLaserLEDS (iDevIdx, iSlotId: integer; var bPowerLED, bLaserActiveLED: boolean) : integer;
  var
    iRetVal            : integer;
    strFkt             : string;
    bytePowerLED       : byte;
    byteLaserActiveLED : byte;
  begin
    strFkt  := 'SEPIA2_SCM_GetPowerAndLaserLEDS';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SCM_GetPowerAndLaserLEDS (iDevIdx, iSlotId, bytePowerLED, byteLaserActiveLED);
    bPowerLED       := (bytePowerLED <> 0);
    bLaserActiveLED := (byteLaserActiveLED <> 0);
    SEPIA2_SCM_GetPowerAndLaserLEDS := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // _SEPIA2_SCM_GetPowerAndLaserLEDS


  function SEPIA2_SCM_GetLaserLocked (iDevIdx, iSlotId: integer; var bLocked: boolean) : integer;
  var
    iRetVal    : integer;
    strFkt     : string;
    byteLocked : byte;
  begin
    strFkt  := 'SEPIA2_SCM_GetLaserLocked';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SCM_GetLaserLocked (iDevIdx, iSlotId, byteLocked);
    bLocked := (byteLocked <> 0);
    SEPIA2_SCM_GetLaserLocked := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SCM_GetLaserLocked


  function SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId: integer; var bSoftLocked: boolean) : integer;
  var
    iRetVal        : integer;
    strFkt         : string;
    byteSoftLocked : byte;
  begin
    strFkt  := 'SEPIA2_SCM_GetLaserSoftLock';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId, byteSoftLocked);
    bSoftLocked := (byteSoftLocked <> 0);
    SEPIA2_SCM_GetLaserSoftLock := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SCM_GetLaserSoftLock


  function SEPIA2_SCM_SetLaserSoftLock (iDevIdx, iSlotId: integer; bSoftLocked: boolean) : integer;
  var
    iRetVal        : integer;
    strFkt         : string;
    byteSoftLocked : byte;
  begin
    strFkt  := 'SEPIA2_SCM_SetLaserSoftLock';
    DebugOut (1, strFkt);
    byteSoftLocked := ifthen (bSoftLocked, 1, 0);
    iRetVal := _SEPIA2_SCM_SetLaserSoftLock (iDevIdx, iSlotId, byteSoftLocked);
    SEPIA2_SCM_SetLaserSoftLock := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SCM_SetLaserSoftLock


  function SEPIA2_SLM_DecodeFreqTrigMode (iFreq: integer; var cFreqTrigMode: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SLM_DecodeFreqTrigMode';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_SLM_DecodeFreqTrigMode (iFreq, pcTmpVal1);
    cFreqTrigMode := string(pcTmpVal1);
    SEPIA2_SLM_DecodeFreqTrigMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_DecodeFreqTrigMode


  function SEPIA2_SLM_DecodeHeadType (iHeadType: integer; var cHeadType: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SLM_DecodeHeadType';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_SLM_DecodeHeadType (iHeadType, pcTmpVal1);
    cHeadType := string(pcTmpVal1);
    SEPIA2_SLM_DecodeHeadType := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_DecodeHeadType


  function SEPIA2_SLM_GetParameters (iDevIdx, iSlotId: integer; var iFreq: integer; var bPulseMode: boolean; var iHead: integer; var byteIntensity: byte) : integer;
  // deprecated  : SEPIA2_SLM_GetParameters;
  // use instead : SEPIA2_SLM_GetIntensityFineStep, SEPIA2_SLM_GetPulseParameters
  var
    iRetVal       : integer;
    strFkt        : string;
    bytePulseMode : byte;
  begin
    strFkt  := 'SEPIA2_SLM_GetParameters';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SLM_GetParameters (iDevIdx, iSlotId, iFreq, bytePulseMode, iHead, byteIntensity);
    bPulseMode := (bytePulseMode <> 0);
    SEPIA2_SLM_GetParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_GetParameters


  function SEPIA2_SLM_SetParameters (iDevIdx, iSlotId, iFreq: integer; bPulseMode: boolean; byteIntensity: byte) : integer;
  // deprecated  : SEPIA2_SLM_SetParameters;
  // use instead : SEPIA2_SLM_SetIntensityFineStep, SEPIA2_SLM_SetPulseParameters
  var
    iRetVal       : integer;
    strFkt        : string;
    bytePulseMode : byte;
  begin
    strFkt  := 'SEPIA2_SLM_SetParameters';
    DebugOut (1, strFkt);
    bytePulseMode := ifthen (bPulseMode, 1, 0);
    iRetVal := _SEPIA2_SLM_SetParameters (iDevIdx, iSlotId, iFreq, bytePulseMode, byteIntensity);
    SEPIA2_SLM_SetParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_SetParameters


  function SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSlotId: integer; var wIntensity: word) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SLM_GetIntensityFineStep';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSlotId, wIntensity);
    SEPIA2_SLM_GetIntensityFineStep := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_GetIntensityFineStep


  function SEPIA2_SLM_SetIntensityFineStep (iDevIdx, iSlotId: integer; wIntensity: word) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SLM_SetIntensityFineStep';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SLM_SetIntensityFineStep (iDevIdx, iSlotId, wIntensity);
    SEPIA2_SLM_SetIntensityFineStep := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_SetIntensityFineStep


  function SEPIA2_SLM_GetPulseParameters (iDevIdx, iSlotId: integer; var iFreq: integer; var bPulseMode: boolean; var iHeadType: integer) : integer;
  var
    iRetVal       : integer;
    strFkt        : string;
    bytePulseMode : byte;
  begin
    strFkt  := 'SEPIA2_SLM_GetPulseParameters';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SLM_GetPulseParameters (iDevIdx, iSlotId, iFreq, bytePulseMode, iHeadType);
    bPulseMode := (bytePulseMode <> 0);
    SEPIA2_SLM_GetPulseParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_GetPulseParameters


  function SEPIA2_SLM_SetPulseParameters (iDevIdx, iSlotId: integer; iFreq: integer; bPulseMode: boolean) : integer;
  var
    iRetVal       : integer;
    strFkt        : string;
    bytePulseMode : byte;
  begin
    strFkt  := 'SEPIA2_SLM_SetPulseParameters';
    DebugOut (1, strFkt);
    bytePulseMode := ifthen (bPulseMode, 1, 0);
    iRetVal := _SEPIA2_SLM_SetPulseParameters (iDevIdx, iSlotId, iFreq, bytePulseMode);
    SEPIA2_SLM_SetPulseParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_SetPulseParameters


  function SEPIA2_SML_DecodeHeadType (iHeadType: integer; var cHeadType: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SML_DecodeHeadType';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_SML_DecodeHeadType (iHeadType, pcTmpVal1);
    cHeadType := string(pcTmpVal1);
    SEPIA2_SML_DecodeHeadType := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SML_DecodeHeadType


  function SEPIA2_SML_GetParameters (iDevIdx, iSlotId: integer; var bPulseMode: boolean; var iHead: integer; var byteIntensity: byte) : integer;
  var
    iRetVal       : integer;
    strFkt        : string;
    bytePulseMode : byte;
  begin
    strFkt  := 'SEPIA2_SML_GetParameters';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SML_GetParameters (iDevIdx, iSlotId, bytePulseMode, iHead, byteIntensity);
    bPulseMode := (bytePulseMode <> 0);
    SEPIA2_SML_GetParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SML_GetParameters


  function SEPIA2_SML_SetParameters (iDevIdx, iSlotId: integer; bPulseMode: boolean; byteIntensity: byte) : integer;
  var
    iRetVal       : integer;
    strFkt        : string;
    bytePulseMode : byte;
  begin
    strFkt  := 'SEPIA2_SML_SetParameters';
    DebugOut (1, strFkt);
    bytePulseMode := ifthen (bPulseMode, 1, 0);
    iRetVal := _SEPIA2_SML_SetParameters (iDevIdx, iSlotId, bytePulseMode, byteIntensity);
    SEPIA2_SML_SetParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SML_SetParameters


  function SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx: integer; var cFreqTrigMode: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    iMType  : integer;
  begin
    strFkt  := 'SEPIA2_SOM_DecodeFreqTrigMode';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, pcTmpVal1);
    end;
    cFreqTrigMode := string(pcTmpVal1);
    SEPIA2_SOM_DecodeFreqTrigMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_DecodeFreqTrigMode


  function SEPIA2_SOM_GetFreqTrigMode (iDevIdx, iSlotId: integer; var iFreqTrigIdx: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    iMType  : integer;
  begin
    strFkt  := 'SEPIA2_SOM_GetFreqTrigMode';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_GetFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx);
    end;
    SEPIA2_SOM_GetFreqTrigMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetFreqTrigMode


  function SEPIA2_SOM_SetFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    iMType  : integer;
  begin
    strFkt  := 'SEPIA2_SOM_SetFreqTrigMode';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_SetFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx);
    end;
    SEPIA2_SOM_SetFreqTrigMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_SetFreqTrigMode


  function SEPIA2_SOM_GetTriggerRange (iDevIdx, iSlotId: integer; var iMilliVoltLow, iMilliVoltHigh: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    iMType  : integer;
  begin
    strFkt  := 'SEPIA2_SOM_GetTriggerRange';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_GetTriggerRange (iDevIdx, iSlotId, iMilliVoltLow, iMilliVoltHigh);
    end;
    SEPIA2_SOM_GetTriggerRange := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetTriggerRange


  function SEPIA2_SOM_GetTriggerLevel (iDevIdx, iSlotId: integer; var iMilliVolt: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    iMType  : integer;
  begin
    strFkt  := 'SEPIA2_SOM_GetTriggerLevel';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_GetTriggerLevel (iDevIdx, iSlotId, iMilliVolt);
    end;
    SEPIA2_SOM_GetTriggerLevel := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetTriggerLevel


  function SEPIA2_SOM_SetTriggerLevel (iDevIdx, iSlotId, iMilliVolt: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    iMType  : integer;
  begin
    strFkt  := 'SEPIA2_SOM_SetTriggerLevel';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_SetTriggerLevel (iDevIdx, iSlotId, iMilliVolt);
    end;
    SEPIA2_SOM_SetTriggerLevel := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_SetTriggerLevel


  function SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSlotId: integer; var lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8: longint) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    iMType  : integer;
  begin
    strFkt  := 'SEPIA2_SOM_GetBurstLengthArray';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSlotId, lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8);
    end;
    SEPIA2_SOM_GetBurstLengthArray := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetBurstLengthArray


  function SEPIA2_SOM_SetBurstLengthArray (iDevIdx, iSlotId: integer; lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8: longint) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    iMType  : integer;
  begin
    strFkt  := 'SEPIA2_SOM_SetBurstLengthArray';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_SetBurstLengthArray (iDevIdx, iSlotId, lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8);
    end;
    SEPIA2_SOM_SetBurstLengthArray := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_SetBurstLengthArray


  function SEPIA2_SOM_GetOutNSyncEnable (iDevIdx, iSlotId: integer; var byteOutEnable, byteSyncEnable: byte; var bSyncInverse: boolean) : integer;
  var
    iRetVal         : integer;
    strFkt          : string;
    iMType          : integer;
    byteSyncInverse : byte;
  begin
    strFkt  := 'SEPIA2_SOM_GetOutNSyncEnable';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_GetOutNSyncEnable (iDevIdx, iSlotId, byteOutEnable, byteSyncEnable, byteSyncInverse);
    end;
    bSyncInverse := (byteSyncInverse <> 0);
    SEPIA2_SOM_GetOutNSyncEnable := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetOutNSyncEnable


  function SEPIA2_SOM_SetOutNSyncEnable (iDevIdx, iSlotId: integer; byteOutEnable, byteSyncEnable: byte; bSyncInverse: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    iMType  : integer;
    byteSyncInverse : byte;
  begin
    strFkt  := 'SEPIA2_SOM_SetOutNSyncEnable';
    DebugOut (1, strFkt);
    byteSyncInverse := ifthen (bSyncInverse, 1, 0);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_SetOutNSyncEnable (iDevIdx, iSlotId, byteOutEnable, byteSyncEnable, byteSyncInverse);
    end;
    SEPIA2_SOM_SetOutNSyncEnable := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_SetOutNSyncEnable


  function SEPIA2_SOM_GetBurstValues (iDevIdx, iSlotId: integer; var wDivider: word; var bytePreSync, byteSyncMask: byte) : integer;
  // this is a unified function for both, SOM and SOMD as well
  var
    iRetVal     : integer;
    iMType      : integer;
    byteDivider : byte;
    strFkt      : string;
  begin
    strFkt  := 'SEPIA2_SOM_GetBurstValues';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else  begin
        iRetVal  := _SEPIA2_SOM_GetBurstValues (iDevIdx, iSlotId, byteDivider, bytePreSync, byteSyncMask);
        wDivider := $0000 or byteDivider;
      end;
    end;
    SEPIA2_SOM_GetBurstValues := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetBurstValues


  function SEPIA2_SOM_SetBurstValues (iDevIdx, iSlotId: integer; wDivider: word; bytePreSync, byteSyncMask: byte) : integer;
  // this is a unified function for both, SOM and SOMD as well
  var
    iRetVal     : integer;
    iMType      : integer;
    byteDivider : byte;
    strFkt      : string;
  begin
    strFkt  := 'SEPIA2_SOM_SetBurstValues';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else  begin
        byteDivider := EnsureRange (wDivider, 1, 255);
        iRetVal := _SEPIA2_SOM_SetBurstValues (iDevIdx, iSlotId, byteDivider, bytePreSync, byteSyncMask);
      end;
    end;
    SEPIA2_SOM_SetBurstValues := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_SetBurstValues


  function SEPIA2_SOM_DecodeAUXINSequencerCtrl (iDevIdx, iSlotId: integer; iAuxInCtrl: integer; var cSequencerCtrl: string) : integer;
  var
    iRetVal          : integer;
    strFkt           : string;
    iMType           : integer;
    iAuxInCtrl_      : integer;
  begin
    strFkt  := 'SEPIA2_SOM_DecodeAUXINSequencerCtrl';
    DebugOut (1, strFkt);
    iAuxInCtrl_      := EnsureRange (iAuxInCtrl, 0, 255);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_DecodeAUXINSequencerCtrl (iAuxInCtrl_, pcTmpVal1);
    end;
    cSequencerCtrl := string (pcTmpVal1);
    SEPIA2_SOM_DecodeAUXINSequencerCtrl := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_DecodeAUXINSequencerCtrl


  function SEPIA2_SOM_GetAUXIOSequencerCtrl (iDevIdx, iSlotId: integer; var bAUXOutEnable: boolean; var byteAUXInSequencerCtrl: byte) : integer;
  var
    iRetVal          : integer;
    strFkt           : string;
    iMType           : integer;
    byteAUXOutEnable : byte;
  begin
    strFkt  := 'SEPIA2_SOM_GetAUXIOSequencerCtrl';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_GetAUXIOSequencerCtrl (iDevIdx, iSlotId, byteAUXOutEnable, byteAUXInSequencerCtrl);
    end;
    bAUXOutEnable := (byteAUXOutEnable <> 0);
    SEPIA2_SOM_GetAUXIOSequencerCtrl := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetAUXIOSequencerCtrl


  function SEPIA2_SOM_SetAUXIOSequencerCtrl (iDevIdx, iSlotId: integer; bAUXOutEnable: boolean; byteAUXInSequencerCtrl: byte) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    iMType  : integer;
    byteAUXOutEnable : byte;
  begin
    strFkt  := 'SEPIA2_SOM_SetAUXIOSequencerCtrl';
    DebugOut (1, strFkt);
    byteAUXOutEnable := ifthen (bAUXOutEnable, 1, 0);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    case iMType of
      SEPIA2OBJECT_SOMD:
        iRetVal := SEPIA2_ERR_LIB_UNKNOWN_FUNCTION;
      else
        iRetVal := _SEPIA2_SOM_SetAUXIOSequencerCtrl (iDevIdx, iSlotId, byteAUXOutEnable, byteAUXInSequencerCtrl);
    end;
    SEPIA2_SOM_SetAUXIOSequencerCtrl := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_SetAUXIOSequencerCtrl


  function SEPIA2_SWM_DecodeRangeIdx (iDevIdx, iSlotId: integer; iRangeIdx: integer; var iUpperLimit: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWM_DecodeRangeIdx';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWM_DecodeRangeIdx (iDevIdx, iSlotId, iRangeIdx, iUpperLimit);
    SEPIA2_SWM_DecodeRangeIdx := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWM_DecodeRangeIdx


  function SEPIA2_SWM_GetUIConstants (iDevIdx, iSlotId: integer; var byteTBIdxCount: byte; var wMaxAmplitude, wMaxSlewRate, wExpRampEffect, wMinUserValue, wMaxUserValue, wUserResolution: word) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWM_GetUIConstants';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWM_GetUIConstants (iDevIdx, iSlotId, byteTBIdxCount, wMaxAmplitude, wMaxSlewRate, wExpRampEffect, wMinUserValue, wMaxUserValue, wUserResolution);
    SEPIA2_SWM_GetUIConstants := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWM_GetUIConstants


  function SEPIA2_SWM_GetCurveParams (iDevIdx, iSlotId: integer; iCurveIdx: integer; var byteTBIdx: byte; var wPAPml, wRRPml, wPSPml, wRSPml, wWSPml: word) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWM_GetCurveParams';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWM_GetCurveParams (iDevIdx, iSlotId, iCurveIdx, byteTBIdx, wPAPml, wRRPml, wPSPml, wRSPml, wWSPml);
    SEPIA2_SWM_GetCurveParams := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWM_GetCurveParams


  function SEPIA2_SWM_SetCurveParams (iDevIdx, iSlotId: integer; iCurveIdx: integer; byteTBIdx: byte; wPAPml, wRRPml, wPSPml, wRSPml, wWSPml: word) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWM_SetCurveParams';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWM_SetCurveParams (iDevIdx, iSlotId, iCurveIdx, byteTBIdx, wPAPml, wRRPml, wPSPml, wRSPml, wWSPml);
    SEPIA2_SWM_SetCurveParams := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWM_SetCurveParams


  function SEPIA2_SWM_GetCalTableVal (iDevIdx, iSlotId: integer; cTableName: string; byteTabRow, byteTabCol: byte; var wValue: word) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    strTN   : AnsiString;
  begin
    strFkt  := 'SEPIA2_SWM_GetCalTableVal';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    if (Length (cTableName) > 0)
    then begin
      strTN := AnsiString (cTableName);
      StrCopy (pcTmpVal1, PAnsiChar(strTN));
    end;
    iRetVal := _SEPIA2_SWM_GetCalTableVal (iDevIdx, iSlotId, pcTmpVal1, byteTabRow, byteTabCol, wValue);
    SEPIA2_SWM_GetCalTableVal := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWM_GetCalTableVal


  function SEPIA2_SPM_GetFWVersion (iDevIdx, iSlotId: integer; var FWVersion: T_SepiaModules_FWVersion) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SPM_GetFWVersion';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetFWVersion (iDevIdx, iSlotId, FWVersion.ulVersion);
    SEPIA2_SPM_GetFWVersion := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetFWVersion


  function SEPIA2_SPM_DecodeModuleState (wModuleState: Word; var cModuleState: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SPM_DecodeModuleState';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_SPM_DecodeModuleState (wModuleState, pcTmpVal1);
    cModuleState := string(pcTmpVal1);
    SEPIA2_SPM_DecodeModuleState := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_DecodeModuleState


  function SEPIA2_SPM_GetManualPumpCurrent (iDevIdx, iSlotId: integer; var wPumpCurrent1, wPumpCurrent2, wPumpCurrent3: word) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SPM_GetManualPumpCurrent';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetManualPumpCurrent (iDevIdx, iSlotId, wPumpCurrent1, wPumpCurrent2, wPumpCurrent3);
    SEPIA2_SPM_GetManualPumpCurrent := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetManualPumpCurrent


  function SEPIA2_SPM_GetControlMode (iDevIdx, iSlotId: integer; var bManualMode: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    byteManualMode: byte;
  begin
    strFkt  := 'SEPIA2_SPM_GetControlMode';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetControlMode (iDevIdx, iSlotId, byteManualMode);
    if (iRetVal = SEPIA2_ERR_NO_ERROR)
    then begin
      bManualMode := (byteManualMode <> SEPIA2_API_SPM_CONTROLMODE_AUTOMATIC);
    end;
    SEPIA2_SPM_GetControlMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetControlMode


  function SEPIA2_SPM_GetPumpCtrlParams (iDevIdx, iSlotId: integer; bIsPumpStateEco: boolean; var PumpCtrlParams: T_SPM_PumpCtrlParams) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    bytePumpState: byte;
  begin
    strFkt  := 'SEPIA2_SPM_GetPumpCtrlParams';
    DebugOut (1, strFkt);
    bytePumpState := ifthen (bIsPumpStateEco, SEPIA2_API_SPM_PUMPSTATE_ECOMODE, SEPIA2_API_SPM_PUMPSTATE_BOOSTMODE);
    iRetVal := _SEPIA2_SPM_GetPumpCtrlParams (iDevIdx, iSlotId, bytePumpState, PumpCtrlParams);
    SEPIA2_SPM_GetPumpCtrlParams := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetPumpCtrlParams


  function SEPIA2_SPM_GetPhotoDiodeCurrents (iDevIdx, iSlotId: integer; var iPhDCurrent1, iPhDCurrent2, iPhDCurrent3: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SPM_GetPhotoDiodeCurrents';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetPhotoDiodeCurrents (iDevIdx, iSlotId, iPhDCurrent1, iPhDCurrent2, iPhDCurrent3);
    SEPIA2_SPM_GetPhotoDiodeCurrents := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetPhotoDiodeCurrents


  function SEPIA2_SPM_GetPumpCurrents (iDevIdx, iSlotId: integer; var iPumpCurrent1, iPumpCurrent2, iPumpCurrent3: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SPM_GetPumpCurrents';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetPumpCurrents (iDevIdx, iSlotId, iPumpCurrent1, iPumpCurrent2, iPumpCurrent3);
    SEPIA2_SPM_GetPumpCurrents := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetPumpCurrents



  function SEPIA2_SPM_GetSensorData (iDevIdx, iSlotId: integer; var SensorData: T_SPM_SensorData) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SPM_GetSensorData';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetSensorData (iDevIdx, iSlotId, SensorData);
    SEPIA2_SPM_GetSensorData := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetSensorData


  function SEPIA2_SPM_GetTemperatureAdjust (iDevIdx, iSlotId: integer; var Temperatures: T_SPM_Temperatures) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SPM_GetTemperatureAdjust';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetTemperatureAdjust (iDevIdx, iSlotId, Temperatures);
    SEPIA2_SPM_GetTemperatureAdjust := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetTemperatureAdjust


  function SEPIA2_SPM_GetUpTimePowerTable (iDevIdx, iSlotId: integer; bIsPumpStateEco: boolean; var UpTimePwrTable: T_SPM_UpTimePowerTable) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    bytePumpState: byte;
  begin
    strFkt  := 'SEPIA2_SPM_GetUpTimePowerTable';
    DebugOut (1, strFkt);
    bytePumpState := ifthen (bIsPumpStateEco, SEPIA2_API_SPM_PUMPSTATE_ECOMODE, SEPIA2_API_SPM_PUMPSTATE_BOOSTMODE);
    iRetVal := _SEPIA2_SPM_GetUpTimePowerTable (iDevIdx, iSlotId, bytePumpState, UpTimePwrTable);
    SEPIA2_SPM_GetUpTimePowerTable := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetUpTimePowerTable


  function SEPIA2_SPM_GetStatusError (iDevIdx, iSlotId: integer; var wModuleState: word; var iErrorCode: SmallInt) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SPM_GetStatusError';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetStatusError (iDevIdx, iSlotId, wModuleState, iErrorCode);
    SEPIA2_SPM_GetStatusError := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetStatusError


  function SEPIA2_SPM_UpdateFirmware (iDevIdx, iSlotId: integer; cFileName: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    strTemp : AnsiString;
  begin
    strFkt  := 'SEPIA2_SPM_UpdateFirmware';
    DebugOut (1, strFkt);
    strTemp := AnsiString (cFileName);
    iRetVal := _SEPIA2_SPM_UpdateFirmware (iDevIdx, iSlotId, PAnsiChar (strTemp));
    SEPIA2_SPM_UpdateFirmware := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_UpdateFirmware


  function SEPIA2_SPM_SetFRAMWriteProtect (iDevIdx, iSlotId: integer; bWriteProtect: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    byteWriteProtect : Byte;
  begin
    strFkt  := 'SEPIA2_SPM_SetFRAMWriteProtect';
    DebugOut (1, strFkt);
    byteWriteProtect := Byte (ifthen (bWriteProtect, SEPIA2_API_SPM_FRAM_WRITE_PROTECTED, SEPIA2_API_SPM_FRAM_WRITE_ENABLED));
    iRetVal := _SEPIA2_SPM_SetFRAMWriteProtect (iDevIdx, iSlotId, byteWriteProtect);
    SEPIA2_SPM_SetFRAMWriteProtect := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_SetFRAMWriteProtect


  function SEPIA2_SPM_GetFiberAmplifierFail (iDevIdx, iSlotId: integer; var bFiberAmpFail: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    byteFiberAmpFail : byte;
  begin
    strFkt  := 'SEPIA2_SPM_GetFiberAmplifierFail';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetFiberAmplifierFail (iDevIdx, iSlotId, byteFiberAmpFail);
    if (iRetVal = SEPIA2_ERR_NO_ERROR)
    then begin
      bFiberAmpFail := (byteFiberAmpFail <> SEPIA2_API_SPM_FIBERAMPLIFIER_OK);
    end;
    SEPIA2_SPM_GetFiberAmplifierFail := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetFiberAmplifierFail


  function SEPIA2_SPM_ResetFiberAmplifierFail (iDevIdx, iSlotId: integer; bFiberAmpFail: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    byteFiberAmpFail : byte;
  begin
    strFkt  := 'SEPIA2_SPM_ResetFiberAmplifierFail';
    DebugOut (1, strFkt);
    byteFiberAmpFail := ifthen (bFiberAmpFail, SEPIA2_API_SPM_FIBERAMPLIFIER_FAILURE, SEPIA2_API_SPM_FIBERAMPLIFIER_OK);
    iRetVal := _SEPIA2_SPM_ResetFiberAmplifierFail (iDevIdx, iSlotId, byteFiberAmpFail);
    SEPIA2_SPM_ResetFiberAmplifierFail := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_ResetFiberAmplifierFail


  function SEPIA2_SPM_GetPumpPowerState (iDevIdx, iSlotId: integer; var bIsPumpStateEco, bIsPumpModeDynamic: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    bytePumpState : byte;
    bytePumpMode  : byte;
  begin
    strFkt  := 'SEPIA2_SPM_GetPumpPowerState';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetPumpPowerState (iDevIdx, iSlotId, bytePumpState, bytePumpMode);
    if (iRetVal = SEPIA2_ERR_NO_ERROR)
    then begin
      bIsPumpStateEco    := (bytePumpState <> SEPIA2_API_SPM_PUMPSTATE_BOOSTMODE);
      bIsPumpModeDynamic := (bytePumpMode  <> SEPIA2_API_SPM_PUMPMODE_STATIC);
    end;
    SEPIA2_SPM_GetPumpPowerState := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetPumpPowerState


  function SEPIA2_SPM_SetPumpPowerState (iDevIdx, iSlotId: integer; bIsPumpStateEco, bIsPumpModeDynamic: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    bytePumpState: byte;
    bytePumpMode: byte;
  begin
    strFkt  := 'SEPIA2_SPM_SetPumpPowerState';
    DebugOut (1, strFkt);
    bytePumpState := ifthen (bIsPumpStateEco,    SEPIA2_API_SPM_PUMPSTATE_ECOMODE, SEPIA2_API_SPM_PUMPSTATE_BOOSTMODE);
    bytePumpMode  := ifthen (bIsPumpModeDynamic, SEPIA2_API_SPM_PUMPMODE_DYNAMIC,  SEPIA2_API_SPM_PUMPMODE_STATIC);
    iRetVal := _SEPIA2_SPM_SetPumpPowerState (iDevIdx, iSlotId, bytePumpState, bytePumpMode);
    SEPIA2_SPM_SetPumpPowerState := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_SetPumpPowerState


  function SEPIA2_SPM_GetOperationTimers (iDevIdx, iSlotId: integer; var dwMainPwrSw_Counter, dwUT_OverAll, dwUT_SinceDelivery, dwUT_SinceFibChg  : Cardinal) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SPM_GetOperationTimers';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetOperationTimers (iDevIdx, iSlotId, dwMainPwrSw_Counter, dwUT_OverAll, dwUT_SinceDelivery, dwUT_SinceFibChg);
    SEPIA2_SPM_GetOperationTimers := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetOperationTimers


  function SEPIA2_SWS_DecodeModuleType (iModuleType: integer; var cModuleType: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWS_DecodeModuleType';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_SWS_DecodeModuleType (iModuleType, pcTmpVal1);
    cModuleType := string(pcTmpVal1);
    SEPIA2_SWS_DecodeModuleType := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_DecodeModuleType


  function SEPIA2_SWS_DecodeModuleState (wModuleState: Word; var cModuleState: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWS_DecodeModuleState';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_SWS_DecodeModuleState (wModuleState, pcTmpVal1);
    cModuleState := string(pcTmpVal1);
    SEPIA2_SWS_DecodeModuleState := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_DecodeModuleState


  function SEPIA2_SWS_GetModuleType (iDevIdx, iSlotId: integer; var iModuleType: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWS_GetModuleType';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetModuleType (iDevIdx, iSlotId, iModuleType);
    SEPIA2_SWS_GetModuleType := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetModuleType


  function SEPIA2_SWS_GetStatusError (iDevIdx, iSlotId: integer; var wModuleState: word; var iErrorCode: SmallInt) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWS_GetStatusError';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetStatusError (iDevIdx, iSlotId, wModuleState, iErrorCode);
    SEPIA2_SWS_GetStatusError := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetStatusError


  function SEPIA2_SWS_GetParamRanges (iDevIdx, iSlotId: integer; var ulUpperWL, ulLowerWL, ulIncrWL, ulPPMToggleWL, ulUpperBW, ulLowerBW, ulIncrBW: Cardinal; var iUpperAtten, iLowerAtten, iIncrAtten: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWS_GetParamRanges';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetParamRanges (iDevIdx, iSlotId, ulUpperWL, ulLowerWL, ulIncrWL, ulPPMToggleWL, ulUpperBW, ulLowerBW, ulIncrBW, iUpperAtten, iLowerAtten, iIncrAtten);
    SEPIA2_SWS_GetParamRanges := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetParamRanges


  function SEPIA2_SWS_GetParameters (iDevIdx, iSlotId: integer; var ulWaveLength, ulBandWidth: Cardinal) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWS_GetParameters';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetParameters (iDevIdx, iSlotId, ulWaveLength, ulBandWidth);
    SEPIA2_SWS_GetParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetParameters


  function SEPIA2_SWS_SetParameters (iDevIdx, iSlotId: integer; ulWaveLength, ulBandWidth: Cardinal) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWS_SetParameters';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_SetParameters (iDevIdx, iSlotId, ulWaveLength, ulBandWidth);
    SEPIA2_SWS_SetParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_SetParameters


  function SEPIA2_SWS_GetIntensity (iDevIdx, iSlotId: integer; var ulIntensRaw: Cardinal; var fIntensity: Single) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWS_GetIntensity';
    DebugOut (1, strFkt);
    iREtVal := _SEPIA2_SWS_GetIntensity (iDevIdx, iSlotId, ulIntensRaw, fIntensity);
    SEPIA2_SWS_GetIntensity := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetIntensity


  function SEPIA2_SWS_GetFWVersion (iDevIdx, iSlotId: integer; var FWVersion: T_SepiaModules_FWVersion) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWS_GetFWVersion';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetFWVersion (iDevIdx, iSlotId, FWVersion.ulVersion);
    SEPIA2_SWS_GetFWVersion := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetFWVersion


  function SEPIA2_SWS_UpdateFirmware (iDevIdx, iSlotId: integer; cFileName: string) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    strTemp : AnsiString;
  begin
    strFkt  := 'SEPIA2_SWS_UpdateFirmware';
    DebugOut (1, strFkt);
    strTemp := AnsiString (cFileName);
    iRetVal := _SEPIA2_SWS_UpdateFirmware (iDevIdx, iSlotId, PAnsiChar (strTemp));
    SEPIA2_SWS_UpdateFirmware := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_UpdateFirmware


  function SEPIA2_SWS_SetFRAMWriteProtect (iDevIdx, iSlotId: integer; bWriteProtect: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    byteWriteProtect : Byte;
  begin
    strFkt  := 'SEPIA2_SWS_SetFRAMWriteProtect';
    DebugOut (1, strFkt);
    byteWriteProtect := Byte (ifthen (bWriteProtect, 1, 0));
    iRetVal := _SEPIA2_SWS_SetFRAMWriteProtect (iDevIdx, iSlotId, byteWriteProtect);
    SEPIA2_SWS_SetFRAMWriteProtect := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_SetFRAMWriteProtect


  function SEPIA2_SWS_GetBeamPos (iDevIdx, iSlotId: integer; var iBeamPosV, iBeamPosH: integer) : integer;
  var
    iRetVal  : integer;
    strFkt   : string;
    BeamPosV : SmallInt;
    BeamPosH : SmallInt;
  begin
    strFkt  := 'SEPIA2_SWS_GetBeamPos';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetBeamPos (iDevIdx, iSlotId, BeamPosV, BeamPosH);
    iBeamPosV := BeamPosV;
    iBeamPosH := BeamPosH;
    SEPIA2_SWS_GetBeamPos := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetBeamPos


  function SEPIA2_SWS_SetBeamPos (iDevIdx, iSlotId: integer; iBeamPosV, iBeamPosH: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    BeamPosV, BeamPosH : SmallInt;
  begin
    strFkt  := 'SEPIA2_SWS_SetBeamPos';
    DebugOut (1, strFkt);
    BeamPosV := SmallInt (EnsureRange (iBeamPosV, Low (SmallInt), High (SmallInt)));
    BeamPosH := SmallInt (EnsureRange (iBeamPosH, Low (SmallInt), High (SmallInt)));
    iRetVal := _SEPIA2_SWS_SetBeamPos (iDevIdx, iSlotId, BeamPosV, BeamPosH);
    SEPIA2_SWS_SetBeamPos := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_SetBeamPos


  function SEPIA2_SWS_SetCalibrationMode (iDevIdx, iSlotId: integer; bCalibrationMode: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    byteCalibrationMode : Byte;
  begin
    strFkt  := 'SEPIA2_SWS_SetCalibrationMode';
    DebugOut (1, strFkt);
    byteCalibrationMode := Byte (ifthen (bCalibrationMode, 1, 0));
    iRetVal := _SEPIA2_SWS_SetCalibrationMode (iDevIdx, iSlotId, byteCalibrationMode);
    SEPIA2_SWS_SetCalibrationMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_SetCalibrationMode


  function SEPIA2_SWS_GetCalTableSize (iDevIdx, iSlotId: integer; var wWLIdxCount, wBWIdxCount: word) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SWS_GetCalTableSize';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetCalTableSize (iDevIdx, iSlotId, wWLIdxCount, wBWIdxCount);
    SEPIA2_SWS_GetCalTableSize := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetCalTableSize


  function SEPIA2_SWS_GetCalPointInfo (iDevIdx, iSlotId: integer; iWLIdx, iBWIdx: integer; var ulWaveLength, ulBandWidth: Cardinal; var iBeamPosV, iBeamPosH: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    WLIdx,
    BWIdx,
    BeamPosV,
    BeamPosH : SmallInt;
  begin
    strFkt  := 'SEPIA2_SWS_GetCalPointInfo';
    DebugOut (1, strFkt);
    WLIdx    := SmallInt (EnsureRange (iWLIdx, -1, High (SmallInt)));
    BWIdx    := SmallInt (EnsureRange (iBWIdx, -1, High (SmallInt)));
    //
    iRetVal  := _SEPIA2_SWS_GetCalPointInfo (iDevIdx, iSlotId, WLIdx, BWIdx, ulWaveLength, ulBandWidth, BeamPosV, BeamPosH);
    //
    iBeamPosV := BeamPosV;
    iBeamPosH := BeamPosH;
    SEPIA2_SWS_GetCalPointInfo := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetCalPointInfo


  function SEPIA2_SWS_SetCalPointValues (iDevIdx, iSlotId: integer; iWLIdx, iBWIdx, iBeamPosV, iBeamPosH: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    WLIdx,
    BWIdx,
    BeamPosV,
    BeamPosH : SmallInt;
  begin
    strFkt  := 'SEPIA2_SWS_SetCalPointValues';
    DebugOut (1, strFkt);
    WLIdx    := SmallInt (EnsureRange (iWLIdx, -1, High (SmallInt)));
    BWIdx    := SmallInt (EnsureRange (iBWIdx, -1, High (SmallInt)));
    BeamPosV := SmallInt (EnsureRange (iBeamPosV, Low(SmallInt), High (SmallInt)));
    BeamPosH := SmallInt (EnsureRange (iBeamPosH, Low(SmallInt), High (SmallInt)));
    //
    iRetVal := _SEPIA2_SWS_SetCalPointValues (iDevIdx, iSlotId, WLIdx, BWIdx, BeamPosV, BeamPosH);
    SEPIA2_SWS_SetCalPointValues := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_SetCalPointValues


  function SEPIA2_SWS_SetCalTableSize (iDevIdx, iSlotId: integer; wWLIdxCount, wBWIdxCount: word; bInit: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    byteInit : byte;
  begin
    strFkt  := 'SEPIA2_SWS_SetCalTableSize';
    DebugOut (1, strFkt);
    //
    byteInit := ifthen (bInit, 1, 0);
    iRetVal := _SEPIA2_SWS_SetCalTableSize (iDevIdx, iSlotId, wWLIdxCount, wBWIdxCount, byteInit);
    SEPIA2_SWS_SetCalTableSize := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_SetCalTableSize


  function SEPIA2_SSM_DecodeFreqTrigMode (iDevIdx, iSlotId: integer; iFreqTrigIdx: integer; var cFreqTrigMode: string; var iMainFreq: integer; var bEnableTrigLvl: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    byteEnableTrigLvl : byte;
  begin
    strFkt  := 'SEPIA2_SSM_DecodeFreqTrigMode';
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_SSM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, pcTmpVal1, iMainFreq, byteEnableTrigLvl);
    bEnableTrigLvl := (byteEnableTrigLvl <> 0);
    cFreqTrigMode  := string(pcTmpVal1);
    SEPIA2_SSM_DecodeFreqTrigMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SSM_DecodeFreqTrigMode


  function SEPIA2_SSM_GetTrigLevelRange (iDevIdx, iSlotId: integer; var iUpperTrigLevel, iLowerTrigLevel, iTrigLevelResol: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SSM_GetTrigLevelRange';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SSM_GetTrigLevelRange (iDevIdx, iSlotId, iUpperTrigLevel, iLowerTrigLevel, iTrigLevelResol);
    SEPIA2_SSM_GetTrigLevelRange := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SSM_GetTrigLevelRange


  function SEPIA2_SSM_GetTriggerData (iDevIdx, iSlotId: integer; var iFreqTrigIdx, iTrigLevel: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SSM_GetTriggerData';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SSM_GetTriggerData (iDevIdx, iSlotId, iFreqTrigIdx, iTrigLevel);
    SEPIA2_SSM_GetTriggerData := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SSM_GetTriggerData


  function SEPIA2_SSM_SetTriggerData (iDevIdx, iSlotId: integer; iFreqTrigIdx, iTrigLevel: integer) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SSM_SetTriggerData';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SSM_SetTriggerData (iDevIdx, iSlotId, iFreqTrigIdx, iTrigLevel);
    SEPIA2_SSM_SetTriggerData := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SSM_SetTriggerData


  function SEPIA2_SSM_GetFRAMWriteProtect (iDevIdx, iSlotId: integer; var bWriteProtect: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
    byteWriteProtect : byte;
  begin
    strFkt  := 'SEPIA2_SSM_GetFRAMWriteProtect';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SSM_GetFRAMWriteProtect (iDevIdx, iSlotId, byteWriteProtect);
    bWriteProtect := (byteWriteProtect <> 0);
    SEPIA2_SSM_GetFRAMWriteProtect := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SSM_GetFRAMWriteProtect


  function SEPIA2_SSM_SetFRAMWriteProtect (iDevIdx, iSlotId: integer; bWriteProtect: boolean) : integer;
  var
    iRetVal : integer;
    strFkt  : string;
  begin
    strFkt  := 'SEPIA2_SSM_SetFRAMWriteProtect';
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SSM_SetFRAMWriteProtect (iDevIdx, iSlotId, byte (ifthen (bWriteProtect, 1, 0)));
    SEPIA2_SSM_SetFRAMWriteProtect := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SSM_SetFRAMWriteProtect




var
  strBuffer : string;

initialization
  {$ifdef __CALL_DEBUGOUT__}
    bActiveDebugOut  := false;
  {$endif}
  pcTmpVal1          := AllocMem  (TEMPVAR_LENGTH);
  pcTmpVal2          := AllocMem  (TEMPVAR_LENGTH);
  bSepia2ImportLibOK := true;
  //
  hdlDLL             := LoadLibrary (STR_LIB_NAME);
  //
  if hdlDLL <> 0
  then begin
    @_SEPIA2_LIB_GetVersion                  := GetProcAddress (hdlDLL, 'SEPIA2_LIB_GetVersion');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_LIB_GetVersion <> nil);
    @_SEPIA2_LIB_IsRunningOnWine             := GetProcAddress (hdlDLL, 'SEPIA2_LIB_IsRunningOnWine');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_LIB_IsRunningOnWine <> nil);
    @_SEPIA2_LIB_DecodeError                 := GetProcAddress (hdlDLL, 'SEPIA2_LIB_DecodeError');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_LIB_DecodeError <> nil);

    @_SEPIA2_USB_OpenDevice                  := GetProcAddress (hdlDLL, 'SEPIA2_USB_OpenDevice');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_USB_OpenDevice <> nil);
    @_SEPIA2_USB_OpenGetSerNumAndClose       := GetProcAddress (hdlDLL, 'SEPIA2_USB_OpenGetSerNumAndClose');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_USB_OpenGetSerNumAndClose <> nil);
    @_SEPIA2_USB_CloseDevice                 := GetProcAddress (hdlDLL, 'SEPIA2_USB_CloseDevice');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_USB_CloseDevice <> nil);
    @_SEPIA2_USB_GetStrDescriptor            := GetProcAddress (hdlDLL, 'SEPIA2_USB_GetStrDescriptor');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_USB_GetStrDescriptor <> nil);

    @_SEPIA2_FWR_GetVersion                  := GetProcAddress (hdlDLL, 'SEPIA2_FWR_GetVersion');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_FWR_GetVersion <> nil);
    @_SEPIA2_FWR_GetLastError                := GetProcAddress (hdlDLL, 'SEPIA2_FWR_GetLastError');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_FWR_GetLastError <> nil);
    @_SEPIA2_FWR_DecodeErrPhaseName          := GetProcAddress (hdlDLL, 'SEPIA2_FWR_DecodeErrPhaseName');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_FWR_DecodeErrPhaseName <> nil);
    @_SEPIA2_FWR_GetModuleMap                := GetProcAddress (hdlDLL, 'SEPIA2_FWR_GetModuleMap');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_FWR_GetModuleMap <> nil);
    @_SEPIA2_FWR_GetModuleInfoByMapIdx       := GetProcAddress (hdlDLL, 'SEPIA2_FWR_GetModuleInfoByMapIdx');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_FWR_GetModuleInfoByMapIdx <> nil);
    @_SEPIA2_FWR_GetUptimeInfoByMapIdx       := GetProcAddress (hdlDLL, 'SEPIA2_FWR_GetUptimeInfoByMapIdx');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_FWR_GetUptimeInfoByMapIdx <> nil);
    @_SEPIA2_FWR_FreeModuleMap               := GetProcAddress (hdlDLL, 'SEPIA2_FWR_FreeModuleMap');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_FWR_FreeModuleMap <> nil);

    @_SEPIA2_COM_DecodeModuleType            := GetProcAddress (hdlDLL, 'SEPIA2_COM_DecodeModuleType');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_COM_DecodeModuleType <> nil);
    @_SEPIA2_COM_DecodeModuleTypeAbbr        := GetProcAddress (hdlDLL, 'SEPIA2_COM_DecodeModuleTypeAbbr');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_COM_DecodeModuleTypeAbbr <> nil);
    @_SEPIA2_COM_GetModuleType               := GetProcAddress (hdlDLL, 'SEPIA2_COM_GetModuleType');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_COM_GetModuleType <> nil);
    @_SEPIA2_COM_GetSerialNumber             := GetProcAddress (hdlDLL, 'SEPIA2_COM_GetSerialNumber');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_COM_GetSerialNumber <> nil);
    @_SEPIA2_COM_HasSecondaryModule          := GetProcAddress (hdlDLL, 'SEPIA2_COM_HasSecondaryModule');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_COM_HasSecondaryModule <> nil);
    @_SEPIA2_COM_GetPresetInfo               := GetProcAddress (hdlDLL, 'SEPIA2_COM_GetPresetInfo');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_COM_GetPresetInfo <> nil);
    @_SEPIA2_COM_RecallPreset                := GetProcAddress (hdlDLL, 'SEPIA2_COM_RecallPreset');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_COM_RecallPreset <> nil);
    @_SEPIA2_COM_SaveAsPreset                := GetProcAddress (hdlDLL, 'SEPIA2_COM_SaveAsPreset');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_COM_SaveAsPreset <> nil);
    @_SEPIA2_COM_IsWritableModule            := GetProcAddress (hdlDLL, 'SEPIA2_COM_IsWritableModule');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_COM_IsWritableModule <> nil);
    @_SEPIA2_COM_UpdateModuleData            := GetProcAddress (hdlDLL, 'SEPIA2_COM_UpdateModuleData');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_COM_UpdateModuleData <> nil);
    @_SEPIA2_SCM_GetPowerAndLaserLEDS        := GetProcAddress (hdlDLL, 'SEPIA2_SCM_GetPowerAndLaserLEDS');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SCM_GetPowerAndLaserLEDS <> nil);
    @_SEPIA2_SCM_GetLaserLocked              := GetProcAddress (hdlDLL, 'SEPIA2_SCM_GetLaserLocked');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SCM_GetLaserLocked <> nil);
    @_SEPIA2_SCM_GetLaserSoftLock            := GetProcAddress (hdlDLL, 'SEPIA2_SCM_GetLaserSoftLock');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SCM_GetLaserSoftLock <> nil);
    @_SEPIA2_SCM_SetLaserSoftLock            := GetProcAddress (hdlDLL, 'SEPIA2_SCM_SetLaserSoftLock');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SCM_SetLaserSoftLock <> nil);

    @_SEPIA2_SLM_DecodeFreqTrigMode          := GetProcAddress (hdlDLL, 'SEPIA2_SLM_DecodeFreqTrigMode');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SLM_DecodeFreqTrigMode <> nil);
    @_SEPIA2_SLM_DecodeHeadType              := GetProcAddress (hdlDLL, 'SEPIA2_SLM_DecodeHeadType');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SLM_DecodeHeadType <> nil);
    //
    @_SEPIA2_SLM_GetParameters               := GetProcAddress (hdlDLL, 'SEPIA2_SLM_GetParameters');                                   // deprecated
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SLM_GetParameters <> nil);
    // deprecated  : SEPIA2_SLM_GetParameters;
    // use instead : SEPIA2_SLM_GetIntensityFineStep, SEPIA2_SLM_GetPulseParameters
    @_SEPIA2_SLM_SetParameters               := GetProcAddress (hdlDLL, 'SEPIA2_SLM_SetParameters');                                   // deprecated
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SLM_SetParameters <> nil);
    // deprecated  : SEPIA2_SLM_SetParameters;
    // use instead : SEPIA2_SLM_SetIntensityFineStep, SEPIA2_SLM_SetPulseParameters
    //
    @_SEPIA2_SLM_GetIntensityFineStep        := GetProcAddress (hdlDLL, 'SEPIA2_SLM_GetIntensityFineStep');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SLM_GetIntensityFineStep <> nil);
    @_SEPIA2_SLM_SetIntensityFineStep        := GetProcAddress (hdlDLL, 'SEPIA2_SLM_SetIntensityFineStep');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SLM_SetIntensityFineStep <> nil);
    @_SEPIA2_SLM_GetPulseParameters          := GetProcAddress (hdlDLL, 'SEPIA2_SLM_GetPulseParameters');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SLM_GetPulseParameters <> nil);
    @_SEPIA2_SLM_SetPulseParameters          := GetProcAddress (hdlDLL, 'SEPIA2_SLM_SetPulseParameters');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SLM_SetPulseParameters <> nil);

    @_SEPIA2_SML_DecodeHeadType              := GetProcAddress (hdlDLL, 'SEPIA2_SML_DecodeHeadType');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SML_DecodeHeadType <> nil);
    @_SEPIA2_SML_GetParameters               := GetProcAddress (hdlDLL, 'SEPIA2_SML_GetParameters');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SML_GetParameters <> nil);
    @_SEPIA2_SML_SetParameters               := GetProcAddress (hdlDLL, 'SEPIA2_SML_SetParameters');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SML_SetParameters <> nil);

    @_SEPIA2_SOM_DecodeFreqTrigMode          := GetProcAddress (hdlDLL, 'SEPIA2_SOM_DecodeFreqTrigMode');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_DecodeFreqTrigMode <> nil);
    @_SEPIA2_SOM_GetFreqTrigMode             := GetProcAddress (hdlDLL, 'SEPIA2_SOM_GetFreqTrigMode');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_GetFreqTrigMode <> nil);
    @_SEPIA2_SOM_SetFreqTrigMode             := GetProcAddress (hdlDLL, 'SEPIA2_SOM_SetFreqTrigMode');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_SetFreqTrigMode <> nil);
    @_SEPIA2_SOM_GetTriggerRange             := GetProcAddress (hdlDLL, 'SEPIA2_SOM_GetTriggerRange');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_GetTriggerRange <> nil);
    @_SEPIA2_SOM_GetTriggerLevel             := GetProcAddress (hdlDLL, 'SEPIA2_SOM_GetTriggerLevel');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_GetTriggerLevel <> nil);
    @_SEPIA2_SOM_SetTriggerLevel             := GetProcAddress (hdlDLL, 'SEPIA2_SOM_SetTriggerLevel');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_SetTriggerLevel <> nil);
    @_SEPIA2_SOM_GetBurstValues              := GetProcAddress (hdlDLL, 'SEPIA2_SOM_GetBurstValues');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_GetBurstValues <> nil);
    @_SEPIA2_SOM_SetBurstValues              := GetProcAddress (hdlDLL, 'SEPIA2_SOM_SetBurstValues');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_SetBurstValues <> nil);
    @_SEPIA2_SOM_GetBurstLengthArray         := GetProcAddress (hdlDLL, 'SEPIA2_SOM_GetBurstLengthArray');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_GetBurstLengthArray <> nil);
    @_SEPIA2_SOM_SetBurstLengthArray         := GetProcAddress (hdlDLL, 'SEPIA2_SOM_SetBurstLengthArray');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_SetBurstLengthArray <> nil);
    @_SEPIA2_SOM_GetOutNSyncEnable           := GetProcAddress (hdlDLL, 'SEPIA2_SOM_GetOutNSyncEnable');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_GetOutNSyncEnable <> nil);
    @_SEPIA2_SOM_SetOutNSyncEnable           := GetProcAddress (hdlDLL, 'SEPIA2_SOM_SetOutNSyncEnable');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_SetOutNSyncEnable <> nil);
    @_SEPIA2_SOM_DecodeAUXINSequencerCtrl    := GetProcAddress (hdlDLL, 'SEPIA2_SOM_DecodeAUXINSequencerCtrl');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_DecodeAUXINSequencerCtrl <> nil);
    @_SEPIA2_SOM_GetAUXIOSequencerCtrl       := GetProcAddress (hdlDLL, 'SEPIA2_SOM_GetAUXIOSequencerCtrl');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_GetAUXIOSequencerCtrl <> nil);
    @_SEPIA2_SOM_SetAUXIOSequencerCtrl       := GetProcAddress (hdlDLL, 'SEPIA2_SOM_SetAUXIOSequencerCtrl');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SOM_SetAUXIOSequencerCtrl <> nil);


    @_SEPIA2_SWM_DecodeRangeIdx              := GetProcAddress (hdlDLL, 'SEPIA2_SWM_DecodeRangeIdx');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWM_DecodeRangeIdx <> nil);
    @_SEPIA2_SWM_GetUIConstants              := GetProcAddress (hdlDLL, 'SEPIA2_SWM_GetUIConstants');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWM_GetUIConstants <> nil);
    @_SEPIA2_SWM_GetCurveParams              := GetProcAddress (hdlDLL, 'SEPIA2_SWM_GetCurveParams');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWM_GetCurveParams <> nil);
    @_SEPIA2_SWM_SetCurveParams              := GetProcAddress (hdlDLL, 'SEPIA2_SWM_SetCurveParams');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWM_SetCurveParams <> nil);

    @_SEPIA2_SPM_DecodeModuleState           := GetProcAddress (hdlDLL, 'SEPIA2_SPM_DecodeModuleState');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_DecodeModuleState <> nil);
    @_SEPIA2_SPM_GetFWVersion                := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetFWVersion');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetFWVersion <> nil);
    @_SEPIA2_SPM_GetManualPumpCurrent        := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetManualPumpCurrent');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetManualPumpCurrent <> nil);
    @_SEPIA2_SPM_GetControlMode              := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetControlMode');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetControlMode <> nil);
    @_SEPIA2_SPM_GetPumpCtrlParams           := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetPumpCtrlParams');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetPumpCtrlParams <> nil);
    @_SEPIA2_SPM_GetPhotoDiodeCurrents       := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetPhotoDiodeCurrents');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetPhotoDiodeCurrents <> nil);
    @_SEPIA2_SPM_GetPumpCurrents             := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetPumpCurrents');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetPumpCurrents <> nil);
    @_SEPIA2_SPM_GetSensorData               := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetSensorData');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetSensorData <> nil);
    @_SEPIA2_SPM_GetTemperatureAdjust        := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetTemperatureAdjust');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetTemperatureAdjust <> nil);
    @_SEPIA2_SPM_GetUpTimePowerTable         := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetUpTimePowerTable');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetUpTimePowerTable <> nil);
    @_SEPIA2_SPM_GetStatusError              := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetStatusError');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetStatusError <> nil);
    @_SEPIA2_SPM_UpdateFirmware              := GetProcAddress (hdlDLL, 'SEPIA2_SPM_UpdateFirmware');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_UpdateFirmware <> nil);
    @_SEPIA2_SPM_SetFRAMWriteProtect         := GetProcAddress (hdlDLL, 'SEPIA2_SPM_SetFRAMWriteProtect');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_SetFRAMWriteProtect <> nil);
    @_SEPIA2_SPM_GetFiberAmplifierFail       := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetFiberAmplifierFail');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetFiberAmplifierFail <> nil);
    @_SEPIA2_SPM_ResetFiberAmplifierFail     := GetProcAddress (hdlDLL, 'SEPIA2_SPM_ResetFiberAmplifierFail');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_ResetFiberAmplifierFail <> nil);
    @_SEPIA2_SPM_GetPumpPowerState           := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetPumpPowerState');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetPumpPowerState <> nil);
    @_SEPIA2_SPM_SetPumpPowerState           := GetProcAddress (hdlDLL, 'SEPIA2_SPM_SetPumpPowerState');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_SetPumpPowerState <> nil);
    @_SEPIA2_SPM_GetOperationTimers          := GetProcAddress (hdlDLL, 'SEPIA2_SPM_GetOperationTimers');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SPM_GetOperationTimers <> nil);
    @_SEPIA2_SWS_DecodeModuleType            := GetProcAddress (hdlDLL, 'SEPIA2_SWS_DecodeModuleType');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_DecodeModuleType <> nil);
    @_SEPIA2_SWS_DecodeModuleState           := GetProcAddress (hdlDLL, 'SEPIA2_SWS_DecodeModuleState');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_DecodeModuleState <> nil);
    @_SEPIA2_SWS_GetModuleType               := GetProcAddress (hdlDLL, 'SEPIA2_SWS_GetModuleType');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_GetModuleType <> nil);
    @_SEPIA2_SWS_GetStatusError              := GetProcAddress (hdlDLL, 'SEPIA2_SWS_GetStatusError');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_GetStatusError <> nil);
    @_SEPIA2_SWS_GetParamRanges              := GetProcAddress (hdlDLL, 'SEPIA2_SWS_GetParamRanges');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_GetParamRanges <> nil);
    @_SEPIA2_SWS_GetParameters               := GetProcAddress (hdlDLL, 'SEPIA2_SWS_GetParameters');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_GetParameters <> nil);
    @_SEPIA2_SWS_SetParameters               := GetProcAddress (hdlDLL, 'SEPIA2_SWS_SetParameters');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_SetParameters <> nil);
    @_SEPIA2_SWS_GetIntensity                := GetProcAddress (hdlDLL, 'SEPIA2_SWS_GetIntensity');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_GetIntensity <> nil);
    @_SEPIA2_SWS_GetFWVersion                := GetProcAddress (hdlDLL, 'SEPIA2_SWS_GetFWVersion');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_GetFWVersion <> nil);
    @_SEPIA2_SWS_UpdateFirmware              := GetProcAddress (hdlDLL, 'SEPIA2_SWS_UpdateFirmware');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_UpdateFirmware <> nil);
    @_SEPIA2_SWS_SetFRAMWriteProtect         := GetProcAddress (hdlDLL, 'SEPIA2_SWS_SetFRAMWriteProtect');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_SetFRAMWriteProtect <> nil);
    @_SEPIA2_SWS_GetBeamPos                  := GetProcAddress (hdlDLL, 'SEPIA2_SWS_GetBeamPos');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_GetBeamPos <> nil);
    @_SEPIA2_SWS_SetBeamPos                  := GetProcAddress (hdlDLL, 'SEPIA2_SWS_SetBeamPos');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_SetBeamPos <> nil);
    @_SEPIA2_SWS_SetCalibrationMode          := GetProcAddress (hdlDLL, 'SEPIA2_SWS_SetCalibrationMode');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_SetCalibrationMode <> nil);
    @_SEPIA2_SWS_GetCalTableSize             := GetProcAddress (hdlDLL, 'SEPIA2_SWS_GetCalTableSize');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@SEPIA2_SWS_GetCalTableSize <> nil);
    @_SEPIA2_SWS_GetCalPointInfo             := GetProcAddress (hdlDLL, 'SEPIA2_SWS_GetCalPointInfo');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_GetCalPointInfo <> nil);
    @_SEPIA2_SWS_SetCalPointValues           := GetProcAddress (hdlDLL, 'SEPIA2_SWS_SetCalPointValues');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_SetCalPointValues <> nil);
    @_SEPIA2_SWS_SetCalTableSize             := GetProcAddress (hdlDLL, 'SEPIA2_SWS_SetCalTableSize');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SWS_SetCalTableSize <> nil);
    @_SEPIA2_SSM_DecodeFreqTrigMode          := GetProcAddress (hdlDLL, 'SEPIA2_SSM_DecodeFreqTrigMode');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SSM_DecodeFreqTrigMode <> nil);
    @_SEPIA2_SSM_GetTrigLevelRange           := GetProcAddress (hdlDLL, 'SEPIA2_SSM_GetTrigLevelRange');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SSM_GetTrigLevelRange <> nil);
    @_SEPIA2_SSM_GetTriggerData              := GetProcAddress (hdlDLL, 'SEPIA2_SSM_GetTriggerData');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SSM_GetTriggerData <> nil);
    @_SEPIA2_SSM_SetTriggerData              := GetProcAddress (hdlDLL, 'SEPIA2_SSM_SetTriggerData');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SSM_SetTriggerData <> nil);
    @_SEPIA2_SSM_GetFRAMWriteProtect         := GetProcAddress (hdlDLL, 'SEPIA2_SSM_GetFRAMWriteProtect');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SSM_GetFRAMWriteProtect <> nil);
    @_SEPIA2_SSM_SetFRAMWriteProtect         := GetProcAddress (hdlDLL, 'SEPIA2_SSM_SetFRAMWriteProtect');
    bSepia2ImportLibOK := bSepia2ImportLibOK and (@_SEPIA2_SSM_SetFRAMWriteProtect <> nil);
    //
    if bSepia2ImportLibOK
    then begin
      iRet := SEPIA2_LIB_GetVersion (strLibVersion);
      if (iRet <> SEPIA2_ERR_NO_ERROR) or (0 > StrLComp(PChar(strLibVersion), PChar(LIB_VERSION_REFERENCE), Length(LIB_VERSION_REFERENCE)))
      then begin
        writeln ('Library Sepia2_lib.dll not up-to-date!');
        bSepia2ImportLibOK := false;
      end;
    end;
  end
  else begin
    writeln ('Library Sepia2_lib.dll not found!');
    bSepia2ImportLibOK := false;
  end;
finalization
  FreeLibrary (hdlDLL);
  FreeMem (pcTmpVal1);
end.
