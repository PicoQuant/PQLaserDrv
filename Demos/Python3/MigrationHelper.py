#-----------------------------------------------------------------------------
#
#      MigrationHelper
#
#-----------------------------------------------------------------------------
#
#  Helper Functions for Migration from C/C++ - Demos to Python
#
#  Consider, this code is for demonstration purposes only.
#  Don't use it in productive environments!
#
#-----------------------------------------------------------------------------


#import Sepia2_Def
import Sepia2_Def
import Sepia2_ErrorCodes
from Sepia2_Lib import Sepia2_Lib
#
#import sys
#import struct
import ctypes as ct
#from ctypes import byref

import math

NO_DEVIDX = -1;
NO_IDX_1 = -99999;
NO_IDX_2 = -97979;
#
#
def Sepia2FunctionSucceeds(iRet, FunctName, iDev, iIdx1, iIdx2):
  #bool Sepia2FunctionSucceeds (int iRet, char* FunctName, int iDev, int iIdx1, int iIdx2)
  #
  cErrTxt = ct.create_string_buffer(Sepia2_Def.SEPIA2_ERRSTRING_LEN + 1)
  STR_INDENT = "   "
  #
  if (iRet != Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR):
    #
    print("")
    Sepia2_Lib.SEPIA2_LIB_DecodeError(iRet, cErrTxt)
    #
    if (isinstance(iIdx1, (ct.c_int, ct.c_byte))):
      iIdx1 = iIdx1.value
    #
    if (isinstance(iIdx2, (ct.c_int, ct.c_byte))):
      iIdx2 = iIdx2.value
    #
    if (iIdx1 == NO_IDX_1):
      print("%sERROR: SEPIA2_%s (%1d) returns %5d:" % (STR_INDENT, FunctName, iDev, iRet))
    else:
      if (iIdx2 == NO_IDX_2):
        print("%sERROR: SEPIA2_%s (%1d, %03d) returns %5d:" % (STR_INDENT, FunctName, iDev, iIdx1, iRet))
      else:
        print("%sERROR: SEPIA2_%s (%1d, %03d, %d) returns %5d:" % (STR_INDENT, FunctName, iDev, iIdx1, iIdx2, iRet))
    #
    print("%s     i. e. '%s'" % (STR_INDENT, cErrTxt.value.decode("utf-8")))
    print("")
    #
    return False
    #
  else:
    #
    return True
