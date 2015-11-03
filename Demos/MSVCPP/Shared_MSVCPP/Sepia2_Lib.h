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
//  apo  01.10.15   removed some superfluous SPM info functions from API
//
//-----------------------------------------------------------------------------
//
#pragma message ("********************************  " __FILE__ " ***     Entering Declaration File...")

#ifndef   __SEPIA2_LIB_H__
  #define __SEPIA2_LIB_H__

  #pragma message ("********************************  " __FILE__ " ***     Declaration Commencing...")

  #ifdef __linux__
    #define   __stdcall
  #endif

  #ifndef   _INVOKED_BY_SEPIA2_DLL_
    #define   __declspec(X)   extern
    #pragma message ("********************************  " __FILE__ " ***     Declaration extern (not invoked by declarator)")
  #else
    #ifndef SEPIA2_DLL_EXPORTS
      #ifndef SEPIA2_DLL_IMPORTS
        #define __declspec(X)   extern
        #pragma message ("********************************  " __FILE__ " ***     Declaration extern (neither import nor export)")
      #else
        #define DIRECTION dllimport
        #pragma message ("********************************  " __FILE__ " ***     Declaration Direction = dllimport")
      #endif
    #else
      #define   DIRECTION dllexport
        #pragma message ("********************************  " __FILE__ " ***     Declaration Direction = dllexport")
    #endif
  #endif // _INVOKED_BY_SEPIA2_DLL_


  // ---  library functions  --------------------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_LIB_DecodeError               (int iErrCode, char* cErrorString);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_LIB_GetVersion                (char* cLibVersion);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_LIB_IsRunningOnWine           (unsigned char* pbIsRunningOnWine);


  // ---  USB functions  ------------------------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_USB_OpenDevice                (int iDevIdx,     char* cProductModel,     char* cSerialNumber);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_USB_OpenGetSerNumAndClose     (int iDevIdx,     char* cProductModel,     char* cSerialNumber);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_USB_GetStrDescriptor          (int iDevIdx,     char* cDescriptor);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_USB_CloseDevice               (int iDevIdx);


  // ---  firmware functions  -------------------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_FWR_DecodeErrPhaseName        (int iErrPhase,   char* cErrorPhase);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_FWR_GetVersion                (int iDevIdx,     char* cFWVersion);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_FWR_GetLastError              (int iDevIdx,     int*  piErrCode,       int*  piPhase,       int* piLocation,  int* piSlot, char* cCondition);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_FWR_GetWorkingMode            (int iDevIdx,     int*  piMode);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_FWR_SetWorkingMode            (int iDevIdx,     int   iMode);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_FWR_RollBackToPermanentValues (int iDevIdx);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_FWR_StoreAsPermanentValues    (int iDevIdx);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_FWR_GetModuleMap              (int iDevIdx,     int   iPerformRestart, int*  piModuleCount);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_FWR_GetModuleInfoByMapIdx     (int iDevIdx,     int   iMapIdx,         int*  piSlotId,      unsigned char* pbIsPrimary, unsigned char* pbIsBackPlane,  unsigned char* pbHasUptimeCounter);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_FWR_GetUptimeInfoByMapIdx     (int iDevIdx,     int   iMapIdx,         unsigned long* pulMainPowerUp, unsigned long* pulActivePowerUp, unsigned long* pulScaledPowerUp);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_FWR_CreateSupportRequestText  (int iDevIdx,     char* cPreamble,       char* cCallingSW, int iOptions, int iBufferLen, char* cBuffer);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_FWR_FreeModuleMap             (int iDevIdx);


  // ---  common module functions  --------------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_COM_DecodeModuleType          (int iModuleType, char* cModulType);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_COM_DecodeModuleTypeAbbr      (int iModuleType, char* cModulTypeAbbr);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_COM_GetModuleType             (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   int* piModuleType);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_COM_HasSecondaryModule        (int iDevIdx,     int   iSlotId,  int*  piHasSecondary);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_COM_GetSerialNumber           (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   char* cSerialNumber);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_COM_GetSupplementaryInfos     (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   char* cLabel, char* cReleaseDate, char* cRevision, char* cHdrMemo);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_COM_GetPresetInfo             (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   int   iPresetNr,  unsigned char* pbIsSet, char* cPresetMemo);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_COM_RecallPreset              (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   int   iPresetNr);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_COM_SaveAsPreset              (int iDevIdx,     int   iSlotId,  int   iSetPrimary,   int   iPresetNr,  char* cPresetMemo);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_COM_IsWritableModule          (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   unsigned char* pbIsWritable);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_COM_UpdateModuleData          (int iDevIdx,     int   iSlotId,  int   iSetPrimary,   char* pcDCLFileName);


  // ---  SCM 828 functions  --------------------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_SCM_GetPowerAndLaserLEDS      (int iDevIdx,     int   iSlotId,  unsigned char* pbPowerLED,  unsigned char* pbLaserActiveLED);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SCM_GetLaserLocked            (int iDevIdx,     int   iSlotId,  unsigned char* pbLocked);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SCM_GetLaserSoftLock          (int iDevIdx,     int   iSlotId,  unsigned char* pbSoftLocked);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SCM_SetLaserSoftLock          (int iDevIdx,     int   iSlotId,  unsigned char  bSoftLocked);


  // ---  SLM 828 functions  --------------------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_SLM_DecodeFreqTrigMode        (int iFreq,       char* cFreqTrigMode);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SLM_DecodeHeadType            (int iHeadType,   char* cHeadType);
  //
