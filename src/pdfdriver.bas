#RetroDevStudio.MetaData.BASIC:2049,BASIC V2,uppercase,10,10
#10 IF NOT A THEN A=-1:LOAD"PDF.BIN",PEEK(186),1
20 POKE 56,144:CLR
30 PRINT FRE(0)+65536
#40 T$="AAAABBCCCCCCXYZDDD"
40 T$="AABCDDEFGG"
50 FOR P=1TOLEN(T$)
55  POKE 827+P,ASC(MID$(T$,P,1))
60 NEXT
#828 DEC = 33C HEX. LB=3C, HB=3
#POKING TO $FB -> 251
65 POKE 251,60:POKE 252,3
70 SYS 36864

80 FOR P=679 TO 679+18
90  PRINT PEEK(P);
100 NEXT