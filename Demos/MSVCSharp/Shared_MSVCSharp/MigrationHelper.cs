//-----------------------------------------------------------------------------
//
//      MigrationHelper
//
//-----------------------------------------------------------------------------
//
//  Helper Functions for Migration from C/C++ - Demos to C#
//
//  Consider, this code is for demonstration purposes only.
//  Don't use it in productive environments!
//
//-----------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Text;

namespace PQ.Sepia2
{
  public static partial class MigrationHelper
  {
    public const int NO_DEVIDX =    -1;
    public const int NO_IDX_1 = -99999;
    public const int NO_IDX_2 = -97979;
    public static int __min(int x, int y) { if (x < y) return x; else return y; }

    public static int __max(int x, int y) { if (x < y) return y; else return x; }

    public static int abs(int x) { if (x < 0) return -x; else return x; }

    public static double fmod(double number, double denom) { return number % denom; }

    public static double log(double number) { return Math.Log(number); }

    public static double floor(double number) { return Math.Floor(number); }

    public static double pow(double number, double exp) { return Math.Pow(number, exp); }

    public static double fabs(double number) { if (number < 0) return -number; else return number; }

    public static bool signbit(double d) { return d < 0; }

    public static float atof(string text)
    {
      if (text == null)
        return 0f;
      //
      string textFloat = text.Trim();
      double f = 0f;
      int i = 0;
      int len = textFloat.Length;
      double fract = 10;
      bool b4numbr = true;
      bool b4comma = true;
      bool isDec = true;
      bool negative = false;
      //
      char c;
      //
      while (i < len)
      {
        c = textFloat[i++];
        //
        if (Char.IsWhiteSpace(c))
        {
          if ((f != 0f) || !b4numbr)
          {
            //throw new Exception("error: unexpected whitespace character");
            break;
          }
        }
        else if (c == '-')
        {
          if ((f == 0f) && b4comma)
            negative = !negative;
          else
            throw new Exception("error: unexpected negative sign");
        }
        else if (c == '+')
        {
          if ((f != 0f) || !b4comma)
            throw new Exception("error: unexpected plus sign");
        }
        else if (c == '.' || c == ',')
        {
          if (isDec)
            if (b4comma)
              b4comma = false;
            else
              throw new Exception("error: multiple decimal separators not allowed");
          else
            throw new Exception("error: decimal separator not allowed in hex representation");
        }
        else if (Char.ToUpper(c) == 'X')
        {
          if (b4comma && isDec && (f == 0f))
          {
            //Hexadecimal!
            isDec = false;
            fract = 16;
          }
          else
            throw new Exception("error: unexpected hex descriptor");
        }
        else if (Char.IsDigit(c))
        {
          if (b4comma || !isDec)
          {
            f = f * fract + (c - '0');
          }
          else
          {
            f += (c - '0') / fract;
            fract *= 10;
          }
        }
        else if (!isDec && (Char.ToUpper(c) >= 'A') && (Char.ToUpper(c) <= 'F'))
        {
          f = f * fract + (Char.ToUpper(c) - 'A' + 10);
        }
        else
        {
          break;
        }
      }
      //
      if (negative)
        return -(float)f;
      else
        return +(float)f;
      //
      //
      /*
        //
        // test environment:
        //
        int i = 0;
        string[] f = new string[] { "    0.32189 "  //  =>      0.32189
                                  , "   -0.32189 "  //  =>     -0.32189
                                  , "-+000.32189 "  //  =>     -0.32189
                                  , "+-000,32189 "  //  =>     -0.32189
                                  , "--000.32189 "  //  =>      0.32189
                                  , "-   0.321895"  //  =>     -0.32190
                                  , " + 00.321894"  //  =>      0.32189
                                //, "+1000,-32189"  // "error: unexpected negative sign"
                                //, "-10+0,321890"  // "error: unexpected plus sign"
                                  , "+1000,321890"  //  =>  1,000.32200
                                  , "0xF1d2"        //  => 61,906.00000
                                  , "0x41d2"        //  => 16,850.00000
                                //, "0x3-1D2"       // "error: unexpected negative sign"
                                  , "0x-21D2"       //  => -8,658.00000
                                  , "0-x11D2"       //  => -4,562.00000
                                  , "-0x01D2"       //  =>   -466.00000
                                //, "-0,3xF1D2"     // "error: unexpected hex descriptor"
                                  };
        //
        for (i = 0; i < f.Length; i++)
        {
          Console.WriteLine(" \"{0,15}\" => {1,12:N5}", f[i], MigrationHelper.atof(f[i]));
        }
        //
        Console.ReadLine();
        //
      */
    }

