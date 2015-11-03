using System.Text;
using System.Runtime.InteropServices;

class Sepia2_Import {

  //-----------------------------------------------------------------------------
  //
  //      Sepia2_ErrorCodes.h
  //
  //-----------------------------------------------------------------------------
  //
  //  Exports the official list of error codes for Sepia2_lib V1.1.xx.412
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
  //  apo  27.02.15   additional error codes for SOMD Module (V1.1.xx.403)
  //
  //  apo  04.03.15   additional symbol construction rules (V1.1.xx.407)
  //
  //-----------------------------------------------------------------------------
  //


  public const int  SEPIA2_ERR_NO_ERROR =                                                             0;   //  "no error"

  public const int  SEPIA2_ERR_FW_MEMORY_ALLOCATION_ERROR =                                       -1001;   //  "FW: memory allocation error"
  public const int  SEPIA2_ERR_FW_CRC_ERROR_WHILE_CHECKING_SCM_828_MODULE =                       -1002;   //  "FW: CRC error while checking SCM 828 module"
  public const int  SEPIA2_ERR_FW_CRC_ERROR_WHILE_CHECKING_BACKPLANE =                            -1003;   //  "FW: CRC error while checking backplane"
  public const int  SEPIA2_ERR_FW_CRC_ERROR_WHILE_CHECKING_MODULE =                               -1004;   //  "FW: CRC error while checking module"
  public const int  SEPIA2_ERR_FW_MAPSIZE_ERROR =                                                 -1005;   //  "FW: mapsize error"
  public const int  SEPIA2_ERR_FW_UNKNOWN_ERROR_PHASE =                                           -1006;   //  "FW: unknown error phase"
  public const int  SEPIA2_ERR_FW_ILLEGAL_MODULE_CHANGE =                                         -1111;   //  "FW: illegal module change"

  public const int  SEPIA2_ERR_USB_WRONG_DRIVER_VERSION =                                         -2001;   //  "USB: wrong driver version"
  public const int  SEPIA2_ERR_USB_OPEN_DEVICE_ERROR =                                            -2002;   //  "USB: open device error"
  public const int  SEPIA2_ERR_USB_DEVICE_BUSY =                                                  -2003;   //  "USB: device busy"
  public const int  SEPIA2_ERR_USB_CLOSE_DEVICE_ERROR =                                           -2005;   //  "USB: close device error"
  public const int  SEPIA2_ERR_USB_DEVICE_CHANGED =                                               -2006;   //  "USB: device changed"
  public const int  SEPIA2_ERR_I2C_ADDRESS_ERROR =                                                -2010;   //  "I2C: address error"
  public const int  SEPIA2_ERR_USB_DEVICE_INDEX_ERROR =                                           -2011;   //  "USB: device index error"
  public const int  SEPIA2_ERR_I2C_ILLEGAL_MULTIPLEXER_PATH =                                     -2012;   //  "I2C: illegal multiplexer path"
  public const int  SEPIA2_ERR_I2C_ILLEGAL_MULTIPLEXER_LEVEL =                                    -2013;   //  "I2C: illegal multiplexer level"
  public const int  SEPIA2_ERR_I2C_ILLEGAL_SLOT_ID =                                              -2014;   //  "I2C: illegal slot id"
  public const int  SEPIA2_ERR_FRAM_NO_UPTIME_COUNTER =                                           -2015;   //  "FRAM: no uptime counter"
  public const int  SEPIA2_ERR_FRAM_BLOCKWRITE_ERROR =                                            -2020;   //  "FRAM: blockwrite error"
  public const int  SEPIA2_ERR_FRAM_BLOCKREAD_ERROR =                                             -2021;   //  "FRAM: blockread error"
  public const int  SEPIA2_ERR_FRAM_CRC_BLOCKCHECK_ERROR =                                        -2022;   //  "FRAM: CRC blockcheck error"
  public const int  SEPIA2_ERR_RAM_BLOCK_ALLOCATION_ERROR =                                       -2023;   //  "RAM: block allocation error"
  public const int  SEPIA2_ERR_I2C_INITIALISING_COMMAND_EXECUTION_ERROR =                         -2100;   //  "I2C: initialising command execution error"
  public const int  SEPIA2_ERR_I2C_FETCHING_INITIALISING_COMMANDS_ERROR =                         -2101;   //  "I2C: fetching initialising commands error"
  public const int  SEPIA2_ERR_I2C_WRITING_INITIALISING_COMMANDS_ERROR =                          -2102;   //  "I2C: writing initialising commands error"
  public const int  SEPIA2_ERR_I2C_MODULE_CALIBRATING_ERROR =                                     -2200;   //  "I2C: module calibrating error"
  public const int  SEPIA2_ERR_I2C_FETCHING_CALIBRATING_COMMANDS_ERROR =                          -2201;   //  "I2C: fetching calibrating commands error"
  public const int  SEPIA2_ERR_I2C_WRITING_CALIBRATING_COMMANDS_ERROR =                           -2202;   //  "I2C: writing calibrating commands error"
  public const int  SEPIA2_ERR_DCL_FILE_OPEN_ERROR =                                              -2301;   //  "DCL: file open error"
  public const int  SEPIA2_ERR_DCL_WRONG_FILE_LENGTH =                                            -2302;   //  "DCL: wrong file length"
  public const int  SEPIA2_ERR_DCL_FILE_READ_ERROR =                                              -2303;   //  "DCL: file read error"
  public const int  SEPIA2_ERR_FRAM_IS_WRITE_PROTECTED =                                          -2304;   //  "FRAM: is write protected"
  public const int  SEPIA2_ERR_DCL_FILE_SPECIFIES_DIFFERENT_MODULETYPE =                          -2305;   //  "DCL: file specifies different moduletype"
  public const int  SEPIA2_ERR_DCL_FILE_SPECIFIES_DIFFERENT_SERIAL_NUMBER =                       -2306;   //  "DCL: file specifies different serial number"

  public const int  SEPIA2_ERR_I2C_INVALID_ARGUMENT =                                             -3001;   //  "I2C: invalid argument"
  public const int  SEPIA2_ERR_I2C_NO_ACKNOWLEDGE_ON_WRITE_ADRESSBYTE =                           -3002;   //  "I2C: no acknowledge on write adressbyte"
  public const int  SEPIA2_ERR_I2C_NO_ACKNOWLEDGE_ON_READ_ADRESSBYTE =                            -3003;   //  "I2C: no acknowledge on read adressbyte"
  public const int  SEPIA2_ERR_I2C_NO_ACKNOWLEDGE_ON_WRITE_DATABYTE =                             -3004;   //  "I2C: no acknowledge on write databyte"
  public const int  SEPIA2_ERR_I2C_READ_BACK_ERROR =                                              -3005;   //  "I2C: read back error"
  public const int  SEPIA2_ERR_I2C_READ_ERROR =                                                   -3006;   //  "I2C: read error"
  public const int  SEPIA2_ERR_I2C_WRITE_ERROR =                                                  -3007;   //  "I2C: write error"
  public const int  SEPIA2_ERR_I_O_FILE_ERROR =                                                   -3009;   //  "I/O: file error"
  public const int  SEPIA2_ERR_I2C_MULTIPLEXER_ERROR =                                            -3014;   //  "I2C: multiplexer error"
  public const int  SEPIA2_ERR_I2C_MULTIPLEXER_PATH_ERROR =                                       -3015;   //  "I2C: multiplexer path error"
  public const int  SEPIA2_ERR_USB_INVALID_ARGUMENT =                                             -3201;   //  "USB: invalid argument"
  public const int  SEPIA2_ERR_USB_DEVICE_STILL_OPEN =                                            -3202;   //  "USB: device still open"
  public const int  SEPIA2_ERR_USB_NO_MEMORY =                                                    -3203;   //  "USB: no memory"
  public const int  SEPIA2_ERR_USB_OPEN_FAILED =                                                  -3204;   //  "USB: open failed"
  public const int  SEPIA2_ERR_USB_GET_DESCRIPTOR_FAILED =                                        -3205;   //  "USB: get descriptor failed"
  public const int  SEPIA2_ERR_USB_INAPPROPRIATE_DEVICE =                                         -3206;   //  "USB: inappropriate device"
  public const int  SEPIA2_ERR_USB_BUSY_DEVICE =                                                  -3207;   //  "USB: busy device"
  public const int  SEPIA2_ERR_USB_INVALID_HANDLE =                                               -3208;   //  "USB: invalid handle"
  public const int  SEPIA2_ERR_USB_INVALID_DESCRIPTOR_BUFFER =                                    -3209;   //  "USB: invalid descriptor buffer"
  public const int  SEPIA2_ERR_USB_IOCTRL_FAILED =                                                -3210;   //  "USB: IOCTRL failed"
  public const int  SEPIA2_ERR_USB_VCMD_FAILED =                                                  -3211;   //  "USB: vcmd failed"
  public const int  SEPIA2_ERR_USB_NO_SUCH_PIPE =                                                 -3212;   //  "USB: no such pipe"
  public const int  SEPIA2_ERR_USB_REGISTER_NOTIFICATION_FAILED =                                 -3213;   //  "USB: register notification failed"
  public const int  SEPIA2_ERR_I2C_DEVICE_ERROR =                                                 -3256;   //  "I2C: device error"
  public const int  SEPIA2_ERR_LMP1_ADC_TABLES_NOT_FOUND =                                        -3501;   //  "LMP1: ADC tables not found"
  public const int  SEPIA2_ERR_LMP1_ADC_OVERFLOW =                                                -3502;   //  "LMP1: ADC overflow"
  public const int  SEPIA2_ERR_LMP1_ADC_UNDERFLOW =                                               -3503;   //  "LMP1: ADC underflow"

