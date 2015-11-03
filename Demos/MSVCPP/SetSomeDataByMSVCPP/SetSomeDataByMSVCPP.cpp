//-----------------------------------------------------------------------------
//
//      SetSomeDataByMSVCPP.cpp
//
//-----------------------------------------------------------------------------
//
//  Illustrates the functions exported by SEPIA2_Lib
//
//  Presumes to find a SOM 828 in slot 100 and a SLM 828 in slot 200
//
//  if there doesn't exist a file named "OrigData.txt"
//    creates the file to save the original values
//    then sets new values for SOM and SLM
//  else
//    sets original values for SOM and SLM from file and
//    deletes file.
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
//-----------------------------------------------------------------------------
//
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <string.h>

extern "C"
{
  #include "portabt.h"
  #include "Sepia2_Def.h"
  #include "Sepia2_Lib.h"
  #include "Sepia2_ErrorCodes.h"
}

// this is to suppress warning C4996: <function_name>: This function or variable may be unsafe.
#pragma warning( disable : 4996 )


int main(int argc, char* argv[])
{
  int             iRetVal        = SEPIA2_ERR_NO_ERROR;
  char            c;
  //
  struct _stat    buf;
  FILE*           f;
  //
  char            cLibVersion    [SEPIA2_VERSIONINFO_LEN]        = "";
  char            cSepiaSerNo    [SEPIA2_SERIALNUMBER_LEN]       = "";
  char            cGivenSerNo    [SEPIA2_SERIALNUMBER_LEN]       = "";
  char            cProductModel  [SEPIA2_PRODUCTMODEL_LEN]       = "";
  char            cGivenProduct  [SEPIA2_PRODUCTMODEL_LEN]       = "";
  char            cFWVersion     [SEPIA2_VERSIONINFO_LEN]        = "";
  char            cDescriptor    [SEPIA2_USB_STRDECR_LEN]        = "";
  char            cFWErrCond     [SEPIA2_FW_ERRCOND_LEN]         = "";
  char            cErrString     [SEPIA2_ERRSTRING_LEN]          = "";
  char            cFWErrPhase    [SEPIA2_FW_ERRPHASE_LEN]        = "";
  char            cFreqTrigMode  [SEPIA2_SOM_FREQ_TRIGMODE_LEN]  = "";
  char            cSOMType       [5]                             = "";
  char            cSLMType       [5]                             = "";
  char            cTemp          [1025];
  //
  long            lBurstChannels [SEPIA2_SOM_BURSTCHANNEL_COUNT] = {0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L};
  long            lTemp;
  //
  int             iSOM_Slot                                      = 100;
  int             iSLM_Slot                                      = 200;
  int             iDevIdx                                        =  -1;
  int             iGivenDevIdx;
  //
  //
  int             iModuleCount;
  int             iModuleType;
  int             iFWErrCode;
  int             iFWErrPhase;
  int             iFWErrLocation;
  int             iFWErrSlot;
  int             iFreqTrigIdx;
  int             iTemp1;
  int             iTemp2;
  int             iTemp3;
  int             iFreq;
  int             iHead;
  int             i;
  //
  // byte
  unsigned char   bUSBInstGiven = false;
  unsigned char   bSerialGiven  = false;
  unsigned char   bProductGiven = false;
  unsigned char   bIsSOMDModule;
  unsigned char   bExtTiggered;
  unsigned char   bDivider;
  unsigned char   bPreSync;
  unsigned char   bMaskSync;
  unsigned char   bOutEnable;
  unsigned char   bSyncEnable;
  unsigned char   bSyncInverse;
  unsigned char   bSynchronized;
  unsigned char   bPulseMode;
  //
  // word
  unsigned short  wIntensity;
  unsigned short  wDivider;
  //
  float           fIntensity;
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
      {
        printf ("    %s : unknown parameter!\n", argv[i]);
      }
    }
  }

  printf ("\n\n     PQLaserDrv   Set SOME Values Demo : \n");
  printf ("    =================================================\n\n\n");
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
  if ((iRetVal = SEPIA2_USB_OpenDevice (iDevIdx, cProductModel, cSepiaSerNo)) == SEPIA2_ERR_NO_ERROR)
  {
    SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion);
    printf ("     FW-Version    = %s\n",     cFWVersion);
    //
    SEPIA2_USB_GetStrDescriptor  (iDevIdx, cDescriptor);
    printf ("     Descriptor    = %s\n", cDescriptor);
    printf ("     Serial Number = '%s'\n\n\n", cSepiaSerNo);
    printf ("    =================================================\n\n\n");
    //
    // get sepia's module map and initialise datastructures for all library functions
    // there are two different ways to do so:
    //
    // first:  if sepia was not touched since last power on, it doesn't need to be restarted
    //
    if ((iRetVal = SEPIA2_FWR_GetModuleMap (iDevIdx, SEPIA2_NO_RESTART, &iModuleCount)) == SEPIA2_ERR_NO_ERROR)
    //
    // second: in case of changes with soft restart
    //
    //  if ((iRetVal = SEPIA2_FWR_GetModuleMap (iDevIdx, SEPIA2_RESTART, &iModuleCount)) == SEPIA2_ERR_NO_ERROR)
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
        else
        {
          //
          // SOM-Type - Initialization
          //
          if ((iRetVal = SEPIA2_COM_GetModuleType (iDevIdx, iSOM_Slot, SEPIA2_PRIMARY_MODULE, &iModuleType)) == SEPIA2_ERR_NO_ERROR)
          {
            bIsSOMDModule = (iModuleType == SEPIA2OBJECT_SOMD);
            SEPIA2_COM_DecodeModuleTypeAbbr (iModuleType, cSOMType);
          }
          //
          // SLM-Type - Initialization
          //
          if ((iRetVal = SEPIA2_COM_GetModuleType (iDevIdx, iSLM_Slot, SEPIA2_PRIMARY_MODULE, &iModuleType)) == SEPIA2_ERR_NO_ERROR)
          {
            SEPIA2_COM_DecodeModuleTypeAbbr (iModuleType, cSLMType);
          }
          //
          //
          // we want to restore the changed values ...
          //
          if (_stat( "OrigData.txt", &buf ) == 0)
          {
            // ... so we have to read the original data from file
            //
            f = fopen ("OrigData.txt", "rt");
            fscanf (f, "%s FreqTrigIdx   =      %d\n", cTemp, &iFreqTrigIdx);
            bExtTiggered = (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_RISING) || (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_FALLING);
            //
            if ((strcmp (cTemp, "SOMD") == 0) && bExtTiggered)
            {
              fscanf (f, "%s ExtTrig.Sync. =      %d\n", cTemp, &iTemp1);
              bSynchronized = (iTemp1 != 0);
            }
            //
            fscanf (f, "%s Divider       =      %d\n", cTemp, &iTemp1);
            fscanf (f, "%s PreSync       =      %d\n", cTemp, &iTemp2);
            fscanf (f, "%s MaskSync      =      %d\n", cTemp, &iTemp3);
            bDivider   = (unsigned char)(iTemp1 % 256);
            wDivider   = iTemp1;
            bPreSync   = iTemp2;
            bMaskSync  = iTemp3;
            //
            fscanf (f, "%s Output Enable =     0x%2X\n", cTemp, &iTemp1);
            fscanf (f, "%s Sync Enable   =     0x%2X\n", cTemp, &iTemp2);
            fscanf (f, "%s Sync Inverse  =        %d\n", cTemp, &iTemp3);
            bOutEnable   = iTemp1;
            bSyncEnable  = iTemp2;
            bSyncInverse = iTemp3;
            for (i = 0; i < SEPIA2_SOM_BURSTCHANNEL_COUNT; i++)
            {
              fscanf (f, "%4s BurstLength %d = %8d\n", cTemp, &iTemp1, &lTemp);
              lBurstChannels[iTemp1-1] = lTemp;
            }
            //
            fscanf (f, "%s FreqTrigIdx   =        %1d\n", cTemp, &iFreq);
            fscanf (f, "%s Pulse Mode    =        %1d\n", cTemp, &iTemp1);
            fscanf (f, "%s Intensity     =      %f%%\n",  cTemp, &fIntensity);
            bPulseMode = iTemp1;
            wIntensity = (word)((int)(10 * fIntensity + 0.5));

            // ... and delete it afterwards
            fclose(f);
            printf ("     original data read from file 'OrigData.txt'\n\n");
            remove("OrigData.txt");
          }
          else
          {
            // ... so we have to save the original data in a file
            // ... and may then set arbitrary values
            //
            if ((f = fopen ("OrigData.txt", "wt")) == NULL)
            {
              printf ("     You tried to start this demo in a write protected directory.\n");
              printf ("     demo execution aborted.\n");
              printf ("\n\n");
              printf ("press RETURN...\n");
              getchar ();

              return iRetVal;
            }
            //
            // SOM
            //
            // FreqTrigMode
            if (bIsSOMDModule)
            {
              SEPIA2_SOMD_GetFreqTrigMode (iDevIdx, iSOM_Slot, &iFreqTrigIdx, &bSynchronized);
              fprintf   (f, "%-4s FreqTrigIdx   =        %1d\n", cSOMType, iFreqTrigIdx);
              if ((iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_RISING) || (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_FALLING))
              {
                fprintf (f, "%-4s ExtTrig.Sync. =        %1d\n", cSOMType, bSynchronized ? 1 : 0);
              }
            }
            else
            {
              SEPIA2_SOM_GetFreqTrigMode  (iDevIdx, iSOM_Slot, &iFreqTrigIdx);
              fprintf (f, "%-4s FreqTrigIdx   =        %1d\n", cSOMType, iFreqTrigIdx);
            }
            iFreqTrigIdx = SEPIA2_SOM_INT_OSC_C;
            //
            // BurstValues
            if (bIsSOMDModule)
            {
              SEPIA2_SOMD_GetBurstValues (iDevIdx, iSOM_Slot, &wDivider, &bPreSync, &bMaskSync);
            }
            else
            {
              SEPIA2_SOM_GetBurstValues  (iDevIdx, iSOM_Slot, &bDivider, &bPreSync, &bMaskSync);
              wDivider = bDivider;
            }
            fprintf (f, "%-4s Divider       =    %5u\n",   cSOMType, wDivider);
            fprintf (f, "%-4s PreSync       =      %3u\n", cSOMType, bPreSync);
            fprintf (f, "%-4s MaskSync      =      %3u\n", cSOMType, bMaskSync);
            bDivider  = 200;
            bPreSync  =  10;
            bMaskSync =   1;
            //
            // Out'n'SyncEnable
            if (bIsSOMDModule)
            {
              SEPIA2_SOMD_GetOutNSyncEnable   (iDevIdx, iSOM_Slot, &bOutEnable, &bSyncEnable, &bSyncInverse);
              SEPIA2_SOMD_GetBurstLengthArray (iDevIdx, iSOM_Slot, &lBurstChannels[0], &lBurstChannels[1], &lBurstChannels[2], &lBurstChannels[3], &lBurstChannels[4], &lBurstChannels[5], &lBurstChannels[6], &lBurstChannels[7]);
            }
            else
            {
              SEPIA2_SOM_GetOutNSyncEnable   (iDevIdx, iSOM_Slot, &bOutEnable, &bSyncEnable, &bSyncInverse);
              SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSOM_Slot, &lBurstChannels[0], &lBurstChannels[1], &lBurstChannels[2], &lBurstChannels[3], &lBurstChannels[4], &lBurstChannels[5], &lBurstChannels[6], &lBurstChannels[7]);
            }
            fprintf (f, "%-4s Output Enable =     0x%2.2X\n", cSOMType, bOutEnable);
            fprintf (f, "%-4s Sync Enable   =     0x%2.2X\n", cSOMType, bSyncEnable);
            fprintf (f, "%-4s Sync Inverse  =        %1d\n",  cSOMType,  bSyncInverse);
            bOutEnable   = 0xA5;
            bSyncEnable  = 0x93;
            bSyncInverse =    1;
            //
            // BurstLengthArray
            for (i = 0; i < SEPIA2_SOM_BURSTCHANNEL_COUNT; i++)
            {
              fprintf (f, "%-4s BurstLength %d = %8d\n", cSOMType, i+1, lBurstChannels[i]);
            }
            // just change places of burstlenght channel 2 & 3
            lTemp             = lBurstChannels[2];
            lBurstChannels[2] = lBurstChannels[1];
            lBurstChannels[1] = lTemp;
            //
            //
            // SLM
            //
            SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSLM_Slot, &wIntensity);
            SEPIA2_SLM_GetPulseParameters   (iDevIdx, iSLM_Slot, &iFreq, &bPulseMode, &iHead);
            fprintf (f, "%-4s FreqTrigIdx   =        %1d\n",   cSLMType, iFreq);
            fprintf (f, "%-4s Pulse Mode    =        %1d\n",   cSLMType, bPulseMode);
            fprintf (f, "%-4s Intensity     =      %3.1f%%\n", cSLMType, 0.1 * wIntensity);
            iFreq      = (2 + iFreq) % SEPIA2_SLM_FREQ_TRIGMODE_COUNT;
            bPulseMode =    1 - bPulseMode;
            wIntensity = 1000 - wIntensity;
            //
            //
            fclose(f);
            printf ("     original data stored in file 'OrigData.txt'\n\n");
          }
          //
          // and here we finally set the new (resp. old) values
          //
          if (bIsSOMDModule)
          {
            SEPIA2_SOMD_SetFreqTrigMode     (iDevIdx, iSOM_Slot, iFreqTrigIdx, bSynchronized);
            SEPIA2_SOMD_DecodeFreqTrigMode  (iDevIdx, iSOM_Slot, iFreqTrigIdx, cFreqTrigMode);
            SEPIA2_SOMD_SetBurstValues      (iDevIdx, iSOM_Slot, wDivider, bPreSync, bMaskSync);
            SEPIA2_SOMD_SetOutNSyncEnable   (iDevIdx, iSOM_Slot, bOutEnable, bSyncEnable, bSyncInverse);
            SEPIA2_SOMD_SetBurstLengthArray (iDevIdx, iSOM_Slot, lBurstChannels[0], lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7]);
          }
          else
          {
            bDivider = (unsigned char) wDivider % 256;
            SEPIA2_SOM_SetFreqTrigMode     (iDevIdx, iSOM_Slot, iFreqTrigIdx);
            SEPIA2_SOM_DecodeFreqTrigMode  (iDevIdx, iSOM_Slot, iFreqTrigIdx, cFreqTrigMode);
            SEPIA2_SOM_SetBurstValues      (iDevIdx, iSOM_Slot, bDivider, bPreSync, bMaskSync);
            SEPIA2_SOM_SetOutNSyncEnable   (iDevIdx, iSOM_Slot, bOutEnable, bSyncEnable, bSyncInverse);
            SEPIA2_SOM_SetBurstLengthArray (iDevIdx, iSOM_Slot, lBurstChannels[0], lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7]);
          }
          printf ("     %-4s FreqTrigMode  =      '%s'\n", cSOMType, cFreqTrigMode);
          if ((iModuleType == SEPIA2OBJECT_SOMD) && ((iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_RISING) || (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_FALLING)))
          {
            printf ("     %-4s ExtTrig.Sync. =        %1d\n", cSOMType, bSynchronized ? 1 : 0);
          }
          //
          printf ("     %-4s Divider       =    %5u\n",   cSOMType,   wDivider);
          printf ("     %-4s PreSync       =      %3u\n", cSOMType,   bPreSync);
          printf ("     %-4s MaskSync      =      %3u\n", cSOMType,   bMaskSync);
          //
          printf ("     %-4s Output Enable =     0x%2.2X\n", cSOMType, bOutEnable);
          printf ("     %-4s Sync Enable   =     0x%2.2X\n", cSOMType, bSyncEnable);
          printf ("     %-4s Sync Inverse  =        %1d\n",  cSOMType,  bSyncInverse);
          //
          printf ("     %-4s BurstLength 2 = %8d\n",   cSOMType, lBurstChannels[1]);
          printf ("     %-4s BurstLength 3 = %8d\n\n", cSOMType, lBurstChannels[2]);
          //
          // SLM
          //
          SEPIA2_SLM_SetPulseParameters   (iDevIdx, iSLM_Slot, iFreq, bPulseMode);
          SEPIA2_SLM_SetIntensityFineStep (iDevIdx, iSLM_Slot, wIntensity);
          SEPIA2_SLM_DecodeFreqTrigMode (iFreq, cFreqTrigMode);
          printf ("     %-4s FreqTrigMode  =      '%s'\n", cSLMType,  cFreqTrigMode);
          printf ("     %-4s Pulse Mode    =        %1d\n", cSLMType, bPulseMode);
          printf ("     %-4s Intensity     =       %3.1f%%\n", cSLMType, 0.1 * wIntensity);
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
    SEPIA2_USB_CloseDevice   (iDevIdx);
  }
  else
  {
    SEPIA2_LIB_DecodeError (iRetVal, cErrString);
    printf ("     ERROR %5d:    '%s'\n\n", iRetVal, cErrString);
  }

  printf ("\n\n");
  printf ("press RETURN...\n");
  getchar ();

  return iRetVal;
}