    public static string GetValStr(System.IO.FileStream f, string pattern)
    {
      //
      // in C/C++, this function was mainly covered by fscanf
      //
      if (f == null || pattern == null)
        return null;
      //
      string line;
      f.Position = 0;
      System.IO.StreamReader sr = new System.IO.StreamReader(f);
      string ret = null;
      while ((line = sr.ReadLine()) != null)
      {
        if (line.StartsWith(pattern))
        {
          ret = line.Substring(pattern.Length);
          break;
        }
      }
      //Do not dispose 'f' !
      return ret;
    }

    public static string BoolToStr(bool b) { if (b) return "True"; else return "False"; }

    public static bool StrToBool(string s)
    {
      Char c = ' ';
      int i = s.IndexOf("=");
      //
      if (i >= 0)
        s = s.Substring(i + 1);
      s = s.Trim();
      if (s.Length > 0)
        c = Char.ToUpper(s[0]);
      //
      return (c == 'T');
    }

    public static int StrToInt(string s)
    {
      //Console.WriteLine("StrToInt: " + s);
      int i = s.IndexOf("=");
      if (i >= 0)
        s = s.Substring(i + 1);
      //
      return (int)(atof(s));
    }

    public static float StrToFloat(string s)
    {
      int i = s.IndexOf("=");
      if (i >= 0)
        s = s.Substring(i + 1);
      //
      return atof(s);
    }

    public static int EnsureRange(int X, int L, int H)
    {
      if (X > H)
      {
        return H;
      }
      else
      {
        if (X < L)
          return L;
        else
          return X;
      }
    }

    public static StringBuilder IntToBin(StringBuilder cDest, int iValue, int iDigits, bool bLowToHigh, char cOnChar, char cOffChar)       //char cOnChar = '1', char cOffChar = '0'
    {
      if (cOnChar < 1)
        cOnChar = '1';
      if (cOffChar < 1)
        cOffChar = '0';
      //
      int i;
      int iTo = __min(__max(1, abs(iDigits)), 32);
      //
      if (cDest == null)
        cDest = new StringBuilder(iTo);
      //
      if (bLowToHigh)
      {
        for (i = 0; i < iTo; i++)
        {
          cDest.Append(((iValue & (1 << i)) != 0) ? cOnChar : cOffChar);
        }
      }
      else
      {
        //reverse order
        int iStart = cDest.Length;
        for (i = 0; i < iTo; i++)
        {
          cDest.Insert(iStart, (((iValue & (1 << i)) != 0) ? cOnChar : cOffChar));
        }
      }
      //
      return cDest;
    }

    public static StringBuilder trim(StringBuilder cDest, string ptrIn)
    {
      cDest.Clear();
      cDest.Append(ptrIn.Trim());
      //
      return cDest;
    }


    private const string PRAEFIXES = "yzafpnµm kMGTPEZY";
    private const int PRAEFIX_OFFSET = 8;

    public static StringBuilder FormatEng(StringBuilder cDest, double fInp, int iMant, string cUnit, int iFixedSpace, int iFixedDigits, bool bUnitSep)
    {
      // totally re-implemented by DSC in C# on base of the C/C++ - Democode...
      //
      int i;
      bool bNSign;
      double fNorm;
      double fTemp0;
      int iTemp;
      //
      cDest.Length = 0;
      //
      bNSign = (fInp < 0);
      if (fInp == 0)
      {
        iTemp = 0;
        fNorm = 0;
      }
      else
      {
        fTemp0 = log(fabs(fInp)) / log(1000.0);
        iTemp = (int)floor(fTemp0);
        fNorm = pow((double)1000.0, fmod(fTemp0, 1.0) + ((fTemp0 > 0) || ((fTemp0 - iTemp) == 0) ? 0 : 1));
      }
      //
      i = iMant - 1;
      if (fNorm >= 10)
      {
        i -= 1;
      }
      if (fNorm >= 100)
      {
        i -= 1;
      }
      //
      string num_spec = String.Format("F{0}", iFixedDigits < 0 ? i : iFixedDigits);       //How many digits after comma
      cDest.Append((fNorm * (bNSign ? -1.0 : 1.0)).ToString(num_spec));                   //format the value in desired format
      if (bUnitSep)
      {
        cDest.Append(" ");                                                                //Space between value and unit
      }
      if (bUnitSep || (iTemp != 0))
      {
        cDest.Append(PRAEFIXES[iTemp + PRAEFIX_OFFSET]);                                  //SI-prefix
      }
      cDest.Append(cUnit);                                                                //unit
                                                                                          //                                                                                  //
      if (iFixedSpace > cDest.Length)
      {
        i = iFixedSpace - cDest.Length;
        while (i-- > 0)
        {
          cDest.Insert(0, " ");
        }
      }
      //
      return cDest;
    }


