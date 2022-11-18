#region Part is from 'SEPIA2_Lib.h'

# -----------------------------------------------------------------------------
#
#   SEPIA2_Lib.h
#
# -----------------------------------------------------------------------------
#
#   functions exported by SEPIA2_Lib
#
# -----------------------------------------------------------------------------
#   HISTORY:
#
#   apo  22.12.05   release of the library interface
#
#   apo  12.02.07   introduced SML Multilaser Module (V1.0.2.0)
#
#   apo  02.12.09   introduced SWM Pulsar Waveform Module (V1.0.2.1)
#
#   apo  04.01.10   introduced function SEPIA2_SWM_GetUIConstants
#
#   apo  14.08.12   re-introduced all strictly internal functions
#                     encapsulated by compiler switch  __STRICTLY_PQ_INTERNAL__
#
#   apo  14.08.12   introduced Solea SWS functions (solea wavelength selector)
#
#   apo  04.09.12   introduced Solea SSM functions (solea seed module)
#
#   apo  11.04.13   introduced COM functions for two presets
#
#   apo  23.04.13   introduced Solea SPM functions (solea pump control)
#
#   apo  07.05.13   introduced LMP module functions for PQ internal laser test site
#
#   apo  22.05.13   introduced new SLM functions with intensity on permille domain
#                   primarily intended for laser test site (LMP), but released
#                   as a common feature;
#                   thus old SLM functions on percentage domain are deprecated
#
#   apo  31.05.13   introduced new SWS function ReInitMotor
#
#   apo  04.06.13   introduced new SWS function UpdateFirmware
#
#   apo  05.06.13   SWS command code 0x04 was withdrawn:
#                     get status is now integrated with get error -> GetStatusError
#
#   apo  06.11.13   introduced new FWR function GetModuleInfoByMapIdx
#
#   apo  15.07.14   introduced new SOMD feature:
#                     Base oscillator predivider is now 16bit
#
#   apo  16.07.14   introduced new SOM/SOMD functions Get/Set AUXIOSequencerCtrl
#
#   apo  24.04.15   introduced new SOMD function DecodeModuleState
#
#   apo  17.09.15   fixed some type incompatibilities with the MatLab environment
#                     This is not officially supported, not officially released!
#
#   apo  01.10.15   removed some superfluous SPM info functions from API
#
#   apo  22.01.21   adapted to DLL version 1.2.<target>.<svn_build>
#
#   apo  28.01.21   introduced VIR, VUV module functions (for VisUV/IR) (V1.2.xx.641)
#
#   dsc  20.04.21   introduced adaption for Python-demo
#                     (mainly a functionlist as comments)
#
# -----------------------------------------------------------------------------
#

import ctypes as ct
#from ctypes import byref



SEPIA2_LIB_DLL_NAME = "Sepia2_Lib.dll"

Sepia2_Lib = ct.WinDLL("./" + SEPIA2_LIB_DLL_NAME)

#  ---  library functions  --------------------------------------------------

# int SEPIA2_LIB_DecodeError(int iErrCode, StringBuilder cErrorString);
# int SEPIA2_LIB_GetVersion(StringBuilder cLibVersion);
# int SEPIA2_LIB_GetLibUSBVersion(StringBuilder cLibUSBVersion);
# int SEPIA2_LIB_IsRunningOnWine(out byte pbIsRunningOnWine);


#  ---  USB functions  ------------------------------------------------------

# int SEPIA2_USB_OpenDevice(int iDevIdx, StringBuilder cProductModel, StringBuilder cSerialNumber);
# int SEPIA2_USB_OpenGetSerNumAndClose(int iDevIdx, StringBuilder cProductModel, StringBuilder cSerialNumber);
# int SEPIA2_USB_GetStrDescriptor(int iDevIdx, StringBuilder cDescriptor);
# int SEPIA2_USB_GetStrDescrByIdx(int iDevIdx, int iDescrIdx, StringBuilder cDescriptor);
# int SEPIA2_USB_IsOpenDevice(int iDevIdx, out byte pbIsOpenDevice);
# int SEPIA2_USB_CloseDevice(int iDevIdx);


#  ---  firmware functions  -------------------------------------------------

