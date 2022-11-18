
namespace PQ.Sepia2
{
  public static partial class Sepia2_Lib
  {
    /*
     * The following constants are from 'Sepia2_Error_Codes.h'
    /**/
    #region Constants are from 'Sepia2_Error_Codes.h'

    //-----------------------------------------------------------------------------
    //
    //      Sepia2_ErrorCodes.h
    //
    //-----------------------------------------------------------------------------
    //
    //  Exports the official list of error codes for Sepia2_lib V1.2.xx.753
    //
    //-----------------------------------------------------------------------------
    //  HISTORY:
    //
    //  apo  26.01.06   derived from Sepia2_lib.dll - SW
    //
    //  apo  07.02.06   eliminated doubles,
    //                  new messages (3201..3211) included
    //
    //  apo  03.03.06   re-added lost error message -9005 (V1.0.1.3)
    //
    //  apo  12.02.07   introduced SML Multilaser Module (V1.0.2.0)
    //
    //  apo  02.12.09   introduced SWM Pulsar Waveform Module (V1.0.2.1)
    //
    //  apo  19.04.10   incorporated into EasyTau-SW   (V1.0.2.0)
    //
    //  apo  04.02.11   incorporated into Submarine-SW (V1.0.2.0)
    //
    //  apo  16.08.12   introduced Solea SWS Wavelength Selector Module (V1.0.3.x)
    //
    //  apo  12.10.12   introduced Solea SSM Seedlaser Module (V1.0.3.x)
    //
    //  apo  21.01.13   introduced new USB error values (as created by MW)
    //
    //  apo  16.05.13   introduced LMP Module for PQ int. laser test site (V1.0.3.x)
    //
    //  apo  12.06.13   introduced Solea SPM Pumpcontrol Module (V1.0.3.x)
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
    //  apo  27.02.15   additional error codes for SOMD Module (V1.1.xx.403)
    //
    //  apo  04.03.15   additional symbol construction rules (V1.1.xx.407)
    //
    //  apo  11.08.15   additional error codes for working modes (V1.1.xx.460)
    //                    changed some error messages and added HW errors for SOMD,
    //                    added error codes for PPL400 VCL
    //
    //  apo  05.08.16   eliminated productname 'Solea' from messages and codes (V1.1.xx.498)
    //
    //  apo  19.10.20   additional error codes for VisUV/IR modules (V1.1.xx.590)
    //
    //  apo  20.01.21   raised library version to 1.2 due to USB driver changes (V1.2.xx.640)
    //
    //  apo  31.08.21   additional error codes for Prima modules (V1.2.xx.733)
    //
    //-----------------------------------------------------------------------------
    //

    public const int SEPIA2_ERR_NO_ERROR = 0;                         //  "no error"

    public const int SEPIA2_ERR_FW_MEMORY_ALLOCATION_ERROR = -1001;               //  "FW: memory allocation error"
    public const int SEPIA2_ERR_FW_CRC_ERROR_WHILE_CHECKING_SCM_828_MODULE = -1002;       //  "FW: CRC error while checking SCM 828 module"
    public const int SEPIA2_ERR_FW_CRC_ERROR_WHILE_CHECKING_BACKPLANE = -1003;          //  "FW: CRC error while checking backplane"
    public const int SEPIA2_ERR_FW_CRC_ERROR_WHILE_CHECKING_MODULE = -1004;           //  "FW: CRC error while checking module"
    public const int SEPIA2_ERR_FW_MAPSIZE_ERROR = -1005;                   //  "FW: mapsize error"
    public const int SEPIA2_ERR_FW_UNKNOWN_ERROR_PHASE = -1006;                 //  "FW: unknown error phase"
    public const int SEPIA2_ERR_FW_INSUFFICIENT_FW_VERSION = -1007;               //  "FW: insufficient FW version"
    public const int SEPIA2_ERR_FW_WRONG_WORKINGMODE = -1008;                 //  "FW: wrong workingmode"
    public const int SEPIA2_ERR_FW_ILLEGAL_MODULE_CHANGE = -1111;               //  "FW: illegal module change"

    public const int SEPIA2_ERR_USB_WRONG_DRIVER_VERSION = -2001;               //  "USB: wrong driver version"
    public const int SEPIA2_ERR_USB_OPEN_DEVICE_ERROR = -2002;                  //  "USB: open device error"
    public const int SEPIA2_ERR_USB_DEVICE_BUSY = -2003;                    //  "USB: device busy"
    public const int SEPIA2_ERR_USB_CLOSE_DEVICE_ERROR = -2005;                 //  "USB: close device error"
    public const int SEPIA2_ERR_USB_DEVICE_CHANGED = -2006;                   //  "USB: device changed"
    public const int SEPIA2_ERR_I2C_ADDRESS_ERROR = -2010;                    //  "I2C: address error"
    public const int SEPIA2_ERR_USB_DEVICE_INDEX_ERROR = -2011;                 //  "USB: device index error"
    public const int SEPIA2_ERR_I2C_ILLEGAL_MULTIPLEXER_PATH = -2012;             //  "I2C: illegal multiplexer path"
    public const int SEPIA2_ERR_I2C_ILLEGAL_MULTIPLEXER_LEVEL = -2013;              //  "I2C: illegal multiplexer level"
    public const int SEPIA2_ERR_I2C_ILLEGAL_SLOT_ID = -2014;                  //  "I2C: illegal slot id"
    public const int SEPIA2_ERR_FRAM_NO_UPTIME_COUNTER = -2015;                 //  "FRAM: no uptime counter"
    public const int SEPIA2_ERR_FRAM_BLOCKWRITE_ERROR = -2020;                  //  "FRAM: blockwrite error"
    public const int SEPIA2_ERR_FRAM_BLOCKREAD_ERROR = -2021;                 //  "FRAM: blockread error"
    public const int SEPIA2_ERR_FRAM_CRC_BLOCKCHECK_ERROR = -2022;                //  "FRAM: CRC blockcheck error"
    public const int SEPIA2_ERR_RAM_BLOCK_ALLOCATION_ERROR = -2023;               //  "RAM: block allocation error"
    public const int SEPIA2_ERR_RAM_SECURE_MEMORY_HANDLING_ERROR = -2024;           //  "RAM: secure memory handling error"
    public const int SEPIA2_ERR_I2C_INITIALISING_COMMAND_EXECUTION_ERROR = -2100;       //  "I2C: initialising command execution error"
    public const int SEPIA2_ERR_I2C_FETCHING_INITIALISING_COMMANDS_ERROR = -2101;       //  "I2C: fetching initialising commands error"
    public const int SEPIA2_ERR_I2C_WRITING_INITIALISING_COMMANDS_ERROR = -2102;        //  "I2C: writing initialising commands error"
    public const int SEPIA2_ERR_I2C_MODULE_CALIBRATING_ERROR = -2200;             //  "I2C: module calibrating error"
    public const int SEPIA2_ERR_I2C_FETCHING_CALIBRATING_COMMANDS_ERROR = -2201;        //  "I2C: fetching calibrating commands error"
    public const int SEPIA2_ERR_I2C_WRITING_CALIBRATING_COMMANDS_ERROR = -2202;         //  "I2C: writing calibrating commands error"
    public const int SEPIA2_ERR_DCL_FILE_OPEN_ERROR = -2301;                  //  "DCL: file open error"
    public const int SEPIA2_ERR_DCL_WRONG_FILE_LENGTH = -2302;                  //  "DCL: wrong file length"
    public const int SEPIA2_ERR_DCL_FILE_READ_ERROR = -2303;                  //  "DCL: file read error"
    public const int SEPIA2_ERR_FRAM_IS_WRITE_PROTECTED = -2304;                //  "FRAM: is write protected"
    public const int SEPIA2_ERR_DCL_FILE_SPECIFIES_DIFFERENT_MODULETYPE = -2305;        //  "DCL: file specifies different moduletype"
    public const int SEPIA2_ERR_DCL_FILE_SPECIFIES_DIFFERENT_SERIAL_NUMBER = -2306;       //  "DCL: file specifies different serial number"

