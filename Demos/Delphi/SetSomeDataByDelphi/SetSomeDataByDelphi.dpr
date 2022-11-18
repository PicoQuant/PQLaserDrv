//-----------------------------------------------------------------------------
//
//      SetSomeDataByDelphi
//
//-----------------------------------------------------------------------------
//
//  Illustrates the functions exported by SEPIA2_Lib
//
//  Presumes to find a SOM 828, SOM-D 828, a SLM 828, a VisUV/IR and/or a Prima
//
//  if there doesn't exist a file named "OrigData.txt"
//    it creates the file to save the original values
//    then sets new values for the modules found (only first of a kind)
//  else
//    it sets back to original values for the modules from file and
//    deletes it afterwards.
//
//  Consider, this code is for demonstration purposes only.
//  Don't use it in productive environments!
//
//-----------------------------------------------------------------------------
//  HISTORY:
//
//  apo  07.02.06   created analogue to SetSomeData.cpp
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
//  apo  06.09.22   introduced PRI module functions (for Prima) (V1.2.xx.753)
//
//-----------------------------------------------------------------------------
//
program SetSomeDataByDelphi;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Math, System.SysConst, System.SysUtils, System.StrUtils, System.Character,
  Sepia2_ErrorCodes in '..\Shared_Delphi\Sepia2_ErrorCodes.pas',
  Sepia2_ImportUnit in '..\Shared_Delphi\Sepia2_ImportUnit.pas';

const
  STR_CMDLINEOPTION_INSTANCE    = 'inst';
  STR_CMDLINEOPTION_SERIAL      = 'serial';
  STR_CMDLINEOPTION_PRODUCT     = 'product';
  STR_CMDLINEOPTION_NO_WAIT     = 'nowait';
  //
  STR_INDENT                    = '     ';
  STR_SEPARATORLINE             = '    ============================================================';
  FNAME                         = 'OrigData.txt';
  IS_A_VUV                      = false;
  IS_A_VIR                      = true;
  //
  NO_IDX_1                      = -99999;
  NO_IDX_2                      = -97979;

