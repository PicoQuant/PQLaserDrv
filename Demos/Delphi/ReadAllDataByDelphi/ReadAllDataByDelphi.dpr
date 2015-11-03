//-----------------------------------------------------------------------------
//
//      ReadAllDataByDelphi.pas
//
//-----------------------------------------------------------------------------
//
//  Illustrates the functions exported by SEPIA2_Lib
//  Scans the whole Sepia II rack and displays all relevant data
//
//-----------------------------------------------------------------------------
//  HISTORY:
//
//  apo  07.02.06   created analogue to ReadAllData.cpp
//
//  apo  12.02.07   introduced SML Multilaser Module (V1.0.2.0)
//
//-----------------------------------------------------------------------------
//
program ReadAllDataByDelphi;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  StrUtils,
  Sepia2_ErrorCodes in '..\Shared_Delphi\Sepia2_ErrorCodes.pas',
  Sepia2_ImportUnit in '..\Shared_Delphi\Sepia2_ImportUnit.pas';

const
  STR_CMDLINEOPTION_RESTART     = 'restart';
  STR_CMDLINEOPTION_INSTANCE    = 'inst';
  STR_CMDLINEOPTION_NO_WAIT     = 'nowait';
  STR_CMDLINEOPTION_INTERACTIVE = 'interactive';
  STR_CMDLINEOPTION_SERIAL      = 'serial';

var
  iRetVal           : integer = SEPIA2_ERR_NO_ERROR;
  c                 : char;
  //
  cLibVersion       : string  = '';
  cProductModel     : string  = '';
  cSepiaSerNo       : string  = '';
  cFWVersion        : string  = '';
  cDescriptor       : string  = '';
  cFWErrCond        : string  = '';
  cErrString        : string  = '';
  cFWErrPhase       : string  = '';
  cModulType        : string  = '';
  cSerialNumber     : string  = '';
  cFreqTrigMode     : string  = '';
  cFreqCopy         : string  = '';
  cFrequency        : string  = '';
  cHeadType         : string  = '';
  //
  lBurstChannels    : array  [1..SEPIA2_SOM_BURSTCHANNEL_COUNT] of longint = (0, 0, 0, 0, 0, 0, 0, 0);
  lBurstSum         : longint =  0;
  //
  iDevIdx           : integer =  0;
  //
  //
  iModuleCount      : integer;
  iFWErrCode        : integer;
  iFWErrPhase       : integer;
  iFWErrLocation    : integer;
  iFWErrSlot        : integer;
  iSlotId           : integer;
  iModuleType       : integer;
  iFreqTrigMode     : integer;
  iHead             : integer;
  iTriggerMilliVolt : integer;
  iUpperLimit       : integer;
  //
  // boolean
  bRestartOption    : boolean;
  bNoWait           : boolean;
  bInteractive      : boolean;
  //
  bIsPrimary        : boolean;
  bIsBackPlane      : boolean;
  bHasUptimeCounter : boolean;
  bHasSecondary     : boolean;
  bSoftLocked       : boolean;
  bLocked           : boolean;
  bPulseMode        : boolean;
  bSyncInverse      : boolean;
  //
  //
  // byte
  byteIntensity     : byte;
  byteOutEnable     : byte;
  byteSyncEnable    : byte;
  bytePreSync       : byte;
  byteMaskSync      : byte;
  byteTBNdx         : byte;
  //
  // word
  wDivider          : word;
  wPAPml            : word;
  wRRPml            : word;
  wPSPml            : word;
  wRSPml            : word;
  wWSPml            : word;
  //
  lwMainPowerUp     : longword;
  lwActivePowerUp   : longword;
  lwScaledPowerUp   : longword;
  //
  fFrequency        : real    = 0.0;
  iPosSep           : integer;
  //
  iMapIdx,
  i, j              : integer;
  strBuffer         : string;
  strTmpSepiaSerNo  : string;

  procedure PrintUptimers (lwMainPowerUp, lwActivePowerUp, lwScaledPowerUp : longword);
  var
    hh, mm, hlp: integer;
  begin
    //
    hlp := Round (5.0 * (lwMainPowerUp + $7F) / $FF);
    mm  := hlp mod 60; hh := hlp div 60;
    writeln (Format ('%47s     = %2.2d:%2.2d h',  ['main power uptime',   hh, mm]));
    //
    if (lwActivePowerUp > 1)
    then begin
      hlp := Round (5.0 * (lwActivePowerUp + $7F) / $FF);
      mm  := hlp mod 60; hh := hlp div 60;
      writeln (Format ('%47s     = %2.2d:%2.2d h',  ['act. power uptime', hh, mm]));
      //
      if (lwScaledPowerUp > (0.001 * lwActivePowerUp))
      then begin
        writeln (Format ('%47s     =    %5.1f%%\n\n',  ['pwr scaled factor', 100.0 * lwScaledPowerUp / lwActivePowerUp]));
      end;
    end;
    writeln;
  end;