  public const int  SEPIA2_ERR_SCM_VOLTAGE_LIMITS_TABLE_NOT_FOUND =                               -4001;   //  "SCM: voltage limits table not found"
  public const int  SEPIA2_ERR_SCM_VOLTAGE_SCALING_LIST_NOT_FOUND =                               -4002;   //  "SCM: voltage scaling list not found"
  public const int  SEPIA2_ERR_SCM_REPEATEDLY_MEASURED_VOLTAGE_FAILURE =                          -4003;   //  "SCM: repeatedly measured voltage failure"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_0_VOLTAGE_TOO_LOW =                          -4010;   //  "SCM: power supply line 0: voltage too low"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_1_VOLTAGE_TOO_LOW =                          -4011;   //  "SCM: power supply line 1: voltage too low"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_2_VOLTAGE_TOO_LOW =                          -4012;   //  "SCM: power supply line 2: voltage too low"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_3_VOLTAGE_TOO_LOW =                          -4013;   //  "SCM: power supply line 3: voltage too low"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_4_VOLTAGE_TOO_LOW =                          -4014;   //  "SCM: power supply line 4: voltage too low"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_5_VOLTAGE_TOO_LOW =                          -4015;   //  "SCM: power supply line 5: voltage too low"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_6_VOLTAGE_TOO_LOW =                          -4016;   //  "SCM: power supply line 6: voltage too low"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_7_VOLTAGE_TOO_LOW =                          -4017;   //  "SCM: power supply line 7: voltage too low"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_0_VOLTAGE_TOO_HIGH =                         -4020;   //  "SCM: power supply line 0: voltage too high"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_1_VOLTAGE_TOO_HIGH =                         -4021;   //  "SCM: power supply line 1: voltage too high"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_2_VOLTAGE_TOO_HIGH =                         -4022;   //  "SCM: power supply line 2: voltage too high"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_3_VOLTAGE_TOO_HIGH =                         -4023;   //  "SCM: power supply line 3: voltage too high"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_4_VOLTAGE_TOO_HIGH =                         -4024;   //  "SCM: power supply line 4: voltage too high"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_5_VOLTAGE_TOO_HIGH =                         -4025;   //  "SCM: power supply line 5: voltage too high"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_6_VOLTAGE_TOO_HIGH =                         -4026;   //  "SCM: power supply line 6: voltage too high"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LINE_7_VOLTAGE_TOO_HIGH =                         -4027;   //  "SCM: power supply line 7: voltage too high"
  public const int  SEPIA2_ERR_SCM_POWER_SUPPLY_LASER_TURNING_OFF_VOLTAGE_TOO_HIGH =              -4030;   //  "SCM: power supply laser turning-off-voltage too high"

  public const int  SEPIA2_ERR_SOM_INT_OSCILLATOR_S_FREQ_LIST_NOT_FOUND =                         -5001;   //  "SOM: int. oscillator's freq.-list not found"
  public const int  SEPIA2_ERR_SOM_TRIGGER_MODE_LIST_NOT_FOUND =                                  -5002;   //  "SOM: trigger mode list not found"
  public const int  SEPIA2_ERR_SOM_TRIGGER_LEVEL_NOT_FOUND =                                      -5003;   //  "SOM: trigger level not found"
  public const int  SEPIA2_ERR_SOM_PREDIVIDER_PRETRIGGER_OR_TRIGGERMASK_NOT_FOUND =               -5004;   //  "SOM: predivider, pretrigger or triggermask not found"
  public const int  SEPIA2_ERR_SOM_BURSTLENGTH_NOT_FOUND =                                        -5005;   //  "SOM: burstlength not found"
  public const int  SEPIA2_ERR_SOM_OUTPUT_AND_SYNC_ENABLE_NOT_FOUND =                             -5006;   //  "SOM: output and sync enable not found"
  public const int  SEPIA2_ERR_SOM_TRIGGER_LEVEL_OUT_OF_BOUNDS =                                  -5007;   //  "SOM: trigger level out of bounds"
  public const int  SEPIA2_ERR_SOM_ILLEGAL_FREQUENCY_TRIGGERMODE =                                -5008;   //  "SOM: illegal frequency / triggermode"
  public const int  SEPIA2_ERR_SOM_ILLEGAL_FREQUENCY_DIVIDER =                                    -5009;   //  "SOM: illegal frequency divider (equal 0)"
  public const int  SEPIA2_ERR_SOM_ILLEGAL_PRESYNC =                                              -5010;   //  "SOM: illegal presync (greater than divider)"
  public const int  SEPIA2_ERR_SOM_ILLEGAL_BURST_LENGTH =                                         -5011;   //  "SOM: illegal burst length (>/= 2^24 or < 0)"
  public const int  SEPIA2_ERR_SOM_AUX_IO_CTRL_NOT_FOUND =                                        -5012;   //  "SOM: AUX I/O control data not found"
  public const int  SEPIA2_ERR_SOM_ILLEGAL_AUX_OUT_CTRL =                                         -5013;   //  "SOM: illegal AUX output control data"
  public const int  SEPIA2_ERR_SOM_ILLEGAL_AUX_IN_CTRL =                                          -5014;   //  "SOM: illegal AUX input control data"
  public const int  SEPIA2_ERR_SOMD_INT_OSCILLATOR_S_FREQ_LIST_NOT_FOUND =                        -5051;   //  "SOMD: int. oscillator's freq.-list not found"
  public const int  SEPIA2_ERR_SOMD_TRIGGER_MODE_LIST_NOT_FOUND =                                 -5052;   //  "SOMD: trigger mode list not found"
  public const int  SEPIA2_ERR_SOMD_TRIGGER_LEVEL_NOT_FOUND =                                     -5053;   //  "SOMD: trigger level not found"
  public const int  SEPIA2_ERR_SOMD_PREDIVIDER_PRETRIGGER_OR_TRIGGERMASK_NOT_FOUND =              -5054;   //  "SOMD: predivider, pretrigger or triggermask not found"
  public const int  SEPIA2_ERR_SOMD_BURSTLENGTH_NOT_FOUND =                                       -5055;   //  "SOMD: burstlength not found"
  public const int  SEPIA2_ERR_SOMD_OUTPUT_AND_SYNC_ENABLE_NOT_FOUND =                            -5056;   //  "SOMD: output and sync enable not found"
  public const int  SEPIA2_ERR_SOMD_TRIGGER_LEVEL_OUT_OF_BOUNDS =                                 -5057;   //  "SOMD: trigger level out of bounds"
  public const int  SEPIA2_ERR_SOMD_ILLEGAL_FREQUENCY_TRIGGERMODE =                               -5058;   //  "SOMD: illegal frequency / triggermode"
  public const int  SEPIA2_ERR_SOMD_ILLEGAL_FREQUENCY_DIVIDER =                                   -5059;   //  "SOMD: illegal frequency divider (equal 0)"
  public const int  SEPIA2_ERR_SOMD_ILLEGAL_PRESYNC =                                             -5060;   //  "SOMD: illegal presync (greater than divider)"
  public const int  SEPIA2_ERR_SOMD_ILLEGAL_BURST_LENGTH =                                        -5061;   //  "SOMD: illegal burst length (>/= 2^24 or < 0)"
  public const int  SEPIA2_ERR_SOMD_AUX_IO_CTRL_NOT_FOUND =                                       -5062;   //  "SOMD: AUX I/O control data not found"
  public const int  SEPIA2_ERR_SOMD_ILLEGAL_AUX_OUT_CTRL =                                        -5063;   //  "SOMD: illegal AUX output control data"
  public const int  SEPIA2_ERR_SOMD_ILLEGAL_AUX_IN_CTRL =                                         -5064;   //  "SOMD: illegal AUX input control data"
  public const int  SEPIA2_ERR_SOMD_ILLEGAL_OUT_MUX_CTRL =                                        -5071;   //  "SOMD: illegal output multiplexer control data"
  public const int  SEPIA2_ERR_SOMD_OUTPUT_DELAY_DATA_NOT_FOUND =                                 -5072;   //  "SOMD: output delay data not found"
  public const int  SEPIA2_ERR_SOMD_ILLEGAL_OUTPUT_DELAY_DATA =                                   -5073;   //  "SOMD: illegal output delay data"
  public const int  SEPIA2_ERR_SOMD_DELAY_NOT_ALLOWED_IN_TRIGGER_MODE =                           -5074;   //  "SOMD: delay not allowed in current trigger mode"
  public const int  SEPIA2_ERR_SOMD_DEVICE_INITIALIZING =                                         -5075;   //  "SOMD: device initializing"
  public const int  SEPIA2_ERR_SOMD_DEVICE_BUSY =                                                 -5076;   //  "SOMD: device busy"
  public const int  SEPIA2_ERR_SOMD_PLL_NOT_LOCKED =                                              -5077;   //  "SOMD: PLL not locked"
  public const int  SEPIA2_ERR_SOMD_FW_UPDATE_FAILED =                                            -5080;   //  "SOMD: firmware update failed"
  public const int  SEPIA2_ERR_SOMD_FW_CRC_CHECK_FAILED =                                         -5081;   //  "SOMD: firmware CRC check failed"
  public const int  SEPIA2_ERR_SOMD_HW_TRIGGERSOURCE_ERROR =                                      -5101;   //  "SOMD HW: triggersource error"
  public const int  SEPIA2_ERR_SOMD_HW_SYCHRONIZE_NOW_ERROR =                                     -5102;   //  "SOMD HW: sychronize now error"
  public const int  SEPIA2_ERR_SOMD_HW_SYNC_RANGE_ERROR =                                         -5103;   //  "SOMD HW: SYNC range error"
  public const int  SEPIA2_ERR_SOMD_HW_ILLEGAL_OUT_MUX_CTRL =                                     -5104;   //  "SOMD HW: illegal output multiplexer control data"
  public const int  SEPIA2_ERR_SOMD_HW_SET_DELAY_ERROR =                                          -5105;   //  "SOMD HW: set delay error"
  public const int  SEPIA2_ERR_SOMD_HW_AUX_IO_COMMAND_ERROR =                                     -5106;   //  "SOMD HW: AUX I/O command error"
  public const int  SEPIA2_ERR_SOMD_HW_PLL_NOT_STABLE =                                           -5107;   //  "SOMD HW: PLL not stable"
  public const int  SEPIA2_ERR_SOMD_HW_BURST_LENGTH_ERROR =                                       -5108;   //  "SOMD HW: burst length error"
  public const int  SEPIA2_ERR_SOMD_HW_OUT_MUX_COMMAND_ERROR =                                    -5109;   //  "SOMD HW: output multiplexer command error"
  public const int  SEPIA2_ERR_SOMD_HW_COARSE_DELAY_SET_ERROR =                                   -5110;   //  "SOMD HW: coarse delay set error"
  public const int  SEPIA2_ERR_SOMD_HW_FINE_DELAY_SET_ERROR =                                     -5111;   //  "SOMD HW: fine delay set error"
  public const int  SEPIA2_ERR_SOMD_HW_FW_EPROM_ERROR =                                           -5112;   //  "SOMD HW: firmware EPROM error"
  public const int  SEPIA2_ERR_SOMD_HW_CRC_ERROR_ON_WRITING_FIRMWARE =                            -5113;   //  "SOMD HW: CRC error on writing firmware"

