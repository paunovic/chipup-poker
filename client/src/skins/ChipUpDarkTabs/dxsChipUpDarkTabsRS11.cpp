//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("dxsChipUpDarkTabs.res");
USEPACKAGE("rtl.bpi");
USEPACKAGE("dxCoreRS11.bpi");
USEPACKAGE("vcl.bpi");
USEPACKAGE("dxGDIPlusRS11.bpi");
USEPACKAGE("cxLibraryRS11.bpi");
USEPACKAGE("dxSkinsCoreRS11.bpi");
USEUNIT("dxsChipUpDarkTabs.pas");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------
//   Package source.
//---------------------------------------------------------------------------
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
        return 1;
}
//---------------------------------------------------------------------------