# int SEPIA2_FWR_DecodeErrPhaseName(int iErrPhase, StringBuilder cErrorPhase);
#
# int SEPIA2_FWR_GetVersion(int iDevIdx, StringBuilder cFWVersion);
# int SEPIA2_FWR_GetLastError(int iDevIdx, out int piErrCode, out int piPhase, out int piLocation, out int piSlot, StringBuilder cCondition);
#
# int SEPIA2_FWR_GetWorkingMode(int iDevIdx, out int piMode);
# int SEPIA2_FWR_SetWorkingMode(int iDevIdx, int iMode);
# int SEPIA2_FWR_RollBackToPermanentValues(int iDevIdx);
# int SEPIA2_FWR_StoreAsPermanentValues(int iDevIdx);
#
# int SEPIA2_FWR_GetModuleMap(int iDevIdx, int iPerformRestart, out int piModuleCount);
# int SEPIA2_FWR_GetModuleInfoByMapIdx(int iDevIdx, int iMapIdx, out int piSlotId, out byte pbIsPrimary, out byte pbIsBackPlane, out byte pbHasUptimeCounter);
# int SEPIA2_FWR_GetUptimeInfoByMapIdx(int iDevIdx, int iMapIdx, out uint pulMainPowerUp, out uint pulActivePowerUp, out uint pulScaledPowerUp);
# int SEPIA2_FWR_CreateSupportRequestText(int iDevIdx, StringBuilder cPreamble, StringBuilder cCallingSW, int iOptions, int iBufferLen, StringBuilder cBuffer);
# int SEPIA2_FWR_FreeModuleMap(int iDevIdx);


#  ---  common module functions  --------------------------------------------

# int SEPIA2_COM_DecodeModuleType(int iModuleType, StringBuilder cModulType);
# int SEPIA2_COM_DecodeModuleTypeAbbr(int iModuleType, StringBuilder cModulTypeAbbr);
#
# int SEPIA2_COM_GetModuleType(int iDevIdx, int iSlotId, int iGetPrimary, out int piModuleType);
# int SEPIA2_COM_HasSecondaryModule(int iDevIdx, int iSlotId, out int piHasSecondary);
# int SEPIA2_COM_GetSerialNumber(int iDevIdx, int iSlotId, int iGetPrimary, StringBuilder cSerialNumber);
# int SEPIA2_COM_GetSupplementaryInfos(int iDevIdx, int iSlotId, int iGetPrimary, StringBuilder cLabel, StringBuilder cReleaseDate, StringBuilder cRevision, StringBuilder cHdrMemo);
# int SEPIA2_COM_GetPresetInfo(int iDevIdx, int iSlotId, int iGetPrimary, int iPresetNr, out byte pbIsSet, StringBuilder cPresetMemo);
# int SEPIA2_COM_RecallPreset(int iDevIdx, int iSlotId, int iGetPrimary, int iPresetNr);
# int SEPIA2_COM_SaveAsPreset(int iDevIdx, int iSlotId, int iSetPrimary, int iPresetNr, StringBuilder cPresetMemo);
# int SEPIA2_COM_IsWritableModule(int iDevIdx, int iSlotId, int iGetPrimary, out byte pbIsWritable);
# int SEPIA2_COM_UpdateModuleData(int iDevIdx, int iSlotId, int iSetPrimary, StringBuilder pcDCLFileName);


#  ---  SCM 828 functions  --------------------------------------------------

# int SEPIA2_SCM_GetPowerAndLaserLEDS(int iDevIdx, int iSlotId, out byte pbPowerLED, out byte pbLaserActiveLED);
# int SEPIA2_SCM_GetLaserLocked(int iDevIdx, int iSlotId, out byte pbLocked);
# int SEPIA2_SCM_GetLaserSoftLock(int iDevIdx, int iSlotId, out byte pbSoftLocked);
# int SEPIA2_SCM_SetLaserSoftLock(int iDevIdx, int iSlotId, byte bSoftLocked);


#  ---  SLM 828 functions  --------------------------------------------------

# int SEPIA2_SLM_DecodeFreqTrigMode(int iFreq, StringBuilder cFreqTrigMode);
# int SEPIA2_SLM_DecodeHeadType(int iHeadType, StringBuilder cHeadType);
# int SEPIA2_SLM_GetIntensityFineStep(int iDevIdx, int iSlotId, out ushort pwIntensity);
# int SEPIA2_SLM_SetIntensityFineStep(int iDevIdx, int iSlotId, ushort wIntensity);
# int SEPIA2_SLM_GetPulseParameters(int iDevIdx, int iSlotId, out int piFreq, out byte pbPulseMode, out int piHeadType);
# int SEPIA2_SLM_SetPulseParameters(int iDevIdx, int iSlotId, int iFreq, byte bPulseMode);


