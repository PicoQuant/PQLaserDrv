using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

// General Information about an assembly is controlled through the following 
// set of attributes. Change these attribute values to modify the information
// associated with an assembly.
[assembly: AssemblyDescription("Sepia II - Family Write-Demo")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("PicoQuant GmbH")]
[assembly: AssemblyProduct("SetSomeDataByMSVCSharp")]
[assembly: AssemblyCopyright("Copyright ©  2021")]
[assembly: AssemblyTrademark("Sepia II, Solea, VisUV/IR")]
[assembly: AssemblyCulture("")]

// Setting ComVisible to false makes the types in this assembly not visible 
// to COM components.  If you need to access a type in this assembly from 
// COM, set the ComVisible attribute to true on that type.
[assembly: ComVisible(false)]

// The following GUID is for the ID of the typelib if this project is exposed to COM
[assembly: Guid("648b0f75-75af-4284-ad93-ba368d72a5d9")]

//
// Version information for an assembly consists of the following four values:
//
//      Major Version, Minor Version, Build Number, Revision
//
// but we use it as
//
//      Major Version, Minor Version, Platform Code, Revision
//
#if (_X86)
  #if (DEBUG)
    [assembly: AssemblyTitle("SetSomeDataByMSVCSharp (x86;Debug)")]
  #else
    [assembly: AssemblyTitle("SetSomeDataByMSVCSharp (x86)")]
  #endif
  [assembly: AssemblyVersion("1.2.32.1")]
  [assembly: AssemblyFileVersion("1.2.32.1")]
#elif (_X64)
  #if (DEBUG)
    [assembly: AssemblyTitle("SetSomeDataByMSVCSharp (x64;Debug)")]
  #else
    [assembly: AssemblyTitle("SetSomeDataByMSVCSharp (x64)")]
  #endif
  [assembly: AssemblyVersion("1.2.64.1")]
  [assembly: AssemblyFileVersion("1.2.64.1")]
#else
  [assembly: AssemblyTitle("SetSomeDataByMSVCSharp")]
  [assembly: AssemblyVersion("1.2.0.1")]
  [assembly: AssemblyFileVersion("1.2.0.1")]
#endif
//