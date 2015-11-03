//-----------------------------------------------------------------------------
//
//      ReadAllDatabyMSVCPP.cpp
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
//-----------------------------------------------------------------------------
//

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

//char PRAEFIXES []   = "yzafpnµm kMGTPEZY";
  char PRAEFIXES []   = "yzafpnæm kMGTPEZY";
  int  PRAEFIX_OFFSET = 8;

void PrintUptimers (unsigned long ulMainPowerUp, unsigned long ulActivePowerUp, unsigned long ulScaledPowerUp)
{
  int    hlp;
  ldiv_t res;
  //
  hlp = (int)(5.0 * (ulMainPowerUp + 0x7F) / 0xFF);
  res = ldiv (hlp, 60);
  printf ("\n");
  printf ("%47s  = %5d:%2.2d h\n",  "main power uptime",   res.quot, res.rem);
  //
  if (ulActivePowerUp > 1)
  {
    hlp = (int)(5.0 * (ulActivePowerUp + 0x7F) / 0xFF);
    res = ldiv (hlp, 60);
    printf ("%47s  = %5d:%2.2d hrs\n",  "act. power uptime", res.quot, res.rem);
    //
    if (ulScaledPowerUp > (0.001 * ulActivePowerUp))
    {
      printf ("%47s  =       %5.1f%%\n\n",  "pwr scaled factor", 100.0 * ulScaledPowerUp / ulActivePowerUp);
    }
  }
  printf ("\n");
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

char* FormatEng (char* cDest, int iDestLen, double fInp, int iMant, char* cUnit = "", int iFixedSpace = -1, int iFixedDigits = -1, unsigned char bUnitSep = 1)
{
  int           i;
  unsigned char bNSign;
  double        fNorm;
  double        fTemp0;
  int           iTemp;
  char          cTemp [64];
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
  sprintf_s (cTemp, sizeof (cTemp), "%.*f%s%c%s", iFixedDigits < 0? i : iFixedDigits, fNorm * (bNSign ? -1.0 : 1.0), (bUnitSep ? " " : ""), PRAEFIXES [iTemp + PRAEFIX_OFFSET], cUnit);
  //
  if (iFixedSpace > (int) strlen (cTemp))
  {
    sprintf_s (cDest, iDestLen, "%*s%s", iFixedSpace - strlen (cTemp), "", cTemp);
  }
  else
  {
    strcpy_s (cDest, iDestLen, cTemp);
  }
  //
  return cDest;
}


int main(int argc, char* argv[])
{
  int             iRetVal                                        = SEPIA2_ERR_NO_ERROR;
  char            c;
  //
  char            cLibVersion    [SEPIA2_VERSIONINFO_LEN]        = "";
  char            cDescriptor    [SEPIA2_USB_STRDECR_LEN]        = "";
  char            cSepiaSerNo    [SEPIA2_SERIALNUMBER_LEN]       = "";
  char            cGivenSerNo    [SEPIA2_SERIALNUMBER_LEN]       = "";
  char            cProductModel  [SEPIA2_PRODUCTMODEL_LEN]       = "";
  char            cGivenProduct  [SEPIA2_PRODUCTMODEL_LEN]       = "";
  char            cFWVersion     [SEPIA2_VERSIONINFO_LEN]        = "";
  char            cFWErrCond     [SEPIA2_FW_ERRCOND_LEN]         = "";
  char            cFWErrPhase    [SEPIA2_FW_ERRPHASE_LEN]        = "";
  char            cErrString     [SEPIA2_ERRSTRING_LEN]          = "";
  char            cModulType     [SEPIA2_MODULETYPESTRING_LEN]   = "";
  char            cFreqTrigMode  [SEPIA2_SOM_FREQ_TRIGMODE_LEN]  = "";
  char            cFrequency     [SEPIA2_SLM_FREQ_TRIGMODE_LEN]  = "";
  char            cHeadType      [SEPIA2_SLM_HEADTYPE_LEN]       = "";
  char            cSerialNumber  [SEPIA2_SERIALNUMBER_LEN]       = "";
  char            cSWSModuleType [SEPIA2_SWS_MODULETYPE_MAXLEN]  = "";
  char            cTemp1         [65]                            = "";
  char            cTemp2         [65]                            = "";
  char            cBuffer        [65535]                         = "";
  char            cPreamble      []                              = "\n     Following are system describing common infos,\n     the considerate support team of PicoQuant GmbH\n     demands for your qualified service request:\n\n    =================================================\n\n";
  char            cCallingSW     []                              = "Demo-Program:   ReadAllDataByMSVCPP.exe\n";
  //
  long            lBurstChannels [SEPIA2_SOM_BURSTCHANNEL_COUNT] = {0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L};
  //
  int             iRestartOption                                 = SEPIA2_NO_RESTART;
  int             iDevIdx                                        = -1;
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
  int             iTriggerMilliVolt;
  int             iSWSModuleType;
  //
  // byte
  unsigned char   bUSBInstGiven = false;
  unsigned char   bSerialGiven  = false;
  unsigned char   bProductGiven = false;
  unsigned char   bNoWait       = false;
  unsigned char   bStayOpened   = false;
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
  T_Module_FWVers SWSFWVers;
  //
  int i, j;
  //
  //
  printf (" called with %d Parameter%s:\n", argc-1, (argc>2)?"s":"");
  for (i=1; i<argc; i++) 
  {
    if (strlen(argv[0]) == 1)
    {
      wchar_t* pwc = (wchar_t*)&(argv[i][0]); 
      //
      if (0 == wcsncmp (pwc, L"-inst=", 6))
      {
        iGivenDevIdx = _wtoi (&(pwc[6]));
        printf ("    -inst=%d\n", iGivenDevIdx);
        bUSBInstGiven = true;
      } else
      if (0 == wcsncmp (pwc, L"-serial=", 8))
      {
        sprintf_s (cGivenSerNo, SEPIA2_SERIALNUMBER_LEN, "%S", &pwc[8]);
        printf ("    -serial=%S\n", &pwc[8]);
        bSerialGiven = (strlen (cGivenSerNo) > 0);
      } else
      if (0 == wcsncmp (pwc, L"-product=", 9))
      {
        sprintf_s (cGivenProduct, SEPIA2_PRODUCTMODEL_LEN, "%S", &pwc[9]);
        printf ("    -product=\"%S\"\n", &pwc[9]);
        bProductGiven = (strlen (cGivenProduct) > 0);
      } else
      if (0 == wcscmp (pwc, L"-stayopened"))
      {
        bStayOpened = true;
        printf ("    %S\n", argv[i]);
      } else
      if (0 == wcscmp (pwc, L"-nowait"))
      {
        bNoWait = true;
        printf ("    %S\n", argv[i]);
      } else
      if (0 == wcscmp (pwc, L"-restart"))
      {
        iRestartOption = SEPIA2_RESTART;
        printf ("    %S\n", argv[i]);
      } else
      {
        printf ("    %S : unknown parameter!\n", argv[i]);
      }
    }
    else
    {
      char* pc = (char*)&(argv[i][0]); 
      if (0 == strncmp (pc, "-inst=", 6))
      {
        iGivenDevIdx = atoi (&(pc[6]));
        printf ("    -inst=%d\n", iGivenDevIdx);
        bUSBInstGiven = true;
      } else
      if (0 == strncmp (pc, "-serial=", 8))
      {
        strcpy_s (cGivenSerNo, SEPIA2_SERIALNUMBER_LEN, &argv[i][8]);
        printf ("    -serial=%s\n", &argv[i][8]);
        bSerialGiven = (strlen (cGivenSerNo) > 0);
      } else
      if (0 == strncmp (pc, "-product=", 9))
      {
        strcpy_s (cGivenProduct, SEPIA2_PRODUCTMODEL_LEN, &argv[i][9]);
        printf ("    -product=%s\n", &argv[i][9]);
        bProductGiven = (strlen (cGivenProduct) > 0);
      } else
      if (0 == strcmp (pc, "-stayopened"))
      {
        bStayOpened = true;
        printf ("    %s\n", argv[i]);
      } else
      if (0 == strcmp (pc, "-nowait"))
      {
        bNoWait = true;
        printf ("    %s\n", argv[i]);
      } else
      if (0 == strcmp (pc, "-restart"))
      {
        iRestartOption = SEPIA2_RESTART;
        printf ("    %s\n", argv[i]);
      } else
      {
        printf ("    %s : unknown parameter!\n", argv[i]);
      }
    }
  }

  printf ("\n\n     PQLaserDrv   Read ALL Values Demo : \n");
  printf ("    =================================================\n\n");
  //
  // preliminaries: check library version
  //
  SEPIA2_LIB_GetVersion (cLibVersion);
  printf ("     Lib-Version    = %s\n", cLibVersion);

  if (0 != strncmp (cLibVersion, LIB_VERSION_REFERENCE, LIB_VERSION_REFERENCE_COMPLEN))
  {
    printf ("\n     Warning: This demo application was built for version  %s!\n", LIB_VERSION_REFERENCE);
    printf ("              Continuing may cause unpredictable results!\n");
    printf ("\n     Do you want to continue anyway? (y/n): ");

    c = getchar();
    if ((c != 'y') && (c != 'Y'))
    {
      exit (-1);
    }
    while ((c = getchar()) != 0x0A ); // reject userinput 'til end of line
    printf ("\n");
  }
  //
  // establish USB connection to the sepia first matching all given conditions
  //
  for (i = (bUSBInstGiven ? iGivenDevIdx : 0); i < (bUSBInstGiven ? iGivenDevIdx+1 : SEPIA2_MAX_USB_DEVICES); i++)
  {
    strcpy_s (cSepiaSerNo,   SEPIA2_SERIALNUMBER_LEN, "");
    strcpy_s (cProductModel, SEPIA2_PRODUCTMODEL_LEN, "");
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
      iDevIdx = bUSBInstGiven ? ((iGivenDevIdx == i) ? i : -1) : i;
      break;
    }
  }
  //
  if ((iRetVal = SEPIA2_USB_OpenDevice (iDevIdx, cProductModel, cSepiaSerNo)) == SEPIA2_ERR_NO_ERROR)
  {
    printf ("     Product Model  = '%s'\n\n",     cProductModel);
    printf ("    =================================================\n\n");
    SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion);
    printf ("     FW-Version     = %s\n",     cFWVersion);
    //
    printf ("     USB Index      = %d\n", iDevIdx);
    SEPIA2_USB_GetStrDescriptor  (iDevIdx, cDescriptor);
    printf ("     USB Descriptor = %s\n", cDescriptor);
    printf ("     Serial Number  = '%s'\n\n", cSepiaSerNo);
    printf ("    =================================================\n\n");
    //
    // get sepia's module map and initialise datastructures for all library functions
    // there are two different ways to do so:
    //
    // first:  if sepia was not touched since last power on, it doesn't need to be restarted
    //         iRestartOption = SEPIA2_NO_RESTART;
    // second: in case of changes with soft restart
    //         iRestartOption = SEPIA2_RESTART;
    //
    if ((iRetVal = SEPIA2_FWR_GetModuleMap (iDevIdx, iRestartOption, &iModuleCount)) == SEPIA2_ERR_NO_ERROR)
    {
      //
      // this is to inform us about possible error conditions during sepia's last startup
      //
      if ((iRetVal = SEPIA2_FWR_GetLastError (iDevIdx, &iFWErrCode, &iFWErrPhase, &iFWErrLocation, &iFWErrSlot, cFWErrCond)) == SEPIA2_ERR_NO_ERROR)
      {
        if (iFWErrCode != SEPIA2_ERR_NO_ERROR)
        {
          SEPIA2_LIB_DecodeError  (iFWErrCode,  cErrString);
          SEPIA2_FWR_DecodeErrPhaseName (iFWErrPhase, cFWErrPhase);
          printf ("     Error detected by firmware on last restart:\n");
          printf ("        error code      : %5d,   i.e. '%s'\n", iFWErrCode,  cErrString);
          printf ("        error phase     : %5d,   i.e. '%s'\n", iFWErrPhase, cFWErrPhase);
          printf ("        error location  : %5d\n",  iFWErrLocation);
          printf ("        error slot      : %5d\n",  iFWErrSlot);
          if (strlen (cFWErrCond) > 0)
          {
            printf ("        error condition : '%s'\n", cFWErrCond);
          }
        }
        else
        {
          // just to show, what sepia2_lib knows about your system, try this:
          SEPIA2_FWR_CreateSupportRequestText (iDevIdx, cPreamble, cCallingSW, 0, sizeof (cBuffer), cBuffer);
          //
          // for console output, we have to change the degree-character:
          for (i=0; i < (int)strlen (cBuffer); i++)
          {
            if (cBuffer[i] == '°')
            {
              cBuffer[i] = '\xF8';
            }
          }
          printf (cBuffer);
          //
          // scan sepia map module by module
          // and iterate by iMapIdx for this approach.
          //
          printf ("\n\n\n    =================================================\n\n\n\n");
          //
          for (iMapIdx = 0; iMapIdx < iModuleCount; iMapIdx++)
          {
            SEPIA2_FWR_GetModuleInfoByMapIdx (iDevIdx, iMapIdx, &iSlotId, &bIsPrimary, &bIsBackPlane, &bHasUptimeCounter);
            //
            if (bIsBackPlane)
            {
              if ((iRetVal = SEPIA2_COM_GetModuleType (iDevIdx, -1, SEPIA2_PRIMARY_MODULE, &iModuleType)) == SEPIA2_ERR_NO_ERROR)
              {
                SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                SEPIA2_COM_GetSerialNumber  (iDevIdx, -1, SEPIA2_PRIMARY_MODULE, cSerialNumber);
                printf (" backplane:   module type     '%s'\n", cModulType);
                printf ("              serial number   '%s'\n\n", cSerialNumber);
              }
            }
            else 
            {
              //
              // identify sepiaobject (module) in slot
              //
              if ((iRetVal = SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, SEPIA2_PRIMARY_MODULE, &iModuleType)) == SEPIA2_ERR_NO_ERROR)
              {
                SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                SEPIA2_COM_GetSerialNumber  (iDevIdx, iSlotId, SEPIA2_PRIMARY_MODULE, cSerialNumber);
                printf (" slot %3.3d :   module type     '%s'\n", iSlotId, cModulType);
                printf ("              serial number   '%s'\n\n", cSerialNumber);
                //
                // now, continue with modulespecific information
                //
                switch (iModuleType)
                {
                  case SEPIA2OBJECT_SCM  :
                    SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId, &bSLock);
                    SEPIA2_SCM_GetLaserLocked   (iDevIdx, iSlotId, &bLock);
                    printf ("                              laser lock state   :    %slocked\n", (!(bLock || bSLock)? " un": (bLock != bSLock ? " hard" : " soft")));
                    printf ("\n");
                    //
                    break;


                  case SEPIA2OBJECT_SOM  :
                  case SEPIA2OBJECT_SOMD :
                    for (iFreqTrigIdx = 0; ((iRetVal == SEPIA2_ERR_NO_ERROR) && (iFreqTrigIdx < SEPIA2_SOM_FREQ_TRIGMODE_COUNT)); iFreqTrigIdx++)
                    {
                      if (iModuleType == SEPIA2OBJECT_SOM)
                      {
                        iRetVal = SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                      }
                      else
                      {
                        iRetVal = SEPIA2_SOMD_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                      }
                      if (iRetVal == SEPIA2_ERR_NO_ERROR)
                      {
                        if (iFreqTrigIdx == 0)
                        {
                          printf ("%46s", "freq./trigmodes ");
                        }
                        else
                        {
                          printf ("%46s", "                ");
                        }
                        //
                        printf ("%1d) =     '%s'", iFreqTrigIdx+1, cFreqTrigMode);
                        //
                        if (iFreqTrigIdx == (SEPIA2_SOM_FREQ_TRIGMODE_COUNT-1))
                        {
                          printf ("\n");
                        }
                        else
                        {
                          printf (",\n");
                        }
                      }
                    }
                    printf ("\n");
                    if (iRetVal == SEPIA2_ERR_NO_ERROR)
                    {
                      if (iModuleType == SEPIA2OBJECT_SOM)
                      {
                        iRetVal = SEPIA2_SOM_GetFreqTrigMode (iDevIdx, iSlotId, &iFreqTrigIdx);
                      }
                      else
                      {
                        iRetVal = SEPIA2_SOMD_GetFreqTrigMode (iDevIdx, iSlotId, &iFreqTrigIdx, &bSynchronize);
                      }
                      if (iRetVal == SEPIA2_ERR_NO_ERROR)
                      {
                        if (iModuleType == SEPIA2OBJECT_SOM)
                        {
                          iRetVal = SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                        }
                        else
                        {
                          iRetVal = SEPIA2_SOMD_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                        }
                        if (iRetVal == SEPIA2_ERR_NO_ERROR)
                        {
                          printf ("%47s  =     '%s'\n", "act. freq./trigm.", cFreqTrigMode);
                          if ((iModuleType == SEPIA2OBJECT_SOMD) && (iFreqTrigIdx < SEPIA2_SOM_INT_OSC_A))
                          {
                            if (bSynchronize)
                            {
                              printf ("%47s        (synchronized,)\n", " ");
                            }
                          }
                          //
                          if (iModuleType == SEPIA2OBJECT_SOM)
                          {
                            iRetVal = SEPIA2_SOM_GetBurstValues (iDevIdx, iSlotId, &bDivider, &bPreSync, &bMaskSync);
                            wDivider = bDivider;
                          }
                          else
                          {
                            iRetVal = SEPIA2_SOMD_GetBurstValues (iDevIdx, iSlotId, &wDivider, &bPreSync, &bMaskSync);
                          }
                          if (iRetVal == SEPIA2_ERR_NO_ERROR)
                          {
                            printf ("%48s = %5d\n", "divider           ", wDivider);
                            printf ("%48s = %5d\n", "pre sync          ", bPreSync);
                            printf ("%48s = %5d\n", "masked sync pulses", bMaskSync);
                            //
                            if ( (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_RISING)
                              || (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_FALLING))
                            {
                              if (iModuleType == SEPIA2OBJECT_SOM)
                              {
                                iRetVal = SEPIA2_SOM_GetTriggerLevel (iDevIdx, iSlotId, &iTriggerMilliVolt);
                              }
                              else
                              {
                                iRetVal = SEPIA2_SOMD_GetTriggerLevel (iDevIdx, iSlotId, &iTriggerMilliVolt);
                              }
                              if (iRetVal == SEPIA2_ERR_NO_ERROR)
                              {
                                printf ("%47s  = %5d mV\n", "triggerlevel     ", iTriggerMilliVolt);
                              }
                            }
                            else
                            {
                              fFrequency  = (float)(atof(cFreqTrigMode)) * 1.0e6f;
                              fFrequency /= wDivider;
                              printf ("%47s  =  %s\n", "oscillator period", FormatEng (cTemp1, sizeof (cTemp1), 1.0 / fFrequency, 6, "s",  11, 3));
                              printf ("%47s     %s\n", "i.e.",              FormatEng (cTemp1, sizeof (cTemp1), fFrequency,       6, "Hz", 12, 3));
                              printf ("\n");
                            }
                            if (iRetVal == SEPIA2_ERR_NO_ERROR)
                            {
                              if (iModuleType == SEPIA2OBJECT_SOM)
                              {
                                iRetVal = SEPIA2_SOM_GetOutNSyncEnable (iDevIdx, iSlotId, &bOutEnable, &bSyncEnable, &bSyncInverse);
                              }
                              else
                              {
                                iRetVal = SEPIA2_SOMD_GetOutNSyncEnable (iDevIdx, iSlotId, &bOutEnable, &bSyncEnable, &bSyncInverse);
                              }
                              if (iRetVal == SEPIA2_ERR_NO_ERROR)
                              {
                                printf ("%47s  =     %s\n\n", "sync mask form   ", (bSyncInverse ? "inverse" : "regular"));
                                if (iModuleType == SEPIA2OBJECT_SOM)
                                {
                                  iRetVal = SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSlotId, &lBurstChannels[0], &lBurstChannels[1], &lBurstChannels[2], &lBurstChannels[3], &lBurstChannels[4], &lBurstChannels[5], &lBurstChannels[6], &lBurstChannels[7]);
                                }
                                else
                                {
                                  iRetVal = SEPIA2_SOMD_GetBurstLengthArray (iDevIdx, iSlotId, &lBurstChannels[0], &lBurstChannels[1], &lBurstChannels[2], &lBurstChannels[3], &lBurstChannels[4], &lBurstChannels[5], &lBurstChannels[6], &lBurstChannels[7]);
                                }
                                if (iRetVal == SEPIA2_ERR_NO_ERROR)
                                {
                                  printf ("%44s ch. | sync | burst len |  out\n", "burst data    ");
                                  printf ("%44s-----+------+-----------+------\n", " ");
                                  //
                                  for (i = 0, lBurstSum = 0; i < SEPIA2_SOM_BURSTCHANNEL_COUNT; i++)
                                  {
                                    printf ("%46s%1d  |    %1d | %9d |    %1d\n", " ", i+1, ((bSyncEnable >> i) & 1), lBurstChannels[i], ((bOutEnable >> i) & 1));
                                    lBurstSum += lBurstChannels[i];
                                  }
                                  printf ("%41s--------+------+ +  -------+------\n", " ");
                                  printf ("%41sHex/Sum | 0x%2.2X | =%8d | 0x%2.2X\n", " ", bSyncEnable, lBurstSum, bOutEnable);
                                  printf ("\n");
                                  if ( (iFreqTrigIdx != SEPIA2_SOM_TRIGMODE_RISING)
                                    && (iFreqTrigIdx != SEPIA2_SOM_TRIGMODE_FALLING))
                                  {
                                    fFrequency /= lBurstSum;
                                    printf ("%47s  =  %s\n", "sequencer period",  FormatEng (cTemp1, sizeof (cTemp1), 1.0 / fFrequency, 6, "s",  11, 3));
                                    printf ("%47s     %s\n", "i.e.",              FormatEng (cTemp1, sizeof (cTemp1), fFrequency,       6, "Hz", 12, 3));
                                    printf ("\n");
                                  }
                                  if (iModuleType == SEPIA2OBJECT_SOMD)
                                  {
                                    iRetVal = SEPIA2_SOMD_GetDelayUnits (iDevIdx, iSlotId, &f64CoarseDelayStep, &bFineDelayStepCount);
                                    printf ("%44s     | combiner |\n", " ");
                                    printf ("%44s     | channels |\n", " ");
                                    printf ("%44s out | 12345678 | delay\n", " ");
                                    printf ("%44s-----+----------+------------------\n", " ");
                                    for (j = 0; j < SEPIA2_SOM_BURSTCHANNEL_COUNT; j++)
                                    {
                                      iRetVal = SEPIA2_SOMD_GetSeqOutputInfos (iDevIdx, iSlotId, j, &bDelayed, &bForcedUndelayed, &bOutCombi, &bMaskedCombi, &f64CoarseDelay, &bFineDelay);
                                      if (!bDelayed | bForcedUndelayed)
                                      {
                                        printf ("%46s%1d  | %s |\n", " ", j+1, IntToBin (cTemp1, sizeof (cTemp1), bOutCombi, SEPIA2_SOM_BURSTCHANNEL_COUNT, true, bMaskedCombi ? '1' : 'B', '_') );
                                      }
                                      else
                                      {
                                        printf ("%46s%1d  | %s |%s + %2da.u.\n", " ", j+1, IntToBin (cTemp1, sizeof (cTemp1), (1 << j), SEPIA2_SOM_BURSTCHANNEL_COUNT, true, 'D', '_'), FormatEng (cTemp2, sizeof (cTemp2), f64CoarseDelay * 1e-9, 4, "s", 9, 1, 0), bFineDelay);
                                      }
                                    }
                                    printf ("\n");
                                    printf ("%46s   = D: delayed burst,   no combi\n",   "combiner legend ");
                                    printf ("%46s     B: combi burst, any non-zero\n",   " ");
                                    printf ("%46s     1: 1st pulse,   any non-zero\n\n", " ");
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    break;


                  case SEPIA2OBJECT_SLM  :

                    if ((iRetVal = SEPIA2_SLM_GetPulseParameters (iDevIdx, iSlotId,  &iFreqTrigIdx, &bPulseMode, &iHead)) == SEPIA2_ERR_NO_ERROR)
                    {
                      SEPIA2_SLM_DecodeFreqTrigMode (iFreqTrigIdx, cFrequency);
                      SEPIA2_SLM_DecodeHeadType     (iHead, cHeadType);
                      //
                      printf ("%47s  =     '%s'\n",        "freq / trigmode  ", cFrequency);
                      printf ("%47s  =     'pulses %s'\n", "pulsmode         ", (bPulseMode ? "enabled" : "disabled"));
                      printf ("%47s  =     '%s'\n",        "headtype         ", cHeadType);
                    }
                    if ((iRetVal = SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSlotId, &wIntensity)) == SEPIA2_ERR_NO_ERROR)
                    {
                      printf ("%47s  =   %5.1f%%\n",     "intensity        ", 0.1*wIntensity);
                    }
                    printf ("\n");
                    break;


                  case SEPIA2OBJECT_SML  :
                    if ((iRetVal = SEPIA2_SML_GetParameters (iDevIdx, iSlotId, &bPulseMode, &iHead, &bIntensity)) == SEPIA2_ERR_NO_ERROR)
                    {
                      SEPIA2_SML_DecodeHeadType     (iHead, cHeadType);
                      //
                      printf ("%47s  =     pulses %s\n", "pulsmode         ", (bPulseMode ? "enabled" : "disabled"));
                      printf ("%47s  =     %s\n",        "headtype         ", cHeadType);
                      printf ("%47s  =   %3d%%\n",        "intensity        ", bIntensity);
                      printf ("\n");
                    }
                    break;


                  case SEPIA2OBJECT_SPM  :
                    if ((iRetVal = SEPIA2_SPM_GetFWVersion (iDevIdx, iSlotId, &SWSFWVers.ul)) == SEPIA2_ERR_NO_ERROR)
                    {
                      printf ("%47s  =     %d.%d.%d\n", "firmware version ", SWSFWVers.v.VersMaj, SWSFWVers.v.VersMin, SWSFWVers.v.BuildNr);
                    }
                    break;


                  case SEPIA2OBJECT_SWS  :
                    if ((iRetVal = SEPIA2_SWS_GetFWVersion (iDevIdx, iSlotId, &SWSFWVers.ul)) == SEPIA2_ERR_NO_ERROR)
                    {
                      printf ("%47s  =     %d.%d.%d\n", "firmware version ", SWSFWVers.v.VersMaj, SWSFWVers.v.VersMin, SWSFWVers.v.BuildNr);
                    }
                    if ((iRetVal = SEPIA2_SWS_GetModuleType (iDevIdx, iSlotId, &iSWSModuleType)) == SEPIA2_ERR_NO_ERROR)
                    {
                      SEPIA2_SWS_DecodeModuleType (iSWSModuleType, cSWSModuleType);
                      printf ("%47s  =     %s\n",       "SWS module type ", cSWSModuleType);
                    }
                    if ((iRetVal = SEPIA2_SWS_GetParameters (iDevIdx, iSlotId, &ulWaveLength, &ulBandWidth)) == SEPIA2_ERR_NO_ERROR)
                    {
                      //
                      printf ("%47s  =  %8.3f nm \n",    "wavelength       ", 0.001 * ulWaveLength);
                      printf ("%47s  =  %8.3f nm \n",    "bandwidth        ", 0.001 * ulBandWidth);
                      printf ("\n");
                    }
                    if ((iRetVal = SEPIA2_SWS_GetIntensity (iDevIdx, iSlotId, &ulIntensRaw, &fIntensity)) == SEPIA2_ERR_NO_ERROR)
                    {
                      printf ("%47s  = 0x%4.4X a.u. i.e. ~ %.1fnA\n",    "power diode      ", ulIntensRaw, fIntensity);
                      printf ("\n");
                    }
                    if ((iRetVal = SEPIA2_SWS_GetBeamPos (iDevIdx, iSlotId, &sBeamVPos, &sBeamHPos)) == SEPIA2_ERR_NO_ERROR)
                    {
                      printf ("%47s  =   %3d steps\n",    "horiz. beamshift ", sBeamHPos);
                      printf ("%47s  =   %3d steps\n",    "vert.  beamshift ", sBeamVPos);
                      printf ("\n");
                    }
                    break;


                  case SEPIA2OBJECT_SSM  :
                    if ((iRetVal = SEPIA2_SSM_GetTriggerData (iDevIdx, iSlotId, &iFreqTrigIdx, &iTriggerMilliVolt)) == SEPIA2_ERR_NO_ERROR)
                    {
                      //
                      SEPIA2_SSM_DecodeFreqTrigMode    (iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode, &iFreq, &bTrigLevelEnabled);
                      printf ("%47s  =     '%s'\n", "act. freq./trigm.", cFreqTrigMode);
                      if (bTrigLevelEnabled != 0)
                      {
                        printf ("%47s  = %5d mV\n", "triggerlevel     ", iTriggerMilliVolt);
                      }
                    }
                    break;


                  case SEPIA2OBJECT_SWM  :
                    if ((iRetVal = SEPIA2_SWM_GetCurveParams (iDevIdx, iSlotId, 1, &bTBNdx, &wPAPml, &wRRPml, &wPSPml, &wRSPml, &wWSPml)) == SEPIA2_ERR_NO_ERROR)
                    {
                      printf ("%47s\n",                "Curve 1:         ");
                      printf ("%47s  =   %3d%\n",      "TBNdx            ", bTBNdx);
                      printf ("%47s  =  %6.1f%%\n",    "PAPml            ", 0.1 * wPAPml);
                      printf ("%47s  =  %6.1f%%\n",    "RRPml            ", 0.1 * wRRPml);
                      printf ("%47s  =  %6.1f%%\n",    "PSPml            ", 0.1 * wPSPml);
                      printf ("%47s  =  %6.1f%%\n",    "RSPml            ", 0.1 * wRSPml);
                      printf ("%47s  =  %6.1f%%\n",    "WSPml            ", 0.1 * wWSPml);
                    }
                    if ((iRetVal = SEPIA2_SWM_GetCurveParams (iDevIdx, iSlotId, 2, &bTBNdx, &wPAPml, &wRRPml, &wPSPml, &wRSPml, &wWSPml)) == SEPIA2_ERR_NO_ERROR)
                    {
                      printf ("%47s\n",                "Curve 2:         ");
                      printf ("%47s  =   %3d%\n",      "TBNdx            ", bTBNdx);
                      printf ("%47s  =  %6.1f%%\n",    "PAPml            ", 0.1 * wPAPml);
                      printf ("%47s  =  %6.1f%%\n",    "RRPml            ", 0.1 * wRRPml);
                      printf ("%47s  =  %6.1f%%\n",    "PSPml            ", 0.1 * wPSPml);
                      printf ("%47s  =  %6.1f%%\n",    "RSPml            ", 0.1 * wRSPml);
                      printf ("%47s  =  %6.1f%%\n",    "WSPml            ", 0.1 * wWSPml);
                    }
                    break;


                  default : break;
                }
              }
            }
            //
            if (iRetVal == SEPIA2_ERR_NO_ERROR)
            {
              //
              if (!bIsPrimary)
              {
                if ((iRetVal = SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, SEPIA2_SECONDARY_MODULE, &iModuleType)) == SEPIA2_ERR_NO_ERROR)
                {
                  SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                  SEPIA2_COM_GetSerialNumber  (iDevIdx, iSlotId, SEPIA2_SECONDARY_MODULE, cSerialNumber);
                  printf ("\n              secondary mod.  '%s'\n", cModulType);
                  printf ("              serial number   '%s'\n\n", cSerialNumber);
                }
              }
              //
              if (bHasUptimeCounter)
              {
                SEPIA2_FWR_GetUptimeInfoByMapIdx (iDevIdx, iMapIdx, &ulMainPowerUp, &ulActivePowerUp, &ulScaledPowerUp);
                PrintUptimers (ulMainPowerUp, ulActivePowerUp, ulScaledPowerUp);
              }
            }
          }
        }
      }
    } // get module map
    else
    {
      SEPIA2_LIB_DecodeError (iRetVal, cErrString);
      printf ("     ERROR %5d:    '%s'\n\n", iRetVal, cErrString);
      if ((iRetVal = SEPIA2_FWR_GetLastError (iDevIdx, &iFWErrCode, &iFWErrPhase, &iFWErrLocation, &iFWErrSlot, cFWErrCond)) == SEPIA2_ERR_NO_ERROR)
      {
        if (iFWErrCode != SEPIA2_ERR_NO_ERROR)
        {
          SEPIA2_LIB_DecodeError  (iFWErrCode,  cErrString);
          SEPIA2_FWR_DecodeErrPhaseName (iFWErrPhase, cFWErrPhase);
          printf ("     Firmware error detected:\n");
          printf ("        error code      : %5d,   i.e. '%s'\n", iFWErrCode,  cErrString);
          printf ("        error phase     : %5d,   i.e. '%s'\n", iFWErrPhase, cFWErrPhase);
          printf ("        error location  : %5d\n",  iFWErrLocation);
          printf ("        error slot      : %5d\n",  iFWErrSlot);
          if (strlen (cFWErrCond) > 0)
          {
            printf ("        error condition : '%s'\n", cFWErrCond);
          }
        }
      }
    }

    //
    SEPIA2_FWR_FreeModuleMap (iDevIdx);
    if (bStayOpened)
    {
      printf ("\npress RETURN to close Sepia... ");
      getchar ();
    }
    SEPIA2_USB_CloseDevice   (iDevIdx);
  }
  else
  {
    SEPIA2_LIB_DecodeError (iRetVal, cErrString);
    printf ("     ERROR %5d:    '%s'\n\n", iRetVal, cErrString);
  }

  printf ("\n");
  //

  if (!bNoWait)
  {
    printf ("\npress RETURN... ");
    getchar ();
  }
  return iRetVal;
}
