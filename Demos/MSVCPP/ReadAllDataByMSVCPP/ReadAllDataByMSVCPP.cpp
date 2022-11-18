//-----------------------------------------------------------------------------
//
//      ReadAllDatabyMSVCPP
//
//-----------------------------------------------------------------------------
//
//  Illustrates the functions exported by SEPIA2_Lib
//  Scans the whole PQLaserDrv rack and displays all relevant data
//
//  Consider, this code is for demonstration purposes only.
//  Don't use it in productive environments!
//
//-----------------------------------------------------------------------------
//  HISTORY:
//
//  apo  06.02.06   created
//
//  apo  12.02.07   introduced SML Multilaser Module (V1.0.2.0)
//
//  apo  05.02.14   introduced new map oriented API functions (V1.0.3.282)
//
//  apo  05.09.14   adapted to DLL version 1.1.<target>.<svn_build>
//
//  apo  18.06.15   substituted deprecated SLM functions
//                  introduced SOM-D Oscillator Module w. Delay Option (V1.1.xx.450)
//
//  apo  22.01.21   adapted to DLL version 1.2.<target>.<svn_build>
//
//  apo  28.01.21   introduced VIR, VUV module functions (for VisUV/IR) (V1.2.xx.641)
//
//  apo  30.08.22   introduced PRI module functions (for Prima, Quader) (V1.2.xx.753)
//
//-----------------------------------------------------------------------------
//

#pragma message ("**************************************************************")
#pragma message ("***                                                        ***")
#pragma message ("*** " __FILE__ " ***")                     
#pragma message ("***                                                        ***")
#pragma message ("**************************************************************")


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <windows.h>

extern "C"
{
  #include "portabt.h"
  #include "Sepia2_Def.h"
  #include "Sepia2_Lib.h"
  #include "Sepia2_ErrorCodes.h"
}

  char cNewLine [4]          = "\x0A";
  char STR_INDENT[]          = "     ";
  char STR_SEPARATORLINE []  = "    ============================================================";
//char PRAEFIXES []          = "yzafpnµm kMGTPEZY";
  char PRAEFIXES []          = "yzafpnæm kMGTPEZY";
  int  PRAEFIX_OFFSET        = 8;


#define WriteLine(FMT, ...)  {char fmt[128]; strcpy_s(fmt, 128, (FMT)); strcat_s(fmt, 128, cNewLine); printf(fmt, __VA_ARGS__);}
#define Write(FMT, ...)      {printf((FMT), __VA_ARGS__);}

void PrintUptimers (unsigned long ulMainPowerUp, unsigned long ulActivePowerUp, unsigned long ulScaledPowerUp)
{
  int    hlp;
  ldiv_t res;
  //
  hlp = (int)(5.0 * (ulMainPowerUp + 0x7F) / 0xFF);
  res = ldiv (hlp, 60);
  WriteLine ("");
  WriteLine ("%47s  = %5d:%2.2d h",  "main power uptime",   res.quot, res.rem);
  //
  if (ulActivePowerUp > 1)
  {
    hlp = (int)(5.0 * (ulActivePowerUp + 0x7F) / 0xFF);
    res = ldiv (hlp, 60);
    WriteLine ("%47s  = %5d:%2.2d hrs",  "act. power uptime", res.quot, res.rem);
    //
    if (ulScaledPowerUp > (0.001 * ulActivePowerUp))
    {
      WriteLine ("%47s  =       %5.1f%%",  "pwr scaled factor", 100.0 * ulScaledPowerUp / ulActivePowerUp);
      WriteLine("");
    }
  }
  WriteLine("");
}

char* IntToBin (char* cDest, int iDestLen, int iValue, int iDigits, unsigned char bLowToHigh, char cOnChar = '1', char cOffChar = '0')
{
  int i, iTo;
  char cTemp [33] = "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";
  //
  *cDest = '\0';
  iTo    = __min (__max (1, abs(iDigits)), 32); 
  for (i = 0; i < iTo; i++)
  {
    cTemp [i] = ((iValue & (1 << i)) != 0) ? cOnChar : cOffChar;
  }
  cTemp [iTo] = '\0';
  if (!bLowToHigh)
  {
    _strrev (cTemp);
  }
  strcpy_s (cDest, iDestLen, cTemp);
  return cDest;
}


char* trim (char* ptrIn)
{
  size_t i;
  //
  // although it might be faster to start from the left side:
  //    we avoid unnecessary pointer movements on blank strings,
  //    if we start from the right side...
  //
  // right trim
  //
  for (i=strlen(ptrIn)-1; (strlen(ptrIn) > 0) && (i >= 0); i--)
  {
    if (isspace(ptrIn[i]))
    {
      ptrIn[i] = '\0';
    }
    else
    {
      break;
    }
  }
  //
  // left trim
  //
  while (isspace(*ptrIn))
  {
    ptrIn++;
  }
  //
  return ptrIn;
}


char* FormatEng (char* cDest, int iDestLen, double fInp, int iMant, char* cUnit = "", int iFixedSpace = -1, int iFixedDigits = -1, unsigned char bUnitSep = 1)
{
  int           i;
  unsigned char bNSign;
  double        fNorm;
  double        fTemp0;
  int           iTemp;
  char          cTemp [64];
  char          cPref[2]      = " ";
  char          cUnitSep[2]   = " ";
  //
  *cDest  = '\0';
  //
  bNSign = (fInp < 0);
  if (fInp == 0)
  {
    iTemp  = 0;
    fNorm  = 0;
  }
  else 
  {
    fTemp0 = log (fabs (fInp)) / log (1000.0);
    iTemp  = (int) floor (fTemp0);
    fNorm  = pow ((double)1000.0, fmod (fTemp0, 1.0) + ((fTemp0 > 0) || ((fTemp0 - iTemp) == 0) ? 0 : 1));
  }
  //
  i = iMant-1;
  if (fNorm >=  10) 
  {
    i-=1;
  }
  if (fNorm >= 100) 
  {
    i-=1;
  }
  //
  //
  cPref[1] = 0;
  cPref[0] = ((bUnitSep || (iTemp != 0)) ? PRAEFIXES[iTemp + PRAEFIX_OFFSET] : 0);
  //
  cUnitSep[1] = 0;
  cUnitSep[0] = (bUnitSep ? ' ' : 0);
  //
  sprintf_s (cTemp, sizeof (cTemp), "%.*f%s%s%s", (iFixedDigits < 0? i : iFixedDigits), fNorm * (bNSign ? -1.0 : 1.0), cUnitSep, cPref, cUnit);
  //
  if (iFixedSpace > (int) strlen (cTemp))
  {
    sprintf_s (cDest, iDestLen, "%*s%s", iFixedSpace - (int)(strlen (cTemp)), " ", cTemp);
  }
  else
  {
    strcpy_s (cDest, iDestLen, cTemp);
  }
  //
  return cDest;
}

bool HasFWError(int iFWErr, int iPhase, int iLocation, int iSlot, char* cErrCond, char* cPromptString)
{
  char cErrTxt   [SEPIA2_ERRSTRING_LEN + 1]   = "";
  char cErrPhase [SEPIA2_FW_ERRPHASE_LEN + 1] = "";
  //
  bool bRet = (iFWErr != SEPIA2_ERR_NO_ERROR);
  //
  if (bRet)
  {
    WriteLine ("%s%s", STR_INDENT, cPromptString);
    SEPIA2_LIB_DecodeError  (iFWErr,  cErrTxt);
    SEPIA2_FWR_DecodeErrPhaseName (iPhase, cErrPhase);
    WriteLine ("");
    WriteLine ("%s   error code      : %5d,   i.e. '%s'", STR_INDENT, iFWErr, cErrTxt);
    WriteLine ("%s   error phase     : %5d,   i.e. '%s'", STR_INDENT, iPhase, cErrPhase);
    WriteLine ("%s   error location  : %5d", STR_INDENT,  iLocation);
    WriteLine ("%s   error slot      : %5d", STR_INDENT,  iSlot);
    if (strlen (cErrCond) > 0)
    {
      WriteLine ("%s   error condition : '%s'", STR_INDENT, cErrCond);
    }
    WriteLine ("");
  }
  //
  return bRet;
}

#define NO_DEVIDX     -1
#define NO_IDX_1  -99999
#define NO_IDX_2  -97979