#  ---  SML 828 functions  --------------------------------------------------

# int SEPIA2_SML_DecodeHeadType(int iHeadType, StringBuilder cHeadType);
#
# int SEPIA2_SML_GetParameters(int iDevIdx, int iSlotId, out byte pbPulseMode, out int piHead, out byte pbIntensity);
# int SEPIA2_SML_SetParameters(int iDevIdx, int iSlotId, byte bPulseMode, byte bIntensity);


#  ---  SOM 828 functions  --------------------------------------------------

# int SEPIA2_SOM_DecodeFreqTrigMode(int iDevIdx, int iSlotId, int iFreqTrigMode, StringBuilder cFreqTrigMode);
#
# int SEPIA2_SOM_GetFreqTrigMode(int iDevIdx, int iSlotId, out int piFreqTrigMode);
# int SEPIA2_SOM_SetFreqTrigMode(int iDevIdx, int iSlotId, int iFreqTrigMode);
#
# int SEPIA2_SOM_GetTriggerRange(int iDevIdx, int iSlotId, out int piMilliVoltLow, out int piMilliVoltHigh);
# int SEPIA2_SOM_GetTriggerLevel(int iDevIdx, int iSlotId, out int piMilliVolt);
# int SEPIA2_SOM_SetTriggerLevel(int iDevIdx, int iSlotId, int iMilliVolt);
#
# int SEPIA2_SOM_GetBurstValues(int iDevIdx, int iSlotId, out byte pbDivider, out byte pbPreSync, out byte pbMaskSync);
# int SEPIA2_SOM_SetBurstValues(int iDevIdx, int iSlotId, byte bDivider, byte bPreSync, byte bMaskSync);
#
# int SEPIA2_SOM_GetBurstLengthArray(int iDevIdx, int iSlotId, out int plBurstLen1, out int plBurstLen2, out int plBurstLen3, out int plBurstLen4, out int plBurstLen5, out int plBurstLen6, out int plBurstLen7, out int plBurstLen8);
# int SEPIA2_SOM_SetBurstLengthArray(int iDevIdx, int iSlotId, int lBurstLen1, int lBurstLen2, int lBurstLen3, int lBurstLen4, int lBurstLen5, int lBurstLen6, int lBurstLen7, int lBurstLen8);
#
# int SEPIA2_SOM_GetOutNSyncEnable(int iDevIdx, int iSlotId, out byte pbOutEnable, out byte pbSyncEnable, out byte pbSyncInverse);
# int SEPIA2_SOM_SetOutNSyncEnable(int iDevIdx, int iSlotId, byte bOutEnable, byte bSyncEnable, byte bSyncInverse);
#
# int SEPIA2_SOM_DecodeAUXINSequencerCtrl(int iAUXInCtrl, StringBuilder cSequencerCtrl);
# int SEPIA2_SOM_GetAUXIOSequencerCtrl(int iDevIdx, int iSlotId, out byte pbAUXOutCtrl, out byte pbAUXInCtrl);
# int SEPIA2_SOM_SetAUXIOSequencerCtrl(int iDevIdx, int iSlotId, byte bAUXOutCtrl, byte bAUXInCtrl);


#  ---  SOM 828 D functions  --------------------------------------------------

