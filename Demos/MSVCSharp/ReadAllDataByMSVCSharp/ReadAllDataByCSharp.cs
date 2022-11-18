using System;
using System.Collections.Generic;
using System.Text;

namespace PQ.Sepia2
{
  public static partial class MigrationHelper
  {
    public static class ReadAllDataByCSharp
    {
      //-----------------------------------------------------------------------------
      //
      //    ReadAllDataByCSharp
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
      //          introduced SOM-D Oscillator Module w. Delay Option (V1.1.xx.450)
      //
      //  apo  22.01.21   adapted to DLL version 1.2.<target>.<svn_build>
      //
      //  apo  28.01.21   introduced VIR, VUV module functions (for VisUV/IR) (V1.2.xx.641)
      //
      //  apo  30.08.22   introduced PRI module functions (for Prima, Quader) (V1.2.xx.753)
      //
      //-----------------------------------------------------------------------------
      //

      private const string STR_SEPARATORLINE = "  ============================================================";

      public static void PrintUptimers(ulong ulMainPowerUp, ulong ulActivePowerUp, ulong ulScaledPowerUp)
      {
        long hlp;
        //
        hlp = (long)(5.0 * (ulMainPowerUp + 0x7F) / 0xFF);
        Console.WriteLine("");
        Console.WriteLine("{0,47}  = {1,5}:{2,2:D2} h", "main power uptime", hlp / 60, hlp % 60);
        //
        if (ulActivePowerUp > 1)
        {
          hlp = (int)(5.0 * (ulActivePowerUp + 0x7F) / 0xFF);
          Console.WriteLine("{0,47}  = {1,5}:{2,2:D2} hrs", "act. power uptime", hlp / 60, hlp % 60);
          //
          if (ulScaledPowerUp > (0.001 * ulActivePowerUp))
          {
            Console.WriteLine("{0,47}  =       {1,5:F1}%", "pwr scaled factor", 100.0 * ulScaledPowerUp / ulActivePowerUp);
            Console.WriteLine("");
          }
        }
        Console.WriteLine("");
      }

      private static bool HasFWError(int iFWErr, int iPhase, int iLocation, int iSlot, string cFWErrCond, string cPromptString)
      {
        StringBuilder cErrTxt = new StringBuilder(Sepia2_Lib.SEPIA2_ERRSTRING_LEN);
        StringBuilder cPhase = new StringBuilder(Sepia2_Lib.SEPIA2_FW_ERRPHASE_LEN);
        //
        bool bRet = (iFWErr != Sepia2_Lib.SEPIA2_ERR_NO_ERROR);
        //
        if (bRet)
        {
          Console.WriteLine("          {0}", cPromptString);
          Console.WriteLine("");
          Sepia2_Lib.SEPIA2_LIB_DecodeError(iFWErr, cErrTxt);
          Sepia2_Lib.SEPIA2_FWR_DecodeErrPhaseName(iPhase, cPhase);
          Console.WriteLine("        error code    : {0,5},   i.e. '{1}'", iFWErr, cErrTxt);
          Console.WriteLine("        error phase   : {0,5},   i.e. '{1}'", iPhase, cPhase);
          Console.WriteLine("        error location  : {0,5}", iLocation);
          Console.WriteLine("        error slot    :   {0:000}", iSlot);
          if (cFWErrCond.Length > 0)
          {
            Console.WriteLine("        error condition : '{0}'", cFWErrCond);
          }
          Console.WriteLine("");
        }
        //
        return bRet;
      }

      private static T_PRI_Constants PRIConst;