    public const int SEPIA2_ERR_I2C_INVALID_ARGUMENT = -3001;                 //  "I2C: invalid argument"
    public const int SEPIA2_ERR_I2C_NO_ACKNOWLEDGE_ON_WRITE_ADRESSBYTE = -3002;         //  "I2C: no acknowledge on write adressbyte"
    public const int SEPIA2_ERR_I2C_NO_ACKNOWLEDGE_ON_READ_ADRESSBYTE = -3003;          //  "I2C: no acknowledge on read adressbyte"
    public const int SEPIA2_ERR_I2C_NO_ACKNOWLEDGE_ON_WRITE_DATABYTE = -3004;         //  "I2C: no acknowledge on write databyte"
    public const int SEPIA2_ERR_I2C_READ_BACK_ERROR = -3005;                  //  "I2C: read back error"
    public const int SEPIA2_ERR_I2C_READ_ERROR = -3006;                     //  "I2C: read error"
    public const int SEPIA2_ERR_I2C_WRITE_ERROR = -3007;                    //  "I2C: write error"
    public const int SEPIA2_ERR_I_O_FILE_ERROR = -3009;                     //  "I/O: file error"
    public const int SEPIA2_ERR_I2C_MULTIPLEXER_ERROR = -3014;                  //  "I2C: multiplexer error"
    public const int SEPIA2_ERR_I2C_MULTIPLEXER_PATH_ERROR = -3015;               //  "I2C: multiplexer path error"
    public const int SEPIA2_ERR_USB_INIT_FAILED = -3200;                    //  "USB: init failed"
    public const int SEPIA2_ERR_USB_INVALID_ARGUMENT = -3201;                 //  "USB: invalid argument"
    public const int SEPIA2_ERR_USB_DEVICE_STILL_OPEN = -3202;                  //  "USB: device still open"
    public const int SEPIA2_ERR_USB_NO_MEMORY = -3203;                      //  "USB: no memory"
    public const int SEPIA2_ERR_USB_OPEN_FAILED = -3204;                    //  "USB: open failed"
    public const int SEPIA2_ERR_USB_GET_DESCRIPTOR_FAILED = -3205;                //  "USB: get descriptor failed"
    public const int SEPIA2_ERR_USB_INAPPROPRIATE_DEVICE = -3206;               //  "USB: inappropriate device"
    public const int SEPIA2_ERR_USB_BUSY_DEVICE = -3207;                    //  "USB: busy device"
    public const int SEPIA2_ERR_USB_INVALID_HANDLE = -3208;                   //  "USB: invalid handle"
    public const int SEPIA2_ERR_USB_INVALID_DESCRIPTOR_BUFFER = -3209;              //  "USB: invalid descriptor buffer"
    public const int SEPIA2_ERR_USB_IOCTRL_FAILED = -3210;                    //  "USB: IOCTRL failed"
    public const int SEPIA2_ERR_USB_VCMD_FAILED = -3211;                    //  "USB: vcmd failed"
    public const int SEPIA2_ERR_USB_NO_SUCH_PIPE = -3212;                   //  "USB: no such pipe"
    public const int SEPIA2_ERR_USB_REGISTER_NOTIFICATION_FAILED = -3213;           //  "USB: register notification failed"
    public const int SEPIA2_ERR_USB_UNKNOWN_DEVICE = -3214;                   //  "USB: unknown device"
    public const int SEPIA2_ERR_USB_WRONG_DRIVER = -3215;                   //  "USB: wrong driver"
    public const int SEPIA2_ERR_USB_WINDOWS_ERROR = -3216;                    //  "USB: windows error"
    public const int SEPIA2_ERR_USB_DEVICE_NOT_OPEN = -3217;                  //  "USB: device not open"
    public const int SEPIA2_ERR_I2C_DEVICE_ERROR = -3256;                   //  "I2C: device error"
    public const int SEPIA2_ERR_LMP1_ADC_TABLES_NOT_FOUND = -3501;                //  "LMP1: ADC tables not found"
    public const int SEPIA2_ERR_LMP1_ADC_OVERFLOW = -3502;                    //  "LMP1: ADC overflow"
    public const int SEPIA2_ERR_LMP1_ADC_UNDERFLOW = -3503;                   //  "LMP1: ADC underflow"

