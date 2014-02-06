//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("dxsChipUpDark.res");
USEPACKAGE("rtl.bpi");
USEPACKAGE("dxCoreC16.bpi");
USEPACKAGE("vcl.bpi");
USEPACKAGE("dxGDIPlusC16.bpi");
USEPACKAGE("cxLibraryC16.bpi");
USEPACKAGE("dxSkinsCoreC16.bpi");
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