  public const int  SEPIA2_ERR_SLM_ILLEGAL_FREQUENCY_TRIGGERMODE =                                -6001;   //  "SLM: illegal frequency / triggermode"
  public const int  SEPIA2_ERR_SLM_ILLEGAL_INTENSITY =                                            -6002;   //  "SLM: illegal intensity (> 100% or < 0%)"
  public const int  SEPIA2_ERR_SLM_ILLEGAL_HEAD_TYPE =                                            -6003;   //  "SLM: illegal head type"
  public const int  SEPIA2_ERR_SML_ILLEGAL_INTENSITY =                                            -6501;   //  "SML: illegal intensity (> 100% or < 0%)"
  public const int  SEPIA2_ERR_SML_POWER_SCALE_TABLES_NOT_FOUND =                                 -6502;   //  "SML: power scale tables not found"
  public const int  SEPIA2_ERR_SML_ILLEGAL_HEAD_TYPE =                                            -6503;   //  "SML: illegal head type"
  public const int  SEPIA2_ERR_SWM_CALIBRATION_TABLES_NOT_FOUND =                                 -6701;   //  "SWM: calibration tables not found"
  public const int  SEPIA2_ERR_SWM_ILLEGAL_CURVE_INDEX =                                          -6702;   //  "SWM: illegal curve index"
  public const int  SEPIA2_ERR_SWM_ILLEGAL_TIMEBASE_RANGE_INDEX =                                 -6703;   //  "SWM: illegal timebase range index"
  public const int  SEPIA2_ERR_SWM_ILLEGAL_PULSE_AMPLITUDE =                                      -6704;   //  "SWM: illegal pulse amplitude"
  public const int  SEPIA2_ERR_SWM_ILLEGAL_RAMP_SLEW_RATE =                                       -6705;   //  "SWM: illegal ramp slew rate"
  public const int  SEPIA2_ERR_SWM_ILLEGAL_PULSE_START_DELAY =                                    -6706;   //  "SWM: illegal pulse start delay"
  public const int  SEPIA2_ERR_SWM_ILLEGAL_RAMP_START_DELAY =                                     -6707;   //  "SWM: illegal ramp start delay"
  public const int  SEPIA2_ERR_SWM_ILLEGAL_WAVE_STOP_DELAY =                                      -6708;   //  "SWM: illegal wave stop delay"
  public const int  SEPIA2_ERR_SWM_ILLEGAL_TABLENAME =                                            -6709;   //  "SWM: illegal tablename"
  public const int  SEPIA2_ERR_SWM_ILLEGAL_TABLE_INDEX =                                          -6710;   //  "SWM: illegal table index"
  public const int  SEPIA2_ERR_SWM_ILLEGAL_TABLE_FIELD =                                          -6711;   //  "SWM: illegal table field"

