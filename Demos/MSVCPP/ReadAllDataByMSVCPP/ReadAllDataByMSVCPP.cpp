//-----------------------------------------------------------------------------
//
//      ReadAllDatabyMSVCPP.cpp
//
//-----------------------------------------------------------------------------
//
//  Illustrates the functions exported by SEPIA2_Lib
//  Scans the whole PQLaserDrv rack and displays all relevant data
//
//-----------------------------------------------------------------------------
//  HISTORY:
//
//  apo  22.12.05   release of the library interface
//
//  apo  25.01.06   release of the DLL interface
//
//  apo  12.02.07   introduced SML Multilaser Module (V1.0.2.0)
//
//  apo  05.02.14   introduced new map oriented API functions (V1.0.3.282)
//
//  apo  26.02.14   raised library version to 1.1 due to API changes
//                    on the device open interfaces
//                    (new parameter strProductModel)
//                  encoded bitwidth of target architecture into
//                    version field 'MinorHighWord', e.g.:
//                    V1.1.32.293 or V1.1.64.293, respectively
//
//-----------------------------------------------------------------------------
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

extern "C"
{
  #include "portabt.h"
  #include "Sepia2_Def.h"
  #include "Sepia2_Lib.h"
  #include "Sepia2_ErrorCodes.h"
}

void PrintUptimers (unsigned long ulMainPowerUp, unsigned long ulActivePowerUp, unsigned long ulScaledPowerUp)
{
  int hh, mm, hlp;
  //
  hlp = (int)(5.0 * (ulMainPowerUp + 0x7F) / 0xFF);
  mm  = hlp % 60; hh  = hlp / 60;
  printf ("\n");
  printf ("%47s  =    %2.2d:%2.2d hrs\n",  "main power uptime",   hh, mm);
  //
  if (ulActivePowerUp > 1)
  {
    hlp = (int)(5.0 * (ulActivePowerUp + 0x7F) / 0xFF);
    mm  = hlp % 60; hh  = hlp / 60;
    printf ("%47s  =    %2.2d:%2.2d hrs\n",  "act. power uptime", hh, mm);
    //
    if (ulScaledPowerUp > (0.001 * ulActivePowerUp))
    {
      printf ("%47s  =       %5.1f%%\n\n",  "pwr scaled factor", 100.0 * ulScaledPowerUp / ulActivePowerUp);
    }
  }
  printf ("\n");
}