bool Sepia2FunctionSucceeds(int iRet, char* FunctName, int iDev, int iIdx1, int iIdx2)
{
  char cErrTxt   [SEPIA2_ERRSTRING_LEN + 1]   = "";
  //
  bool bRet = (iRet == SEPIA2_ERR_NO_ERROR);
  //
  if (!bRet)
  {
    WriteLine ("");
    SEPIA2_LIB_DecodeError(iRet, cErrTxt);
    if (iIdx1 == NO_IDX_1)
    {
      WriteLine ("%sERROR: SEPIA2_%s (%1d) returns %5d:", STR_INDENT, FunctName, iDev, iRet);
    }
    else if (iIdx2 == NO_IDX_2)
    {
      WriteLine ("%sERROR: SEPIA2_%s (%1d, %03d) returns %5d:", STR_INDENT, FunctName, iDev, iIdx1, iRet);
    }
    else
    {
      WriteLine ("%sERROR: SEPIA2_%s (%1d, %03d, %3d) returns %5d:", STR_INDENT, FunctName, iDev, iIdx1, iIdx2, iRet);
    }
    WriteLine ("%s       i. e. '%s'", STR_INDENT, cErrTxt);
    WriteLine ("");
  }
  return bRet;
}


int SEPIA2_PRI_GetConstants(int iDevIdx, int iSlotId, T_ptrPRI_Constants pPRIConst)
{
  int  Ret = SEPIA2_ERR_NO_ERROR;
  int  Idx;
  char OpMod[SEPIA2_PRI_OPERMODE_LEN + 1];
  char TrSrc[SEPIA2_PRI_TRIGSRC_LEN + 1];
  unsigned char bDummy1;
  unsigned char bDummy2;

  __try
  {
    if (!pPRIConst)
    {
      Ret = SEPIA2_ERR_LIB_ILLEGAL_PARAMETER_ON_FUNCTION_CALL;
      return Ret;
      exit (-2);
    }
    SecureZeroMemory(pPRIConst, sizeof(T_PRI_Constants));
    memset(&(pPRIConst->PrimaUSBIdx), 0xFF, sizeof(T_PRI_Constants) - ((_int64)(&(pPRIConst->PrimaUSBIdx)) - ((_int64)pPRIConst)));
    //
    pPRIConst->PrimaUSBIdx = iDevIdx;
    pPRIConst->PrimaSlotId = iSlotId;
    //
    Ret = SEPIA2_PRI_GetDeviceInfo(iDevIdx, iSlotId, pPRIConst->PrimaModuleID, pPRIConst->PrimaModuleType, pPRIConst->PrimaFWVers, &pPRIConst->PrimaWLCount);
    if (Sepia2FunctionSucceeds(Ret, "PRI_GetDeviceInfo", iDevIdx, iSlotId, NO_IDX_2))
    {
      memmove_s(pPRIConst->PrimaModuleID, SEPIA2_PRI_DEVICE_ID_LEN+1, trim(pPRIConst->PrimaModuleID),   strlen(pPRIConst->PrimaModuleID));
      memmove_s(pPRIConst->PrimaModuleType, SEPIA2_PRI_DEVTYPE_LEN+1, trim(pPRIConst->PrimaModuleType), strlen(pPRIConst->PrimaModuleType));
      memmove_s(pPRIConst->PrimaFWVers,   SEPIA2_PRI_DEVICE_FW_LEN+1, trim(pPRIConst->PrimaFWVers),     strlen(pPRIConst->PrimaFWVers));
      //
      for (Idx = 0; Idx < pPRIConst->PrimaWLCount; Idx++)
      {
        Ret = SEPIA2_PRI_DecodeWavelength(iDevIdx, iSlotId, Idx, &pPRIConst->PrimaWLs[Idx]);
        if (!Sepia2FunctionSucceeds(Ret, "PRI_DecodeWavelength", iDevIdx, iSlotId, Idx))
        {
          break;
        }
      }
      //
      if (Ret == SEPIA2_ERR_NO_ERROR)
      {
        //
        // find Operation Modes
        //
        for (Idx = 0; Idx < 7; Idx++) // 7 is definitely bigger!
        {
          Ret = SEPIA2_PRI_DecodeOperationMode(iDevIdx, iSlotId, Idx, OpMod);
          if (Ret != SEPIA2_ERR_NO_ERROR)
          {
            if (Ret == SEPIA2_ERR_PRI_ILLEGAL_OPERATION_MODE_INDEX)
            {
              pPRIConst->PrimaOpModCount = Idx;
              Ret = SEPIA2_ERR_NO_ERROR;
            }
            else
            {
              Sepia2FunctionSucceeds(Ret, "PRI_DecodeOperationMode", iDevIdx, iSlotId, Idx);
            }
            break;
          }
          else
          {
            _strlwr_s(OpMod, sizeof(OpMod));
            if (strstr(OpMod, "off"))
            {
              pPRIConst->PrimaOpModOff = Idx;
            }
            else if (strstr(OpMod, "narrow"))
            {
              pPRIConst->PrimaOpModNarrow = Idx;
            }
            else if (strstr(OpMod, "broad"))
            {
              pPRIConst->PrimaOpModBroad = Idx;
            }
            else if (strstr(OpMod, "cw"))
            {
              pPRIConst->PrimaOpModCW = Idx;
            }
          }
        }
      }
      if (Ret == SEPIA2_ERR_NO_ERROR)
      {
        //
        // find Trigger Sources
        //
        for (Idx = 0; Idx < 7; Idx++) // 7 is definitely bigger!
        {
          Ret = SEPIA2_PRI_DecodeTriggerSource(iDevIdx, iSlotId, Idx, TrSrc, &bDummy1, &bDummy2);
          if (Ret != SEPIA2_ERR_NO_ERROR)
          {
            if (Ret == SEPIA2_ERR_PRI_ILLEGAL_TRIGGER_SOURCE_INDEX)
            {
              pPRIConst->PrimaTrSrcCount = Idx;
              Ret = SEPIA2_ERR_NO_ERROR;
            }
            else
            {
              Sepia2FunctionSucceeds(Ret, "PRI_DecodeTriggerSource", iDevIdx, iSlotId, Idx);
            }
            break;
          }
          else
          {
            _strlwr_s(TrSrc, sizeof(TrSrc));
            if (strstr(TrSrc, "ext"))
            {
              if (strstr(TrSrc, "nim"))
              {
                pPRIConst->PrimaTrSrcExtNIM = Idx;
              }
              else if (strstr(TrSrc, "ttl"))
              {
                pPRIConst->PrimaTrSrcExtTTL = Idx;
              }
              else if (strstr(TrSrc, "fal"))
              {
                pPRIConst->PrimaTrSrcExtFalling = Idx;
              }
              else if (strstr(TrSrc, "ris"))
              {
                pPRIConst->PrimaTrSrcExtRising = Idx;
              }
            }
            else if (strstr(TrSrc, "int"))
            {
              pPRIConst->PrimaTrSrcInt = Idx;
            }
          }
        }  // for TriggerSources
      }
      //
      if (Ret == SEPIA2_ERR_NO_ERROR)
      {
        pPRIConst->PrimaTemp_min = 15.0; // [°C]
        pPRIConst->PrimaTemp_max = 42.0; // [°C]
      }
    }  // end of if (Sepia2FunctionSucceeds(Ret, "PRI_GetDeviceInfo", ...
    //
    if (Ret == SEPIA2_ERR_NO_ERROR)
    {
      pPRIConst->bInitialized = true;
    }
  }
  __finally
  {
    return Ret;
  }
} // SEPIA2_PRI_GetConstants


