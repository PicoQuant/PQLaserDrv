# ReadAllDataByPython

import Sepia2_Def
import Sepia2_ErrorCodes
from Sepia2_Lib import SEPIA2_LIB_DLL_NAME
from Sepia2_Lib import Sepia2_Lib

import sys
#import struct
import ctypes as ct
from ctypes import byref

#from MigrationHelper import NO_DEVIDX
from MigrationHelper import NO_IDX_1
from MigrationHelper import NO_IDX_2
from MigrationHelper import Sepia2FunctionSucceeds
from MigrationHelper import atof
from MigrationHelper import IntToBin
from MigrationHelper import FormatEng
from MigrationHelper import T_PRI_Constants

import locale

locale.setlocale(locale.LC_ALL, 'en-US')


# -----------------------------------------------------------------------------
#
#     ReadAllDataByPython
#
# -----------------------------------------------------------------------------
#
#   Illustrates the functions exported by SEPIA2_Lib
#   Scans the whole PQLaserDrv rack and displays all relevant data
#
#   Consider, this code is for demonstration purposes only.
#   Don't use it in productive environments!
#
# -----------------------------------------------------------------------------
#   HISTORY:
#
#   apo  06.02.06   created
#
#   apo  12.02.07   introduced SML Multilaser Module (V1.0.2.0)
#
#   apo  05.02.14   introduced new map oriented API functions (V1.0.3.282)
#
#   apo  05.09.14   adapted to DLL version 1.1.<target>.<svn_build>
#
#   apo  18.06.15   substituted deprecated SLM functions
#           introduced SOM-D Oscillator Module w. Delay Option (V1.1.xx.450)
#
#   apo  22.01.21   adapted to DLL version 1.2.<target>.<svn_build>
#
#   apo  28.01.21   introduced VIR, VUV module functions (for VisUV/IR) (V1.2.xx.641)
#
#   dsc  20.04.21   introduced ReadAllDataByPython-demo
#
#   apo  30.08.22   introduced PRI module functions (for Prima, Quader) (V1.2.xx.753)
#
# -----------------------------------------------------------------------------
#
#
#
#
def PrintUptimers(ulMainPowerUp, ulActivePowerUp, ulScaledPowerUp):
  # ulong ulMainPowerUp, ulong ulActivePowerUp, ulong ulScaledPowerUp
  #
  hlp = (int)(5.0 * (ulMainPowerUp + 0x7F) / 0xFF)
  print("")
  print("%47s  = %5d:%2d h" % ("main power uptime", hlp / 60, hlp % 60))
  #
  if ulActivePowerUp > 1:
    hlp = (int)(5.0 * (ulActivePowerUp + 0x7F) / 0xFF)
    print("%47s  = %5d:%2d hrs" % ("act. power uptime", hlp / 60, hlp % 60))
  #
  if ulScaledPowerUp > (0.001 * ulActivePowerUp):
    print("%47s  =     %5.1f%%" % ("pwr scaled factor", 100.0 * ulScaledPowerUp / ulActivePowerUp))
    print("")
  #
  print("")
#
#


def HasFWError(iFWErr, iPhase, iLocation, iSlot, cFWErrCond, cPromptString):
  # int iFWErr, int iPhase, int iLocation, int iSlot, string cFWErrCond, string cPromptString
  cErrTxt = ct.create_string_buffer(b"", Sepia2_Def.SEPIA2_ERRSTRING_LEN)
  cPhase = ct.create_string_buffer(b"", Sepia2_Def.SEPIA2_FW_ERRPHASE_LEN)
  #
  bRet = (iFWErr != Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR)
  #
  if (bRet):
    print("  %s" % (cPromptString))
    print("")
    Sepia2_Lib.SEPIA2_LIB_DecodeError(iFWErr, cErrTxt)
    Sepia2_Lib.SEPIA2_FWR_DecodeErrPhaseName(iPhase, cPhase)
    print("     error code    : %5d,   i.e. '%s'" % (iFWErr, cErrTxt.value.decode("utf-8")))
    print("     error phase   : %5d,   i.e. '%s'" % (iPhase, cPhase.value.decode("utf-8")))
    print("     error location  : %5d" % (iLocation))
    print("     error slot    : %5d" % (iSlot))
    if (len(cFWErrCond) > 0):
      print("     error condition : '%s'" % (cFWErrCond))
    #
    print("")
  #
  return bRet
