# The following constants and structs are from 'Sepia2_Def.h'
# -----------------------------------------------------------------------------
#
#       Sepia2_Def.h
#
# -----------------------------------------------------------------------------
#
#   symbols used by SEPIA2_LIB
#
# -----------------------------------------------------------------------------
#   HISTORY:
#
#   apo  22.12.05   release of the library interface
#
#   apo  12.02.07   introduced SML Multilaser Module (V1.0.2.0)
#
#   apo  02.12.09   introduced SWM Pulsar Waveform Module (V1.0.2.1)
#                   changed SEPIA2OBJECT_SLT to 0x42
#
#   apo  24.02.14   raised library version number to 1.1.0.x (V1.1.0.293)
#
#   apo  25.02.14   now the version number identifies the configuration
#                     x86 vs. x64 (V1.1.xx.294)
#
#   apo  24.04.15   from now on the device index stuff is defined here
#                     (and only here!) (V1.1.xx.429)
#
#   apo  25.01.21   introduced VIR, VUV module functions (for VisUV/IR) (V1.2.xx.641)
#
#   dsc  20.04.21   introduced adaption for Python-demo
#
# -----------------------------------------------------------------------------
#

import struct
import ctypes as ct
#from typing import NamedTuple
#
#
LIB_VERSION_REFERENCE_WIN64 = "1.2.64.*";                           #  this is the part to compare with, but ignore the asterisk
LIB_VERSION_REFERENCE_WIN32 = "1.2.32.*";                           #  this is the part to compare with, but ignore the asterisk

if struct.calcsize("P") == 8:
    LIB_VERSION_REFERENCE = LIB_VERSION_REFERENCE_WIN64             # For 64 Bit processes we need compare the DLL-import against the 64 Bit version
else:
    LIB_VERSION_REFERENCE = LIB_VERSION_REFERENCE_WIN32             # For 32 Bit processes we need compare the DLL-import against the 32 Bit version

SEPIA2_VERSIONINFO_LEN = 11;                                        #  "1.2.xx.nnn\0" where xx is either 32 or 64 and nnn is the SVN build number
LIB_VERSION_REFERENCE_COMPLEN = 7;

SEPIA2_FW_VERSIONINFO_LEN = 10;                                     #  "2.01.nnn\0" where nnn is the firmware build number
FW_VERSION_REFERENCE_OLD = "1.05.";
FW_VERSION_REFERENCE = "2.01.";

FW_VERSION_REFERENCE_COMPLEN = 5;

SEPIA2_MAX_USB_DEVICES = 8;

SEPIA2_PRODID = 7;

SEPIA2_STRDSCR_IDX_VENDOR = 1;
SEPIA2_STRDSCR_IDX_MODEL = 2;
SEPIA2_STRDSCR_IDX_BUILD = 3;
SEPIA2_STRDSCR_IDX_SERIAL = 4;

SEPIA2_SUPREQ_OPT_NO_PREAMBLE = 0x0001;
SEPIA2_SUPREQ_OPT_NO_TITLE = 0x0002;
SEPIA2_SUPREQ_OPT_NO_CALLING_SW_INDENT = 0x0004;
SEPIA2_SUPREQ_OPT_NO_SYSTEM_INFO = 0x0008;


#  error codes  --------------------------------------------------------------------------------------------------------------
SEPIA2_NO_ERROR = 0;



SEPIA2_SOM_BURSTCHANNEL_COUNT = 8;

SEPIA2_RESTART = 1;
SEPIA2_NO_RESTART = 0;

SEPIA2_LASER_LOCKED = 1;
SEPIA2_LASER_UNLOCKED = 0;

SEPIA2_PRIMARY_MODULE = 1;
SEPIA2_SECONDARY_MODULE = 0;

SEPIA2_SLM_PULSE_MODE = 1;
SEPIA2_SLM_CW_MODE = 0;

SEPIA2_SML_PULSE_MODE = 1;
SEPIA2_SML_CW_MODE = 0;

SEPIA2_SOM_INVERSE_SYNC_MASK = 1;
SEPIA2_SOM_STANDARD_SYNC_MASK = 0;


SEPIA2_USB_STRDECR_LEN = 256;
SEPIA2_ERRSTRING_LEN = 64;
SEPIA2_FW_ERRCOND_LEN = 55;
SEPIA2_FW_ERRPHASE_LEN = 24;
SEPIA2_SERIALNUMBER_LEN = 13;
SEPIA2_PRODUCTMODEL_LEN = 33;
SEPIA2_MODULETYPESTRING_LEN = 55;
SEPIA2_SLM_FREQ_TRIGMODE_LEN = 28;
SEPIA2_SLM_HEADTYPE_LEN = 18;
SEPIA2_SOM_FREQ_TRIGMODE_LEN = 32;
SEPIA2_SWS_MODULETYPE_LEN = 20;
SEPIA2_SWS_MODULESTATE_LEN = 20;
SEPIA2_VUV_VIR_DEVTYPE_LEN = 32;
SEPIA2_VUV_VIR_TRIGINFO_LEN = 15;
SEPIA2_PRI_DEVICE_ID_LEN = 6;
SEPIA2_PRI_DEVTYPE_LEN = 32;
SEPIA2_PRI_DEVICE_FW_LEN = 8;
SEPIA2_PRI_OPERMODE_LEN = 16;
SEPIA2_PRI_TRIGSRC_LEN = 26;

