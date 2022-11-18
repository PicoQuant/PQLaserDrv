%%-----------------------------------------------------------------------------
%%
%%           MATLAB Demo for the Usage of the Sepia2_Lib.DLL
%%             (API-Library  for PicoQuant Laser Divers)
%%
%%            Developed for, and running under MATLAB R2019b
%%
%%-----------------------------------------------------------------------------
%%
%%  Consider, this code is for demonstration purposes only.
%%
%%  PicoQuant officially disclaims any support for MATLAB integration.
%%
%%  This is just to illustrate the possibility of such an integration
%%  and how to solve some of the major problems on the way.
%%  This demo is provided 'as is' without any warranty whatsoever.
%%
%%  Although protected by copyright and intellectual property laws,
%%  you may use and modify this demo code to create your own software.
%%  Original or modified demo code may be re-distributed, provided that
%%  the original disclaimer and copyright notes are not removed from it.
%%
%%  Products and corporate names appearing in this demo may or may not
%%  be registered trademarks or copyrights of their respective owners.
%%  They are used only for identification or explanation and to the
%%  owner’s benefit, without intent to infringe.
%%
%%-----------------------------------------------------------------------------
%%
%%  Special thanks go to Xiangyu (Mike) Zhang, Duke University.
%%  This demo is largely based on his efforts.
%%
%%-----------------------------------------------------------------------------
%%  HISTORY:
%%
%%  apo  20.10.15   created on the base of a script by Mike
%%
%%  apo  10.02.21   adapted to DLL V1.2.xx.nnn
%%                    enhanced to deal with new VisUV / VisIR devices
%%                    this Demo no longer supports PPL400 and Solea functions
%%
%%  apo  25.10.22   enhanced to deal with new Prima devices
%%
%%-----------------------------------------------------------------------------
%
%
%%-----------------------------------------------------------------------------
% %
% % This demo mainly shows how to open and read data from a PQLaserDrv
% % device. Setting the parameters follows mainly the same rules, but
% % is quite less sophisticated, since you don't need to provide pointers
% % but give the parameters directly by value.
% %
% % The main issue is to import the functions from the API-library.
% % The library is written in C/C++, so carefully read the chapter
% % "Advanced Software Development | Calling External Functions | Call C Shared Libraries"
% % from the MATLAB manual "Programming" on the import fundamentals.
% %
% % Searching for errors that occured in the beginning, I found this:
% %
% %   http://www.mathworks.com/matlabcentral/answers/96578-why-does-matlab-crash-when-i-make-a-function-call-on-a-dll-in-matlab-7-6-r2008a
% %
% % and although all functions were properly identified as stdcall by MATLAB,
% % I followed these hints, anyway.
% %
% % I reommend to use a MATLAB library headerfile for the DLL,
% % but due to some peculiarity in parameter usage (some of the
% % API functions use "input modifying parameters"), I found,
% % that the headerfile created by MATLAB yet has to be edited
% % by hand, anyway! The modifications are stated below:
% %
% % 1) I had to add a function, missing in the MATLAB created header,
% %    and it was of all functions just "SEPIA2_LIB_DecodeError" !!!
% %    (I've no clue why MATLAB didn't find it in the first place...
% %    Perhaps it was because this function was listed at first in the *.h file?)
% %    But this function is a frequently used one, don't set it aside.
% %    It helps to understand the reasons for some errors firing. Refer
% %    also to the API manual and read on the function, returning the error...
% %    - Edited with Version 1.2:
% %      This error seems now to be fixed.
% %
% % 2) Next I changed for some 'cstring' parameter types to 'voidPtr',
% %    to achieve bidirectional Input/Output parameters (sometimes also
% %    called  "transfer parameters" or "input modifying parameters")
% %    for the following functions:
% %      "SEPIA2_USB_OpenDevice",
% %      "SEPIA2_USB_OpenGetSerNumAndClose",
% %      "SEPIA2_FWR_CreateSupportRequestText",
% %      "SEPIA2_COM_SaveAsPreset" and
% %      "SEPIA2_COM_UpdateModuleData".
% %    This trick is also documented here:
% %
% %      http://de.mathworks.com/help/matlab/matlab_external/working-with-pointers.html
% %
% %    This results in a little inconvenience, having the output as a
% %    pointer with the need to cast and copy its content, but it works.
% %
% % After a call to
% %   loadlibrary('Sepia2_Lib.dll', 'Sepia2_Lib.h', 'alias', 'Sepia2_Lib', 'mfilename', 'mHeader_Sepia2_Lib')
% % you'll find the modified header file named "mHeader_Sepia2_Lib.m"
% % side by side with this demo script.
% % - Edited with Version 1.2 and R2019b:
% %   Also a thunk-DLL is created in the same directory
% %
%%-----------------------------------------------------------------------------
%
%
%%-----------------------------------------------------------------------------
%  Open the Library
%%-----------------------------------------------------------------------------
%
clear all;
old_Format        = get(0,'Format');
old_FormatSpacing = get(0,'FormatSpacing');
%
format short
format compact
%
bSuppressSupportRequestText = false;
%
NO_DEVIDX =     -1;
NO_IDX_1  = -99999;
NO_IDX_2  = -97979;
%
%
if ~libisloaded('Sepia2_Lib')
  %
  % %
  % % this would be to create a new MATLAB library headerfile named "mHeader.m"
  % % but keep in mind, the headerfile has to be edited by hand, anyway!
  % %
  %
  % [notfound, warnings] = loadlibrary('Sepia2_Lib.dll', 'Sepia2_Lib.h', 'alias', 'Sepia2_Lib', 'mfilename', 'mHeader')
  %
  % %
  % % but once we have one, we can edit and rename it to "mHeader_Sepia2_Lib.m".
  % % after that, we can simplify the call like this:
  % %
  %
  loadlibrary('Sepia2_Lib.dll', @mHeader_Sepia2_Lib, 'alias', 'Sepia2_Lib');
end
%
% %
% % use one of these, if you want to test for proper loading
% % either this ...
% %
%
%if libisloaded('Sepia2_Lib')
%  libfunctionsview('Sepia2_Lib');
%end
%
% %
% % ... or that:
% %
%
%func_list=libfunctions ('Sepia2_Lib', '-full');
%
% %
% % just meant as a help for counting ;-)
% %
% %               '0000000001111111111222222222233333333334444444444555555555566666'
% %               '1234567890123456789012345678901234567890123456789012345678901234'
% %
%
cTemp           = '';
cErrorString    = blanks (56); % grant for enough length! (This means: provide at least 54 chars!!!)
pcErrorString   = libpointer('cstring',cErrorString);
OffOn_Values    = ['off'; 'on '];
DisEna_Values   = ['disabled'; 'enabled '];
%
%%-----------------------------------------------------------------------------
%
% %
% % this code stores and prints all error codes with their messages;
% % You might use this list instead of the one in the library's manual:
% %
% iErrNrs  = 0;
% err_list = struct('ErrCode', {}, 'ErrText', {});
% %
% fname='SEPIA2_LIB_DecodeError';
% for n=-1:-1:-9999
%   [ret1, cErrorString] = calllib('Sepia2_Lib', fname, n, pcErrorString);
%   if ret1==0
%     iErrNrs = iErrNrs+1;
%     err_list(iErrNrs).ErrCode = n;
%     err_list(iErrNrs).ErrText = cErrorString;
%   end
% end
% %
% for n=1:length(err_list)
%  cDisplay = sprintf ('%d: "%s"\n',err_list(n).ErrCode,err_list(n).ErrText);
%  disp(cDisplay)
% end
%
%%-----------------------------------------------------------------------------
%
% %
% %               '0000000001111111111222222222233333333334444444444555555555566666'
% %               '1234567890123456789012345678901234567890123456789012345678901234'
% %
%
cLibVersion = blanks (16); % grant for enough length! (This means: provide at least 14 chars!!!)
pLibVersion = libpointer('cstring',cLibVersion);
% %
fname='SEPIA2_LIB_GetVersion';
[ret, cLibVersion] = calllib('Sepia2_Lib', fname, pLibVersion);
if Sepia2FunctionSucceeds(ret,fname,NO_DEVIDX,NO_IDX_1,NO_IDX_2)
  cDisplay = sprintf (['%s ran OK:\n   Library Version = "%s"\n'...
                      '   For support cases, please always mention the LIB version number\n'],...
                      fname, cLibVersion);
  disp(cDisplay)
end
%
%%-----------------------------------------------------------------------------
%  To Open the Device: Find the USB-Index
%%-----------------------------------------------------------------------------
%
% %
% % Next, we want to properly open an USB-device.
% %
% % Since the functions used to open a device are relying
% % on "input modifying parameters" (as earlier mentioned),
% % we need to implement some 'voidPtr' variables.
% % Once we got them, we may use them multiply...
% %
%
% %
% % again, just meant as a help for counting ;-)
% %                 '0000000001111111111222222222233333333334444444444555555555566666'
% %                 '1234567890123456789012345678901234567890123456789012345678901234'
% %
%
cProductModelIn   = blanks (36); % grant for enough length! (This means: provide at least 34 chars!!!)
pProductModelIn   = libpointer('voidPtr',[uint8(0) uint8(cProductModelIn)]);
%
cSerialNumberIn   = blanks (16);             % grant for enough length! (This means: provide at least 14 chars!!!)
pSerialNumberIn   = libpointer('voidPtr',[uint8(0) uint8(cSerialNumberIn)]);
%
cProductModelOut  = blanks (36); % grant for enough length! (This means: provide at least 34 chars!!!)
pProductModelOut  = libpointer('voidPtr',[uint8(0) uint8(cProductModelOut)]);
iProductModelSize = size(cProductModelOut);
%
cSerialNumberOut  = blanks (16); % grant for enough length! (This means: provide at least 14 chars!!!)
pSerialNumberOut  = libpointer('voidPtr',[uint8(0) uint8(cSerialNumberOut)]);
iSerialNumberSize = size(cSerialNumberOut);
%
% %
% % now we can go on:
% %
% % There are different ways to find out about the proper iDevIdx value:
% % You could simply _assume_ a value (starting with 0 to 7) and if one fails,
% % just try the next...
% %
%
%iDevIdx = 0; % asign your assumption here
%
% %
% % ...or you could really find out the first valid value by calling
% % the function "SEPIA2_USB_OpenGetSerNumAndClose", implemented in a loop.
% % But remember: The name of the function ends "...AndClose", so there is
% % no device open after completing the loop...
% %
%
%
iDevIdx = -1;
fname='SEPIA2_USB_OpenGetSerNumAndClose';
for m=0:1:7
  pProductModelIn.Value(1) = 0;
  pSerialNumberIn.Value(1) = 0;
  %
  [ret, pProductModelOut, pSerialNumberOut] = calllib('Sepia2_Lib', fname, m, pProductModelIn, pSerialNumberIn);
  if Sepia2FunctionSucceeds(ret,fname,m,NO_IDX_1,NO_IDX_2)
    setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2))
    for n=1:1:iSerialNumberSize(2)
      if pSerialNumberOut.Value(n)==0
        iSerialNumberSize(2)=n-1;
        setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2));
        cSerialNumberOut=strtrim(char(pSerialNumberOut.Value));
        break;
      end
    end
    setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2))
    for n=1:1:iProductModelSize(2)
      if pProductModelOut.Value(n)==0
        iProductModelSize(2)=n-1;
        setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2));
        cProductModelOut=strtrim(char(pProductModelOut.Value));
        break;
      end
    end
    cDisplay = sprintf ('%s (%d) ran OK:\n   Product="%s", S/N="%s"\n',...
                        fname, m, cProductModelOut, cSerialNumberOut);
    disp(cDisplay)
    iDevIdx = m;
    break;
  end
end
%
% your choice:
%iDevIdx = 1;
%
if iDevIdx == -1
  cDisplay = sprintf ('No device found; Terminate this run!\n');
  disp(cDisplay)
  return;
else
  cDisplay = sprintf ('From now on, we take iDevIdx = %d  as USB index for our PQ-LaserDevice!\n', iDevIdx);
  disp(cDisplay)