    public static bool Sepia2FunctionSucceeds(int iRet, string FunctName, int iDev, int iIdx1, int iIdx2)
    {
      StringBuilder cErrTxt = new StringBuilder(Sepia2_Lib.SEPIA2_ERRSTRING_LEN + 1);
      //
      bool bRet = (iRet == Sepia2_Lib.SEPIA2_ERR_NO_ERROR);
      //
      if (!bRet)
      {
        Console.WriteLine ("");
        Sepia2_Lib.SEPIA2_LIB_DecodeError(iRet, cErrTxt);
        if (iIdx1 == NO_IDX_1)
        {
          Console.WriteLine ("     ERROR: SEPIA2_{0} ({1}) returns {2,5}:", FunctName, iDev, iRet);
        }
        else if (iIdx2 == NO_IDX_2)
        {
          Console.WriteLine("     ERROR: SEPIA2_{0} ({1}, {2,3}) returns {3,5}:", FunctName, iDev, iIdx1, iRet);
        }
        else
        {
          Console.WriteLine("     ERROR: SEPIA2_{0} ({1}, {2,3}, {4,3}) returns {4,5}:", FunctName, iDev, iIdx1, iIdx2, iRet);
        }
        Console.WriteLine ("            i. e. '{0}'", cErrTxt);
        Console.WriteLine ("");
      }
      //
      return bRet;
    }

