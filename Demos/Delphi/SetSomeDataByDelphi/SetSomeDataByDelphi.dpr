//-----------------------------------------------------------------------------
//
//      SetSomeDataByDelphi.pas
//
//-----------------------------------------------------------------------------
//
//  Illustrates the functions exported by SEPIA2_Lib
//
//  Presumes to find a SOM 828 in slot 100 and a SLM 828 in slot 200
//
//  if there doesn't exist a file named "OrigData.txt"
//    it creates the file to save the original values
//    then sets new values for SOM and SLM
//  else
//    it sets original values for SOM and SLM from file and
//    deletes file.
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
//-----------------------------------------------------------------------------
//
program SetSomeDataByDelphi;

{$APPTYPE CONSOLE}

uses
  System.SysConst, System.SysUtils, System.StrUtils,
  Sepia2_ErrorCodes in '..\Shared_Delphi\Sepia2_ErrorCodes.pas',
  Sepia2_ImportUnit in '..\Shared_Delphi\Sepia2_ImportUnit.pas';

const
  FNAME             = 'OrigData.txt';

var
  iRetVal           : integer = SEPIA2_ERR_NO_ERROR;
  c                 : char;
  f                 : text;
  //
  cLibVersion       : string  = '';
  cProductModel     : string  = '';
  cSepiaSerNo       : string  = '';
  cFWVersion        : string  = '';
  cDescriptor       : string  = '';
  cFWErrCond        : string  = '';
  cErrString        : string  = '';
  cFWErrPhase       : string  = '';
  cSOMType          : string  = '';
  cSLMType          : string  = '';
  cFreqTrigMode     : string  = '';
  //
  cDummy            : string[20] = '';
  cTemp             : string  = '';
  cBuffer           : string;
  //
  lBurstChannels    : array  [1..SEPIA2_SOM_BURSTCHANNEL_COUNT] of longint = (0, 0, 0, 0, 0, 0, 0, 0);
  lTemp             : longint;
  //
  iDevIdx           : integer                                              =   0;
  iSOM_Slot         : integer                                              = 100;
  iSLM_Slot         : integer                                              = 200;
  //
  //
  iModuleCount      : integer;
  iSOMModuleType    : integer;
  iFWErrCode        : integer;
  iFWErrPhase       : integer;
  iFWErrLocation    : integer;
  iFWErrSlot        : integer;
  iFreqTrigMode     : integer;
  iHead             : integer;
  iFreq             : integer;
  iErrorCode        : integer;
  //
  // boolean
  bPulseMode        : boolean;
  bSyncInverse      : boolean;
  bSynchronize      : boolean;
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
  wSOMState         : word;
  //
  fIntensity        : real;
  //
  i                 : integer;

