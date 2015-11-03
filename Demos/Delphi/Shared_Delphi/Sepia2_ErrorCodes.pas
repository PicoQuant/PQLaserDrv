//-----------------------------------------------------------------------------
//
//      Sepia2_ErrorCodes.pas
//
//-----------------------------------------------------------------------------
//
//  Exports the official list of error codes for Sepia2_lib V1.1.xx.450
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
//  apo  12.02.07   introduced SML multilaser module (V1.0.2.0)
//
//  apo  02.12.09   introduced PPL400 SWM waveform module (V1.0.2.1)
//
//  apo  19.04.10   incorporated into EasyTau-SW   (V1.0.2.0)
//
//  apo  04.02.11   incorporated into Submarine-SW (V1.0.2.0)
//
//  apo  16.08.12   introduced Solea SWS wavelength selector module (V1.0.3.x)
//
//  apo  12.10.12   introduced Solea SSM seedlaser module (V1.0.3.x)
//
//  apo  21.01.13   introduced new USB error values (as created by MW)
//
//  apo  12.06.13   introduced Solea SPM pumpcontrol module (V1.0.3.x)
//
//  apo  03.01.14   additional error codes for Solea SWS module (V1.0.3.x)
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
//-----------------------------------------------------------------------------
//

unit Sepia2_ErrorCodes;