  public const int  SEPIA2_ERR_SPM_ILLEGAL_INPUT_VALUE =                                          -7001;   //  "Solea SPM: illegal input value"
  public const int  SEPIA2_ERR_SPM_VALUE_OUT_OF_BOUNDS =                                          -7006;   //  "Solea SPM: value out of bounds"
  public const int  SEPIA2_ERR_SPM_FW_OUT_OF_MEMORY =                                             -7011;   //  "Solea SPM FW: out of memory"
  public const int  SEPIA2_ERR_SPM_FW_UPDATE_FAILED =                                             -7013;   //  "Solea SPM FW: update failed"
  public const int  SEPIA2_ERR_SPM_FW_CRC_CHECK_FAILED =                                          -7014;   //  "Solea SPM FW: CRC check failed"
  public const int  SEPIA2_ERR_SPM_FW_FLASH_DELETION_FAILED =                                     -7015;   //  "Solea SPM FW: Flash deletion failed"
  public const int  SEPIA2_ERR_SPM_FW_FILE_OPEN_ERROR =                                           -7021;   //  "Solea SPM FW: file open error"
  public const int  SEPIA2_ERR_SPM_FW_FILE_READ_ERROR =                                           -7022;   //  "Solea SPM FW: file read error"
  public const int  SEPIA2_ERR_SSM_SCALING_TABLES_NOT_FOUND =                                     -7051;   //  "Solea SSM: scaling tables not found"
  public const int  SEPIA2_ERR_SSM_ILLEGAL_TRIGGER_MODE =                                         -7052;   //  "Solea SSM: illegal trigger mode"
  public const int  SEPIA2_ERR_SSM_ILLEGAL_TRIGGER_LEVEL_VALUE =                                  -7053;   //  "Solea SSM: illegal trigger level value"
  public const int  SEPIA2_ERR_SSM_ILLEGAL_CORRECTION_VALUE =                                     -7054;   //  "Solea SSM: illegal correction value"
  public const int  SEPIA2_ERR_SSM_TRIGGER_DATA_NOT_FOUND =                                       -7055;   //  "Solea SSM: trigger data not found"
  public const int  SEPIA2_ERR_SSM_CORRECTION_DATA_COMMAND_NOT_FOUND =                            -7056;   //  "Solea SSM: correction data command not found"
  public const int  SEPIA2_ERR_SWS_SCALING_TABLES_NOT_FOUND =                                     -7101;   //  "Solea SWS: scaling tables not found"
  public const int  SEPIA2_ERR_SWS_ILLEGAL_HW_MODULETYPE =                                        -7102;   //  "Solea SWS: illegal HW moduletype"
  public const int  SEPIA2_ERR_SWS_MODULE_NOT_FUNCTIONAL =                                        -7103;   //  "Solea SWS: module not functional"
  public const int  SEPIA2_ERR_SWS_ILLEGAL_CENTER_WAVELENGTH =                                    -7104;   //  "Solea SWS: illegal center wavelength"
  public const int  SEPIA2_ERR_SWS_ILLEGAL_BANDWIDTH =                                            -7105;   //  "Solea SWS: illegal bandwidth"
  public const int  SEPIA2_ERR_SWS_VALUE_OUT_OF_BOUNDS =                                          -7106;   //  "Solea SWS: value out of bounds"
  public const int  SEPIA2_ERR_SWS_MODULE_BUSY =                                                  -7107;   //  "Solea SWS: module busy"
  public const int  SEPIA2_ERR_SWS_FW_WRONG_COMPONENT_ANSWERING =                                 -7109;   //  "Solea SWS FW: wrong component answering"
  public const int  SEPIA2_ERR_SWS_FW_UNKNOWN_HW_MODULETYPE =                                     -7110;   //  "Solea SWS FW: unknown HW moduletype"
  public const int  SEPIA2_ERR_SWS_FW_OUT_OF_MEMORY =                                             -7111;   //  "Solea SWS FW: out of memory"
  public const int  SEPIA2_ERR_SWS_FW_VERSION_CONFLICT =                                          -7112;   //  "Solea SWS FW: version conflict"
  public const int  SEPIA2_ERR_SWS_FW_UPDATE_FAILED =                                             -7113;   //  "Solea SWS FW: update failed"
  public const int  SEPIA2_ERR_SWS_FW_CRC_CHECK_FAILED =                                          -7114;   //  "Solea SWS FW: CRC check failed"
  public const int  SEPIA2_ERR_SWS_FW_ERROR_ON_FLASH_DELETION =                                   -7115;   //  "Solea SWS FW: error on flash deletion"
  public const int  SEPIA2_ERR_SWS_FW_CALIBRATION_MODE_ERROR =                                    -7116;   //  "Solea SWS FW: calibration mode error"
  public const int  SEPIA2_ERR_SWS_FW_FUNCTION_NOT_IMPLEMENTED_YET =                              -7117;   //  "Solea SWS FW: function not implemented yet"
  public const int  SEPIA2_ERR_SWS_FW_WRONG_CALIBRATION_TABLE_ENTRY =                             -7118;   //  "Solea SWS FW: wrong calibration table entry"
  public const int  SEPIA2_ERR_SWS_FW_INSUFFICIENT_CALIBRATION_TABLE_SIZE =                       -7119;   //  "Solea SWS FW: insufficient calibration table size"
  public const int  SEPIA2_ERR_SWS_FW_FILE_OPEN_ERROR =                                           -7151;   //  "Solea SWS FW: file open error"
  public const int  SEPIA2_ERR_SWS_FW_FILE_READ_ERROR =                                           -7152;   //  "Solea SWS FW: file read error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_INIT_TIMEOUT =                          -7201;   //  "Solea SWS HW: module 0, all motors: init timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_PLAUSI_CHECK =                          -7202;   //  "Solea SWS HW: module 0, all motors: plausi check"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_DAC_SET_CURRENT =                       -7203;   //  "Solea SWS HW: module 0, all motors: DAC set current"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_TIMEOUT=                                -7204;   //  "Solea SWS HW: module 0, all motors: timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_FLASH_WRITE_ERROR =                     -7205;   //  "Solea SWS HW: module 0, all motors: flash write error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_ALL_MOTORS_OUT_OF_BOUNDS =                         -7206;   //  "Solea SWS HW: module 0, all motors: out of bounds"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_I2C_FAILURE =                                      -7207;   //  "Solea SWS HW: module 0: I2C failure"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_INIT_FAILURE =                                     -7208;   //  "Solea SWS HW: module 0: init failure"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_DATA_NOT_FOUND =                           -7210;   //  "Solea SWS HW: module 0, motor 1: data not found"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_INIT_TIMEOUT =                             -7211;   //  "Solea SWS HW: module 0, motor 1: init timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_PLAUSI_CHECK =                             -7212;   //  "Solea SWS HW: module 0, motor 1: plausi check"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_DAC_SET_CURRENT =                          -7213;   //  "Solea SWS HW: module 0, motor 1: DAC set current"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_TIMEOUT =                                  -7214;   //  "Solea SWS HW: module 0, motor 1: timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_FLASH_WRITE_ERROR =                        -7215;   //  "Solea SWS HW: module 0, motor 1: flash write error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_1_OUT_OF_BOUNDS =                            -7216;   //  "Solea SWS HW: module 0, motor 1: out of bounds"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_DATA_NOT_FOUND =                           -7220;   //  "Solea SWS HW: module 0, motor 2: data not found"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_INIT_TIMEOUT =                             -7221;   //  "Solea SWS HW: module 0, motor 2: init timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_PLAUSI_CHECK =                             -7222;   //  "Solea SWS HW: module 0, motor 2: plausi check"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_DAC_SET_CURRENT =                          -7223;   //  "Solea SWS HW: module 0, motor 2: DAC set current"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_TIMEOUT =                                  -7224;   //  "Solea SWS HW: module 0, motor 2: timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_FLASH_WRITE_ERROR =                        -7225;   //  "Solea SWS HW: module 0, motor 2: flash write error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_2_OUT_OF_BOUNDS =                            -7226;   //  "Solea SWS HW: module 0, motor 2: out of bounds"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_DATA_NOT_FOUND =                           -7230;   //  "Solea SWS HW: module 0, motor 3: data not found"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_INIT_TIMEOUT =                             -7231;   //  "Solea SWS HW: module 0, motor 3: init timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_PLAUSI_CHECK =                             -7232;   //  "Solea SWS HW: module 0, motor 3: plausi check"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_DAC_SET_CURRENT =                          -7233;   //  "Solea SWS HW: module 0, motor 3: DAC set current"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_TIMEOUT =                                  -7234;   //  "Solea SWS HW: module 0, motor 3: timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_FLASH_WRITE_ERROR =                        -7235;   //  "Solea SWS HW: module 0, motor 3: flash write error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_0_MOTOR_3_OUT_OF_BOUNDS =                            -7236;   //  "Solea SWS HW: module 0, motor 3: out of bounds"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_INIT_TIMEOUT =                          -7301;   //  "Solea SWS HW: module 1, all motors: init timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_PLAUSI_CHECK =                          -7302;   //  "Solea SWS HW: module 1, all motors: plausi check"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_DAC_SET_CURRENT =                       -7303;   //  "Solea SWS HW: module 1, all motors: DAC set current"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_TIMEOUT =                               -7304;   //  "Solea SWS HW: module 1, all motors: timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_FLASH_WRITE_ERROR =                     -7305;   //  "Solea SWS HW: module 1, all motors: flash write error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_ALL_MOTORS_OUT_OF_BOUNDS =                         -7306;   //  "Solea SWS HW: module 1, all motors: out of bounds"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_I2C_FAILURE =                                      -7307;   //  "Solea SWS HW: module 1: I2C failure"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_INIT_FAILURE =                                     -7308;   //  "Solea SWS HW: module 1: init failure"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_DATA_NOT_FOUND =                           -7310;   //  "Solea SWS HW: module 1, motor 1: data not found"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_INIT_TIMEOUT =                             -7311;   //  "Solea SWS HW: module 1, motor 1: init timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_PLAUSI_CHECK =                             -7312;   //  "Solea SWS HW: module 1, motor 1: plausi check"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_DAC_SET_CURRENT =                          -7313;   //  "Solea SWS HW: module 1, motor 1: DAC set current"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_TIMEOUT =                                  -7314;   //  "Solea SWS HW: module 1, motor 1: timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_FLASH_WRITE_ERROR =                        -7315;   //  "Solea SWS HW: module 1, motor 1: flash write error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_1_OUT_OF_BOUNDS =                            -7316;   //  "Solea SWS HW: module 1, motor 1: out of bounds"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_DATA_NOT_FOUND =                           -7320;   //  "Solea SWS HW: module 1, motor 2: data not found"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_INIT_TIMEOUT =                             -7321;   //  "Solea SWS HW: module 1, motor 2: init timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_PLAUSI_CHECK =                             -7322;   //  "Solea SWS HW: module 1, motor 2: plausi check"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_DAC_SET_CURRENT =                          -7323;   //  "Solea SWS HW: module 1, motor 2: DAC set current"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_TIMEOUT =                                  -7324;   //  "Solea SWS HW: module 1, motor 2: timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_FLASH_WRITE_ERROR =                        -7325;   //  "Solea SWS HW: module 1, motor 2: flash write error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_2_OUT_OF_BOUNDS =                            -7326;   //  "Solea SWS HW: module 1, motor 2: out of bounds"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_DATA_NOT_FOUND =                           -7330;   //  "Solea SWS HW: module 1, motor 3: data not found"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_INIT_TIMEOUT =                             -7331;   //  "Solea SWS HW: module 1, motor 3: init timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_PLAUSI_CHECK =                             -7332;   //  "Solea SWS HW: module 1, motor 3: plausi check"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_DAC_SET_CURRENT =                          -7333;   //  "Solea SWS HW: module 1, motor 3: DAC set current"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_TIMEOUT =                                  -7334;   //  "Solea SWS HW: module 1, motor 3: timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_FLASH_WRITE_ERROR =                        -7335;   //  "Solea SWS HW: module 1, motor 3: flash write error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_1_MOTOR_3_OUT_OF_BOUNDS =                            -7336;   //  "Solea SWS HW: module 1, motor 3: out of bounds"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_INIT_TIMEOUT =                          -7401;   //  "Solea SWS HW: module 2, all motors: init timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_PLAUSI_CHECK =                          -7402;   //  "Solea SWS HW: module 2, all motors: plausi check"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_DAC_SET_CURRENT =                       -7403;   //  "Solea SWS HW: module 2, all motors: DAC set current"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_TIMEOUT =                               -7404;   //  "Solea SWS HW: module 2, all motors: timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_FLASH_WRITE_ERROR =                     -7405;   //  "Solea SWS HW: module 2, all motors: flash write error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_ALL_MOTORS_OUT_OF_BOUNDS =                         -7406;   //  "Solea SWS HW: module 2, all motors: out of bounds"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_I2C_FAILURE =                                      -7407;   //  "Solea SWS HW: module 2: I2C failure"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_INIT_FAILURE =                                     -7408;   //  "Solea SWS HW: module 2: init failure"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_DATA_NOT_FOUND =                           -7410;   //  "Solea SWS HW: module 2, motor 1: data not found"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_INIT_TIMEOUT =                             -7411;   //  "Solea SWS HW: module 2, motor 1: init timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_PLAUSI_CHECK =                             -7412;   //  "Solea SWS HW: module 2, motor 1: plausi check"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_DAC_SET_CURRENT =                          -7413;   //  "Solea SWS HW: module 2, motor 1: DAC set current"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_TIMEOUT =                                  -7414;   //  "Solea SWS HW: module 2, motor 1: timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_FLASH_WRITE_ERROR =                        -7415;   //  "Solea SWS HW: module 2, motor 1: flash write error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_1_OUT_OF_BOUNDS =                            -7416;   //  "Solea SWS HW: module 2, motor 1: out of bounds"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_DATA_NOT_FOUND =                           -7420;   //  "Solea SWS HW: module 2, motor 2: data not found"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_INIT_TIMEOUT =                             -7421;   //  "Solea SWS HW: module 2, motor 2: init timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_PLAUSI_CHECK =                             -7422;   //  "Solea SWS HW: module 2, motor 2: plausi check"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_DAC_SET_CURRENT =                          -7423;   //  "Solea SWS HW: module 2, motor 2: DAC set current"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_TIMEOUT =                                  -7424;   //  "Solea SWS HW: module 2, motor 2: timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_FLASH_WRITE_ERROR =                        -7425;   //  "Solea SWS HW: module 2, motor 2: flash write error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_2_OUT_OF_BOUNDS =                            -7426;   //  "Solea SWS HW: module 2, motor 2: out of bounds"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_DATA_NOT_FOUND =                           -7430;   //  "Solea SWS HW: module 2, motor 3: data not found"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_INIT_TIMEOUT =                             -7431;   //  "Solea SWS HW: module 2, motor 3: init timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_PLAUSI_CHECK =                             -7432;   //  "Solea SWS HW: module 2, motor 3: plausi check"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_DAC_SET_CURRENT =                          -7433;   //  "Solea SWS HW: module 2, motor 3: DAC set current"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_TIMEOUT =                                  -7434;   //  "Solea SWS HW: module 2, motor 3: timeout"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_FLASH_WRITE_ERROR =                        -7435;   //  "Solea SWS HW: module 2, motor 3: flash write error"
  public const int  SEPIA2_ERR_SWS_HW_MODULE_2_MOTOR_3_OUT_OF_BOUNDS =                            -7436;   //  "Solea SWS HW: module 2, motor 3: out of bounds"

