using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

namespace PQ.Sepia2
{
  public static partial class MigrationHelper
  {
    public static class SetSomeDataByCSharp
    {
      //-----------------------------------------------------------------------------
      //
      //      SetSomeDataByCSharp
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
      //  apo  30.08.22   introduced PRI module functions (for Prima, Quader) (V1.2.xx.753)
      //
      //-----------------------------------------------------------------------------
      //
      public const int IS_A_VUV = 0;
      public const int IS_A_VIR = 1;
      //
      private const string STR_SEPARATORLINE = "    ============================================================";
      private const string FNAME = "OrigData.txt";
      //
      private static int iRetVal = Sepia2_Lib.SEPIA2_ERR_NO_ERROR;
      private static int iDevIdx = -1;
      private static int[] iFreqTrigSrc = { -1, -1 };
      private static int[] iFreqDivIdx = { -1, -1 };
      private static int[] iTrigLevel = { 0, 0 };
      private static int[] iIntensity = { 0, 0 };
      private static byte[] bFanRunning = { 0, 0 };
      //
      private static void GetWriteAndModify_VUV_VIR_Data(System.IO.StreamWriter f, StringBuilder cVUV_VIRType, int iVUV_VIR_Slot, int IsVIR)
      {
        int TrgLvlUpper;
        int TrgLvlLower;
        int TrgLvlRes;
        //
        iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetTriggerData(iDevIdx, iVUV_VIR_Slot, out iFreqTrigSrc[IsVIR], out iFreqDivIdx[IsVIR], out iTrigLevel[IsVIR]);
        if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetTriggerData", iDevIdx, iVUV_VIR_Slot, NO_IDX_2))
        {
          f.WriteLine(String.Format("{0,4} TrigSrcIdx    =      {1,3}", cVUV_VIRType, iFreqTrigSrc[IsVIR]));
          f.WriteLine(String.Format("{0,4} FreqDivIdx    =      {1,3}", cVUV_VIRType, iFreqDivIdx[IsVIR]));
          f.WriteLine(String.Format("{0,4} TrigLevel     =    {1,5}", cVUV_VIRType, iTrigLevel[IsVIR]));
          //
          iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetIntensity(iDevIdx, iVUV_VIR_Slot, out iIntensity[IsVIR]);
          if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetIntensity", iDevIdx, iVUV_VIR_Slot, NO_IDX_2))
          {
            f.WriteLine(String.Format("{0,4} Intensity     =      {1,5:F1} %", cVUV_VIRType, 0.1 * iIntensity[IsVIR]));
            //
            iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetFan(iDevIdx, iVUV_VIR_Slot, out bFanRunning[IsVIR]);
            if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetFan", iDevIdx, iVUV_VIR_Slot, NO_IDX_2))
            {
              f.WriteLine(String.Format("{0,4} FanRunning    =        {1}", cVUV_VIRType, BoolToStr(bFanRunning[IsVIR] != 0)));
            }
          }
        }
        //
        //
        iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetTrigLevelRange(iDevIdx, iVUV_VIR_Slot, out TrgLvlUpper, out TrgLvlLower, out TrgLvlRes);
        if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetTrigLevelRange", iDevIdx, iVUV_VIR_Slot, NO_IDX_2))
        {
          iFreqTrigSrc[IsVIR] = (iFreqTrigSrc[IsVIR] == 1 ? 0 : 1);
          iFreqDivIdx[IsVIR] = (iFreqDivIdx[IsVIR] == 2 ? 1 : 2);
          iTrigLevel[IsVIR] = EnsureRange(50 - iTrigLevel[IsVIR], TrgLvlLower, TrgLvlUpper);
          iIntensity[IsVIR] = 1000 - iIntensity[IsVIR];
          bFanRunning[IsVIR] = (bFanRunning[IsVIR] == 0 ? (byte)1 : (byte)0);
        }
        else
        {
          iFreqTrigSrc[IsVIR] = 1;
          iFreqDivIdx[IsVIR] = 2;
          iTrigLevel[IsVIR] = -350;
          iIntensity[IsVIR] = 440;
          bFanRunning[IsVIR] = 1;
        }
      }

      private static void Read_VUV_VIR_Data(System.IO.FileStream f, StringBuilder cVUV_VIRType, int IsVIR)
      {
        float fIntensity;
        //
        iFreqTrigSrc[IsVIR] = StrToInt(GetValStr(f, String.Format("{0,4} TrigSrcIdx    =", cVUV_VIRType)));
        iFreqDivIdx[IsVIR] = StrToInt(GetValStr(f, String.Format("{0,4} FreqDivIdx    =", cVUV_VIRType)));
        iTrigLevel[IsVIR] = StrToInt(GetValStr(f, String.Format("{0,4} TrigLevel     =", cVUV_VIRType)));
        fIntensity = StrToFloat(GetValStr(f, String.Format("{0,4} Intensity     =", cVUV_VIRType)));
        iIntensity[IsVIR] = (signbit(fIntensity) ? -1 : 1) * (int)(10.0 * fabs(fIntensity) + 0.5);
        bFanRunning[IsVIR] = (byte)(StrToBool(GetValStr(f, String.Format("{0,4} FanRunning    =", cVUV_VIRType))) ? 1 : 0);
      }