begin
  if (bSepia2ImportLibOK)
  then begin
    writeln; writeln;
    writeln ('     Sepia II   Set SOME Values Demo : ');
    writeln ('    =================================================');
    writeln; writeln;
    //
    // preliminaries: check library version
    //
    cLibVersion := 'Test';
    SEPIA2_LIB_GetVersion (cLibVersion);
    writeln ('     Lib-Version   = ', cLibVersion);

    if (StrLComp (PChar (cLibVersion), PChar (LIB_VERSION_REFERENCE), LIB_VERSION_COMPLEN) <> 0)
    then begin
      writeln;
      writeln ('     Warning: This demo application was built for version  ', LIB_VERSION_REFERENCE, 'xxx');
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
    iRetVal := SEPIA2_USB_OpenDevice (iDevIdx, cProductModel, cSepiaSerNo);
    if (iRetVal = SEPIA2_ERR_NO_ERROR)
    then begin
      SEPIA2_FWR_GetVersion (iDevIdx, cFWVersion);
      writeln ('     FW-Version    = ', cFWVersion);
      //
      SEPIA2_USB_GetStrDescriptor  (iDevIdx, cDescriptor);
      writeln ('     Descriptor    = ', cDescriptor);
      writeln ('     Serial Number = ''', cSepiaSerNo, '''');
      writeln ('     Product Model = ''', cProductModel, '''');
      writeln; writeln;
      writeln ('    =================================================');
      writeln; writeln;
      //
      // get sepia's module map and initialise datastructures for all library functions
      // there are two different ways to do so:
      //
      // first:  if sepia was not touched since last power on, it doesn't need to be restarted
      //
      iRetVal := SEPIA2_FWR_GetModuleMap (iDevIdx, SEPIA2_NO_RESTART, iModuleCount);
      //
      // second: in case of changes with soft restart:
      // iRetVal := SEPIA2_FWR_GetModuleMap (iDevIdx, SEPIA2_RESTART, iModuleCount);
      //
      if (iRetVal = SEPIA2_ERR_NO_ERROR)
      then begin
        iRetVal := SEPIA2_COM_GetModuleType (iDevIdx, iSOM_Slot, true, iSOMModuleType);
        if (iRetVal = SEPIA2_ERR_NO_ERROR)
        then begin
          SEPIA2_COM_DecodeModuleTypeAbbr (iSOMModuleType, cSOMType);
          cSOMType := LeftStr (cSOMType + '  ', 4);
          if (iSOMModuleType = SEPIA2OBJECT_SOMD)
          then
            SEPIA2_SOMD_GetStatusError (iDevIdx, iSOM_Slot, wSOMState, iErrorCode);
          //
          SEPIA2_COM_DecodeModuleTypeAbbr (SEPIA2OBJECT_SLM, cSLMType);
          cSLMType := LeftStr (cSLMType + '  ', 4);
        end;
      end;

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
            // we want to restore the changed values ...
            //
            if FileExists (FNAME)
            then begin
              // ... so we have to read the original data from file
              //
              AssignFile (f, FNAME);
              Reset(f);
              //
              readln (f, cDummy, iFreqTrigMode);     // 'SOM FreqTrigMode  ='
              if ((iSOMModuleType = SEPIA2OBJECT_SOMD) and (iFreqTrigMode < ord (SEPIA2_SOM_INT_OSC_A)))
              then begin
                readln (f, cDummy, cTemp);         // 'SOMD TrigSynchron ='
                i := 1;
                while (cTemp[i] = ' ')
                do begin
                  inc (i);
                end;
                bSynchronize := (cTemp[i] = 'T');
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
              i := 1;
              while (cTemp[i] = ' ')
              do begin
                inc (i);
              end;
              bSyncInverse := (cTemp[i] = 'T');
              //
              for i:=1 to 8 do
              begin
                readln (f, cDummy, lBurstChannels[i]); // 'SOM BurstLength 1 ='
              end;
              //
              readln (f, cDummy, iFreq);             // 'SLM FreqTrigMode  ='
              readln (f, cDummy, cTemp);             // 'SLM Pulse Mode    ='
              i := 1;
              while (cTemp[i] = ' ')
              do begin
                inc (i);
              end;
              bPulseMode := (cTemp[i] = 'T');
              //
              readln (f, cDummy, fIntensity);        // 'SLM Intensity     ='
              wIntensity := Round (10 * fIntensity);
              //
              // ... and delete it afterwards
              CloseFile (f);
              writeln ('     original data read from file ''', FNAME, '''');
              writeln;
              DeleteFile (FNAME);
            end
            else begin
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
              end;
              //
              // SOM / SOMD
              //
              // FreqTrigMode
              bSynchronize := false;
              if (iSOMModuleType = SEPIA2OBJECT_SOMD)
              then iRetVal := SEPIA2_SOMD_GetFreqTrigMode (iDevIdx, iSOM_Slot, iFreqTrigMode, bSynchronize)
              else iRetVal := SEPIA2_SOM_GetFreqTrigMode  (iDevIdx, iSOM_Slot, iFreqTrigMode);
              //
              if (iRetVal = SEPIA2_ERR_NO_ERROR)
              then begin
                writeln (f, cSOMType:4, ' FreqTrigMode  =      ', iFreqTrigMode:3);
                if ((iSOMModuleType = SEPIA2OBJECT_SOMD) and (iFreqTrigMode < ord (SEPIA2_SOM_INT_OSC_A)))
                then writeln (f, cSOMType:4, ' TrigSynchron  =        ', bSynchronize);
              end;
              iFreqTrigMode := ord (SEPIA2_SOM_INT_OSC_C);
              //
              // BurstValues
              iRetVal := SEPIA2_SOM_GetBurstValues  (iDevIdx, iSOM_Slot, wDivider, bytePreSync, byteMaskSync);
              if (iRetVal = SEPIA2_ERR_NO_ERROR)
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
              if (iRetVal = SEPIA2_ERR_NO_ERROR)
              then begin
                writeln (f, cSOMType:4, ' Output Enable =      $',  IntToHex (byteOutEnable,  2):2);
                writeln (f, cSOMType:4, ' Sync Enable   =      $',  IntToHex (byteSyncEnable, 2):2);
                writeln (f, cSOMType:4, ' Sync Inverse  =        ', bSyncInverse);
              end;
              byteOutEnable  :=  $A5;
              byteSyncEnable :=  $93;
              bSyncInverse   :=  not bSyncInverse;
              //
              // BurstLengthArray
              iRetVal := SEPIA2_SOM_GetBurstLengthArray (iDevIdx, iSOM_Slot, lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7], lBurstChannels[8]);
              if (iRetVal = SEPIA2_ERR_NO_ERROR)
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
              //
              //
              // SLM
              //
              iRetVal := SEPIA2_SLM_GetIntensityFineStep (iDevIdx, iSLM_Slot, wIntensity);
              if (iRetVal = SEPIA2_ERR_NO_ERROR)
              then begin
                iRetVal := SEPIA2_SLM_GetPulseParameters (iDevIdx, iSLM_Slot, iFreq, bPulseMode, iHead);
              end;
              if (iRetVal = SEPIA2_ERR_NO_ERROR)
              then begin
                writeln (f, cSLMType:4, ' FreqTrigMode  =        ', iFreq:1);
                writeln (f, cSLMType:4, ' Pulse Mode    =        ', bPulseMode);
                writeln (f, cSLMType:4, ' Intensity     =      ',   0.1*wIntensity:3:1, ' %');
                iFreq         := (2 + iFreq) mod SEPIA2_SLM_FREQ_TRIGMODE_COUNT;
                bPulseMode    := not bPulseMode;
                wIntensity    := 1000 - wIntensity;
              end
              else begin
                iFreq         := ord (SEPIA2_SLM_FREQ_20MHZ);
                bPulseMode    := true;
                wIntensity    := 440;
              end;
              //
              //
              CloseFile (f);
              writeln ('     original data stored in file ''', FNAME, '''');
              writeln;
            end;
            //
            // and here we finally set the new (resp. old) values
            //
            if (iSOMModuleType = SEPIA2OBJECT_SOM)
            then
              iRetVal := SEPIA2_SOM_SetFreqTrigMode    (iDevIdx, iSOM_Slot, iFreqTrigMode)
            else begin
              iRetVal := SEPIA2_SOMD_SetFreqTrigMode    (iDevIdx, iSOM_Slot, iFreqTrigMode, bSynchronize);
              iRetVal := SEPIA2_SOMD_GetStatusError (iDevIdx, iSOM_Slot, wSOMState, iErrorCode);
            end;
            //
            if (iRetVal = SEPIA2_ERR_NO_ERROR)
            then begin
              iRetVal := SEPIA2_SOM_DecodeFreqTrigMode (iDevIdx, iSOM_Slot, iFreqTrigMode, cFreqTrigMode);
              if (iRetVal = SEPIA2_ERR_NO_ERROR)
              then begin
                writeln ('     ', cSOMType:4, ' FreqTrigMode  =      ''', cFreqTrigMode, '''');
                if ((iSOMModuleType = SEPIA2OBJECT_SOMD) and (iFreqTrigMode < ord (SEPIA2_SOM_INT_OSC_A)))
                then begin
                  writeln ('     ', cSOMType:4, ' TrigSynchron  =        ', bSynchronize);
                end;
              end
              else begin
                writeln ('     ', cSOMType:4, ' FreqTrigMode         ??  (decoding error)');
              end;
            end
            else begin
              writeln ('     ', cSOMType:4, ' FreqTrigMode         ??  (reading error)');
            end;
            //
            iRetVal := SEPIA2_SOM_SetBurstValues  (iDevIdx, iSOM_Slot, wDivider, bytePreSync, byteMaskSync);
            if (iRetVal = SEPIA2_ERR_NO_ERROR)
            then begin
              writeln ('     ', cSOMType:4, ' Divider       =      ', wDivider:3);
              writeln ('     ', cSOMType:4, ' PreSync       =      ', bytePreSync:3);
              writeln ('     ', cSOMType:4, ' MaskSync      =      ', byteMaskSync:3);
            end;
            //
            iRetVal := SEPIA2_SOM_SetOutNSyncEnable (iDevIdx, iSOM_Slot, byteOutEnable, byteSyncEnable, bSyncInverse);
            if (iRetVal = SEPIA2_ERR_NO_ERROR)
            then begin
              writeln ('     ', cSOMType:4, ' Output Enable =      $',  IntToHex (byteOutEnable,  2):2);
              writeln ('     ', cSOMType:4, ' Sync Enable   =      $',  IntToHex (byteSyncEnable, 2):2);
              writeln ('     ', cSOMType:4, ' Sync Inverse  =        ', bSyncInverse);
              writeln;
            end;
            //
            iRetVal := SEPIA2_SOM_SetBurstLengthArray (iDevIdx, iSOM_Slot, lBurstChannels[1], lBurstChannels[2], lBurstChannels[3], lBurstChannels[4], lBurstChannels[5], lBurstChannels[6], lBurstChannels[7], lBurstChannels[8]);
            if (iRetVal = SEPIA2_ERR_NO_ERROR)
            then begin
              writeln ('     ', cSOMType:4, ' BurstLength 2 = ', lBurstChannels[2]:8);
              writeln ('     ', cSOMType:4, ' BurstLength 3 = ', lBurstChannels[3]:8);
              writeln;
            end;
            //
            // SLM
            //
            iRetVal := SEPIA2_SLM_SetIntensityFineStep (iDevIdx, iSLM_Slot, wIntensity);
            if (iRetVal = SEPIA2_ERR_NO_ERROR)
            then begin
              iRetVal := SEPIA2_SLM_SetPulseParameters (iDevIdx, iSLM_Slot, iFreq, bPulseMode);
            end;

            if (iRetVal = SEPIA2_ERR_NO_ERROR)
            then begin
              SEPIA2_SLM_DecodeFreqTrigMode (iFreq, cFreqTrigMode);
              if (iRetVal = SEPIA2_ERR_NO_ERROR)
              then begin
                writeln ('     ', cSLMType:4, ' FreqTrigMode   =      ''', cFreqTrigMode, '''');
              end
              else begin
                writeln ('     ', cSLMType:4, ' FreqTrigMode   =       ??  (decoding error)');
              end;
              writeln ('     ', cSLMType:4,   ' Pulse Mode     =        ', bPulseMode);
              writeln ('     ', cSLMType:4,   ' Intensity      =       ',   0.1*wIntensity:3:1, ' %');
            end
            else begin
              writeln ('     ', cSLMType:4,   ' FreqTrigMode   =       ??  (reading error)');
              writeln ('     ', cSLMType:4,   ' Pulse Mode     =       ??  (reading error)');
              writeln ('     ', cSLMType:4,   ' Intensity      =       ??  (reading error)');
            end;
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
  end;
  //
  writeln; writeln;
  writeln ('press RETURN...');
  Readln;
end.
 