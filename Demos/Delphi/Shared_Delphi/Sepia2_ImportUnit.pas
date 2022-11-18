//-----------------------------------------------------------------------------
//
//      Sepia2_ImportUnit.pas
//
//-----------------------------------------------------------------------------
//
//  Exports the Sepia 2  functions from Sepia2_lib.dll  V1.2.<xx>.<nnn>
//    <xx>  = 32: Sepia2_Lib for x86 target architecture;
//    <xx>  = 64: Sepia2_Lib for x64 target architecture;
//    <nnn> = SVN build number
//
//-----------------------------------------------------------------------------
//  HISTORY:
//
//  apo  26.01.06   first released (derived from Sepia2_lib.dll)
//  apo  12.02.07   introduced SML multilaser module (V1.0.2.0)
//  apo  02.12.09   introduced SWM Pulsar Waveform Module (V1.0.2.1)
//  apo  19.04.10   incorporated into EasyTau-SW    (V1.0.2.0)
//  apo  04.02.11   incorporated into SymPhoTime    (V1.0.2.0)
//  apo  06.01.12   incorporated into SymPhoTime 64 (V1.0.3.0)
//                    implied changes to SEPIA2_SERIALNUMBER_LEN!
//                  restricted bSepia2ImportLibOK:
//                    - all fuctions must be available
//                    - lib-version  must be 1.0.3.x
//  sac  17.04.12   bugfix for functions using PChars  (V1.0.3.x)
//  apo  14.08.12   added Solea SSM seedlaser module functions (V1.0.3.x)
//  apo  16.08.12   added Solea SWS wavelength selector module functions (V1.0.3.x)
//  apo  19.09.12   synchronised SymPhoTime and Sepia-GUI Versions
//  apo  26.04.13   added Solea SPM pump control module functions (V1.0.3.121)
//  apo  21.05.13   introduced SLM intensity with permille resolution
//                    (SLM functions GetParameters & SetParameters are deprecated now)
//  apo  04.06.13   introduced SWS and SPM function UpdateFirmware
//  apo  11.06.13   introduced COM function UpdateModuleData
//  apo  14.10.13   introduced SWS and SPM function SetFRAMWriteProtect
//  apo  30.10.13   changed interfaces of SWS parameter functions (V1.0.3.204)
//                    all attenuation parameters changed from cardinal to integer
//  apo  27.01.14   SEPIA2_SERIALNUMBER_LEN might be greater than 8 (->12) again
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  apo  26.02.14   raised library version to 1.1.0.x due to API changes on the
//                    device open interfaces (new parameter strProductModel)
//                  encoded bitwidth of target architecture into version field
//                    "MinorHighWord" and changed LIB_VERSION_REFERENCE accordingly, e.g.:
//                    V1.1.32.293 or V1.1.64.293, respectively
//  apo  08.07.14   preparing SOMD basic functions  (V1.1.xx.336)
//  apo  15.07.14   introduced SOMD feature: SOMD Get/Set BurstValues takes 16 bits
//                    for base oscillator predivider
//  apo  16.07.14   introduced SOM functions Get/Set AUXIOSequencerCtrl
//  apo  05.08.14   integrating SOM and SOMD functions Get/Set BurstValues into
//                    one for both module types (named SOM, but with 16 bits
//                    for the base oscillator predivider parameter field)
//  apo  09.10.14   introducing full featured SOMD
//  apo  26.03.15   introduced SWM Curve Visualisation
//  apo  28.05.15   new FWR function creates service request text
//  apo  01.10.15   removed some superfluous SPM info functions from API
//  apo  24.05.16   introduced new SPM function GetDeviceDescription and
//                    Get/SetOutputStageControl
//  apo  06.06.16   enhanced debug strings by showing the input parameters
//
//  apo  19.10.20   additional functions for VisUV/IR Module (V1.1.xx.590)
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//  apo  15.01.21   raised library version to 1.2.xx.nnn due to some new API
//                    functions and a new Windows USB driver
//
//  apo  12.07.21   additional functions for Prima Module (V1.2.xx.720)
//
//  apo  15.02.22   added type T_PRI_Constants and function SEPIA2_PRI_GetConstants
//                    to substitute the missing-by-design index constants for Prima
//
//-----------------------------------------------------------------------------
//


unit Sepia2_ImportUnit;

  //
  // This switch disables Debug output of certain functions, used to be polled
  {$define __POLLING_AWARE_AVOIDING_DEBUGOUT__}
  // as there are:
  //    SEPIA2_SCM_GetPowerAndLaserLEDS,
  //    SEPIA2_SCM_GetLaserLocked, ...
  //

interface

uses
  System.SysUtils, System.Classes;

  const
    STR_LIB_NAME                                = 'Sepia2_Lib.dll';

    {$ifdef __x64__}
      LIB_VERSION_REFERENCE_OLD                 = '1.1.64.';       // minor low word (SVN-build) may be ignored
      LIB_VERSION_REFERENCE                     = '1.2.64.';       // minor low word (SVN-build) may be ignored
    {$else}
      LIB_VERSION_REFERENCE_OLD                 = '1.1.32.';       // minor low word (SVN-build) may be ignored
      LIB_VERSION_REFERENCE                     = '1.2.32.';       // minor low word (SVN-build) may be ignored
    {$endif}
    LIB_VERSION_COMPLEN                         =     7;

    FW_VERSION_REFERENCE_OLD                    = '1.05.';
    FW_VERSION_REFERENCE                        = '2.01.';
    FW_VERSION_COMPLEN                          =     5;

  type
    T_SEPIA2_FWR_WORKINGMODE                    = (SEPIA2_FWR_WORKINGMODE_STAY_PERMANENT, SEPIA2_FWR_WORKINGMODE_VOLATILE);

  const
    MILLISECONDS_PER_DAY                        =  86400000;

    SEPIA2_SUPREQ_OPT_NO_PREAMBLE               = $00000001;       // option parameters for SEPIA2_FWR_CreateSupportRequestText
    SEPIA2_SUPREQ_OPT_NO_TITLE                  = $00000002;
    SEPIA2_SUPREQ_OPT_NO_CALLING_SW_INDENT      = $00000004;
    SEPIA2_SUPREQ_OPT_NO_SYSTEM_INFO            = $00000008;

    SEPIA2_MAX_USB_DEVICES                      =     8;

    SEPIA2_USB_STRDSCR_IDX_VENDOR               =     1;
    SEPIA2_USB_STRDSCR_IDX_MODEL                =     2;
    SEPIA2_USB_STRDSCR_IDX_BUILD                =     3;
    SEPIA2_USB_STRDSCR_IDX_SERIAL               =     4;

    SEPIA2_SCM_MAX_VOLTAGES                     =     8;
    SEPIA2_SCM_VOLTAGE_5V_POSITIVE_POWERSUPPLY  =     0;
    SEPIA2_SCM_VOLTAGE_5V_NEGATIVE_POWERSUPPLY  =     1;
    SEPIA2_SCM_VOLTAGE_5V_POSITIVE_ON_BUS       =     2;
    SEPIA2_SCM_VOLTAGE_5V_NEGATIVE_ON_BUS       =     3;
    SEPIA2_SCM_VOLTAGE_28V_POSITIVE_POWERSUPPLY =     4;
    SEPIA2_SCM_VOLTAGE_28V_POSITIVE_ON_BUS      =     5;
    SEPIA2_SCM_VOLTAGE_28V_POSITIVE_BEHIND_FUSE =     6;
    SEPIA2_SCM_VOLTAGE_28V_OFF_MAXIMUM_READ     =     2.97; //1.55;      // 1,55 V residual voltage permitted when key locked
    SEPIA2_SCM_VOLTAGE_COUNT                    =     7;

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
    SEPIA2_VUV_VIR_DEVICETYPE_LEN               =    32;
    SEPIA2_VUV_VIR_TRIGINFO_LEN                 =    15;
    SEPIA2_PRI_DEVICE_ID_LEN                    =     6;
    SEPIA2_PRI_DEVICE_FW_LEN                    =     8;
    SEPIA2_PRI_OPER_MODE_LEN                    =    15;
    SEPIA2_PRI_WAVELENGTH_LEN                   =     9;
    SEPIA2_PRI_TRIG_SRC_LEN                     =    16;
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
    SEPIA2OBJECT_SWM                            =   $43;  // 0 1 00  0 011     module    primary   no    no   d.c.          // for PPL 400: Waveform Shaper Modules
    SEPIA2OBJECT_SWS                            =   $44;  // 0 1 00  0 100     module    primary   no    no   d.c.          // for Solea: Wavelength Selector Modules
    SEPIA2OBJECT_SPM                            =   $45;  // 0 1 00  0 101     module    primary   no    no   d.c.          // for Solea: Pumpcontrol Modules
    SEPIA2OBJECT_SOM                            =   $50;  // 0 1 01  0 000     module    primary   no    yes  d.c.   0-7    // for Sepia II: Oscillator Module
    SEPIA2OBJECT_SOMD                           =   $51;  // 0 1 01  0 001     module    primary   no    yes  d.c.   0-7    // for Sepia II: Oscillator Module with Delay Option
    SEPIA2OBJECT_SML                            =   $60;  // 0 1 10  0 000     module    primary   yes   no   d.c.   0-7    // for Sepia II: Multi-Laser Module
    SEPIA2OBJECT_VCL                            =   $61;  // 0 1 10  0 000     module    primary   yes   no   d.c.   0-7    // for PPL 400: Voltage Controlled Laser Module
    SEPIA2OBJECT_SLM                            =   $70;  // 0 1 11  0 000     module    primary   yes   yes  d.c.   0-7    // for Sepia II: Laser Driver Module
    SEPIA2OBJECT_SSM                            =   $71;  // 0 1 11  0 001     module    primary   yes   yes  d.c.   0-7    // for Solea: Seed Laser Module
    SEPIA2OBJECT_VIR                            =   $72;  // 0 1 11  0 010     module    primary   yes   yes  d.c.   0-7    // for VisIR: Laser Module
    SEPIA2OBJECT_VUV                            =   $73;  // 0 1 11  0 011     module    primary   yes   yes  d.c.   0-7    // for VisUV: Laser Module
    SEPIA2OBJECT_PRI                            =   $74;  // 0 1 11  0 100     module    primary   yes   yes  d.c.   0-7    // for Prima: Laser Module
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


type
    T_COM_MODULETYPE_STR                        = array [0..SEPIA2_COM_MODULETYPE_LEN-1] of AnsiChar;
    T_COM_FW_MAGIC                              = array [0..SEPIA2_COM_FW_MAGIC_LEN-1] of AnsiChar;

    T_Version_Short = record
      case boolean of
        true:  ( w        : word);
        false: (
                 VersLo   : byte;
                 VersHi   : byte;
               );
    end;

    T_SepiaModules_FWVersion = record
      case boolean of
        true:  (ulVersion : Cardinal);
        false: (
                 Build    : word;
                 Vers     : T_Version_Short;
               );
    end;

    TFW_Discriminator = record
      FW_Version      : T_SepiaModules_FWVersion;
      cModuleType     : T_COM_MODULETYPE_STR;
      cFWMagic        : T_COM_FW_MAGIC;
      dwReserve1      : LongWord;
      dwReserve2      : LongWord;
      dwReserve3      : LongWord;
      wReserve1       : word;
      wCRC            : word;
    end;
    TPtr_FW_Discriminator = ^TFW_Discriminator;


const
    SEPIA2_SOMD_TIMEOUT                         =  3000.0 / MILLISECONDS_PER_DAY;    // 3 sec
    SEPIA2_SOMD_FW_PAGE_LEN                     =   256;
    SEPIA2_SOMD_FW_MAGIC                        : T_COM_FW_MAGIC = 'PQFWSOMD';
    SEPIA2_SOMD_FW_DISCRIMINATOR_VERS           = $0100;
    SEPIA2_SOMD_HW_MAGIC                        : T_COM_FW_MAGIC = 'PQHWSOMD';
    SEPIA2_SOMD_HW_DISCRIMINATOR_VERS           = $0100;
    SEPIA2_SOMD_HW_CALTABLE_MAGIC               : T_COM_FW_MAGIC = 'SOMDCALT';
    SEPIA2_SOMD_HW_CALTABLE_VERS                = $0100;

    {$Z2} // values are SmallInt (Delphi), i.e. short (C)
    SEPIA2_SOMD_STATE_READY                     = $0000; // Module ready
    SEPIA2_SOMD_STATE_INIT                      = $0001; // Module initialising
    SEPIA2_SOMD_STATE_BUSY                      = $0002; // Calculating on update data
    SEPIA2_SOMD_STATE_HARDWAREERROR             = $0010; // Hardware errorcode pending; Can be read by GetStatusError
    SEPIA2_SOMD_STATE_FWUPDATERUNNING           = $0020; // Firmware update running
    SEPIA2_SOMD_STATE_FRAM_WRITEPROTECTED       = $0040; // FRAM is write protected = 1, FRAM write enabled = 0
    SEPIA2_SOMD_STATE_PLL_UNSTABLE              = $0080; // PLL is not stable after changing the base oscillator or trigger mode
    SEPIA2_SOMD_STATEMASK_NOT_FUNCTIONAL        = $0013; // SEPIA2_SOMD_STATE_INIT + SEPIA2_SOMD_STATE_BUSY + SEPIA2_SOMD_STATE_HARDWAREERROR


    SEPIA2_SPM_TEMPERATURE_SENSORCOUNT          =     6;

    {$Z2} // values are SmallInt (Delphi), i.e. short (C)
    SEPIA2_SPM_STATE_READY                      = $0000; // Module bereit
    SEPIA2_SPM_STATE_INIT                       = $0001; // Module Initialisierung
    SEPIA2_SPM_STATE_BUSY                       = $0002; // Motoren aktiv
    SEPIA2_SPM_STATE_ERROR                      = $0010; // Error info pending
    SEPIA2_SPM_STATE_UPDATING_FW                = $0020; // Firmware update running
    SEPIA2_SPM_STATE_FRAM_WRITEPROTECTED        = $0040; // FRAM write protected on adresses > $1800
    //
    SEPIA2_SPM_STATEMASK_NOT_FUNCTIONAL         = $0013; // OK wenn READY
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

    T_SOMD_FW_PAGE        = array [0..SEPIA2_SOMD_FW_PAGE_LEN-1] of Byte;

    T_SOMD_FW_Discriminator = record
      FWMagic           : T_COM_FW_MAGIC;                                     // 'PQFWSOMD'
      FWDiscr_Version   : T_Version_Short;                                    // $0100
      PCB_Version       : T_Version_Short;                                    // $0100
      FW_Version        : T_Version_Short;                                    // $0100
      CalTab_Version    : T_Version_Short;                                    // $0100
      Reserve           : array [0..3] of LongWord;
      FileName          : array [0..63] of AnsiChar;                          // 'som828d_lp<pcb_vers=%4.4d>_fw<fw_vers=%4.4d>[_<comment>].bit'#$00...
      FileTime          : array [0..23] of AnsiChar;                          // '2015/05/31;17:59:01.000'
      BurnTime          : array [0..23] of AnsiChar;                          // '2015/05/31;17:59:01.000'
      UserName          : array [0..31] of AnsiChar;                          // 'pillepalle'#$00...
      FileLength        : LongWord;                                           // netto bitfile length
      // ---- crc32 limit ----
      FWDiscr_crc32     : LongWord;                                           // header only; inverted, low byte first
      FWData_crc32      : LongWord;                                           // firmware data only, following this header
    end;
    TPtr_SOMD_FW_Discriminator = ^T_SOMD_FW_Discriminator;

  const
    SEPIA2_SOMD_FWDISCR_CRCLIM   = sizeof (T_SOMD_FW_Discriminator) - 2 * sizeof (LongWord);
    SEPIA2_SOMD_FWDISCR_CHECKLEN = sizeof (T_SOMD_FW_Discriminator) -     sizeof (LongWord);

  type
    T_SOMD_HW_Discriminator = record                                          // as positioned at page $3F00
      HWMagic           : T_COM_FW_MAGIC;                                     // 'PQHWSOMD'
      HWDiscr_Version   : T_Version_Short;                                    // $0100
      PCB_Version       : T_Version_Short;                                    // $0100
      FW_Version        : T_Version_Short;                                    // $0100
      CalTab_Version    : T_Version_Short;                                    // $0001
      Reserve           : array [0..3] of LongWord;
      FileName          : array [0..63] of AnsiChar;                          // 'som828d_lp<pcb_vers=%4.4d>_fw<fw_vers=%4.4d>[_<comment>].bit'#$00...
      FileTime          : array [0..23] of AnsiChar;                          // '2015/05/31_17:59:01.000'#$00
      BurnTime          : array [0..23] of AnsiChar;                          // '2015/05/31_17:59:01.000'#$00
      UserName          : array [0..31] of AnsiChar;                          // 'PQ.pillepalle'#$00...
      FileLength        : LongWord;                                           // netto bitfile length
      // ---- crc32 limit ----                                                //
      HWDiscr_crc32     : LongWord;                                           // header only; inverted, low byte first
      FWData_crc32      : LongWord;                                           // firmware data only
    end;
    TPtr_SOMD_HW_Discriminator = ^T_SOMD_HW_Discriminator;

  const
    SEPIA2_SOMD_HWDISCR_CRCLIM      = sizeof (T_SOMD_HW_Discriminator) - 2 * sizeof (LongWord);
    SEPIA2_SOMD_HWDISCR_CHECKLEN    = sizeof (T_SOMD_HW_Discriminator) -     sizeof (LongWord);

    SEPIA2_SOMD_CALIBSET_MAXCOUNT   = 15;
    SEPIA2_SOMD_CALIBSTATE_MAXCOUNT = 16;

  type
    T_SOMD_CalibSetCnt    = 0..SEPIA2_SOMD_CALIBSET_MAXCOUNT;
    T_SOMD_CalibStateCnt  = 0..SEPIA2_SOMD_CALIBSTATE_MAXCOUNT;
    T_SOMD_CalibSetIdx    = 0..SEPIA2_SOMD_CALIBSET_MAXCOUNT-1;
    T_SOMD_CalibStateIdx  = 0..SEPIA2_SOMD_CALIBSTATE_MAXCOUNT-1;
    T_SOMD_CalibSet       = array [T_SOMD_CalibStateIdx] of ShortInt;         // up to 16 signed byte values         (10 already used)
    T_SOMD_CalibTable     = array [T_SOMD_CalibSetIdx] of T_SOMD_CalibSet;    // up to 15 calibration parameter sets ( 3 already used)

    T_SOMD_HW_CalTable = record                                               // as positioned at page $3F01
      CalTableMagic     : T_COM_FW_MAGIC;                                     // 'SOMDCALT'
      CalTableVersion   : T_Version_Short;                                    // $0001
      SetsUsed          : T_SOMD_CalibSetCnt;                                 // $03
      StatesUsed        : T_SOMD_CalibStateCnt;                               // $0A
      CalTable          : T_SOMD_CalibTable;                                  //
      // ---- crc32 limit ----                                                //
      CalTable_crc32    : LongWord;                                           // CalTable only; inverted, low byte first
    end;
    TPtr_SOMD_HW_CalTable = ^T_SOMD_HW_CalTable;

  const
    SEPIA2_SOMD_HWCALTAB_CRCLIM   = sizeof (T_SOMD_HW_CalTable) - sizeof (LongWord);
    SEPIA2_SOMD_HWCALTAB_CHECKLEN = sizeof (T_SOMD_HW_CalTable);


  var
    strLibVersion      : string;
    strLibUSBVersion   : string;
    bSepia2ImportLibOK : Boolean;
    iDLLFuncsCount     : integer;
    strCount           : string;
    strReason          : string;


  // ---  library functions  ----------------------------------------------------

  function SEPIA2_LIB_DecodeError               (iErrCode: integer; var cErrorString: string) : integer;
  function SEPIA2_LIB_GetVersion                (var cLibVersion: string) : integer;
  function SEPIA2_LIB_IsRunningOnWine           (var bIsRunningOnWine : boolean) : integer;

  // ---  USB functions  --------------------------------------------------------

  function SEPIA2_USB_OpenDevice                (iDevIdx: integer; var cProductModel: string; var cSerialNumber: string) : integer;
  function SEPIA2_USB_CloseDevice               (iDevIdx: integer) : integer;
  function SEPIA2_USB_GetStrDescriptor          (iDevIdx: integer; var cDescriptor: string) : integer;
  function SEPIA2_USB_OpenGetSerNumAndClose     (iDevIdx: integer; var cProductModel: string; var cSerialNumber: string) : integer;
  function SEPIA2_USB_IsOpenDevice              (iDevIdx: integer; var bIsOpenDevice : boolean) : integer;
  function SEPIA2_USB_GetStrDescrByIdx          (iDevIdx: integer; iDescrIdx: integer; var cDescriptor: string) : integer;

  // ---  firmware functions  ---------------------------------------------------

  function SEPIA2_FWR_GetVersion                (iDevIdx: integer;   var cFWVersion: string) : integer;
  function SEPIA2_FWR_GetLastError              (iDevIdx: integer;   var iErrCode, iPhase, iLocation, iSlot: integer; var cCondition: string) : integer;
  function SEPIA2_FWR_DecodeErrPhaseName        (iErrPhase: integer; var cErrorPhase: string) : integer;
  function SEPIA2_FWR_GetWorkingMode            (iDevIdx: integer; var fwmMode: T_SEPIA2_FWR_WORKINGMODE) : integer;
  function SEPIA2_FWR_SetWorkingMode            (iDevIdx: integer; fwmMode: T_SEPIA2_FWR_WORKINGMODE) : integer;
  function SEPIA2_FWR_RollBackToPermanentValues (iDevIdx: integer) : integer;
  function SEPIA2_FWR_StoreAsPermanentValues    (iDevIdx: integer) : integer;
  function SEPIA2_FWR_GetModuleMap              (iDevIdx: integer; bPerformRestart: boolean; var iModuleCount: integer) : integer;
  function SEPIA2_FWR_GetModuleInfoByMapIdx     (iDevIdx, iMapIdx: integer; var iSlotId: integer; var bIsPrimary, bIsBackPlane, bHasUptimeCounter: boolean) : integer;
  function SEPIA2_FWR_GetUptimeInfoByMapIdx     (iDevIdx, iMapIdx: integer; var dwMainPowerUp, dwActivePowerUp, dwScaledPowerUp: cardinal) : integer;
  function SEPIA2_FWR_CreateSupportRequestText  (iDevIdx: integer; cPreamble, cCallingSW: string; iOptions: integer; var cBuffer: string) : integer;
  function SEPIA2_FWR_FreeModuleMap             (iDevIdx: integer) : integer;


  // ---  common module functions  ----------------------------------------------

  function SEPIA2_COM_DecodeModuleType          (iModuleType: integer; var cModuleType: string) : integer;
  function SEPIA2_COM_DecodeModuleTypeAbbr      (iModuleType: integer; var cModuleTypeAbbr: string) : integer;
  function SEPIA2_COM_HasSecondaryModule        (iDevIdx, iSlotId: integer; var bHasSecondary: boolean) : integer;
  function SEPIA2_COM_GetModuleType             (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var iModuleType: integer) : integer;
  function SEPIA2_COM_GetSerialNumber           (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var cSerialNumber: string) : integer;
  function SEPIA2_COM_GetSupplementaryInfos     (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var cLabel: string; var dtRelease: TDateTime; var cRevision: string; var cMemo : string) : integer;
  function SEPIA2_COM_GetPresetInfo             (iDevIdx, iSlotId: integer; bGetPrimary: boolean; iPresetNr: integer; var bPresetIsSet: boolean; var cPresetMemo: string) : integer;
  function SEPIA2_COM_RecallPreset              (iDevIdx, iSlotId: integer; bGetPrimary: boolean; iPresetNr: integer) : integer;
  function SEPIA2_COM_SaveAsPreset              (iDevIdx, iSlotId: integer; bSetPrimary: boolean; iPresetNr: integer; const cPresetMemo: string) : integer;
  function SEPIA2_COM_IsWritableModule          (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var bIsWritable: boolean) : integer;
  function SEPIA2_COM_UpdateModuleData          (iDevIdx, iSlotId: integer; bSetPrimary: boolean; cFileName: string) : integer;


  // ---  SCM 828 functions  ----------------------------------------------------

  function SEPIA2_SCM_GetPowerAndLaserLEDS      (iDevIdx, iSlotId: integer;  var bPowerLED,   bLaserActiveLED: boolean) : integer;
  function SEPIA2_SCM_GetLaserLocked            (iDevIdx, iSlotId: integer;  var bLocked:     boolean) : integer;
  function SEPIA2_SCM_GetLaserSoftLock          (iDevIdx, iSlotId: integer;  var bSoftLocked: boolean) : integer;
  function SEPIA2_SCM_SetLaserSoftLock          (iDevIdx, iSlotId: integer;      bSoftLocked: boolean) : integer;


  // ---  SLM 828 functions  ----------------------------------------------------

  function SEPIA2_SLM_DecodeFreqTrigMode        (iFreq: integer; var cFreqTrigMode: string) : integer;
  function SEPIA2_SLM_DecodeHeadType            (iHeadType: integer; var cHeadType: string) : integer;
  //
{$ifdef __INCLUDE_DEPRECATED_SLM_FUNCTIONS__}
  function SEPIA2_SLM_GetParameters             (iDevIdx, iSlotId: integer; var iFreq: integer; var bPulseMode: boolean; var iHead: integer; var byteIntensity: byte) : integer;
  // deprecated  : SEPIA2_SLM_GetParameters;
  // use instead : SEPIA2_SLM_GetIntensityFineStep, SEPIA2_SLM_GetPulseParameters
  //
  function SEPIA2_SLM_SetParameters             (iDevIdx, iSlotId, iFreq: integer; bPulseMode: boolean; byteIntensity: byte) : integer;
  // deprecated  : SEPIA2_SLM_SetParameters;
  // use instead : SEPIA2_SLM_SetIntensityFineStep, SEPIA2_SLM_SetPulseParameters
{$endif}
  //
  function SEPIA2_SLM_GetIntensityFineStep      (iDevIdx, iSlotId: integer; var wIntensity: word) : integer;
  function SEPIA2_SLM_SetIntensityFineStep      (iDevIdx, iSlotId: integer; wIntensity: word) : integer;
  function SEPIA2_SLM_GetPulseParameters        (iDevIdx, iSlotId: integer; var iFreq: integer; var bPulseMode: boolean; var iHeadType: integer) : integer;
  function SEPIA2_SLM_SetPulseParameters        (iDevIdx, iSlotId: integer; iFreq: integer; bPulseMode: boolean) : integer;


  // ---  SML 828 functions  ----------------------------------------------------

  function SEPIA2_SML_DecodeHeadType            (iHeadType: integer; var cHeadType: string) : integer;
  function SEPIA2_SML_GetParameters             (iDevIdx, iSlotId: integer; var bPulseMode: boolean; var iHead: integer; var byteIntensity: byte) : integer;
  function SEPIA2_SML_SetParameters             (iDevIdx, iSlotId: integer; bPulseMode: boolean; byteIntensity: byte) : integer;


  // ---  SOM 828 / SOM 828 D functions  ----------------------------------------

