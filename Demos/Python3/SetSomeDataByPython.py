#SetSomeDataByPython

import Sepia2_Def
import Sepia2_ErrorCodes
from Sepia2_Lib import SEPIA2_LIB_DLL_NAME
from Sepia2_Lib import Sepia2_Lib

import sys
import math
#import struct
import ctypes as ct
from ctypes import byref

from MigrationHelper import NO_DEVIDX
from MigrationHelper import NO_IDX_1
from MigrationHelper import NO_IDX_2
from MigrationHelper import Sepia2FunctionSucceeds
from MigrationHelper import EnsureRange
from MigrationHelper import BoolToStr
from MigrationHelper import StrToBool
from MigrationHelper import StrToInt
from MigrationHelper import StrToFloat
from MigrationHelper import GetValStr
from MigrationHelper import T_PRI_Constants



import locale

locale.setlocale(locale.LC_ALL, 'en-US')

import os.path

#-----------------------------------------------------------------------------
#
#      SetSomeDataByPython
#
#-----------------------------------------------------------------------------
#
#  Illustrates the functions exported by SEPIA2_Lib
#
#  Presumes to find a SOM 828, a SLM 828, a VisUV/IR and/or a Prima
#
#  if there doesn't exist a file named "OrigData.txt"
#    creates the file to save the original values
#    then sets new values for SOM and SLM
#  else
#    sets original values for SOM and SLM from file and
#    deletes file.
#
#  Consider, this code is for demonstration purposes only.
#  Don't use it in productive environments!
#
#-----------------------------------------------------------------------------
#  HISTORY:
#
#  apo  06.02.06   created
#
#  apo  05.02.14   introduced new map oriented API functions (V1.0.3.282)
#
#  apo  05.09.14   adapted to DLL version 1.1.<target>.<svn_build>
#
#  apo  18.06.15   substituted deprecated SLM functions
#                  introduced SOM-D Oscillator Module w. Delay Option (V1.1.xx.450)
#
#  apo  22.01.21   adapted to DLL version 1.2.<target>.<svn_build>
#
#  apo  29.01.21   introduced VIR, VUV module functions (for VisUV/IR) (V1.2.xx.641)
#
#  dsc  20.04.26   introduced SetSomeDataByPython-demo
#
#  apo  14.09.22   introduced PRI module functions (for Prima, Quader) (V1.2.xx.753)
#
#-----------------------------------------------------------------------------
#
#
#
IS_A_VUV = 0
IS_A_VIR = 1
#
STR_SEPARATORLINE = "    ============================================================"
STR_INDENT        = "     "
FNAME             = "OrigData.txt"
#
iFreqTrigSrc = [ ct.c_int(-1), ct.c_int(-1) ]
iFreqDivIdx  = [ ct.c_int(-1), ct.c_int(-1) ]
iTrigLevel   = [ ct.c_int(0),  ct.c_int(0)  ]
iIntensity   = [ ct.c_int(0),  ct.c_int(0)  ]
bFanRunning  = [ ct.c_int(0),  ct.c_int(0)  ]
#
#
def HasFWError (iFWErr, iPhase, iLocation, iSlot, cErrCond, cPromptString):
  #bool HasFWError (int iFWErr, int iPhase, int iLocation, int iSlot, char* cErrCond, char* cPromptString)
  #
  #
  if (isinstance(iFWErr, (ct.c_int, ct.c_byte))):
    iFWErr = iFWErr.value
  #
  if (iFWErr != Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR):
    #
    cErrTxt = ct.create_string_buffer(Sepia2_Def.SEPIA2_ERRSTRING_LEN + 1)
    cErrPhase = ct.create_string_buffer(Sepia2_Def.SEPIA2_FW_ERRPHASE_LEN + 1)
    #
    if (isinstance(iPhase, (ct.c_int, ct.c_byte))):
      iPhase = iPhase.value
    #
    if (isinstance(iLocation, (ct.c_int, ct.c_byte))):
      iLocation = iLocation.value
    #
    if (isinstance(iSlot, (ct.c_int, ct.c_byte))):
      iSlot = iSlot.value
    #
    #
    print("%s%s" % (STR_INDENT, cPromptString))
    #
    Sepia2_Lib.SEPIA2_LIB_DecodeError(iFWErr,  cErrTxt)
    Sepia2_Lib.SEPIA2_FWR_DecodeErrPhaseName(iPhase, cErrPhase)
    print("")
    print("%s   error code      : %5d,   i.e. '%s'" % (STR_INDENT, iFWErr, cErrTxt.value.decode("utf-8")))
    print("%s   error phase     : %5d,   i.e. '%s'" % (STR_INDENT, iPhase, cErrPhase.value.decode("utf-8")))
    print("%s   error location  : %5d" % (STR_INDENT,  iLocation))
    print("%s   error slot      : %5d" % (STR_INDENT,  iSlot))
    if (len(cErrCond) > 0):
      #
      print("%s   error condition : '%s'" % (STR_INDENT, cErrCond.value.decode("utf-8")))
      #
    print("")
    #  end of 'if (len(cErrCond) > 0)'
    #
    return True
  #  end of 'if (iFWErr != Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR)'
  #
  return False
#
#
def F_WriteLine(f, str, newline = "\n"):
  #void F_WriteLine(FileStream f, string str)
  f.write(str)
  f.write(newline)
#
#
def GetWriteAndModify_VUV_VIR_Data (f, iDevIdx, cVUV_VIRType, iVUV_VIR_Slot, IsVIR):
  #void GetWriteAndModify_VUV_VIR_Data (FileStream f, int iDevIdx, char* cVUV_VIRType, int iVUV_VIR_Slot, int IsVIR)
  #
  TrgLvlUpper = ct.c_int(0)
  TrgLvlLower = ct.c_int(0)
  TrgLvlRes = ct.c_int(0)
  #
  iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetTriggerData(iDevIdx, iVUV_VIR_Slot, byref(iFreqTrigSrc[IsVIR]), byref(iFreqDivIdx[IsVIR]), byref(iTrigLevel[IsVIR]))
  if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetTriggerData", iDevIdx, iVUV_VIR_Slot, NO_IDX_2)):
    #
    F_WriteLine(f, "%-4s TrigSrcIdx    =      %3d" % (cVUV_VIRType, iFreqTrigSrc[IsVIR].value))
    F_WriteLine(f, "%-4s FreqDivIdx    =      %3d" % (cVUV_VIRType, iFreqDivIdx[IsVIR].value))
    F_WriteLine(f, "%-4s TrigLevel     =    %5d"   % (cVUV_VIRType, iTrigLevel[IsVIR].value))
    #
    iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetIntensity(iDevIdx, iVUV_VIR_Slot, byref(iIntensity[IsVIR]))
    if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetIntensity", iDevIdx, iVUV_VIR_Slot, NO_IDX_2)):
      #
      F_WriteLine(f, "%-4s Intensity     =      %5.1f %%" % (cVUV_VIRType, 0.1 * iIntensity[IsVIR].value))
      #
      iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetFan(iDevIdx, iVUV_VIR_Slot, byref(bFanRunning[IsVIR]))
      if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetFan", iDevIdx, iVUV_VIR_Slot, NO_IDX_2)):
        #
        F_WriteLine(f, "%-4s FanRunning    =        %s" % (cVUV_VIRType, BoolToStr(bFanRunning[IsVIR])))
        #
      #  end of 'SEPIA2_VUV_VIR_GetFan'
    #  end of 'SEPIA2_VUV_VIR_GetIntensity'
    #
    iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_GetTrigLevelRange(iDevIdx, iVUV_VIR_Slot, byref(TrgLvlUpper), byref(TrgLvlLower), byref(TrgLvlRes))
    if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_GetTrigLevelRange", iDevIdx, iVUV_VIR_Slot, NO_IDX_2)):
      #
      iFreqTrigSrc[IsVIR].value = (0 if (iFreqTrigSrc[IsVIR].value == 1) else 1)
      iFreqDivIdx[IsVIR].value  = (1 if (iFreqDivIdx[IsVIR].value  == 2) else 2)
      iTrigLevel[IsVIR].value   = EnsureRange (50 - iTrigLevel[IsVIR].value, TrgLvlLower.value, TrgLvlUpper.value)
      iIntensity[IsVIR].value   = 1000 - iIntensity[IsVIR].value
      bFanRunning[IsVIR].value  = (1 if (bFanRunning[IsVIR].value  == 0) else 0)
      #
    else:
      #
      iFreqTrigSrc[IsVIR].value =    1
      iFreqDivIdx[IsVIR].value  =    2
      iTrigLevel[IsVIR].value   = -350
      iIntensity[IsVIR].value   =  440
      bFanRunning[IsVIR].value  =    1
      #
    #  end of 'SEPIA2_VUV_VIR_GetTrigLevelRange'
  #  end of 'SEPIA2_VUV_VIR_GetTriggerData'
  #
  return iRetVal


