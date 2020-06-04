del *.ppu
del *.o
call lz64 zeit
call lz64 test1
del test1_fpc.exe
ren test1.exe test1_fpc.exe
call lz64 test2
del test2_fpc.exe
ren test2.exe test2_fpc.exe
call lz64 test3
del test3_fpc.exe
ren test3.exe test3_fpc.exe
del *.ppu
del *.o
call lz64 zeit
call lz64 test1
del test1_dos.exe
ren test1.exe test1_dos.exe
call lz64 test2
del test2_dos.exe
ren test2.exe test2_dos.exe
call lz64 test3
del test3_dos1.exe
ren test3.exe test3_dos1.exe
del *.ppu
del *.o
call lz64 -ddosfpc zeit
call lz64 -ddosfpc test3
del test3_dos2.exe
ren test3.exe test3_dos2.exe
del *.ppu
del *.o