  public const int  SEPIA2_ERR_LIB_TOO_MANY_USB_HANDLES =                                         -9001;   //  "LIB: too many USB handles"
  public const int  SEPIA2_ERR_LIB_ILLEGAL_DEVICE_INDEX =                                         -9002;   //  "LIB: illegal device index"
  public const int  SEPIA2_ERR_LIB_USB_DEVICE_OPEN_ERROR =                                        -9003;   //  "LIB: USB device open error"
  public const int  SEPIA2_ERR_LIB_USB_DEVICE_BUSY_OR_BLOCKED =                                   -9004;   //  "LIB: USB device busy or blocked"
  public const int  SEPIA2_ERR_LIB_USB_DEVICE_ALREADY_OPENED =                                    -9005;   //  "LIB: USB device already opened"
  public const int  SEPIA2_ERR_LIB_UNKNOWN_USB_HANDLE =                                           -9006;   //  "LIB: unknown USB handle"
  public const int  SEPIA2_ERR_LIB_SCM_828_MODULE_NOT_FOUND =                                     -9007;   //  "LIB: SCM 828 module not found"
  public const int  SEPIA2_ERR_LIB_ILLEGAL_SLOT_NUMBER =                                          -9008;   //  "LIB: illegal slot number"
  public const int  SEPIA2_ERR_LIB_REFERENCED_SLOT_IS_NOT_IN_USE =                                -9009;   //  "LIB: referenced slot is not in use"
  public const int  SEPIA2_ERR_LIB_THIS_IS_NO_SCM_828_MODULE =                                    -9010;   //  "LIB: this is no SCM 828 module"
  public const int  SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_MODULE =                                    -9011;   //  "LIB: this is no SOM 828 module"
  public const int  SEPIA2_ERR_LIB_THIS_IS_NO_SLM_828_MODULE =                                    -9012;   //  "LIB: this is no SLM 828 module"
  public const int  SEPIA2_ERR_LIB_THIS_IS_NO_SML_828_MODULE =                                    -9013;   //  "LIB: this is no SML 828 module"
  public const int  SEPIA2_ERR_LIB_THIS_IS_NO_SWM_828_MODULE =                                    -9014;   //  "LIB: this is no SWM 828 module"
  public const int  SEPIA2_ERR_LIB_THIS_IS_NO_SOLEA_SSM_MODULE =                                  -9015;   //  "LIB: this is no Solea SSM module"
  public const int  SEPIA2_ERR_LIB_THIS_IS_NO_SOLEA_SWS_MODULE =                                  -9016;   //  "LIB: this is no Solea SWS module"
  public const int  SEPIA2_ERR_LIB_THIS_IS_NO_SOLEA_SPM_MODULE =                                  -9017;   //  "LIB: this is no Solea SPM module"
  public const int  SEPIA2_ERR_LIB_THIS_IS_NO_LMP1 =                                              -9018;   //  "LIB: this is no LMP1 (metermodule w. shuttercontrol)"
  public const int  SEPIA2_ERR_LIB_THIS_IS_NO_SOM_828_D_MODULE =                                  -9019;   //  "LIB: this is no SOM 828 D module"
  public const int  SEPIA2_ERR_LIB_NO_MAP_FOUND =                                                 -9020;   //  "LIB: no map found"
  public const int  SEPIA2_ERR_LIB_THIS_IS_NO_LMP8 =                                              -9021;   //  "LIB: this is no LMP8 (eightfold metermodule)"
  public const int  SEPIA2_ERR_LIB_DEVICE_CHANGED_RE_INITIALISE_USB_DEVICE_LIST =                 -9025;   //  "LIB: device changed, re-initialise USB device list"
  public const int  SEPIA2_ERR_LIB_INAPPROPRIATE_USB_DEVICE =                                     -9026;   //  "LIB: inappropriate USB device"
  public const int  SEPIA2_ERR_LIB_WRONG_USB_DRIVER_VERSION =                                     -9090;   //  "LIB: wrong USB driver version"
  public const int  SEPIA2_ERR_LIB_UNKNOWN_FUNCTION =                                             -9900;   //  "LIB: unknown function"
  public const int  SEPIA2_ERR_LIB_ILLEGAL_PARAMETER_ON_FUNCTION_CALL =                           -9910;   //  "LIB: illegal parameter on function call"
  public const int  SEPIA2_ERR_LIB_UNKNOWN_ERROR_CODE =                                           -9999;   //  "LIB: unknown error code"



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

  public const int LIB_VERSION_REFERENCE_COMPLEN =                  7;

  public const string  FW_VERSION_REFERENCE =                       "1.05.";

  public const int  FW_VERSION_REFERENCE_COMPLEN =                  5;

  public const int  SEPIA2_MAX_USB_DEVICES =                        8;

  public const int  SEPIA2_SOM_BURSTCHANNEL_COUNT =                 8;

  public const int  SEPIA2_RESTART =                                1;
  public const int  SEPIA2_NO_RESTART =                             0;

  public const int  SEPIA2_LASER_LOCKED =                           1;
  public const int  SEPIA2_LASER_UNLOCKED =                         0;

  public const int  SEPIA2_PRIMARY_MODULE =                         1;
  public const int  SEPIA2_SECONDARY_MODULE =                       0;

  public const int  SEPIA2_SLM_PULSE_MODE =                         1;
  public const int  SEPIA2_SLM_CW_MODE =                            0;

  public const int  SEPIA2_SML_PULSE_MODE =                         1;
  public const int  SEPIA2_SML_CW_MODE =                            0;

  public const int  SEPIA2_SOM_INVERSE_SYNC_MASK =                  1;
  public const int  SEPIA2_SOM_STANDARD_SYNC_MASK =                 0;


  public const int  SEPIA2_USB_STRDECR_LEN =                      256;
  public const int  SEPIA2_VERSIONINFO_LEN =                       11;    // "1.1.xx.nnn\0" where xx is either 32 or 64 and nnn is the SVN build number
  public const int  SEPIA2_ERRSTRING_LEN =                         64;

  public const int  SEPIA2_FW_ERRCOND_LEN =                        55;

  public const int  SEPIA2_FW_ERRPHASE_LEN =                       24;
  public const int  SEPIA2_SERIALNUMBER_LEN =                      13;
  public const int  SEPIA2_PRODUCTMODEL_LEN =                      33;
  public const int  SEPIA2_MODULETYPESTRING_LEN =                  55;
  public const int  SEPIA2_SLM_FREQ_TRIGMODE_LEN =                 28;
  public const int  SEPIA2_SLM_HEADTYPE_LEN =                      18;
  public const int  SEPIA2_SOM_FREQ_TRIGMODE_LEN =                 32;
  public const int  SEPIA2_SWS_MODULETYPE_MAXLEN =                 20;
  public const int  SEPIA2_SWS_MODULESTATE_MAXLEN =                20;
  //
  //                                                                       //              bit  7         6         5     4    3      2..0
  //      SepiaObjTyp                                                      //                   L module  secondary            S
  //           -                                                           //                   /         /         laser osc  /      typecnt
  //   construction table                                                  //                   H backpl  primary              L or F
  //
  public const int  SEPIA2OBJECT_FRMS =                             0xC0;  // 1 1 00  0 000     backplane primary   no    no   small
  public const int  SEPIA2OBJECT_FRML =                             0xC8;  // 1 1 00  1 000     backplane primary   no    no   large
  public const int  SEPIA2OBJECT_FRXS =                             0x80;  // 1 0 00  0 000     backplane secondary no    no   small
  public const int  SEPIA2OBJECT_FRXL =                             0x88;  // 1 0 00  1 000     backplane secondary no    no   large
  public const int  SEPIA2OBJECT_SCM =                              0x40;  // 0 1 00  0 000     module    primary   no    no   d.c.          // for Sepia II Controller Modules
  public const int  SEPIA2OBJECT_SCX =                              0x41;  // 0 1 00  0 001     module    primary   no    no   d.c.          // for simulation
  public const int  SEPIA2OBJECT_SLT =                              0x42;  // 0 1 00  0 010     module    primary   no    no   d.c.          // for test
  public const int  SEPIA2OBJECT_SWM =                              0x43;  // 0 1 00  0 011     module    primary   no    no   d.c.          // for PULSAR Waveform Modules
  public const int  SEPIA2OBJECT_SWS =                              0x44;  // 0 1 00  0 100     module    primary   no    no   d.c.          // for Solea  Wavelength Selectors
  public const int  SEPIA2OBJECT_SPM =                              0x45;  // 0 1 00  0 101     module    primary   no    no   d.c.          // for Solea  Pumpcontrol Modules
  public const int  SEPIA2OBJECT_LMP =                              0x46;  // 0 1 00  0 110     module    primary   no    no   d.c.          // Laser test site
  public const int  SEPIA2OBJECT_SOM =                              0x50;  // 0 1 01  0 000     module    primary   no    yes  d.c.   0-7    // for Sepia II Oscillator Modules
  public const int  SEPIA2OBJECT_SOMD =                             0x51;  // 0 1 01  0 001     module    primary   no    yes  d.c.   0-7    // for Sepia II Oscillator Modules with Delay
  public const int  SEPIA2OBJECT_SML =                              0x60;  // 0 1 10  0 000     module    primary   yes   no   d.c.   0-7    // for Sepia II Multi Laser Modules
  public const int  SEPIA2OBJECT_VCL =                              0x61;  // 0 1 10  0 000     module    primary   yes   no   d.c.   1      // for PPL 400  Voltage Controlled Laser Modules
  public const int  SEPIA2OBJECT_SLM =                              0x70;  // 0 1 11  0 000     module    primary   yes   yes  d.c.          // for Sepia II Laser Modules
  public const int  SEPIA2OBJECT_SSM =                              0x71;  // 0 1 11  0 001     module    primary   yes   yes  d.c.          // for Solea  Seed Modules
  public const int  SEPIA2OBJECT_LHS =                              0x20;  // 0 0 10  0 000     module    secondary yes   no   slow   0-7
  public const int  SEPIA2OBJECT_LHF =                              0x28;  // 0 0 10  1 000     module    secondary yes   no   fast
  public const int  SEPIA2OBJECT_LH_ =                              0x29;  // 0 0 10  1 001     module    secondary yes   no   fast
  public const int  SEPIA2OBJECT_FAIL =                             0xFF;