int main (int argc, char* argv[])
{
  int             iRetVal        = SEPIA2_ERR_NO_ERROR;
  char            c;
  //
  char            cLibVersion    [SEPIA2_VERSIONINFO_LEN]        = "";
  char            cDescriptor    [SEPIA2_USB_STRDECR_LEN]        = "";
  char            cSepiaSerNo    [SEPIA2_SERIALNUMBER_LEN]       = "";
  char            cProductModel  [SEPIA2_PRODUCTMODEL_LEN]       = "";
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
  //
  long            lBurstChannels [SEPIA2_SOM_BURSTCHANNEL_COUNT] = {0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L};
  //
  int             iRestartOption                                 = SEPIA2_NO_RESTART;
  int             iDevIdx                                        = 0;
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
  unsigned char   bNoWait = false;
  unsigned char   bStayOpened = false;
  unsigned char   bInteractive = false;
  unsigned char   bIsPrimary;
  unsigned char   bIsBackPlane;
  unsigned char   bHasUptimeCounter;
  unsigned char   bLock;
  unsigned char   bSLock;
  unsigned char   bPulseMode;
  unsigned char   bDivider;
  unsigned char   bPreSync;
  unsigned char   bMaskSync;
  unsigned char   bOutEnable;
  unsigned char   bSyncEnable;
  unsigned char   bSyncInverse;
  unsigned char   bTrigLevelEnabled;
  unsigned char   bIntensity;
  //
  // word
  unsigned short  wIntensity;
  unsigned short  wDivider;
  //
  unsigned char   bTBNdx;
  unsigned short  wPAPml;
  unsigned short  wRRPml;
  unsigned short  wPSPml;
  unsigned short  wRSPml; 
  unsigned short  wWSPml;
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
  T_Module_FWVers SWSFWVers;
  //
  int i;
  //
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
        iDevIdx = _wtoi (&(pwc[6]));
        printf ("    -inst=%d\n", iDevIdx);
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
      if (0 == wcscmp (pwc, L"-interactive"))
      {
        bInteractive = true;
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
        iDevIdx = atoi (&(pc[6]));
        printf ("    -inst=%d\n", iDevIdx);
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
      if (0 == strcmp (pc, "-interactive"))
      {
        bInteractive = true;
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
  printf ("     Lib-Version   = %s\n", cLibVersion);

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
  // establish USB connection to sepia
  //
  if ((iRetVal = SEPIA2_USB_OpenDevice (iDevIdx, cProductModel, cSepiaSerNo)) == SEPIA2_ERR_NO_ERROR)
  {
    printf ("     Product Model = %s\n\n",     cProductModel);
    printf ("    =================================================\n\n");
    SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion);
    printf ("     FW-Version    = %s\n",     cFWVersion);
    //
    SEPIA2_USB_GetStrDescriptor  (iDevIdx, cDescriptor);
    printf ("     Descriptor    = %s\n", cDescriptor);
    printf ("     Serial Number = '%s'\n\n", cSepiaSerNo);
    printf ("    =================================================\n\n\n");
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
          //
          // scan sepia map module by module
          //
          printf ("\n\n");
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
                  case SEPIA2OBJECT_SCX  :
                    //
                    SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId, &bSLock);
                    printf ("                              laser softlock status : %slocked\n", (!bSLock? " un":" "));
                    //
                    SEPIA2_SCM_GetLaserLocked   (iDevIdx, iSlotId, &bLock);
                    printf ("                              laser     lock status : %slocked\n", (!bLock?  " un":" "));
                    //
                    // lock / softlock demonstration
                    //
                    // for the soft lock state,
                    //   this demonstration should always produce the sequence "unlocked", "locked", "unlocked"
                    //
                    // for the lock state, (if inquired after a little time)
                    //   the demonstration should produce threetimes "locked", if sepia is locked by key and
                    //   the sequence "unlocked", "locked", "unlocked" else.
                    //   if called too early, the function retrieves the "old" value which was previously set.
                    //
                    if (bInteractive)
                    {
                      printf ("\n\npress RETURN...\n");
                      getchar ();
                      //
                      SEPIA2_SCM_SetLaserSoftLock (iDevIdx, iSlotId, SEPIA2_LASER_LOCKED);
                      SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId, &bSLock);
                      printf ("                              laser softlock status : %slocked\n", (!bSLock? " un":" "));
                      //
                      Sleep (100);
                      SEPIA2_SCM_GetLaserLocked   (iDevIdx, iSlotId, &bLock);
                      printf ("                              laser     lock status : %slocked\n", (!bLock?  " un":" "));
                      printf ("\n\npress RETURN...\n");
                      getchar ();
                      //
                      SEPIA2_SCM_SetLaserSoftLock (iDevIdx, iSlotId, SEPIA2_LASER_UNLOCKED);
                      SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId, &bSLock);
                      printf ("                              laser softlock status : %slocked\n", (!bSLock? " un":" "));
                      //
                      Sleep (100);
                      SEPIA2_SCM_GetLaserLocked   (iDevIdx, iSlotId, &bLock);
                      printf ("                              laser     lock status : %slocked\n", (!bLock?  " un":" "));
                      printf ("\n\npress RETURN...\n");
                      getchar ();
                    }
                    printf ("\n");
                    //
                    break;


                  case SEPIA2OBJECT_SOM  :
                  case SEPIA2OBJECT_SOMD :
                    for (iFreqTrigIdx = 0; ((iRetVal == SEPIA2_ERR_NO_ERROR) && (iFreqTrigIdx < SEPIA2_SOM_FREQ_TRIGMODE_COUNT)); iFreqTrigIdx++)
                    {
                      iRetVal = SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
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
                      if ((iRetVal = SEPIA2_SOM_GetFreqTrigMode (iDevIdx, iSlotId, &iFreqTrigIdx)) == SEPIA2_ERR_NO_ERROR)
                      {
                        if ((iRetVal = SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode)) == SEPIA2_ERR_NO_ERROR)
                        {
                          printf ("%47s  =     '%s'\n", "act. freq./trigm.", cFreqTrigMode);
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
                            if ( (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_RAISING)
                              || (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_FALLING))
                            {
                              if ((iRetVal = SEPIA2_SOM_GetTriggerLevel (iDevIdx, iSlotId, &iTriggerMilliVolt)) == SEPIA2_ERR_NO_ERROR)
                              {
                                printf ("%47s  = %5d mV\n", "triggerlevel     ", iTriggerMilliVolt);
                              }
                            }
                            else
                            {
                              fFrequency  = (float)(atof(cFreqTrigMode)) * 1.0e6f;
                              fFrequency /= bDivider;
                              printf ("%47s  =    %11.3e msec\n", "oscillator period", 1000. / fFrequency);
                              printf ("%50s    %11.3e kHz\n",      "i.e.",              fFrequency / 1000.);
                              printf ("\n");
                            }
                            if (iRetVal == SEPIA2_ERR_NO_ERROR)
                            {
                              if ((iRetVal = SEPIA2_SOM_GetOutNSyncEnable (iDevIdx, iSlotId, &bOutEnable, &bSyncEnable, &bSyncInverse)) == SEPIA2_ERR_NO_ERROR)
                              {
                                printf ("%47s  =     %s\n\n", "sync mask form   ", (bSyncInverse ? "inverse" : "regular"));
                                if (SEPIA2_ERR_NO_ERROR == (iRetVal = SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSlotId, 
                                                                                                      &lBurstChannels[0], 
                                                                                                      &lBurstChannels[1], 
                                                                                                      &lBurstChannels[2], 
                                                                                                      &lBurstChannels[3], 
                                                                                                      &lBurstChannels[4], 
                                                                                                      &lBurstChannels[5], 
                                                                                                      &lBurstChannels[6], 
                                                                                                      &lBurstChannels[7])))
                                {
                                  printf ("                              burst data     ch. |  out | burst len | sync\n");
                                  printf ("                                            -----+------+-----------+------\n");
                                  //
                                  for (i = 0, lBurstSum = 0; i < 8; i++)
                                  {
                                    printf ("%46s%1d  |    %1d | %9d |    %1d\n", " ", i+1, ((bOutEnable >> i) & 1), lBurstChannels[i], ((bSyncEnable >> i) & 1));
                                    lBurstSum += lBurstChannels[i];
                                  }
                                  printf ("                                         --------+------+ += -------+------\n");
                                  printf ("%41sHex/Sum | 0x%2.2X | %9d | 0x%2.2X\n", " ", bOutEnable, lBurstSum, bSyncEnable);
                                  printf ("\n");
                                }
                              }
                            }
                          }
                        }
                        if ( (iFreqTrigIdx != SEPIA2_SOM_TRIGMODE_RAISING)
                          && (iFreqTrigIdx != SEPIA2_SOM_TRIGMODE_FALLING))
                        {
                          fFrequency /= lBurstSum;
                          printf ("%47s  =    %11.3e msec\n", "sequencer period ", 1000. / fFrequency);
                          printf ("%50s    %11.3e kHz\n",      "i.e.",              fFrequency / 1000.);
                          printf ("\n");
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
                      printf ("%47s  =     '%s'\n",      "freq / trigmode  ", cFrequency);
                      printf ("%47s  =     pulses %s\n", "pulsmode         ", (bPulseMode ? "enabled" : "disabled"));
                      printf ("%47s  =     %s\n",        "headtype         ", cHeadType);
                    }
                    if ((iRetVal = SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSlotId, &wIntensity)) == SEPIA2_ERR_NO_ERROR)
                    {
                      printf ("%47s  =    %5.1f%%\n",     "intensity        ", 0.1*wIntensity);
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
                    printf ("\n");
                    break;


                  default : break;
                }
                //
                if (iRetVal == SEPIA2_ERR_NO_ERROR)
                {
                  //
                  if (bIsPrimary)
                  {
                    if (bHasUptimeCounter)
                    {
                      SEPIA2_FWR_GetUptimeInfoByMapIdx (iDevIdx, iMapIdx, &ulMainPowerUp, &ulActivePowerUp, &ulScaledPowerUp);
                      PrintUptimers (ulMainPowerUp, ulActivePowerUp, ulScaledPowerUp);
                    }
                  }
                  else
                  {
                    if ((iRetVal = SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, SEPIA2_SECONDARY_MODULE, &iModuleType)) == SEPIA2_ERR_NO_ERROR)
                    {
                      SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                      SEPIA2_COM_GetSerialNumber  (iDevIdx, iSlotId, SEPIA2_SECONDARY_MODULE, cSerialNumber);
                      printf ("\n              secondary mod.  '%s'\n", cModulType);
                      printf ("              serial number   '%s'\n\n", cSerialNumber);
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
            }
            if (iRetVal != SEPIA2_ERR_NO_ERROR)
            {
              if (iRetVal == SEPIA2_ERR_LIB_REFERENCED_SLOT_IS_NOT_IN_USE)
              {
                printf (" slot %3.3d :   empty\n\n", iSlotId);
                iRetVal = SEPIA2_ERR_NO_ERROR;
              }
              else
              {
                if (iRetVal == SEPIA2_ERR_LIB_ILLEGAL_SLOT_NUMBER)
                {
                  printf (" slot %3.3d :   n/a\n\n", iSlotId);
                  iRetVal = SEPIA2_ERR_NO_ERROR;
                }
                else
                {
                  SEPIA2_LIB_DecodeError (iRetVal, cErrString);
                  printf (" slot %3.3d :   ERROR %5d:    '%s'\n\n", iSlotId, iRetVal, cErrString);
                }                    
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