# int SEPIA2_SOMD_DecodeFreqTrigMode(int iDevIdx, int iSlotId, int iFreqTrigIdx, StringBuilder cFreqTrigMode);
#
# int SEPIA2_SOMD_GetFreqTrigMode(int iDevIdx, int iSlotId, out int piFreqTrigIdx, out byte pbSynchronize);
# int SEPIA2_SOMD_SetFreqTrigMode(int iDevIdx, int iSlotId, int iFreqTrigIdx, byte bSynchronize);
#
# int SEPIA2_SOMD_GetTriggerRange(int iDevIdx, int iSlotId, out int piMilliVoltLow, out int piMilliVoltHigh);
# int SEPIA2_SOMD_GetTriggerLevel(int iDevIdx, int iSlotId, out int piMilliVolt);
# int SEPIA2_SOMD_SetTriggerLevel(int iDevIdx, int iSlotId, int iMilliVolt);
#
# int SEPIA2_SOMD_GetBurstValues(int iDevIdx, int iSlotId, out ushort pwDivider, out byte pbPreSync, out byte pbMaskSync);
# int SEPIA2_SOMD_SetBurstValues(int iDevIdx, int iSlotId, ushort wDivider, byte bPreSync, byte bMaskSync);
#
# int SEPIA2_SOMD_GetBurstLengthArray(int iDevIdx, int iSlotId, out int plBurstLen1, out int plBurstLen2, out int plBurstLen3, out int plBurstLen4, out int plBurstLen5, out int plBurstLen6, out int plBurstLen7, out int plBurstLen8);
# int SEPIA2_SOMD_SetBurstLengthArray(int iDevIdx, int iSlotId, int lBurstLen1, int lBurstLen2, int lBurstLen3, int lBurstLen4, int lBurstLen5, int lBurstLen6, int lBurstLen7, int lBurstLen8);
#
# int SEPIA2_SOMD_GetOutNSyncEnable(int iDevIdx, int iSlotId, out byte pbOutEnable, out byte pbSyncEnable, out byte pbSyncInverse);
# int SEPIA2_SOMD_SetOutNSyncEnable(int iDevIdx, int iSlotId, byte bOutEnable, byte bSyncEnable, byte bSyncInverse);
#
# int SEPIA2_SOMD_DecodeAUXINSequencerCtrl(int iAUXInCtrl, StringBuilder cSequencerCtrl);
# int SEPIA2_SOMD_GetAUXIOSequencerCtrl(int iDevIdx, int iSlotId, out byte pbAUXOutCtrl, out byte pbAUXInCtrl);
# int SEPIA2_SOMD_SetAUXIOSequencerCtrl(int iDevIdx, int iSlotId, byte bAUXOutCtrl, byte bAUXInCtrl);
#
# int SEPIA2_SOMD_GetSeqOutputInfos(int iDevIdx, int iSlotId, byte bSeqOutIdx, out byte pbDelayed, out byte pbForcedUndelayed, out byte pbOutCombi, out byte pbMaskedCombi, out double pf64CoarseDly, out byte pbFineDly); #  [double fCoarseDly] : ns
# int SEPIA2_SOMD_SetSeqOutputInfos(int iDevIdx, int iSlotId, byte bSeqOutIdx, byte bDelayed, byte bOutCombi, byte bMaskedCombi, double fCoarseDly, byte bFineDly);  #  [byte bFineDly] : a.u., shouldn't be read as ps
#
# int SEPIA2_SOMD_SynchronizeNow(int iDevIdx, int iSlotId);
# int SEPIA2_SOMD_DecodeModuleState(ushort wState, StringBuilder cStatusText);
# int SEPIA2_SOMD_GetStatusError(int iDevIdx, int iSlotId, out ushort pwState, out short piErrorCode);
# int SEPIA2_SOMD_GetTrigSyncFreq(int iDevIdx, int iSlotId, out byte pbFreqStable, out uint pulTrigSyncFreq);
# int SEPIA2_SOMD_GetDelayUnits(int iDevIdx, int iSlotId, out double pfCoarseDlyStep, out byte pbFineDlyStepCount); #  [double fCoarseDlyStep] : ns
# int SEPIA2_SOMD_GetFWVersion(int iDevIdx, int iSlotId, out uint pulFWVersion);
#
# int SEPIA2_SOMD_FWReadPage(int iDevIdx, int iSlotId, ushort iPageIdx, out byte pbFWPage);
# int SEPIA2_SOMD_FWWritePage(int iDevIdx, int iSlotId, ushort iPageIdx, out byte pbFWPage);
# int SEPIA2_SOMD_GetHWParams(int iDevIdx, int iSlotId, out ushort pwHWParTemp1, out ushort pwHWParTemp2, out ushort pwHWParTemp3, out ushort pwHWParVolt1, out ushort pwHWParVolt2, out ushort pwHWParVolt3, out ushort pwHWParVolt4, out ushort pwHWParAUX);


#  ---  SWM 828 functions (PPL400)  -----------------------------------------