end
%
%%-----------------------------------------------------------------------------
%
% %
% % which way you ever may have chosen, from now on keep the once found value!
% % Next we're going to really open the device:
% %
%
% %
% % PQ-LaserDevices return -9005 if already opened,
% % so, let us simply ignore this on opening.
% % Nevertheless, if this happens with other functions, too,
% % we ought to handle this...
% %
%
%%-----------------------------------------------------------------------------
%  Open the Device With the Index Given
%%-----------------------------------------------------------------------------
%
fname='SEPIA2_USB_OpenDevice';
pProductModelIn.Value(1) = 0;
pSerialNumberIn.Value(1) = 0;
%
[ret, pProductModelOut, pSerialNumberOut] = calllib('Sepia2_Lib', fname, iDevIdx, pProductModelIn, pSerialNumberIn);
if (ret ~= 0) && (ret ~= -9005)
  [~, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  cDisplay = sprintf ('%s returns errorcode %d: "%s"\n',...
                      fname,ret,cErrorString);
  disp(cDisplay)
else
  setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2))
  for n=1:1:iSerialNumberSize(2)
    if pSerialNumberOut.Value(n)==0
      iSerialNumberSize(2)=n;
      setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2));
      cSerialNumberOut=strtrim(char(pSerialNumberOut.Value));
      break;
    end
  end
  setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2))
  for n=1:1:iProductModelSize(2)
    if pProductModelOut.Value(n)==0
      iProductModelSize(2)=n;
      setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2));
      cProductModelOut=strtrim(char(pProductModelOut.Value));
      break;
    end
  end
  cDisplay = sprintf ('%s ran OK:\n   Product="%s", S/N="%s"\n',...
                      fname, cProductModelOut, cSerialNumberOut);
  disp(cDisplay)
end
%
% %
% % %
% % % Just to show, that this also works with Parameters:
% % % First we try with a definitely non-fitting model
% % % (here: "Solea", if this demo is for a Solea, change the parameter to e.g. "Sepia II" or "PPL400"):
% % %
% % % We expect this to fail with errorcode -9026.
% % %
% %
% pProductModelIn   = libpointer('voidPtr',[uint8('Solea') uint8(0)]);
% [ret, pProductModelOut, pSerialNumberOut] = calllib('Sepia2_Lib', fname, iDevIdx, pProductModelIn, pSerialNumberIn);
% if (ret ~= 0) && (ret ~= -9005)
%   [~, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
%   cDisplay = sprintf ('%s returns errorcode %d: "%s"\n',...
%                       fname,ret,cErrorString);
%   disp(cDisplay)
% else
%   setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2))
%   for n=1:1:iSerialNumberSize(2)
%     if pSerialNumberOut.Value(n)==0
%       iSerialNumberSize(2)=n;
%       setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2));
%       cSerialNumberOut=strtrim(char(pSerialNumberOut.Value));
%       break;
%     end
%   end
%   setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2))
%   for n=1:1:iProductModelSize(2)
%     if pProductModelOut.Value(n)==0
%       iProductModelSize(2)=n;
%       setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2));
%       cProductModelOut=strtrim(char(pProductModelOut.Value));
%       break;
%     end
%   end
%   cDisplay = sprintf ('%s ran OK:\n   Product="%s", S/N="%s"\n',...
%                       fname, cProductModelOut, cSerialNumberOut);
%   disp(cDisplay)
% end
% %
% % %
% % % Now we repeat the test with a proper product model
% % % (here: "Sepia II", of course we expect this to succeed):
% % %
% % % Instead of a product model, you could also specify
% % % a serial number, the workflow would be just the same.
% % % Consider a logical "AND" applied to the parameters given.
% % %
% %
% pProductModelIn   = libpointer('voidPtr',[uint8('Sepia II') uint8(0)]);
% [ret, pProductModelOut, pSerialNumberOut] = calllib('Sepia2_Lib', fname, iDevIdx, pProductModelIn, pSerialNumberIn);
% if (ret ~= 0) && (ret ~= -9005)
%   [~, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);  
%   cDisplay = sprintf ('%s returns errorcode %d: "%s"\n',...
%                        fname, ret, cErrorString);
%   disp(cDisplay)
% else
%   setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2))
%   for n=1:1:iSerialNumberSize(2)
%     if pSerialNumberOut.Value(n)==0
%       iSerialNumberSize(2)=n;
%       setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2));
%       cSerialNumberOut=strtrim(char(pSerialNumberOut.Value));
%       break;
%     end
%   end
%   setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2))
%   for n=1:1:iProductModelSize(2)
%     if pProductModelOut.Value(n)==0
%       iProductModelSize(2)=n;
%       setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2));
%       cProductModelOut=strtrim(char(pProductModelOut.Value));
%       break;
%     end
%   end
%   cDisplay = sprintf ('%s ran OK:\n   Product="%s", S/N="%s"\n',...
%                       fname, cProductModelOut, cSerialNumberOut);
%   disp(cDisplay)
% end
%
%
% %
% % now we're already able to get some more informations on the device opened:
% % these functions provide strings as simple output parameters, so they don't
% % need the more complex void pointers, as needed for input modifying parameters
% %
%
cStringDescr      = blanks (256); % grant for enough length! (This means: provide at least 255 chars!!!)
pcStringDescr     = libpointer('cstring',cStringDescr);
cFWRVersion       = blanks (10); % grant for enough length! (This means: provide at least 8 chars!!!)
pcFWRVersion      = libpointer('cstring',cFWRVersion);
iErrCode          = int32(0);
piErrCode         = libpointer('int32Ptr',iErrCode);
iErrPhase         = int32(0);
piErrPhase        = libpointer('int32Ptr',iErrPhase);
cErrorPhase       = blanks (25); % grant for enough length! (This means: provide at least 24 chars!!!)
pcErrorPhase      = libpointer('cstring',cErrorPhase);
iErrLocation      = int32(0);
piErrLocation     = libpointer('int32Ptr',iErrLocation);
iErrSlot          = int32(0);
piErrSlot         = libpointer('int32Ptr',iErrSlot);
cErrCondition     = blanks (56); % grant for enough length! (This means: provide at least 55 chars!!!)
pcErrCondition    = libpointer('cstring',cErrCondition);
%
fname = 'SEPIA2_USB_GetStrDescriptor';
[ret, cStringDescr] = calllib('Sepia2_Lib', fname, iDevIdx, pcStringDescr);
if Sepia2FunctionSucceeds(ret,fname,iDevIdx,NO_IDX_1,NO_IDX_2)
  cDisplay = sprintf ('%s ran OK:\n   cStringDescr = "%s"\n',...
                      fname, cStringDescr);
  disp(cDisplay)
end
%
fname = 'SEPIA2_FWR_GetVersion';
[ret, cFWRVersion] = calllib('Sepia2_Lib', fname, iDevIdx, pcFWRVersion);
if Sepia2FunctionSucceeds(ret,fname,iDevIdx,NO_IDX_1,NO_IDX_2)
  cDisplay = sprintf ([ '%s ran OK:\n   Firmware Version = "%s"\n'...
                        '   For support cases, please always mention the FWR version number\n'],...
                        fname, cFWRVersion);
  disp(cDisplay)