begin
  //
  bRestartOption := FindCmdLineSwitch (STR_CMDLINEOPTION_RESTART,     true);
  bInteractive   := FindCmdLineSwitch (STR_CMDLINEOPTION_INTERACTIVE, true);
  bNoWait        := FindCmdLineSwitch (STR_CMDLINEOPTION_NO_WAIT,     true);
  //
  if FindCmdLineSwitch (STR_CMDLINEOPTION_INSTANCE, strBuffer, true, [clstValueAppended])
  then begin
    //
    if strBuffer[1] = '='
    then begin
      Delete (strBuffer, 1, 1);
    end;
    //
    if not TryStrToInt (Trim (AnsiDequotedStr (strBuffer, '''')), iDevIdx)
    then
      iDevIdx := 0;
  end;
  //
  if FindCmdLineSwitch (STR_CMDLINEOPTION_SERIAL, strBuffer, true, [clstValueAppended])
  then begin
    //
    if strBuffer[1] = '='
    then begin
      Delete (strBuffer, 1, 1);
    end;
    //
    try
      cSepiaSerNo := trim (AnsiDequotedStr (strBuffer, ''''));
    except
      ;
    end;
  end;
  //
  if (bSepia2ImportLibOK)
  then begin
    //
    writeln; writeln;
    writeln ('         PQLaserDrv   Read ALL Values Demo : ');
    writeln ('    =================================================');
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
    // establish USB connection to sepia
    //
    if cSepiaSerNo <> ''
    then begin
      for i:=0 to SEPIA2_MAX_USB_DEVICES-1
      do begin
        strTmpSepiaSerNo := '';
        SEPIA2_USB_OpenGetSerNumAndClose (i, cProductModel, strTmpSepiaSerNo);
        if (strTmpSepiaSerNo = cSepiaSerNo)
        then begin
          iDevIdx := i;
          break;
        end;
      end;
    end;
    //
    iRetVal := SEPIA2_USB_OpenDevice (iDevIdx, cProductModel, cSepiaSerNo);
    if (iRetVal = SEPIA2_ERR_NO_ERROR)
    then begin
      writeln ('     Product Model  = ''', cProductModel, '''');
      writeln ('    =================================================');
      SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion);
      writeln ('     FW-Version     = ', cFWVersion);
      //
      SEPIA2_USB_GetStrDescriptor  (iDevIdx, cDescriptor);
      writeln ('     USB Index      = ', iDevIdx);
      writeln ('     USB Descriptor = ', cDescriptor);
      writeln ('     Serial Number  = ''', cSepiaSerNo, '''');
      writeln ('    =================================================');
      writeln; writeln;
      //
      // get sepia's module map and initialise datastructures for all library functions
      // there are two different ways to do so:
      //
      // first:  if sepia was not touched since last power on, it doesn't need to be restarted
      //         => bRestartOption := SEPIA2_NO_RESTART;
      // second: if there were any changes since last power on, perform a soft restart
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
            writeln ('     Firmware error detected:');
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
            //
            // scan sepia module by module
            // and iterate by iMapIdx for this approach.
            //
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
                      writeln ('                              laser softlock status : ' + ifthen (bSoftLocked, 'locked', 'unlocked'));
                      Sleep (100); // give it a little time to get polled; otherwise you'd still see the former state...
                      SEPIA2_SCM_GetLaserLocked   (iDevIdx, iSlotId, bLocked);
                      writeln ('                              laser     lock status : ' + ifthen (bLocked,     'locked', 'unlocked'));
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
                          SEPIA2_SCM_GetLaserSoftLock (iDevIdx, iSlotId, bSoftLocked);
                          writeln ('                              laser softlock status : ' + ifthen (bSoftLocked, 'locked', 'unlocked'));
                          Sleep (100);
                          SEPIA2_SCM_GetLaserLocked   (iDevIdx, iSlotId, bLocked);
                          writeln ('                              laser     lock status : ' + ifthen (bLocked,     'locked', 'unlocked'));
                          writeln; writeln;
                          writeln ('press RETURN...');
                          Readln;
                        end;
                      end;
                      writeln;
                    end;

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
                        iRetVal := SEPIA2_SOM_GetFreqTrigMode (iDevIdx, iSlotId, iFreqTrigMode);
                        if (iRetVal = SEPIA2_ERR_NO_ERROR)
                        then begin
                          iRetVal := SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSlotId, iFreqTrigMode, cFreqTrigMode);
                          if (iRetVal = SEPIA2_ERR_NO_ERROR)
                          then begin
                            writeln ('act. freq./trigm.':47,'  =     ''', cFreqTrigMode, ''',');
                            //
                            iRetVal := SEPIA2_SOM_GetBurstValues (iDevIdx, iSlotId, wDivider, bytePreSync, byteMaskSync);
                            if (iRetVal = SEPIA2_ERR_NO_ERROR)
                            then begin
                              writeln ('divider           ':48, ' = ', wDivider:5, ',');
                              writeln ('pre sync          ':48, ' = ', bytePreSync:5, ',');
                              writeln ('masked sync pulses':48, ' = ', byteMaskSync:5, ',');
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
                                writeln ('oscillator period':47,'  =    ', (1000.0 / fFrequency):12, ' msec,');
                                writeln (' i.e.   ':53,               ' ', (fFrequency / 1000.0):12, ' kHz');
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
                                    writeln ('                              burst data     ch. |  out | burst len | sync');
                                    writeln ('                                            -----+------+-----------+------');
                                    lBurstSum := 0;
                                    for j := 1 to SEPIA2_SOM_BURSTCHANNEL_COUNT
                                    do begin
                                      writeln ('  ':46, j:1, '  |    ', (byteOutEnable shr (j-1) and 1):1, ' | ', lBurstChannels[j]:9, ' |    ', (byteSyncEnable shr (j-1) and 1):1);
                                      lBurstSum := lBurstSum + lBurstChannels[j];
                                    end;
                                    writeln ('                                         --------+------+ += -------+------');
                                    writeln ('  ':41, 'Hex/Sum |  $', IntToHex(byteOutEnable, 2), ' | ', lBurstSum:9, ' |  $', IntToHex(byteSyncEnable, 2));
                                    writeln;
                                  end;
                                end;
                              end;
                            end;
                          end;
                          if (  (iFreqTrigMode <> ord (SEPIA2_SOM_EXT_TRIG_RAISING))
                            and (iFreqTrigMode <> ord (SEPIA2_SOM_EXT_TRIG_FALLING)) )
                          then begin
                            fFrequency := fFrequency / lBurstSum;
                            writeln ('sequencer period ':47,'  =    ', (1000.0 / fFrequency):12, ' msec,');
                            writeln (' i.e.   ':53,               ' ', (fFrequency / 1000.0):12, ' kHz');
                          end;
                        end;
                      end;
                      writeln;
                    end; // case iModuleType of SOM

                    SEPIA2OBJECT_SLM : begin
                      iRetVal := SEPIA2_SLM_GetParameters (iDevIdx, iSlotId, iFreqTrigMode, bPulseMode, iHead, byteIntensity);
                      if (iRetVal = SEPIA2_ERR_NO_ERROR)
                      then begin
                        SEPIA2_SLM_DecodeFreqTrigMode (iFreqTrigMode, cFrequency);
                        SEPIA2_SLM_DecodeHeadType     (iHead, cHeadType);
                        //
                        writeln ('freq / trigmode  ':47, '  =     ''', cFrequency, ''',');
                        write   ('pulsmode         ':47, '  =     ''pulses ');
                        if (bPulseMode)
                          then writeln ('enabled'',')
                          else writeln ('disabled'',');
                        writeln ('headtype         ':47, '  =     ''', cHeadType, ''',');
                        writeln ('intensity        ':47, '  =   ', byteIntensity:3, '%');
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
                          then writeln ('enabled'',')
                          else writeln ('disabled'',');
                        writeln ('headtype         ':47, '  =     ''', cHeadType, ''',');
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
                        writeln ('timebase idx TBNdx':48, ' = ',    byteTBNdx:1, ': ', iUpperLimit:3, ' nsec');
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
                        writeln ('timebase idx TBNdx':48, ' = ',    byteTBNdx:1, ': ', iUpperLimit:3, ' nsec');
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
                if (iRetVal <> SEPIA2_ERR_NO_ERROR)
                then begin
                  if (iRetVal = SEPIA2_ERR_LIB_REFERENCED_SLOT_IS_NOT_IN_USE)
                  then begin
                    writeln (' slot ', iSlotId:3, ' :   empty');
                    writeln;
                    iRetVal := SEPIA2_ERR_NO_ERROR;
                  end
                  else begin
                    if (iRetVal = SEPIA2_ERR_LIB_ILLEGAL_SLOT_NUMBER)
                    then begin
                      writeln (' slot ', iSlotId:3, ' :   n/a');
                      writeln;
                      iRetVal := SEPIA2_ERR_NO_ERROR;
                    end
                    else begin
                      SEPIA2_LIB_DecodeError (iRetVal, cErrString);
                      writeln (' slot ', iSlotId:3, ' :   ERROR ', iRetVal:5, ':    ''', cErrString, '''');
                      writeln;
                    end; // error, slot not illegal
                  end; // error, slot not empty
                end;
              end; // no error
              //
              if (iRetVal = SEPIA2_ERR_NO_ERROR)
              then begin
                //
                if (bIsPrimary)
                then begin
                  if (bHasUptimeCounter)
                  then begin                                   // ifthen (bIsBackPlane, -1, iMapIdx)
                    SEPIA2_FWR_GetUptimeInfoByMapIdx (iDevIdx, iMapIdx, lwMainPowerUp, lwActivePowerUp, lwScaledPowerUp);
                    PrintUptimers (lwMainPowerUp, lwActivePowerUp, lwScaledPowerUp);
                  end;
                end
                else begin
                  iRetVal := SEPIA2_COM_GetModuleType (iDevIdx, iSlotId, SEPIA2_SECONDARY_MODULE, iModuleType);
                  if (iRetVal = SEPIA2_ERR_NO_ERROR)
                  then begin
                    SEPIA2_COM_DecodeModuleType (iModuleType, cModulType);
                    SEPIA2_COM_GetSerialNumber  (iDevIdx, iSlotId, SEPIA2_SECONDARY_MODULE, cSerialNumber);
                    writeln;
                    writeln ('              secondary mod.  ''', cModulType, '''');
                    writeln ('              serial number   ''', cSerialNumber, '''');
                    writeln;
                    //
                    if (bHasUptimeCounter)
                    then begin
                      SEPIA2_FWR_GetUptimeInfoByMapIdx (iDevIdx, iMapIdx, lwMainPowerUp, lwActivePowerUp, lwScaledPowerUp);
                      PrintUptimers (lwMainPowerUp, lwActivePowerUp, lwScaledPowerUp);
                    end;
                  end;
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
