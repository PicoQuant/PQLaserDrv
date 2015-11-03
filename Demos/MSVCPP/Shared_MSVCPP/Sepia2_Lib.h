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
//  apo  16.07.14   introduced new SOM functions Get/Set AUXIOSequencerCtrl
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

  __declspec(DIRECTION)  int __stdcall SEPIA2_LIB_DecodeError             (int iErrCode, char* cErrorString);
  __declspec(DIRECTION)  int __stdcall SEPIA2_LIB_GetVersion              (char* cLibVersion);
  __declspec(DIRECTION)  int __stdcall SEPIA2_LIB_IsRunningOnWine         (unsigned char* pbIsRunningOnWine);


  // ---  USB functions  ------------------------------------------------------

  __declspec(DIRECTION)  int __stdcall SEPIA2_USB_OpenDevice              (int iDevIdx,     char* cProductModel,     char* cSerialNumber);
  __declspec(DIRECTION)  int __stdcall SEPIA2_USB_OpenGetSerNumAndClose   (int iDevIdx,     char* cProductModel,     char* cSerialNumber);
  __declspec(DIRECTION)  int __stdcall SEPIA2_USB_GetStrDescriptor        (int iDevIdx,     char* cDescriptor);
  __declspec(DIRECTION)  int __stdcall SEPIA2_USB_CloseDevice             (int iDevIdx);


  // ---  firmware functions  -------------------------------------------------

  __declspec(DIRECTION)  int __stdcall SEPIA2_FWR_DecodeErrPhaseName      (int iErrPhase,   char* cErrorPhase);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_FWR_GetVersion              (int iDevIdx,     char* cFWVersion);
  __declspec(DIRECTION)  int __stdcall SEPIA2_FWR_GetLastError            (int iDevIdx,     int*  piErrCode,       int*  piPhase,       int* piLocation,  int* piSlot, char* cCondition);
  __declspec(DIRECTION)  int __stdcall SEPIA2_FWR_GetModuleMap            (int iDevIdx,     int   iPerformRestart, int*  piModuleCount);
  __declspec(DIRECTION)  int __stdcall SEPIA2_FWR_GetModuleInfoByMapIdx   (int iDevIdx,     int   iMapIdx,         int*  piSlotId,      unsigned char* pbIsPrimary, unsigned char* pbIsBackPlane,  unsigned char* pbHasUptimeCounter);
  __declspec(DIRECTION)  int __stdcall SEPIA2_FWR_GetUptimeInfoByMapIdx   (int iDevIdx,     int   iMapIdx,         unsigned long* pulMainPowerUp, unsigned long* pulActivePowerUp, unsigned long* pulScaledPowerUp);
  __declspec(DIRECTION)  int __stdcall SEPIA2_FWR_FreeModuleMap           (int iDevIdx);


  // ---  common module functions  --------------------------------------------

  __declspec(DIRECTION)  int __stdcall SEPIA2_COM_DecodeModuleType        (int iModuleType, char* cModulType);
  __declspec(DIRECTION)  int __stdcall SEPIA2_COM_DecodeModuleTypeAbbr    (int iModuleType, char* cModulTypeAbbr);
  __declspec(DIRECTION)  int __stdcall SEPIA2_COM_Slot2PathString         (int iDevIdx,     int   iSlotId,  char* pcPath);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_COM_GetModuleType           (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   int* piModuleType);
  __declspec(DIRECTION)  int __stdcall SEPIA2_COM_HasSecondaryModule      (int iDevIdx,     int   iSlotId,  int*  piHasSecondary);
  __declspec(DIRECTION)  int __stdcall SEPIA2_COM_GetSerialNumber         (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   char* cSerialNumber);
  __declspec(DIRECTION)  int __stdcall SEPIA2_COM_GetPresetInfo           (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   int   iPresetNr,  unsigned char* pbIsSet, char* cPresetMemo);
  __declspec(DIRECTION)  int __stdcall SEPIA2_COM_RecallPreset            (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   int   iPresetNr);
  __declspec(DIRECTION)  int __stdcall SEPIA2_COM_SaveAsPreset            (int iDevIdx,     int   iSlotId,  int   iSetPrimary,   int   iPresetNr,  char* cPresetMemo);
  __declspec(DIRECTION)  int __stdcall SEPIA2_COM_IsWritableModule        (int iDevIdx,     int   iSlotId,  int   iGetPrimary,   unsigned char* pbIsWritable);
  __declspec(DIRECTION)  int __stdcall SEPIA2_COM_UpdateModuleData        (int iDevIdx,     int   iSlotId,  int   iSetPrimary,   char* pcDCLFileName);


  // ---  SCM 828 functions  --------------------------------------------------

  __declspec(DIRECTION)  int __stdcall SEPIA2_SCM_GetPowerAndLaserLEDS    (int iDevIdx,     int   iSlotId,  unsigned char* pbPowerLED,  unsigned char* pbLaserActiveLED);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SCM_GetLaserLocked          (int iDevIdx,     int   iSlotId,  unsigned char* pbLocked);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SCM_GetLaserSoftLock        (int iDevIdx,     int   iSlotId,  unsigned char* pbSoftLocked);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SCM_SetLaserSoftLock        (int iDevIdx,     int   iSlotId,  unsigned char  bSoftLocked);


  // ---  SLM 828 functions  --------------------------------------------------

  __declspec(DIRECTION)  int __stdcall SEPIA2_SLM_DecodeFreqTrigMode      (int iFreq,       char* cFreqTrigMode);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SLM_DecodeHeadType          (int iHeadType,   char* cHeadType);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_SLM_GetParameters           (int iDevIdx,     int   iSlotId,  int*  piFreq,  unsigned char* pbPulseMode, int* piHead,  unsigned char* pbIntensity);
  // deprecated  : SEPIA2_SLM_GetParameters;
  // use instead : SEPIA2_SLM_GetIntensityFineStep, SEPIA2_SLM_GetPulseParameters
  __declspec(DIRECTION)  int __stdcall SEPIA2_SLM_SetParameters           (int iDevIdx,     int   iSlotId,  int   iFreq,   unsigned char  bPulseMode,                unsigned char  bIntensity);
  // deprecated  : SEPIA2_SLM_SetParameters;
  // use instead : SEPIA2_SLM_SetIntensityFineStep, SEPIA2_SLM_SetPulseParameters
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_SLM_GetIntensityFineStep    (int iDevIdx,     int   iSlotId,  word* pwIntensity);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SLM_SetIntensityFineStep    (int iDevIdx,     int   iSlotId,  word  wIntensity);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SLM_GetPulseParameters      (int iDevIdx,     int   iSlotId,  int*  piFreq, unsigned char* pbPulseMode,  int* piHeadType);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SLM_SetPulseParameters      (int iDevIdx,     int   iSlotId,  int   iFreq,  unsigned char  bPulseMode);


  // ---  SML 828 functions  --------------------------------------------------

  __declspec(DIRECTION)  int __stdcall SEPIA2_SML_DecodeHeadType          (int iHeadType,   char* cHeadType);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_SML_GetParameters           (int iDevIdx,     int   iSlotId,  unsigned char* pbPulseMode, int* piHead, unsigned char* pbIntensity);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SML_SetParameters           (int iDevIdx,     int   iSlotId,  unsigned char  bPulseMode,               unsigned char  bIntensity);


  // ---  SOM 828 functions  --------------------------------------------------

  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_DecodeFreqTrigMode      (int iDevIdx,     int   iSlotId,  int   iFreqTrigMode, char* cFreqTrigMode);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_GetFreqTrigMode         (int iDevIdx,     int   iSlotId,  int*  piFreqTrigMode);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_SetFreqTrigMode         (int iDevIdx,     int   iSlotId,  int   iFreqTrigMode);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_GetTriggerRange         (int iDevIdx,     int   iSlotId,  int*  piMilliVoltLow, int* piMilliVoltHigh);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_GetTriggerLevel         (int iDevIdx,     int   iSlotId,  int*  piMilliVolt);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_SetTriggerLevel         (int iDevIdx,     int   iSlotId,  int   iMilliVolt);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_GetBurstValues          (int iDevIdx,     int   iSlotId,  unsigned char* pbDivider,   unsigned char* pbPreSync,    unsigned char* pbMaskSync);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_SetBurstValues          (int iDevIdx,     int   iSlotId,  unsigned char  bDivider,    unsigned char  bPreSync,     unsigned char  bMaskSync);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_GetBurstLengthArray     (int iDevIdx,     int   iSlotId,  long* plBurstLen1, long* plBurstLen2, long* plBurstLen3, long* plBurstLen4, long* plBurstLen5, long* plBurstLen6, long* plBurstLen7, long* plBurstLen8);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_SetBurstLengthArray     (int iDevIdx,     int   iSlotId,  long  lBurstLen1,  long  lBurstLen2,  long  lBurstLen3,  long  lBurstLen4,  long  lBurstLen5,  long  lBurstLen6,  long  lBurstLen7,  long  lBurstLen8);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_GetOutNSyncEnable       (int iDevIdx,     int   iSlotId,  unsigned char* pbOutEnable,  unsigned char* pbSyncEnable, unsigned char* pbSyncInverse);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_SetOutNSyncEnable       (int iDevIdx,     int   iSlotId,  unsigned char  bOutEnable,   unsigned char  bSyncEnable,  unsigned char  bSyncInverse);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_GetAUXIOSequencerCtrl   (int iDevIdx,     int   iSlotId,  byte* pbAUXOutCtrl, byte* pbAUXInCtrl);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOM_SetAUXIOSequencerCtrl   (int iDevIdx,     int   iSlotId,  byte  bAUXOutCtrl,  byte  bAUXInCtrl);


  // ---  SOM 828 D functions  --------------------------------------------------

  __declspec(DIRECTION)  int __stdcall SEPIA2_SOMD_GetBurstValues         (int iDevIdx,     int   iSlotId,  word* pwDivider,   unsigned char* pbPreSync,    unsigned char* pbMaskSync);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOMD_SetBurstValues         (int iDevIdx,     int   iSlotId,  word  wDivider,    unsigned char  bPreSync,     unsigned char  bMaskSync);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOMD_GetOutMuxArray         (int iDevIdx,     int   iSlotId,  word* pwOutMux);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOMD_SetOutMuxArray         (int iDevIdx,     int   iSlotId,  word* pwOutMux);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOMD_GetDelayInfos          (int iDevIdx,     int   iSlotId,  byte  bSeqChan,    __int64* pi64CoarseDly, byte* pbFineDly);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SOMD_SetDelayInfos          (int iDevIdx,     int   iSlotId,  byte  bSeqChan,    __int64  i64CoarseDly,  byte  bFineDly);


  // ---  SWM 828 functions  --------------------------------------------------

  __declspec(DIRECTION)  int __stdcall SEPIA2_SWM_DecodeRangeIdx          (int iDevIdx,     int   iSlotId,  int iRangeIdx, int* iUpperLimit);
  //
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWM_GetUIConstants          (int iDevIdx,     int   iSlotId,  unsigned char* bTBNdxCount, unsigned short* wMaxAmplitude, unsigned short* wMaxSlewRate, unsigned short* wExpRampEffect, unsigned short* wMinUserValue, unsigned short* wMaxUserValue, unsigned short* wUserResolution);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWM_GetCurveParams          (int iDevIdx,     int   iSlotId,  int iCurveIdx, unsigned char* bTBNdx, unsigned short* wPAPml, unsigned short* wRRPml,   unsigned short* wPSPml, unsigned short* wRSPml, unsigned short* wWSPml);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWM_SetCurveParams          (int iDevIdx,     int   iSlotId,  int iCurveIdx, unsigned char  bTBNdx, unsigned short  wPAPml, unsigned short  wRRPml,   unsigned short  wPSPml, unsigned short  wRSPml, unsigned short  wWSPml);


  // ---  Solea SPM functions  ------------------------------------------------

  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_DecodeModuleState       (unsigned short wState, char* cStatusText);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetFWVersion            (int iDevIdx,     int   iSlotId,  unsigned long* pulFWVersion);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetManualPumpCurrent    (int iDevIdx,     int   iSlotId,  word* pwPumpCurrent1, word* pwPumpCurrent2,  word* pwPumpCurrent3);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetControlMode          (int iDevIdx,     int   iSlotId,  byte* pbCtrlMode);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetPumpCtrlParams       (int iDevIdx,     int   iSlotId,  byte   bPumpState,  T_ptrSPM_PumpCtrlParams pPumpCtrlParams);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetPhotoDiodeCurrents   (int iDevIdx,     int   iSlotId,  int*  piPhDCurrent1,   int*  piPhDCurrent2,   int*  piPhDCurrent3);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetPumpCurrents         (int iDevIdx,     int   iSlotId,  int*  piPumpCurrent1,  int*  piPumpCurrent2,  int*  piPumpCurrent3);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetSensorData           (int iDevIdx,     int   iSlotId,  T_ptrSPM_SensorData   pSensorData);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetTemperatureAdjust    (int iDevIdx,     int   iSlotId,  T_ptrSPM_Temperatures pTempAdjust);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetUpTimePowerTable     (int iDevIdx,     int   iSlotId,  byte   bPumpState, T_ptrSPM_UpTimePowerTable  pUpTimePwrTable);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetStatusError          (int iDevIdx,     int   iSlotId,  unsigned short* pwState, short* piErrorCode);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_UpdateFirmware          (int iDevIdx,     int   iSlotId,  char* pcFWFileName);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_SetFRAMWriteProtect     (int iDevIdx,     int   iSlotId,  unsigned char   bWriteProtect);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetFiberAmplifierFail   (int iDevIdx,     int   iSlotId,  byte* pbFiberAmpFail);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_ResetFiberAmplifierFail (int iDevIdx,     int   iSlotId,  byte   bFiberAmpFail);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetPumpPowerState       (int iDevIdx,     int   iSlotId,  byte* pbPumpState, byte* pbPumpMode);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_SetPumpPowerState       (int iDevIdx,     int   iSlotId,  byte   bPumpState, byte   bPumpMode);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SPM_GetOperationTimers      (int iDevIdx,     int   iSlotId,  unsigned long*  pulMainPwrSwitch, unsigned long*  pulUTOverAll, unsigned long*  pulUTSinceDelivery, unsigned long*  pulUTSinceFiberChg);


  // ---  Solea SWS functions  ------------------------------------------------

  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_DecodeModuleType        (int iModuleType,       char* cModulType);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_DecodeModuleState       (unsigned short wState, char* cStatusText);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_GetModuleType           (int iDevIdx,     int   iSlotId,  int* piModuleType);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_GetStatusError          (int iDevIdx,     int   iSlotId,  unsigned short* pwState,         short*          piErrorCode);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_GetParamRanges          (int iDevIdx,     int   iSlotId,  unsigned long*  pulUpperWL,      unsigned long*  pulLowerWL,    unsigned long* pulIncrWL, unsigned long *pulPPMToggleWL, unsigned long* pulUpperBW, unsigned long* pulLowerBW, unsigned long* pulIncrBW, int* piUpperBeamPos, int* piLowerBeamPos, int* piIncrBeamPos);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_GetParameters           (int iDevIdx,     int   iSlotId,  unsigned long*  pulWaveLength,   unsigned long*  pulBandWidth);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_SetParameters           (int iDevIdx,     int   iSlotId,  unsigned long    ulWaveLength,   unsigned long    ulBandWidth);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_GetIntensity            (int iDevIdx,     int   iSlotId,  unsigned long*  pulIntensityRaw, float*          pfIntensity);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_GetFWVersion            (int iDevIdx,     int   iSlotId,  unsigned long*  pulFWVersion);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_UpdateFirmware          (int iDevIdx,     int   iSlotId,  char* pcFWFileName);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_SetFRAMWriteProtect     (int iDevIdx,     int   iSlotId,  unsigned char   bWriteProtect);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_GetBeamPos              (int iDevIdx,     int   iSlotId,  short* piBeamVPos,  short* piBeamHPos);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_SetBeamPos              (int iDevIdx,     int   iSlotId,  short   iBeamVPos,  short   iBeamHPos);

  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_SetCalibrationMode      (int iDevIdx,     int   iSlotId,  unsigned char   bCalibrationMode);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_GetCalTableSize         (int iDevIdx,     int   iSlotId,  unsigned short* pwWLIdxCount,  unsigned short* pwBWIdxCount);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_SetCalTableSize         (int iDevIdx,     int   iSlotId,  unsigned short  wWLIdxCount,   unsigned short   wBWIdxCount, byte bInit);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_GetCalPointInfo         (int iDevIdx,     int   iSlotId,  short  iWLIdx, short iBWIdx, unsigned long *pulWaveLength, unsigned long *pulBandWidth, short *piBeamVPos, short *piBeamHPos);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SWS_SetCalPointValues       (int iDevIdx,     int   iSlotId,  short  iWLIdx, short iBWIdx, short iBeamVPos, short iBeamHPos);


  // ---  Solea SSM functions  ------------------------------------------------

  __declspec(DIRECTION)  int __stdcall SEPIA2_SSM_DecodeFreqTrigMode      (int iDevIdx,     int   iSlotId,  int   iMainFreqTrigIdx, char* cMainFreqTrig, int*  piMainFreq,   byte* pbTrigLevelEnabled);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SSM_GetTrigLevelRange       (int iDevIdx,     int   iSlotId,  int* piUpperTL,         int*  piLowerTL,     int*  piResolTL);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SSM_GetTriggerData          (int iDevIdx,     int   iSlotId,  int* piMainFreqTrigIdx, int*  piTrigLevel);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SSM_SetTriggerData          (int iDevIdx,     int   iSlotId,  int   iMainFreqTrigIdx, int    iTrigLevel);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SSM_SetFRAMWriteProtect     (int iDevIdx,     int   iSlotId,  unsigned char   bWriteProtect);
  __declspec(DIRECTION)  int __stdcall SEPIA2_SSM_GetFRAMWriteProtect     (int iDevIdx,     int   iSlotId,  unsigned char* pbWriteProtect);

#endif // __SEPIA2_LIB_H__

#pragma message ("********************************  " __FILE__ " ***     ...Leaving Declaration File")