end
%
% %
% % let's read out the result of the latest firmware boot.
% % this information is vital for the support in case of hardware trouble!
% %
%
% extern int _stdcall SEPIA2_FWR_GetLastError ( int iDevIdx , int * piErrCode , int * piPhase , int * piLocation , int * piSlot , char * cCondition );
fname = 'SEPIA2_FWR_GetLastError';
[ret, iErrCode, iErrPhase, iErrLocation, iErrSlot, cErrCondition] = calllib('Sepia2_Lib', fname, iDevIdx, piErrCode, piErrPhase, piErrLocation, piErrSlot, pcErrCondition);
if Sepia2FunctionSucceeds(ret,fname,iDevIdx,NO_IDX_1,NO_IDX_2)
  if iErrCode ~= 0
    [~, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', iErrCode, pcErrorString);
    [~, cErrorPhase]  = calllib('Sepia2_Lib', 'SEPIA2_FWR_DecodeErrPhaseName', iErrPhase, pcErrorPhase);
    %
    cDisplay = sprintf ([ '%s ran OK:\n\n'...
                          '   Last firmware boot resulted in following error:\n'...
                          '   Error Code      = %5d      (i.e. "%s")\n'...
                          '   Error Phase     = %5d      (i.e. "%s")\n'...
                          '   Error Location  = %5d\n'...
                          '   Error Slot      =   %03d\n'...
                          '   Error Condition = "%s"\n\n'...
                          '   For support cases, please always mention the  "Last Error"  block\n'...
                          '\n'],...
                          fname, iErrCode, cErrorString,...
                          iErrPhase, cErrorPhase,...
                          iErrLocation, iErrSlot, cErrCondition);
    disp(cDisplay)
  else
    
    cDisplay = sprintf ([ '%s ran OK:\n   Last firmware boot was error-free!\n'...
                          '   For support cases, please mention, that the  "Last Error"  block was clear!\n'], fname);
    disp(cDisplay)
  end
end
%
%
%%-----------------------------------------------------------------------------
%  Get the Device Map
%%-----------------------------------------------------------------------------
%
% %
% % At this point, we should have an open device.
% % Now, let's have the device-specific data space of the DLL initialized.
% % This is done by fetching the module map:
% %
%
iPerformRestart = 0;
% %
iModuleCount    = 0;
piModuleCount   = libpointer('int32Ptr',iModuleCount);
%
fname = 'SEPIA2_FWR_GetModuleMap';
[ret, iModuleCount] = calllib('Sepia2_Lib', fname, iDevIdx, iPerformRestart, piModuleCount);
if Sepia2FunctionSucceeds(ret,fname,iDevIdx,NO_IDX_1,NO_IDX_2)
  cDisplay = sprintf ('%s ran OK:\n   iModuleCount = %d\n',...
                      fname, iModuleCount);
  disp(cDisplay)
end
%
%
%%-----------------------------------------------------------------------------
%  Iterate through the Map
%%-----------------------------------------------------------------------------
%
% %
% % Now we inspect the modules by map index and collect categorical infos,
% % as - most important - the slot IDs...
% %
%
iSlotId         = 0;
piSlotId        = libpointer('int32Ptr', iSlotId);
bIsPrimary      = uint8 (0);
pbIsPrimary     = libpointer('uint8Ptr', bIsPrimary);
bIsBackPlane    = uint8 (0);
pbIsBackPlane   = libpointer('uint8Ptr', bIsBackPlane);
bHasUptimeCntr  = uint8 (0);
pbHasUptimeCntr = libpointer('uint8Ptr', bHasUptimeCntr);
iModTyp         = int32 (0);
piModTyp        = libpointer('int32Ptr', iModTyp);
%
% %               '0000000001111111111222222222233333333334444444444555555555566666'
% %               '1234567890123456789012345678901234567890123456789012345678901234'
% %
%
cModTyp         = blanks (58); % grant for enough length! (This means: provide at least 56 chars!!!)
pcModTyp        = libpointer('cstring',cModTyp);
cModTypA        = blanks ( 6); % grant for enough length! (This means: provide at least 4 chars!!!)
pcModTypA       = libpointer('cstring',cModTypA);
cLabel          = blanks (10); % grant for enough length! (This means: provide at least 8 chars!!!)
pcLabel         = libpointer('cstring',cLabel);
cSerialNo       = blanks (14); % grant for enough length! (This means: provide at least 12 chars!!!)
pcSerialNo      = libpointer('cstring',cSerialNo);
cReleaseDate    = blanks (10); % grant for enough length! (This means: provide at least 8 chars!!!)
pcReleaseDate   = libpointer('cstring',cReleaseDate);
cRevision       = blanks (10); % grant for enough length! (This means: provide at least 8 chars!!!)
pcRevision      = libpointer('cstring',cRevision);
cHdrMemo        = blanks(128); % grant for enough length! (This means: provide at least 128 chars!!!)
pcHdrMemo       = libpointer('cstring',cHdrMemo);
wFormatVers     = uint16 (0);
pwFormatVers    = libpointer('uint16Ptr',wFormatVers);
%
%
cSOMFrqTrgMod   = blanks (34); % grant for enough length! (This means: provide at least 32 chars!!!)
pcSOMFrqTrgMod  = libpointer('cstring',cSOMFrqTrgMod);
%
%
cSLMFrqTrgMod   = blanks (30); % grant for enough length! (This means: provide at least 28 chars!!!)
pcSLMFrqTrgMod  = libpointer('cstring',cSLMFrqTrgMod);
cSLMHeadType    = blanks (20); % grant for enough length! (This means: provide at least 18 chars!!!)
pcSLMHeadType   = libpointer('cstring',cSLMHeadType);
%
%
cVUV_VIRTrgSrc  = blanks (18); % grant for enough length! (This means: provide at least 16 chars!!!)
pcVUV_VIRTrgSrc = libpointer('cstring',cVUV_VIRTrgSrc);
iDummy          = int32 (0);
piDummy         = libpointer('int32Ptr',iDummy);
bDummy1         = uint8 (0);
pbDummy1        = libpointer('uint8Ptr',bDummy1);
bDummy2         = uint8 (0);
pbDummy2        = libpointer('uint8Ptr',bDummy2);
bFrqDivEna      = uint8 (0);
pbFrqDivEna     = libpointer('uint8Ptr',bFrqDivEna);
bTrgLvlEna      = uint8 (0);
pbTrgLvlEna     = libpointer('uint8Ptr',bTrgLvlEna);
%
%
cPRITrgSrc  = blanks (18); % grant for enough length! (This means: provide at least 16 chars!!!)
pcPRITrgSrc = libpointer('cstring',cPRITrgSrc);
%
global pri_empty;
%                                   %0________1_________2_________3_________4
%                                   %1234567890123456789012345678901234567890
pri_empty = struct (  'bInitialized', false, ...
                     'PrimaModuleID', blanks(8), ...
                   'PrimaModuleType', blanks(34), ...
                       'PrimaFWVers', blanks(10), ...
                     'PrimaTemp_min', single(0.0), ...
                     'PrimaTemp_max', single(0.0), ...
                       'PrimaUSBIdx', int32(-1), ...
                       'PrimaSlotId', int32(-1), ...
                      'PrimaWLCount', int32(-1), ...
                          'PrimaWLs', [int32(-1) int32(-1) int32(-1)], ...
                   'PrimaOpModCount', int32(-1), ...
                     'PrimaOpModOff', int32(-1), ...
                  'PrimaOpModNarrow', int32(-1), ...
                   'PrimaOpModBroad', int32(-1), ...
                      'PrimaOpModCW', int32(-1), ...
                   'PrimaTrSrcCount', int32(-1), ...
                     'PrimaTrSrcInt', int32(-1), ...
                  'PrimaTrSrcExtNIM', int32(-1), ...
                  'PrimaTrSrcExtTTL', int32(-1), ...
              'PrimaTrSrcExtFalling', int32(-1), ...
               'PrimaTrSrcExtRising', int32(-1)     );
%
PRIConst(8) = pri_empty;
%
modtyp = struct('iSlotId', int32(0), 'bIsPrimary', uint8(0), 'bIsBackPlane', uint8(0), 'bHasUptimeCntr', uint8(0), 'iModTyp', uint8(0), 'cModTyp', cModTyp, 'cModTypA', cModTypA, 'cSerialNo', cSerialNo, 'cLabel', cLabel, 'cReleaseDate', cReleaseDate, 'cRevision', cRevision, 'cHdrMemo', cHdrMemo);
Modules(iModuleCount) = modtyp;
Orig_Slot = -1;
SCM_Slot  = -1;           % only once in a frame
%
% backplane and SCM _must_ exist, but none of the following has to.
% therefore we've got to check for their indvidual counts
%
SOM_Count = 0;
SOM_Slot  = -1;           % only once in a frame
%
SLM_Count = 0;
SLM_Slot  = zeros (1, 8); % this is the max. for large Sepia II frames...
%
VUV_VIR_Count = 0;
VUV_VIR_Slot  = zeros (1, 8);
VUV_VIR_IsVIR = zeros (1, 8);
%
PRI_Count = 0;
PRI_Slot  = zeros (1, 8);
%
%
isSOMD    = false;
SOM_TrigModCount       = 0;
SOMFrqTrgModi{1,5}     = []; % SEPIA2_SOM_FREQ_TRIGMODE_COUNT == 5
SLMFrqTrgModi{1,8}     = []; % SEPIA2_SLM_FREQ_TRIGMODE_COUNT == 8
SLMHeadTypes{1,4}      = []; % SEPIA2_SLM_HEAD_TYPES_COUNT == 4
VUV_VIR_TrgSrcs{1,5}   = []; % SEPIA2_VUV_VIR_TRIGSRC_COUNT == 5
VUV_VIR_FrqDivEna{1,5} = []; % SEPIA2_VUV_VIR_TRIGSRC_COUNT == 5
VUV_VIR_TrgLvlEna{1,5} = []; % SEPIA2_VUV_VIR_TRIGSRC_COUNT == 5
VUV_VIR_FreqList{2,6}  = []; % SEPIA2_VUV_VIR_FREQDIV_COUNT == 6
%
for m=1:1:iModuleCount
  iMapIdx = m-1;
  module  = modtyp;
  %
  fname = 'SEPIA2_FWR_GetModuleInfoByMapIdx';
  [ret, module.iSlotId, module.bIsPrimary, module.bIsBackPlane, module.bHasUptimeCntr] = calllib('Sepia2_Lib', fname, iDevIdx, iMapIdx, piSlotId, pbIsPrimary, pbIsBackPlane, pbHasUptimeCntr);
  if Sepia2FunctionSucceeds(ret,fname,iDevIdx,iMapIdx,NO_IDX_2)
    %
    fname = 'SEPIA2_COM_GetFormatVersion';
    [ret, wFormatVers] = calllib('Sepia2_Lib', fname, iDevIdx, module.iSlotId, module.bIsPrimary, pwFormatVers);
    if Sepia2FunctionSucceeds(ret,fname,iDevIdx,module.iSlotId,NO_IDX_2)
      if ~isequal(wFormatVers, 0x0105)          
        cDisplay = sprintf ([ '%s (%03d) returns format V%X.%2.2X:\n'...
                              '   This Demo will only work with V1.05 formatted modules.\n'...
                              ],fname, module.iSlotId,...
                              wFormatVers./256, rem(wFormatVers,256));
        disp(cDisplay)
      else
        %
        if (module.bIsBackPlane~=0)
          % this is a trick to get more infos on the backplane;
          % sorry, but since this is only needed on rare occasions...
          Orig_Slot = module.iSlotId;
          module.iSlotId=-1;
        end
        %
        fname = 'SEPIA2_COM_GetModuleType';
        [ret, module.iModTyp] = calllib('Sepia2_Lib', fname, iDevIdx, module.iSlotId, module.bIsPrimary, piModTyp);
        Sepia2FunctionSucceeds(ret,fname,iDevIdx,module.iSlotId,NO_IDX_2);
        %
        fname = 'SEPIA2_COM_DecodeModuleType';
        [ret, module.cModTyp] = calllib('Sepia2_Lib', fname, module.iModTyp, pcModTyp);
        Sepia2FunctionSucceeds(ret,fname,iDevIdx,module.iModTyp,NO_IDX_2);
        %
        fname = 'SEPIA2_COM_DecodeModuleTypeAbbr';
        [ret, module.cModTypA] = calllib('Sepia2_Lib', fname, module.iModTyp, pcModTypA);
        Sepia2FunctionSucceeds(ret,fname,iDevIdx,module.iModTyp,NO_IDX_2);
        %
        fname = 'SEPIA2_COM_GetSerialNumber';
        [ret, module.cSerialNo] = calllib('Sepia2_Lib', fname, iDevIdx, module.iSlotId, module.bIsPrimary, pcSerialNo);
        Sepia2FunctionSucceeds(ret,fname,iDevIdx,module.iSlotId,NO_IDX_2);
        %
        fname = 'SEPIA2_COM_GetSupplementaryInfos';
        [ret, module.cLabel, module.cReleaseDate, module.cRevision, module.cHdrMemo] = calllib('Sepia2_Lib', fname, iDevIdx, module.iSlotId, module.bIsPrimary, pcLabel, pcReleaseDate, pcRevision, pcHdrMemo);
        Sepia2FunctionSucceeds(ret,fname,iDevIdx,module.iSlotId,NO_IDX_2);
        %
        cHeader4Printing = '';
        cHeaders4Printing = strsplit(module.cHdrMemo, '\r\n');
        if ~isempty(cHeaders4Printing)
          cHeader4Printing = string(cHeaders4Printing(1));
          if length(cHeaders4Printing) > 1
            for n=2:1:length(cHeaders4Printing)
              cHeader4Printing = sprintf('%s\n                  | %s',...
                                         cHeader4Printing,...
                                         string (cHeaders4Printing (n)));
            end
          end
        end
        %
        if module.bIsBackPlane == 0            
          cDisplay = sprintf ([ 'There is a %s module in slot %3.3d:\n'...
                                '   Serial No.   = "%s"\n'...
                                '   Label        = "%s"\n'...
                                '   Release Date = "%s"\n'...
                                '   Revision     = "%s"\n'...
                                '   Header Memo  = | %s\n'],...
                                module.cModTypA, module.iSlotId,...
                                module.cSerialNo, module.cLabel,...
                                module.cReleaseDate, module.cRevision,...
                                cHeader4Printing);
          disp(cDisplay)
        end
        %
        switch module.cModTypA
          case 'SCM'
            SCM_Slot  = module.iSlotId;
            %
          case 'SOM'
            SOM_Count = SOM_Count+1;
            SOM_Slot  = module.iSlotId;
            isSOMD    = false;
            SOM_SeqCtrlCount  = 3; % SEPIA2_SOM_AUXIN_SequencerCtrl_COUNT == 3
            %
            fname = 'SEPIA2_SOM_DecodeFreqTrigMode';
            for n=0:1:4 % SEPIA2_SOM_FREQ_TRIGMODE_COUNT-1
              [ret,cSOMFrqTrgMod] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, n, pcSOMFrqTrgMod);
              if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SOM_Slot,n)
                SOM_TrigModCount = n+1;
                SOMFrqTrgModi{1, n+1} = cSOMFrqTrgMod;
              else
                break;
              end
            end
            %
          case 'SOMD'
            SOM_Count = SOM_Count+1;
            SOM_Slot  = module.iSlotId;
            isSOMD    = true;
            SOM_SeqCtrlCount  = 4; % SEPIA2_SOMD_AUXIN_SequencerCtrl_COUNT == 4
            %
            fname = 'SEPIA2_SOMD_DecodeFreqTrigMode';
            for n=0:1:4 % SEPIA2_SOMD_FREQ_TRIGMODE_COUNT-1
              [ret,cSOMFrqTrgMod] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, n, pcSOMFrqTrgMod);
              if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SOM_Slot,n)
                SOM_TrigModCount = n+1;
                SOMFrqTrgModi{1, n+1} = cSOMFrqTrgMod;
              else
                break;
              end
            end
            %
          case 'SLM'
            SLM_Count = SLM_Count+1;
            SLM_Slot(SLM_Count) = module.iSlotId;
            %
            fname = 'SEPIA2_SLM_DecodeFreqTrigMode';
            for n=0:1:7 % SEPIA2_SLM_FREQ_TRIGMODE_COUNT-1
              [ret,cSLMFrqTrgMod] = calllib('Sepia2_Lib', fname, n, pcSLMFrqTrgMod);
              if Sepia2FunctionSucceeds(ret,fname,NO_DEVIDX,n,NO_IDX_2)
                SLMFrqTrgModi{1, n+1} = cSLMFrqTrgMod;
              else
                break;
              end
            end
            %
            fname = 'SEPIA2_SLM_DecodeHeadType';
            for n=0:1:3 % SEPIA2_SLM_HEAD_TYPE_COUNT-1
              [ret,cSLMHeadType] = calllib('Sepia2_Lib', fname, n, pcSLMHeadType);
              if Sepia2FunctionSucceeds(ret,fname,NO_DEVIDX,n,NO_IDX_2)
                SLMHeadTypes{1, n+1} = cSLMHeadType;
              else
                break;
              end
            end
            %
          case {'VUV', 'VIR'}
            VUV_VIR_Count = VUV_VIR_Count+1;
            VUV_VIR_Slot(VUV_VIR_Count) = module.iSlotId;
            if isequal(module.cModTypA, 'VIR')
              VUV_VIR_IsVIR(VUV_VIR_Count) = true;
            else
              VUV_VIR_IsVIR(VUV_VIR_Count) = false;
            end
            %
            fname = 'SEPIA2_VUV_VIR_DecodeFreqTrigMode';
            % creating list of trigger sources and associated attributes
            for n=0:1:4
              [ret,cVUV_VIRTrgSrc,~,bFrqDivEna,bTrgLvlEna] = calllib('Sepia2_Lib', fname, iDevIdx, VUV_VIR_Slot(VUV_VIR_Count), n, -1, pcVUV_VIRTrgSrc, piDummy, pbFrqDivEna, pbTrgLvlEna);
              if Sepia2FunctionSucceeds(ret,fname,iDevIdx,VUV_VIR_Slot(VUV_VIR_Count),n)
                VUV_VIR_TrgSrcs{1,n+1}   = cVUV_VIRTrgSrc;
                VUV_VIR_FrqDivEna{1,n+1} = bFrqDivEna;
                VUV_VIR_TrgLvlEna{1,n+1} = bTrgLvlEna;
              else
                break;
              end
            end
            %
            % creating list of frequencies derived from high base oscillator
            for n=0:1:5
              [ret,cVUV_VIRTrgSrc,~,~,~] = calllib('Sepia2_Lib', fname, iDevIdx, VUV_VIR_Slot(VUV_VIR_Count), 0, n, pcVUV_VIRTrgSrc, piDummy, pbDummy1, pbDummy2);
              if Sepia2FunctionSucceeds(ret,fname,iDevIdx,VUV_VIR_Slot(VUV_VIR_Count),n)
                VUV_VIR_FreqList{1, n+1} = cVUV_VIRTrgSrc;
              else
                break;
              end
            end
            %
            % creating list of frequencies derived from low base oscillator
            for n=0:1:5
              [ret,cVUV_VIRTrgSrc,~,~,~] = calllib('Sepia2_Lib', fname, iDevIdx, VUV_VIR_Slot(VUV_VIR_Count), 1, n, pcVUV_VIRTrgSrc, piDummy, pbDummy1, pbDummy2);
              if Sepia2FunctionSucceeds(ret,fname,iDevIdx,VUV_VIR_Slot(VUV_VIR_Count),n)
                VUV_VIR_FreqList{2, n+1} = cVUV_VIRTrgSrc;
              else
                break;
              end
            end
            %
          case {'PRI'}
            PRI_Count = PRI_Count+1;
            PRI_Slot(PRI_Count) = module.iSlotId;
            %
            %
            %
            % implement additional cases here
            %   e.g. modules typical for Solea or PPL400 drivers
            % ...
            %
          otherwise
            if module.bIsBackPlane > 0
              cDisplay = sprintf ('We don''t handle the %s backplane carrying slot %3.3d\n',...
                                   module.cModTypA, Orig_Slot);
              disp(cDisplay)
            else
              cDisplay = sprintf ('Yet, we don''t handle the %s module in slot %3.3d\n',...
                                   module.cModTypA, module.iSlotId);
              disp(cDisplay)             
            end
        end
        %
        Modules(m) = module;
      end
    end
  end