    public const int SEPIA2_ERR_SCM_VOLTAGE_LIMITS_TABLE_NOT_FOUND = -4001;           //  "SCM: voltage limits table not found"
    public const int SEPIA2_ERR_SCM_VOLTAGE_SCALING_LIST_NOT_FOUND = -4002;           //  "SCM: voltage scaling list not found"
    public const int SEPIA2_ERR_SCM_REPEATEDLY_MEASURED_VOLTAGE_FAILURE = -4003;        //  "SCM: repeatedly measured voltage failure"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_0_VOLTAGE_TOO_LOW = -4010;        //  "SCM: power supply line 0: voltage too low"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_1_VOLTAGE_TOO_LOW = -4011;        //  "SCM: power supply line 1: voltage too low"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_2_VOLTAGE_TOO_LOW = -4012;        //  "SCM: power supply line 2: voltage too low"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_3_VOLTAGE_TOO_LOW = -4013;        //  "SCM: power supply line 3: voltage too low"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_4_VOLTAGE_TOO_LOW = -4014;        //  "SCM: power supply line 4: voltage too low"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_5_VOLTAGE_TOO_LOW = -4015;        //  "SCM: power supply line 5: voltage too low"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_6_VOLTAGE_TOO_LOW = -4016;        //  "SCM: power supply line 6: voltage too low"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_7_VOLTAGE_TOO_LOW = -4017;        //  "SCM: power supply line 7: voltage too low"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_0_VOLTAGE_TOO_HIGH = -4020;       //  "SCM: power supply line 0: voltage too high"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_1_VOLTAGE_TOO_HIGH = -4021;       //  "SCM: power supply line 1: voltage too high"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_2_VOLTAGE_TOO_HIGH = -4022;       //  "SCM: power supply line 2: voltage too high"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_3_VOLTAGE_TOO_HIGH = -4023;       //  "SCM: power supply line 3: voltage too high"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_4_VOLTAGE_TOO_HIGH = -4024;       //  "SCM: power supply line 4: voltage too high"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_5_VOLTAGE_TOO_HIGH = -4025;       //  "SCM: power supply line 5: voltage too high"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_6_VOLTAGE_TOO_HIGH = -4026;       //  "SCM: power supply line 6: voltage too high"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_7_VOLTAGE_TOO_HIGH = -4027;       //  "SCM: power supply line 7: voltage too high"
    public const int SEPIA2_ERR_SCM_POWER_SUPPLY_LASER_TURNING_OFF_VOLTAGE_TOO_HIGH = -4030;  //  "SCM: power supply laser turning-off-voltage too high"
    public const int SEPIA2_ERR_SCM_INVALID_TEMPERATURE_TABLE_COUNT = -4040;          //  "SCM: invalid temperature table count"
    public const int SEPIA2_ERR_SCM_TCONFG_TABLE_READ_FAILED = -4041;             //  "SCM: tconfg table read failed"
    public const int SEPIA2_ERR_SCM_INVALID_NUMBER_OF_TABLE_ENTRIES = -4042;          //  "SCM: invalid number of table entries"
    public const int SEPIA2_ERR_SCM_INVALID_TIMERTICK_VALUE = -4043;              //  "SCM: invalid timertick value"
    public const int SEPIA2_ERR_SCM_INVALID_TEMPERATURE_VALUE_TABLE = -4044;          //  "SCM: invalid temperature value table"
    public const int SEPIA2_ERR_SCM_INVALID_DAC_CONTROL_TABLE_A = -4045;            //  "SCM: invalid DAC control table A"
    public const int SEPIA2_ERR_SCM_INVALID_DAC_CONTROL_TABLE_B = -4046;            //  "SCM: invalid DAC control table B"
    public const int SEPIA2_ERR_SCM_TEMPERATURE_TABLE_READ_FAILED = -4047;            //  "SCM: temperature table read failed"