#
#
#
# public static int main(string[] argv)
#
def main(argv):
  #
  # region buffers and variables
  #
  STR_SEPARATORLINE = "  ============================================================"
  iRetVal = Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR
  #
  #
  cLibVersion = ct.create_string_buffer(Sepia2_Def.SEPIA2_VERSIONINFO_LEN)
  cDescriptor = ct.create_string_buffer(Sepia2_Def.SEPIA2_USB_STRDECR_LEN)
  cSepiaSerNo = ct.create_string_buffer(Sepia2_Def.SEPIA2_SERIALNUMBER_LEN)
  cGivenSerNo = ""
  cProductModel = ct.create_string_buffer(Sepia2_Def.SEPIA2_PRODUCTMODEL_LEN)
  cGivenProduct = ct.create_string_buffer(Sepia2_Def.SEPIA2_PRODUCTMODEL_LEN)
  cFWVersion = ct.create_string_buffer(Sepia2_Def.SEPIA2_VERSIONINFO_LEN)
  cFWErrCond = ct.create_string_buffer(Sepia2_Def.SEPIA2_FW_ERRCOND_LEN)
  #cFWErrPhase = ct.create_string_buffer(Sepia2_Def.SEPIA2_FW_ERRPHASE_LEN)
  #cErrString = ct.create_string_buffer(Sepia2_Def.SEPIA2_ERRSTRING_LEN)
  cModulType = ct.create_string_buffer(Sepia2_Def.SEPIA2_MODULETYPESTRING_LEN)
  cFreqTrigMode = ct.create_string_buffer(Sepia2_Def.SEPIA2_SOM_FREQ_TRIGMODE_LEN)
  cFrequency = ct.create_string_buffer(Sepia2_Def.SEPIA2_SLM_FREQ_TRIGMODE_LEN)
  cHeadType = ct.create_string_buffer(Sepia2_Def.SEPIA2_SLM_HEADTYPE_LEN)
  cSerialNumber = ct.create_string_buffer(Sepia2_Def.SEPIA2_SERIALNUMBER_LEN)
  cSWSModuleType = ct.create_string_buffer(Sepia2_Def.SEPIA2_SWS_MODULETYPE_LEN)
  cTemp1 = ct.create_string_buffer(65)
  cTemp2 = ct.create_string_buffer(65)
  cBuffer = ct.create_string_buffer(262145)
  cPreamble = ct.create_string_buffer(2048)
  cCallingSW = ct.create_string_buffer(2048)
  cDevType = ct.create_string_buffer(Sepia2_Def.SEPIA2_VUV_VIR_DEVTYPE_LEN)
  #cTrigMode = ct.create_string_buffer(Sepia2_Def.SEPIA2_VUV_VIR_TRIGINFO_LEN)
  cFreqTrigSrc = ct.create_string_buffer(Sepia2_Def.SEPIA2_VUV_VIR_TRIGINFO_LEN)
  cOpMode = ct.create_string_buffer(Sepia2_Def.SEPIA2_PRI_OPERMODE_LEN)
  cTrigSrc = ct.create_string_buffer(Sepia2_Def.SEPIA2_PRI_TRIGSRC_LEN)
  #
  #
  lBurstChannels = [ct.c_int(0), ct.c_int(0), ct.c_int(0), ct.c_int(0),
                    ct.c_int(0), ct.c_int(0), ct.c_int(0), ct.c_int(0)]
  #
  iRestartOption = Sepia2_Def.SEPIA2_NO_RESTART
  iDevIdx = -1
  iGivenDevIdx = 0
  #
  # int
  iModuleCount = ct.c_int(0)
  iFWErrCode = ct.c_int(0)
  iFWErrPhase = ct.c_int(0)
  iFWErrLocation = ct.c_int(0)
  iFWErrSlot = ct.c_int(0)
  iMapIdx = 0
  iSlotId = ct.c_int(0)
  iModuleType = ct.c_int(0)
  iFreqTrigIdx = ct.c_int(0)
  iFrequency = ct.c_int(0)
  iHead = ct.c_int(0)
  iTrigSrcIdx = ct.c_int(0)
  iFreqDivIdx = ct.c_int(0)
  iTriggerMilliVolt = ct.c_int(0)
  iIntensity = ct.c_int(0)
  iSWSModuleType = ct.c_int(0)
  iWL_Idx = ct.c_int(0)
  iOM_Idx = ct.c_int(0)
  iTS_Idx = ct.c_int(0)
  iMinFreq = ct.c_int(0)
  iMaxFreq = ct.c_int(0)
  iFreq = ct.c_int(0)
  iMinTrgLvl = ct.c_int(0)
  iMaxTrgLvl = ct.c_int(0)
  iResTrgLvl = ct.c_int(0)
  iMinOnTime = ct.c_int(0)
  iMaxOnTime = ct.c_int(0)
  iOnTime = ct.c_int(0)
  iMinOffTimefact = ct.c_int(0)
  iMaxOffTimefact = ct.c_int(0)
  iOffTimefact = ct.c_int(0)
  iFormatWidth = ct.c_int(0)
  iDummy = ct.c_int(0)
  #
  PRI_Const = T_PRI_Constants()
  #
  #  byte
  bUSBInstGiven = False
  bSerialGiven = False
  bProductGiven = False
  bNoWait = False
  bStayOpened = False
  bLinux = ct.c_byte(0)
  bIsPrimary = ct.c_byte(0)
  bIsBackPlane = ct.c_byte(0)
  bHasUptimeCounter = ct.c_byte(0)
  bLock = ct.c_byte(0)
  bSLock = ct.c_byte(0)
  bSynchronize = ct.c_byte(0)  # for SOM-D
  bPulseMode = ct.c_byte(0)
  bDivider = ct.c_byte(0)
  bPreSync = ct.c_byte(0)
  bMaskSync = ct.c_byte(0)
  bOutEnable = ct.c_byte(0)
  bSyncEnable = ct.c_byte(0)
  bSyncInverse = ct.c_byte(0)
  bFineDelayStepCount = ct.c_byte(0)  # for SOM-D
  bDelayed = ct.c_byte(0)  # for SOM-D
  bForcedUndelayed = ct.c_byte(0)  # for SOM-D
  bFineDelay = ct.c_byte(0)  # for SOM-D
  bOutCombi = ct.c_byte(0)  # for SOM-D
  bMaskedCombi = ct.c_byte(0)  # for SOM-D
  bTrigLevelEnabled = ct.c_byte(0)
  bIntensity = ct.c_byte(0)
  bTBNdx = ct.c_byte(0)  # for PPL 400
  bHasCW = ct.c_byte(0)  # for VisUV/IR
  bHasFanSwitch = ct.c_byte(0)  # for VisUV/IR
  bIsFanRunning = ct.c_byte(0)  # for VisUV/IR
  bDivListEnabled = ct.c_byte(0)  # for VisUV/IR
  bTrigLvlEnabled = ct.c_byte(0)  # for VisUV/IR, Prima
  bFreqncyEnabled = ct.c_byte(0)  # for Prima/Quader
  bGatingEnabled = ct.c_byte(0)    # for Prima/Quader
  bGateHiImp = ct.c_byte(0)    # for Prima/Quader
  bDummy1 = ct.c_byte(0)  # for VisUV/IR
  bDummy2 = ct.c_byte(0)  # for VisUV/IR
  #
  #  word
  wIntensity = ct.c_ushort(0)
  wDivider = ct.c_ushort(0)
  wPAPml = ct.c_ushort(0)  # for PPL 400
  wRRPml = ct.c_ushort(0)  # for PPL 400
  wPSPml = ct.c_ushort(0)  # for PPL 400
  wRSPml = ct.c_ushort(0)  # for PPL 400
  wWSPml = ct.c_ushort(0)  # for PPL 400
  #
  #  float
  fFrequency = ct.c_float(0)
  fIntensity = ct.c_float(0)
  #
  lBurstSum = 0
  ulWaveLength = ct.c_uint(0)
  ulBandWidth = ct.c_uint(0)
  sBeamVPos = ct.c_short(0)
  sBeamHPos = ct.c_short(0)
  ulIntensRaw = ct.c_uint(0)
  ulMainPowerUp = ct.c_uint(0)
  ulActivePowerUp = ct.c_uint(0)
  ulScaledPowerUp = ct.c_uint(0)
  #
  f64CoarseDelayStep = ct.c_double(0)  # for SOM-D
  f64CoarseDelay = ct.c_double(0)  # for SOM-D
  #
  #
  #
  SWSFWVers = Sepia2_Def.T_Module_FWVers()
  #
  i = 0
  j = 0
  pos = 0
  parameter_found = False
  #
  #
  # endregion buffers and variables
  #
  #
  Sepia2_Lib.SEPIA2_LIB_IsRunningOnWine(byref(bLinux))
  if (bLinux != 0):
    newLine = "\n"
  else:
    newLine = "\r\n"
  #
  cPreamble.value = newLine.encode('utf-8')
  cPreamble.value += "   Following are system describing common infos,".encode('utf-8')
  cPreamble.value += newLine.encode('utf-8')
  cPreamble.value += "   the considerate support team of PicoQuant GmbH".encode('utf-8')
  cPreamble.value += newLine.encode('utf-8')
  cPreamble.value += "   demands for your qualified service request:".encode('utf-8')
  cPreamble.value += newLine.encode('utf-8')
  cPreamble.value += newLine.encode('utf-8')
  cPreamble.value += "  ============================================================".encode('utf-8')
  cPreamble.value += newLine.encode('utf-8')
  cPreamble.value += newLine.encode('utf-8')
  #
  cCallingSW.value = "Demo-Program:   ReadAllDataByPython.py".encode('utf-8')
  cCallingSW.value += newLine.encode('utf-8')
  #
  #  print(cCallingSW.value.decode("utf-8"))
  #  print(cPreamble.value.decode("utf-8"))
  #  return 0
  #
  if (len(argv) - 1 == 0):
    print(" called without parameters")
  else:
    print(" called with %d Parameter%s:" % (len(argv) - 1, "s" if len(argv) > 2 else ""))
    #
    # region CMD-Args checks
    #
    # for cmd_arg in argv:
    for i in range(1, len(argv)):
      parameter_found = False
      cmd_arg = argv[i]
      #
      pos = cmd_arg.find("-inst=")
      if (pos >= 0):
        iGivenDevIdx = (int)(cmd_arg[pos + 6:])  # throws an exception if the value is no number
        #
        bUSBInstGiven = True
        parameter_found = True
        print("  -inst=%d" % (iGivenDevIdx))
      #
      pos = cmd_arg.find("-serial=")
      if (pos >= 0):
        cGivenSerNo = cmd_arg[pos + 8:]
        if (len(cGivenSerNo) > Sepia2_Def.SEPIA2_SERIALNUMBER_LEN):
          cGivenSerNo = cGivenSerNo[0: Sepia2_Def.SEPIA2_SERIALNUMBER_LEN]
        #
        bSerialGiven = len(cGivenSerNo) > 0
        parameter_found = True
        print("  -serial=%s" % (cGivenSerNo))
      #
      pos = cmd_arg.find("-product=")
      if (pos >= 0):
        cGivenProduct = cmd_arg[pos + 9:]
        if (len(cGivenProduct) > Sepia2_Def.SEPIA2_PRODUCTMODEL_LEN):
          cGivenProduct = cGivenProduct[0: Sepia2_Def.SEPIA2_PRODUCTMODEL_LEN]
        #
        bProductGiven = len(cGivenProduct) > 0
        parameter_found = True
        print("  -product=%s" % (cGivenProduct))
      #
      pos = cmd_arg.find("-stayopened")
      if (pos >= 0):
        bStayOpened = True
        parameter_found = True
        print("  -stayopened")
      #
      pos = cmd_arg.find("-nowait")
      if (pos >= 0):
        bNoWait = True
        parameter_found = True
        print("  -nowait")
      #
      pos = cmd_arg.find("-restart")
      if (pos >= 0):
        iRestartOption = Sepia2_Def.SEPIA2_RESTART
        parameter_found = True
        print("  -restart")
      #
      #
      if(not parameter_found):
        print("  %s : unknown parameter!" % cmd_arg)
      #
    #
    # endregion CMD-Args checks
    #
  #
  print("")
  print("")
  print("   PQLaserDrv   Read ALL Values Demo : ")
  print(STR_SEPARATORLINE)
  print("")
  print("")
  #
  #
  #  preliminaries: check library version
  #
  try:
    iRetVal = Sepia2_Lib.SEPIA2_LIB_GetVersion(cLibVersion)
    if (not Sepia2FunctionSucceeds(iRetVal, "LIB_GetVersion", -1, NO_IDX_1, NO_IDX_2)):  # NO_DEVIDX
      return iRetVal
    #
  except Exception as ex:
    print("error using %s" % SEPIA2_LIB_DLL_NAME)
    print("  Check the existence of the library '%s'!" % SEPIA2_LIB_DLL_NAME)
    print("  Make sure that your runtime and the library are both either 32-bit or 64-bit!")
    print("")
    print("  system message: %s" % ex)
    if (not bNoWait):
      print("press RETURN... ")
      input()
    return Sepia2_ErrorCodes.SEPIA2_ERR_LIB_UNKNOWN_ERROR_CODE
  #
  #
  print("   Lib-Version    = %s" % cLibVersion.value.decode("utf-8"))
  #
  #
  if (not cLibVersion.value.decode("utf-8").startswith(Sepia2_Def.LIB_VERSION_REFERENCE[0: Sepia2_Def.LIB_VERSION_REFERENCE_COMPLEN])):
    print("")
    print("   Warning: This demo application was built for version  %s!" % Sepia2_Def.LIB_VERSION_REFERENCE)
    print("        Continuing may cause unpredictable results!")
    print("")
    print("   Do you want to continue anyway? (y/n): ")

    user_inp = input()
    if (not user_inp.upper().startswith("Y")):
      return -1
    #
    print("")
  #
  # endregion check library version
  #
  #
  # region Establish USB connection to the Sepia first matching all given conditions
  #
  if (bUSBInstGiven):
    i = iGivenDevIdx
    pos = i + 1
  else:
    i = 0
    pos = Sepia2_Def.SEPIA2_MAX_USB_DEVICES
  #
  while(i < pos):
    cSepiaSerNo.value = b""
    cProductModel.value = b""
    #
    iRetVal = Sepia2_Lib.SEPIA2_USB_OpenGetSerNumAndClose(i, cProductModel, cSepiaSerNo)
    if ((iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR)
      and (((bSerialGiven and bProductGiven)
        and (cGivenSerNo == cSepiaSerNo.value.decode("utf-8"))
        and (cGivenProduct == cProductModel.value.decode("utf-8")))
        or (((not bSerialGiven) != (not bProductGiven))
          and ((cGivenSerNo == cSepiaSerNo.value.decode("utf-8"))
          or (cGivenProduct == cProductModel.value.decode("utf-8"))))
        or (not bSerialGiven and not bProductGiven))):
      #
      if (bUSBInstGiven):
        if (iGivenDevIdx == i):
          iDevIdx = iGivenDevIdx;
        else:
          iDevIdx = -1;
      else:
        iDevIdx = i;
      #
      break;
    #
    i += 1;
    #
  #
  # endregion Establish USB connection to the Sepia first matching all given conditions
  #
  #
  iRetVal = Sepia2_Lib.SEPIA2_USB_OpenDevice(iDevIdx, cProductModel, cSepiaSerNo)
  if (Sepia2FunctionSucceeds(iRetVal, "USB_OpenDevice", iDevIdx, NO_IDX_1, NO_IDX_2)):
    #
    # region Print some information about the device
    #
    print("   Product Model  = '%s'" % cProductModel.value.decode("utf-8"))
    print("")
    print(STR_SEPARATORLINE)
    print("")
    iRetVal = Sepia2_Lib.SEPIA2_FWR_GetVersion(iDevIdx, cFWVersion)
    if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetVersion", iDevIdx, NO_IDX_1, NO_IDX_2)):
        print("   FW-Version     = %s" % cFWVersion.value.decode("utf-8"))
    print("   USB Index      = %d" % iDevIdx)
    iRetVal = Sepia2_Lib.SEPIA2_USB_GetStrDescriptor(iDevIdx, cDescriptor)
    if (Sepia2FunctionSucceeds(iRetVal, "USB_GetStrDescriptor", iDevIdx, NO_IDX_1, NO_IDX_2)):
        print("   USB Descriptor = %s" % cDescriptor.value.decode("utf-8"))
    print("   Serial Number  = '%s'" % cSepiaSerNo.value.decode("utf-8"))
    print("")
    print(STR_SEPARATORLINE)
    print("")
    #
    # endregion Print some information about the device
    #
    #
    #  get sepia's module map and initialise datastructures for all library functions
    #  there are two different ways to do so:
    #
    #  first:  if sepia was not touched since last power on, it doesn't need to be restarted
    #          iRestartOption = SEPIA2_NO_RESTART
    #  second: in case of changes with soft restart
    #          iRestartOption = SEPIA2_RESTART
    #
    iRetVal = Sepia2_Lib.SEPIA2_FWR_GetModuleMap(iDevIdx, iRestartOption, byref(iModuleCount))
    if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetModuleMap", iDevIdx, NO_IDX_1, NO_IDX_2)):
      #
      # this is to inform us about possible error conditions during sepia's last startup
      #
      iRetVal = Sepia2_Lib.SEPIA2_FWR_GetLastError(iDevIdx, byref(iFWErrCode), byref(iFWErrPhase),
                                                   byref(iFWErrLocation), byref(iFWErrSlot), cFWErrCond)
      if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetLastError", iDevIdx, NO_IDX_1, NO_IDX_2)):
        #
        if (not HasFWError(iFWErrCode.value, iFWErrPhase.value, iFWErrLocation.value, iFWErrSlot.value, cFWErrCond.value.decode("utf-8"), "Error detected by firmware on last restart:")):
          #
          #  just to show, what sepia2_lib knows about your system, try this:
          #
          Sepia2_Lib.SEPIA2_FWR_CreateSupportRequestText(
              iDevIdx, cPreamble, cCallingSW, 0, ct.sizeof(cBuffer), cBuffer)
          #
          #
          # print(cBuffer.value.decode("utf-8")) # Python claims an error when it comes to the degree-character '°'
          #  so we 'decode' the String ourselfes...
          cBufferStr = ""
          for i in range(0, len(cBuffer.value)):
              cBufferStr += "%c" % cBuffer.value[i]
              #
          #
          print(cBufferStr)
          print("")
          print("")
          print(STR_SEPARATORLINE)
          print("")
          print("")
          print("")
          #
          #
          #
          # scan sepia map module by module
          # and iterate by iMapIdx for this approach.
          #
          for iMapIdx in range(0, iModuleCount.value):
            #
            iRetVal = Sepia2_Lib.SEPIA2_FWR_GetModuleInfoByMapIdx(iDevIdx, iMapIdx, byref(iSlotId), byref(bIsPrimary),
                                                                  byref(bIsBackPlane), byref(bHasUptimeCounter))
            if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetModuleInfoByMapIdx", iDevIdx, iMapIdx, NO_IDX_2)):
              #
              if (bIsBackPlane.value != 0):
                #
                iRetVal = Sepia2_Lib.SEPIA2_COM_GetModuleType(iDevIdx, -1, Sepia2_Def.SEPIA2_PRIMARY_MODULE, byref(iModuleType))
                if (Sepia2FunctionSucceeds(iRetVal, "COM_GetModuleType", iDevIdx, -1, NO_IDX_2)):
                  #
                  Sepia2_Lib.SEPIA2_COM_DecodeModuleType(iModuleType, cModulType)
                  iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, -1, Sepia2_Def.SEPIA2_PRIMARY_MODULE, cSerialNumber)
                  if (Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, -1, NO_IDX_2)):
                    #
                    print(" backplane:   module type     '%s'" % cModulType.value.decode("utf-8"))
                    print("              serial number   '%s'" % cSerialNumber.value.decode("utf-8"))
                    print("")
                  #  end of 'SEPIA2_COM_GetSerialNumber'
                #  end of 'SEPIA2_COM_GetModuleType'
              #  end of 'if (bIsBackPlane)'
              else:
                #
                #
                # identify sepiaobject (module) in slot
                #
                iRetVal = Sepia2_Lib.SEPIA2_COM_GetModuleType(iDevIdx, iSlotId, Sepia2_Def.SEPIA2_PRIMARY_MODULE,
                                                              byref(iModuleType))
                if (Sepia2FunctionSucceeds(iRetVal, "COM_GetModuleType", iDevIdx, iSlotId, NO_IDX_2)):
                  #
                  Sepia2_Lib.SEPIA2_COM_DecodeModuleType(iModuleType, cModulType)
                  iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(
                      iDevIdx, iSlotId, Sepia2_Def.SEPIA2_PRIMARY_MODULE, cSerialNumber)
                  if (Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotId, NO_IDX_2)):
                      #
                      print(" slot %3.3d :   module type     '%s'" %
                            (iSlotId.value, cModulType.value.decode("utf-8")))
                      print("              serial number   '%s'" %
                            cSerialNumber.value.decode("utf-8"))
                      print("")
                  #  end of 'SEPIA2_COM_GetSerialNumber'
                  #
                  # now, continue with modulespecific information
                  #
                  if (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SCM):
                      iRetVal = Sepia2_Lib.SEPIA2_SCM_GetLaserSoftLock(
                          iDevIdx, iSlotId, byref(bSLock))
                      if (Sepia2FunctionSucceeds(iRetVal, "SCM_GetLaserSoftLock", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          iRetVal = Sepia2_Lib.SEPIA2_SCM_GetLaserLocked(
                              iDevIdx, iSlotId, byref(bLock))
                          if (Sepia2FunctionSucceeds(iRetVal, "SCM_GetLaserLocked", iDevIdx, iSlotId, NO_IDX_2)):
                              #
                              print("                              laser lock state   :  %slocked" % (
                                  " un" if (not (bLock.value > 0 or bSLock.value > 0)) else " hard" if (bLock.value != bSLock.value) else " soft"))
                              print("")
                              #
                          #
                      #
                  # end of 'if (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SCM)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOM or iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOMD):
                      #
                      for iFreqTrigMode in range(0, Sepia2_Def.SEPIA2_SOM_FREQ_TRIGMODE_COUNT):
                          #
                          if (iRetVal != Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR):
                              break
                          #
                          if (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOM):
                              #
                              iRetVal = Sepia2_Lib.SEPIA2_SOM_DecodeFreqTrigMode(
                                  iDevIdx, iSlotId, iFreqTrigMode, cFreqTrigMode)
                              bRet = Sepia2FunctionSucceeds(
                                  iRetVal, "SOM_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2)
                          else:
                              #
                              iRetVal = Sepia2_Lib.SEPIA2_SOMD_DecodeFreqTrigMode(
                                  iDevIdx, iSlotId, iFreqTrigMode, cFreqTrigMode)
                              bRet = Sepia2FunctionSucceeds(
                                  iRetVal, "SOMD_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2)
                          #
                          if (bRet):
                              #
                              if (iFreqTrigMode == 0):
                                  #
                                  print("%46s" % ("freq./trigmodes "), end="")
                              else:
                                  #
                                  print("%46s" % ("                "), end="")
                              #
                              print("%1d) =     '%s'" %
                                    (iFreqTrigMode + 1, cFreqTrigMode.value.decode("utf-8")), end="")
                              #
                              if (iFreqTrigMode == (Sepia2_Def.SEPIA2_SOM_FREQ_TRIGMODE_COUNT - 1)):
                                  #
                                  print("")
                              else:
                                  #
                                  print(",")
                              #
                          #  end of 'if (bRet)'
                      #  end of 'for (iFreqTrigMode ...'
                      #
                      print("")
                      #
                      if (iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR):
                          #  GetFreqTrigMode definding on device-type
                          if (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOM):
                              iRetVal = Sepia2_Lib.SEPIA2_SOM_GetFreqTrigMode(
                                  iDevIdx, iSlotId, byref(iFreqTrigIdx))
                              bRet = Sepia2FunctionSucceeds(
                                  iRetVal, "SOM_GetFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2)
                          else:
                              iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetFreqTrigMode(
                                  iDevIdx, iSlotId, byref(iFreqTrigIdx), byref(bSynchronize))
                              bRet = Sepia2FunctionSucceeds(
                                  iRetVal, "SOMD_GetFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2)
                          #
                          if (bRet):
                              #  GetFreqTrigMode succeded => DecodeFreqTrigMode
                              if (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOM):
                                  iRetVal = Sepia2_Lib.SEPIA2_SOM_DecodeFreqTrigMode(
                                      iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode)
                                  bRet = Sepia2FunctionSucceeds(
                                      iRetVal, "SOM_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2)
                              else:
                                  iRetVal = Sepia2_Lib.SEPIA2_SOMD_DecodeFreqTrigMode(
                                      iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode)
                                  bRet = Sepia2FunctionSucceeds(
                                      iRetVal, "SOMD_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2)
                              #
                              if (bRet):
                                  #  DecodeFreqTrigMode succeded
                                  print("%47s  =     '%s'" %
                                        ("act. freq./trigm.", cFreqTrigMode.value.decode("utf-8")))
                                  if ((iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOMD) and (iFreqTrigIdx < Sepia2_Def.SEPIA2_SOM_INT_OSC_A)):
                                      if (bSynchronize.value > 0):
                                          #
                                          print("%47s        (synchronized,)", " ")
                                      #  end of 'if (bSynchronize.value > 0)'
                                  #  end of 'if ((iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOMD) and (iFreqTrigIdx < Sepia2_Def.SEPIA2_SOM_INT_OSC_A))'
                                  #
                                  if (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOM):
                                      iRetVal = Sepia2_Lib.SEPIA2_SOM_GetBurstValues(
                                          iDevIdx, iSlotId, byref(bDivider), byref(bPreSync), byref(bMaskSync))
                                      bRet = Sepia2FunctionSucceeds(
                                          iRetVal, "SOM_GetBurstValues", iDevIdx, iSlotId, NO_IDX_2)
                                      if (bRet):
                                          # copy only values! not the 'object' itself because of possible next round...
                                          wDivider.value = bDivider.value
                                      #
                                  else:
                                      iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetBurstValues(
                                          iDevIdx, iSlotId, byref(wDivider), byref(bPreSync), byref(bMaskSync))
                                      bRet = Sepia2FunctionSucceeds(
                                          iRetVal, "SOMD_GetBurstValues", iDevIdx, iSlotId, NO_IDX_2)
                                  #
                                  if (bRet):
                                      #  GetBurstValues succeded
                                      #
                                      print("%48s = %5d" % ("divider           ", wDivider.value))
                                      print("%48s = %5d" % ("pre sync          ", bPreSync.value))
                                      print("%48s = %5d" % ("masked sync pulses", bMaskSync.value))
                                      #
                                      if ((iFreqTrigIdx.value == Sepia2_Def.SEPIA2_SOM_TRIGMODE_RISING)
                                              or (iFreqTrigIdx.value == Sepia2_Def.SEPIA2_SOM_TRIGMODE_FALLING)):
                                          #
                                          if (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOM):
                                              iRetVal = Sepia2_Lib.SEPIA2_SOM_GetTriggerLevel(
                                                  iDevIdx, iSlotId, byref(iTriggerMilliVolt))
                                              bRet = Sepia2FunctionSucceeds(
                                                  iRetVal, "SOM_GetTriggerLevel", iDevIdx, iSlotId, NO_IDX_2)
                                          else:
                                              iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetTriggerLevel(
                                                  iDevIdx, iSlotId, byref(iTriggerMilliVolt))
                                              bRet = Sepia2FunctionSucceeds(
                                                  iRetVal, "SOMD_GetTriggerLevel", iDevIdx, iSlotId, NO_IDX_2)
                                          #
                                          if (bRet):
                                              print("%47s  = %5d mV" %
                                                    ("triggerlevel     ", iTriggerMilliVolt.value))
                                          #
                                      #  end of 'if (( iFreqTrigIdx.value == Sepia2_Def.SEPIA2_SOM_TRIGMODE_RISING) or (iFreqTrigIdx.value == Sepia2_Def.SEPIA2_SOM_TRIGMODE_FALLING))'
                                      #
                                      else:
                                          #
                                          fFrequency.value = (
                                              atof(cFreqTrigMode.value.decode("utf-8"))) * 1.0e6
                                          fFrequency.value /= wDivider.value
                                          freqFormat = FormatEng(
                                              1.0 / fFrequency.value, 6, "s", 11, 3)
                                          print("%47s  =  %s" % ("oscillator period", freqFormat))
                                          freqFormat = FormatEng(fFrequency.value, 6, "Hz", 12, 3)
                                          print("%47s     %s" % ("i.e.", freqFormat))
                                          print("")
                                      #
                                      if (bRet):
                                          #  last API-call succeded
                                          if (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOM):
                                              iRetVal = Sepia2_Lib.SEPIA2_SOM_GetOutNSyncEnable(
                                                  iDevIdx, iSlotId, byref(bOutEnable), byref(bSyncEnable), byref(bSyncInverse))
                                              bRet = Sepia2FunctionSucceeds(
                                                  iRetVal, "SOM_GetOutNSyncEnable", iDevIdx, iSlotId, NO_IDX_2)
                                          else:
                                              iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetOutNSyncEnable(
                                                  iDevIdx, iSlotId, byref(bOutEnable), byref(bSyncEnable), byref(bSyncInverse))
                                              bRet = Sepia2FunctionSucceeds(
                                                  iRetVal, "SOMD_GetOutNSyncEnable", iDevIdx, iSlotId, NO_IDX_2)
                                          #
                                          if (bRet):
                                              #  GetOutNSyncEnable succeded
                                              #
                                              print("%47s  =     %s" % ("sync mask form   ", "inverse" if (
                                                  bSyncInverse.value > 0) else "regular"))
                                              print("")
                                              if (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOM):
                                                  iRetVal = Sepia2_Lib.SEPIA2_SOM_GetBurstLengthArray(iDevIdx, iSlotId, byref(lBurstChannels[0]), byref(lBurstChannels[1]), byref(
                                                      lBurstChannels[2]), byref(lBurstChannels[3]), byref(lBurstChannels[4]), byref(lBurstChannels[5]), byref(lBurstChannels[6]), byref(lBurstChannels[7]))
                                                  bRet = Sepia2FunctionSucceeds(
                                                      iRetVal, "SOM_GetBurstLengthArray", iDevIdx, iSlotId, NO_IDX_2)
                                              else:
                                                  iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetBurstLengthArray(iDevIdx, iSlotId, byref(lBurstChannels[0]), byref(lBurstChannels[1]), byref(
                                                      lBurstChannels[2]), byref(lBurstChannels[3]), byref(lBurstChannels[4]), byref(lBurstChannels[5]), byref(lBurstChannels[6]), byref(lBurstChannels[7]))
                                                  bRet = Sepia2FunctionSucceeds(
                                                      iRetVal, "SOMD_GetBurstLengthArray", iDevIdx, iSlotId, NO_IDX_2)
                                              #
                                              if (bRet):
                                                  #  GetBurstLengthArray succeded
                                                  #
                                                  #
                                                  print("%44s ch. | sync | burst len |  out" %
                                                        "burst data    ")
                                                  print("%44s-----+------+-----------+------" % " ")
                                                  #
                                                  lBurstSum = 0
                                                  for i in range(0, Sepia2_Def.SEPIA2_SOM_BURSTCHANNEL_COUNT):
                                                      #
                                                      print("%46s%1d  |    %1d | %9d |    %1d" % (
                                                          " ", i + 1, ((bSyncEnable.value >> i) & 1), lBurstChannels[i].value, ((bOutEnable.value >> i) & 1)))
                                                      lBurstSum += lBurstChannels[i].value
                                                  #  end of 'for (i in range(0, Sepia2_Def.SEPIA2_SOM_BURSTCHANNEL_COUNT))'
                                                  #
                                                  print("%41s--------+------+ +  -------+------" % " ")
                                                  print("%41sHex/Sum | 0x%2.2X | =%8d | 0x%2.2X" %
                                                        (" ", bSyncEnable.value, lBurstSum, bOutEnable.value))
                                                  print("")
                                                  #
                                                  if ((iFreqTrigIdx.value != Sepia2_Def.SEPIA2_SOM_TRIGMODE_RISING)
                                                          and (iFreqTrigIdx.value != Sepia2_Def.SEPIA2_SOM_TRIGMODE_FALLING)):
                                                      #
                                                      fFrequency.value /= lBurstSum
                                                      freqFormat = FormatEng(
                                                          1.0 / fFrequency.value, 6, "s", 11, 3)
                                                      print("%47s  =  %s" %
                                                            ("sequencer period", freqFormat))
                                                      freqFormat = FormatEng(
                                                          fFrequency.value, 6, "Hz", 12, 3)
                                                      print("%47s     %s" % ("i.e.", freqFormat))
                                                      print("")
                                                      #
                                                  #  end of 'if ((iFreqTrigIdx.value != Sepia2_Def.SEPIA2_SOM_TRIGMODE_RISING) and (iFreqTrigIdx.value != Sepia2_Def.SEPIA2_SOM_TRIGMODE_FALLING))'
                                                  if (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOMD):
                                                      #
                                                      iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetDelayUnits(
                                                          iDevIdx, iSlotId, byref(f64CoarseDelayStep), byref(bFineDelayStepCount))
                                                      if (Sepia2FunctionSucceeds(iRetVal, "SOMD_GetDelayUnits", iDevIdx, iSlotId, NO_IDX_2)):
                                                          #  SEPIA2_SOMD_GetDelayUnits succeded
                                                          #
                                                          print("%44s     | combiner |" % " ")
                                                          print("%44s     | channels |" % " ")
                                                          print("%44s out | 12345678 | delay" % " ")
                                                          print(
                                                              "%44s-----+----------+------------------" % " ")
                                                      #  end of 'SEPIA2_SOMD_GetDelayUnits'
                                                      #
                                                      for j in range(0, Sepia2_Def.SEPIA2_SOM_BURSTCHANNEL_COUNT):
                                                          iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetSeqOutputInfos(iDevIdx, iSlotId, j, byref(bDelayed), byref(
                                                              bForcedUndelayed), byref(bOutCombi), byref(bMaskedCombi), byref(f64CoarseDelay), byref(bFineDelay))
                                                          if (Sepia2FunctionSucceeds(iRetVal, "SOMD_GetSeqOutputInfos", iDevIdx, iSlotId, NO_IDX_2)):
                                                              #  SEPIA2_SOMD_GetSeqOutputInfos succeded
                                                              if (bDelayed.value == 0 or bForcedUndelayed.value != 0):
                                                                  #
                                                                  binStr = IntToBin(bOutCombi, Sepia2_Def.SEPIA2_SOM_BURSTCHANNEL_COUNT, True, '1' if (
                                                                      bMaskedCombi.value > 0) else 'B', '_')
                                                                  print("%46s%1d  | %s |" %
                                                                        (" ", j + 1, binStr))
                                                              else:
                                                                  #
                                                                  binStr = IntToBin(
                                                                      (1 << j), Sepia2_Def.SEPIA2_SOM_BURSTCHANNEL_COUNT, True, 'D', '_')
                                                                  freqFormat = FormatEng(
                                                                      f64CoarseDelay * 1e-9, 4, "s", 9, 1, 0)

                                                                  print(
                                                                      "%46s%1d  | %s |%s + %2da.u." % (" ", j + 1, binStr, freqFormat, bFineDelay.value))
                                                              #
                                                          #  end of 'SEPIA2_SOMD_GetSeqOutputInfos'
                                                      #  end of 'for j in range(0, Sepia2_Def.SEPIA2_SOM_BURSTCHANNEL_COUNT)'
                                                      #
                                                      print("")
                                                      print("%46s   = D: delayed burst,   no combi" %
                                                            "combiner legend ")
                                                      print("%46s     B: combi burst, any non-zero" % " ")
                                                      print("%46s     1: 1st pulse,   any non-zero" % " ")
                                                      print("")
                                                      #
                                                  #  end of 'if (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOMD)'
                                              #  end of 'if (bRet)'  <=  from 'SEPIA2_SOM_GetBurstLengthArray' or 'SEPIA2_SOMD_GetBurstLengthArray'
                                          #  end of 'if (bRet)'  <=  from 'SEPIA2_SOM_GetOutNSyncEnable' or 'SEPIA2_SOMD_GetOutNSyncEnable'
                                      #  end of 'if (bRet)'  <=  from 'SEPIA2_SOM_GetTriggerLevel' or 'SEPIA2_SOMD_GetTriggerLevel'  or  from older API-call 'SEPIA2_SOM_GetBurstValues' or 'SEPIA2_SOMD_GetBurstValues'
                                  #  end of 'if (bRet)'  <=  from 'SEPIA2_SOM_GetBurstValues' or 'SEPIA2_SOMD_GetBurstValues'
                              #  end of 'if (bRet)'  <=  from 'SEPIA2_SOM_DecodeFreqTrigMode' or 'SEPIA2_SOMD_DecodeFreqTrigMode'
                          #  end of 'if (bRet)'  <=  from 'SEPIA2_SOM_GetFreqTrigMode' or 'SEPIA2_SOMD_GetFreqTrigMode'
                      #  end of 'if (iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR)'  <=  after for (iFreqTrigIdx ...'
                  # end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOM or iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOMD)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SLM):
                      iRetVal = Sepia2_Lib.SEPIA2_SLM_GetPulseParameters(
                          iDevIdx, iSlotId, byref(iFreqTrigIdx), byref(bPulseMode), byref(iHead))
                      if (Sepia2FunctionSucceeds(iRetVal, "SLM_GetPulseParameters", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          Sepia2_Lib.SEPIA2_SLM_DecodeFreqTrigMode(iFreqTrigIdx, cFrequency)
                          Sepia2_Lib.SEPIA2_SLM_DecodeHeadType(iHead, cHeadType)
                          #
                          print("%47s  =     '%s'" %
                                ("freq / trigmode  ", cFrequency.value.decode("utf-8")))
                          print("%47s  =     'pulses %s'" % ("pulsmode         ",
                                ("enabled" if (bPulseMode.value > 0) else "disabled")))
                          print("%47s  =     '%s'" %
                                ("headtype         ", cHeadType.value.decode("utf-8")))
                      # end of 'SEPIA2_SLM_GetPulseParameters'
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_SLM_GetIntensityFineStep(
                          iDevIdx, iSlotId, byref(wIntensity))
                      if (Sepia2FunctionSucceeds(iRetVal, "SLM_GetIntensityFineStep", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          print("%47s  =   %5.1f%%" %
                                ("intensity        ", (0.1 * wIntensity.value)))
                      #
                      print("")
                  # end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SLM)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SML):
                      iRetVal = Sepia2_Lib.SEPIA2_SML_GetParameters(
                          iDevIdx, iSlotId, byref(bPulseMode), byref(iHead), byref(bIntensity))
                      if (Sepia2FunctionSucceeds(iRetVal, "SML_GetParameters", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          Sepia2_Lib.SEPIA2_SML_DecodeHeadType(iHead, cHeadType)
                          #
                          print("%47s  =     pulses %s" % ("pulsmode         ",
                                ("enabled" if (bPulseMode.value > 0) else "disabled")))
                          print("%47s  =     %s" %
                                ("headtype         ", cHeadType.value.decode("utf-8")))
                          print("%47s  =   %3d%%" % ("intensity        ", bIntensity.value))
                          print("")
                      # end of 'SEPIA2_SML_GetParameters'
                  # end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SML)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SPM):
                      iRetVal = Sepia2_Lib.SEPIA2_SPM_GetFWVersion(
                          iDevIdx, iSlotId, byref(SWSFWVers))
                      if (Sepia2FunctionSucceeds(iRetVal, "SPM_GetFWVersion", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          print("%47s  =     %d.%d.%d" % ("firmware version ",
                                SWSFWVers.VersMaj, SWSFWVers.VersMin, SWSFWVers.BuildNr))
                      #  end of 'SEPIA2_SPM_GetFWVersion'
                  #  end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SPM)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SWS):
                      iRetVal = Sepia2_Lib.SEPIA2_SWS_GetFWVersion(
                          iDevIdx, iSlotId, byref(SWSFWVers))
                      if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetFWVersion", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          print("%47s  =     %d.%d.%d" % ("firmware version ",
                                SWSFWVers.VersMaj, SWSFWVers.VersMin, SWSFWVers.BuildNr))
                      # end of 'SEPIA2_SWS_GetFWVersion'
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_SWS_GetModuleType(
                          iDevIdx, iSlotId, byref(iSWSModuleType))
                      if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetModuleType", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          Sepia2_Lib.SEPIA2_SWS_DecodeModuleType(iSWSModuleType, cSWSModuleType)
                          print("%47s  =     %s" %
                                ("SWS module type ", cSWSModuleType.value.decode("utf-8")))
                      # end of 'SEPIA2_SWS_GetModuleType'
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_SWS_GetParameters(
                          iDevIdx, iSlotId, byref(ulWaveLength), byref(ulBandWidth))
                      if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetParameters", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          print("%47s  =  %8.3f nm" %
                                ("wavelength       ", 0.001 * ulWaveLength.value))
                          print("%47s  =  %8.3f nm" %
                                ("bandwidth        ", 0.001 * ulBandWidth.value))
                          print("")
                      #  end of 'SEPIA2_SWS_GetParameters'
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_SWS_GetIntensity(
                          iDevIdx, iSlotId, byref(ulIntensRaw), byref(fIntensity))
                      if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetIntensity", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          print("%47s  = 0x%4.4X a.u. i.e. ~ %.1fnA" %
                                ("power diode      ", ulIntensRaw.value, fIntensity.value))
                          print("")
                      #  end of 'SEPIA2_SWS_GetIntensity'
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_SWS_GetBeamPos(
                          iDevIdx, iSlotId, byref(sBeamVPos), byref(sBeamHPos))
                      if (Sepia2FunctionSucceeds(iRetVal, "SWS_GetBeamPos", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          print("%47s  =   %3d steps" % ("horiz. beamshift ", sBeamHPos.value))
                          print("%47s  =   %3d steps" % ("vert.  beamshift ", sBeamVPos.value))
                          print("")
                      #  end of 'SEPIA2_SWS_GetBeamPos'
                  #  end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SWS)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SSM):
                      iRetVal = Sepia2_Lib.SEPIA2_SSM_GetTriggerData(
                          iDevIdx, iSlotId, byref(iFreqTrigIdx), byref(iTriggerMilliVolt))
                      if (Sepia2FunctionSucceeds(iRetVal, "SSM_GetTriggerData", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          iRetVal = Sepia2_Lib.SEPIA2_SSM_DecodeFreqTrigMode(
                              iDevIdx, iSlotId, iFreqTrigIdx, cFreqTrigMode, byref(iFrequency), byref(bTrigLevelEnabled))
                          if (Sepia2FunctionSucceeds(iRetVal, "SSM_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2)):
                              #
                              print("%47s  =     '%s'" %
                                    ("act. freq./trigm.", cFreqTrigMode.value.decode("utf-8")))
                              if (bTrigLevelEnabled.value != 0):
                                  #
                                  print("%47s  = %5d mV" %
                                        ("triggerlevel     ", iTriggerMilliVolt.value))
                              #  end of 'if (bTrigLevelEnabled.value != 0)'
                          #  end of 'SEPIA2_SSM_DecodeFreqTrigMode'
                      #  end of 'SEPIA2_SSM_GetTriggerData'
                  #  end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SSM)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SWM):
                      iRetVal = Sepia2_Lib.SEPIA2_SWM_GetCurveParams(iDevIdx, iSlotId, 1, byref(
                          bTBNdx), byref(wPAPml), byref(wRRPml), byref(wPSPml), byref(wRSPml), byref(wWSPml))
                      if (Sepia2FunctionSucceeds(iRetVal, "SWM_GetCurveParams 1", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          print("%47s" % ("Curve 1:         "))
                          print("%47s  =   %3d" % ("TBNdx            ", bTBNdx.value))
                          print("%47s  =  %6.1f%%" % ("PAPml            ", 0.1 * wPAPml.value))
                          print("%47s  =  %6.1f%%" % ("RRPml            ", 0.1 * wRRPml.value))
                          print("%47s  =  %6.1f%%" % ("PSPml            ", 0.1 * wPSPml.value))
                          print("%47s  =  %6.1f%%" % ("RSPml            ", 0.1 * wRSPml.value))
                          print("%47s  =  %6.1f%%" % ("WSPml            ", 0.1 * wWSPml.value))
                      #  end of 'SEPIA2_SWM_GetCurveParams' => iCurveIdx <= 1
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_SWM_GetCurveParams(iDevIdx, iSlotId, 2, byref(
                          bTBNdx), byref(wPAPml), byref(wRRPml), byref(wPSPml), byref(wRSPml), byref(wWSPml))
                      if (Sepia2FunctionSucceeds(iRetVal, "SWM_GetCurveParams 2", iDevIdx, iSlotId, NO_IDX_2)):
                          #
                          print("%47s", "Curve 2:         ")
                          print("%47s  =   %3d" % ("TBNdx            ", bTBNdx.value))
                          print("%47s  =  %6.1f%%" % ("PAPml            ", 0.1 * wPAPml.value))
                          print("%47s  =  %6.1f%%" % ("RRPml            ", 0.1 * wRRPml.value))
                          print("%47s  =  %6.1f%%" % ("PSPml            ", 0.1 * wPSPml.value))
                          print("%47s  =  %6.1f%%" % ("RSPml            ", 0.1 * wRSPml.value))
                          print("%47s  =  %6.1f%%" % ("WSPml            ", 0.1 * wWSPml.value))
                      #  end of 'SEPIA2_SWM_GetCurveParams' => iCurveIdx <= 2
                  #  end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SWM)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_VUV or iModuleType.value == Sepia2_Def.SEPIA2OBJECT_VIR):
                      iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetDeviceType(
                          iDevIdx, iSlotId, cDevType, byref(bHasCW), byref(bHasFanSwitch))
                      if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetDeviceType", iDevIdx, iSlotId, NO_IDX_2)):
                          iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetTriggerData(iDevIdx, iSlotId, byref(
                              iTrigSrcIdx), byref(iFreqDivIdx), byref(iTriggerMilliVolt))
                          if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetTriggerData", iDevIdx, iSlotId, NO_IDX_2)):
                              #
                              iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_DecodeFreqTrigMode(
                                  iDevIdx, iSlotId, iTrigSrcIdx, -1, cFreqTrigMode, byref(iDummy), byref(bDummy1), byref(bDummy2))
                              if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2)):
                                  #
                                  iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_DecodeFreqTrigMode(iDevIdx, iSlotId, iTrigSrcIdx, iFreqDivIdx, cFreqTrigSrc, byref(
                                      iFrequency), byref(bDivListEnabled), byref(bTrigLvlEnabled))
                                  if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_DecodeFreqTrigMode", iDevIdx, iSlotId, NO_IDX_2)):
                                      #
                                      print("%47s  =   '%s'" %
                                            ("devicetype       ", cDevType.value.decode("utf-8")))
                                      print("%47s  :   %s = %s" % ("options          ",
                                            "CW        ", "True" if (bHasCW.value > 0) else "False"))
                                      print("%47s      %s = %s" % ("                 ", "fan-switch",
                                            "True" if (bHasFanSwitch.value > 0) else "False"))
                                      print("%47s  =   %s" % ("trigger source   ",
                                            cFreqTrigMode.value.decode("utf-8")))
                                      if ((bDivListEnabled.value > 0) and (iFrequency.value > 0)):
                                          #
                                          freqFormat = FormatEng(iFrequency.value, 4, "Hz", 9)
                                          print("%47s  =   2^%d = %d" % ("divider          ",
                                                iFreqDivIdx.value, 2 ** iFreqDivIdx.value))
                                          print("%47s  =   %s" % ("frequency        ", freqFormat))
                                      #  end of 'if ((bDivListEnabled.value > 0) and (iFrequency.value > 0))'
                                      #
                                      elif (bTrigLvlEnabled.value > 0):
                                          #
                                          print("%47s  =   %.3f V" %
                                                ("trigger level    ", 0.001 * iTriggerMilliVolt.value))
                                      #  end of 'elif (bTrigLvlEnabled.value > 0)'
                                  #  end of 'Sepia2_LibSEPIA2_VUV_VIR_DecodeFreqTrigMode'
                              #  end of 'SEPIA2_VUV_VIR_DecodeFreqTrigMode'
                          #  end of 'SEPIA2_VUV_VIR_GetTriggerData'
                          #
                          iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetIntensity(
                              iDevIdx, iSlotId, byref(iIntensity))
                          if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetIntensity", iDevIdx, iSlotId, NO_IDX_2)):
                              #
                              print("%47s  =   %3.1f %%" %
                                    ("intensity        ", 0.1 * iIntensity.value))
                          #  end of 'SEPIA2_VUV_VIR_GetIntensity'
                          #
                          if (bHasFanSwitch.value > 0):
                              #
                              iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetFan(
                                  iDevIdx, iSlotId, byref(bIsFanRunning))
                              if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetFan", iDevIdx, iSlotId, NO_IDX_2)):
                                  #
                                  print("%47s  =   %s" % ("fan running      ",
                                        "True" if (bIsFanRunning.value > 0) else "False"))
                              #  end of 'SEPIA2_VUV_VIR_GetFan'
                          #  end of 'if (bHasFanSwitch.value > 0)'
                      #  end of 'SEPIA2_VUV_VIR_GetDeviceType'
                  #  end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_VUV or iModuleType.value == Sepia2_Def.SEPIA2OBJECT_VIR)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_PRI):
                    #
                    PRI_Const.PRI_GetConstants(iDevIdx, iSlotId);
                    #
                    if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetConstants", iDevIdx, iSlotId, NO_IDX_2)):
                      #
                      #print("außen 2: %d, %03d, Type = '%s', WLs = %d" % (PRI_Const.PrimaUSBIdx, PRI_Const.PrimaSlotId, PRI_Const.PrimaModuleType.decode("utf-8"), PRI_Const.PrimaWLCount));
                      #print("");
                      #
                      print("%47s  =   '%s'" % ("devicetype       ", (PRI_Const.PrimaModuleType.decode("utf-8"))));
                      print("%47s  =   %s" % ("firmware version ", PRI_Const.PrimaFWVers.decode("utf-8")));
                      print("");
                      print("%47s  =   %d" % ("wavelengths count", PRI_Const.PrimaWLCount));
                      #
                      for i in range(0, PRI_Const.PrimaWLCount):
                        cTemp1 = ("wavelength [%1d] " % i);
                        print("%47s  =  %4dnm" % (cTemp1, PRI_Const.PrimaWLs[i]))
                      #  end of for PrimaWLCount
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_PRI_GetWavelengthIdx(iDevIdx, iSlotId, byref(iWL_Idx))
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetWavelengthIdx", iDevIdx, iSlotId, NO_IDX_2)):
                        print("%47s  =  %4dnm;            WL-Idx=%d" %
                              ("cur. wavelength  ", PRI_Const.PrimaWLs[iWL_Idx.value], iWL_Idx.value))
                        print("")
                      #
                      #
                      #  now we loop over the amount of operation modes for this indiviual PRI module
                      #
                      print("%47s  =   %1d" % ("operation modes  ", PRI_Const.PrimaOpModCount))
                      #
                      for i in range(0, PRI_Const.PrimaOpModCount):
                        #
                        iRetVal = Sepia2_Lib.SEPIA2_PRI_DecodeOperationMode(iDevIdx, iSlotId, i, cOpMode)
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeOperationMode", iDevIdx, iSlotId, i)):
                          #
                          cTemp1 = ("oper. mode [%1d] " % i)
                          print("%47s  =   '%s'" % (cTemp1, cOpMode.value.decode("utf-8").strip()))
                        #
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_PRI_GetOperationMode(iDevIdx, iSlotId, byref(iOM_Idx))
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetOperationMode", iDevIdx, iSlotId, iOM_Idx)):
                        iRetVal = Sepia2_Lib.SEPIA2_PRI_DecodeOperationMode(iDevIdx, iSlotId, iOM_Idx, cOpMode)
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeOperationMode", iDevIdx, iSlotId, iOM_Idx)):
                          #
                          cOpMode = cOpMode.value.strip()
                          iFormatWidth = 15 - len(cOpMode)  # .value
                          print(("%47s  =   '%s';%" + ("%d" % iFormatWidth) + "sOM-Idx=%d") %
                                ("cur. oper. mode  ", cOpMode.decode("utf-8"), " ", iOM_Idx.value))
                        #
                      #
                      print("")
                      #
                      #  now we loop over the amount of trigger sources for this indiviual PRI module
                      #
                      print("%47s  =   %1d" % ("trigger sources  ", PRI_Const.PrimaTrSrcCount))
                      for i in range(0, PRI_Const.PrimaTrSrcCount):
                        iRetVal = Sepia2_Lib.SEPIA2_PRI_DecodeTriggerSource(iDevIdx, iSlotId, i, cTrigSrc,
                                                                            byref(bDummy1), byref(bDummy2))
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeTriggerSource", iDevIdx, iSlotId, i)):
                          cTemp1 = ("trig. src. [%1d] " % i)
                          print("%47s  =   '%s'" % (cTemp1, cTrigSrc.value.decode("utf-8").strip()))
                        #
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_PRI_GetTriggerSource(iDevIdx, iSlotId, byref(iTS_Idx))
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetTriggerSource", iDevIdx, iSlotId, iTS_Idx)):
                        iRetVal = Sepia2_Lib.SEPIA2_PRI_DecodeTriggerSource(iDevIdx, iSlotId, iTS_Idx, cTrigSrc,
                                                                            byref(bFreqncyEnabled), byref(bTrigLvlEnabled))
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeTriggerSource", iDevIdx, iSlotId, iTS_Idx)):
                          cTrigSrc = cTrigSrc.value.strip()
                          iFormatWidth = 15 - len(cTrigSrc)
                          print(("%47s  =   '%s';%" + ("%d" % iFormatWidth) + "sTS-Idx=%d") %
                                ("cur. trig. source", cTrigSrc.decode("utf-8"), " ", iTS_Idx.value))
                        #
                      #
                      print("")
                      #
                      cTemp1 = ("for TS-Idx = %1d   " % iTS_Idx.value)
                      print("%47s  :   frequency is %sactive:" % (cTemp1, ("in" if not bFreqncyEnabled else "")))
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_PRI_GetFrequencyLimits(
                          iDevIdx, iSlotId, byref(iMinFreq), byref(iMaxFreq))
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetFrequencyLimits", iDevIdx, iSlotId, NO_IDX_2)):
                        cTemp1 = FormatEng(iMinFreq.value, 3, "Hz", -1, 0, False)
                        cTemp2 = FormatEng(iMaxFreq.value, 3, "Hz", -1, 0, False)
                        print("%47s  =   %s <= f <= %s" % ("frequency range", cTemp1, cTemp2))
                        iRetVal = Sepia2_Lib.SEPIA2_PRI_GetFrequency(iDevIdx, iSlotId, byref(iFreq))
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetFrequency", iDevIdx, iSlotId, NO_IDX_2)):
                          cTemp1 = FormatEng(iFreq.value, 3, "Hz", -1, 0, False)
                          print("%47s  =   %s" % ("cur. frequency ", cTemp1))
                        #
                      #
                      print("")
                      #
                      cTemp1 = ("for TS-Idx = %1d   " % iTS_Idx.value)
                      print("%47s  :   trigger level is %sactive:" % (cTemp1, ("in" if not bTrigLvlEnabled else "")))
                      iRetVal = Sepia2_Lib.SEPIA2_PRI_GetTriggerLevelLimits(iDevIdx, iSlotId, byref(iMinTrgLvl),
                                                                            byref(iMaxTrgLvl), byref(iResTrgLvl))
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetTriggerLevelLimits", iDevIdx, iSlotId, NO_IDX_2)):
                        iRetVal = Sepia2_Lib.SEPIA2_PRI_GetTriggerLevel(iDevIdx, iSlotId, byref(iTriggerMilliVolt))
                        print("%47s  =  %6.3fV <= tl <= %5.3fV" % ("trig.lvl. range", 0.001*iMinTrgLvl.value, 0.001*iMaxTrgLvl.value))
                        print("%47s  =  %6.3fV" % ("cur. trig.lvl. ", 0.001*iTriggerMilliVolt.value))
                      #
                      print("")
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_PRI_GetIntensity(iDevIdx, iSlotId, iWL_Idx, byref(wIntensity))
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetIntensity", iDevIdx, iSlotId, iWL_Idx)):
                          cTemp1 = FormatEng(0.1 * wIntensity.value, 3, "%", -1, 1, False)
                          iFormatWidth = 16 - len(cTemp1)
                          print(("%47s  =   %s; %" + ("%d" % iFormatWidth) + "sWL-Idx=%d") % ("intensity        ", cTemp1,
                                                                                              " ", iWL_Idx.value))
                          #
                      print("")
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_PRI_GetGatingEnabled(iDevIdx, iSlotId, byref(bGatingEnabled))
                      if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGatingEnabled", iDevIdx, iSlotId, NO_IDX_2)):
                        print("%47s  :   %sabled" % ("gating           ", ("en" if bGatingEnabled else "dis")))
                        iRetVal = Sepia2_Lib.SEPIA2_PRI_GetGateHighImpedance(iDevIdx, iSlotId, byref(bGateHiImp))
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGateHighImpedance", iDevIdx, iSlotId, NO_IDX_2)):
                          print("%47s  =   %s" % ("gate impedance ",
                                                  ("high (>= 1 kOhm)" if bGateHiImp else "low (50 Ohm)")))
                          #
                        #
                        iRetVal = Sepia2_Lib.SEPIA2_PRI_GetGatingLimits(iDevIdx, iSlotId,
                                                                        byref(iMinOnTime), byref(iMaxOnTime),
                                                                        byref(iMinOffTimefact), byref(iMaxOffTimefact))
                        if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGatingLimits", iDevIdx, iSlotId, NO_IDX_2)):
                          iRetVal = Sepia2_Lib.SEPIA2_PRI_GetGatingData(iDevIdx, iSlotId,
                                                                        byref(iOnTime), byref(iOffTimefact))
                          if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGatingData", iDevIdx, iSlotId, NO_IDX_2)):
                            cTemp1 = FormatEng(1.0e-9*iMinOnTime.value, 4, "s", -1, 1, False)
                            cTemp2 = FormatEng(1.0e-9*iMaxOnTime.value, 4, "s", -1, 1, False)
                            print("%48s =   %s <= t <= %s" % ("on-time range   ", cTemp1, cTemp2))
                            #
                            cTemp1 = FormatEng(1.0e-9*iOnTime.value, 4, "s", -1, 1, False)
                            print("%48s =   %s" % ("cur. on-time    ", cTemp1))
                            #
                            print("%48s =   %d <= tf <= %d" % ("off-t.fact range", iMinOffTimefact.value, iMaxOffTimefact.value))
                            #
                            cTemp1 = FormatEng(1.0e-9*iOnTime.value * iOffTimefact.value, 4, "s", -1, 3, False)
                            print("%48s =   %d * on-time = %s" % ("cur. off-time   ", iOffTimefact.value, cTemp1))
                            fGatePeriod = 1.0e-9 * iOnTime.value * (1 + iOffTimefact.value)
                            cTemp1 = FormatEng(fGatePeriod, 4, "s", -1, 3, False)
                            print("%48s =   %s" % ("gate period     ", cTemp1))
                            cTemp1 = FormatEng(1.0 / fGatePeriod, 4, "Hz", -1, -1, False)
                            print("%48s =   %s" % ("gate frequency  ", cTemp1))
                            #
                          # end of if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGatingData",...
                        # end of if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGatingLimits",...
                      # end of if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetGatingEnabled",...
                    #  end of if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetConstants",...
                  #  end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_PRI)'
                  #
                  #
                  else:
                    # The value of 'iModuleType' was not yet implemented here...
                    print(" TODO - switch (iModuleType = %d = 0x%.2X) was not yet implemented here!" %
                          (iModuleType.value, iModuleType.value))
                  #  end of switching between modulespecific information
                #  end of 'SEPIA2_COM_GetModuleType'
              #  end of 'else' from 'if (bIsBackPlane)'
            #  end of 'SEPIA2_FWR_GetModuleInfoByMapIdx'
            #
            if (iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR):
              #
              if (bIsPrimary.value == 0):
                #
                iRetVal = Sepia2_Lib.SEPIA2_COM_GetModuleType(iDevIdx, iSlotId, Sepia2_Def.SEPIA2_SECONDARY_MODULE,
                                                              byref(iModuleType))
                if (Sepia2FunctionSucceeds(iRetVal, "COM_GetModuleType", iDevIdx, iSlotId, NO_IDX_2)):
                  #
                  Sepia2_Lib.SEPIA2_COM_DecodeModuleType(iModuleType, cModulType)
                  iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotId, Sepia2_Def.SEPIA2_SECONDARY_MODULE,
                                                                  cSerialNumber)
                  if (Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotId, NO_IDX_2)):
                    #
                    print("")
                    print("              secondary mod.  '%s'" % cModulType.value.decode("utf-8"))
                    print("              serial number   '%s'" % cSerialNumber.value.decode("utf-8"))
                    print("")
                  #  end of 'SEPIA2_COM_GetSerialNumber'
                #  end of 'SEPIA2_COM_GetModuleType'
              #  end of 'if (not bIsPrimary)'
              #
              if (bHasUptimeCounter.value != 0):
                #
                iRetVal = Sepia2_Lib.SEPIA2_FWR_GetUptimeInfoByMapIdx(iDevIdx, iMapIdx, byref(ulMainPowerUp),
                                                                      byref(ulActivePowerUp), byref(ulScaledPowerUp))
                if (Sepia2FunctionSucceeds(iRetVal, "", iDevIdx, iSlotId, NO_IDX_2)):
                  #
                  PrintUptimers(ulMainPowerUp.value, ulActivePowerUp.value, ulScaledPowerUp.value)
                #  end of 'SEPIA2_FWR_GetUptimeInfoByMapIdx'
              #  end of 'if (bHasUptimeCounter)'
            #  end of 'if (iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR)'
          #  end of 'for i in range(0, iModuleCount)'
        #  end of '!HasFWError'
      #  end of 'SEPIA2_FWR_GetLastError'
    #  end of 'SEPIA2_FWR_GetModuleMap'
    else:
      #
      iRetVal = Sepia2_Lib.SEPIA2_FWR_GetLastError(iDevIdx, byref(iFWErrCode), byref(
        iFWErrPhase), byref(iFWErrLocation), byref(iFWErrSlot), cFWErrCond)
      if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetLastError", iDevIdx, NO_IDX_1, NO_IDX_2)):
        #
        HasFWError(iFWErrCode.value, iFWErrPhase.value, iFWErrLocation.value, iFWErrSlot.value,
                   cFWErrCond.value.decode("utf-8"), "Firmware error detected:")
      #  end of 'SEPIA2_FWR_GetLastError'
    #  end of 'else' from 'SEPIA2_FWR_GetModuleMap'
    #
    Sepia2_Lib.SEPIA2_FWR_FreeModuleMap(iDevIdx)
    if (bStayOpened):
      #
      print("")
      print("press RETURN to close Sepia... ")
      input()
    #  end of 'if (bStayOpened)'
    #
    Sepia2_Lib.SEPIA2_USB_CloseDevice(iDevIdx)
    #
  # end of 'SEPIA2_USB_OpenDevice'
  #
  print("")
  #
  if (not bNoWait):
      #
      print("")
      print("press RETURN... ")
      input()
  #
  return iRetVal


#
#
#
#
if __name__ == "__main__":
    #
    main(sys.argv)
    #
#
