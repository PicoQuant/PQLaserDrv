//-----------------------------------------------------------------------------
//
//      ReadAllDataByCSharp.cs
//
//      (Converted from ReadAllDataByMSVCPP.cpp)
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


using System;
using System.Text;
using System.Text.RegularExpressions;

namespace ReadAllData
{
  class MainClass
  {

    public static string PRAEFIXES = "yzafpnµm kMGTPEZY";
    public static int PRAEFIX_OFFSET = 8;

    public static void PrintUptimers (uint ulMainPowerUp, uint ulActivePowerUp, uint ulScaledPowerUp)
    {
      int    hlp;
      //
      hlp = (int)(5.0 * (ulMainPowerUp + 0x7F) / 0xFF);
      Console.Write ("\n");
      Console.Write ("{0,47}  = {1,5}:{2,2:D2} h\n",  "main power uptime", hlp / 60, hlp % 60);
      //
      if (ulActivePowerUp > 1)
      {
        hlp = (int)(5.0 * (ulActivePowerUp + 0x7F) / 0xFF);
        Console.Write ("{0,47}  = {1,5}:{2,2:D2} hrs\n",  "act. power uptime", hlp / 60, hlp % 60);
        //
        if (ulScaledPowerUp > (0.001 * ulActivePowerUp))
        {
          Console.Write ("{0,47}  =       {1,5:F1}%\n\n",  "pwr scaled factor", 100.0 * ulScaledPowerUp / ulActivePowerUp);
        }
      }
      Console.Write ("\n");
    }

    public static StringBuilder FormatEng (StringBuilder cDest, double fInp, int iMant, string cUnit, int iFixedSpace = -1, int iFixedDigits = -1, bool bUnitSep = true)
    {
      bool          bNSign;
      double        fNorm;
      double        fTemp0;
      int           iTemp;
      int           iNormSeparatorPos;
      StringBuilder cTemp = new StringBuilder ("", 64);
      StringBuilder cNorm = new StringBuilder ("", 64);
      //
      cDest.Length = 0;
      //
      bNSign = (fInp < 0);
      if (fInp == 0)
      {
        iTemp  = 0;
        fNorm  = 0;
      }
      else
      {
        fTemp0 = Math.Log (Math.Abs (fInp)) / Math.Log (1000.0);
        iTemp  = (int) Math.Floor (fTemp0);
        fNorm  = Math.Pow ((double)1000.0, (fTemp0 % 1.0) + ((fTemp0 > 0) || ((fTemp0 - iTemp) == 0) ? 0 : 1));
      }
      //
      cNorm.AppendFormat ("{0:G60}", fNorm);
      iNormSeparatorPos = cNorm.ToString ().IndexOf ('.');
      if (iNormSeparatorPos != -1)
        iMant += 1;
      if (iFixedDigits != -1)
      {
        int iLength = iNormSeparatorPos + iFixedDigits + 1;
        if (cNorm.Length > iLength)
          cNorm.Length = iLength;
      }
      else
      {
        if (cNorm.Length > iMant)
          cNorm.Length = iMant;
      }
      cTemp.AppendFormat ("{0}{1}{2}{3}{4}", bNSign ? "-" : "", cNorm, (bUnitSep ? " " : ""), PRAEFIXES [iTemp + PRAEFIX_OFFSET], cUnit);
      //
      if (iFixedSpace > cTemp.Length)
      {
        cDest.Append (cTemp.ToString().PadLeft(iFixedSpace));
      }
      else
      {
        cDest.Append (cTemp);
      }
      //
      return cDest;
    }


