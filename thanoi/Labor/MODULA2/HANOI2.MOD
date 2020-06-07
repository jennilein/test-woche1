MODULE Hanoi2;
FROM Bild IMPORT Ausgabe,Linie,Cursor,Loeschen,Lesen;
FROM Consol IMPORT ClearScreen,SetPos,SetPosRel,WriteCard,ReadCard;
CONST start = 1;   pfahl1 = 14;   boden = 18;
      ziel  = 2;   pfahl2 = 40;   rand  = 2;
      hilfe = 3;   pfahl3 = 66;
TYPE  FELD = ARRAY[0..24] OF CHAR;
      TURMTYP = RECORD
          oben: CARDINAL;
          etage: BITSET
      END;
VAR   turm: ARRAY[1..3] OF TURMTYP;
      magazin: ARRAY[0..12] OF FELD;
      scheiben,lauf: CARDINAL;
      weiter:   CHAR;
PROCEDURE Zug(anzahl,anfang,ende,lager: CARDINAL);
BEGIN
   IF anzahl=1 
     THEN Setzen(anfang,ende)
     ELSE Zug(anzahl-1,anfang,lager,ende);
          Setzen(anfang,ende);
          Zug(anzahl-1,lager,ende,anfang)
  END    
END Zug;
PROCEDURE Setzen(von,nach: CARDINAL);
VAR kleinster: CARDINAL;
BEGIN 
      Cursor(FALSE);  kleinster:=Minimum(von);
      Merken(von,nach,kleinster);  
      Transport(von,nach,kleinster);
      SetPos(21,18); WriteCard(von,1);
      SetPos(21,32); WriteCard(nach,1);
      SetPos(24,77); Cursor(TRUE); Lesen(weiter);
      IF weiter=33C THEN HALT END 
END Setzen;
PROCEDURE Transport(von,nach,kleinster: CARDINAL);
VAR tvon,tnach: CARDINAL;
BEGIN
    tvon:=boden-1-turm[von].oben;
    tnach:=boden-turm[nach].oben;
    Ausgabe(magazin[0],tvon,(von-1)*26+rand);
    Ausgabe(magazin[kleinster],tnach,(nach-1)*26+rand);
    lauf:=lauf+1; SetPos(23,14); WriteCard(lauf,5);
END Transport;
PROCEDURE Merken(von,nach,kleinster: CARDINAL);
BEGIN  
  WITH turm[von] DO
    EXCL(etage,kleinster); DEC(oben)
  END;    
  WITH turm[nach] DO
    INCL(etage,kleinster); INC(oben)
  END
END Merken;
PROCEDURE Minimum(index: CARDINAL):CARDINAL;
VAR k: CARDINAL;
BEGIN
  WITH turm[index] DO 
    k:=1; 
    REPEAT 
      IF k IN etage 
        THEN RETURN k
        ELSE INC(k)
      END
    UNTIL k=13
  END
END Minimum;
PROCEDURE Initialisierung(anzahl: CARDINAL);
VAR i: CARDINAL;
    infeld: FELD;
    cc: CHAR;
BEGIN  
  infeld:="            |            "; magazin[0]:=infeld;  
  WITH turm[2] DO oben:=0; etage:={} END; 
  turm[3]:=turm[2];  lauf:=0; cc:="A";
  WITH turm[1] DO
    oben:=anzahl; etage:={}; 
    FOR i:=1 TO anzahl DO
      INCL(etage,i); 
      infeld[12]:=cc; infeld[12-i]:="=";
      infeld[12+i]:="="; cc:=CHR(ORD(cc)+1);
      magazin[i]:=infeld;
    END
  END 
END Initialisierung;
PROCEDURE Bildschirm(anzahl: CARDINAL);
VAR i,h: CARDINAL;
BEGIN
  Loeschen(17,19,1); Linie("-",boden,1,boden,78); 
  h:=boden-anzahl-1;
  Linie("|",h,pfahl1,boden-1,pfahl1);
  Linie("|",h,pfahl2,boden-1,pfahl2);
  Linie("|",h,pfahl3,boden-1,pfahl3); Cursor(FALSE);
  FOR i:=anzahl TO 1 BY -1 DO
    Ausgabe(magazin[i],h+i,rand)
  END;
  Ausgabe("1 ",boden+1,pfahl1); Ausgabe("2 ",0,pfahl2); Ausgabe("3 ",0,pfahl3);
  Ausgabe("Zug von Pfahl    nach Pfahl",21,4); Ausgabe("Zuganzahl:",23,4);
  Ausgabe("naechster Zug >ENTER<      ",24,50);
END Bildschirm;
BEGIN
  ClearScreen; Ausgabe("Tuerme von HANOI",1,10);
  Ausgabe("================",2,10);
  Ausgabe("Wieviele Scheiben sollen aufgelegt werden (1..12) ?  ",17,4);
  REPEAT SetPos(17,57);ReadCard(scheiben) UNTIL (scheiben>0) AND (scheiben<13);
  Initialisierung(scheiben); Bildschirm(scheiben);
  SetPos(24,77); Cursor(TRUE); Lesen(weiter);
  Zug(scheiben,start,ziel,hilfe);
  ClearScreen; Ausgabe("Ende",4,17); Cursor(TRUE)
END Hanoi2.
