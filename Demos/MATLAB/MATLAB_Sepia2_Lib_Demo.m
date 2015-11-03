%%-----------------------------------------------------------------------------
%%
%%           MATLAB Demo for the Usage of the Sepia2_Lib.DLL 
%%             (API-Library  for PicoQuant Laser Divers)
%%
%%            Developed for, and running under MATLAB R2006
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
% % You'll find the modified header file named "mHeader_Sepia2_Lib.m"
% % side by side with this demo script. 
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
end;
%
% %
% % use one of these, if you want to test for proper loading
% % either this ...
% %
%
%if libisloaded('Sepia2_Lib')
%  libfunctionsview('Sepia2_Lib'); 
%end;
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
cErrorString    = '                                                       '; % grant for enough length! (This means: provide at least 54 chars!!!)
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
%   end;
% end;
% %
% for n=1:length(err_list)
%   sprintf ('%d: "%s"\n',err_list(n).ErrCode,err_list(n).ErrText)
% end;
%
%%-----------------------------------------------------------------------------
%
% %
% %               '0000000001111111111222222222233333333334444444444555555555566666' 
% %               '1234567890123456789012345678901234567890123456789012345678901234' 
% %
%
cLibVersion     = '                '; % grant for enough length! (This means: provide at least 14 chars!!!)
pLibVersion     = libpointer('cstring',cLibVersion);                 
% %
fname='SEPIA2_LIB_GetVersion';
[ret, cLibVersion] = calllib('Sepia2_Lib', fname, pLibVersion);
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  sprintf ('%s ran OK: Library Version = "%s"\n   For support cases, please always mention the LIB version number\n', fname, cLibVersion)  
end;
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
cProductModelIn   = '                                    '; % grant for enough length! (This means: provide at least 34 chars!!!)
pProductModelIn   = libpointer('voidPtr',[uint8(0) uint8(cProductModelIn)]);  
%
cSerialNumberIn   = '                ';             % grant for enough length! (This means: provide at least 14 chars!!!)
pSerialNumberIn   = libpointer('voidPtr',[uint8(0) uint8(cSerialNumberIn)]);     
%
cProductModelOut  = '                                    '; % grant for enough length! (This means: provide at least 34 chars!!!)
pProductModelOut  = libpointer('voidPtr',[uint8(0) uint8(cProductModelOut)]);  
iProductModelSize = size(cProductModelOut);
%
cSerialNumberOut  = '                '; % grant for enough length! (This means: provide at least 14 chars!!!)
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
iDevIdx = -1;
%
fname='SEPIA2_USB_OpenGetSerNumAndClose'; 
for m=0:1:7
  [ret, pProductModelOut, pSerialNumberOut] = calllib('Sepia2_Lib', fname, m, pProductModelIn, pSerialNumberIn);
  if (ret ~= 0)
    [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
    sprintf ('%s (%d) returns errorcode %d: "%s"\n',fname,m,ret,cErrorString)
  else
    setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2))
    for n=1:1:iSerialNumberSize(2)
      if pSerialNumberOut.Value(n)==0
        iSerialNumberSize(2)=n;
        setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2));
        cSerialNumberOut=strtrim(char(pSerialNumberOut.Value));
        break;
      end;
    end;
    setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2))
    for n=1:1:iProductModelSize(2)
      if pProductModelOut.Value(n)==0
        iProductModelSize(2)=n;
        setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2));
        cProductModelOut=strtrim(char(pProductModelOut.Value));
        break;
      end;
    end;
    sprintf ('%s (%d) ran OK: Product="%s", S/N="%s"\n', fname, m, cProductModelOut, cSerialNumberOut)
    iDevIdx = m;
    break;
  end;
end;
%
if iDevIdx == -1
  sprintf ('No device found; Terminate this run!\n')
  return;
else
  sprintf ('From now on, we take iDevIdx = %d  as USB index for our PQ-LaserDevice!\n', iDevIdx)
end;
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
[ret, pProductModelOut, pSerialNumberOut] = calllib('Sepia2_Lib', fname, iDevIdx, pProductModelIn, pSerialNumberIn);
if (ret ~= 0) && (ret ~= -9005)
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2))
  for n=1:1:iSerialNumberSize(2)
    if pSerialNumberOut.Value(n)==0
      iSerialNumberSize(2)=n;
      setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2));
      cSerialNumberOut=strtrim(char(pSerialNumberOut.Value));
      break;
    end;
  end;
  setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2))
  for n=1:1:iProductModelSize(2)
    if pProductModelOut.Value(n)==0
      iProductModelSize(2)=n;
      setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2));
      cProductModelOut=strtrim(char(pProductModelOut.Value));
      break;
    end;
  end;
  sprintf ('%s ran OK: Product="%s", S/N="%s"\n', fname, cProductModelOut, cSerialNumberOut)
