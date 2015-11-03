//-----------------------------------------------------------------------------
//
//      ReadAllDataByDelphi.pas
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
//-----------------------------------------------------------------------------
//
program ReadAllDataByDelphi;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.StrUtils, System.Math,
  Sepia2_ErrorCodes in '..\Shared_Delphi\Sepia2_ErrorCodes.pas',
  Sepia2_ImportUnit in '..\Shared_Delphi\Sepia2_ImportUnit.pas';

const
  PRAEFIXES                     = 'yzafpnµm kMGTPEZY';
  PRAEFIX_OFFSET                = 9;


  STR_CMDLINEOPTION_RESTART     = 'restart';
  STR_CMDLINEOPTION_INSTANCE    = 'inst';
  STR_CMDLINEOPTION_NO_WAIT     = 'nowait';
  STR_CMDLINEOPTION_INTERACTIVE = 'interactive';
  STR_CMDLINEOPTION_SERIAL      = 'serial';
  STR_CMDLINEOPTION_PRODUCT     = 'product';

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
  cFreqCopy               : string  = '';
  cFrequency              : string  = '';
  cHeadType               : string  = '';
  cPreamble               : string  = '     Following are system describing common infos,'#13#10
                                    + '     the considerate support team of PicoQuant GmbH'#13#10
                                    + '     demands for your qualified service request:'#13#10#13#10
                                    + '    ================================================='#13#10#13#10;
  cCallingSW              : string  = 'Demo-Program:   ReadAllDataByDelphi.exe'#13#10;

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
  iSkippedSlotId          : integer;
  iModuleType             : integer;
  iFreqTrigMode           : integer;
  iHead                   : integer;
  iTriggerMilliVolt       : integer;
  iUpperLimit             : integer;
  iFineDelay              : integer;
  //
  // boolean
  bUSBInstGiven           : boolean = false;
  bSerialGiven            : boolean = false;
  bProductGiven           : boolean = false;
  bRestartOption          : boolean;
  bNoWait                 : boolean;
  bInteractive            : boolean;
  //
  bIsPrimary              : boolean;
  bIsBackPlane            : boolean;
  bHasUptimeCounter       : boolean;
  bHasSecondary           : boolean;
  bSoftLocked             : boolean;
  bLocked                 : boolean;
  bPulseMode              : boolean;
  bSynchronize            : boolean;
  bSyncInverse            : boolean;
  bDelayed                : boolean;
  bForcedUndelayed        : boolean;
  bMaskedCombi            : boolean;
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
    i      := iMant-1;
    if fNorm >=  10 then dec (i);
    if fNorm >= 100 then dec (i);
    //
    cTemp  := Format ('%.*f%s%s%s', [ifthen (iFixedDigits < 0, i, iFixedDigits), fNorm * ifthen (bNSign, -1, 1), ifthen (bUnitSep, ' ', ''), PRAEFIXES [iTemp + PRAEFIX_OFFSET], cUnit], fsDecode);
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


