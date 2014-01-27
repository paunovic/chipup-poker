//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("dxsChipUpDark.res");
USEPACKAGE("rtl.bpi");
USEPACKAGE("dxCoreRS16.bpi");
USEPACKAGE("vcl.bpi");
USEPACKAGE("dxGDIPlusRS16.bpi");
USEPACKAGE("cxLibraryRS16.bpi");
USEPACKAGE("dxSkinsCoreRS16.bpi");
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