end
%
%
%%-----------------------------------------------------------------------------
%  Get More and Specialized Module Information (ad lib.)
%%-----------------------------------------------------------------------------
%
%
% %
% % now, that we know the configuration of our device, we can read all settings:
% %
% % first the SCM
% %
%
bPowerLED         = uint8(0);
pbPowerLED        = libpointer('uint8Ptr',bPowerLED);
bLaserActiveLED   = uint8(0);
pbLaserActiveLED  = libpointer('uint8Ptr',bLaserActiveLED);
bLaserLocked      = uint8(0);
pbLaserLocked     = libpointer('uint8Ptr',bLaserLocked);
bLaserSoftLocked  = uint8(0);
pbLaserSoftLocked = libpointer('uint8Ptr',bLaserSoftLocked);
HardSoft_Values   = ['hard'; 'soft'];
cSCM_Out          = '';
%
fname = 'SEPIA2_SCM_GetPowerAndLaserLEDS';
[ret,bPowerLED,bLaserActiveLED] = calllib('Sepia2_Lib', fname, iDevIdx, SCM_Slot, pbPowerLED, pbLaserActiveLED);
if Sepia2FunctionSucceeds(ret, fname,iDevIdx,SCM_Slot,NO_IDX_2)
  if bPowerLED~=0
    bPowerLED=1;
  end
  if bLaserActiveLED~=0
    bLaserActiveLED=1;
  end
  cSCM_Out = sprintf (['\n   Power LED        is %s \n'...
                       '   Laser Active LED is %s \n'],...
                      strtrim(OffOn_Values(bPowerLED+1,:)),...
                      strtrim(OffOn_Values(bLaserActiveLED+1,:)));
end
%
fname = 'SEPIA2_SCM_GetLaserLocked';
[ret,bLaserLocked] = calllib('Sepia2_Lib', fname, iDevIdx, SCM_Slot, pbLaserLocked);
if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SCM_Slot,NO_IDX_2)
  if bLaserLocked ~= 0
    fname = 'SEPIA2_SCM_GetLaserSoftLock';
    [ret,bLaserSoftLocked] = calllib('Sepia2_Lib', fname, iDevIdx, SCM_Slot, pbLaserSoftLocked);
    Sepia2FunctionSucceeds(ret,fname,iDevIdx,SCM_Slot,NO_IDX_2);
    if bLaserSoftLocked ~= 0
      bLaserSoftLocked = 1;
    end
    cSCM_Out = [cSCM_Out sprintf('\n   Lasers are %s locked',...
                                 HardSoft_Values(bLaserSoftLocked+1,:))];
  else
    cSCM_Out = [cSCM_Out sprintf('\n   Lasers are unlocked')];
  end
end
cDisplay = sprintf ('SCM (slot %03d) state:\n%s\n', SCM_Slot, cSCM_Out);
disp(cDisplay)
%
% %
% % next following the SOM / SOM-D
% %
%
if SOM_Count >= 1
  iSOMTrgMod        = int32(0);
  piSOMTrgMod       = libpointer('int32Ptr',iSOMTrgMod);
  bSynchronized     = uint8(0);
  pbSynchronized    = libpointer('uint8Ptr',bSynchronized);
  iSOMTrgLvlLo      = int32(0);
  piSOMTrgLvlLo     = libpointer('int32Ptr',iSOMTrgLvlLo);
  iSOMTrgLvlHi      = int32(0);
  piSOMTrgLvlHi     = libpointer('int32Ptr',iSOMTrgLvlHi);
  SOMTrgRange       = zeros(1,2,'int32');
  iSOMTrgLvl        = int32(0);
  piSOMTrgLvl       = libpointer('int32Ptr',iSOMTrgLvl);
  %
  if isSOMD ~= 0
    iSOMDivider     = uint16(0);
    piSOMDivider    = libpointer('uint16Ptr',iSOMDivider);
  else
    iSOMDivider     = uint8(0);
    piSOMDivider    = libpointer('uint8Ptr',iSOMDivider);
  end
  %
  bPreSync          = uint8(0);
  pbPreSync         = libpointer('uint8Ptr',bPreSync);
  bSyncMask         = uint8(0);
  pbSyncMask        = libpointer('uint8Ptr',bSyncMask);
  bSyncInverse      = uint8(0);
  pbSyncInverse     = libpointer('uint8Ptr',bSyncInverse);
  bOutEnable        = uint8(0);
  pbOutEnable       = libpointer('uint8Ptr',bOutEnable);
  bSyncEnable       = uint8(0);
  pbSyncEnable      = libpointer('uint8Ptr',bSyncEnable);
  %
  cSOMSeqCtrl       = blanks (26); % grant for enough length! (This means: provide at least 24 chars!!!)
  pcSOMSeqCtrl      = libpointer('cstring', cSOMSeqCtrl);
  bAUXOutCtrl       = uint8(0);
  pbAUXOutCtrl      = libpointer('uint8Ptr',bAUXOutCtrl);
  bAUXInCtrl        = uint8(0);
  pbAUXInCtrl       = libpointer('uint8Ptr',bAUXInCtrl);
  %
  cSOM_Out          = '';
  cSOM_Discr        = '';
  %
  if isSOMD ~= 0
    cSOM_Discr = 'D';
    fname = 'SEPIA2_SOMD_GetFreqTrigMode';
    [ret,iSOMTrgMod,bSynchronized] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, piSOMTrgMod, pbSynchronized);
    if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SOM_Slot,NO_IDX_2)
      if bSynchronized ~= 0
        bSynchronized = 1;
      end
      cTemp = SOMFrqTrgModi{1,iSOMTrgMod+1};
      cSOM_Out = sprintf ('   Trigger Mode  : %s\n   Synchronized  : %s',...
                          cTemp, strtrim(OffOn_Values(bSynchronized+1,:)));
    end
  else
    fname = 'SEPIA2_SOM_GetFreqTrigMode';
    [ret,iSOMTrgMod] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, piSOMTrgMod);
    if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SOM_Slot,NO_IDX_2)
      cTemp = SOMFrqTrgModi{1,iSOMTrgMod+1};
      cSOM_Out = sprintf ('   Trigger Mode  : %s', cTemp);
    end
  end
  %
  % %
  % % The following functions exist for SOM and SOMD, respectively, with the very same footprint.
  % % You could implement wrapper functions to have only one instance for the both of them,
  % % but you could also call the respective function by simply variing the name string:
  % %
  %
  fname = sprintf('SEPIA2_SOM%s_GetTriggerRange', cSOM_Discr);
  [ret,iSOMTrgLvlLo,iSOMTrgLvlHi] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, piSOMTrgLvlLo, piSOMTrgLvlHi);
  if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SOM_Slot,NO_IDX_2)
    SOMTrgRange = [iSOMTrgLvlLo, iSOMTrgLvlHi];
    cTemp = sprintf (['\n   Trigger Range : %5d mV'...
                      ' <= Trigger Level <= %d mV'],...
                      iSOMTrgLvlLo, iSOMTrgLvlHi);
    cSOM_Out = [cSOM_Out, cTemp];
  end
  %
  fname = sprintf('SEPIA2_SOM%s_GetTriggerLevel', cSOM_Discr);
  [ret,iSOMTrgLvl] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, piSOMTrgLvl);
  if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SOM_Slot,NO_IDX_2)
    cTemp = sprintf ('\n   Trigger Level : %5d mV', iSOMTrgLvl);
    cSOM_Out = [cSOM_Out, cTemp];
  end
  %
  fname = sprintf('SEPIA2_SOM%s_GetBurstValues', cSOM_Discr);
  % this function differs in footprint, due to the bigger divider for SOMD,
  % but we declared iSOMDivider and piSOMDivider different above, to fit either needs
  %
  [ret,iSOMDivider,bPreSync,bSyncMask] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, piSOMDivider, pbPreSync, pbSyncMask);
  if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SOM_Slot,NO_IDX_2)
    cTemp = sprintf (['\n   Base Divider  : %5d\n'...
                      '   Pre-Sync      : %5d\n'...
                      '   Sync Mask     : %5d'],...
                      iSOMDivider, bPreSync, bSyncMask);
    cSOM_Out = [cSOM_Out, cTemp];
  end
  %
  fname = sprintf('SEPIA2_SOM%s_GetOutNSyncEnable', cSOM_Discr);
  [ret,bOutEnable,bSyncEnable,bSyncInverse] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, pbOutEnable, pbSyncEnable, pbSyncInverse);
  if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SOM_Slot,NO_IDX_2)
    % bOutEnable and bSyncEnable are bitcoded information
    % on the output states and therefore handled later with the outputs
    if bSyncInverse ~= 0
      cSOM_Out = [cSOM_Out, ';   (mask is working inverted)'];
    else
      cSOM_Out = [cSOM_Out, ';   (mask is working normal)'];
    end
  end
  %
  fname = sprintf('SEPIA2_SOM%s_DecodeAUXINSequencerCtrl', cSOM_Discr);
  SOMSeqCtrl{1,SOM_SeqCtrlCount} = [];
  for n=0:1:SOM_SeqCtrlCount-1
    [~,cSOMSeqCtrl] = calllib('Sepia2_Lib', fname, n, pcSOMSeqCtrl);
    SOMSeqCtrl{1,n+1} = cSOMSeqCtrl;
  end
  %
  fname = sprintf('SEPIA2_SOM%s_GetAUXIOSequencerCtrl', cSOM_Discr);
  [ret,bAUXOutCtrl,bAUXInCtrl] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, pbAUXOutCtrl, pbAUXInCtrl);
  if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SOM_Slot,NO_IDX_2)
    if bAUXOutCtrl ~= 0
      bAUXOutCtrl = 1;
    end
    cTemp = SOMSeqCtrl{1,bAUXInCtrl+1};
    cTemp = sprintf ('\n   AUX Output    : %s\n   Sequencer     : %s',...
                     strtrim(DisEna_Values(bAUXOutCtrl+1,:)), cTemp);
    cSOM_Out = [cSOM_Out, cTemp];
  end
  %
  % %
  % % Now we inspect the output channel lines of our SOM(D)
  % %
  %
  somouttyp = struct('iBurstLen', int32(0), 'bSyncEna', uint8(0), 'bOutEna', uint8(0));
  SOMOutput(8) = somouttyp;
  %
  iBurstLen1    = int32(0);
  piBurstLen1   = libpointer('int32Ptr',iBurstLen1);
  iBurstLen2    = int32(0);
  piBurstLen2   = libpointer('int32Ptr',iBurstLen2);
  iBurstLen3    = int32(0);
  piBurstLen3   = libpointer('int32Ptr',iBurstLen3);
  iBurstLen4    = int32(0);
  piBurstLen4   = libpointer('int32Ptr',iBurstLen4);
  iBurstLen5    = int32(0);
  piBurstLen5   = libpointer('int32Ptr',iBurstLen5);
  iBurstLen6    = int32(0);
  piBurstLen6   = libpointer('int32Ptr',iBurstLen6);
  iBurstLen7    = int32(0);
  piBurstLen7   = libpointer('int32Ptr',iBurstLen7);
  iBurstLen8    = int32(0);
  piBurstLen8   = libpointer('int32Ptr',iBurstLen8);
  %
  if isSOMD ~= 0
    bDelayed           = uint8(0);
    pbDelayed          = libpointer('uint8Ptr',bDelayed);
    bForcedUndelayed   = uint8(0);
    pbForcedUndelayed  = libpointer('uint8Ptr',bForcedUndelayed);
    bOutCombi          = uint8(0);
    pbOutCombi         = libpointer('uint8Ptr',bOutCombi);
    bMaskedCombi       = uint8(0);
    pbMaskedCombi      = libpointer('uint8Ptr',bMaskedCombi);
    f64CoarseDly       = double(0);
    pf64CoarseDly      = libpointer('doublePtr',f64CoarseDly);
    bFineDly           = uint8(0);
    pbFineDly          = libpointer('uint8Ptr',bFineDly);
  end
  %
  fname = sprintf('SEPIA2_SOM%s_GetBurstLengthArray', cSOM_Discr);
  [ret,iBurstLen1,iBurstLen2,iBurstLen3,iBurstLen4,iBurstLen5,iBurstLen6,iBurstLen7,iBurstLen8] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, piBurstLen1, piBurstLen2, piBurstLen3, piBurstLen4, piBurstLen5, piBurstLen6, piBurstLen7, piBurstLen8);
  if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SOM_Slot,NO_IDX_2)
    SOMOutput(1).iBurstLen = iBurstLen1;
    SOMOutput(2).iBurstLen = iBurstLen2;
    SOMOutput(3).iBurstLen = iBurstLen3;
    SOMOutput(4).iBurstLen = iBurstLen4;
    SOMOutput(5).iBurstLen = iBurstLen5;
    SOMOutput(6).iBurstLen = iBurstLen6;
    SOMOutput(7).iBurstLen = iBurstLen7;
    SOMOutput(8).iBurstLen = iBurstLen8;
  end
  %
  for n=1:1:8
    bitmask = bitset(uint8(0), n);
    if bitand (bitmask, bSyncEnable) ~= 0
      SOMOutput(n).bSyncEna = 1;
    else
      SOMOutput(n).bSyncEna = 0;
    end
    if bitand (bitmask, bOutEnable) ~= 0
      SOMOutput(n).bOutEna = 1;
    else
      SOMOutput(n).bOutEna = 0;
    end
    cTemp = sprintf ('\n   Line %d        : Burst Length = %8d;   Sync %8s;   Output %8s',...
                     n, SOMOutput(n).iBurstLen,...
                     strtrim(DisEna_Values(SOMOutput(n).bSyncEna+1,:)),...
                     strtrim(DisEna_Values(SOMOutput(n).bOutEna+1,:)));
    cSOM_Out = [cSOM_Out, cTemp];
    %
    if isSOMD ~= 0
      fname = 'SEPIA2_SOMD_GetSeqOutputInfos';
      [ret,bDelayed,bForcedUndelayed,bOutCombi,bMaskedCombi,f64CoarseDly,bFineDly] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, uint8(n-1), pbDelayed, pbForcedUndelayed, pbOutCombi, pbMaskedCombi, pf64CoarseDly, pbFineDly);
      if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SOM_Slot,n-1)
        %
        if ((bDelayed == 0) || (bForcedUndelayed ~= 0))
          %
          % this line combines some bursts undelayed
          %
          cCombi = '';
          for m=1:1:8
            bitmask2 = bitset(uint8(0), m);
            if bitand (bitmask2, bOutCombi) ~= 0
              if ~isempty(cCombi)
                cCombi = [cCombi ', ' int2str(m)];
              else
                cCombi = int2str(m);
              end
            end
          end
          %
          if length(cCombi) > 1
            cTemp = sprintf (';  Combining bursts %s', cCombi);
          else
            cTemp = sprintf (';  Outputs burst %s', cCombi);
          end
          %
        else
          %
          % this line outputs its burst delayed
          %
          cTemp = sprintf (';  Delayed: %.1f nsec + %d fine steps',...
                           f64CoarseDly, bFineDly);
          %
        end
        cSOM_Out = [cSOM_Out, cTemp];
      end
    end
  end
  %
  cDisplay = sprintf ('SOM%s (slot %03d) state:\n%s\n',... 
                      cSOM_Discr, SOM_Slot, cSOM_Out);
  disp(cDisplay)
  %