# int SEPIA2_SWM_DecodeRangeIdx(int iDevIdx, int iSlotId, int iRangeIdx, out int iUpperLimit);
#
# int SEPIA2_SWM_GetUIConstants(int iDevIdx, int iSlotId, out byte bTBNdxCount, out ushort wMaxAmplitude, out ushort wMaxSlewRate, out ushort wExpRampEffect, out ushort wMinUserValue, out ushort wMaxUserValue, out ushort wUserResolution);
# int SEPIA2_SWM_GetCurveParams(int iDevIdx, int iSlotId, int iCurveIdx, out byte bTBNdx, out ushort wPAPml, out ushort wRRPml, out ushort wPSPml, out ushort wRSPml, out ushort wWSPml);
# int SEPIA2_SWM_SetCurveParams(int iDevIdx, int iSlotId, int iCurveIdx, byte bTBNdx, ushort wPAPml, ushort wRRPml, ushort wPSPml, ushort wRSPml, ushort wWSPml);
# int SEPIA2_SWM_GetExtAtten(int iDevIdx, int iSlotId, out float fExtAtt);
# int SEPIA2_SWM_SetExtAtten(int iDevIdx, int iSlotId, float fExtAtt);


#  ---  VCL 828 functions (PPL400)  -----------------------------------------

# int SEPIA2_VCL_GetUIConstants(int iDevIdx, int iSlotId, out int piMinUserValueTmp, out int piMaxUserValueTmp, out int piUserResolutionTmp);
# int SEPIA2_VCL_GetTemperature(int iDevIdx, int iSlotId, out int piTemperature);
# int SEPIA2_VCL_SetTemperature(int iDevIdx, int iSlotId, int iTemperature);
# int SEPIA2_VCL_GetBiasVoltage(int iDevIdx, int iSlotId, out int piBiasVoltage);


#  ---  Solea SPM functions  ------------------------------------------------

# int SEPIA2_SPM_DecodeModuleState(ushort wState, StringBuilder cStatusText);
# int SEPIA2_SPM_GetFWVersion(int iDevIdx, int iSlotId, out T_Module_FWVers pulFWVersion); #
# int SEPIA2_SPM_GetSensorData(int iDevIdx, int iSlotId, out T_SPM_SensorData pSensorData);
# int SEPIA2_SPM_GetTemperatureAdjust(int iDevIdx, int iSlotId, out T_SPM_Temperatures pTempAdjust);
# int SEPIA2_SPM_GetStatusError(int iDevIdx, int iSlotId, out ushort pwState, out short piErrorCode);
# int SEPIA2_SPM_UpdateFirmware(int iDevIdx, int iSlotId, StringBuilder pcFWFileName);
# int SEPIA2_SPM_SetFRAMWriteProtect(int iDevIdx, int iSlotId, byte bWriteProtect);
# int SEPIA2_SPM_GetFiberAmplifierFail(int iDevIdx, int iSlotId, out byte pbFiberAmpFail);
# int SEPIA2_SPM_ResetFiberAmplifierFail(int iDevIdx, int iSlotId, byte bFiberAmpFail);
# int SEPIA2_SPM_GetPumpPowerState(int iDevIdx, int iSlotId, out byte pbPumpState, out byte pbPumpMode);
# int SEPIA2_SPM_SetPumpPowerState(int iDevIdx, int iSlotId, byte bPumpState, byte bPumpMode);
# int SEPIA2_SPM_GetOperationTimers(int iDevIdx, int iSlotId, out uint pulMainPwrSwitch, out uint pulUTOverAll, out uint pulUTSinceDelivery, out uint pulUTSinceFiberChg);


#  ---  Solea SWS functions  ------------------------------------------------

