//-----------------------------------------------------------------------------
//
//      ReadAllDataByDelphi
//
//-----------------------------------------------------------------------------
//
//  Illustrates the functions exported by SEPIA2_Lib
//  Scans the whole Sepia II rack and displays all relevant data
//
//  Consider, this code is for demonstration purposes only.
//  Don't use it in productive environments!
//
//-----------------------------------------------------------------------------
//  HISTORY:
//
//  apo  07.02.06   created analogue to ReadAllData.cpp
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
//  apo  22.01.21   adapted to DLL version 1.2.<target>.<svn_build>
//
//  apo  25.01.21   introduced VIR, VUV module functions (for VisUV/IR) (V1.2.xx.641)
//
//  apo  24.08.22   introduced PRI module functions (for Prima) (V1.2.xx.753)
//
//-----------------------------------------------------------------------------
//
program ReadAllDataByDelphi;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, System.StrUtils, System.Character, System.Math,
  Sepia2_ErrorCodes in '..\Shared_Delphi\Sepia2_ErrorCodes.pas',
  Sepia2_ImportUnit in '..\Shared_Delphi\Sepia2_ImportUnit.pas';

const
  PRAEFIXES                     = 'yzafpnµm kMGTPEZY';
  PRAEFIX_OFFSET                = 9;
  //
  STR_INDENT                    = '     ';
  STR_SEPARATORLINE             = '    ============================================================';
  STR_CMDLINEOPTION_RESTART     = 'restart';
  STR_CMDLINEOPTION_INSTANCE    = 'inst';
  STR_CMDLINEOPTION_NO_WAIT     = 'nowait';
  STR_CMDLINEOPTION_INTERACTIVE = 'interactive';
  STR_CMDLINEOPTION_SERIAL      = 'serial';
  STR_CMDLINEOPTION_PRODUCT     = 'product';
  //
  NO_IDX_1                      = -99999;
  NO_IDX_2                      = -97979;