#
#
def atof(text):
  #float atof(string text)
  #this functions is necessary because 'locale.atof' does not accept non-numbers in 'text'...
  textFloat = text.strip()
  f = 0.0
  i = 0
  len_text = len(textFloat)
  fract = 10
  b4numbr = True
  b4comma = True
  isDec = True
  negative = False
  #
  while (i < len_text):
    #
    c = textFloat[i]
    i += 1
    #
    if (c == ' '):
      #
      if ((f != 0.0) or not b4numbr):
        #
        #print("error: unexpected whitespace character")
        break
        #
      #
    #  end of 'if (c == ' ')'
    elif (c == '-'):
      #
      if ((f == 0.0) and b4comma):
        #
        negative = not negative
      else:
        #
        print("error: unexpected negative sign")
      #
    #  end of 'elif (c == '-')'
    elif (c == '+'):
      #
      if ((f != 0.0) or not b4comma):
        #
        print("error: unexpected plus sign")
        #
      #
    #  end of 'elif (c == '+')'
    elif (c == '.' or c == ','):
      #
      if (isDec):
        #
        if (b4comma):
          #
          b4comma = False
        else:
          #
          print("error: multiple decimal separators not allowed")
        #
      else:
        #
        print("error: decimal separator not allowed in hex representation")
      #
    #  end of 'elif (c == '.' or c == ',')'
    elif (c.upper() == 'X'):
      #
      if (b4comma and isDec and (f == 0.0)):
        #Hexadecimal!
        isDec = False
        fract = 16
      else:
        #
        print("error: unexpected hex descriptor")
      #
    #  end of 'elif (c.upper() == 'X')'
    elif (c >= '0' and c <= '9'):
      #
      if (b4comma or not isDec):
        #
        f = f * fract + (ord(c) - ord('0'))
        #
      else:
        #
        f += (ord(c) - ord('0')) / fract
        fract *= 10
        #
      #
    #  end of 'elif (c >= '0' and c <= '9')'
    elif (not isDec and (c.upper() >= 'A') and (c.upper() <= 'F')):
      #
      f = f * fract + (ord(c.upper()) - ord('A') + 10)
      #
    #  end of 'elif (not isDec and (c.upper() >= 'A') and (c.upper() <= 'F'))'
    else:
      #
      break
      #
    #  end of 'else'
  #  end of 'while (i < len)'
  #
  if (negative):
    #
    return -f
  else:
    #
    return +f
  #
  # test environment:
  #
  #fStr = ["    0.32189 ",  #  =>      0.32189 \
  #      "   -0.32189 ",  #  =>     -0.32189 \
  #      "-+000.32189 ",  #  =>     -0.32189 \
  #      "+-000,32189 ",  #  =>     -0.32189 \
  #      "--000.32189 ",  #  =>      0.32189 \
  #      "-   0.321895",  #  =>     -0.32190 \
  #      " + 00.321894",  #  =>      0.32189 \
  #      "+1000,-32189",  # "error: unexpected negative sign" \
  #      "-10+0,321890",  # "error: unexpected plus sign" \
  #      "+1000,321890",  #  =>  1,000.32200 \
  #      "0xF1d2",        #  => 61,906.00000 \
  #      "0x41d2",        #  => 16,850.00000 \
  #      "0x3-1D2",       # "error: unexpected negative sign" \
  #      "0x-21D2",       #  => -8,658.00000 \
  #      "0-x11D2",       #  => -4,562.00000 \
  #      "-0x01D2",       #  =>   -466.00000 \
  #      "-0,3xF1D2"      # "error: unexpected hex descriptor"
  #      ]
  #
  #for fStrI in fStr:
  #
  #print(" \"%15s\" => " % fStrI, end = "")
  #f = ReadAllDataByPython.atof(fStrI)
  #print(f)
  #
#
#
def GetValStr(f, pattern):
  #string GetValStr(FileStream f, string pattern)
  #
  # in C/C++, this function was mainly covered by fscanf
  #
  f.seek(0)
  line = f.readline()
  while (len(line) > 0):
    #
    if (line.startswith(pattern)):
      #
      return line[len(pattern):]
    #
    line = f.readline()
    #
  #
  return ""
#
#
def BoolToStr(X):
  ##define BoolToStr(X)        ((X)?"True":"False")
  #
  if (isinstance(X, (ct.c_int, ct.c_byte))):
    X = X.value != 0
  #
  if (X):
    return "True"
  else:
    return "False"
  #
#
#
def StrToBool(s):
  #bool StrToBool(string s)
  #
  if (len(s) < 1):
    return False
  #
  c = s.strip().upper()[0]
  return (c == 'T')
#
#
def StrToInt(s):
  #int StrToInt(string s)
  #
  if (len(s) < 1):
    return 0
  #
  s = s.strip()
  index = s.find(' ')
  if(index > 0):
    s = s[:index]
  #
  return int(atof(s))
#
#
def StrToFloat(s):
  #float StrToFloat(string s)
  return 1.0 * StrToInt(s)
#
#
def EnsureRange(X, L, H):
  ##define EnsureRange(X,L,H)  (((X)>(H))?(H):(((X)<(L))?(L):(X)))
  #
  if (X > H):
    #
    return H
  elif(X < L):
    #
    return L
  else:
    #
    return X
  #