else
  %
  cDisplay = sprintf ('No SOM module found!\n');
  disp(cDisplay)
  %
end
%
% %
% % next we inspect the SLM(s) (if there are any, at all)
% %
%
if SLM_Count >= 1
  iFreqTrgMod   = int32(0);
  piFreqTrgMod  = libpointer('int32Ptr',iFreqTrgMod);
  bPulseMode    = uint8(0);
  pbPulseMode   = libpointer('uint8Ptr',bPulseMode);
  iHeadType     = int32(0);
  piHeadType    = libpointer('int32Ptr',iHeadType);
  wIntensity    = uint16(0);
  pwIntensity   = libpointer('uint16Ptr',wIntensity);
  %
  slmtyp = struct ('iSlotId', int32(0), 'iFreqTrgMod', int32(0), 'bPulseMode', uint8(0), 'iHeadType', int32(0), 'wIntensity', uint16(0));
  SLMs(SLM_Count) = slmtyp;
  %
  for slm=1:1:SLM_Count
    %cSLM_Out  = '';
    SLMs(slm) = slmtyp;
    %
    SLMs(slm).iSlotId = SLM_Slot(slm);
    %
    fname = 'SEPIA2_SLM_GetPulseParameters';
    [ret, iFreqTrgMod, bPulseMode, iHeadType] = calllib('Sepia2_Lib', fname, iDevIdx, SLM_Slot(slm), piFreqTrgMod, pbPulseMode, piHeadType);
    if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SLM_Slot(slm),NO_IDX_2)
      if bPulseMode ~= 0
        bPulseMode = 1;
      end
      SLMs(slm).iFreqTrgMod = iFreqTrgMod;
      SLMs(slm).bPulseMode  = bPulseMode;
      SLMs(slm).iHeadType   = iHeadType;
    end
    %
    fname = 'SEPIA2_SLM_GetIntensityFineStep';
    [ret, wIntensity] = calllib('Sepia2_Lib', fname, iDevIdx, SLM_Slot(slm), pwIntensity);
    if Sepia2FunctionSucceeds(ret,fname,iDevIdx,SLM_Slot(slm),NO_IDX_2)
      SLMs(slm).wIntensity = wIntensity;
    end
    %
    cTemp = SLMFrqTrgModi{1,iFreqTrgMod+1};
    cTemp1 = SLMHeadTypes{1,iHeadType+1};
    cSLM_Out = sprintf (['\n'...
                         '   Trigger Mode  : %s\n'...
                         '   Pulse Mode    : %s\n'...
                         '   Head Type     : %s\n'...
                         '   Intensity     : %5.1f %%'],...
                         cTemp, strtrim(DisEna_Values(bPulseMode+1,:)),...
                         cTemp1, 1.0 * wIntensity / 10);
    %
    cDisplay = sprintf ('SLM %d (slot %03d) state:\n%s\n',...
                        slm, SLM_Slot(slm), cSLM_Out);
    disp(cDisplay)
  end
  %
else
  %
  cDisplay = sprintf ('No SLM modules found!\n');
  disp(cDisplay)
  %
end
%
%
% %
% % next we inspect the VUV- and VIR-modules  (i.e. VisUV / VisIR devices)
% %
%
if VUV_VIR_Count >= 1
  %
  for vuv_vir=1:1:VUV_VIR_Count
    if SEPIA2_VUV_VIR_GetData(iDevIdx, VUV_VIR_Slot(vuv_vir), VUV_VIR_IsVIR(vuv_vir), VUV_VIR_TrgSrcs, VUV_VIR_FrqDivEna, VUV_VIR_TrgLvlEna, VUV_VIR_FreqList)
    else
      cDisplay = sprintf ('Error on VisUV / VisIR GetData function!\n');
      disp(cDisplay)
    end
  end
  %cDevType, &bHasCW, &bHasFanSwitch
  %
else
  %
  cDisplay = sprintf ('No VisUV / VisIR devices found!\n');
  disp(cDisplay)
  %