interface

  const
      
    SEPIA2_ERR_NO_ERROR                                                     =      0;  //  "no error"

    SEPIA2_ERR_FW_MEMORY_ALLOCATION_ERROR                                   =  -1001;  //  "FW: memory allocation error"
    SEPIA2_ERR_FW_CRC_ERROR_WHILE_CHECKING_SCM_828_MODULE                   =  -1002;  //  "FW: CRC error while checking SCM 828 module"
    SEPIA2_ERR_FW_CRC_ERROR_WHILE_CHECKING_BACKPLANE                        =  -1003;  //  "FW: CRC error while checking backplane"
    SEPIA2_ERR_FW_CRC_ERROR_WHILE_CHECKING_MODULE                           =  -1004;  //  "FW: CRC error while checking module"
    SEPIA2_ERR_FW_MAPSIZE_ERROR                                             =  -1005;  //  "FW: mapsize error"
    SEPIA2_ERR_FW_UNKNOWN_ERROR_PHASE                                       =  -1006;  //  "FW: unknown error phase"
    SEPIA2_ERR_FW_WRONG_WORKINGMODE                                         =  -1007;  //  "FW: wrong workingmode"
    SEPIA2_ERR_FW_ILLEGAL_MODULE_CHANGE                                     =  -1111;  //  "FW: illegal module change"

    SEPIA2_ERR_USB_WRONG_DRIVER_VERSION                                     =  -2001;  //  "USB: wrong driver version"
    SEPIA2_ERR_USB_OPEN_DEVICE_ERROR                                        =  -2002;  //  "USB: open device error"
    SEPIA2_ERR_USB_DEVICE_BUSY                                              =  -2003;  //  "USB: device busy"
    SEPIA2_ERR_USB_CLOSE_DEVICE_ERROR                                       =  -2005;  //  "USB: close device error"
    SEPIA2_ERR_USB_DEVICE_CHANGED                                           =  -2006;  //  "USB: device changed"
    SEPIA2_ERR_I2C_ADDRESS_ERROR                                            =  -2010;  //  "I2C: address error"
    SEPIA2_ERR_USB_DEVICE_INDEX_ERROR                                       =  -2011;  //  "USB: device index error"
    SEPIA2_ERR_I2C_ILLEGAL_MULTIPLEXER_PATH                                 =  -2012;  //  "I2C: illegal multiplexer path"
    SEPIA2_ERR_I2C_ILLEGAL_MULTIPLEXER_LEVEL                                =  -2013;  //  "I2C: illegal multiplexer level"
    SEPIA2_ERR_I2C_ILLEGAL_SLOT_ID                                          =  -2014;  //  "I2C: illegal slot id"
    SEPIA2_ERR_FRAM_NO_UPTIME_COUNTER                                       =  -2015;  //  "FRAM: no uptime counter"
    SEPIA2_ERR_FRAM_BLOCKWRITE_ERROR                                        =  -2020;  //  "FRAM: blockwrite error"
    SEPIA2_ERR_FRAM_BLOCKREAD_ERROR                                         =  -2021;  //  "FRAM: blockread error"
    SEPIA2_ERR_FRAM_CRC_BLOCKCHECK_ERROR                                    =  -2022;  //  "FRAM: CRC blockcheck error"
    SEPIA2_ERR_RAM_BLOCK_ALLOCATION_ERROR                                   =  -2023;  //  "RAM: block allocation error"
    SEPIA2_ERR_I2C_INITIALISING_COMMAND_EXECUTION_ERROR                     =  -2100;  //  "I2C: initialising command execution error"
    SEPIA2_ERR_I2C_FETCHING_INITIALISING_COMMANDS_ERROR                     =  -2101;  //  "I2C: fetching initialising commands error"
    SEPIA2_ERR_I2C_WRITING_INITIALISING_COMMANDS_ERROR                      =  -2102;  //  "I2C: writing initialising commands error"
    SEPIA2_ERR_I2C_MODULE_CALIBRATING_ERROR                                 =  -2200;  //  "I2C: module calibrating error"
    SEPIA2_ERR_I2C_FETCHING_CALIBRATING_COMMANDS_ERROR                      =  -2201;  //  "I2C: fetching calibrating commands error"
    SEPIA2_ERR_I2C_WRITING_CALIBRATING_COMMANDS_ERROR                       =  -2202;  //  "I2C: writing calibrating commands error"
    SEPIA2_ERR_DCL_FILE_OPEN_ERROR                                          =  -2301;  //  "DCL: file open error"
    SEPIA2_ERR_DCL_WRONG_FILE_LENGTH                                        =  -2302;  //  "DCL: wrong file length"
    SEPIA2_ERR_DCL_FILE_READ_ERROR                                          =  -2303;  //  "DCL: file read error"
    SEPIA2_ERR_FRAM_IS_WRITE_PROTECTED                                      =  -2304;  //  "FRAM: is write protected"
    SEPIA2_ERR_DCL_FILE_SPECIFIES_DIFFERENT_MODULETYPE                      =  -2305;  //  "DCL: file specifies different moduletype"
    SEPIA2_ERR_DCL_FILE_SPECIFIES_DIFFERENT_SERIAL_NUMBER                   =  -2306;  //  "DCL: file specifies different serial number"

    SEPIA2_ERR_I2C_INVALID_ARGUMENT                                         =  -3001;  //  "I2C: invalid argument"
    SEPIA2_ERR_I2C_NO_ACKNOWLEDGE_ON_WRITE_ADRESSBYTE                       =  -3002;  //  "I2C: no acknowledge on write adressbyte"
    SEPIA2_ERR_I2C_NO_ACKNOWLEDGE_ON_READ_ADRESSBYTE                        =  -3003;  //  "I2C: no acknowledge on read adressbyte"
    SEPIA2_ERR_I2C_NO_ACKNOWLEDGE_ON_WRITE_DATABYTE                         =  -3004;  //  "I2C: no acknowledge on write databyte"
    SEPIA2_ERR_I2C_READ_BACK_ERROR                                          =  -3005;  //  "I2C: read back error"
    SEPIA2_ERR_I2C_READ_ERROR                                               =  -3006;  //  "I2C: read error"
    SEPIA2_ERR_I2C_WRITE_ERROR                                              =  -3007;  //  "I2C: write error"
    SEPIA2_ERR_I_O_FILE_ERROR                                               =  -3009;  //  "I/O: file error"
    SEPIA2_ERR_I2C_MULTIPLEXER_ERROR                                        =  -3014;  //  "I2C: multiplexer error"
    SEPIA2_ERR_I2C_MULTIPLEXER_PATH_ERROR                                   =  -3015;  //  "I2C: multiplexer path error"
    SEPIA2_ERR_USB_INVALID_ARGUMENT                                         =  -3201;  //  "USB: invalid argument"
    SEPIA2_ERR_USB_DEVICE_STILL_OPEN                                        =  -3202;  //  "USB: device still open"
    SEPIA2_ERR_USB_NO_MEMORY                                                =  -3203;  //  "USB: no memory"
    SEPIA2_ERR_USB_OPEN_FAILED                                              =  -3204;  //  "USB: open failed"
    SEPIA2_ERR_USB_GET_DESCRIPTOR_FAILED                                    =  -3205;  //  "USB: get descriptor failed"
    SEPIA2_ERR_USB_INAPPROPRIATE_DEVICE                                     =  -3206;  //  "USB: inappropriate device"
    SEPIA2_ERR_USB_BUSY_DEVICE                                              =  -3207;  //  "USB: busy device"
    SEPIA2_ERR_USB_INVALID_HANDLE                                           =  -3208;  //  "USB: invalid handle"
    SEPIA2_ERR_USB_INVALID_DESCRIPTOR_BUFFER                                =  -3209;  //  "USB: invalid descriptor buffer"
    SEPIA2_ERR_USB_IOCTRL_FAILED                                            =  -3210;  //  "USB: IOCTRL failed"
    SEPIA2_ERR_USB_VCMD_FAILED                                              =  -3211;  //  "USB: vcmd failed"
    SEPIA2_ERR_USB_NO_SUCH_PIPE                                             =  -3212;  //  "USB: no such pipe"
    SEPIA2_ERR_USB_REGISTER_NOTIFICATION_FAILED                             =  -3213;  //  "USB: register notification failed"
    SEPIA2_ERR_I2C_DEVICE_ERROR                                             =  -3256;  //  "I2C: device error"
    SEPIA2_ERR_LMP1_ADC_TABLES_NOT_FOUND                                    =  -3501;  //  "LMP1: ADC tables not found"
    SEPIA2_ERR_LMP1_ADC_OVERFLOW                                            =  -3502;  //  "LMP1: ADC overflow"
    SEPIA2_ERR_LMP1_ADC_UNDERFLOW                                           =  -3503;  //  "LMP1: ADC underflow"

    SEPIA2_ERR_SCM_VOLTAGE_LIMITS_TABLE_NOT_FOUND                           =  -4001;  //  "SCM: voltage limits table not found"
    SEPIA2_ERR_SCM_VOLTAGE_SCALING_LIST_NOT_FOUND                           =  -4002;  //  "SCM: voltage scaling list not found"
    SEPIA2_ERR_SCM_REPEATEDLY_MEASURED_VOLTAGE_FAILURE                      =  -4003;  //  "SCM: repeatedly measured voltage failure"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_0_VOLTAGE_TOO_LOW                      =  -4010;  //  "SCM: power supply line 0: voltage too low"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_1_VOLTAGE_TOO_LOW                      =  -4011;  //  "SCM: power supply line 1: voltage too low"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_2_VOLTAGE_TOO_LOW                      =  -4012;  //  "SCM: power supply line 2: voltage too low"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_3_VOLTAGE_TOO_LOW                      =  -4013;  //  "SCM: power supply line 3: voltage too low"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_4_VOLTAGE_TOO_LOW                      =  -4014;  //  "SCM: power supply line 4: voltage too low"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_5_VOLTAGE_TOO_LOW                      =  -4015;  //  "SCM: power supply line 5: voltage too low"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_6_VOLTAGE_TOO_LOW                      =  -4016;  //  "SCM: power supply line 6: voltage too low"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_7_VOLTAGE_TOO_LOW                      =  -4017;  //  "SCM: power supply line 7: voltage too low"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_0_VOLTAGE_TOO_HIGH                     =  -4020;  //  "SCM: power supply line 0: voltage too high"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_1_VOLTAGE_TOO_HIGH                     =  -4021;  //  "SCM: power supply line 1: voltage too high"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_2_VOLTAGE_TOO_HIGH                     =  -4022;  //  "SCM: power supply line 2: voltage too high"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_3_VOLTAGE_TOO_HIGH                     =  -4023;  //  "SCM: power supply line 3: voltage too high"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_4_VOLTAGE_TOO_HIGH                     =  -4024;  //  "SCM: power supply line 4: voltage too high"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_5_VOLTAGE_TOO_HIGH                     =  -4025;  //  "SCM: power supply line 5: voltage too high"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_6_VOLTAGE_TOO_HIGH                     =  -4026;  //  "SCM: power supply line 6: voltage too high"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_7_VOLTAGE_TOO_HIGH                     =  -4027;  //  "SCM: power supply line 7: voltage too high"
    SEPIA2_ERR_SCM_POWER_SUPPLY_LASER_TURNING_OFF_VOLTAGE_TOO_HIGH          =  -4030;  //  "SCM: power supply laser turning-off-voltage too high"

    SEPIA2_ERR_SOM_INT_OSCILLATOR_S_FREQ_LIST_NOT_FOUND                     =  -5001;  //  "SOM: int. oscillator's freq.-list not found"
    SEPIA2_ERR_SOM_TRIGGER_MODE_LIST_NOT_FOUND                              =  -5002;  //  "SOM: trigger mode list not found"
    SEPIA2_ERR_SOM_TRIGGER_LEVEL_NOT_FOUND                                  =  -5003;  //  "SOM: trigger level not found"
    SEPIA2_ERR_SOM_PREDIVIDER_PRETRIGGER_OR_TRIGGERMASK_NOT_FOUND           =  -5004;  //  "SOM: predivider, pretrigger or triggermask not found"
    SEPIA2_ERR_SOM_BURSTLENGTH_NOT_FOUND                                    =  -5005;  //  "SOM: burstlength not found"
    SEPIA2_ERR_SOM_OUTPUT_AND_SYNC_ENABLE_NOT_FOUND                         =  -5006;  //  "SOM: output and sync enable not found"
    SEPIA2_ERR_SOM_TRIGGER_LEVEL_OUT_OF_BOUNDS                              =  -5007;  //  "SOM: trigger level out of bounds"
    SEPIA2_ERR_SOM_ILLEGAL_FREQUENCY_TRIGGERMODE                            =  -5008;  //  "SOM: illegal frequency / triggermode"
    SEPIA2_ERR_SOM_ILLEGAL_FREQUENCY_DIVIDER                                =  -5009;  //  "SOM: illegal frequency divider (equal 0)"
    SEPIA2_ERR_SOM_ILLEGAL_PRESYNC                                          =  -5010;  //  "SOM: illegal presync (greater than divider)"
    SEPIA2_ERR_SOM_ILLEGAL_BURST_LENGTH                                     =  -5011;  //  "SOM: illegal burst length (>/= 2^24 or < 0)"
    SEPIA2_ERR_SOM_AUX_IO_CTRL_NOT_FOUND                                    =  -5012;  //  "SOM: AUX I/O control data not found"
    SEPIA2_ERR_SOM_ILLEGAL_AUX_OUT_CTRL                                     =  -5013;  //  "SOM: illegal AUX output control data"
    SEPIA2_ERR_SOM_ILLEGAL_AUX_IN_CTRL                                      =  -5014;  //  "SOM: illegal AUX input control data"
    SEPIA2_ERR_SOMD_INT_OSCILLATOR_S_FREQ_LIST_NOT_FOUND                    =  -5051;  //  "SOMD: int. oscillator's freq.-list not found"
    SEPIA2_ERR_SOMD_TRIGGER_MODE_LIST_NOT_FOUND                             =  -5052;  //  "SOMD: trigger mode list not found"
    SEPIA2_ERR_SOMD_TRIGGER_LEVEL_NOT_FOUND                                 =  -5053;  //  "SOMD: trigger level not found"
    SEPIA2_ERR_SOMD_PREDIVIDER_PRETRIGGER_OR_TRIGGERMASK_NOT_FOUND          =  -5054;  //  "SOMD: predivider, pretrigger or triggermask not found"
    SEPIA2_ERR_SOMD_BURSTLENGTH_NOT_FOUND                                   =  -5055;  //  "SOMD: burstlength not found"
    SEPIA2_ERR_SOMD_OUTPUT_AND_SYNC_ENABLE_NOT_FOUND                        =  -5056;  //  "SOMD: output and sync enable not found"
    SEPIA2_ERR_SOMD_TRIGGER_LEVEL_OUT_OF_BOUNDS                             =  -5057;  //  "SOMD: trigger level out of bounds"
    SEPIA2_ERR_SOMD_ILLEGAL_FREQUENCY_TRIGGERMODE                           =  -5058;  //  "SOMD: illegal frequency / triggermode"
    SEPIA2_ERR_SOMD_ILLEGAL_FREQUENCY_DIVIDER                               =  -5059;  //  "SOMD: illegal frequency divider (equal 0)"
    SEPIA2_ERR_SOMD_ILLEGAL_PRESYNC                                         =  -5060;  //  "SOMD: illegal presync (greater than divider)"
    SEPIA2_ERR_SOMD_ILLEGAL_BURST_LENGTH                                    =  -5061;  //  "SOMD: illegal burst length (>/= 2^24 or < 0)"
    SEPIA2_ERR_SOMD_AUX_IO_CTRL_NOT_FOUND                                   =  -5062;  //  "SOMD: AUX I/O control data not found"
    SEPIA2_ERR_SOMD_ILLEGAL_AUX_OUT_CTRL                                    =  -5063;  //  "SOMD: illegal AUX output control data"
    SEPIA2_ERR_SOMD_ILLEGAL_AUX_IN_CTRL                                     =  -5064;  //  "SOMD: illegal AUX input control data"
    SEPIA2_ERR_SOMD_ILLEGAL_OUT_MUX_CTRL                                    =  -5071;  //  "SOMD: illegal output multiplexer control data"
    SEPIA2_ERR_SOMD_OUTPUT_DELAY_DATA_NOT_FOUND                             =  -5072;  //  "SOMD: output delay data not found"
    SEPIA2_ERR_SOMD_ILLEGAL_OUTPUT_DELAY_DATA                               =  -5073;  //  "SOMD: illegal output delay data"
    SEPIA2_ERR_SOMD_DELAY_NOT_ALLOWED_IN_TRIGGER_MODE                       =  -5074;  //  "SOMD: delay not allowed in current trigger mode"
    SEPIA2_ERR_SOMD_DEVICE_INITIALIZING                                     =  -5075;  //  "SOMD: device initializing"
    SEPIA2_ERR_SOMD_DEVICE_BUSY                                             =  -5076;  //  "SOMD: device busy"
    SEPIA2_ERR_SOMD_PLL_NOT_LOCKED                                          =  -5077;  //  "SOMD: PLL not locked"
    SEPIA2_ERR_SOMD_FW_UPDATE_FAILED                                        =  -5080;  //  "SOMD: firmware update failed"
    SEPIA2_ERR_SOMD_FW_CRC_CHECK_FAILED                                     =  -5081;  //  "SOMD: firmware CRC check failed"
    SEPIA2_ERR_SOMD_HW_TRIGGERSOURCE_ERROR                                  =  -5101;  //  "SOMD HW: triggersource error"
    SEPIA2_ERR_SOMD_HW_SYCHRONIZE_NOW_ERROR                                 =  -5102;  //  "SOMD HW: sychronize now error"
    SEPIA2_ERR_SOMD_HW_SYNC_RANGE_ERROR                                     =  -5103;  //  "SOMD HW: SYNC range error"
    SEPIA2_ERR_SOMD_HW_ILLEGAL_OUT_MUX_CTRL                                 =  -5104;  //  "SOMD HW: illegal output multiplexer control data"
    SEPIA2_ERR_SOMD_HW_SET_DELAY_ERROR                                      =  -5105;  //  "SOMD HW: set delay error"
    SEPIA2_ERR_SOMD_HW_AUX_IO_COMMAND_ERROR                                 =  -5106;  //  "SOMD HW: AUX I/O command error"
    SEPIA2_ERR_SOMD_HW_PLL_NOT_STABLE                                       =  -5107;  //  "SOMD HW: PLL not stable"
    SEPIA2_ERR_SOMD_HW_BURST_LENGTH_ERROR                                   =  -5108;  //  "SOMD HW: burst length error"
    SEPIA2_ERR_SOMD_HW_OUT_MUX_COMMAND_ERROR                                =  -5109;  //  "SOMD HW: output multiplexer command error"
    SEPIA2_ERR_SOMD_HW_COARSE_DELAY_SET_ERROR                               =  -5110;  //  "SOMD HW: coarse delay set error"
    SEPIA2_ERR_SOMD_HW_FINE_DELAY_SET_ERROR                                 =  -5111;  //  "SOMD HW: fine delay set error"
    SEPIA2_ERR_SOMD_HW_FW_EPROM_ERROR                                       =  -5112;  //  "SOMD HW: firmware EPROM error"
    SEPIA2_ERR_SOMD_HW_CRC_ERROR_ON_WRITING_FIRMWARE                        =  -5113;  //  "SOMD HW: CRC error on writing firmware"
    SEPIA2_ERR_SOMD_HW_CALIBRATION_DATA_NOT_FOUND                           =  -5114;  //  "SOMD HW: calibration data not found");
    SEPIA2_ERR_SOMD_HW_WRONG_EXTERNAL_FREQUENCY                             =  -5115;  //  "SOMD HW: wrong external frequency");
    SEPIA2_ERR_SOMD_HW_EXTERNAL_FREQUENCY_NOT_STABLE                        =  -5116;  //  "SOMD HW: external frequency not stable");

    SEPIA2_ERR_SLM_ILLEGAL_FREQUENCY_TRIGGERMODE                            =  -6001;  //  "SLM: illegal frequency / triggermode"
    SEPIA2_ERR_SLM_ILLEGAL_INTENSITY                                        =  -6002;  //  "SLM: illegal intensity (> 100% or < 0%)"
    SEPIA2_ERR_SLM_ILLEGAL_HEAD_TYPE                                        =  -6003;  //  "SLM: illegal head type"
    SEPIA2_ERR_SML_ILLEGAL_INTENSITY                                        =  -6501;  //  "SML: illegal intensity (> 100% or < 0%)"
    SEPIA2_ERR_SML_POWER_SCALE_TABLES_NOT_FOUND                             =  -6502;  //  "SML: power scale tables not found"
    SEPIA2_ERR_SML_ILLEGAL_HEAD_TYPE                                        =  -6503;  //  "SML: illegal head type"
    SEPIA2_ERR_SWM_CALIBRATION_TABLES_NOT_FOUND                             =  -6701;  //  "SWM: calibration tables not found"
    SEPIA2_ERR_SWM_ILLEGAL_CURVE_INDEX                                      =  -6702;  //  "SWM: illegal curve index"
    SEPIA2_ERR_SWM_ILLEGAL_TIMEBASE_RANGE_INDEX                             =  -6703;  //  "SWM: illegal timebase range index"
    SEPIA2_ERR_SWM_ILLEGAL_PULSE_AMPLITUDE                                  =  -6704;  //  "SWM: illegal pulse amplitude"
    SEPIA2_ERR_SWM_ILLEGAL_RAMP_SLEW_RATE                                   =  -6705;  //  "SWM: illegal ramp slew rate"
    SEPIA2_ERR_SWM_ILLEGAL_PULSE_START_DELAY                                =  -6706;  //  "SWM: illegal pulse start delay"
    SEPIA2_ERR_SWM_ILLEGAL_RAMP_START_DELAY                                 =  -6707;  //  "SWM: illegal ramp start delay"
    SEPIA2_ERR_SWM_ILLEGAL_WAVE_STOP_DELAY                                  =  -6708;  //  "SWM: illegal wave stop delay"
    SEPIA2_ERR_SWM_ILLEGAL_TABLENAME                                        =  -6709;  //  "SWM: illegal tablename"
    SEPIA2_ERR_SWM_ILLEGAL_TABLE_INDEX                                      =  -6710;  //  "SWM: illegal table index"
    SEPIA2_ERR_SWM_ILLEGAL_TABLE_FIELD                                      =  -6711;  //  "SWM: illegal table field"
    SEPIA2_ERR_SWM_EXT_ATTENUATION_NOT_FOUND                                =  -6712;  //  "SWM: ext. attenuation not found"
    SEPIA2_ERR_SWM_ILLEGAL_ATTENUATION_VALUE                                =  -6713;  //  "SWM: illegal attenuation value"

    SEPIA2_ERR_SPM_ILLEGAL_INPUT_VALUE                                      =  -7001;  //  "Solea SPM: illegal input value"
    SEPIA2_ERR_SPM_VALUE_OUT_OF_BOUNDS                                      =  -7006;  //  "Solea SPM: value out of bounds"
    SEPIA2_ERR_SPM_FW_OUT_OF_MEMORY                                         =  -7011;  //  "Solea SPM FW: out of memory"
    SEPIA2_ERR_SPM_FW_UPDATE_FAILED                                         =  -7013;  //  "Solea SPM FW: update failed"
    SEPIA2_ERR_SPM_FW_CRC_CHECK_FAILED                                      =  -7014;  //  "Solea SPM FW: CRC check failed"
    SEPIA2_ERR_SPM_FW_FLASH_DELETION_FAILED                                 =  -7015;  //  "Solea SPM FW: Flash deletion failed"
    SEPIA2_ERR_SPM_FW_FILE_OPEN_ERROR                                       =  -7021;  //  "Solea SPM FW: file open error"
    SEPIA2_ERR_SPM_FW_FILE_READ_ERROR                                       =  -7022;  //  "Solea SPM FW: file read error"
    SEPIA2_ERR_SSM_SCALING_TABLES_NOT_FOUND                                 =  -7051;  //  "Solea SSM: scaling tables not found"
    SEPIA2_ERR_SSM_ILLEGAL_TRIGGER_MODE                                     =  -7052;  //  "Solea SSM: illegal trigger mode"
    SEPIA2_ERR_SSM_ILLEGAL_TRIGGER_LEVEL_VALUE                              =  -7053;  //  "Solea SSM: illegal trigger level value"
    SEPIA2_ERR_SSM_ILLEGAL_CORRECTION_VALUE                                 =  -7054;  //  "Solea SSM: illegal correction value"
    SEPIA2_ERR_SSM_TRIGGER_DATA_NOT_FOUND                                   =  -7055;  //  "Solea SSM: trigger data not found"
    SEPIA2_ERR_SSM_CORRECTION_DATA_COMMAND_NOT_FOUND                        =  -7056;  //  "Solea SSM: correction data command not found"
    SEPIA2_ERR_SWS_SCALING_TABLES_NOT_FOUND                                 =  -7101;  //  "Solea SWS: scaling tables not found"
    SEPIA2_ERR_SWS_ILLEGAL_HW_MODULETYPE                                    =  -7102;  //  "Solea SWS: illegal HW moduletype"
    SEPIA2_ERR_SWS_MODULE_NOT_FUNCTIONAL                                    =  -7103;  //  "Solea SWS: module not functional"
    SEPIA2_ERR_SWS_ILLEGAL_CENTER_WAVELENGTH                                =  -7104;  //  "Solea SWS: illegal center wavelength"
    SEPIA2_ERR_SWS_ILLEGAL_BANDWIDTH                                        =  -7105;  //  "Solea SWS: illegal bandwidth"
    SEPIA2_ERR_SWS_VALUE_OUT_OF_BOUNDS                                      =  -7106;  //  "Solea SWS: value out of bounds"
    SEPIA2_ERR_SWS_MODULE_BUSY                                              =  -7107;  //  "Solea SWS: module busy"
    SEPIA2_ERR_SWS_FW_WRONG_COMPONENT_ANSWERING                             =  -7109;  //  "Solea SWS FW: wrong component answering"
    SEPIA2_ERR_SWS_FW_UNKNOWN_HW_MODULETYPE                                 =  -7110;  //  "Solea SWS FW: unknown HW moduletype"
    SEPIA2_ERR_SWS_FW_OUT_OF_MEMORY                                         =  -7111;  //  "Solea SWS FW: out of memory"
    SEPIA2_ERR_SWS_FW_VERSION_CONFLICT                                      =  -7112;  //  "Solea SWS FW: version conflict"
    SEPIA2_ERR_SWS_FW_UPDATE_FAILED                                         =  -7113;  //  "Solea SWS FW: update failed"
    SEPIA2_ERR_SWS_FW_CRC_CHECK_FAILED                                      =  -7114;  //  "Solea SWS FW: CRC check failed"
    SEPIA2_ERR_SWS_FW_ERROR_ON_FLASH_DELETION                               =  -7115;  //  "Solea SWS FW: error on flash deletion"
    SEPIA2_ERR_SWS_FW_CALIBRATION_MODE_ERROR                                =  -7116;  //  "Solea SWS FW: calibration mode error"
    SEPIA2_ERR_SWS_FW_FUNCTION_NOT_IMPLEMENTED_YET                          =  -7117;  //  "Solea SWS FW: function not implemented yet"
    SEPIA2_ERR_SWS_FW_WRONG_CALIBRATION_TABLE_ENTRY                         =  -7118;  //  "Solea SWS FW: wrong calibration table entry"
    SEPIA2_ERR_SWS_FW_INSUFFICIENT_CALIBRATION_TABLE_SIZE                   =  -7119;  //  "Solea SWS FW: insufficient calibration table size"
    SEPIA2_ERR_SWS_FW_FILE_OPEN_ERROR                                       =  -7151;  //  "Solea SWS FW: file open error"
    SEPIA2_ERR_SWS_FW_FILE_READ_ERROR                                       =  -7152;  //  "Solea SWS FW: file read error"
    SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_INIT_TIMEOUT                      =  -7201;  //  "Solea SWS HW: module 0, all motors: init timeout"
    SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_PLAUSI_CHECK                      =  -7202;  //  "Solea SWS HW: module 0, all motors: plausi check"
    SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_DAC_SET_CURRENT                   =  -7203;  //  "Solea SWS HW: module 0, all motors: DAC set current"
    SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_TIMEOUT                           =  -7204;  //  "Solea SWS HW: module 0, all motors: timeout"
    SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_FLASH_WRITE_ERROR                 =  -7205;  //  "Solea SWS HW: module 0, all motors: flash write error"
    SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_OUT_OF_BOUNDS                     =  -7206;  //  "Solea SWS HW: module 0, all motors: out of bounds"
    SEPIA2_ERR_SWS_HW_MODULE_0_I2C_FAILURE                                  =  -7207;  //  "Solea SWS HW: module 0: I2C failure"
    SEPIA2_ERR_SWS_HW_MODULE_0_INIT_FAILURE                                 =  -7208;  //  "Solea SWS HW: module 0: init failure"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_DATA_NOT_FOUND                       =  -7210;  //  "Solea SWS HW: module 0, motor 1: data not found"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_INIT_TIMEOUT                         =  -7211;  //  "Solea SWS HW: module 0, motor 1: init timeout"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_PLAUSI_CHECK                         =  -7212;  //  "Solea SWS HW: module 0, motor 1: plausi check"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_DAC_SET_CURRENT                      =  -7213;  //  "Solea SWS HW: module 0, motor 1: DAC set current"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_TIMEOUT                              =  -7214;  //  "Solea SWS HW: module 0, motor 1: timeout"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_FLASH_WRITE_ERROR                    =  -7215;  //  "Solea SWS HW: module 0, motor 1: flash write error"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_OUT_OF_BOUNDS                        =  -7216;  //  "Solea SWS HW: module 0, motor 1: out of bounds"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_DATA_NOT_FOUND                       =  -7220;  //  "Solea SWS HW: module 0, motor 2: data not found"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_INIT_TIMEOUT                         =  -7221;  //  "Solea SWS HW: module 0, motor 2: init timeout"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_PLAUSI_CHECK                         =  -7222;  //  "Solea SWS HW: module 0, motor 2: plausi check"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_DAC_SET_CURRENT                      =  -7223;  //  "Solea SWS HW: module 0, motor 2: DAC set current"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_TIMEOUT                              =  -7224;  //  "Solea SWS HW: module 0, motor 2: timeout"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_FLASH_WRITE_ERROR                    =  -7225;  //  "Solea SWS HW: module 0, motor 2: flash write error"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_OUT_OF_BOUNDS                        =  -7226;  //  "Solea SWS HW: module 0, motor 2: out of bounds"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_DATA_NOT_FOUND                       =  -7230;  //  "Solea SWS HW: module 0, motor 3: data not found"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_INIT_TIMEOUT                         =  -7231;  //  "Solea SWS HW: module 0, motor 3: init timeout"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_PLAUSI_CHECK                         =  -7232;  //  "Solea SWS HW: module 0, motor 3: plausi check"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_DAC_SET_CURRENT                      =  -7233;  //  "Solea SWS HW: module 0, motor 3: DAC set current"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_TIMEOUT                              =  -7234;  //  "Solea SWS HW: module 0, motor 3: timeout"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_FLASH_WRITE_ERROR                    =  -7235;  //  "Solea SWS HW: module 0, motor 3: flash write error"
    SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_OUT_OF_BOUNDS                        =  -7236;  //  "Solea SWS HW: module 0, motor 3: out of bounds"
    SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_INIT_TIMEOUT                      =  -7301;  //  "Solea SWS HW: module 1, all motors: init timeout"
    SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_PLAUSI_CHECK                      =  -7302;  //  "Solea SWS HW: module 1, all motors: plausi check"
    SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_DAC_SET_CURRENT                   =  -7303;  //  "Solea SWS HW: module 1, all motors: DAC set current"
    SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_TIMEOUT                           =  -7304;  //  "Solea SWS HW: module 1, all motors: timeout"
    SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_FLASH_WRITE_ERROR                 =  -7305;  //  "Solea SWS HW: module 1, all motors: flash write error"
    SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_OUT_OF_BOUNDS                     =  -7306;  //  "Solea SWS HW: module 1, all motors: out of bounds"
    SEPIA2_ERR_SWS_HW_MODULE_1_I2C_FAILURE                                  =  -7307;  //  "Solea SWS HW: module 1: I2C failure"
    SEPIA2_ERR_SWS_HW_MODULE_1_INIT_FAILURE                                 =  -7308;  //  "Solea SWS HW: module 1: init failure"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_DATA_NOT_FOUND                       =  -7310;  //  "Solea SWS HW: module 1, motor 1: data not found"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_INIT_TIMEOUT                         =  -7311;  //  "Solea SWS HW: module 1, motor 1: init timeout"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_PLAUSI_CHECK                         =  -7312;  //  "Solea SWS HW: module 1, motor 1: plausi check"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_DAC_SET_CURRENT                      =  -7313;  //  "Solea SWS HW: module 1, motor 1: DAC set current"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_TIMEOUT                              =  -7314;  //  "Solea SWS HW: module 1, motor 1: timeout"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_FLASH_WRITE_ERROR                    =  -7315;  //  "Solea SWS HW: module 1, motor 1: flash write error"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_OUT_OF_BOUNDS                        =  -7316;  //  "Solea SWS HW: module 1, motor 1: out of bounds"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_DATA_NOT_FOUND                       =  -7320;  //  "Solea SWS HW: module 1, motor 2: data not found"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_INIT_TIMEOUT                         =  -7321;  //  "Solea SWS HW: module 1, motor 2: init timeout"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_PLAUSI_CHECK                         =  -7322;  //  "Solea SWS HW: module 1, motor 2: plausi check"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_DAC_SET_CURRENT                      =  -7323;  //  "Solea SWS HW: module 1, motor 2: DAC set current"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_TIMEOUT                              =  -7324;  //  "Solea SWS HW: module 1, motor 2: timeout"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_FLASH_WRITE_ERROR                    =  -7325;  //  "Solea SWS HW: module 1, motor 2: flash write error"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_OUT_OF_BOUNDS                        =  -7326;  //  "Solea SWS HW: module 1, motor 2: out of bounds"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_DATA_NOT_FOUND                       =  -7330;  //  "Solea SWS HW: module 1, motor 3: data not found"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_INIT_TIMEOUT                         =  -7331;  //  "Solea SWS HW: module 1, motor 3: init timeout"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_PLAUSI_CHECK                         =  -7332;  //  "Solea SWS HW: module 1, motor 3: plausi check"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_DAC_SET_CURRENT                      =  -7333;  //  "Solea SWS HW: module 1, motor 3: DAC set current"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_TIMEOUT                              =  -7334;  //  "Solea SWS HW: module 1, motor 3: timeout"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_FLASH_WRITE_ERROR                    =  -7335;  //  "Solea SWS HW: module 1, motor 3: flash write error"
    SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_OUT_OF_BOUNDS                        =  -7336;  //  "Solea SWS HW: module 1, motor 3: out of bounds"
    SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_INIT_TIMEOUT                      =  -7401;  //  "Solea SWS HW: module 2, all motors: init timeout"
    SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_PLAUSI_CHECK                      =  -7402;  //  "Solea SWS HW: module 2, all motors: plausi check"
    SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_DAC_SET_CURRENT                   =  -7403;  //  "Solea SWS HW: module 2, all motors: DAC set current"
    SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_TIMEOUT                           =  -7404;  //  "Solea SWS HW: module 2, all motors: timeout"
    SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_FLASH_WRITE_ERROR                 =  -7405;  //  "Solea SWS HW: module 2, all motors: flash write error"
    SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_OUT_OF_BOUNDS                     =  -7406;  //  "Solea SWS HW: module 2, all motors: out of bounds"
    SEPIA2_ERR_SWS_HW_MODULE_2_I2C_FAILURE                                  =  -7407;  //  "Solea SWS HW: module 2: I2C failure"
    SEPIA2_ERR_SWS_HW_MODULE_2_INIT_FAILURE                                 =  -7408;  //  "Solea SWS HW: module 2: init failure"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_DATA_NOT_FOUND                       =  -7410;  //  "Solea SWS HW: module 2, motor 1: data not found"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_INIT_TIMEOUT                         =  -7411;  //  "Solea SWS HW: module 2, motor 1: init timeout"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_PLAUSI_CHECK                         =  -7412;  //  "Solea SWS HW: module 2, motor 1: plausi check"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_DAC_SET_CURRENT                      =  -7413;  //  "Solea SWS HW: module 2, motor 1: DAC set current"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_TIMEOUT                              =  -7414;  //  "Solea SWS HW: module 2, motor 1: timeout"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_FLASH_WRITE_ERROR                    =  -7415;  //  "Solea SWS HW: module 2, motor 1: flash write error"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_OUT_OF_BOUNDS                        =  -7416;  //  "Solea SWS HW: module 2, motor 1: out of bounds"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_DATA_NOT_FOUND                       =  -7420;  //  "Solea SWS HW: module 2, motor 2: data not found"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_INIT_TIMEOUT                         =  -7421;  //  "Solea SWS HW: module 2, motor 2: init timeout"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_PLAUSI_CHECK                         =  -7422;  //  "Solea SWS HW: module 2, motor 2: plausi check"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_DAC_SET_CURRENT                      =  -7423;  //  "Solea SWS HW: module 2, motor 2: DAC set current"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_TIMEOUT                              =  -7424;  //  "Solea SWS HW: module 2, motor 2: timeout"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_FLASH_WRITE_ERROR                    =  -7425;  //  "Solea SWS HW: module 2, motor 2: flash write error"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_OUT_OF_BOUNDS                        =  -7426;  //  "Solea SWS HW: module 2, motor 2: out of bounds"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_DATA_NOT_FOUND                       =  -7430;  //  "Solea SWS HW: module 2, motor 3: data not found"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_INIT_TIMEOUT                         =  -7431;  //  "Solea SWS HW: module 2, motor 3: init timeout"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_PLAUSI_CHECK                         =  -7432;  //  "Solea SWS HW: module 2, motor 3: plausi check"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_DAC_SET_CURRENT                      =  -7433;  //  "Solea SWS HW: module 2, motor 3: DAC set current"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_TIMEOUT                              =  -7434;  //  "Solea SWS HW: module 2, motor 3: timeout"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_FLASH_WRITE_ERROR                    =  -7435;  //  "Solea SWS HW: module 2, motor 3: flash write error"
    SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_OUT_OF_BOUNDS                        =  -7436;  //  "Solea SWS HW: module 2, motor 3: out of bounds"

    SEPIA2_ERR_LIB_TOO_MANY_USB_HANDLES                                     =  -9001;  //  "LIB: too many USB handles"
    SEPIA2_ERR_LIB_ILLEGAL_DEVICE_INDEX                                     =  -9002;  //  "LIB: illegal device index"
    SEPIA2_ERR_LIB_USB_DEVICE_OPEN_ERROR                                    =  -9003;  //  "LIB: USB device open error"
    SEPIA2_ERR_LIB_USB_DEVICE_BUSY_OR_BLOCKED                               =  -9004;  //  "LIB: USB device busy or blocked"
    SEPIA2_ERR_LIB_USB_DEVICE_ALREADY_OPENED                                =  -9005;  //  "LIB: USB device already opened"
    SEPIA2_ERR_LIB_UNKNOWN_USB_HANDLE                                       =  -9006;  //  "LIB: unknown USB handle"
    SEPIA2_ERR_LIB_SCM_828_MODULE_NOT_FOUND                                 =  -9007;  //  "LIB: SCM 828 module not found"
    SEPIA2_ERR_LIB_ILLEGAL_SLOT_NUMBER                                      =  -9008;  //  "LIB: illegal slot number"
    SEPIA2_ERR_LIB_REFERENCED_SLOT_IS_NOT_IN_USE                            =  -9009;  //  "LIB: referenced slot is not in use"
    SEPIA2_ERR_LIB_THIS_IS_NO_SCM_828_MODULE                                =  -9010;  //  "LIB: this is no SCM 828 module"
    SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_MODULE                                =  -9011;  //  "LIB: this is no SOM 828 module"
    SEPIA2_ERR_LIB_THIS_IS_NO_SLM_828_MODULE                                =  -9012;  //  "LIB: this is no SLM 828 module"
    SEPIA2_ERR_LIB_THIS_IS_NO_SML_828_MODULE                                =  -9013;  //  "LIB: this is no SML 828 module"
    SEPIA2_ERR_LIB_THIS_IS_NO_SWM_828_MODULE                                =  -9014;  //  "LIB: this is no SWM 828 module"
    SEPIA2_ERR_HIS_IS_NO_SOLEA_SSM_MODULE                                   =  -9015;  //  "LIB: this is no Solea SSM module"
    SEPIA2_ERR_HIS_IS_NO_SOLEA_SWS_MODULE                                   =  -9016;  //  "LIB: this is no Solea SWS module"
    SEPIA2_ERR_HIS_IS_NO_SOLEA_SPM_MODULE                                   =  -9017;  //  "LIB: this is no Solea SPM module"
    SEPIA2_ERR_LIB_THIS_IS_NO_LMP1                                          =  -9018;  //  "LIB: this is no LMP1 (metermodule w. shuttercontrol)"
    SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_D_MODULE                              =  -9019;  //  "LIB: this is no SOM 828 D module"
    SEPIA2_ERR_LIB_NO_MAP_FOUND                                             =  -9020;  //  "LIB: no map found"
    SEPIA2_ERR_LIB_THIS_IS_NO_LMP8                                          =  -9021;  //  "LIB: this is no LMP8 (eightfold metermodule)"
    SEPIA2_ERR_LIB_DEVICE_CHANGED_RE_INITIALISE_USB_DEVICE_LIST             =  -9025;  //  "LIB: device changed, re-initialise USB device list"
    SEPIA2_ERR_LIB_INAPPROPRIATE_USB_DEVICE                                 =  -9026;  //  "LIB: inappropriate USB device"
    SEPIA2_ERR_LIB_WRONG_USB_DRIVER_VERSION                                 =  -9090;  //  "LIB: wrong USB driver version"
    SEPIA2_ERR_LIB_UNKNOWN_FUNCTION                                         =  -9900;  //  "LIB: unknown function"
    SEPIA2_ERR_LIB_ILLEGAL_PARAMETER_ON_FUNCTION_CALL                       =  -9910;  //  "LIB: illegal parameter on function call"
    SEPIA2_ERR_LIB_UNKNOWN_ERROR_CODE                                       =  -9999;  //  "LIB: unknown error code"



implementation

end.
