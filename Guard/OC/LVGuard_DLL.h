//LVGuard_DLL.h

#ifndef LVGUARD_DLL
#define LVGUARD_DLL


#ifdef BUILDING_EXAMPLE_DLL
#define LVGUARD __declspec(dllexport)
#else
#define LVGUARD __declspec(dllimport)
#endif

void LVGUARD LVRecieveCtrl(bool& valid, double& uReal, int& uInt);

#endif