end
%
%
% %
% % last but not least following the PRI-modules  (i.e. QUADER / Prima devices)
% %
%
if PRI_Count >= 1
  %
  iWLIdx  = int32(-1);
  piWLIdx = libpointer('int32Ptr',iWLIdx);
  %
  iOMIdx  = int32(-1);
  piOMIdx = libpointer('int32Ptr',iOMIdx);
  cOpMod  = blanks(18); % grant for enough length! (This means: provide at least SEPIA2_PRI_OPERMODE_LEN=16 + 1 chars!!!)
  pcOpMod = libpointer('cstring',cOpMod);
  %
  iTSIdx  = int32(-1);
  piTSIdx = libpointer('int32Ptr',iTSIdx);
  cTrSrc  = blanks(28); % grant for enough length! (This means: provide at least SEPIA2_PRI_TRIGSRC_LEN=26 + 1 chars!!!)
  pcTrSrc = libpointer('cstring',cTrSrc);
  %
  bFreqncyEnabled  = uint8(0);
  pbFreqncyEnabled = libpointer('uint8Ptr',bFreqncyEnabled);
  bTrigLvlEnabled  = uint8(0);
  pbTrigLvlEnabled = libpointer('uint8Ptr',bTrigLvlEnabled);
  %
  iMinFreq   = int32(-1);
  iMaxFreq   = int32(-1);
  iFreq      = int32(-1);
  piMinFreq  = libpointer('int32Ptr',iMinFreq);
  piMaxFreq  = libpointer('int32Ptr',iMaxFreq);
  piFreq     = libpointer('int32Ptr',iFreq);
  %
  iMinTrgLvl  = int32(-1);
  iMaxTrgLvl  = int32(-1);
  iResTrgLvl  = int32(-1);
  iTrgLvl     = int32(-1);
  piMinTrgLvl = libpointer('int32Ptr',iMinTrgLvl);
  piMaxTrgLvl = libpointer('int32Ptr',iMaxTrgLvl);
  piResTrgLvl = libpointer('int32Ptr',iResTrgLvl);
  piTrgLvl    = libpointer('int32Ptr',iTrgLvl);
  %
  wIntensity  = uint16(0);
  pwIntensity = libpointer('uint16Ptr',wIntensity);
  %
  bGatingEnabled   = uint8(0);
  bGateHiImp       = uint8(0);
  iMinOnTime       = int32(-1);
  iMaxOnTime       = int32(-1);
  iOnTime          = int32(-1);
  iMinOffTimefact  = int32(-1);
  iMaxOffTimefact  = int32(-1);
  iOffTimefact     = int32(-1);
  pbGatingEnabled  = libpointer('uint8Ptr',bGatingEnabled);
  pbGateHiImp      = libpointer('uint8Ptr',bGateHiImp);
  piMinOnTime      = libpointer('int32Ptr',iMinOnTime);
  piMaxOnTime      = libpointer('int32Ptr',iMaxOnTime);
  piOnTime         = libpointer('int32Ptr',iOnTime);
  piMinOffTimefact = libpointer('int32Ptr',iMinOffTimefact);
  piMaxOffTimefact = libpointer('int32Ptr',iMaxOffTimefact);
  piOffTimefact    = libpointer('int32Ptr',iOffTimefact);
  %
  %  using:
  %  % SEPIA2_PRI_GetWavelengthIdx      % ( int iDevIdx , int iSlotId , int * piWLIdx ); 
  %  % SEPIA2_PRI_DecodeOperationMode   % ( int iDevIdx , int iSlotId , int iOperModeIdx , char * pcOperMode ); 
  %  % SEPIA2_PRI_GetOperationMode      % ( int iDevIdx , int iSlotId , int * piOperModeIdx ); 
  %  % SEPIA2_PRI_DecodeTriggerSource   % ( int iDevIdx , int iSlotId , int iTrgSrcIdx , char * pcTrgSrc , unsigned char * pbFrequencyEnabled , unsigned char * pbTrigLevelEnabled ); 
  %  % SEPIA2_PRI_GetTriggerSource      % ( int iDevIdx , int iSlotId , int * piTrgSrcIdx ); 
  %  % SEPIA2_PRI_GetFrequencyLimits    % ( int iDevIdx , int iSlotId , int * piMinFreq , int * piMaxFreq ); 
  %  % SEPIA2_PRI_GetFrequency          % ( int iDevIdx , int iSlotId , int * piFrequency ); 
  %  % SEPIA2_PRI_GetTriggerLevelLimits % ( int iDevIdx , int iSlotId , int * piTrg_MinLvl , int * piTrg_MaxLvl , int * piTrg_LvlRes ); 
  %  % SEPIA2_PRI_GetTriggerLevel       % ( int iDevIdx , int iSlotId , int * piTrgLevel ); 
  %  % SEPIA2_PRI_GetIntensity          % ( int iDevIdx , int iSlotId , int iWLIdx , unsigned short * pwIntensity ); 
  %  % SEPIA2_PRI_GetGatingEnabled      % ( int iDevIdx , int iSlotId , unsigned char * pbGatingEnabled ); 
  %  % SEPIA2_PRI_GetGateHighImpedance  % ( int iDevIdx , int iSlotId , unsigned char * pbHighImpedance ); 
  %  % SEPIA2_PRI_GetGatingLimits       % ( int iDevIdx , int iSlotId , int * piMinOnTime , int * piMaxOnTime , int * pbMinOffTimefactor , int * pbMaxOffTimefactor ); 
  %  % SEPIA2_PRI_GetGatingData         % ( int iDevIdx , int iSlotId , int * piOnTime , int * piOffTimefact ); 
  %
  for pri=1:1:PRI_Count
  %  
    fname = 'SEPIA2_PRI_GetConstants';
    %
    %  % in fact, this is no genuine DLL function, but a MatLab-function
    %  % as a helper for PRI devices, supplying an array element with a
    %  % PRI constants struct related to the individual PRI-module as is
    %  % identified by the counting index pri
    %     
    [ret, PRIConst] = SEPIA2_PRI_GetConstants(iDevIdx, PRI_Slot(pri), PRIConst, pri);
    if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),pri)
      %
      PRI = PRIConst(pri);
      %
      cDisplay = sprintf([ 'PRI %d (slot %03d):\n'...
                           '   devicetype         =   ''%s''\n'...
                           '   firmware version   =    %s\n'],...
                            pri, PRI_Slot(pri),...
                            PRI.PrimaModuleType,...
                            PRI.PrimaFWVers);
      disp(cDisplay)
      %
      fname = 'SEPIA2_PRI_GetWavelengthIdx';
      [ret, iWLIdx] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), piWLIdx);
      if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),NO_IDX_2)
        %
        cTemp = '';
        for idx=1:1:PRI.PrimaWLCount
          cTemp = [cTemp sprintf('\n     wavelength [%1d]   = %4dnm',...
                                 idx-1, PRI.PrimaWLs(idx))];        
        end
        %
        cDisplay = sprintf([ '   wavelengths count  =    %1d'...
                             '%s\n'...
                             '   cur. wavelength    = %4dnm;%*sWL-Idx=%d\n'],...
                              PRI.PrimaWLCount, cTemp,...
                              PRI.PrimaWLs(iWLIdx+1), 13, ' ', iWLIdx);
                            
        disp(cDisplay)
        %
        fname = 'SEPIA2_PRI_DecodeOperationMode';
        cTemp = '';
        for idx=1:1:PRI.PrimaOpModCount
          [ret, cOpMod] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), idx-1, pcOpMod);
          if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),idx-1)
            cOpMod = strtrim(cOpMod);
            cTemp = [cTemp sprintf('\n     oper. mode [%1d]   =   ''%s''',...
                                   idx-1, cOpMod)];
          end
        end
        fname = 'SEPIA2_PRI_GetOperationMode';
        [ret, iOMIdx] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), piOMIdx);
        if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),NO_IDX_2)
          %
          fname = 'SEPIA2_PRI_DecodeOperationMode';
          [ret, cOpMod] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), iOMIdx, pcOpMod);
          if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),iOMIdx)
            cOpMod = strtrim(cOpMod);
            cDisplay = sprintf([ '   operation modes    =    %1d'...
                                 '%s\n'...
                                 '   cur. oper. mode    =   ''%s'';%*sOM-Idx=%d\n'],...
                                  PRI.PrimaOpModCount, cTemp, cOpMod,...
                                  15-strlength(cOpMod), ' ', iOMIdx);
            disp(cDisplay)
            %
          end % Sepia2FunctionSucceeds 'SEPIA2_PRI_DecodeOperationMode'
        end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetOperationMode'
        %
        %
        fname = 'SEPIA2_PRI_DecodeTriggerSource';
        cTemp = '';
        for idx=1:1:PRI.PrimaTrSrcCount
          [ret, cTrSrc, ~, ~] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), idx-1, pcTrSrc, pbDummy1, pbDummy2);
          if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),idx-1)
            cTrSrc = strtrim(cTrSrc);
            cTemp = [cTemp sprintf('\n     trig. src. [%1d]   =   ''%s''',...
                                   idx-1, cTrSrc)];
          end
        end
        fname = 'SEPIA2_PRI_GetTriggerSource';
        [ret, iTSIdx] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), piTSIdx);
        if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),NO_IDX_2)
          %
          fname = 'SEPIA2_PRI_DecodeTriggerSource';
          [ret, cTrSrc, bFreqncyEnabled, bTrigLvlEnabled] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), iTSIdx, pcTrSrc, pbFreqncyEnabled, pbTrigLvlEnabled);
          if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),iTSIdx)
            cTrSrc = strtrim(cTrSrc);
            cDisplay = sprintf([ '   trigger sources    =    %1d'...
                                 '%s\n'...
                                 '   cur. trig. source  =   ''%s'';%*sTS-Idx=%d\n'],...
                                  PRI.PrimaTrSrcCount, cTemp, cTrSrc,...
                                  15-strlength(cTrSrc), ' ', iTSIdx);
            disp(cDisplay)
            %
            fname = 'SEPIA2_PRI_GetFrequencyLimits';
            [ret, iMinFreq, iMaxFreq] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), piMinFreq, piMaxFreq);
            if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),NO_IDX_2)
              fname = 'SEPIA2_PRI_GetFrequency';
              [ret, iFreq] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), piFreq);
              if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),NO_IDX_2)
                %
                fname = 'SEPIA2_PRI_GetTriggerLevelLimits';
                [ret, iMinTrgLvl, iMaxTrgLvl, ~] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), piMinTrgLvl, piMaxTrgLvl, piResTrgLvl);
                if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),NO_IDX_2)
                  %
                  fname = 'SEPIA2_PRI_GetTriggerLevel';
                  [ret, iTrgLvl] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), piTrgLvl);
                  if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),NO_IDX_2)
                    %
                    cTemp1 = sprintf('for TS-Idx = %1d     :    frequency is %sactive',...
                                     iTSIdx, iif(~bFreqncyEnabled, 'in', ''));
                    cTemp2 = FormatEng(iMinFreq, 3, 'Hz', -1, 0, false);
                    cTemp3 = FormatEng(iMaxFreq, 3, 'Hz', -1, 0, false);
                    cTemp4 = FormatEng(iFreq,    3, 'Hz', -1, 0, false);
                    cTemp5 = sprintf('for TS-Idx = %1d     :    trigger level is %sactive',...
                                      iTSIdx, iif(~bTrigLvlEnabled, 'in', ''));
                    cDisplay = sprintf([ '   %s\n'...
                                         '     frequency range  = %7s <= f <= %s\n'...
                                         '     cur. frequency   = %7s\n'...
                                         '   %s\n'...
                                         '     trig.lvl. range  =   %6.3fV <= tl <= %5.3fV\n'...
                                         '     cur. trig.lvl.   =   %6.3fV\n' ],...
                                         cTemp1, cTemp2, cTemp3,...
                                         cTemp4, cTemp5, 0.001*iMinTrgLvl,...
                                         0.001*iMaxTrgLvl, 0.001*iTrgLvl);
                    disp(cDisplay)
                    %
                  end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetTriggerLevel';
                end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetTriggerLevelLimits';
              end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetFrequency'
            end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetFrequencyLimits' 
          end % Sepia2FunctionSucceeds 'SEPIA2_PRI_DecodeTriggerSource'
        end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetTriggerSource
        %
        % Getting the current intensity needs to have had GetWavelengthIndex successfully run
        %
        fname = 'SEPIA2_PRI_GetIntensity';
        [ret, wIntensity] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), iWLIdx, pwIntensity);
        if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),iWLIdx)
          %
          cTemp    = sprintf('%5.1f%%', 0.1*wIntensity);
          cDisplay = sprintf('   intensity          =  %s; %*sWL-Idx=%d\n',...
                             cTemp, 17 - strlength(cTemp), ' ', iWLIdx);
          disp(cDisplay)
          %
        end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetIntensity'
        %
        %
        fname = 'SEPIA2_PRI_GetGatingEnabled';
        [ret, bGatingEnabled] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), pbGatingEnabled);
        if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),NO_IDX_2)
          %
          fname = 'SEPIA2_PRI_GetGateHighImpedance';
          [ret, bGateHiImp] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), pbGateHiImp);
          if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),NO_IDX_2)
            %
            fname = 'SEPIA2_PRI_GetGatingLimits';
            [ret, iMinOnTime, iMaxOnTime, iMinOffTimefact, iMaxOffTimefact] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), piMinOnTime, piMaxOnTime, piMinOffTimefact, piMaxOffTimefact);
            if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),NO_IDX_2)
              %
              fname = 'SEPIA2_PRI_GetGatingData';
              [ret, iOnTime, iOffTimefact] = calllib('Sepia2_Lib', fname, iDevIdx, PRI_Slot(pri), piOnTime, piOffTimefact);
              if Sepia2FunctionSucceeds(ret,fname,iDevIdx,PRI_Slot(pri),NO_IDX_2)
                %
                iOffTime    = iOnTime * iOffTimefact;
                fGatePeriod = 1.0e-9 * double(iOnTime * (1 + iOffTimefact));
                fGateFreq   = 1.0 / fGatePeriod;
                %
                cTemp1 = FormatEng(1.0e-9*double(iMinOnTime), 4, 's',  -1,  1, false);
                cTemp2 = FormatEng(1.0e-9*double(iMaxOnTime), 4, 's',  -1,  1, false);
                cTemp3 = FormatEng(1.0e-9*double(iOnTime),    4, 's',  -1,  1, false);
                cTemp4 = FormatEng(1.0e-9*double(iOffTime),   4, 's',  -1,  3, false);
                cTemp5 = FormatEng(fGatePeriod,               4, 's',  -1,  3, false);
                cTemp6 = FormatEng(fGateFreq,                 4, 'Hz', -1, -1, false);
                %
                cDisplay = sprintf([ '   gating             :    %sabled\n'...
                                     '     gate impedance   =    %s\n'...
                                     '     on-time range    =    %s <= t <= %s\n'...
                                     '     cur. on-time     =    %s\n'...
                                     '     off-t.fact range =    %d <= tf <= %d\n'...
                                     '     cur. off-time    =    %d * on-time = %s\n'...
                                     '     gate period      =    %s\n'...
                                     '     gate frequency   =    %s\n'],...
                                     iif((bGatingEnabled > 0), 'en', 'dis'),...
                                     iif((bGateHiImp > 0), 'high (>= 1 kOhm)', 'low (50 Ohm)' ),...
                                     cTemp1, cTemp2, cTemp3,...
                                     iMinOffTimefact, iMaxOffTimefact,...
                                     iOffTimefact, cTemp4, cTemp5, cTemp6);
                disp(cDisplay)
                %
              end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetGatingData'
            end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetGatingLimits'
          end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetGateHighImpedance'
        end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetGatingEnabled'
      end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetWavelengthIdx'
    end % Sepia2FunctionSucceeds 'SEPIA2_PRI_GetConstants'
  end % for PRI_Count
  %
else
  %   
  cDisplay = sprintf ('No Prima devices found!\n'); 
  disp(cDisplay)
  %
