using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

// General Information about an assembly is controlled through the following 
// set of attributes. Change these attribute values to modify the information
// associated with an assembly.
[assembly: AssemblyDescription("Sepia II - Family Read-Demo")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("PicoQuant GmbH")]
[assembly: AssemblyProduct("ReadAllDataByMSVCSharp")]
[assembly: AssemblyCopyright("Copyright ©  2021")]
[assembly: AssemblyTrademark("Sepia II, Solea, VisUV/IR")]
[assembly: AssemblyCulture("")]

// Setting ComVisible to false makes the types in this assembly not visible 
// to COM components.  If you need to access a type in this assembly from 
// COM, set the ComVisible attribute to true on that type.
[assembly: ComVisible(false)]

// The following GUID is for the ID of the typelib if this project is exposed to COM
[assembly: Guid("ee1d44ce-98ed-4323-8895-c9b8ee864c0b")]

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
	  [assembly: AssemblyTitle("ReadAllDataByMSVCSharp (x86;Debug)")]
	#else
	  [assembly: AssemblyTitle("ReadAllDataByMSVCSharp (x86)")]
	#endif
	[assembly: AssemblyVersion("1.2.32.1")]
	[assembly: AssemblyFileVersion("1.2.32.1")]
#elif (_X64)
  #if (DEBUG)
    [assembly: AssemblyTitle("ReadAllDataByMSVCSharp (x64;Debug)")]
  #else
    [assembly: AssemblyTitle("ReadAllDataByMSVCSharp (x64)")]
  #endif
  [assembly: AssemblyVersion("1.2.64.1")]
  [assembly: AssemblyFileVersion("1.2.64.1")]
#else
	[assembly: AssemblyTitle("ReadAllDataByMSVCSharp")]
	[assembly: AssemblyVersion("1.2.0.1")]
	[assembly: AssemblyFileVersion("1.2.0.1")]
#endif
//