      private static void Set_VUV_VIR_Data(StringBuilder cVUV_VIRType, int iVUV_VIR_Slot, int IsVIR)
      {
        iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_SetTriggerData(iDevIdx, iVUV_VIR_Slot, iFreqTrigSrc[IsVIR], iFreqDivIdx[IsVIR], iTrigLevel[IsVIR]);
        if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_SetTriggerData", iDevIdx, iVUV_VIR_Slot, NO_IDX_2))
        {
          iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_SetIntensity(iDevIdx, iVUV_VIR_Slot, iIntensity[IsVIR]);
          if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_SetIntensity", iDevIdx, iVUV_VIR_Slot, NO_IDX_2))
          {
            iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_SetFan(iDevIdx, iVUV_VIR_Slot, bFanRunning[IsVIR]);
            Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_SetFan", iDevIdx, iVUV_VIR_Slot, NO_IDX_2);
          }
        }
        //
        Console.WriteLine("     {0,4} TrigSrcIdx    =      {1,3}", cVUV_VIRType, iFreqTrigSrc[IsVIR]);
        Console.WriteLine("     {0,4} FreqDivIdx    =      {1,3}", cVUV_VIRType, iFreqDivIdx[IsVIR]);
        Console.WriteLine("     {0,4} TrigLevel     =    {1,5} mV", cVUV_VIRType, iTrigLevel[IsVIR]);
        Console.WriteLine("     {0,4} Intensity     =      {1,5:F1} %", cVUV_VIRType, 0.1 * iIntensity[IsVIR]);
        Console.WriteLine("     {0,4} FanRunning    =        {1}", cVUV_VIRType, BoolToStr(bFanRunning[IsVIR] != 0));
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
          Console.WriteLine("    {0}", cPromptString);
          Console.WriteLine("");
          Sepia2_Lib.SEPIA2_LIB_DecodeError(iFWErr, cErrTxt);
          Sepia2_Lib.SEPIA2_FWR_DecodeErrPhaseName(iPhase, cPhase);
          Console.WriteLine("       error code      : {0,5},   i.e. '{1}'", iFWErr, cErrTxt);
          Console.WriteLine("       error phase     : {0,5},   i.e. '{1}'", iPhase, cPhase);
          Console.WriteLine("       error location  : {0,5}", iLocation);
          Console.WriteLine("       error slot      :   {0:000}", iSlot);
          if (cFWErrCond.Length > 0)
          {
            Console.WriteLine("       error condition : '{0}'", cFWErrCond);
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
        //
        #region buffers and variables

        StringBuilder cLibVersion = new StringBuilder(Sepia2_Lib.SEPIA2_VERSIONINFO_LEN);
        StringBuilder cSepiaSerNo = new StringBuilder(Sepia2_Lib.SEPIA2_SERIALNUMBER_LEN);
        StringBuilder cGivenSerNo = new StringBuilder(Sepia2_Lib.SEPIA2_SERIALNUMBER_LEN);
        StringBuilder cProductModel = new StringBuilder(Sepia2_Lib.SEPIA2_PRODUCTMODEL_LEN);
        StringBuilder cGivenProduct = new StringBuilder(Sepia2_Lib.SEPIA2_PRODUCTMODEL_LEN);
        StringBuilder cFWVersion = new StringBuilder(Sepia2_Lib.SEPIA2_VERSIONINFO_LEN);
        StringBuilder cDescriptor = new StringBuilder(Sepia2_Lib.SEPIA2_USB_STRDECR_LEN);
        StringBuilder cFWErrCond = new StringBuilder(Sepia2_Lib.SEPIA2_FW_ERRCOND_LEN);
        StringBuilder cFWErrPromt = new StringBuilder(80);
        StringBuilder cErrString = new StringBuilder(Sepia2_Lib.SEPIA2_ERRSTRING_LEN);
        StringBuilder cSOMSerNr = new StringBuilder(Sepia2_Lib.SEPIA2_SERIALNUMBER_LEN);
        StringBuilder cSLMSerNr = new StringBuilder(Sepia2_Lib.SEPIA2_SERIALNUMBER_LEN);
        StringBuilder cVUVSerNr = new StringBuilder(Sepia2_Lib.SEPIA2_SERIALNUMBER_LEN);
        StringBuilder cVIRSerNr = new StringBuilder(Sepia2_Lib.SEPIA2_SERIALNUMBER_LEN);
        StringBuilder cPRISerNr = new StringBuilder(Sepia2_Lib.SEPIA2_SERIALNUMBER_LEN);
        StringBuilder cFreqTrigMode = new StringBuilder(Sepia2_Lib.SEPIA2_SOM_FREQ_TRIGMODE_LEN);
        StringBuilder cOperMode = new StringBuilder(Sepia2_Lib.SEPIA2_PRI_OPERMODE_LEN);
        StringBuilder cSOMType = new StringBuilder(6);
        StringBuilder cSLMType = new StringBuilder(6);
        StringBuilder cVUVType = new StringBuilder(6);
        StringBuilder cVIRType = new StringBuilder(6);
        StringBuilder cPRIType = new StringBuilder(6);
        //
        //read from file with local methods
        string cSOMFSerNr;
        string cSLMFSerNr;
        string cVUVFSerNr;
        string cVIRFSerNr;
        string cPRIFSerNr;
        //
        int[] lBurstChannels = { 0, 0, 0, 0, 0, 0, 0, 0 };
        int lTemp;
        //
        int iGivenDevIdx = 0;
        int iSlotNr;
        int iSOM_Slot = -1;
        int iSLM_Slot = -1;
        int iVUV_Slot = -1;
        int iVIR_Slot = -1;
        int iPRI_Slot = -1;
        int iSOM_FSlot = -1;
        int iSLM_FSlot = -1;
        int iVUV_FSlot = -1;
        int iVIR_FSlot = -1;
        int iPRI_FSlot = -1;
        //
        int iModuleCount;
        int iModuleType = 0;
        int iFWErrCode;
        int iFWErrPhase;
        int iFWErrLocation;
        int iFWErrSlot;
        int iSOMModuleType;
        int iFreqTrigIdx = 0;
        int iOpModeIdx = 0;
        int iWL_Idx = 0;
        int iTemp1;
        int iTemp2;
        int iTemp3;
        int iFreq = 0;
        int iHead;
        int i;
        int pos;
        //
        //
        // byte (boolean)
        //
        bool bUSBInstGiven = false;
        bool bSerialGiven = false;
        bool bProductGiven = false;
        bool bNoWait = false;
        byte bIsPrimary;
        byte bIsBackPlane;
        byte bHasUptimeCounter;
        bool bSOM_Found = false;
        bool bSLM_Found = false;
        bool bVUV_Found = false;
        bool bVIR_Found = false;
        bool bPRI_Found = false;
        bool bSOM_FFound = false;
        bool bSLM_FFound = false;
        bool bVUV_FFound = false;
        bool bVIR_FFound = false;
        bool bPRI_FFound = false;
        bool bIsSOMDModule = false;
        bool bExtTiggered;
        byte bLinux = 0;
        byte bPulseMode = 0;
        byte bSyncInverse = 0;
        byte bSynchronized = 0;
        //
        //
        // byte (numerical or bit-coded value)
        //
        byte bDivider;
        byte bOutEnable = 0;
        byte bSyncEnable = 0;
        byte bPreSync = 0;
        byte bMaskSync = 0;
        //
        //
        // word
        //
        ushort wIntensity = 0;
        ushort wDivider = 0;
        ushort wSOMDState;
        short iSOMDErrorCode;
        //
        float fIntensity;

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
        if (argv.Length < 1)
        {
          Console.WriteLine(" called without parameters");
        }
        else
        {
          Console.WriteLine(" called with {0} parameter{1}:", argv.Length, (argv.Length > 1) ? "s" : "");
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
            else if (cmd_arg.IndexOf("-nowait") >= 0)
            {
              bNoWait = true;
              Console.WriteLine("  -nowait");
            }
            else
            {
              Console.WriteLine("    {0} : unknown parameter!", cmd_arg);
            }
          }
          //
          #endregion CMD-Args checks
          //
        }
        //
        Console.WriteLine(""); Console.WriteLine("");
        Console.WriteLine("     PQLaserDrv   Set SOME Values Demo : ");
        Console.WriteLine("{0}", STR_SEPARATORLINE);
        Console.WriteLine("");
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
            Console.WriteLine("     Lib-Version    = {0}", cLibVersion);
            //
            //
            if (!cLibVersion.ToString().StartsWith(Sepia2_Lib.LIB_VERSION_REFERENCE.Substring(0, Sepia2_Lib.LIB_VERSION_REFERENCE_COMPLEN)))
            {
              Console.WriteLine("");
              Console.WriteLine("     Warning: This demo application was built for version  {0}!", Sepia2_Lib.LIB_VERSION_REFERENCE);
              Console.WriteLine("              Continuing may cause unpredictable results!");
              Console.Write("     Do you want to continue anyway? (y/n): ");
              //
              string user_inp = Console.ReadLine();
              if (Char.ToUpper(user_inp[0]) != 'Y')
              {
                return (-1);
              }
              Console.WriteLine("");
            }
          }
        }
        catch (Exception ex)
        {
          Console.WriteLine("");
          Console.WriteLine("error using {0}", Sepia2_Lib.SEPIA2_LIB);
          Console.WriteLine("  Check the existence of the library '{0}'!", Sepia2_Lib.SEPIA2_LIB);
          Console.WriteLine("  Make sure that your runtime and the library are both either 32-bit or 64-bit!");
          Console.WriteLine("");
          Console.WriteLine("  system message: {0}", ex.Message);
          Console.Write("press RETURN... ");
          Console.ReadLine();
          //
          return Sepia2_Lib.SEPIA2_ERR_LIB_UNKNOWN_ERROR_CODE;
        }
        //
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
        #endregion Establish USB connection to the Sepia first matching all given conditions
        //
        //Console.WriteLine("Opening Device {0}", iDevIdx);
        //
        iRetVal = Sepia2_Lib.SEPIA2_USB_OpenDevice(iDevIdx, cProductModel, cSepiaSerNo);
        if (Sepia2FunctionSucceeds(iRetVal, "USB_OpenDevice", iDevIdx, NO_IDX_1, NO_IDX_2))
        {
          Console.WriteLine("     Product Model  = '{0}'", cProductModel);
          Console.WriteLine("");
          Console.WriteLine("{0}", STR_SEPARATORLINE);
          Console.WriteLine("");
          iRetVal = Sepia2_Lib.SEPIA2_FWR_GetVersion(iDevIdx, cFWVersion);
          if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetVersion", iDevIdx, NO_IDX_1, NO_IDX_2))
          {
            Console.WriteLine("     FW-Version     = {0}", cFWVersion);
          }
          //
          iRetVal = Sepia2_Lib.SEPIA2_USB_GetStrDescriptor(iDevIdx, cDescriptor);
          if (Sepia2FunctionSucceeds(iRetVal, "USB_GetStrDescriptor", iDevIdx, NO_IDX_1, NO_IDX_2))
          {
            Console.WriteLine("     USB Index      = {0}", iDevIdx);
            Console.WriteLine("     USB Descriptor = {0}", cDescriptor);
            Console.WriteLine("     Serial Number  = '{0}'", cSepiaSerNo);
          }
          Console.WriteLine("");
          Console.WriteLine("{0}", STR_SEPARATORLINE);
          Console.WriteLine(""); Console.WriteLine("");
          //
          // get sepia's module map and initialise datastructures for all library functions
          // there are two different ways to do so:
          //
          // first:  if sepia was not touched since last power on, it doesn't need to be restarted
          //
          iRetVal = Sepia2_Lib.SEPIA2_FWR_GetModuleMap(iDevIdx, Sepia2_Lib.SEPIA2_NO_RESTART, out iModuleCount);
          //
          // second: in case of changes with soft restart
          //
          //  iRetVal = Sepia2_Lib.SEPIA2_FWR_GetModuleMap (iDevIdx, Sepia2_Lib.SEPIA2_RESTART, out iModuleCount);
          if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetModuleMap", iDevIdx, NO_IDX_1, NO_IDX_2))
          {
            //
            // this is to inform us about possible error conditions during sepia's last startup
            //
            iRetVal = Sepia2_Lib.SEPIA2_FWR_GetLastError(iDevIdx, out iFWErrCode, out iFWErrPhase, out iFWErrLocation, out iFWErrSlot, cFWErrCond);
            if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetLastError", iDevIdx, NO_IDX_1, NO_IDX_2))
            {
              if (!HasFWError(iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond.ToString(), "Firmware error detected:"))
              {
                //
                #region look for SOM(D), SLM, VUV/VIR, PRI modules, take always the first
                //
                // now look for SOM(D), SLM, VUV/VIR, PRI modules, take always the first
                //
                for (i = 0; i < iModuleCount; i++)
                {
                  iRetVal = Sepia2_Lib.SEPIA2_FWR_GetModuleInfoByMapIdx(iDevIdx, i, out iSlotNr, out bIsPrimary, out bIsBackPlane, out bHasUptimeCounter);
                  if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetModuleInfoByMapIdx", iDevIdx, i, NO_IDX_2))
                  {
                    if ((bIsPrimary != 0) && (bIsBackPlane == 0))
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_COM_GetModuleType(iDevIdx, iSlotNr, Sepia2_Lib.SEPIA2_PRIMARY_MODULE, out iModuleType);
                      if (Sepia2FunctionSucceeds(iRetVal, "COM_GetModuleType", iDevIdx, iSlotNr, NO_IDX_2))
                      {
                        switch (iModuleType)
                        {
                          case Sepia2_Lib.SEPIA2OBJECT_SOM:
                          case Sepia2_Lib.SEPIA2OBJECT_SOMD:
                            if (!bSOM_Found)
                            {
                              bSOM_Found = true;
                              iSOM_Slot = iSlotNr;
                              iSOMModuleType = iModuleType;
                              bIsSOMDModule = (iModuleType == Sepia2_Lib.SEPIA2OBJECT_SOMD);
                              //
                              iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, Sepia2_Lib.SEPIA2_PRIMARY_MODULE, cSOMSerNr);
                              if (Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotNr, NO_IDX_2))
                              {
                                Sepia2_Lib.SEPIA2_COM_DecodeModuleTypeAbbr(iModuleType, cSOMType);
                                //
                                if (bIsSOMDModule)
                                {
                                  iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetStatusError(iDevIdx, iSOM_Slot, out wSOMDState, out iSOMDErrorCode);
                                  Sepia2FunctionSucceeds(iRetVal, "SOMD_GetStatusError", iDevIdx, iSOM_Slot, NO_IDX_2);
                                }
                              }  // end of 'SEPIA2_COM_GetSerialNumber'
                            }
                            break;
                          //
                          case Sepia2_Lib.SEPIA2OBJECT_SLM:
                            if (!bSLM_Found)
                            {
                              bSLM_Found = true;
                              iSLM_Slot = iSlotNr;
                              //
                              iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, Sepia2_Lib.SEPIA2_PRIMARY_MODULE, cSLMSerNr);
                              Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotNr, NO_IDX_2);
                            }
                            break;
                          //
                          case Sepia2_Lib.SEPIA2OBJECT_VUV:
                            if (!bVUV_Found)
                            {
                              bVUV_Found = true;
                              iVUV_Slot = iSlotNr;
                              //
                              iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, Sepia2_Lib.SEPIA2_PRIMARY_MODULE, cVUVSerNr);
                              Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotNr, NO_IDX_2);
                            }
                            break;
                          //
                          case Sepia2_Lib.SEPIA2OBJECT_VIR:
                            if (!bVIR_Found)
                            {
                              bVIR_Found = true;
                              iVIR_Slot = iSlotNr;
                              //
                              iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, Sepia2_Lib.SEPIA2_PRIMARY_MODULE, cVIRSerNr);
                              Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotNr, NO_IDX_2);
                            }
                            break;
                          //
                          case Sepia2_Lib.SEPIA2OBJECT_PRI:
                            if (!bPRI_Found)
                            {
                              bPRI_Found = true;
                              iPRI_Slot = iSlotNr;
                              //
                              PRIConst = new T_PRI_Constants(iDevIdx, iPRI_Slot);
                              //
                              iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, Sepia2_Lib.SEPIA2_PRIMARY_MODULE, cPRISerNr);
                              Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotNr, NO_IDX_2);
                            }
                            break;
                        } // switch
                      } // if SEPIA2_COM_GetModuleType
                    } // if bIsPrimary && !bIsBackPlane
                  } // if SEPIA2_FWR_GetModuleInfoByMapIdx
                } // for ModuleCount
                //
                if (cSOMType.ToString().CompareTo("SOM ") < 0)
                {
                  Sepia2_Lib.SEPIA2_COM_DecodeModuleTypeAbbr(Sepia2_Lib.SEPIA2OBJECT_SOM, cSOMType);
                }
                Sepia2_Lib.SEPIA2_COM_DecodeModuleTypeAbbr(Sepia2_Lib.SEPIA2OBJECT_SLM, cSLMType);
                Sepia2_Lib.SEPIA2_COM_DecodeModuleTypeAbbr(Sepia2_Lib.SEPIA2OBJECT_VUV, cVUVType);
                Sepia2_Lib.SEPIA2_COM_DecodeModuleTypeAbbr(Sepia2_Lib.SEPIA2OBJECT_VIR, cVIRType);
                Sepia2_Lib.SEPIA2_COM_DecodeModuleTypeAbbr(Sepia2_Lib.SEPIA2OBJECT_PRI, cPRIType);
                //
                // let all module types be exact 4 characters long:
                while (cSOMType.Length < 4)
                  cSOMType.Append(" ");
                cSOMType.Length = 4;
                while (cSLMType.Length < 4)
                  cSLMType.Append(" ");
                cSLMType.Length = 4;
                while (cVUVType.Length < 4)
                  cVUVType.Append(" ");
                cVUVType.Length = 4;
                while (cVIRType.Length < 4)
                  cVIRType.Append(" ");
                cVIRType.Length = 4;
                while (cPRIType.Length < 4)
                  cPRIType.Append(" ");
                cPRIType.Length = 4;

                #endregion look for SOM(D), SLM, VUV/VIR, PRI modules, take always the first
                //
                //
                // we want to restore the changed values ...
                //
                if (System.IO.File.Exists(FNAME))
                {
                  // ... so we have to read the original data from file
                  //
                  System.IO.FileStream f = new System.IO.FileStream(FNAME, System.IO.FileMode.Open);
                  //
                  #region Read all data from file

                  #region SOM
                  //
                  //   SOM
                  //
                  bSOM_FFound = StrToBool(GetValStr(f, String.Format("{0,4} ModuleFound   =", cSOMType)));
                  //
                  if (bSOM_FFound != bSOM_Found)
                  {
                    Console.WriteLine("");
                    f.Close();
                    f.Dispose();
                    Console.WriteLine("     device configuration probably changed:");
                    Console.WriteLine("     couldn't process original data as read from file '{0}'", FNAME);
                    Console.WriteLine("     file {0} SOM data, but", (bSOM_FFound ? "contains" : "doesn't contain"));
                    Console.WriteLine("     device has currently {0} SOM module", (bSOM_Found ? "a" : "no"));
                    Console.WriteLine("");
                    Console.WriteLine("     demo execution aborted.");
                    Console.WriteLine(""); Console.WriteLine("");
                    Console.Write("press RETURN...");
                    Console.ReadLine();
                    return (1);
                  }
                  if (bSOM_FFound)
                  {
                    //
                    // SOM / SOMD Data
                    //
                    iSOM_FSlot = StrToInt(GetValStr(f, String.Format("{0,4} SlotID        =", cSOMType)));
                    cSOMFSerNr = GetValStr(f, String.Format("{0,4} SerialNumber  =", cSOMType));
                    //
                    if ((iSOM_FSlot != iSOM_Slot) || (!cSOMFSerNr.ToString().Trim().Equals(cSOMSerNr.ToString().Trim())))
                    {
                      Console.WriteLine("");
                      f.Close();
                      f.Dispose();

                      Console.WriteLine("     device configuration probably changed:");
                      Console.WriteLine("     couldn't process original data as read from file '{0}'", FNAME);
                      Console.WriteLine("     file data on the slot or serial number of the SOM module differs");
                      Console.WriteLine("");
                      Console.WriteLine("     demo execution aborted.");
                      Console.WriteLine(""); Console.WriteLine("");
                      Console.Write("press RETURN...");
                      Console.ReadLine();
                      return (1);
                    }
                    //
                    // FreqTrigMode
                    //
                    iFreqTrigIdx = StrToInt(GetValStr(f, String.Format("{0,4} FreqTrigIdx   =", cSOMType)));
                    bExtTiggered = (iFreqTrigIdx == Sepia2_Lib.SEPIA2_SOM_TRIGMODE_RISING) || (iFreqTrigIdx == Sepia2_Lib.SEPIA2_SOM_TRIGMODE_FALLING);
                    //
                    if ("SOMD".Equals(cSOMType) && bExtTiggered)
                    {
                      iTemp1 = StrToInt(GetValStr(f, String.Format("{0,4} ExtTrig.Sync. =", cSOMType)));
                      bSynchronized = (byte)iTemp1;
                    }
                    //
                    iTemp1 = StrToInt(GetValStr(f, String.Format("{0,4} Divider       =", cSOMType)));
                    iTemp2 = StrToInt(GetValStr(f, String.Format("{0,4} PreSync       =", cSOMType)));
                    iTemp3 = StrToInt(GetValStr(f, String.Format("{0,4} MaskSync      =", cSOMType)));
                    bDivider = (byte)(iTemp1 % 256);
                    wDivider = (ushort)iTemp1;
                    bPreSync = (byte)iTemp2;
                    bMaskSync = (byte)iTemp3;
                    //
                    iTemp1 = StrToInt(GetValStr(f, String.Format("{0,4} Output Enable =", cSOMType)));
                    iTemp2 = StrToInt(GetValStr(f, String.Format("{0,4} Sync Enable   =", cSOMType)));
                    bOutEnable = (byte)iTemp1;
                    bSyncEnable = (byte)iTemp2;
                    bSyncInverse = (byte)(StrToBool(GetValStr(f, String.Format("{0,4} Sync Inverse  =", cSOMType))) ? 1 : 0);
                    for (i = 0; i < Sepia2_Lib.SEPIA2_SOM_BURSTCHANNEL_COUNT; i++)
                    {
                      lTemp = StrToInt(GetValStr(f, String.Format("{0,4} BurstLength {1} =", cSOMType, i + 1)));
                      lBurstChannels[i] = lTemp;
                    }
                  } // bSOM_FFound
                  #endregion SOM

                  #region SLM
                  //
                  //   SLM
                  //
                  bSLM_FFound = StrToBool(GetValStr(f, String.Format("{0,4} ModuleFound   =", cSLMType)));
                  //
                  if (bSLM_FFound != bSLM_Found)
                  {
                    Console.WriteLine("");
                    f.Close();
                    f.Dispose();
                    Console.WriteLine("     device configuration probably changed:");
                    Console.WriteLine("     couldn't process original data as read from file '{0}'", FNAME);
                    Console.WriteLine("     file {0} SLM data, but", (bSLM_FFound ? "contains" : "doesn't contain"));
                    Console.WriteLine("     device has currently {0} SLM module", (bSLM_Found ? "a" : "no"));
                    Console.WriteLine("");
                    Console.WriteLine("     demo execution aborted.");
                    Console.WriteLine(""); Console.WriteLine("");
                    Console.Write("press RETURN...");
                    Console.ReadLine();
                    return (1);
                  }
                  if (bSLM_FFound)
                  {
                    //
                    // SLM Data
                    //
                    iSLM_FSlot = StrToInt(GetValStr(f, String.Format("{0,4} SlotID        =", cSLMType)));
                    cSLMFSerNr = GetValStr(f, String.Format("{0,4} SerialNumber  =", cSLMType));
                    //
                    //
                    if ((iSLM_FSlot != iSLM_Slot) || (!cSLMFSerNr.ToString().Trim().Equals(cSLMSerNr.ToString().Trim())))
                    {
                      Console.WriteLine("");
                      f.Close();
                      f.Dispose();
                      Console.WriteLine("     device configuration probably changed:");
                      Console.WriteLine("     couldn't process original data as read from file '{0}'", FNAME);
                      Console.WriteLine("     file data on the slot or serial number of the SLM module differs");
                      Console.WriteLine("");
                      Console.WriteLine("     demo execution aborted.");
                      Console.WriteLine(""); Console.WriteLine("");
                      Console.Write("press RETURN...");
                      Console.ReadLine();
                      return (1);
                    }
                    //
                    iFreq = StrToInt(GetValStr(f, String.Format("{0,4} FreqTrigIdx   =", cSLMType)));
                    fIntensity = StrToFloat(GetValStr(f, String.Format("{0,4} Intensity     =", cSLMType)));
                    bPulseMode = (byte)(StrToBool(GetValStr(f, String.Format("{0,4} Pulse Mode    =", cSLMType))) ? 1 : 0);
                    wIntensity = (ushort)((int)(10 * fIntensity + 0.5));
                  } // bSLM_FFound
                  #endregion SLM

                  #region VUV
                  //
                  //   VUV
                  //
                  bVUV_FFound = StrToBool(GetValStr(f, String.Format("{0,4} ModuleFound   =", cVUVType)));
                  //
                  if (bVUV_FFound != bVUV_Found)
                  {
                    Console.WriteLine("");
                    f.Close();
                    f.Dispose();
                    Console.WriteLine("     device configuration probably changed:");
                    Console.WriteLine("     couldn't process original data as read from file '{0}'", FNAME);
                    Console.WriteLine("     file {0} VisUV data, but", (bVUV_FFound ? "contains" : "doesn't contain"));
                    Console.WriteLine("     device has currently {0} VUV module", (bVUV_Found ? "a" : "no"));
                    Console.WriteLine("");
                    Console.WriteLine("     demo execution aborted.");
                    Console.WriteLine(""); Console.WriteLine("");
                    Console.Write("press RETURN...");
                    Console.ReadLine();
                    return (1);
                  }
                  if (bVUV_FFound)
                  {
                    //
                    // VUV Data
                    //
                    iVUV_FSlot = StrToInt(GetValStr(f, String.Format("{0,4} SlotID        =", cVUVType)));
                    cVUVFSerNr = GetValStr(f, String.Format("{0,4} SerialNumber  =", cVUVType));
                    //
                    //
                    if ((iVUV_FSlot != iVUV_Slot) || (!cVUVFSerNr.ToString().Trim().Equals(cVUVSerNr.ToString().Trim())))
                    {
                      Console.WriteLine("");
                      f.Close();
                      f.Dispose();
                      Console.WriteLine("     device configuration probably changed:");
                      Console.WriteLine("     couldn't process original data as read from file '{0}'", FNAME);
                      Console.WriteLine("     file data on the slot or serial number of the VUV module differs");
                      Console.WriteLine("");
                      Console.WriteLine("     demo execution aborted.");
                      Console.WriteLine(""); Console.WriteLine("");
                      Console.Write("press RETURN...");
                      Console.ReadLine();
                      return (1);
                    }
                    //
                    Read_VUV_VIR_Data(f, cVUVType, IS_A_VUV);
                    //
                  } // bVUV_FFound
                  #endregion VUV

                  #region VIR
                  //
                  //   VIR
                  //
                  bVIR_FFound = StrToBool(GetValStr(f, String.Format("{0,4} ModuleFound   =", cVIRType)));
                  //
                  if (bVIR_FFound != bVIR_Found)
                  {
                    Console.WriteLine("");
                    f.Close();
                    f.Dispose();
                    Console.WriteLine("     device configuration probably changed:");
                    Console.WriteLine("     couldn't process original data as read from file '{0}'", FNAME);
                    Console.WriteLine("     file {0} VisIR data, but", (bVIR_FFound ? "contains" : "doesn't contain"));
                    Console.WriteLine("     device has currently {0} VIR module", (bVIR_Found ? "a" : "no"));
                    Console.WriteLine("");
                    Console.WriteLine("     demo execution aborted.");
                    Console.WriteLine(""); Console.WriteLine("");
                    Console.Write("press RETURN...");
                    Console.ReadLine();
                    return (1);
                  }
                  if (bVIR_FFound)
                  {
                    //
                    // VIR Data
                    //
                    iVIR_FSlot = StrToInt(GetValStr(f, String.Format("{0,4} SlotID        =", cVIRType)));
                    cVIRFSerNr = GetValStr(f, String.Format("{0,4} SerialNumber  =", cVIRType));
                    //
                    //
                    if ((iVIR_FSlot != iVIR_Slot) || (!cVIRFSerNr.ToString().Trim().Equals(cVIRSerNr.ToString().Trim())))
                    {
                      Console.WriteLine("");
                      f.Close();
                      f.Dispose();
                      Console.WriteLine("     device configuration probably changed:");
                      Console.WriteLine("     couldn't process original data as read from file '{0}'", FNAME);
                      Console.WriteLine("     file data on the slot or serial number of the VIR module differs");
                      Console.WriteLine("");
                      Console.WriteLine("     demo execution aborted.");
                      Console.WriteLine(""); Console.WriteLine("");
                      Console.Write("press RETURN...");
                      Console.ReadLine();
                      return (1);
                    }
                    //
                    //
                    Read_VUV_VIR_Data(f, cVIRType, IS_A_VIR);
                    //
                  } // bVIR_FFound
                  #endregion VIR

                  #region PRI
                  //
                  //   PRI
                  //
                  bPRI_FFound = StrToBool(GetValStr(f, String.Format("{0,4} ModuleFound   =", cPRIType)));
                  //
                  if (bPRI_FFound != bPRI_Found)
                  {
                    Console.WriteLine("");
                    f.Close();
                    f.Dispose();
                    Console.WriteLine("     device configuration probably changed:");
                    Console.WriteLine("     couldn't process original data as read from file '{0}'", FNAME);
                    Console.WriteLine("     file {0} Prima data, but", (bPRI_FFound ? "contains" : "doesn't contain"));
                    Console.WriteLine("     device has currently {0} PRI module", (bPRI_Found ? "a" : "no"));
                    Console.WriteLine("");
                    Console.WriteLine("     demo execution aborted.");
                    Console.WriteLine(""); Console.WriteLine("");
                    Console.Write("press RETURN...");
                    Console.ReadLine();
                    return (1);
                  }
                  if (bPRI_FFound)
                  {
                    //
                    // PRI Data
                    //
                    iPRI_FSlot = StrToInt(GetValStr(f, String.Format("{0,4} SlotID        =", cPRIType)));
                    cPRIFSerNr = GetValStr(f, String.Format("{0,4} SerialNumber  =", cPRIType));
                    //
                    //
                    if ((iPRI_FSlot != iPRI_Slot) || (!cPRIFSerNr.ToString().Trim().Equals(cPRISerNr.ToString().Trim())))
                    {
                      Console.WriteLine("");
                      f.Close();
                      f.Dispose();
                      Console.WriteLine("     device configuration probably changed:");
                      Console.WriteLine("     couldn't process original data as read from file '{0}'", FNAME);
                      Console.WriteLine("     file data on the slot or serial number of the PRI module differs");
                      Console.WriteLine("");
                      Console.WriteLine("     demo execution aborted.");
                      Console.WriteLine(""); Console.WriteLine("");
                      Console.Write("press RETURN...");
                      Console.ReadLine();
                      return (1);
                    }
                    //
                    //
                    iOpModeIdx = StrToInt  (GetValStr(f, String.Format("{0,4} OperModeIdx   =", cPRIType)));
                    iWL_Idx    = StrToInt  (GetValStr(f, String.Format("{0,4} WavelengthIdx =", cPRIType)));
                    fIntensity = StrToFloat(GetValStr(f, String.Format("{0,4} Intensity     =", cPRIType)));
                    wIntensity = (ushort)((int)(10 * fIntensity + 0.5));
                    //
                  } // bPRI_FFound
                  #endregion PRI
                  //
                  //
                  // ... and delete it afterwards
                  f.Close();
                  f.Dispose();
                  //
                  Console.WriteLine("     original data as read from file '{0}':", FNAME);
                  Console.WriteLine("     (file was deleted after processing)");
                  Console.WriteLine(""); Console.WriteLine("");
                  System.IO.File.Delete(FNAME);
                  #endregion Read all data from file
                  //
                } // read from file
                else
                {
                  // ... so we have to save the original data in a file
                  // ... and may then set arbitrary values
                  //
                  System.IO.StreamWriter f;
                  try { f = new System.IO.StreamWriter(FNAME, false); }
                  catch (Exception)
                  {
                    Console.WriteLine("     You tried to start this demo in a write protected directory.");
                    Console.WriteLine("");
                    Console.WriteLine("     demo execution aborted.");
                    Console.WriteLine(""); Console.WriteLine("");
                    Console.Write("press RETURN...");
                    Console.ReadLine();
                    //
                    return iRetVal;
                  }
                  f.NewLine = Console.Out.NewLine;
                  //
                  // SOM
                  //
                  f.WriteLine("{0,4} ModuleFound   =        {1}", cSOMType, BoolToStr(bSOM_Found));
                  if (bSOM_Found)
                  {
                    //
                    // SOM / SOMD
                    //
                    f.WriteLine("{0,4} SlotID        =      {1,3}", cSOMType, iSOM_Slot);
                    f.WriteLine("{0,4} SerialNumber  = {1,8}", cSOMType, cSOMSerNr);
                    //
                    // FreqTrigMode
                    //
                    if (bIsSOMDModule)
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetFreqTrigMode(iDevIdx, iSOM_Slot, out iFreqTrigIdx, out bSynchronized);
                      if (Sepia2FunctionSucceeds(iRetVal, "SOMD_GetFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2))
                      {
                        f.WriteLine("{0,4} FreqTrigIdx   =        {1,1}", cSOMType, iFreqTrigIdx);
                        if ((iFreqTrigIdx == Sepia2_Lib.SEPIA2_SOM_TRIGMODE_RISING) || (iFreqTrigIdx == Sepia2_Lib.SEPIA2_SOM_TRIGMODE_FALLING))
                        {
                          f.WriteLine("{0,4} ExtTrig.Sync. =        {1,1}", cSOMType, bSynchronized);
                        }
                      }
                    }
                    else
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_SOM_GetFreqTrigMode(iDevIdx, iSOM_Slot, out iFreqTrigIdx);
                      if (Sepia2FunctionSucceeds(iRetVal, "SOM_GetFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2))
                      {
                        f.WriteLine("{0,4} FreqTrigIdx   =        {1,1}", cSOMType, iFreqTrigIdx);
                      }
                    }
                    iFreqTrigIdx = Sepia2_Lib.SEPIA2_SOM_INT_OSC_C;
                    //
                    // BurstValues
                    //
                    if (bIsSOMDModule)
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetBurstValues(iDevIdx, iSOM_Slot, out wDivider, out bPreSync, out bMaskSync);
                      Sepia2FunctionSucceeds(iRetVal, "SOMD_GetBurstValues", iDevIdx, iSOM_Slot, NO_IDX_2);
                    }
                    else
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_SOM_GetBurstValues(iDevIdx, iSOM_Slot, out bDivider, out bPreSync, out bMaskSync);
                      if (Sepia2FunctionSucceeds(iRetVal, "SOM_GetBurstValues", iDevIdx, iSOM_Slot, NO_IDX_2))
                      {
                        wDivider = bDivider;
                      }
                    }
                    f.WriteLine("{0,4} Divider       =    {1,5}", cSOMType, wDivider);
                    f.WriteLine("{0,4} PreSync       =      {1,3}", cSOMType, bPreSync);
                    f.WriteLine("{0,4} MaskSync      =      {1,3}", cSOMType, bMaskSync);
                    bDivider = 200;
                    wDivider = 200;
                    bPreSync = 2;
                    bMaskSync = 1;
                    //
                    // Out'n'SyncEnable
                    //
                    if (bIsSOMDModule)
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetOutNSyncEnable(iDevIdx, iSOM_Slot, out bOutEnable, out bSyncEnable, out bSyncInverse);
                      if (Sepia2FunctionSucceeds(iRetVal, "SOMD_GetOutNSyncEnable", iDevIdx, iSOM_Slot, NO_IDX_2))
                      {
                        iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetBurstLengthArray(iDevIdx, iSOM_Slot, out lBurstChannels[0], out lBurstChannels[1], out lBurstChannels[2], out lBurstChannels[3], out lBurstChannels[4], out lBurstChannels[5], out lBurstChannels[6], out lBurstChannels[7]);
                        Sepia2FunctionSucceeds(iRetVal, "SOMD_GetBurstLengthArray", iDevIdx, iSOM_Slot, NO_IDX_2);
                      }
                    }
                    else
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_SOM_GetOutNSyncEnable(iDevIdx, iSOM_Slot, out bOutEnable, out bSyncEnable, out bSyncInverse);
                      if (Sepia2FunctionSucceeds(iRetVal, "SOM_GetOutNSyncEnable", iDevIdx, iSOM_Slot, NO_IDX_2))
                      {
                        iRetVal = Sepia2_Lib.SEPIA2_SOM_GetBurstLengthArray(iDevIdx, iSOM_Slot, out lBurstChannels[0], out lBurstChannels[1], out lBurstChannels[2], out lBurstChannels[3], out lBurstChannels[4], out lBurstChannels[5], out lBurstChannels[6], out lBurstChannels[7]);
                        Sepia2FunctionSucceeds(iRetVal, "SOM_GetBurstLengthArray", iDevIdx, iSOM_Slot, NO_IDX_2);
                      }
                    }
                    f.WriteLine("{0,4} Output Enable =     0x{1,2:X2}", cSOMType, bOutEnable);
                    f.WriteLine("{0,4} Sync Enable   =     0x{1,2:X2}", cSOMType, bSyncEnable);
                    f.WriteLine("{0,4} Sync Inverse  =        {1}", cSOMType, BoolToStr(bSyncInverse > 0));
                    bOutEnable = 0xA5;
                    bSyncEnable = 0x93;
                    bSyncInverse = 1;
                    //
                    // BurstLengthArray
                    //
                    for (i = 0; i < Sepia2_Lib.SEPIA2_SOM_BURSTCHANNEL_COUNT; i++)
                    {
                      f.WriteLine("{0,4} BurstLength {1} = {2,8}", cSOMType, i + 1, lBurstChannels[i]);
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
                  f.WriteLine("{0,4} ModuleFound   =        {1}", cSLMType, BoolToStr(bSLM_Found));
                  if (bSLM_Found)
                  {
                    //
                    // SLM
                    //
                    f.WriteLine("{0,4} SlotID        =      {1,3}", cSLMType, iSLM_Slot);
                    f.WriteLine("{0,4} SerialNumber  = {1,8}", cSLMType, cSLMSerNr);
                    //
                    //
                    iRetVal = Sepia2_Lib.SEPIA2_SLM_GetIntensityFineStep(iDevIdx, iSLM_Slot, out wIntensity);
                    if (Sepia2FunctionSucceeds(iRetVal, "SLM_GetIntensityFineStep", iDevIdx, iSLM_Slot, NO_IDX_2))
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_SLM_GetPulseParameters(iDevIdx, iSLM_Slot, out iFreq, out bPulseMode, out iHead);
                      Sepia2FunctionSucceeds(iRetVal, "SLM_GetPulseParameters", iDevIdx, iSLM_Slot, NO_IDX_2);
                    }
                    if (iRetVal == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
                    {
                      f.WriteLine("{0,4} FreqTrigIdx   =        {1,1}", cSLMType, iFreq);
                      f.WriteLine("{0,4} Pulse Mode    =        {1}", cSLMType, BoolToStr(bPulseMode > 0));
                      f.WriteLine("{0,4} Intensity     =      {1,5:F1} %", cSLMType, 0.1 * wIntensity);
                      iFreq = (2 + iFreq) % Sepia2_Lib.SEPIA2_SLM_FREQ_TRIGMODE_COUNT;
                      bPulseMode = (byte)(1 - bPulseMode);
                      wIntensity = (ushort)(1000 - wIntensity);
                    }
                    else
                    {
                      iFreq = Sepia2_Lib.SEPIA2_SLM_FREQ_20MHZ;
                      bPulseMode = 1;
                      wIntensity = 440;
                    }
                  }
                  //
                  //
                  //
                  f.WriteLine("{0,4} ModuleFound   =        {1}", cVUVType, BoolToStr(bVUV_Found));
                  if (bVUV_Found)
                  {
                    //
                    // VisUV
                    //
                    f.WriteLine("{0,4} SlotID        =      {1,3}", cVUVType, iVUV_Slot);
                    f.WriteLine("{0,4} SerialNumber  = {1,8}", cVUVType, cVUVSerNr);
                    //
                    GetWriteAndModify_VUV_VIR_Data(f, cVUVType, iVUV_Slot, IS_A_VUV);
                    //
                  }
                  //
                  //
                  f.WriteLine("{0,4} ModuleFound   =        {1}", cVIRType, BoolToStr(bVIR_Found));
                  if (bVIR_Found)
                  {
                    //
                    // VisIR
                    //
                    f.WriteLine("{0,4} SlotID        =      {1,3}", cVIRType, iVIR_Slot);
                    f.WriteLine("{0,4} SerialNumber  = {1,8}", cVIRType, cVIRSerNr);
                    //
                    GetWriteAndModify_VUV_VIR_Data(f, cVIRType, iVIR_Slot, IS_A_VIR);
                    //
                  }
                  //
                  //
                  f.WriteLine("{0,4} ModuleFound   =        {1}", cPRIType, BoolToStr(bPRI_Found));
                  if (bPRI_Found)
                  {
                    //
                    // Prima
                    //
                    f.WriteLine("{0,4} SlotID        =      {1,3}", cPRIType, iPRI_Slot);
                    f.WriteLine("{0,4} SerialNumber  = {1,8}", cPRIType, cPRISerNr);
                    //
                    iRetVal = Sepia2_Lib.SEPIA2_PRI_GetOperationMode(iDevIdx, iPRI_Slot, out iOpModeIdx);
                    if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetOperationMode", iDevIdx, iPRI_Slot, NO_IDX_2))
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_PRI_GetWavelengthIdx(iDevIdx, iPRI_Slot, out iWL_Idx);
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetWavelengthIdx", iDevIdx, iPRI_Slot, NO_IDX_2))
                      {
                        iRetVal = Sepia2_Lib.SEPIA2_PRI_GetIntensity(iDevIdx, iPRI_Slot, iWL_Idx, out wIntensity);
                        Sepia2FunctionSucceeds(iRetVal, "PRI_GetIntensity", iDevIdx, iPRI_Slot, iWL_Idx);
                      }
                    }
                    //
                    if (iRetVal == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
                    {
                      f.WriteLine("{0,4} OperModeIdx   =        {1}", cPRIType, iOpModeIdx);
                      f.WriteLine("{0,4} WavelengthIdx =        {1}", cPRIType, iWL_Idx);
                      f.WriteLine("{0,4} Intensity     =      {1,5:F1} %", cPRIType, 0.1 * wIntensity);
                      //
                      iOpModeIdx = ((iOpModeIdx == PRIConst.PrimaOpModBroad) ? PRIConst.PrimaOpModNarrow : PRIConst.PrimaOpModBroad);
                      iWL_Idx    = ((++iWL_Idx) % PRIConst.PrimaWLCount);
                      wIntensity = (ushort)(1000 - wIntensity);
                    }
                    else
                    {
                      iOpModeIdx = ((iOpModeIdx == PRIConst.PrimaOpModBroad) ? PRIConst.PrimaOpModNarrow : PRIConst.PrimaOpModBroad);
                      iWL_Idx    = ((iWL_Idx == 0) ? 1 : 0);
                      wIntensity = 440;
                    }
                  }
                  //
                  f.Flush();
                  f.Close();
                  f.Dispose();
                  //
                  Console.WriteLine("     original data was stored in file '{0}'.", FNAME);
                  Console.WriteLine("     changed data as follows:");
                  Console.WriteLine("");
                } // write to file
                //
                //
                // and here we finally set the new (resp. old) values
                //
                if (bSOM_Found)
                {
                  if (bIsSOMDModule)
                  {
                    iRetVal = Sepia2_Lib.SEPIA2_SOMD_SetFreqTrigMode(iDevIdx, iSOM_Slot, iFreqTrigIdx, bSynchronized);
                    if (Sepia2FunctionSucceeds(iRetVal, "SOMD_SetFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2))
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_SOMD_DecodeFreqTrigMode(iDevIdx, iSOM_Slot, iFreqTrigIdx, cFreqTrigMode);
                      if (Sepia2FunctionSucceeds(iRetVal, "SOMD_DecodeFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2))
                      {
                        iRetVal = Sepia2_Lib.SEPIA2_SOMD_SetBurstValues(iDevIdx, iSOM_Slot, wDivider, bPreSync, bMaskSync);
                        if (Sepia2FunctionSucceeds(iRetVal, "SOMD_SetBurstValues", iDevIdx, iSOM_Slot, NO_IDX_2))
                        {
                          iRetVal = Sepia2_Lib.SEPIA2_SOMD_SetOutNSyncEnable(iDevIdx, iSOM_Slot, bOutEnable, bSyncEnable, bSyncInverse);
                          if (Sepia2FunctionSucceeds(iRetVal, "SOMD_SetOutNSyncEnable", iDevIdx, iSOM_Slot, NO_IDX_2))
                          {
                            iRetVal = Sepia2_Lib.SEPIA2_SOMD_SetBurstLengthArray(iDevIdx, iSOM_Slot, lBurstChannels[0], lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7]);
                            Sepia2FunctionSucceeds(iRetVal, "SOMD_SetBurstLengthArray", iDevIdx, iSOM_Slot, NO_IDX_2);
                          }
                        }
                      }
                    }
                  }
                  else
                  {
                    bDivider = (byte)(wDivider % 256);
                    iRetVal = Sepia2_Lib.SEPIA2_SOM_SetFreqTrigMode(iDevIdx, iSOM_Slot, iFreqTrigIdx);
                    if (Sepia2FunctionSucceeds(iRetVal, "SOM_SetFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2))
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_SOM_DecodeFreqTrigMode(iDevIdx, iSOM_Slot, iFreqTrigIdx, cFreqTrigMode);
                      if (Sepia2FunctionSucceeds(iRetVal, "SOM_DecodeFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2))
                      {
                        iRetVal = Sepia2_Lib.SEPIA2_SOM_SetBurstValues(iDevIdx, iSOM_Slot, bDivider, bPreSync, bMaskSync);
                        if (Sepia2FunctionSucceeds(iRetVal, "SOM_SetBurstValues", iDevIdx, iSOM_Slot, NO_IDX_2))
                        {
                          iRetVal = Sepia2_Lib.SEPIA2_SOM_SetOutNSyncEnable(iDevIdx, iSOM_Slot, bOutEnable, bSyncEnable, bSyncInverse);
                          if (Sepia2FunctionSucceeds(iRetVal, "SOM_SetOutNSyncEnable", iDevIdx, iSOM_Slot, NO_IDX_2))
                          {
                            Sepia2_Lib.SEPIA2_SOM_SetBurstLengthArray(iDevIdx, iSOM_Slot, lBurstChannels[0], lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7]);
                            Sepia2FunctionSucceeds(iRetVal, "SOM_SetBurstLengthArray", iDevIdx, iSOM_Slot, NO_IDX_2);
                          }
                        }
                      }
                    }
                  }
                  Console.WriteLine("     {0,4} FreqTrigMode  =      '{1}'", cSOMType, cFreqTrigMode);
                  if ((bIsSOMDModule) && ((iFreqTrigIdx == Sepia2_Lib.SEPIA2_SOM_TRIGMODE_RISING) || (iFreqTrigIdx == Sepia2_Lib.SEPIA2_SOM_TRIGMODE_FALLING)))
                  {
                    Console.WriteLine("     {0,4} ExtTrig.Sync. =        {1}", cSOMType, bSynchronized);
                  }
                  //
                  Console.WriteLine("     {0,4} Divider       =    {1,5}", cSOMType, wDivider);
                  Console.WriteLine("     {0,4} PreSync       =      {1,3}", cSOMType, bPreSync);
                  Console.WriteLine("     {0,4} MaskSync      =      {1,3}", cSOMType, bMaskSync);
                  //
                  Console.WriteLine("     {0,4} Output Enable =     0x{1,2:X2}", cSOMType, bOutEnable);
                  Console.WriteLine("     {0,4} Sync Enable   =     0x{1,2:X2}", cSOMType, bSyncEnable);
                  Console.WriteLine("     {0,4} Sync Inverse  =        {1}", cSOMType, BoolToStr(bSyncInverse > 0));
                  //
                  Console.WriteLine("     {0,4} BurstLength 2 = {1,8}", cSOMType, lBurstChannels[1]);
                  Console.WriteLine("     {0,4} BurstLength 3 = {1,8}", cSOMType, lBurstChannels[2]);
                  Console.WriteLine("");
                }
                //
                // SLM
                //
                if (bSLM_Found)
                {
                  iRetVal = Sepia2_Lib.SEPIA2_SLM_SetPulseParameters(iDevIdx, iSLM_Slot, iFreq, bPulseMode);
                  if (Sepia2FunctionSucceeds(iRetVal, "SLM_SetPulseParameters", iDevIdx, iSLM_Slot, NO_IDX_2))
                  {
                    iRetVal = Sepia2_Lib.SEPIA2_SLM_SetIntensityFineStep(iDevIdx, iSLM_Slot, wIntensity);
                    if (Sepia2FunctionSucceeds(iRetVal, "SLM_SetIntensityFineStep", iDevIdx, iSLM_Slot, NO_IDX_2))
                    {
                      Sepia2_Lib.SEPIA2_SLM_DecodeFreqTrigMode(iFreq, cFreqTrigMode);
                      Console.WriteLine("     {0,4} FreqTrigMode  =      '{1}'", cSLMType, cFreqTrigMode);
                      Console.WriteLine("     {0,4} Pulse Mode    =        {1}", cSLMType, BoolToStr(bPulseMode > 0));
                      Console.WriteLine("     {0,4} Intensity     =      {1,5:F1} %", cSLMType, 0.1 * wIntensity);
                      Console.WriteLine("");
                    }
                  }
                }
                //
                // VisUV
                //
                if (bVUV_Found)
                {
                  Set_VUV_VIR_Data(cVUVType, iVUV_Slot, IS_A_VUV);
                }
                //
                // VisIR
                //
                if (bVIR_Found)
                {
                  Set_VUV_VIR_Data(cVIRType, iVIR_Slot, IS_A_VIR);
                }
                //
                // Prima
                //
                if (bPRI_Found)
                {
                  iRetVal = Sepia2_Lib.SEPIA2_PRI_SetOperationMode(iDevIdx, iPRI_Slot, iOpModeIdx);
                  if (Sepia2FunctionSucceeds(iRetVal, "PRI_SetOperationMode", iDevIdx, iPRI_Slot, NO_IDX_2))
                  {
                    iRetVal = Sepia2_Lib.SEPIA2_PRI_DecodeOperationMode(iDevIdx, iPRI_Slot, iOpModeIdx, cOperMode);
                    if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeOperationMode", iDevIdx, iPRI_Slot, iOpModeIdx))
                    {
                      iRetVal = Sepia2_Lib.SEPIA2_PRI_SetWavelengthIdx(iDevIdx, iPRI_Slot, iWL_Idx);
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_SetWavelengthIdx", iDevIdx, iPRI_Slot, NO_IDX_2))
                      {
                        iRetVal = Sepia2_Lib.SEPIA2_PRI_SetIntensity(iDevIdx, iPRI_Slot, iWL_Idx, wIntensity);
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_SetIntensity", iDevIdx, iPRI_Slot, iWL_Idx))
                        {
                          cOperMode = trim(cOperMode, cOperMode.ToString());
                          Console.WriteLine("     {0,4} OperModeIdx   =        {1}  ==> '{2}'", cPRIType, iOpModeIdx, cOperMode);
                          Console.WriteLine("     {0,4} WavelengthIdx =        {1}  ==> {2} nm", cPRIType, iWL_Idx, PRIConst.PrimaWLs[iWL_Idx]);
                          Console.WriteLine("     {0,4} Intensity     =      {1,5:F1} %", cPRIType, 0.1 * wIntensity);
                          Console.WriteLine("");
                        }
                      }
                    }
                  }
                }
              } // (iFWErrCode == SEPIA2_ERR_NO_ERROR)
            } // else GetLastError
          } // if GetModuleMap
          else
          {
            iRetVal = Sepia2_Lib.SEPIA2_FWR_GetLastError(iDevIdx, out iFWErrCode, out iFWErrPhase, out iFWErrLocation, out iFWErrSlot, cFWErrCond);
            if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetLastError", iDevIdx, NO_IDX_1, NO_IDX_2))
            {
              HasFWError(iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, String.Format("{0}", cFWErrCond), String.Format("Firmware error detected:"));
            }
          }
          //
          Sepia2_Lib.SEPIA2_FWR_FreeModuleMap(iDevIdx);
          Sepia2_Lib.SEPIA2_USB_CloseDevice(iDevIdx);
        }
        //
        Console.WriteLine("");
        if (!bNoWait)
        {
          Console.Write("press RETURN...");
          Console.ReadLine();
        }
        //
        return iRetVal;
      }
    }
  }
}