  public const int  SEPIA2_SLM_FREQ_80MHZ =                         0;
  public const int  SEPIA2_SLM_FREQ_40MHZ =                         1;
  public const int  SEPIA2_SLM_FREQ_20MHZ =                         2;
  public const int  SEPIA2_SLM_FREQ_10MHZ =                         3;
  public const int  SEPIA2_SLM_FREQ_5MHZ =                          4;
  public const int  SEPIA2_SLM_FREQ_2_5MHZ =                        5;
  public const int  SEPIA2_SLM_TRIGMODE_RAISING =                   6;
  public const int  SEPIA2_SLM_TRIGMODE_FALLING =                   7;
  public const int  SEPIA2_SLM_FREQ_TRIGMODE_COUNT =                8;


  public const int  SEPIA2_SLM_HEADTYPE_FAILURE =                   0;
  public const int  SEPIA2_SLM_HEADTYPE_LED =                       1;
  public const int  SEPIA2_SLM_HEADTYPE_LASER =                     2;
  public const int  SEPIA2_SLM_HEADTYPE_NONE =                      3;
  public const int  SEPIA2_SLM_HEADTYPE_COUNT =                     4;


  public const int  SEPIA2_SML_HEADTYPE_FAILURE =                   0;
  public const int  SEPIA2_SML_HEADTYPE_4_LEDS =                    1;
  public const int  SEPIA2_SML_HEADTYPE_4_LASERS =                  2;
  public const int  SEPIA2_SML_HEADTYPE_COUNT =                     3;

  public const int  SEPIA2_SOM_TRIGGERLEVEL_STEP =                 20; // in mV
  public const int  SEPIA2_SOM_TRIGGERLEVEL_HALFSTEP =              (SEPIA2_SOM_TRIGGERLEVEL_STEP / 2);
  public const int  SEPIA2_SOM_TRIGMODE_RISING =                    0;
  public const int  SEPIA2_SOM_TRIGMODE_FALLING =                   1;
  public const int  SEPIA2_SOM_INT_OSC_A =                          2;
  public const int  SEPIA2_SOM_INT_OSC_B =                          3;
  public const int  SEPIA2_SOM_INT_OSC_C =                          4;
  public const int  SEPIA2_SOM_FREQ_TRIGMODE_COUNT =                5;

  public const int  SEPIA2_SWM_CURVES_COUNT =                       2;
  public const int  SEPIA2_SWM_TIMEBASE_RANGES_COUNT =              3;
  //
  public const int  SEPIA2_SWM_UI_TABIDX_RESOLUTION =               0;
  public const int  SEPIA2_SWM_UI_TABIDX_MIN_USERVALUE =            1;
  public const int  SEPIA2_SWM_UI_TABIDX_MAX_USERVALUE =            2;
  public const int  SEPIA2_SWM_UI_TABIDX_USER_RESOLUTION =          3;
  public const int  SEPIA2_SWM_UI_TABIDX_MAX_AMPLITUDE =            4;
  public const int  SEPIA2_SWM_UI_TABIDX_MAX_SLEWRATE =             5;
  public const int  SEPIA2_SWM_UI_TABIDX_EXP_RAMP_EFFECT =          6;
  public const int  SEPIA2_SWM_UI_TABIDX_TIMEBASERANGES_COUNT =     7;
  public const int  SEPIA2_SWM_UI_TABIDX_PULSEDATA_COUNT =          8;
  public const int  SEPIA2_SWM_UI_TABIDX_RAMPDATA_COUNT =           9;
  public const int  SEPIA2_SWM_UI_TABIDX_DELAYDATA_TB0_COUNT =     10;
  public const int  SEPIA2_SWM_UI_TABIDX_DELAYDATA_TB1_COUNT =     11;
  public const int  SEPIA2_SWM_UI_TABIDX_DELAYDATA_TB2_COUNT =     12;

  [StructLayout(LayoutKind.Sequential, Pack = 1)]
  public struct T_Module_FWVers {
    public ushort  BuildNr;
    public byte    VersMin;
    public byte    VersMaj;
  };

  public const int  SEPIA2_SPM_TEMPERATURE_SENSORCOUNT =          6;
  public const int  SEPIA2_SPM_ALL_SENSORCOUNT =                  SEPIA2_SPM_TEMPERATURE_SENSORCOUNT + 3;

  public struct T_SPM_Temperatures {
    // use this ushort [] as call parameter for function SEPIA2_SPM_GetTemperatureAdjust
    public ushort[] wArray;

    public T_SPM_Temperatures (int unnecessary) {
      wArray = new ushort[SEPIA2_SPM_TEMPERATURE_SENSORCOUNT];
    }

    // there are fixed positions of the values in the array
    public const int index_wT_Pump1 = 0;
    public const int index_wT_Pump2 = 1;
    public const int index_wT_Pump3 = 2;
    public const int index_wT_Pump4 = 3;
    public const int index_wT_FiberStack = 4;
    public const int index_wT_AuxAdjust = 5;

    public ushort wT_Pump1 {
      get { return wArray [index_wT_Pump1]; }
      set { wArray [index_wT_Pump1] = value; }
    }

    public ushort wT_Pump2 {
      get { return wArray [index_wT_Pump2]; }
      set { wArray [index_wT_Pump2] = value; }
    }

    public ushort wT_Pump3 {
      get { return wArray [index_wT_Pump3]; }
      set { wArray [index_wT_Pump3] = value; }
    }

    public ushort wT_Pump4 {
      get { return wArray [index_wT_Pump4]; }
      set { wArray [index_wT_Pump4] = value; }
    }

    public ushort wT_FiberStack {
      get { return wArray [index_wT_FiberStack]; }
      set { wArray [index_wT_FiberStack] = value; }
    }

    public ushort wT_AuxAdjust {
      get { return wArray [index_wT_AuxAdjust]; }
      set { wArray [index_wT_AuxAdjust] = value; }
    }
  }

  public struct T_SPM_SensorData {
    // use this ushort [] as call parameter for function SEPIA2_SPM_GetSensorData
    public ushort [] wArray;

    public T_SPM_SensorData (int unnecessary) {
      wArray = new ushort[SEPIA2_SPM_ALL_SENSORCOUNT];
    }

    // there are fixed positions of the values in the array
    public const int index_wOverAllCurrent  = SEPIA2_SPM_TEMPERATURE_SENSORCOUNT + 0;
    public const int index_wOptionalSensor1 = SEPIA2_SPM_TEMPERATURE_SENSORCOUNT + 1;
    public const int index_wOptionalSensor2 = SEPIA2_SPM_TEMPERATURE_SENSORCOUNT + 2;

    public T_SPM_Temperatures Temperatures {
      get { 
        T_SPM_Temperatures sTemperatures = new T_SPM_Temperatures (0);
        int i;
        for (i = 0; i < SEPIA2_SPM_TEMPERATURE_SENSORCOUNT; ++i)
          sTemperatures.wArray[i] = wArray [i];
        return sTemperatures;
      }
      set {
        int i;
        for (i = 0; i < SEPIA2_SPM_TEMPERATURE_SENSORCOUNT; ++i)
          wArray[i] = value.wArray[i];
      }
    }

    public ushort wOverAllCurrent {
      get { return wArray [index_wOverAllCurrent]; }
      set { wArray [index_wOverAllCurrent] = value; }
    }

    public ushort wOptionalSensor1 {
      get { return wArray [index_wOptionalSensor1]; }
      set { wArray [index_wOptionalSensor1] = value; }
    }

    public ushort wOptionalSensor2 {
      get { return wArray [index_wOptionalSensor2]; }
      set { wArray [index_wOptionalSensor2] = value; }
    }
  };


