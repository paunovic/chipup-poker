//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("dxsChipUpDark.res");
USEPACKAGE("rtl.bpi");
USEPACKAGE("dxCoreRS14.bpi");
USEPACKAGE("vcl.bpi");
USEPACKAGE("dxGDIPlusRS14.bpi");
USEPACKAGE("cxLibraryRS14.bpi");
USEPACKAGE("dxSkinsCoreRS14.bpi");
USEUNIT("dxsChipUpDark.pas");
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