#
#
def IntToBin (iValue, iDigits, bLowToHigh, cOnChar = '1', cOffChar = '0'):
  #char* IntToBin (int iValue, int iDigits, unsigned char bLowToHigh, char cOnChar = '1', char cOffChar = '0')
  cDest = ""
  if (bLowToHigh):
    iRange = range(0, min(max(1, abs(iDigits)), 32))
  else:
    iRange = range(min(max(1, abs(iDigits)), 32), 0, -1)
  #
  if (isinstance(iValue, (ct.c_int, ct.c_byte))):
    iValue = iValue.value
  #
  for i in iRange:
    #
    cDest += cOnChar if ((iValue & (1 << i)) != 0) else cOffChar
    #
  #
  return cDest
#
#
def FormatEng (fInp, iMant, cUnit = "", iFixedSpace = -1, iFixedDigits = -1, bUnitSep = 1):
  #char* FormatEng (double fInp, int iMant, char* cUnit = "", int iFixedSpace = -1, int iFixedDigits = -1, unsigned char bUnitSep = 1)
  #
  cDest = ""
  #
  if (fInp == 0):
    iTemp  = 0
    fNorm  = 0
  else:
    fTemp0 = math.log(abs(fInp)) / math.log(1000.0)
    iTemp  = math.floor(fTemp0)
    if ((fTemp0 > 0) or ((fTemp0 - iTemp) == 0)):
      fNorm  = pow (1000.0, math.fmod(fTemp0, 1.0) + 0)
    else:
      fNorm  = pow (1000.0, math.fmod(fTemp0, 1.0) + 1)
    #
  #
  i = iMant -1
  if (fNorm >=  10):
    i -= 1
  #
  if (fNorm >= 100):
    i -= 1
  #
  if (iFixedDigits < 0):
    num_spec = "%." + str(i) + "f"
  else:
    num_spec = "%." + str(iFixedDigits) + "f"
  #
  if (fInp < 0):
    fNorm *= -1
  #
  cDest += num_spec % fNorm
  #
  if (bUnitSep):
    cDest += " "
  #
  cDest += ((Sepia2_Def.PRAEFIXES[iTemp + Sepia2_Def.PRAEFIX_OFFSET]) if (bUnitSep or (iTemp != 0)) else "")
  cDest += cUnit
  #
  while len(cDest) < iFixedSpace:
    cDest = " " + cDest
  #
  return cDest
#