const
  SEPIA2_API_SOM_SEQUENCER_CTRL_FREE_RUN        : byte = (0);
  SEPIA2_API_SOM_SEQUENCER_CTRL_RUN_ON_HIGH     : byte = (1);
  SEPIA2_API_SOM_SEQUENCER_CTRL_RUN_ON_LOW      : byte = (2);
  SEPIA2_API_SOM_SEQUENCER_DISABLED             : byte = (3);
  SEPIA2_API_SOM_AUXOUT_DISABLED                : byte = (0);
  SEPIA2_API_SOM_AUXOUT_SEQUENCER_IDXPULSE      : byte = (1);


  // ---  common SOM 828 / SOM 828 D functions  ---------------------------------

  function SEPIA2_SOM_DecodeFreqTrigMode        (iDevIdx, iSlotId, iFreqTrigIdx: integer; var cFreqTrigMode: string) : integer;
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


  // ---  SOM 828 only functions  -----------------------------------------------

  function SEPIA2_SOM_GetFreqTrigMode           (iDevIdx, iSlotId: integer; var iFreqTrigIdx: integer) : integer;
  function SEPIA2_SOM_SetFreqTrigMode           (iDevIdx, iSlotId, iFreqTrigIdx: integer) : integer;


  // ---  SOM 828 D only functions  ---------------------------------------------

  function SEPIA2_SOMD_GetFreqTrigMode          (iDevIdx, iSlotId: integer; var iFreqTrigIdx: integer; var bSynchronize: boolean) : integer;
  function SEPIA2_SOMD_SetFreqTrigMode          (iDevIdx, iSlotId, iFreqTrigIdx: integer; bSynchronize: boolean) : integer;
  function SEPIA2_SOMD_GetSeqOutputInfos        (iDevIdx, iSlotId: integer; byteSeqOutputIdx: byte; var bDelayed: boolean; var bForcedUndelayed: boolean; var byteOutCombi: byte; var bMaskedCombi: boolean; var f64CoarseDly: double; var iFineDly: integer) : integer;
  function SEPIA2_SOMD_SetSeqOutputInfos        (iDevIdx, iSlotId: integer; byteSeqOutputIdx: byte; bDelayed: boolean; byteOutCombi: byte; bMaskedCombi: boolean; f64CoarseDly: double; iFineDly: integer) : integer;
  function SEPIA2_SOMD_SynchronizeNow           (iDevIdx, iSlotId: integer) : integer;
  function SEPIA2_SOMD_DecodeModuleState        (wModuleState: word;        var cModuleState: string) : integer;
  function SEPIA2_SOMD_GetStatusError           (iDevIdx, iSlotId: integer; var wModuleState: word; var iErrorCode: integer) : integer;
  function SEPIA2_SOMD_GetTrigSyncFreq          (iDevIdx, iSlotId: integer; var bSyncStable: boolean; var iTrigSyncFreq: integer) : integer;
  function SEPIA2_SOMD_GetDelayUnits            (iDevIdx, iSlotId: integer; var fCoarseDlyStep: double; var byteFineDlyStepCount: byte) : integer;
  function SEPIA2_SOMD_GetFWVersion             (iDevIdx, iSlotId: integer; var FWVersion: T_SepiaModules_FWVersion) : integer;
  function SEPIA2_SOMD_FWReadPage               (iDevIdx, iSlotId: integer; wPageIdx: word; var FWPage: T_SOMD_FW_PAGE) : integer;
  function SEPIA2_SOMD_FWWritePage              (iDevIdx, iSlotId: integer; wPageIdx: word; const FWPage: T_SOMD_FW_PAGE) : integer;
  function SEPIA2_SOMD_GetHWParams              (iDevIdx, iSlotId: integer; var wHWParamTemp1, wHWParamTemp2, wHWParamTemp3, wHWParamVolt1, wHWParamVolt2, wHWParamVolt3, wHWParamVolt4, wHWParamAUX : word) : integer;


  // ---  SWM 828 (PPL 400) functions  -------------------------------------------

  function SEPIA2_SWM_DecodeRangeIdx            (iDevIdx, iSlotId: integer; iRangeIdx: integer; var iUpperLimit: integer) : integer;
  function SEPIA2_SWM_GetUIConstants            (iDevIdx, iSlotId: integer; var byteTBIdxCount: byte; var wMaxAmplitude, wMaxSlewRate, wExpRampEffect, wMinUserValue, wMaxUserValue, wUserResolution: word) : integer;
  function SEPIA2_SWM_GetCurveParams            (iDevIdx, iSlotId: integer; iCurveIdx: integer; var byteTBIdx: byte; var wPAPml, wRRPml, wPSPml, wRSPml, wWSPml: word) : integer;
  function SEPIA2_SWM_SetCurveParams            (iDevIdx, iSlotId: integer; iCurveIdx: integer; byteTBIdx: byte; wPAPml, wRRPml, wPSPml, wRSPml, wWSPml: word) : integer;
  function SEPIA2_SWM_GetExtAtten               (iDevIdx, iSlotId: integer; var fExtAtt: Single) : integer;
  function SEPIA2_SWM_SetExtAtten               (iDevIdx, iSlotId: integer; fExtAtt: Single) : integer;


  // ---  VCL 828 (PPL 400) functions  -------------------------------------------
  function SEPIA2_VCL_GetUIConstants            (iDevIdx, iSlotId: integer; var iMinUserValueTmp, iMaxUserValueTmp, iUserResolutionTmp : integer) : integer;
  function SEPIA2_VCL_GetTemperature            (iDevIdx, iSlotId: integer; var iTemperature : integer) : integer;
  function SEPIA2_VCL_SetTemperature            (iDevIdx, iSlotId: integer; iTemperature : integer) : integer;
  function SEPIA2_VCL_GetBiasVoltage            (iDevIdx, iSlotId: integer; var iBiasVoltage : integer) : integer;


  // ---  Solea SPM functions  --------------------------------------------------

  type

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


  function SEPIA2_SPM_DecodeModuleState         (wModuleState: word;        var cModuleState: string) : integer;
  function SEPIA2_SPM_GetDeviceDescription      (iDevIdx, iSlotId: integer; var cDeviceDescription: string) : integer;
  function SEPIA2_SPM_GetFWVersion              (iDevIdx, iSlotId: integer; var FWVersion: T_SepiaModules_FWVersion) : integer;
  function SEPIA2_SPM_GetSensorData             (iDevIdx, iSlotId: integer; var SensorData: T_SPM_SensorData) : integer;
  function SEPIA2_SPM_GetTemperatureAdjust      (iDevIdx, iSlotId: integer; var Temperatures: T_SPM_Temperatures) : integer;
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

  // --- VisUV/IR functions  ----------------------------------------------------

  function SEPIA2_VUV_VIR_GetDeviceType         (iDevIdx, iSlotId: integer; var cDeviceType: string; var bOptCW, bOptFanSwitch: boolean) : integer;
  function SEPIA2_VUV_VIR_DecodeFreqTrigMode    (iDevIdx, iSlotId: integer; iTrigSourceIdx, iFreqDividerIdx: integer; var cFreqTrigMode: string; var iMainFreq: integer; var bEnableDivList, bEnableTrigLvl: boolean) : integer;
  function SEPIA2_VUV_VIR_GetTrigLevelRange     (iDevIdx, iSlotId: integer; var iUpperTrigLevel, iLowerTrigLevel, iTrigLevelResol: integer) : integer;
  function SEPIA2_VUV_VIR_GetTriggerData        (iDevIdx, iSlotId: integer; var iTrigSrcIdx, iFreqDivIdx, iTrigLevel: integer) : integer;
  function SEPIA2_VUV_VIR_SetTriggerData        (iDevIdx, iSlotId: integer; iTrigSrcIdx, iFreqDivIdx, iTrigLevel: integer) : integer;
  function SEPIA2_VUV_VIR_GetIntensityRange     (iDevIdx, iSlotId: integer; var iUpperIntens, iLowerIntens, iIntensResol: integer) : integer;
  function SEPIA2_VUV_VIR_GetIntensity          (iDevIdx, iSlotId: integer; var iIntensity: integer) : integer;
  function SEPIA2_VUV_VIR_SetIntensity          (iDevIdx, iSlotId: integer; iIntensity: integer) : integer;
  function SEPIA2_VUV_VIR_GetFan                (iDevIdx, iSlotId: integer; var bFanRunning: boolean) : integer;
  function SEPIA2_VUV_VIR_SetFan                (iDevIdx, iSlotId: integer; bFanRunning: boolean) : integer;

  // --- Prima functions  ----------------------------------------------------
  type
    T_PRI_Constants = record
      bInitialized: Boolean;
      //
      PrimaModuleID: string;
      PrimaModuleType: string;
      PrimaFWVers: string;
      //
      PrimaTemp_min: Single;
      PrimaTemp_max: Single;
      //
      // bis hierher    init mit $00
      // --- - - - - - - - - - - ---  Initialisierungsgrenze
      // ab hier        init mit $FF
      //
      PrimaUSBIdx: Integer;
      PrimaSlotId: Integer;
      //
      PrimaWLCount: Integer;
      PrimaWLs: array [0..2] of Integer;
      //
      PrimaOpModCount: Integer;
      PrimaOpModOff: Integer;
      PrimaOpModNarrow: Integer;
      PrimaOpModBroad: Integer;
      PrimaOpModCW: Integer;
      //
      PrimaTrSrcCount: Integer;
      PrimaTrSrcInt: Integer;
      PrimaTrSrcExtNIM: Integer;
      PrimaTrSrcExtTTL: Integer;
      PrimaTrSrcExtFalling: Integer;
      PrimaTrSrcExtRising: Integer;
    end;

  function SEPIA2_PRI_GetConstants              (iDevIdx, iSlotId: integer; var PRIConstants: T_PRI_Constants) : integer;

  function SEPIA2_PRI_GetDeviceInfo             (iDevIdx, iSlotId: integer; var cPRIModuleID: string; var cPRIModuleType: string; var cFW_Vers: string; var iWLCount: integer) : integer;
  function SEPIA2_PRI_DecodeOperationMode       (iDevIdx, iSlotId: integer; iOpModeIdx: integer; var cOpMode: string) : integer;
  function SEPIA2_PRI_GetOperationMode          (iDevIdx, iSlotId: integer; var iOpModeIdx: integer) : integer;
  function SEPIA2_PRI_SetOperationMode          (iDevIdx, iSlotId: integer; iOpModeIdx: integer) : integer;
  function SEPIA2_PRI_DecodeTriggerSource       (iDevIdx, iSlotId: integer; iTrgSrcIdx: integer; var cTrgSrc: string; var bEnableFrequency, bEnableTrigLvl: boolean) : integer;
  function SEPIA2_PRI_GetTriggerSource          (iDevIdx, iSlotId: integer; var iTrgSrcIdx: integer) : integer;
  function SEPIA2_PRI_SetTriggerSource          (iDevIdx, iSlotId: integer; iTrgSrcIdx: integer) : integer;
  function SEPIA2_PRI_GetTriggerLevelLimits     (iDevIdx, iSlotId: integer; var iTrgMinLvl: integer; var iTrgMaxLvl: integer; var iTrgLvlRes: integer) : integer;
  function SEPIA2_PRI_GetTriggerLevel           (iDevIdx, iSlotId: integer; var iTrgLevel: integer) : integer;
  function SEPIA2_PRI_SetTriggerLevel           (iDevIdx, iSlotId: integer; iTrgLevel: integer) : integer;
  function SEPIA2_PRI_GetFrequencyLimits        (iDevIdx, iSlotId: integer; var iMinFreq: integer; var iMaxFreq: integer) : integer;
  function SEPIA2_PRI_GetFrequency              (iDevIdx, iSlotId: integer; var iFrequency: integer) : integer;
  function SEPIA2_PRI_SetFrequency              (iDevIdx, iSlotId: integer; iFrequency: integer) : integer;

  function SEPIA2_PRI_GetGatingLimits           (iDevIdx, iSlotId: integer; var iMinOnTime: integer; var iMaxOnTime: integer; var iMinOffTimefactor: integer; var iMaxOffTimefactor: integer) : integer;
  function SEPIA2_PRI_GetGatingData             (iDevIdx, iSlotId: integer; var iOnTime: integer; var iOffTimefact: integer) : integer;
  function SEPIA2_PRI_SetGatingData             (iDevIdx, iSlotId: integer; iOnTime, iOffTimefact: integer) : integer;
  function SEPIA2_PRI_GetGatingEnabled          (iDevIdx, iSlotId: integer; var bGatingEnabled: boolean) : integer;
  function SEPIA2_PRI_SetGatingEnabled          (iDevIdx, iSlotId: integer; bGatingEnabled: boolean) : integer;
  function SEPIA2_PRI_GetGateHighImpedance      (iDevIdx, iSlotId: integer; var bHighImp: boolean) : integer;
  function SEPIA2_PRI_SetGateHighImpedance      (iDevIdx, iSlotId: integer; bHighImp: boolean) : integer;
  function SEPIA2_PRI_DecodeWavelength          (iDevIdx, iSlotId: integer; iWLIdx: integer; var iWL: integer) : integer;
  function SEPIA2_PRI_GetWavelengthIdx          (iDevIdx, iSlotId: integer; var iWLIdx: integer) : integer;
  function SEPIA2_PRI_SetWavelengthIdx          (iDevIdx, iSlotId: integer; iWLIdx: integer) : integer;
  function SEPIA2_PRI_GetIntensity              (iDevIdx, iSlotId: integer; iWLIdx: integer; var wIntensity: word) : integer;
  function SEPIA2_PRI_SetIntensity              (iDevIdx, iSlotId: integer; iWLIdx: integer; wIntensity: word) : integer;


  procedure DebugOut (const iDir : Integer; const strIn : string; iRetVal : integer = 0); overload;
  procedure DebugOut (const iDir : Integer; const strIn : string; cAdditionalStr : string); overload;

  function GetDLLFunction (Name: PAnsiChar; Default: Pointer = nil): pointer;

  var
    bActiveDebugOut     : boolean;
    FormatSettings_enUS : TFormatSettings;
    hdlDLL              : THandle;
    strCurLibName       : string;
  {$ifdef __CALL_DEBUGOUT__}
    arrDebugModules     : array [T_SEPIA2_MODULE_INDEX] of boolean;
  {$endif}

  const
    PRI_TempADCRegIdx                                 =    3;                         // Temp ADC Register in Prima-modules
    PRI_SupPnts_TECRefVoltage                         =    3.3;                       // V
    PRI_SupPnts_Temperature : array [0..3] of Single  =  (15.0, 20.0, 30.0, 42.0);    // °C
    PRI_SupPnts_TECRegValue : array [0..3] of Word    =  ($000, $0BA, $1F0, $3FF);    // DAC-Steps