#
#                                      #               bit  7         6         5     4    3      2..0
#       SepiaObjTyp                    #                    L module  secondary            S
#            -                         #                    /         /         laser osc  /      typecnt
#    construction table                #                    H backpl  primary              L or F
#                                      #
SEPIA2OBJECT_FRMS = 0xC0;              #  1 1 00  0 000     backplane primary   no    no   small  0  #  primary backplane, small
SEPIA2OBJECT_FRML = 0xC8;              #  1 1 00  1 000     backplane primary   no    no   large  0  #  primary backplane, large
SEPIA2OBJECT_SCM = 0x40;               #  0 1 00  0 000     module    primary   no    no   d.c.   0  #  for Sepia II: Controller Modules (Safety Board)
SEPIA2OBJECT_SLC = 0x41;               #  0 1 00  0 001     module    primary   no    no   d.c.   1  #  for Solea: Laser Coupler
SEPIA2OBJECT_SLT = 0x42;               #  0 1 00  0 010     module    primary   no    no   d.c.   2  #  for Module Commissioning Site: Voltage Meter Module
SEPIA2OBJECT_SWM = 0x43;               #  0 1 00  0 011     module    primary   no    no   d.c.   3  #  for PPL 400: Waveform Shaper Modules
SEPIA2OBJECT_SWS = 0x44;               #  0 1 00  0 100     module    primary   no    no   d.c.   4  #  for Solea: Wavelength Selector Modules
SEPIA2OBJECT_SPM = 0x45;               #  0 1 00  0 101     module    primary   no    no   d.c.   5  #  for Solea: Pumpcontrol Modules
SEPIA2OBJECT_LMP1 = 0x46;              #  0 1 00  0 110     module    primary   no    no   small  6  #  for Laser Test Site: Meter Module w. Shutter Control
SEPIA2OBJECT_LMP8 = 0x4E;              #  0 1 00  1 110     module    primary   no    no   large  6  #  for Laser Test Site: 8 Meter Modules
SEPIA2OBJECT_SOM = 0x50;               #  0 1 01  0 000     module    primary   no    yes  d.c.   0  #  for Sepia II: Oscillator Modules
SEPIA2OBJECT_SOMD = 0x51;              #  0 1 01  0 001     module    primary   no    yes  d.c.   1  #  for Sepia II: Oscillator Modules with Delay
SEPIA2OBJECT_SML = 0x60;               #  0 1 10  0 000     module    primary   yes   no   d.c.   0  #  for Sepia II: Multi Laser Modules
SEPIA2OBJECT_VCL = 0x61;               #  0 1 10  0 000     module    primary   yes   no   d.c.   1  #  for PPL 400: Voltage Controlled Laser Modules
SEPIA2OBJECT_SLM = 0x70;               #  0 1 11  0 000     module    primary   yes   yes  d.c.   0  #  for Sepia II: Laser Driver Modules
SEPIA2OBJECT_SSM = 0x71;               #  0 1 11  0 001     module    primary   yes   yes  d.c.   1  #  for Solea: Seed Laser Modules
SEPIA2OBJECT_VIR = 0x72;               #  0 1 11  0 010     module    primary   yes   yes  d.c.   2  #  for VisIR: Laser Modules
SEPIA2OBJECT_VUV = 0x73;               #  0 1 11  0 011     module    primary   yes   yes  d.c.   3  #  for VisUV: Laser Modules
SEPIA2OBJECT_PRI = 0x74;               #  0 1 11  0 100     module    primary   yes   yes  d.c.   4  #  for Prima: Laser Modules (PUMUCL)
SEPIA2OBJECT_LHS = 0x20;               #  0 0 10  0 000     module    secondary yes   no   slow   0  #  for Sepia II: Laser Head slow
SEPIA2OBJECT_LHF = 0x28;               #  0 0 10  1 000     module    secondary yes   no   fast   0  #  for Sepia II: Laser Head fast
SEPIA2OBJECT_LH_ = 0x29;               #  0 0 10  1 001     module    secondary yes   no   fast   1
SEPIA2OBJECT_FAIL = 0xFF;

