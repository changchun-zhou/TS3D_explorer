srcSourceCodeView
debImport "-2001" "-f" "vf.v"
debLoadSimResult F:\1-DL_hardware\S2CNN\Project\TS3D\Debussy\TS3D_tb.fsdb
wvCreateWindow
wvResizeWindow -win $_nWave2 450 494 960 332
wvOpenFile -win $_nWave2 \
           {F:\1-DL_hardware\S2CNN\Project\TS3D\Debussy\TS3D_tb.fsdb}
wvRestoreSignal -win $_nWave2 "TS3D_tb.rc"
srcResizeWindow 424 237 886 502
wvResizeWindow -win $_nWave2 450 494 960 332
wvCloseWindow -win $_nWave2
wvGetSignalClose -win $_nWave2
srcDeselectAll -win $_nTrace1
debExit
