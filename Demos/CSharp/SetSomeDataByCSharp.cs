//-----------------------------------------------------------------------------
//
//      SetSomeDataByCSharp.cs
//
//      (Converted from SetSomeDataByMSVCPP.cpp)
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

using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Globalization;


namespace SetSomeData
{
  class MainClass
  {
    public static void ScanFile (string regex, StringBuilder sFirst, out int iVal)
    {
      iVal = 0;
      //
      foreach (string line in File.ReadLines ("OrigData.txt")) {
        if (Regex.IsMatch (line, regex)) {
          //
          sFirst.Length = 0;
          sFirst.Append (line.Split (' ') [0]);
          //
          string sVal = line.Split ('=') [1];
          if (sVal.Contains (".")) {
            float fVal;
            float.TryParse (sVal.Replace ('%', ' '), out fVal);
            iVal = (int)(10.0 * fVal + 0.5);
          } else if (sVal.Contains ("0x")) {
            Int32.TryParse (sVal.Replace("0x", ""), NumberStyles.HexNumber, null as IFormatProvider, out iVal);
          } else {
            Int32.TryParse (sVal, out iVal);
          }
        }
      }
    }

    public static void Main (string[] args)
    {
      int             iRetVal        = Sepia2_Import.SEPIA2_ERR_NO_ERROR;
      //
      StringBuilder   cLibVersion    = new StringBuilder("", Sepia2_Import.SEPIA2_VERSIONINFO_LEN);
      StringBuilder   cSepiaSerNo    = new StringBuilder("", Sepia2_Import.SEPIA2_SERIALNUMBER_LEN);
      StringBuilder   cGivenSerNo    = new StringBuilder("", Sepia2_Import.SEPIA2_SERIALNUMBER_LEN);
      StringBuilder   cProductModel  = new StringBuilder("", Sepia2_Import.SEPIA2_PRODUCTMODEL_LEN);
      StringBuilder   cGivenProduct  = new StringBuilder("", Sepia2_Import.SEPIA2_PRODUCTMODEL_LEN);
      StringBuilder   cFWVersion     = new StringBuilder("", Sepia2_Import.SEPIA2_VERSIONINFO_LEN);
      StringBuilder   cDescriptor    = new StringBuilder("", Sepia2_Import.SEPIA2_USB_STRDECR_LEN);
      StringBuilder   cFWErrCond     = new StringBuilder("", Sepia2_Import.SEPIA2_FW_ERRCOND_LEN);
      StringBuilder   cErrString     = new StringBuilder("", Sepia2_Import.SEPIA2_ERRSTRING_LEN);
      StringBuilder   cFWErrPhase    = new StringBuilder("", Sepia2_Import.SEPIA2_FW_ERRPHASE_LEN);
      StringBuilder   cFreqTrigMode  = new StringBuilder("", Sepia2_Import.SEPIA2_SOM_FREQ_TRIGMODE_LEN);
      StringBuilder   cSOMType       = new StringBuilder("", 5);
      StringBuilder   cSLMType       = new StringBuilder("", 5);
      StringBuilder   cTemp          = new StringBuilder("", 1025);
      //
      int []         lBurstChannels  = new int[Sepia2_Import.SEPIA2_SOM_BURSTCHANNEL_COUNT] {0, 0, 0, 0, 0, 0, 0, 0};
      int            lTemp;
      //
      int             iSOM_Slot                                      = 100;
      int             iSLM_Slot                                      = 200;
      int             iDevIdx                                        =  -1;
      int             iGivenDevIdx                                   =   0;
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
      bool   bUSBInstGiven = false;
      bool   bSerialGiven  = false;
      bool   bProductGiven = false;
      bool   bIsSOMDModule = false;
      bool   bExtTiggered;
      byte   bDivider;
      byte   bPreSync;
      byte   bMaskSync;
      byte   bOutEnable;
      byte   bSyncEnable;
      byte   bSyncInverse;
      byte   bSynchronized = 0;
      byte   bPulseMode;
      //
      // word
      ushort  wIntensity;
      ushort  wDivider;
      //
      //
      Console.WriteLine (" called with {0} Parameter{1}:", args.Length, (args.Length>1)?"s":"");
      foreach (string s in args)
      {
        if (Regex.IsMatch(s, "^-inst="))
        {
          string sVal = Regex.Replace (s, "^-inst=", "");
          try
          {
            iGivenDevIdx = Int32.Parse (sVal);
          }
          catch (FormatException)
          {
            throw new Exception ("error: param \"-inst=\" is not an integer");
          }
          Console.Write ("    -inst={0}\n", iGivenDevIdx);
          bUSBInstGiven = true;
        } else
          if (Regex.IsMatch(s, "^-serial="))
        {
          string sVal = Regex.Replace (s, "^-serial=", "");
          cGivenSerNo.Append (Regex.Match (sVal, @"\d{1," + Sepia2_Import.SEPIA2_SERIALNUMBER_LEN + "}").Value);
          Console.Write ("    -serial={0}\n", cGivenSerNo);
          bSerialGiven = (cGivenSerNo.Length > 0);
        } else
          if (Regex.IsMatch(s, "^-product="))
        {
          string sVal = Regex.Replace (s, "^-product=", "");
          cGivenProduct.Append (Regex.Match (sVal, @"\d{1," + Sepia2_Import.SEPIA2_PRODUCTMODEL_LEN + "}").Value);
          Console.Write ("    -product={0}\n", cGivenProduct);
          bProductGiven = (cGivenProduct.Length > 0);
        } else
        {
          Console.Write ("    {0} : unknown parameter!\n", s);
        }
      }

      Console.Write ("\n\n     PQLaserDrv   Set SOME Values Demo : \n");
      Console.Write ("    =================================================\n\n\n");
      //
      // preliminaries: check library version
      //
      Sepia2_Import.SEPIA2_LIB_GetVersion (cLibVersion);
      Console.Write ("     Lib-Version   = {0}\n", cLibVersion);

//      if (0 != strncmp (cLibVersion, LIB_VERSION_REFERENCE, LIB_VERSION_REFERENCE_COMPLEN))
//      {
//        Console.Write ("\n     Warning: This demo application was built for version  %s!\n", LIB_VERSION_REFERENCE);
//        Console.Write ("              Continuing may cause unpredictable results!\n");
//        Console.Write ("\n     Do you want to continue anyway? (y/n): ");
//
//        c = Console.Read();
//        if ((c != 'y') && (c != 'Y'))
//        {
//          exit (-1);
//        }
//        while ((c = Console.Read()) != 0x0A ); // reject userinput 'til end of line
//        Console.Write ("\n");
//      }
      //
      // establish USB connection to the sepia first matching all given conditions
      //
      for (i = (bUSBInstGiven ? iGivenDevIdx : 0); i < (bUSBInstGiven ? iGivenDevIdx+1 : Sepia2_Import.SEPIA2_MAX_USB_DEVICES); i++)
      {
        cSepiaSerNo.Length = 0;
        cProductModel.Length = 0;
        //
        iRetVal = Sepia2_Import.SEPIA2_USB_OpenGetSerNumAndClose (i, cProductModel, cSepiaSerNo);
        if ( (iRetVal == Sepia2_Import.SEPIA2_ERR_NO_ERROR) 
            && (  (  (bSerialGiven && bProductGiven)
               && (cGivenSerNo.Equals (cSepiaSerNo)  )
               && (cGivenProduct.Equals (cProductModel)  )
               )
            ||  (  (!bSerialGiven != !bProductGiven)
             && (  (cGivenSerNo.Equals (cSepiaSerNo)  )
            || (cGivenProduct.Equals (cProductModel)  )
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
      if ((iRetVal = Sepia2_Import.SEPIA2_USB_OpenDevice (iDevIdx, cProductModel, cSepiaSerNo)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
      {
        Sepia2_Import.SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion);
        Console.Write ("     FW-Version    = {0}\n",     cFWVersion);
        //
        Sepia2_Import.SEPIA2_USB_GetStrDescriptor  (iDevIdx, cDescriptor);
        Console.Write ("     Descriptor    = {0}\n", cDescriptor);
        Console.Write ("     Serial Number = '{0}'\n\n\n", cSepiaSerNo);
        Console.Write ("    =================================================\n\n\n");
        //
        // get sepia's module map and initialise datastructures for all library functions
        // there are two different ways to do so:
        //
        // first:  if sepia was not touched since last power on, it doesn't need to be restarted
        //
        if ((iRetVal = Sepia2_Import.SEPIA2_FWR_GetModuleMap (iDevIdx, Sepia2_Import.SEPIA2_NO_RESTART, out iModuleCount)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
          //
          // second: in case of changes with soft restart
          //
          //  if ((iRetVal = Sepia2_Import.SEPIA2_FWR_GetModuleMap (iDevIdx, Sepia2_Import.SEPIA2_RESTART, out iModuleCount)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
        {
          //
          // this is to inform us about possible error conditions during sepia's last startup
          //
          if ((iRetVal = Sepia2_Import.SEPIA2_FWR_GetLastError (iDevIdx, out iFWErrCode, out iFWErrPhase, out iFWErrLocation, out iFWErrSlot, cFWErrCond)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
          {
            if (iFWErrCode != Sepia2_Import.SEPIA2_ERR_NO_ERROR)
            {
              Sepia2_Import.SEPIA2_LIB_DecodeError  (iFWErrCode,  cErrString);
              Sepia2_Import.SEPIA2_FWR_DecodeErrPhaseName (iFWErrPhase, cFWErrPhase);
              Console.Write ("     Error detected by firmware on last restart:\n");
              Console.Write ("        error code      : {0:5},   i.e. '{1}'\n", iFWErrCode,  cErrString);
              Console.Write ("        error phase     : {0:5},   i.e. '{1}'\n", iFWErrPhase, cFWErrPhase);
              Console.Write ("        error location  : {0:5}\n",  iFWErrLocation);
              Console.Write ("        error slot      : {0:5}\n",  iFWErrSlot);
              if (cFWErrCond.Length > 0)
              {
                Console.Write ("        error condition : '{0}'\n", cFWErrCond);
              }
            }
            else
            {
              //
              // SOM-Type - Initialization
              //
              if ((iRetVal = Sepia2_Import.SEPIA2_COM_GetModuleType (iDevIdx, iSOM_Slot, Sepia2_Import.SEPIA2_PRIMARY_MODULE, out iModuleType)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
              {
                bIsSOMDModule = (iModuleType == Sepia2_Import.SEPIA2OBJECT_SOMD);
                Sepia2_Import.SEPIA2_COM_DecodeModuleTypeAbbr (iModuleType, cSOMType);
              }
              //
              // SLM-Type - Initialization
              //
              if ((iRetVal = Sepia2_Import.SEPIA2_COM_GetModuleType (iDevIdx, iSLM_Slot, Sepia2_Import.SEPIA2_PRIMARY_MODULE, out iModuleType)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
              {
                Sepia2_Import.SEPIA2_COM_DecodeModuleTypeAbbr (iModuleType, cSLMType);
              }
              //
              //
              // we want to restore the changed values ...
              //
              if (File.Exists ("OrigData.txt"))
              {
                // ... so we have to read the original data from file
                //
                ScanFile ("SOM.*FreqTrigIdx", cTemp, out iFreqTrigIdx);
                bExtTiggered = (iFreqTrigIdx == Sepia2_Import.SEPIA2_SOM_TRIGMODE_RISING) || (iFreqTrigIdx == Sepia2_Import.SEPIA2_SOM_TRIGMODE_FALLING);
                //

                if (cTemp.Equals ("SOMD") && bExtTiggered)
                {
                  ScanFile ("ExtTrig.Sync.", cTemp, out iTemp1);
                  bSynchronized = (byte)((iTemp1 != 0) ? 1 : 0);
                }
                //
                ScanFile ("Divider", cTemp, out iTemp1);
                ScanFile ("PreSync", cTemp, out iTemp2);
                ScanFile ("MaskSync", cTemp, out iTemp3);
                bDivider   = (byte)(iTemp1 % 256);
                wDivider   = (ushort)iTemp1;
                bPreSync   = (byte)iTemp2;
                bMaskSync  = (byte)iTemp3;
                //
                ScanFile ("Output Enable", cTemp, out iTemp1);
                ScanFile ("Sync Enable", cTemp, out iTemp2);
                ScanFile ("Sync Inverse", cTemp, out iTemp3);
                bOutEnable   = (byte)iTemp1;
                bSyncEnable  = (byte)iTemp2;
                bSyncInverse = (byte)iTemp3;
                for (i = 0; i < Sepia2_Import.SEPIA2_SOM_BURSTCHANNEL_COUNT; i++)
                {
                  ScanFile (string.Format("BurstLength {0}", i+1), cTemp, out lTemp);
                  lBurstChannels[i] = lTemp;
                }
                //
                ScanFile ("SLM.*FreqTrigIdx", cTemp, out iFreq);
                ScanFile ("Pulse Mode", cTemp, out iTemp1);
                ScanFile ("Intensity",  cTemp, out iTemp2);
                bPulseMode = (byte)iTemp1;
                wIntensity = (ushort)(iTemp2);

                // ... and delete it afterwards
                Console.Write ("     original data read from file 'OrigData.txt'\n\n");
                File.Delete ("OrigData.txt");
              }
              else
              {
                // ... so we have to save the original data in a file
                // ... and may then set arbitrary values
                //
                try
                {
                  File.WriteAllText ("OrigData.txt", "");
                }
                catch
                {
                  Console.Write ("     You tried to start this demo in a write protected directory.\n");
                  Console.Write ("     demo execution aborted.\n");
                  Console.Write ("\n\n");
                  Console.Write ("press RETURN...\n");
                  Console.Read ();

                  return;
                }
                //
                // SOM
                //
                // FreqTrigMode
                if (bIsSOMDModule)
                {
                  Sepia2_Import.SEPIA2_SOMD_GetFreqTrigMode (iDevIdx, iSOM_Slot, out iFreqTrigIdx, out bSynchronized);
                  File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} FreqTrigIdx   =        {1:D1}\n", cSOMType, iFreqTrigIdx));
                  if ((iFreqTrigIdx == Sepia2_Import.SEPIA2_SOM_TRIGMODE_RISING) || (iFreqTrigIdx == Sepia2_Import.SEPIA2_SOM_TRIGMODE_FALLING))
                  {
                    File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} ExtTrig.Sync. =        {1:D1}\n", cSOMType, bSynchronized != 0 ? 1 : 0));
                  }
                }
                else
                {
                  Sepia2_Import.SEPIA2_SOM_GetFreqTrigMode  (iDevIdx, iSOM_Slot, out iFreqTrigIdx);
                  File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} FreqTrigIdx   =        {1:D1}\n", cSOMType, iFreqTrigIdx));
                }
                iFreqTrigIdx = Sepia2_Import.SEPIA2_SOM_INT_OSC_C;
                //
                // BurstValues
                if (bIsSOMDModule)
                {
                  Sepia2_Import.SEPIA2_SOMD_GetBurstValues (iDevIdx, iSOM_Slot, out wDivider, out bPreSync, out bMaskSync);
                }
                else
                {
                  Sepia2_Import.SEPIA2_SOM_GetBurstValues  (iDevIdx, iSOM_Slot, out bDivider, out bPreSync, out bMaskSync);
                  wDivider = bDivider;
                }
                File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} Divider       =    {1,5}\n",   cSOMType, wDivider));
                File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} PreSync       =      {1,3}\n", cSOMType, bPreSync));
                File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} MaskSync      =      {1,3}\n", cSOMType, bMaskSync));
                bDivider  = 200;
                bPreSync  =  10;
                bMaskSync =   1;
                //
                // Out'n'SyncEnable
                if (bIsSOMDModule)
                {
                  Sepia2_Import.SEPIA2_SOMD_GetOutNSyncEnable   (iDevIdx, iSOM_Slot, out bOutEnable, out bSyncEnable, out bSyncInverse);
                  Sepia2_Import.SEPIA2_SOMD_GetBurstLengthArray (iDevIdx, iSOM_Slot, out lBurstChannels[0], out lBurstChannels[1], out lBurstChannels[2], out lBurstChannels[3], out lBurstChannels[4], out lBurstChannels[5], out lBurstChannels[6], out lBurstChannels[7]);
                }
                else
                {
                  Sepia2_Import.SEPIA2_SOM_GetOutNSyncEnable   (iDevIdx, iSOM_Slot, out bOutEnable, out bSyncEnable, out bSyncInverse);
                  Sepia2_Import.SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSOM_Slot, out lBurstChannels[0], out lBurstChannels[1], out lBurstChannels[2], out lBurstChannels[3], out lBurstChannels[4], out lBurstChannels[5], out lBurstChannels[6], out lBurstChannels[7]);
                }
                File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} Output Enable =     0x{1,2:X2}\n", cSOMType, bOutEnable));
                File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} Sync Enable   =     0x{1,2:X2}\n", cSOMType, bSyncEnable));
                File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} Sync Inverse  =        {1:D1}\n",  cSOMType,  bSyncInverse));
                bOutEnable   = 0xA5;
                bSyncEnable  = 0x93;
                bSyncInverse =    1;
                //
                // BurstLengthArray
                for (i = 0; i < Sepia2_Import.SEPIA2_SOM_BURSTCHANNEL_COUNT; i++)
                {
                  File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} BurstLength {1} = {2,8}\n", cSOMType, i+1, lBurstChannels[i]));
                }
                // just change places of burstlenght channel 2 & 3
                lTemp             = lBurstChannels[2];
                lBurstChannels[2] = lBurstChannels[1];
                lBurstChannels[1] = lTemp;
                //
                //
                // SLM
                //
                Sepia2_Import.SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSLM_Slot, out wIntensity);
                Sepia2_Import.SEPIA2_SLM_GetPulseParameters   (iDevIdx, iSLM_Slot, out iFreq, out bPulseMode, out iHead);
                File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} FreqTrigIdx   =        {1:D1}\n",   cSLMType, iFreq));
                File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} Pulse Mode    =        {1:D1}\n",   cSLMType, bPulseMode));
                File.AppendAllText ("OrigData.txt", string.Format ("{0,-4} Intensity     =      {1,2:F1}%\n", cSLMType, 0.1 * wIntensity));
                iFreq      = (2 + iFreq) % Sepia2_Import.SEPIA2_SLM_FREQ_TRIGMODE_COUNT;
                bPulseMode = (byte)(1 - bPulseMode);
                wIntensity = (ushort)(1000 - wIntensity);
                //
                //
                Console.Write ("     original data stored in file 'OrigData.txt'\n\n");
              }
              //
              // and here we finally set the new (resp. old) values
              //
              if (bIsSOMDModule)
              {
                Sepia2_Import.SEPIA2_SOMD_SetFreqTrigMode     (iDevIdx, iSOM_Slot, iFreqTrigIdx, bSynchronized);
                Sepia2_Import.SEPIA2_SOMD_DecodeFreqTrigMode  (iDevIdx, iSOM_Slot, iFreqTrigIdx, cFreqTrigMode);
                Sepia2_Import.SEPIA2_SOMD_SetBurstValues      (iDevIdx, iSOM_Slot, wDivider, bPreSync, bMaskSync);
                Sepia2_Import.SEPIA2_SOMD_SetOutNSyncEnable   (iDevIdx, iSOM_Slot, bOutEnable, bSyncEnable, bSyncInverse);
                Sepia2_Import.SEPIA2_SOMD_SetBurstLengthArray (iDevIdx, iSOM_Slot, lBurstChannels[0], lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7]);
              }
              else
              {
                bDivider = (byte)(wDivider % 256);
                Sepia2_Import.SEPIA2_SOM_SetFreqTrigMode     (iDevIdx, iSOM_Slot, iFreqTrigIdx);
                Sepia2_Import.SEPIA2_SOM_DecodeFreqTrigMode  (iDevIdx, iSOM_Slot, iFreqTrigIdx, cFreqTrigMode);
                Sepia2_Import.SEPIA2_SOM_SetBurstValues      (iDevIdx, iSOM_Slot, bDivider, bPreSync, bMaskSync);
                Sepia2_Import.SEPIA2_SOM_SetOutNSyncEnable   (iDevIdx, iSOM_Slot, bOutEnable, bSyncEnable, bSyncInverse);
                Sepia2_Import.SEPIA2_SOM_SetBurstLengthArray (iDevIdx, iSOM_Slot, lBurstChannels[0], lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7]);
              }
              Console.Write ("     {0,-4} FreqTrigMode  =      '{1}'\n", cSOMType, cFreqTrigMode);
              if ((iModuleType == Sepia2_Import.SEPIA2OBJECT_SOMD) && ((iFreqTrigIdx == Sepia2_Import.SEPIA2_SOM_TRIGMODE_RISING) || (iFreqTrigIdx == Sepia2_Import.SEPIA2_SOM_TRIGMODE_FALLING)))
              {
                Console.Write ("     {0,-4} ExtTrig.Sync. =        {1:D1}\n", cSOMType, bSynchronized != 0 ? 1 : 0);
              }
              //
              Console.Write ("     {0,-4} Divider       =    {1,5}\n",   cSOMType,   wDivider);
              Console.Write ("     {0,-4} PreSync       =      {1,3}\n", cSOMType,   bPreSync);
              Console.Write ("     {0,-4} MaskSync      =      {1,3}\n", cSOMType,   bMaskSync);
              //
              Console.Write ("     {0,-4} Output Enable =     0x{1,2:X2}\n", cSOMType, bOutEnable);
              Console.Write ("     {0,-4} Sync Enable   =     0x{1,2:X2}\n", cSOMType, bSyncEnable);
              Console.Write ("     {0,-4} Sync Inverse  =        {1:D1}\n",  cSOMType,  bSyncInverse);
              //
              Console.Write ("     {0,-4} BurstLength 2 = {1,8}\n",   cSOMType, lBurstChannels[1]);
              Console.Write ("     {0,-4} BurstLength 3 = {1,8}\n\n", cSOMType, lBurstChannels[2]);
              //
              // SLM
              //
              Sepia2_Import.SEPIA2_SLM_SetPulseParameters   (iDevIdx, iSLM_Slot, iFreq, bPulseMode);
              Sepia2_Import.SEPIA2_SLM_SetIntensityFineStep (iDevIdx, iSLM_Slot, wIntensity);
              Sepia2_Import.SEPIA2_SLM_DecodeFreqTrigMode (iFreq, cFreqTrigMode);
              Console.Write ("     {0,-4} FreqTrigMode  =      '{1}'\n", cSLMType,  cFreqTrigMode);
              Console.Write ("     {0,-4} Pulse Mode    =        {1:D1}\n", cSLMType, bPulseMode);
              Console.Write ("     {0,-4} Intensity     =       {1,2:F1}%\n", cSLMType, 0.1 * wIntensity);
            }
          }
        } // get module map
        else
        {
          Sepia2_Import.SEPIA2_LIB_DecodeError (iRetVal, cErrString);
          Console.Write ("     ERROR {0,5}:    '{1}'\n\n", iRetVal, cErrString);
          if ((iRetVal = Sepia2_Import.SEPIA2_FWR_GetLastError (iDevIdx, out iFWErrCode, out iFWErrPhase, out iFWErrLocation, out iFWErrSlot, cFWErrCond)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
          {
            if (iFWErrCode != Sepia2_Import.SEPIA2_ERR_NO_ERROR)
            {
              Sepia2_Import.SEPIA2_LIB_DecodeError  (iFWErrCode,  cErrString);
              Sepia2_Import.SEPIA2_FWR_DecodeErrPhaseName (iFWErrPhase, cFWErrPhase);
              Console.Write ("     Firmware error detected:\n");
              Console.Write ("        error code      : {0,5},   i.e. '{1}'\n", iFWErrCode,  cErrString);
              Console.Write ("        error phase     : {0,5},   i.e. '{1}'\n", iFWErrPhase, cFWErrPhase);
              Console.Write ("        error location  : {0,5}\n",  iFWErrLocation);
              Console.Write ("        error slot      : {0,5}\n",  iFWErrSlot);
              if (cFWErrCond.Length > 0)
              {
                Console.Write ("        error condition : '{0}'\n", cFWErrCond);
              }
            }
          }
        }

        //
        Sepia2_Import.SEPIA2_FWR_FreeModuleMap (iDevIdx);
        Sepia2_Import.SEPIA2_USB_CloseDevice   (iDevIdx);
      }
      else
      {
        Sepia2_Import.SEPIA2_LIB_DecodeError (iRetVal, cErrString);
        Console.Write ("     ERROR {0,5}:    '{1}'\n\n", iRetVal, cErrString);
      }

      Console.Write ("\n\n");
      Console.Write ("press RETURN...\n");
      Console.Read ();
    }

  }
}