    public static void Main (string[] args)
    {
      int             iRetVal              = Sepia2_Import.SEPIA2_ERR_NO_ERROR;
      //
      StringBuilder   cLibVersion          = new StringBuilder ("", Sepia2_Import.SEPIA2_VERSIONINFO_LEN);
      StringBuilder   cDescriptor          = new StringBuilder ("", Sepia2_Import.SEPIA2_USB_STRDECR_LEN);
      StringBuilder   cSepiaSerNo          = new StringBuilder ("", Sepia2_Import.SEPIA2_SERIALNUMBER_LEN);
      StringBuilder   cGivenSerNo          = new StringBuilder ("", Sepia2_Import.SEPIA2_SERIALNUMBER_LEN);
      StringBuilder   cProductModel        = new StringBuilder ("", Sepia2_Import.SEPIA2_PRODUCTMODEL_LEN);
      StringBuilder   cGivenProduct        = new StringBuilder ("", Sepia2_Import.SEPIA2_PRODUCTMODEL_LEN);
      StringBuilder   cFWVersion           = new StringBuilder ("", Sepia2_Import.SEPIA2_VERSIONINFO_LEN);
      StringBuilder   cFWErrCond           = new StringBuilder ("", Sepia2_Import.SEPIA2_FW_ERRCOND_LEN);
      StringBuilder   cFWErrPhase          = new StringBuilder ("", Sepia2_Import.SEPIA2_FW_ERRPHASE_LEN);
      StringBuilder   cErrString           = new StringBuilder ("", Sepia2_Import.SEPIA2_ERRSTRING_LEN);
      StringBuilder   cModulType           = new StringBuilder ("", Sepia2_Import.SEPIA2_MODULETYPESTRING_LEN);
      StringBuilder   cFreqTrigMode        = new StringBuilder ("", Sepia2_Import.SEPIA2_SOM_FREQ_TRIGMODE_LEN);
      StringBuilder   cFrequency           = new StringBuilder ("", Sepia2_Import.SEPIA2_SLM_FREQ_TRIGMODE_LEN);
      StringBuilder   cHeadType            = new StringBuilder ("", Sepia2_Import.SEPIA2_SLM_HEADTYPE_LEN);
      StringBuilder   cSerialNumber        = new StringBuilder ("", Sepia2_Import.SEPIA2_SERIALNUMBER_LEN);
      StringBuilder   cSWSModuleType       = new StringBuilder ("", Sepia2_Import.SEPIA2_SWS_MODULETYPE_MAXLEN);
      StringBuilder   cTemp1               = new StringBuilder ("", 65);
      StringBuilder   cTemp2               = new StringBuilder ("", 65);
      StringBuilder   cBuffer              = new StringBuilder ("", 65535);
      StringBuilder   cPreamble            = new StringBuilder ( "\n     Following are system describing common infos,\n     the considerate support team of PicoQuant GmbH\n     demands for your qualified service request:\n\n    =================================================\n\n");
      StringBuilder   cCallingSW           = new StringBuilder ("Demo-Program:   ReadAllDataByMSVCPP.exe\n");
      //
      int []          lBurstChannels       = new int [Sepia2_Import.SEPIA2_SOM_BURSTCHANNEL_COUNT] {0, 0, 0, 0, 0, 0, 0, 0};
      //
      int             iRestartOption                                 = Sepia2_Import.SEPIA2_NO_RESTART;
      int             iDevIdx                                        = -1;
      int             iGivenDevIdx = 0;
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
      bool   bUSBInstGiven = false;
      bool   bSerialGiven  = false;
      bool   bProductGiven = false;
      bool   bNoWait       = false;
      bool   bStayOpened   = false;
      byte   bIsPrimary;
      byte   bIsBackPlane;
      byte   bHasUptimeCounter;
      byte   bLock;
      byte   bSLock;
      byte   bSynchronize = 0;             // for SOM-D
      byte   bPulseMode;
      byte   bDivider;
      byte   bPreSync;
      byte   bMaskSync;
      byte   bOutEnable;
      byte   bSyncEnable;
      byte   bSyncInverse;
      byte   bFineDelayStepCount;      // for SOM-D
      byte   bDelayed;                 // for SOM-D
      byte   bForcedUndelayed;         // for SOM-D
      byte   bFineDelay;               // for SOM-D
      byte   bOutCombi;                // for SOM-D
      byte   bMaskedCombi;             // for SOM-D
      byte   bTrigLevelEnabled;
      byte   bIntensity;
      byte   bTBNdx;                   // for PPL 400
      //
      // word
      ushort  wIntensity;
      ushort  wDivider;
      ushort  wPAPml;                   // for PPL 400
      ushort  wRRPml;                   // for PPL 400
      ushort  wPSPml;                   // for PPL 400
      ushort  wRSPml;                   // for PPL 400
      ushort  wWSPml;                   // for PPL 400
      //
      float           fFrequency = 1;
      float           fIntensity;
      //
      int             lBurstSum;
      uint   ulWaveLength; 
      uint   ulBandWidth;
      short  sBeamVPos;
      short  sBeamHPos;
      uint   ulIntensRaw; 
      uint   ulMainPowerUp;
      uint   ulActivePowerUp;
      uint   ulScaledPowerUp;
      //
      double          f64CoarseDelayStep = 1;   // for SOM-D
      double          f64CoarseDelay     = 1;   // for SOM-D
      //
      Sepia2_Import.T_Module_FWVers SWSFWVers;
      //
      int i, j;
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
          if (Regex.IsMatch(s, "^-stayopened$"))
        {
          bStayOpened = true;
          Console.Write ("    {0}\n", s);
        } else
          if (Regex.IsMatch(s, "^-nowait$"))
        {
          bNoWait = true;
          Console.Write ("    {0}\n", s);
        } else
          if (Regex.IsMatch(s, "^-restart$"))
        {
          iRestartOption = Sepia2_Import.SEPIA2_RESTART;
          Console.Write ("    {0}\n", s);
        } else
        {
          Console.Write ("    {0} : unknown parameter!\n", s);
        }
      }