int main(int argc, char* argv[])
{
  int             iRetVal                                             = SEPIA2_ERR_NO_ERROR;
  bool            bRet;
  char            c;
  //
  char            cLibVersion    [SEPIA2_VERSIONINFO_LEN + 1]         = "";
  char            cDescriptor    [SEPIA2_USB_STRDECR_LEN + 1]         = "";
  char            cSepiaSerNo    [SEPIA2_SERIALNUMBER_LEN + 1]        = "";
  char            cGivenSerNo    [SEPIA2_SERIALNUMBER_LEN + 1]        = "";
  char            cProductModel  [SEPIA2_PRODUCTMODEL_LEN + 1]        = "";
  char            cGivenProduct  [SEPIA2_PRODUCTMODEL_LEN + 1]        = "";
  char            cFWVersion     [SEPIA2_VERSIONINFO_LEN + 1]         = "";
  char            cErrString     [SEPIA2_ERRSTRING_LEN + 1]           = "";
  char            cFWErrCond     [SEPIA2_FW_ERRCOND_LEN + 1]          = "";
  char            cModulType     [SEPIA2_MODULETYPESTRING_LEN + 1]    = "";
  char            cFreqTrigMode  [SEPIA2_SOM_FREQ_TRIGMODE_LEN + 1]   = "";
  char            cFrequency     [SEPIA2_SLM_FREQ_TRIGMODE_LEN + 1]   = "";
  char            cHeadType      [SEPIA2_SLM_HEADTYPE_LEN + 1]        = "";
  char            cSerialNumber  [SEPIA2_SERIALNUMBER_LEN + 1]        = "";
  char            cSWSModuleType [SEPIA2_SWS_MODULETYPE_LEN + 1]      = "";
  char            cTemp1         [65]                                 = "";
  char            cTemp2         [65]                                 = "";
  char            cBuffer        [262145]                             = "";
  char            cPreamble      [2048]                               = "";
  char            cCallingSW     [2048]                               = "";
  char            cDevType       [SEPIA2_VUV_VIR_DEVTYPE_LEN + 1]     = "";
  char            cTrigMode      [SEPIA2_VUV_VIR_TRIGINFO_LEN + 1]    = "";
  char            cFreqTrigSrc   [SEPIA2_VUV_VIR_TRIGINFO_LEN + 1]    = "";
  char            cDevFWVers     [SEPIA2_PRI_DEVICE_FW_LEN + 1]       = "";
  char            cDevID         [SEPIA2_PRI_DEVICE_ID_LEN + 1]       = "";
  char            cOpMode        [SEPIA2_PRI_OPERMODE_LEN + 1]        = "";
  char            cTrigSrc       [SEPIA2_PRI_TRIGSRC_LEN + 1]         = "";
  //
  long            lBurstChannels [SEPIA2_SOM_BURSTCHANNEL_COUNT]      = {0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L};
  //
  int             iRestartOption                                      = SEPIA2_NO_RESTART;
  int             iDevIdx                                             = NO_DEVIDX;
  int             iGivenDevIdx;
  //
  //
  int             iModuleCount;
  int             iFWErrCode;
  int             iFWErrPhase;
  int             iFWErrLocation;
  int             iFWErrSlot;
  int             iMapIdx;
  int             iSlotId;
  int             iModuleType;
  int             iFreqTrigIdx;
  int             iFreq;
  int             iHead;
  int             iTrigSrcIdx;
  int             iFreqDivIdx;
  int             iTriggerMilliVolt;
  int             iIntensity;
  int             iSWSModuleType;
  int             iWL_Idx;
  int             iOM_Idx;
  int             iTS_Idx;
  int             iMinFreq;
  int             iMaxFreq;
  int             iMinTrgLvl;
  int             iMaxTrgLvl;
  int             iResTrgLvl;
  int             iMinOnTime;
  int             iMaxOnTime;
  int             iOnTime;
  int             iMinOffTimefact;
  int             iMaxOffTimefact;
  int             iOffTimefact;
  int             iDummy;
  //
  T_PRI_Constants PRIConst;
  //
  // byte
  unsigned char   bUSBInstGiven = false;
  unsigned char   bSerialGiven  = false;
  unsigned char   bProductGiven = false;
  unsigned char   bNoWait       = false;
  unsigned char   bStayOpened   = false;
  unsigned char   bLinux        = 0;
  unsigned char   bIsPrimary;
  unsigned char   bIsBackPlane;
  unsigned char   bHasUptimeCounter;
  unsigned char   bLock;
  unsigned char   bSLock;
  unsigned char   bSynchronize;             // for SOM-D
  unsigned char   bPulseMode;
  unsigned char   bDivider;
  unsigned char   bPreSync;
  unsigned char   bMaskSync;
  unsigned char   bOutEnable;
  unsigned char   bSyncEnable;
  unsigned char   bSyncInverse;
  unsigned char   bFineDelayStepCount;      // for SOM-D
  unsigned char   bDelayed;                 // for SOM-D
  unsigned char   bForcedUndelayed;         // for SOM-D
  unsigned char   bFineDelay;               // for SOM-D
  unsigned char   bOutCombi;                // for SOM-D
  unsigned char   bMaskedCombi;             // for SOM-D
  unsigned char   bTrigLevelEnabled;
  unsigned char   bIntensity;
  unsigned char   bTBNdx;                   // for PPL 400
  unsigned char   bHasCW;                   // for VisUV/IR
  unsigned char   bHasFanSwitch;            // for VisUV/IR
  unsigned char   bIsFanRunning;            // for VisUV/IR
  unsigned char   bDivListEnabled;          // for VisUV/IR
  unsigned char   bTrigLvlEnabled;          // for VisUV/IR, Prima/Quader
  unsigned char   bFreqncyEnabled;          // for Prima/Quader
  unsigned char   bGatingEnabled;           // for Prima/Quader
  unsigned char   bGateHiImp;               // for Prima/Quader
  unsigned char   bDummy1;                  // for VisUV/IR, Prima/Quader
  unsigned char   bDummy2;                  // for VisUV/IR, Prima/Quader
  //
  // word
  unsigned short  wIntensity;
  unsigned short  wDivider;
  unsigned short  wPAPml;                   // for PPL 400
  unsigned short  wRRPml;                   // for PPL 400
  unsigned short  wPSPml;                   // for PPL 400
  unsigned short  wRSPml;                   // for PPL 400
  unsigned short  wWSPml;                   // for PPL 400
  //
  float           fGatePeriod;              // for Prima/Quader
  float           fFrequency;
  float           fIntensity;
  //
  long            lBurstSum;
  unsigned long   ulWaveLength; 
  unsigned long   ulBandWidth;
  signed short    sBeamVPos;
  signed short    sBeamHPos;
  unsigned long   ulIntensRaw; 
  unsigned long   ulMainPowerUp;
  unsigned long   ulActivePowerUp;
  unsigned long   ulScaledPowerUp;
  //
  double          f64CoarseDelayStep;       // for SOM-D
  double          f64CoarseDelay;           // for SOM-D
  //
  T_Module_FWVers SWSFWVers = { 0 };
  //
  int i, j;
  //
  /*
  iRetVal = SEPIA2_LIB_IsRunningOnWine(&bLinux);
  if (Sepia2FunctionSucceeds(iRetVal, "LIB_IsRunningOnWine", NO_DEVIDX, NO_IDX_1, NO_IDX_2))
  {
    if (bLinux)
    {
    */
      cNewLine[i = 0] = '\x0A';
      cNewLine[++i]   = '\x00';
      cNewLine[++i]   = '\x00';
    /*
    }
    else
    {
      cNewLine[i = 0] = '\x0D';
      cNewLine[++i]   = '\x0A';
      cNewLine[++i]   = '\x00';
    }
  }
  */
  //
  if (argc <= 1)
  {
    WriteLine (" called without parameters");
  }
  else
  {
    WriteLine (" called with %d parameter%s:", argc - 1, (argc > 2) ? "s" : "");
    //
    #pragma region CMD-Args checks
      //
      for (i=1; i<argc; i++) 
      {
        if (strlen(argv[0]) == 1)
        {
          wchar_t* pwc = (wchar_t*)&(argv[i][0]); 
          //
          if (0 == wcsncmp (pwc, L"-inst=", 6))
          {
            iGivenDevIdx = _wtoi (&(pwc[6]));
            WriteLine ("    -inst=%d", iGivenDevIdx);
            bUSBInstGiven = true;
          }
          else if (0 == wcsncmp (pwc, L"-serial=", 8))
          {
            sprintf_s (cGivenSerNo, SEPIA2_SERIALNUMBER_LEN, "%S", &pwc[8]);
            WriteLine ("    -serial=%S", &pwc[8]);
            bSerialGiven = (strlen (cGivenSerNo) > 0);
          }
          else if (0 == wcsncmp (pwc, L"-product=", 9))
          {
            sprintf_s (cGivenProduct, SEPIA2_PRODUCTMODEL_LEN, "%S", &pwc[9]);
            WriteLine ("    -product=\"%S\"", &pwc[9]);
            bProductGiven = (strlen (cGivenProduct) > 0);
          } 
          else if (0 == wcscmp (pwc, L"-stayopened"))
          {
            bStayOpened = true;
            WriteLine ("    %S", (wchar_t*)argv[i]);
          } 
          else if (0 == wcscmp (pwc, L"-nowait"))
          {
            bNoWait = true;
            WriteLine ("    %S", (wchar_t*)argv[i]);
          } 
          else if (0 == wcscmp (pwc, L"-restart"))
          {
            iRestartOption = SEPIA2_RESTART;
            WriteLine ("    %S", (wchar_t*)argv[i]);
          } 
          else
          {
            WriteLine ("    %S : unknown parameter!", (wchar_t*)argv[i]);
          }
        }
        else
        {
          char* pc = (char*)&(argv[i][0]); 
          //
          if (0 == strncmp (pc, "-inst=", 6))
          {
            iGivenDevIdx = atoi (&(pc[6]));
            WriteLine ("    -inst=%d", iGivenDevIdx);
            bUSBInstGiven = true;
          }
          else if (0 == strncmp (pc, "-serial=", 8))
          {
            strcpy_s (cGivenSerNo, SEPIA2_SERIALNUMBER_LEN, &argv[i][8]);
            WriteLine ("    -serial=%s", &argv[i][8]);
            bSerialGiven = (strlen (cGivenSerNo) > 0);
          }
          else if (0 == strncmp (pc, "-product=", 9))
          {
            strcpy_s (cGivenProduct, SEPIA2_PRODUCTMODEL_LEN, &argv[i][9]);
            WriteLine ("    -product=%s", &argv[i][9]);
            bProductGiven = (strlen (cGivenProduct) > 0);
          }
          else if (0 == strcmp (pc, "-stayopened"))
          {
            bStayOpened = true;
            WriteLine ("    %s", argv[i]);
          }
          else if (0 == strcmp (pc, "-nowait"))
          {
            bNoWait = true;
            WriteLine ("    %s", argv[i]);
          }
          else if (0 == strcmp (pc, "-restart"))
          {
            iRestartOption = SEPIA2_RESTART;
            WriteLine ("    %s", argv[i]);
          } 
          else
          {
            WriteLine ("    %s : unknown parameter!", argv[i]);
          }
        }
      }
      //
    #pragma endregion
    //
  }
  //
  WriteLine (""); WriteLine ("");
  WriteLine ("     PQLaserDrv   Read ALL Values Demo : ");
  WriteLine ("%s", STR_SEPARATORLINE); WriteLine ("");
  //
  // preliminaries: check library version
  //
  iRetVal = SEPIA2_LIB_GetVersion (cLibVersion);
  if (Sepia2FunctionSucceeds(iRetVal, "LIB_GetVersion", NO_DEVIDX, NO_IDX_1, NO_IDX_2))
  {
    WriteLine("     Lib-Version    = %s", cLibVersion);
  }

  if (0 != strncmp (cLibVersion, LIB_VERSION_REFERENCE, LIB_VERSION_REFERENCE_COMPLEN))
  {
    WriteLine ("");
    WriteLine ("     Warning: This demo application was built for version  %s!", LIB_VERSION_REFERENCE);
    WriteLine("              Continuing may cause unpredictable results!"); WriteLine ("");
    Write("     Do you want to continue anyway? (y/n): ");

    c = toupper(getchar());      
    if (c != 'Y')
    {
      exit (-1);
    }
    while ((c = getchar()) != 0x0A ); // reject userinput 'til end of line
    WriteLine ("");
  }
  //
  // establish USB connection to the sepia first matching all given conditions
  //
  for (i = (bUSBInstGiven ? iGivenDevIdx : 0); i < (bUSBInstGiven ? iGivenDevIdx+1 : SEPIA2_MAX_USB_DEVICES); i++)
  {
    SecureZeroMemory (cSepiaSerNo, sizeof(cSepiaSerNo));
    SecureZeroMemory (cProductModel, sizeof(cProductModel));
    //
    iRetVal = SEPIA2_USB_OpenGetSerNumAndClose (i, cProductModel, cSepiaSerNo);
    if ( (iRetVal == SEPIA2_ERR_NO_ERROR) 
      && (  (  (bSerialGiven && bProductGiven)
            && (strcmp (cGivenSerNo,   cSepiaSerNo)   == 0)
            && (strcmp (cGivenProduct, cProductModel) == 0)
            )
        ||  (  (!bSerialGiven != !bProductGiven)
            && (  (strcmp (cGivenSerNo,   cSepiaSerNo)   == 0)
               || (strcmp (cGivenProduct, cProductModel) == 0)
               )
            )
        ||  ( !bSerialGiven && !bProductGiven) 
          )
        )
    {
      iDevIdx = bUSBInstGiven ? ((iGivenDevIdx == i) ? i : NO_DEVIDX) : i;
      break;
    }
  }
  //
  iRetVal = SEPIA2_USB_OpenDevice(iDevIdx, cProductModel, cSepiaSerNo);
  if (Sepia2FunctionSucceeds(iRetVal, "USB_OpenDevice", iDevIdx, NO_IDX_1, NO_IDX_2))
  {
    WriteLine ("     Product Model  = '%s'", cProductModel); WriteLine("");
    WriteLine ("%s", STR_SEPARATORLINE); WriteLine("");
    iRetVal = SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion);
    if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetVersion", iDevIdx, NO_IDX_1, NO_IDX_2))
    {
      WriteLine("     FW-Version     = %s", cFWVersion);
    }
    //
    WriteLine ("     USB Index      = %d", iDevIdx);
    iRetVal = SEPIA2_USB_GetStrDescriptor  (iDevIdx, cDescriptor);
    if (Sepia2FunctionSucceeds(iRetVal, "USB_GetStrDescriptor", iDevIdx, NO_IDX_1, NO_IDX_2))
    {
      WriteLine("     USB Descriptor = %s", cDescriptor);
    }
    WriteLine ("     Serial Number  = '%s'", cSepiaSerNo); WriteLine("");
    WriteLine ("%s", STR_SEPARATORLINE);  WriteLine("");
    //
    // get sepia's module map and initialise datastructures for all library functions
    // there are two different ways to do so:
    //
    // first:  if sepia was not touched since last power on, it doesn't need to be restarted
    //         iRestartOption = SEPIA2_NO_RESTART;
    // second: in case of changes with soft restart
    //         iRestartOption = SEPIA2_RESTART;
    //
    iRetVal = SEPIA2_FWR_GetModuleMap(iDevIdx, iRestartOption, &iModuleCount);
    if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetModuleMap", iDevIdx, NO_IDX_1, NO_IDX_2))
    {
      //
      // this is to inform us about possible error conditions during sepia's last startup
      //
      iRetVal = SEPIA2_FWR_GetLastError(iDevIdx, &iFWErrCode, &iFWErrPhase, &iFWErrLocation, &iFWErrSlot, cFWErrCond);
      if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetLastError", iDevIdx, NO_IDX_1, NO_IDX_2))
      {
        if (!HasFWError(iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond, "Error detected by firmware on last restart:"))
        {
          // just to show, what sepia2_lib knows about your system, try this:
          _sprintf_p(cPreamble, sizeof(cPreamble), "%1$s     Following are system describing common infos,%1$s     the considerate support team of PicoQuant GmbH%1$s     demands for your qualified service request:%1$s%1$s    ============================================================%1$s%1$s", cNewLine);
          _sprintf_p(cCallingSW, sizeof(cCallingSW), "Demo-Program:   ReadAllDataByMSVCPP.exe%1$s", cNewLine);
          //
          iRetVal = SEPIA2_FWR_CreateSupportRequestText (iDevIdx, cPreamble, cCallingSW, 0, sizeof (cBuffer), cBuffer);
          if (Sepia2FunctionSucceeds(iRetVal, "FWR_CreateSupportRequestText", iDevIdx, NO_IDX_1, NO_IDX_2))
          {
            //
            // for console output, we have to change the degree-character.
            // and for uooer mentioned reason, we have to eliminate the <CR>
            // (carriage return) preceeding the linefeed
            for (i = 0; i < (int)strlen(cBuffer); i++)
            {
              if (cBuffer[i] == '°')
              {
                cBuffer[i] = '\xF8';
              }
            }
            Write("%s", cBuffer);
          }
          //
          // scan sepia map module by module
          // and iterate by iMapIdx for this approach.
          //
          WriteLine (""); WriteLine (""); WriteLine ("");
          WriteLine ("%s", STR_SEPARATORLINE);
          WriteLine (""); WriteLine (""); WriteLine ("");
          //
          for (iMapIdx = 0; iMapIdx < iModuleCount; iMapIdx++)
          {
            iRetVal = SEPIA2_FWR_GetModuleInfoByMapIdx (iDevIdx, iMapIdx, &iSlotId, &bIsPrimary, &bIsBackPlane, &bHasUptimeCounter);
            if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetModuleInfoByMapIdx", iDevIdx, iMapIdx, NO_IDX_2))
            {
              //
              if (bIsBackPlane)
              {
                iRetVal = SEPIA2_COM_GetModuleType(iDevIdx, -1, SEPIA2_PRIMARY_MODULE, &iModuleType);
                if (Sepia2FunctionSucceeds(iRetVal, "COM_GetModuleType", iDevIdx, NO_IDX_1, NO_IDX_2))
                {
                  SEPIA2_COM_DecodeModuleType(iModuleType, cModulType);
                  iRetVal = SEPIA2_COM_GetSerialNumber(iDevIdx, -1, SEPIA2_PRIMARY_MODULE, cSerialNumber);
                  if (Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, NO_IDX_1, NO_IDX_2))
                  {
                    WriteLine (" backplane:   module type     '%s'", cModulType);
                    WriteLine ("              serial number   '%s'", cSerialNumber);
                    WriteLine("");
                  }
                }
              }
              else
              {
                //
                // identify sepiaobject (module) in slot
                //
                iRetVal = SEPIA2_COM_GetModuleType(iDevIdx, iSlotId, SEPIA2_PRIMARY_MODULE, &iModuleType);
                if (Sepia2FunctionSucceeds(iRetVal, "COM_GetModuleType", iDevIdx, iSlotId, NO_IDX_2))
                {
                  SEPIA2_COM_DecodeModuleType(iModuleType, cModulType);
                  iRetVal = SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotId, SEPIA2_PRIMARY_MODULE, cSerialNumber);
                  if (Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotId, NO_IDX_2))
                  {
                    WriteLine (" slot %3.3d :   module type     '%s'", iSlotId, cModulType);
                    WriteLine ("              serial number   '%s'", cSerialNumber);
                    WriteLine("");
                  }
                  //
                  // now, continue with modulespecific information
                  //
                  switch (iModuleType)
                  {
                  case SEPIA2OBJECT_SCM:
                    iRetVal = SEPIA2_SCM_GetLaserSoftLock(iDevIdx, iSlotId, &bSLock);
                    if (Sepia2FunctionSucceeds(iRetVal, "SCM_GetLaserSoftLock", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      iRetVal = SEPIA2_SCM_GetLaserLocked(iDevIdx, iSlotId, &bLock);
                      if (Sepia2FunctionSucceeds(iRetVal, "SCM_GetLaserLocked", iDevIdx, iSlotId, NO_IDX_2))
                      {
                        WriteLine ("                              laser lock state   :  %slocked", (!(bLock || bSLock) ? " un" : (bLock != bSLock ? " hard" : " soft")));
                        WriteLine ("");
                      }
                    }
                    //
                    break;


                  case SEPIA2OBJECT_SOM:
                  case SEPIA2OBJECT_SOMD:
                    for (iFreqTrigIdx = 0; ((iRetVal == SEPIA2_ERR_NO_ERROR) && (iFreqTrigIdx < SEPIA2_SOM_FREQ_TRIGMODE_COUNT)); iFreqTrigIdx++)
                    {
                      if (iModuleType == SEPIA2OBJECT_SOM)
                      {
                        iRetVal = SEPIA2_SOM_DecodeFreqTrigMode(iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                        bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2);
                      }
                      else
                      {
                        iRetVal = SEPIA2_SOMD_DecodeFreqTrigMode(iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                        bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2);
                      }
                      if (bRet)
                      {
                        if (iFreqTrigIdx == 0)
                        {
                          Write ("%46s", "freq./trigmodes ");
                        }
                        else
                        {
                          Write ("%46s", "                ");
                        }
                        //
                        Write ("%1d) =     '%s'", iFreqTrigIdx + 1, cFreqTrigMode);
                        //
                        if (iFreqTrigIdx == (SEPIA2_SOM_FREQ_TRIGMODE_COUNT - 1))
                        {
                          WriteLine ("");
                        }
                        else
                        {
                          WriteLine (",");
                        }
                      }
                    }
                    WriteLine ("");
                    if (iRetVal == SEPIA2_ERR_NO_ERROR)
                    {
                      if (iModuleType == SEPIA2OBJECT_SOM)
                      {
                        iRetVal = SEPIA2_SOM_GetFreqTrigMode(iDevIdx, iSlotId, &iFreqTrigIdx);
                        bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_GetFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2);
                      }
                      else
                      {
                        iRetVal = SEPIA2_SOMD_GetFreqTrigMode(iDevIdx, iSlotId, &iFreqTrigIdx, &bSynchronize);
                        bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_GetFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2);
                      }
                      if (bRet)
                      {
                        if (iModuleType == SEPIA2OBJECT_SOM)
                        {
                          iRetVal = SEPIA2_SOM_DecodeFreqTrigMode(iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                          bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2);
                        }
                        else
                        {
                          iRetVal = SEPIA2_SOMD_DecodeFreqTrigMode(iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                          bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2);
                        }
                        if (bRet)
                        {
                          WriteLine ("%47s  =     '%s'", "act. freq./trigm.", cFreqTrigMode);
                          if ((iModuleType == SEPIA2OBJECT_SOMD) && (iFreqTrigIdx < SEPIA2_SOM_INT_OSC_A))
                          {
                            if (bSynchronize)
                            {
                              WriteLine ("%47s        (synchronized,)", " ");
                            }
                          }
                          //
                          if (iModuleType == SEPIA2OBJECT_SOM)
                          {
                            iRetVal = SEPIA2_SOM_GetBurstValues(iDevIdx, iSlotId, &bDivider, &bPreSync, &bMaskSync);
                            if (bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_GetBurstValues", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              wDivider = bDivider;
                            }
                          }
                          else
                          {
                            iRetVal = SEPIA2_SOMD_GetBurstValues(iDevIdx, iSlotId, &wDivider, &bPreSync, &bMaskSync);
                            bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_GetBurstValues", iDevIdx, iSlotId, NO_IDX_2);
                          }
                          if (bRet)
                          {
                            WriteLine ("%48s = %5d", "divider           ", wDivider);
                            WriteLine ("%48s = %5d", "pre sync          ", bPreSync);
                            WriteLine ("%48s = %5d", "masked sync pulses", bMaskSync);
                            //
                            if ((iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_RISING)
                              || (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_FALLING))
                            {
                              if (iModuleType == SEPIA2OBJECT_SOM)
                              {
                                iRetVal = SEPIA2_SOM_GetTriggerLevel(iDevIdx, iSlotId, &iTriggerMilliVolt);
                                bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_GetTriggerLevel", iDevIdx, iSlotId, NO_IDX_2);
                              }
                              else
                              {
                                iRetVal = SEPIA2_SOMD_GetTriggerLevel(iDevIdx, iSlotId, &iTriggerMilliVolt);
                                bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_GetTriggerLevel", iDevIdx, iSlotId, NO_IDX_2);
                              }
                              if (bRet)
                              {
                                WriteLine ("%47s  = %5d mV", "triggerlevel     ", iTriggerMilliVolt);
                              }
                            }
                            else
                            {
                              fFrequency = (float)(atof(cFreqTrigMode)) * 1.0e6f;
                              fFrequency /= wDivider;
                              WriteLine ("%47s  =  %s", "oscillator period", FormatEng(cTemp1, sizeof(cTemp1), 1.0 / fFrequency, 6, "s", 11, 3));
                              WriteLine ("%47s     %s", "i.e.", FormatEng(cTemp1, sizeof(cTemp1), fFrequency, 6, "Hz", 12, 3));
                              WriteLine ("");
                            }
                            if (iRetVal == SEPIA2_ERR_NO_ERROR)
                            {
                              if (iModuleType == SEPIA2OBJECT_SOM)
                              {
                                iRetVal = SEPIA2_SOM_GetOutNSyncEnable(iDevIdx, iSlotId, &bOutEnable, &bSyncEnable, &bSyncInverse);
                                bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_GetOutNSyncEnable", iDevIdx, iSlotId, NO_IDX_2);
                              }
                              else
                              {
                                iRetVal = SEPIA2_SOMD_GetOutNSyncEnable(iDevIdx, iSlotId, &bOutEnable, &bSyncEnable, &bSyncInverse);
                                bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_GetOutNSyncEnable", iDevIdx, iSlotId, NO_IDX_2);
                              }
                              if (iRetVal == SEPIA2_ERR_NO_ERROR)
                              {
                                WriteLine ("%47s  =     %s", "sync mask form   ", (bSyncInverse ? "inverse" : "regular"));
                                WriteLine("");
                                if (iModuleType == SEPIA2OBJECT_SOM)
                                {
                                  iRetVal = SEPIA2_SOM_GetBurstLengthArray(iDevIdx, iSlotId, &lBurstChannels[0], &lBurstChannels[1], &lBurstChannels[2], &lBurstChannels[3], &lBurstChannels[4], &lBurstChannels[5], &lBurstChannels[6], &lBurstChannels[7]);
                                  bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_GetBurstLengthArray", iDevIdx, iSlotId, NO_IDX_2);
                                }
                                else
                                {
                                  iRetVal = SEPIA2_SOMD_GetBurstLengthArray(iDevIdx, iSlotId, &lBurstChannels[0], &lBurstChannels[1], &lBurstChannels[2], &lBurstChannels[3], &lBurstChannels[4], &lBurstChannels[5], &lBurstChannels[6], &lBurstChannels[7]);
                                  bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_GetBurstLengthArray", iDevIdx, iSlotId, NO_IDX_2);
                                }
                                if (bRet)
                                {
                                  WriteLine ("%44s ch. | sync | burst len |  out", "burst data    ");
                                  WriteLine ("%44s-----+------+-----------+------", " ");
                                  //
                                  for (i = 0, lBurstSum = 0; i < SEPIA2_SOM_BURSTCHANNEL_COUNT; i++)
                                  {
                                    WriteLine ("%46s%1d  |    %1d | %9d |    %1d", " ", i + 1, ((bSyncEnable >> i) & 1), lBurstChannels[i], ((bOutEnable >> i) & 1));
                                    lBurstSum += lBurstChannels[i];
                                  }
                                  WriteLine ("%41s--------+------+ +  -------+------", " ");
                                  WriteLine ("%41sHex/Sum | 0x%2.2X | =%8d | 0x%2.2X", " ", bSyncEnable, lBurstSum, bOutEnable);
                                  WriteLine ("");
                                  if ((iFreqTrigIdx != SEPIA2_SOM_TRIGMODE_RISING)
                                    && (iFreqTrigIdx != SEPIA2_SOM_TRIGMODE_FALLING))
                                  {
                                    fFrequency /= lBurstSum;
                                    WriteLine ("%47s  =  %s", "sequencer period", FormatEng(cTemp1, sizeof(cTemp1), 1.0 / fFrequency, 6, "s", 11, 3));
                                    WriteLine ("%47s     %s", "i.e.", FormatEng(cTemp1, sizeof(cTemp1), fFrequency, 6, "Hz", 12, 3));
                                    WriteLine ("");
                                  }
                                  if (iModuleType == SEPIA2OBJECT_SOMD)
                                  {
                                    iRetVal = SEPIA2_SOMD_GetDelayUnits(iDevIdx, iSlotId, &f64CoarseDelayStep, &bFineDelayStepCount);
                                    if (Sepia2FunctionSucceeds(iRetVal, "SOMD_GetDelayUnits", iDevIdx, iSlotId, NO_IDX_2))
                                    {
                                      WriteLine ("%44s     | combiner |", " ");
                                      WriteLine ("%44s     | channels |", " ");
                                      WriteLine ("%44s out | 12345678 | delay", " ");
                                      WriteLine ("%44s-----+----------+------------------", " ");
                                    }
                                    for (j = 0; j < SEPIA2_SOM_BURSTCHANNEL_COUNT; j++)
                                    {
                                      iRetVal = SEPIA2_SOMD_GetSeqOutputInfos(iDevIdx, iSlotId, j, &bDelayed, &bForcedUndelayed, &bOutCombi, &bMaskedCombi, &f64CoarseDelay, &bFineDelay);
                                      if (Sepia2FunctionSucceeds(iRetVal, "SOMD_GetSeqOutputInfos", iDevIdx, iSlotId, NO_IDX_2))
                                      {
                                        if (!bDelayed || bForcedUndelayed)
                                        {
                                          WriteLine ("%46s%1d  | %s |", " ", j + 1, IntToBin(cTemp1, sizeof(cTemp1), bOutCombi, SEPIA2_SOM_BURSTCHANNEL_COUNT, true, bMaskedCombi ? '1' : 'B', '_'));
                                        }
                                        else
                                        {
                                          WriteLine ("%46s%1d  | %s |%s + %2da.u.", " ", j + 1, IntToBin(cTemp1, sizeof(cTemp1), (1 << j), SEPIA2_SOM_BURSTCHANNEL_COUNT, true, 'D', '_'), FormatEng(cTemp2, sizeof(cTemp2), f64CoarseDelay * 1e-9, 4, "s", 9, 1, 0), bFineDelay);
                                        }
                                      }
                                    }
                                    WriteLine ("");
                                    WriteLine ("%46s   = D: delayed burst,   no combi", "combiner legend ");
                                    WriteLine ("%46s     B: combi burst, any non-zero", " ");
                                    WriteLine ("%46s     1: 1st pulse,   any non-zero", " ");
                                    WriteLine ("");
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    break;


                  case SEPIA2OBJECT_SLM:

                    iRetVal = SEPIA2_SLM_GetPulseParameters(iDevIdx, iSlotId, &iFreqTrigIdx, &bPulseMode, &iHead);
                    if (Sepia2FunctionSucceeds(iRetVal, "SLM_GetPulseParameters", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      SEPIA2_SLM_DecodeFreqTrigMode(iFreqTrigIdx, cFrequency);
                      SEPIA2_SLM_DecodeHeadType(iHead, cHeadType);
                      //
                      WriteLine ("%47s  =     '%s'", "freq / trigmode  ", cFrequency);
                      WriteLine ("%47s  =     'pulses %s'", "pulsmode         ", (bPulseMode ? "enabled" : "disabled"));
                      WriteLine ("%47s  =     '%s'", "headtype         ", cHeadType);
                    }
                    iRetVal = SEPIA2_SLM_GetIntensityFineStep(iDevIdx, iSlotId, &wIntensity);
                    if (Sepia2FunctionSucceeds(iRetVal, "SLM_GetIntensityFineStep", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      WriteLine ("%47s  =   %5.1f%%", "intensity        ", 0.1 * wIntensity);
                    }
                    WriteLine ("");
                    break;


                  case SEPIA2OBJECT_SML:
                    iRetVal = SEPIA2_SML_GetParameters(iDevIdx, iSlotId, &bPulseMode, &iHead, &bIntensity);
                    if (Sepia2FunctionSucceeds(iRetVal, "SML_GetParameters", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      SEPIA2_SML_DecodeHeadType(iHead, cHeadType);
                      //
                      WriteLine ("%47s  =     pulses %s", "pulsmode         ", (bPulseMode ? "enabled" : "disabled"));
                      WriteLine ("%47s  =     %s", "headtype         ", cHeadType);
                      WriteLine ("%47s  =   %3d%%", "intensity        ", bIntensity);
                      WriteLine ("");
                    }
                    break;


                  case SEPIA2OBJECT_SPM:
                    iRetVal = SEPIA2_SPM_GetFWVersion(iDevIdx, iSlotId, &SWSFWVers.ul);
                    if (Sepia2FunctionSucceeds(iRetVal, "SPM_GetFWVersion", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      WriteLine ("%47s  =     %hhd.%hhd.%hd", "firmware version ", SWSFWVers.v.VersMaj, SWSFWVers.v.VersMin, SWSFWVers.v.BuildNr);
                    }
                    break;


                  case SEPIA2OBJECT_SWS:
                    iRetVal = SEPIA2_SWS_GetFWVersion(iDevIdx, iSlotId, &SWSFWVers.ul);
                    if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetFWVersion", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      WriteLine ("%47s  =     %hhd.%hhd.%hd", "firmware version ", SWSFWVers.v.VersMaj, SWSFWVers.v.VersMin, SWSFWVers.v.BuildNr);
                    }
                    iRetVal = SEPIA2_SWS_GetModuleType(iDevIdx, iSlotId, &iSWSModuleType);
                    if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetModuleType", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      SEPIA2_SWS_DecodeModuleType(iSWSModuleType, cSWSModuleType);
                      WriteLine ("%47s  =     %s", "SWS module type ", cSWSModuleType);
                    }
                    iRetVal = SEPIA2_SWS_GetParameters(iDevIdx, iSlotId, &ulWaveLength, &ulBandWidth);
                    if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetParameters", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      //
                      WriteLine ("%47s  =  %8.3f nm", "wavelength       ", 0.001 * ulWaveLength);
                      WriteLine ("%47s  =  %8.3f nm", "bandwidth        ", 0.001 * ulBandWidth);
                      WriteLine ("");
                    }
                    iRetVal = SEPIA2_SWS_GetIntensity(iDevIdx, iSlotId, &ulIntensRaw, &fIntensity);
                    if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetIntensity", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      WriteLine ("%47s  = 0x%4.4X a.u. i.e. ~ %.1fnA", "power diode      ", ulIntensRaw, fIntensity);
                      WriteLine ("");
                    }
                    iRetVal = SEPIA2_SWS_GetBeamPos(iDevIdx, iSlotId, &sBeamVPos, &sBeamHPos);
                    if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetBeamPos", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      WriteLine ("%47s  =   %3d steps", "horiz. beamshift ", sBeamHPos);
                      WriteLine ("%47s  =   %3d steps", "vert.  beamshift ", sBeamVPos);
                      WriteLine ("");
                    }
                    break;


                  case SEPIA2OBJECT_SSM:
                    iRetVal = SEPIA2_SSM_GetTriggerData(iDevIdx, iSlotId, &iFreqTrigIdx, &iTriggerMilliVolt);
                    if (Sepia2FunctionSucceeds(iRetVal, "SSM_GetTriggerData", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      //
                      iRetVal = SEPIA2_SSM_DecodeFreqTrigMode(iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode, &iFreq, &bTrigLevelEnabled);
                      if (Sepia2FunctionSucceeds(iRetVal, "SSM_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2))
                      {
                        WriteLine ("%47s  =     '%s'", "act. freq./trigm.", cFreqTrigMode);
                        if (bTrigLevelEnabled != 0)
                        {
                          WriteLine ("%47s  = %5d mV", "triggerlevel     ", iTriggerMilliVolt);
                        }
                      }
                    }
                    break;


                  case SEPIA2OBJECT_SWM:
                    iRetVal = SEPIA2_SWM_GetCurveParams(iDevIdx, iSlotId, 1, &bTBNdx, &wPAPml, &wRRPml, &wPSPml, &wRSPml, &wWSPml);
                    if (Sepia2FunctionSucceeds(iRetVal, "SWM_GetCurveParams 1", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      WriteLine ("%47s", "Curve 1:         ");
                      WriteLine ("%47s  =   %3hhd", "TBNdx            ", bTBNdx);
                      WriteLine ("%47s  =  %6.1f%%", "PAPml            ", 0.1 * wPAPml);
                      WriteLine ("%47s  =  %6.1f%%", "RRPml            ", 0.1 * wRRPml);
                      WriteLine ("%47s  =  %6.1f%%", "PSPml            ", 0.1 * wPSPml);
                      WriteLine ("%47s  =  %6.1f%%", "RSPml            ", 0.1 * wRSPml);
                      WriteLine ("%47s  =  %6.1f%%", "WSPml            ", 0.1 * wWSPml);
                    }
                    iRetVal = SEPIA2_SWM_GetCurveParams(iDevIdx, iSlotId, 2, &bTBNdx, &wPAPml, &wRRPml, &wPSPml, &wRSPml, &wWSPml);
                    if (Sepia2FunctionSucceeds(iRetVal, "SWM_GetCurveParams 2", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      WriteLine ("%47s", "Curve 2:         ");
                      WriteLine ("%47s  =   %3hhd", "TBNdx            ", bTBNdx);
                      WriteLine ("%47s  =  %6.1f%%", "PAPml            ", 0.1 * wPAPml);
                      WriteLine ("%47s  =  %6.1f%%", "RRPml            ", 0.1 * wRRPml);
                      WriteLine ("%47s  =  %6.1f%%", "PSPml            ", 0.1 * wPSPml);
                      WriteLine ("%47s  =  %6.1f%%", "RSPml            ", 0.1 * wRSPml);
                      WriteLine ("%47s  =  %6.1f%%", "WSPml            ", 0.1 * wWSPml);
                    }
                    break;


                  case SEPIA2OBJECT_VUV:
                  case SEPIA2OBJECT_VIR:
                    iRetVal = SEPIA2_VUV_VIR_GetDeviceType(iDevIdx, iSlotId, cDevType, &bHasCW, &bHasFanSwitch);
                    if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetDeviceType", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      iRetVal = SEPIA2_VUV_VIR_GetTriggerData(iDevIdx, iSlotId, &iTrigSrcIdx, &iFreqDivIdx, &iTriggerMilliVolt);
                      if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetTriggerData", iDevIdx, iSlotId, NO_IDX_2))
                      {
                        iRetVal = SEPIA2_VUV_VIR_DecodeFreqTrigMode(iDevIdx, iSlotId, iTrigSrcIdx, -1, cFreqTrigMode, &iDummy, &bDummy1, &bDummy2);
                        if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2))
                        {
                          iRetVal = SEPIA2_VUV_VIR_DecodeFreqTrigMode(iDevIdx, iSlotId, iTrigSrcIdx, iFreqDivIdx, cFreqTrigSrc, &iFreq, &bDivListEnabled, &bTrigLvlEnabled);
                          if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2))
                          {
                            WriteLine ("%47s  =   '%s'", "devicetype       ", cDevType);
                            WriteLine ("%47s  :   %s = %s", "options          ", "CW        ", (bHasCW ? "True" : "False"));
                            WriteLine ("%47s      %s = %s", "                 ", "fan-switch", (bHasFanSwitch ? "True" : "False"));
                            WriteLine ("%47s  =   %s", "trigger source   ", cFreqTrigMode);
                            if ((bDivListEnabled) && (iFreq > 0))
                            {
                              WriteLine ("%47s  =   2^%d = %d", "divider          ", iFreqDivIdx, (int)(pow(2.0, 1.0 * iFreqDivIdx)));
                              WriteLine ("%47s  =   %s", "frequency        ", FormatEng(cTemp1, sizeof(cTemp1), 1.0 * iFreq, 4, "Hz", 9));
                            }
                            else if (bTrigLvlEnabled)
                            {
                              WriteLine ("%47s  =   %.3f V", "trigger level    ", 0.001 * iTriggerMilliVolt);
                            }
                          }
                        }
                      }
                      iRetVal = SEPIA2_VUV_VIR_GetIntensity(iDevIdx, iSlotId, &iIntensity);
                      if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetIntensity", iDevIdx, iSlotId, NO_IDX_2))
                      {
                        WriteLine ("%47s  =   %3.1f %%", "intensity        ", 0.1 * iIntensity);
                      }
                      if (bHasFanSwitch)
                      {
                        iRetVal = SEPIA2_VUV_VIR_GetFan(iDevIdx, iSlotId, &bIsFanRunning);
                        if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetFan", iDevIdx, iSlotId, NO_IDX_2))
                        {
                          WriteLine ("%47s  =   %s", "fan running      ", (bIsFanRunning ? "True" : "False"));
                        }
                      }
                    }
                    break;


                  case SEPIA2OBJECT_PRI:
                    iRetVal = SEPIA2_PRI_GetConstants(iDevIdx, iSlotId, &PRIConst);
                    if (Sepia2FunctionSucceeds(iRetVal, "SEPIA2_PRI_GetConstants", iDevIdx, iSlotId, NO_IDX_2))
                    {
                      WriteLine ("%47s  =   '%s'", "devicetype       ", PRIConst.PrimaModuleType);
                      WriteLine ("%47s  =   %s", "firmware version ",   PRIConst.PrimaFWVers);
                      WriteLine ("");
                      WriteLine ("%47s  =   %1d", "wavelengths count",  PRIConst.PrimaWLCount);
                      for (i = 0; i < PRIConst.PrimaWLCount; i++)
                      {
                        sprintf_s(cTemp1, sizeof(cTemp1), "wavelength [%1d] ", i);
                        WriteLine ("%47s  =  %4dnm", cTemp1, PRIConst.PrimaWLs[i])
                      }
                      iRetVal = SEPIA2_PRI_GetWavelengthIdx (iDevIdx, iSlotId, &iWL_Idx);
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetWavelengthIdx", iDevIdx, iSlotId, iWL_Idx))
                      {
                        WriteLine("%47s  =  %4dnm;%*sWL-Idx=%d", "cur. wavelength  ", PRIConst.PrimaWLs[iWL_Idx], 12, " ", iWL_Idx);
                        WriteLine("");
                      }
                      //
                      //
                      WriteLine("%47s  =   %1d", "operation modes  ", PRIConst.PrimaOpModCount);
                      for (i=0; i < PRIConst.PrimaOpModCount; i++)
                      {
                        iRetVal = SEPIA2_PRI_DecodeOperationMode (iDevIdx, iSlotId, i, cOpMode);
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeOperationMode", iDevIdx, iSlotId, i))
                        {
                          sprintf_s(cTemp1, sizeof(cTemp1), "oper. mode [%1d] ", i);
                          WriteLine("%47s  =   '%s'", cTemp1, trim(cOpMode));
                        }
                      }
                      iRetVal = SEPIA2_PRI_GetOperationMode (iDevIdx, iSlotId, &iOM_Idx);
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetOperationMode", iDevIdx, iSlotId, iOM_Idx))
                      {
                        iRetVal = SEPIA2_PRI_DecodeOperationMode (iDevIdx, iSlotId, iOM_Idx, cOpMode);
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeOperationMode", iDevIdx, iSlotId, iOM_Idx))
                        {
                          trim(cOpMode);
                          WriteLine("%47s  =   '%s';%*sOM-Idx=%d", "cur. oper. mode  ", cOpMode, (15 - strlen(cOpMode)), " ", iOM_Idx);
                        }
                      }
                      WriteLine("");
                      //
                      // now we calculate the amount of trigger sources for this indiviual PRI module
                      //
                      WriteLine("%47s  =   %1d", "trigger sources  ", PRIConst.PrimaTrSrcCount);
                      for (i = 0; i < PRIConst.PrimaTrSrcCount; i++)
                      {
                        iRetVal = SEPIA2_PRI_DecodeTriggerSource(iDevIdx, iSlotId, i, cTrigSrc, &bDummy1, &bDummy2);
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeTriggerSource", iDevIdx, iSlotId, i))
                        {
                          sprintf_s(cTemp1, sizeof(cTemp1), "trig. src. [%1d] ", i);
                          WriteLine("%47s  =   '%s'", cTemp1, trim(cTrigSrc));
                        }
                      }
                      iRetVal = SEPIA2_PRI_GetTriggerSource (iDevIdx, iSlotId, &iTS_Idx);
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetTriggerSource", iDevIdx, iSlotId, iTS_Idx))
                      {
                        iRetVal = SEPIA2_PRI_DecodeTriggerSource (iDevIdx, iSlotId, iTS_Idx, cTrigSrc, &bFreqncyEnabled, &bTrigLvlEnabled);
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeTriggerSource", iDevIdx, iSlotId, iTS_Idx))
                        {
                          trim(cTrigSrc);
                          WriteLine("%47s  =   '%s';%*sTS-Idx=%d", "cur. trig. source", cTrigSrc, (15 - strlen(cTrigSrc)), " ", iTS_Idx);
                        }
                      }
                      WriteLine("");
                      sprintf_s(cTemp1, sizeof(cTemp1), "for TS-Idx = %1d   ", iTS_Idx);
                      WriteLine("%47s  :   frequency is %sactive:", cTemp1, (!bFreqncyEnabled ? "in" : ""));
                      iRetVal = SEPIA2_PRI_GetFrequencyLimits (iDevIdx, iSlotId, &iMinFreq, &iMaxFreq);
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetFrequencyLimits", iDevIdx, iSlotId, NO_IDX_2))
                      {
                        FormatEng(cTemp1, sizeof(cTemp1), iMinFreq, 3, "Hz", -1, 0, false);
                        FormatEng(cTemp2, sizeof(cTemp2), iMaxFreq, 3, "Hz", -1, 0, false);
                        WriteLine("%47s  =   %s <= f <= %s", "frequency range", cTemp1, cTemp2);
                        iRetVal = SEPIA2_PRI_GetFrequency(iDevIdx, iSlotId, &iFreq);
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetFrequency", iDevIdx, iSlotId, NO_IDX_2))
                        {
                          FormatEng(cTemp1, sizeof(cTemp1), iFreq, 3, "Hz", -1, 0, false);
                          WriteLine("%47s  =   %s", "cur. frequency ", cTemp1);
                        }
                      }
                      WriteLine("");
                      sprintf_s(cTemp1, sizeof(cTemp1), "for TS-Idx = %1d   ", iTS_Idx);
                      WriteLine("%47s  :   trigger level is %sactive:", cTemp1, (!bTrigLvlEnabled ? "in" : ""));
                      iRetVal = SEPIA2_PRI_GetTriggerLevelLimits (iDevIdx, iSlotId, &iMinTrgLvl, &iMaxTrgLvl, &iResTrgLvl);
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetTriggerLevelLimits", iDevIdx, iSlotId, NO_IDX_2))
                      {
                        iRetVal = SEPIA2_PRI_GetTriggerLevel (iDevIdx, iSlotId, &iTriggerMilliVolt);
                        WriteLine("%47s  =  %6.3fV <= tl <= %5.3fV", "trig.lvl. range", 0.001*iMinTrgLvl, 0.001*iMaxTrgLvl);
                        //
                        WriteLine("%47s  =  %6.3fV", "cur. trig.lvl. ", 0.001*iTriggerMilliVolt);
                      }
                      WriteLine("");
                      iRetVal = SEPIA2_PRI_GetIntensity (iDevIdx, iSlotId, iWL_Idx, &wIntensity);
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetIntensity", iDevIdx, iSlotId, iWL_Idx))
                      {
                        FormatEng(cTemp1, sizeof(cTemp1), 0.1 * wIntensity, 3, "%", -1, 1, false);
                        WriteLine("%47s  =   %s; %*sWL-Idx=%d", "intensity        ", cTemp1, 16 - strlen(cTemp1), " ", iWL_Idx);
                      }
                      WriteLine("");
                      iRetVal = SEPIA2_PRI_GetGatingEnabled (iDevIdx, iSlotId, &bGatingEnabled);
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGatingEnabled", iDevIdx, iSlotId, NO_IDX_2))
                      {
                        WriteLine("%47s  :   %sabled", "gating           ", (bGatingEnabled ? "en" : "dis"));
                        iRetVal = SEPIA2_PRI_GetGateHighImpedance (iDevIdx, iSlotId, &bGateHiImp);
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGateHighImpedance", iDevIdx, iSlotId, NO_IDX_2))
                        { 
                          WriteLine("%47s  =   %s", "gate impedance ", (bGateHiImp ? "high (>= 1 kOhm)" : "low (50 Ohm)"));
                        }
                        //
                        iRetVal = SEPIA2_PRI_GetGatingLimits (iDevIdx, iSlotId, &iMinOnTime, &iMaxOnTime, &iMinOffTimefact, &iMaxOffTimefact);
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGatingLimits", iDevIdx, iSlotId, NO_IDX_2))
                        {
                          iRetVal = SEPIA2_PRI_GetGatingData (iDevIdx, iSlotId, &iOnTime, &iOffTimefact);
                          if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGatingData", iDevIdx, iSlotId, NO_IDX_2))
                          {
                            FormatEng(cTemp1, sizeof(cTemp1), 1.0e-9*iMinOnTime, 4, "s", -1, 1, false);
                            FormatEng(cTemp2, sizeof(cTemp2), 1.0e-9*iMaxOnTime, 4, "s", -1, 1, false);
                            WriteLine("%48s =   %s <= t <= %s", "on-time range   ", cTemp1, cTemp2);
                            //
                            FormatEng(cTemp1, sizeof(cTemp1), 1.0e-9*iOnTime, 4, "s", -1, 1, false);
                            WriteLine("%48s =   %s", "cur. on-time    ", cTemp1);
                            //
                            WriteLine("%48s =   %d <= tf <= %d", "off-t.fact range", iMinOffTimefact, iMaxOffTimefact);
                            //
                            FormatEng (cTemp1, sizeof(cTemp1), 1.0e-9*iOnTime*iOffTimefact, 4, "s", -1, 3, false);
                            WriteLine("%48s =   %d * on-time = %s", "cur. off-time   ", iOffTimefact, cTemp1);
                            fGatePeriod = 1.0e-9F * iOnTime * (1 + iOffTimefact);
                            FormatEng (cTemp1, sizeof(cTemp1), fGatePeriod, 4, "s", -1, 3, false);
                            WriteLine("%48s =   %s", "gate period     ", cTemp1);
                            FormatEng (cTemp1, sizeof(cTemp1), 1.0 / fGatePeriod, 4, "Hz", -1, -1, false);
                            WriteLine("%48s =   %s", "gate frequency  ", cTemp1);
                          }
                        }
                      }
                    }
                    break;
                    //
                  default: break;
                  } // switch (iModuleType)
                }
              }
            }
            //
            //
            if (iRetVal == SEPIA2_ERR_NO_ERROR)
            {
              //
              if (!bIsPrimary)
              {
                iRetVal = SEPIA2_COM_GetModuleType(iDevIdx, iSlotId, SEPIA2_SECONDARY_MODULE, &iModuleType);
                if (Sepia2FunctionSucceeds(iRetVal, "COM_GetModuleType", iDevIdx, iSlotId, NO_IDX_2))
                {
                  SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                  iRetVal = SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotId, SEPIA2_SECONDARY_MODULE, cSerialNumber);
                  if (Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotId, NO_IDX_2))
                  {
                    WriteLine ("");
                    WriteLine ("              secondary mod.  '%s'", cModulType);
                    WriteLine ("              serial number   '%s'", cSerialNumber);
                    WriteLine ("");
                  }
                }
              }
              //
              if (bHasUptimeCounter)
              {
                iRetVal = SEPIA2_FWR_GetUptimeInfoByMapIdx (iDevIdx, iMapIdx, &ulMainPowerUp, &ulActivePowerUp, &ulScaledPowerUp);
                if (Sepia2FunctionSucceeds(iRetVal, "", iDevIdx, iSlotId, NO_IDX_2))
                {
                  PrintUptimers(ulMainPowerUp, ulActivePowerUp, ulScaledPowerUp);
                }
              }
            }
          }
        }
      }
    } // get module map
    else
    {
      iRetVal = SEPIA2_FWR_GetLastError(iDevIdx, &iFWErrCode, &iFWErrPhase, &iFWErrLocation, &iFWErrSlot, cFWErrCond);
      if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetLastError", iDevIdx, NO_IDX_1, NO_IDX_2))
      {
        HasFWError(iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond, "Firmware error detected:");
      }
    }
    //
    SEPIA2_FWR_FreeModuleMap (iDevIdx);
    if (bStayOpened)
    {
      WriteLine("");
      Write ("press RETURN to close Sepia... ");
      getchar ();
    }
    SEPIA2_USB_CloseDevice   (iDevIdx);
  }
  //
  WriteLine  ("");
  //
  if (!bNoWait)
  {
    WriteLine("");
    Write ("press RETURN... ");
    getchar ();
  }
  return iRetVal;
}