def Read_VUV_VIR_Data(f, cVUV_VIRType, IsVIR):
  #void Read_VUV_VIR_Data(FileStream f, StringBuilder cVUV_VIRType, int IsVIR)
  #
  fIntensity = StrToFloat(GetValStr(f, "%4s Intensity     =" % cVUV_VIRType))
  #
  bFanRunning[IsVIR].value  = (1 if (StrToBool(GetValStr(f, "%4s FanRunning    =" % cVUV_VIRType))) else 0)
  iFreqTrigSrc[IsVIR].value =        StrToInt (GetValStr(f, "%4s TrigSrcIdx    =" % cVUV_VIRType))
  iFreqDivIdx[IsVIR].value  =        StrToInt (GetValStr(f, "%4s FreqDivIdx    =" % cVUV_VIRType))
  iTrigLevel[IsVIR].value   =        StrToInt (GetValStr(f, "%4s TrigLevel     =" % cVUV_VIRType))
  iIntensity[IsVIR].value   = int(10 * math.fabs(fIntensity) + 0.5)
  if(fIntensity < 0):
    iIntensity[IsVIR].value *= -1
  #


def Set_VUV_VIR_Data(iDevIdx, cVUV_VIRType, iVUV_VIR_Slot, IsVIR):
  #void Set_VUV_VIR_Data(int iDevIdx, char* cVUV_VIRType, int iVUV_VIR_Slot, int IsVIR)
  #
  iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_SetTriggerData(iDevIdx, iVUV_VIR_Slot, iFreqTrigSrc[IsVIR], iFreqDivIdx[IsVIR], iTrigLevel[IsVIR])
  if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_SetTriggerData", iDevIdx, iVUV_VIR_Slot, NO_IDX_2)):
    #
    iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_SetIntensity(iDevIdx, iVUV_VIR_Slot, iIntensity[IsVIR])
    if (Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_SetIntensity", iDevIdx, iVUV_VIR_Slot, NO_IDX_2)):
      #
      iRetVal = Sepia2_Lib.SEPIA2_VUV_VIR_SetFan (iDevIdx, iVUV_VIR_Slot, bFanRunning[IsVIR])
      Sepia2FunctionSucceeds(iRetVal, "VUV_VIR_SetFan", iDevIdx, iVUV_VIR_Slot, NO_IDX_2)
    #  end of 'SEPIA2_VUV_VIR_SetIntensity'
    #
    print("%s%-4s TrigSrcIdx    =      %3d"      % (STR_INDENT, cVUV_VIRType, iFreqTrigSrc[IsVIR].value))
    print("%s%-4s FreqDivIdx    =      %3d"      % (STR_INDENT, cVUV_VIRType, iFreqDivIdx[IsVIR].value))
    print("%s%-4s TrigLevel     =    %5d mV"     % (STR_INDENT, cVUV_VIRType, iTrigLevel[IsVIR].value))
    print("%s%-4s Intensity     =      %5.1f %%" % (STR_INDENT, cVUV_VIRType, (0.1 * iIntensity[IsVIR].value)))
    print("%s%-4s FanRunning    =        %s"     % (STR_INDENT, cVUV_VIRType, BoolToStr(bFanRunning[IsVIR])))
    print("")
  #  end of 'SEPIA2_VUV_VIR_SetTriggerData'
  #
  return iRetVal


def main(argv):
  #int main(int argc, char* argv[])
  #
  cLibVersion = ct.create_string_buffer(Sepia2_Def.SEPIA2_VERSIONINFO_LEN)
  cSepiaSerNo = ct.create_string_buffer(Sepia2_Def.SEPIA2_SERIALNUMBER_LEN)
  cGivenSerNo = ""
  cProductModel = ct.create_string_buffer(Sepia2_Def.SEPIA2_PRODUCTMODEL_LEN)
  cGivenProduct = ct.create_string_buffer(Sepia2_Def.SEPIA2_PRODUCTMODEL_LEN)
  cFWVersion = ct.create_string_buffer(Sepia2_Def.SEPIA2_VERSIONINFO_LEN)
  cDescriptor = ct.create_string_buffer(Sepia2_Def.SEPIA2_USB_STRDECR_LEN)
  cFWErrCond = ct.create_string_buffer(Sepia2_Def.SEPIA2_FW_ERRCOND_LEN)
  #cErrString = ct.create_string_buffer(Sepia2_Def.SEPIA2_ERRSTRING_LEN)
  #cFWErrPhase = ct.create_string_buffer(Sepia2_Def.SEPIA2_FW_ERRPHASE_LEN)
  cSOMSerNr = ct.create_string_buffer(Sepia2_Def.SEPIA2_SERIALNUMBER_LEN + 1)
  cSLMSerNr = ct.create_string_buffer(Sepia2_Def.SEPIA2_SERIALNUMBER_LEN + 1)
  cVUVSerNr = ct.create_string_buffer(Sepia2_Def.SEPIA2_SERIALNUMBER_LEN + 1)
  cVIRSerNr = ct.create_string_buffer(Sepia2_Def.SEPIA2_SERIALNUMBER_LEN + 1)
  cPRISerNr = ct.create_string_buffer(Sepia2_Def.SEPIA2_SERIALNUMBER_LEN + 1)
  cSOMFSerNr = ""
  cSLMFSerNr = ""
  cVUVFSerNr = ""
  cVIRFSerNr = ""
  cPRIFSerNr = ""
  cFreqTrigMode = ct.create_string_buffer(Sepia2_Def.SEPIA2_SOM_FREQ_TRIGMODE_LEN)
  cOperMode = ct.create_string_buffer(Sepia2_Def.SEPIA2_PRI_OPERMODE_LEN);

  cSOMType = ct.create_string_buffer(6)
  cSLMType = ct.create_string_buffer(6)
  cVUVType = ct.create_string_buffer(6)
  cVIRType = ct.create_string_buffer(6)
  cPRIType = ct.create_string_buffer(6)
  # long
  lBurstChannels = [ ct.c_int(0), ct.c_int(0), ct.c_int(0), ct.c_int(0), ct.c_int(0), ct.c_int(0), ct.c_int(0), ct.c_int(0) ]
  lTemp = 0
  # int
  iGivenDevIdx = ct.c_int(0)
  iSlotNr = ct.c_int(0)
  iSOM_Slot = -1
  iSLM_Slot = -1
  iVUV_Slot = -1
  iVIR_Slot = -1
  iPRI_Slot = -1
  iSOM_FSlot = ct.c_int(-1)
  iSLM_FSlot = ct.c_int(-1)
  iVUV_FSlot = ct.c_int(-1)
  iVIR_FSlot = ct.c_int(-1)
  iPRI_FSlot = ct.c_int(-1)
  #
  #
  iModuleCount = ct.c_int(0)
  iModuleType = ct.c_int(0)
  iFWErrCode = ct.c_int(0)
  iFWErrPhase = ct.c_int(0)
  iFWErrLocation = ct.c_int(0)
  iFWErrSlot = ct.c_int(0)
  iSOMModuleType = 0
  iFreqTrigIdx = ct.c_int(0)
  #
  iOpModeIdx = ct.c_int(0)
  #iTrgSrcIdx = ct.c_int(0)
  iWL_Idx = ct.c_int(0)
  #
  iTemp1 = 0
  iTemp2 = 0
  iTemp3 = 0
  iFreq = ct.c_int(0)
  iHead = ct.c_int(0)
  i = 0
  #
  PRI_Const = T_PRI_Constants()
  #
  # byte (boolean)
  bUSBInstGiven     = False
  bSerialGiven      = False
  bProductGiven     = False
  bNoWait           = False
  bIsPrimary        = ct.c_byte(0)
  bIsBackPlane      = ct.c_byte(0)
  bHasUptimeCounter = ct.c_byte(0)
  bSOM_Found        = False
  bSLM_Found        = False
  bVUV_Found        = False
  bVIR_Found        = False
  bPRI_Found        = False
  bSOM_FFound       = False
  bSLM_FFound       = False
  bVUV_FFound       = False
  bVIR_FFound       = False
  bPRI_FFound       = False
  bIsSOMDModule     = False
  bExtTiggered      = ct.c_byte(0)
  bPulseMode        = ct.c_byte(0)
  bSyncInverse      = ct.c_byte(0)
  bSynchronized     = ct.c_byte(0)
  #
  # byte (numerical or bit-coded value)
  bDivider          = ct.c_byte(0)
  bOutEnable        = ct.c_byte(0)
  bSyncEnable       = ct.c_byte(0)
  bPreSync          = ct.c_byte(0)
  bMaskSync         = ct.c_byte(0)
  #
  # word
  wIntensity = ct.c_ushort(0)
  wDivider = ct.c_ushort(0)
  wSOMDState = ct.c_ushort(0)
  iSOMDErrorCode = ct.c_short(0)
  #
  fIntensity = 0.0
  iRetVal = Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR
  iDevIdx = -1
  #
  #
  #
  if (len(argv) - 1 == 0):
    print(" called without parameters")
  else:
    print(" called with %d Parameter%s:" % (len(argv) - 1, "s" if len(argv) > 2 else ""))
    #
    #region CMD-Args checks
    #
    #for cmd_arg in argv:
    for i in range(1, len(argv)):
      parameter_found = False
      cmd_arg = argv[i]
      pos = cmd_arg.find("-inst=")
      if (pos >= 0):
        iGivenDevIdx = (int)(cmd_arg[pos + 6:]) #throws an exception if the value is no number
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
      pos = cmd_arg.find("-nowait")
      if (pos >= 0):
        bNoWait = True
        parameter_found = True
        print("  -nowait")
      #
      #
      if(not parameter_found):
        print("  %s : unknown parameter!" % cmd_arg)
      #
    #
    #endregion CMD-Args checks
    #
  #
  #
  print("")
  print("")
  print("%sPQLaserDrv   Set SOME Values Demo : " % STR_INDENT)
  print("%s" % STR_SEPARATORLINE)
  print("")
  #
  #
  #  preliminaries: check library version
  #
  try:
    iRetVal = Sepia2_Lib.SEPIA2_LIB_GetVersion(cLibVersion)
    if (not Sepia2FunctionSucceeds(iRetVal, "LIB_GetVersion", NO_DEVIDX, NO_IDX_1, NO_IDX_2)):
      return iRetVal
    #
  except  Exception as ex:
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
  print("%sLib-Version    = %s" % (STR_INDENT, cLibVersion.value.decode("utf-8")))
  #
  #
  if (not cLibVersion.value.decode("utf-8").startswith(Sepia2_Def.LIB_VERSION_REFERENCE[0: Sepia2_Def.LIB_VERSION_REFERENCE_COMPLEN])):
    print("")
    print("%sWarning: This demo application was built for version  %s!" % (STR_INDENT, Sepia2_Def.LIB_VERSION_REFERENCE))
    print("%s         Continuing may cause unpredictable results!" % STR_INDENT)
    print("")
    print("%sDo you want to continue anyway? (y/n): " % STR_INDENT)

    user_inp = input()
    if (not user_inp.upper().startswith("Y")):
      return -1
    #
    print("")
  #
  #endregion check library version
  #
  #
  #region Establish USB connection to the Sepia first matching all given conditions
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
    if ((iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR)                  \
        and (((bSerialGiven and bProductGiven)                              \
            and (cGivenSerNo == cSepiaSerNo.value.decode("utf-8"))          \
            and (cGivenProduct == cProductModel.value.decode("utf-8"))      \
          )                                                                 \
          or (((not bSerialGiven) != (not bProductGiven))                   \
            and ((cGivenSerNo == cSepiaSerNo.value.decode("utf-8"))         \
              or (cGivenProduct == cProductModel.value.decode("utf-8"))     \
            )                                                               \
          )                                                                 \
          or (not bSerialGiven and not bProductGiven)                       \
         )                                                                  \
       ):
      #
      if (bUSBInstGiven):
        if (iGivenDevIdx == i):
          iDevIdx = iGivenDevIdx
        else:
          iDevIdx = -1
      else:
        iDevIdx = i
      #
      break
    #
    i += 1
    #
  #
  #endregion Establish USB connection to the Sepia first matching all given conditions
  #
  #
  iRetVal = Sepia2_Lib.SEPIA2_USB_OpenDevice(iDevIdx, cProductModel, cSepiaSerNo)
  if (Sepia2FunctionSucceeds(iRetVal, "USB_OpenDevice", iDevIdx, NO_IDX_1, NO_IDX_2)):
    #
    print("%sProduct Model  = '%s'" % (STR_INDENT, cProductModel.value.decode("utf-8")))
    print("")
    print(STR_SEPARATORLINE)
    print("")
    #
    iRetVal = Sepia2_Lib.SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion)
    if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetVersion", iDevIdx, NO_IDX_1, NO_IDX_2)):
      #
      print("%sFW-Version     = %s" % (STR_INDENT, cFWVersion.value.decode("utf-8")))
    #  end of 'SEPIA2_FWR_GetVersion'
    #
    iRetVal = Sepia2_Lib.SEPIA2_USB_GetStrDescriptor (iDevIdx, cDescriptor)
    if (Sepia2FunctionSucceeds(iRetVal, "USB_GetStrDescriptor", iDevIdx, NO_IDX_1, NO_IDX_2)):
      #
      print("%sUSB Index      = %d" % (STR_INDENT, iDevIdx))
      print("%sUSB Descriptor = %s" % (STR_INDENT, cDescriptor.value.decode("utf-8")))
      print("%sSerial Number  = '%s'" % (STR_INDENT, cSepiaSerNo.value.decode("utf-8")))
    #  end of 'SEPIA2_USB_GetStrDescriptor'
    #
    print("")
    print(STR_SEPARATORLINE)
    print("")
    print("")
    #
    #
    # get sepia's module map and initialise datastructures for all library functions
    # there are two different ways to do so:
    #
    # first:  if sepia was not touched since last power on, it doesn't need to be restarted
    #
    iRetVal = Sepia2_Lib.SEPIA2_FWR_GetModuleMap (iDevIdx, Sepia2_Def.SEPIA2_NO_RESTART, byref(iModuleCount))
    #
    # second: in case of changes with soft restart
    #
    #  iRetVal = Sepia2_Lib.SEPIA2_FWR_GetModuleMap (iDevIdx, Sepia2_Def.SEPIA2_RESTART, byref(iModuleCount))
    #
    if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetModuleMap", iDevIdx, NO_IDX_1, NO_IDX_2)):
      #
      #
      # this is to inform us about possible error conditions during sepia's last startup
      #
      iRetVal = Sepia2_Lib.SEPIA2_FWR_GetLastError (iDevIdx, byref(iFWErrCode), byref(iFWErrPhase), byref(iFWErrLocation), byref(iFWErrSlot), cFWErrCond)
      if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetLastError", iDevIdx, NO_IDX_1, NO_IDX_2)):
        #
        #
        if (not HasFWError (iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond, "Firmware error detected:")):
          #
          # now look for SOM(D), SLM, VUV/VIR, PRI - modules, take always the first
          #
          for i in range(0, iModuleCount.value):
            #
            iRetVal = Sepia2_Lib.SEPIA2_FWR_GetModuleInfoByMapIdx(iDevIdx, i, byref(iSlotNr), byref(bIsPrimary), byref(bIsBackPlane), byref(bHasUptimeCounter))
            if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetModuleInfoByMapIdx", iDevIdx, i, NO_IDX_2)):
              #
              if (bIsPrimary.value != 0 and bIsBackPlane.value == 0):
                #
                iRetVal = Sepia2_Lib.SEPIA2_COM_GetModuleType(iDevIdx, iSlotNr, Sepia2_Def.SEPIA2_PRIMARY_MODULE, byref(iModuleType))
                if (Sepia2FunctionSucceeds(iRetVal, "COM_GetModuleType", iDevIdx, iSlotNr, NO_IDX_2)):
                  #
                  # switch through 'iModuleType' with cases for possible Module-Types...
                  #
                  if (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOM or iModuleType.value ==  Sepia2_Def.SEPIA2OBJECT_SOMD):
                    #
                    if (not bSOM_Found):
                      #
                      bSOM_Found = True
                      iSOM_Slot = iSlotNr.value
                      iSOMModuleType = iModuleType.value
                      bIsSOMDModule = (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOMD)
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, Sepia2_Def.SEPIA2_PRIMARY_MODULE, cSOMSerNr)
                      if (Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotNr, NO_IDX_2)):
                        #
                        Sepia2_Lib.SEPIA2_COM_DecodeModuleTypeAbbr(iModuleType, cSOMType)
                        #
                        if (bIsSOMDModule):
                          #
                          iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetStatusError(iDevIdx, iSOM_Slot, byref(wSOMDState), byref(iSOMDErrorCode))
                          Sepia2FunctionSucceeds(iRetVal, "SOMD_GetStatusError", iDevIdx, iSOM_Slot, NO_IDX_2)
                        #  end of 'if (bIsSOMDModule)'
                      #  end of 'SEPIA2_COM_GetSerialNumber'
                    #  end of 'if (not bSOM_Found)'
                  #  end of 'if(iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SOM or iModuleType.value ==  Sepia2_Def.SEPIA2OBJECT_SOMD)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SLM):
                    #
                    if (not bSLM_Found):
                      #
                      bSLM_Found = True
                      iSLM_Slot = iSlotNr.value
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, Sepia2_Def.SEPIA2_PRIMARY_MODULE, cSLMSerNr)
                      Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotNr, NO_IDX_2)
                    #  end of 'if (not bSLM_Found)'
                  #  end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_SLM)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_VUV):
                    #
                    if (not bVUV_Found):
                      #
                      bVUV_Found = True
                      iVUV_Slot = iSlotNr.value
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, Sepia2_Def.SEPIA2_PRIMARY_MODULE, cVUVSerNr)
                      Sepia2FunctionSucceeds(iRetVal, "COM_GetSerialNumber", iDevIdx, iSlotNr, NO_IDX_2)
                    #  end of 'if (not bVUV_Found)'
                  #  end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_VUV)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_VIR):
                    #
                    if (not bVIR_Found):
                      #
                      bVIR_Found = True
                      iVIR_Slot = iSlotNr.value
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, Sepia2_Def.SEPIA2_PRIMARY_MODULE, cVIRSerNr)
                      Sepia2FunctionSucceeds(iRetVal, "", iDevIdx, iSlotNr, NO_IDX_2)
                    #  end of 'if (not bVIR_Found)'
                  #  end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_VIR)'
                  #
                  elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_PRI):
                    #
                    if (not bPRI_Found):
                      #
                      bPRI_Found = True
                      iPRI_Slot = iSlotNr.value
                      #
                      PRI_Const.PRI_GetConstants(iDevIdx, iPRI_Slot);
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_COM_GetSerialNumber(iDevIdx, iSlotNr, Sepia2_Def.SEPIA2_PRIMARY_MODULE, cPRISerNr)
                      Sepia2FunctionSucceeds(iRetVal, "", iDevIdx, iSlotNr, NO_IDX_2)
                    #  end of 'if (not bPRI_Found)'
                  #  end of 'elif (iModuleType.value == Sepia2_Def.SEPIA2OBJECT_PRI)'
                  #
                  # END of switching between modulespecific information
                #  end of 'SEPIA2_COM_GetModuleType'
              #  end of 'if (bIsPrimary && !bIsBackPlane)
            #  end of 'SEPIA2_FWR_GetModuleInfoByMapIdx'
          #  end of 'for i in range(0, iModuleCount.value)'
          #
          #
          #
          if (cSOMType.value.decode("utf-8") < "SOM "):
            #
            Sepia2_Lib.SEPIA2_COM_DecodeModuleTypeAbbr(Sepia2_Def.SEPIA2OBJECT_SOM, cSOMType)
            #
          #  end of 'if (cSOMType.value.decode("utf-8") < "SOM ")'
          #
          Sepia2_Lib.SEPIA2_COM_DecodeModuleTypeAbbr(Sepia2_Def.SEPIA2OBJECT_SLM, cSLMType)
          Sepia2_Lib.SEPIA2_COM_DecodeModuleTypeAbbr(Sepia2_Def.SEPIA2OBJECT_VUV, cVUVType)
          Sepia2_Lib.SEPIA2_COM_DecodeModuleTypeAbbr(Sepia2_Def.SEPIA2OBJECT_VIR, cVIRType)
          Sepia2_Lib.SEPIA2_COM_DecodeModuleTypeAbbr(Sepia2_Def.SEPIA2OBJECT_PRI, cPRIType)
          #
          # let all module types be exact 4 characters long:
          while (len(cSOMType.value) < 4):
            cSOMType.value += b" "
          cSOMType.value = cSOMType.value[:4]
          cSOMType = cSOMType.value.decode("utf-8")
          #
          while (len(cSLMType.value) < 4):
            cSLMType.value += b" "
          cSLMType.value = cSLMType.value[:4]
          cSLMType = cSLMType.value.decode("utf-8")
          #
          while (len(cVUVType.value) < 4):
            cVUVType.value += b" "
          cVUVType.value = cVUVType.value[:4]
          cVUVType = cVUVType.value.decode("utf-8")
          #
          while (len(cVIRType.value) < 4):
            cVIRType.value += b" "
          cVIRType.value = cVIRType.value[:4]
          cVIRType = cVIRType.value.decode("utf-8")
          #
          while (len(cPRIType.value) < 4):
            cPRIType.value += b" "
          cPRIType.value = cPRIType.value[:4]
          cPRIType = cPRIType.value.decode("utf-8")
          #
          #
          #  we want to restore the changed values ...
          if (os.path.isfile("./%s" % FNAME)):
            #
            # The params-file exists
            # ... so we have to read the original data from file
            #
            f = open("./%s" % FNAME, "r")
            #
            #   SOM
            #
            bSOM_FFound = StrToBool(GetValStr(f, "%s ModuleFound   =" % cSOMType))
            #
            if (bSOM_FFound != bSOM_Found):
              #
              print("")
              f.close()
              print("%sdevice configuration probably changed:" % STR_INDENT)
              print("%scouldn't process original data as read from file '%s'" % (STR_INDENT, FNAME))
              print("%sfile %s SOM data, but" % (STR_INDENT, ("contains" if (bSOM_FFound) else "doesn't contain")))
              print("%sdevice has currently %s SOM module" % (STR_INDENT, ("a" if (bSOM_Found) else "no")))
              print("")
              print("%sdemo execution aborted." % STR_INDENT)
              print("")
              print("")
              print("press RETURN...")
              input()
              return (1)
            #  end of 'if (bSOM_FFound != bSOM_Found)'
            #
            if (bSOM_FFound):
              #
              # SOM / SOMD Data
              #
              iSOM_FSlot = StrToInt(GetValStr(f, "%4s SlotID        =" % cSOMType))
              cSOMFSerNr = GetValStr(f, "%4s SerialNumber  =" % cSOMType).strip()
              #
              if ((iSOM_FSlot != iSOM_Slot) or (cSOMFSerNr != cSOMSerNr.value.decode("utf-8"))):
                #
                print("")
                f.close()
                print("%sdevice configuration probably changed:" % STR_INDENT)
                print("%scouldn't process original data as read from file '%s'" % (STR_INDENT, FNAME))
                print("%sfile data on the slot or serial number of the SOM module differs" % STR_INDENT)
                print("")
                print("%sdemo execution aborted." % STR_INDENT)
                print("")
                print("")
                print("press RETURN...")
                input()
                return (1)
              #  end of 'if ((iSOM_FSlot != iSOM_Slot) or (cSOMFSerNr != cSOMSerNr.value.decode("utf-8")))'
              #
              #
              # FreqTrigMode
              #
              iFreqTrigIdx = StrToInt(GetValStr(f, "%4s FreqTrigIdx   =" % cSOMType))
              bExtTiggered = (iFreqTrigIdx == Sepia2_Def.SEPIA2_SOM_TRIGMODE_RISING) or (iFreqTrigIdx == Sepia2_Def.SEPIA2_SOM_TRIGMODE_FALLING)
              #
              if ("SOMD" == cSOMType and bExtTiggered):
                #
                iTemp1 = StrToInt(GetValStr(f, "%4s ExtTrig.Sync. =" % cSOMType))
                bSynchronized.value = 1 if (iTemp1 != 0) else 0
              #  end of 'if ("SOMD" == cSOMType.value.decode("utf-8") and bExtTiggered)'
              #
              iTemp1 = StrToInt(GetValStr(f, "%4s Divider       =" % cSOMType))
              iTemp2 = StrToInt(GetValStr(f, "%4s PreSync       =" % cSOMType))
              iTemp3 = StrToInt(GetValStr(f, "%4s MaskSync      =" % cSOMType))
              bDivider.value = (iTemp1 % 256)
              wDivider.value = iTemp1
              bPreSync.value = iTemp2
              bMaskSync.value = iTemp3
              #
              iTemp1 = StrToInt(GetValStr(f, "%4s Output Enable =" % cSOMType))
              iTemp2 = StrToInt(GetValStr(f, "%4s Sync Enable   =" % cSOMType))
              bOutEnable.value  = iTemp1
              bSyncEnable.value = iTemp2
              bSyncInverse.value = 1 if (StrToBool(GetValStr(f, "%4s Sync Inverse  =" % cSOMType))) else 0
              for i in range(0, Sepia2_Def.SEPIA2_SOM_BURSTCHANNEL_COUNT):
                #
                lTemp = StrToInt(GetValStr(f, "%4s BurstLength %d =" % (cSOMType, i + 1)))
                lBurstChannels[i].value = lTemp
                #
              #  end of 'for i in range(0, Sepia2_Def.SEPIA2_SOM_BURSTCHANNEL_COUNT)'
              #
            #  end of 'if (bSOM_FFound)'
            #
            #
            #   SLM
            #
            bSLM_FFound = StrToBool(GetValStr(f, "%s ModuleFound   =" % cSLMType))
            #
            if (bSLM_FFound != bSLM_Found):
              #
              print("")
              f.close()
              print("%sdevice configuration probably changed:" % STR_INDENT)
              print("%scouldn't process original data as read from file '%s'" % (STR_INDENT, FNAME))
              print("%sfile %s SLM data, but" % (STR_INDENT, ("contains" if (bSLM_FFound) else "doesn't contain")))
              print("%sdevice has currently %s SLM module" % (STR_INDENT, ("a" if (bSLM_Found) else "no")))
              print("")
              print("%sdemo execution aborted." % STR_INDENT)
              print("")
              print("")
              print("press RETURN...")
              input()
              return (1)
            #  end of 'if (bSLM_FFound != bSLM_Found)'
            #
            if (bSLM_FFound):
              #
              # SLM Data
              #
              iSLM_FSlot = StrToInt(GetValStr(f, "%4s SlotID        =" % cSLMType))
              cSLMFSerNr = GetValStr(f, "%4s SerialNumber  =" % cSLMType).strip()
              #
              if ((iSLM_FSlot != iSLM_Slot) or (cSLMFSerNr != cSLMSerNr.value.decode("utf-8"))):
                #
                print("")
                f.close()
                print("%sdevice configuration probably changed:" % STR_INDENT)
                print("%scouldn't process original data as read from file '%s'" % (STR_INDENT, FNAME))
                print("%sfile data on the slot or serial number of the SLM module differs" % STR_INDENT)
                print("")
                print("%sdemo execution aborted." % STR_INDENT)
                print("")
                print("")
                print("press RETURN...")
                input()
                return (1)
              #  end of 'if ((iSLM_FSlot != iSLM_Slot) or (cSLMFSerNr != cSLMSerNr.value.decode("utf-8")))'
              #
              iFreq.value      = StrToInt  (GetValStr(f, "%4s FreqTrigIdx   =" % cSLMType))
              fIntensity       = StrToFloat(GetValStr(f, "%4s Intensity     =" % cSLMType))
              bPulseMode.value = 1 if (StrToBool(GetValStr(f, "%4s Pulse Mode    =" % cSLMType))) else 0
              wIntensity.value = int(10 * fIntensity + 0.5)
              #
            #  end of 'if (bSLM_FFound)'
            #
            #
            #   VUV
            #
            bVUV_FFound = StrToBool(GetValStr(f, "%4s ModuleFound   =" % cVUVType))
            #
            if (bVUV_FFound != bVUV_Found):
              #
              print("")
              f.close()
              print("%sdevice configuration probably changed:" % STR_INDENT)
              print("%scouldn't process original data as read from file '%s'" % (STR_INDENT, FNAME))
              print("%sfile %s VisUV data, but" % (STR_INDENT, ("contains" if (bVUV_FFound) else "doesn't contain")))
              print("%sdevice has currently %s VUV module" % (STR_INDENT, ("a" if (bVUV_Found) else "no")))
              print("")
              print("%sdemo execution aborted." % STR_INDENT)
              print("")
              print("")
              print("press RETURN...")
              input()
              return (1)
            #  end of 'if (bVUV_FFound != bVUV_Found)'
            #
            if (bVUV_FFound):
              #
              # VUV Data
              #
              iVUV_FSlot = StrToInt(GetValStr(f, "%4s SlotID        =" % cVUVType))
              cVUVFSerNr = GetValStr(f, "%4s SerialNumber  =" % cVUVType).strip()
              #
              if ((iVUV_FSlot != iVUV_Slot) or (cVUVFSerNr != cVUVSerNr.value.decode("utf-8"))):
                #
                print("")
                f.close()
                print("%sdevice configuration probably changed:" % STR_INDENT)
                print("%scouldn't process original data as read from file '%s'" % (STR_INDENT, FNAME))
                print("%sfile data on the slot or serial number of the VUV module differs" % STR_INDENT)
                print("")
                print("%sdemo execution aborted." % STR_INDENT)
                print("")
                print("")
                print("press RETURN...")
                input()
                return (1)
              #  end of 'if ((iVUV_FSlot != iVUV_Slot) or (cVUVFSerNr != cVUVSerNr.value.decode("utf-8")))'
              #
              Read_VUV_VIR_Data(f, cVUVType, IS_A_VUV)
              #
            #  end of 'if (bVUV_FFound)'
            #
            #
            #   VIR
            #
            bVIR_FFound = StrToBool(GetValStr(f, "%4s ModuleFound   =" % cVIRType))
            #
            if (bVIR_FFound != bVIR_Found):
              #
              print("")
              f.close()
              print("%sdevice configuration probably changed:" % STR_INDENT)
              print("%scouldn't process original data as read from file '%s'" % (STR_INDENT, FNAME))
              print("%sfile %s VisIR data, but" % (STR_INDENT, ("contains" if (bVIR_FFound) else "doesn't contain")))
              print("%sdevice has currently %s VIR module" % (STR_INDENT, ("a" if (bVIR_Found) else "no")))
              print("")
              print("%sdemo execution aborted." % STR_INDENT)
              print("")
              print("")
              print("press RETURN...")
              input()
              return (1)
            #  end of 'if (bVIR_FFound != bVIR_Found)'
            #
            if (bVIR_FFound):
              #
              # VIR Data
              #
              iVIR_FSlot = StrToInt(GetValStr(f, "%4s SlotID        =" % cVIRType))
              cVIRFSerNr = GetValStr(f, "%4s SerialNumber  =" % cVIRType).strip()
              #
              if ((iVIR_FSlot != iVIR_Slot) or (cVIRFSerNr != cVIRSerNr.value.decode("utf-8"))):
                #
                print("")
                f.close()
                print("%sdevice configuration probably changed:" % STR_INDENT)
                print("%scouldn't process original data as read from file '%s'" % STR_INDENT, FNAME)
                print("%sfile data on the slot or serial number of the VIR module differs" % STR_INDENT)
                print("")
                print("%sdemo execution aborted." % STR_INDENT)
                print("")
                print("")
                print("press RETURN...")
                input()
                return (1)
              #  end of 'if (bVIR_FFound)'
              #
              Read_VUV_VIR_Data(f, cVIRType, IS_A_VIR)
              #
            #  end of 'if (bVIR_FFound)'
            #
            #
            #   PRI
            #
            bPRI_FFound = StrToBool(GetValStr(f, "%4s ModuleFound   =" % cPRIType))
            #
            if (bPRI_FFound != bPRI_Found):
              #
              print("")
              f.close()
              print("%sdevice configuration probably changed:" % STR_INDENT)
              print("%scouldn't process original data as read from file '%s'" % (STR_INDENT, FNAME))
              print("%sfile %s Prima data, but" % (STR_INDENT, ("contains" if (bPRI_FFound) else "doesn't contain")))
              print("%sdevice has currently %s PRI module" % (STR_INDENT, ("a" if (bPRI_Found) else "no")))
              print("")
              print("%sdemo execution aborted." % STR_INDENT)
              print("")
              print("")
              print("press RETURN...")
              input()
              return (1)
            #  end of 'if (bPRI_FFound != bPRI_Found)'
            #
            if (bPRI_FFound):
              #
              # PRI Data
              #
              iPRI_FSlot = StrToInt(GetValStr(f, "%4s SlotID        =" % cPRIType))
              cPRIFSerNr = GetValStr(f, "%4s SerialNumber  =" % cPRIType).strip()
              #
              if ((iPRI_FSlot != iPRI_Slot) or (cPRIFSerNr != cPRISerNr.value.decode("utf-8"))):
                #
                print("")
                f.close()
                print("%sdevice configuration probably changed:" % STR_INDENT)
                print("%scouldn't process original data as read from file '%s'" % STR_INDENT, FNAME)
                print("%sfile data on the slot or serial number of the PRI module differs" % STR_INDENT)
                print("")
                print("%sdemo execution aborted." % STR_INDENT)
                print("")
                print("")
                print("press RETURN...")
                input()
                return (1)
              #  end of 'if (bPRI_FFound)'
              #
              # Read_PRI_Data(f, cPRIType)
              #
              iOpModeIdx.value = StrToInt(GetValStr(f, "%4s OperModeIdx   =" % cPRIType))
              iWL_Idx.value    = StrToInt(GetValStr(f, "%4s WavelengthIdx =" % cPRIType))
              fIntensity       = StrToFloat(GetValStr(f, "%4s Intensity     =" % cPRIType))
              wIntensity.value = int(10 * fIntensity + 0.5)
              #
            #  end of 'if (bPRI_FFound)'
            #
            #
            # ... and delete it afterwards
            f.close()
            print("%soriginal data as read from file '%s':" % (STR_INDENT, FNAME))
            print("%s(file was deleted after processing)" % STR_INDENT)
            print("")
            os.remove("./%s" % FNAME)
            #
          #  end of 'if (os.path.isfile("./%s" % FNAME))'
          #
          else:
            #
            # The params-file does not exits
            # ... so we have to save the original data in a file
            # ... and may then set arbitrary values
            #
            try:
              #
              f = open("./%s" % FNAME, "w")
            #
            except  Exception as ex:
              #
              print("%sYou tried to start this demo in a write protected directory." % STR_INDENT)
              print("%sdemo execution aborted." % STR_INDENT)
              print("")
              print("press RETURN...")
              input()
              return iRetVal
            #
            #
            #
            # SOM
            #
            F_WriteLine(f, "%4s ModuleFound   =        %s" % (cSOMType, BoolToStr(bSOM_Found)))
            if (bSOM_Found):
              #
              # SOM / SOMD
              #
              F_WriteLine(f, "%4s SlotID        =      %3d" % (cSOMType, iSOM_Slot))
              F_WriteLine(f, "%4s SerialNumber  = %8s"      % (cSOMType, cSOMSerNr.value.decode("utf-8")))
              #
              # FreqTrigMode
              #
              if (bIsSOMDModule):
                #
                iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetFreqTrigMode(iDevIdx, iSOM_Slot, byref(iFreqTrigIdx), byref(bSynchronized))
                if (Sepia2FunctionSucceeds(iRetVal, "SOMD_GetFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2)):
                  #
                  F_WriteLine(f, "%-4s FreqTrigIdx   =        %1d" % (cSOMType, iFreqTrigIdx.value))
                  if ((iFreqTrigIdx.value == Sepia2_Def.SEPIA2_SOM_TRIGMODE_RISING) or (iFreqTrigIdx.value == Sepia2_Def.SEPIA2_SOM_TRIGMODE_FALLING)):
                    #
                    F_WriteLine(f, "%-4s ExtTrig.Sync. =        %1d" % (cSOMType, (1 if (bSynchronized.value != 0) else 0)))
                    #
                  #  end of 'if ((iFreqTrigIdx.value == Sepia2_Def.SEPIA2_SOM_TRIGMODE_RISING) or (iFreqTrigIdx.value == Sepia2_Def.SEPIA2_SOM_TRIGMODE_FALLING))'
                #  end of 'SEPIA2_SOMD_GetFreqTrigMode'
              #  end of 'if (bIsSOMDModule)'
              #
              else:
                #
                iRetVal = Sepia2_Lib.SEPIA2_SOM_GetFreqTrigMode(iDevIdx, iSOM_Slot, byref(iFreqTrigIdx))
                if (Sepia2FunctionSucceeds(iRetVal, "SOM_GetFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2)):
                  #
                  F_WriteLine(f, "%-4s FreqTrigIdx   =        %1d" % (cSOMType, iFreqTrigIdx.value))
                  #
                #  end of 'SEPIA2_SOM_GetFreqTrigMode'
              #  end of 'else' of 'if (bIsSOMDModule)'
              #
              iFreqTrigIdx.value = Sepia2_Def.SEPIA2_SOM_INT_OSC_C
              #
              # BurstValues
              if (bIsSOMDModule):
                #
                iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetBurstValues(iDevIdx, iSOM_Slot, byref(wDivider), byref(bPreSync), byref(bMaskSync))
                Sepia2FunctionSucceeds(iRetVal, "SOMD_GetBurstValues", iDevIdx, iSOM_Slot, NO_IDX_2)
              #  end of 'if (bIsSOMDModule)'
              #
              else:
                #
                iRetVal = Sepia2_Lib.SEPIA2_SOM_GetBurstValues(iDevIdx, iSOM_Slot, byref(bDivider), byref(bPreSync), byref(bMaskSync))
                if (Sepia2FunctionSucceeds(iRetVal, "SOM_GetBurstValues", iDevIdx, iSOM_Slot, NO_IDX_2)):
                  #
                  wDivider.value = bDivider.value
                  #
                #  end of 'SEPIA2_SOM_GetBurstValues'
              #  end of 'else' of 'if (bIsSOMDModule)'
              #
              F_WriteLine(f, "%-4s Divider       =    %5u"   % (cSOMType, wDivider.value))
              F_WriteLine(f, "%-4s PreSync       =      %3u" % (cSOMType, bPreSync.value))
              F_WriteLine(f, "%-4s MaskSync      =      %3u" % (cSOMType, bMaskSync.value))
              bDivider.value = 200
              bPreSync.value = 10
              bMaskSync.value = 1
              #
              # Out'n'SyncEnable
              if (bIsSOMDModule):
                #
                iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetOutNSyncEnable(iDevIdx, iSOM_Slot, byref(bOutEnable), byref(bSyncEnable), byref(bSyncInverse))
                if (Sepia2FunctionSucceeds(iRetVal, "SOMD_GetOutNSyncEnable", iDevIdx, iSOM_Slot, NO_IDX_2)):
                  #
                  iRetVal = Sepia2_Lib.SEPIA2_SOMD_GetBurstLengthArray(iDevIdx, iSOM_Slot, byref(lBurstChannels[0]), byref(lBurstChannels[1]), byref(lBurstChannels[2]), byref(lBurstChannels[3]), byref(lBurstChannels[4]), byref(lBurstChannels[5]), byref(lBurstChannels[6]), byref(lBurstChannels[7]))
                  Sepia2FunctionSucceeds(iRetVal, "SOMD_GetBurstLengthArray", iDevIdx, iSOM_Slot, NO_IDX_2)
                #  end of 'SEPIA2_SOMD_GetOutNSyncEnable'
              #  end of 'if (bIsSOMDModule)'
              #
              else:
                #
                iRetVal = Sepia2_Lib.SEPIA2_SOM_GetOutNSyncEnable(iDevIdx, iSOM_Slot, byref(bOutEnable), byref(bSyncEnable), byref(bSyncInverse))
                if (Sepia2FunctionSucceeds(iRetVal, "SOM_GetOutNSyncEnable", iDevIdx, iSOM_Slot, NO_IDX_2)):
                  #
                  iRetVal = Sepia2_Lib.SEPIA2_SOM_GetBurstLengthArray(iDevIdx, iSOM_Slot, byref(lBurstChannels[0]), byref(lBurstChannels[1]), byref(lBurstChannels[2]), byref(lBurstChannels[3]), byref(lBurstChannels[4]), byref(lBurstChannels[5]), byref(lBurstChannels[6]), byref(lBurstChannels[7]))
                  Sepia2FunctionSucceeds(iRetVal, "SOM_GetBurstLengthArray", iDevIdx, iSOM_Slot, NO_IDX_2)
                #  end of 'SEPIA2_SOM_GetOutNSyncEnable'
              #  end of 'else' of 'if (bIsSOMDModule)'
              #
              F_WriteLine(f, "%-4s Output Enable =     0x%2X" % (cSOMType, bOutEnable.value))
              F_WriteLine(f, "%-4s Sync Enable   =     0x%2X" % (cSOMType, bSyncEnable.value))
              F_WriteLine(f, "%-4s Sync Inverse  =        %s" % (cSOMType, BoolToStr(bSyncInverse)))
              bOutEnable.value = 0xA5
              bSyncEnable.value = 0x93
              bSyncInverse.value = 1
              #
              # BurstLengthArray
              for i in range(0, Sepia2_Def.SEPIA2_SOM_BURSTCHANNEL_COUNT):
                #
                F_WriteLine(f, "%-4s BurstLength %d = %8d" % (cSOMType, (i + 1), lBurstChannels[i].value))
              #  end of 'for i in range(0, Sepia2_Def.SEPIA2_SOM_BURSTCHANNEL_COUNT)'
              #
              # just change places of burstlenght channel 2 & 3
              lTemp = lBurstChannels[2].value
              lBurstChannels[2].value = lBurstChannels[1].value
              lBurstChannels[1].value = lTemp
              #
            #  end of 'if (bSOM_Found)'
            #
            #
            # SLM
            #
            F_WriteLine(f, "%4s ModuleFound   =        %s" % (cSLMType, BoolToStr(bSLM_Found)))
            if (bSLM_Found):
              #
              # SLM
              #
              F_WriteLine(f, "%4s SlotID        =      %3d" % (cSLMType, iSLM_Slot))
              F_WriteLine(f, "%4s SerialNumber  = %8s"      % (cSLMType, cSLMSerNr.value.decode("utf-8")))
              #
              #
              iRetVal = Sepia2_Lib.SEPIA2_SLM_GetIntensityFineStep(iDevIdx, iSLM_Slot, byref(wIntensity))
              if (Sepia2FunctionSucceeds(iRetVal, "SLM_GetIntensityFineStep", iDevIdx, iSLM_Slot, NO_IDX_2)):
                #
                iRetVal = Sepia2_Lib.SEPIA2_SLM_GetPulseParameters(iDevIdx, iSLM_Slot, byref(iFreq), byref(bPulseMode), byref(iHead))
                Sepia2FunctionSucceeds(iRetVal, "SLM_GetPulseParameters", iDevIdx, iSLM_Slot, NO_IDX_2)
              #  end of 'SEPIA2_SLM_GetIntensityFineStep'
              #
              if (iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR):
                #
                F_WriteLine(f, "%-4s FreqTrigIdx   =        %1d"    % (cSLMType, iFreq.value))
                F_WriteLine(f, "%-4s Pulse Mode    =        %s"     % (cSLMType, BoolToStr(bPulseMode)))
                F_WriteLine(f, "%-4s Intensity     =      %5.1f %%" % (cSLMType, 0.1 * wIntensity.value))
                iFreq.value = (2 + iFreq.value) % Sepia2_Def.SEPIA2_SLM_FREQ_TRIGMODE_COUNT
                bPulseMode.value = 1 - bPulseMode.value
                wIntensity.value = 1000 - wIntensity.value
              #  end of 'if (iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR)'
              #
              else:
                #
                iFreq.value = Sepia2_Def.SEPIA2_SLM_FREQ_20MHZ
                bPulseMode.value = 1
                wIntensity.value = 440
              #  end of 'else' of 'if (iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR)'
              #
            #  end of 'if (bSLM_Found)'
            #
            #
            # VUV
            #
            F_WriteLine(f, "%4s ModuleFound   =        %s" % (cVUVType, BoolToStr(bVUV_Found)))
            if (bVUV_Found):
              #
              # VisUV
              #
              F_WriteLine(f, "%4s SlotID        =      %3d" % (cVUVType, iVUV_Slot))
              F_WriteLine(f, "%4s SerialNumber  = %8s"      % (cVUVType, cVUVSerNr.value.decode("utf-8")))
              #
              GetWriteAndModify_VUV_VIR_Data(f, iDevIdx, cVUVType, iVUV_Slot, IS_A_VUV)
              #
            #  end of 'if (bVUV_Found)'
            #
            #
            # VIR
            #
            F_WriteLine(f, "%4s ModuleFound   =        %s" % (cVIRType, BoolToStr(bVIR_Found)))
            if (bVIR_Found):
              #
              # VisIR
              #
              F_WriteLine (f, "%4s SlotID        =      %3d" % (cVIRType, iVIR_Slot))
              F_WriteLine (f, "%4s SerialNumber  = %8s"      % (cVIRType, cVIRSerNr.value.decode("utf-8")))
              #
              GetWriteAndModify_VUV_VIR_Data(f, iDevIdx, cVIRType, iVIR_Slot, IS_A_VIR)
              #
            #  end of 'if (bVIR_Found)'
            #
            #
            # PRI
            #
            F_WriteLine(f, "%4s ModuleFound   =        %s" % (cPRIType, BoolToStr(bPRI_Found)))
            if (bPRI_Found):
              #
              # Prima
              #
              F_WriteLine (f, "%4s SlotID        =      %3d" % (cPRIType, iPRI_Slot))
              F_WriteLine (f, "%4s SerialNumber  = %8s"      % (cPRIType, cPRISerNr.value.decode("utf-8")))
              #
              # GetWriteAndModify_PRI_Data(f, iDevIdx, cPRIType, iPRI_Slot)
              #
              iRetVal = Sepia2_Lib.SEPIA2_PRI_GetOperationMode (iDevIdx, iPRI_Slot, byref(iOpModeIdx));
              if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetOperationMode", iDevIdx, iPRI_Slot, NO_IDX_2)):
                #
                iRetVal = Sepia2_Lib.SEPIA2_PRI_GetWavelengthIdx(iDevIdx, iPRI_Slot, byref(iWL_Idx));
                if (Sepia2FunctionSucceeds(iRetVal, "PRI_GetWavelengthIdx", iDevIdx, iPRI_Slot, NO_IDX_2)):
                  #
                  iRetVal = Sepia2_Lib.SEPIA2_PRI_GetIntensity(iDevIdx, iPRI_Slot, iWL_Idx, byref(wIntensity));
                  Sepia2FunctionSucceeds(iRetVal, "PRI_GetIntensity", iDevIdx, iPRI_Slot, iWL_Idx);
                  #
                #
              #
              if (iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR):
                #
                F_WriteLine (f, "%4s OperModeIdx   =        %d" % (cPRIType, iOpModeIdx.value));
                F_WriteLine (f, "%4s WavelengthIdx =        %d" % (cPRIType, iWL_Idx.value));
                F_WriteLine (f, "%4s Intensity     =      %5.1f %%" % (cPRIType, 0.1 * wIntensity.value));
                #
                iOpModeIdx.value = (PRI_Const.PrimaOpModNarrow if (iOpModeIdx.value == PRI_Const.PrimaOpModBroad)
                                    else PRI_Const.PrimaOpModBroad);
                iWL_Idx.value   += 1;
                iWL_Idx.value    = (iWL_Idx.value % PRI_Const.PrimaWLCount);
                wIntensity.value = 1000 - wIntensity.value;
                #
              else:
                #
                iOpModeIdx.value = (PRI_Const.PrimaOpModNarrow if (iOpModeIdx.value == PRI_Const.PrimaOpModBroad)
                                    else PRI_Const.PrimaOpModBroad);
                iWL_Idx.value    = (1 if (iWL_Idx.value == 0) else 0);
                wIntensity.value = 440;
                #
              #
            #  end of 'if (bPRI_Found)'
            #
            f.close()
            print("%soriginal data was stored in file '%s'." % (STR_INDENT, FNAME))
            print("%schanged data as follows:" % STR_INDENT)
            print("")
            #
            #
          # end of 'else' of 'if (os.path.isfile("./%s" % FNAME))'
          #
          #
          #
          #
          # and here we finally set the new (resp. old) values
          #
          # SOM / SOMD
          #
          if (bSOM_Found):
            #
            if (bIsSOMDModule):
              #
              iRetVal = Sepia2_Lib.SEPIA2_SOMD_SetFreqTrigMode(iDevIdx, iSOM_Slot, iFreqTrigIdx, bSynchronized)
              if (Sepia2FunctionSucceeds(iRetVal, "SOMD_SetFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2)):
                #
                iRetVal = Sepia2_Lib.SEPIA2_SOMD_DecodeFreqTrigMode(iDevIdx, iSOM_Slot, iFreqTrigIdx, cFreqTrigMode)
                if (Sepia2FunctionSucceeds(iRetVal, "SOMD_DecodeFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2)):
                  #
                  iRetVal = Sepia2_Lib.SEPIA2_SOMD_SetBurstValues(iDevIdx, iSOM_Slot, wDivider, bPreSync, bMaskSync)
                  if (Sepia2FunctionSucceeds(iRetVal, "SOMD_SetBurstValues", iDevIdx, iSOM_Slot, NO_IDX_2)):
                    #
                    iRetVal = Sepia2_Lib.SEPIA2_SOMD_SetOutNSyncEnable(iDevIdx, iSOM_Slot, bOutEnable, bSyncEnable, bSyncInverse)
                    if (Sepia2FunctionSucceeds(iRetVal, "SOMD_SetOutNSyncEnable", iDevIdx, iSOM_Slot, NO_IDX_2)):
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_SOMD_SetBurstLengthArray(iDevIdx, iSOM_Slot, lBurstChannels[0], lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7])
                      Sepia2FunctionSucceeds(iRetVal, "SOMD_SetBurstLengthArray", iDevIdx, iSOM_Slot, NO_IDX_2)
                    #  end of 'SEPIA2_SOMD_SetOutNSyncEnable'
                  #  end of 'SEPIA2_SOMD_SetBurstValues'
                #  end of 'SEPIA2_SOMD_DecodeFreqTrigMode'
              #  end of 'SEPIA2_SOMD_SetFreqTrigMode'
            #  end of 'if (bIsSOMDModule)'
            #
            else :
              #
              bDivider.value = wDivider.value % 256
              #
              iRetVal = Sepia2_Lib.SEPIA2_SOM_SetFreqTrigMode(iDevIdx, iSOM_Slot, iFreqTrigIdx)
              if (Sepia2FunctionSucceeds(iRetVal, "SOM_SetFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2)):
                #
                iRetVal = Sepia2_Lib.SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSOM_Slot, iFreqTrigIdx, cFreqTrigMode)
                if (Sepia2FunctionSucceeds(iRetVal, "SOM_DecodeFreqTrigMode", iDevIdx, iSOM_Slot, NO_IDX_2)):
                  #
                  iRetVal = Sepia2_Lib.SEPIA2_SOM_SetBurstValues (iDevIdx, iSOM_Slot, bDivider, bPreSync, bMaskSync)
                  if (Sepia2FunctionSucceeds(iRetVal, "SOM_SetBurstValues", iDevIdx, iSOM_Slot, NO_IDX_2)):
                    #
                    iRetVal = Sepia2_Lib.SEPIA2_SOM_SetOutNSyncEnable (iDevIdx, iSOM_Slot, bOutEnable, bSyncEnable, bSyncInverse)
                    if (Sepia2FunctionSucceeds(iRetVal, "SOM_SetOutNSyncEnable", iDevIdx, iSOM_Slot, NO_IDX_2)):
                      #
                      iRetVal = Sepia2_Lib.SEPIA2_SOM_SetBurstLengthArray (iDevIdx, iSOM_Slot, lBurstChannels[0], lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7])
                      Sepia2FunctionSucceeds(iRetVal, "SOM_SetBurstLengthArray", iDevIdx, iSOM_Slot, NO_IDX_2)
                    #  end of 'SEPIA2_SOM_SetOutNSyncEnable'
                  #  end of 'SEPIA2_SOM_SetBurstValues'
                #  end of 'SEPIA2_SOM_DecodeFreqTrigMode'
              #  end of 'SEPIA2_SOM_SetFreqTrigMode'
            #  end of 'else' of 'if (bIsSOMDModule)'
            #
            print("%s%-4s FreqTrigMode  =      '%s'" % (STR_INDENT, cSOMType, cFreqTrigMode.value.decode("utf-8")))
            if ((bIsSOMDModule) and ((iFreqTrigIdx == Sepia2_Def.SEPIA2_SOM_TRIGMODE_RISING) or (iFreqTrigIdx == Sepia2_Def.SEPIA2_SOM_TRIGMODE_FALLING))):
              #
              print("%s%-4s ExtTrig.Sync. =        %1d" % (STR_INDENT, cSOMType, (1 if (bSynchronized) else 0)))
            #  end of 'if ((bIsSOMDModule) and ((iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_RISING) or (iFreqTrigIdx == SEPIA2_SOM_TRIGMODE_FALLING)))'
            #
            print("%s%-4s Divider       =    %5u"      % (STR_INDENT, cSOMType, wDivider.value))
            print("%s%-4s PreSync       =      %3u"    % (STR_INDENT, cSOMType, bPreSync.value))
            print("%s%-4s MaskSync      =      %3u"    % (STR_INDENT, cSOMType, bMaskSync.value))
            #
            print("%s%-4s Output Enable =     0x%2.2X" % (STR_INDENT, cSOMType, bOutEnable.value))
            print("%s%-4s Sync Enable   =     0x%2.2X" % (STR_INDENT, cSOMType, bSyncEnable.value))
            print("%s%-4s Sync Inverse  =        %s"   % (STR_INDENT, cSOMType, BoolToStr(bSyncInverse)))
            #
            print("%s%-4s BurstLength 2 = %8d"         % (STR_INDENT, cSOMType, lBurstChannels[1].value))
            print("%s%-4s BurstLength 3 = %8d"         % (STR_INDENT, cSOMType, lBurstChannels[2].value))
            print("")
            #
          #  end of 'if (bSOM_Found)'
          #
          #
          # SLM
          #
          if (bSLM_Found):
            #
            iRetVal = Sepia2_Lib.SEPIA2_SLM_SetPulseParameters(iDevIdx, iSLM_Slot, iFreq, bPulseMode)
            if (Sepia2FunctionSucceeds(iRetVal, "SLM_SetPulseParameters", iDevIdx, iSLM_Slot, NO_IDX_2)):
              #
              iRetVal = Sepia2_Lib.SEPIA2_SLM_SetIntensityFineStep(iDevIdx, iSLM_Slot, wIntensity)
              if (Sepia2FunctionSucceeds(iRetVal, "SLM_SetIntensityFineStep", iDevIdx, iSLM_Slot, NO_IDX_2)):
                #
                Sepia2_Lib.SEPIA2_SLM_DecodeFreqTrigMode(iFreq, cFreqTrigMode)
                print("%s%-4s FreqTrigMode  =      '%s'"     % (STR_INDENT, cSLMType, cFreqTrigMode.value.decode("utf-8")))
                print("%s%-4s Pulse Mode    =        %s"     % (STR_INDENT, cSLMType, BoolToStr(bPulseMode)))
                print("%s%-4s Intensity     =      %5.1f %%" % (STR_INDENT, cSLMType, 0.1 * wIntensity.value))
                print("")
              #  end of 'SEPIA2_SLM_SetIntensityFineStep'
            #  end of 'SEPIA2_SLM_SetPulseParameters'
          #  end of 'if (bSLM_Found)'
          #
          #
          # VisUV
          #
          if (bVUV_Found):
            #
            Set_VUV_VIR_Data (iDevIdx, cVUVType, iVUV_Slot, IS_A_VUV)
            #
          #  end of 'if (bVUV_Found)'
          #
          #
          # VisIR
          #
          if (bVIR_Found):
            #
            Set_VUV_VIR_Data (iDevIdx, cVIRType, iVIR_Slot, IS_A_VIR)
            #
          #  end of 'if (bVIR_Found)'
          #
          #
          # PRI
          #
          if (bPRI_Found):
            #
            # Set_PRI_Data (iDevIdx, cPRIType, iPRI_Slot)
            #
            iRetVal = Sepia2_Lib.SEPIA2_PRI_SetOperationMode (iDevIdx, iPRI_Slot, iOpModeIdx);
            if (Sepia2FunctionSucceeds(iRetVal, "PRI_SetOperationMode", iDevIdx, iPRI_Slot, NO_IDX_2)):
              #
              iRetVal = Sepia2_Lib.SEPIA2_PRI_SetWavelengthIdx(iDevIdx, iPRI_Slot, iWL_Idx);
              if (Sepia2FunctionSucceeds(iRetVal, "PRI_SetWavelengthIdx", iDevIdx, iPRI_Slot, NO_IDX_2)):
                #
                iRetVal = Sepia2_Lib.SEPIA2_PRI_SetIntensity(iDevIdx, iPRI_Slot, iWL_Idx, wIntensity);
                Sepia2FunctionSucceeds(iRetVal, "PRI_SetIntensity", iDevIdx, iPRI_Slot, iWL_Idx);
                #
              #
            #
            if (iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR):
              #
              iRetVal = Sepia2_Lib.SEPIA2_PRI_DecodeOperationMode(iDevIdx, iPRI_Slot, iOpModeIdx, cOperMode);
              if (iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR):
                print("%s%-4s OperModeIdx    =        %d  ==> '%s'" % (STR_INDENT, cPRIType, iOpModeIdx.value, cOperMode.value.strip().decode("utf-8")));
              else:
                print("%s%-4s OperModeIdx    =        %d  ==>  ??  (decoding error)" % (STR_INDENT, cPRIType, iOpModeIdx.value));
              #
              if (iRetVal == Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR):
                print("%s%-4s WavelengthIdx  =        %d  ==> %d nm" % (STR_INDENT, cPRIType, iWL_Idx.value, PRI_Const.PrimaWLs[iWL_Idx.value]));
              #
              print(  "%s%-4s Intensity      =      %5.1f %%" % (STR_INDENT, cPRIType, 0.1 * wIntensity.value));
              #
            #
            else:
              print("%s%-4s OperModeIdx    =       ??  (reading error)" % (STR_INDENT, cPRIType));
              print("%s%-4s WavelengthIdx  =       ??  (reading error)" % (STR_INDENT, cPRIType));
              print("%s%-4s Intensity      =       ??  (reading error)" % (STR_INDENT, cPRIType));
              #
            #
            print("");
          #  end of 'if (bPRI_Found)'
          #
        #  end of 'if (not HasFWError(...))'
      # end of 'SEPIA2_FWR_GetLastError'
      #
    else:
      #  'SEPIA2_FWR_GetModuleMap' did not succeed!
      #
      iRetVal = Sepia2_Lib.SEPIA2_FWR_GetLastError (iDevIdx, byref(iFWErrCode), byref(iFWErrPhase), byref(iFWErrLocation), byref(iFWErrSlot), cFWErrCond)
      if (Sepia2FunctionSucceeds(iRetVal, "FWR_GetLastError", iDevIdx, NO_IDX_1, NO_IDX_2)):
        #
        HasFWError (iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond, "Firmware error detected:")
        #
      #  end of 'SEPIA2_FWR_GetLastError'
    #  end of 'else' of 'SEPIA2_FWR_GetModuleMap'
    #
    Sepia2_Lib.SEPIA2_FWR_FreeModuleMap (iDevIdx)
    Sepia2_Lib.SEPIA2_USB_CloseDevice   (iDevIdx)
    #
  #  end of 'SEPIA2_USB_OpenDevice'
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