end;
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
%   [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
%   sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
% else
%   setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2))
%   for n=1:1:iSerialNumberSize(2)
%     if pSerialNumberOut.Value(n)==0
%       iSerialNumberSize(2)=n;
%       setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2));
%       cSerialNumberOut=strtrim(char(pSerialNumberOut.Value));
%       break;
%     end;
%   end;
%   setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2))
%   for n=1:1:iProductModelSize(2)
%     if pProductModelOut.Value(n)==0
%       iProductModelSize(2)=n;
%       setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2));
%       cProductModelOut=strtrim(char(pProductModelOut.Value));
%       break;
%     end;
%   end;
%   sprintf ('%s ran OK: Product="%s", S/N="%s"\n', fname, cProductModelOut, cSerialNumberOut)
% end;
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
%   [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
%   sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
% else
%   setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2))
%   for n=1:1:iSerialNumberSize(2)
%     if pSerialNumberOut.Value(n)==0
%       iSerialNumberSize(2)=n;
%       setdatatype(pSerialNumberOut,'uint8Ptr',iSerialNumberSize(1),iSerialNumberSize(2));
%       cSerialNumberOut=strtrim(char(pSerialNumberOut.Value));
%       break;
%     end;
%   end;
%   setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2))
%   for n=1:1:iProductModelSize(2)
%     if pProductModelOut.Value(n)==0
%       iProductModelSize(2)=n;
%       setdatatype(pProductModelOut,'uint8Ptr',iProductModelSize(1),iProductModelSize(2));
%       cProductModelOut=strtrim(char(pProductModelOut.Value));
%       break;
%     end;
%   end;
%   sprintf ('%s ran OK: Product="%s", S/N="%s"\n', fname, cProductModelOut, cSerialNumberOut)
% end;
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
cFWRVersion       = '         '; % grant for enough length! (This means: provide at least 8 chars!!!)
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
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  sprintf ('%s ran OK: cStringDescr = "%s"\n', fname, cStringDescr)  
end;
%
fname = 'SEPIA2_FWR_GetVersion';
[ret, cFWRVersion] = calllib('Sepia2_Lib', fname, iDevIdx, pcFWRVersion);
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  sprintf ('%s ran OK: Firmware Version = "%s"\n   For support cases, please always mention the FWR version number\n', fname, cFWRVersion)  
end;
%
% %
% % let's read out the result of the latest firmware boot.
% % this information is vital for the support in case of hardware trouble!
% %
%
% extern int _stdcall SEPIA2_FWR_GetLastError ( int iDevIdx , int * piErrCode , int * piPhase , int * piLocation , int * piSlot , char * cCondition ); 
fname = 'SEPIA2_FWR_GetLastError';
[ret, iErrCode, iErrPhase, iErrLocation, iErrSlot, cErrCondition] = calllib('Sepia2_Lib', fname, iDevIdx, piErrCode, piErrPhase, piErrLocation, piErrSlot, pcErrCondition);
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  if iErrCode ~= 0
    [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', iErrCode, pcErrorString);
    [ret1, cErrorPhase]  = calllib('Sepia2_Lib', 'SEPIA2_FWR_DecodeErrPhaseName', iErrPhase, pcErrorPhase);
    sprintf (['%s ran OK:\n\n'...
              '   Last firmware boot resulted in following error:\n'...
              '   Error Code      = %5d      (i.e. "%s")\n'...
              '   Error Phase     = %5d      (i.e. "%s")\n'...
              '   Error Location  = %5d\n'...
              '   Error Slot      =   %03d\n'...
              '   Error Condition = "%s"\n\n'...
              '   For support cases, please always mention the  "Last Error"  block\n\n'], fname, iErrCode, cErrorString, iErrPhase, cErrorPhase, iErrLocation, iErrSlot, cErrCondition)
  else
    sprintf (['%s ran OK: Last firmware boot was error-free!\n'...
              '   For support cases, please mention, that the  "Last Error"  block was clear!\n\n'], fname)  
  end;
end;
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
pModuleCount    = libpointer('int32Ptr',0);
%
fname = 'SEPIA2_FWR_GetModuleMap';
[ret, iModuleCount] = calllib('Sepia2_Lib', fname, iDevIdx, iPerformRestart, pModuleCount);
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  sprintf ('%s ran OK: iModuleCount = %d\n', fname, iModuleCount)  
end;
%
%
%%-----------------------------------------------------------------------------
%  Iterate through the Map
%%-----------------------------------------------------------------------------
%
%
% %
% % Now we inspect the modules by map index and collect categorical infos,
% % as - most important - the slot IDs...
% %
%
iSlotId = 0;
piSlotId = libpointer('int32Ptr', iSlotId);
bIsPrimary = uint8 (0);
pbIsPrimary = libpointer('uint8Ptr', bIsPrimary);
bIsBackPlane = uint8 (0);
pbIsBackPlane = libpointer('uint8Ptr', bIsBackPlane);
bHasUptimeCounter = uint8 (0);
pbHasUptimeCounter = libpointer('uint8Ptr', bHasUptimeCounter);
iModTyp = int32 (0);
piModTyp = libpointer('int32Ptr', iModTyp);
%
% %               '0000000001111111111222222222233333333334444444444555555555566666' 
% %               '1234567890123456789012345678901234567890123456789012345678901234' 
% %
%
cModTyp         = blanks(58); % grant for enough length! (This means: provide at least 56 chars!!!)
pcModTyp        = libpointer('cstring',cModTyp);  
cModTypA        = '    '; % grant for enough length! (This means: provide at least 4 chars!!!)
pcModTypA       = libpointer('cstring',cModTypA);
cLabel          = '        '; % grant for enough length! (This means: provide at least 8 chars!!!)
pcLabel         = libpointer('cstring',cLabel);
cSerialNo       = '            '; % grant for enough length! (This means: provide at least 12 chars!!!)
pcSerialNo      = libpointer('cstring',cSerialNo);
cReleaseDate    = '        '; % grant for enough length! (This means: provide at least 8 chars!!!)
pcReleaseDate   = libpointer('cstring',cReleaseDate);
cRevision       = '        '; % grant for enough length! (This means: provide at least 8 chars!!!)
pcRevision      = libpointer('cstring',cRevision);
cHdrMemo        = blanks(128); % grant for enough length! (This means: provide at least 128 chars!!!)
pcHdrMemo       = libpointer('cstring',cHdrMemo);
cSOMFrqTrgMod   = '                                '; % grant for enough length! (This means: provide at least 32 chars!!!)
pcSOMFrqTrgMod  = libpointer('cstring',cSOMFrqTrgMod);
cSLMFrqTrgMod   = '                            '; % grant for enough length! (This means: provide at least 28 chars!!!)
pcSLMFrqTrgMod  = libpointer('cstring',cSLMFrqTrgMod);
cSLMHeadType    = '                  '; % grant for enough length! (This means: provide at least 18 chars!!!)
pcSLMHeadType   = libpointer('cstring',cSLMHeadType);
%
modtyp = struct('iSlotId', int32(0), 'bIsPrimary', uint8(0), 'bIsBackPlane', uint8(0), 'bHasUptimeCounter', uint8(0), 'iModTyp', uint8(0), 'cModTyp', cModTyp, 'cModTypA', cModTypA, 'cSerialNo', cSerialNo, 'cLabel', cLabel, 'cReleaseDate', cReleaseDate, 'cRevision', cRevision, 'cHdrMemo', cHdrMemo);
Modules(iModuleCount) = modtyp;
Orig_Slot = -1;
SCM_Slot  = -1;
SOM_Slot  = -1;
isSOMD    = false;
SOM_TrigModCount   = 0;
SOMFrqTrgModi{1,5} = []; % SEPIA2_SOM_FREQ_TRIGMODE_COUNT == 5
SLMFrqTrgModi{1,8} = []; % SEPIA2_SLM_FREQ_TRIGMODE_COUNT == 8
SLMHeadTypes{1,4}  = []; % SEPIA2_SLM_HEAD_TYPES_COUNT == 4
SLM_Count = 0;
SLM_Slot  = zeros (1, 8); % this is the max. for large Sepia II frames...
%
for m=1:1:iModuleCount
  iMapIdx = m-1;
  module  = modtyp;
  %
  [ret, module.iSlotId, module.bIsPrimary, module.bIsBackPlane, module.bHasUptimeCounter] = calllib('Sepia2_Lib', 'SEPIA2_FWR_GetModuleInfoByMapIdx', iDevIdx, iMapIdx, piSlotId, pbIsPrimary, pbIsBackPlane, pbHasUptimeCounter);
  if ret ~= 0
    [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
    sprintf ('SEPIA2_FWR_GetModuleInfoByMapIdx(%d) returns errorcode %d: "%s"\n',iMapIdx,ret,cErrorString)
  end;
  %
  if (module.bIsBackPlane~=0)
    % this is a trick to get more infos on the backplane; 
    % sorry, but since this is only needed on rare occasions...
    Orig_Slot = module.iSlotId;
    module.iSlotId=-1;
  end;
  %
  [ret, module.iModTyp] = calllib('Sepia2_Lib', 'SEPIA2_COM_GetModuleType', iDevIdx, module.iSlotId, module.bIsPrimary, piModTyp);
  if ret ~= 0
    [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
    sprintf ('SEPIA2_COM_GetModuleType(%d) returns errorcode %d: "%s"\n',iMapIdx,ret,cErrorString)
  end;
  %
  [ret, module.cModTyp] = calllib('Sepia2_Lib', 'SEPIA2_COM_DecodeModuleType', module.iModTyp, pcModTyp);
  if ret ~= 0
    [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
    sprintf ('SEPIA2_COM_DecodeModuleTypeAbbr(Typ=%d) returns errorcode %d: "%s"\n',module.iModTyp,ret,cErrorString)
  end;
  %
  [ret, module.cModTypA] = calllib('Sepia2_Lib', 'SEPIA2_COM_DecodeModuleTypeAbbr', module.iModTyp, pcModTypA);
  if ret ~= 0
    [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
    sprintf ('SEPIA2_COM_DecodeModuleTypeAbbr(Typ=%d) returns errorcode %d: "%s"\n',module.iModTyp,ret,cErrorString)
  end;
  %
  [ret, module.cSerialNo] = calllib('Sepia2_Lib', 'SEPIA2_COM_GetSerialNumber', iDevIdx, module.iSlotId, module.bIsPrimary, pcSerialNo); 
  %
  [ret, module.cLabel, module.cReleaseDate, module.cRevision, module.cHdrMemo] = calllib('Sepia2_Lib', 'SEPIA2_COM_GetSupplementaryInfos', iDevIdx, module.iSlotId, module.bIsPrimary, pcLabel, pcReleaseDate, pcRevision, pcHdrMemo);
  %
  % % nowadays, you could use the strsplit function,
  % % but this was not included in MATLAB R2006b...
  %
  cHeader4Printing = '';
  remain = module.cHdrMemo;
  while true
    [str, remain] = strtok (remain, char([10 13]));
    if isempty(str)
      break;  
    end;
    if ~isempty(cHeader4Printing)
      cHeader4Printing = [cHeader4Printing sprintf('\n                  | ') str];
    else
      cHeader4Printing = str;
    end;
  end;
  %
  if module.bIsBackPlane == 0
    sprintf (['There is a %s module in slot %3.3d:\n'...
              '   Serial No.   = "%s"\n'...
              '   Label        = "%s"\n'...
              '   Release Date = "%s"\n'...
              '   Revision     = "%s"\n'...
              '   Header Memo  = | %s\n\n'], module.cModTypA, module.iSlotId, module.cSerialNo, module.cLabel, module.cReleaseDate, module.cRevision, cHeader4Printing)
  end;
  %
  switch module.cModTypA
    case 'SCM'
      SCM_Slot = module.iSlotId;
      %
    case 'SOM'
      SOM_Slot = module.iSlotId;
      isSOMD   = false;
      SOM_SeqCtrlCount  = 3; % SEPIA2_SOM_AUXIN_SequencerCtrl_COUNT == 3
      %
      for n=0:1:4 % SEPIA2_SOM_FREQ_TRIGMODE_COUNT-1
        [ret,cSOMFrqTrgMod] = calllib('Sepia2_Lib', 'SEPIA2_SOM_DecodeFreqTrigMode', iDevIdx, SOM_Slot, n, pcSOMFrqTrgMod);
        if ret == 0
          SOM_TrigModCount = n+1;
          SOMFrqTrgModi{1, n+1} = cSOMFrqTrgMod;          
        else
          [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
          sprintf ('SEPIA2_SOM_DecodeFreqTrigMode(%d) returns errorcode %d: "%s"\n',n,ret,cErrorString)
          break;
        end;
      end;
      %
    case 'SOMD'
      SOM_Slot = module.iSlotId;
      isSOMD   = true;
      SOM_SeqCtrlCount  = 4; % SEPIA2_SOMD_AUXIN_SequencerCtrl_COUNT == 4
      %
      for n=0:1:4 % SEPIA2_SOMD_FREQ_TRIGMODE_COUNT-1
        [ret,cSOMFrqTrgMod] = calllib('Sepia2_Lib', 'SEPIA2_SOMD_DecodeFreqTrigMode', iDevIdx, SOM_Slot, n, pcSOMFrqTrgMod);
        if ret == 0
          SOM_TrigModCount = n+1;
          SOMFrqTrgModi{1, n+1} = cSOMFrqTrgMod;          
        else
          [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
          sprintf ('SEPIA2_SOMD_DecodeFreqTrigMode(%d) returns errorcode %d: "%s"\n',n,ret,cErrorString)
          break;
        end;
      end;
      %
    case 'SLM'
      SLM_Count = SLM_Count+1;
      SLM_Slot(SLM_Count) = module.iSlotId;
      %
      for n=0:1:7 % SEPIA2_SLM_FREQ_TRIGMODE_COUNT-1
        [ret,cSLMFrqTrgMod] = calllib('Sepia2_Lib', 'SEPIA2_SLM_DecodeFreqTrigMode', n, pcSLMFrqTrgMod);
        if ret == 0
          SLMFrqTrgModi{1, n+1} = cSLMFrqTrgMod;          
        else
          [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
          sprintf ('SEPIA2_SLM_DecodeFreqTrigMode(%d) returns errorcode %d: "%s"\n',n,ret,cErrorString)
          break;
        end;
      end;
      %
      for n=0:1:3 % SEPIA2_SLM_HEAD_TYPE_COUNT-1
        [ret,cSLMHeadType] = calllib('Sepia2_Lib', 'SEPIA2_SLM_DecodeHeadType', n, pcSLMHeadType);
        if ret == 0
          SLMHeadTypes{1, n+1} = cSLMHeadType;          
        else
          [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
          sprintf ('SEPIA2_SLM_DecodeHeadType(%d) returns errorcode %d: "%s"\n',n,ret,cErrorString)
          break;
        end;
      end;
      %
    %
    % implement additional cases here
    %   for modules typical for Solea or PPL400 drivers
    % ...
    % ... 
    otherwise
      if module.bIsBackPlane > 0
        sprintf ('We don''t handle the %s backplane carrying slot %3.3d\n', module.cModTypA, Orig_Slot)
      else
        sprintf ('Yet, we don''t handle the %s module in slot %3.3d\n', module.cModTypA, module.iSlotId)
      end;
  end;
  %
  Modules(m) = module;
end;
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
[ret,bPowerLED,bLaserActiveLED] = calllib('Sepia2_Lib', 'SEPIA2_SCM_GetPowerAndLaserLEDS', iDevIdx, SCM_Slot, pbPowerLED, pbLaserActiveLED);
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('SEPIA2_SCM_GetPowerAndLaserLEDS returns errorcode %d: "%s"\n',ret,cErrorString)
else
  if bPowerLED~=0
    bPowerLED=1;
  end;
  if bLaserActiveLED~=0
    bLaserActiveLED=1;
  end;
  cSCM_Out = sprintf ('\n   Power LED        is %s \n   Laser Active LED is %s \n', strtrim(OffOn_Values(bPowerLED+1,:)), strtrim(OffOn_Values(bLaserActiveLED+1,:)));
end;
%
[ret,bLaserLocked] = calllib('Sepia2_Lib', 'SEPIA2_SCM_GetLaserLocked', iDevIdx, SCM_Slot, pbLaserLocked);
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('SEPIA2_SCM_GetLaserLocked returns errorcode %d: "%s"\n',ret,cErrorString)
else
  if bLaserLocked ~= 0
    [ret,bLaserSoftLocked] = calllib('Sepia2_Lib', 'SEPIA2_SCM_GetLaserSoftLock', iDevIdx, SCM_Slot, pbLaserSoftLocked);
    if ret ~= 0
      [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
      sprintf ('SEPIA2_SCM_GetLaserSoftLock returns errorcode %d: "%s"\n',ret,cErrorString)
    end;
    if bLaserSoftLocked ~= 0
      bLaserSoftLocked = 1;
    end;
    cSCM_Out = [cSCM_Out sprintf('\n   Lasers are %s locked\n', HardSoft_Values(bLaserSoftLocked+1,:))];
  else
    cSCM_Out = [cSCM_Out sprintf('\n   Lasers are unlocked\n')];
  end;
end;
sprintf ('\nSCM (slot %03d) state:\n%s\n', SCM_Slot, cSCM_Out)
%
% % 
% % next following the SOM / SOM-D
% %
%
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
end;
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
cSOMSeqCtrl       = '                         '; % grant for enough length! (This means: provide at least 24 chars!!!)
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
  [ret,iSOMTrgMod,bSynchronized] = calllib('Sepia2_Lib', 'SEPIA2_SOMD_GetFreqTrigMode', iDevIdx, SOM_Slot, piSOMTrgMod, pbSynchronized);
  if ret ~= 0
    [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
    sprintf ('SEPIA2_SOMD_GetFreqTrigMode returns errorcode %d: "%s"\n',ret,cErrorString)
  else
    if bSynchronized ~= 0
      bSynchronized = 1;
    end;
    cTemp = SOMFrqTrgModi{1,iSOMTrgMod+1};
    cSOM_Out = sprintf ('   Trigger Mode  : %s\n   Synchronized  : %s', cTemp, strtrim(OffOn_Values(bSynchronized+1,:)));
  end;
else
  [ret,iSOMTrgMod] = calllib('Sepia2_Lib', 'SEPIA2_SOM_GetFreqTrigMode', iDevIdx, SOM_Slot, piSOMTrgMod);
  if ret ~= 0
    [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
    sprintf ('SEPIA2_SOM_GetFreqTrigMode returns errorcode %d: "%s"\n',ret,cErrorString)
  else
    cTemp = SOMFrqTrgModi{1,iSOMTrgMod+1};
    cSOM_Out = sprintf ('   Trigger Mode  : %s', cTemp);
  end;
end;
%
% %
% % The following functions exist for SOM and SOMD, respectively, with the very same footprint.
% % You could implement wrapper functions to have only one instance for the both of them, 
% % but you could also call the respective function by simply variing the name string:
% %
%
fname = sprintf('SEPIA2_SOM%s_GetTriggerRange', cSOM_Discr);
[ret,iSOMTrgLvlLo,iSOMTrgLvlHi] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, piSOMTrgLvlLo, piSOMTrgLvlHi);
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  SOMTrgRange = [iSOMTrgLvlLo, iSOMTrgLvlHi];
  cTemp = sprintf ('\n   Trigger Range : %5d mV <= Trigger Level <= %d mV', iSOMTrgLvlLo, iSOMTrgLvlHi);
  cSOM_Out = [cSOM_Out, cTemp];
end;
%
fname = sprintf('SEPIA2_SOM%s_GetTriggerLevel', cSOM_Discr);
[ret,iSOMTrgLvl] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, piSOMTrgLvl);
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  cTemp = sprintf ('\n   Trigger Level : %5d mV', iSOMTrgLvl);
  cSOM_Out = [cSOM_Out, cTemp];
end;
%
fname = sprintf('SEPIA2_SOM%s_GetBurstValues', cSOM_Discr);
% this function differs in footprint, due to the bigger divider for SOMD,
% but we declared iSOMDivider and piSOMDivider different above, to fit either needs
%
[ret,iSOMDivider,bPreSync,bSyncMask] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, piSOMDivider, pbPreSync, pbSyncMask);
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  cTemp = sprintf ('\n   Base Divider  : %5d\n   Pre-Sync      : %5d\n   Sync Mask     : %5d', iSOMDivider, bPreSync, bSyncMask);
  cSOM_Out = [cSOM_Out, cTemp];
end;
%
fname = sprintf('SEPIA2_SOM%s_GetOutNSyncEnable', cSOM_Discr);
[ret,bOutEnable,bSyncEnable,bSyncInverse] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, pbOutEnable, pbSyncEnable, pbSyncInverse);
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  % bOutEnable and bSyncEnable are bitcoded information 
  % on the output states and therefore handled later with the outputs
  if bSyncInverse ~= 0
    cSOM_Out = [cSOM_Out, ';   (mask is working inverted)'];
  else
    cSOM_Out = [cSOM_Out, ';   (mask is working normal)'];
  end;
end;
%
fname = sprintf('SEPIA2_SOM%s_DecodeAUXINSequencerCtrl', cSOM_Discr);
SOMSeqCtrl{1,SOM_SeqCtrlCount} = [];
for n=0:1:SOM_SeqCtrlCount-1
  [ret,cSOMSeqCtrl] = calllib('Sepia2_Lib', fname, n, pcSOMSeqCtrl);
  SOMSeqCtrl{1,n+1} = cSOMSeqCtrl;
end;
%
fname = sprintf('SEPIA2_SOM%s_GetAUXIOSequencerCtrl', cSOM_Discr);
[ret,bAUXOutCtrl,bAUXInCtrl] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, pbAUXOutCtrl, pbAUXInCtrl);
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  if bAUXOutCtrl ~= 0
    bAUXOutCtrl = 1;
  end;
  cTemp = SOMSeqCtrl{1,bAUXInCtrl+1};
  cTemp = sprintf ('\n   AUX Output    : %s\n   Sequencer     : %s',  strtrim(DisEna_Values(bAUXOutCtrl+1,:)), cTemp);
  cSOM_Out = [cSOM_Out, cTemp];
end;
%
% %
% % Now we inspect the output channel lines of our SOM 
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
end;
%
fname = sprintf('SEPIA2_SOM%s_GetBurstLengthArray', cSOM_Discr);
[ret,iBurstLen1,iBurstLen2,iBurstLen3,iBurstLen4,iBurstLen5,iBurstLen6,iBurstLen7,iBurstLen8] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, piBurstLen1, piBurstLen2, piBurstLen3, piBurstLen4, piBurstLen5, piBurstLen6, piBurstLen7, piBurstLen8);
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  SOMOutput(1).iBurstLen = iBurstLen1;
  SOMOutput(2).iBurstLen = iBurstLen2;
  SOMOutput(3).iBurstLen = iBurstLen3;
  SOMOutput(4).iBurstLen = iBurstLen4;
  SOMOutput(5).iBurstLen = iBurstLen5;
  SOMOutput(6).iBurstLen = iBurstLen6;
  SOMOutput(7).iBurstLen = iBurstLen7;
  SOMOutput(8).iBurstLen = iBurstLen8;
end;
%
for n=1:1:8
  bitmask = bitset(uint8(0), n);
  if bitand (bitmask, bSyncEnable) ~= 0
    SOMOutput(n).bSyncEna = 1;
  else
    SOMOutput(n).bSyncEna = 0;
  end;
  if bitand (bitmask, bOutEnable) ~= 0
    SOMOutput(n).bOutEna = 1;
  else
    SOMOutput(n).bOutEna = 0;
  end;
  cTemp = sprintf ('\n   Line %d        : Burst Length = %8d;   Sync %8s;   Output %8s', n, SOMOutput(n).iBurstLen, strtrim(DisEna_Values(SOMOutput(n).bSyncEna+1,:)), strtrim(DisEna_Values(SOMOutput(n).bOutEna+1,:)));
  cSOM_Out = [cSOM_Out, cTemp];
  %
  if isSOMD ~= 0
    fname = 'SEPIA2_SOMD_GetSeqOutputInfos';
    [ret,bDelayed,bForcedUndelayed,bOutCombi,bMaskedCombi,f64CoarseDly,bFineDly] = calllib('Sepia2_Lib', fname, iDevIdx, SOM_Slot, uint8(n-1), pbDelayed, pbForcedUndelayed, pbOutCombi, pbMaskedCombi, pf64CoarseDly, pbFineDly);
    if ret ~= 0
      [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
      sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
    else
      if ((bDelayed == 0) || (bForcedUndelayed ~= 0))
        % 
        % this line combines some bursts undelayed
        %
        cCombi = '';
        for m=1:1:8
          bitmask2 = bitset(uint8(0), m);
          if bitand (bitmask2, bOutCombi) ~= 0
            if length(cCombi > 0)
              cCombi = [cCombi ', ' int2str(m)];
            else
              cCombi = int2str(m);
            end;
          end;
        end;
        %
        if length(cCombi) > 1
          cTemp = sprintf (';  Combining bursts %s', cCombi); 
        else
          cTemp = sprintf (';  Outputs burst %s', cCombi); 
        end;
        %
      else
        % 
        % this line outputs its burst delayed
        %
        cTemp = sprintf (';  Delayed: %.1f nsec + %d fine steps', f64CoarseDly, bFineDly); 
        %
      end;
      cSOM_Out = [cSOM_Out, cTemp];
    end;
  end;
end;
%
sprintf ('\nSOM%s (slot %03d) state:\n%s\n', cSOM_Discr, SOM_Slot, cSOM_Out)
%
%
% % 
% % last but not least we inspect the SLM(s)
% %
% % don't use deprecated functions "SEPIA2_SLM_GetParameters" and "SEPIA2_SLM_SetParameters"
%
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
  cSLM_Out = '';
  SLMs(slm) = slmtyp;
  %
  SLMs(slm).iSlotId = SLM_Slot(slm);  
  %
  fname = 'SEPIA2_SLM_GetPulseParameters';  
  [ret, iFreqTrgMod, bPulseMode, iHeadType] = calllib('Sepia2_Lib', fname, iDevIdx, SLM_Slot(slm), piFreqTrgMod, pbPulseMode, piHeadType);
  if ret ~= 0
    [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
    sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
  else
    if bPulseMode ~= 0
      bPulseMode = 1;
    end;
    SLMs(slm).iFreqTrgMod = iFreqTrgMod;
    SLMs(slm).bPulseMode  = bPulseMode;
    SLMs(slm).iHeadType   = iHeadType;
  end;
  %
  fname = 'SEPIA2_SLM_GetIntensityFineStep';  
  [ret, wIntensity] = calllib('Sepia2_Lib', fname, iDevIdx, SLM_Slot(slm), pwIntensity);
  if ret ~= 0
    [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
    sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
  else
    SLMs(slm).wIntensity = wIntensity;
  end;
  %
  cTemp = SLMFrqTrgModi{1,iFreqTrgMod+1};
  cTemp1 = SLMHeadTypes{1,iHeadType+1};
  cSLM_Out = sprintf ('\n   Trigger Mode  : %s\n   Pulse Mode    : %s\n   Head Type     : %s\n   Intensity     : %5.1f %%', cTemp, strtrim(DisEna_Values(bPulseMode+1,:)), cTemp1, 1.0 * wIntensity / 10);
  %
  sprintf ('\nSLM %d (slot %03d) state:\n%s\n', slm, SLM_Slot(slm), cSLM_Out)
end;
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
% % used as input, they are also listed in the output vector,
% % whilst the last one is by all means a simple output parameter.
% %
%
cPreamble     = sprintf (['\nThese infos (in the freshest state) are to be sent\n'...
                          'to support@PicoQuant.com in case of a support request.\n']);
pcPreamble    = libpointer('voidPtr',[uint8(cPreamble) uint8(0)]);  
%
cCallingSW    = 'MATLAB Demo';
pcCallingSW   = libpointer('voidPtr',[uint8(cCallingSW) uint8(0)]);     
%
cSupportText  = blanks (65536); % grant for enough length! (This means: provide at least 65535 chars!!!)
pcSupportText = libpointer('cstring',cSupportText);                              
%
%
fname = 'SEPIA2_FWR_CreateSupportRequestText';
[ret,cPreamble,cCallingSW,cSupportText] = calllib('Sepia2_Lib', fname, iDevIdx, pcPreamble, pcCallingSW, 0, length(cSupportText), pcSupportText); 
if ret ~= 0
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  %
  % %
  % % for a good result readable in the command window,
  % % we have to replace <CR><LF> by only <LF>.
  % % if writing to a file, however, you should comment this out!
  % % (otherwise, the CRC will fail on checks!)
  % %
  %
  cText4Printing = strrep (cSupportText, char([13 10]), char(10));
  %
  sprintf (['%%-----------------------------------------------------------------------------\n'...
            '%s\n'...
            '%%-----------------------------------------------------------------------------\n'], cText4Printing)
end;
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
%   end;    
%   fname = 'SEPIA2_SLM_SetIntensityFineStep';  
%   %ret = calllib('Sepia2_Lib', fname, iDevIdx, SLMs(1).iSlotId, 500+wDelta);
%   if ret ~= 0
%     [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
%     sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
%   end;
% end;
% empty_loop=toc;
% %
% tic;
% for n=1:1:loops
%   %
%   if bitand(1, n) > 0
%     wDelta = uint16(100);
%   else
%     wDelta = uint16(0);
%   end;    
%   fname = 'SEPIA2_SLM_SetIntensityFineStep';  
%   ret = calllib('Sepia2_Lib', fname, iDevIdx, SLMs(1).iSlotId, 500+wDelta);
%   if ret ~= 0
%     [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
%     sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
%   end;
% end;
% real_loop=toc;
% %
% sprintf (['\n\nBenchmark (%d calls) Results:\n'...
%           '   Benchmark took overall %.3f sec,\n'...
%           '   thereof %.3f msec for surrounding (ineffective) statements.\n'...
%           '   After deductions, "SEPIA2_SLM_SetIntensityFineStep"  took on average %8.3f msec per call.\n'], loops, real_loop+empty_loop, 2000*empty_loop, 1000.0*(real_loop-empty_loop)/loops)
% %
% fname = 'SEPIA2_SLM_SetIntensityFineStep';  
% ret = calllib('Sepia2_Lib', fname, iDevIdx, SLMs(1).iSlotId, OldIntensity);
% if ret ~= 0
%   [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
%   sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
% end;
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
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  sprintf ('%s ran OK\n', fname)
end;
%
fname = 'SEPIA2_USB_CloseDevice';
ret = calllib('Sepia2_Lib', fname, iDevIdx);
if (ret ~= 0)
  [ret1, cErrorString] = calllib('Sepia2_Lib', 'SEPIA2_LIB_DecodeError', ret, pcErrorString);
  sprintf ('%s returns errorcode %d: "%s"\n',fname,ret,cErrorString)
else
  sprintf ('%s ran OK\n', fname)
end;
%
unloadlibrary Sepia2_Lib;
set (0, 'FormatSpacing', old_FormatSpacing);
set (0, 'Format', old_Format);
%clear;
%