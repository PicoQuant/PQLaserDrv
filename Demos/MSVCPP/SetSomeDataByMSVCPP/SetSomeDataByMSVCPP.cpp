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
//
//-----------------------------------------------------------------------------
//  HISTORY:
//
//  apo  06.02.06   created
//
//  apo  05.09.14   adapted to DLL version 1.1.<target>.<svn_build>
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
  int           iRetVal        = SEPIA2_ERR_NO_ERROR;
  char          c;
  //
  struct _stat  buf;
  FILE*         f;
  //
  char          cLibVersion    [SEPIA2_VERSIONINFO_LEN]        = "";
  char          cSepiaSerNo    [SEPIA2_SERIALNUMBER_LEN]       = "";
  char          cProductModel  [SEPIA2_PRODUCTMODEL_LEN]       = "";
  char          cFWVersion     [SEPIA2_VERSIONINFO_LEN]        = "";
  char          cDescriptor    [SEPIA2_USB_STRDECR_LEN]        = "";
  char          cFWErrCond     [SEPIA2_FW_ERRCOND_LEN]         = "";
  char          cErrString     [SEPIA2_ERRSTRING_LEN]          = "";
  char          cFWErrPhase    [SEPIA2_FW_ERRPHASE_LEN]        = "";
  char          cFreqTrigMode  [SEPIA2_SOM_FREQ_TRIGMODE_LEN]  = "";
  //
  long          lBurstChannels [SEPIA2_SOM_BURSTCHANNEL_COUNT] = {0L, 0L, 0L, 0L, 0L, 0L, 0L, 0L};
  long          lTemp;
  //
  int           iDevIdx                                        =   0;
  int           iSOM_Slot                                      = 100;
  int           iSLM_Slot                                      = 200;
  //
  //
  int           iModuleCount;
  int           iFWErrCode;
  int           iFWErrPhase;
  int           iFWErrLocation;
  int           iFWErrSlot;
  int           iFreqTrigMode;
  int           iTemp1;
  int           iTemp2;
  int           iTemp3;
  int           iFreq;
  int           iHead;
  //
  // byte
  unsigned char bDivider;
  unsigned char bPreSync;
  unsigned char bMaskSync;
  unsigned char bOutEnable;
  unsigned char bSyncEnable;
  unsigned char bSyncInverse;
  unsigned char bPulseMode;
  unsigned char bIntensity;
  //


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
  // establish USB connection to sepia
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
          // we want to restore the changed values ...
          //
          if (_stat( "OrigData.txt", &buf ) == 0)
          {
            // ... so we have to read the original data from file
            //
            f = fopen ("OrigData.txt", "rt");
            fscanf (f, "SOM FreqTrigMode  =        %d\n", &iFreqTrigMode);
            //
            fscanf (f, "SOM Divider       =      %d\n", &iTemp1);
            fscanf (f, "SOM PreSync       =      %d\n", &iTemp2);
            fscanf (f, "SOM MaskSync      =      %d\n", &iTemp3);
            bDivider  = iTemp1;
            bPreSync  = iTemp2;
            bMaskSync = iTemp3;
            //
            fscanf (f, "SOM Output Enable =     0x%2X\n", &iTemp1);
            fscanf (f, "SOM Sync Enable   =     0x%2X\n", &iTemp2);
            fscanf (f, "SOM Sync Inverse  =        %d\n", &iTemp3);
            bOutEnable   = iTemp1;
            bSyncEnable  = iTemp2;
            bSyncInverse = iTemp3;
            fscanf (f, "SOM BurstLength 1 = %8d\n", &lBurstChannels[0]);
            fscanf (f, "SOM BurstLength 2 = %8d\n", &lBurstChannels[1]);
            fscanf (f, "SOM BurstLength 3 = %8d\n", &lBurstChannels[2]);
            fscanf (f, "SOM BurstLength 4 = %8d\n", &lBurstChannels[3]);
            fscanf (f, "SOM BurstLength 5 = %8d\n", &lBurstChannels[4]);
            fscanf (f, "SOM BurstLength 6 = %8d\n", &lBurstChannels[5]);
            fscanf (f, "SOM BurstLength 7 = %8d\n", &lBurstChannels[6]);
            fscanf (f, "SOM BurstLength 8 = %8d\n", &lBurstChannels[7]);
            //
            fscanf (f, "SLM FreqTrigMode  =        %1d\n", &iFreq);
            fscanf (f, "SLM Pulse Mode    =        %1d\n", &iTemp1);
            fscanf (f, "SLM Intensity     =      %3d%%\n",  &iTemp2);
            bPulseMode = iTemp1;
            bIntensity = iTemp2;

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
            SEPIA2_SOM_GetFreqTrigMode (iDevIdx, iSOM_Slot, &iFreqTrigMode);
            fprintf (f, "SOM FreqTrigMode  =        %1d\n", iFreqTrigMode);
            iFreqTrigMode = SEPIA2_SOM_INT_OSC_C;
            //
            // BurstValues
            SEPIA2_SOM_GetBurstValues  (iDevIdx, iSOM_Slot, &bDivider, &bPreSync, &bMaskSync);
            fprintf (f, "SOM Divider       =      %3u\n", bDivider);
            fprintf (f, "SOM PreSync       =      %3u\n", bPreSync);
            fprintf (f, "SOM MaskSync      =      %3u\n", bMaskSync);
            bDivider  = 200;
            bPreSync  =  10;
            bMaskSync =   1;
            //
            // Out'n'SyncEnable
            SEPIA2_SOM_GetOutNSyncEnable (iDevIdx, iSOM_Slot, &bOutEnable, &bSyncEnable, &bSyncInverse);
            fprintf (f, "SOM Output Enable =     0x%2.2X\n", bOutEnable);
            fprintf (f, "SOM Sync Enable   =     0x%2.2X\n", bSyncEnable);
            fprintf (f, "SOM Sync Inverse  =        %1d\n",  bSyncInverse);
            bOutEnable   = 0xA5;
            bSyncEnable  = 0x93;
            bSyncInverse =    1;
            //
            // BurstLengthArray
            SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSOM_Slot, &lBurstChannels[0], &lBurstChannels[1], &lBurstChannels[2], &lBurstChannels[3], &lBurstChannels[4], &lBurstChannels[5], &lBurstChannels[6], &lBurstChannels[7]);
            fprintf (f, "SOM BurstLength 1 = %8d\n", lBurstChannels[0]);
            fprintf (f, "SOM BurstLength 2 = %8d\n", lBurstChannels[1]);
            fprintf (f, "SOM BurstLength 3 = %8d\n", lBurstChannels[2]);
            fprintf (f, "SOM BurstLength 4 = %8d\n", lBurstChannels[3]);
            fprintf (f, "SOM BurstLength 5 = %8d\n", lBurstChannels[4]);
            fprintf (f, "SOM BurstLength 6 = %8d\n", lBurstChannels[5]);
            fprintf (f, "SOM BurstLength 7 = %8d\n", lBurstChannels[6]);
            fprintf (f, "SOM BurstLength 8 = %8d\n", lBurstChannels[7]);
            // just change places of burstlenght channel 2 & 3
            lTemp             = lBurstChannels[2];
            lBurstChannels[2] = lBurstChannels[1];
            lBurstChannels[1] = lTemp;
            //
            //
            // SLM
            //
            SEPIA2_SLM_GetParameters (iDevIdx, iSLM_Slot, &iFreq, &bPulseMode, &iHead, &bIntensity);
            fprintf (f, "SLM FreqTrigMode  =        %1d\n", iFreq);
            fprintf (f, "SLM Pulse Mode    =        %1d\n", bPulseMode);
            fprintf (f, "SLM Intensity     =      %3d%%\n",  bIntensity);
            iFreq      =  (2 + iFreq) % SEPIA2_SLM_FREQ_TRIGMODE_COUNT;
            bPulseMode =   1 - bPulseMode;
            bIntensity = 100 - bIntensity;
            //
            //
            fclose(f);
            printf ("     original data stored in file 'OrigData.txt'\n\n");
          }
          //
          // and here we finally set the new (resp. old) values
          //
          SEPIA2_SOM_SetFreqTrigMode    (iDevIdx, iSOM_Slot, iFreqTrigMode);
          SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSOM_Slot, iFreqTrigMode, cFreqTrigMode);
          printf ("     SOM FreqTrigMode  =      '%s'\n", cFreqTrigMode);
          //
          SEPIA2_SOM_SetBurstValues  (iDevIdx, iSOM_Slot, bDivider, bPreSync, bMaskSync);
          printf ("     SOM Divider       =      %3u\n",   bDivider);
          printf ("     SOM PreSync       =      %3u\n",   bPreSync);
          printf ("     SOM MaskSync      =      %3u\n",   bMaskSync);
          //
          SEPIA2_SOM_SetOutNSyncEnable (iDevIdx, iSOM_Slot, bOutEnable, bSyncEnable, bSyncInverse);
          printf ("     SOM Output Enable =     0x%2.2X\n", bOutEnable);
          printf ("     SOM Sync Enable   =     0x%2.2X\n", bSyncEnable);
          printf ("     SOM Sync Inverse  =        %1d\n",  bSyncInverse);
          //
          SEPIA2_SOM_SetBurstLengthArray (iDevIdx, iSOM_Slot, lBurstChannels[0], lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7]);
          printf ("     SOM BurstLength 2 = %8d\n",   lBurstChannels[1]);
          printf ("     SOM BurstLength 3 = %8d\n\n", lBurstChannels[2]);
          //
          // SLM
          //
          SEPIA2_SLM_SetParameters (iDevIdx, iSLM_Slot, iFreq, bPulseMode, bIntensity);
          SEPIA2_SLM_DecodeFreqTrigMode (iFreq, cFreqTrigMode);
          printf ("     SLM FreqTrigMode  =      '%s'\n",  cFreqTrigMode);
          printf ("     SLM Pulse Mode    =        %1d\n", bPulseMode);
          printf ("     SLM Intensity     =      %3d%%\n", bIntensity);
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