    public class T_PRI_Constants
    {
      public bool bInitialized;
      //
      //                                             SEPIA2_PRI_OPERMODE_LEN
      //                                             SEPIA2_PRI_TRIGSRC_LEN
      public StringBuilder PrimaModuleID = new StringBuilder("", Sepia2_Lib.SEPIA2_PRI_DEVICE_ID_LEN + 1);
      public StringBuilder PrimaModuleType = new StringBuilder("", Sepia2_Lib.SEPIA2_PRI_DEVTYPE_LEN + 1);
      public StringBuilder PrimaFWVers = new StringBuilder("", Sepia2_Lib.SEPIA2_PRI_DEVICE_FW_LEN + 1);
      //
      public float PrimaTemp_min = 0.0F;
      public float PrimaTemp_max = 0.0F;
      //
      // 'til here      init with 0x00
      // --- - - - - - - - - - - -----  initializing border
      // from here      init with 0xFF
      //
      //
      public int PrimaUSBIdx = -1;
      public int PrimaSlotId = -1;
      //
      public int PrimaWLCount = -1;
      public int[] PrimaWLs = new int[3] { -1, -1, -1 };
      //
      public int PrimaOpModCount = -1;
      public int PrimaOpModOff = -1;
      public int PrimaOpModNarrow = -1;
      public int PrimaOpModBroad = -1;
      public int PrimaOpModCW = -1;
      //
      public int PrimaTrSrcCount = -1;
      public int PrimaTrSrcInt = -1;
      public int PrimaTrSrcExtNIM = -1;
      public int PrimaTrSrcExtTTL = -1;
      public int PrimaTrSrcExtFalling = -1;
      public int PrimaTrSrcExtRising = -1;
      //
      public T_PRI_Constants(int iDevIdx, int iSlotId)
      {
        // this constructor is an equivalent to SEPIA2_PRI_GetConstants in Delphi or C/C++
        //
        int Ret;
        int Idx;
        StringBuilder OpMod = new StringBuilder(Sepia2_Lib.SEPIA2_PRI_OPERMODE_LEN + 1);
        StringBuilder TrSrc = new StringBuilder(Sepia2_Lib.SEPIA2_PRI_TRIGSRC_LEN + 1);
        byte bDummy1;
        byte bDummy2;
        //
        //
        PrimaUSBIdx = iDevIdx;
        PrimaSlotId = iSlotId;
        //
        PrimaTemp_min = 15.0F; // [°C]
        PrimaTemp_max = 42.0F; // [°C]
        //
        Ret = Sepia2_Lib.SEPIA2_PRI_GetDeviceInfo(iDevIdx, iSlotId, PrimaModuleID, PrimaModuleType, PrimaFWVers, out PrimaWLCount);
        if (Ret == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
        {
          trim(PrimaModuleID,   PrimaModuleID.ToString());
          trim(PrimaModuleType, PrimaModuleType.ToString());
          trim(PrimaFWVers,     PrimaFWVers.ToString());
          //
          for (Idx = 0; (Ret == Sepia2_Lib.SEPIA2_ERR_NO_ERROR) && (Idx < PrimaWLCount); Idx++)
          {
            Ret = Sepia2_Lib.SEPIA2_PRI_DecodeWavelength(iDevIdx, iSlotId, Idx, out PrimaWLs[Idx]);
          } // for WL_Idx

          //
          // Count Operation Modes
          //
          for (Idx = 7; (Ret == Sepia2_Lib.SEPIA2_ERR_NO_ERROR) && (Idx > 0); Idx--) // 7 is definitely bigger!
          {
            Ret = Sepia2_Lib.SEPIA2_PRI_DecodeOperationMode(iDevIdx, iSlotId, Idx, OpMod);
            //
            if (Ret == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
            {
              PrimaOpModCount = Idx + 1;
              break;
            }
            else if (Ret == Sepia2_Lib.SEPIA2_ERR_PRI_ILLEGAL_OPERATION_MODE_INDEX)
            {
              Ret = Sepia2_Lib.SEPIA2_ERR_NO_ERROR;
            }
          } // for Idx > PrimaOpModCount
          //
          for (Idx = 0; (Ret == Sepia2_Lib.SEPIA2_ERR_NO_ERROR) && (Idx < PrimaOpModCount); Idx++)
          {
            Ret = Sepia2_Lib.SEPIA2_PRI_DecodeOperationMode(iDevIdx, iSlotId, Idx, OpMod);
            //
            if (Ret == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
            {
              if (OpMod.ToString().ToLower().Contains("off"))
              {
                PrimaOpModOff = Idx;
              }
              else if (OpMod.ToString().ToLower().Contains("narrow"))
              {
                PrimaOpModNarrow = Idx;
              }
              else if (OpMod.ToString().ToLower().Contains("broad"))
              {
                PrimaOpModBroad = Idx;
              }
              else if (OpMod.ToString().ToLower().Contains("cw"))
              {
                PrimaOpModCW = Idx;
              }
            }
          } // for OpModes

          //
          // Count Trigger Sources
          //
          for (Idx = 7; (Ret == Sepia2_Lib.SEPIA2_ERR_NO_ERROR) && (Idx > 0); Idx--) // 7 is definitely bigger!
          {
            Ret = Sepia2_Lib.SEPIA2_PRI_DecodeTriggerSource(iDevIdx, iSlotId, Idx, TrSrc, out bDummy1, out bDummy2);
            //
            if (Ret == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
            {
              PrimaTrSrcCount = Idx + 1;
              break;
            }
            else if (Ret == Sepia2_Lib.SEPIA2_ERR_PRI_ILLEGAL_TRIGGER_SOURCE_INDEX)
            {
              Ret = Sepia2_Lib.SEPIA2_ERR_NO_ERROR;
            }
          } // for Idx > PrimaTrSrcCount
          //
          //
          for (Idx = 0; (Ret == Sepia2_Lib.SEPIA2_ERR_NO_ERROR) && (Idx < PrimaTrSrcCount); Idx++)
          {
            Ret = Sepia2_Lib.SEPIA2_PRI_DecodeTriggerSource(iDevIdx, iSlotId, Idx, TrSrc, out bDummy1, out bDummy2);
            //
            if (Ret == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
            {
              if (TrSrc.ToString().ToLower().Contains("ext"))
              {
                if (TrSrc.ToString().ToLower().Contains("nim"))
                {
                  PrimaTrSrcExtNIM = Idx;
                }
                else if (TrSrc.ToString().ToLower().Contains("ttl"))
                {
                  PrimaTrSrcExtTTL = Idx;
                }
                else if (TrSrc.ToString().ToLower().Contains("fal"))
                {
                  PrimaTrSrcExtFalling = Idx;
                }
                else if (TrSrc.ToString().ToLower().Contains("ris"))
                {
                  PrimaTrSrcExtRising = Idx;
                }
              }
              else if (TrSrc.ToString().ToLower().Contains("int"))
              {
                PrimaTrSrcInt = Idx;
              }
            }
          }
        } // PRI_GetDeviceInfo
        if (Ret == Sepia2_Lib.SEPIA2_ERR_NO_ERROR)
        {
          bInitialized = true;
        }
      } // constructor T_PRI_Constants(int iDevIdx, int iSlotId);
    } // class T_PRI_Constants
  }
}