#ifdef __INCLUDE_DEPRECATED_SLM_FUNCTIONS__
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SLM_GetParameters             (int iDevIdx,     int   iSlotId,  int*  piFreq,  unsigned char* pbPulseMode, int* piHead,  unsigned char* pbIntensity);
  // deprecated  : SEPIA2_SLM_GetParameters;
  // use instead : SEPIA2_SLM_GetIntensityFineStep, SEPIA2_SLM_GetPulseParameters
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SLM_SetParameters             (int iDevIdx,     int   iSlotId,  int   iFreq,   unsigned char  bPulseMode,                unsigned char  bIntensity);
  // deprecated  : SEPIA2_SLM_SetParameters;
  // use instead : SEPIA2_SLM_SetIntensityFineStep, SEPIA2_SLM_SetPulseParameters
#endif
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SLM_GetIntensityFineStep      (int iDevIdx,     int   iSlotId,  unsigned short* pwIntensity);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SLM_SetIntensityFineStep      (int iDevIdx,     int   iSlotId,  unsigned short  wIntensity);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SLM_GetPulseParameters        (int iDevIdx,     int   iSlotId,  int*  piFreq, unsigned char* pbPulseMode,  int* piHeadType);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SLM_SetPulseParameters        (int iDevIdx,     int   iSlotId,  int   iFreq,  unsigned char  bPulseMode);


  // ---  SML 828 functions  --------------------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_SML_DecodeHeadType            (int iHeadType,   char* cHeadType);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SML_GetParameters             (int iDevIdx,     int   iSlotId,  unsigned char* pbPulseMode, int* piHead, unsigned char* pbIntensity);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SML_SetParameters             (int iDevIdx,     int   iSlotId,  unsigned char  bPulseMode,               unsigned char  bIntensity);


  // ---  SOM 828 functions  --------------------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_DecodeFreqTrigMode        (int iDevIdx,     int   iSlotId,  int   iFreqTrigMode, char* cFreqTrigMode);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_GetFreqTrigMode           (int iDevIdx,     int   iSlotId,  int*  piFreqTrigMode);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_SetFreqTrigMode           (int iDevIdx,     int   iSlotId,  int   iFreqTrigMode);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_GetTriggerRange           (int iDevIdx,     int   iSlotId,  int*  piMilliVoltLow, int* piMilliVoltHigh);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_GetTriggerLevel           (int iDevIdx,     int   iSlotId,  int*  piMilliVolt);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_SetTriggerLevel           (int iDevIdx,     int   iSlotId,  int   iMilliVolt);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_GetBurstValues            (int iDevIdx,     int   iSlotId,  unsigned char* pbDivider,   unsigned char* pbPreSync,    unsigned char* pbMaskSync);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_SetBurstValues            (int iDevIdx,     int   iSlotId,  unsigned char  bDivider,    unsigned char  bPreSync,     unsigned char  bMaskSync);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_GetBurstLengthArray       (int iDevIdx,     int   iSlotId,  long* plBurstLen1, long* plBurstLen2, long* plBurstLen3, long* plBurstLen4, long* plBurstLen5, long* plBurstLen6, long* plBurstLen7, long* plBurstLen8);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_SetBurstLengthArray       (int iDevIdx,     int   iSlotId,  long  lBurstLen1,  long  lBurstLen2,  long  lBurstLen3,  long  lBurstLen4,  long  lBurstLen5,  long  lBurstLen6,  long  lBurstLen7,  long  lBurstLen8);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_GetOutNSyncEnable         (int iDevIdx,     int   iSlotId,  unsigned char* pbOutEnable,  unsigned char* pbSyncEnable, unsigned char* pbSyncInverse);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_SetOutNSyncEnable         (int iDevIdx,     int   iSlotId,  unsigned char  bOutEnable,   unsigned char  bSyncEnable,  unsigned char  bSyncInverse);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_DecodeAUXINSequencerCtrl  (int iAUXInCtrl,  char* cSequencerCtrl);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_GetAUXIOSequencerCtrl     (int iDevIdx,     int   iSlotId,  unsigned char* pbAUXOutCtrl, unsigned char* pbAUXInCtrl);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOM_SetAUXIOSequencerCtrl     (int iDevIdx,     int   iSlotId,  unsigned char  bAUXOutCtrl,  unsigned char  bAUXInCtrl);


  // ---  SOM 828 D functions  --------------------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_DecodeFreqTrigMode       (int iDevIdx,     int   iSlotId,  int   iFreqTrigIdx, char* cFreqTrigMode);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetFreqTrigMode          (int iDevIdx,     int   iSlotId,  int*  piFreqTrigIdx, unsigned char* pbSynchronize);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_SetFreqTrigMode          (int iDevIdx,     int   iSlotId,  int   iFreqTrigIdx,  unsigned char   bSynchronize);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetTriggerRange          (int iDevIdx,     int   iSlotId,  int*  piMilliVoltLow, int* piMilliVoltHigh);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetTriggerLevel          (int iDevIdx,     int   iSlotId,  int*  piMilliVolt);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_SetTriggerLevel          (int iDevIdx,     int   iSlotId,  int   iMilliVolt);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetBurstValues           (int iDevIdx,     int   iSlotId,  unsigned short* pwDivider,   unsigned char* pbPreSync,    unsigned char* pbMaskSync);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_SetBurstValues           (int iDevIdx,     int   iSlotId,  unsigned short  wDivider,    unsigned char  bPreSync,     unsigned char  bMaskSync);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetBurstLengthArray      (int iDevIdx,     int   iSlotId,  long* plBurstLen1, long* plBurstLen2, long* plBurstLen3, long* plBurstLen4, long* plBurstLen5, long* plBurstLen6, long* plBurstLen7, long* plBurstLen8);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_SetBurstLengthArray      (int iDevIdx,     int   iSlotId,  long  lBurstLen1,  long  lBurstLen2,  long  lBurstLen3,  long  lBurstLen4,  long  lBurstLen5,  long  lBurstLen6,  long  lBurstLen7,  long  lBurstLen8);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetOutNSyncEnable        (int iDevIdx,     int   iSlotId,  unsigned char* pbOutEnable,  unsigned char* pbSyncEnable, unsigned char* pbSyncInverse);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_SetOutNSyncEnable        (int iDevIdx,     int   iSlotId,  unsigned char  bOutEnable,   unsigned char  bSyncEnable,  unsigned char  bSyncInverse);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_DecodeAUXINSequencerCtrl (int iAUXInCtrl,  char* cSequencerCtrl);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetAUXIOSequencerCtrl    (int iDevIdx,     int   iSlotId,  unsigned char* pbAUXOutCtrl, unsigned char* pbAUXInCtrl);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_SetAUXIOSequencerCtrl    (int iDevIdx,     int   iSlotId,  unsigned char  bAUXOutCtrl,  unsigned char  bAUXInCtrl);
  //   
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetSeqOutputInfos        (int iDevIdx,     int   iSlotId,  unsigned char  bSeqOutIdx, unsigned char* pbDelayed, unsigned char* pbForcedUndelayed, unsigned char* pbOutCombi, unsigned char* pbMaskedCombi, double* pf64CoarseDly, unsigned char* pbFineDly); // [double fCoarseDly] : ns
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_SetSeqOutputInfos        (int iDevIdx,     int   iSlotId,  unsigned char  bSeqOutIdx, unsigned char  bDelayed,  unsigned char  bOutCombi, unsigned char bMaskedCombi, double fCoarseDly, unsigned char bFineDly);  // [unsigned char bFineDly] : a.u., shouldn't be read as ps
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_SynchronizeNow           (int iDevIdx,     int   iSlotId);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_DecodeModuleState        (unsigned short wState, char* cStatusText);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetStatusError           (int iDevIdx,     int   iSlotId,  unsigned short* pwState,      short* piErrorCode);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetTrigSyncFreq          (int iDevIdx,     int   iSlotId,  unsigned char*  pbFreqStable, unsigned long* pulTrigSyncFreq);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetDelayUnits            (int iDevIdx,     int   iSlotId,  double*      pfCoarseDlyStep, unsigned char* pbFineDlyStepCount); // [double fCoarseDlyStep] : ns
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetFWVersion             (int iDevIdx,     int   iSlotId,  unsigned long*  pulFWVersion);    
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_FWReadPage               (int iDevIdx,     int   iSlotId,  unsigned short  iPageIdx, unsigned char* pbFWPage);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_FWWritePage              (int iDevIdx,     int   iSlotId,  unsigned short  iPageIdx, unsigned char* pbFWPage);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_Calibrate                (int iDevIdx,     int   iSlotId,  unsigned char   bCalParam);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SOMD_GetHWParams              (int iDevIdx,     int   iSlotId,  unsigned short* pwHWParTemp1, unsigned short* pwHWParTemp2, unsigned short* pwHWParTemp3, unsigned short* pwHWParVolt1, unsigned short* pwHWParVolt2, unsigned short* pwHWParVolt3, unsigned short* pwHWParVolt4, unsigned short* pwHWParAUX);


  // ---  SWM 828 functions (PPL400)  -----------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWM_DecodeRangeIdx            (int iDevIdx,     int   iSlotId,  int iRangeIdx, int* iUpperLimit);
  //
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWM_GetUIConstants            (int iDevIdx,     int   iSlotId,  unsigned char* bTBNdxCount, unsigned short* wMaxAmplitude, unsigned short* wMaxSlewRate, unsigned short* wExpRampEffect, unsigned short* wMinUserValue, unsigned short* wMaxUserValue, unsigned short* wUserResolution);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWM_GetCurveParams            (int iDevIdx,     int   iSlotId,  int iCurveIdx, unsigned char* bTBNdx, unsigned short* wPAPml, unsigned short* wRRPml,   unsigned short* wPSPml, unsigned short* wRSPml, unsigned short* wWSPml);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWM_SetCurveParams            (int iDevIdx,     int   iSlotId,  int iCurveIdx, unsigned char  bTBNdx, unsigned short  wPAPml, unsigned short  wRRPml,   unsigned short  wPSPml, unsigned short  wRSPml, unsigned short  wWSPml);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWM_GetCalTableVal            (int iDevIdx,     int   iSlotId,  char* cTableName, unsigned char bTabIdx, unsigned char bTabCol, unsigned short* wValue);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWM_GetExtAtten               (int iDevIdx,     int   iSlotId,  float* fExtAtt);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWM_SetExtAtten               (int iDevIdx,     int   iSlotId,  float  fExtAtt);


  // ---  VCL 828 functions (PPL400)  -----------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_VCL_GetUIConstants            (int iDevIdx,     int   iSlotId,  int* piMinUserValueTmp, int* piMaxUserValueTmp, int* piUserResolutionTmp);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_VCL_GetTemperature            (int iDevIdx,     int   iSlotId,  int* piTemperature);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_VCL_SetTemperature            (int iDevIdx,     int   iSlotId,  int   iTemperature);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_VCL_GetBiasVoltage            (int iDevIdx,     int   iSlotId,  int* piBiasVoltage);


  // ---  Solea SPM functions  ------------------------------------------------

  #ifndef _SPM_TYPES_DEFINED_
  
    #define SEPIA2_SPM_TEMPERATURE_SENSORCOUNT         6
    typedef union {
      struct {
        unsigned short wT_Pump1;
        unsigned short wT_Pump2;
        unsigned short wT_Pump3;
        unsigned short wT_Pump4;
        unsigned short wT_FiberStack;
        unsigned short wT_AuxAdjust;
      } Temperatures;
      unsigned short wT [SEPIA2_SPM_TEMPERATURE_SENSORCOUNT];
    } T_SPM_Temperatures;
    typedef T_SPM_Temperatures* T_ptrSPM_Temperatures;

    typedef struct {
      T_SPM_Temperatures Temperatures;
      unsigned short     wOverAllCurrent;
      unsigned short     wOptionalSensor1;
      unsigned short     wOptionalSensor2;
    } T_SPM_SensorData;
    typedef T_SPM_SensorData* T_ptrSPM_SensorData;
    
  #endif

  __declspec(DIRECTION)  int   __stdcall SEPIA2_SPM_DecodeModuleState         (unsigned short wState, char* cStatusText);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SPM_GetFWVersion              (int iDevIdx,     int   iSlotId,  unsigned long* pulFWVersion);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SPM_GetSensorData             (int iDevIdx,     int   iSlotId,  T_ptrSPM_SensorData   pSensorData);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SPM_GetTemperatureAdjust      (int iDevIdx,     int   iSlotId,  T_ptrSPM_Temperatures pTempAdjust);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SPM_GetStatusError            (int iDevIdx,     int   iSlotId,  unsigned short* pwState, short* piErrorCode);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SPM_UpdateFirmware            (int iDevIdx,     int   iSlotId,  char* pcFWFileName);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SPM_SetFRAMWriteProtect       (int iDevIdx,     int   iSlotId,  unsigned char   bWriteProtect);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SPM_GetFiberAmplifierFail     (int iDevIdx,     int   iSlotId,  unsigned char* pbFiberAmpFail);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SPM_ResetFiberAmplifierFail   (int iDevIdx,     int   iSlotId,  unsigned char   bFiberAmpFail);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SPM_GetPumpPowerState         (int iDevIdx,     int   iSlotId,  unsigned char* pbPumpState, unsigned char* pbPumpMode);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SPM_SetPumpPowerState         (int iDevIdx,     int   iSlotId,  unsigned char   bPumpState, unsigned char   bPumpMode);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SPM_GetOperationTimers        (int iDevIdx,     int   iSlotId,  unsigned long*  pulMainPwrSwitch, unsigned long*  pulUTOverAll, unsigned long*  pulUTSinceDelivery, unsigned long*  pulUTSinceFiberChg);


  // ---  Solea SWS functions  ------------------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_DecodeModuleType          (int iModuleType,       char* cModulType);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_DecodeModuleState         (unsigned short wState, char* cStatusText);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_GetModuleType             (int iDevIdx,     int   iSlotId,  int* piModuleType);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_GetStatusError            (int iDevIdx,     int   iSlotId,  unsigned short* pwState,         short*          piErrorCode);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_GetParamRanges            (int iDevIdx,     int   iSlotId,  unsigned long*  pulUpperWL,      unsigned long*  pulLowerWL,    unsigned long* pulIncrWL, unsigned long* pulPPMToggleWL, unsigned long* pulUpperBW, unsigned long* pulLowerBW, unsigned long* pulIncrBW, int* piUpperBeamPos, int* piLowerBeamPos, int* piIncrBeamPos);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_GetParameters             (int iDevIdx,     int   iSlotId,  unsigned long*  pulWaveLength,   unsigned long*  pulBandWidth);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_SetParameters             (int iDevIdx,     int   iSlotId,  unsigned long    ulWaveLength,   unsigned long    ulBandWidth);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_GetIntensity              (int iDevIdx,     int   iSlotId,  unsigned long*  pulIntensityRaw, float*          pfIntensity);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_GetFWVersion              (int iDevIdx,     int   iSlotId,  unsigned long*  pulFWVersion);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_UpdateFirmware            (int iDevIdx,     int   iSlotId,  char* pcFWFileName);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_SetFRAMWriteProtect       (int iDevIdx,     int   iSlotId,  unsigned char   bWriteProtect);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_GetBeamPos                (int iDevIdx,     int   iSlotId,  short* piBeamVPos,  short* piBeamHPos);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_SetBeamPos                (int iDevIdx,     int   iSlotId,  short   iBeamVPos,  short   iBeamHPos);

  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_SetCalibrationMode        (int iDevIdx,     int   iSlotId,  unsigned char   bCalibrationMode);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_GetCalTableSize           (int iDevIdx,     int   iSlotId,  unsigned short* pwWLIdxCount, unsigned short* pwBWIdxCount);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_SetCalTableSize           (int iDevIdx,     int   iSlotId,  unsigned short  wWLIdxCount,  unsigned short   wBWIdxCount, unsigned char bInit);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_GetCalPointInfo           (int iDevIdx,     int   iSlotId,  short  iWLIdx, short iBWIdx,  unsigned long* pulWaveLength, unsigned long* pulBandWidth, short* piBeamVPos, short* piBeamHPos);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SWS_SetCalPointValues         (int iDevIdx,     int   iSlotId,  short  iWLIdx, short iBWIdx,  short iBeamVPos, short iBeamHPos);


  // ---  Solea SSM functions  ------------------------------------------------

  __declspec(DIRECTION)  int   __stdcall SEPIA2_SSM_DecodeFreqTrigMode        (int iDevIdx,     int   iSlotId,  int   iMainFreqTrigIdx, char* cMainFreqTrig, int*  piMainFreq,   unsigned char* pbTrigLevelEnabled);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SSM_GetTrigLevelRange         (int iDevIdx,     int   iSlotId,  int* piUpperTL,         int*  piLowerTL,     int*  piResolTL);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SSM_GetTriggerData            (int iDevIdx,     int   iSlotId,  int* piMainFreqTrigIdx, int*  piTrigLevel);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SSM_SetTriggerData            (int iDevIdx,     int   iSlotId,  int   iMainFreqTrigIdx, int    iTrigLevel);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SSM_SetFRAMWriteProtect       (int iDevIdx,     int   iSlotId,  unsigned char   bWriteProtect);
  __declspec(DIRECTION)  int   __stdcall SEPIA2_SSM_GetFRAMWriteProtect       (int iDevIdx,     int   iSlotId,  unsigned char* pbWriteProtect);

#endif // __SEPIA2_LIB_H__

#pragma message ("********************************  " __FILE__ " ***     ...Leaving Declaration File")