var
  iRetVal                 : integer = SEPIA2_ERR_NO_ERROR;
  c                       : char;
  //
  cLibVersion             : string  = '';
  cProductModel           : string  = '';
  cGivenProduct           : string  = '';
  cSepiaSerNo             : string  = '';
  cGivenSerNo             : string  = '';
  cFWVersion              : string  = '';
  cDescriptor             : string  = '';
  cFWErrCond              : string  = '';
  cErrString              : string  = '';
  cFWErrPhase             : string  = '';
  cModulType              : string  = '';
  cSerialNumber           : string  = '';
  cFreqTrigMode           : string  = '';
  cFreqTrigSrc            : string  = '';
  cFreqCopy               : string  = '';
  cFrequency              : string  = '';
  cHeadType               : string  = '';
  cPreamble               : string  = '     Following are system describing common infos,'#13#10
                                    + '     the considerate support team of PicoQuant GmbH'#13#10
                                    + '     demands for your qualified service request:'#13#10#13#10
                                    + STR_SEPARATORLINE + ''#13#10#13#10;
  cCallingSW              : string  = 'Demo-Program:   ReadAllDataByDelphi.exe'#13#10;
  cDevID                  : string  = '';
  cDevType                : string  = '';
  cDevFWVers              : string  = '';
  cOpMode                 : string  = '';
  cTrigSrc                : string  = '';
  cValue                  : string  = '';
  //
  //
  lBurstChannels          : array  [1..SEPIA2_SOM_BURSTCHANNEL_COUNT] of longint = (0, 0, 0, 0, 0, 0, 0, 0);
  lBurstSum               : longint =  0;
  //
  iDevIdx                 : integer = -1;
  iGivenDevIdx            : integer = -1;
  //
  //
  iModuleCount            : integer;
  iFWErrCode              : integer;
  iFWErrPhase             : integer;
  iFWErrLocation          : integer;
  iFWErrSlot              : integer;
  iSlotId                 : integer;
  iModuleType             : integer;
  iFreqTrigMode           : integer;
  iHead                   : integer;
  iTriggerMilliVolt       : integer;
  iUpperLimit             : integer;
  iFineDelay              : integer;
  iTrigSrcIdx             : integer;
  iFreqDivIdx             : integer;
  iMainFreq               : integer;
  iIntensity              : integer;
  iWL_Idx                 : integer;
  iOM_Idx                 : integer;
  iTS_Idx                 : integer;
  iMinFreq                : integer;
  iMaxFreq                : integer;
  iMinTrgLvl              : integer;
  iMaxTrgLvl              : integer;
  iResTrgLvl              : integer;
  iMinOnTime              : integer;
  iMaxOnTime              : integer;
  iOnTime                 : integer;
  iMinOffTimefact         : integer;
  iMaxOffTimefact         : integer;
  iOffTimefact            : integer;
  iDummy                  : integer;
  //
  PRIConst                : T_PRI_Constants;
  //
  // boolean
  bUSBInstGiven           : boolean = false;
  bSerialGiven            : boolean = false;
  bProductGiven           : boolean = false;
  bNoWait                 : boolean = false;
  bRestartOption          : boolean = false;
  bInteractive            : boolean = false;
  //
  bIsPrimary              : boolean;
  bIsBackPlane            : boolean;
  bHasUptimeCounter       : boolean;
  bSoftLocked             : boolean;
  bLocked                 : boolean;
  bPulseMode              : boolean;
  bSynchronize            : boolean;
  bSyncInverse            : boolean;
  bDelayed                : boolean;
  bForcedUndelayed        : boolean;
  bMaskedCombi            : boolean;
  bHasCW                  : boolean;
  bHasFanSwitch           : boolean;
  bIsFanRunning           : boolean;
  bDivListEnabled         : boolean;
  bTrigLvlEnabled         : boolean;
  bFreqncyEnabled         : boolean;
  bGatingEnabled          : boolean;
  bGateHiImp              : boolean;
  bDummy1, bDummy2        : boolean;
  //
  //
  // byte
  byteIntensity           : byte;
  byteOutEnable           : byte;
  byteSyncEnable          : byte;
  bytePreSync             : byte;
  byteMaskSync            : byte;
  byteTBNdx               : byte;
  byteOutCombi            : byte;
  byteFineDelayStepCount  : byte;
  //
  // word
  wIntensity              : word;
  wDivider                : word;
  wPAPml                  : word;
  wRRPml                  : word;
  wPSPml                  : word;
  wRSPml                  : word;
  wWSPml                  : word;
  //
  lwMainPowerUp           : longword;
  lwActivePowerUp         : longword;
  lwScaledPowerUp         : longword;
  //
  fGatePeriod             : real    = 0.0;
  fFrequency              : real    = 0.0;
  f64CoarseDelayStep,
  f64CoarseDelay          : double;
  iPosSep                 : integer;
  //
  iMapIdx,
  i, j                    : integer;
  cBuffer                 : string;

  procedure PrintUptimers (lwMainPowerUp, lwActivePowerUp, lwScaledPowerUp : longword);
  var
    hh, mm, hlp: integer;
  begin
    //
    hlp := Round (5.0 * (lwMainPowerUp + $7F) / $FF);
    mm  := hlp mod 60; hh := hlp div 60;
    writeln (Format ('%47s  = %5d:%2.2d h',  ['main power uptime',   hh, mm]));
    //
    if (lwActivePowerUp > 1)
    then begin
      hlp := Round (5.0 * (lwActivePowerUp + $7F) / $FF);
      mm  := hlp mod 60; hh := hlp div 60;
      writeln (Format ('%47s  = %5d:%2.2d h',  ['act. power uptime', hh, mm]));
      //
      if (lwScaledPowerUp > (0.001 * lwActivePowerUp))
      then begin
        writeln (Format ('%47s  =    %5.1f%%\n\n',  ['pwr scaled factor', 100.0 * lwScaledPowerUp / lwActivePowerUp]));
      end;
    end;
    writeln;
  end;

  function IntToBin (Value: integer; Digits: integer; LowToHigh: boolean = false; OnChar: Char = '1'; OffChar: Char = '0'): string;
  var
    i: integer;
  begin
    result := '';
    if LowToHigh
    then begin
      for i:=0 to min (max (1, abs(Digits))-1, 31)
      do begin
        result := result + ifthen ((value and (1 shl i)) > 0, OnChar, OffChar);
      end;
    end
    else begin
      for i:= min (max (1, abs(Digits))-1, 31) downto 0
      do begin
        result := result + ifthen ((value and (1 shl i)) > 0, OnChar, OffChar);
      end;
    end;
  end;

  function FormatEng (const fInp : double; const iMant : integer; const cUnit : string = ''; const iFixedSpace : integer = -1; const iFixedDigits : integer = -1; const bUnitSep : boolean = true) : string;
  var
    i      : integer;
    bNSign : boolean;
    fNorm  : double;
    fTemp0 : double;
    iTemp  : integer;
    cTemp  : string;
  begin
    bNSign := (fInp < 0);
    if (fInp = 0)
    then begin
      iTemp  := 0;
      fNorm  := 0;
    end
    else begin
      fTemp0 := ln (abs (fInp)) / ln (1000);
      iTemp  := Floor (fTemp0);
      fNorm  := power (1000, Frac (fTemp0) + ifthen ((fTemp0 > 0) or ((fTemp0-iTemp) = 0), 0, 1));
    end;
    //
    i := iMant-1;
    if fNorm >=  10 then dec (i);
    if fNorm >= 100 then dec (i);
    //
    cTemp  := Format ('%.*f%s%s%s', [ifthen (iFixedDigits < 0, i, iFixedDigits), fNorm * ifthen (bNSign, -1, 1), ifthen (bUnitSep, ' ', ''), ifthen (bUnitSep, PRAEFIXES [iTemp + PRAEFIX_OFFSET], trim(PRAEFIXES [iTemp + PRAEFIX_OFFSET])), cUnit], FormatSettings_enUS);
    //
    if (iFixedSpace > Length (cTemp))
    then begin
      result := Format ('%*s%s', [iFixedSpace - Length (cTemp), '', cTemp]);
    end
    else begin
      result := cTemp;
    end;
    //
  end;

  function HasFWError (iFWErr, iPhase, iLoc, iErrSlot: integer; const cCond, cPrompt : string): boolean;
  var
    cErrTxt, cErrPhase : string;
  begin
    result := (iFWErr <> SEPIA2_ERR_NO_ERROR);
    //
    if result
    then begin
      writeln (STR_INDENT, cPrompt);
      writeln;
      SEPIA2_LIB_DecodeError  (iFWErr, cErrTxt);
      SEPIA2_FWR_DecodeErrPhaseName (iPhase, cErrPhase);
      writeln (STR_INDENT, '   error code      : ', iFWErr:5, ',   i.e. ''', cErrTxt,'''');
      writeln (STR_INDENT, '   error phase     : ', iPhase:5, ',   i.e. ''', cErrPhase, '''');
      writeln (STR_INDENT, '   error location  : ', iLoc:5);
      writeln (STR_INDENT, '   error slot      : ', iErrSlot:5);
      if (Length (cCond) > 0)
      then begin
        writeln (STR_INDENT, '   error condition : ''', cCond, '''');
      end;
      writeln;
    end;
  end;

  function Sepia2FunctionSucceeds (iRet: integer; const FunctName: string; iDev : integer; iIdx1 : integer = NO_IDX_1; iIdx2 : integer = NO_IDX_2): boolean;
  begin
    result := (iRet = SEPIA2_ERR_NO_ERROR);
    //
    if not result
    then begin
      writeln;
      SEPIA2_LIB_DecodeError (iRetVal, cErrString);
      if iIdx1 = NO_IDX_1 then
        writeln (STR_INDENT, 'ERROR: SEPIA2_', FunctName, ' (', iDev:1, ') returns ', iRet:5, ':')
      else if iIdx2 = NO_IDX_2 then
        writeln (STR_INDENT, 'ERROR: SEPIA2_', FunctName, ' (', iDev:1, ', ', iIdx1:3, ') returns ', iRet:5, ':')
      else
        writeln (STR_INDENT, 'ERROR: SEPIA2_', FunctName, ' (', iDev:1, ', ', iIdx1:3, ', ', iIdx2:3, ') returns ', iRet:5, ':');
      //
      writeln (STR_INDENT, '       i. e. ''', cErrString, '''');
      writeln;
    end;
  end;

begin
  SetLength(TrueBoolStrs, 2);
  TrueBoolStrs[0] := 'True';
  TrueBoolStrs[1] := 'T';
  SetLength(FalseBoolStrs, 2);
  FalseBoolStrs[0] := 'False';
  FalseBoolStrs[1] := 'F';
  //
  if ParamCount = 0
  then
    writeln(' called without parameters')
  else
    writeln(' called with ', ParamCount, ' parameter', ifthen (ParamCount > 1, 's', ''), ':');
  //
  {$region 'CMD-Args checks'}
    //
    bRestartOption := FindCmdLineSwitch (STR_CMDLINEOPTION_RESTART,     true);
    if bRestartOption then
      writeln ('    -', STR_CMDLINEOPTION_RESTART);

    bInteractive   := FindCmdLineSwitch (STR_CMDLINEOPTION_INTERACTIVE, true);
    if bInteractive then
      writeln ('    -', STR_CMDLINEOPTION_INTERACTIVE);

    bNoWait        := FindCmdLineSwitch (STR_CMDLINEOPTION_NO_WAIT,     true);
    if bNoWait then
      writeln ('    -', STR_CMDLINEOPTION_NO_WAIT);

    if FindCmdLineSwitch (STR_CMDLINEOPTION_INSTANCE, cBuffer, true, [clstValueAppended])
    then begin
      //
      if cBuffer.StartsWith('=')
      then begin
        cBuffer := cBuffer.remove(0, 1);
      end;
      //
      if not TryStrToInt (Trim (AnsiDequotedStr (cBuffer, '''')), iGivenDevIdx)
      then
        iGivenDevIdx := -1;

      if (iGivenDevIdx <> -1)
      then
        bUSBInstGiven := true;

      if bUSBInstGiven then
        writeln ('    -', STR_CMDLINEOPTION_INSTANCE, '=', iGivenDevIdx:1);
    end;
    //
    if FindCmdLineSwitch (STR_CMDLINEOPTION_SERIAL, cBuffer, true, [clstValueAppended])
    then begin
      //
      if cBuffer.StartsWith('=')
      then begin
        cBuffer := cBuffer.remove(0, 1);
      end;
      //
      try
        cGivenSerNo := trim (AnsiDequotedStr (cBuffer, ''''));
      except
        ;
      end;
      bSerialGiven := Length (cGivenSerNo) > 0;

      if bSerialGiven then
        writeln ('    -', STR_CMDLINEOPTION_SERIAL, '=', cGivenSerNo);
    end;
    //
    if FindCmdLineSwitch (STR_CMDLINEOPTION_PRODUCT, cBuffer, true, [clstValueAppended])
    then begin
      //
      if cBuffer.StartsWith('=')
      then begin
        cBuffer := cBuffer.remove(0, 1);
      end;
      //
      try
        cGivenProduct := trim (AnsiDequotedStr (cBuffer, ''''));
      except
        ;
      end;
      bProductGiven := Length (cGivenProduct) > 0;

      if bProductGiven then
        writeln ('    -', STR_CMDLINEOPTION_PRODUCT, '=', cGivenProduct);
    end;
    //
  {$endregion 'CMD-Args checks'}
  //
  if (bSepia2ImportLibOK)
  then begin
    //
    writeln; writeln;
    writeln ('     PQLaserDrv   Read ALL Values Demo : ');
    writeln (STR_SEPARATORLINE);
    writeln;
    //
    {$region 'preliminaries: check library version'}
      //
      // preliminaries: check library version
      //
      cLibVersion := 'Test';
      SEPIA2_LIB_GetVersion (cLibVersion);
      writeln ('     Lib-Version    = ', cLibVersion);

      if (StrLComp (PChar (cLibVersion), PChar (LIB_VERSION_REFERENCE), LIB_VERSION_COMPLEN) <> 0)
      then begin
        writeln;
        writeln ('     Warning: This demo application was built for version  ', LIB_VERSION_REFERENCE, 'xxx');
        writeln ('              Continuing may cause unpredictable results!');
        writeln;
        write   ('     Do you want to continue anyway? (y/n): ');

        Read(c);
        if (c.ToUpper <> 'Y')
        then begin
          halt (1);
        end;

        Readln;
        writeln;
      end;
      //
    {$endregion 'preliminaries: check library version'}
    //
    {$region 'get USB index of the first device matching all given conditions'}
      //
      // get USB index of the first device matching all given conditions
      //
      for i := ifthen (bUSBInstGiven, iGivenDevIdx, 0) to ifthen (bUSBInstGiven, iGivenDevIdx, SEPIA2_MAX_USB_DEVICES-1)
      do begin
        iRetVal := SEPIA2_USB_OpenGetSerNumAndClose (i, cProductModel, cSepiaSerNo);
        if ( (iRetVal = SEPIA2_ERR_NO_ERROR)
         and (  (  (bSerialGiven and bProductGiven)
              and  (  (cGivenSerNo   = cSepiaSerNo)
                 and  (cGivenProduct = cProductModel)
                   )
                )
            or  (  (bSerialGiven xor bProductGiven)
              and  (  (cGivenSerNo   = cSepiaSerNo)
                  or  (cGivenProduct = cProductModel)
                   )
                )
            or  (not bSerialGiven and not bProductGiven)
             )
           )
        then begin
          iDevIdx := ifthen (bUSBInstGiven, ifthen (iGivenDevIdx = i, i, -1), i);
          break;
        end;
      end;
      //
    {$endregion 'establish USB connection to the sepia first matching all given conditions'}
    //
    try
      iRetVal := SEPIA2_USB_OpenDevice (iDevIdx, cProductModel, cSepiaSerNo);
      if Sepia2FunctionSucceeds (iRetVal, 'USB_OpenDevice', iDevIdx)
      then begin
        writeln ('     Product Model  = ''', cProductModel, '''');
        writeln;
        writeln (STR_SEPARATORLINE);
        writeln;
        SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion);
        writeln ('     FW-Version     = ', cFWVersion);
        //
        writeln ('     USB Index      = ', iDevIdx);
        SEPIA2_USB_GetStrDescriptor  (iDevIdx, cDescriptor);
        writeln ('     USB Descriptor = ', cDescriptor);
        writeln ('     Serial Number  = ''', cSepiaSerNo, '''');
        writeln;
        writeln (STR_SEPARATORLINE);
        writeln; writeln;
        //
        // get sepia's module map and initialise datastructures for all library functions
        // there are two different ways to do so:
        //
        // first:  if sepia was not touched since last power on, it doesn't need to be restarted
        //         => bRestartOption := SEPIA2_NO_RESTART;
        // second: in case of changes with soft restart
        //         => bRestartOption := SEPIA2_RESTART;
        //
        try
          iRetVal := SEPIA2_FWR_GetModuleMap (iDevIdx, bRestartOption, iModuleCount);
          if Sepia2FunctionSucceeds(iRetVal, 'FWR_GetModuleMap', iDevIdx)
          then begin
            //
            // this is to inform us about possible error conditions during sepia's last startup
            //
            iRetVal := SEPIA2_FWR_GetLastError (iDevIdx, iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond);
            if Sepia2FunctionSucceeds(iRetVal, 'FWR_GetLastError', iDevIdx)
            then begin
              if not HasFWError (iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond, 'Error detected by firmware on last restart:')
              then begin
                // just to show, what sepia2_lib knows about your system, try this:
                cBuffer := '';
                SEPIA2_FWR_CreateSupportRequestText (iDevIdx, cPreamble, cCallingSW, 0, cBuffer);
                if Sepia2FunctionSucceeds(iRetVal, 'FWR_CreateSupportRequestText', iDevIdx)
                then begin
                  writeln (cBuffer);
                  writeln;
                  writeln;
                  writeln (STR_SEPARATORLINE);
                  writeln;
                  writeln;
                end;
                //
                // scan sepia module by module
                // and iterate by iMapIdx for this approach.
                //
                writeln;
                //
                for iMapIdx := 0 to iModuleCount-1
                do begin
                  //
                  iRetVal := SEPIA2_FWR_GetModuleInfoByMapIdx (iDevIdx, iMapIdx, iSlotId, bIsPrimary, bIsBackPlane, bHasUptimeCounter);
                  if Sepia2FunctionSucceeds(iRetVal, 'FWR_GetModuleInfoByMapIdx', iDevIdx, iMapIdx)
                  then begin
                    if (bIsBackPlane)
                    then begin
                      iRetVal := SEPIA2_COM_GetModuleType (iDevIdx, -1, SEPIA2_PRIMARY_MODULE, iModuleType);
                      if Sepia2FunctionSucceeds(iRetVal, 'COM_GetModuleType', iDevIdx, -1)
                      then begin
                        SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                        SEPIA2_COM_GetSerialNumber  (iDevIdx, -1, SEPIA2_PRIMARY_MODULE, cSerialNumber);
                        if Sepia2FunctionSucceeds(iRetVal, 'COM_GetSerialNumber', iDevIdx, -1)
                        then begin
                          writeln (' backplane:   module type     ''', cModulType, '''');
                          writeln ('              serial number   ''', cSerialNumber, '''');
                          writeln;
                        end;
                      end;
                      writeln;
                    end
                    else begin
                      //
                      // identify sepia object (module) in slot
                      //
                      iRetVal := SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, SEPIA2_PRIMARY_MODULE, iModuleType);
                      if Sepia2FunctionSucceeds(iRetVal, 'COM_GetModuleType', iDevIdx, iSlotId)
                      then begin
                        SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                        SEPIA2_COM_GetSerialNumber  (iDevIdx, iSlotId, SEPIA2_PRIMARY_MODULE, cSerialNumber);
                        if Sepia2FunctionSucceeds(iRetVal, 'COM_GetSerialNumber', iDevIdx, iSlotId)
                        then begin
                          writeln (Format (' slot %3.3d :   module type     ''%s''', [iSlotId, cModulType]));
                          writeln ('              serial number   ''', cSerialNumber, '''');
                          writeln;
                        end;
                        //
                        // now, continue with modulespecific information
                        //
                        //
                        case iModuleType of
                          //
                          SEPIA2OBJECT_SCM : begin
                            //
                            // softlock demonstration
                            // behaviour depends on the variable bInteractive at program's begin keyword
                            //
                            // if locked by key, the demonstration should produce
                            //       the sequence "unlocked", "locked", "unlocked"  as soft lock status
                            //   and threetimes   "locked"                          as lock status
                            // else, the demonstration should produce
                            //       the sequence "unlocked", "locked", "unlocked"  as soft lock status
                            //   and the sequence "unlocked", "locked", "unlocked"  as lock status
                            //
                            SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId, bSoftLocked);
                            SEPIA2_SCM_GetLaserLocked   (iDevIdx, iSlotId, bLocked);
                            writeln ('                              laser lock state   :    ', ifthen (not (bLocked or bSoftLocked), ' un', ifthen (bLocked <> bSoftLocked, ' hard', ' soft')), 'locked');
                            //
                            if (bInteractive)
                            then begin
                              writeln; writeln;
                              writeln ('press RETURN...');
                              Readln;
                              for i:=0 to 1
                              do begin
                                iRetVal := SEPIA2_SCM_SetLaserSoftLock (iDevIdx, iSlotId, not bSoftLocked);
                                if Sepia2FunctionSucceeds(iRetVal, 'SCM_SetLaserSoftLock', iDevIdx, iSlotId)
                                then begin
                                  Sleep (100);
                                  iRetVal := SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId, bSoftLocked);
                                  if Sepia2FunctionSucceeds(iRetVal, 'SCM_GetLaserSoftLock', iDevIdx, iSlotId)
                                  then begin
                                    iRetVal := SEPIA2_SCM_GetLaserLocked   (iDevIdx, iSlotId, bLocked);
                                    if Sepia2FunctionSucceeds(iRetVal, 'SCM_GetLaserLocked', iDevIdx, iSlotId)
                                    then begin
                                      writeln ('                              laser lock state   :    ', ifthen (not (bLocked or bSoftLocked), ' un', ifthen (bLocked <> bSoftLocked, ' hard', ' soft')), 'locked');
                                      writeln; writeln;
                                      writeln ('press RETURN...');
                                      Readln;
                                    end;
                                  end;
                                end;
                              end;
                            end;
                            writeln;
                          end;
                          //
                          //
                          SEPIA2OBJECT_SOMD,
                          SEPIA2OBJECT_SOM : begin
                            for iFreqTrigMode := 0 to SEPIA2_SOM_FREQ_TRIGMODE_COUNT-1
                            do begin
                              iRetVal := SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigMode, cFreqTrigMode);
                              if Sepia2FunctionSucceeds(iRetVal, 'SOM_DecodeFreqTrigMode', iDevIdx, iSlotId)
                              then begin
                                if (iFreqTrigMode = 0)
                                  then write ('freq./trigmodes ':46)
                                  else write ('                ':46);
                                write ((iFreqTrigMode+1):1, ') =     ''', cFreqTrigMode);
                                if (iFreqTrigMode = (SEPIA2_SOM_FREQ_TRIGMODE_COUNT - 1))
                                  then writeln ('''')
                                  else writeln (''',');
                              end
                              else begin
                                break;
                              end;
                            end; // for iFreqTrigMode
                            writeln;
                            if (iRetVal = SEPIA2_ERR_NO_ERROR)
                            then begin
                              if iModuleType = SEPIA2OBJECT_SOM
                              then iRetVal := SEPIA2_SOM_GetFreqTrigMode (iDevIdx, iSlotId, iFreqTrigMode)
                              else iRetVal := SEPIA2_SOMD_GetFreqTrigMode (iDevIdx, iSlotId, iFreqTrigMode, bSynchronize);
                              //
                              if Sepia2FunctionSucceeds(iRetVal, ifthen (iModuleType = SEPIA2OBJECT_SOM, 'SOM', 'SOMD')+'_GetFreqTrigMode', iDevIdx, iSlotId)
                              then begin
                                iRetVal := SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigMode, cFreqTrigMode);
                                if Sepia2FunctionSucceeds(iRetVal, 'SOM_DecodeFreqTrigMode', iDevIdx, iSlotId)
                                then begin
                                  writeln ('act. freq./trigm.':47,'  =     ''', cFreqTrigMode, '''');
                                  if (iModuleType = SEPIA2OBJECT_SOMD) and (iFreqTrigMode < ord (SEPIA2_SOM_INT_OSC_A))
                                  then begin
                                    if (bSynchronize)
                                    then writeln ('  ':47,'        (synchronized,)');
                                  end;
                                  //
                                  iRetVal := SEPIA2_SOM_GetBurstValues (iDevIdx, iSlotId, wDivider, bytePreSync, byteMaskSync);
                                  if Sepia2FunctionSucceeds(iRetVal, 'SOM_GetBurstValues', iDevIdx, iSlotId)
                                  then begin
                                    writeln ('divider           ':48, ' = ', wDivider:5);
                                    writeln ('pre sync          ':48, ' = ', bytePreSync:5);
                                    writeln ('masked sync pulses':48, ' = ', byteMaskSync:5);
                                    //
                                    if ( (iFreqTrigMode = ord (SEPIA2_SOM_EXT_TRIG_RAISING))
                                      or (iFreqTrigMode = ord (SEPIA2_SOM_EXT_TRIG_FALLING)) )
                                    then begin
                                      iRetVal := SEPIA2_SOM_GetTriggerLevel (iDevIdx, iSlotId, iTriggerMilliVolt);
                                      if Sepia2FunctionSucceeds(iRetVal, 'SOM_GetTriggerLevel', iDevIdx, iSlotId)
                                      then begin
                                        writeln ('triggerlevel     ':47,'  = ', iTriggerMilliVolt:5, ' mV');
                                      end;
                                    end
                                    else begin
                                      cFreqCopy := TrimLeft(cFreqTrigMode + ' ');
                                      if (FormatSettings.DecimalSeparator <> '.')
                                      then begin
                                        iPosSep := Pos('.', cFreqCopy);
                                        if (iPosSep > 0)
                                        then begin
                                          cFreqCopy[iPosSep] := FormatSettings.DecimalSeparator;
                                        end;
                                      end;
                                      fFrequency := StrToFloat(TrimRight(LeftStr(cFreqCopy, Pos(' ', cFreqCopy))));
                                      fFrequency := fFrequency * 1.0e6 / wDivider;
                                      writeln ('oscillator period':47,'  =  ', FormatEng (1.0 / fFrequency, 6, 's',  11, 3));
                                      writeln ('i.e.':47,             '     ', FormatEng (fFrequency,       6, 'Hz', 12, 3));
                                      writeln;
                                    end;
                                    if (iRetVal = SEPIA2_ERR_NO_ERROR)
                                    then begin
                                      iRetVal := SEPIA2_SOM_GetOutNSyncEnable (iDevIdx, iSlotId, byteOutEnable, byteSyncEnable, bSyncInverse);
                                      if Sepia2FunctionSucceeds(iRetVal, 'SOM_GetOutNSyncEnable', iDevIdx, iSlotId)
                                      then begin
                                        writeln ('sync mask form   ':47, '  =     ', ifthen(bSyncInverse, 'inverse', 'regular'));
                                        writeln;
                                        iRetVal := SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSlotId, lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7], lBurstChannels[8]);
                                        if Sepia2FunctionSucceeds(iRetVal, 'SOM_GetBurstLengthArray', iDevIdx, iSlotId)
                                        then begin
                                          writeln ('                              burst data     ch. | sync | burst len |  out');
                                          writeln ('                                            -----+------+-----------+------');
                                          lBurstSum := 0;
                                          for j := 1 to SEPIA2_SOM_BURSTCHANNEL_COUNT
                                          do begin
                                            writeln ('  ':46, j:1, '  |    ', (byteSyncEnable shr (j-1) and 1):1, ' | ', lBurstChannels[j]:9, ' |    ', (byteOutEnable shr (j-1) and 1):1);
                                            lBurstSum := lBurstSum + lBurstChannels[j];
                                          end;
                                          writeln ('                                         --------+------+ +  -------+------');
                                          writeln ('  ':41, 'Hex/Sum | 0x', IntToHex(byteSyncEnable, 2), ' | =', lBurstSum:8, ' | 0x', IntToHex(byteOutEnable, 2));
                                          writeln;
                                          if (  (iFreqTrigMode <> ord (SEPIA2_SOM_EXT_TRIG_RAISING))
                                            and (iFreqTrigMode <> ord (SEPIA2_SOM_EXT_TRIG_FALLING)) )
                                          then begin
                                            fFrequency := fFrequency / lBurstSum;
                                            writeln ('sequencer period ':47,'  =  ', FormatEng (1.0 / fFrequency, 6, 's',  11, 3));
                                            writeln ('i.e.':47,             '     ', FormatEng (fFrequency,       6, 'Hz', 12, 3));
                                          end;
                                          if (iModuleType = SEPIA2OBJECT_SOMD)
                                          then begin
                                            iRetVal := SEPIA2_SOMD_GetDelayUnits (iDevIdx, iSlotId, f64CoarseDelayStep, byteFineDelayStepCount);
                                            Sepia2FunctionSucceeds(iRetVal, 'SOMD_GetDelayUnits', iDevIdx, iSlotId);
                                            writeln ('                                                 | combiner |');
                                            writeln ('                                                 | channels |');
                                            writeln ('                                             out | 12345678 | delay');
                                            writeln ('                                            -----+----------+------------------');
                                            for j := 1 to SEPIA2_SOM_BURSTCHANNEL_COUNT
                                            do begin
                                              iRetVal := SEPIA2_SOMD_GetSeqOutputInfos (iDevIdx, iSlotId, j, bDelayed, bForcedUndelayed, byteOutCombi, bMaskedCombi, f64CoarseDelay, iFineDelay);
                                              if Sepia2FunctionSucceeds(iRetVal, 'SOMD_GetSeqOutputInfos', iDevIdx, iSlotId)
                                              then begin
                                                write ('  ':46, j:1, '  | ');
                                                if not bDelayed or bForcedUndelayed
                                                then write (IntToBin (byteOutCombi, SEPIA2_SOM_BURSTCHANNEL_COUNT, true, ifthen (bMaskedCombi, '1', 'B')[1], '_'))
                                                else write (IntToBin (1 shl (j-1),  SEPIA2_SOM_BURSTCHANNEL_COUNT, true, 'D', '_'));
                                                write (' |');
                                                if bDelayed and not bForcedUndelayed
                                                then begin
                                                  write (FormatEng (f64CoarseDelay * 1e-9, 4, 's', 9, 1, false), ' + ', iFineDelay:2, 'a.u.');
                                                end;
                                                writeln;
                                              end;
                                            end;
                                            writeln;
                                            writeln ('                              combiner legend    = D: delayed burst,   no combi');
                                            writeln ('                                                   B: combi burst, any non-zero');
                                            writeln ('                                                   1: 1st pulse,   any non-zero');
                                          end;
                                        end;
                                      end;
                                    end;
                                  end;
                                end;
                              end;
                            end;
                            writeln;
                          end; // case iModuleType of SOM / SOM-D
                          //
                          //
                          SEPIA2OBJECT_SLM : begin
                            iRetVal := SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSlotId, wIntensity);
                            if Sepia2FunctionSucceeds(iRetVal, 'SLM_GetIntensityFineStep', iDevIdx, iSlotId)
                            then begin
                              iRetVal := SEPIA2_SLM_GetPulseParameters (iDevIdx, iSlotId, iFreqTrigMode, bPulseMode, iHead);
                              Sepia2FunctionSucceeds(iRetVal, 'SLM_GetPulseParameters', iDevIdx, iSlotId)
                            end;
                            if (iRetVal = SEPIA2_ERR_NO_ERROR)
                            then begin
                              SEPIA2_SLM_DecodeFreqTrigMode (iFreqTrigMode, cFrequency);
                              SEPIA2_SLM_DecodeHeadType     (iHead, cHeadType);
                              //
                              writeln ('freq / trigmode  ':47, '  =     ''', cFrequency, '''');
                              writeln ('pulsmode         ':47, '  =     ''pulses ', ifthen (bPulseMode, 'en', 'dis'), 'abled''');
                              writeln ('headtype         ':47, '  =     ''', cHeadType, '''');
                              writeln ('intensity        ':47, '  =   ', 0.1*wIntensity:5:1, '%');
                            end;
                            writeln;
                          end; // case iModuleType of SLM
                          //
                          //
                          SEPIA2OBJECT_SML : begin
                            iRetVal := SEPIA2_SML_GetParameters (iDevIdx, iSlotId, bPulseMode, iHead, byteIntensity);
                            if Sepia2FunctionSucceeds(iRetVal, 'SML_GetParameters', iDevIdx, iSlotId)
                            then begin
                              SEPIA2_SML_DecodeHeadType (iHead, cHeadType);
                              //
                              writeln ('pulsmode         ':47, '  =     ''pulses ', ifthen(bPulseMode, 'en', 'dis'), 'abled''');
                              writeln ('headtype         ':47, '  =     ''', cHeadType, '''');
                              writeln ('intensity        ':47, '  =   ', byteIntensity:3, '%');
                            end;
                            writeln;
                          end; // case iModuleType of SML
                          //
                          //
                          SEPIA2OBJECT_SWM : begin
                            iRetVal := SEPIA2_SWM_GetCurveParams (iDevIdx, iSlotId, 1, byteTBNdx, wPAPml, wRRPml, wPSPml, wRSPml, wWSPml);
                            if Sepia2FunctionSucceeds(iRetVal, 'SWM_GetCurveParams', iDevIdx, iSlotId)
                            then begin
                              SEPIA2_SWM_DecodeRangeIdx (iDevIdx, iSlotId, byteTBNdx, iUpperLimit);
                              writeln ('Curve 1:          ':48);
                              writeln ('timebase idx TBNdx':48, ' = ',    byteTBNdx:1, ': ', iUpperLimit:3, ' ns');
                              writeln ('pulse ampl.  PAPml':48, ' =   ', 0.1 * wPAPml:6:1, ' %');
                              writeln ('ramp slewrt. RRPml':48, ' =   ', 0.1 * wRRPml:6:1, ' %');
                              writeln ('pulse start  PSPml':48, ' =   ', 0.1 * wPSPml:6:1, ' %');
                              writeln ('ramp start   RSPml':48, ' =   ', 0.1 * wRSPml:6:1, ' %');
                              writeln ('wave stop    WSPml':48, ' =   ', 0.1 * wWSPml:6:1, ' %');
                              writeln;
                            end;
                            iRetVal := SEPIA2_SWM_GetCurveParams (iDevIdx, iSlotId, 2, byteTBNdx, wPAPml, wRRPml, wPSPml, wRSPml, wWSPml);
                            if Sepia2FunctionSucceeds(iRetVal, 'SWM_GetCurveParams', iDevIdx, iSlotId)
                            then begin
                              SEPIA2_SWM_DecodeRangeIdx (iDevIdx, iSlotId, byteTBNdx, iUpperLimit);
                              writeln ('Curve 2:          ':48);
                              writeln ('timebase idx TBNdx':48, ' = ',    byteTBNdx:1, ': ', iUpperLimit:3, ' ns');
                              writeln ('pulse ampl.  PAPml':48, ' =   ', 0.1 * wPAPml:6:1, ' %');
                              writeln ('ramp slewrt. RRPml':48, ' =   ', 0.1 * wRRPml:6:1, ' %');
                              writeln ('pulse start  PSPml':48, ' =   ', 0.1 * wPSPml:6:1, ' %');
                              writeln ('ramp start   RSPml':48, ' =   ', 0.1 * wRSPml:6:1, ' %');
                              writeln ('wave stop    WSPml':48, ' =   ', 0.1 * wWSPml:6:1, ' %');
                            end;
                            writeln;
                          end; // case iModuleType of SWM
                          //
                          //
                          SEPIA2OBJECT_VIR,
                          SEPIA2OBJECT_VUV : begin
                            iRetVal := SEPIA2_VUV_VIR_GetDeviceType (iDevIdx, iSlotId, cDevType, bHasCW, bHasFanSwitch);
                            if Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_GetDeviceType', iDevIdx, iSlotId)
                            then begin
                              iRetVal := SEPIA2_VUV_VIR_GetTriggerData (iDevIdx, iSlotId, iTrigSrcIdx, iFreqDivIdx, iTriggerMilliVolt);
                              if Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_GetTriggerData', iDevIdx, iSlotId)
                              then begin
                                iRetVal := SEPIA2_VUV_VIR_DecodeFreqTrigMode (iDevIdx, iSlotId, iTrigSrcIdx, -1,          cFreqTrigMode, iDummy,    bDummy1,         bDummy2);
                                if Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_DecodeFreqTrigMode', iDevIdx, iSlotId)
                                then begin
                                  iRetVal := SEPIA2_VUV_VIR_DecodeFreqTrigMode (iDevIdx, iSlotId, iTrigSrcIdx, iFreqDivIdx, cFreqTrigSrc,  iMainFreq, bDivListEnabled, bTrigLvlEnabled);
                                  if Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_DecodeFreqTrigMode', iDevIdx, iSlotId)
                                  then begin
                                    writeln ('devicetype       ':47, '  =   ''', cDevType, '''');
                                    writeln ('options          ':47, '  :   CW         = ', BoolToStr(bHasCW, true));
                                    writeln ('                 ':47, '      fan-switch = ', BoolToStr(bHasFanSwitch, true));
                                    writeln ('trigger source   ':47, '  =   ', cFreqTrigMode);
                                    if bDivListEnabled  and (iMainFreq > 0) then
                                    begin
                                      writeln ('divider          ':47, '  =   2^', iFreqDivIdx, ' = ', Round (IntPower (2.0, iFreqDivIdx)));
                                      writeln ('frequency        ':47, '  =   ', FormatEng (1.0*iMainFreq, 4, 'Hz', 9));
                                    end
                                    else if bTrigLvlEnabled then
                                      writeln ('trigger level    ':47, '  =   ', Format ('%.3f V', [0.001*iTriggerMilliVolt], FormatSettings_enUS));
                                  end;
                                end;
                                iRetVal := SEPIA2_VUV_VIR_GetIntensity (iDevIdx, iSlotId, iIntensity);
                                if Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_GetIntensity', iDevIdx, iSlotId)
                                then begin
                                  writeln ('intensity        ':47, '  =   ', Format ('%.1f %%', [0.1*iIntensity], FormatSettings_enUS));
                                end;
                                if bHasFanSwitch then
                                begin
                                  iRetVal := SEPIA2_VUV_VIR_GetFan (iDevIdx, iSlotId, bIsFanRunning);
                                  if Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_GetFan', iDevIdx, iSlotId)
                                  then begin
                                    writeln ('fan running      ':47, '  =   ', BoolToStr(bIsFanRunning, true));
                                  end;
                                end;
                              end;
                            end;
                            writeln;
                          end; // case iModuleType of VUV / VIR
                          //
                          //
                          SEPIA2OBJECT_PRI : begin
                            iRetVal := SEPIA2_PRI_GetConstants(iDevIdx, iSlotId, PRIConst);
                            if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetConstants', iDevIdx, iSlotId)
                            then begin
                              writeln ('devicetype       ':47, '  =   ''', PRIConst.PrimaModuleType, '''');
                              writeln ('firmware version ':47, '  =   ', PRIConst.PrimaFWVers);
                              writeln;
                              writeln ('wavelengths count':47, '  =   ', PRIConst.PrimaWLCount:1);
                              for i:=0 to PRIConst.PrimaWLCount-1 do
                              begin
                                writeln (Format('wavelength [%1d] ', [i]):47, '  =  ', PRIConst.PrimaWLs[i]:4, 'nm')
                              end;
                              iRetVal := SEPIA2_PRI_GetWavelengthIdx (iDevIdx, iSlotId, iWL_Idx);
                              if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetWavelengthIdx', iDevIdx, iSlotId, iWL_Idx)
                              then begin
                                writeln ('cur. wavelength  ':47, '  =  ', PRIConst.PrimaWLs[iWL_Idx]:4, 'nm;            WL-Idx=', iWL_Idx:1);
                              end;
                              writeln;
                              //
                              //
                              writeln ('operation modes  ':47, '  =   ', PRIConst.PrimaOpModCount:1);
                              for i:=0 to PRIConst.PrimaOpModCount-1 do
                              begin
                                iRetVal := SEPIA2_PRI_DecodeOperationMode (iDevIdx, iSlotId, i, cOpMode);
                                if Sepia2FunctionSucceeds(iRetVal, 'PRI_DecodeOperationMode', iDevIdx, iSlotId, i)
                                then begin
                                  writeln (Format('oper. mode [%1d] ', [i]):47, '  =   ''', trim(cOpMode), '''');
                                end;
                              end;
                              iRetVal := SEPIA2_PRI_GetOperationMode (iDevIdx, iSlotId, iOM_Idx);
                              if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetOperationMode', iDevIdx, iSlotId, iOM_Idx)
                              then begin
                                iRetVal := SEPIA2_PRI_DecodeOperationMode (iDevIdx, iSlotId, iOM_Idx, cOpMode);
                                if Sepia2FunctionSucceeds(iRetVal, 'PRI_DecodeOperationMode', iDevIdx, iSlotId, iOM_Idx)
                                then begin
                                  writeln ('cur. oper. mode  ':47, '  =   ''', trim(cOpMode), ''';  ', 'OM-Idx=':(20 - length(trim(cOpMode))) , iOM_Idx:1);
                                end;
                              end;
                              writeln;
                              //
                              //
                              writeln ('trigger sources  ':47, '  =   ', PRIConst.PrimaTrSrcCount:1);
                              for i:=0 to PRIConst.PrimaTrSrcCount-1 do
                              begin
                                iRetVal := SEPIA2_PRI_DecodeTriggerSource (iDevIdx, iSlotId, i, cTrigSrc, bDummy1, bDummy2);
                                if Sepia2FunctionSucceeds(iRetVal, 'PRI_DecodeTriggerSource', iDevIdx, iSlotId, i)
                                then begin
                                  writeln (Format('trig. src. [%1d] ', [i]):47, '  =   ''', trim(cTrigSrc), '''');
                                end;
                              end;
                              iRetVal := SEPIA2_PRI_GetTriggerSource (iDevIdx, iSlotId, iTS_Idx);
                              if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetTriggerSource', iDevIdx, iSlotId, iTS_Idx)
                              then begin
                                iRetVal := SEPIA2_PRI_DecodeTriggerSource (iDevIdx, iSlotId, iTS_Idx, cTrigSrc, bFreqncyEnabled, bTrigLvlEnabled);
                                if Sepia2FunctionSucceeds(iRetVal, 'PRI_DecodeTriggerSource', iDevIdx, iSlotId, iTS_Idx)
                                then begin
                                  writeln ('cur. trig. source':47, '  =   ''', trim(cTrigSrc), '''; ', 'TS-Idx=':(21 - length(trim(cTrigSrc))) , iTS_Idx:1);
                                end;
                              end;
                            end;
                            writeln;
                            //
                            writeln (Format ('for TS-Idx = %1d   ', [iTS_Idx]):47, '  :   frequency is ', ifthen (not bFreqncyEnabled, 'in', '') + 'active:' );
                            iRetVal := SEPIA2_PRI_GetFrequencyLimits (iDevIdx, iSlotId, iMinFreq, iMaxFreq);
                            if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetFrequencyLimits', iDevIdx, iSlotId)
                            then begin
                              writeln ('frequency range':47, '  =   ', FormatEng (iMinFreq, 3, 'Hz', -1, 0, false), ' <= f <= ', FormatEng (iMaxFreq, 3, 'Hz', -1, 0, false));
                              iRetVal := SEPIA2_PRI_GetFrequency (iDevIdx, iSlotId, iMainFreq);
                              if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetFrequency', iDevIdx, iSlotId)
                              then begin
                                writeln ('cur. frequency ':47, '  =   ', FormatEng (iMainFreq, 3, 'Hz', -1, 0, false));
                              end;
                            end;
                            writeln;
                            //
                            writeln (Format ('for TS-Idx = %1d   ', [iTS_Idx]):47, '  :   trigger level is ', ifthen (not bTrigLvlEnabled, 'in', '') + 'active:' );
                            iRetVal := SEPIA2_PRI_GetTriggerLevelLimits (iDevIdx, iSlotId, iMinTrgLvl, iMaxTrgLvl, iResTrgLvl);
                            if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetTriggerLevelLimits', iDevIdx, iSlotId)
                            then begin
                              iRetVal := SEPIA2_PRI_GetTriggerLevel (iDevIdx, iSlotId, iTriggerMilliVolt);
                              writeln ('trig.lvl. range':47, '  =   ', 0.001*iMinTrgLvl:5:3, 'V <= tl <= ', 0.001*iMaxTrgLvl:5:3, 'V');
                              //
                              writeln ('cur. trig.lvl. ':47, '  =   ', 0.001*iTriggerMilliVolt:5:3, 'V');
                            end;
                            writeln;
                            //
                            iRetVal := SEPIA2_PRI_GetIntensity (iDevIdx, iSlotId, iWL_Idx, wIntensity);
                            if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetIntensity', iDevIdx, iSlotId, iWL_Idx)
                            then begin
                              cValue := FormatEng (0.1 * wIntensity, 3, '%', -1, 1, false);
                              writeln ('intensity        ':47, '  =   ', cValue, ';   ', 'WL-Idx=':(21-length(cValue)), iWL_Idx:1);
                            end;
                            writeln;
                            iRetVal := SEPIA2_PRI_GetGatingEnabled (iDevIdx, iSlotId, bGatingEnabled);
                            if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetGatingEnabled', iDevIdx, iSlotId)
                            then begin
                              writeln ('gating           ':47, '  :   ', ifthen (bGatingEnabled, 'en', 'dis'), 'abled');
                              iRetVal := SEPIA2_PRI_GetGateHighImpedance (iDevIdx, iSlotId, bGateHiImp);
                              if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetGateHighImpedance', iDevIdx, iSlotId)
                              then begin
                                writeln ('gate impedance ':47, '  =   ', ifthen (bGateHiImp, 'high (>= 1 kOhm)', 'low (50 Ohm)'));
                              end;
                              //
                              iRetVal := SEPIA2_PRI_GetGatingLimits (iDevIdx, iSlotId, iMinOnTime, iMaxOnTime, iMinOffTimefact, iMaxOffTimefact);
                              if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetGatingLimits', iDevIdx, iSlotId)
                              then begin
                                iRetVal := SEPIA2_PRI_GetGatingData (iDevIdx, iSlotId, iOnTime, iOffTimefact);
                                if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetGatingData', iDevIdx, iSlotId)
                                then begin
                                  fGatePeriod := 1.0e-9 * iOnTime * (1 + iOffTimefact);
                                  //
                                  writeln ('on-time range   ':48, ' =   ', FormatEng (1.0e-9 * iMinOnTime, 4, 's', -1, 1, false), ' <= t <= ', FormatEng (1.0e-9 * iMaxOnTime, 4, 's', -1, 1, false));
                                  writeln ('cur. on-time    ':48, ' =   ', FormatEng (1.0e-9 * iOnTime, 4, 's', -1, 1, false));
                                  writeln ('off-t.fact range':48, ' =   ', iMinOffTimefact, ' <= tf <= ', iMaxOffTimefact);
                                  writeln ('cur. off-time   ':48, ' =   ', iOffTimefact, ' * on-time = ', FormatEng (1.0e-9 * iOnTime * iOffTimefact, 4, 's', -1, 3, false));
                                  writeln ('gate period     ':48, ' =   ', FormatEng (fGatePeriod, 4, 's', -1, 3, false));
                                  writeln ('gate frequency  ':48, ' =   ', FormatEng (1.0 / fGatePeriod, 4, 'Hz', -1, -1, false));
                                end;
                              end;
                            end;
                          end; // case iModuleType of PRI
                          //
                        else
                          writeln;
                        end; // case
                      end; // succeeds COM_GetModuleType
                    end; // not backplane
                  end; // succeeds FWR_GetModuleInfoByMapIdx
                  //
                  if (iRetVal = SEPIA2_ERR_NO_ERROR)
                  then begin
                    //
                    if (not bIsPrimary)
                    then begin
                      iRetVal := SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, SEPIA2_SECONDARY_MODULE, iModuleType);
                      if Sepia2FunctionSucceeds(iRetVal, 'COM_GetModuleType', iDevIdx, iSlotId)
                      then begin
                        SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                        iRetVal := SEPIA2_COM_GetSerialNumber  (iDevIdx, iSlotId, SEPIA2_SECONDARY_MODULE, cSerialNumber);
                        if Sepia2FunctionSucceeds(iRetVal, 'COM_GetSerialNumber', iDevIdx, iSlotId)
                        then begin
                          writeln;
                          writeln ('              secondary mod.  ''', cModulType, '''');
                          writeln ('              serial number   ''', cSerialNumber, '''');
                        end;
                        writeln;
                      end;
                    end;
                    //
                    if (bHasUptimeCounter)
                    then begin
                      iRetVal := SEPIA2_FWR_GetUptimeInfoByMapIdx (iDevIdx, iMapIdx, lwMainPowerUp, lwActivePowerUp, lwScaledPowerUp);
                      if Sepia2FunctionSucceeds(iRetVal, 'FWR_GetUptimeInfoByMapIdx', iDevIdx, iMapIdx) then
                        PrintUptimers (lwMainPowerUp, lwActivePowerUp, lwScaledPowerUp);
                    end;
                  end;
                end; // for all modules in maps
              end; // no FW error
            end; // get last FW error
          end  // succeeds FWR_GetModuleMap
          else begin
            iRetVal := SEPIA2_FWR_GetLastError (iDevIdx, iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond);
            if Sepia2FunctionSucceeds(iRetVal, 'FWR_GetLastError', iDevIdx)
            then begin
              HasFWError(iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond, 'Firmware error detected:');
            end;
          end;
          //
        finally
          iRetVal := SEPIA2_FWR_FreeModuleMap (iDevIdx);
          Sepia2FunctionSucceeds(iRetVal, 'FWR_FreeModuleMap', iDevIdx);
        end;
      end; // succeeds USB_OpenDevice
    finally
      iRetVal := SEPIA2_USB_CloseDevice (iDevIdx);
      Sepia2FunctionSucceeds(iRetVal, 'USB_CloseDevice', iDevIdx, iSlotId)
    end; // open USB device
    //
  end // bSepia2ImportLibOK
  else begin
    writeln ('     error in importlib!');
    writeln ('     ', strReason);
  end;
  //
  writeln;
  //
  if not bNoWait
  then begin
    writeln ('press RETURN...');
    Readln;
  end;
end.
