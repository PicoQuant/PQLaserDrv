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
//  apo  17.09.15   fixed some type incompatibilities with the MatLab environment
//                    This is not officially supported, not officially released!
//
//  apo  22.01.21   adapted to DLL version 1.2.<target>.<svn_build>
//                    due to USB driver changes
//
//  apo  25.01.21   introduced VIR, VUV module functions (for VisUV/IR) (V1.2.xx.641)
//
//  apo  10.02.21   removed functions for Solea modules (SPM, SWS, SSM), SML 828
//                    and PPL 400 (SWM, VCL)  (only from this file, not from DLL)
//                    Contact PicoQuant if you need them with MatLab...
//
//  apo  25.10.22   introduced PRI module functions (for Prima / QUADER) (V1.2.xx.720)
//
//-----------------------------------------------------------------------------
//
#pragma message ("********************************  " __FILE__ " ***     Entering Declaration File...")

#ifndef   __SEPIA2_LIB_H__
  #define __SEPIA2_LIB_H__

  #pragma message ("********************************  " __FILE__ " ***     Declaration Commencing...")

  // ---  library functions  --------------------------------------------------

  extern int __stdcall SEPIA2_LIB_DecodeError               (int iErrCode, char* cErrorString);
  extern int __stdcall SEPIA2_LIB_GetVersion                (char* cLibVersion);
  extern int __stdcall SEPIA2_LIB_GetLibUSBVersion          (char* cLibUSBVersion);
  extern int __stdcall SEPIA2_LIB_IsRunningOnWine           (unsigned char* pbIsRunningOnWine);


  // ---  USB functions  ------------------------------------------------------

  //extern int __stdcall SEPIA2_USB_OpenDevice              (int iDevIdx,     char* cProductModel,     char* cSerialNumber);
  //extern int __stdcall SEPIA2_USB_OpenGetSerNumAndClose   (int iDevIdx,     char* cProductModel,     char* cSerialNumber);
  //
  // cProductModel and cSerialNumber are bi-directional I/O-Parameters 
  // (i.e. input parameters and output parameters as well), 
  // and therefore have to be altered manually to void pointers
  extern int __stdcall SEPIA2_USB_OpenDevice                (int iDevIdx,     void* cProductModel,     void* cSerialNumber);
  extern int __stdcall SEPIA2_USB_OpenGetSerNumAndClose     (int iDevIdx,     void* cProductModel,     void* cSerialNumber);
  //
  extern int __stdcall SEPIA2_USB_GetStrDescriptor          (int iDevIdx,     char* cDescriptor);
  extern int __stdcall SEPIA2_USB_GetStrDescrByIdx          (int iDevIdx,     int   iDescrIdx,         char* cDescriptor);
  extern int __stdcall SEPIA2_USB_IsOpenDevice              (int iDevIdx,     unsigned char* pbIsOpenDevice);
  extern int __stdcall SEPIA2_USB_CloseDevice               (int iDevIdx);


  // ---  firmware functions  -------------------------------------------------

  extern int __stdcall SEPIA2_FWR_DecodeErrPhaseName        (int iErrPhase,   char* cErrorPhase);
  //
  extern int __stdcall SEPIA2_FWR_GetVersion                (int iDevIdx,     char* cFWVersion);
  extern int __stdcall SEPIA2_FWR_GetLastError              (int iDevIdx,     int*  piErrCode,       int*  piPhase,       int* piLocation,  int* piSlot, char* cCondition);
  //
  extern int __stdcall SEPIA2_FWR_GetWorkingMode            (int iDevIdx,     int*  piMode);
  extern int __stdcall SEPIA2_FWR_SetWorkingMode            (int iDevIdx,     int   iMode);
  extern int __stdcall SEPIA2_FWR_RollBackToPermanentValues (int iDevIdx);
  extern int __stdcall SEPIA2_FWR_StoreAsPermanentValues    (int iDevIdx);
  //
  extern int __stdcall SEPIA2_FWR_GetModuleMap              (int iDevIdx,     int   iPerformRestart, int*  piModuleCount);
  extern int __stdcall SEPIA2_FWR_GetModuleInfoByMapIdx     (int iDevIdx,     int   iMapIdx,         int*  piSlotId,      unsigned char* pbIsPrimary, unsigned char* pbIsBackPlane,  unsigned char* pbHasUptimeCounter);
  extern int __stdcall SEPIA2_FWR_GetUptimeInfoByMapIdx     (int iDevIdx,     int   iMapIdx,         unsigned long* pulMainPowerUp, unsigned long* pulActivePowerUp, unsigned long* pulScaledPowerUp);
  //
  //extern int __stdcall SEPIA2_FWR_CreateSupportRequestText  (int iDevIdx,     char* cPreamble,       char* cCallingSW, int iOptions, int iBufferLen, char* cBuffer);
  //
  // cPreamble and cCallingSW are strings that work as Input-Parameters 
  // and therefore have to be altered manually to void pointers
  extern int __stdcall SEPIA2_FWR_CreateSupportRequestText  (int iDevIdx,     void* cPreamble,       void* cCallingSW, int iOptions, int iBufferLen, char* cBuffer);
  extern int __stdcall SEPIA2_FWR_FreeModuleMap             (int iDevIdx);


  // ---  common module functions  --------------------------------------------

  extern int __stdcall SEPIA2_COM_DecodeModuleType          (int iModuleType, char* cModulType);
  extern int __stdcall SEPIA2_COM_DecodeModuleTypeAbbr      (int iModuleType, char* cModulTypeAbbr);
  //
  extern int __stdcall SEPIA2_COM_GetFormatVersion          (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   unsigned short* pwFormatVersion);
  extern int __stdcall SEPIA2_COM_GetModuleType             (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   int* piModuleType);
  extern int __stdcall SEPIA2_COM_HasSecondaryModule        (int iDevIdx,     int   iSlotId,  int*  piHasSecondary);
  extern int __stdcall SEPIA2_COM_GetSerialNumber           (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   char* cSerialNumber);
  extern int __stdcall SEPIA2_COM_GetSupplementaryInfos     (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   char* cLabel, char* cReleaseDate, char* cRevision, char* cHdrMemo);
  extern int __stdcall SEPIA2_COM_GetPresetInfo             (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   int   iPresetNr,  unsigned char* pbIsSet, char* cPresetMemo);
  extern int __stdcall SEPIA2_COM_RecallPreset              (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   int   iPresetNr);
  //
  //extern int __stdcall SEPIA2_COM_SaveAsPreset              (int iDevIdx,     int   iSlotId,  int   iSetPrimary,   int   iPresetNr,  char* cPresetMemo);
  //
  // cPresetMemo is a string that works as Input-Parameter
  // and therefore have to be changed manually into a void pointer
  extern int __stdcall SEPIA2_COM_SaveAsPreset              (int iDevIdx,     int   iSlotId,  int   iSetPrimary,   int   iPresetNr,  void* cPresetMemo);
  extern int __stdcall SEPIA2_COM_IsWritableModule          (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   unsigned char* pbIsWritable);
  //
  //extern int __stdcall SEPIA2_COM_UpdateModuleData          (int iDevIdx,     int   iSlotId,  int   iSetPrimary,   char* pcDCLFileName);
  //
  // pcDCLFileName is a string that works as Input-Parameter
  // and therefore have to be changed manually into a void pointer
  extern int __stdcall SEPIA2_COM_UpdateModuleData          (int iDevIdx,     int   iSlotId,  int   iSetPrimary,   void* pcDCLFileName);


  // ---  SCM 828 functions  --------------------------------------------------

  extern int __stdcall SEPIA2_SCM_GetPowerAndLaserLEDS      (int iDevIdx,     int   iSlotId,  unsigned char* pbPowerLED,  unsigned char* pbLaserActiveLED);
  extern int __stdcall SEPIA2_SCM_GetLaserLocked            (int iDevIdx,     int   iSlotId,  unsigned char* pbLocked);
  extern int __stdcall SEPIA2_SCM_GetLaserSoftLock          (int iDevIdx,     int   iSlotId,  unsigned char* pbSoftLocked);
  extern int __stdcall SEPIA2_SCM_SetLaserSoftLock          (int iDevIdx,     int   iSlotId,  unsigned char  bSoftLocked);


  // ---  SLM 828 functions  --------------------------------------------------

  extern int __stdcall SEPIA2_SLM_DecodeFreqTrigMode        (int iFreq,       char* cFreqTrigMode);
  extern int __stdcall SEPIA2_SLM_DecodeHeadType            (int iHeadType,   char* cHeadType);
  //
  extern int __stdcall SEPIA2_SLM_GetIntensityFineStep      (int iDevIdx,     int   iSlotId,  unsigned short* pwIntensity);
  extern int __stdcall SEPIA2_SLM_SetIntensityFineStep      (int iDevIdx,     int   iSlotId,  unsigned short  wIntensity);
  extern int __stdcall SEPIA2_SLM_GetPulseParameters        (int iDevIdx,     int   iSlotId,  int*  piFreq, unsigned char* pbPulseMode,  int* piHeadType);
  extern int __stdcall SEPIA2_SLM_SetPulseParameters        (int iDevIdx,     int   iSlotId,  int   iFreq,  unsigned char  bPulseMode);


  // ---  SOM 828 functions  --------------------------------------------------

  extern int __stdcall SEPIA2_SOM_DecodeFreqTrigMode        (int iDevIdx,     int   iSlotId,  int   iFreqTrigMode, char* cFreqTrigMode);
  //
  extern int __stdcall SEPIA2_SOM_GetFreqTrigMode           (int iDevIdx,     int   iSlotId,  int*  piFreqTrigMode);
  extern int __stdcall SEPIA2_SOM_SetFreqTrigMode           (int iDevIdx,     int   iSlotId,  int   iFreqTrigMode);
  //
  extern int __stdcall SEPIA2_SOM_GetTriggerRange           (int iDevIdx,     int   iSlotId,  int*  piMilliVoltLow, int* piMilliVoltHigh);
  extern int __stdcall SEPIA2_SOM_GetTriggerLevel           (int iDevIdx,     int   iSlotId,  int*  piMilliVolt);
  extern int __stdcall SEPIA2_SOM_SetTriggerLevel           (int iDevIdx,     int   iSlotId,  int   iMilliVolt);
  //
  extern int __stdcall SEPIA2_SOM_GetBurstValues            (int iDevIdx,     int   iSlotId,  unsigned char* pbDivider,   unsigned char* pbPreSync,    unsigned char* pbMaskSync);
  extern int __stdcall SEPIA2_SOM_SetBurstValues            (int iDevIdx,     int   iSlotId,  unsigned char  bDivider,    unsigned char  bPreSync,     unsigned char  bMaskSync);
  //
  extern int __stdcall SEPIA2_SOM_GetBurstLengthArray       (int iDevIdx,     int   iSlotId,  long* plBurstLen1, long* plBurstLen2, long* plBurstLen3, long* plBurstLen4, long* plBurstLen5, long* plBurstLen6, long* plBurstLen7, long* plBurstLen8);
  extern int __stdcall SEPIA2_SOM_SetBurstLengthArray       (int iDevIdx,     int   iSlotId,  long  lBurstLen1,  long  lBurstLen2,  long  lBurstLen3,  long  lBurstLen4,  long  lBurstLen5,  long  lBurstLen6,  long  lBurstLen7,  long  lBurstLen8);
  //
  extern int __stdcall SEPIA2_SOM_GetOutNSyncEnable         (int iDevIdx,     int   iSlotId,  unsigned char* pbOutEnable,  unsigned char* pbSyncEnable, unsigned char* pbSyncInverse);
  extern int __stdcall SEPIA2_SOM_SetOutNSyncEnable         (int iDevIdx,     int   iSlotId,  unsigned char  bOutEnable,   unsigned char  bSyncEnable,  unsigned char  bSyncInverse);
  //
  extern int __stdcall SEPIA2_SOM_DecodeAUXINSequencerCtrl  (int iAUXInCtrl,  char* cSequencerCtrl);
  extern int __stdcall SEPIA2_SOM_GetAUXIOSequencerCtrl     (int iDevIdx,     int   iSlotId,  unsigned char* pbAUXOutCtrl, unsigned char* pbAUXInCtrl);
  extern int __stdcall SEPIA2_SOM_SetAUXIOSequencerCtrl     (int iDevIdx,     int   iSlotId,  unsigned char  bAUXOutCtrl,  unsigned char  bAUXInCtrl);


  // ---  SOM 828 D functions  --------------------------------------------------

  extern int __stdcall SEPIA2_SOMD_DecodeFreqTrigMode       (int iDevIdx,     int   iSlotId,  int   iFreqTrigIdx, char* cFreqTrigMode);
  //
  extern int __stdcall SEPIA2_SOMD_GetFreqTrigMode          (int iDevIdx,     int   iSlotId,  int*  piFreqTrigIdx, unsigned char* pbSynchronize);
  extern int __stdcall SEPIA2_SOMD_SetFreqTrigMode          (int iDevIdx,     int   iSlotId,  int   iFreqTrigIdx,  unsigned char   bSynchronize);
  //
  extern int __stdcall SEPIA2_SOMD_GetTriggerRange          (int iDevIdx,     int   iSlotId,  int*  piMilliVoltLow, int* piMilliVoltHigh);
  extern int __stdcall SEPIA2_SOMD_GetTriggerLevel          (int iDevIdx,     int   iSlotId,  int*  piMilliVolt);
  extern int __stdcall SEPIA2_SOMD_SetTriggerLevel          (int iDevIdx,     int   iSlotId,  int   iMilliVolt);
  //
  extern int __stdcall SEPIA2_SOMD_GetBurstValues           (int iDevIdx,     int   iSlotId,  unsigned short* pwDivider,   unsigned char* pbPreSync,    unsigned char* pbMaskSync);
  extern int __stdcall SEPIA2_SOMD_SetBurstValues           (int iDevIdx,     int   iSlotId,  unsigned short  wDivider,    unsigned char  bPreSync,     unsigned char  bMaskSync);
  //
  extern int __stdcall SEPIA2_SOMD_GetBurstLengthArray      (int iDevIdx,     int   iSlotId,  long* plBurstLen1, long* plBurstLen2, long* plBurstLen3, long* plBurstLen4, long* plBurstLen5, long* plBurstLen6, long* plBurstLen7, long* plBurstLen8);
  extern int __stdcall SEPIA2_SOMD_SetBurstLengthArray      (int iDevIdx,     int   iSlotId,  long  lBurstLen1,  long  lBurstLen2,  long  lBurstLen3,  long  lBurstLen4,  long  lBurstLen5,  long  lBurstLen6,  long  lBurstLen7,  long  lBurstLen8);
  //
  extern int __stdcall SEPIA2_SOMD_GetOutNSyncEnable        (int iDevIdx,     int   iSlotId,  unsigned char* pbOutEnable,  unsigned char* pbSyncEnable, unsigned char* pbSyncInverse);
  extern int __stdcall SEPIA2_SOMD_SetOutNSyncEnable        (int iDevIdx,     int   iSlotId,  unsigned char  bOutEnable,   unsigned char  bSyncEnable,  unsigned char  bSyncInverse);
  //
  extern int __stdcall SEPIA2_SOMD_DecodeAUXINSequencerCtrl (int iAUXInCtrl,  char* cSequencerCtrl);
  extern int __stdcall SEPIA2_SOMD_GetAUXIOSequencerCtrl    (int iDevIdx,     int   iSlotId,  unsigned char* pbAUXOutCtrl, unsigned char* pbAUXInCtrl);
  extern int __stdcall SEPIA2_SOMD_SetAUXIOSequencerCtrl    (int iDevIdx,     int   iSlotId,  unsigned char  bAUXOutCtrl,  unsigned char  bAUXInCtrl);
  //   
  extern int __stdcall SEPIA2_SOMD_GetSeqOutputInfos        (int iDevIdx,     int   iSlotId,  unsigned char  bSeqOutIdx, unsigned char* pbDelayed, unsigned char* pbForcedUndelayed, unsigned char* pbOutCombi, unsigned char* pbMaskedCombi, double* pf64CoarseDly, unsigned char* pbFineDly); // [double fCoarseDly] : ns
  extern int __stdcall SEPIA2_SOMD_SetSeqOutputInfos        (int iDevIdx,     int   iSlotId,  unsigned char  bSeqOutIdx, unsigned char  bDelayed,  unsigned char  bOutCombi, unsigned char bMaskedCombi, double fCoarseDly, unsigned char bFineDly);  // [unsigned char bFineDly] : a.u., shouldn't be read as ps
  //
  extern int __stdcall SEPIA2_SOMD_SynchronizeNow           (int iDevIdx,     int   iSlotId);
  extern int __stdcall SEPIA2_SOMD_DecodeModuleState        (unsigned short wState, char* cStatusText);
  extern int __stdcall SEPIA2_SOMD_GetStatusError           (int iDevIdx,     int   iSlotId,  unsigned short* pwState,      short* piErrorCode);
  extern int __stdcall SEPIA2_SOMD_GetTrigSyncFreq          (int iDevIdx,     int   iSlotId,  unsigned char*  pbFreqStable, unsigned long* pulTrigSyncFreq);
  extern int __stdcall SEPIA2_SOMD_GetDelayUnits            (int iDevIdx,     int   iSlotId,  double*      pfCoarseDlyStep, unsigned char* pbFineDlyStepCount); // [double fCoarseDlyStep] : ns
  extern int __stdcall SEPIA2_SOMD_GetFWVersion             (int iDevIdx,     int   iSlotId,  unsigned long*  pulFWVersion);    
  //
  extern int __stdcall SEPIA2_SOMD_FWReadPage               (int iDevIdx,     int   iSlotId,  unsigned short  iPageIdx, unsigned char* pbFWPage);
  extern int __stdcall SEPIA2_SOMD_FWWritePage              (int iDevIdx,     int   iSlotId,  unsigned short  iPageIdx, unsigned char* pbFWPage);
  extern int __stdcall SEPIA2_SOMD_GetHWParams              (int iDevIdx,     int   iSlotId,  unsigned short* pwHWParTemp1, unsigned short* pwHWParTemp2, unsigned short* pwHWParTemp3, unsigned short* pwHWParVolt1, unsigned short* pwHWParVolt2, unsigned short* pwHWParVolt3, unsigned short* pwHWParVolt4, unsigned short* pwHWParAUX);


  // ---  VisUV/IR  VUV / VIR functions  ------------------------------------------

  extern int __stdcall SEPIA2_VUV_VIR_GetDeviceType         (int iDevIdx,     int   iSlotId,  char* pcDeviceType,     unsigned char* pbOptCW, unsigned char* pbOptFanSwitch);
  extern int __stdcall SEPIA2_VUV_VIR_DecodeFreqTrigMode    (int iDevIdx,     int   iSlotId,  int    iMainTrigSrcIdx, int    iMainFreqDivIdx, char* pcMainFreqTrig, int*  piMainFreq, unsigned char* pbTrigDividerEnabled, unsigned char* pbTrigLevelEnabled);
  extern int __stdcall SEPIA2_VUV_VIR_GetTrigLevelRange     (int iDevIdx,     int   iSlotId,  int*  piUpperTL,        int*  piLowerTL,        int*  piResolTL);
  extern int __stdcall SEPIA2_VUV_VIR_GetTriggerData        (int iDevIdx,     int   iSlotId,  int*  piMainTrigSrcIdx, int*  piMainFreqDivIdx, int*  piTrigLevel);
  extern int __stdcall SEPIA2_VUV_VIR_SetTriggerData        (int iDevIdx,     int   iSlotId,  int    iMainTrigSrcIdx, int    iMainFreqDivIdx, int    iTrigLevel);
  extern int __stdcall SEPIA2_VUV_VIR_GetIntensityRange     (int iDevIdx,     int   iSlotId,  int*  piUpperIntens,    int*  piLowerIntens,    int*  piResolIntens);
  extern int __stdcall SEPIA2_VUV_VIR_GetIntensity          (int iDevIdx,     int   iSlotId,  int*  piIntensity);
  extern int __stdcall SEPIA2_VUV_VIR_SetIntensity          (int iDevIdx,     int   iSlotId,  int    iIntensity);
  extern int __stdcall SEPIA2_VUV_VIR_GetFan                (int iDevIdx,     int   iSlotId,  unsigned char* pbFanRunning);
  extern int __stdcall SEPIA2_VUV_VIR_SetFan                (int iDevIdx,     int   iSlotId,  unsigned char   bFanRunning);


  // ---  Prima  PRI functions  ------------------------------------------

  extern int __stdcall SEPIA2_PRI_GetDeviceInfo             (int iDevIdx,     int   iSlotId,  char* pcDeviceID,       char* pcDeviceType,  char*  pcFW_Version,   int*  piWL_Count);
  extern int __stdcall SEPIA2_PRI_DecodeOperationMode       (int iDevIdx,     int   iSlotId,  int    iOperModeIdx,    char* pcOperMode);
  extern int __stdcall SEPIA2_PRI_GetOperationMode          (int iDevIdx,     int   iSlotId,  int*  piOperModeIdx);
  extern int __stdcall SEPIA2_PRI_SetOperationMode          (int iDevIdx,     int   iSlotId,  int    iOperModeIdx);
  extern int __stdcall SEPIA2_PRI_DecodeTriggerSource       (int iDevIdx,     int   iSlotId,  int    iTrgSrcIdx,      char* pcTrgSrc,      unsigned char* pbFrequencyEnabled, unsigned char* pbTrigLevelEnabled);
  extern int __stdcall SEPIA2_PRI_GetTriggerSource          (int iDevIdx,     int   iSlotId,  int*  piTrgSrcIdx);
  extern int __stdcall SEPIA2_PRI_SetTriggerSource          (int iDevIdx,     int   iSlotId,  int    iTrgSrcIdx);
  extern int __stdcall SEPIA2_PRI_GetTriggerLevelLimits     (int iDevIdx,     int   iSlotId,  int*  piTrg_MinLvl,     int*  piTrg_MaxLvl,  int*   piTrg_LvlRes);
  extern int __stdcall SEPIA2_PRI_GetTriggerLevel           (int iDevIdx,     int   iSlotId,  int*  piTrgLevel);
  extern int __stdcall SEPIA2_PRI_SetTriggerLevel           (int iDevIdx,     int   iSlotId,  int    iTrgLevel);
  extern int __stdcall SEPIA2_PRI_GetFrequencyLimits        (int iDevIdx,     int   iSlotId,  int*  piMinFreq,        int*  piMaxFreq);
  extern int __stdcall SEPIA2_PRI_GetFrequency              (int iDevIdx,     int   iSlotId,  int*  piFrequency);
  extern int __stdcall SEPIA2_PRI_SetFrequency              (int iDevIdx,     int   iSlotId,  int    iFrequency);
  extern int __stdcall SEPIA2_PRI_GetGatingLimits           (int iDevIdx,     int   iSlotId,  int*  piMinOnTime,      int*  piMaxOnTime,   int*  pbMinOffTimefactor,  int*  pbMaxOffTimefactor);
  extern int __stdcall SEPIA2_PRI_GetGatingData             (int iDevIdx,     int   iSlotId,  int*  piOnTime,         int*  piOffTimefact);
  extern int __stdcall SEPIA2_PRI_SetGatingData             (int iDevIdx,     int   iSlotId,  int    iOnTime,         int    iOffTimefact);
  extern int __stdcall SEPIA2_PRI_GetGatingEnabled          (int iDevIdx,     int   iSlotId,  unsigned char* pbGatingEnabled);
  extern int __stdcall SEPIA2_PRI_SetGatingEnabled          (int iDevIdx,     int   iSlotId,  unsigned char   bGatingEnabled);
  extern int __stdcall SEPIA2_PRI_GetGateHighImpedance      (int iDevIdx,     int   iSlotId,  unsigned char* pbHighImpedance);
  extern int __stdcall SEPIA2_PRI_SetGateHighImpedance      (int iDevIdx,     int   iSlotId,  unsigned char   bHighImpedance);
  extern int __stdcall SEPIA2_PRI_DecodeWavelength          (int iDevIdx,     int   iSlotId,  int    iWLIdx,          int*  piWL);
  extern int __stdcall SEPIA2_PRI_GetWavelengthIdx          (int iDevIdx,     int   iSlotId,  int*  piWLIdx);
  extern int __stdcall SEPIA2_PRI_SetWavelengthIdx          (int iDevIdx,     int   iSlotId,  int    iWLIdx);
  extern int __stdcall SEPIA2_PRI_GetIntensity              (int iDevIdx,     int   iSlotId,  int    iWLIdx,          unsigned short* pwIntensity);
  extern int __stdcall SEPIA2_PRI_SetIntensity              (int iDevIdx,     int   iSlotId,  int    iWLIdx,          unsigned short   wIntensity);


#endif // __SEPIA2_LIB_H__

#pragma message ("********************************  " __FILE__ " ***     ...Leaving Declaration File")