end
%
%
%
%%-----------------------------------------------------------------------------
%  How to Easily get System Infos in Case of a Support Request
%%-----------------------------------------------------------------------------
%
% %
% % to ease-up your life, we also provide a special function
% % to gather all the infos needed in case of a support request.
% %
% % notice: although the first two string parameters are de facto
% %         solely used as input parameters, they are also listed
% %         in the output vector, whilst the last is by all means
% %         a simple output parameter.
% %
%
if (~bSuppressSupportRequestText)
  %
  cPreamble     = sprintf (['\nThese infos (in the freshest state) are to be sent\n'...
                            'to support@PicoQuant.com in case of a support request.\n']);
  pcPreamble    = libpointer('voidPtr',[uint8(cPreamble) uint8(0)]);
  %
  cCallingSW    = 'MATLAB Demo';
  pcCallingSW   = libpointer('voidPtr',[uint8(cCallingSW) uint8(0)]);
  %
  cSupportText  = blanks (262144); % grant for enough length! (This means: provide at least 131071 chars!!!)
  pcSupportText = libpointer('cstring',cSupportText);
  %
  % %
  % % notice: the formerly given size (65536) assumed to be big enough,
  % %         in fact sometimes wasn't, due to the huge number of DLLs 
  % %         with extremely long names as used by the MatLab environment.
  % %         this led to very hard to debug crashes...
  % % 
  %
  %
  fname = 'SEPIA2_FWR_CreateSupportRequestText';
  [ret,~,~,cSupportText] = calllib('Sepia2_Lib', fname, iDevIdx, pcPreamble, pcCallingSW, 0, length(cSupportText), pcSupportText);
  if Sepia2FunctionSucceeds(ret,fname,iDevIdx,NO_IDX_1,NO_IDX_2)
    %
    % %
    % % for a good result readable in the command window,
    % % we have to replace <CR><LF> by only <LF>.
    % % if writing to a file, however, you should comment this out!
    % % (otherwise, the CRC will fail on checks!)
    % %
    %
    cText4Printing = strrep (cSupportText, char([13 10]), newline);
    %
    cDisplay = sprintf (['%%--------------------------------------'...
                         '---------------------------------------\n'...
                         '%s\n'...
                         '%%--------------------------------------'...
                         '---------------------------------------\n'],...
                         cText4Printing);
    disp(cDisplay)
  end
else
  cDisplay = sprintf (['%%--------------------------------------'...
                       '---------------------------------------\n'...
                       '  SupportRequestText was suppressed by user\n'...
                       '%%--------------------------------------'...
                       '---------------------------------------\n']);
  disp(cDisplay)