    public const int SEPIA2_ERR_SOM_INT_OSCILLATOR_S_FREQ_LIST_NOT_FOUND = -5001;       //  "SOM: int. oscillator's freq.-list not found"
    public const int SEPIA2_ERR_SOM_TRIGGER_MODE_LIST_NOT_FOUND = -5002;            //  "SOM: trigger mode list not found"
    public const int SEPIA2_ERR_SOM_TRIGGER_LEVEL_NOT_FOUND = -5003;              //  "SOM: trigger level not found"
    public const int SEPIA2_ERR_SOM_PREDIVIDER_PRETRIGGER_OR_TRIGGERMASK_NOT_FOUND = -5004;   //  "SOM: predivider, pretrigger or triggermask not found"
    public const int SEPIA2_ERR_SOM_BURSTLENGTH_NOT_FOUND = -5005;                //  "SOM: burstlength not found"
    public const int SEPIA2_ERR_SOM_OUTPUT_AND_SYNC_ENABLE_NOT_FOUND = -5006;         //  "SOM: output and sync enable not found"
    public const int SEPIA2_ERR_SOM_TRIGGER_LEVEL_OUT_OF_BOUNDS = -5007;            //  "SOM: trigger level out of bounds"
    public const int SEPIA2_ERR_SOM_ILLEGAL_FREQUENCY_TRIGGERMODE = -5008;            //  "SOM: illegal frequency / triggermode"
    public const int SEPIA2_ERR_SOM_ILLEGAL_FREQUENCY_DIVIDER = -5009;              //  "SOM: illegal frequency divider"
    public const int SEPIA2_ERR_SOM_ILLEGAL_PRESYNC = -5010;                  //  "SOM: illegal presync (greater than divider)"
    public const int SEPIA2_ERR_SOM_ILLEGAL_BURST_LENGTH = -5011;               //  "SOM: illegal burst length (>/= 2^24 or < 0)"
    public const int SEPIA2_ERR_SOM_AUX_IO_CTRL_NOT_FOUND = -5012;                //  "SOM: AUX I/O control data not found"
    public const int SEPIA2_ERR_SOM_ILLEGAL_AUX_OUT_CTRL = -5013;               //  "SOM: illegal AUX output control data"
    public const int SEPIA2_ERR_SOM_ILLEGAL_AUX_IN_CTRL = -5014;                //  "SOM: illegal AUX input control data"
    public const int SEPIA2_ERR_SOMD_INT_OSCILLATOR_S_FREQ_LIST_NOT_FOUND = -5051;        //  "SOMD: int. oscillator's freq.-list not found"
    public const int SEPIA2_ERR_SOMD_TRIGGER_MODE_LIST_NOT_FOUND = -5052;           //  "SOMD: trigger mode list not found"
    public const int SEPIA2_ERR_SOMD_TRIGGER_LEVEL_NOT_FOUND = -5053;             //  "SOMD: trigger level not found"
    public const int SEPIA2_ERR_SOMD_PREDIVIDER_PRETRIGGER_OR_TRIGGERMASK_NOT_FOUND = -5054;  //  "SOMD: predivider, pretrigger or triggermask not found"
    public const int SEPIA2_ERR_SOMD_BURSTLENGTH_NOT_FOUND = -5055;               //  "SOMD: burstlength not found"
    public const int SEPIA2_ERR_SOMD_OUTPUT_AND_SYNC_ENABLE_NOT_FOUND = -5056;          //  "SOMD: output and sync enable not found"
    public const int SEPIA2_ERR_SOMD_TRIGGER_LEVEL_OUT_OF_BOUNDS = -5057;           //  "SOMD: trigger level out of bounds"
    public const int SEPIA2_ERR_SOMD_ILLEGAL_FREQUENCY_TRIGGERMODE = -5058;           //  "SOMD: illegal frequency / triggermode"
    public const int SEPIA2_ERR_SOMD_ILLEGAL_FREQUENCY_DIVIDER = -5059;             //  "SOMD: illegal frequency divider"
    public const int SEPIA2_ERR_SOMD_ILLEGAL_PRESYNC = -5060;                 //  "SOMD: illegal presync (greater than divider)"
    public const int SEPIA2_ERR_SOMD_ILLEGAL_BURST_LENGTH = -5061;                //  "SOMD: illegal burst length (>/= 2^24 or < 0)"
    public const int SEPIA2_ERR_SOMD_AUX_IO_CTRL_NOT_FOUND = -5062;               //  "SOMD: AUX I/O control data not found"
    public const int SEPIA2_ERR_SOMD_ILLEGAL_AUX_OUT_CTRL = -5063;                //  "SOMD: illegal AUX output control data"
    public const int SEPIA2_ERR_SOMD_ILLEGAL_AUX_IN_CTRL = -5064;               //  "SOMD: illegal AUX input control data"
    public const int SEPIA2_ERR_SOMD_ILLEGAL_OUT_MUX_CTRL = -5071;                //  "SOMD: illegal output multiplexer control data"
    public const int SEPIA2_ERR_SOMD_OUTPUT_DELAY_DATA_NOT_FOUND = -5072;           //  "SOMD: output delay data not found"
    public const int SEPIA2_ERR_SOMD_ILLEGAL_OUTPUT_DELAY_DATA = -5073;             //  "SOMD: illegal output delay data"
    public const int SEPIA2_ERR_SOMD_DELAY_NOT_ALLOWED_IN_TRIGGER_MODE = -5074;         //  "SOMD: delay not allowed in current trigger mode"
    public const int SEPIA2_ERR_SOMD_DEVICE_INITIALIZING = -5075;               //  "SOMD: device initializing"
    public const int SEPIA2_ERR_SOMD_DEVICE_BUSY = -5076;                   //  "SOMD: device busy"
    public const int SEPIA2_ERR_SOMD_PLL_NOT_LOCKED = -5077;                  //  "SOMD: PLL not locked"
    public const int SEPIA2_ERR_SOMD_FW_UPDATE_FAILED = -5080;                  //  "SOMD: firmware update failed"
    public const int SEPIA2_ERR_SOMD_FW_CRC_CHECK_FAILED = -5081;               //  "SOMD: firmware CRC check failed"
    public const int SEPIA2_ERR_SOMD_HW_TRIGGERSOURCE_ERROR = -5101;              //  "SOMD HW: triggersource error"
    public const int SEPIA2_ERR_SOMD_HW_SYCHRONIZE_NOW_ERROR = -5102;             //  "SOMD HW: sychronize now error"
    public const int SEPIA2_ERR_SOMD_HW_SYNC_RANGE_ERROR = -5103;               //  "SOMD HW: SYNC range error"
    public const int SEPIA2_ERR_SOMD_HW_ILLEGAL_OUT_MUX_CTRL = -5104;             //  "SOMD HW: illegal output multiplexer control data"
    public const int SEPIA2_ERR_SOMD_HW_SET_DELAY_ERROR = -5105;                //  "SOMD HW: set delay error"
    public const int SEPIA2_ERR_SOMD_HW_AUX_IO_COMMAND_ERROR = -5106;             //  "SOMD HW: AUX I/O command error"
    public const int SEPIA2_ERR_SOMD_HW_PLL_NOT_STABLE = -5107;                 //  "SOMD HW: PLL not stable"
    public const int SEPIA2_ERR_SOMD_HW_BURST_LENGTH_ERROR = -5108;               //  "SOMD HW: burst length error"
    public const int SEPIA2_ERR_SOMD_HW_OUT_MUX_COMMAND_ERROR = -5109;              //  "SOMD HW: output multiplexer command error"
    public const int SEPIA2_ERR_SOMD_HW_COARSE_DELAY_SET_ERROR = -5110;             //  "SOMD HW: coarse delay set error"
    public const int SEPIA2_ERR_SOMD_HW_FINE_DELAY_SET_ERROR = -5111;             //  "SOMD HW: fine delay set error"
    public const int SEPIA2_ERR_SOMD_HW_FW_EPROM_ERROR = -5112;                 //  "SOMD HW: firmware EPROM error"
    public const int SEPIA2_ERR_SOMD_HW_CRC_ERROR_ON_WRITING_FIRMWARE = -5113;          //  "SOMD HW: CRC error on writing firmware"
    public const int SEPIA2_ERR_SOMD_HW_CALIBRATION_DATA_NOT_FOUND = -5114;           //  "SOMD HW: calibration data not found"
    public const int SEPIA2_ERR_SOMD_HW_WRONG_EXTERNAL_FREQUENCY = -5115;           //  "SOMD HW: wrong external frequency"
    public const int SEPIA2_ERR_SOMD_HW_EXTERNAL_FREQUENCY_NOT_STABLE = -5116;          //  "SOMD HW: external frequency not stable"

