//-----------------------------------------------------------------------------
//
//      SetSomeDataByMSVCPP
//
//-----------------------------------------------------------------------------
//
//  Illustrates the functions exported by SEPIA2_Lib
//
//  Presumes to find a SOM 828, SOM-D 828, a SLM 828, a VisUV/IR and/or a Prima
//
//  if there doesn't exist a file named "OrigData.txt"
//    creates the file to save the original values
//    then sets new values for the modules found (only first of a kind)
//  else
//    sets back to original values for the modules from file and
//    deletes it afterwards.
//
//  Consider, this code is for demonstration purposes only.
//  Don't use it in productive environments!
//
//-----------------------------------------------------------------------------
//  HISTORY:
//
//  apo  06.02.06   created
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
//  apo  29.01.21   introduced VIR, VUV module functions (for VisUV/IR) (V1.2.xx.641)
//
//  apo  06.09.22   introduced PRI functions (for Prima / Quader) (V1.2.xx.753)
//
//-----------------------------------------------------------------------------
//

#pragma message ("**************************************************************")
#pragma message ("***                                                        ***")
#pragma message ("*** " __FILE__ " ***")                     
#pragma message ("***                                                        ***")
#pragma message ("**************************************************************")


#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
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
  #include "MiscFunctions.h"
}

// this is to suppress warning C4996: <function_name>: This function or variable may be unsafe.
#pragma warning( disable : 4996 )

  #define IS_A_VUV            0
  #define IS_A_VIR            1


  char            cNewLine [4]         = "\x0A";
  char            STR_INDENT[]         = "     ";
  char            STR_SEPARATORLINE [] = "    ============================================================";
  char            FNAME []             = "OrigData.txt";
  char            cTemp [1025];
  char            cTemp1[10];
  char            c;
  //
  char            cOperMode [SEPIA2_PRI_OPERMODE_LEN + 1]  = "";
  //
  struct _stat    buf;
  FILE*           f;
  //
  int             iRetVal              = SEPIA2_ERR_NO_ERROR;
  int             iDevIdx              =  -1;

  int             iFreqTrigSrc[2]      = { -1, -1 };
  int             iFreqDivIdx[2]       = { -1, -1 };
  int             iTrigLevel[2]        = {  0,  0 };
  int             iIntensity[2]        = {  0,  0 };
  unsigned char   bFanRunning[2]       = {  0,  0 };
  //
  int             iOpModeIdx;
  int             iTrgSrcIdx;
  int             iWL_Idx;
  int             iWL;

  unsigned short  wIntensity;


#define F_WriteLine(F,FMT, ...) {char fmt[128]; strcpy_s(fmt, 128, (FMT)); strcat_s(fmt, 128, cNewLine); fprintf((F), fmt, __VA_ARGS__);}
#define F_Write(F,FMT, ...)     {fprintf((F), (FMT), __VA_ARGS__);}