      public static int main(string[] argv)
      {
        System.Threading.Thread.CurrentThread.CurrentCulture = new System.Globalization.CultureInfo("en-US");

        #region buffers and variables

        int iRetVal = Sepia2_Lib.SEPIA2_ERR_NO_ERROR;
        bool bRet;

        //
        StringBuilder cLibVersion = new StringBuilder(Sepia2_Lib.SEPIA2_VERSIONINFO_LEN);
        StringBuilder cDescriptor = new StringBuilder(Sepia2_Lib.SEPIA2_USB_STRDECR_LEN);
        StringBuilder cSepiaSerNo = new StringBuilder(Sepia2_Lib.SEPIA2_SERIALNUMBER_LEN);
        StringBuilder cGivenSerNo = new StringBuilder(Sepia2_Lib.SEPIA2_SERIALNUMBER_LEN);
        StringBuilder cProductModel = new StringBuilder(Sepia2_Lib.SEPIA2_PRODUCTMODEL_LEN);
        StringBuilder cGivenProduct = new StringBuilder(Sepia2_Lib.SEPIA2_PRODUCTMODEL_LEN);
        StringBuilder cFWVersion = new StringBuilder(Sepia2_Lib.SEPIA2_VERSIONINFO_LEN);
        StringBuilder cFWErrCond = new StringBuilder(Sepia2_Lib.SEPIA2_FW_ERRCOND_LEN);
        StringBuilder cFWErrPhase = new StringBuilder(Sepia2_Lib.SEPIA2_FW_ERRPHASE_LEN);
        StringBuilder cErrString = new StringBuilder(Sepia2_Lib.SEPIA2_ERRSTRING_LEN);
        StringBuilder cModulType = new StringBuilder(Sepia2_Lib.SEPIA2_MODULETYPESTRING_LEN);
        StringBuilder cFreqTrigMode = new StringBuilder(Sepia2_Lib.SEPIA2_SOM_FREQ_TRIGMODE_LEN);
        StringBuilder cFrequency = new StringBuilder(Sepia2_Lib.SEPIA2_SLM_FREQ_TRIGMODE_LEN);
        StringBuilder cHeadType = new StringBuilder(Sepia2_Lib.SEPIA2_SLM_HEADTYPE_LEN);
        StringBuilder cSerialNumber = new StringBuilder(Sepia2_Lib.SEPIA2_SERIALNUMBER_LEN);
        StringBuilder cSWSModuleType = new StringBuilder(Sepia2_Lib.SEPIA2_SWS_MODULETYPE_LEN);
        StringBuilder cTemp1 = new StringBuilder(65);
        StringBuilder cTemp2 = new StringBuilder(65);
        StringBuilder cBuffer = new StringBuilder(262145);
        StringBuilder cPreamble = new StringBuilder();
        StringBuilder cCallingSW = new StringBuilder();
        StringBuilder cDevType = new StringBuilder(Sepia2_Lib.SEPIA2_VUV_VIR_DEVTYPE_LEN);
        StringBuilder cTrigMode = new StringBuilder(Sepia2_Lib.SEPIA2_VUV_VIR_TRIGINFO_LEN);
        StringBuilder cFreqTrigSrc = new StringBuilder(Sepia2_Lib.SEPIA2_VUV_VIR_TRIGINFO_LEN);
        StringBuilder cDevFWVers = new StringBuilder(Sepia2_Lib.SEPIA2_PRI_DEVICE_FW_LEN);
        StringBuilder cDevID = new StringBuilder(Sepia2_Lib.SEPIA2_PRI_DEVICE_ID_LEN);
        StringBuilder cOpMode = new StringBuilder(Sepia2_Lib.SEPIA2_PRI_OPERMODE_LEN);
        StringBuilder cTrigSrc = new StringBuilder(Sepia2_Lib.SEPIA2_PRI_TRIGSRC_LEN);
        //
        int[] lBurstChannels = new int[Sepia2_Lib.SEPIA2_SOM_BURSTCHANNEL_COUNT] { 0, 0, 0, 0, 0, 0, 0, 0 };
        //
        int iRestartOption = Sepia2_Lib.SEPIA2_NO_RESTART;
        int iDevIdx = -1;
        int iGivenDevIdx = 0;
        //
        int iModuleCount;
        int iFWErrCode;
        int iFWErrPhase;
        int iFWErrLocation;
        int iFWErrSlot;
        int iMapIdx;
        int iSlotId;
        int iModuleType;
        int iFreqTrigIdx;
        int iFrequency;
        int iHead;
        int iTrigSrcIdx;
        int iFreqDivIdx;
        int iTriggerMilliVolt;
        int iIntensity;
        int iSWSModuleType;
        //
        int iWL_Idx;
        int iOM_Idx;
        int iTS_Idx;
        int iMinFreq;
        int iMaxFreq;
        int iFreq;
        int iMinTrgLvl;
        int iMaxTrgLvl;
        int iResTrgLvl;
        int iMinOnTime;
        int iMaxOnTime;
        int iOnTime;
        int iMinOffTimefact;
        int iMaxOffTimefact;
        int iOffTimefact;
        int iFormatWidth;
        int iDummy;
        //
        //
        // byte
        bool bUSBInstGiven = false;
        bool bSerialGiven = false;
        bool bProductGiven = false;
        bool bNoWait = false;
        bool bStayOpened = false;
        byte bLinux = 0;
        byte bIsPrimary;
        byte bIsBackPlane;
        byte bHasUptimeCounter;
        byte bLock;
        byte bSLock;
        byte bSynchronize = 0;       // for SOM-D
        byte bPulseMode;
        byte bDivider;
        byte bPreSync;
        byte bMaskSync;
        byte bOutEnable;
        byte bSyncEnable;
        byte bSyncInverse;
        byte bFineDelayStepCount;  // for SOM-D
        byte bDelayed;             // for SOM-D
        byte bForcedUndelayed;     // for SOM-D
        byte bFineDelay;           // for SOM-D
        byte bOutCombi;            // for SOM-D
        byte bMaskedCombi;         // for SOM-D
        byte bTrigLevelEnabled;
        byte bIntensity;
        byte bTBNdx;               // for PPL 400
        byte bHasCW;               // for VisUV/IR
        byte bHasFanSwitch;        // for VisUV/IR
        byte bIsFanRunning;        // for VisUV/IR
        byte bDivListEnabled;      // for VisUV/IR
        byte bTrigLvlEnabled;      // for VisUV/IR, Prima/Quader
        byte bFreqncyEnabled;      // for Prima/Quader
        byte bGatingEnabled;       // for Prima/Quader
        byte bGateHiImp;           // for Prima/Quader
        byte bDummy1;              // for VisUV/IR, Prima/Quader
        byte bDummy2;              // for VisUV/IR, Prima/Quader
        //
        // word
        ushort wIntensity;
        ushort wDivider = 0;
        ushort wPAPml;           // for PPL 400
        ushort wRRPml;           // for PPL 400
        ushort wPSPml;           // for PPL 400
        ushort wRSPml;           // for PPL 400
        ushort wWSPml;           // for PPL 400
        //
        // float
        float fGatePeriod;       // for Prima/Quader
        float fFrequency = 0;
        float fIntensity;
        //
        int lBurstSum;
        uint ulWaveLength;
        uint ulBandWidth;
        short sBeamVPos;
        short sBeamHPos;
        uint ulIntensRaw;
        uint ulMainPowerUp;
        uint ulActivePowerUp;
        uint ulScaledPowerUp;
        //
        double f64CoarseDelayStep;     // for SOM-D
        double f64CoarseDelay;       // for SOM-D
        //
        Sepia2_Lib.T_Module_FWVers SWSFWVers;
        //
        int i, j, pos;
        //
        //
        #endregion buffers and variables
        //
        Sepia2_Lib.SEPIA2_LIB_IsRunningOnWine(out bLinux);
        if (bLinux != 0)
        {
          Console.Out.NewLine = "\n";
        }
        else
        {
          Console.Out.NewLine = "\r\n";
        }
        //
        cPreamble.Length = 0;
        cPreamble.AppendFormat("{0}   Following are system describing common infos,{0}   the considerate support team of PicoQuant GmbH{0}   demands for your qualified service request:{0}{0}  ============================================================{0}{0}", Console.Out.NewLine);
        //
        cCallingSW.Length = 0;
        cCallingSW.AppendFormat("Demo-Program:   ReadAllDataByMSVCSharp.exe{0}", Console.Out.NewLine);
        //
        if (argv.Length == 0)
        {
          Console.WriteLine(" called without parameters");
        }
        else
        {
          Console.WriteLine(" called with {0} Parameter{1}:", argv.Length, (argv.Length > 1) ? "s" : "");
          //
          #region CMD-Args checks
          //
          string cmd_arg;
          for (i = 0; i < argv.Length; i++)
          {
            cmd_arg = argv[i];
            if (cmd_arg == null)
              continue;
            //
            if ((pos = cmd_arg.IndexOf("-inst=")) >= 0)
            {
              if (!Int32.TryParse(cmd_arg.Substring(pos + 6), out iGivenDevIdx))
                throw new Exception("error: param \"-inst=\" is not an integer");
              //
              bUSBInstGiven = true;
              Console.WriteLine("    -inst={0}", iGivenDevIdx);
            }
            else if ((pos = cmd_arg.IndexOf("-serial=")) >= 0)
            {
              cmd_arg = cmd_arg.Substring(pos + 8);
              if (cmd_arg.Length > Sepia2_Lib.SEPIA2_SERIALNUMBER_LEN)
                cGivenSerNo.Append(cmd_arg.Substring(0, Sepia2_Lib.SEPIA2_SERIALNUMBER_LEN));
              else
                cGivenSerNo.Append(cmd_arg);
              //
              bSerialGiven = (cGivenSerNo.Length > 0);
              Console.WriteLine("    -serial={0}", cGivenSerNo);
            }
            else if ((pos = cmd_arg.IndexOf("-product=")) >= 0)
            {
              cmd_arg = cmd_arg.Substring(pos + 9);
              if (cmd_arg.Length > Sepia2_Lib.SEPIA2_PRODUCTMODEL_LEN)
                cGivenProduct.Append(cmd_arg.Substring(0, Sepia2_Lib.SEPIA2_PRODUCTMODEL_LEN));
              else
                cGivenProduct.Append(cmd_arg);
              //
              Console.WriteLine("    -product={0}", cGivenProduct);
              bProductGiven = (cGivenProduct.Length > 0);
            }
            else if (cmd_arg.IndexOf("-stayopened") >= 0)
            {
              bStayOpened = true;
              Console.WriteLine("    -stayopened");
            }
            else if (cmd_arg.IndexOf("-nowait") >= 0)
            {
              bNoWait = true;
              Console.WriteLine("    -nowait");
            }
            else if (cmd_arg.IndexOf("-restart") >= 0)
            {
              iRestartOption = Sepia2_Lib.SEPIA2_RESTART;
              Console.WriteLine("    -restart");
            }
            else
            {
              Console.WriteLine("    {0} : unknown parameter!", cmd_arg);
            }
          }
          //
          #endregion CMD-Args checks
        }
        //
        Console.WriteLine(""); Console.WriteLine("");
        Console.WriteLine("     PQLaserDrv   Read ALL Values Demo : ");
        Console.Write("{0}", STR_SEPARATORLINE);
        Console.WriteLine(""); Console.WriteLine("");
        //
        #region preliminaries: check library version
        //
        // preliminaries: check library version
        //
        try
        {
          iRetVal = Sepia2_Lib.SEPIA2_LIB_GetVersion(cLibVersion);
          if (Sepia2FunctionSucceeds(iRetVal, "LIB_GetVersion", NO_DEVIDX, NO_IDX_1, NO_IDX_2))
          {
            Console.WriteLine("     Lib-Version  = {0}", cLibVersion);
          }
        }
        catch (Exception ex)
        {
          Console.WriteLine("error using {0}", Sepia2_Lib.SEPIA2_LIB);
          Console.WriteLine("  Check the existence of the library '{0}'!", Sepia2_Lib.SEPIA2_LIB);
          Console.WriteLine("  Make sure that your runtime and the library are both either 32-bit or 64-bit!");
          Console.WriteLine("");
          Console.WriteLine("  system message: {0}", ex.Message);
          if (!bNoWait)
          {
            Console.WriteLine("press RETURN... ");
            Console.ReadLine();
          }
          return Sepia2_Lib.SEPIA2_ERR_LIB_UNKNOWN_ERROR_CODE;
        }
        //
        if (!cLibVersion.ToString().StartsWith(Sepia2_Lib.LIB_VERSION_REFERENCE.Substring(0, Sepia2_Lib.LIB_VERSION_REFERENCE_COMPLEN)))
        {
          Console.WriteLine("");
          Console.WriteLine("     Warning: This demo application was built for version  {0}!", Sepia2_Lib.LIB_VERSION_REFERENCE);
          Console.WriteLine("              Continuing may cause unpredictable results!");
          Console.WriteLine("");
          Console.Write("     Do you want to continue anyway? (y/n): ");

          string user_inp = Console.ReadLine();
          if (Char.ToUpper(user_inp[0]) != 'Y')
          {
            return (-1);
          }
          Console.WriteLine("");
        }

        #endregion check library version
        //
        #region Establish USB connection to the Sepia first matching all given conditions
        //
        // establish USB connection to the Sepia first matching all given conditions
        //
        for (i = (bUSBInstGiven ? iGivenDevIdx : 0); i < (bUSBInstGiven ? iGivenDevIdx + 1 : Sepia2_Lib.SEPIA2_MAX_USB_DEVICES); i++)
        {
          cSepiaSerNo.Length = 0;
          cProductModel.Length = 0;
          //
          iRetVal = Sepia2_Lib.SEPIA2_USB_OpenGetSerNumAndClose(i, cProductModel, cSepiaSerNo);
          if ((iRetVal == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
            && (((bSerialGiven && bProductGiven)
            && (cGivenSerNo.Equals(cSepiaSerNo))
            && (cGivenProduct.Equals(cProductModel))
            )
            || ((!bSerialGiven != !bProductGiven)
            && ((cGivenSerNo.Equals(cSepiaSerNo))
               || (cGivenProduct.Equals(cProductModel))
               )
            )
            || (!bSerialGiven && !bProductGiven)
            )
            )
          {
            iDevIdx = bUSBInstGiven ? ((iGivenDevIdx == i) ? i : -1) : i;
            break;
          }
        }
        //
        #endregion Establish USB connection to the Sepia first matching all given conditions
        //
        iRetVal = Sepia2_Lib.SEPIA2_USB_OpenDevice(iDevIdx, cProductModel, cSepiaSerNo);
        if (Sepia2FunctionSucceeds(iRetVal, "USB_OpenDevice", iDevIdx, NO_IDX_1, NO_IDX_2))
        {
          #region Print some information about the device
          //
          Console.WriteLine("     Product Model  = '{0}'", cProductModel);
          Console.WriteLine("");
          Console.WriteLine("{0}", STR_SEPARATORLINE);
          Console.WriteLine("");
          iRetVal = Sepia2_Lib.SEPIA2_FWR_GetVersion(iDevIdx, cFWVersion);
          if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetVersion", iDevIdx, NO_IDX_1, NO_IDX_2))
          {
            Console.WriteLine("     FW-Version   = {0}", cFWVersion);
          }
          //
          Console.WriteLine("     USB Index    = {0}", iDevIdx);
          iRetVal = Sepia2_Lib.SEPIA2_USB_GetStrDescriptor(iDevIdx, cDescriptor);
          if (Sepia2FunctionSucceeds(iRetVal, "USB_GetStrDescriptor", iDevIdx, NO_IDX_1, NO_IDX_2))
          {
            Console.WriteLine("     USB Descriptor = {0}", cDescriptor);
          }
          Console.WriteLine("     Serial Number  = '{0}'", cSepiaSerNo);
          Console.WriteLine("");
          Console.WriteLine("{0}", STR_SEPARATORLINE);
          Console.WriteLine("");
          //
          #endregion Print some information about the device
          //
          // get sepia's module map and initialise datastructures for all library functions
          // there are two different ways to do so:
          //
          // first:  if sepia was not touched since last power on, it doesn't need to be restarted
          //     iRestartOption = SEPIA2_NO_RESTART;
          // second: in case of changes with soft restart
          //     iRestartOption = SEPIA2_RESTART;
          //
          iRetVal = Sepia2_Lib.SEPIA2_FWR_GetModuleMap(iDevIdx, iRestartOption, out iModuleCount);
          if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetModuleMap", iDevIdx, NO_IDX_1, NO_IDX_2))
          {
            //
            // this is to inform us about possible error conditions during sepia's last startup
            //
            iRetVal = Sepia2_Lib.SEPIA2_FWR_GetLastError(iDevIdx, out iFWErrCode, out iFWErrPhase, out iFWErrLocation, out iFWErrSlot, cFWErrCond);
            if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetLastError", iDevIdx, NO_IDX_1, NO_IDX_2))
            {
              if (!HasFWError(iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond.ToString(), "Error detected by firmware on last restart:"))
              {
                // just to show, what sepia2_lib knows about your system, try this:
                iRetVal = Sepia2_Lib.SEPIA2_FWR_CreateSupportRequestText(iDevIdx, cPreamble, cCallingSW, 0, cBuffer.Capacity, cBuffer);
                if (Sepia2FunctionSucceeds(iRetVal, "FWR_CreateSupportRequestText", iDevIdx, NO_IDX_1, NO_IDX_2))
                {
                  //
                  Console.WriteLine("{0}", cBuffer);
                }
                //
                // scan sepia map module by module
                // and iterate by iMapIdx for this approach.
                //        
                Console.WriteLine(""); Console.WriteLine("");
                Console.WriteLine("{0}", STR_SEPARATORLINE);
                Console.WriteLine(""); Console.WriteLine(""); Console.WriteLine("");
                //
                for (iMapIdx = 0; iMapIdx < iModuleCount; iMapIdx++)
                {
                  iRetVal = Sepia2_Lib.SEPIA2_FWR_GetModuleInfoByMapIdx(iDevIdx, iMapIdx, out iSlotId, out bIsPrimary, out bIsBackPlane, out bHasUptimeCounter);
                  if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetModuleInfoByMapIdx", iDevIdx, iMapIdx, NO_IDX_2))
                  {
                    //
                    if (bIsBackPlane != 0)
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_COM_GetModuleType(iDevIdx, -1, Sepia2_Lib.SEPIA2_PRIMARY_MODULE, out iModuleType);
                      if (Sepia2FunctionSucceeds(iRetVal, "COM_GetModuleType", iDevIdx, NO_IDX_1, NO_IDX_2))
                      {
                        Sepia2_Lib.SEPIA2_COM_DecodeModuleType(iModuleType, cModulType);
                        iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, -1, Sepia2_Lib.SEPIA2_PRIMARY_MODULE, cSerialNumber);
                        if (Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, NO_IDX_1, NO_IDX_2))
                        {
                          Console.WriteLine(" backplane:   module type   '{0}'", cModulType);
                          Console.WriteLine("              serial number   '{0}'", cSerialNumber);
                          Console.WriteLine("");
                        }
                      }  // end of 'SEPIA2_COM_GetModuleType'
                    }  //  end of 'if (bIsBackPlane != 0)'
                    else
                    {
                      //
                      // identify sepiaobject (module) in slot
                      //
                      iRetVal = Sepia2_Lib.SEPIA2_COM_GetModuleType(iDevIdx, iSlotId, Sepia2_Lib.SEPIA2_PRIMARY_MODULE, out iModuleType);
                      if (Sepia2FunctionSucceeds(iRetVal, "COM_GetModuleType", iDevIdx, iSlotId, NO_IDX_2))
                      {
                        Sepia2_Lib.SEPIA2_COM_DecodeModuleType(iModuleType, cModulType);
                        iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotId, Sepia2_Lib.SEPIA2_PRIMARY_MODULE, cSerialNumber);
                        if (Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotId, NO_IDX_2))
                        {
                          Console.WriteLine(" slot {0:000} :   module type   '{1}'", iSlotId, cModulType);
                          Console.WriteLine("              serial number   '{0}'", cSerialNumber);
                          Console.WriteLine("");
                        }
                        //
                        // now, continue with modulespecific information
                        //
                        switch (iModuleType)
                        {
                          case Sepia2_Lib.SEPIA2OBJECT_SCM:
                            iRetVal = Sepia2_Lib.SEPIA2_SCM_GetLaserSoftLock(iDevIdx, iSlotId, out bSLock);
                            if (Sepia2FunctionSucceeds(iRetVal, "SCM_GetLaserSoftLock", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              iRetVal = Sepia2_Lib.SEPIA2_SCM_GetLaserLocked(iDevIdx, iSlotId, out bLock);
                              if (Sepia2FunctionSucceeds(iRetVal, "SCM_GetLaserLocked", iDevIdx, iSlotId, NO_IDX_2))
                              {
                                Console.WriteLine("                              laser lock state   :  {0}locked", (!((bLock != 0) || (bSLock != 0)) ? " un" : ((bLock != bSLock) ? " hard" : " soft")));
                                Console.WriteLine("");
                              }
                            }
                            //
                            break;

                          case Sepia2_Lib.SEPIA2OBJECT_SOM:
                          case Sepia2_Lib.SEPIA2OBJECT_SOMD:
                            for (iFreqTrigIdx = 0; ((iRetVal == Sepia2_Lib.SEPIA2_ERR_NO_ERROR) && (iFreqTrigIdx < Sepia2_Lib.SEPIA2_SOM_FREQ_TRIGMODE_COUNT)); iFreqTrigIdx++)
                            {
                              if (iModuleType == Sepia2_Lib.SEPIA2OBJECT_SOM)
                              {
                                iRetVal = Sepia2_Lib.SEPIA2_SOM_DecodeFreqTrigMode(iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                                bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2);
                              }
                              else
                              {
                                iRetVal = Sepia2_Lib.SEPIA2_SOMD_DecodeFreqTrigMode(iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                                bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2);
                              }
                              if (bRet)
                              {
                                if (iFreqTrigIdx == 0)
                                {
                                  Console.Write("{0,46}", "freq./trigmodes ");
                                }
                                else
                                {
                                  Console.Write("{0,46}", "                ");
                                }
                                //
                                Console.Write("{0:D1}) =     '{1}'", iFreqTrigIdx + 1, cFreqTrigMode);
                                //
                                if (iFreqTrigIdx == (Sepia2_Lib.SEPIA2_SOM_FREQ_TRIGMODE_COUNT - 1))
                                {
                                  Console.WriteLine("");
                                }
                                else
                                {
                                  Console.WriteLine(",");
                                }
                              }
                            }
                            Console.WriteLine("");
                            if (iRetVal == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
                            {
                              if (iModuleType == Sepia2_Lib.SEPIA2OBJECT_SOM)
                              {
                                iRetVal = Sepia2_Lib.SEPIA2_SOM_GetFreqTrigMode(iDevIdx, iSlotId, out iFreqTrigIdx);
                                bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_GetFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2);
                              }
                              else
                              {
                                iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetFreqTrigMode(iDevIdx, iSlotId, out iFreqTrigIdx, out bSynchronize);
                                bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_GetFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2);
                              }
                              if (bRet)
                              {
                                if (iModuleType == Sepia2_Lib.SEPIA2OBJECT_SOM)
                                {
                                  iRetVal = Sepia2_Lib.SEPIA2_SOM_DecodeFreqTrigMode(iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                                  bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2);
                                }
                                else
                                {
                                  iRetVal = Sepia2_Lib.SEPIA2_SOMD_DecodeFreqTrigMode(iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode);
                                  bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2);
                                }
                                if (bRet)
                                {
                                  Console.WriteLine("{0,47}  =     '{1}'", "act. freq./trigm.", cFreqTrigMode);
                                  if ((iModuleType == Sepia2_Lib.SEPIA2OBJECT_SOMD) && (iFreqTrigIdx < Sepia2_Lib.SEPIA2_SOM_INT_OSC_A))
                                  {
                                    if (bSynchronize != 0)
                                    {
                                      Console.WriteLine("{0,47}        (synchronized,)", " ");
                                    }
                                  }
                                  //
                                  if (iModuleType == Sepia2_Lib.SEPIA2OBJECT_SOM)
                                  {
                                    iRetVal = Sepia2_Lib.SEPIA2_SOM_GetBurstValues(iDevIdx, iSlotId, out bDivider, out bPreSync, out bMaskSync);
                                    if (bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_GetBurstValues", iDevIdx, iSlotId, NO_IDX_2))
                                    {
                                      wDivider = bDivider;
                                    }
                                  }
                                  else
                                  {
                                    iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetBurstValues(iDevIdx, iSlotId, out wDivider, out bPreSync, out bMaskSync);
                                    bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_GetBurstValues", iDevIdx, iSlotId, NO_IDX_2);
                                  }
                                  if (bRet)
                                  {
                                    Console.WriteLine("{0,48} = {1,5:D}", "divider       ", wDivider);
                                    Console.WriteLine("{0,48} = {1,5:D}", "pre sync      ", bPreSync);
                                    Console.WriteLine("{0,48} = {1,5:D}", "masked sync pulses", bMaskSync);
                                    //
                                    if ((iFreqTrigIdx == Sepia2_Lib.SEPIA2_SOM_TRIGMODE_RISING)
                                      || (iFreqTrigIdx == Sepia2_Lib.SEPIA2_SOM_TRIGMODE_FALLING))
                                    {
                                      if (iModuleType == Sepia2_Lib.SEPIA2OBJECT_SOM)
                                      {
                                        iRetVal = Sepia2_Lib.SEPIA2_SOM_GetTriggerLevel(iDevIdx, iSlotId, out iTriggerMilliVolt);
                                        bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_GetTriggerLevel", iDevIdx, iSlotId, NO_IDX_2);
                                      }
                                      else
                                      {
                                        iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetTriggerLevel(iDevIdx, iSlotId, out iTriggerMilliVolt);
                                        bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_GetTriggerLevel", iDevIdx, iSlotId, NO_IDX_2);
                                      }
                                      if (bRet)
                                      {
                                        Console.WriteLine("{0,47}  = {1,5:D} mV", "triggerlevel     ", iTriggerMilliVolt);
                                      }
                                    }
                                    else
                                    {
                                      fFrequency = atof(cFreqTrigMode.ToString(0, 5).Trim()) * 1.0e6f;
                                      fFrequency /= wDivider;
                                      Console.WriteLine("{0,47}  =  {1}", "oscillator period", FormatEng(cTemp1, 1.0 / fFrequency, 6, "s", 11, 3, true));
                                      Console.WriteLine("{0,47}     {1}", "i.e.", FormatEng(cTemp1, fFrequency, 6, "Hz", 12, 3, true));
                                      Console.WriteLine("");
                                    }
                                    if (iRetVal == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
                                    {
                                      if (iModuleType == Sepia2_Lib.SEPIA2OBJECT_SOM)
                                      {
                                        iRetVal = Sepia2_Lib.SEPIA2_SOM_GetOutNSyncEnable(iDevIdx, iSlotId, out bOutEnable, out bSyncEnable, out bSyncInverse);
                                        bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_GetOutNSyncEnable", iDevIdx, iSlotId, NO_IDX_2);
                                      }
                                      else
                                      {
                                        iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetOutNSyncEnable(iDevIdx, iSlotId, out bOutEnable, out bSyncEnable, out bSyncInverse);
                                        bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_GetOutNSyncEnable", iDevIdx, iSlotId, NO_IDX_2);
                                      }
                                      if (iRetVal == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
                                      {
                                        Console.WriteLine("{0,47}  =     {1}", "sync mask form   ", ((bSyncInverse != 0) ? "inverse" : "regular"));
                                        Console.WriteLine("");
                                        if (iModuleType == Sepia2_Lib.SEPIA2OBJECT_SOM)
                                        {
                                          iRetVal = Sepia2_Lib.SEPIA2_SOM_GetBurstLengthArray(iDevIdx, iSlotId, out lBurstChannels[0], out lBurstChannels[1], out lBurstChannels[2], out lBurstChannels[3], out lBurstChannels[4], out lBurstChannels[5], out lBurstChannels[6], out lBurstChannels[7]);
                                          bRet = Sepia2FunctionSucceeds(iRetVal, "SOM_GetBurstLengthArray", iDevIdx, iSlotId, NO_IDX_2);
                                        }
                                        else
                                        {
                                          iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetBurstLengthArray(iDevIdx, iSlotId, out lBurstChannels[0], out lBurstChannels[1], out lBurstChannels[2], out lBurstChannels[3], out lBurstChannels[4], out lBurstChannels[5], out lBurstChannels[6], out lBurstChannels[7]);
                                          bRet = Sepia2FunctionSucceeds(iRetVal, "SOMD_GetBurstLengthArray", iDevIdx, iSlotId, NO_IDX_2);
                                        }
                                        if (bRet)
                                        {
                                          Console.WriteLine("{0,44} ch. | sync | burst len |  out", "burst data    ");
                                          Console.WriteLine("{0,44}-----+------+-----------+------", " ");
                                          //
                                          for (i = 0, lBurstSum = 0; i < Sepia2_Lib.SEPIA2_SOM_BURSTCHANNEL_COUNT; i++)
                                          {
                                            Console.WriteLine("{0,46}{1,1}  |  {2,1} | {3,9} |  {4,1}", " ", i + 1, ((bSyncEnable >> i) & 1), lBurstChannels[i], ((bOutEnable >> i) & 1));
                                            lBurstSum += lBurstChannels[i];
                                          }
                                          Console.WriteLine("{0,41}--------+------+ +  -------+------", " ");
                                          Console.WriteLine("{0,41}Hex/Sum | 0x{1:X2} | ={2,8} | 0x{3:X2}", " ", bSyncEnable, lBurstSum, bOutEnable);
                                          Console.WriteLine("");
                                          if ((iFreqTrigIdx != Sepia2_Lib.SEPIA2_SOM_TRIGMODE_RISING)
                                            && (iFreqTrigIdx != Sepia2_Lib.SEPIA2_SOM_TRIGMODE_FALLING))
                                          {
                                            fFrequency /= lBurstSum;
                                            Console.WriteLine("{0,47}  =  {1}", "sequencer period", FormatEng(cTemp1, 1.0 / fFrequency, 6, "s", 11, 3, true));
                                            Console.WriteLine("{0,47}     {1}", "i.e.", FormatEng(cTemp1, fFrequency, 6, "Hz", 12, 3, true));
                                            Console.WriteLine("");
                                          }
                                          if (iModuleType == Sepia2_Lib.SEPIA2OBJECT_SOMD)
                                          {
                                            iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetDelayUnits(iDevIdx, iSlotId, out f64CoarseDelayStep, out bFineDelayStepCount);
                                            if (Sepia2FunctionSucceeds(iRetVal, "SOMD_GetDelayUnits", iDevIdx, iSlotId, NO_IDX_2))
                                            {
                                              Console.WriteLine("{0,44}     | combiner |", " ");
                                              Console.WriteLine("{0,44}     | channels |", " ");
                                              Console.WriteLine("{0,44} out | 12345678 | delay", " ");
                                              Console.WriteLine("{0,44}-----+----------+------------------", " ");
                                            }
                                            for (j = 0; j < Sepia2_Lib.SEPIA2_SOM_BURSTCHANNEL_COUNT; j++)
                                            {
                                              iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetSeqOutputInfos(iDevIdx, iSlotId, (byte)j, out bDelayed, out bForcedUndelayed, out bOutCombi, out bMaskedCombi, out f64CoarseDelay, out bFineDelay);
                                              if (Sepia2FunctionSucceeds(iRetVal, "SOMD_GetSeqOutputInfos", iDevIdx, iSlotId, NO_IDX_2))
                                              {
                                                if ((bDelayed == 0) || (bForcedUndelayed != 0))
                                                {
                                                  Console.WriteLine("{0,46}{1,1}  | {2} |", " ", j + 1, IntToBin(cTemp1, bOutCombi, Sepia2_Lib.SEPIA2_SOM_BURSTCHANNEL_COUNT, true, ((bMaskedCombi != 0) ? '1' : 'B'), '_'));
                                                }
                                                else
                                                {
                                                  Console.WriteLine("{0,46}{1,1}  | {2} |{3} + {4,2}a.u.", " ", j + 1, IntToBin(cTemp1, (1 << j), Sepia2_Lib.SEPIA2_SOM_BURSTCHANNEL_COUNT, true, 'D', '_'), FormatEng(cTemp2, f64CoarseDelay * 1e-9, 4, "s", 9, 1, false), bFineDelay);
                                                }
                                              }
                                            }  // end of 'for (j = 0; j < Sepia2_Lib.SEPIA2_SOM_BURSTCHANNEL_COUNT; j++)'
                                            Console.WriteLine("");
                                            Console.WriteLine("{0,46}   = D: delayed burst,   no combi", "combiner legend ");
                                            Console.WriteLine("{0,46}     B: combi burst, any non-zero", " ");
                                            Console.WriteLine("{0,46}     1: 1st pulse,   any non-zero", " ");
                                            Console.WriteLine("");
                                          } // (iModuleType == Sepia2_Lib.SEPIA2OBJECT_SOMD)
                                        }  // end of 'SEPIA2_SOMD_GetBurstLengthArray'  or  'SEPIA2_SOM_GetBurstLengthArray'
                                      }  // end of 'SEPIA2_SOMD_GetOutNSyncEnable'  or  'SEPIA2_SOM_GetOutNSyncEnable'
                                    }
                                  }  // end of 'SEPIA2_SOMD_GetBurstValues'  or  'SEPIA2_SOM_GetBurstValues'
                                }  // end of 'SEPIA2_SOMD_DecodeFreqTrigMode'  or  'SEPIA2_SOM_DecodeFreqTrigMode'
                              }  // end of 'SEPIA2_SOMD_GetFreqTrigMode'  or  'SEPIA2_SOM_GetFreqTrigMode'
                            }
                            break;  // case Sepia2_Lib.SEPIA2OBJECT_SOM: case Sepia2_Lib.SEPIA2OBJECT_SOMD:

                          case Sepia2_Lib.SEPIA2OBJECT_SLM:

                            iRetVal = Sepia2_Lib.SEPIA2_SLM_GetPulseParameters(iDevIdx, iSlotId, out iFreqTrigIdx, out bPulseMode, out iHead);
                            if (Sepia2FunctionSucceeds(iRetVal, "SLM_GetPulseParameters", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              Sepia2_Lib.SEPIA2_SLM_DecodeFreqTrigMode(iFreqTrigIdx, cFrequency);
                              Sepia2_Lib.SEPIA2_SLM_DecodeHeadType(iHead, cHeadType);
                              //
                              Console.WriteLine("{0,47}  =     '{1}'", "freq / trigmode  ", cFrequency);
                              Console.WriteLine("{0,47}  =     'pulses {1}'", "pulsmode     ", ((bPulseMode != 0) ? "enabled" : "disabled"));
                              Console.WriteLine("{0,47}  =     '{1,3}'", "headtype     ", cHeadType);
                            }
                            iRetVal = Sepia2_Lib.SEPIA2_SLM_GetIntensityFineStep(iDevIdx, iSlotId, out wIntensity);
                            if (Sepia2FunctionSucceeds(iRetVal, "SLM_GetIntensityFineStep", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              Console.WriteLine("{0,47}  =   {1,5:F1}%", "intensity    ", 0.1 * wIntensity);
                            }
                            Console.WriteLine("");
                            break;

                          case Sepia2_Lib.SEPIA2OBJECT_SML:
                            iRetVal = Sepia2_Lib.SEPIA2_SML_GetParameters(iDevIdx, iSlotId, out bPulseMode, out iHead, out bIntensity);
                            if (Sepia2FunctionSucceeds(iRetVal, "SML_GetParameters", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              Sepia2_Lib.SEPIA2_SML_DecodeHeadType(iHead, cHeadType);
                              //
                              Console.WriteLine("{0,47}  =     pulses {1}", "pulsmode     ", ((bPulseMode != 0) ? "enabled" : "disabled"));
                              Console.WriteLine("{0,47}  =     {1}", "headtype     ", cHeadType);
                              Console.WriteLine("{0,47}  =   {1,3}%", "intensity    ", bIntensity);
                              Console.WriteLine("");
                            }
                            break;

                          case Sepia2_Lib.SEPIA2OBJECT_SPM:
                            iRetVal = Sepia2_Lib.SEPIA2_SPM_GetFWVersion(iDevIdx, iSlotId, out SWSFWVers);
                            if (Sepia2FunctionSucceeds(iRetVal, "SPM_GetFWVersion", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              Console.WriteLine("{0,47}  =     {1}.{2}.{3}", "firmware version ", SWSFWVers.VersMaj, SWSFWVers.VersMin, SWSFWVers.BuildNr);
                            }
                            break;

                          case Sepia2_Lib.SEPIA2OBJECT_SWS:
                            iRetVal = Sepia2_Lib.SEPIA2_SWS_GetFWVersion(iDevIdx, iSlotId, out SWSFWVers);
                            if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetFWVersion", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              Console.WriteLine("{0,47}  =     {1}.{2}.{3}", "firmware version ", SWSFWVers.VersMaj, SWSFWVers.VersMin, SWSFWVers.BuildNr);
                            }
                            iRetVal = Sepia2_Lib.SEPIA2_SWS_GetModuleType(iDevIdx, iSlotId, out iSWSModuleType);
                            if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetModuleType", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              Sepia2_Lib.SEPIA2_SWS_DecodeModuleType(iSWSModuleType, cSWSModuleType);
                              Console.WriteLine("{0,47}  =     {1}", "SWS module type ", cSWSModuleType);
                            }
                            iRetVal = Sepia2_Lib.SEPIA2_SWS_GetParameters(iDevIdx, iSlotId, out ulWaveLength, out ulBandWidth);
                            if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetParameters", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              //
                              Console.WriteLine("{0,47}  =  {1,8:F3} nm ", "wavelength     ", 0.001 * ulWaveLength);
                              Console.WriteLine("{0,47}  =  {1,8:F3} nm ", "bandwidth    ", 0.001 * ulBandWidth);
                              Console.WriteLine("");
                            }
                            iRetVal = Sepia2_Lib.SEPIA2_SWS_GetIntensity(iDevIdx, iSlotId, out ulIntensRaw, out fIntensity);
                            if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetIntensity", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              Console.WriteLine("{0,47}  = 0x{1,4:X4} a.u. i.e. ~ {2:F1}nA", "power diode    ", ulIntensRaw, fIntensity);
                              Console.WriteLine("");
                            }
                            iRetVal = Sepia2_Lib.SEPIA2_SWS_GetBeamPos(iDevIdx, iSlotId, out sBeamVPos, out sBeamHPos);
                            if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetBeamPos", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              Console.WriteLine("{0,47}  =   {1,3} steps", "horiz. beamshift ", sBeamHPos);
                              Console.WriteLine("{0,47}  =   {1,3} steps", "vert.  beamshift ", sBeamVPos);
                              Console.WriteLine("");
                            }
                            break;

                          case Sepia2_Lib.SEPIA2OBJECT_SSM:
                            iRetVal = Sepia2_Lib.SEPIA2_SSM_GetTriggerData(iDevIdx, iSlotId, out iFreqTrigIdx, out iTriggerMilliVolt);
                            if (Sepia2FunctionSucceeds(iRetVal, "SSM_GetTriggerData", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              //
                              iRetVal = Sepia2_Lib.SEPIA2_SSM_DecodeFreqTrigMode(iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode, out iFrequency, out bTrigLevelEnabled);
                              if (Sepia2FunctionSucceeds(iRetVal, "SSM_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2))
                              {
                                Console.WriteLine("{0,47}  =     '{1}'", "act. freq./trigm.", cFreqTrigMode);
                                if (bTrigLevelEnabled != 0)
                                {
                                  Console.WriteLine("{0,47}  = {1:D5} mV", "triggerlevel   ", iTriggerMilliVolt);
                                }
                              }
                            }
                            break;

                          case Sepia2_Lib.SEPIA2OBJECT_SWM:
                            iRetVal = Sepia2_Lib.SEPIA2_SWM_GetCurveParams(iDevIdx, iSlotId, 1, out bTBNdx, out wPAPml, out wRRPml, out wPSPml, out wRSPml, out wWSPml);
                            if (Sepia2FunctionSucceeds(iRetVal, "SWM_GetCurveParams 1", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              Console.WriteLine("{0,47}", "Curve 1:         ");
                              Console.WriteLine("{0,47}  =   {1,3}", "TBNdx            ", bTBNdx);
                              Console.WriteLine("{0,47}  =  {1,6:F1}%", "PAPml            ", 0.1 * wPAPml);
                              Console.WriteLine("{0,47}  =  {1,6:F1}%", "RRPml            ", 0.1 * wRRPml);
                              Console.WriteLine("{0,47}  =  {1,6:F1}%", "PSPml            ", 0.1 * wPSPml);
                              Console.WriteLine("{0,47}  =  {1,6:F1}%", "RSPml            ", 0.1 * wRSPml);
                              Console.WriteLine("{0,47}  =  {1,6:F1}%", "WSPml            ", 0.1 * wWSPml);
                            }
                            iRetVal = Sepia2_Lib.SEPIA2_SWM_GetCurveParams(iDevIdx, iSlotId, 2, out bTBNdx, out wPAPml, out wRRPml, out wPSPml, out wRSPml, out wWSPml);
                            if (Sepia2FunctionSucceeds(iRetVal, "SWM_GetCurveParams 2", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              Console.WriteLine("{0,47}", "Curve 2:         ");
                              Console.WriteLine("{0,47}  =   {1,3}", "TBNdx            ", bTBNdx);
                              Console.WriteLine("{0,47}  =  {1,6:F1}%", "PAPml            ", 0.1 * wPAPml);
                              Console.WriteLine("{0,47}  =  {1,6:F1}%", "RRPml            ", 0.1 * wRRPml);
                              Console.WriteLine("{0,47}  =  {1,6:F1}%", "PSPml            ", 0.1 * wPSPml);
                              Console.WriteLine("{0,47}  =  {1,6:F1}%", "RSPml            ", 0.1 * wRSPml);
                              Console.WriteLine("{0,47}  =  {1,6:F1}%", "WSPml            ", 0.1 * wWSPml);
                            }
                            break;

                          case Sepia2_Lib.SEPIA2OBJECT_VUV:
                          case Sepia2_Lib.SEPIA2OBJECT_VIR:
                            iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetDeviceType(iDevIdx, iSlotId, cDevType, out bHasCW, out bHasFanSwitch);
                            if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetDeviceType", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetTriggerData(iDevIdx, iSlotId, out iTrigSrcIdx, out iFreqDivIdx, out iTriggerMilliVolt);
                              if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetTriggerData", iDevIdx, iSlotId, NO_IDX_2))
                              {
                                iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_DecodeFreqTrigMode(iDevIdx, iSlotId, iTrigSrcIdx, -1, cFreqTrigMode, out iDummy, out bDummy1, out bDummy2);
                                if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2))
                                {
                                  iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_DecodeFreqTrigMode(iDevIdx, iSlotId, iTrigSrcIdx, iFreqDivIdx, cFreqTrigSrc, out iFrequency, out bDivListEnabled, out bTrigLvlEnabled);
                                  if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2))
                                  {
                                    Console.WriteLine("{0,47}  =   '{1}'", "devicetype       ", cDevType);
                                    Console.WriteLine("{0,47}  :   {1} = {2}", "options          ", "CW        ", BoolToStr(bHasCW != 0));
                                    Console.WriteLine("{0,47}      {1} = {2}", "                 ", "fan-switch", BoolToStr(bHasFanSwitch != 0));
                                    Console.WriteLine("{0,47}  =   {1}", "trigger source   ", cFreqTrigMode);
                                    if ((bDivListEnabled != 0) && (iFrequency > 0))
                                    {
                                      Console.WriteLine("{0,47}  =   2^{1} = {2}", "divider          ", iFreqDivIdx, (int)(Math.Pow(2.0, 1.0 * iFreqDivIdx)));
                                      Console.WriteLine("{0,47}  =   {1}", "frequency        ", FormatEng(cTemp1, 1.0 * iFrequency, 4, "Hz", 9, -1, true));
                                    }
                                    else if (bTrigLvlEnabled != 0)
                                    {
                                      Console.WriteLine("{0,47}  =   {1:F3} V", "trigger level    ", 0.001 * iTriggerMilliVolt);
                                    }
                                  }  //  end of 'SEPIA2_VUV_VIR_DecodeFreqTrigMode'
                                }  //  end of 'SEPIA2_VUV_VIR_DecodeFreqTrigMode'
                                iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetIntensity(iDevIdx, iSlotId, out iIntensity);
                                if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetIntensity", iDevIdx, iSlotId, NO_IDX_2))
                                {
                                  Console.WriteLine("{0,47}  =   {1,3:F1}%", "intensity        ", 0.1 * iIntensity);
                                }
                                if (bHasFanSwitch != 0)
                                {
                                  iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetFan(iDevIdx, iSlotId, out bIsFanRunning);
                                  if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetFan", iDevIdx, iSlotId, NO_IDX_2))
                                  {
                                    Console.WriteLine("{0,47}  =   {1}", "fan running      ", BoolToStr(bIsFanRunning != 0));
                                  }
                                }
                              }  // end of 'SEPIA2_VUV_VIR_GetTriggerData'
                            }  // end of 'SEPIA2_VUV_VIR_GetDeviceType'
                            break;

                          case Sepia2_Lib.SEPIA2OBJECT_PRI:

                            PRIConst = new T_PRI_Constants (iDevIdx, iSlotId);

                            Console.WriteLine("{0,47}  =   '{1}'", "devicetype       ", PRIConst.PrimaModuleType.ToString());
                            Console.WriteLine("{0,47}  =   {1}", "firmware version ", PRIConst.PrimaFWVers.ToString());
                            Console.WriteLine("");
                            Console.WriteLine("{0,47}  =   {1}", "wavelengths count", PRIConst.PrimaWLCount);
                            //
                            for (i = 0; i < PRIConst.PrimaWLCount; i++)
                            {
                              cTemp1.Clear();
                              cTemp1.AppendFormat("wavelength [{0}] ", i);
                              Console.WriteLine("{0,47}  =  {1,4}nm", cTemp1, PRIConst.PrimaWLs[i]);
                            }
                            iRetVal = Sepia2_Lib.SEPIA2_PRI_GetWavelengthIdx(iDevIdx, iSlotId, out iWL_Idx);
                            if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetWavelengthIdx", iDevIdx, iSlotId, iWL_Idx))
                            {
                              iFormatWidth = 12;
                              Console.WriteLine("{0,47}  =  {1,4}nm;{2," + iFormatWidth.ToString() + "}WL-Idx={3}", "cur. wavelength  ", PRIConst.PrimaWLs[iWL_Idx], " ", iWL_Idx);
                            }
                            Console.WriteLine("");
                            //
                            // now we take the amount of operation modes for this indiviual PRI module
                            //
                            Console.WriteLine("{0,47}  =   {1}", "operation modes  ", PRIConst.PrimaOpModCount);
                            //
                            for (i = 0; i < PRIConst.PrimaOpModCount; i++)
                            {
                              iRetVal = Sepia2_Lib.SEPIA2_PRI_DecodeOperationMode(iDevIdx, iSlotId, i, cOpMode);
                              if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeOperationMode", iDevIdx, iSlotId, i))
                              {
                                cTemp1.Clear();
                                cTemp1.AppendFormat("oper. mode [{0}] ", i);
                                cTemp2 = trim(cTemp2, cOpMode.ToString());
                                Console.WriteLine("{0,47}  =   '{1}'", cTemp1, cTemp2);
                              }
                            }
                            iRetVal = Sepia2_Lib.SEPIA2_PRI_GetOperationMode(iDevIdx, iSlotId, out iOM_Idx);
                            if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetOperationMode", iDevIdx, iSlotId, iOM_Idx))
                            {
                              iRetVal = Sepia2_Lib.SEPIA2_PRI_DecodeOperationMode(iDevIdx, iSlotId, iOM_Idx, cOpMode);
                              if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeOperationMode", iDevIdx, iSlotId, iOM_Idx))
                              {
                                cTemp1.Clear();
                                cTemp1 = trim(cTemp1, cOpMode.ToString());
                                iFormatWidth = (15 - cTemp1.Length);
                                Console.WriteLine("{0,47}  =   '{1}';{2," + iFormatWidth.ToString() + "}OM-Idx={3}", "cur. oper. mode  ", cTemp1, " ", iOM_Idx);
                              }
                            }
                            Console.WriteLine("");
                            //
                            // now we take the amount of trigger sources for this indiviual PRI module
                            //
                            Console.WriteLine("{0,47}  =   {1}", "trigger sources  ", PRIConst.PrimaTrSrcCount);
                            for (i = 0; i < PRIConst.PrimaTrSrcCount; i++)
                            {
                              iRetVal = Sepia2_Lib.SEPIA2_PRI_DecodeTriggerSource(iDevIdx, iSlotId, i, cTrigSrc, out bDummy1, out bDummy2);
                              if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeTriggerSource", iDevIdx, iSlotId, i))
                              {
                                cTemp1.Clear();
                                cTemp1.AppendFormat("trig. src. [{0}] ", i);
                                cTemp2.Clear();
                                cTemp2 = trim(cTemp2, cTrigSrc.ToString());
                                Console.WriteLine("{0,47}  =   '{1}'", cTemp1, cTemp2);
                              }
                            }
                            iRetVal = Sepia2_Lib.SEPIA2_PRI_GetTriggerSource(iDevIdx, iSlotId, out iTS_Idx);
                            if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetTriggerSource", iDevIdx, iSlotId, iTS_Idx))
                            {
                              iRetVal = Sepia2_Lib.SEPIA2_PRI_DecodeTriggerSource(iDevIdx, iSlotId, iTS_Idx, cTrigSrc, out bFreqncyEnabled, out bTrigLvlEnabled);
                              if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeTriggerSource", iDevIdx, iSlotId, iTS_Idx))
                              {
                                cTemp1.Clear();
                                cTemp1 = trim(cTemp1, cTrigSrc.ToString());
                                iFormatWidth = (15 - cTrigSrc.Length);
                                Console.WriteLine("{0,47}  =   '{1}';{2," + iFormatWidth.ToString() + "}TS-Idx={3}", "cur. trig. source", cTrigSrc, " ", iTS_Idx);
                              }
                              Console.WriteLine("");
                              cTemp1.Clear(); 
                              cTemp1.AppendFormat("for TS-Idx = {0}   ", iTS_Idx);
                              Console.WriteLine("{0,47}  :   frequency is {1}active:", cTemp1, ((bFreqncyEnabled.Equals(0)) ? "in" : ""));
                              iRetVal = Sepia2_Lib.SEPIA2_PRI_GetFrequencyLimits(iDevIdx, iSlotId, out iMinFreq, out iMaxFreq);
                              if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetFrequencyLimits", iDevIdx, iSlotId, NO_IDX_2))
                              {
                                cTemp1.Clear();
                                cTemp1 = FormatEng(cTemp1, iMinFreq, 3, "Hz", -1, 0, false);
                                cTemp2.Clear();
                                cTemp2 = FormatEng(cTemp2, iMaxFreq, 3, "Hz", -1, 0, false);
                                Console.WriteLine("{0,47}  =   {1} <= f <= {2}", "frequency range", cTemp1, cTemp2);
                                iRetVal = Sepia2_Lib.SEPIA2_PRI_GetFrequency(iDevIdx, iSlotId, out iFreq);
                                if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetFrequency", iDevIdx, iSlotId, NO_IDX_2))
                                {
                                  cTemp1.Clear();
                                  cTemp1 = FormatEng(cTemp1, iFreq, 3, "Hz", -1, 0, false);
                                  Console.WriteLine("{0,47}  =   {1}", "cur. frequency ", cTemp1);
                                }
                              }
                              Console.WriteLine("");
                              cTemp1.Clear();
                              cTemp1.AppendFormat("for TS-Idx = {0}   ", iTS_Idx);
                              Console.WriteLine("{0,47}  :   trigger level is {1}active:", cTemp1, (bTrigLvlEnabled.Equals(0) ? "in" : ""));
                              iRetVal = Sepia2_Lib.SEPIA2_PRI_GetTriggerLevelLimits (iDevIdx, iSlotId, out iMinTrgLvl, out iMaxTrgLvl, out iResTrgLvl);
                              if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetTriggerLevelLimits", iDevIdx, iSlotId, NO_IDX_2))
                              {
                                iRetVal = Sepia2_Lib.SEPIA2_PRI_GetTriggerLevel (iDevIdx, iSlotId, out iTriggerMilliVolt);
                                Console.WriteLine("{0,47}  =  {1,6:N3}V <= tl <= {2,5:N3}V", "trig.lvl. range", 0.001*iMinTrgLvl, 0.001*iMaxTrgLvl);
                                //
                                Console.WriteLine("{0,47}  =  {1,6:N3}V", "cur. trig.lvl. ", 0.001*iTriggerMilliVolt);
                              }
                              Console.WriteLine("");
                            }
                            iRetVal = Sepia2_Lib.SEPIA2_PRI_GetIntensity(iDevIdx, iSlotId, iWL_Idx, out wIntensity);
                            if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetIntensity", iDevIdx, iSlotId, iWL_Idx))
                            {
                              cTemp1.Clear();
                              cTemp1.AppendFormat("{0:N1}%", 0.1 * wIntensity);
                              iFormatWidth = 16 - cTemp1.Length;
                              Console.WriteLine("{0,47}  =   {1}; {2," + iFormatWidth.ToString() + "}WL-Idx={3}", "intensity        ", cTemp1, " ", iWL_Idx);
                            }
                            Console.WriteLine("");
                            iRetVal = Sepia2_Lib.SEPIA2_PRI_GetGatingEnabled(iDevIdx, iSlotId, out bGatingEnabled);
                            if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGatingEnabled", iDevIdx, iSlotId, NO_IDX_2))
                            {
                              Console.WriteLine("{0,47}  :   {1}abled", "gating           ", (bGatingEnabled.Equals(0) ? "dis" : "en"));
                              iRetVal = Sepia2_Lib.SEPIA2_PRI_GetGateHighImpedance(iDevIdx, iSlotId, out bGateHiImp);
                              if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGateHighImpedance", iDevIdx, iSlotId, NO_IDX_2))
                              {
                                Console.WriteLine("{0,47}  =   {1}", "gate impedance ", (bGateHiImp.Equals(0) ? "low (50 Ohm)" :  "high (>= 1 kOhm)"));
                              }
                              //
                              iRetVal = Sepia2_Lib.SEPIA2_PRI_GetGatingLimits(iDevIdx, iSlotId, out iMinOnTime, out iMaxOnTime, out iMinOffTimefact, out iMaxOffTimefact);
                              if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGatingLimits", iDevIdx, iSlotId, NO_IDX_2))
                              {
                                iRetVal = Sepia2_Lib.SEPIA2_PRI_GetGatingData(iDevIdx, iSlotId, out iOnTime, out iOffTimefact);
                                if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGatingData", iDevIdx, iSlotId, NO_IDX_2))
                                {
                                  cTemp1 = FormatEng(cTemp1, 1.0e-9 * iMinOnTime, 4, "s", -1, 1, false);
                                  cTemp2 = FormatEng(cTemp2, 1.0e-9 * iMaxOnTime, 4, "s", -1, 1, false);
                                  Console.WriteLine("{0,48} =   {1} <= t <= {2}", "on-time range   ", cTemp1, cTemp2);
                                  //
                                  cTemp1 = FormatEng(cTemp1, 1.0e-9 * iOnTime, 4, "s", -1, 1, false);
                                  Console.WriteLine("{0,48} =   {1}", "cur. on-time    ", cTemp1);
                                  //
                                  Console.WriteLine("{0,48} =   {1} <= tf <= {2}", "off-t.fact range", iMinOffTimefact, iMaxOffTimefact);
                                  //
                                  cTemp1 = FormatEng(cTemp1, 1.0e-9 * iOnTime * iOffTimefact, 4, "s", -1, 3, false);
                                  Console.WriteLine("{0,48} =   {1} * on-time = {2}", "cur. off-time   ", iOffTimefact, cTemp1);
                                  fGatePeriod = 1.0e-9F * iOnTime * (1 + iOffTimefact);
                                  cTemp1 = FormatEng(cTemp1, fGatePeriod, 4, "s", -1, 3, false);
                                  Console.WriteLine("{0,48} =   {1}", "gate period     ", cTemp1);
                                  cTemp1 = FormatEng(cTemp1, 1.0 / fGatePeriod, 4, "Hz", -1, -1, false);
                                  Console.WriteLine("{0,48} =   {1}", "gate frequency  ", cTemp1);
                                }
                              }
                            }
                            break;

                          default: break;
                        }
                      }
                    }  // end of 'else' of 'if (bIsBackPlane != 0)'
                  }  // end of 'SEPIA2_FWR_GetModuleInfoByMapIdx'
                  //
                  if (iRetVal == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
                  {
                    if (bIsPrimary == 0)
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_COM_GetModuleType(iDevIdx, iSlotId, Sepia2_Lib.SEPIA2_SECONDARY_MODULE, out iModuleType);
                      if (Sepia2FunctionSucceeds(iRetVal, "COM_GetModuleType", iDevIdx, iSlotId, NO_IDX_2))
                      {
                        Sepia2_Lib.SEPIA2_COM_DecodeModuleType(iModuleType, cModulType);
                        iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotId, Sepia2_Lib.SEPIA2_SECONDARY_MODULE, cSerialNumber);
                        if (Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotId, NO_IDX_2))
                        {
                          Console.WriteLine("");
                          Console.WriteLine("              secondary mod.  '{0}'", cModulType);
                          Console.WriteLine("              serial number   '{0}'", cSerialNumber);
                          Console.WriteLine("");
                        }  // end of 'SEPIA2_COM_GetSerialNumber'
                      }  // end of 'SEPIA2_COM_GetModuleType'
                    }  // end of 'if (bIsPrimary == 0)'
                    //
                    if (bHasUptimeCounter != 0)
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_FWR_GetUptimeInfoByMapIdx(iDevIdx, iMapIdx, out ulMainPowerUp, out ulActivePowerUp, out ulScaledPowerUp);
                      if (Sepia2FunctionSucceeds(iRetVal, "", iDevIdx, iSlotId, NO_IDX_2))
                      {
                        PrintUptimers(ulMainPowerUp, ulActivePowerUp, ulScaledPowerUp);
                      }
                    }
                  }
                }  // end of 'for (iMapIdx = 0; iMapIdx < iModuleCount; iMapIdx++)'
              }  // end of 'if (!HasFWError(....))'
            }  // end of 'SEPIA2_FWR_GetLastError'
          } // end of 'SEPIA2_FWR_GetModuleMap'
          else
          {
            iRetVal = Sepia2_Lib.SEPIA2_FWR_GetLastError(iDevIdx, out iFWErrCode, out iFWErrPhase, out iFWErrLocation, out iFWErrSlot, cFWErrCond);
            if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetLastError", iDevIdx, NO_IDX_1, NO_IDX_2))
            {
              HasFWError(iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond.ToString(), "Firmware error detected:");
            }
          }
          //
          Sepia2_Lib.SEPIA2_FWR_FreeModuleMap(iDevIdx);
          if (bStayOpened)
          {
            Console.WriteLine("");
            Console.Write("press RETURN to close Sepia... ");
            Console.ReadLine();
          }
          Sepia2_Lib.SEPIA2_USB_CloseDevice(iDevIdx);
        }
        //
        Console.WriteLine("");
        //
        if (!bNoWait)
        {
          Console.WriteLine("");
          Console.Write("press RETURN... ");
          Console.ReadLine();
        }
        return iRetVal;
      }
    }
  }
}
