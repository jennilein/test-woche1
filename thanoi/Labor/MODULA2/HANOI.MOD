MODULE Hanoi;
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
      LESEMASKE = PROCEDURE(CHAR):CARDINAL;
      SCHREIBMASKE = PROCEDURE(CHAR):CHAR;
VAR   turm: ARRAY[1..3] OF TURMTYP;
      magazin: ARRAY[0..12] OF FELD;
      scheiben,lauf: CARDINAL;
      weiter:   CHAR;
      weg: ARRAY[1..4095] OF CHAR;
PROCEDURE Ziehen(anzahl: CARDINAL);
VAR index: CARDINAL;  
    i:     INTEGER;
    Maske: LESEMASKE;
    anfang,ende: CHAR;
BEGIN
  index:=Potenz(anzahl)-1;
  IF anzahl MOD 2 = 1
    THEN Maske:=Lesenungerade
    ELSE Maske:=Lesengerade
  END;
  FOR i:=INTEGER(index) TO 1 BY -1 DO
    Rufen(anfang,ende,CARDINAL(i));
    Setzen(Maske(anfang),Maske(ende))
  END
END Ziehen;
PROCEDURE Potenz(exponent: CARDINAL):CARDINAL;
BEGIN
  IF exponent=0
    THEN RETURN 1
    ELSE RETURN 2*Potenz(exponent-1)
  END
END Potenz;
PROCEDURE Route(anzahl:CARDINAL);
VAR mitte,i,j: CARDINAL;
    Maske: SCHREIBMASKE;
    neu,anfang,ende: CHAR;
BEGIN
  FOR i:=1 TO anzahl DO
    IF i>6 THEN 
      Ausgabe("               ",19,22); Ausgabe("Bitte warten !",19,22) 
    END;
    mitte:=Potenz(i-1);
    IF i MOD 2 = 1
      THEN Maske:=Schreibenungerade; neu:="A"
      ELSE Maske:=Schreibengerade; neu:="L" 
    END;
    Speichern(neu,"E",mitte);
    FOR j:=1 TO (mitte-1) DO
      Rufen(anfang,ende,j);
      Speichern(Maske(anfang),Maske(ende),j+mitte)
    END
  END
END Route;
PROCEDURE Rufen(VAR anfang,ende: CHAR; n: CARDINAL);
BEGIN 
  CASE weg[n] OF
      "S" : anfang:="A"; ende:="E"
    | "T" : anfang:="A"; ende:="L"
    | "U" : anfang:="E"; ende:="L"
    | "X" : anfang:="E"; ende:="A"
    | "Y" : anfang:="L"; ende:="A"
    | "Z" : anfang:="L"; ende:="E"    
    ELSE 
  END
END Rufen;
PROCEDURE Speichern(anfang,ende: CHAR; n: CARDINAL);
VAR code: CHAR;
BEGIN
  CASE anfang OF
      "A" : IF ende="E" THEN code:="S"
                        ELSE code:="T" END
    | "E" : IF ende="L" THEN code:="U"
                        ELSE code:="X" END
    | "L" : IF ende="A" THEN code:="Y"
                        ELSE code:="Z" END
    ELSE 
  END;
  weg[n]:=code
END Speichern;
PROCEDURE Lesenungerade(zeichen: CHAR):CARDINAL;
BEGIN
  CASE zeichen OF
      "A": RETURN 1  |  "E": RETURN 2  |  "L": RETURN 3    ELSE
  END
END Lesenungerade;
PROCEDURE Lesengerade(zeichen: CHAR):CARDINAL;
BEGIN
  CASE zeichen OF
      "A": RETURN 3  |  "E": RETURN 2  |  "L": RETURN 1    ELSE 
  END
END Lesengerade;
PROCEDURE Schreibenungerade(zeichen: CHAR):CHAR;
BEGIN
  CASE zeichen OF
      "A": RETURN "E"  |  "E": RETURN "L"  |  "L": RETURN "A"    ELSE
  END
END Schreibenungerade;  
PROCEDURE Schreibengerade(zeichen: CHAR):CHAR;
BEGIN
  CASE zeichen OF
      "A": RETURN "L"  |  "E": RETURN "A"  |  "L": RETURN "E"    ELSE
  END
END Schreibengerade;  
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
  Ausgabe("Ich muss ueberlegen.",19,38); Cursor(FALSE); 
  Route(scheiben);  Initialisierung(scheiben); Bildschirm(scheiben);
  SetPos(24,77); Cursor(TRUE); Lesen(weiter);
  Ziehen(scheiben);
  ClearScreen; Ausgabe("Ende",4,17); Cursor(TRUE)
END Hanoi.