    public const int SEPIA2_ERR_SLM_ILLEGAL_FREQUENCY_TRIGGERMODE = -6001;            //  "SLM: illegal frequency / triggermode"
    public const int SEPIA2_ERR_SLM_ILLEGAL_INTENSITY = -6002;                  //  "SLM: illegal intensity (> 100% or < 0%)"
    public const int SEPIA2_ERR_SLM_ILLEGAL_HEAD_TYPE = -6003;                  //  "SLM: illegal head type"
    public const int SEPIA2_ERR_SML_ILLEGAL_INTENSITY = -6501;                  //  "SML: illegal intensity (> 100% or < 0%)"
    public const int SEPIA2_ERR_SML_POWER_SCALE_TABLES_NOT_FOUND = -6502;           //  "SML: power scale tables not found"
    public const int SEPIA2_ERR_SML_ILLEGAL_HEAD_TYPE = -6503;                  //  "SML: illegal head type"
    public const int SEPIA2_ERR_VUV_VIR_SCALING_TABLES_NOT_FOUND = -6511;           //  "VUV/VIR: scaling tables not found"
    public const int SEPIA2_ERR_VUV_VIR_DEVICE_TYPE_NOT_FOUND = -6512;              //  "VUV/VIR: device type not found"
    public const int SEPIA2_ERR_VUV_VIR_ILLEGAL_TRIGGER_SOURCE_INDEX = -6513;         //  "VUV/VIR: illegal trigger source index"
    public const int SEPIA2_ERR_VUV_VIR_ILLEGAL_FREQUENCY_DIVIDER_INDEX = -6514;        //  "VUV/VIR: illegal frequency divider index"
    public const int SEPIA2_ERR_VUV_VIR_ILLEGAL_TRIGGER_LEVEL_VALUE = -6515;          //  "VUV/VIR: illegal trigger level value"
    public const int SEPIA2_ERR_VUV_VIR_TRIGGER_DATA_NOT_FOUND = -6516;             //  "VUV/VIR: trigger data not found"
    public const int SEPIA2_ERR_VUV_VIR_ILLEGAL_PUMP_REGISTER_READ_INDEX = -6517;       //  "VUV/VIR: illegal pump register read index"
    public const int SEPIA2_ERR_VUV_VIR_ILLEGAL_PUMP_REGISTER_WRITE_INDEX = -6518;        //  "VUV/VIR: illegal pump register write index"
    public const int SEPIA2_ERR_VUV_VIR_INTENSITY_DATA_NOT_FOUND = -6519;           //  "VUV/VIR: intensity data not found"
    public const int SEPIA2_ERR_VUV_VIR_ILLEGAL_INTENSITY_DATA = -6520;             //  "VUV/VIR: illegal intensity data"
    public const int SEPIA2_ERR_VUV_VIR_UNSUPPORTED_OPTION = -6521;               //  "VUV/VIR: unsupported option"
    public const int SEPIA2_ERR_PRI_UI_CONSTANTS_TABLES_NOT_FOUND = -6531;                //  "PRI: UI-constants tables not found"
    public const int SEPIA2_ERR_PRI_WAVELENGTHS_TABLE_NOT_FOUND = -6532;                //  "PRI: wavelengths table not found"
    public const int SEPIA2_ERR_PRI_ILLEGAL_WAVELENGTH_INDEX = -6533;                //  "PRI: illegal wavelength index"
    public const int SEPIA2_ERR_PRI_ERROR_ON_WRITING_WAVELENGTH_INDEX = -6534;                //  "PRI: error on writing wavelength index"
    public const int SEPIA2_ERR_PRI_OPERATION_MODE_TEXTS_NOT_FOUND = -6535;                //  "PRI: operation mode texts not found"
    public const int SEPIA2_ERR_PRI_OPERATION_MODE_COMMANDS_NOT_FOUND = -6536;                //  "PRI: operation mode commands not found"
    public const int SEPIA2_ERR_PRI_ILLEGAL_OPERATION_MODE_INDEX = -6537;                //  "PRI: illegal operation mode index"
    public const int SEPIA2_ERR_PRI_ERROR_ON_WRITING_OPERATION_MODE_INDEX = -6538;                //  "PRI: error on writing operation mode index"
    public const int SEPIA2_ERR_PRI_TRIGGER_SOURCE_TEXTS_NOT_FOUND = -6539;                //  "PRI: trigger source texts not found"
    public const int SEPIA2_ERR_PRI_TRIGGER_SOURCE_COMMANDS_NOT_FOUND = -6540;                //  "PRI: trigger source commands not found"
    public const int SEPIA2_ERR_PRI_ILLEGAL_TRIGGER_SOURCE_INDEX = -6541;                //  "PRI: illegal trigger source index"
    public const int SEPIA2_ERR_PRI_ERROR_ON_WRITING_TRIGGER_SOURCE_INDEX = -6542;                //  "PRI: error on writing trigger source index"
    public const int SEPIA2_ERR_PRI_ILLEGAL_TRIGGER_LEVEL = -6543;                //  "PRI: illegal trigger level"
    public const int SEPIA2_ERR_PRI_ERROR_ON_WRITING_TRIGGER_LEVEL = -6544;                //  "PRI: error on writing trigger level"
    public const int SEPIA2_ERR_PRI_ILLEGAL_INTENSITY_DATA = -6545;                //  "PRI: illegal intensity data"
    public const int SEPIA2_ERR_PRI_ERROR_ON_WRITING_INTENSITY_DATA = -6546;                //  "PRI: error on writing intensity data"
    public const int SEPIA2_ERR_PRI_ILLEGAL_FREQUENCY_DATA = -6547;                //  "PRI: illegal frequency data"
    public const int SEPIA2_ERR_PRI_ERROR_ON_WRITING_FREQUENCY_DATA = -6548;                //  "PRI: error on writing frequency data"
    public const int SEPIA2_ERR_PRI_ILLEGAL_GATING_DATA = -6549;                //  "PRI: illegal gating data"
    public const int SEPIA2_ERR_PRI_ERROR_ON_WRITING_GATING_DATA = -6550;                //  "PRI: error on writing gating data"
    public const int SEPIA2_ERR_SWM_CALTABLES_NOT_FOUND = -6701;                //  "SWM: calibration tables not found"
    public const int SEPIA2_ERR_SWM_ILLEGAL_CURVE_INDEX = -6702;                //  "SWM: illegal curve index"
    public const int SEPIA2_ERR_SWM_ILLEGAL_TIMEBASE_RANGE_INDEX = -6703;           //  "SWM: illegal timebase range index"
    public const int SEPIA2_ERR_SWM_ILLEGAL_PULSE_AMPLITUDE = -6704;              //  "SWM: illegal pulse amplitude"
    public const int SEPIA2_ERR_SWM_ILLEGAL_RAMP_SLEW_RATE = -6705;               //  "SWM: illegal ramp slew rate"
    public const int SEPIA2_ERR_SWM_ILLEGAL_PULSE_START_DELAY = -6706;              //  "SWM: illegal pulse start delay"
    public const int SEPIA2_ERR_SWM_ILLEGAL_RAMP_START_DELAY = -6707;             //  "SWM: illegal ramp start delay"
    public const int SEPIA2_ERR_SWM_ILLEGAL_WAVE_STOP_DELAY = -6708;              //  "SWM: illegal wave stop delay"
    public const int SEPIA2_ERR_SWM_ILLEGAL_TABLENAME = -6709;                  //  "SWM: illegal tablename"
    public const int SEPIA2_ERR_SWM_ILLEGAL_TABLE_INDEX = -6710;                //  "SWM: illegal table index"
    public const int SEPIA2_ERR_SWM_ILLEGAL_TABLE_FIELD = -6711;                //  "SWM: illegal table field"
    public const int SEPIA2_ERR_SWM_EXT_ATTENUATION_NOT_FOUND = -6712;              //  "SWM: ext. attenuation not found"
    public const int SEPIA2_ERR_SWM_ILLEGAL_ATTENUATION_VALUE = -6713;              //  "SWM: illegal attenuation value"
    public const int SEPIA2_ERR_VCL_UI_CONSTANTS_NOT_FOUND = -6751;               //  "VCL: UI-constants not found"
    public const int SEPIA2_ERR_VCL_TEMPERATURE_CALTABLE_NOT_FOUND = -6752;           //  "VCL: temperature calibration table not found"
    public const int SEPIA2_ERR_VCL_BIAS_VOLTAGE_CALTABLE_NOT_FOUND = -6753;          //  "VCL: bias voltage calibration table not found"
    public const int SEPIA2_ERR_VCL_ILLEGAL_TEMPERATURE = -6754;                //  "VCL: illegal temperature"
    public const int SEPIA2_ERR_VCL_ILLEGAL_BIAS_VOLTAGE = -6755;               //  "VCL: illegal bias voltage"