#define WriteLine(FMT, ...)     {char fmt[128]; strcpy_s(fmt, 128, (FMT)); strcat_s(fmt, 128, cNewLine); printf(fmt, __VA_ARGS__);}
#define Write(FMT, ...)         {printf((FMT), __VA_ARGS__);}


  bool HasFWError (int iFWErr, int iPhase, int iLocation, int iSlot, char* cErrCond, char* cPromptString)
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


  void GetWriteAndModify_VUV_VIR_Data (char* cVUV_VIRType, int iVUV_VIR_Slot, int IsVIR)
  {
    int TrgLvlUpper;
    int TrgLvlLower;
    int TrgLvlRes;
    //
    iRetVal = SEPIA2_VUV_VIR_GetTriggerData(iDevIdx, iVUV_VIR_Slot, &iFreqTrigSrc[IsVIR], &iFreqDivIdx[IsVIR], &iTrigLevel[IsVIR]);
    if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetTriggerData", iDevIdx, iVUV_VIR_Slot, NO_IDX_2))
    {
      F_WriteLine (f, "%-4s TrigSrcIdx    =      %3d", cVUV_VIRType, iFreqTrigSrc[IsVIR]);
      F_WriteLine (f, "%-4s FreqDivIdx    =      %3d", cVUV_VIRType, iFreqDivIdx[IsVIR]);
      F_WriteLine (f, "%-4s TrigLevel     =    %5d",   cVUV_VIRType, iTrigLevel[IsVIR]);
      //
      iRetVal = SEPIA2_VUV_VIR_GetIntensity(iDevIdx, iVUV_VIR_Slot, &iIntensity[IsVIR]);
      if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetIntensity", iDevIdx, iVUV_VIR_Slot, NO_IDX_2))
      {
        F_WriteLine (f, "%-4s Intensity     =      %5.1f %%", cVUV_VIRType, 0.1 * iIntensity[IsVIR]);
        //
        iRetVal = SEPIA2_VUV_VIR_GetFan(iDevIdx, iVUV_VIR_Slot, &bFanRunning[IsVIR]);
        if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetFan", iDevIdx, iVUV_VIR_Slot, NO_IDX_2))
        {
          F_WriteLine(f, "%-4s FanRunning    =        %s", cVUV_VIRType, BoolToStr(bFanRunning[IsVIR]));
        }
      }
    }
    //
    //
    iRetVal = SEPIA2_VUV_VIR_GetTrigLevelRange(iDevIdx, iVUV_VIR_Slot, &TrgLvlUpper, &TrgLvlLower, &TrgLvlRes);
    if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetTrigLevelRange", iDevIdx, iVUV_VIR_Slot, NO_IDX_2))
    {
      iFreqTrigSrc[IsVIR] = (iFreqTrigSrc[IsVIR] == 1 ? 0 : 1);
      iFreqDivIdx[IsVIR] = (iFreqDivIdx[IsVIR] == 2 ? 1 : 2);
      iTrigLevel[IsVIR] = EnsureRange(50 - iTrigLevel[IsVIR], TrgLvlLower, TrgLvlUpper);
      iIntensity[IsVIR] = 1000 - iIntensity[IsVIR];
      bFanRunning[IsVIR] = (bFanRunning[IsVIR] == 0 ? 1 : 0);
    }
    else {
      iFreqTrigSrc[IsVIR] = 1;
      iFreqDivIdx[IsVIR] = 2;
      iTrigLevel[IsVIR] = -350;
      iIntensity[IsVIR] = 440;
      bFanRunning[IsVIR] = 1;
    }
  }

  void Read_VUV_VIR_Data(int IsVIR)
  {
    float fIntensity;
    //
    fscanf(f, "%4s TrigSrcIdx    =      %d\n", cTemp, &iFreqTrigSrc[IsVIR]);
    fscanf(f, "%4s FreqDivIdx    =      %d\n", cTemp, &iFreqDivIdx[IsVIR]);
    fscanf(f, "%4s TrigLevel     =    %d\n", cTemp, &iTrigLevel[IsVIR]);
    fscanf(f, "%4s Intensity     =      %f %%\n", cTemp, &fIntensity);
    iIntensity[IsVIR] = (signbit(fIntensity) ? -1 : 1) * (int)(10 * fabs(fIntensity) + 0.5);  // round (10*fIntensity)
    fscanf(f, "%4s FanRunning    =        %s\n", cTemp, cTemp1);
    bFanRunning[IsVIR] = StrToBool(cTemp1);
  }

  void Set_VUV_VIR_Data(char* cVUV_VIRType, int iVUV_VIR_Slot, int IsVIR)
  {
    iRetVal = SEPIA2_VUV_VIR_SetTriggerData(iDevIdx, iVUV_VIR_Slot, iFreqTrigSrc[IsVIR], iFreqDivIdx[IsVIR], iTrigLevel[IsVIR]);
    if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_SetTriggerData", iDevIdx, iVUV_VIR_Slot, NO_IDX_2))
    {
      iRetVal = SEPIA2_VUV_VIR_SetIntensity(iDevIdx, iVUV_VIR_Slot, iIntensity[IsVIR]);
      if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_SetIntensity", iDevIdx, iVUV_VIR_Slot, NO_IDX_2))
      {
        iRetVal = SEPIA2_VUV_VIR_SetFan(iDevIdx, iVUV_VIR_Slot, bFanRunning[IsVIR]);
        Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_SetFan", iDevIdx, iVUV_VIR_Slot, NO_IDX_2);
      }
    }
    //
    WriteLine("%s%-4s TrigSrcIdx    =      %3d", STR_INDENT, cVUV_VIRType, iFreqTrigSrc[IsVIR]);
    WriteLine("%s%-4s FreqDivIdx    =      %3d", STR_INDENT, cVUV_VIRType, iFreqDivIdx[IsVIR]);
    WriteLine("%s%-4s TrigLevel     =    %5d mV", STR_INDENT, cVUV_VIRType, iTrigLevel[IsVIR]);
    WriteLine("%s%-4s Intensity     =      %5.1f %%", STR_INDENT, cVUV_VIRType, 0.1 * iIntensity[IsVIR]);
    WriteLine("%s%-4s FanRunning    =        %s", STR_INDENT, cVUV_VIRType, BoolToStr(bFanRunning[IsVIR]));
    WriteLine("");
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
  char            cLibVersion    [SEPIA2_VERSIONINFO_LEN + 1]        = "";
  char            cSepiaSerNo    [SEPIA2_SERIALNUMBER_LEN + 1]       = "";
  char            cGivenSerNo    [SEPIA2_SERIALNUMBER_LEN + 1]       = "";
  char            cProductModel  [SEPIA2_PRODUCTMODEL_LEN + 1]       = "";
  char            cGivenProduct  [SEPIA2_PRODUCTMODEL_LEN + 1]       = "";
  char            cFWVersion     [SEPIA2_VERSIONINFO_LEN + 1]        = "";
  char            cDescriptor    [SEPIA2_USB_STRDECR_LEN + 1]        = "";
  char            cFWErrCond     [SEPIA2_FW_ERRCOND_LEN + 1]         = "";
  char            cErrString     [SEPIA2_ERRSTRING_LEN + 1]          = "";
  char            cFWErrPhase    [SEPIA2_FW_ERRPHASE_LEN + 1]        = "";
  char            cSOMSerNr      [SEPIA2_SERIALNUMBER_LEN + 1]       = "";
  char            cSLMSerNr      [SEPIA2_SERIALNUMBER_LEN + 1]       = "";
  char            cVUVSerNr      [SEPIA2_SERIALNUMBER_LEN + 1]       = "";
  char            cVIRSerNr      [SEPIA2_SERIALNUMBER_LEN + 1]       = "";
  char            cPRISerNr      [SEPIA2_SERIALNUMBER_LEN + 1]       = "";
  char            cSOMFSerNr     [SEPIA2_SERIALNUMBER_LEN + 1]       = "";
  char            cSLMFSerNr     [SEPIA2_SERIALNUMBER_LEN + 1]       = "";
  char            cVUVFSerNr     [SEPIA2_SERIALNUMBER_LEN + 1]       = "";
  char            cVIRFSerNr     [SEPIA2_SERIALNUMBER_LEN + 1]       = "";
  char            cPRIFSerNr     [SEPIA2_SERIALNUMBER_LEN + 1]       = "";
  char            cFreqTrigMode  [SEPIA2_SOM_FREQ_TRIGMODE_LEN + 1]  = "";
  char            cSOMType       [6]                                 = "";
  char            cSLMType       [6]                                 = "";
  char            cVUVType       [6]                                 = "";
  char            cVIRType       [6]                                 = "";
  char            cPRIType       [6]                                 = "";
  //
  long            lBurstChannels [SEPIA2_SOM_BURSTCHANNEL_COUNT] = {0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L};
  long            lTemp;
  //
  int             iGivenDevIdx;
  int             iSlotNr;
  int             iSOM_Slot           =  -1;
  int             iSLM_Slot           =  -1;
  int             iVUV_Slot           =  -1;
  int             iVIR_Slot           =  -1;
  int             iPRI_Slot           =  -1;
  int             iSOM_FSlot          =  -1;
  int             iSLM_FSlot          =  -1;
  int             iVUV_FSlot          =  -1;
  int             iVIR_FSlot          =  -1;
  int             iPRI_FSlot          =  -1;
  //
  //
  int             iModuleCount;
  int             iModuleType;
  int             iFWErrCode;
  int             iFWErrPhase;
  int             iFWErrLocation;
  int             iFWErrSlot;
  int             iSOMModuleType;
  int             iFreqTrigIdx;
  int             iTemp1;
  int             iTemp2;
  int             iTemp3;
  int             iFreq;
  int             iHead;
  //
  int             i;
  //
  T_PRI_Constants PRIConst;
  //
  // byte (boolean)
  unsigned char   bUSBInstGiven = false;
  unsigned char   bSerialGiven  = false;
  unsigned char   bProductGiven = false;
  unsigned char   bNoWait       = false;
  unsigned char   bIsPrimary;
  unsigned char   bIsBackPlane;
  unsigned char   bHasUptimeCounter;
  unsigned char   bSOM_Found    = false;
  unsigned char   bSLM_Found    = false;
  unsigned char   bVUV_Found    = false;
  unsigned char   bVIR_Found    = false;
  unsigned char   bPRI_Found    = false;
  unsigned char   bSOM_FFound   = false;
  unsigned char   bSLM_FFound   = false;
  unsigned char   bVUV_FFound   = false;
  unsigned char   bVIR_FFound   = false;
  unsigned char   bPRI_FFound   = false;
  unsigned char   bIsSOMDModule = false;
  unsigned char   bExtTiggered;
  unsigned char   bPulseMode;
  unsigned char   bSyncInverse;
  unsigned char   bSynchronized;
  //
  // byte (numerical or bit-coded value)
  unsigned char   bDivider;
  unsigned char   bOutEnable;
  unsigned char   bSyncEnable;
  unsigned char   bPreSync;
  unsigned char   bMaskSync;

  //
  // word
  unsigned short  wDivider;
  unsigned short  wSOMDState;
  short           iSOMDErrorCode;
  //
  float           fIntensity;
  //
  //
  /*
  // I don't know, why this happens, it is totally puzzling me:
  //
  // I expect the proper newline for DOS/Windows to be <CR><LF>,
  // i.e. "\r\n" or "\x0D\x0A", while it should be only <LF>,
  // i.e. "\n" or "\x0A" for Linux. But it seems, that in this
  // runtime environment, Visual Studio C/C++ expands the '\n'
  // all by itself to a "\r\n" so that there come out _two_ <CR> 
  // ("\r\r\n") if you properly terminate lines with "\r\n".
  // You can see them if you redirect the whole output into a
  // file and analyse the results in an editor like notepad++
  // with options like e.g. "Show End of Line" or similar...
  //
  // So I deactivated the decision if this demo runs under Linux
  // and left it all with newline = "\x0A"...
  // 
  */

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
      // this didn't work, see above
      cNewLine[i = 0] = '\x0D';
      cNewLine[++i]   = '\x0A';
      cNewLine[++i]   = '\x00';
    }
  }
  */
  //
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
    for (i = 1; i < argc; i++)
    {
      if (strlen(argv[0]) == 1)
      {
        // arguments come as wide char
        wchar_t* pwc = (wchar_t*)&(argv[i][0]);
        //
        if (0 == wcsncmp(pwc, L"-inst=", 6))
        {
          iGivenDevIdx = _wtoi(&(pwc[6]));
          WriteLine ("    -inst=%d", iGivenDevIdx);
          bUSBInstGiven = true;
        }
        else if (0 == wcsncmp(pwc, L"-serial=", 8))
        {
          sprintf_s(cGivenSerNo, SEPIA2_SERIALNUMBER_LEN, "%S", &pwc[8]);
          WriteLine ("    -serial=%S", &pwc[8]);
          bSerialGiven = (strlen(cGivenSerNo) > 0);
        }
        else if (0 == wcsncmp(pwc, L"-product=", 9))
        {
          sprintf_s(cGivenProduct, SEPIA2_PRODUCTMODEL_LEN, "%S", &pwc[9]);
          WriteLine ("    -product=\"%S\"", &pwc[9]);
          bProductGiven = (strlen(cGivenProduct) > 0);
        }
        else if (0 == wcscmp (pwc, L"-nowait"))
        {
          bNoWait = true;
          WriteLine ("    %S", (wchar_t*)argv[i]);
        } 
        else
        {
          WriteLine ("    %s : unknown parameter!", argv[i]);
        }
      }
      else
      {
        // arguments come as wide char
        char* pc = (char*)&(argv[i][0]);
        //
        if (0 == strncmp(pc, "-inst=", 6))
        {
          iGivenDevIdx = atoi(&(pc[6]));
          WriteLine ("    -inst=%d", iGivenDevIdx);
          bUSBInstGiven = true;
        }
        else if (0 == strncmp(pc, "-serial=", 8))
        {
          strcpy_s(cGivenSerNo, SEPIA2_SERIALNUMBER_LEN, &argv[i][8]);
          WriteLine ("    -serial=%s", &argv[i][8]);
          bSerialGiven = (strlen(cGivenSerNo) > 0);
        }
        else if (0 == strncmp(pc, "-product=", 9))
        {
          strcpy_s(cGivenProduct, SEPIA2_PRODUCTMODEL_LEN, &argv[i][9]);
          WriteLine ("    -product=%s", &argv[i][9]);
          bProductGiven = (strlen(cGivenProduct) > 0);
        }
        else if (0 == strcmp (pc, "-nowait"))
        {
          bNoWait = true;
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
  WriteLine ("%sPQLaserDrv   Set SOME Values Demo : ", STR_INDENT);
  WriteLine ("%s", STR_SEPARATORLINE);
  WriteLine ("");
  //
  // preliminaries: check library version
  //
  iRetVal = SEPIA2_LIB_GetVersion (cLibVersion);
  if (Sepia2FunctionSucceeds(iRetVal, "LIB_GetVersion", NO_DEVIDX, NO_IDX_1, NO_IDX_2))
  {
    WriteLine ("%sLib-Version    = %s", STR_INDENT, cLibVersion);


    if (0 != strncmp(cLibVersion, LIB_VERSION_REFERENCE, LIB_VERSION_REFERENCE_COMPLEN))
    {
      WriteLine ("");
      WriteLine ("%sWarning: This demo application was built for version  %s!", STR_INDENT, LIB_VERSION_REFERENCE);
      WriteLine ("%s         Continuing may cause unpredictable results!", STR_INDENT);
      WriteLine ("");
      Write ("%sDo you want to continue anyway? (y/n): ", STR_INDENT);

      c = getchar();
      if (toupper(c) != 'Y')
      {
        exit (-1);
      }
      while ((c = getchar()) != '\n'); // reject userinput 'til end of line
      WriteLine ("");
    }
  }
  //
  // establish USB connection to the sepia first matching all given conditions
  //
  for (i = (bUSBInstGiven ? iGivenDevIdx : 0); i < (bUSBInstGiven ? iGivenDevIdx+1 : SEPIA2_MAX_USB_DEVICES); i++)
  {
    SecureZeroMemory (cSepiaSerNo,   sizeof(cSepiaSerNo));
    SecureZeroMemory (cProductModel, sizeof(cProductModel));
    //
    iRetVal = SEPIA2_USB_OpenGetSerNumAndClose (i, cProductModel, cSepiaSerNo);
    if ( (iRetVal == SEPIA2_ERR_NO_ERROR) 
      && (  (  (bSerialGiven && bProductGiven)
            && ( (strcmp (cGivenSerNo,   cSepiaSerNo)   == 0)
              && (strcmp (cGivenProduct, cProductModel) == 0)
                )
            )
        ||  (  (!bSerialGiven != !bProductGiven)
            && ( (strcmp (cGivenSerNo,   cSepiaSerNo)   == 0)
              || (strcmp (cGivenProduct, cProductModel) == 0)
                )
            )
        ||  ( !bSerialGiven && !bProductGiven) 
          )
        )
    {
      iDevIdx = bUSBInstGiven ? ((iGivenDevIdx == i) ? i : -1) : i;
      break;
    }
  }
  //
  iRetVal = SEPIA2_USB_OpenDevice(iDevIdx, cProductModel, cSepiaSerNo);
  if (Sepia2FunctionSucceeds(iRetVal, "USB_OpenDevice", iDevIdx, NO_IDX_1, NO_IDX_2))
  {
    WriteLine ("%sProduct Model  = '%s'", STR_INDENT, cProductModel);
    WriteLine ("");
    WriteLine ("%s", STR_SEPARATORLINE);
    WriteLine ("");
    iRetVal = SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion);
    if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetVersion", iDevIdx, NO_IDX_1, NO_IDX_2))
    {
      WriteLine("%sFW-Version     = %s", STR_INDENT, cFWVersion);
    }
    //
    iRetVal = SEPIA2_USB_GetStrDescriptor (iDevIdx, cDescriptor);
    if (Sepia2FunctionSucceeds(iRetVal, "USB_GetStrDescriptor", iDevIdx, NO_IDX_1, NO_IDX_2))
    {
      WriteLine ("%sUSB Index      = %d",   STR_INDENT, iDevIdx);
      WriteLine ("%sUSB Descriptor = %s",   STR_INDENT, cDescriptor);
      WriteLine ("%sSerial Number  = '%s'", STR_INDENT, cSepiaSerNo);
    }
    WriteLine ("");
    WriteLine ("%s", STR_SEPARATORLINE);
    WriteLine (""); WriteLine ("");
    //
    // get sepia's module map and initialise datastructures for all library functions
    // there are two different ways to do so:
    //
    // first:  if sepia was not touched since last power on, it doesn't need to be restarted
    //
    iRetVal = SEPIA2_FWR_GetModuleMap (iDevIdx, SEPIA2_NO_RESTART, &iModuleCount);
    //
    // second: in case of changes with soft restart
    //
    //  iRetVal = SEPIA2_FWR_GetModuleMap (iDevIdx, SEPIA2_RESTART, &iModuleCount);
    //
    if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetModuleMap", iDevIdx, NO_IDX_1, NO_IDX_2))
    {
      //
      // this is to inform us about possible error conditions during sepia's last startup
      //
      iRetVal = SEPIA2_FWR_GetLastError (iDevIdx, &iFWErrCode, &iFWErrPhase, &iFWErrLocation, &iFWErrSlot, cFWErrCond);
      if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetLastError", iDevIdx, NO_IDX_1, NO_IDX_2))
      {
        if (!HasFWError (iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond, "Firmware error detected:"))
        {
          //
          // now look for SOM(D), SLM, VUV/VIR modules, take always the first
          //
          for (i = 0; i < iModuleCount; i++)
          {
            iRetVal = SEPIA2_FWR_GetModuleInfoByMapIdx(iDevIdx, i, &iSlotNr, &bIsPrimary, &bIsBackPlane, &bHasUptimeCounter);
            if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetModuleInfoByMapIdx", iDevIdx, i, NO_IDX_2))
            {
              if (bIsPrimary && !bIsBackPlane)
              {
                iRetVal = SEPIA2_COM_GetModuleType(iDevIdx, iSlotNr, SEPIA2_PRIMARY_MODULE, &iModuleType);
                if (Sepia2FunctionSucceeds(iRetVal, "COM_GetModuleType", iDevIdx, iSlotNr, NO_IDX_2))
                {
                  switch (iModuleType) {
                  case SEPIA2OBJECT_SOM:
                  case SEPIA2OBJECT_SOMD:
                    if (!bSOM_Found)
                    {
                      bSOM_Found = true;
                      iSOM_Slot = iSlotNr;
                      iSOMModuleType = iModuleType;
                      bIsSOMDModule = (iModuleType == SEPIA2OBJECT_SOMD);
                      //
                      iRetVal = SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, SEPIA2_PRIMARY_MODULE, cSOMSerNr);
                      if (Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotNr, NO_IDX_2))
                      {
                        SEPIA2_COM_DecodeModuleTypeAbbr(iModuleType, cSOMType);
                        //
                        if (bIsSOMDModule)
                        {
                          iRetVal = SEPIA2_SOMD_GetStatusError(iDevIdx, iSOM_Slot, &wSOMDState, &iSOMDErrorCode);
                          Sepia2FunctionSucceeds(iRetVal, "SOMD_GetStatusError", iDevIdx, iSOM_Slot, NO_IDX_2);
                        }
                      }
                    }
                    break;
                    //
                  case SEPIA2OBJECT_SLM:
                    if (!bSLM_Found)
                    {
                      bSLM_Found = true;
                      iSLM_Slot = iSlotNr;
                      //
                      iRetVal = SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, SEPIA2_PRIMARY_MODULE, cSLMSerNr);
                      Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotNr, NO_IDX_2);
                    }
                    break;
                    //
                  case SEPIA2OBJECT_VUV:
                    if (!bVUV_Found)
                    {
                      bVUV_Found = true;
                      iVUV_Slot = iSlotNr;
                      //
                      iRetVal = SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, SEPIA2_PRIMARY_MODULE, cVUVSerNr);
                      Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotNr, NO_IDX_2);
                    }
                    break;
                    //
                  case SEPIA2OBJECT_VIR:
                    if (!bVIR_Found)
                    {
                      bVIR_Found = true;
                      iVIR_Slot = iSlotNr;
                      //
                      iRetVal = SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, SEPIA2_PRIMARY_MODULE, cVIRSerNr);
                      Sepia2FunctionSucceeds(iRetVal, "", iDevIdx, iSlotNr, NO_IDX_2);
                    }
                    break;
                    //
                  case SEPIA2OBJECT_PRI:
                    if (!bPRI_Found)
                    {
                      bPRI_Found = true;
                      iPRI_Slot = iSlotNr;
                      //
                      iRetVal = SEPIA2_PRI_GetConstants(iDevIdx, iPRI_Slot, &PRIConst);
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetConstants", iDevIdx, iPRI_Slot, NO_IDX_2))
                      {
                        iRetVal = SEPIA2_COM_GetSerialNumber(iDevIdx, iPRI_Slot, SEPIA2_PRIMARY_MODULE, cPRISerNr);
                        Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iPRI_Slot, NO_IDX_2);
                      }
                    }
                    break;
                    //
                  } // switch
                } // if SEPIA2_COM_GetModuleType
              } // if bIsPrimary && !bIsBackPlane
            } // if SEPIA2_FWR_GetModuleInfoByMapIdx
          } // for ModuleCount
          //
          if (strcmp(cSOMType, "SOM ") < 0)
          {
            SEPIA2_COM_DecodeModuleTypeAbbr(SEPIA2OBJECT_SOM, cSOMType);
          }
          SEPIA2_COM_DecodeModuleTypeAbbr(SEPIA2OBJECT_SLM, cSLMType);
          SEPIA2_COM_DecodeModuleTypeAbbr(SEPIA2OBJECT_VUV, cVUVType);
          SEPIA2_COM_DecodeModuleTypeAbbr(SEPIA2OBJECT_VIR, cVIRType);
          SEPIA2_COM_DecodeModuleTypeAbbr(SEPIA2OBJECT_PRI, cPRIType);
          //
          // let all module types be exact 4 characters long:
          (strcat(cSOMType, " "))[4] = '\0';
          (strcat(cSLMType, " "))[4] = '\0';
          (strcat(cVUVType, " "))[4] = '\0';
          (strcat(cVIRType, " "))[4] = '\0';
          (strcat(cPRIType, " "))[4] = '\0';
          //
          //
          // we want to restore the changed values ...
          //
          if (_stat(FNAME, &buf) == 0)
          {
            // ... so we have to read the original data from file
            //
            f = fopen(FNAME, "rt");
            //
            //   SOM
            //
            fscanf (f, "%s ModuleFound   =        %s\n", cTemp, cTemp1);
            bSOM_FFound = StrToBool(cTemp1);
            //
            if (bSOM_FFound != bSOM_Found)
            {
              WriteLine ("");
              fclose(f);
              WriteLine ("%sdevice configuration probably changed:", STR_INDENT);
              WriteLine ("%scouldn't process original data as read from file '%s'", STR_INDENT, FNAME);
              WriteLine ("%sfile %s SOM data, but", STR_INDENT, (bSOM_FFound ? "contains" : "doesn't contain"));
              WriteLine ("%sdevice has currently %s SOM module", STR_INDENT, (bSOM_Found ? "a" : "no"));
              WriteLine ("");
              WriteLine ("%sdemo execution aborted.", STR_INDENT);
              WriteLine (""); WriteLine ("");
              Write     ("press RETURN...");
              getchar();
              return (1);
            }
            if (bSOM_FFound)
            {
              //
              // SOM / SOMD Data
              //
              fscanf(f, "%4s SlotID        =        %d\n", cSOMType, &iSOM_FSlot);
              fscanf(f, "%4s SerialNumber  = %s\n", cSOMType, cSOMFSerNr);
              //
              if ((iSOM_FSlot != iSOM_Slot) || (strcmp(trim(cSOMFSerNr), trim(cSOMSerNr)) != 0))
              {
                WriteLine ("");
                fclose(f);
                WriteLine ("%sdevice configuration probably changed:", STR_INDENT);
                WriteLine ("%scouldn't process original data as read from file '%s'", STR_INDENT, FNAME);
                WriteLine ("%sfile data on the slot or serial number of the SOM module differs", STR_INDENT);
                WriteLine ("");
                WriteLine ("%sdemo execution aborted.", STR_INDENT);
                WriteLine (""); WriteLine ("");
                Write     ("press RETURN...");
                getchar();
                return (1);
              }
              //
              //
              // FreqTrigMode
              //
              fscanf(f, "%s FreqTrigIdx   =      %d\n", cTemp, &iFreqTrigIdx);
              bExtTiggered = (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_RISING) || (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_FALLING);
              //
              if ((strcmp(cTemp, "SOMD") == 0) && bExtTiggered)
              {
                fscanf(f, "%s ExtTrig.Sync. =      %d\n", cTemp, &iTemp1);
                bSynchronized = (iTemp1 != 0);
              }
              //
              fscanf(f, "%s Divider       =      %d\n", cTemp, &iTemp1);
              fscanf(f, "%s PreSync       =      %d\n", cTemp, &iTemp2);
              fscanf(f, "%s MaskSync      =      %d\n", cTemp, &iTemp3);
              bDivider = (unsigned char)(iTemp1 % 256);
              wDivider = iTemp1;
              bPreSync = iTemp2;
              bMaskSync = iTemp3;
              //
              fscanf(f, "%s Output Enable =     0x%2X\n", cTemp, &iTemp1);
              fscanf(f, "%s Sync Enable   =     0x%2X\n", cTemp, &iTemp2);
              fscanf(f, "%s Sync Inverse  =        %s\n", cTemp, cTemp1);
              bOutEnable = iTemp1;
              bSyncEnable = iTemp2;
              bSyncInverse = StrToBool(cTemp1);
              for (i = 0; i < SEPIA2_SOM_BURSTCHANNEL_COUNT; i++)
              {
                fscanf(f, "%4s BurstLength %d = %8d\n", cTemp, &iTemp1, &lTemp);
                lBurstChannels[iTemp1 - 1] = lTemp;
              }
            } // bSOM_FFound
            //
            //
            //   SLM
            //
            fscanf(f, "%s ModuleFound   =        %s\n", cTemp, cTemp1);
            bSLM_FFound = StrToBool(cTemp1);
            //
            if (bSLM_FFound != bSLM_Found)
            {
              WriteLine ("");
              fclose(f);
              WriteLine ("%sdevice configuration probably changed:", STR_INDENT);
              WriteLine ("%scouldn't process original data as read from file '%s'", STR_INDENT, FNAME);
              WriteLine ("%sfile %s SLM data, but", STR_INDENT, (bSLM_FFound ? "contains" : "doesn't contain"));
              WriteLine ("%sdevice has currently %s SLM module", STR_INDENT, (bSLM_Found ? "a" : "no"));
              WriteLine ("");
              WriteLine ("%sdemo execution aborted.", STR_INDENT);
              WriteLine (""); WriteLine ("");
              Write     ("press RETURN...");
              getchar();
              return (1);
            }
            if (bSLM_FFound)
            {
              //
              // SLM Data
              //
              fscanf(f, "%4s SlotID        =        %d\n", cSLMType, &iSLM_FSlot);
              fscanf(f, "%4s SerialNumber  = %s\n", cSLMType, cSLMFSerNr);
              //
              //
              if ((iSLM_FSlot != iSLM_Slot) || (strcmp(trim(cSLMFSerNr), trim(cSLMSerNr)) != 0))
              {
                WriteLine ("");
                fclose(f);
                WriteLine ("%sdevice configuration probably changed:", STR_INDENT);
                WriteLine ("%scouldn't process original data as read from file '%s'", STR_INDENT, FNAME);
                WriteLine ("%sfile data on the slot or serial number of the SLM module differs", STR_INDENT);
                WriteLine ("");
                WriteLine ("%sdemo execution aborted.", STR_INDENT);
                WriteLine (""); WriteLine ("");
                Write     ("press RETURN...");
                getchar();
                return (1);
              }
              //
              fscanf(f, "%s FreqTrigIdx   =        %1d\n", cTemp, &iFreq);
              fscanf(f, "%s Pulse Mode    =        %s\n", cTemp, cTemp1);
              fscanf(f, "%s Intensity     =      %f %%\n", cTemp, &fIntensity);
              bPulseMode = StrToBool(cTemp1);
              wIntensity = (word)((int)(10 * fIntensity + 0.5));
            } // bSLM_FFound
            //
            //
            //   VUV
            //
            fscanf(f, "%s ModuleFound   =        %s\n", cTemp, cTemp1);
            bVUV_FFound = StrToBool(cTemp1);
            //
            if (bVUV_FFound != bVUV_Found)
            {
              WriteLine ("");
              fclose(f);
              WriteLine ("%sdevice configuration probably changed:", STR_INDENT);
              WriteLine ("%scouldn't process original data as read from file '%s'", STR_INDENT, FNAME);
              WriteLine ("%sfile %s VisUV data, but", STR_INDENT, (bVUV_FFound ? "contains" : "doesn't contain"));
              WriteLine ("%sdevice has currently %s VUV module", STR_INDENT, (bVUV_Found ? "a" : "no"));
              WriteLine ("");
              WriteLine ("%sdemo execution aborted.", STR_INDENT);
              WriteLine (""); WriteLine ("");
              Write     ("press RETURN...");
              getchar();
              return (1);
            }
            if (bVUV_FFound)
            {
              //
              // VUV Data
              //
              fscanf(f, "%4s SlotID        =        %d\n", cVUVType, &iVUV_FSlot);
              fscanf(f, "%4s SerialNumber  = %s\n", cVUVType, cVUVFSerNr);
              //
              //
              if ((iVUV_FSlot != iVUV_Slot) || (strcmp(trim(cVUVFSerNr), trim(cVUVSerNr)) != 0))
              {
                WriteLine ("");
                fclose(f);
                WriteLine ("%sdevice configuration probably changed:", STR_INDENT);
                WriteLine ("%scouldn't process original data as read from file '%s'", STR_INDENT, FNAME);
                WriteLine ("%sfile data on the slot or serial number of the VUV module differs", STR_INDENT);
                WriteLine ("");
                WriteLine ("%sdemo execution aborted.", STR_INDENT);
                WriteLine (""); WriteLine ("");
                Write     ("press RETURN...");
                getchar();
                return (1);
              }
              //
              Read_VUV_VIR_Data(IS_A_VUV);
              //
            } // bVUV_FFound
            //
            //
            //   VIR
            //
            fscanf(f, "%s ModuleFound   =        %s\n", cTemp, cTemp1);
            bVIR_FFound = StrToBool(cTemp1);
            //
            if (bVIR_FFound != bVIR_Found)
            {
              WriteLine ("");
              fclose(f);
              WriteLine ("%sdevice configuration probably changed:", STR_INDENT);
              WriteLine ("%scouldn't process original data as read from file '%s'", STR_INDENT, FNAME);
              WriteLine ("%sfile %s VisIR data, but", STR_INDENT, (bVIR_FFound ? "contains" : "doesn't contain"));
              WriteLine ("%sdevice has currently %s VIR module", STR_INDENT, (bVIR_Found ? "a" : "no"));
              WriteLine ("");
              WriteLine ("%sdemo execution aborted.", STR_INDENT);
              WriteLine (""); WriteLine ("");
              Write     ("press RETURN...");
              getchar();
              return (1);
            }
            if (bVIR_FFound)
            {
              //
              // VIR Data
              //
              fscanf(f, "%4s SlotID        =        %d\n", cVIRType, &iVIR_FSlot);
              fscanf(f, "%4s SerialNumber  = %s\n", cVIRType, cVIRFSerNr);
              //
              //
              if ((iVIR_FSlot != iVIR_Slot) || (strcmp(trim(cVIRFSerNr), trim(cVIRSerNr)) != 0))
              {
                WriteLine ("");
                fclose(f);
                WriteLine ("%sdevice configuration probably changed:", STR_INDENT);
                WriteLine ("%scouldn't process original data as read from file '%s'", STR_INDENT, FNAME);
                WriteLine ("%sfile data on the slot or serial number of the VIR module differs", STR_INDENT);
                WriteLine ("");
                WriteLine ("%sdemo execution aborted.", STR_INDENT);
                WriteLine (""); WriteLine ("");
                Write     ("press RETURN...");
                getchar();
                return (1);
              }
              //
              //
              Read_VUV_VIR_Data(IS_A_VIR);
              //
            } // bVIR_FFound
            //
            //
            //   PRI
            //
            fscanf(f, "%s ModuleFound   =        %s\n", cTemp, cTemp1);
            bPRI_FFound = StrToBool(cTemp1);
            //
            if (bPRI_FFound != bPRI_Found)
            {
              WriteLine ("");
              fclose(f);
              WriteLine ("%sdevice configuration probably changed:", STR_INDENT);
              WriteLine ("%scouldn't process original data as read from file '%s'", STR_INDENT, FNAME);
              WriteLine ("%sfile %s Prima data, but", STR_INDENT, (bPRI_FFound ? "contains" : "doesn't contain"));
              WriteLine ("%sdevice has currently %s PRI module", STR_INDENT, (bPRI_Found ? "a" : "no"));
              WriteLine ("");
              WriteLine ("%sdemo execution aborted.", STR_INDENT);
              WriteLine (""); WriteLine ("");
              Write     ("press RETURN...");
              getchar();
              return (1);
            }
            if (bPRI_FFound)
            {
              //
              // PRI Data
              //
              fscanf(f, "%4s SlotID        =        %d\n", cPRIType, &iPRI_FSlot);
              fscanf(f, "%4s SerialNumber  = %s\n", cPRIType, cPRIFSerNr);
              //
              //
              if ((iPRI_FSlot != iPRI_Slot) || (strcmp(trim(cPRIFSerNr), trim(cPRISerNr)) != 0))
              {
                WriteLine ("");
                fclose(f);
                WriteLine ("%sdevice configuration probably changed:", STR_INDENT);
                WriteLine ("%scouldn't process original data as read from file '%s'", STR_INDENT, FNAME);
                WriteLine ("%sfile data on the slot or serial number of the PRI module differs", STR_INDENT);
                WriteLine ("");
                WriteLine ("%sdemo execution aborted.", STR_INDENT);
                WriteLine (""); WriteLine ("");
                Write     ("press RETURN...");
                getchar();
                return (1);
              }
              //
              fscanf(f, "%4s OperModeIdx   =      %d\n", cTemp, &iOpModeIdx);
              fscanf(f, "%4s WavelengthIdx =      %d\n", cTemp, &iWL_Idx);
              fscanf(f, "%4s Intensity     =      %f %%\n", cTemp, &fIntensity);
              wIntensity = (int)((10 * fIntensity) + 0.5);  // round (10*fIntensity)
              //
            } // bPRI_FFound
            //
            //

            //
            //
            // ... and delete it afterwards
            fclose(f);
            WriteLine ("%soriginal data as read from file '%s':", STR_INDENT, FNAME);
            WriteLine ("%s(file was deleted after processing)", STR_INDENT);
            WriteLine ("");
            remove(FNAME);
          } // read from file
          else
          {
            // ... so we have to save the original data in a file
            // ... and may then set arbitrary values
            //
            if ((f = fopen(FNAME, "wt")) == NULL)
            {
              WriteLine ("%sYou tried to start this demo in a write protected directory.", STR_INDENT);
              WriteLine ("%sdemo execution aborted.", STR_INDENT);
              WriteLine ("");
              Write     ("press RETURN...");
              getchar();
              return iRetVal;
            }
            //
            // SOM
            //
            F_WriteLine (f, "%4s ModuleFound   =        %s", cSOMType, BoolToStr(bSOM_Found));
            if (bSOM_Found)
            {
              //
              // SOM / SOMD
              //
              F_WriteLine (f, "%4s SlotID        =      %3d", cSOMType, iSOM_Slot);
              F_WriteLine (f, "%4s SerialNumber  = %8s", cSOMType, cSOMSerNr);
              //
              // FreqTrigMode
              //
              if (bIsSOMDModule)
              {
                iRetVal = SEPIA2_SOMD_GetFreqTrigMode(iDevIdx, iSOM_Slot, &iFreqTrigIdx, &bSynchronized);
                if (Sepia2FunctionSucceeds(iRetVal, "SOMD_GetFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2))
                {
                  F_WriteLine (f, "%-4s FreqTrigIdx   =        %1d", cSOMType, iFreqTrigIdx);
                  if ((iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_RISING) || (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_FALLING))
                  {
                    F_WriteLine (f, "%-4s ExtTrig.Sync. =        %1d", cSOMType, bSynchronized ? 1 : 0);
                  }
                }
              }
              else
              {
                iRetVal = SEPIA2_SOM_GetFreqTrigMode(iDevIdx, iSOM_Slot, &iFreqTrigIdx);
                if (Sepia2FunctionSucceeds(iRetVal, "SOM_GetFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2))
                {
                  F_WriteLine (f, "%-4s FreqTrigIdx   =        %1d", cSOMType, iFreqTrigIdx);
                }
              }
              iFreqTrigIdx = SEPIA2_SOM_INT_OSC_C;
              //
              // BurstValues
              if (bIsSOMDModule)
              {
                iRetVal = SEPIA2_SOMD_GetBurstValues(iDevIdx, iSOM_Slot, &wDivider, &bPreSync, &bMaskSync);
                Sepia2FunctionSucceeds(iRetVal, "SOMD_GetBurstValues", iDevIdx, iSOM_Slot, NO_IDX_2);
              }
              else
              {
                iRetVal = SEPIA2_SOM_GetBurstValues(iDevIdx, iSOM_Slot, &bDivider, &bPreSync, &bMaskSync);
                if (Sepia2FunctionSucceeds(iRetVal, "SOM_GetBurstValues", iDevIdx, iSOM_Slot, NO_IDX_2))
                {
                  wDivider = bDivider;
                }
              }
              F_WriteLine (f, "%-4s Divider       =    %5u", cSOMType, wDivider);
              F_WriteLine (f, "%-4s PreSync       =      %3u", cSOMType, bPreSync);
              F_WriteLine (f, "%-4s MaskSync      =      %3u", cSOMType, bMaskSync);
              bDivider = 200;
              wDivider = 200;
              bPreSync = 10;
              bMaskSync = 1;
              //
              // Out'n'SyncEnable
              if (bIsSOMDModule)
              {
                iRetVal = SEPIA2_SOMD_GetOutNSyncEnable(iDevIdx, iSOM_Slot, &bOutEnable, &bSyncEnable, &bSyncInverse);
                if (Sepia2FunctionSucceeds(iRetVal, "SOMD_GetOutNSyncEnable", iDevIdx, iSOM_Slot, NO_IDX_2))
                {
                  iRetVal = SEPIA2_SOMD_GetBurstLengthArray(iDevIdx, iSOM_Slot, &lBurstChannels[0], &lBurstChannels[1], &lBurstChannels[2], &lBurstChannels[3], &lBurstChannels[4], &lBurstChannels[5], &lBurstChannels[6], &lBurstChannels[7]);
                  Sepia2FunctionSucceeds(iRetVal, "SOMD_GetBurstLengthArray", iDevIdx, iSOM_Slot, NO_IDX_2);
                }
              }
              else
              {
                iRetVal = SEPIA2_SOM_GetOutNSyncEnable(iDevIdx, iSOM_Slot, &bOutEnable, &bSyncEnable, &bSyncInverse);
                if (Sepia2FunctionSucceeds(iRetVal, "SOM_GetOutNSyncEnable", iDevIdx, iSOM_Slot, NO_IDX_2))
                {
                  iRetVal = SEPIA2_SOM_GetBurstLengthArray(iDevIdx, iSOM_Slot, &lBurstChannels[0], &lBurstChannels[1], &lBurstChannels[2], &lBurstChannels[3], &lBurstChannels[4], &lBurstChannels[5], &lBurstChannels[6], &lBurstChannels[7]);
                  Sepia2FunctionSucceeds(iRetVal, "SOM_GetBurstLengthArray", iDevIdx, iSOM_Slot, NO_IDX_2);
                }
              }
              F_WriteLine (f, "%-4s Output Enable =     0x%2.2X", cSOMType, bOutEnable);
              F_WriteLine (f, "%-4s Sync Enable   =     0x%2.2X", cSOMType, bSyncEnable);
              F_WriteLine (f, "%-4s Sync Inverse  =        %s", cSOMType, BoolToStr(bSyncInverse));
              bOutEnable = 0xA5;
              bSyncEnable = 0x93;
              bSyncInverse = 1;
              //
              // BurstLengthArray
              for (i = 0; i < SEPIA2_SOM_BURSTCHANNEL_COUNT; i++)
              {
                F_WriteLine (f, "%-4s BurstLength %d = %8d", cSOMType, i + 1, lBurstChannels[i]);
              }
              // just change places of burstlenght channel 2 & 3
              lTemp = lBurstChannels[2];
              lBurstChannels[2] = lBurstChannels[1];
              lBurstChannels[1] = lTemp;
              //
            }
            //
            //
            //
            F_WriteLine (f, "%4s ModuleFound   =        %s", cSLMType, BoolToStr(bSLM_Found));
            if (bSLM_Found)
            {
              //
              // SLM
              //
              F_WriteLine (f, "%4s SlotID        =      %3d", cSLMType, iSLM_Slot);
              F_WriteLine (f, "%4s SerialNumber  = %8s", cSLMType, cSLMSerNr);
              //
              //
              iRetVal = SEPIA2_SLM_GetIntensityFineStep(iDevIdx, iSLM_Slot, &wIntensity);
              if (Sepia2FunctionSucceeds(iRetVal, "SLM_GetIntensityFineStep", iDevIdx, iSLM_Slot, NO_IDX_2))
              {
                iRetVal = SEPIA2_SLM_GetPulseParameters(iDevIdx, iSLM_Slot, &iFreq, &bPulseMode, &iHead);
                Sepia2FunctionSucceeds(iRetVal, "SLM_GetPulseParameters", iDevIdx, iSLM_Slot, NO_IDX_2);
              }
              if (iRetVal == SEPIA2_ERR_NO_ERROR)
              {
                F_WriteLine (f, "%-4s FreqTrigIdx   =        %1d", cSLMType, iFreq);
                F_WriteLine (f, "%-4s Pulse Mode    =        %s", cSLMType, BoolToStr(bPulseMode));
                F_WriteLine (f, "%-4s Intensity     =      %5.1f %%", cSLMType, 0.1 * wIntensity);
                iFreq = (2 + iFreq) % SEPIA2_SLM_FREQ_TRIGMODE_COUNT;
                bPulseMode = 1 - bPulseMode;
                wIntensity = 1000 - wIntensity;
              }
              else
              {
                iFreq = SEPIA2_SLM_FREQ_20MHZ;
                bPulseMode = true;
                wIntensity = 440;
              }
            }
            //
            //
            //
            F_WriteLine (f, "%4s ModuleFound   =        %s", cVUVType, BoolToStr(bVUV_Found));
            if (bVUV_Found)
            {
              //
              // VisUV
              //
              F_WriteLine (f, "%4s SlotID        =      %3d", cVUVType, iVUV_Slot);
              F_WriteLine (f, "%4s SerialNumber  = %8s", cVUVType, cVUVSerNr);
              //
              GetWriteAndModify_VUV_VIR_Data(cVUVType, iVUV_Slot, IS_A_VUV);
              //
            }
            //
            //
            //
            F_WriteLine (f, "%4s ModuleFound   =        %s", cVIRType, BoolToStr(bVIR_Found));
            if (bVIR_Found)
            {
              //
              // VisIR
              //
              F_WriteLine (f, "%4s SlotID        =      %3d", cVIRType, iVIR_Slot);
              F_WriteLine (f, "%4s SerialNumber  = %8s", cVIRType, cVIRSerNr);
              //
              GetWriteAndModify_VUV_VIR_Data(cVIRType, iVIR_Slot, IS_A_VIR);
              //
            }
            //
            //
            //
            F_WriteLine (f, "%4s ModuleFound   =        %s", cPRIType, BoolToStr(bPRI_Found));
            if (bPRI_Found)
            {
              //
              // Prima
              //
              F_WriteLine (f, "%4s SlotID        =      %3d", cPRIType, iPRI_Slot);
              F_WriteLine (f, "%4s SerialNumber  = %8s", cPRIType, cPRISerNr);
              //
              iRetVal = SEPIA2_PRI_GetOperationMode (iDevIdx, iPRI_Slot, &iOpModeIdx);
              if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetOperationMode", iDevIdx, iPRI_Slot, NO_IDX_2))
              {
                iRetVal = SEPIA2_PRI_GetWavelengthIdx(iDevIdx, iPRI_Slot, &iWL_Idx);
                if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetWavelengthIdx", iDevIdx, iPRI_Slot, NO_IDX_2))
                {
                  iRetVal = SEPIA2_PRI_GetIntensity(iDevIdx, iPRI_Slot, iWL_Idx, &wIntensity);
                  Sepia2FunctionSucceeds(iRetVal, "PRI_GetIntensity", iDevIdx, iPRI_Slot, iWL_Idx);
                }
              }
              if (iRetVal == SEPIA2_ERR_NO_ERROR)
              {
                F_WriteLine (f, "%4s OperModeIdx   =        %d", cPRIType, iOpModeIdx);
                F_WriteLine (f, "%4s WavelengthIdx =        %d", cPRIType, iWL_Idx);
                F_WriteLine (f, "%4s Intensity     =      %5.1f %%", cPRIType, 0.1 * wIntensity);
                //
                iOpModeIdx = ((iOpModeIdx == PRIConst.PrimaOpModBroad) ? PRIConst.PrimaOpModNarrow : PRIConst.PrimaOpModBroad);
                iWL_Idx    = ((++iWL_Idx) % PRIConst.PrimaWLCount);
                wIntensity = 1000 - wIntensity;
              }
              else
              {
                iOpModeIdx = ((iOpModeIdx == PRIConst.PrimaOpModBroad) ? PRIConst.PrimaOpModNarrow : PRIConst.PrimaOpModBroad);
                iWL_Idx    = ((iWL_Idx == 0) ? 1 : 0);
                wIntensity = 440;
              }
              //
            }
            //
            //
            fclose(f);
            WriteLine ("%soriginal data was stored in file '%s'.", STR_INDENT, FNAME);
            WriteLine ("%schanged data as follows:", STR_INDENT);
            WriteLine ("");
          } // write to file
          //
          //
          //
          // and here we finally set the new (resp. old) values
          //
          if (bSOM_Found)
          {
            if (bIsSOMDModule)
            {
              iRetVal = SEPIA2_SOMD_SetFreqTrigMode(iDevIdx, iSOM_Slot, iFreqTrigIdx, bSynchronized);
              if (Sepia2FunctionSucceeds(iRetVal, "SOMD_SetFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2))
              {
                iRetVal = SEPIA2_SOMD_DecodeFreqTrigMode(iDevIdx, iSOM_Slot, iFreqTrigIdx, cFreqTrigMode);
                if (Sepia2FunctionSucceeds(iRetVal, "SOMD_DecodeFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2))
                {
                  iRetVal = SEPIA2_SOMD_SetBurstValues(iDevIdx, iSOM_Slot, wDivider, bPreSync, bMaskSync);
                  if (Sepia2FunctionSucceeds(iRetVal, "SOMD_SetBurstValues", iDevIdx, iSOM_Slot, NO_IDX_2))
                  {
                    iRetVal = SEPIA2_SOMD_SetOutNSyncEnable(iDevIdx, iSOM_Slot, bOutEnable, bSyncEnable, bSyncInverse);
                    if (Sepia2FunctionSucceeds(iRetVal, "SOMD_SetOutNSyncEnable", iDevIdx, iSOM_Slot, NO_IDX_2))
                    {
                      iRetVal = SEPIA2_SOMD_SetBurstLengthArray(iDevIdx, iSOM_Slot, lBurstChannels[0], lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7]);
                      Sepia2FunctionSucceeds(iRetVal, "SOMD_SetBurstLengthArray", iDevIdx, iSOM_Slot, NO_IDX_2);
                    }
                  }
                }
              }
            }
            else
            {
              bDivider = (unsigned char)wDivider % 256;
              //
              iRetVal = SEPIA2_SOM_SetFreqTrigMode(iDevIdx, iSOM_Slot, iFreqTrigIdx);
              if (Sepia2FunctionSucceeds(iRetVal, "SOM_SetFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2))
              {
                iRetVal = SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSOM_Slot, iFreqTrigIdx, cFreqTrigMode);
                if (Sepia2FunctionSucceeds(iRetVal, "SOM_DecodeFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2))
                {
                  iRetVal = SEPIA2_SOM_SetBurstValues (iDevIdx, iSOM_Slot, bDivider, bPreSync, bMaskSync);
                  if (Sepia2FunctionSucceeds(iRetVal, "SOM_SetBurstValues", iDevIdx, iSOM_Slot, NO_IDX_2))
                  {
                    iRetVal = SEPIA2_SOM_SetOutNSyncEnable (iDevIdx, iSOM_Slot, bOutEnable, bSyncEnable, bSyncInverse);
                    if (Sepia2FunctionSucceeds(iRetVal, "SOM_SetOutNSyncEnable", iDevIdx, iSOM_Slot, NO_IDX_2))
                    {
                      iRetVal = SEPIA2_SOM_SetBurstLengthArray (iDevIdx, iSOM_Slot, lBurstChannels[0], lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7]);
                      Sepia2FunctionSucceeds(iRetVal, "SOM_SetBurstLengthArray", iDevIdx, iSOM_Slot, NO_IDX_2);
                    }
                  }
                }
              }
            }
            WriteLine ("%s%-4s FreqTrigMode  =      '%s'", STR_INDENT, cSOMType, cFreqTrigMode);
            if ((bIsSOMDModule) && ((iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_RISING) || (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_FALLING)))
            {
              WriteLine ("%s%-4s ExtTrig.Sync. =        %1d", STR_INDENT, cSOMType, bSynchronized ? 1 : 0);
            }
            //
            WriteLine ("%s%-4s Divider       =    %5u", STR_INDENT, cSOMType, wDivider);
            WriteLine ("%s%-4s PreSync       =      %3u", STR_INDENT, cSOMType, bPreSync);
            WriteLine ("%s%-4s MaskSync      =      %3u", STR_INDENT, cSOMType, bMaskSync);
            //
            WriteLine ("%s%-4s Output Enable =     0x%2.2X", STR_INDENT, cSOMType, bOutEnable);
            WriteLine ("%s%-4s Sync Enable   =     0x%2.2X", STR_INDENT, cSOMType, bSyncEnable);
            WriteLine ("%s%-4s Sync Inverse  =        %s", STR_INDENT, cSOMType, BoolToStr(bSyncInverse));
            //
            WriteLine ("%s%-4s BurstLength 2 = %8d", STR_INDENT, cSOMType, lBurstChannels[1]);
            WriteLine ("%s%-4s BurstLength 3 = %8d", STR_INDENT, cSOMType, lBurstChannels[2]);
            WriteLine ("");
          }
          //
          // SLM
          //
          if (bSLM_Found)
          {
            iRetVal = SEPIA2_SLM_SetPulseParameters(iDevIdx, iSLM_Slot, iFreq, bPulseMode);
            if (Sepia2FunctionSucceeds(iRetVal, "SLM_SetPulseParameters", iDevIdx, iSLM_Slot, NO_IDX_2))
            {
              iRetVal = SEPIA2_SLM_SetIntensityFineStep(iDevIdx, iSLM_Slot, wIntensity);
              if (Sepia2FunctionSucceeds(iRetVal, "SLM_SetIntensityFineStep", iDevIdx, iSLM_Slot, NO_IDX_2))
              {
                SEPIA2_SLM_DecodeFreqTrigMode(iFreq, cFreqTrigMode);
                WriteLine ("%s%-4s FreqTrigMode  =      '%s'", STR_INDENT, cSLMType, cFreqTrigMode);
                WriteLine ("%s%-4s Pulse Mode    =        %s", STR_INDENT, cSLMType, BoolToStr(bPulseMode));
                WriteLine ("%s%-4s Intensity     =      %5.1f %%", STR_INDENT, cSLMType, 0.1 * wIntensity);
                WriteLine ("");
              }
            }
          }
          //
          // VisUV
          //
          if (bVUV_Found)
          {
            Set_VUV_VIR_Data (cVUVType, iVUV_Slot, IS_A_VUV);
          }
          //
          // VisIR
          //
          if (bVIR_Found)
          {
            Set_VUV_VIR_Data (cVIRType, iVIR_Slot, IS_A_VIR);
          }
          //
          // Prima
          //
          if (bPRI_Found)
          {
            iRetVal = SEPIA2_PRI_SetOperationMode (iDevIdx, iPRI_Slot, iOpModeIdx);
            if (Sepia2FunctionSucceeds(iRetVal, "PRI_SetOperationMode", iDevIdx, iPRI_Slot, NO_IDX_2))
            {
              iRetVal = SEPIA2_PRI_SetWavelengthIdx(iDevIdx, iPRI_Slot, iWL_Idx);
              if (Sepia2FunctionSucceeds(iRetVal, "PRI_SetWavelengthIdx", iDevIdx, iPRI_Slot, NO_IDX_2))
              {
                iRetVal = SEPIA2_PRI_SetIntensity(iDevIdx, iPRI_Slot, iWL_Idx, wIntensity);
                Sepia2FunctionSucceeds(iRetVal, "PRI_SetIntensity", iDevIdx, iPRI_Slot, iWL_Idx);
              }
            }
            if (iRetVal == SEPIA2_ERR_NO_ERROR)
            {
              iRetVal = SEPIA2_PRI_DecodeOperationMode(iDevIdx, iPRI_Slot, iOpModeIdx, cOperMode);
              if (iRetVal == SEPIA2_ERR_NO_ERROR)
              {
                WriteLine("%s%-4s OperModeIdx    =        %d  ==> '%s'", STR_INDENT, cPRIType, iOpModeIdx, trim(cOperMode));
              }
              else
              {
                WriteLine("%s%-4s OperationMode  =        %d  ==>  ??  (decoding error)", STR_INDENT, cPRIType, iOpModeIdx);
              }
              //
              iRetVal = SEPIA2_PRI_DecodeWavelength(iDevIdx, iPRI_Slot, iWL_Idx, &iWL);
              if (iRetVal == SEPIA2_ERR_NO_ERROR)
              {
                WriteLine("%s%-4s WavelengthIdx  =        %d  ==> %d nm", STR_INDENT, cPRIType, iWL_Idx, iWL);
              }
              else
              {
                WriteLine("%s%-4s WavelengthIdx  =        %d  ==>  ??  (decoding error)", STR_INDENT, cPRIType, iWL_Idx);
              }
              WriteLine(  "%s%-4s Intensity      =      %5.1f %%", STR_INDENT, cPRIType, 0.1 * wIntensity);
            }
            else
            {
              WriteLine("%s%-4s OperationMode  =       ??  (reading error)", STR_INDENT, cPRIType);
              WriteLine("%s%-4s WavelengthIdx  =       ??  (reading error)", STR_INDENT, cPRIType);
              WriteLine("%s%-4s Intensity      =       ??  (reading error)", STR_INDENT, cPRIType);
            }
            //
            WriteLine("");
          }
          //
        } // (iFWErrCode == SEPIA2_ERR_NO_ERROR)
      } // else GetLastError
    } // if GetModuleMap
    else
    {
      iRetVal = SEPIA2_FWR_GetLastError (iDevIdx, &iFWErrCode, &iFWErrPhase, &iFWErrLocation, &iFWErrSlot, cFWErrCond);
      if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetLastError", iDevIdx, NO_IDX_1, NO_IDX_2))
      {
        HasFWError (iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond, "Firmware error detected:");
      }
    }
    //
    SEPIA2_FWR_FreeModuleMap (iDevIdx);
    SEPIA2_USB_CloseDevice   (iDevIdx);
  }
  //
  WriteLine ("");
  //
  if (!bNoWait)
  {
    WriteLine ("press RETURN... ");
    getchar ();
  }
  return iRetVal;
}