var
  iRetVal           : integer = SEPIA2_ERR_NO_ERROR;
  c                 : char;
  f                 : text;
  //
  cLibVersion       : string  = '';
  cProductModel     : string  = '';
  cGivenProduct     : string  = '';
  cSepiaSerNo       : string  = '';
  cGivenSerNo       : string  = '';
  cFWVersion        : string  = '';
  cDescriptor       : string  = '';
  cFWErrCond        : string  = '';
  cErrString        : string  = '';
  cFWErrPhase       : string  = '';
  //
  cSOMType          : string  = '';
  cSLMType          : string  = '';
  cVUVType          : string  = '';
  cVIRType          : string  = '';
  cPRIType          : string  = '';
  cSOMSerNr         : string  = '';
  cSLMSerNr         : string  = '';
  cVUVSerNr         : string  = '';
  cVIRSerNr         : string  = '';
  cPRISerNr         : string  = '';
  cSOMFSerNr        : string  = '';
  cSLMFSerNr        : string  = '';
  cVUVFSerNr        : string  = '';
  cVIRFSerNr        : string  = '';
  cPRIFSerNr        : string  = '';
  //
  cFreqTrigMode     : string  = '';
  cOperMode         : string  = '';
  //
  cDummy            : string[20] = '';
  cTemp             : string  = '';
  //
  lBurstChannels    : array  [1..SEPIA2_SOM_BURSTCHANNEL_COUNT] of longint = (0, 0, 0, 0, 0, 0, 0, 0);
  lTemp             : longint;
  //
  iDevIdx           : integer =  -1;
  iGivenDevIdx      : integer =  -1;
  iSOM_Slot         : integer =  -1;
  iSLM_Slot         : integer =  -1;
  iVUV_Slot         : integer =  -1;
  iVIR_Slot         : integer =  -1;
  iPRI_Slot         : integer =  -1;
  iSOM_FSlot        : integer =  -1;
  iSLM_FSlot        : integer =  -1;
  iVUV_FSlot        : integer =  -1;
  iVIR_FSlot        : integer =  -1;
  iPRI_FSlot        : integer =  -1;
  //
  iModuleCount      : integer;
  iSlotNr           : integer;
  iModuleType       : integer;
  //
  iSOMModuleType    : integer = SEPIA2OBJECT_SOM;
  iFWErrCode        : integer;
  iFWErrPhase       : integer;
  iFWErrLocation    : integer;
  iFWErrSlot        : integer;
  iFreqTrigIdx      : integer;
  iFreqTrigSrc      : array [Boolean] of integer;
  iFreqDivIdx       : array [Boolean] of integer;
  iTrigLevel        : array [Boolean] of integer;
  iIntensity        : array [Boolean] of integer;
  iHead             : integer;
  iFreqIdx          : integer;
  iSOMDErrorCode    : integer;
  //
  iOpModeIdx        : integer;
  iWL_Idx           : integer;
  iWL               : integer;
  //
  PRIConst          : T_PRI_Constants;
  //
  // boolean
  bUSBInstGiven     : boolean =  false;
  bSerialGiven      : boolean =  false;
  bProductGiven     : boolean =  false;
  bNoWait           : boolean =  false;
  bIsPrimary        : boolean;
  bIsBackPlane      : boolean;
  bHasUptimeCounter : boolean;
  bSOM_Found        : boolean =  false;
  bSLM_Found        : boolean =  false;
  bVUV_Found        : boolean =  false;
  bVIR_Found        : boolean =  false;
  bPRI_Found        : boolean =  false;
  bSOM_FFound       : boolean =  false;
  bSLM_FFound       : boolean =  false;
  bVUV_FFound       : boolean =  false;
  bVIR_FFound       : boolean =  false;
  bPRI_FFound       : boolean =  false;
  bIsSOMDModule     : boolean =  false;
  bPulseMode        : boolean;
  bSyncInverse      : boolean;
  bSynchronize      : boolean;
  bFanRunning       : array [Boolean] of boolean;
  //
  // byte
  byteOutEnable     : byte;
  byteSyncEnable    : byte;
  bytePreSync       : byte;
  byteMaskSync      : byte;
  //
  // word
  wDivider          : word;
  wIntensity        : word;
  wSOMDState        : word;
  //
  fIntensity        : real;
  //
  i                 : integer;
  cBuffer           : string;


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

  procedure GetWriteAndModify_VUV_VIR_Data (cVUV_VIRType: string; iVUV_VIR_Slot: integer; IsVIR: boolean);
  var
    TrgLvlUpper, TrgLvlLower, TrgLvlRes : integer;
  begin
    iRetVal := SEPIA2_VUV_VIR_GetTriggerData (iDevIdx, iVUV_VIR_Slot, iFreqTrigSrc[IsVIR], iFreqDivIdx[IsVIR], iTrigLevel[IsVIR]);
    if Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_GetTriggerData', iDevIdx, iVUV_VIR_Slot)
    then begin
      writeln (f, cVUV_VIRType:4,     ' TrigSrcIdx    =      ', iFreqTrigSrc[IsVIR]:3);
      writeln (f, cVUV_VIRType:4,     ' FreqDivIdx    =      ', iFreqDivIdx[IsVIR]:3);
      writeln (f, cVUV_VIRType:4,     ' TrigLevel     =    ',   iTrigLevel[IsVIR]:5);
      //
      iRetVal := SEPIA2_VUV_VIR_GetIntensity (iDevIdx, iVUV_VIR_Slot, iIntensity[IsVIR]);
      if Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_GetIntensity', iDevIdx, iVUV_VIR_Slot)
      then begin
        writeln (f, cVUV_VIRType:4,   ' Intensity     =      ',   0.1*iIntensity[IsVIR]:5:1, ' %');
        //
        iRetVal := SEPIA2_VUV_VIR_GetFan (iDevIdx, iVUV_VIR_Slot, bFanRunning[IsVIR]);
        if Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_GetFan', iDevIdx, iVUV_VIR_Slot)
        then begin
          writeln (f, cVUV_VIRType:4, ' FanRunning    =        ', BoolToStr(bFanRunning[IsVIR], true));
        end;
      end;
    end;
    //
    iRetVal := SEPIA2_VUV_VIR_GetTrigLevelRange (iDevIdx, iVUV_VIR_Slot, TrgLvlUpper, TrgLvlLower, TrgLvlRes);
    if Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_GetTrigLevelRange', iDevIdx, iVUV_VIR_Slot)
    then begin
      iFreqTrigSrc[IsVIR] := ifthen(iFreqTrigSrc[IsVIR] = 1, 0, 1);
      iFreqDivIdx[IsVIR]  := ifthen(iFreqDivIdx[IsVIR] = 2, 1, 2);
      iTrigLevel[IsVIR]   := EnsureRange (50 - iTrigLevel[IsVIR], TrgLvlLower, TrgLvlUpper);
      iIntensity[IsVIR]   := 1000 - iIntensity[IsVIR];
      bFanRunning[IsVIR]  := not bFanRunning[IsVIR];
    end
    else begin
      iFreqTrigSrc[IsVIR] :=    1;
      iFreqDivIdx[IsVIR]  :=    2;
      iTrigLevel[IsVIR]   := -350;
      iIntensity[IsVIR]   :=  440;
      bFanRunning[IsVIR]  := true;
    end;
  end;

  procedure Read_VUV_VIR_Data (IsVIR: boolean);
  begin
    readln (f, cDummy, iFreqTrigSrc[IsVIR]);
    readln (f, cDummy, iFreqDivIdx[IsVIR]);
    readln (f, cDummy, iTrigLevel[IsVIR]);
    readln (f, cDummy, fIntensity);
    iIntensity[IsVIR]  := Round (10 * fIntensity);
    readln (f, cDummy, cTemp);
    bFanRunning[IsVIR] := StrToBool(trim(cTemp));
  end;

  procedure Set_VUV_VIR_Data (cVUV_VIRType: string; iVUV_VIR_Slot: integer; IsVIR: boolean);
  begin
    iRetVal := SEPIA2_VUV_VIR_SetTriggerData (iDevIdx, iVUV_VIR_Slot, iFreqTrigSrc[IsVIR], iFreqDivIdx[IsVIR], iTrigLevel[IsVIR]);
    if Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_SetTriggerData', iDevIdx, iVUV_VIR_Slot)
    then begin
      iRetVal := SEPIA2_VUV_VIR_SetIntensity (iDevIdx, iVUV_VIR_Slot, iIntensity[IsVIR]);
      if Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_SetIntensity', iDevIdx, iVUV_VIR_Slot)
      then begin
        iRetVal := SEPIA2_VUV_VIR_SetFan (iDevIdx, iVUV_VIR_Slot, bFanRunning[IsVIR]);
        Sepia2FunctionSucceeds(iRetVal, 'VUV_VIR_SetFan', iDevIdx, iVUV_VIR_Slot)
      end;
    end;
    //
    writeln ('     ', cVUV_VIRType:4, ' TrigSrcIdx     =      ',   iFreqTrigSrc[IsVIR]:3);
    writeln ('     ', cVUV_VIRType:4, ' FreqDivIdx     =      ',   iFreqDivIdx[IsVIR]:3);
    writeln ('     ', cVUV_VIRType:4, ' TrigLevel      =    ',     iTrigLevel[IsVIR]:5, ' mV');
    writeln ('     ', cVUV_VIRType:4, ' Intensity      =      ',   0.1*iIntensity[IsVIR]:5:1, ' %');
    writeln ('     ', cVUV_VIRType:4, ' FanRunning     =        ', BoolToStr(bFanRunning[IsVIR], true));
    //
    writeln;
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
    bNoWait        := FindCmdLineSwitch (STR_CMDLINEOPTION_NO_WAIT,     true);
    //
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
    end;
    //
  {$endregion}
  //
  if (bSepia2ImportLibOK)
  then begin
    writeln; writeln;
    writeln ('     PQLaserDrv   Set SOME Values Demo : ');
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
      if Sepia2FunctionSucceeds(iRetVal, 'USB_OpenDevice', iDevIdx)
      then begin
        writeln ('     Product Model  = ''', cProductModel, '''');
        writeln;
        writeln (STR_SEPARATORLINE);
        writeln;
        iRetVal := SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion);
        if Sepia2FunctionSucceeds(iRetVal, 'FWR_GetVersion', iDevIdx)
        then begin
          writeln ('     FW-Version     = ', cFWVersion);
        end;
        //
        iRetVal := SEPIA2_USB_GetStrDescriptor  (iDevIdx, cDescriptor);
        if Sepia2FunctionSucceeds(iRetVal, 'USB_GetStrDescriptor', iDevIdx)
        then begin
          writeln ('     USB Index      = ', iDevIdx);
          writeln ('     USB Descriptor = ', cDescriptor);
          writeln ('     Serial Number  = ''', cSepiaSerNo, '''');
        end;
        writeln;
        writeln (STR_SEPARATORLINE);
        writeln; writeln;
        //
        // get sepia's module map and initialise datastructures for all library functions
        // there are two different ways to do so:
        //
        // first:  if sepia was not touched since last power on, it doesn't need to be restarted
        //
        try
          //
          iRetVal := SEPIA2_FWR_GetModuleMap (iDevIdx, SEPIA2_NO_RESTART, iModuleCount);
          //
          // second: in case of changes with soft restart:
          // iRetVal := SEPIA2_FWR_GetModuleMap (iDevIdx, SEPIA2_RESTART, iModuleCount);
          //
          if Sepia2FunctionSucceeds(iRetVal, 'FWR_GetModuleMap', iDevIdx)
          then begin
            //
            // this is to inform us about possible error conditions during sepia's last startup
            //
            iRetVal := SEPIA2_FWR_GetLastError (iDevIdx, iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond);
            if Sepia2FunctionSucceeds(iRetVal, 'FWR_GetLastError', iDevIdx)
            then begin
              if not HasFWError (iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond, 'Firmware error detected:')
              then begin
                //
                {$region 'now look for SOM(D), SLM, VUV/VIR modules, take always the first'}
                  //
                  // now look for SOM(D), SLM, VUV/VIR modules, take always the first
                  //
                  for i:=0 to iModuleCount-1
                  do begin
                    iRetVal := SEPIA2_FWR_GetModuleInfoByMapIdx (iDevIdx, i, iSlotNr, bIsPrimary, bIsBackPlane, bHasUptimeCounter);
                    if Sepia2FunctionSucceeds(iRetVal, 'FWR_GetModuleInfoByMapIdx', iDevIdx, i)
                    then begin
                      if bIsPrimary and not bIsBackPlane
                      then begin
                        iRetVal := SEPIA2_COM_GetModuleType (iDevIdx, iSlotNr, SEPIA2_PRIMARY_MODULE, iModuleType);
                        if Sepia2FunctionSucceeds(iRetVal, 'COM_GetModuleType', iDevIdx, iSlotNr)
                        then begin
                          case iModuleType of
                            SEPIA2OBJECT_SOM,
                            SEPIA2OBJECT_SOMD: begin
                              if not bSOM_Found
                              then begin
                                bSOM_Found := true;
                                iSOM_Slot  := iSlotNr;
                                iSOMModuleType := iModuleType;
                                bIsSOMDModule  := (iModuleType = SEPIA2OBJECT_SOMD);
                                //
                                iRetVal := SEPIA2_COM_GetSerialNumber(iDevIdx, iSOM_Slot, SEPIA2_PRIMARY_MODULE, cSOMSerNr);
                                if Sepia2FunctionSucceeds(iRetVal, 'COM_GetSerialNumber', iDevIdx, iSOM_Slot)
                                then begin
                                  SEPIA2_COM_DecodeModuleTypeAbbr (iSOMModuleType, cSOMType);
                                  cSOMType := LeftStr (cSOMType + '  ', 4);
                                  //
                                  if (bIsSOMDModule)
                                  then begin
                                    iRetVal := SEPIA2_SOMD_GetStatusError (iDevIdx, iSOM_Slot, wSOMDState, iSOMDErrorCode);
                                    Sepia2FunctionSucceeds(iRetVal, 'SOMD_GetStatusError', iDevIdx, iSOM_Slot);
                                  end;
                                end;
                                //
                              end;
                            end;

                            SEPIA2OBJECT_SLM: begin
                              if not bSLM_Found
                              then begin
                                bSLM_Found := true;
                                iSLM_Slot  := iSlotNr;
                                iRetVal := SEPIA2_COM_GetSerialNumber(iDevIdx, iSLM_Slot, SEPIA2_PRIMARY_MODULE, cSLMSerNr);
                                Sepia2FunctionSucceeds(iRetVal, 'COM_GetSerialNumber', iDevIdx, iSLM_Slot);
                              end;
                            end;
                            SEPIA2OBJECT_VUV: begin
                              if not bVUV_Found
                              then begin
                                bVUV_Found := true;
                                iVUV_Slot  := iSlotNr;
                                iRetVal := SEPIA2_COM_GetSerialNumber(iDevIdx, iVUV_Slot, SEPIA2_PRIMARY_MODULE, cVUVSerNr);
                                Sepia2FunctionSucceeds(iRetVal, 'COM_GetSerialNumber', iDevIdx, iVUV_Slot);
                              end;
                            end;
                            SEPIA2OBJECT_VIR: begin
                              if not bVIR_Found
                              then begin
                                bVIR_Found := true;
                                iVIR_Slot  := iSlotNr;
                                iRetVal := SEPIA2_COM_GetSerialNumber(iDevIdx, iVIR_Slot, SEPIA2_PRIMARY_MODULE, cVIRSerNr);
                                Sepia2FunctionSucceeds(iRetVal, 'COM_GetSerialNumber', iDevIdx, iVIR_Slot);
                              end;
                            end;
                            SEPIA2OBJECT_PRI: begin
                              if not bPRI_Found
                              then begin
                                bPRI_Found := true;
                                iPRI_Slot  := iSlotNr;
                                //
                                iRetVal := SEPIA2_PRI_GetConstants(iDevIdx, iPRI_Slot, PRIConst);
                                if (Sepia2FunctionSucceeds(iRetVal, 'PRI_GetConstants', iDevIdx, iPRI_Slot))
                                then begin
                                  iRetVal := SEPIA2_COM_GetSerialNumber(iDevIdx, iPRI_Slot, SEPIA2_PRIMARY_MODULE, cPRISerNr);
                                  Sepia2FunctionSucceeds(iRetVal, 'COM_GetSerialNumber', iDevIdx, iPRI_Slot);
                                end;
                              end;
                            end;
                          end;
                        end;
                      end;
                    end;
                  end;
                  //
                {$endregion 'now look for SOM(D), SLM, VUV/VIR, PRI modules, take always the first'}
                //
                if trim(cSOMType) = ''
                then begin
                  SEPIA2_COM_DecodeModuleTypeAbbr (iSOMModuleType, cSOMType);
                end;
                //
                SEPIA2_COM_DecodeModuleTypeAbbr (SEPIA2OBJECT_SLM, cSLMType);
                SEPIA2_COM_DecodeModuleTypeAbbr (SEPIA2OBJECT_VUV, cVUVType);
                SEPIA2_COM_DecodeModuleTypeAbbr (SEPIA2OBJECT_VIR, cVIRType);
                SEPIA2_COM_DecodeModuleTypeAbbr (SEPIA2OBJECT_PRI, cPRIType);
                //
                // let all module types be exact 4 characters long:
                cSOMType := LeftStr (cSOMType + '  ', 4);
                cSLMType := LeftStr (cSLMType + '  ', 4);
                cVUVType := LeftStr (cVUVType + '  ', 4);
                cVIRType := LeftStr (cVIRType + '  ', 4);
                cPRIType := LeftStr (cPRIType + '  ', 4);
                //
                //
                //
                if FileExists (FNAME) // we want to restore the changed values ...
                then begin
                  // ... so we have to read the original data from file
                  //
                  AssignFile (f, FNAME);
                  Reset(f);
                  //
                  readln (f, cDummy, cTemp);
                  bSOM_FFound := StrToBool(trim(cTemp));
                  if bSOM_FFound <> bSOM_Found then
                  begin
                    writeln;
                    CloseFile (f);
                    writeln ('     device configuration probably changed:');
                    writeln ('     couldn''t process original data as read from file ''', FNAME, '''');
                    writeln ('     file ', ifthen (bSOM_FFound, 'contains', 'doesn''t contain'), ' SOM data, but');
                    writeln ('     device has currently ', ifthen (bSOM_Found, 'a', 'no'), ' SOM module');
                    writeln;
                    writeln ('     demo execution aborted.');
                    writeln; writeln;
                    writeln ('press RETURN...');
                    readln;
                    halt(1);
                  end;
                  //
                  if bSOM_FFound then
                  begin
                    readln (f, cDummy, iSOM_FSlot);
                    readln (f, cDummy, cSOMFSerNr);
                    if (iSOM_FSlot <> iSOM_Slot) or (trim(cSOMFSerNr) <> trim(cSOMSerNr)) then
                    begin
                      writeln;
                      CloseFile (f);
                      writeln ('     device configuration probably changed:');
                      writeln ('     couldn''t process original data as read from file ''', FNAME, '''');
                      writeln ('     file data on the slot or serial number of the SOM module differs');
                      writeln;
                      writeln ('     demo execution aborted.');
                      writeln; writeln;
                      writeln ('press RETURN...');
                      readln;
                      halt(1);
                    end;
                    //
                    readln (f, cDummy, iFreqTrigIdx);      // 'SOM FreqTrigIdx   ='
                    if (bIsSOMDModule and (iFreqTrigIdx < ord (SEPIA2_SOM_INT_OSC_A)))
                    then begin
                      readln (f, cDummy, cTemp);           // 'SOMD TrigSynchron ='
                      bSynchronize := StrToBool(trim(cTemp));
                    end
                    else bSynchronize := false;
                    //
                    readln (f, cDummy, wDivider);          // 'SOM Divider       ='
                    readln (f, cDummy, bytePreSync);       // 'SOM PreSync       ='
                    readln (f, cDummy, byteMaskSync);      // 'SOM MaskSync      ='
                    //
                    readln (f, cDummy, byteOutEnable);     // 'SOM Output Enable ='
                    readln (f, cDummy, byteSyncEnable);    // 'SOM Sync Enable   ='
                    readln (f, cDummy, cTemp);             // 'SOM Sync Inverse  ='
                    bSyncInverse := StrToBool(trim(cTemp));
                    //
                    for i:=1 to 8 do
                    begin
                      readln (f, cDummy, lBurstChannels[i]); // 'SOM BurstLength 1 ='
                    end;
                  end;
                  //
                  //
                  //
                  readln (f, cDummy, cTemp);
                  bSLM_FFound := StrToBool(trim(cTemp));
                  if bSLM_FFound <> bSLM_Found then
                  begin
                    writeln;
                    CloseFile (f);
                    writeln ('     device configuration probably changed:');
                    writeln ('     couldn''t process original data as read from file ''', FNAME, '''');
                    writeln ('     file ', ifthen (bSLM_FFound, 'contains', 'doesn''t contain'), ' SLM data, but');
                    writeln ('     device has currently ', ifthen (bSLM_Found, 'a', 'no'), ' SLM module');
                    writeln;
                    writeln ('     demo execution aborted.');
                    writeln; writeln;
                    writeln ('press RETURN...');
                    readln;
                    halt(1);
                  end;
                  //
                  if bSLM_FFound then
                  begin
                    readln (f, cDummy, iSLM_FSlot);
                    readln (f, cDummy, cSLMFSerNr);
                    if (iSLM_FSlot <> iSLM_Slot) or (trim(cSLMFSerNr) <> trim(cSLMSerNr)) then
                    begin
                      writeln;
                      CloseFile (f);
                      writeln ('     device configuration probably changed:');
                      writeln ('     couldn''t process original data as read from file ''', FNAME, '''');
                      writeln ('     file data on the slot or serial number of the SLM module differs');
                      writeln;
                      writeln ('     demo execution aborted.');
                      writeln; writeln;
                      writeln ('press RETURN...');
                      readln;
                      halt(1);
                    end;
                    //
                    readln (f, cDummy, iFreqIdx);          // 'SLM FreqTrigIdx   ='
                    readln (f, cDummy, cTemp);             // 'SLM Pulse Mode    ='
                    bPulseMode := StrToBool(trim(cTemp));
                    //
                    readln (f, cDummy, fIntensity);        // 'SLM Intensity     ='
                    wIntensity := Round (10 * fIntensity);
                    //
                  end;
                  //
                  //
                  //
                  readln (f, cDummy, cTemp);
                  bVUV_FFound := StrToBool(trim(cTemp));
                  if bVUV_FFound <> bVUV_Found then
                  begin
                    writeln;
                    CloseFile (f);
                    writeln ('     device configuration probably changed:');
                    writeln ('     couldn''t process original data as read from file ''', FNAME, '''');
                    writeln ('     file ', ifthen (bVUV_FFound, 'contains', 'doesn''t contain'), ' VisUV data, but');
                    writeln ('     device has currently ', ifthen (bVUV_Found, 'a', 'no'), ' VisUV module');
                    writeln;
                    writeln ('     demo execution aborted.');
                    writeln; writeln;
                    writeln ('press RETURN...');
                    readln;
                    halt(1);
                  end;
                  //
                  if bVUV_FFound then
                  begin
                    readln (f, cDummy, iVUV_FSlot);
                    readln (f, cDummy, cVUVFSerNr);
                    if (iVUV_FSlot <> iVUV_Slot) or (trim(cVUVFSerNr) <> trim(cVUVSerNr)) then
                    begin
                      writeln;
                      CloseFile (f);
                      writeln ('     device configuration probably changed:');
                      writeln ('     couldn''t process original data as read from file ''', FNAME, '''');
                      writeln ('     file data on the slot or serial number of the VisUV module differs');
                      writeln;
                      writeln ('     demo execution aborted.');
                      writeln; writeln;
                      writeln ('press RETURN...');
                      readln;
                      halt(1);
                    end;
                    //
                    Read_VUV_VIR_Data (IS_A_VUV);
                    //
                  end;
                  //
                  //
                  //
                  readln (f, cDummy, cTemp);
                  bVIR_FFound := StrToBool(trim(cTemp));
                  if bVIR_FFound <> bVIR_Found then
                  begin
                    writeln;
                    CloseFile (f);
                    writeln ('     device configuration probably changed:');
                    writeln ('     couldn''t process original data as read from file ''', FNAME, '''');
                    writeln ('     file ', ifthen (bVIR_FFound, 'contains', 'doesn''t contain'), ' VisIR data, but');
                    writeln ('     device has currently ', ifthen (bVIR_Found, 'a', 'no'), ' VisIR module');
                    writeln;
                    writeln ('     demo execution aborted.');
                    writeln; writeln;
                    writeln ('press RETURN...');
                    readln;
                    halt(1);
                  end;
                  //
                  if bVIR_FFound then
                  begin
                    readln (f, cDummy, iVIR_FSlot);
                    readln (f, cDummy, cVIRFSerNr);
                    if (iVIR_FSlot <> iVIR_Slot) or (trim(cVIRFSerNr) <> trim(cVIRSerNr)) then
                    begin
                      writeln;
                      CloseFile (f);
                      writeln ('     device configuration probably changed:');
                      writeln ('     couldn''t process original data as read from file ''', FNAME, '''');
                      writeln ('     file data on the slot or serial number of the VisIR module differs');
                      writeln;
                      writeln ('     demo execution aborted.');
                      writeln; writeln;
                      writeln ('press RETURN...');
                      readln;
                      halt(1);
                    end;
                    //
                    Read_VUV_VIR_Data (IS_A_VIR);
                    //
                  end;
                  //
                  //
                  //
                  readln (f, cDummy, cTemp);
                  bPRI_FFound := StrToBool(trim(cTemp));
                  if bPRI_FFound <> bPRI_Found then
                  begin
                    writeln;
                    CloseFile (f);
                    writeln ('     device configuration probably changed:');
                    writeln ('     couldn''t process original data as read from file ''', FNAME, '''');
                    writeln ('     file ', ifthen (bPRI_FFound, 'contains', 'doesn''t contain'), ' Prima data, but');
                    writeln ('     device has currently ', ifthen (bPRI_Found, 'a', 'no'), ' Prima module');
                    writeln;
                    writeln ('     demo execution aborted.');
                    writeln; writeln;
                    writeln ('press RETURN...');
                    readln;
                    halt(1);
                  end;
                  //
                  if bPRI_FFound then
                  begin
                    readln (f, cDummy, iPRI_FSlot);
                    readln (f, cDummy, cPRIFSerNr);
                    if (iPRI_FSlot <> iPRI_Slot) or (trim(cPRIFSerNr) <> trim(cPRISerNr)) then
                    begin
                      writeln;
                      CloseFile (f);
                      writeln ('     device configuration probably changed:');
                      writeln ('     couldn''t process original data as read from file ''', FNAME, '''');
                      writeln ('     file data on the slot or serial number of the Prima module differs');
                      writeln;
                      writeln ('     demo execution aborted.');
                      writeln; writeln;
                      writeln ('press RETURN...');
                      readln;
                      halt(1);
                    end;
                    //
                    readln (f, cDummy, iOpModeIdx);          // 'PRI OperModeIdx   ='
                    readln (f, cDummy, iWL_Idx);             // 'PRI WavelengthIdx ='
                    readln (f, cDummy, fIntensity);          // 'PRI Intensity     ='
                    wIntensity := Round (10 * fIntensity);
                    //
                  end;
                  //
                  //
                  // ... and delete it afterwards
                  CloseFile (f);
                  writeln ('     original data as read from file ''', FNAME, ''':');
                  writeln ('     (file was deleted after processing)');
                  writeln;
                  DeleteFile (FNAME);
                end
                else begin // file doesn't exist!
                  // ... so we have to save the original data in a file
                  // ... and may then set arbitrary values
                  //
                  AssignFile (f, FNAME);
                  {$I-}
                    Rewrite (f);
                  {$I+}
                  if IOResult <> 0 then
                  begin
                    writeln ('     You tried to start this demo in a write protected directory.');
                    writeln ('     demo execution aborted.');
                    writeln; writeln;
                    writeln ('press RETURN...');
                    readln;
                    halt(1);
                  end;
                  //
                  //
                  writeln (f, cSOMType:4, ' ModuleFound   =        ', BoolToStr(bSOM_Found, true));
                  if bSOM_Found
                  then begin
                    //
                    // SOM / SOMD
                    //
                    writeln (f, cSOMType:4, ' SlotID        =      ', iSOM_Slot:3);
                    writeln (f, cSOMType:4, ' SerialNumber  = ',      cSOMSerNr:8);
                    //
                    // FreqTrigMode
                    bSynchronize := false;
                    if (bIsSOMDModule) then
                      iRetVal := SEPIA2_SOMD_GetFreqTrigMode (iDevIdx, iSOM_Slot, iFreqTrigIdx, bSynchronize)
                    else
                      iRetVal := SEPIA2_SOM_GetFreqTrigMode  (iDevIdx, iSOM_Slot, iFreqTrigIdx);
                    //
                    if Sepia2FunctionSucceeds(iRetVal, ifthen (bIsSOMDModule, 'SOMD', 'SOM') + '_GetModuleType', iDevIdx, iSOM_Slot)
                    then begin
                      writeln (f, cSOMType:4, ' FreqTrigIdx   =      ', iFreqTrigIdx:3);
                      if (bIsSOMDModule and (iFreqTrigIdx < ord (SEPIA2_SOM_INT_OSC_A))) then
                        writeln (f, cSOMType:4, ' TrigSynchron  =        ', bSynchronize);
                    end;
                    iFreqTrigIdx := ord (SEPIA2_SOM_INT_OSC_C);
                    //
                    // BurstValues
                    iRetVal := SEPIA2_SOM_GetBurstValues  (iDevIdx, iSOM_Slot, wDivider, bytePreSync, byteMaskSync);
                    if Sepia2FunctionSucceeds(iRetVal, 'SOM_GetBurstValues', iDevIdx, iSOM_Slot)
                    then begin
                      writeln (f, cSOMType:4, ' Divider       =      ', wDivider:3);
                      writeln (f, cSOMType:4, ' PreSync       =      ', bytePreSync:3);
                      writeln (f, cSOMType:4, ' MaskSync      =      ', byteMaskSync:3);
                    end;
                    wDivider     := 200;
                    bytePreSync  :=  10;
                    byteMaskSync :=   1;
                    //
                    // Out'n'SyncEnable
                    iRetVal := SEPIA2_SOM_GetOutNSyncEnable (iDevIdx, iSOM_Slot, byteOutEnable, byteSyncEnable, bSyncInverse);
                    if Sepia2FunctionSucceeds(iRetVal, 'SOM_GetOutNSyncEnable', iDevIdx, iSOM_Slot)
                    then begin
                      writeln (f, cSOMType:4, ' Output Enable =     0x',  IntToHex (byteOutEnable,  2):2);
                      writeln (f, cSOMType:4, ' Sync Enable   =     0x',  IntToHex (byteSyncEnable, 2):2);
                      writeln (f, cSOMType:4, ' Sync Inverse  =        ', BoolToStr(bSyncInverse, true));
                    end;
                    byteOutEnable  :=  $A5;
                    byteSyncEnable :=  $93;
                    bSyncInverse   :=  not bSyncInverse;
                    //
                    // BurstLengthArray
                    iRetVal := SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSOM_Slot, lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7], lBurstChannels[8]);
                    if Sepia2FunctionSucceeds(iRetVal, 'SOM_GetBurstLengthArray', iDevIdx, iSOM_Slot)
                    then begin
                      for i:=1 to 8 do
                        writeln (f, cSOMType, ' BurstLength ', i, ' = ', lBurstChannels[i]:8);
                      // just change places of burstlenght channel 2 & 3
                      lTemp             := lBurstChannels[3];
                      lBurstChannels[3] := lBurstChannels[2];
                      lBurstChannels[2] := lTemp;
                    end
                    else begin
                      lBurstChannels[2] := 22;
                      lBurstChannels[3] := 33;
                    end;
                  end;
                  //
                  //
                  writeln (f, cSLMType:4, ' ModuleFound   =        ', BoolToStr(bSLM_Found, true));
                  if bSLM_Found
                  then begin
                    //
                    // SLM
                    //
                    writeln (f, cSLMType:4, ' SlotID        =      ', iSLM_Slot:3);
                    writeln (f, cSLMType:4, ' SerialNumber  = ',      cSLMSerNr:8);
                    iRetVal := SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSLM_Slot, wIntensity);
                    if Sepia2FunctionSucceeds(iRetVal, 'SLM_GetIntensityFineStep', iDevIdx, iSLM_Slot)
                    then begin
                      iRetVal := SEPIA2_SLM_GetPulseParameters (iDevIdx, iSLM_Slot, iFreqIdx, bPulseMode, iHead);
                      Sepia2FunctionSucceeds(iRetVal, 'SLM_GetPulseParameters', iDevIdx, iSLM_Slot)
                    end;
                    if (iRetVal = SEPIA2_ERR_NO_ERROR)
                    then begin
                      writeln (f, cSLMType:4, ' FreqTrigIdx   =        ', iFreqIdx:1);
                      writeln (f, cSLMType:4, ' Pulse Mode    =        ', BoolToStr(bPulseMode, true));
                      writeln (f, cSLMType:4, ' Intensity     =      ',   0.1*wIntensity:5:1, ' %');
                      //
                      iFreqIdx         := (2 + iFreqIdx) mod SEPIA2_SLM_FREQ_TRIGMODE_COUNT;
                      bPulseMode    := not bPulseMode;
                      wIntensity    := 1000 - wIntensity;
                    end
                    else begin
                      iFreqIdx         := ord (SEPIA2_SLM_FREQ_20MHZ);
                      bPulseMode    := true;
                      wIntensity    := 440;
                    end;
                    //
                  end;
                  //
                  //
                  writeln (f, cVUVType:4, ' ModuleFound   =        ', BoolToStr(bVUV_Found, true));
                  if bVUV_Found
                  then begin
                    //
                    // VisUV
                    //
                    writeln (f, cVUVType:4, ' SlotID        =      ', iVUV_Slot:3);
                    writeln (f, cVUVType:4, ' SerialNumber  = ',      cVUVSerNr:8);
                    //
                    GetWriteAndModify_VUV_VIR_Data (cVUVType, iVUV_Slot, IS_A_VUV);
                  end;
                  //
                  //
                  writeln (f, cVIRType:4, ' ModuleFound   =        ', BoolToStr(bVIR_Found, true));
                  if bVIR_Found
                  then begin
                    //
                    // VisIR
                    //
                    writeln (f, cVIRType:4, ' SlotID        =      ', iVIR_Slot:3);
                    writeln (f, cVIRType:4, ' SerialNumber  = ',      cVIRSerNr:8);
                    //
                    GetWriteAndModify_VUV_VIR_Data (cVIRType, iVIR_Slot, IS_A_VIR);
                  end;
                  //
                  writeln (f, cPRIType:4, ' ModuleFound   =        ', BoolToStr(bPRI_Found, true));
                  if bPRI_Found
                  then begin
                    //
                    // PRI
                    //
                    writeln (f, cPRIType:4, ' SlotID        =      ', iPRI_Slot:3);
                    writeln (f, cPRIType:4, ' SerialNumber  = ',      cPRISerNr:8);
                    //
                    iRetVal := SEPIA2_PRI_GetOperationMode (iDevIdx, iPRI_Slot, iOpModeIdx);
                    if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetOperationMode', iDevIdx, iPRI_Slot)
                    then begin
                      iRetVal := SEPIA2_PRI_GetWavelengthIdx (iDevIdx, iPRI_Slot, iWL_Idx);
                      if Sepia2FunctionSucceeds(iRetVal, 'PRI_GetWavelengthIdx', iDevIdx, iPRI_Slot)
                      then begin
                        iRetVal := SEPIA2_PRI_GetIntensity (iDevIdx, iPRI_Slot, iWL_Idx, wIntensity);
                        Sepia2FunctionSucceeds(iRetVal, 'PRI_GetIntensity', iDevIdx, iPRI_Slot, iWL_Idx);
                      end;
                    end;
                    if (iRetVal = SEPIA2_ERR_NO_ERROR)
                    then begin
                      writeln (f, cPRIType:4, ' OperModeIdx   =        ', iOpModeIdx);
                      writeln (f, cPRIType:4, ' WavelengthIdx =        ', iWL_Idx:1);
                      writeln (f, cPRIType:4, ' Intensity     =      ',   0.1*wIntensity:5:1, ' %');
                      //

                      iOpModeIdx    := ifthen (iOpModeIdx = PRIConst.PrimaOpModBroad, PRIConst.PrimaOpModNarrow, PRIConst.PrimaOpModBroad);
                      iWL_Idx       := (iWL_Idx + 1) mod PRIConst.PrimaWLCount;
                      wIntensity    := 1000 - wIntensity;
                    end
                    else begin
                      iOpModeIdx    := ifthen (iOpModeIdx = PRIConst.PrimaOpModBroad, PRIConst.PrimaOpModNarrow, PRIConst.PrimaOpModBroad);
                      iWL_Idx       := 0;
                      wIntensity    := 440;
                    end;
                    //
                  end;
                  //
                  //
                  //
                  CloseFile (f);
                  writeln ('     original data was stored in file ''', FNAME, '''.');
                  writeln ('     changed data as follows:');
                  writeln;
                end;
                //
                //
                //
                // and here we finally set the new (resp. old) values
                //
                if bSOM_Found
                then begin
                  if (iSOMModuleType = SEPIA2OBJECT_SOM)
                  then begin
                    iRetVal := SEPIA2_SOM_SetFreqTrigMode (iDevIdx, iSOM_Slot, iFreqTrigIdx);
                    Sepia2FunctionSucceeds(iRetVal, 'SOM_SetFreqTrigMode', iDevIdx, iSOM_Slot);
                  end
                  else begin
                    iRetVal := SEPIA2_SOMD_SetFreqTrigMode    (iDevIdx, iSOM_Slot, iFreqTrigIdx, bSynchronize);
                    if Sepia2FunctionSucceeds(iRetVal, 'SOMD_SetFreqTrigMode', iDevIdx, iSOM_Slot)
                    then begin
                      iRetVal := SEPIA2_SOMD_GetStatusError (iDevIdx, iSOM_Slot, wSOMDState, iSOMDErrorCode);
                      Sepia2FunctionSucceeds(iRetVal, 'SOMD_GetStatusError', iDevIdx, iSOM_Slot)
                    end;
                  end;
                  //
                  if (iRetVal = SEPIA2_ERR_NO_ERROR)
                  then begin
                    iRetVal := SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSOM_Slot, iFreqTrigIdx, cFreqTrigMode);
                    if Sepia2FunctionSucceeds(iRetVal, 'SOM_DecodeFreqTrigMode', iDevIdx, iSOM_Slot)
                    then begin
                      writeln ('     ', cSOMType:4, ' FreqTrigMode   =      ''', cFreqTrigMode, '''');
                      if (bIsSOMDModule and (iFreqTrigIdx < ord (SEPIA2_SOM_INT_OSC_A)))
                      then begin
                        writeln ('     ', cSOMType:4, ' TrigSynchron   =        ', bSynchronize);
                      end;
                    end
                    else begin
                      writeln ('     ', cSOMType:4, ' FreqTrigMode          ??  (decoding error)');
                    end;
                  end
                  else begin
                    writeln ('     ', cSOMType:4, ' FreqTrigMode          ??  (reading error)');
                  end;
                  //
                  iRetVal := SEPIA2_SOM_SetBurstValues  (iDevIdx, iSOM_Slot, wDivider, bytePreSync, byteMaskSync);
                  if Sepia2FunctionSucceeds(iRetVal, 'SOM_SetBurstValues', iDevIdx, iSOM_Slot)
                  then begin
                    writeln ('     ', cSOMType:4, ' Divider        =      ', wDivider:3);
                    writeln ('     ', cSOMType:4, ' PreSync        =      ', bytePreSync:3);
                    writeln ('     ', cSOMType:4, ' MaskSync       =      ', byteMaskSync:3);
                  end;
                  //
                  iRetVal := SEPIA2_SOM_SetOutNSyncEnable (iDevIdx, iSOM_Slot, byteOutEnable, byteSyncEnable, bSyncInverse);
                  if Sepia2FunctionSucceeds(iRetVal, 'SOM_SetOutNSyncEnable', iDevIdx, iSOM_Slot)
                  then begin
                    writeln ('     ', cSOMType:4, ' Output Enable  =     0x',  IntToHex (byteOutEnable,  2):2);
                    writeln ('     ', cSOMType:4, ' Sync Enable    =     0x',  IntToHex (byteSyncEnable, 2):2);
                    writeln ('     ', cSOMType:4, ' Sync Inverse   =        ', BoolToStr(bSyncInverse, true));
                  end;
                  //
                  iRetVal := SEPIA2_SOM_SetBurstLengthArray (iDevIdx, iSOM_Slot, lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7], lBurstChannels[8]);
                  if Sepia2FunctionSucceeds(iRetVal, 'SOM_SetBurstLengthArray', iDevIdx, iSOM_Slot)
                  then begin
                    writeln ('     ', cSOMType:4, ' BurstLength 2  = ', lBurstChannels[2]:8);
                    writeln ('     ', cSOMType:4, ' BurstLength 3  = ', lBurstChannels[3]:8);
                  end;
                  //
                  writeln;
                end;
                //
                // SLM
                //
                if bSLM_Found
                then begin
                  iRetVal := SEPIA2_SLM_SetIntensityFineStep (iDevIdx, iSLM_Slot, wIntensity);
                  if Sepia2FunctionSucceeds(iRetVal, 'SLM_SetIntensityFineStep', iDevIdx, iSLM_Slot)
                  then begin
                    iRetVal := SEPIA2_SLM_SetPulseParameters (iDevIdx, iSLM_Slot, iFreqIdx, bPulseMode);
                    Sepia2FunctionSucceeds(iRetVal, 'SLM_SetPulseParameters', iDevIdx, iSLM_Slot)
                  end;

                  if (iRetVal = SEPIA2_ERR_NO_ERROR)
                  then begin
                    SEPIA2_SLM_DecodeFreqTrigMode (iFreqIdx, cFreqTrigMode);
                    if (iRetVal = SEPIA2_ERR_NO_ERROR)
                    then begin
                      writeln ('     ', cSLMType:4, ' FreqTrigMode   =      ''', cFreqTrigMode, '''');
                    end
                    else begin
                      writeln ('     ', cSLMType:4, ' FreqTrigMode   =       ??  (decoding error)');
                    end;
                    writeln ('     ', cSLMType:4,   ' Pulse Mode     =        ', BoolToStr(bPulseMode, true));
                    writeln ('     ', cSLMType:4,   ' Intensity      =      ',   0.1*wIntensity:5:1, ' %');
                  end
                  else begin
                    writeln ('     ', cSLMType:4,   ' FreqTrigMode   =       ??  (reading error)');
                    writeln ('     ', cSLMType:4,   ' Pulse Mode     =       ??  (reading error)');
                    writeln ('     ', cSLMType:4,   ' Intensity      =       ??  (reading error)');
                  end;
                  //
                  writeln;
                end;
                //
                // VisUV
                //
                if bVUV_Found
                then begin
                  Set_VUV_VIR_Data (cVUVType, iVUV_Slot, IS_A_VUV);
                end;
                //
                // VisIR
                //
                if bVIR_Found
                then begin
                  Set_VUV_VIR_Data (cVIRType, iVIR_Slot, IS_A_VIR);
                end;
                //
                // Prima
                //
                if bPRI_Found
                then begin
                  iRetVal := SEPIA2_PRI_SetOperationMode (iDevIdx, iPRI_Slot, iOpModeIdx);
                  if Sepia2FunctionSucceeds(iRetVal, 'PRI_SetOperationMode', iDevIdx, iPRI_Slot)
                  then begin
                    iRetVal := SEPIA2_PRI_SetWavelengthIdx (iDevIdx, iPRI_Slot, iWL_Idx);
                    if Sepia2FunctionSucceeds(iRetVal, 'PRI_SetWavelengthIdx', iDevIdx, iPRI_Slot)
                    then begin
                      iRetVal := SEPIA2_PRI_SetIntensity (iDevIdx, iPRI_Slot, iWL_Idx, wIntensity);
                      Sepia2FunctionSucceeds(iRetVal, 'PRI_SetIntensity', iDevIdx, iPRI_Slot, iWL_Idx);
                    end;
                  end;
                  if (iRetVal = SEPIA2_ERR_NO_ERROR)
                  then begin
                    iRetVal := SEPIA2_PRI_DecodeOperationMode (iDevIdx, iPRI_Slot, iOpModeIdx, cOperMode);
                    if (iRetVal = SEPIA2_ERR_NO_ERROR)
                    then begin
                      writeln ('     ', cPRIType:4, ' OperModeIdx    =        ', iOpModeIdx, '  ==> ''', trim(cOperMode), '''');
                    end
                    else begin
                      writeln ('     ', cPRIType:4, ' OperModeIdx    =        ', iOpModeIdx, '  ==>  ??  (decoding error)');
                    end;
                    //
                    iRetVal := SEPIA2_PRI_DecodeWavelength(iDevIdx, iPRI_Slot, iWL_Idx, iWL);
                    if (iRetVal = SEPIA2_ERR_NO_ERROR)
                    then begin
                      writeln ('     ', cPRIType:4, ' WavelengthIdx  =        ', iWL_Idx, '  ==> ', iWL, ' nm' );
                    end
                    else begin
                      writeln ('     ', cPRIType:4, ' WavelengthIdx  =        ', iWL_Idx, '  ==>  ??  (decoding error)');
                    end;

                    writeln ('     ', cPRIType:4,   ' Intensity      =      ',   0.1*wIntensity:5:1, ' %');
                  end
                  else begin
                    writeln ('     ', cPRIType:4,   ' OperationMode  =       ??  (reading error)');
                    writeln ('     ', cPRIType:4,   ' WavelengthIdx  =       ??  (reading error)');
                    writeln ('     ', cPRIType:4,   ' Intensity      =       ??  (reading error)');
                  end;
                  //
                  writeln;
                  //
                end;
                //
              end; // no error
            end; // get last FW error
          end  // get module map
          else begin
            iRetVal := SEPIA2_FWR_GetLastError (iDevIdx, iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond);
            if Sepia2FunctionSucceeds(iRetVal, 'FWR_GetLastError', iDevIdx)
            then begin
              HasFWError (iFWErrCode, iFWErrPhase, iFWErrLocation, iFWErrSlot, cFWErrCond, 'Firmware error detected:');
            end;
          end;
          //
        finally
          iRetVal := SEPIA2_FWR_FreeModuleMap (iDevIdx);
          Sepia2FunctionSucceeds(iRetVal, 'FWR_FreeModuleMap', iDevIdx)
        end;
      end; // open USB device
    finally
      iRetVal := SEPIA2_USB_CloseDevice (iDevIdx);
      Sepia2FunctionSucceeds(iRetVal, 'USB_CloseDevice', iDevIdx)
    end;
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