    public const int SEPIA2_ERR_SPM_ILLEGAL_INPUT_VALUE = -7001;                //  "SPM: illegal input value"
    public const int SEPIA2_ERR_SPM_VALUE_OUT_OF_BOUNDS = -7006;                //  "SPM: value out of bounds"
    public const int SEPIA2_ERR_SPM_FW_OUT_OF_MEMORY = -7011;                 //  "SPM FW: out of memory"
    public const int SEPIA2_ERR_SPM_FW_UPDATE_FAILED = -7013;                 //  "SPM FW: update failed"
    public const int SEPIA2_ERR_SPM_FW_CRC_CHECK_FAILED = -7014;                //  "SPM FW: CRC check failed"
    public const int SEPIA2_ERR_SPM_FW_FLASH_DELETION_FAILED = -7015;             //  "SPM FW: flash deletion failed"
    public const int SEPIA2_ERR_SPM_FW_FUNCTION_NOT_IMPLEMENTED = -7017;            //  "SPM FW: function not implemented"
    public const int SEPIA2_ERR_SPM_FW_FILE_OPEN_ERROR = -7021;                 //  "SPM FW: file open error"
    public const int SEPIA2_ERR_SPM_FW_FILE_READ_ERROR = -7022;                 //  "SPM FW: file read error"
    public const int SEPIA2_ERR_SSM_SCALING_TABLES_NOT_FOUND = -7051;             //  "SSM: scaling tables not found"
    public const int SEPIA2_ERR_SSM_ILLEGAL_TRIGGER_MODE = -7052;               //  "SSM: illegal trigger mode"
    public const int SEPIA2_ERR_SSM_ILLEGAL_TRIGGER_LEVEL_VALUE = -7053;            //  "SSM: illegal trigger level value"
    public const int SEPIA2_ERR_SSM_ILLEGAL_CORRECTION_VALUE = -7054;             //  "SSM: illegal correction value"
    public const int SEPIA2_ERR_SSM_TRIGGER_DATA_NOT_FOUND = -7055;               //  "SSM: trigger data not found"
    public const int SEPIA2_ERR_SSM_CORRECTION_DATA_COMMAND_NOT_FOUND = -7056;          //  "SSM: correction data command not found"
    public const int SEPIA2_ERR_SWS_SCALING_TABLES_NOT_FOUND = -7101;             //  "SWS: scaling tables not found"
    public const int SEPIA2_ERR_SWS_ILLEGAL_HW_MODULETYPE = -7102;                //  "SWS: illegal HW moduletype"
    public const int SEPIA2_ERR_SWS_MODULE_NOT_FUNCTIONAL = -7103;                //  "SWS: module not functional"
    public const int SEPIA2_ERR_SWS_ILLEGAL_CENTER_WAVELENGTH = -7104;              //  "SWS: illegal center wavelength"
    public const int SEPIA2_ERR_SWS_ILLEGAL_BANDWIDTH = -7105;                  //  "SWS: illegal bandwidth"
    public const int SEPIA2_ERR_SWS_VALUE_OUT_OF_BOUNDS = -7106;                //  "SWS: value out of bounds"
    public const int SEPIA2_ERR_SWS_MODULE_BUSY = -7107;                    //  "SWS: module busy"
    public const int SEPIA2_ERR_SWS_FW_WRONG_COMPONENT_ANSWERING = -7109;           //  "SWS FW: wrong component answering"
    public const int SEPIA2_ERR_SWS_FW_UNKNOWN_HW_MODULETYPE = -7110;             //  "SWS FW: unknown HW moduletype"
    public const int SEPIA2_ERR_SWS_FW_OUT_OF_MEMORY = -7111;                 //  "SWS FW: out of memory"
    public const int SEPIA2_ERR_SWS_FW_VERSION_CONFLICT = -7112;                //  "SWS FW: version conflict"
    public const int SEPIA2_ERR_SWS_FW_UPDATE_FAILED = -7113;                 //  "SWS FW: update failed"
    public const int SEPIA2_ERR_SWS_FW_CRC_CHECK_FAILED = -7114;                //  "SWS FW: CRC check failed"
    public const int SEPIA2_ERR_SWS_FW_ERROR_ON_FLASH_DELETION = -7115;             //  "SWS FW: error on flash deletion"
    public const int SEPIA2_ERR_SWS_FW_CALIBRATION_MODE_ERROR = -7116;              //  "SWS FW: calibration mode error"
    public const int SEPIA2_ERR_SWS_FW_FUNCTION_NOT_IMPLEMENTED = -7117;            //  "SWS FW: function not implemented"
    public const int SEPIA2_ERR_SWS_FW_WRONG_CALTABLE_ENTRY = -7118;              //  "SWS FW: wrong calibration table entry"
    public const int SEPIA2_ERR_SWS_FW_INSUFFICIENT_CALTABLE_SIZE = -7119;            //  "SWS FW: insufficient calibration table size"
    public const int SEPIA2_ERR_SWS_FW_FILE_OPEN_ERROR = -7151;                 //  "SWS FW: file open error"
    public const int SEPIA2_ERR_SWS_FW_FILE_READ_ERROR = -7152;                 //  "SWS FW: file read error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_INIT_TIMEOUT = -7201;        //  "SWS HW: module 0, all motors: init timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_PLAUSI_CHECK = -7202;        //  "SWS HW: module 0, all motors: plausi check"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_DAC_SET_CURRENT = -7203;       //  "SWS HW: module 0, all motors: DAC set current"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_TIMEOUT = -7204;  //  "SWS HW: module 0, all motors: timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_FLASH_WRITE_ERROR = -7205;  //  "SWS HW: module 0, all motors: flash write error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_OUT_OF_BOUNDS = -7206;  //  "SWS HW: module 0, all motors: out of bounds"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_I2C_FAILURE = -7207;  //  "SWS HW: module 0: I2C failure"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_INIT_FAILURE = -7208;  //  "SWS HW: module 0: init failure"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_DATA_NOT_FOUND = -7210;  //  "SWS HW: module 0, motor 1: data not found"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_INIT_TIMEOUT = -7211;  //  "SWS HW: module 0, motor 1: init timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_PLAUSI_CHECK = -7212;  //  "SWS HW: module 0, motor 1: plausi check"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_DAC_SET_CURRENT = -7213;  //  "SWS HW: module 0, motor 1: DAC set current"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_TIMEOUT = -7214;  //  "SWS HW: module 0, motor 1: timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_FLASH_WRITE_ERROR = -7215;  //  "SWS HW: module 0, motor 1: flash write error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_OUT_OF_BOUNDS = -7216;  //  "SWS HW: module 0, motor 1: out of bounds"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_DATA_NOT_FOUND = -7220;  //  "SWS HW: module 0, motor 2: data not found"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_INIT_TIMEOUT = -7221;  //  "SWS HW: module 0, motor 2: init timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_PLAUSI_CHECK = -7222;  //  "SWS HW: module 0, motor 2: plausi check"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_DAC_SET_CURRENT = -7223;  //  "SWS HW: module 0, motor 2: DAC set current"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_TIMEOUT = -7224;  //  "SWS HW: module 0, motor 2: timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_FLASH_WRITE_ERROR = -7225;  //  "SWS HW: module 0, motor 2: flash write error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_OUT_OF_BOUNDS = -7226;  //  "SWS HW: module 0, motor 2: out of bounds"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_DATA_NOT_FOUND = -7230;  //  "SWS HW: module 0, motor 3: data not found"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_INIT_TIMEOUT = -7231;  //  "SWS HW: module 0, motor 3: init timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_PLAUSI_CHECK = -7232;  //  "SWS HW: module 0, motor 3: plausi check"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_DAC_SET_CURRENT = -7233;  //  "SWS HW: module 0, motor 3: DAC set current"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_TIMEOUT = -7234;  //  "SWS HW: module 0, motor 3: timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_FLASH_WRITE_ERROR = -7235;  //  "SWS HW: module 0, motor 3: flash write error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_OUT_OF_BOUNDS = -7236;  //  "SWS HW: module 0, motor 3: out of bounds"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_INIT_TIMEOUT = -7301;  //  "SWS HW: module 1, all motors: init timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_PLAUSI_CHECK = -7302;  //  "SWS HW: module 1, all motors: plausi check"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_DAC_SET_CURRENT = -7303;  //  "SWS HW: module 1, all motors: DAC set current"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_TIMEOUT = -7304;  //  "SWS HW: module 1, all motors: timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_FLASH_WRITE_ERROR = -7305;  //  "SWS HW: module 1, all motors: flash write error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_OUT_OF_BOUNDS = -7306;  //  "SWS HW: module 1, all motors: out of bounds"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_I2C_FAILURE = -7307;  //  "SWS HW: module 1: I2C failure"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_INIT_FAILURE = -7308;  //  "SWS HW: module 1: init failure"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_DATA_NOT_FOUND = -7310;  //  "SWS HW: module 1, motor 1: data not found"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_INIT_TIMEOUT = -7311;  //  "SWS HW: module 1, motor 1: init timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_PLAUSI_CHECK = -7312;  //  "SWS HW: module 1, motor 1: plausi check"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_DAC_SET_CURRENT = -7313;  //  "SWS HW: module 1, motor 1: DAC set current"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_TIMEOUT = -7314;  //  "SWS HW: module 1, motor 1: timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_FLASH_WRITE_ERROR = -7315;  //  "SWS HW: module 1, motor 1: flash write error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_OUT_OF_BOUNDS = -7316;  //  "SWS HW: module 1, motor 1: out of bounds"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_DATA_NOT_FOUND = -7320;  //  "SWS HW: module 1, motor 2: data not found"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_INIT_TIMEOUT = -7321;  //  "SWS HW: module 1, motor 2: init timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_PLAUSI_CHECK = -7322;  //  "SWS HW: module 1, motor 2: plausi check"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_DAC_SET_CURRENT = -7323;  //  "SWS HW: module 1, motor 2: DAC set current"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_TIMEOUT = -7324;  //  "SWS HW: module 1, motor 2: timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_FLASH_WRITE_ERROR = -7325;  //  "SWS HW: module 1, motor 2: flash write error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_OUT_OF_BOUNDS = -7326;  //  "SWS HW: module 1, motor 2: out of bounds"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_DATA_NOT_FOUND = -7330;  //  "SWS HW: module 1, motor 3: data not found"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_INIT_TIMEOUT = -7331;  //  "SWS HW: module 1, motor 3: init timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_PLAUSI_CHECK = -7332;  //  "SWS HW: module 1, motor 3: plausi check"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_DAC_SET_CURRENT = -7333;  //  "SWS HW: module 1, motor 3: DAC set current"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_TIMEOUT = -7334;  //  "SWS HW: module 1, motor 3: timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_FLASH_WRITE_ERROR = -7335;  //  "SWS HW: module 1, motor 3: flash write error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_OUT_OF_BOUNDS = -7336;  //  "SWS HW: module 1, motor 3: out of bounds"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_INIT_TIMEOUT = -7401;  //  "SWS HW: module 2, all motors: init timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_PLAUSI_CHECK = -7402;  //  "SWS HW: module 2, all motors: plausi check"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_DAC_SET_CURRENT = -7403;  //  "SWS HW: module 2, all motors: DAC set current"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_TIMEOUT = -7404;  //  "SWS HW: module 2, all motors: timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_FLASH_WRITE_ERROR = -7405;  //  "SWS HW: module 2, all motors: flash write error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_OUT_OF_BOUNDS = -7406;  //  "SWS HW: module 2, all motors: out of bounds"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_I2C_FAILURE = -7407;  //  "SWS HW: module 2: I2C failure"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_INIT_FAILURE = -7408;  //  "SWS HW: module 2: init failure"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_DATA_NOT_FOUND = -7410;  //  "SWS HW: module 2, motor 1: data not found"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_INIT_TIMEOUT = -7411;  //  "SWS HW: module 2, motor 1: init timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_PLAUSI_CHECK = -7412;  //  "SWS HW: module 2, motor 1: plausi check"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_DAC_SET_CURRENT = -7413;  //  "SWS HW: module 2, motor 1: DAC set current"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_TIMEOUT = -7414;  //  "SWS HW: module 2, motor 1: timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_FLASH_WRITE_ERROR = -7415;  //  "SWS HW: module 2, motor 1: flash write error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_OUT_OF_BOUNDS = -7416;  //  "SWS HW: module 2, motor 1: out of bounds"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_DATA_NOT_FOUND = -7420;  //  "SWS HW: module 2, motor 2: data not found"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_INIT_TIMEOUT = -7421;  //  "SWS HW: module 2, motor 2: init timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_PLAUSI_CHECK = -7422;  //  "SWS HW: module 2, motor 2: plausi check"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_DAC_SET_CURRENT = -7423;  //  "SWS HW: module 2, motor 2: DAC set current"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_TIMEOUT = -7424;  //  "SWS HW: module 2, motor 2: timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_FLASH_WRITE_ERROR = -7425;  //  "SWS HW: module 2, motor 2: flash write error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_OUT_OF_BOUNDS = -7426;  //  "SWS HW: module 2, motor 2: out of bounds"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_DATA_NOT_FOUND = -7430;  //  "SWS HW: module 2, motor 3: data not found"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_INIT_TIMEOUT = -7431;  //  "SWS HW: module 2, motor 3: init timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_PLAUSI_CHECK = -7432;  //  "SWS HW: module 2, motor 3: plausi check"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_DAC_SET_CURRENT = -7433;  //  "SWS HW: module 2, motor 3: DAC set current"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_TIMEOUT = -7434;  //  "SWS HW: module 2, motor 3: timeout"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_FLASH_WRITE_ERROR = -7435;  //  "SWS HW: module 2, motor 3: flash write error"
    public const int SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_OUT_OF_BOUNDS = -7436;  //  "SWS HW: module 2, motor 3: out of bounds"