# int SEPIA2_SWS_DecodeModuleType(int iModuleType, StringBuilder cModulType);
# int SEPIA2_SWS_DecodeModuleState(ushort wState, StringBuilder cStatusText);
# int SEPIA2_SWS_GetModuleType(int iDevIdx, int iSlotId, out int piModuleType);
# int SEPIA2_SWS_GetStatusError(int iDevIdx, int iSlotId, out ushort pwState, out short piErrorCode);
# int SEPIA2_SWS_GetParamRanges(int iDevIdx, int iSlotId, out uint pulUpperWL, out uint pulLowerWL, out uint pulIncrWL, out uint pulPPMToggleWL, out uint pulUpperBW, out uint pulLowerBW, out uint pulIncrBW, out int piUpperBeamPos, out int piLowerBeamPos, out int piIncrBeamPos);
# int SEPIA2_SWS_GetParameters(int iDevIdx, int iSlotId, out uint pulWaveLength, out uint pulBandWidth);
# int SEPIA2_SWS_SetParameters(int iDevIdx, int iSlotId, uint ulWaveLength, uint ulBandWidth);
# int SEPIA2_SWS_GetIntensity(int iDevIdx, int iSlotId, out uint pulIntensityRaw, out float pfIntensity);
# int SEPIA2_SWS_GetFWVersion(int iDevIdx, int iSlotId, out T_Module_FWVers pulFWVersion);
# int SEPIA2_SWS_UpdateFirmware(int iDevIdx, int iSlotId, StringBuilder pcFWFileName);
# int SEPIA2_SWS_SetFRAMWriteProtect(int iDevIdx, int iSlotId, byte bWriteProtect);
# int SEPIA2_SWS_GetBeamPos(int iDevIdx, int iSlotId, out short piBeamVPos, out short piBeamHPos);
# int SEPIA2_SWS_SetBeamPos(int iDevIdx, int iSlotId, short iBeamVPos, short iBeamHPos);

# int SEPIA2_SWS_SetCalibrationMode(int iDevIdx, int iSlotId, byte bCalibrationMode);
# int SEPIA2_SWS_GetCalTableSize(int iDevIdx, int iSlotId, out ushort pwWLIdxCount, out ushort pwBWIdxCount);
# int SEPIA2_SWS_SetCalTableSize(int iDevIdx, int iSlotId, ushort wWLIdxCount, ushort wBWIdxCount, byte bInit);
# int SEPIA2_SWS_GetCalPointInfo(int iDevIdx, int iSlotId, short iWLIdx, short iBWIdx, out uint pulWaveLength, out uint pulBandWidth, out short piBeamVPos, out short piBeamHPos);
# int SEPIA2_SWS_SetCalPointValues(int iDevIdx, int iSlotId, short iWLIdx, short iBWIdx, short iBeamVPos, short iBeamHPos);


#  ---  Solea SSM functions  ------------------------------------------------

# int SEPIA2_SSM_DecodeFreqTrigMode(int iDevIdx, int iSlotId, int iMainFreqTrigIdx, StringBuilder cMainFreqTrig, out int piMainFreq, out byte pbTrigLevelEnabled);
# int SEPIA2_SSM_GetTrigLevelRange(int iDevIdx, int iSlotId, out int piUpperTL, out int piLowerTL, out int piResolTL);
# int SEPIA2_SSM_GetTriggerData(int iDevIdx, int iSlotId, out int piMainFreqTrigIdx, out int piTrigLevel);
# int SEPIA2_SSM_SetTriggerData(int iDevIdx, int iSlotId, int iMainFreqTrigIdx, int iTrigLevel);
# int SEPIA2_SSM_SetFRAMWriteProtect(int iDevIdx, int iSlotId, byte bWriteProtect);
# int SEPIA2_SSM_GetFRAMWriteProtect(int iDevIdx, int iSlotId, out byte pbWriteProtect);


#  ---  VisUV/IR  VUV / VIR functions  ------------------------------------------

# int SEPIA2_VUV_VIR_GetDeviceType(int iDevIdx, int iSlotId, StringBuilder pcDeviceType, out byte pbOptCW, out byte pbOptFanSwitch);
# int SEPIA2_VUV_VIR_DecodeFreqTrigMode(int iDevIdx, int iSlotId, int iMainTrigSrcIdx, int iMainFreqDivIdx, StringBuilder pcMainFreqTrig, out int piMainFreq, out byte pbTrigDividerEnabled, out byte pbTrigLevelEnabled);
# int SEPIA2_VUV_VIR_GetTrigLevelRange(int iDevIdx, int iSlotId, out int piUpperTL, out int piLowerTL, out int piResolTL);
# int SEPIA2_VUV_VIR_GetTriggerData(int iDevIdx, int iSlotId, out int piMainTrigSrcIdx, out int piMainFreqDivIdx, out int piTrigLevel);
# int SEPIA2_VUV_VIR_SetTriggerData(int iDevIdx, int iSlotId, int iMainTrigSrcIdx, int iMainFreqDivIdx, int iTrigLevel);
# int SEPIA2_VUV_VIR_GetIntensityRange(int iDevIdx, int iSlotId, out int piUpperIntens, out int piLowerIntens, out int piResolIntens);
# int SEPIA2_VUV_VIR_GetIntensity(int iDevIdx, int iSlotId, out int piIntensity);
# int SEPIA2_VUV_VIR_SetIntensity(int iDevIdx, int iSlotId, int iIntensity);
# int SEPIA2_VUV_VIR_GetFan(int iDevIdx, int iSlotId, out byte pbFanRunning);
# int SEPIA2_VUV_VIR_SetFan(int iDevIdx, int iSlotId, byte bFanRunning);


