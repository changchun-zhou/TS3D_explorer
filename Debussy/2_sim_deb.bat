vsim -c -novopt work.TS3D_tb -do "run -all"
vfast -o TS3D_tb.fsdb TS3D_tb.vcd

start /b debussy -2001 -f vf.v -ssf TS3D_tb.fsdb -sswr TS3D_tb.rc
pause