      Console.Write ("\n\n     PQLaserDrv   Read ALL Values Demo : \n");
      Console.Write ("    =================================================\n\n");
      //
      // preliminaries: check library version
      //
      try {
        Sepia2_Import.SEPIA2_LIB_GetVersion (cLibVersion);
      }
      catch (Exception ex) {
        Console.Write ("\nerror using Sepia2_Lib");
        Console.Write ("\n  Check the existence of the library 'Sepia2_Lib.dll'!");
        Console.Write ("\n  Make sure that your runtime and the library are both either 32-bit or 64-bit!");
        Console.Write ("\n\n  system message: \n{0}\n", ex.Message);
        if (!bNoWait)
        {
          Console.Write ("\npress RETURN... ");
          Console.Read ();
        }
        return;
      }
      Console.Write ("     Lib-Version    = {0}\n", cLibVersion);
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
        Console.Write ("     Product Model  = '{0}'\n\n",     cProductModel);
        Console.Write ("    =================================================\n\n");
        Sepia2_Import.SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion);
        Console.Write ("     FW-Version     = {0}\n",     cFWVersion);
        //
        Console.Write ("     USB Index      = {0}\n", iDevIdx);
        Sepia2_Import.SEPIA2_USB_GetStrDescriptor  (iDevIdx, cDescriptor);
        Console.Write ("     USB Descriptor = {0}\n", cDescriptor);
        Console.Write ("     Serial Number  = '{0}'\n\n", cSepiaSerNo);
        Console.Write ("    =================================================\n\n");
        //
        // get sepia's module map and initialise datastructures for all library functions
        // there are two different ways to do so:
        //
        // first:  if sepia was not touched since last power on, it doesn't need to be restarted
        //         iRestartOption = SEPIA2_NO_RESTART;
        // second: in case of changes with soft restart
        //         iRestartOption = SEPIA2_RESTART;
        //
        if ((iRetVal = Sepia2_Import.SEPIA2_FWR_GetModuleMap (iDevIdx, iRestartOption, out iModuleCount)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
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
              // just to show, what sepia2_lib knows about your system, try this:
              Sepia2_Import.SEPIA2_FWR_CreateSupportRequestText (iDevIdx, cPreamble, cCallingSW, 0, cBuffer.Capacity, cBuffer);
              //
              Console.Write (cBuffer);
              //
              // scan sepia map module by module
              // and iterate by iMapIdx for this approach.
              //
              Console.Write ("\n\n\n    =================================================\n\n\n\n");
              //
              for (iMapIdx = 0; iMapIdx < iModuleCount; iMapIdx++)
              {
                Sepia2_Import.SEPIA2_FWR_GetModuleInfoByMapIdx (iDevIdx, iMapIdx, out iSlotId, out bIsPrimary, out bIsBackPlane, out bHasUptimeCounter);
                //
                if (bIsBackPlane != 0)
                {
                  if ((iRetVal = Sepia2_Import.SEPIA2_COM_GetModuleType (iDevIdx, -1, Sepia2_Import.SEPIA2_PRIMARY_MODULE, out iModuleType)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                  {
                    Sepia2_Import.SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                    Sepia2_Import.SEPIA2_COM_GetSerialNumber  (iDevIdx, -1, Sepia2_Import.SEPIA2_PRIMARY_MODULE, cSerialNumber);
                    Console.Write (" backplane:   module type     '{0}'\n", cModulType);
                    Console.Write ("              serial number   '{0}'\n\n", cSerialNumber);
                  }
                }
                else 
                {
                  //
                  // identify sepiaobject (module) in slot
                  //
                  if ((iRetVal = Sepia2_Import.SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, Sepia2_Import.SEPIA2_PRIMARY_MODULE, out iModuleType)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                  {
                    Sepia2_Import.SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                    Sepia2_Import.SEPIA2_COM_GetSerialNumber  (iDevIdx, iSlotId, Sepia2_Import.SEPIA2_PRIMARY_MODULE, cSerialNumber);
                    Console.Write (" slot {0:000} :   module type     '{1}'\n", iSlotId, cModulType);
                    Console.Write ("              serial number   '{0}'\n\n", cSerialNumber);
                    //
                    // now, continue with modulespecific information
                    //
                    switch (iModuleType)
                    {
                      case Sepia2_Import.SEPIA2OBJECT_SCM  :
                      Sepia2_Import.SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId, out bSLock);
                      Sepia2_Import.SEPIA2_SCM_GetLaserLocked   (iDevIdx, iSlotId, out bLock);
                      Console.Write ("                              laser lock state   :    {0}locked\n", (!((bLock != 0) || (bSLock != 0))? " un": (bLock != bSLock ? " hard" : " soft")));
                      Console.Write ("\n");
                      //
                      break;


                      case Sepia2_Import.SEPIA2OBJECT_SOM:
                      goto case Sepia2_Import.SEPIA2OBJECT_SOMD;
                      case Sepia2_Import.SEPIA2OBJECT_SOMD :
                      for (iFreqTrigIdx = 0; ((iRetVal == Sepia2_Import.SEPIA2_ERR_NO_ERROR) && (iFreqTrigIdx < Sepia2_Import.SEPIA2_SOM_FREQ_TRIGMODE_COUNT)); iFreqTrigIdx++)
                      {
                        if (iModuleType == Sepia2_Import.SEPIA2OBJECT_SOM)
                        {
                          iRetVal = Sepia2_Import.SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                        }
                        else
                        {
                          iRetVal = Sepia2_Import.SEPIA2_SOMD_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                        }
                        if (iRetVal == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                        {
                          if (iFreqTrigIdx == 0)
                          {
                            Console.Write ("{0,46}", "freq./trigmodes ");
                          }
                          else
                          {
                            Console.Write ("{0,46}", "                ");
                          }
                          //
                          Console.Write ("{0:C0}) =     '{1}'", iFreqTrigIdx+1, cFreqTrigMode);
                          //
                          if (iFreqTrigIdx == (Sepia2_Import.SEPIA2_SOM_FREQ_TRIGMODE_COUNT-1))
                          {
                            Console.Write ("\n");
                          }
                          else
                          {
                            Console.Write (",\n");
                          }
                        }
                      }
                      Console.Write ("\n");
                      if (iRetVal == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        if (iModuleType == Sepia2_Import.SEPIA2OBJECT_SOM)
                        {
                          iRetVal = Sepia2_Import.SEPIA2_SOM_GetFreqTrigMode (iDevIdx, iSlotId, out iFreqTrigIdx);
                        }
                        else
                        {
                          iRetVal = Sepia2_Import.SEPIA2_SOMD_GetFreqTrigMode (iDevIdx, iSlotId, out iFreqTrigIdx, out bSynchronize);
                        }
                        if (iRetVal == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                        {
                          if (iModuleType == Sepia2_Import.SEPIA2OBJECT_SOM)
                          {
                            iRetVal = Sepia2_Import.SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                          }
                          else
                          {
                            iRetVal = Sepia2_Import.SEPIA2_SOMD_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                          }
                          if (iRetVal == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                          {
                            Console.Write ("{0,47}  =     '{1}'\n", "act. freq./trigm.", cFreqTrigMode);
                            if ((iModuleType == Sepia2_Import.SEPIA2OBJECT_SOMD) && (iFreqTrigIdx < Sepia2_Import.SEPIA2_SOM_INT_OSC_A))
                            {
                              if (bSynchronize != 0)
                              {
                                Console.Write ("{0,47}        (synchronized,)\n", " ");
                              }
                            }
                            //
                            if (iModuleType == Sepia2_Import.SEPIA2OBJECT_SOM)
                            {
                              iRetVal = Sepia2_Import.SEPIA2_SOM_GetBurstValues (iDevIdx, iSlotId, out bDivider, out bPreSync, out bMaskSync);
                              wDivider = bDivider;
                            }
                            else
                            {
                              iRetVal = Sepia2_Import.SEPIA2_SOMD_GetBurstValues (iDevIdx, iSlotId, out wDivider, out bPreSync, out bMaskSync);
                            }
                            if (iRetVal == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                            {
                              Console.Write ("{0,48} = {1,5:D}\n", "divider           ", wDivider);
                              Console.Write ("{0,48} = {1,5:D}\n", "pre sync          ", bPreSync);
                              Console.Write ("{0,48} = {1,5:D}\n", "masked sync pulses", bMaskSync);
                              //
                              if ( (iFreqTrigIdx == Sepia2_Import.SEPIA2_SOM_TRIGMODE_RISING)
                                  || (iFreqTrigIdx == Sepia2_Import.SEPIA2_SOM_TRIGMODE_FALLING))
                              {
                                if (iModuleType == Sepia2_Import.SEPIA2OBJECT_SOM)
                                {
                                  iRetVal = Sepia2_Import.SEPIA2_SOM_GetTriggerLevel (iDevIdx, iSlotId, out iTriggerMilliVolt);
                                }
                                else
                                {
                                  iRetVal = Sepia2_Import.SEPIA2_SOMD_GetTriggerLevel (iDevIdx, iSlotId, out iTriggerMilliVolt);
                                }
                                if (iRetVal == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                                {
                                  Console.Write ("{0,47}  = {1,5:D} mV\n", "triggerlevel     ", iTriggerMilliVolt);
                                }
                              }
                              else
                              {
                                fFrequency  = float.Parse ( Regex.Match (cFreqTrigMode.ToString(), @"\d*\.\d*").ToString()) * 1.0e6f;
                                fFrequency /= wDivider;
                                Console.Write ("{0,47}  =  {1}\n", "oscillator period", FormatEng (cTemp1, 1.0 / fFrequency, 6, "s",  11, 3));
                                Console.Write ("{0,47}     {1}\n", "i.e.", FormatEng (cTemp1, fFrequency,       6, "Hz", 12, 3));
                                Console.Write ("\n");
                              }
                              if (iRetVal == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                              {
                                if (iModuleType == Sepia2_Import.SEPIA2OBJECT_SOM)
                                {
                                  iRetVal = Sepia2_Import.SEPIA2_SOM_GetOutNSyncEnable (iDevIdx, iSlotId, out bOutEnable, out bSyncEnable, out bSyncInverse);
                                }
                                else
                                {
                                  iRetVal = Sepia2_Import.SEPIA2_SOMD_GetOutNSyncEnable (iDevIdx, iSlotId, out bOutEnable, out bSyncEnable, out bSyncInverse);
                                }
                                if (iRetVal == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                                {
                                  Console.Write ("{0,47}  =     {1}\n\n", "sync mask form   ", (bSyncInverse != 0 ? "inverse" : "regular"));
                                  if (iModuleType == Sepia2_Import.SEPIA2OBJECT_SOM)
                                  {
                                    iRetVal = Sepia2_Import.SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSlotId, out lBurstChannels[0], out lBurstChannels[1], out lBurstChannels[2], out lBurstChannels[3], out lBurstChannels[4], out lBurstChannels[5], out lBurstChannels[6], out lBurstChannels[7]);
                                  }
                                  else
                                  {
                                    iRetVal = Sepia2_Import.SEPIA2_SOMD_GetBurstLengthArray (iDevIdx, iSlotId, out lBurstChannels[0], out lBurstChannels[1], out lBurstChannels[2], out lBurstChannels[3], out lBurstChannels[4], out lBurstChannels[5], out lBurstChannels[6], out lBurstChannels[7]);
                                  }
                                  if (iRetVal == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                                  {
                                    Console.Write ("{0,44} ch. | sync | burst len |  out\n", "burst data    ");
                                    Console.Write ("{0,44}-----+------+-----------+------\n", " ");
                                    //
                                    for (i = 0, lBurstSum = 0; i < Sepia2_Import.SEPIA2_SOM_BURSTCHANNEL_COUNT; i++)
                                    {
                                      Console.Write ("{0,46}{1,1}  |    {2,1} | {3,9} |    {4,1}\n", " ", i+1, ((bSyncEnable >> i) & 1), lBurstChannels[i], ((bOutEnable >> i) & 1));
                                      lBurstSum += lBurstChannels[i];
                                    }
                                    Console.Write ("{0,41}--------+------+ +  -------+------\n", " ");
                                    Console.Write ("{0,41}Hex/Sum | 0x{1:X2} | ={2,8} | 0x{3:X2}\n", " ", bSyncEnable, lBurstSum, bOutEnable);
                                    Console.Write ("\n");
                                    if ( (iFreqTrigIdx != Sepia2_Import.SEPIA2_SOM_TRIGMODE_RISING)
                                        && (iFreqTrigIdx != Sepia2_Import.SEPIA2_SOM_TRIGMODE_FALLING))
                                    {
                                      fFrequency /= lBurstSum;
                                      Console.Write ("{0,47}  =  {1}\n", "sequencer period", FormatEng (cTemp1, 1.0 / fFrequency, 6, "s",  11, 3));
                                      Console.Write ("{0,47}     {1}\n", "i.e.", FormatEng (cTemp1, fFrequency,       6, "Hz", 12, 3));
                                      Console.Write ("\n");
                                    }
                                    if (iModuleType == Sepia2_Import.SEPIA2OBJECT_SOMD)
                                    {
                                      iRetVal = Sepia2_Import.SEPIA2_SOMD_GetDelayUnits (iDevIdx, iSlotId, ref f64CoarseDelayStep, out bFineDelayStepCount);
                                      Console.Write ("{0,44}     | combiner |\n", " ");
                                      Console.Write ("{0,44}     | channels |\n", " ");
                                      Console.Write ("{0,44} out | 12345678 | delay\n", " ");
                                      Console.Write ("{0,44}-----+----------+------------------\n", " ");
                                      for (j = 0; j < Sepia2_Import.SEPIA2_SOM_BURSTCHANNEL_COUNT; j++)
                                      {
                                        iRetVal = Sepia2_Import.SEPIA2_SOMD_GetSeqOutputInfos (iDevIdx, iSlotId, Convert.ToByte(j), out bDelayed, out bForcedUndelayed, out bOutCombi, out bMaskedCombi, ref f64CoarseDelay, out bFineDelay);
                                        if ((bDelayed | bForcedUndelayed) == 0)
                                        {
                                          StringBuilder sOutCombi = new StringBuilder( Convert.ToString (bOutCombi, 2).PadLeft (8, '0') );
                                          sOutCombi.Replace ('0', '_');
                                          sOutCombi.Replace ('1', bMaskedCombi != 0 ? '1' : 'B');
                                          char[] aOutCombi = sOutCombi.ToString().ToCharArray();
                                          Array.Reverse (aOutCombi);
                                          sOutCombi.Length = 0;
                                          sOutCombi.Append (aOutCombi);
                                          Console.Write ("{0,46}{1,1}  | {2} |\n", " ", j+1, sOutCombi);
                                        }
                                        else
                                        {
                                          StringBuilder sOutCombi = new StringBuilder( Convert.ToString (1 << j, 2).PadLeft (8, '0') );
                                          sOutCombi.Replace ('0', '_');
                                          sOutCombi.Replace ('1', 'D');
                                          char[] aOutCombi = sOutCombi.ToString().ToCharArray();
                                          Array.Reverse (aOutCombi);
                                          sOutCombi.Length = 0;
                                          sOutCombi.Append (aOutCombi);
                                          Console.Write ("{0,46}{1,1}  | {2} |{3} + {4,2}a.u.\n", " ", j+1, sOutCombi, FormatEng (cTemp2, f64CoarseDelay * 1e-9, 4, "s", 9, 1, false), bFineDelay);
                                        }
                                      }
                                      Console.Write ("\n");
                                      Console.Write ("{0,46}   = D: delayed burst,   no combi\n",   "combiner legend ");
                                      Console.Write ("{0,46}     B: combi burst, any non-zero\n",   " ");
                                      Console.Write ("{0,46}     1: 1st pulse,   any non-zero\n\n", " ");
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                      break;


                      case Sepia2_Import.SEPIA2OBJECT_SLM  :

                      if ((iRetVal = Sepia2_Import.SEPIA2_SLM_GetPulseParameters (iDevIdx, iSlotId,  out iFreqTrigIdx, out bPulseMode, out iHead)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        Sepia2_Import.SEPIA2_SLM_DecodeFreqTrigMode (iFreqTrigIdx, cFrequency);
                        Sepia2_Import.SEPIA2_SLM_DecodeHeadType     (iHead, cHeadType);
                        //
                        Console.Write ("{0,47}  =     '{1}'\n",        "freq / trigmode  ", cFrequency);
                        Console.Write ("{0,47}  =     'pulses {1}'\n", "pulsmode         ", (bPulseMode != 0 ? "enabled" : "disabled"));
                        Console.Write ("{0,47}  =     '{1}'\n",        "headtype         ", cHeadType);
                      }
                      if ((iRetVal = Sepia2_Import.SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSlotId, out wIntensity)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        Console.Write ("{0,47}  =   {1,5:F1}%\n",     "intensity        ", 0.1*wIntensity);
                      }
                      Console.Write ("\n");
                      break;


                      case Sepia2_Import.SEPIA2OBJECT_SML  :
                      if ((iRetVal = Sepia2_Import.SEPIA2_SML_GetParameters (iDevIdx, iSlotId, out bPulseMode, out iHead, out bIntensity)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        Sepia2_Import.SEPIA2_SML_DecodeHeadType     (iHead, cHeadType);
                        //
                        Console.Write ("{0,47}  =     pulses %s\n", "pulsmode         ", (bPulseMode != 0 ? "enabled" : "disabled"));
                        Console.Write ("{0,47}  =     {1}\n",        "headtype         ", cHeadType);
                        Console.Write ("{0,47}  =   {1,3}%\n",        "intensity        ", bIntensity);
                        Console.Write ("\n");
                      }
                      break;


                      case Sepia2_Import.SEPIA2OBJECT_SPM  :
                      if ((iRetVal = Sepia2_Import.SEPIA2_SPM_GetFWVersion (iDevIdx, iSlotId, out SWSFWVers)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        Console.Write ("{0,47}  =     {1}.{2}.{3}\n", "firmware version ", SWSFWVers.VersMaj, SWSFWVers.VersMin, SWSFWVers.BuildNr);
                      }
                      break;


                      case Sepia2_Import.SEPIA2OBJECT_SWS  :
                      if ((iRetVal = Sepia2_Import.SEPIA2_SWS_GetFWVersion (iDevIdx, iSlotId, out SWSFWVers)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        Console.Write ("{0,47}  =     {1}.{2}.{3}\n", "firmware version ", SWSFWVers.VersMaj, SWSFWVers.VersMin, SWSFWVers.BuildNr);
                      }
                      if ((iRetVal = Sepia2_Import.SEPIA2_SWS_GetModuleType (iDevIdx, iSlotId, out iSWSModuleType)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        Sepia2_Import.SEPIA2_SWS_DecodeModuleType (iSWSModuleType, cSWSModuleType);
                        Console.Write ("{0,47}  =     {1}\n",       "SWS module type ", cSWSModuleType);
                      }
                      if ((iRetVal = Sepia2_Import.SEPIA2_SWS_GetParameters (iDevIdx, iSlotId, out ulWaveLength, out ulBandWidth)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        //
                        Console.Write ("{0,47}  =  {1,8:F3} nm \n",    "wavelength       ", 0.001 * ulWaveLength);
                        Console.Write ("{0,47}  =  {1,8:F3} nm \n",    "bandwidth        ", 0.001 * ulBandWidth);
                        Console.Write ("\n");
                      }
                      if ((iRetVal = Sepia2_Import.SEPIA2_SWS_GetIntensity (iDevIdx, iSlotId, out ulIntensRaw, out fIntensity)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        Console.Write ("{0,47}  = 0x{1,4:X4} a.u. i.e. ~ {2:F1}nA\n",    "power diode      ", ulIntensRaw, fIntensity);
                        Console.Write ("\n");
                      }
                      if ((iRetVal = Sepia2_Import.SEPIA2_SWS_GetBeamPos (iDevIdx, iSlotId, out sBeamVPos, out sBeamHPos)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        Console.Write ("{0,47}  =   {1,3} steps\n",    "horiz. beamshift ", sBeamHPos);
                        Console.Write ("{0,47}  =   {1,3} steps\n",    "vert.  beamshift ", sBeamVPos);
                        Console.Write ("\n");
                      }
                      break;


                      case Sepia2_Import.SEPIA2OBJECT_SSM  :
                      if ((iRetVal = Sepia2_Import.SEPIA2_SSM_GetTriggerData (iDevIdx, iSlotId, out iFreqTrigIdx, out iTriggerMilliVolt)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        //
                        Sepia2_Import.SEPIA2_SSM_DecodeFreqTrigMode    (iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode, out iFreq, out bTrigLevelEnabled);
                        Console.Write ("{0,47}  =     '{1}'\n", "act. freq./trigm.", cFreqTrigMode);
                        if (bTrigLevelEnabled != 0)
                        {
                          Console.Write ("{0,47}  = {1:D5} mV\n", "triggerlevel     ", iTriggerMilliVolt);
                        }
                      }
                      break;


                      case Sepia2_Import.SEPIA2OBJECT_SWM  :
                      if ((iRetVal = Sepia2_Import.SEPIA2_SWM_GetCurveParams (iDevIdx, iSlotId, 1, out bTBNdx, out wPAPml, out wRRPml, out wPSPml, out wRSPml, out wWSPml)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        Console.Write ("{0,47}\n",                "Curve 1:         ");
                        Console.Write ("{0,47}  =   {1,3}\n",      "TBNdx            ", bTBNdx);
                        Console.Write ("{0,47}  =  {1,6:F1}%\n",    "PAPml            ", 0.1 * wPAPml);
                        Console.Write ("{0,47}  =  {1,6:F1}%\n",    "RRPml            ", 0.1 * wRRPml);
                        Console.Write ("{0,47}  =  {1,6:F1}%\n",    "PSPml            ", 0.1 * wPSPml);
                        Console.Write ("{0,47}  =  {1,6:F1}%\n",    "RSPml            ", 0.1 * wRSPml);
                        Console.Write ("{0,47}  =  {1,6:F1}%\n",    "WSPml            ", 0.1 * wWSPml);
                      }
                      if ((iRetVal = Sepia2_Import.SEPIA2_SWM_GetCurveParams (iDevIdx, iSlotId, 2, out bTBNdx, out wPAPml, out wRRPml, out wPSPml, out wRSPml, out wWSPml)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                      {
                        Console.Write ("{0,47}\n",                "Curve 2:         ");
                        Console.Write ("{0,47}  =   {1,3}\n",      "TBNdx            ", bTBNdx);
                        Console.Write ("{0,47}  =  {1,6:F1}%\n",    "PAPml            ", 0.1 * wPAPml);
                        Console.Write ("{0,47}  =  {1,6:F1}%\n",    "RRPml            ", 0.1 * wRRPml);
                        Console.Write ("{0,47}  =  {1,6:F1}%\n",    "PSPml            ", 0.1 * wPSPml);
                        Console.Write ("{0,47}  =  {1,6:F1}%\n",    "RSPml            ", 0.1 * wRSPml);
                        Console.Write ("{0,47}  =  {1,6:F1}%\n",    "WSPml            ", 0.1 * wWSPml);
                      }
                      break;


                      default : break;
                    }
                  }
                }
                //
                if (iRetVal == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                {
                  //
                  if (bIsPrimary == 0)
                  {
                    if ((iRetVal = Sepia2_Import.SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, Sepia2_Import.SEPIA2_SECONDARY_MODULE, out iModuleType)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
                    {
                      Sepia2_Import.SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                      Sepia2_Import.SEPIA2_COM_GetSerialNumber  (iDevIdx, iSlotId, Sepia2_Import.SEPIA2_SECONDARY_MODULE, cSerialNumber);
                      Console.Write ("\n              secondary mod.  '{0}'\n", cModulType);
                      Console.Write ("              serial number   '{0}'\n\n", cSerialNumber);
                    }
                  }
                  //
                  if (bHasUptimeCounter != 0)
                  {
                    Sepia2_Import.SEPIA2_FWR_GetUptimeInfoByMapIdx (iDevIdx, iMapIdx, out ulMainPowerUp, out ulActivePowerUp, out ulScaledPowerUp);
                    PrintUptimers (ulMainPowerUp, ulActivePowerUp, ulScaledPowerUp);
                  }
                }
              }
            }
          }
        } // get module map
        else
        {
          Sepia2_Import.SEPIA2_LIB_DecodeError (iRetVal, cErrString);
          Console.Write ("     ERROR {0:D5}:    '{1}'\n\n", iRetVal, cErrString);
          if ((iRetVal = Sepia2_Import.SEPIA2_FWR_GetLastError (iDevIdx, out iFWErrCode, out iFWErrPhase, out iFWErrLocation, out iFWErrSlot, cFWErrCond)) == Sepia2_Import.SEPIA2_ERR_NO_ERROR)
          {
            if (iFWErrCode != Sepia2_Import.SEPIA2_ERR_NO_ERROR)
            {
              Sepia2_Import.SEPIA2_LIB_DecodeError  (iFWErrCode,  cErrString);
              Sepia2_Import.SEPIA2_FWR_DecodeErrPhaseName (iFWErrPhase, cFWErrPhase);
              Console.Write ("     Firmware error detected:\n");
              Console.Write ("        error code      : {0:D5},   i.e. '{1}'\n", iFWErrCode,  cErrString);
              Console.Write ("        error phase     : {0:D5},   i.e. '{1}'\n", iFWErrPhase, cFWErrPhase);
              Console.Write ("        error location  : {0:D5}\n",  iFWErrLocation);
              Console.Write ("        error slot      : {0:D5}\n",  iFWErrSlot);
              if (cFWErrCond.Length > 0)
              {
                Console.Write ("        error condition : '{0}'\n", cFWErrCond);
              }
            }
          }
        }
        //
        Sepia2_Import.SEPIA2_FWR_FreeModuleMap (iDevIdx);
        if (bStayOpened)
        {
          Console.Write ("\npress RETURN to close Sepia... ");
          Console.Read ();
        }
        Sepia2_Import.SEPIA2_USB_CloseDevice   (iDevIdx);
      }
      else
      {
        Sepia2_Import.SEPIA2_LIB_DecodeError (iRetVal, cErrString);
        Console.Write ("     ERROR {0:D5}:    '{1}'\n\n", iRetVal, cErrString);
      }

      Console.Write ("\n");

      if (!bNoWait)
      {
        Console.Write ("\npress RETURN... ");
        Console.Read ();
      }
    }
  }
}