  //-----------------------------------------------------------------------------
  //
  //      SEPIA2_Lib.h
  //
  //-----------------------------------------------------------------------------
  //
  //  functions exported by SEPIA2_Lib
  //
  //-----------------------------------------------------------------------------
  //  HISTORY:
  //
  //  apo  22.12.05   release of the library interface
  //
  //  apo  12.02.07   introduced SML Multilaser Module (V1.0.2.0)
  //
  //  apo  02.12.09   introduced SWM Pulsar Waveform Module (V1.0.2.1)
  //
  //  apo  04.01.10   introduced function SEPIA2_SWM_GetUIConstants
  //
  //  apo  14.08.12   re-introduced all strictly internal functions
  //                    encapsulated by compiler switch  __STRICTLY_PQ_INTERNAL__
  //
  //  apo  14.08.12   introduced Solea SWS functions (solea wavelength selector)
  //
  //  apo  04.09.12   introduced Solea SSM functions (solea seed module)
  //
  //  apo  11.04.13   introduced COM functions for two presets
  //
  //  apo  23.04.13   introduced Solea SPM functions (solea pump control)
  //
  //  apo  07.05.13   introduced LMP module functions for PQ internal laser test site
  //
  //  apo  22.05.13   introduced new SLM functions with intensity on permille domain
  //                  primarily intended for laser test site (LMP), but released
  //                  as a common feature;
  //                  thus old SLM functions on percentage domain are deprecated
  //
  //  apo  31.05.13   introduced new SWS function ReInitMotor
  //
  //  apo  04.06.13   introduced new SWS function UpdateFirmware
  //
  //  apo  05.06.13   SWS command code 0x04 was withdrawn:
  //                    get status is now integrated with get error -> GetStatusError
  //
  //  apo  06.11.13   introduced new FWR function GetModuleInfoByMapIdx
  //
  //  apo  15.07.14   introduced new SOMD feature: 
  //                    Base oscillator predivider is now 16bit
  //
  //  apo  16.07.14   introduced new SOM/SOMD functions Get/Set AUXIOSequencerCtrl
  //
  //  apo  24.04.15   introduced new SOMD function DecodeModuleState
  //
  //-----------------------------------------------------------------------------
  //

  // ---  library functions  --------------------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_LIB_DecodeError (int iErrCode, StringBuilder cErrorString);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_LIB_GetVersion (StringBuilder cLibVersion);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_LIB_IsRunningOnWine (out byte pbIsRunningOnWine);

  // ---  USB functions  ------------------------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_USB_OpenDevice (int iDevIdx, StringBuilder cProductModel, StringBuilder cSerialNumber);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_USB_OpenGetSerNumAndClose (int iDevIdx, StringBuilder cProductModel, StringBuilder cSerialNumber);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_USB_GetStrDescriptor (int iDevIdx, StringBuilder cDescriptor);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_USB_CloseDevice (int iDevIdx);

  // ---  firmware functions  -------------------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_FWR_DecodeErrPhaseName (int iErrPhase, StringBuilder cErrorPhase);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_FWR_GetVersion (int iDevIdx, StringBuilder cFWVersion);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_FWR_GetLastError (int iDevIdx, out int piErrCode, out int piPhase, out int piLocation, out int piSlot, StringBuilder cCondition);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_FWR_GetModuleMap (int iDevIdx, int iPerformRestart, out int piModuleCount);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_FWR_GetModuleInfoByMapIdx (int iDevIdx, int iMapIdx, out int piSlotId, out byte pbIsPrimary, out byte pbIsBackPlane, out byte pbHasUptimeCounter);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_FWR_GetUptimeInfoByMapIdx (int iDevIdx, int iMapIdx, out uint pulMainPowerUp, out uint pulActivePowerUp, out uint pulScaledPowerUp);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_FWR_CreateSupportRequestText (int iDevIdx, StringBuilder cPreamble, StringBuilder cCallingSW, int iOptions, int iBufferLen, StringBuilder cBuffer);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_FWR_FreeModuleMap (int iDevIdx);

  // ---  common module functions  --------------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_COM_DecodeModuleType (int iModuleType, StringBuilder cModulType);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_COM_DecodeModuleTypeAbbr (int iModuleType, StringBuilder cModulTypeAbbr);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_COM_Slot2PathString (int iDevIdx, int iSlotId, StringBuilder pcPath);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_COM_GetModuleType (int iDevIdx, int iSlotId, int iGetPrimary, out int piModuleType);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_COM_HasSecondaryModule (int iDevIdx, int iSlotId, out int piHasSecondary);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_COM_GetSerialNumber (int iDevIdx, int iSlotId, int iGetPrimary, StringBuilder cSerialNumber);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_COM_GetSupplementaryInfos (int iDevIdx, int iSlotId, int iGetPrimary, StringBuilder cLabel, StringBuilder cReleaseDate, StringBuilder cRevision, StringBuilder cHdrMemo);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_COM_GetPresetInfo (int iDevIdx, int iSlotId, int iGetPrimary, int iPresetNr, out byte pbIsSet, StringBuilder cPresetMemo);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_COM_RecallPreset (int iDevIdx, int iSlotId, int iGetPrimary, int iPresetNr);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_COM_SaveAsPreset (int iDevIdx, int iSlotId, int iSetPrimary, int iPresetNr, StringBuilder cPresetMemo);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_COM_IsWritableModule (int iDevIdx, int iSlotId, int iGetPrimary, out byte pbIsWritable);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_COM_UpdateModuleData (int iDevIdx, int iSlotId, int iSetPrimary, StringBuilder pcDCLFileName);

  // ---  SCM 828 functions  --------------------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SCM_GetPowerAndLaserLEDS (int iDevIdx, int iSlotId, out byte pbPowerLED, out byte pbLaserActiveLED);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SCM_GetLaserLocked (int iDevIdx, int iSlotId, out byte pbLocked);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SCM_GetLaserSoftLock (int iDevIdx, int iSlotId, out byte pbSoftLocked);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SCM_SetLaserSoftLock (int iDevIdx, int iSlotId, byte bSoftLocked);

  // ---  SLM 828 functions  --------------------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SLM_DecodeFreqTrigMode (int iFreq, StringBuilder cFreqTrigMode);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SLM_DecodeHeadType (int iHeadType, StringBuilder cHeadType);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SLM_GetIntensityFineStep (int iDevIdx, int iSlotId, out ushort pwIntensity);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SLM_SetIntensityFineStep (int iDevIdx, int iSlotId, ushort wIntensity);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SLM_GetPulseParameters (int iDevIdx, int iSlotId, out int piFreq, out byte pbPulseMode, out int piHeadType);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SLM_SetPulseParameters (int iDevIdx, int iSlotId, int iFreq, byte bPulseMode);

  // ---  SML 828 functions  --------------------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SML_DecodeHeadType (int iHeadType, StringBuilder cHeadType);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SML_GetParameters (int iDevIdx, int iSlotId, out byte pbPulseMode, out int piHead, out byte pbIntensity);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SML_SetParameters (int iDevIdx, int iSlotId, byte bPulseMode, byte bIntensity);

  // ---  SOM 828 functions  --------------------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_DecodeFreqTrigMode (int iDevIdx, int iSlotId, int iFreqTrigMode, StringBuilder cFreqTrigMode);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_GetFreqTrigMode (int iDevIdx, int iSlotId, out int piFreqTrigMode);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_SetFreqTrigMode (int iDevIdx, int iSlotId, int iFreqTrigMode);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_GetTriggerRange (int iDevIdx, int iSlotId, out int piMilliVoltLow, out int piMilliVoltHigh);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_GetTriggerLevel (int iDevIdx, int iSlotId, out int piMilliVolt);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_SetTriggerLevel (int iDevIdx, int iSlotId, int iMilliVolt);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_GetBurstValues (int iDevIdx, int iSlotId, out byte pbDivider, out byte pbPreSync, out byte pbMaskSync);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_SetBurstValues (int iDevIdx, int iSlotId, byte bDivider, byte bPreSync, byte bMaskSync);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_GetBurstLengthArray (int iDevIdx, int iSlotId, out int plBurstLen1, out int plBurstLen2, out int plBurstLen3, out int plBurstLen4, out int plBurstLen5, out int plBurstLen6, out int plBurstLen7, out int plBurstLen8);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_SetBurstLengthArray (int iDevIdx, int iSlotId, int lBurstLen1, int lBurstLen2, int lBurstLen3, int lBurstLen4, int lBurstLen5, int lBurstLen6, int lBurstLen7, int lBurstLen8);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_GetOutNSyncEnable (int iDevIdx, int iSlotId, out byte pbOutEnable, out byte pbSyncEnable, out byte pbSyncInverse);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_SetOutNSyncEnable (int iDevIdx, int iSlotId, byte bOutEnable, byte bSyncEnable, byte bSyncInverse);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_DecodeAUXINSequencerCtrl (int iAUXInCtrl, StringBuilder cSequencerCtrl);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_GetAUXIOSequencerCtrl (int iDevIdx, int iSlotId, out byte pbAUXOutCtrl, out byte pbAUXInCtrl);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOM_SetAUXIOSequencerCtrl (int iDevIdx, int iSlotId, byte bAUXOutCtrl, byte bAUXInCtrl);