#  ---  Prima  PRI functions  ------------------------------------------

# int SEPIA2_PRI_GetDeviceInfo(int iDevIdx, int iSlotId, StringBuilder pcDeviceID, StringBuilder pcDeviceType, StringBuilder pcFW_Version, out int piWL_Count);
# int SEPIA2_PRI_DecodeOperationMode(int iDevIdx, int iSlotId, int iOperModeIdx, StringBuilder pcOperMode);
# int SEPIA2_PRI_GetOperationMode(int iDevIdx, int iSlotId, out int piOperModeIdx);
# int SEPIA2_PRI_SetOperationMode(int iDevIdx, int iSlotId, int iOperModeIdx);
# int SEPIA2_PRI_DecodeTriggerSource(int iDevIdx, int iSlotId, int iTrgSrcIdx, StringBuilder pcTrgSrc, out byte pbFrequencyEnabled, out byte pbTrigLevelEnabled);
# int SEPIA2_PRI_GetTriggerSource(int iDevIdx, int iSlotId, out int piTrgSrcIdx);
# int SEPIA2_PRI_SetTriggerSource(int iDevIdx, int iSlotId, int iTrgSrcIdx);
# int SEPIA2_PRI_GetTriggerLevelLimits(int iDevIdx, int iSlotId, out int piTrg_MinLvl, out int piTrg_MaxLvl, out int piTrg_LvlRes);
# int SEPIA2_PRI_GetTriggerLevel(int iDevIdx, int iSlotId, out int piTrgLevel);
# int SEPIA2_PRI_SetTriggerLevel(int iDevIdx, int iSlotId, int iTrgLevel);
# int SEPIA2_PRI_GetFrequencyLimits(int iDevIdx, int iSlotId, out int piMinFreq, out int piMaxFreq);
# int SEPIA2_PRI_GetFrequency(int iDevIdx, int iSlotId, out int piFrequency);
# int SEPIA2_PRI_SetFrequency(int iDevIdx, int iSlotId, int iFrequency);
# int SEPIA2_PRI_GetGatingLimits(int iDevIdx, int iSlotId, out int piMinOnTime, out int piMaxOnTime, out int pbMinOffTimefactor, out int pbMaxOffTimefactor);
# int SEPIA2_PRI_GetGatingData(int iDevIdx, int iSlotId, out int piOnTime, out int piOffTimefact);
# int SEPIA2_PRI_SetGatingData(int iDevIdx, int iSlotId, int iOnTime, int iOffTimefact);
# int SEPIA2_PRI_GetGatingEnabled(int iDevIdx, int iSlotId, out byte pbGatingEnabled);
# int SEPIA2_PRI_SetGatingEnabled(int iDevIdx, int iSlotId, byte bGatingEnabled);
# int SEPIA2_PRI_GetGateHighImpedance(int iDevIdx, int iSlotId, out byte pbHighImpedance);
# int SEPIA2_PRI_SetGateHighImpedance(int iDevIdx, int iSlotId, byte bHighImpedance);
# int SEPIA2_PRI_DecodeWavelength(int iDevIdx, int iSlotId, int iWLIdx, out int piWL);
# int SEPIA2_PRI_GetWavelengthIdx(int iDevIdx, int iSlotId, out int piWLIdx);
# int SEPIA2_PRI_SetWavelengthIdx(int iDevIdx, int iSlotId, int iWLIdx);
# int SEPIA2_PRI_GetIntensity(int iDevIdx, int iSlotId, int iWLIdx, out ushort pwIntensity);
# int SEPIA2_PRI_SetIntensity(int iDevIdx, int iSlotId, int iWLIdx, ushort wIntensity);