SEPIA2_SLM_FREQ_80MHZ = 0;
SEPIA2_SLM_FREQ_40MHZ = 1;
SEPIA2_SLM_FREQ_20MHZ = 2;
SEPIA2_SLM_FREQ_10MHZ = 3;
SEPIA2_SLM_FREQ_5MHZ = 4;
SEPIA2_SLM_FREQ_2_5MHZ = 5;
SEPIA2_SLM_TRIGMODE_RAISING = 6;
SEPIA2_SLM_TRIGMODE_FALLING = 7;
SEPIA2_SLM_FREQ_TRIGMODE_COUNT = 8;

SEPIA2_SLM_HEADTYPE_FAILURE = 0;
SEPIA2_SLM_HEADTYPE_LED = 1;
SEPIA2_SLM_HEADTYPE_LASER = 2;
SEPIA2_SLM_HEADTYPE_NONE = 3;
SEPIA2_SLM_HEADTYPE_COUNT = 4;

SEPIA2_SML_HEADTYPE_FAILURE = 0;
SEPIA2_SML_HEADTYPE_4_LEDS = 1;
SEPIA2_SML_HEADTYPE_4_LASERS = 2;
SEPIA2_SML_HEADTYPE_COUNT = 3;

SEPIA2_SOM_TRIGGERLEVEL_STEP = 20; # in mV
SEPIA2_SOM_TRIGGERLEVEL_HALFSTEP = (SEPIA2_SOM_TRIGGERLEVEL_STEP / 2);
SEPIA2_SOM_TRIGMODE_RISING = 0;
SEPIA2_SOM_TRIGMODE_FALLING = 1;
SEPIA2_SOM_INT_OSC_A = 2;
SEPIA2_SOM_INT_OSC_B = 3;
SEPIA2_SOM_INT_OSC_C = 4;
SEPIA2_SOM_FREQ_TRIGMODE_COUNT = 5;
SEPIA2_SOMD_TRIGMODE_RISING = 0;
SEPIA2_SOMD_TRIGMODE_FALLING = 1;
SEPIA2_SOMD_INT_OSC_A = 2;
SEPIA2_SOMD_INT_OSC_B = 3;
SEPIA2_SOMD_INT_OSC_C = 4;
SEPIA2_SOMD_FREQ_TRIGMODE_COUNT = 5;

SEPIA2_SWM_CURVES_COUNT = 2;
SEPIA2_SWM_TIMEBASE_RANGES_COUNT = 3;
#
SEPIA2_SWM_UI_TABIDX_RESOLUTION = 0;
SEPIA2_SWM_UI_TABIDX_MIN_USERVALUE = 1;
SEPIA2_SWM_UI_TABIDX_MAX_USERVALUE = 2;
SEPIA2_SWM_UI_TABIDX_USER_RESOLUTION = 3;
SEPIA2_SWM_UI_TABIDX_MAX_AMPLITUDE = 4;
SEPIA2_SWM_UI_TABIDX_MAX_SLEWRATE = 5;
SEPIA2_SWM_UI_TABIDX_EXP_RAMP_EFFECT = 6;
SEPIA2_SWM_UI_TABIDX_TIMEBASERANGES_COUNT = 7;
SEPIA2_SWM_UI_TABIDX_PULSEDATA_COUNT = 8;
SEPIA2_SWM_UI_TABIDX_RAMPDATA_COUNT = 9;
SEPIA2_SWM_UI_TABIDX_DELAYDATA_TB0_COUNT = 10;
SEPIA2_SWM_UI_TABIDX_DELAYDATA_TB1_COUNT = 11;
SEPIA2_SWM_UI_TABIDX_DELAYDATA_TB2_COUNT = 12;

SEPIA2_SPM_TEMPERATURE_SENSORCOUNT = 6;

PRAEFIXES = "yzafpnµm kMGTPEZY"
PRAEFIX_OFFSET = 8

class T_Module_FWVers(ct.Structure):
    _fields_ = [("BuildNr", ct.c_ushort),
                ("VersMin", ct.c_byte),
                ("VersMaj", ct.c_byte)]


class T_Version_Short(ct.Structure):
    _fields_ = [("VersMin", ct.c_byte),
                ("VersMaj", ct.c_byte)]


class T_SPM_Temperatures(ct.Structure):
    _fields_ = [("wT_Pump1", ct.c_ushort),
                ("wT_Pump2", ct.c_ushort),
                ("wT_Pump3", ct.c_ushort),
                ("wT_Pump4", ct.c_ushort),
                ("wT_FiberStack", ct.c_ushort),
                ("wT_AuxAdjust", ct.c_ushort)]


class T_SPM_SensorData(ct.Structure):
    _fields_ = [("Temperatures", T_SPM_Temperatures),
                ("wOverAllCurrent", ct.c_ushort),
                ("wOptionalSensor1", ct.c_ushort),
                ("wOptionalSensor2", ct.c_ushort)]