end
%
%
%%-----------------------------------------------------------------------------
%  How to Benchmark API Functions
%%-----------------------------------------------------------------------------
%
% %
% % %
% % % now let's benchmark the SLM set intensity function (as an example)
% % % this should show an average of some 30 msec per call,
% % % if you own a current version of the library.
% % %
% % % library versions with buildnumbers later than 469 are totally
% % % re-designed and streamlined as "FastLib", while older versions
% % % take up to a factor of 30 in time...
% % %
% %
% loops=100;
% %
% sprintf ('\n\nRunning benchmark (%d calls on SEPIA2_SLM_SetIntensityFineStep)...\n', loops)
% %
% OldIntensity = SLMs(1).wIntensity;
% %
% tic;
% for n=1:1:loops
%   %
%   if bitand(1, n) > 0
%     wDelta = uint16(100);
%   else
%     wDelta = uint16(0);
%   end
%   fname = 'SEPIA2_SLM_SetIntensityFineStep';
%   %ret = calllib('Sepia2_Lib', fname, iDevIdx, SLMs(1).iSlotId, 500+wDelta);
%   Sepia2FunctionSucceeds(ret,fname,iDevIdx,SLMs(1).iSlotId,NO_IDX_2);
% end
% empty_loop=toc;
% %
% tic;
% for n=1:1:loops
%   %
%   if bitand(1, n) > 0
%     wDelta = uint16(100);
%   else
%     wDelta = uint16(0);
%   end
%   fname = 'SEPIA2_SLM_SetIntensityFineStep';
%   ret = calllib('Sepia2_Lib', fname, iDevIdx, SLMs(1).iSlotId, 500+wDelta);
%   Sepia2FunctionSucceeds(ret,fname,iDevIdx,SLMs(1).iSlotId,NO_IDX_2);
% end
% real_loop=toc;
% %
% sprintf (['\n\nBenchmark (%d calls) Results:\n'...
%           '   Benchmark took overall %.3f sec,\n'...
%           '   thereof %.3f msec for surrounding (ineffective) statements.\n'...
%           '   After deductions, "SEPIA2_SLM_SetIntensityFineStep"  took on average %8.3f msec per call.\n'],...
%           loops, real_loop+empty_loop, 2000*empty_loop, 1000.0*(real_loop-empty_loop)/loops)
% %
% fname = 'SEPIA2_SLM_SetIntensityFineStep';
% ret = calllib('Sepia2_Lib', fname, iDevIdx, SLMs(1).iSlotId, OldIntensity);
% Sepia2FunctionSucceeds(ret,fname,iDevIdx,SLMs(1).iSlotId,NO_IDX_2);
%
%
%%-----------------------------------------------------------------------------
%  Clean-Up and Close
%%-----------------------------------------------------------------------------
%
%
fname = 'SEPIA2_FWR_FreeModuleMap';
ret = calllib('Sepia2_Lib', fname, iDevIdx);
if ret ~= 0
  [~, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  cDisplay = sprintf ('%s returns errorcode %d: "%s"\n',...
                      fname, ret, cErrorString);
  disp(cDisplay)
else
  cDisplay = sprintf ('%s ran OK\n', fname);
  disp(cDisplay)
end
%
fname = 'SEPIA2_USB_CloseDevice';
ret = calllib('Sepia2_Lib', fname, iDevIdx);
if (ret ~= 0)
  [~, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  cDisplay = sprintf ('%s returns errorcode %d: "%s"\n',...
                      fname, ret, cErrorString);
  disp(cDisplay)
else
  cDisplay = sprintf ('%s ran OK\n', fname);
  disp(cDisplay)
end
%
unloadlibrary Sepia2_Lib;
set (0, 'FormatSpacing', old_FormatSpacing);
set (0, 'Format', old_Format);
%clear;
%
%
%
function bNoErr = SEPIA2_VUV_VIR_GetData(iDevIdx, iSlotId, bIsVIR, VUV_VIR_TrgSrcs, VUV_VIR_FrqDivEna, VUV_VIR_TrgLvlEna, VUV_VIR_FreqList)
  %
  %NO_DEVIDX =     -1;
  %NO_IDX_1  = -99999;
  NO_IDX_2  = -97979;
  %
  bNoErr = false;
  if bIsVIR
    cDevice = 'VisIR';
    cMod    = 'VIR';
  else
    cDevice = 'VisUV';
    cMod    = 'VUV';
  end
  %
  YesNo_Values    = ['no '; 'yes'];
  %
  cDevType        = blanks (33); % grant for enough length! (This means: provide at least 32 chars!!!)
  pcDevType       = libpointer('cstring',cDevType);
  bHasCW          = uint8(0);
  pbHasCW         = libpointer('uint8Ptr',bHasCW);
  bHasFanSwitch   = uint8(0);
  pbHasFanSwitch  = libpointer('uint8Ptr',bHasFanSwitch);
  iTrigSrcIdx     = int32(0);
  piTrigSrcIdx    = libpointer('int32Ptr',iTrigSrcIdx);
  iFreqDivIdx     = int32(0);
  piFreqDivIdx    = libpointer('int32Ptr',iFreqDivIdx);

  iTrigLvlMin     = int32(0);
  piTrigLvlMin    = libpointer('int32Ptr',iTrigLvlMin);
  iTrigLvlMax     = int32(0);
  piTrigLvlMax    = libpointer('int32Ptr',iTrigLvlMax);
  iTrigLvlRes     = int32(0);
  piTrigLvlRes    = libpointer('int32Ptr',iTrigLvlRes);

  iTrigMilliVolt  = int32(0);
  piTrigMilliVolt = libpointer('int32Ptr',iTrigMilliVolt);
  iIntensity      = int32(0);
  piIntensity     = libpointer('int32Ptr',iIntensity);
  bIsFanRunning   = uint8(0);
  pbIsFanRunning  = libpointer('uint8Ptr',bIsFanRunning);
  %
  %
  cDisplay = sprintf ('%s module (i.e. %s device) in Slot %03d found!\n',...
                      cMod, cDevice, iSlotId);
  disp(cDisplay)
  %
  cVUV_VIR_Out = '   unknown\n';
  %
  fname = 'SEPIA2_VUV_VIR_GetDeviceType';
  [ret, cDevType, bHasCW, bHasFanSwitch] = calllib('Sepia2_Lib', fname, iDevIdx, iSlotId, pcDevType, pbHasCW, pbHasFanSwitch);
  if Sepia2FunctionSucceeds(ret,fname,iDevIdx,iSlotId,NO_IDX_2)
    fname = 'SEPIA2_VUV_VIR_GetTriggerData';
    [ret, iTrigSrcIdx, iFreqDivIdx, iTrigMilliVolt] = calllib('Sepia2_Lib', fname, iDevIdx, iSlotId, piTrigSrcIdx, piFreqDivIdx, piTrigMilliVolt);
    if Sepia2FunctionSucceeds(ret,fname,iDevIdx,iSlotId,NO_IDX_2)
      %
      cVUV_VIR_Out = sprintf (['\n'...
                               '   device type      : "%s"\n'...
                               '   options          : - %s = %s\n'...
                               '                      - %s = %s\n'...
                               '   trigger source   : idx =%2d; i.e. "%s"\n'],...
                               cDevType,...
                               'CW        ', YesNo_Values(bHasCW+1,:),...
                               'fan-switch', YesNo_Values(bHasFanSwitch+1,:),...
                               iTrigSrcIdx, string(VUV_VIR_TrgSrcs(1,iTrigSrcIdx+1))...
                               );
      if isequal({1}, VUV_VIR_FrqDivEna(iTrigSrcIdx+1))
        cVUV_VIR_Out = [cVUV_VIR_Out sprintf(['   divider          : 2^%d = %d\n'...
                                              '   frequency        : %s\n'],...
                                              iFreqDivIdx, 2^iFreqDivIdx,...
                                              string(VUV_VIR_FreqList(iTrigSrcIdx+1,iFreqDivIdx+1)))];
      else
        if isequal({1}, VUV_VIR_TrgLvlEna(iTrigSrcIdx+1))
          fname = 'SEPIA2_VUV_VIR_GetTrigLevelRange';
          [ret, iTrigLvlMax, iTrigLvlMin, iTrigLvlRes] = calllib('Sepia2_Lib', fname, iDevIdx, iSlotId, piTrigLvlMax, piTrigLvlMin, piTrigLvlRes);
          if Sepia2FunctionSucceeds(ret,fname,iDevIdx,iSlotId,NO_IDX_2)
            cVUV_VIR_Out = [cVUV_VIR_Out sprintf('   trigger level    : %6.3f V <= level <= %.3f V in steps of %d mV\n',...
                                                 0.001 .* single(iTrigLvlMin), ...
                                                 0.001 .* single(iTrigLvlMax), iTrigLvlRes)];
            cVUV_VIR_Out = [cVUV_VIR_Out sprintf('     - currently    : %6.3f V\n',...
                                                 0.001 .* single(iTrigMilliVolt))];
          else
            cVUV_VIR_Out = [cVUV_VIR_Out sprintf('   trigger level    : %6.3f V\n',...
                                                 0.001 .* single(iTrigMilliVolt))];
          end
        end
      end
      %
      fname = 'SEPIA2_VUV_VIR_GetIntensity';
      [ret, iIntensity] = calllib('Sepia2_Lib', fname, iDevIdx, iSlotId, piIntensity);
      if Sepia2FunctionSucceeds(ret,fname,iDevIdx,iSlotId,NO_IDX_2)
        cVUV_VIR_Out = [cVUV_VIR_Out sprintf('   intensity        : %3.1f %%\n',...
                                             0.1 .* single(iIntensity))];
        %
        fname = 'SEPIA2_VUV_VIR_GetFan';
        [ret, bIsFanRunning] = calllib('Sepia2_Lib', fname, iDevIdx, iSlotId, pbIsFanRunning);
        if Sepia2FunctionSucceeds(ret,fname,iDevIdx,iSlotId,NO_IDX_2)
          cVUV_VIR_Out = [cVUV_VIR_Out sprintf('   fan running      : %s\n',...
                                               YesNo_Values(bIsFanRunning+1,:))];
          bNoErr = true;
        end
      end
    end
  end
  cDisplay = [sprintf('%s (slot %03d) state:\n', cMod, iSlotId) cVUV_VIR_Out];
  disp(cDisplay)
end
%
%
function [iRetVal, PRI_Const_out] = SEPIA2_PRI_GetConstants(iDevIdx, iSlotId, PRI_Const_in, pri)
  %
  %  using:
  %  % SEPIA2_PRI_GetDeviceInfo         % ( int iDevIdx , int iSlotId , char * pcDeviceID , char * pcDeviceType , char * pcFW_Version , int * piWL_Count ); 
  %  % SEPIA2_PRI_DecodeOperationMode   % ( int iDevIdx , int iSlotId , int iOperModeIdx , char * pcOperMode ); 
  %  % SEPIA2_PRI_DecodeTriggerSource   % ( int iDevIdx , int iSlotId , int iTrgSrcIdx , char * pcTrgSrc , unsigned char * pbFrequencyEnabled , unsigned char * pbTrigLevelEnabled ); 
  %  % SEPIA2_PRI_DecodeWavelength      % ( int iDevIdx , int iSlotId , int iWLIdx , int * piWL ); 
  %
  global pri_empty; 
  % 
  %NO_DEVIDX =     -1;
  %NO_IDX_1  = -99999;
  NO_IDX_2  = -97979;
  %
  cDeviceID      = blanks (8);   % grant for enough length! (This means: provide at least SEPIA2_PRI_DEVICE_ID_LEN = 6+1 chars!!!)
  pcDeviceID     = libpointer('cstring', cDeviceID);
  cDeviceType    = blanks (34);  % grant for enough length! (This means: provide at least SEPIA2_PRI_DEVTYPE_LEN = 32+1 chars!!!)
  pcDeviceType   = libpointer('cstring', cDeviceType);
  cFW_Version    = blanks (10);   % grant for enough length! (This means: provide at least SEPIA2_PRI_DEVICE_FW_LEN = 8+1 chars!!!)
  pcFW_Version   = libpointer('cstring', cFW_Version);
  %
  iWL_Count      = int32(0);
  piWL_Count     = libpointer('int32Ptr', iWL_Count);
  iWL            = int32(0);
  piWL           = libpointer('int32Ptr', iWL);
  %
  cOpMod         = blanks(18);   % grant for enough length! (This means: provide at least SEPIA2_PRI_OPERMODE_LEN = 16+1 chars!!!)
  pcOpMod        = libpointer('cstring', cOpMod);
  %
  cTrSrc         = blanks(28);   % grant for enough length! (This means: provide at least SEPIA2_PRI_TRIGSRC_LEN = 26+1 chars!!!)
  pcTrSrc        = libpointer('cstring', cTrSrc);
  bDummy1        = uint8(0);
  pbDummy1       = libpointer('uint8Ptr', bDummy1);
  bDummy2        = uint8(0);
  pbDummy2       = libpointer('uint8Ptr', bDummy2);
  %
  iRetVal = 0;
  %
  PRI_Const_out  = PRI_Const_in;
  % 
  PRI_Const_out(pri) = pri_empty;
  %
  % % filling them with "real" data
  %
  fname = 'SEPIA2_PRI_GetDeviceInfo'; % ( int iDevIdx , int iSlotId , char * pcDeviceID , char * pcDeviceType , char * pcFW_Version , int * piWL_Count ); 
  [iRetVal, cDeviceID, cDeviceType, cFW_Version, iWL_Count] = calllib('Sepia2_Lib', fname, iDevIdx, iSlotId, pcDeviceID, pcDeviceType, pcFW_Version, piWL_Count);
  if Sepia2FunctionSucceeds(iRetVal,fname,iDevIdx,iSlotId,NO_IDX_2)
    %
    PRI_Const_out(pri).PrimaModuleID   = strtrim(cDeviceID);
    PRI_Const_out(pri).PrimaModuleType = strtrim(cDeviceType);
    PRI_Const_out(pri).PrimaFWVers     = strtrim(cFW_Version);
    PRI_Const_out(pri).PrimaTemp_min   = 15.0;
    PRI_Const_out(pri).PrimaTemp_max   = 42.0;
    PRI_Const_out(pri).PrimaUSBIdx     = iDevIdx;
    PRI_Const_out(pri).PrimaSlotId     = iSlotId;
    PRI_Const_out(pri).PrimaWLCount    = iWL_Count;    
    %
    fname = 'SEPIA2_PRI_DecodeWavelength'; % ( int iDevIdx , int iSlotId , int iWLIdx , int * piWL ); 
    for idx=1:1:iWL_Count
      [iRetVal, iWL] = calllib('Sepia2_Lib', fname, iDevIdx, iSlotId, (idx-1), piWL);
      if Sepia2FunctionSucceeds(iRetVal,fname,iDevIdx,iSlotId,idx-1)
        %
        PRI_Const_out(pri).PrimaWLs(idx) = iWL;
        %
      end
      if iRetVal ~= 0
        break;
      end
    end
    %
    fname = 'SEPIA2_PRI_DecodeOperationMode'; %  ( int iDevIdx , int iSlotId , int iOperModeIdx , char * pcOperMode ); 
    if iRetVal == 0
      for idx=0:1:7 % 7 is definitely greater than the OpMod_Count we want to find
        [iRetVal, ~] = calllib('Sepia2_Lib', fname, iDevIdx, iSlotId, idx, pcOpMod);  
        if iRetVal ~= 0
          if iRetVal == (-6537) %  errorcode -6537: "PRI: illegal operation mode index"  was expected here!
            iRetVal = 0;
            PRI_Const_out(pri).PrimaOpModCount = idx;
          else
            Sepia2FunctionSucceeds(iRetVal,fname,iDevIdx,iSlotId,idx);
          end
          break;
        end
      end
    end
    if iRetVal == 0
      for idx=1:1:PRI_Const_out(pri).PrimaOpModCount
        [iRetVal, cOpMod] = calllib('Sepia2_Lib', fname, iDevIdx, iSlotId, idx-1, pcOpMod);
        cOpMod = lower(strtrim(cOpMod));
        if contains(cOpMod, 'off')
          PRI_Const_out(pri).PrimaOpModOff = idx-1;
        elseif contains(cOpMod, 'narrow')
          PRI_Const_out(pri).PrimaOpModNarrow = idx-1;
        elseif contains(cOpMod, 'broad')
          PRI_Const_out(pri).PrimaOpModBroad = idx-1;
        elseif contains(cOpMod, 'cw')
          PRI_Const_out(pri).PrimaOpModCW = idx-1;
        else
          iRetVal = -6537;
          break;
        end        
      end
    end
    %
    fname = 'SEPIA2_PRI_DecodeTriggerSource'; %  ( int iDevIdx , int iSlotId , int iTrgSrcIdx , char * pcTrgSrc , unsigned char * pbFrequencyEnabled , unsigned char * pbTrigLevelEnabled );
    if iRetVal == 0
      for idx=0:1:7 % 7 is definitely greater than the TrSrc_Count we want to find
        [iRetVal, ~, ~, ~] = calllib('Sepia2_Lib', fname, iDevIdx, iSlotId, idx, pcTrSrc, pbDummy1, pbDummy2);  
        if iRetVal ~= 0
          if iRetVal == (-6541) %  errorcode -6541: "PRI: illegal trigger source index"  was expected here!
            iRetVal = 0;
            PRI_Const_out(pri).PrimaTrSrcCount = idx;
          else
            Sepia2FunctionSucceeds(iRetVal,fname,iDevIdx,iSlotId,idx);
          end
          break;
        end
      end
    end
    if iRetVal == 0
      for idx=1:1:PRI_Const_out(pri).PrimaTrSrcCount
        [iRetVal, cTrSrc, ~, ~] = calllib('Sepia2_Lib', fname, iDevIdx, iSlotId, idx-1, pcTrSrc, pbDummy1, pbDummy2);
        cTrSrc = lower(strtrim(cTrSrc));
        if contains(cTrSrc, 'ext')
          if contains(cTrSrc, 'nim')
            PRI_Const_out(pri).PrimaTrSrcExtNIM = idx-1;
          elseif contains(cTrSrc, 'ttl')
            PRI_Const_out(pri).PrimaTrSrcExtTTL = idx-1;
          elseif contains(cTrSrc, 'fal')
            PRI_Const_out(pri).PrimaTrSrcExtFalling = idx-1;
          elseif contains(cTrSrc, 'ris')
            PRI_Const_out(pri).PrimaTrSrcExtRising = idx-1;
          else
            iRetVal = -6541;
            break;
          end
        elseif contains(cTrSrc, 'int')
          PRI_Const_out(pri).PrimaTrSrcInt = idx-1;
        else
          iRetVal = -6541;
          break;
        end        
      end
    end
    %
    %
    if iRetVal == 0
      PRI_Const_out(pri).bInitialized = true;
    end
  end
end
%
%
function bNoErr = Sepia2FunctionSucceeds(iRetVal,cFuncName,iDevIdx,iID1, iID2)
  %
  NO_DEVIDX =     -1;
  NO_IDX_1  = -99999;
  NO_IDX_2  = -97979;
  %
  cErrString  = blanks (56); % grant for enough length! (This means: provide at least 54 chars!!!)
  pcErrString = libpointer('cstring',cErrString);
  %
  if iRetVal == 0
    bNoErr = true;
  else
    [~, cErrString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', iRetVal, pcErrString);
    if iDevIdx == NO_DEVIDX
      if iID1 == NO_IDX_1
        sprintf ('%s returns errorcode %d: "%s"\n',...
                 cFuncName, iRetVal, cErrString)
      else             
        if iID2 == NO_IDX_2
          sprintf ('%s (%03d) returns errorcode %d: "%s"\n',...
                   cFuncName, iID1, iRetVal, cErrString)
        else
          sprintf ('%s (%03d, %d) returns errorcode %d: "%s"\n',...
                   cFuncName, iID1, iID2, iRetVal, cErrString)
        end
      end
    else
      if iID1 == NO_IDX_1
        sprintf ('%s (%1d) returns errorcode %d: "%s"\n',...
                 cFuncName, iDevIdx, iRetVal, cErrString)
      else             
        if iID2 == NO_IDX_2
          sprintf ('%s (%1d, %03d) returns errorcode %d: "%s"\n',...
                   cFuncName, iDevIdx, iID1, iRetVal, cErrString)
        else
          sprintf ('%s (%1d, %03d, %d) returns errorcode %d: "%s"\n',...
                   cFuncName, iDevIdx, iID1, iID2, iRetVal, cErrString)
        end
      end
    end
    bNoErr = false;
  end
end
%
%
function res = iif(cond, in_true, in_false)
  if cond
    res = in_true;
  else
    res = in_false;
  end  
end
%
%
function outstr = FormatEng ( fInp, iMant, cUnit, iFixedSpace, iFixedDigits, bUnitSep )
  %                       % (double fInp, int iMant, char* cUnit = "", int iFixedSpace = -1, int iFixedDigits = -1, unsigned char bUnitSep = 1)
  %PRAEFIXES = 'yzafpnæm kMGTPEZY';
  PRAEFIXES = 'yzafpnµm kMGTPEZY';
  PRAEFIX_OFFSET = 9;
  %
  i         = int32(0);
  bNSign    = uint8(0);
  fNorm     = double(0);
  fTemp0    = double(0);
  iTemp     = int32(0);
  cTemp     = blanks(64);
  cPref     = blanks(2);
  cUnitSep  = blanks(2);
  %
  outstr    = blanks(0);
  %
  bNSign    = (fInp < 0);
  %
  if (fInp == 0)
    iTemp   = 0;
    fNorm   = 0;
  else 
    fTemp0  = log10 (abs (double(fInp))) / log10 (double(1000.0));
    iTemp   = int32(floor (fTemp0));
    if((fTemp0 > 0) || ((fTemp0 - iTemp) == 0))
      fNorm   = realpow (double(1000.0), mod (fTemp0, 1.0));
    else
      fNorm   = realpow (double(1000.0), mod (fTemp0,-1.0) + 1.0);
    end
  end
  %
  i = iMant-1;
  if (fNorm >=  10) 
    i = i-1;
  end
  if (fNorm >= 100) 
    i = i-1;
  end
  %
  cPref    = iif((bUnitSep || (iTemp ~= 0)), PRAEFIXES(iTemp + PRAEFIX_OFFSET), '');
  cUnitSep = iif(bUnitSep,' ','');
  %
  %
  cTemp = sprintf('%.*f%s%s%s',... 
                  iif(iFixedDigits < 0, i, iFixedDigits),... 
                  fNorm * iif(bNSign, -1.0, 1.0),...
                  cUnitSep, cPref, cUnit);
  %
  if (iFixedSpace > strlength(cTemp))
    cDest = sprintf('%*s%s', iFixedSpace - strlength(cTemp), ' ', cTemp);
  else
    cDest = cTemp;
  end
  %
  outstr = cDest;
end  
  