implementation

  uses
    WinAPI.Windows,
    System.StrUtils, System.Math, System.AnsiStrings,
    Sepia2_ErrorCodes;

  const
    SEPIA2_API_SPM_TRANSFERDIR_RAM2FLASH            = byte(1);
    SEPIA2_API_SPM_TRANSFERDIR_FLASH2RAM            = byte(0);

    SEPIA2_API_SPM_FRAM_WRITE_PROTECTED             = byte(1);
    SEPIA2_API_SPM_FRAM_WRITE_ENABLED               = byte(0);

    SEPIA2_API_SPM_FIBERAMPLIFIER_FAILURE           = byte(1);
    SEPIA2_API_SPM_FIBERAMPLIFIER_OK                = byte(0);

    SEPIA2_API_SPM_PUMPSTATE_ECOMODE                = byte(1);
    SEPIA2_API_SPM_PUMPSTATE_BOOSTMODE              = byte(0);

    SEPIA2_API_SPM_PUMPMODE_DYNAMIC                 = byte(1);
    SEPIA2_API_SPM_PUMPMODE_STATIC                  = byte(0);

  var
    iRet    : integer;

  type
    T_SEPIA2_LIB_GetVersion                = function (pcLibVersion: pAnsiChar) : integer; stdcall;
    T_SEPIA2_LIB_GetLibUSBVersion          = function (pcLibUSBVersion: pAnsiChar) : integer; stdcall;
    T_SEPIA2_LIB_IsRunningOnWine           = function (var byteIsRunningOnWine: byte) : integer; stdcall;
    T_SEPIA2_LIB_DecodeError               = function (iErrCode: integer; pcErrorString: pAnsiChar) : integer; stdcall;

    T_SEPIA2_USB_OpenDevice                = function (iDevIdx: integer; pcProductModel: pAnsiChar; pcSerialNumber: pAnsiChar) : integer; stdcall;
    T_SEPIA2_USB_CloseDevice               = function (iDevIdx: integer) : integer; stdcall;
    T_SEPIA2_USB_GetStrDescriptor          = function (iDevIdx: integer; pcDescriptor: pAnsiChar) : integer; stdcall;
    T_SEPIA2_USB_OpenGetSerNumAndClose     = function (iDevIdx: integer; pcProductModel: pAnsiChar; pcSerialNumber: pAnsiChar) : integer; stdcall;
    T_SEPIA2_USB_IsOpenDevice              = function (iDevIdx: integer; var byteIsOpenDevice: byte) : integer; stdcall;
    T_SEPIA2_USB_GetStrDescrByIdx          = function (iDevIdx: integer; iDescrIdx: integer; pcDescriptor: pAnsiChar) : integer; stdcall;

    T_SEPIA2_FWR_GetVersion                = function (iDevIdx: integer; pcFWVersion: pAnsiChar) : integer; stdcall;
    T_SEPIA2_FWR_GetLastError              = function (iDevIdx: integer; var iErrCode, iPhase, iLocation, iSlot: integer; pcCondition: pAnsiChar) : integer; stdcall;
    T_SEPIA2_FWR_DecodeErrPhaseName        = function (iErrPhase: integer; pcErrorPhase: pAnsiChar) : integer; stdcall;
    T_SEPIA2_FWR_GetWorkingMode            = function (iDevIdx: integer; var iMode: integer) : integer; stdcall;
    T_SEPIA2_FWR_SetWorkingMode            = function (iDevIdx: integer; iMode: integer) : integer; stdcall;
    T_SEPIA2_FWR_RollBackToPermanentValues = function (iDevIdx: integer) : integer; stdcall;
    T_SEPIA2_FWR_StoreAsPermanentValues    = function (iDevIdx: integer) : integer; stdcall;
    T_SEPIA2_FWR_GetModuleMap              = function (iDevIdx, iPerformRestart: integer; var iModuleCount: integer) : integer; stdcall;
    T_SEPIA2_FWR_GetModuleInfoByMapIdx     = function (iDevIdx, iMapIdx: integer; var iSlotId: integer; var byteIsPrimary, byteIsBackPlane, byteHasUptimeCounter: byte) : integer; stdcall;
    T_SEPIA2_FWR_GetUptimeInfoByMapIdx     = function (iDevIdx, iMapIdx: integer; var dwMainPowerUp, dwActivePowerUp, dwScaledPowerUp: cardinal) : integer; stdcall;
    T_SEPIA2_FWR_CreateSupportRequestText  = function (iDevIdx: integer; cPreamble, cCallingSW: pAnsiChar; iOptions, iBufferLen: integer; cBuffer: pAnsiChar) : integer; stdcall;
    T_SEPIA2_FWR_FreeModuleMap             = function (iDevIdx: integer) : integer; stdcall;

    T_SEPIA2_COM_DecodeModuleType          = function (iModuleType: integer; pcModuleType: pAnsiChar) : integer; stdcall;
    T_SEPIA2_COM_DecodeModuleTypeAbbr      = function (iModuleType: integer; pcModuleTypeAbbr: pAnsiChar) : integer; stdcall;
    T_SEPIA2_COM_HasSecondaryModule        = function (iDevIdx, iSlotId: integer; var iHasSecondary: integer) : integer; stdcall;
    T_SEPIA2_COM_GetModuleType             = function (iDevIdx, iSlotId, iGetPrimary: integer; var iModuleType: integer) : integer; stdcall;
    T_SEPIA2_COM_GetSerialNumber           = function (iDevIdx, iSlotId, iGetPrimary: integer; pcSerialNumber: pAnsiChar) : integer; stdcall;
    T_SEPIA2_COM_GetSupplementaryInfos     = function (iDevIdx, iSlotId, iGetPrimary: integer; pcLabel, pcReleaseDate, pcRevision, pcMemo : pAnsiChar) : integer; stdcall;
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
{$ifdef __INCLUDE_DEPRECATED_SLM_FUNCTIONS__}
    T_SEPIA2_SLM_GetParameters             = function (iDevIdx, iSlotId: integer; var iFreq: integer; var bytePulseMode: byte; var iHead: integer; var byteIntensity: byte) : integer; stdcall;
    // deprecated  : SEPIA2_SLM_GetParameters;
    // use instead : SEPIA2_SLM_GetIntensityFineStep, SEPIA2_SLM_GetPulseParameters
    T_SEPIA2_SLM_SetParameters             = function (iDevIdx, iSlotId, iFreq: integer; bytePulseMode, byteIntensity: byte) : integer; stdcall;
    // deprecated  : SEPIA2_SLM_SetParameters;
    // use instead : SEPIA2_SLM_SetIntensityFineStep, SEPIA2_SLM_SetPulseParameters
{$endif}
    //
    T_SEPIA2_SLM_GetIntensityFineStep      = function (iDevIdx, iSlotId: integer; var wIntensity: word) : integer; stdcall;
    T_SEPIA2_SLM_SetIntensityFineStep      = function (iDevIdx, iSlotId: integer; wIntensity: word) : integer; stdcall;
    T_SEPIA2_SLM_GetPulseParameters        = function (iDevIdx, iSlotId: integer; var iFreq: integer; var bytePulseMode: byte; var iHeadType: integer) : integer; stdcall;
    T_SEPIA2_SLM_SetPulseParameters        = function (iDevIdx, iSlotId, iFreq: integer; bytePulseMode: byte) : integer; stdcall;

    T_SEPIA2_SML_DecodeHeadType            = function (iHeadType: integer; pcHeadType: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SML_GetParameters             = function (iDevIdx, iSlotId: integer; var bytePulseMode: byte; var iHead: integer; var byteIntensity: byte) : integer; stdcall;
    T_SEPIA2_SML_SetParameters             = function (iDevIdx, iSlotId: integer; bytePulseMode, byteIntensity: byte) : integer; stdcall;

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

    T_SEPIA2_SOMD_DecodeFreqTrigMode       = function (iDevIdx, iSlotId, iFreqTrigIdx: integer; pcFreqTrigMode: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SOMD_GetFreqTrigMode          = function (iDevIdx, iSlotId: integer; var iFreqTrigIdx: integer; var byteSynchronize: byte) : integer; stdcall;
    T_SEPIA2_SOMD_SetFreqTrigMode          = function (iDevIdx, iSlotId, iFreqTrigIdx: integer; byteSynchronize: byte) : integer; stdcall;
    T_SEPIA2_SOMD_GetTriggerRange          = function (iDevIdx, iSlotId: integer; var iMilliVoltLow, iMilliVoltHigh: integer) : integer; stdcall;
    T_SEPIA2_SOMD_GetTriggerLevel          = function (iDevIdx, iSlotId: integer; var iMilliVolt: integer) : integer; stdcall;
    T_SEPIA2_SOMD_SetTriggerLevel          = function (iDevIdx, iSlotId, iMilliVolt: integer) : integer; stdcall;
    T_SEPIA2_SOMD_GetBurstValues           = function (iDevIdx, iSlotId: integer; var wDivider: word; var bytePreSync, byteSyncMask: byte) : integer; stdcall;
    T_SEPIA2_SOMD_SetBurstValues           = function (iDevIdx, iSlotId: integer; wDivider: word; bytePreSync, byteSyncMask: byte) : integer; stdcall;
    T_SEPIA2_SOMD_GetBurstLengthArray      = function (iDevIdx, iSlotId: integer; var lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8: longint) : integer; stdcall;
    T_SEPIA2_SOMD_SetBurstLengthArray      = function (iDevIdx, iSlotId: integer; lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8: longint) : integer; stdcall;
    T_SEPIA2_SOMD_GetOutNSyncEnable        = function (iDevIdx, iSlotId: integer; var byteOutEnable, byteSyncEnable, byteSyncInverse: byte) : integer; stdcall;
    T_SEPIA2_SOMD_SetOutNSyncEnable        = function (iDevIdx, iSlotId: integer; byteOutEnable, byteSyncEnable, byteSyncInverse: byte) : integer; stdcall;
    T_SEPIA2_SOMD_DecodeAUXINSequencerCtrl = function (byteAuxInCtrl: byte; pcSequencerCtrl: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SOMD_GetAUXIOSequencerCtrl    = function (iDevIdx, iSlotId: integer; var byteAUXOutEnable, byteAUXInSequencerCtrl: byte) : integer; stdcall;
    T_SEPIA2_SOMD_SetAUXIOSequencerCtrl    = function (iDevIdx, iSlotId: integer; byteAUXOutEnable, byteAUXInSequencerCtrl: byte) : integer; stdcall;

    T_SEPIA2_SOMD_GetSeqOutputInfos        = function (iDevIdx, iSlotId: integer; byteSeqOutputIdx: byte; var byteDelayed: byte; var byteForcedUndelayed: byte; var byteOutCombi: byte; var byteMaskedCombi: byte; var f64CoarseDly: double; var byteFineDly: byte) : integer; stdcall;
    T_SEPIA2_SOMD_SetSeqOutputInfos        = function (iDevIdx, iSlotId: integer; byteSeqOutputIdx: byte; byteDelayed: byte; byteOutCombi: byte; byteMaskedCombi: byte; f64CoarseDly: double; byteFineDly: byte) : integer; stdcall;

    T_SEPIA2_SOMD_SynchronizeNow           = function (iDevIdx, iSlotId: integer) : integer; stdcall;
    T_SEPIA2_SOMD_DecodeModuleState        = function (wModuleState: Word; pcModuleState: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SOMD_GetStatusError           = function (iDevIdx, iSlotId: integer; var wModuleState: word; var iErrorCode: SmallInt) : integer; stdcall;
    T_SEPIA2_SOMD_GetTrigSyncFreq          = function (iDevIdx, iSlotId: integer; var byteSyncStable: byte; var iTrigSyncFreq: integer) : integer; stdcall;
    T_SEPIA2_SOMD_GetDelayUnits            = function (iDevIdx, iSlotId: integer; var fCoarseDlyStep: double; var byteFineDlyStepCount: byte) : integer; stdcall;
    T_SEPIA2_SOMD_GetFWVersion             = function (iDevIdx, iSlotId: integer; var ulFWVersion: Cardinal) : integer; stdcall;
    T_SEPIA2_SOMD_FWReadPage               = function (iDevIdx, iSlotId: integer; wPageIdx: word; var FWPage: T_SOMD_FW_PAGE) : integer; stdcall;
    T_SEPIA2_SOMD_FWWritePage              = function (iDevIdx, iSlotId: integer; wPageIdx: word; const FWPage: T_SOMD_FW_PAGE) : integer; stdcall;
    T_SEPIA2_SOMD_GetHWParams              = function (iDevIdx, iSlotId: integer; var wHWParamTemp1, wHWParamTemp2, wHWParamTemp3, wHWParamVolt1, wHWParamVolt2, wHWParamVolt3, wHWParamVolt4, wHWParamAUX : word) : integer; stdcall;

    T_SEPIA2_SWM_DecodeRangeIdx            = function (iDevIdx, iSlotId: integer; iRangeIdx: integer; var iUpperLimit: integer) : integer; stdcall;
    T_SEPIA2_SWM_GetUIConstants            = function (iDevIdx, iSlotId: integer; var byteTBIdxCount: byte; var wMaxAmplitude, wMaxSlewRate, wExpRampEffect, wMinUserValue, wMaxUserValue, wUserResolution: word) : integer; stdcall;
    T_SEPIA2_SWM_GetCurveParams            = function (iDevIdx, iSlotId: integer; iCurveIdx: integer; var byteTBIdx: byte; var wPAPml, wRRPml, wPSPml, wRSPml, wWSPml: word) : integer; stdcall;
    T_SEPIA2_SWM_SetCurveParams            = function (iDevIdx, iSlotId: integer; iCurveIdx: integer;     byteTBIdx: byte;     wPAPml, wRRPml, wPSPml, wRSPml, wWSPml: word) : integer; stdcall;
    T_SEPIA2_SWM_GetExtAtten               = function (iDevIdx, iSlotId: integer; var fExtAtt: Single) : integer; stdcall;
    T_SEPIA2_SWM_SetExtAtten               = function (iDevIdx, iSlotId: integer; fExtAtt: Single) : integer; stdcall;

    T_SEPIA2_VCL_GetUIConstants            = function (iDevIdx, iSlotId: integer; var iMinUserValueTmp, iMaxUserValueTmp, iUserResolutionTmp : integer) : integer; stdcall;
    T_SEPIA2_VCL_GetTemperature            = function (iDevIdx, iSlotId: integer; var iTemperature : integer) : integer; stdcall;
    T_SEPIA2_VCL_SetTemperature            = function (iDevIdx, iSlotId: integer; iTemperature : integer) : integer; stdcall;
    T_SEPIA2_VCL_GetBiasVoltage            = function (iDevIdx, iSlotId: integer; var iBiasVoltage : integer) : integer; stdcall;

    T_SEPIA2_SPM_DecodeModuleState         = function (wModuleState: Word; pcModuleState: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SPM_GetFWVersion              = function (iDevIdx, iSlotId: integer; var ulFWVersion: Cardinal) : integer; stdcall;
    T_SEPIA2_SPM_GetDeviceDescription      = function (iDevIdx, iSlotId: integer; pcDeviceDescription: pAnsiChar) : integer; stdcall;
    T_SEPIA2_SPM_GetSensorData             = function (iDevIdx, iSlotId: integer; var SensorData : T_SPM_SensorData) : integer; stdcall;
    T_SEPIA2_SPM_GetTemperatureAdjust      = function (iDevIdx, iSlotId: integer; var Temperatures : T_SPM_Temperatures) : integer; stdcall;
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

    T_SEPIA2_VUV_VIR_GetDeviceType         = function (iDevIdx, iSlotId: integer; pcDeviceType: pAnsiChar; var byteOptCW: byte; var byteOptFanSwitch: byte) : integer; stdcall;
    T_SEPIA2_VUV_VIR_DecodeFreqTrigMode    = function (iDevIdx, iSlotId: integer; iTrigSrcIdx, iFreqDivIdx: integer; pcFreqTrigMode: pAnsiChar; var iMainFreq: integer; var byteEnableDivList, byteEnableTrigLvl: byte) : integer; stdcall;
    T_SEPIA2_VUV_VIR_GetTrigLevelRange     = function (iDevIdx, iSlotId: integer; var iUpperTL, iLowerTL, iTLResol: integer) : integer; stdcall;
    T_SEPIA2_VUV_VIR_GetTriggerData        = function (iDevIdx, iSlotId: integer; var iTrigSrcIdx, iFreqDivIdx, iTrigLevel: integer) : integer; stdcall;
    T_SEPIA2_VUV_VIR_SetTriggerData        = function (iDevIdx, iSlotId: integer; iTrigSrcIdx, iFreqDivIdx, iTrigLevel: integer) : integer; stdcall;
    T_SEPIA2_VUV_VIR_GetIntensityRange     = function (iDevIdx, iSlotId: integer; var iUpperIntens, iLowerIntens, iIntensResol: integer) : integer; stdcall;
    T_SEPIA2_VUV_VIR_GetIntensity          = function (iDevIdx, iSlotId: integer; var iIntensity: integer) : integer; stdcall;
    T_SEPIA2_VUV_VIR_SetIntensity          = function (iDevIdx, iSlotId: integer; iIntensity: integer) : integer; stdcall;
    T_SEPIA2_VUV_VIR_GetFan                = function (iDevIdx, iSlotId: integer; var byteFanRunning: byte) : integer; stdcall;
    T_SEPIA2_VUV_VIR_SetFan                = function (iDevIdx, iSlotId: integer; byteFanRunning: byte) : integer; stdcall;
    T_SEPIA2_VUV_VIR_GetPumpData           = function (iDevIdx, iSlotId: integer; iRegisterIdx: integer; var iRegisterVal: integer) : integer; stdcall;
    T_SEPIA2_VUV_VIR_SetPumpData           = function (iDevIdx, iSlotId: integer; iRegisterIdx, iRegisterVal: integer) : integer; stdcall;

    T_SEPIA2_PRI_GetDeviceInfo             = function (iDevIdx, iSlotId: integer; pcPRIModulID: pAnsiChar; pcPRIModulType: pAnsiChar; pcFW_Vers: pAnsiChar; var iWLCount: integer) : integer; stdcall;
    T_SEPIA2_PRI_DecodeOperationMode       = function (iDevIdx, iSlotId: integer; iOpModeIdx: integer; pcOpMode: pAnsiChar) : integer; stdcall;
    T_SEPIA2_PRI_GetOperationMode          = function (iDevIdx, iSlotId: integer; var iOpModeIdx: integer) : integer; stdcall;
    T_SEPIA2_PRI_SetOperationMode          = function (iDevIdx, iSlotId: integer; iOpModeIdx: integer) : integer; stdcall;
    T_SEPIA2_PRI_DecodeTriggerSource       = function (iDevIdx, iSlotId: integer; iTrgSrcIdx: integer; pcTrgSrc: pAnsiChar; var byteEnableFrequency, byteEnableTrigLvl: byte) : integer; stdcall;
    T_SEPIA2_PRI_GetTriggerSource          = function (iDevIdx, iSlotId: integer; var iTrgSrcIdx: integer) : integer; stdcall;
    T_SEPIA2_PRI_SetTriggerSource          = function (iDevIdx, iSlotId: integer; iTrgSrcIdx: integer) : integer; stdcall;
    T_SEPIA2_PRI_GetTriggerLevelLimits     = function (iDevIdx, iSlotId: integer; var iTrgMinLvl: integer; var iTrgMaxLvl: integer; var iTrgLvlRes: integer) : integer; stdcall;
    T_SEPIA2_PRI_GetTriggerLevel           = function (iDevIdx, iSlotId: integer; var iTrgLvl: integer) : integer; stdcall;
    T_SEPIA2_PRI_SetTriggerLevel           = function (iDevIdx, iSlotId: integer; iTrgLvl: integer) : integer; stdcall;
    T_SEPIA2_PRI_GetFrequencyLimits        = function (iDevIdx, iSlotId: integer; var iMinFreq: integer; var iMaxFreq: integer) : integer; stdcall;
    T_SEPIA2_PRI_GetFrequency              = function (iDevIdx, iSlotId: integer; var iFrequency: integer) : integer; stdcall;
    T_SEPIA2_PRI_SetFrequency              = function (iDevIdx, iSlotId: integer; iFrequency: integer) : integer; stdcall;
    T_SEPIA2_PRI_GetGatingLimits           = function (iDevIdx, iSlotId: integer; var iMinOnTime: integer; var iMaxOnTime: integer; var iMinOffTimefactor: integer; var iMaxOffTimefactor) : integer; stdcall;
    T_SEPIA2_PRI_GetGatingData             = function (iDevIdx, iSlotId: integer; var iOnTime: integer; var iOffTimefact: integer) : integer; stdcall;
    T_SEPIA2_PRI_SetGatingData             = function (iDevIdx, iSlotId: integer; iOnTime, iOffTimefact: integer) : integer; stdcall;
    T_SEPIA2_PRI_GetGatingEnabled          = function (iDevIdx, iSlotId: integer; var bGatingEnabled: byte) : integer; stdcall;
    T_SEPIA2_PRI_SetGatingEnabled          = function (iDevIdx, iSlotId: integer; bGatingEnabled: byte) : integer; stdcall;
    T_SEPIA2_PRI_GetGateHighImpedance      = function (iDevIdx, iSlotId: integer; var byteHighImp: byte) : integer; stdcall;
    T_SEPIA2_PRI_SetGateHighImpedance      = function (iDevIdx, iSlotId: integer; byteHighImp: byte) : integer; stdcall;
    T_SEPIA2_PRI_DecodeWavelength          = function (iDevIdx, iSlotId: integer; iWLIdx: integer; var iWL: integer) : integer; stdcall;
    T_SEPIA2_PRI_GetWavelengthIdx          = function (iDevIdx, iSlotId: integer; var iWLIdx: integer) : integer; stdcall;
    T_SEPIA2_PRI_SetWavelengthIdx          = function (iDevIdx, iSlotId: integer; iWLIdx: integer) : integer; stdcall;
    T_SEPIA2_PRI_GetIntensity              = function (iDevIdx, iSlotId: integer; iWLIdx: integer; var wIntensity: word) : integer; stdcall;
    T_SEPIA2_PRI_SetIntensity              = function (iDevIdx, iSlotId: integer; iWLIdx: integer; wIntensity: word) : integer; stdcall;


  const
    TEMPVAR_LENGTH                         =     1025;
    TEMPLONGVAR_LENGTH                     =   262145;  // 65537;  // reicht manchmal nicht aus, z.B. bei SupportRequest auf MatLab-Rechnern...

  var
    pcTmpVal1                             : pAnsiChar;
    pcTmpVal2                             : pAnsiChar;
    pcTmpVal3                             : pAnsiChar;
    pcTmpLongVal1                         : pAnsiChar;
    pcTmpLongVal2                         : pAnsiChar;

    _SEPIA2_LIB_GetVersion                : T_SEPIA2_LIB_GetVersion;
    _SEPIA2_LIB_GetLibUSBVersion          : T_SEPIA2_LIB_GetLibUSBVersion;
    _SEPIA2_LIB_IsRunningOnWine           : T_SEPIA2_LIB_IsRunningOnWine;
    _SEPIA2_LIB_DecodeError               : T_SEPIA2_LIB_DecodeError;

    _SEPIA2_USB_OpenDevice                : T_SEPIA2_USB_OpenDevice;
    _SEPIA2_USB_CloseDevice               : T_SEPIA2_USB_CloseDevice;
    _SEPIA2_USB_GetStrDescriptor          : T_SEPIA2_USB_GetStrDescriptor;
    _SEPIA2_USB_OpenGetSerNumAndClose     : T_SEPIA2_USB_OpenGetSerNumAndClose;
    _SEPIA2_USB_IsOpenDevice              : T_SEPIA2_USB_IsOpenDevice;
    _SEPIA2_USB_GetStrDescrByIdx          : T_SEPIA2_USB_GetStrDescrByIdx;

    _SEPIA2_FWR_GetVersion                : T_SEPIA2_FWR_GetVersion;
    _SEPIA2_FWR_GetLastError              : T_SEPIA2_FWR_GetLastError;
    _SEPIA2_FWR_DecodeErrPhaseName        : T_SEPIA2_FWR_DecodeErrPhaseName;
    _SEPIA2_FWR_GetWorkingMode            : T_SEPIA2_FWR_GetWorkingMode;
    _SEPIA2_FWR_SetWorkingMode            : T_SEPIA2_FWR_SetWorkingMode;
    _SEPIA2_FWR_RollBackToPermanentValues : T_SEPIA2_FWR_RollBackToPermanentValues;
    _SEPIA2_FWR_StoreAsPermanentValues    : T_SEPIA2_FWR_StoreAsPermanentValues;
    _SEPIA2_FWR_GetModuleMap              : T_SEPIA2_FWR_GetModuleMap;
    _SEPIA2_FWR_GetModuleInfoByMapIdx     : T_SEPIA2_FWR_GetModuleInfoByMapIdx;
    _SEPIA2_FWR_GetUptimeInfoByMapIdx     : T_SEPIA2_FWR_GetUptimeInfoByMapIdx;
    _SEPIA2_FWR_CreateSupportRequestText  : T_SEPIA2_FWR_CreateSupportRequestText;
    _SEPIA2_FWR_FreeModuleMap             : T_SEPIA2_FWR_FreeModuleMap;

    _SEPIA2_COM_DecodeModuleType          : T_SEPIA2_COM_DecodeModuleType;
    _SEPIA2_COM_DecodeModuleTypeAbbr      : T_SEPIA2_COM_DecodeModuleTypeAbbr;
    _SEPIA2_COM_HasSecondaryModule        : T_SEPIA2_COM_HasSecondaryModule;
    _SEPIA2_COM_GetModuleType             : T_SEPIA2_COM_GetModuleType;
    _SEPIA2_COM_GetSerialNumber           : T_SEPIA2_COM_GetSerialNumber;
    _SEPIA2_COM_GetSupplementaryInfos     : T_SEPIA2_COM_GetSupplementaryInfos;
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
{$ifdef __INCLUDE_DEPRECATED_SLM_FUNCTIONS__}
    _SEPIA2_SLM_GetParameters             : T_SEPIA2_SLM_GetParameters;
    // deprecated  : SEPIA2_SLM_GetParameters;
    // use instead : SEPIA2_SLM_GetIntensityFineStep, SEPIA2_SLM_GetPulseParameters
    _SEPIA2_SLM_SetParameters             : T_SEPIA2_SLM_SetParameters;
    // deprecated  : SEPIA2_SLM_SetParameters;
    // use instead : SEPIA2_SLM_SetIntensityFineStep, SEPIA2_SLM_SetPulseParameters
{$endif}
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

    _SEPIA2_SOMD_DecodeFreqTrigMode       : T_SEPIA2_SOMD_DecodeFreqTrigMode;
    _SEPIA2_SOMD_GetFreqTrigMode          : T_SEPIA2_SOMD_GetFreqTrigMode;
    _SEPIA2_SOMD_SetFreqTrigMode          : T_SEPIA2_SOMD_SetFreqTrigMode;
    _SEPIA2_SOMD_GetTriggerRange          : T_SEPIA2_SOMD_GetTriggerRange;
    _SEPIA2_SOMD_GetTriggerLevel          : T_SEPIA2_SOMD_GetTriggerLevel;
    _SEPIA2_SOMD_SetTriggerLevel          : T_SEPIA2_SOMD_SetTriggerLevel;
    _SEPIA2_SOMD_GetBurstValues           : T_SEPIA2_SOMD_GetBurstValues;
    _SEPIA2_SOMD_SetBurstValues           : T_SEPIA2_SOMD_SetBurstValues;
    _SEPIA2_SOMD_GetBurstLengthArray      : T_SEPIA2_SOMD_GetBurstLengthArray;
    _SEPIA2_SOMD_SetBurstLengthArray      : T_SEPIA2_SOMD_SetBurstLengthArray;
    _SEPIA2_SOMD_GetOutNSyncEnable        : T_SEPIA2_SOMD_GetOutNSyncEnable;
    _SEPIA2_SOMD_SetOutNSyncEnable        : T_SEPIA2_SOMD_SetOutNSyncEnable;
    _SEPIA2_SOMD_DecodeAUXINSequencerCtrl : T_SEPIA2_SOMD_DecodeAUXINSequencerCtrl;
    _SEPIA2_SOMD_GetAUXIOSequencerCtrl    : T_SEPIA2_SOMD_GetAUXIOSequencerCtrl;
    _SEPIA2_SOMD_SetAUXIOSequencerCtrl    : T_SEPIA2_SOMD_SetAUXIOSequencerCtrl;
    _SEPIA2_SOMD_GetSeqOutputInfos        : T_SEPIA2_SOMD_GetSeqOutputInfos;
    _SEPIA2_SOMD_SetSeqOutputInfos        : T_SEPIA2_SOMD_SetSeqOutputInfos;
    _SEPIA2_SOMD_SynchronizeNow           : T_SEPIA2_SOMD_SynchronizeNow;
    _SEPIA2_SOMD_DecodeModuleState        : T_SEPIA2_SOMD_DecodeModuleState;
    _SEPIA2_SOMD_GetStatusError           : T_SEPIA2_SOMD_GetStatusError;
    _SEPIA2_SOMD_GetTrigSyncFreq          : T_SEPIA2_SOMD_GetTrigSyncFreq;
    _SEPIA2_SOMD_GetDelayUnits            : T_SEPIA2_SOMD_GetDelayUnits;
    _SEPIA2_SOMD_GetFWVersion             : T_SEPIA2_SOMD_GetFWVersion;
    _SEPIA2_SOMD_FWReadPage               : T_SEPIA2_SOMD_FWReadPage;
    _SEPIA2_SOMD_FWWritePage              : T_SEPIA2_SOMD_FWWritePage;
    _SEPIA2_SOMD_GetHWParams              : T_SEPIA2_SOMD_GetHWParams;

    _SEPIA2_SWM_DecodeRangeIdx            : T_SEPIA2_SWM_DecodeRangeIdx;
    _SEPIA2_SWM_GetUIConstants            : T_SEPIA2_SWM_GetUIConstants;
    _SEPIA2_SWM_GetCurveParams            : T_SEPIA2_SWM_GetCurveParams;
    _SEPIA2_SWM_SetCurveParams            : T_SEPIA2_SWM_SetCurveParams;
    _SEPIA2_SWM_GetExtAtten               : T_SEPIA2_SWM_GetExtAtten;
    _SEPIA2_SWM_SetExtAtten               : T_SEPIA2_SWM_SetExtAtten;

    _SEPIA2_VCL_GetUIConstants            : T_SEPIA2_VCL_GetUIConstants;
    _SEPIA2_VCL_GetTemperature            : T_SEPIA2_VCL_GetTemperature;
    _SEPIA2_VCL_SetTemperature            : T_SEPIA2_VCL_SetTemperature;
    _SEPIA2_VCL_GetBiasVoltage            : T_SEPIA2_VCL_GetBiasVoltage;

    _SEPIA2_SPM_DecodeModuleState         : T_SEPIA2_SPM_DecodeModuleState;
    _SEPIA2_SPM_GetDeviceDescription      : T_SEPIA2_SPM_GetDeviceDescription;
    _SEPIA2_SPM_GetFWVersion              : T_SEPIA2_SPM_GetFWVersion;
    _SEPIA2_SPM_GetSensorData             : T_SEPIA2_SPM_GetSensorData;
    _SEPIA2_SPM_GetTemperatureAdjust      : T_SEPIA2_SPM_GetTemperatureAdjust;
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

    _SEPIA2_VUV_VIR_GetDeviceType         : T_SEPIA2_VUV_VIR_GetDeviceType;
    _SEPIA2_VUV_VIR_DecodeFreqTrigMode    : T_SEPIA2_VUV_VIR_DecodeFreqTrigMode;
    _SEPIA2_VUV_VIR_GetTrigLevelRange     : T_SEPIA2_VUV_VIR_GetTrigLevelRange;
    _SEPIA2_VUV_VIR_GetTriggerData        : T_SEPIA2_VUV_VIR_GetTriggerData;
    _SEPIA2_VUV_VIR_SetTriggerData        : T_SEPIA2_VUV_VIR_SetTriggerData;
    _SEPIA2_VUV_VIR_GetIntensityRange     : T_SEPIA2_VUV_VIR_GetIntensityRange;
    _SEPIA2_VUV_VIR_GetIntensity          : T_SEPIA2_VUV_VIR_GetIntensity;
    _SEPIA2_VUV_VIR_SetIntensity          : T_SEPIA2_VUV_VIR_SetIntensity;
    _SEPIA2_VUV_VIR_GetFan                : T_SEPIA2_VUV_VIR_GetFan;
    _SEPIA2_VUV_VIR_SetFan                : T_SEPIA2_VUV_VIR_SetFan;

    _SEPIA2_PRI_GetDeviceInfo             : T_SEPIA2_PRI_GetDeviceInfo;
    _SEPIA2_PRI_DecodeOperationMode       : T_SEPIA2_PRI_DecodeOperationMode;
    _SEPIA2_PRI_GetOperationMode          : T_SEPIA2_PRI_GetOperationMode;
    _SEPIA2_PRI_SetOperationMode          : T_SEPIA2_PRI_SetOperationMode;
    _SEPIA2_PRI_DecodeTriggerSource       : T_SEPIA2_PRI_DecodeTriggerSource;
    _SEPIA2_PRI_GetTriggerSource          : T_SEPIA2_PRI_GetTriggerSource;
    _SEPIA2_PRI_SetTriggerSource          : T_SEPIA2_PRI_SetTriggerSource;
    _SEPIA2_PRI_GetTriggerLevelLimits     : T_SEPIA2_PRI_GetTriggerLevelLimits;
    _SEPIA2_PRI_GetTriggerLevel           : T_SEPIA2_PRI_GetTriggerLevel;
    _SEPIA2_PRI_SetTriggerLevel           : T_SEPIA2_PRI_SetTriggerLevel;
    _SEPIA2_PRI_GetFrequencyLimits        : T_SEPIA2_PRI_GetFrequencyLimits;
    _SEPIA2_PRI_GetFrequency              : T_SEPIA2_PRI_GetFrequency;
    _SEPIA2_PRI_SetFrequency              : T_SEPIA2_PRI_SetFrequency;
    _SEPIA2_PRI_GetGatingLimits           : T_SEPIA2_PRI_GetGatingLimits;
    _SEPIA2_PRI_GetGatingData             : T_SEPIA2_PRI_GetGatingData;
    _SEPIA2_PRI_SetGatingData             : T_SEPIA2_PRI_SetGatingData;
    _SEPIA2_PRI_GetGatingEnabled          : T_SEPIA2_PRI_GetGatingEnabled;
    _SEPIA2_PRI_SetGatingEnabled          : T_SEPIA2_PRI_SetGatingEnabled;
    _SEPIA2_PRI_GetGateHighImpedance      : T_SEPIA2_PRI_GetGateHighImpedance;
    _SEPIA2_PRI_SetGateHighImpedance      : T_SEPIA2_PRI_SetGateHighImpedance;
    _SEPIA2_PRI_DecodeWavelength          : T_SEPIA2_PRI_DecodeWavelength;
    _SEPIA2_PRI_GetWavelengthIdx          : T_SEPIA2_PRI_GetWavelengthIdx;
    _SEPIA2_PRI_SetWavelengthIdx          : T_SEPIA2_PRI_SetWavelengthIdx;
    _SEPIA2_PRI_GetIntensity              : T_SEPIA2_PRI_GetIntensity;
    _SEPIA2_PRI_SetIntensity              : T_SEPIA2_PRI_SetIntensity;

  procedure DebugOut (const iDir : Integer; const strIn : string; iRetVal : integer = 0); overload;
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
              strDir := ' --- ';
        end;
        OutputDebugString (PWideChar (Format ('PQLaserDrv:%s%s%s', [strDir, strIn, ifthen (iRetVal <> 0, ' => ' + IntToStr (iRetVal), '')])));
      end;
    {$endif}
  end;  // DebugOut (const iDir : Integer; const strIn : string; iRetVal : integer = 0);


  procedure DebugOut (const iDir : Integer; const strIn : string; cAdditionalStr : string); overload;
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
              strDir := ' --- ';
        end;
        OutputDebugString (PWideChar (Format ('PQLaserDrv:%s%s%s', [strDir, strIn, ifthen (length(cAdditionalStr) > 0, ' ' + cAdditionalStr, '')])));
      end;
    {$endif}
  end;  // DebugOut (const iDir : Integer; const strIn : string; cAdditionalStr : string);


  function SEPIA2_LIB_GetVersion (var cLibVersion: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_LIB_GetVersion';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_LIB_GetVersion (pcTmpVal1);
    cLibVersion := string(pcTmpVal1);
    SEPIA2_LIB_GetVersion := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_LIB_GetVersion


  function SUBST_LIB_GetLibUSBVersion (var cLibUSBVersion: string) : integer; stdcall;
  const
    strFkt  = 'SUBST_LIB_GetLibUSBVersion';
  begin
    DebugOut (1, strFkt);
    cLibUSBVersion := '0x0';
    SUBST_LIB_GetLibUSBVersion := SEPIA2_ERR_NO_ERROR;
    DebugOut (0, strFkt, SEPIA2_ERR_NO_ERROR);
  end;  // SUBST_LIB_GetLibUSBVersion

  function SEPIA2_LIB_GetLibUSBVersion (var cLibUSBVersion: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_LIB_GetLibUSBVersion';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_LIB_GetLibUSBVersion (pcTmpVal1);
    cLibUSBVersion := string(pcTmpVal1);
    SEPIA2_LIB_GetLibUSBVersion := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_LIB_GetLibUSBVersion


  function SEPIA2_LIB_IsRunningOnWine (var bIsRunningOnWine: boolean) : integer;
  var
    iRetVal : integer;
    byteIsRunningOnWine : byte;
  const
    strFkt  = 'SEPIA2_LIB_IsRunningOnWine';
  begin
    DebugOut (1, strFkt);
    iRetVal           := _SEPIA2_LIB_IsRunningOnWine (byteIsRunningOnWine);
    bIsRunningOnWine  := (byteIsRunningOnWine <> 0);
    SEPIA2_LIB_IsRunningOnWine := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_LIB_IsRunningOnWine


  function SEPIA2_LIB_DecodeError (iErrCode: integer; var cErrorString: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_LIB_DecodeError';
  begin
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
    strPM   : AnsiString;
    strSN   : AnsiString;
  const
    strFkt  = 'SEPIA2_USB_OpenDevice';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    if (Length (cProductModel) > 0)
    then begin
      strPM := AnsiString (trim (cProductModel));
      System.AnsiStrings.StrCopy (pcTmpVal1, PAnsiChar(strPM));
    end;
    FillChar(pcTmpVal2^, TEMPVAR_LENGTH, #0);
    if (Length (cSerialNumber) > 0)
    then begin
      strSN := AnsiString (trim (cSerialNumber));
      System.AnsiStrings.StrCopy (pcTmpVal2, PAnsiChar(strSN));
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
  const
    strFkt  = 'SEPIA2_USB_CloseDevice';
  begin
    DebugOut (1, strFkt);
    iRetVal :=  _SEPIA2_USB_CloseDevice (iDevIdx);
    SEPIA2_USB_CloseDevice :=  iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_USB_CloseDevice


  function SEPIA2_USB_GetStrDescriptor (iDevIdx: integer; var cDescriptor: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_USB_GetStrDescriptor';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_USB_GetStrDescriptor (iDevIdx, pcTmpVal1);
    cDescriptor := string(pcTmpVal1);
    SEPIA2_USB_GetStrDescriptor := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_USB_GetStrDescriptor

  function SUBST_USB_GetStrDescrByIdx (iDevIdx: integer; iDescrIdx: integer; pcDescriptor: pAnsiChar) : integer; stdcall;
  var
    iRetVal : integer;
    cTempStr: string;
    caTempStr: AnsiString;
  const
    strFkt  = 'SUBST_USB_GetStrDescrByIdx';
  begin
    DebugOut (1, strFkt);
    //
    // iRetVal := SEPIA2_USB_GetStrDescriptor (iDevIdx, cTempStr);
    // returns    cTempStr := '<vendor>, <model>, Build <build>'
    //  e.g.                  'PicoQuant, Sepia II, Build 0420';
    // or (newly) cTempStr := '<vendor>, <model>, Build <build>, <serial>'
    //  e.g.                  'PicoQuant, Sepia II, Build 0420, 1234567';
    //
    iRetVal := SEPIA2_USB_GetStrDescriptor (iDevIdx, cTempStr);
    if (iRetVal = SEPIA2_ERR_NO_ERROR)
    then begin
      case iDescrIdx of
        SEPIA2_USB_STRDSCR_IDX_VENDOR: begin
          // alles ab erstem Komma löschen:
          Delete (cTempStr, Pos(',', cTempStr), 999);
        end;
        SEPIA2_USB_STRDSCR_IDX_MODEL: begin
          // alles bis incl. erstem Komma löschen:
          Delete (cTempStr, 1, Pos(',', cTempStr));
          // alles ab erstem (i.e. zweitem) Komma löschen:
          Delete (cTempStr, Pos(',', cTempStr), 999);
        end;
        SEPIA2_USB_STRDSCR_IDX_BUILD: begin
          // alles bis bis 'Build' löschen:
          Delete (cTempStr, 1, Pos('Build', cTempStr) - 1);
          // alles ab erstem (i.e. drittem) Komma löschen:
          Delete (cTempStr, Pos(',', cTempStr), 999);
        end;
        SEPIA2_USB_STRDSCR_IDX_SERIAL: begin
          // alles bis bis 'Build' löschen:
          Delete (cTempStr, 1, Pos('Build', cTempStr) - 1);
          if Pos(',', cTempStr) = 0
          then begin
            // old USB descriptor style (i.e.: <serial> is missing)
            // but we could try to get it, anyway
            // (at least as long as the map was already fetched :-(  ):
            //
            // iRetVal := SEPIA2_COM_GetSerialNumber (iDevIdx, -1, true, cTempStr);
            // returns    cTempStr := '<serial>'
            //
            iRetVal := SEPIA2_COM_GetSerialNumber (iDevIdx, -1, true, cTempStr);
          end
          else begin
            // alles bis incl. erstem (i.e. drittem) Komma löschen:
            Delete (cTempStr, 1, Pos(',', cTempStr));
          end;
        end;
      else
        iRetVal  := SEPIA2_ERR_USB_INVALID_ARGUMENT;
        cTempStr := ' ';
      end;

    end;
    cTempStr  := trim (cTempStr);
    caTempStr := AnsiString(cTempStr);
    System.AnsiStrings.StrPCopy(pcDescriptor, caTempStr);
    SUBST_USB_GetStrDescrByIdx := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SUBST_USB_GetStrDescrByIdx


  function SEPIA2_USB_GetStrDescrByIdx (iDevIdx: integer; iDescrIdx: integer; var cDescriptor: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_USB_GetStrDescrByIdx';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_USB_GetStrDescrByIdx (iDevIdx, iDescrIdx, pcTmpVal1);
    cDescriptor := string(pcTmpVal1);
    SEPIA2_USB_GetStrDescrByIdx := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_USB_GetStrDescrByIdx


  function SEPIA2_USB_OpenGetSerNumAndClose (iDevIdx: integer; var cProductModel: string; var cSerialNumber: string) : integer;
  var
    iRetVal : integer;
    strPM   : AnsiString;
    strSN   : AnsiString;
  const
    strFkt  = 'SEPIA2_USB_OpenGetSerNumAndClose';
  begin
    DebugOut (1, strFkt);
    FillChar (pcTmpVal1^, TEMPVAR_LENGTH, #0);
    if (Length (cProductModel) > 0)
    then begin
      strPM := AnsiString (cProductModel);
      System.AnsiStrings.StrCopy (pcTmpVal1, PAnsiChar(strPM));
    end;
    FillChar(pcTmpVal2^, TEMPVAR_LENGTH, #0);
    if (Length (cSerialNumber) > 0)
    then begin
      strSN := AnsiString (cSerialNumber);
      System.AnsiStrings.StrCopy (pcTmpVal2, PAnsiChar(strSN));
    end;
    iRetVal := _SEPIA2_USB_OpenGetSerNumAndClose (iDevIdx, pcTmpVal1, pcTmpVal2);
    cProductModel := string(pcTmpVal1);
    cSerialNumber := string(pcTmpVal2);
    SEPIA2_USB_OpenGetSerNumAndClose := iRetVal;
    DebugOut (-1, strFkt + ' returns cProductModel = ', '"' + cProductModel + '"');
    DebugOut (-1, strFkt + ' returns cSerialNumber = ', '"' + cSerialNumber + '"');
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_USB_OpenGetSerNumAndClose


    function SUBST_USB_IsOpenDevice (iDevIdx: integer; var byteIsOpenDevice: byte) : integer; stdcall;
  var
    iRetVal : integer;
    cDescriptor : string;
  const
    strFkt  = 'SUBST_USB_IsOpenDevice';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_USB_GetStrDescriptor (iDevIdx, pcTmpVal1);
    cDescriptor := string(pcTmpVal1);
    byteIsOpenDevice := Byte(ifthen((iRetVal = SEPIA2_ERR_NO_ERROR) and not cDescriptor.IsEmpty, 1, 0));
    SUBST_USB_IsOpenDevice := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SUBST_USB_IsOpenDevice

  function SEPIA2_USB_IsOpenDevice (iDevIdx: integer; var bIsOpenDevice : boolean) : integer;
  var
    iRetVal : integer;
    byteIsOpenDevice : byte;
  const
    strFkt  = 'SEPIA2_USB_IsOpenDevice';
  begin
    DebugOut (1, strFkt);
    iRetVal        := _SEPIA2_USB_IsOpenDevice (iDevIdx, byteIsOpenDevice);
    bIsOpenDevice  := (byteIsOpenDevice <> 0);
    SEPIA2_USB_IsOpenDevice := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_USB_IsOpenDevice


  function SEPIA2_FWR_GetVersion (iDevIdx: integer; var cFWVersion: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_FWR_GetVersion';
  begin
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
  const
    strFkt  = 'SEPIA2_FWR_GetLastError';
  begin
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
  const
    strFkt  = 'SEPIA2_FWR_DecodeErrPhaseName';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_FWR_DecodeErrPhaseName (iErrPhase, pcTmpVal1);
    cErrorPhase := string(pcTmpVal1);
    SEPIA2_FWR_DecodeErrPhaseName := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_DecodeErrPhaseName


  function SEPIA2_FWR_GetWorkingMode (iDevIdx: integer; var fwmMode: T_SEPIA2_FWR_WORKINGMODE) : integer;
  var
    iRetVal : integer;
    iMode   : integer;
  const
    strFkt  = 'SEPIA2_FWR_GetWorkingMode';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_FWR_GetWorkingMode (iDevIdx, iMode);
    try
      fwmMode := T_SEPIA2_FWR_WORKINGMODE (iMode);
    except
      fwmMode := SEPIA2_FWR_WORKINGMODE_STAY_PERMANENT;
    end;
    SEPIA2_FWR_GetWorkingMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_GetWorkingMode


  function SEPIA2_FWR_SetWorkingMode (iDevIdx: integer; fwmMode: T_SEPIA2_FWR_WORKINGMODE) : integer;
  var
    iRetVal : integer;
    iMode   : integer;
  const
    strFkt  = 'SEPIA2_FWR_SetWorkingMode';
  begin
    DebugOut (1, strFkt);
    iMode   := ord (fwmMode);
    iRetVal := _SEPIA2_FWR_SetWorkingMode (iDevIdx, iMode);
    SEPIA2_FWR_SetWorkingMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_SetWorkingMode


  function SEPIA2_FWR_RollBackToPermanentValues (iDevIdx: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_FWR_RollBackToPermanentValues';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_FWR_RollBackToPermanentValues (iDevIdx);
    SEPIA2_FWR_RollBackToPermanentValues := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_RollBackToPermanentValues


  function SEPIA2_FWR_StoreAsPermanentValues (iDevIdx: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_FWR_StoreAsPermanentValues';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_FWR_StoreAsPermanentValues (iDevIdx);
    SEPIA2_FWR_StoreAsPermanentValues := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_StoreAsPermanentValues


  function SEPIA2_FWR_GetModuleMap (iDevIdx: integer; bPerformRestart: boolean; var iModuleCount: integer) : integer;
  var
    iRetVal         : integer;
    iPerformRestart : integer;
  const
    strFkt  = 'SEPIA2_FWR_GetModuleMap';
  begin
    DebugOut (1, strFkt);
    iPerformRestart := ifthen (bPerformRestart, 1, 0);
    iRetVal := _SEPIA2_FWR_GetModuleMap (iDevIdx, iPerformRestart, iModuleCount);
    SEPIA2_FWR_GetModuleMap := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_GetModuleMap


  function SEPIA2_FWR_GetModuleInfoByMapIdx (iDevIdx, iMapIdx: integer; var iSlotId: integer; var bIsPrimary, bIsBackPlane, bHasUptimeCounter: boolean) : integer;
  var
    iRetVal              : integer;
    byteIsPrimary        : byte;
    byteIsBackPlane      : byte;
    byteHasUptimeCounter : byte;
  const
    strFkt  = 'SEPIA2_FWR_GetModuleInfoByMapIdx';
  begin
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
  const
    strFkt  = 'SEPIA2_FWR_GetUptimeInfoByMapIdx';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_FWR_GetUptimeInfoByMapIdx (iDevIdx, iMapIdx, dwMainPowerUp, dwActivePowerUp, dwScaledPowerUp);
    SEPIA2_FWR_GetUptimeInfoByMapIdx := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_GetUptimeInfoByMapIdx


  function SEPIA2_FWR_CreateSupportRequestText (iDevIdx: integer; cPreamble, cCallingSW: string; iOptions: integer; var cBuffer: string) : integer;
  var
    iRetVal       : integer;
    strPreamble   : AnsiString;
    strCallingSW  : AnsiString;
  const
    strFkt  = 'SEPIA2_FWR_CreateSupportRequestText';
  begin
    DebugOut (1, strFkt);
    FillChar (pcTmpVal1^,     TEMPVAR_LENGTH, #0);
    FillChar (pcTmpVal2^,     TEMPVAR_LENGTH, #0);
    FillChar (pcTmpLongVal1^, TEMPLONGVAR_LENGTH, #0);
    FillChar (pcTmpLongVal2^, TEMPLONGVAR_LENGTH, #0);
    //
    if (Length (cPreamble) > 0)
    then begin
      strPreamble := AnsiString (cPreamble);
      System.AnsiStrings.StrCopy (pcTmpVal1, PAnsiChar(strPreamble));
    end;
    //
    if (Length (cCallingSW) > 0)
    then begin
      strCallingSW := AnsiString (cCallingSW);
      System.AnsiStrings.StrCopy (pcTmpVal2, PAnsiChar(strCallingSW));
    end;
    //
    iRetVal := _SEPIA2_FWR_CreateSupportRequestText (iDevIdx, pcTmpVal1, pcTmpVal2, iOptions, TEMPLONGVAR_LENGTH, pcTmpLongVal2);
    //
    cBuffer := string(pcTmpLongVal2);
    SEPIA2_FWR_CreateSupportRequestText := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_CreateSupportRequestText

  function SEPIA2_FWR_FreeModuleMap (iDevIdx: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_FWR_FreeModuleMap';
  begin
    DebugOut (1, strFkt);
    iRetVal :=  _SEPIA2_FWR_FreeModuleMap (iDevIdx);
    SEPIA2_FWR_FreeModuleMap := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_FWR_FreeModuleMap


  function SEPIA2_COM_DecodeModuleType (iModuleType: integer; var cModuleType: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_COM_DecodeModuleType';
  begin
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
  const
    strFkt  = 'SEPIA2_COM_DecodeModuleTypeAbbr';
  begin
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
    iHasSecondary : integer;
  const
    strFkt  = 'SEPIA2_COM_HasSecondaryModule';
  begin
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
    iGetPrimary : integer;
  const
    strFkt  = 'SEPIA2_COM_GetModuleType';
  begin
    DebugOut (1, strFkt);
    iGetPrimary := ifthen (bGetPrimary, 1, 0);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, iGetPrimary, iModuleType);
    SEPIA2_COM_GetModuleType := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_GetModuleType


  function SEPIA2_COM_GetSerialNumber (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var cSerialNumber: string) : integer;
  var
    iRetVal    : integer;
    iGetPrimary: integer;
  const
    strFkt  = 'SEPIA2_COM_GetSerialNumber';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iGetPrimary := ifthen (bGetPrimary, 1, 0);
    iRetVal := _SEPIA2_COM_GetSerialNumber (iDevIdx, iSlotId, iGetPrimary, pcTmpVal1);
    cSerialNumber := string(pcTmpVal1);
    SEPIA2_COM_GetSerialNumber := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_GetSerialNumber


  function SEPIA2_COM_GetSupplementaryInfos   (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var cLabel: string; var dtRelease: TDateTime; var cRevision: string; var cMemo : string) : integer;
  var
    iRetVal     : integer;
    strDate     : string;
    iGetPrimary : integer;
    p1          : pAnsiChar;
    p2          : pAnsiChar;
    p3          : pAnsiChar;
    p4          : pAnsiChar;
  const
    strFkt  = 'SEPIA2_COM_GetSupplementaryInfos';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iGetPrimary := ifthen (bGetPrimary, 1, 0);
    p1          := @pcTmpVal1[0];
    p2          := @pcTmpVal1[100];
    p3          := @pcTmpVal1[200];
    p4          := @pcTmpVal1[300];
    iRetVal     := _SEPIA2_COM_GetSupplementaryInfos (iDevIdx, iSlotId, iGetPrimary, p1, p2, p3, p4);
    cLabel      := string (p1);
    strDate     := string (p2);
    try
      dtRelease := StrToDate (strDate,    FormatSettings_enUS);
    except
      dtRelease := StrToDate ('69/12/31', FormatSettings_enUS);
    end;
    cRevision   := string (p3);
    cMemo       := string (p4);
    SEPIA2_COM_GetSupplementaryInfos := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_GetSupplementaryInfos


  function SEPIA2_COM_GetPresetInfo (iDevIdx, iSlotId: integer; bGetPrimary: boolean; iPresetNr: integer; var bPresetIsSet: boolean; var cPresetMemo: string) : integer;
  var
    iRetVal         : integer;
    iGetPrimary     : integer;
    bytePresetIsSet : byte;
  const
    strFkt  = 'SEPIA2_COM_GetPresetInfo';
  begin
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
    iGetPrimary : integer;
  const
    strFkt  = 'SEPIA2_COM_RecallPreset';
  begin
    DebugOut (1, strFkt);
    iGetPrimary := ifthen (bGetPrimary, 1, 0);
    iRetVal := _SEPIA2_COM_RecallPreset (iDevIdx, iSlotId, iGetPrimary, iPresetNr);
    SEPIA2_COM_RecallPreset := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_RecallPreset


  function SEPIA2_COM_SaveAsPreset (iDevIdx, iSlotId: integer; bSetPrimary: boolean; iPresetNr: integer; const cPresetMemo: string) : integer;
  var
    iRetVal         : integer;
    iSetPrimary     : integer;
  const
    strFkt  = 'SEPIA2_COM_SaveAsPreset';
  begin
    DebugOut (1, strFkt);
    iSetPrimary := ifthen (bSetPrimary, 1, 0);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    System.AnsiStrings.StrCopy (pcTmpVal1, PAnsiChar (@AnsiString(cPresetMemo + #0)[1]));
    iRetVal := _SEPIA2_COM_SaveAsPreset (iDevIdx, iSlotId, iSetPrimary, iPresetNr, pcTmpVal1);
    SEPIA2_COM_SaveAsPreset := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_COM_SaveAsPreset


  function SEPIA2_COM_IsWritableModule (iDevIdx, iSlotId: integer; bGetPrimary: boolean; var bIsWritable: boolean) : integer;
  var
    iRetVal        : integer;
    iGetPrimary    : integer;
    byteIsWritable : byte;
  const
    strFkt  = 'SEPIA2_COM_IsWritableModule';
  begin
    DebugOut (1, strFkt);
    iGetPrimary := ifthen (bGetPrimary, 1, 0);
    iRetVal := _SEPIA2_COM_IsWritableModule (iDevIdx, iSlotId, iGetPrimary, byteIsWritable);
    bIsWritable := (byteIsWritable <> 0);
    SEPIA2_COM_IsWritableModule := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_COM_IsWritableModule


  function SEPIA2_COM_UpdateModuleData (iDevIdx, iSlotId: integer; bSetPrimary: boolean; cFileName: string) : integer;
  var
    iRetVal     : integer;
    strTemp     : AnsiString;
    iSetPrimary : integer;
  const
    strFkt  = 'SEPIA2_COM_UpdateModuleData';
  begin
    DebugOut (1, strFkt);
    iSetPrimary := ifthen (bSetPrimary, 1, 0);
    strTemp := AnsiString (cFileName);
    iRetVal := _SEPIA2_COM_UpdateModuleData (iDevIdx, iSlotId, iSetPrimary, PAnsiChar (strTemp));
    SEPIA2_COM_UpdateModuleData := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_COM_UpdateModuleData


  function SEPIA2_SCM_GetPowerAndLaserLEDS (iDevIdx, iSlotId: integer; var bPowerLED, bLaserActiveLED: boolean) : integer;
  var
    iRetVal            : integer;
    bytePowerLED       : byte;
    byteLaserActiveLED : byte;
  const
    strFkt  = 'SEPIA2_SCM_GetPowerAndLaserLEDS';
  begin
  {$ifndef __POLLING_AWARE_AVOIDING_DEBUGOUT__}
    DebugOut (1, strFkt);
  {$endif}
    iRetVal := _SEPIA2_SCM_GetPowerAndLaserLEDS (iDevIdx, iSlotId, bytePowerLED, byteLaserActiveLED);
    bPowerLED       := (bytePowerLED <> 0);
    bLaserActiveLED := (byteLaserActiveLED <> 0);
    SEPIA2_SCM_GetPowerAndLaserLEDS := iRetVal;
  {$ifndef __POLLING_AWARE_AVOIDING_DEBUGOUT__}
    DebugOut (0, strFkt, iRetVal);
  {$endif}
  end;  // _SEPIA2_SCM_GetPowerAndLaserLEDS


  function SEPIA2_SCM_GetLaserLocked (iDevIdx, iSlotId: integer; var bLocked: boolean) : integer;
  var
    iRetVal    : integer;
    byteLocked : byte;
  const
    strFkt  = 'SEPIA2_SCM_GetLaserLocked';
  begin
  {$ifndef __POLLING_AWARE_AVOIDING_DEBUGOUT__}
    DebugOut (1, strFkt);
  {$endif}
    iRetVal := _SEPIA2_SCM_GetLaserLocked (iDevIdx, iSlotId, byteLocked);
    bLocked := (byteLocked <> 0);
    SEPIA2_SCM_GetLaserLocked := iRetVal;
  {$ifndef __POLLING_AWARE_AVOIDING_DEBUGOUT__}
    DebugOut (0, strFkt, iRetVal);
  {$endif}
  end;  // SEPIA2_SCM_GetLaserLocked


  function SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId: integer; var bSoftLocked: boolean) : integer;
  var
    iRetVal        : integer;
    byteSoftLocked : byte;
  const
    strFkt  = 'SEPIA2_SCM_GetLaserSoftLock';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId, byteSoftLocked);
    bSoftLocked := (byteSoftLocked <> 0);
    SEPIA2_SCM_GetLaserSoftLock := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SCM_GetLaserSoftLock


  function SEPIA2_SCM_SetLaserSoftLock (iDevIdx, iSlotId: integer; bSoftLocked: boolean) : integer;
  var
    iRetVal        : integer;
    byteSoftLocked : byte;
  const
    strFkt  = 'SEPIA2_SCM_SetLaserSoftLock';
  begin
    DebugOut (1, strFkt);
    byteSoftLocked := ifthen (bSoftLocked, 1, 0);
    iRetVal := _SEPIA2_SCM_SetLaserSoftLock (iDevIdx, iSlotId, byteSoftLocked);
    SEPIA2_SCM_SetLaserSoftLock := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SCM_SetLaserSoftLock


  function SEPIA2_SLM_DecodeFreqTrigMode (iFreq: integer; var cFreqTrigMode: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SLM_DecodeFreqTrigMode';
  begin
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
  const
    strFkt  = 'SEPIA2_SLM_DecodeHeadType';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_SLM_DecodeHeadType (iHeadType, pcTmpVal1);
    cHeadType := string(pcTmpVal1);
    SEPIA2_SLM_DecodeHeadType := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_DecodeHeadType

{$ifdef __INCLUDE_DEPRECATED_SLM_FUNCTIONS__}
  function SEPIA2_SLM_GetParameters (iDevIdx, iSlotId: integer; var iFreq: integer; var bPulseMode: boolean; var iHead: integer; var byteIntensity: byte) : integer;
  // deprecated  : SEPIA2_SLM_GetParameters;
  // use instead : SEPIA2_SLM_GetIntensityFineStep, SEPIA2_SLM_GetPulseParameters
  var
    iRetVal       : integer;
    bytePulseMode : byte;
  const
    strFkt  = 'SEPIA2_SLM_GetParameters';
  begin
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
    bytePulseMode : byte;
  const
    strFkt  = 'SEPIA2_SLM_SetParameters';
  begin
    DebugOut (1, strFkt);
    bytePulseMode := ifthen (bPulseMode, 1, 0);
    iRetVal := _SEPIA2_SLM_SetParameters (iDevIdx, iSlotId, iFreq, bytePulseMode, byteIntensity);
    SEPIA2_SLM_SetParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_SetParameters
{$endif}

  function SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSlotId: integer; var wIntensity: word) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SLM_GetIntensityFineStep';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSlotId, wIntensity);
    SEPIA2_SLM_GetIntensityFineStep := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_GetIntensityFineStep


  function SEPIA2_SLM_SetIntensityFineStep (iDevIdx, iSlotId: integer; wIntensity: word) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SLM_SetIntensityFineStep';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SLM_SetIntensityFineStep (iDevIdx, iSlotId, wIntensity);
    SEPIA2_SLM_SetIntensityFineStep := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_SetIntensityFineStep


  function SEPIA2_SLM_GetPulseParameters (iDevIdx, iSlotId: integer; var iFreq: integer; var bPulseMode: boolean; var iHeadType: integer) : integer;
  var
    iRetVal       : integer;
    bytePulseMode : byte;
  const
    strFkt  = 'SEPIA2_SLM_GetPulseParameters';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SLM_GetPulseParameters (iDevIdx, iSlotId, iFreq, bytePulseMode, iHeadType);
    bPulseMode := (bytePulseMode <> 0);
    SEPIA2_SLM_GetPulseParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SLM_GetPulseParameters


  function SEPIA2_SLM_SetPulseParameters (iDevIdx, iSlotId: integer; iFreq: integer; bPulseMode: boolean) : integer;
  var
    iRetVal       : integer;
    bytePulseMode : byte;
  const
    strFkt  = 'SEPIA2_SLM_SetPulseParameters';
  begin
    DebugOut (1, strFkt);
    bytePulseMode := ifthen (bPulseMode, 1, 0);
    iRetVal := _SEPIA2_SLM_SetPulseParameters (iDevIdx, iSlotId, iFreq, bytePulseMode);
    SEPIA2_SLM_SetPulseParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SLM_SetPulseParameters


  function SEPIA2_SML_DecodeHeadType (iHeadType: integer; var cHeadType: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SML_DecodeHeadType';
  begin
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
    bytePulseMode : byte;
  const
    strFkt  = 'SEPIA2_SML_GetParameters';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SML_GetParameters (iDevIdx, iSlotId, bytePulseMode, iHead, byteIntensity);
    bPulseMode := (bytePulseMode <> 0);
    SEPIA2_SML_GetParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SML_GetParameters


  function SEPIA2_SML_SetParameters (iDevIdx, iSlotId: integer; bPulseMode: boolean; byteIntensity: byte) : integer;
  var
    iRetVal       : integer;
    bytePulseMode : byte;
  const
    strFkt  = 'SEPIA2_SML_SetParameters';
  begin
    DebugOut (1, strFkt);
    bytePulseMode := ifthen (bPulseMode, 1, 0);
    iRetVal := _SEPIA2_SML_SetParameters (iDevIdx, iSlotId, bytePulseMode, byteIntensity);
    SEPIA2_SML_SetParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SML_SetParameters


  function SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx: integer; var cFreqTrigMode: string) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
  const
    strFkt  = 'SEPIA2_SOM_DecodeFreqTrigMode';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal := _SEPIA2_SOMD_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, pcTmpVal1);
        else
          iRetVal := _SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, pcTmpVal1);
      end;
      cFreqTrigMode := string(pcTmpVal1);
    end;
    SEPIA2_SOM_DecodeFreqTrigMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_DecodeFreqTrigMode


  function SEPIA2_SOM_GetFreqTrigMode (iDevIdx, iSlotId: integer; var iFreqTrigIdx: integer) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
  const
    strFkt  = 'SEPIA2_SOM_GetFreqTrigMode';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD: begin
          OutputDebugString (PChar ('Error: --- SOM function "' + strFkt + '" called for SOMD module!'));
          iRetVal := SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_MODULE;
        end;
        else
          iRetVal := _SEPIA2_SOM_GetFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx);
      end;
    end;
    SEPIA2_SOM_GetFreqTrigMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetFreqTrigMode


  function SEPIA2_SOM_SetFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx: integer) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
  const
    strFkt  = 'SEPIA2_SOM_SetFreqTrigMode';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD: begin
          OutputDebugString (PChar ('Error: --- SOM function "' + strFkt + '" called for SOMD module!'));
          iRetVal := SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_MODULE;
        end;
        else
          iRetVal := _SEPIA2_SOM_SetFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx);
      end;
    end;
    SEPIA2_SOM_SetFreqTrigMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_SetFreqTrigMode


  function SEPIA2_SOM_GetTriggerRange (iDevIdx, iSlotId: integer; var iMilliVoltLow, iMilliVoltHigh: integer) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
  const
    strFkt  = 'SEPIA2_SOM_GetTriggerRange';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal := _SEPIA2_SOMD_GetTriggerRange (iDevIdx, iSlotId, iMilliVoltLow, iMilliVoltHigh);
        else
          iRetVal := _SEPIA2_SOM_GetTriggerRange (iDevIdx, iSlotId, iMilliVoltLow, iMilliVoltHigh);
      end;
    end;
    SEPIA2_SOM_GetTriggerRange := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetTriggerRange


  function SEPIA2_SOM_GetTriggerLevel (iDevIdx, iSlotId: integer; var iMilliVolt: integer) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
  const
    strFkt  = 'SEPIA2_SOM_GetTriggerLevel';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal := _SEPIA2_SOMD_GetTriggerLevel (iDevIdx, iSlotId, iMilliVolt);
        else
          iRetVal := _SEPIA2_SOM_GetTriggerLevel (iDevIdx, iSlotId, iMilliVolt);
      end;
    end;
    SEPIA2_SOM_GetTriggerLevel := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetTriggerLevel


  function SEPIA2_SOM_SetTriggerLevel (iDevIdx, iSlotId, iMilliVolt: integer) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
  const
    strFkt  = 'SEPIA2_SOM_SetTriggerLevel';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal := _SEPIA2_SOMD_SetTriggerLevel (iDevIdx, iSlotId, iMilliVolt);
        else
          iRetVal := _SEPIA2_SOM_SetTriggerLevel (iDevIdx, iSlotId, iMilliVolt);
      end;
    end;
    SEPIA2_SOM_SetTriggerLevel := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_SetTriggerLevel


  function SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSlotId: integer; var lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8: longint) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
  const
    strFkt  = 'SEPIA2_SOM_GetBurstLengthArray';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal := _SEPIA2_SOMD_GetBurstLengthArray (iDevIdx, iSlotId, lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8);
        else
          iRetVal := _SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSlotId, lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8);
      end;
    end;
    SEPIA2_SOM_GetBurstLengthArray := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetBurstLengthArray


  function SEPIA2_SOM_SetBurstLengthArray (iDevIdx, iSlotId: integer; lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8: longint) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
  const
    strFkt  = 'SEPIA2_SOM_SetBurstLengthArray';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal := _SEPIA2_SOMD_SetBurstLengthArray (iDevIdx, iSlotId, lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8);
        else
          iRetVal := _SEPIA2_SOM_SetBurstLengthArray (iDevIdx, iSlotId, lBurstLen1, lBurstLen2, lBurstLen3, lBurstLen4, lBurstLen5, lBurstLen6, lBurstLen7, lBurstLen8);
      end;
    end;
    SEPIA2_SOM_SetBurstLengthArray := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_SetBurstLengthArray


  function SEPIA2_SOM_GetOutNSyncEnable (iDevIdx, iSlotId: integer; var byteOutEnable, byteSyncEnable: byte; var bSyncInverse: boolean) : integer;
  var
    iRetVal         : integer;
    iMType          : integer;
    byteSyncInverse : byte;
  const
    strFkt  = 'SEPIA2_SOM_GetOutNSyncEnable';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal := _SEPIA2_SOMD_GetOutNSyncEnable (iDevIdx, iSlotId, byteOutEnable, byteSyncEnable, byteSyncInverse);
        else
          iRetVal := _SEPIA2_SOM_GetOutNSyncEnable (iDevIdx, iSlotId, byteOutEnable, byteSyncEnable, byteSyncInverse);
      end;
      bSyncInverse := (byteSyncInverse <> 0);
    end;
    SEPIA2_SOM_GetOutNSyncEnable := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetOutNSyncEnable


  function SEPIA2_SOM_SetOutNSyncEnable (iDevIdx, iSlotId: integer; byteOutEnable, byteSyncEnable: byte; bSyncInverse: boolean) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
    byteSyncInverse : byte;
  const
    strFkt  = 'SEPIA2_SOM_SetOutNSyncEnable';
  begin
    DebugOut (1, strFkt);
    byteSyncInverse := ifthen (bSyncInverse, 1, 0);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal := _SEPIA2_SOMD_SetOutNSyncEnable (iDevIdx, iSlotId, byteOutEnable, byteSyncEnable, byteSyncInverse);
        else
          iRetVal := _SEPIA2_SOM_SetOutNSyncEnable (iDevIdx, iSlotId, byteOutEnable, byteSyncEnable, byteSyncInverse);
      end;
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
  const
    strFkt  = 'SEPIA2_SOM_GetBurstValues';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal  := _SEPIA2_SOMD_GetBurstValues (iDevIdx, iSlotId, wDivider, bytePreSync, byteSyncMask);
        else  begin
          iRetVal  := _SEPIA2_SOM_GetBurstValues (iDevIdx, iSlotId, byteDivider, bytePreSync, byteSyncMask);
          wDivider := $0000 or byteDivider;
        end;
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
  const
    strFkt  = 'SEPIA2_SOM_SetBurstValues';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal := _SEPIA2_SOMD_SetBurstValues (iDevIdx, iSlotId, wDivider, bytePreSync, byteSyncMask);
        else  begin
          byteDivider := EnsureRange (wDivider, 1, 255);
          if (($0000 or byteDivider) <> wDivider) then
          begin
            iRetVal := SEPIA2_ERR_SOM_ILLEGAL_FREQUENCY_DIVIDER;
          end
          else begin
            iRetVal := _SEPIA2_SOM_SetBurstValues (iDevIdx, iSlotId, byteDivider, bytePreSync, byteSyncMask);
          end;
        end;
      end;
    end;
    SEPIA2_SOM_SetBurstValues := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_SetBurstValues


  function SEPIA2_SOM_DecodeAUXINSequencerCtrl (iDevIdx, iSlotId: integer; iAuxInCtrl: integer; var cSequencerCtrl: string) : integer;
  var
    iRetVal          : integer;
    iMType           : integer;
    iAuxInCtrl_      : integer;
  const
    strFkt  = 'SEPIA2_SOM_DecodeAUXINSequencerCtrl';
  begin
    DebugOut (1, strFkt);
    iAuxInCtrl_      := EnsureRange (iAuxInCtrl, 0, 255);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal := _SEPIA2_SOMD_DecodeAUXINSequencerCtrl (iAuxInCtrl_, pcTmpVal1);
        else
          iRetVal := _SEPIA2_SOM_DecodeAUXINSequencerCtrl (iAuxInCtrl_, pcTmpVal1);
      end;
      cSequencerCtrl := string (pcTmpVal1);
    end;
    SEPIA2_SOM_DecodeAUXINSequencerCtrl := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_DecodeAUXINSequencerCtrl


  function SEPIA2_SOM_GetAUXIOSequencerCtrl (iDevIdx, iSlotId: integer; var bAUXOutEnable: boolean; var byteAUXInSequencerCtrl: byte) : integer;
  var
    iRetVal          : integer;
    iMType           : integer;
    byteAUXOutEnable : byte;
  const
    strFkt  = 'SEPIA2_SOM_GetAUXIOSequencerCtrl';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal := _SEPIA2_SOMD_GetAUXIOSequencerCtrl (iDevIdx, iSlotId, byteAUXOutEnable, byteAUXInSequencerCtrl);
        else
          iRetVal := _SEPIA2_SOM_GetAUXIOSequencerCtrl (iDevIdx, iSlotId, byteAUXOutEnable, byteAUXInSequencerCtrl);
      end;
      bAUXOutEnable := (byteAUXOutEnable <> 0);
    end;
    SEPIA2_SOM_GetAUXIOSequencerCtrl := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_GetAUXIOSequencerCtrl


  function SEPIA2_SOM_SetAUXIOSequencerCtrl (iDevIdx, iSlotId: integer; bAUXOutEnable: boolean; byteAUXInSequencerCtrl: byte) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
    byteAUXOutEnable : byte;
  const
    strFkt  = 'SEPIA2_SOM_SetAUXIOSequencerCtrl';
  begin
    DebugOut (1, strFkt);
    byteAUXOutEnable := ifthen (bAUXOutEnable, 1, 0);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOMD:
          iRetVal := _SEPIA2_SOMD_SetAUXIOSequencerCtrl (iDevIdx, iSlotId, byteAUXOutEnable, byteAUXInSequencerCtrl);
        else
          iRetVal := _SEPIA2_SOM_SetAUXIOSequencerCtrl (iDevIdx, iSlotId, byteAUXOutEnable, byteAUXInSequencerCtrl);
      end;
    end;
    SEPIA2_SOM_SetAUXIOSequencerCtrl := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOM_SetAUXIOSequencerCtrl


  function SEPIA2_SOMD_GetFreqTrigMode (iDevIdx, iSlotId: integer; var iFreqTrigIdx: integer; var bSynchronize: boolean) : integer;
  var
    iRetVal         : integer;
    iMType          : integer;
    byteSynchronize : byte;
  const
    strFkt  = 'SEPIA2_SOMD_GetFreqTrigMode';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOM: begin
          OutputDebugString (PChar ('Error: --- SOMD function "' + strFkt + '" called for SOM module!'));
          iRetVal := SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_D_MODULE;
        end;
        else
          iRetVal := _SEPIA2_SOMD_GetFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, byteSynchronize);
      end;
      bSynchronize := (byteSynchronize <> 0);
    end;
    SEPIA2_SOMD_GetFreqTrigMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOMD_GetFreqTrigMode


  function SEPIA2_SOMD_SetFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx: integer; bSynchronize: boolean) : integer;
  var
    iRetVal         : integer;
    iMType          : integer;
    byteSynchronize : byte;
  const
    strFkt  = 'SEPIA2_SOMD_SetFreqTrigMode';
  begin
    DebugOut (1, strFkt);
    byteSynchronize := ifthen (bSynchronize, 1, 0);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOM: begin
          OutputDebugString (PChar ('Error: --- SOMD function "' + strFkt + '" called for SOM module!'));
          iRetVal := SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_D_MODULE;
        end;
        else
          iRetVal := _SEPIA2_SOMD_SetFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, byteSynchronize);
      end;
    end;
    SEPIA2_SOMD_SetFreqTrigMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOMD_SetFreqTrigMode


  function SEPIA2_SOMD_GetSeqOutputInfos (iDevIdx, iSlotId: integer; byteSeqOutputIdx: byte; var bDelayed: boolean; var bForcedUndelayed: boolean; var byteOutCombi: byte; var bMaskedCombi: boolean; var f64CoarseDly: double; var iFineDly: integer) : integer;
  var
    iRetVal             : integer;
    iMType              : integer;
    bbyteSeqOutputIdx   : byte;
    byteDelayed         : byte;
    byteForcedUndelayed : byte;
    bbyteOutCombi       : byte;
    byteMaskedCombi     : byte;
    dblCoarseDly        : double;
    bFineDly            : byte;
  const
    strFkt  = 'SEPIA2_SOMD_GetSeqOutputInfos';
  begin
    DebugOut (1, strFkt);
    bbyteSeqOutputIdx  := EnsureRange (byteSeqOutputIdx, 1, SEPIA2_SOM_BURSTCHANNEL_COUNT);
    if (bbyteSeqOutputIdx <> byteSeqOutputIdx)
    then begin
      iRetVal := SEPIA2_ERR_LIB_ILLEGAL_PARAMETER_ON_FUNCTION_CALL;
    end
    else begin
      iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
      if iRetVal = SEPIA2_ERR_NO_ERROR
      then begin
        case iMType of
          SEPIA2OBJECT_SOM: begin
            OutputDebugString (PChar ('Error: --- SOMD function "' + strFkt + '" called for SOM module!'));
            iRetVal := SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_D_MODULE;
          end;
          else
            iRetVal := _SEPIA2_SOMD_GetSeqOutputInfos (iDevIdx, iSlotId, bbyteSeqOutputIdx-1, byteDelayed, byteForcedUndelayed, bbyteOutCombi, byteMaskedCombi, dblCoarseDly, bFineDly);
        end;
        f64CoarseDly := dblCoarseDly;
        bDelayed := (byteDelayed <> 0);
        bForcedUndelayed := (byteForcedUndelayed <> 0);
        byteOutCombi := bbyteOutCombi;
        bMaskedCombi := (byteMaskedCombi <> 0);
        iFineDly := bFineDly;
      end;
    end;
    SEPIA2_SOMD_GetSeqOutputInfos := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SOMD_GetSeqOutputInfos


  function SEPIA2_SOMD_SetSeqOutputInfos (iDevIdx, iSlotId: integer; byteSeqOutputIdx: byte; bDelayed: boolean; byteOutCombi: byte; bMaskedCombi: boolean; f64CoarseDly: double; iFineDly: integer) : integer;
  var
    iRetVal           : integer;
    iMType            : integer;
    bbyteSeqOutputIdx : byte;
    byteDelayed       : byte;
    byteMaskedCombi   : byte;
    byteFineDly       : byte;
  const
    strFkt  = 'SEPIA2_SOMD_SetSeqOutputInfos';
  begin
    DebugOut (1, strFkt);
    byteDelayed       := ifthen (bDelayed, 1, 0);
    byteMaskedCombi   := ifthen (bMaskedCombi, 1, 0);
    byteFineDly       := EnsureRange (iFineDly, 0, High (byte));
    bbyteSeqOutputIdx := EnsureRange (byteSeqOutputIdx, 1, SEPIA2_SOM_BURSTCHANNEL_COUNT);
    if (bbyteSeqOutputIdx <> byteSeqOutputIdx)
    then begin
      iRetVal := SEPIA2_ERR_LIB_ILLEGAL_PARAMETER_ON_FUNCTION_CALL;
    end
    else begin
      iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
      if iRetVal = SEPIA2_ERR_NO_ERROR
      then begin
        case iMType of
          SEPIA2OBJECT_SOM: begin
            OutputDebugString (PChar ('Error: --- SOMD function "' + strFkt + '" called for SOM module!'));
            iRetVal := SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_D_MODULE;
          end;
          else
            iRetVal := _SEPIA2_SOMD_SetSeqOutputInfos (iDevIdx, iSlotId, byteSeqOutputIdx-1, byteDelayed, byteOutCombi, byteMaskedCombi, f64CoarseDly, byteFineDly);
        end;
      end;
    end;
    SEPIA2_SOMD_SetSeqOutputInfos := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SOMD_SetSeqOutputInfos


  function SEPIA2_SOMD_SynchronizeNow (iDevIdx, iSlotId: integer) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
  const
    strFkt  = 'SEPIA2_SOMD_SynchronizeNow';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOM: begin
          OutputDebugString (PChar ('Error: --- SOMD function "' + strFkt + '" called for SOM module!'));
          iRetVal := SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_D_MODULE;
        end;
        else
          iRetVal := _SEPIA2_SOMD_SynchronizeNow (iDevIdx, iSlotId);
      end;
    end;
    SEPIA2_SOMD_SynchronizeNow := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOMD_SynchronizeNow


  function SEPIA2_SOMD_DecodeModuleState (wModuleState: Word; var cModuleState: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SOMD_DecodeModuleState';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_SOMD_DecodeModuleState (wModuleState, pcTmpVal1);
    cModuleState := string(pcTmpVal1);
    SEPIA2_SOMD_DecodeModuleState := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOMD_DecodeModuleState


  function SEPIA2_SOMD_GetStatusError (iDevIdx, iSlotId: integer; var wModuleState: word; var iErrorCode: integer) : integer;
  var
    iRetVal     : integer;
    iMType      : integer;
    siErrorCode : SmallInt;
  const
    strFkt  = 'SEPIA2_SOMD_GetStatusError';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOM: begin
          OutputDebugString (PChar ('Error: --- SOMD function "' + strFkt + '" called for SOM module!'));
          iRetVal := SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_D_MODULE;
        end;
        else
          iRetVal := _SEPIA2_SOMD_GetStatusError (iDevIdx, iSlotId, wModuleState, siErrorCode);
      end;
    end;
    iErrorCode := siErrorCode;
    SEPIA2_SOMD_GetStatusError := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOMD_GetStatusError


  function SEPIA2_SOMD_GetTrigSyncFreq (iDevIdx, iSlotId: integer; var bSyncStable: boolean; var iTrigSyncFreq: integer) : integer;
  var
    iRetVal        : integer;
    iMType         : integer;
    byteSyncStable : byte;
  const
    strFkt  = 'SEPIA2_SOMD_GetTrigSyncFreq';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOM: begin
          OutputDebugString (PChar ('Error: --- SOMD function "' + strFkt + '" called for SOM module!'));
          iRetVal := SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_D_MODULE;
        end;
        else
          iRetVal := _SEPIA2_SOMD_GetTrigSyncFreq (iDevIdx, iSlotId, byteSyncStable, iTrigSyncFreq);
      end;
    end;
    bSyncStable := (byteSyncStable <> 0);
    SEPIA2_SOMD_GetTrigSyncFreq := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOMD_GetTrigSyncFreq


  function SEPIA2_SOMD_GetDelayUnits (iDevIdx, iSlotId: integer; var fCoarseDlyStep: double; var byteFineDlyStepCount: byte) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
  const
    strFkt  = 'SEPIA2_SOMD_GetDelayUnits';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOM: begin
          OutputDebugString (PChar ('Error: --- SOMD function "' + strFkt + '" called for SOM module!'));
          iRetVal := SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_D_MODULE;
        end;
        else
          iRetVal := _SEPIA2_SOMD_GetDelayUnits (iDevIdx, iSlotId, fCoarseDlyStep, byteFineDlyStepCount);
      end;
    end;
    SEPIA2_SOMD_GetDelayUnits := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SOMD_GetDelayUnits


  function SEPIA2_SOMD_GetFWVersion (iDevIdx, iSlotId: integer; var FWVersion: T_SepiaModules_FWVersion) : integer;
  var
    iRetVal : integer;
    iMType  : integer;
  const
    strFkt  = 'SEPIA2_SOMD_GetFWVersion';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, 1, iMType);
    if iRetVal = SEPIA2_ERR_NO_ERROR
    then begin
      case iMType of
        SEPIA2OBJECT_SOM: begin
          OutputDebugString (PChar ('Error: --- SOMD function "' + strFkt + '" called for SOM module!'));
          iRetVal := SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_D_MODULE;
        end;
        else
          iRetVal := _SEPIA2_SOMD_GetFWVersion (iDevIdx, iSlotId, FWVersion.ulVersion);
      end;
    end;
    SEPIA2_SOMD_GetFWVersion := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SOMD_GetFWVersion


  function SEPIA2_SOMD_FWReadPage (iDevIdx, iSlotId: integer; wPageIdx: word; var FWPage: T_SOMD_FW_PAGE) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SOMD_FWReadPage';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SOMD_FWReadPage (iDevIdx, iSlotId, wPageIdx, FWPage);
    SEPIA2_SOMD_FWReadPage := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SOMD_FWReadPage


  function SEPIA2_SOMD_FWWritePage (iDevIdx, iSlotId: integer; wPageIdx: word; const FWPage: T_SOMD_FW_PAGE) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SOMD_FWWritePage';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SOMD_FWWritePage (iDevIdx, iSlotId, wPageIdx, FWPage);
    SEPIA2_SOMD_FWWritePage := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SOMD_FWWritePage


  function SEPIA2_SOMD_GetHWParams (iDevIdx, iSlotId: integer; var wHWParamTemp1, wHWParamTemp2, wHWParamTemp3, wHWParamVolt1, wHWParamVolt2, wHWParamVolt3, wHWParamVolt4, wHWParamAUX : word) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SOMD_GetHWParams';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SOMD_GetHWParams (iDevIdx, iSlotId, wHWParamTemp1, wHWParamTemp2, wHWParamTemp3, wHWParamVolt1, wHWParamVolt2, wHWParamVolt3, wHWParamVolt4, wHWParamAUX);
    SEPIA2_SOMD_GetHWParams := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SOMD_GetHWParams


  function SEPIA2_SWM_DecodeRangeIdx (iDevIdx, iSlotId: integer; iRangeIdx: integer; var iUpperLimit: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWM_DecodeRangeIdx';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWM_DecodeRangeIdx (iDevIdx, iSlotId, iRangeIdx, iUpperLimit);
    SEPIA2_SWM_DecodeRangeIdx := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWM_DecodeRangeIdx


  function SEPIA2_SWM_GetUIConstants (iDevIdx, iSlotId: integer; var byteTBIdxCount: byte; var wMaxAmplitude, wMaxSlewRate, wExpRampEffect, wMinUserValue, wMaxUserValue, wUserResolution: word) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWM_GetUIConstants';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWM_GetUIConstants (iDevIdx, iSlotId, byteTBIdxCount, wMaxAmplitude, wMaxSlewRate, wExpRampEffect, wMinUserValue, wMaxUserValue, wUserResolution);
    SEPIA2_SWM_GetUIConstants := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWM_GetUIConstants


  function SEPIA2_SWM_GetCurveParams (iDevIdx, iSlotId: integer; iCurveIdx: integer; var byteTBIdx: byte; var wPAPml, wRRPml, wPSPml, wRSPml, wWSPml: word) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWM_GetCurveParams';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWM_GetCurveParams (iDevIdx, iSlotId, iCurveIdx, byteTBIdx, wPAPml, wRRPml, wPSPml, wRSPml, wWSPml);
    SEPIA2_SWM_GetCurveParams := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWM_GetCurveParams


  function SEPIA2_SWM_SetCurveParams (iDevIdx, iSlotId: integer; iCurveIdx: integer; byteTBIdx: byte; wPAPml, wRRPml, wPSPml, wRSPml, wWSPml: word) : integer;
  var
    iRetVal : integer;

  const
    strFkt  = 'SEPIA2_SWM_SetCurveParams';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWM_SetCurveParams (iDevIdx, iSlotId, iCurveIdx, byteTBIdx, wPAPml, wRRPml, wPSPml, wRSPml, wWSPml);
    SEPIA2_SWM_SetCurveParams := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWM_SetCurveParams


  function SEPIA2_SWM_GetExtAtten (iDevIdx, iSlotId: integer; var fExtAtt: Single) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWM_GetExtAtten';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWM_GetExtAtten (iDevIdx, iSlotId, fExtAtt);
    SEPIA2_SWM_GetExtAtten := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWM_GetExtAtten


  function SEPIA2_SWM_SetExtAtten (iDevIdx, iSlotId: integer; fExtAtt: Single) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWM_SetExtAtten';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWM_SetExtAtten (iDevIdx, iSlotId, fExtAtt);
    SEPIA2_SWM_SetExtAtten := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWM_SetExtAtten



  function SEPIA2_VCL_GetUIConstants (iDevIdx, iSlotId: integer; var iMinUserValueTmp, iMaxUserValueTmp, iUserResolutionTmp : integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_VCL_GetUIConstants';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_VCL_GetUIConstants (iDevIdx, iSlotId, iMinUserValueTmp, iMaxUserValueTmp, iUserResolutionTmp);
    SEPIA2_VCL_GetUIConstants := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VCL_GetUIConstants


  function SEPIA2_VCL_GetTemperature (iDevIdx, iSlotId: integer; var iTemperature : integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_VCL_GetTemperature';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_VCL_GetTemperature (iDevIdx, iSlotId, iTemperature);
    SEPIA2_VCL_GetTemperature := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VCL_GetTemperature


  function SEPIA2_VCL_SetTemperature (iDevIdx, iSlotId: integer; iTemperature : integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_VCL_SetTemperature';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_VCL_SetTemperature (iDevIdx, iSlotId, iTemperature);
    SEPIA2_VCL_SetTemperature := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VCL_SetTemperature


  function SEPIA2_VCL_GetBiasVoltage (iDevIdx, iSlotId: integer; var iBiasVoltage : integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_VCL_GetBiasVoltage';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_VCL_GetBiasVoltage (iDevIdx, iSlotId, iBiasVoltage);
    SEPIA2_VCL_GetBiasVoltage := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VCL_GetBiasVoltage


  function SEPIA2_SPM_GetDeviceDescription (iDevIdx, iSlotId: integer; var cDeviceDescription: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SPM_GetDeviceDescription';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_SPM_GetDeviceDescription (iDevIdx, iSlotId, pcTmpVal1);
    cDeviceDescription := string(pcTmpVal1);
    SEPIA2_SPM_GetDeviceDescription := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SPM_GetDeviceDescription


  function SEPIA2_SPM_GetFWVersion (iDevIdx, iSlotId: integer; var FWVersion: T_SepiaModules_FWVersion) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SPM_GetFWVersion';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetFWVersion (iDevIdx, iSlotId, FWVersion.ulVersion);
    SEPIA2_SPM_GetFWVersion := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SPM_GetFWVersion


  function SEPIA2_SPM_DecodeModuleState (wModuleState: Word; var cModuleState: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SPM_DecodeModuleState';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_SPM_DecodeModuleState (wModuleState, pcTmpVal1);
    cModuleState := string(pcTmpVal1);
    SEPIA2_SPM_DecodeModuleState := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_DecodeModuleState


  function SEPIA2_SPM_GetSensorData (iDevIdx, iSlotId: integer; var SensorData: T_SPM_SensorData) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SPM_GetSensorData';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetSensorData (iDevIdx, iSlotId, SensorData);
    SEPIA2_SPM_GetSensorData := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SPM_GetSensorData


  function SEPIA2_SPM_GetTemperatureAdjust (iDevIdx, iSlotId: integer; var Temperatures: T_SPM_Temperatures) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SPM_GetTemperatureAdjust';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetTemperatureAdjust (iDevIdx, iSlotId, Temperatures);
    SEPIA2_SPM_GetTemperatureAdjust := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SPM_GetTemperatureAdjust


  function SEPIA2_SPM_GetStatusError (iDevIdx, iSlotId: integer; var wModuleState: word; var iErrorCode: SmallInt) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SPM_GetStatusError';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetStatusError (iDevIdx, iSlotId, wModuleState, iErrorCode);
    SEPIA2_SPM_GetStatusError := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetStatusError


  function SEPIA2_SPM_UpdateFirmware (iDevIdx, iSlotId: integer; cFileName: string) : integer;
  var
    iRetVal : integer;
    strTemp : AnsiString;
  const
    strFkt  = 'SEPIA2_SPM_UpdateFirmware';
  begin
    DebugOut (1, strFkt);
    strTemp := AnsiString (cFileName);
    iRetVal := _SEPIA2_SPM_UpdateFirmware (iDevIdx, iSlotId, PAnsiChar (strTemp));
    SEPIA2_SPM_UpdateFirmware := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SPM_UpdateFirmware


  function SEPIA2_SPM_SetFRAMWriteProtect (iDevIdx, iSlotId: integer; bWriteProtect: boolean) : integer;
  var
    iRetVal : integer;
    byteWriteProtect : Byte;
  const
    strFkt  = 'SEPIA2_SPM_SetFRAMWriteProtect';
  begin
    DebugOut (1, strFkt);
    byteWriteProtect := Byte (ifthen (bWriteProtect, SEPIA2_API_SPM_FRAM_WRITE_PROTECTED, SEPIA2_API_SPM_FRAM_WRITE_ENABLED));
    iRetVal := _SEPIA2_SPM_SetFRAMWriteProtect (iDevIdx, iSlotId, byteWriteProtect);
    SEPIA2_SPM_SetFRAMWriteProtect := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SPM_SetFRAMWriteProtect


  function SEPIA2_SPM_GetFiberAmplifierFail (iDevIdx, iSlotId: integer; var bFiberAmpFail: boolean) : integer;
  var
    iRetVal : integer;
    byteFiberAmpFail : byte;
  const
    strFkt  = 'SEPIA2_SPM_GetFiberAmplifierFail';
  begin
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
    byteFiberAmpFail : byte;
  const
    strFkt  = 'SEPIA2_SPM_ResetFiberAmplifierFail';
  begin
    DebugOut (1, strFkt);
    byteFiberAmpFail := ifthen (bFiberAmpFail, SEPIA2_API_SPM_FIBERAMPLIFIER_FAILURE, SEPIA2_API_SPM_FIBERAMPLIFIER_OK);
    iRetVal := _SEPIA2_SPM_ResetFiberAmplifierFail (iDevIdx, iSlotId, byteFiberAmpFail);
    SEPIA2_SPM_ResetFiberAmplifierFail := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_ResetFiberAmplifierFail


  function SEPIA2_SPM_GetPumpPowerState (iDevIdx, iSlotId: integer; var bIsPumpStateEco, bIsPumpModeDynamic: boolean) : integer;
  var
    iRetVal : integer;
    bytePumpState : byte;
    bytePumpMode  : byte;
  const
    strFkt  = 'SEPIA2_SPM_GetPumpPowerState';
  begin
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
    bytePumpState: byte;
    bytePumpMode: byte;
  const
    strFkt  = 'SEPIA2_SPM_SetPumpPowerState';
  begin
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
  const
    strFkt  = 'SEPIA2_SPM_GetOperationTimers';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SPM_GetOperationTimers (iDevIdx, iSlotId, dwMainPwrSw_Counter, dwUT_OverAll, dwUT_SinceDelivery, dwUT_SinceFibChg);
    SEPIA2_SPM_GetOperationTimers := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SPM_GetOperationTimers


  function SEPIA2_SWS_DecodeModuleType (iModuleType: integer; var cModuleType: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWS_DecodeModuleType';
  begin
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
  const
    strFkt  = 'SEPIA2_SWS_DecodeModuleState';
  begin
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
  const
    strFkt  = 'SEPIA2_SWS_GetModuleType';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetModuleType (iDevIdx, iSlotId, iModuleType);
    SEPIA2_SWS_GetModuleType := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetModuleType


  function SEPIA2_SWS_GetStatusError (iDevIdx, iSlotId: integer; var wModuleState: word; var iErrorCode: SmallInt) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWS_GetStatusError';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetStatusError (iDevIdx, iSlotId, wModuleState, iErrorCode);
    SEPIA2_SWS_GetStatusError := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetStatusError


  function SEPIA2_SWS_GetParamRanges (iDevIdx, iSlotId: integer; var ulUpperWL, ulLowerWL, ulIncrWL, ulPPMToggleWL, ulUpperBW, ulLowerBW, ulIncrBW: Cardinal; var iUpperAtten, iLowerAtten, iIncrAtten: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWS_GetParamRanges';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetParamRanges (iDevIdx, iSlotId, ulUpperWL, ulLowerWL, ulIncrWL, ulPPMToggleWL, ulUpperBW, ulLowerBW, ulIncrBW, iUpperAtten, iLowerAtten, iIncrAtten);
    SEPIA2_SWS_GetParamRanges := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetParamRanges


  function SEPIA2_SWS_GetParameters (iDevIdx, iSlotId: integer; var ulWaveLength, ulBandWidth: Cardinal) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWS_GetParameters';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetParameters (iDevIdx, iSlotId, ulWaveLength, ulBandWidth);
    SEPIA2_SWS_GetParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetParameters


  function SEPIA2_SWS_SetParameters (iDevIdx, iSlotId: integer; ulWaveLength, ulBandWidth: Cardinal) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWS_SetParameters';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_SetParameters (iDevIdx, iSlotId, ulWaveLength, ulBandWidth);
    SEPIA2_SWS_SetParameters := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_SetParameters


  function SEPIA2_SWS_GetIntensity (iDevIdx, iSlotId: integer; var ulIntensRaw: Cardinal; var fIntensity: Single) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWS_GetIntensity';
  begin
    DebugOut (1, strFkt);
    iREtVal := _SEPIA2_SWS_GetIntensity (iDevIdx, iSlotId, ulIntensRaw, fIntensity);
    SEPIA2_SWS_GetIntensity := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetIntensity


  function SEPIA2_SWS_GetFWVersion (iDevIdx, iSlotId: integer; var FWVersion: T_SepiaModules_FWVersion) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWS_GetFWVersion';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetFWVersion (iDevIdx, iSlotId, FWVersion.ulVersion);
    SEPIA2_SWS_GetFWVersion := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end;  // SEPIA2_SWS_GetFWVersion


  function SEPIA2_SWS_UpdateFirmware (iDevIdx, iSlotId: integer; cFileName: string) : integer;
  var
    iRetVal : integer;
    strTemp : AnsiString;
  const
    strFkt  = 'SEPIA2_SWS_UpdateFirmware';
  begin
    DebugOut (1, strFkt);
    strTemp := AnsiString (cFileName);
    iRetVal := _SEPIA2_SWS_UpdateFirmware (iDevIdx, iSlotId, PAnsiChar (strTemp));
    SEPIA2_SWS_UpdateFirmware := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWS_UpdateFirmware


  function SEPIA2_SWS_SetFRAMWriteProtect (iDevIdx, iSlotId: integer; bWriteProtect: boolean) : integer;
  var
    iRetVal : integer;
    byteWriteProtect : Byte;
  const
    strFkt  = 'SEPIA2_SWS_SetFRAMWriteProtect';
  begin
    DebugOut (1, strFkt);
    byteWriteProtect := Byte (ifthen (bWriteProtect, 1, 0));
    iRetVal := _SEPIA2_SWS_SetFRAMWriteProtect (iDevIdx, iSlotId, byteWriteProtect);
    SEPIA2_SWS_SetFRAMWriteProtect := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWS_SetFRAMWriteProtect


  function SEPIA2_SWS_GetBeamPos (iDevIdx, iSlotId: integer; var iBeamPosV, iBeamPosH: integer) : integer;
  var
    iRetVal  : integer;
    BeamPosV : SmallInt;
    BeamPosH : SmallInt;
  const
    strFkt  = 'SEPIA2_SWS_GetBeamPos';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetBeamPos (iDevIdx, iSlotId, BeamPosV, BeamPosH);
    iBeamPosV := BeamPosV;
    iBeamPosH := BeamPosH;
    SEPIA2_SWS_GetBeamPos := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWS_GetBeamPos


  function SEPIA2_SWS_SetBeamPos (iDevIdx, iSlotId: integer; iBeamPosV, iBeamPosH: integer) : integer;
  var
    iRetVal : integer;
    BeamPosV, BeamPosH : SmallInt;
  const
    strFkt  = 'SEPIA2_SWS_SetBeamPos';
  begin
    DebugOut (1, strFkt);
    BeamPosV := SmallInt (EnsureRange (iBeamPosV, Low (SmallInt), High (SmallInt)));
    BeamPosH := SmallInt (EnsureRange (iBeamPosH, Low (SmallInt), High (SmallInt)));
    iRetVal := _SEPIA2_SWS_SetBeamPos (iDevIdx, iSlotId, BeamPosV, BeamPosH);
    SEPIA2_SWS_SetBeamPos := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWS_SetBeamPos


  function SEPIA2_SWS_SetCalibrationMode (iDevIdx, iSlotId: integer; bCalibrationMode: boolean) : integer;
  var
    iRetVal : integer;
    byteCalibrationMode : Byte;
  const
    strFkt  = 'SEPIA2_SWS_SetCalibrationMode';
  begin
    DebugOut (1, strFkt);
    byteCalibrationMode := Byte (ifthen (bCalibrationMode, 1, 0));
    iRetVal := _SEPIA2_SWS_SetCalibrationMode (iDevIdx, iSlotId, byteCalibrationMode);
    SEPIA2_SWS_SetCalibrationMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWS_SetCalibrationMode


  function SEPIA2_SWS_GetCalTableSize (iDevIdx, iSlotId: integer; var wWLIdxCount, wBWIdxCount: word) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SWS_GetCalTableSize';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SWS_GetCalTableSize (iDevIdx, iSlotId, wWLIdxCount, wBWIdxCount);
    SEPIA2_SWS_GetCalTableSize := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWS_GetCalTableSize


  function SEPIA2_SWS_GetCalPointInfo (iDevIdx, iSlotId: integer; iWLIdx, iBWIdx: integer; var ulWaveLength, ulBandWidth: Cardinal; var iBeamPosV, iBeamPosH: integer) : integer;
  var
    iRetVal : integer;
    WLIdx,
    BWIdx,
    BeamPosV,
    BeamPosH : SmallInt;
  const
    strFkt  = 'SEPIA2_SWS_GetCalPointInfo';
  begin
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
  end; // SEPIA2_SWS_GetCalPointInfo


  function SEPIA2_SWS_SetCalPointValues (iDevIdx, iSlotId: integer; iWLIdx, iBWIdx, iBeamPosV, iBeamPosH: integer) : integer;
  var
    iRetVal : integer;
    WLIdx,
    BWIdx,
    BeamPosV,
    BeamPosH : SmallInt;
  const
    strFkt  = 'SEPIA2_SWS_SetCalPointValues';
  begin
    DebugOut (1, strFkt);
    WLIdx    := SmallInt (EnsureRange (iWLIdx, -1, High (SmallInt)));
    BWIdx    := SmallInt (EnsureRange (iBWIdx, -1, High (SmallInt)));
    BeamPosV := SmallInt (EnsureRange (iBeamPosV, Low(SmallInt), High (SmallInt)));
    BeamPosH := SmallInt (EnsureRange (iBeamPosH, Low(SmallInt), High (SmallInt)));
    //
    iRetVal := _SEPIA2_SWS_SetCalPointValues (iDevIdx, iSlotId, WLIdx, BWIdx, BeamPosV, BeamPosH);
    SEPIA2_SWS_SetCalPointValues := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWS_SetCalPointValues


  function SEPIA2_SWS_SetCalTableSize (iDevIdx, iSlotId: integer; wWLIdxCount, wBWIdxCount: word; bInit: boolean) : integer;
  var
    iRetVal : integer;
    byteInit : byte;
  const
    strFkt  = 'SEPIA2_SWS_SetCalTableSize';
  begin
    DebugOut (1, strFkt);
    //
    byteInit := ifthen (bInit, 1, 0);
    iRetVal := _SEPIA2_SWS_SetCalTableSize (iDevIdx, iSlotId, wWLIdxCount, wBWIdxCount, byteInit);
    SEPIA2_SWS_SetCalTableSize := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SWS_SetCalTableSize


  function SEPIA2_SSM_DecodeFreqTrigMode (iDevIdx, iSlotId: integer; iFreqTrigIdx: integer; var cFreqTrigMode: string; var iMainFreq: integer; var bEnableTrigLvl: boolean) : integer;
  var
    iRetVal : integer;
    byteEnableTrigLvl : byte;
  const
    strFkt  = 'SEPIA2_SSM_DecodeFreqTrigMode';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_SSM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, pcTmpVal1, iMainFreq, byteEnableTrigLvl);
    bEnableTrigLvl := (byteEnableTrigLvl <> 0);
    cFreqTrigMode  := string(pcTmpVal1);
    SEPIA2_SSM_DecodeFreqTrigMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SSM_DecodeFreqTrigMode


  function SEPIA2_SSM_GetTrigLevelRange (iDevIdx, iSlotId: integer; var iUpperTrigLevel, iLowerTrigLevel, iTrigLevelResol: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SSM_GetTrigLevelRange';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SSM_GetTrigLevelRange (iDevIdx, iSlotId, iUpperTrigLevel, iLowerTrigLevel, iTrigLevelResol);
    SEPIA2_SSM_GetTrigLevelRange := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SSM_GetTrigLevelRange


  function SEPIA2_SSM_GetTriggerData (iDevIdx, iSlotId: integer; var iFreqTrigIdx, iTrigLevel: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SSM_GetTriggerData';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SSM_GetTriggerData (iDevIdx, iSlotId, iFreqTrigIdx, iTrigLevel);
    SEPIA2_SSM_GetTriggerData := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SSM_GetTriggerData


  function SEPIA2_SSM_SetTriggerData (iDevIdx, iSlotId: integer; iFreqTrigIdx, iTrigLevel: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SSM_SetTriggerData';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SSM_SetTriggerData (iDevIdx, iSlotId, iFreqTrigIdx, iTrigLevel);
    SEPIA2_SSM_SetTriggerData := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SSM_SetTriggerData


  function SEPIA2_SSM_GetFRAMWriteProtect (iDevIdx, iSlotId: integer; var bWriteProtect: boolean) : integer;
  var
    iRetVal : integer;
    byteWriteProtect : byte;
  const
    strFkt  = 'SEPIA2_SSM_GetFRAMWriteProtect';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SSM_GetFRAMWriteProtect (iDevIdx, iSlotId, byteWriteProtect);
    bWriteProtect := (byteWriteProtect <> 0);
    SEPIA2_SSM_GetFRAMWriteProtect := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SSM_GetFRAMWriteProtect


  function SEPIA2_SSM_SetFRAMWriteProtect (iDevIdx, iSlotId: integer; bWriteProtect: boolean) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_SSM_SetFRAMWriteProtect';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_SSM_SetFRAMWriteProtect (iDevIdx, iSlotId, byte (ifthen (bWriteProtect, 1, 0)));
    SEPIA2_SSM_SetFRAMWriteProtect := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_SSM_SetFRAMWriteProtect


  function SEPIA2_VUV_VIR_GetDeviceType (iDevIdx, iSlotId: integer; var cDeviceType: string; var bOptCW, bOptFanSwitch: boolean) : integer;
  var
    iRetVal : integer;
    byteOptCW,
    byteOptFanSwitch : byte;
  const
    strFkt  = 'SEPIA2_VUV_VIR_GetDeviceType';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_VUV_VIR_GetDeviceType (iDevIdx, iSlotId, pcTmpVal1, byteOptCW, byteOptFanSwitch);
    bOptCW  := (byteOptCW <> 0);
    bOptFanSwitch := (byteOptFanSwitch <> 0);
    cDeviceType  := string(pcTmpVal1);
    SEPIA2_VUV_VIR_GetDeviceType := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VUV_VIR_GetDeviceType


  function SEPIA2_VUV_VIR_DecodeFreqTrigMode (iDevIdx, iSlotId: integer; iTrigSourceIdx, iFreqDividerIdx: integer; var cFreqTrigMode: string; var iMainFreq: integer; var bEnableDivList, bEnableTrigLvl: boolean) : integer;
  var
    iRetVal : integer;
    byteEnableDivList,
    byteEnableTrigLvl : byte;
  const
    strFkt  = 'SEPIA2_VUV_VIR_DecodeFreqTrigMode';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_VUV_VIR_DecodeFreqTrigMode (iDevIdx, iSlotId, iTrigSourceIdx, iFreqDividerIdx, pcTmpVal1, iMainFreq, byteEnableDivList, byteEnableTrigLvl);
    bEnableDivList := (byteEnableDivList <> 0);
    bEnableTrigLvl := (byteEnableTrigLvl <> 0);
    cFreqTrigMode  := string(pcTmpVal1);
    SEPIA2_VUV_VIR_DecodeFreqTrigMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VUV_VIR_DecodeFreqTrigMode


  function SEPIA2_VUV_VIR_GetTrigLevelRange (iDevIdx, iSlotId: integer; var iUpperTrigLevel, iLowerTrigLevel, iTrigLevelResol: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_VUV_VIR_GetTrigLevelRange';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_VUV_VIR_GetTrigLevelRange (iDevIdx, iSlotId, iUpperTrigLevel, iLowerTrigLevel, iTrigLevelResol);
    SEPIA2_VUV_VIR_GetTrigLevelRange := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VUV_VIR_GetTrigLevelRange


  function SEPIA2_VUV_VIR_GetTriggerData (iDevIdx, iSlotId: integer; var iTrigSrcIdx, iFreqDivIdx, iTrigLevel: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_VUV_VIR_GetTriggerData';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_VUV_VIR_GetTriggerData (iDevIdx, iSlotId, iTrigSrcIdx, iFreqDivIdx, iTrigLevel);
    SEPIA2_VUV_VIR_GetTriggerData := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VUV_VIR_GetTriggerData

  function SEPIA2_VUV_VIR_SetTriggerData (iDevIdx, iSlotId: integer; iTrigSrcIdx, iFreqDivIdx, iTrigLevel: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_VUV_VIR_SetTriggerData';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_VUV_VIR_SetTriggerData (iDevIdx, iSlotId, iTrigSrcIdx, iFreqDivIdx, iTrigLevel);
    SEPIA2_VUV_VIR_SetTriggerData := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VUV_VIR_SetTriggerData


  function SEPIA2_VUV_VIR_GetIntensityRange (iDevIdx, iSlotId: integer; var iUpperIntens, iLowerIntens, iIntensResol: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_VUV_VIR_GetIntensityRange';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_VUV_VIR_GetIntensityRange (iDevIdx, iSlotId, iUpperIntens, iLowerIntens, iIntensResol);
    SEPIA2_VUV_VIR_GetIntensityRange := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VUV_VIR_GetIntensityRange


  function SEPIA2_VUV_VIR_GetIntensity (iDevIdx, iSlotId: integer; var iIntensity: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_VUV_VIR_GetIntensity';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_VUV_VIR_GetIntensity (iDevIdx, iSlotId, iIntensity);
    SEPIA2_VUV_VIR_GetIntensity := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VUV_VIR_GetIntensity

  function SEPIA2_VUV_VIR_SetIntensity (iDevIdx, iSlotId: integer; iIntensity: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_VUV_VIR_SetIntensity';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_VUV_VIR_SetIntensity (iDevIdx, iSlotId, iIntensity);
    SEPIA2_VUV_VIR_SetIntensity := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VUV_VIR_SetIntensity

  function SEPIA2_VUV_VIR_GetFan (iDevIdx, iSlotId: integer; var bFanRunning: boolean) : integer;
  var
    iRetVal : integer;
    byteFanRunning : Byte;
  const
    strFkt  = 'SEPIA2_VUV_VIR_GetFan';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_VUV_VIR_GetFan (iDevIdx, iSlotId, byteFanRunning);
    bFanRunning := (byteFanRunning > 0);
    SEPIA2_VUV_VIR_GetFan := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VUV_VIR_GetFan

  function SEPIA2_VUV_VIR_SetFan (iDevIdx, iSlotId: integer; bFanRunning: boolean) : integer;
  var
    iRetVal : integer;
    byteFanRunning : Byte;
  const
    strFkt  = 'SEPIA2_VUV_VIR_SetFan';
  begin
    DebugOut (1, strFkt);
    byteFanRunning := Byte(ifthen(bFanRunning, 1, 0));
    iRetVal := _SEPIA2_VUV_VIR_SetFan (iDevIdx, iSlotId, byteFanRunning);
    SEPIA2_VUV_VIR_SetFan := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_VUV_VIR_SetFan





  function SEPIA2_PRI_GetConstants (iDevIdx, iSlotId: integer; var PRIConstants: T_PRI_Constants) : integer;
  var
    Ret: Integer;
    Idx: Integer;
    OpMod: String;
    TrSrc: String;
    bDummy1: Boolean;
    bDummy2: Boolean;
  begin
    Ret := SEPIA2_ERR_NO_ERROR;
    try
      if (@PRIConstants = nil) then
      begin
        Ret := SEPIA2_ERR_LIB_ILLEGAL_PARAMETER_ON_FUNCTION_CALL;
        Result := Ret;
        exit;
      end;
      FillChar(PRIConstants, sizeof(T_PRI_Constants), 0);
      FillChar(PRIConstants.PrimaUSBIdx, Integer(NativeInt(sizeof(T_PRI_Constants)) + NativeInt(@PRIConstants) - NativeInt(@(PRIConstants.PrimaUSBIdx))), $FF);
      //
      with PRIConstants do
      begin
        PrimaUSBIdx := iDevIdx;
        PrimaSlotId := iSlotId;
        //
        if SEPIA2_PRI_GetDeviceInfo(iDevIdx, iSlotId, PrimaModuleID, PrimaModuleType, PrimaFWVers, PrimaWLCount) = SEPIA2_ERR_NO_ERROR then
        begin
          PrimaModuleID   := trim(PrimaModuleID);
          PrimaModuleType := trim(PrimaModuleType);
          PrimaFWVers     := trim(PrimaFWVers);
          //
          for Idx := 0 to PrimaWLCount-1 do
          begin
            Ret := SEPIA2_PRI_DecodeWavelength (iDevIdx, iSlotId, Idx, PrimaWLs[Idx]);
            if Ret <> SEPIA2_ERR_NO_ERROR then
              break;
          end;
          //
          if Ret = SEPIA2_ERR_NO_ERROR then
          begin
            for Idx := 0 to 7 do // 7 is definitely bigger!
            begin
              Ret := SEPIA2_PRI_DecodeOperationMode(iDevIdx, iSlotId, Idx, OpMod);
              if Ret <> SEPIA2_ERR_NO_ERROR then
              begin
                if (Ret = SEPIA2_ERR_PRI_ILLEGAL_OPERATION_MODE_INDEX) then
                begin
                  Ret := SEPIA2_ERR_NO_ERROR;
                  PrimaOpModCount := Idx;
                end;
                break;
              end
              else begin
                OpMod := OpMod.ToLower;
                if OpMod.Contains('off') then
                begin
                  PrimaOpModOff := Idx;
                end
                else if OpMod.Contains('narrow') then
                begin
                  PrimaOpModNarrow := Idx;
                end
                else if OpMod.Contains('broad') then
                begin
                  PrimaOpModBroad := Idx;
                end
                else if OpMod.Contains('cw') then
                begin
                  PrimaOpModCW := Idx;
                end;
              end;
            end; // for
          end;
          //
          if Ret = SEPIA2_ERR_NO_ERROR then
          begin
            for Idx := 0 to 7 do // 7 is definitely bigger!
            begin
              Ret := SEPIA2_PRI_DecodeTriggerSource (iDevIdx, iSlotId, Idx, TrSrc, bDummy1, bDummy2);
              if Ret <> SEPIA2_ERR_NO_ERROR then
              begin
                if (Ret = SEPIA2_ERR_PRI_ILLEGAL_TRIGGER_SOURCE_INDEX) then
                begin
                  Ret := SEPIA2_ERR_NO_ERROR;
                  PrimaTrSrcCount := Idx;
                end;
                break;
              end
              else begin
                TrSrc := TrSrc.ToLower;
                if TrSrc.Contains('int') then
                begin
                  PrimaTrSrcInt := Idx;
                end
                else if TrSrc.Contains('ext') then
                begin
                  if TrSrc.Contains('nim') then
                  begin
                    PrimaTrSrcExtNIM := Idx;
                  end
                  else if TrSrc.Contains('ttl') then
                  begin
                    PrimaTrSrcExtTTL := Idx;
                  end
                  else if TrSrc.Contains('fal') then
                  begin
                    PrimaTrSrcExtFalling := Idx;
                  end
                  else if TrSrc.Contains('ris') then
                  begin
                    PrimaTrSrcExtRising := Idx;
                  end;
                end; // TrSrc.Contains('ext')
              end; // else Ret <> SEPIA2_ERR_NO_ERROR
            end; // for TriggerSources
            //
            if Ret = SEPIA2_ERR_NO_ERROR then
            begin
              PrimaTemp_min := PRI_SupPnts_Temperature[ Low(PRI_SupPnts_Temperature)];
              PrimaTemp_max := PRI_SupPnts_Temperature[High(PRI_SupPnts_Temperature)];
            end;
            //
          end; // Ret = SEPIA2_ERR_NO_ERROR
        end; // GetDeviceInfo
        if Ret = SEPIA2_ERR_NO_ERROR then
          bInitialized := true;
      end; // with PRIConstants
      //
    finally
      Result := Ret;
    end;
    //
  end; // SEPIA2_PRI_GetConstants


  function SEPIA2_PRI_GetDeviceInfo (iDevIdx, iSlotId: integer; var cPRIModuleID: string; var cPRIModuleType: string; var cFW_Vers: string; var iWLCount: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_GetDeviceInfo';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    FillChar(pcTmpVal2^, TEMPVAR_LENGTH, #0);
    FillChar(pcTmpVal3^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_PRI_GetDeviceInfo (iDevIdx, iSlotId, pcTmpVal1, pcTmpVal2, pcTmpVal3, iWLCount);
    cPRIModuleID   := string(pcTmpVal1);
    cPRIModuleType := string(pcTmpVal2);
    cFW_Vers       := string(pcTmpVal3);
    SEPIA2_PRI_GetDeviceInfo := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetDeviceInfo


  function SEPIA2_PRI_DecodeOperationMode (iDevIdx, iSlotId: integer; iOpModeIdx: integer; var cOpMode: string) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_DecodeOperationMode';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_PRI_DecodeOperationMode (iDevIdx, iSlotId, iOpModeIdx, pcTmpVal1);
    cOpMode  := string(pcTmpVal1);
    SEPIA2_PRI_DecodeOperationMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_DecodeOperationMode


  function SEPIA2_PRI_GetOperationMode (iDevIdx, iSlotId: integer; var iOpModeIdx: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_GetOperationMode';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_GetOperationMode (iDevIdx, iSlotId, iOpModeIdx);
    SEPIA2_PRI_GetOperationMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetOperationMode

  function SEPIA2_PRI_SetOperationMode (iDevIdx, iSlotId: integer; iOpModeIdx: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_SetOperationMode';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_SetOperationMode (iDevIdx, iSlotId, iOpModeIdx);
    SEPIA2_PRI_SetOperationMode := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_SetOperationMode


  function SEPIA2_PRI_DecodeWavelength (iDevIdx, iSlotId: integer; iWLIdx: integer; var iWL: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_DecodeWavelength';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_DecodeWavelength (iDevIdx, iSlotId, iWLIdx, iWL);
    SEPIA2_PRI_DecodeWavelength := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_DecodeWavelength


  function SEPIA2_PRI_GetWavelengthIdx (iDevIdx, iSlotId: integer; var iWLIdx: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_GetWavelengthIdx';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_GetWavelengthIdx (iDevIdx, iSlotId, iWLIdx);
    SEPIA2_PRI_GetWavelengthIdx := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetWavelengthIdx

  function SEPIA2_PRI_SetWavelengthIdx (iDevIdx, iSlotId: integer; iWLIdx: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_SetWavelengthIdx';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_SetWavelengthIdx (iDevIdx, iSlotId, iWLIdx);
    SEPIA2_PRI_SetWavelengthIdx := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_SetWavelengthIdx


  function SEPIA2_PRI_GetIntensity (iDevIdx, iSlotId: integer; iWLIdx: integer; var wIntensity: word) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_GetIntensity';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_GetIntensity (iDevIdx, iSlotId, iWLIdx, wIntensity);
    SEPIA2_PRI_GetIntensity := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetIntensity

  function SEPIA2_PRI_SetIntensity (iDevIdx, iSlotId: integer; iWLIdx: integer; wIntensity: word) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_SetIntensity';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_SetIntensity (iDevIdx, iSlotId, iWLIdx, wIntensity);
    SEPIA2_PRI_SetIntensity := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_SetIntensity


  function SEPIA2_PRI_GetFrequencyLimits (iDevIdx, iSlotId: integer; var iMinFreq: integer; var iMaxFreq: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_GetFrequencyLimits';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_GetFrequencyLimits (iDevIdx, iSlotId, iMinFreq, iMaxFreq);
    SEPIA2_PRI_GetFrequencyLimits := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetFrequencyLimits

  function SEPIA2_PRI_GetFrequency (iDevIdx, iSlotId: integer; var iFrequency: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_GetFrequency';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_GetFrequency (iDevIdx, iSlotId, iFrequency);
    SEPIA2_PRI_GetFrequency := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetFrequency

  function SEPIA2_PRI_SetFrequency (iDevIdx, iSlotId: integer; iFrequency: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_SetFrequency';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_SetFrequency (iDevIdx, iSlotId, iFrequency);
    SEPIA2_PRI_SetFrequency := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_SetFrequency


  function SEPIA2_PRI_DecodeTriggerSource (iDevIdx, iSlotId: integer; iTrgSrcIdx: integer; var cTrgSrc: string; var bEnableFrequency, bEnableTrigLvl: boolean) : integer;
  var
    iRetVal : integer;
    byteEnableFrequency,
    byteEnableTrigLvl : byte;
  const
    strFkt  = 'SEPIA2_PRI_DecodeTriggerSource';
  begin
    DebugOut (1, strFkt);
    FillChar(pcTmpVal1^, TEMPVAR_LENGTH, #0);
    iRetVal := _SEPIA2_PRI_DecodeTriggerSource (iDevIdx, iSlotId, iTrgSrcIdx, pcTmpVal1, byteEnableFrequency, byteEnableTrigLvl);
    bEnableFrequency := (byteEnableFrequency <> 0);
    bEnableTrigLvl := (byteEnableTrigLvl <> 0);
    cTrgSrc  := string(pcTmpVal1);
    SEPIA2_PRI_DecodeTriggerSource := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_DecodeTriggerSource


  function SEPIA2_PRI_GetTriggerSource (iDevIdx, iSlotId: integer; var iTrgSrcIdx: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_GetTriggerSource';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_GetTriggerSource (iDevIdx, iSlotId, iTrgSrcIdx);
    SEPIA2_PRI_GetTriggerSource := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetTriggerSource

  function SEPIA2_PRI_SetTriggerSource (iDevIdx, iSlotId: integer; iTrgSrcIdx: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_SetTriggerSource';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_SetTriggerSource (iDevIdx, iSlotId, iTrgSrcIdx);
    SEPIA2_PRI_SetTriggerSource := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_SetTriggerSource


  function SEPIA2_PRI_GetTriggerLevelLimits (iDevIdx, iSlotId: integer; var iTrgMinLvl: integer; var iTrgMaxLvl: integer; var iTrgLvlRes: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_GetTriggerLevelLimits';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_GetTriggerLevelLimits (iDevIdx, iSlotId, iTrgMinLvl, iTrgMaxLvl, iTrgLvlRes);
    SEPIA2_PRI_GetTriggerLevelLimits := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetTriggerLevelLimits

  function SEPIA2_PRI_GetTriggerLevel (iDevIdx, iSlotId: integer; var iTrgLevel: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_GetTriggerLevel';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_GetTriggerLevel (iDevIdx, iSlotId, iTrgLevel);
    SEPIA2_PRI_GetTriggerLevel := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetTriggerLevel

  function SEPIA2_PRI_SetTriggerLevel (iDevIdx, iSlotId: integer; iTrgLevel: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_SetTriggerLevel';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_SetTriggerLevel (iDevIdx, iSlotId, iTrgLevel);
    SEPIA2_PRI_SetTriggerLevel := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_SetTriggerLevel


  function SEPIA2_PRI_GetGatingLimits (iDevIdx, iSlotId: integer; var iMinOnTime: integer; var iMaxOnTime: integer; var iMinOffTimefactor: integer; var iMaxOffTimefactor: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_GetGatingLimits';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_GetGatingLimits (iDevIdx, iSlotId, iMinOnTime, iMaxOnTime, iMinOffTimefactor, iMaxOffTimefactor);
    SEPIA2_PRI_GetGatingLimits := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetGatingLimits

  function SEPIA2_PRI_GetGatingData (iDevIdx, iSlotId: integer; var iOnTime: integer; var iOffTimefact: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_GetGatingData';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_GetGatingData (iDevIdx, iSlotId, iOnTime, iOffTimefact);
    SEPIA2_PRI_GetGatingData := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetGatingData

  function SEPIA2_PRI_SetGatingData (iDevIdx, iSlotId: integer; iOnTime: integer; iOffTimefact: integer) : integer;
  var
    iRetVal : integer;
  const
    strFkt  = 'SEPIA2_PRI_SetGatingData';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_SetGatingData (iDevIdx, iSlotId, iOnTime, iOffTimefact);
    SEPIA2_PRI_SetGatingData := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_SetGatingData

  function SEPIA2_PRI_GetGatingEnabled (iDevIdx, iSlotId: integer; var bGatingEnabled: boolean) : integer;
  var
    iRetVal : integer;
    byteGatingEnabled : Byte;
  const
    strFkt  = 'SEPIA2_PRI_GetGatingEnabled';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_GetGatingEnabled (iDevIdx, iSlotId, byteGatingEnabled);
    bGatingEnabled := (byteGatingEnabled > 0);
    SEPIA2_PRI_GetGatingEnabled := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetGatingEnabled

  function SEPIA2_PRI_SetGatingEnabled (iDevIdx, iSlotId: integer; bGatingEnabled: boolean) : integer;
  var
    iRetVal : integer;
    byteGatingEnabled : Byte;
  const
    strFkt  = 'SEPIA2_PRI_SetGatingEnabled';
  begin
    DebugOut (1, strFkt);
    byteGatingEnabled := Byte(ifthen(bGatingEnabled, 1, 0));
    iRetVal := _SEPIA2_PRI_SetGatingEnabled (iDevIdx, iSlotId, byteGatingEnabled);
    SEPIA2_PRI_SetGatingEnabled := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_SetGatingEnabled

  function SEPIA2_PRI_GetGateHighImpedance (iDevIdx, iSlotId: integer; var bHighImp: boolean) : integer;
  var
    iRetVal : integer;
    byteHighImp : Byte;
  const
    strFkt  = 'SEPIA2_PRI_GetGateHighImpedance';
  begin
    DebugOut (1, strFkt);
    iRetVal := _SEPIA2_PRI_GetGateHighImpedance (iDevIdx, iSlotId, byteHighImp);
    bHighImp := (byteHighImp > 0);
    SEPIA2_PRI_GetGateHighImpedance := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_GetGateHighImpedance

  function SEPIA2_PRI_SetGateHighImpedance (iDevIdx, iSlotId: integer; bHighImp: boolean) : integer;
  var
    iRetVal : integer;
    byteHighImp : Byte;
  const
    strFkt  = 'SEPIA2_PRI_SetGateHighImpedance';
  begin
    DebugOut (1, strFkt);
    byteHighImp := Byte(ifthen(bHighImp, 1, 0));
    iRetVal := _SEPIA2_PRI_SetGateHighImpedance (iDevIdx, iSlotId, byteHighImp);
    SEPIA2_PRI_SetGateHighImpedance := iRetVal;
    DebugOut (0, strFkt, iRetVal);
  end; // SEPIA2_PRI_SetGateHighImpedance


  function GetDLLFunction(Name: PAnsiChar; Default: Pointer = nil): FARPROC;
  begin
    Result := GetProcAddress(hdlDLL, Name);
    if not Assigned(Result) then
    begin
      if Assigned(Default) then
        Result := Default
      else
        bSepia2ImportLibOK := False;
    end;
    //
    if bSepia2ImportLibOK and Assigned (Result) then
      inc(iDLLFuncsCount);
  end;


initialization
  {$ifdef __CALL_DEBUGOUT__}
    bActiveDebugOut  := false;
  {$endif}

  try
    FormatSettings_enUS                 := TFormatSettings.Create ('en-US');
    FormatSettings_enUS.DateSeparator   := '/';
    FormatSettings_enUS.ShortDateFormat := 'yy/mm/dd';

    pcTmpVal1          := AllocMem  (TEMPVAR_LENGTH);
    pcTmpVal2          := AllocMem  (TEMPVAR_LENGTH);
    pcTmpVal3          := AllocMem  (TEMPVAR_LENGTH);
    pcTmpLongVal1      := AllocMem  (TEMPLONGVAR_LENGTH);
    pcTmpLongVal2      := AllocMem  (TEMPLONGVAR_LENGTH);
    bSepia2ImportLibOK := true;
    iDLLFuncsCount     := 0;
    //
    hdlDLL             := LoadLibrary (STR_LIB_NAME);
    //
    if hdlDLL = 0
    then begin
      strReason := 'Library Sepia2_lib.dll not found!';
      bSepia2ImportLibOK := false;
      //
      exit;
    end
    else begin
      @_SEPIA2_LIB_GetVersion                  := GetDLLFunction('SEPIA2_LIB_GetVersion');
      @_SEPIA2_LIB_GetLibUSBVersion            := GetDLLFunction('SEPIA2_LIB_GetLibUSBVersion',        @SUBST_LIB_GetLibUSBVersion);
      @_SEPIA2_LIB_IsRunningOnWine             := GetDLLFunction('SEPIA2_LIB_IsRunningOnWine');
      @_SEPIA2_LIB_DecodeError                 := GetDLLFunction('SEPIA2_LIB_DecodeError');
      //
      @_SEPIA2_USB_OpenDevice                  := GetDLLFunction('SEPIA2_USB_OpenDevice');
      @_SEPIA2_USB_OpenGetSerNumAndClose       := GetDLLFunction('SEPIA2_USB_OpenGetSerNumAndClose');
      @_SEPIA2_USB_CloseDevice                 := GetDLLFunction('SEPIA2_USB_CloseDevice');
      @_SEPIA2_USB_GetStrDescriptor            := GetDLLFunction('SEPIA2_USB_GetStrDescriptor');
      @_SEPIA2_USB_GetStrDescrByIdx            := GetDLLFunction('SEPIA2_USB_GetStrDescrByIdx',        @SUBST_USB_GetStrDescrByIdx);
      @_SEPIA2_USB_IsOpenDevice                := GetDLLFunction('SEPIA2_USB_IsOpenDevice',            @SUBST_USB_IsOpenDevice);
      //
      @_SEPIA2_FWR_GetVersion                  := GetDLLFunction('SEPIA2_FWR_GetVersion');
      @_SEPIA2_FWR_GetLastError                := GetDLLFunction('SEPIA2_FWR_GetLastError');
      @_SEPIA2_FWR_DecodeErrPhaseName          := GetDLLFunction('SEPIA2_FWR_DecodeErrPhaseName');
      @_SEPIA2_FWR_GetWorkingMode              := GetDLLFunction('SEPIA2_FWR_GetWorkingMode');
      @_SEPIA2_FWR_SetWorkingMode              := GetDLLFunction('SEPIA2_FWR_SetWorkingMode');
      @_SEPIA2_FWR_RollBackToPermanentValues   := GetDLLFunction('SEPIA2_FWR_RollBackToPermanentValues');
      @_SEPIA2_FWR_StoreAsPermanentValues      := GetDLLFunction('SEPIA2_FWR_StoreAsPermanentValues');
      @_SEPIA2_FWR_GetModuleMap                := GetDLLFunction('SEPIA2_FWR_GetModuleMap');
      @_SEPIA2_FWR_GetModuleInfoByMapIdx       := GetDLLFunction('SEPIA2_FWR_GetModuleInfoByMapIdx');
      @_SEPIA2_FWR_GetUptimeInfoByMapIdx       := GetDLLFunction('SEPIA2_FWR_GetUptimeInfoByMapIdx');
      @_SEPIA2_FWR_CreateSupportRequestText    := GetDLLFunction('SEPIA2_FWR_CreateSupportRequestText');
      @_SEPIA2_FWR_FreeModuleMap               := GetDLLFunction('SEPIA2_FWR_FreeModuleMap');
      //
      @_SEPIA2_COM_DecodeModuleType            := GetDLLFunction('SEPIA2_COM_DecodeModuleType');
      @_SEPIA2_COM_DecodeModuleTypeAbbr        := GetDLLFunction('SEPIA2_COM_DecodeModuleTypeAbbr');
      @_SEPIA2_COM_GetModuleType               := GetDLLFunction('SEPIA2_COM_GetModuleType');
      @_SEPIA2_COM_GetSerialNumber             := GetDLLFunction('SEPIA2_COM_GetSerialNumber');
      @_SEPIA2_COM_GetSupplementaryInfos       := GetDLLFunction('SEPIA2_COM_GetSupplementaryInfos');
      @_SEPIA2_COM_HasSecondaryModule          := GetDLLFunction('SEPIA2_COM_HasSecondaryModule');
      @_SEPIA2_COM_GetPresetInfo               := GetDLLFunction('SEPIA2_COM_GetPresetInfo');
      @_SEPIA2_COM_RecallPreset                := GetDLLFunction('SEPIA2_COM_RecallPreset');
      @_SEPIA2_COM_SaveAsPreset                := GetDLLFunction('SEPIA2_COM_SaveAsPreset');
      @_SEPIA2_COM_IsWritableModule            := GetDLLFunction('SEPIA2_COM_IsWritableModule');
      @_SEPIA2_COM_UpdateModuleData            := GetDLLFunction('SEPIA2_COM_UpdateModuleData');
      //
      @_SEPIA2_SCM_GetPowerAndLaserLEDS        := GetDLLFunction('SEPIA2_SCM_GetPowerAndLaserLEDS');
      @_SEPIA2_SCM_GetLaserLocked              := GetDLLFunction('SEPIA2_SCM_GetLaserLocked');
      @_SEPIA2_SCM_GetLaserSoftLock            := GetDLLFunction('SEPIA2_SCM_GetLaserSoftLock');
      @_SEPIA2_SCM_SetLaserSoftLock            := GetDLLFunction('SEPIA2_SCM_SetLaserSoftLock');
      //
      @_SEPIA2_SLM_DecodeFreqTrigMode          := GetDLLFunction('SEPIA2_SLM_DecodeFreqTrigMode');
      @_SEPIA2_SLM_DecodeHeadType              := GetDLLFunction('SEPIA2_SLM_DecodeHeadType');
      //
  {$ifdef __INCLUDE_DEPRECATED_SLM_FUNCTIONS__}
      @_SEPIA2_SLM_GetParameters               := GetDLLFunction('SEPIA2_SLM_GetParameters');                                   // deprecated
      // deprecated  : SEPIA2_SLM_GetParameters;
      // use instead : SEPIA2_SLM_GetIntensityFineStep, SEPIA2_SLM_GetPulseParameters
      @_SEPIA2_SLM_SetParameters               := GetDLLFunction('SEPIA2_SLM_SetParameters');                                   // deprecated
      // deprecated  : SEPIA2_SLM_SetParameters;
      // use instead : SEPIA2_SLM_SetIntensityFineStep, SEPIA2_SLM_SetPulseParameters
  {$endif}
      //
      @_SEPIA2_SLM_GetIntensityFineStep        := GetDLLFunction('SEPIA2_SLM_GetIntensityFineStep');
      @_SEPIA2_SLM_SetIntensityFineStep        := GetDLLFunction('SEPIA2_SLM_SetIntensityFineStep');
      @_SEPIA2_SLM_GetPulseParameters          := GetDLLFunction('SEPIA2_SLM_GetPulseParameters');
      @_SEPIA2_SLM_SetPulseParameters          := GetDLLFunction('SEPIA2_SLM_SetPulseParameters');
      //
      @_SEPIA2_SML_DecodeHeadType              := GetDLLFunction('SEPIA2_SML_DecodeHeadType');
      @_SEPIA2_SML_GetParameters               := GetDLLFunction('SEPIA2_SML_GetParameters');
      @_SEPIA2_SML_SetParameters               := GetDLLFunction('SEPIA2_SML_SetParameters');
      //
      @_SEPIA2_SOM_DecodeFreqTrigMode          := GetDLLFunction('SEPIA2_SOM_DecodeFreqTrigMode');
      @_SEPIA2_SOM_GetFreqTrigMode             := GetDLLFunction('SEPIA2_SOM_GetFreqTrigMode');
      @_SEPIA2_SOM_SetFreqTrigMode             := GetDLLFunction('SEPIA2_SOM_SetFreqTrigMode');
      @_SEPIA2_SOM_GetTriggerRange             := GetDLLFunction('SEPIA2_SOM_GetTriggerRange');
      @_SEPIA2_SOM_GetTriggerLevel             := GetDLLFunction('SEPIA2_SOM_GetTriggerLevel');
      @_SEPIA2_SOM_SetTriggerLevel             := GetDLLFunction('SEPIA2_SOM_SetTriggerLevel');
      @_SEPIA2_SOM_GetBurstValues              := GetDLLFunction('SEPIA2_SOM_GetBurstValues');
      @_SEPIA2_SOM_SetBurstValues              := GetDLLFunction('SEPIA2_SOM_SetBurstValues');
      @_SEPIA2_SOM_GetBurstLengthArray         := GetDLLFunction('SEPIA2_SOM_GetBurstLengthArray');
      @_SEPIA2_SOM_SetBurstLengthArray         := GetDLLFunction('SEPIA2_SOM_SetBurstLengthArray');
      @_SEPIA2_SOM_GetOutNSyncEnable           := GetDLLFunction('SEPIA2_SOM_GetOutNSyncEnable');
      @_SEPIA2_SOM_SetOutNSyncEnable           := GetDLLFunction('SEPIA2_SOM_SetOutNSyncEnable');
      @_SEPIA2_SOM_DecodeAUXINSequencerCtrl    := GetDLLFunction('SEPIA2_SOM_DecodeAUXINSequencerCtrl');
      @_SEPIA2_SOM_GetAUXIOSequencerCtrl       := GetDLLFunction('SEPIA2_SOM_GetAUXIOSequencerCtrl');
      @_SEPIA2_SOM_SetAUXIOSequencerCtrl       := GetDLLFunction('SEPIA2_SOM_SetAUXIOSequencerCtrl');
      //
      @_SEPIA2_SOMD_DecodeFreqTrigMode         := GetDLLFunction('SEPIA2_SOMD_DecodeFreqTrigMode');
      @_SEPIA2_SOMD_GetFreqTrigMode            := GetDLLFunction('SEPIA2_SOMD_GetFreqTrigMode');
      @_SEPIA2_SOMD_SetFreqTrigMode            := GetDLLFunction('SEPIA2_SOMD_SetFreqTrigMode');
      @_SEPIA2_SOMD_GetTriggerRange            := GetDLLFunction('SEPIA2_SOMD_GetTriggerRange');
      @_SEPIA2_SOMD_GetTriggerLevel            := GetDLLFunction('SEPIA2_SOMD_GetTriggerLevel');
      @_SEPIA2_SOMD_SetTriggerLevel            := GetDLLFunction('SEPIA2_SOMD_SetTriggerLevel');
      @_SEPIA2_SOMD_GetBurstValues             := GetDLLFunction('SEPIA2_SOMD_GetBurstValues');
      @_SEPIA2_SOMD_SetBurstValues             := GetDLLFunction('SEPIA2_SOMD_SetBurstValues');
      @_SEPIA2_SOMD_GetBurstLengthArray        := GetDLLFunction('SEPIA2_SOMD_GetBurstLengthArray');
      @_SEPIA2_SOMD_SetBurstLengthArray        := GetDLLFunction('SEPIA2_SOMD_SetBurstLengthArray');
      @_SEPIA2_SOMD_GetOutNSyncEnable          := GetDLLFunction('SEPIA2_SOMD_GetOutNSyncEnable');
      @_SEPIA2_SOMD_SetOutNSyncEnable          := GetDLLFunction('SEPIA2_SOMD_SetOutNSyncEnable');
      @_SEPIA2_SOMD_DecodeAUXINSequencerCtrl   := GetDLLFunction('SEPIA2_SOMD_DecodeAUXINSequencerCtrl');
      @_SEPIA2_SOMD_GetAUXIOSequencerCtrl      := GetDLLFunction('SEPIA2_SOMD_GetAUXIOSequencerCtrl');
      @_SEPIA2_SOMD_SetAUXIOSequencerCtrl      := GetDLLFunction('SEPIA2_SOMD_SetAUXIOSequencerCtrl');
      @_SEPIA2_SOMD_GetSeqOutputInfos          := GetDLLFunction('SEPIA2_SOMD_GetSeqOutputInfos');
      @_SEPIA2_SOMD_SetSeqOutputInfos          := GetDLLFunction('SEPIA2_SOMD_SetSeqOutputInfos');
      //
      @_SEPIA2_SOMD_SynchronizeNow             := GetDLLFunction('SEPIA2_SOMD_SynchronizeNow');
      @_SEPIA2_SOMD_DecodeModuleState          := GetDLLFunction('SEPIA2_SOMD_DecodeModuleState');
      @_SEPIA2_SOMD_GetStatusError             := GetDLLFunction('SEPIA2_SOMD_GetStatusError');
      @_SEPIA2_SOMD_GetTrigSyncFreq            := GetDLLFunction('SEPIA2_SOMD_GetTrigSyncFreq');
      @_SEPIA2_SOMD_GetDelayUnits              := GetDLLFunction('SEPIA2_SOMD_GetDelayUnits');
      @_SEPIA2_SOMD_GetFWVersion               := GetDLLFunction('SEPIA2_SOMD_GetFWVersion');
      @_SEPIA2_SOMD_FWReadPage                 := GetDLLFunction('SEPIA2_SOMD_FWReadPage');
      @_SEPIA2_SOMD_FWWritePage                := GetDLLFunction('SEPIA2_SOMD_FWWritePage');
      @_SEPIA2_SOMD_GetHWParams                := GetDLLFunction('SEPIA2_SOMD_GetHWParams');
      //
      @_SEPIA2_SWM_DecodeRangeIdx              := GetDLLFunction('SEPIA2_SWM_DecodeRangeIdx');
      @_SEPIA2_SWM_GetUIConstants              := GetDLLFunction('SEPIA2_SWM_GetUIConstants');
      @_SEPIA2_SWM_GetCurveParams              := GetDLLFunction('SEPIA2_SWM_GetCurveParams');
      @_SEPIA2_SWM_SetCurveParams              := GetDLLFunction('SEPIA2_SWM_SetCurveParams');
      @_SEPIA2_SWM_GetExtAtten                 := GetDLLFunction('SEPIA2_SWM_GetExtAtten');
      @_SEPIA2_SWM_SetExtAtten                 := GetDLLFunction('SEPIA2_SWM_SetExtAtten');
      //
      @_SEPIA2_VCL_GetUIConstants              := GetDLLFunction('SEPIA2_VCL_GetUIConstants');
      @_SEPIA2_VCL_GetTemperature              := GetDLLFunction('SEPIA2_VCL_GetTemperature');
      @_SEPIA2_VCL_SetTemperature              := GetDLLFunction('SEPIA2_VCL_SetTemperature');
      @_SEPIA2_VCL_GetBiasVoltage              := GetDLLFunction('SEPIA2_VCL_GetBiasVoltage');
      //
      @_SEPIA2_SPM_DecodeModuleState           := GetDLLFunction('SEPIA2_SPM_DecodeModuleState');
      @_SEPIA2_SPM_GetDeviceDescription        := GetDLLFunction('SEPIA2_SPM_GetDeviceDescription');
      @_SEPIA2_SPM_GetFWVersion                := GetDLLFunction('SEPIA2_SPM_GetFWVersion');
      @_SEPIA2_SPM_GetSensorData               := GetDLLFunction('SEPIA2_SPM_GetSensorData');
      @_SEPIA2_SPM_GetTemperatureAdjust        := GetDLLFunction('SEPIA2_SPM_GetTemperatureAdjust');
      @_SEPIA2_SPM_GetStatusError              := GetDLLFunction('SEPIA2_SPM_GetStatusError');
      @_SEPIA2_SPM_UpdateFirmware              := GetDLLFunction('SEPIA2_SPM_UpdateFirmware');
      @_SEPIA2_SPM_SetFRAMWriteProtect         := GetDLLFunction('SEPIA2_SPM_SetFRAMWriteProtect');
      @_SEPIA2_SPM_GetFiberAmplifierFail       := GetDLLFunction('SEPIA2_SPM_GetFiberAmplifierFail');
      @_SEPIA2_SPM_ResetFiberAmplifierFail     := GetDLLFunction('SEPIA2_SPM_ResetFiberAmplifierFail');
      @_SEPIA2_SPM_GetPumpPowerState           := GetDLLFunction('SEPIA2_SPM_GetPumpPowerState');
      @_SEPIA2_SPM_SetPumpPowerState           := GetDLLFunction('SEPIA2_SPM_SetPumpPowerState');
      @_SEPIA2_SPM_GetOperationTimers          := GetDLLFunction('SEPIA2_SPM_GetOperationTimers');
      //
      @_SEPIA2_SWS_DecodeModuleType            := GetDLLFunction('SEPIA2_SWS_DecodeModuleType');
      @_SEPIA2_SWS_DecodeModuleState           := GetDLLFunction('SEPIA2_SWS_DecodeModuleState');
      @_SEPIA2_SWS_GetModuleType               := GetDLLFunction('SEPIA2_SWS_GetModuleType');
      @_SEPIA2_SWS_GetStatusError              := GetDLLFunction('SEPIA2_SWS_GetStatusError');
      @_SEPIA2_SWS_GetParamRanges              := GetDLLFunction('SEPIA2_SWS_GetParamRanges');
      @_SEPIA2_SWS_GetParameters               := GetDLLFunction('SEPIA2_SWS_GetParameters');
      @_SEPIA2_SWS_SetParameters               := GetDLLFunction('SEPIA2_SWS_SetParameters');
      @_SEPIA2_SWS_GetIntensity                := GetDLLFunction('SEPIA2_SWS_GetIntensity');
      @_SEPIA2_SWS_GetFWVersion                := GetDLLFunction('SEPIA2_SWS_GetFWVersion');
      @_SEPIA2_SWS_UpdateFirmware              := GetDLLFunction('SEPIA2_SWS_UpdateFirmware');
      @_SEPIA2_SWS_SetFRAMWriteProtect         := GetDLLFunction('SEPIA2_SWS_SetFRAMWriteProtect');
      @_SEPIA2_SWS_GetBeamPos                  := GetDLLFunction('SEPIA2_SWS_GetBeamPos');
      @_SEPIA2_SWS_SetBeamPos                  := GetDLLFunction('SEPIA2_SWS_SetBeamPos');
      @_SEPIA2_SWS_SetCalibrationMode          := GetDLLFunction('SEPIA2_SWS_SetCalibrationMode');
      @_SEPIA2_SWS_GetCalTableSize             := GetDLLFunction('SEPIA2_SWS_GetCalTableSize');
      @_SEPIA2_SWS_SetCalTableSize             := GetDLLFunction('SEPIA2_SWS_SetCalTableSize');
      @_SEPIA2_SWS_GetCalPointInfo             := GetDLLFunction('SEPIA2_SWS_GetCalPointInfo');
      @_SEPIA2_SWS_SetCalPointValues           := GetDLLFunction('SEPIA2_SWS_SetCalPointValues');
      //
      @_SEPIA2_SSM_DecodeFreqTrigMode          := GetDLLFunction('SEPIA2_SSM_DecodeFreqTrigMode');
      @_SEPIA2_SSM_GetTrigLevelRange           := GetDLLFunction('SEPIA2_SSM_GetTrigLevelRange');
      @_SEPIA2_SSM_GetTriggerData              := GetDLLFunction('SEPIA2_SSM_GetTriggerData');
      @_SEPIA2_SSM_SetTriggerData              := GetDLLFunction('SEPIA2_SSM_SetTriggerData');
      @_SEPIA2_SSM_GetFRAMWriteProtect         := GetDLLFunction('SEPIA2_SSM_GetFRAMWriteProtect');
      @_SEPIA2_SSM_SetFRAMWriteProtect         := GetDLLFunction('SEPIA2_SSM_SetFRAMWriteProtect');
      //
      @_SEPIA2_VUV_VIR_GetDeviceType           := GetDLLFunction('SEPIA2_VUV_VIR_GetDeviceType');
      @_SEPIA2_VUV_VIR_DecodeFreqTrigMode      := GetDLLFunction('SEPIA2_VUV_VIR_DecodeFreqTrigMode');
      @_SEPIA2_VUV_VIR_GetTrigLevelRange       := GetDLLFunction('SEPIA2_VUV_VIR_GetTrigLevelRange');
      @_SEPIA2_VUV_VIR_GetTriggerData          := GetDLLFunction('SEPIA2_VUV_VIR_GetTriggerData');
      @_SEPIA2_VUV_VIR_SetTriggerData          := GetDLLFunction('SEPIA2_VUV_VIR_SetTriggerData');
      @_SEPIA2_VUV_VIR_GetIntensityRange       := GetDLLFunction('SEPIA2_VUV_VIR_GetIntensityRange');
      @_SEPIA2_VUV_VIR_GetIntensity            := GetDLLFunction('SEPIA2_VUV_VIR_GetIntensity');
      @_SEPIA2_VUV_VIR_SetIntensity            := GetDLLFunction('SEPIA2_VUV_VIR_SetIntensity');
      @_SEPIA2_VUV_VIR_GetFan                  := GetDLLFunction('SEPIA2_VUV_VIR_GetFan');
      @_SEPIA2_VUV_VIR_SetFan                  := GetDLLFunction('SEPIA2_VUV_VIR_SetFan');
      //
      @_SEPIA2_PRI_GetDeviceInfo               := GetDLLFunction('SEPIA2_PRI_GetDeviceInfo');
      @_SEPIA2_PRI_DecodeOperationMode         := GetDLLFunction('SEPIA2_PRI_DecodeOperationMode');
      @_SEPIA2_PRI_GetOperationMode            := GetDLLFunction('SEPIA2_PRI_GetOperationMode');
      @_SEPIA2_PRI_SetOperationMode            := GetDLLFunction('SEPIA2_PRI_SetOperationMode');
      @_SEPIA2_PRI_DecodeWavelength            := GetDLLFunction('SEPIA2_PRI_DecodeWavelength');
      @_SEPIA2_PRI_GetWavelengthIdx            := GetDLLFunction('SEPIA2_PRI_GetWavelengthIdx');
      @_SEPIA2_PRI_SetWavelengthIdx            := GetDLLFunction('SEPIA2_PRI_SetWavelengthIdx');
      @_SEPIA2_PRI_GetIntensity                := GetDLLFunction('SEPIA2_PRI_GetIntensity');
      @_SEPIA2_PRI_SetIntensity                := GetDLLFunction('SEPIA2_PRI_SetIntensity');
      @_SEPIA2_PRI_GetFrequencyLimits          := GetDLLFunction('SEPIA2_PRI_GetFrequencyLimits');
      @_SEPIA2_PRI_GetFrequency                := GetDLLFunction('SEPIA2_PRI_GetFrequency');
      @_SEPIA2_PRI_SetFrequency                := GetDLLFunction('SEPIA2_PRI_SetFrequency');
      @_SEPIA2_PRI_DecodeTriggerSource         := GetDLLFunction('SEPIA2_PRI_DecodeTriggerSource');
      @_SEPIA2_PRI_GetTriggerSource            := GetDLLFunction('SEPIA2_PRI_GetTriggerSource');
      @_SEPIA2_PRI_SetTriggerSource            := GetDLLFunction('SEPIA2_PRI_SetTriggerSource');
      @_SEPIA2_PRI_GetTriggerLevelLimits       := GetDLLFunction('SEPIA2_PRI_GetTriggerLevelLimits');
      @_SEPIA2_PRI_GetTriggerLevel             := GetDLLFunction('SEPIA2_PRI_GetTriggerLevel');
      @_SEPIA2_PRI_SetTriggerLevel             := GetDLLFunction('SEPIA2_PRI_SetTriggerLevel');
      @_SEPIA2_PRI_GetGatingLimits             := GetDLLFunction('SEPIA2_PRI_GetGatingLimits');
      @_SEPIA2_PRI_GetGatingData               := GetDLLFunction('SEPIA2_PRI_GetGatingData');
      @_SEPIA2_PRI_SetGatingData               := GetDLLFunction('SEPIA2_PRI_SetGatingData');
      @_SEPIA2_PRI_GetGatingEnabled            := GetDLLFunction('SEPIA2_PRI_GetGatingEnabled');
      @_SEPIA2_PRI_SetGatingEnabled            := GetDLLFunction('SEPIA2_PRI_SetGatingEnabled');
      @_SEPIA2_PRI_GetGateHighImpedance        := GetDLLFunction('SEPIA2_PRI_GetGateHighImpedance');
      @_SEPIA2_PRI_SetGateHighImpedance        := GetDLLFunction('SEPIA2_PRI_SetGateHighImpedance');
      //
      strCount  := RightStr ('   ' + IntToStr(iDLLFuncsCount), 3);
      strReason := '*  Error after ' + strCount + ' DLL-functions!  *';
      //
      //
      if bSepia2ImportLibOK
      then begin
        iRet := SEPIA2_LIB_GetVersion (strLibVersion);
        if (iRet <> SEPIA2_ERR_NO_ERROR)
          or ( (0 > StrLComp(PChar(strLibVersion), PChar(LIB_VERSION_REFERENCE), LIB_VERSION_COMPLEN))
           and (0 > StrLComp(PChar(strLibVersion), PChar(LIB_VERSION_REFERENCE_OLD), LIB_VERSION_COMPLEN))
             )
        then begin
          strReason := 'Library Sepia2_lib.dll not up-to-date!';
          bSepia2ImportLibOK := false;
        end;
        //
        iRet := SEPIA2_LIB_GetLibUSBVersion (strLibUSBVersion);
        if (iRet <> SEPIA2_ERR_NO_ERROR)
        then begin
          strReason := 'USB-wrapper SVN-version unknown!';
          bSepia2ImportLibOK := false;
        end;
        //
        if bSepia2ImportLibOK
        then begin
          if (0 > StrLComp(PChar(strLibVersion), PChar(LIB_VERSION_REFERENCE_OLD), LIB_VERSION_COMPLEN))
          then begin
            OutputDebugString(PChar('   ********************************************************   '));
            OutputDebugString(PChar('   *   Warning:  Library Sepia2_lib.dll not up-to-date!   *   '));
            OutputDebugString(PChar('   ********************************************************   '));
          end;
        end;
      end;
    end;

  finally

    if not bSepia2ImportLibOK
    then begin
      OutputDebugString(PChar('   *************************************   '));
      OutputDebugString(PChar('   *  Error on Import Sepia2 Library!  *   '));
      OutputDebugString(PChar('   *************************************   '));
      OutputDebugString(PChar('   ' + strReason + '   '));
    end;

  end;

finalization
  FreeLibrary (hdlDLL);
  FreeMem (pcTmpLongVal2);
  FreeMem (pcTmpLongVal1);
  FreeMem (pcTmpVal3);
  FreeMem (pcTmpVal2);
  FreeMem (pcTmpVal1);
end.