  // ---  SOM 828 D functions  --------------------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_DecodeFreqTrigMode (int iDevIdx, int iSlotId, int iFreqTrigIdx, StringBuilder cFreqTrigMode);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetFreqTrigMode (int iDevIdx, int iSlotId, out int piFreqTrigIdx, out byte pbSynchronize);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_SetFreqTrigMode (int iDevIdx, int iSlotId, int iFreqTrigIdx, byte bSynchronize);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetTriggerRange (int iDevIdx, int iSlotId, out int piMilliVoltLow, out int piMilliVoltHigh);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetTriggerLevel (int iDevIdx, int iSlotId, out int piMilliVolt);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_SetTriggerLevel (int iDevIdx, int iSlotId, int iMilliVolt);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetBurstValues (int iDevIdx, int iSlotId, out ushort pwDivider, out byte pbPreSync, out byte pbMaskSync);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_SetBurstValues (int iDevIdx, int iSlotId, ushort wDivider, byte bPreSync, byte bMaskSync);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetBurstLengthArray (int iDevIdx, int iSlotId, out int plBurstLen1, out int plBurstLen2, out int plBurstLen3, out int plBurstLen4, out int plBurstLen5, out int plBurstLen6, out int plBurstLen7, out int plBurstLen8);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_SetBurstLengthArray (int iDevIdx, int iSlotId, int lBurstLen1, int lBurstLen2, int lBurstLen3, int lBurstLen4, int lBurstLen5, int lBurstLen6, int lBurstLen7, int lBurstLen8);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetOutNSyncEnable (int iDevIdx, int iSlotId, out byte pbOutEnable, out byte pbSyncEnable, out byte pbSyncInverse);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_SetOutNSyncEnable (int iDevIdx, int iSlotId, byte bOutEnable, byte bSyncEnable, byte bSyncInverse);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_DecodeAUXINSequencerCtrl (int iAUXInCtrl, StringBuilder cSequencerCtrl);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetAUXIOSequencerCtrl (int iDevIdx, int iSlotId, out byte pbAUXOutCtrl, out byte pbAUXInCtrl);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_SetAUXIOSequencerCtrl (int iDevIdx, int iSlotId, byte bAUXOutCtrl, byte bAUXInCtrl);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetSeqOutputInfos (int iDevIdx, int iSlotId, byte bSeqOutIdx, out byte pbDelayed, out byte pbForcedUndelayed, out byte pbOutCombi, out byte pbMaskedCombi, ref double pf64CoarseDly, out byte pbFineDly);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_SetSeqOutputInfos (int iDevIdx, int iSlotId, byte bSeqOutIdx, byte bDelayed, byte bOutCombi, byte bMaskedCombi, ref double fCoarseDly, byte bFineDly);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_SynchronizeNow (int iDevIdx, int iSlotId);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_DecodeModuleState (ushort wState, StringBuilder cStatusText);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetStatusError (int iDevIdx, int iSlotId, out ushort pwState, out short piErrorCode);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetTrigSyncFreq (int iDevIdx, int iSlotId, out byte pbFreqStable, out uint pulTrigSyncFreq);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetDelayUnits (int iDevIdx, int iSlotId, ref double pfCoarseDlyStep, out byte pbFineDlyStepCount);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetFWVersion (int iDevIdx, int iSlotId, out uint pulFWVersion);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_FWReadPage (int iDevIdx, int iSlotId, ushort iPageIdx, out byte pbFWPage);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_FWWritePage (int iDevIdx, int iSlotId, ushort iPageIdx, out byte pbFWPage);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_Calibrate (int iDevIdx, int iSlotId, byte bCalParam);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SOMD_GetHWParams (int iDevIdx, int iSlotId, out ushort pwHWParTemp1, out ushort pwHWParTemp2, out ushort pwHWParTemp3, out ushort pwHWParVolt1, out ushort pwHWParVolt2, out ushort pwHWParVolt3, out ushort pwHWParVolt4, out ushort pwHWParAUX);

  // ---  SWM 828 functions (PPL400)  -----------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWM_DecodeRangeIdx (int iDevIdx, int iSlotId, int iRangeIdx, out int iUpperLimit);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWM_GetUIConstants (int iDevIdx, int iSlotId, out byte bTBNdxCount, out ushort wMaxAmplitude, out ushort wMaxSlewRate, out ushort wExpRampEffect, out ushort wMinUserValue, out ushort wMaxUserValue, out ushort wUserResolution);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWM_GetCurveParams (int iDevIdx, int iSlotId, int iCurveIdx, out byte bTBNdx, out ushort wPAPml, out ushort wRRPml, out ushort wPSPml, out ushort wRSPml, out ushort wWSPml);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWM_SetCurveParams (int iDevIdx, int iSlotId, int iCurveIdx, byte bTBNdx, ushort wPAPml, ushort wRRPml, ushort wPSPml, ushort wRSPml, ushort wWSPml);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWM_GetCalTableVal (int iDevIdx, int iSlotId, StringBuilder cTableName, byte bTabIdx, byte bTabCol, out ushort wValue);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWM_GetExtAtten (int iDevIdx, int iSlotId, out float fExtAtt);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWM_SetExtAtten (int iDevIdx, int iSlotId, float fExtAtt);

  // ---  VCL 828 functions (PPL400)  -----------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_VCL_GetUIConstants (int iDevIdx, int iSlotId, out int piMinUserValueTmp, out int piMaxUserValueTmp, out int piUserResolutionTmp);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_VCL_GetTemperature (int iDevIdx, int iSlotId, out int piTemperature);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_VCL_SetTemperature (int iDevIdx, int iSlotId, int iTemperature);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_VCL_GetBiasVoltage (int iDevIdx, int iSlotId, out int piBiasVoltage);

  // ---  SPM functions (Solea)  ----------------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SPM_DecodeModuleState (ushort wState, StringBuilder cStatusText);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SPM_GetFWVersion (int iDevIdx, int iSlotId, out T_Module_FWVers sFWVersion);

  // it's recommended to use wArray in 'public struct T_SPM_SensorData' as call parameter
  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SPM_GetSensorData (int iDevIdx, int iSlotId, ushort [] wArray);

  // it's recommended to use wArray in 'public struct T_SPM_Temperatures' as call parameter
  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SPM_GetTemperatureAdjust (int iDevIdx, int iSlotId, ushort [] wArray);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SPM_GetStatusError (int iDevIdx, int iSlotId, out ushort pwState, out short piErrorCode);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SPM_UpdateFirmware (int iDevIdx, int iSlotId, StringBuilder pcFWFileName);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SPM_SetFRAMWriteProtect (int iDevIdx, int iSlotId, byte bWriteProtect);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SPM_GetFiberAmplifierFail (int iDevIdx, int iSlotId, out byte pbFiberAmpFail);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SPM_ResetFiberAmplifierFail (int iDevIdx, int iSlotId, byte bFiberAmpFail);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SPM_GetPumpPowerState (int iDevIdx, int iSlotId, out byte pbPumpState, out byte pbPumpMode);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SPM_SetPumpPowerState (int iDevIdx, int iSlotId, byte bPumpState, byte bPumpMode);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SPM_GetOperationTimers (int iDevIdx, int iSlotId, out uint pulMainPwrSwitch, out uint pulUTOverAll, out uint pulUTSinceDelivery, out uint pulUTSinceFiberChg);

  // ---  SWS functions (Solea)  ----------------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_DecodeModuleType (int iModuleType, StringBuilder cModulType);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_DecodeModuleState (ushort wState, StringBuilder cStatusText);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_GetModuleType (int iDevIdx, int iSlotId, out int piModuleType);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_GetStatusError (int iDevIdx, int iSlotId, out ushort pwState, out short piErrorCode);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_GetParamRanges (int iDevIdx, int iSlotId, out uint pulUpperWL, out uint pulLowerWL, out uint pulIncrWL, out uint pulPPMToggleWL, out uint pulUpperBW, out uint pulLowerBW, out uint pulIncrBW, out int piUpperBeamPos, out int piLowerBeamPos, out int piIncrBeamPos);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_GetParameters (int iDevIdx, int iSlotId, out uint pulWaveLength, out uint pulBandWidth);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_SetParameters (int iDevIdx, int iSlotId, uint ulWaveLength, uint ulBandWidth);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_GetIntensity (int iDevIdx, int iSlotId, out uint pulIntensityRaw, out float pfIntensity);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_GetFWVersion (int iDevIdx, int iSlotId, out T_Module_FWVers sFWVersion);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_UpdateFirmware (int iDevIdx, int iSlotId, StringBuilder pcFWFileName);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_SetFRAMWriteProtect (int iDevIdx, int iSlotId, byte bWriteProtect);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_GetBeamPos (int iDevIdx, int iSlotId, out short piBeamVPos, out short piBeamHPos);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_SetBeamPos (int iDevIdx, int iSlotId, short iBeamVPos, short iBeamHPos);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_SetCalibrationMode (int iDevIdx, int iSlotId, byte bCalibrationMode);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_GetCalTableSize (int iDevIdx, int iSlotId, out ushort pwWLIdxCount, out ushort pwBWIdxCount);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_SetCalTableSize (int iDevIdx, int iSlotId, ushort wWLIdxCount, ushort wBWIdxCount, byte bInit);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_GetCalPointInfo (int iDevIdx, int iSlotId, short iWLIdx, short iBWIdx, out uint pulWaveLength, out uint pulBandWidth, out short piBeamVPos, out short piBeamHPos);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SWS_SetCalPointValues (int iDevIdx, int iSlotId, short iWLIdx, short iBWIdx, short iBeamVPos, short iBeamHPos);

  // ---  SSM functions (Solea)  ----------------------------------------------

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SSM_DecodeFreqTrigMode (int iDevIdx, int iSlotId, int iMainFreqTrigIdx, StringBuilder cMainFreqTrig, out int piMainFreq, out byte pbTrigLevelEnabled);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SSM_GetTrigLevelRange (int iDevIdx, int iSlotId, out int piUpperTL, out int piLowerTL, out int piResolTL);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SSM_GetTriggerData (int iDevIdx, int iSlotId, out int piMainFreqTrigIdx, out int piTrigLevel);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SSM_SetTriggerData (int iDevIdx, int iSlotId, int iMainFreqTrigIdx, int iTrigLevel);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SSM_SetFRAMWriteProtect (int iDevIdx, int iSlotId, byte bWriteProtect);

  [DllImport("Sepia2_Lib", CallingConvention=CallingConvention.StdCall)]
  public extern static int SEPIA2_SSM_GetFRAMWriteProtect (int iDevIdx, int iSlotId, out byte pbWriteProtect);

}