    public const int SEPIA2_ERR_LIB_TOO_MANY_USB_HANDLES = -9001;  //  "LIB: too many USB handles"
    public const int SEPIA2_ERR_LIB_ILLEGAL_DEVICE_INDEX = -9002;  //  "LIB: illegal device index"
    public const int SEPIA2_ERR_LIB_USB_DEVICE_OPEN_ERROR = -9003;  //  "LIB: USB device open error"
    public const int SEPIA2_ERR_LIB_USB_DEVICE_BUSY_OR_BLOCKED = -9004;  //  "LIB: USB device busy or blocked"
    public const int SEPIA2_ERR_LIB_USB_DEVICE_ALREADY_OPENED = -9005;  //  "LIB: USB device already opened"
    public const int SEPIA2_ERR_LIB_UNKNOWN_USB_HANDLE = -9006;  //  "LIB: unknown USB handle"
    public const int SEPIA2_ERR_LIB_SCM_828_MODULE_NOT_FOUND = -9007;  //  "LIB: SCM 828 module not found"
    public const int SEPIA2_ERR_LIB_ILLEGAL_SLOT_NUMBER = -9008;  //  "LIB: illegal slot number"
    public const int SEPIA2_ERR_LIB_REFERENCED_SLOT_IS_NOT_IN_USE = -9009;  //  "LIB: referenced slot is not in use"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_SCM_828_MODULE = -9010;  //  "LIB: this is no SCM 828 module"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_MODULE = -9011;  //  "LIB: this is no SOM 828 module"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_SLM_828_MODULE = -9012;  //  "LIB: this is no SLM 828 module"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_SML_828_MODULE = -9013;  //  "LIB: this is no SML 828 module"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_SWM_828_MODULE = -9014;  //  "LIB: this is no SWM 828 module"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_SSM_MODULE = -9015;  //  "LIB: this is no SSM module"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_SWS_MODULE = -9016;  //  "LIB: this is no SWS module"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_SPM_MODULE = -9017;  //  "LIB: this is no SPM module"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_LMP1 = -9018;  //  "LIB: this is no LMP1 (metermodule w. shuttercontrol)"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_D_MODULE = -9019;  //  "LIB: this is no SOM 828 D module"
    public const int SEPIA2_ERR_LIB_NO_MAP_FOUND = -9020;  //  "LIB: no map found"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_LMP8 = -9021;  //  "LIB: this is no LMP8 (eightfold metermodule)"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_VCL_828_MODULE = -9022;  //  "LIB: this is no VCL 828 module"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_VUV_NOR_VIR_MODULE = -9023;  //  "LIB: this is no VUV nor VIR module"
    public const int SEPIA2_ERR_LIB_THIS_IS_NO_PRI_MODULE =-9024;  //  "LIB: this is no PRI module"
    public const int SEPIA2_ERR_LIB_DEVICE_CHANGED_RE_INITIALISE_USB_DEVICE_LIST = -9025;  //  "LIB: device changed, re-initialise USB device list"
    public const int SEPIA2_ERR_LIB_INAPPROPRIATE_USB_DEVICE = -9026;  //  "LIB: inappropriate USB device"
    public const int SEPIA2_ERR_LIB_WRONG_USB_DRIVER_VERSION = -9090;  //  "LIB: wrong USB driver version"
    public const int SEPIA2_ERR_LIB_UNKNOWN_FUNCTION = -9900;  //  "LIB: unknown function"
    public const int SEPIA2_ERR_LIB_ILLEGAL_PARAMETER_ON_FUNCTION_CALL = -9910;  //  "LIB: illegal parameter on function call"
    public const int SEPIA2_ERR_LIB_UNKNOWN_ERROR_CODE = -9999;                 //  "LIB: unknown error code"



    #endregion Constants are from 'Sepia2_Error_Codes.h'


  }
}