class T_PRI_Constants(ct.Structure):
    _fields_ = [("bInitialized", ct.c_bool),
                #
                ("PrimaModuleID",   ct.c_char * (Sepia2_Def.SEPIA2_PRI_DEVICE_ID_LEN + 1)),
                ("PrimaModuleType", ct.c_char * (Sepia2_Def.SEPIA2_PRI_DEVTYPE_LEN + 1)),
                ("PrimaFWVers",     ct.c_char * (Sepia2_Def.SEPIA2_PRI_DEVICE_FW_LEN + 1)),
                #
                ("PrimaTemp_min", ct.c_float),
                ("PrimaTemp_max", ct.c_float),
                #
                #  'til here      init with 0x00
                # --- - - - - - - - - - - -----  initializing border
                # from here      init with 0xFF
                #
                ("PrimaUSBIdx", ct.c_int),
                ("PrimaSlotId", ct.c_int),
                #
                ("PrimaWLCount", ct.c_int),
                ("PrimaWLs", ct.c_int * 3),
                #
                ("PrimaOpModCount", ct.c_int),
                ("PrimaOpModOff", ct.c_int),
                ("PrimaOpModNarrow", ct.c_int),
                ("PrimaOpModBroad", ct.c_int),
                ("PrimaOpModCW", ct.c_int),
                #
                ("PrimaTrSrcCount", ct.c_int),
                ("PrimaTrSrcInt", ct.c_int),
                ("PrimaTrSrcExtNIM", ct.c_int),
                ("PrimaTrSrcExtTTL", ct.c_int),
                ("PrimaTrSrcExtFalling", ct.c_int),
                ("PrimaTrSrcExtRising", ct.c_int)]
    #
    def __init__(self):
      self.bInitialized = False;
      #
      self.PrimaModuleID = (b"");
      self.PrimaModuleType = (b"");
      self.PrimaFWVers =  (b"");
      #
      self.PrimaTemp_min = 0.0;
      self.PrimaTemp_max = 0.0;
      #
      self.PrimaUSBIdx = -1;
      self.PrimaSlotId = -1;
      #
      self.PrimaWLCount = -1;
      self.PrimaWLs = (-1, -1, -1);
      self.PrimaOpModCount = -1;
      self.PrimaOpModOff   = -1;
      self.PrimaOpModNarrow = -1;
      self.PrimaOpModBroad = -1;
      self.PrimaOpModCW = -1;
      self.PrimaTrSrcCount = -1;
      self.PrimaTrSrcInt = -1;
      self.PrimaTrSrcExtNIM = -1;
      self.PrimaTrSrcExtTTL = -1;
      self.PrimaTrSrcExtFalling = -1;
      self.PrimaTrSrcExtRising = -1;
    #
    def PRI_GetConstants(self, USBIdx: int, SlotID: int):
      #
      #
      Ret = Sepia2_ErrorCodes.SEPIA2_ERR_NO_ERROR
      Idx = ct.c_int(-1)
      #
      cDevID = ct.create_string_buffer(Sepia2_Def.SEPIA2_PRI_DEVICE_ID_LEN)
      cDevType = ct.create_string_buffer(Sepia2_Def.SEPIA2_PRI_DEVTYPE_LEN)
      cDevFWVers = ct.create_string_buffer(Sepia2_Def.SEPIA2_PRI_DEVICE_FW_LEN)
      #
      iWL_Count = ct.c_int(-1)
      iWL = ct.c_int(-1)
      #
      iOM_Count = ct.c_int(-1)
      OpMod = ct.create_string_buffer(Sepia2_Def.SEPIA2_PRI_OPERMODE_LEN)
      #
      iTS_Count = ct.c_int(-1)
      TrSrc = ct.create_string_buffer(Sepia2_Def.SEPIA2_PRI_TRIGSRC_LEN)
      bDummy1 = ct.c_byte(0)
      bDummy2 = ct.c_byte(0)
      #
      if (self):
        #
        self.bInitialized = False
        #
        #print("innen 1: DevIdx = %d, SlotId = %03d" % (self.PrimaUSBIdx, self.PrimaSlotId))
        #
        self.PrimaUSBIdx   = USBIdx
        self.PrimaSlotId   = SlotID
        #
        self.PrimaTemp_min = 15.0; # [°C]
        self.PrimaTemp_max = 42.0; # [°C]
        #
        #print("innen 2: DevIdx = %d, SlotId = %03d" % (self.PrimaUSBIdx, self.PrimaSlotId))
        #
        Ret = Sepia2_Lib.SEPIA2_PRI_GetDeviceInfo(USBIdx, SlotID, cDevID, cDevType, cDevFWVers, ct.byref(iWL_Count))
        if (Sepia2FunctionSucceeds(Ret, "SEPIA2_PRI_GetDeviceInfo", USBIdx, SlotID, NO_IDX_2)):
          #
          self.PrimaModuleID = cDevID.value.strip().decode("utf-8").encode();
          self.PrimaModuleType = cDevType.value.strip().decode("utf-8").encode();
          self.PrimaFWVers = cDevFWVers.value.strip().decode("utf-8").encode();
          self.PrimaWLCount = iWL_Count.value;
          #
          #print("cDevType  = '%s';  PRI_Type = '%s', WLs = %d" % ((cDevType.value.strip().decode("utf-8")), (self.PrimaModuleType.decode("utf-8")), self.PrimaWLCount));  # .encode().strip().decode("utf-8")
          #
          for Idx in range(0, self.PrimaWLCount):
            Ret = Sepia2_Lib.SEPIA2_PRI_DecodeWavelength(USBIdx, SlotID, Idx, ct.byref(iWL));
            if (Sepia2FunctionSucceeds(Ret, "PRI_DecodeWavelength", USBIdx, SlotID, Idx)):
              self.PrimaWLs[Idx] = iWL;
              #
              #cTemp1 = ("wavelength [%1d] " % Idx);
              #print("%47s  =  %4dnm" % (cTemp1, iWL.value));
              #
            #  end of if Sepia2FunctionSucceeds(iRetVal, "PRI_DecodeWavelength",...
          #  end of for iWL_Count
          #
          #  now we calculate the amount of operation modes for this indiviual PRI module
          #
          iOM_Count = 7;  # is definitely greater
          while ((iOM_Count > 0) and (0 > Sepia2_Lib.SEPIA2_PRI_DecodeOperationMode(USBIdx, SlotID, iOM_Count - 1, OpMod))):
            iOM_Count -= 1;
          #
          self.PrimaOpModCount = iOM_Count;
          #
          for Idx in range(0, self.PrimaOpModCount):
            Ret = Sepia2_Lib.SEPIA2_PRI_DecodeOperationMode(USBIdx, SlotID, Idx, OpMod);
            if (Sepia2FunctionSucceeds(Ret, "PRI_DecodeOperationMode", USBIdx, SlotID, Idx)):
              cOpMod = OpMod.value.strip().lower().decode("utf-8");
              #
              if ("off" in cOpMod):
                self.PrimaOpModOff = Idx;
              elif ("narrow" in cOpMod):
                self.PrimaOpModNarrow = Idx;
              elif ("broad" in cOpMod):
                self.PrimaOpModBroad = Idx;
              elif ("cw" in cOpMod):
                self.PrimaOpModCW = Idx;
              #
            # if (Sepia2FunctionSucceeds(Ret, "PRI_DecodeOperationMode", ...
          # for Operation Modes
          #
          #  now we calculate the amount of trigger sources for this indiviual PRI module
          #
          iTS_Count = 7;  # is definitely greater
          while ((iTS_Count > 0) and (0 > Sepia2_Lib.SEPIA2_PRI_DecodeTriggerSource(USBIdx, SlotID, iTS_Count - 1,
                                                                                    TrSrc, ct.byref(bDummy1), ct.byref(bDummy2)))):
            iTS_Count -= 1;
          #
          self.PrimaTrSrcCount = iTS_Count;
          #
          #
          for Idx in range(0, self.PrimaTrSrcCount):
            Ret = Sepia2_Lib.SEPIA2_PRI_DecodeTriggerSource(USBIdx, SlotID, Idx, TrSrc, ct.byref(bDummy1), ct.byref(bDummy2));
            if (Sepia2FunctionSucceeds(Ret, "PRI_DecodeTriggerSource", USBIdx, SlotID, Idx)):
              cTrSrc = TrSrc.value.strip().lower().decode("utf-8");
              #
              if ("ext" in cTrSrc):
                #
                if ("nim" in cTrSrc):
                  self.PrimaTrSrcExtNIM = Idx;
                elif ("ttl" in cTrSrc):
                  self.PrimaTrSrcExtTTL = Idx;
                elif ("fal" in cTrSrc):
                  self.PrimaTrSrcExtFalling = Idx;
                elif ("ris" in cTrSrc):
                  self.PrimaTrSrcExtRising = Idx;
                #
              elif ("int" in cTrSrc):
                self.PrimaTrSrcInt = Idx;
              #
            # if (Sepia2FunctionSucceeds(Ret, "PRI_DecodeTriggerSource", ...
          # for Tigger Sources
        # if (Sepia2FunctionSucceeds(Ret, "SEPIA2_PRI_GetDeviceInfo", ...
      # if (self)
      else:
        Ret = Sepia2_ErrorCodes.SEPIA2_ERR_LIB_ILLEGAL_PARAMETER_ON_FUNCTION_CALL
        return Ret
        exit(-2)
      #
      return Ret