begin
  //
  bRestartOption := FindCmdLineSwitch (STR_CMDLINEOPTION_RESTART,     true);
  bInteractive   := FindCmdLineSwitch (STR_CMDLINEOPTION_INTERACTIVE, true);
  bNoWait        := FindCmdLineSwitch (STR_CMDLINEOPTION_NO_WAIT,     true);
  //
  if FindCmdLineSwitch (STR_CMDLINEOPTION_INSTANCE, cBuffer, true, [clstValueAppended])
  then begin
    //
    if cBuffer[1] = '='
    then begin
      Delete (cBuffer, 1, 1);
    end;
    //
    if not TryStrToInt (Trim (AnsiDequotedStr (cBuffer, '''')), iGivenDevIdx)
    then
      iGivenDevIdx := -1;

    if (iGivenDevIdx <> -1)
    then
      bUSBInstGiven := true;
  end;
  //
  if FindCmdLineSwitch (STR_CMDLINEOPTION_SERIAL, cBuffer, true, [clstValueAppended])
  then begin
    //
    if cBuffer[1] = '='
    then begin
      Delete (cBuffer, 1, 1);
    end;
    //
    try
      cSepiaSerNo := trim (AnsiDequotedStr (cBuffer, ''''));
    except
      ;
    end;
    bSerialGiven := Length (cSepiaSerNo) > 0;
  end;
  //
  if FindCmdLineSwitch (STR_CMDLINEOPTION_PRODUCT, cBuffer, true, [clstValueAppended])
  then begin
    //
    if cBuffer[1] = '='
    then begin
      Delete (cBuffer, 1, 1);
    end;
    //
    try
      cGivenProduct := trim (AnsiDequotedStr (cBuffer, ''''));
    except
      ;
    end;
    bProductGiven := Length (cGivenProduct) > 0;
  end;
  //
  if (bSepia2ImportLibOK)
  then begin
    //
    writeln; writeln;
    writeln ('     PQLaserDrv   Read ALL Values Demo : ');
    writeln ('    =================================================');
    writeln;
    //
    // preliminaries: check library version
    //
    cLibVersion := 'Test';
    SEPIA2_LIB_GetVersion (cLibVersion);
    writeln ('     Lib-Version    = ', cLibVersion);

    if (StrLComp (PChar (cLibVersion), PChar (LIB_VERSION_REFERENCE), LIB_VERSION_COMPLEN) <> 0)
    then begin
      writeln;
      writeln ('     Warning: This demo application was built for version  ', LIB_VERSION_REFERENCE);
      writeln ('              Continuing may cause unpredictable results!');
      writeln;
      write   ('     Do you want to continue anyway? (y/n): ');

      Read(c);
      if ((c <> 'y') and (c <> 'Y'))
      then begin
        halt (1);
      end;

      Readln;
      writeln;
    end;
    //
    // establish USB connection to the sepia first matching all given conditions
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
    iRetVal := SEPIA2_USB_OpenDevice (iDevIdx, cProductModel, cSepiaSerNo);
    if (iRetVal = SEPIA2_ERR_NO_ERROR)
    then begin
      writeln ('     Product Model  = ''', cProductModel, '''');
      writeln;
      writeln ('    =================================================');
      writeln;
      SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion);
      writeln ('     FW-Version     = ', cFWVersion);
      //
      SEPIA2_USB_GetStrDescriptor  (iDevIdx, cDescriptor);
      writeln ('     USB Index      = ', iDevIdx);
      writeln ('     USB Descriptor = ', cDescriptor);
      writeln ('     Serial Number  = ''', cSepiaSerNo, '''');
      writeln;
      writeln ('    =================================================');
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
      iRetVal := SEPIA2_FWR_GetModuleMap (iDevIdx, bRestartOption, iModuleCount);
      //
      if (iRetVal = SEPIA2_ERR_NO_ERROR)
      then begin
        //
        // this is to inform us about possible error conditions during sepia's last startup
        //
        iRetVal := SEPIA2_FWR_GetLastError (iDevIdx, iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond);
        if (iRetVal = SEPIA2_ERR_NO_ERROR)
        then begin
          if (iFWErrCode <> SEPIA2_ERR_NO_ERROR)
          then begin
            SEPIA2_LIB_DecodeError  (iFWErrCode,  cErrString);
            SEPIA2_FWR_DecodeErrPhaseName (iFWErrPhase, cFWErrPhase);
            writeln ('     Error detected by firmware on last restart:');
            writeln ('        error code      : ', iFWErrCode:5, ',   i.e. ''', cErrString,'''');
            writeln ('        error phase     : ', iFWErrPhase:5,',   i.e. ''', cFWErrPhase, '''');
            writeln ('        error location  : ', iFWErrLocation:5);
            writeln ('        error slot      : ', iFWErrSlot:5);
            if (Length (cFWErrCond) > 0)
            then begin
              writeln ('        error condition : ''', cFWErrCond, '''');
            end;
          end
          else begin
            // just to show, what sepia2_lib knows about your system, try this:
            cBuffer := '';
            SEPIA2_FWR_CreateSupportRequestText (iDevIdx, cPreamble, cCallingSW, 0, cBuffer);
            //
            writeln (cBuffer);
            writeln;
            writeln;
            writeln ('    =================================================');
            //
            // scan sepia module by module
            // and iterate by iMapIdx for this approach.
            //
            writeln;
            writeln;
            writeln;
            //
            for iMapIdx := 0 to iModuleCount-1
            do begin
              //
              iRetVal := SEPIA2_FWR_GetModuleInfoByMapIdx (iDevIdx, iMapIdx, iSlotId, bIsPrimary, bIsBackPlane, bHasUptimeCounter);
              if (bIsBackPlane)
              then begin
                iRetVal := SEPIA2_COM_GetModuleType (iDevIdx, -1, SEPIA2_PRIMARY_MODULE, iModuleType);
                if (iRetVal = SEPIA2_ERR_NO_ERROR)
                then begin
                  SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                  SEPIA2_COM_GetSerialNumber  (iDevIdx, -1, SEPIA2_PRIMARY_MODULE, cSerialNumber);
                  writeln (' backplane:   module type     ''', cModulType, '''');
                  writeln ('              serial number   ''', cSerialNumber, '''');
                  writeln;
                end;
              end
              else begin
                //
                // identify sepia object (module) in slot
                //
                iRetVal := SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, SEPIA2_PRIMARY_MODULE, iModuleType);
                if (iRetVal = SEPIA2_ERR_NO_ERROR)
                then begin
                  SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                  SEPIA2_COM_GetSerialNumber  (iDevIdx, iSlotId, SEPIA2_PRIMARY_MODULE, cSerialNumber);
                  writeln (Format (' slot %3.3d :   module type     ''%s''', [iSlotId, cModulType]));
                  writeln ('              serial number   ''', cSerialNumber, '''');
                  writeln;
                  //
                  // now, continue with modulespecific information
                  //
                  case iModuleType of
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
                          SEPIA2_SCM_SetLaserSoftLock (iDevIdx, iSlotId, not bSoftLocked);
                          //
                          Sleep (100);
                          SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId, bSoftLocked);
                          SEPIA2_SCM_GetLaserLocked   (iDevIdx, iSlotId, bLocked);
                          writeln ('                              laser lock state   :    ', ifthen (not (bLocked or bSoftLocked), ' un', ifthen (bLocked <> bSoftLocked, ' hard', ' soft')), 'locked');
                          writeln; writeln;
                          writeln ('press RETURN...');
                          Readln;
                        end;
                      end;
                      writeln;
                    end;

                    SEPIA2OBJECT_SOMD,
                    SEPIA2OBJECT_SOM : begin
                      for iFreqTrigMode := 0 to SEPIA2_SOM_FREQ_TRIGMODE_COUNT-1
                      do begin
                        iRetVal := SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigMode, cFreqTrigMode);
                        if (iRetVal = SEPIA2_ERR_NO_ERROR)
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
                        if (iRetVal = SEPIA2_ERR_NO_ERROR)
                        then begin
                          iRetVal := SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigMode, cFreqTrigMode);
                          if (iRetVal = SEPIA2_ERR_NO_ERROR)
                          then begin
                            writeln ('act. freq./trigm.':47,'  =     ''', cFreqTrigMode, '''');
                            if (iModuleType = SEPIA2OBJECT_SOMD) and (iFreqTrigMode < ord (SEPIA2_SOM_INT_OSC_A))
                            then begin
                              if (bSynchronize)
                              then writeln ('  ':47,'        (synchronized,)');
                            end;
                            //
                            iRetVal := SEPIA2_SOM_GetBurstValues (iDevIdx, iSlotId, wDivider, bytePreSync, byteMaskSync);
                            if (iRetVal = SEPIA2_ERR_NO_ERROR)
                            then begin
                              writeln ('divider           ':48, ' = ', wDivider:5);
                              writeln ('pre sync          ':48, ' = ', bytePreSync:5);
                              writeln ('masked sync pulses':48, ' = ', byteMaskSync:5);
                              //
                              if ( (iFreqTrigMode = ord (SEPIA2_SOM_EXT_TRIG_RAISING))
                                or (iFreqTrigMode = ord (SEPIA2_SOM_EXT_TRIG_FALLING)) )
                              then begin
                                iRetVal := SEPIA2_SOM_GetTriggerLevel (iDevIdx, iSlotId, iTriggerMilliVolt);
                                if (iRetVal = SEPIA2_ERR_NO_ERROR)
                                then begin
                                  writeln ('triggerlevel     ':47,'  = ', iTriggerMilliVolt:5, ' mV');
                                end;
                              end
                              else begin
                                cFreqCopy := cFreqTrigMode;
                                if (DecimalSeparator <> '.')
                                then begin
                                  iPosSep := Pos('.', cFreqCopy);
                                  if (iPosSep > 0)
                                  then begin
                                    cFreqCopy[iPosSep] := DecimalSeparator;
                                  end;
                                end;
                                if (length(cFreqCopy) > 5)
                                then begin
                                  for j:=6 to length(cFreqCopy)
                                  do begin
                                    cFreqCopy[j] := ' ';
                                  end;
                                end;
                                fFrequency := StrToFloat (cFreqCopy);
                                fFrequency := fFrequency * 1.0e6 / wDivider;
                                ;
                                writeln ('oscillator period':47,'  =  ', FormatEng (1.0 / fFrequency, 6, 's',  11, 3));
                                writeln ('i.e.':47,             '     ', FormatEng (fFrequency,       6, 'Hz', 12, 3));
                                writeln;
                              end;
                              if (iRetVal = SEPIA2_ERR_NO_ERROR)
                              then begin
                                iRetVal := SEPIA2_SOM_GetOutNSyncEnable (iDevIdx, iSlotId, byteOutEnable, byteSyncEnable, bSyncInverse);
                                if (iRetVal = SEPIA2_ERR_NO_ERROR)
                                then begin
                                  write ('sync mask form   ':47, '  =     ');
                                  if (bSyncInverse)
                                    then writeln ('inverse')
                                    else writeln ('regular');
                                  writeln;
                                  iRetVal := SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSlotId, lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7], lBurstChannels[8]);
                                  if (iRetVal = SEPIA2_ERR_NO_ERROR)
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
                                    writeln ('  ':41, 'Hex/Sum |  $', IntToHex(byteSyncEnable, 2), ' | =', lBurstSum:8, ' |  $', IntToHex(byteOutEnable, 2));
                                    writeln;
                                    if (  (iFreqTrigMode <> ord (SEPIA2_SOM_EXT_TRIG_RAISING))
                                      and (iFreqTrigMode <> ord (SEPIA2_SOM_EXT_TRIG_FALLING)) )
                                    then begin
                                      fFrequency := fFrequency / lBurstSum;
                                      writeln ('sequencer period':47,'  =  ', FormatEng (1.0 / fFrequency, 6, 's',  11, 3));
                                      writeln ('i.e.':47,            '     ', FormatEng (fFrequency,       6, 'Hz', 12, 3));
                                    end;
                                    writeln;
                                    if (iModuleType = SEPIA2OBJECT_SOMD)
                                    then begin
                                      iRetVal := SEPIA2_SOMD_GetDelayUnits (iDevIdx, iSlotId, f64CoarseDelayStep, byteFineDelayStepCount);
                                      writeln ('                                                 | combiner |');
                                      writeln ('                                                 | channels |');
                                      writeln ('                                             out | 12345678 | delay');
                                      writeln ('                                            -----+----------+------------------');
                                      for j := 1 to SEPIA2_SOM_BURSTCHANNEL_COUNT
                                      do begin
                                        iRetVal := SEPIA2_SOMD_GetSeqOutputInfos (iDevIdx, iSlotId, j, bDelayed, bForcedUndelayed, byteOutCombi, bMaskedCombi, f64CoarseDelay, iFineDelay);
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

                    SEPIA2OBJECT_SLM : begin
                      iRetVal := SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSlotId, wIntensity);
                      if (iRetVal = SEPIA2_ERR_NO_ERROR)
                      then begin
                        iRetVal := SEPIA2_SLM_GetPulseParameters (iDevIdx, iSlotId, iFreqTrigMode, bPulseMode, iHead);
                      end;
                      if (iRetVal = SEPIA2_ERR_NO_ERROR)
                      then begin
                        SEPIA2_SLM_DecodeFreqTrigMode (iFreqTrigMode, cFrequency);
                        SEPIA2_SLM_DecodeHeadType     (iHead, cHeadType);
                        //
                        writeln ('freq / trigmode  ':47, '  =     ''', cFrequency, '''');
                        write   ('pulsmode         ':47, '  =     ''pulses ');
                        if (bPulseMode)
                          then writeln ('enabled''')
                          else writeln ('disabled''');
                        writeln ('headtype         ':47, '  =     ''', cHeadType, '''');
                        writeln ('intensity        ':47, '  =   ', 0.1*wIntensity:5:1, '%');
                      end;
                      writeln;
                    end; // case iModuleType of SLM

                    SEPIA2OBJECT_SML : begin
                      iRetVal := SEPIA2_SML_GetParameters (iDevIdx, iSlotId, bPulseMode, iHead, byteIntensity);
                      if (iRetVal = SEPIA2_ERR_NO_ERROR)
                      then begin
                        SEPIA2_SML_DecodeHeadType     (iHead, cHeadType);
                        //
                        write   ('pulsmode         ':47, '  =     ''pulses ');
                        if (bPulseMode)
                          then writeln ('enabled''')
                          else writeln ('disabled''');
                        writeln ('headtype         ':47, '  =     ''', cHeadType, '''');
                        writeln ('intensity        ':47, '  =   ', byteIntensity:3, '%');
                      end;
                      writeln;
                    end; // case iModuleType of SML

                    SEPIA2OBJECT_SWM : begin
                      iRetVal := SEPIA2_SWM_GetCurveParams (iDevIdx, iSlotId, 1, byteTBNdx, wPAPml, wRRPml, wPSPml, wRSPml, wWSPml);
                      if (iRetVal = SEPIA2_ERR_NO_ERROR)
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
                      if (iRetVal = SEPIA2_ERR_NO_ERROR)
                      then begin
                        SEPIA2_SWM_DecodeRangeIdx (iDevIdx, iSlotId, byteTBNdx, iUpperLimit);
                        writeln ('Curve 2:          ':48);
                        writeln ('timebase idx TBNdx':48, ' = ',    byteTBNdx:1, ': ', iUpperLimit:3, ' ns');
                        writeln ('pulse ampl.  PAPml':48, ' =   ', 0.1 * wPAPml:6:1, ' %');
                        writeln ('ramp slewrt. RRPml':48, ' =   ', 0.1 * wRRPml:6:1, ' %');
                        writeln ('pulse start  PSPml':48, ' =   ', 0.1 * wPSPml:6:1, ' %');
                        writeln ('ramp start   RSPml':48, ' =   ', 0.1 * wRSPml:6:1, ' %');
                        writeln ('wave stop    WSPml':48, ' =   ', 0.1 * wWSPml:6:1, ' %');
                        writeln;
                      end;
                    end; // case iModuleType of SWM

                  else
                    ;
                  end; // case
                end;
              end; // no error
              //
              if (iRetVal = SEPIA2_ERR_NO_ERROR)
              then begin
                //
                if (not bIsPrimary)
                then begin
                  iRetVal := SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, SEPIA2_SECONDARY_MODULE, iModuleType);
                  if (iRetVal = SEPIA2_ERR_NO_ERROR)
                  then begin
                    SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                    SEPIA2_COM_GetSerialNumber  (iDevIdx, iSlotId, SEPIA2_SECONDARY_MODULE, cSerialNumber);
                    writeln;
                    writeln ('              secondary mod.  ''', cModulType, '''');
                    writeln ('              serial number   ''', cSerialNumber, '''');
                    writeln;
                  end;
                end;
                //
                if (bHasUptimeCounter)
                then begin
                  SEPIA2_FWR_GetUptimeInfoByMapIdx (iDevIdx, iMapIdx, lwMainPowerUp, lwActivePowerUp, lwScaledPowerUp);
                  PrintUptimers (lwMainPowerUp, lwActivePowerUp, lwScaledPowerUp);
                end;
              end;
            end; // for all modules in maps
          end; // no error
        end; // get last FW error
      end  // get module map
      else begin
        SEPIA2_LIB_DecodeError (iRetVal, cErrString);
        writeln ('     ERROR ', iRetVal:5, ':    ''', cErrString, '''');
        writeln;
        iRetVal := SEPIA2_FWR_GetLastError (iDevIdx, iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond);
        if (iRetVal = SEPIA2_ERR_NO_ERROR)
        then begin
          if (iFWErrCode <> SEPIA2_ERR_NO_ERROR)
          then begin
            SEPIA2_LIB_DecodeError  (iFWErrCode,  cErrString);
            SEPIA2_FWR_DecodeErrPhaseName (iFWErrPhase, cFWErrPhase);
            writeln ('     Firmware error detected:');
            writeln ('        error code      : ', iFWErrCode:5, ',   i.e. ''', cErrString,'''');
            writeln ('        error phase     : ', iFWErrPhase:5,',   i.e. ''', cFWErrPhase, '''');
            writeln ('        error location  : ', iFWErrLocation:5);
            writeln ('        error slot      : ', iFWErrSlot:5);
            if (Length (cFWErrCond) > 0)
            then begin
              writeln ('        error condition : ''', cFWErrCond, '''');
            end;
          end;
        end;
      end;
      //
      SEPIA2_FWR_FreeModuleMap (iDevIdx);
      SEPIA2_USB_CloseDevice (iDevIdx);
    end // open USB device
    else begin
      SEPIA2_LIB_DecodeError (iRetVal, cErrString);
      writeln ('     ERROR ', iRetVal:5, ':    ''', cErrString, '''');
    end;
    //
  end
  else begin
    writeln ('     error in importlib!');
  end;
  //
  if not bNoWait
  then begin
    writeln; writeln;
    writeln ('press RETURN...');
    Readln;
  end;
end.
