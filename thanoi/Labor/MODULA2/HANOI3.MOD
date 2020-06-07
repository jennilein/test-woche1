MODULE Hanoi3;
FROM Bild IMPORT Ausgabe,Linie,Cursor,Loeschen,Lesen;
FROM Storage IMPORT ALLOCATE,DEALLOCATE;
FROM Consol IMPORT ClearScreen,SetPos,SetPosRel,WriteCard,ReadCard;
CONST start = 1;   pfahl1 = 14;   boden = 18;
      ziel  = 2;   pfahl2 = 40;   rand  = 2;
      hilfe = 3;   pfahl3 = 66;
TYPE  FELD = ARRAY[0..24] OF CHAR;
      TURMTYP = RECORD
          oben: CARDINAL;
          etage: BITSET
      END;
      ZEIGER = POINTER TO WEG;
      WEG = RECORD
        ab,bis: CHAR;
        vor,rueck: ZEIGER
      END; 
      LESEMASKE = PROCEDURE(CHAR):CARDINAL;
      SCHREIBMASKE = PROCEDURE(CHAR):CHAR;
VAR   turm: ARRAY[1..3] OF TURMTYP;
      magazin: ARRAY[0..12] OF FELD;
      scheiben,lauf: CARDINAL;
      weiter:   CHAR;
      mast,anker: ZEIGER;
PROCEDURE Ziehen(anzahl: CARDINAL; VAR mast: ZEIGER);
VAR position: ZEIGER;  
    Maske: LESEMASKE;
    anfang,ende: CHAR;
BEGIN
  IF anzahl MOD 2 = 1
    THEN Maske:=Lesenungerade
    ELSE Maske:=Lesengerade
  END;
  position:=mast;
  REPEAT
    Rufen(anfang,ende,position);
    Setzen(Maske(anfang),Maske(ende));
    Nachfolger(position)
  UNTIL position=NIL
END Ziehen;
PROCEDURE Route(anzahl:CARDINAL; VAR anker,mast: ZEIGER);
VAR unten,oben: ZEIGER;
    Maske: SCHREIBMASKE;
    i: CARDINAL;
    neu,anfang,ende: CHAR;
BEGIN
  anker:=NIL; mast:=NIL;
  FOR i:=1 TO anzahl DO
    IF i>6 THEN
      Ausgabe("               ",19,22); Ausgabe("Bitte warten !",19,22) 
    END;
    IF i MOD 2 = 1
      THEN Maske:=Schreibenungerade; neu:="A"
      ELSE Maske:=Schreibengerade; neu:="L" 
    END;
    Speichern(neu,"E",mast);
    oben:=mast; unten:=anker;
    WHILE unten<>oben DO
      Rufen(anfang,ende,unten);
      Speichern(Maske(anfang),Maske(ende),mast);
      Vorgaenger(unten)
    END
  END
END Route;
PROCEDURE Rufen(VAR anfang,ende: CHAR; position: ZEIGER);
BEGIN 
  WITH position^ DO
    anfang:=ab; ende:=bis
  END
END Rufen;
PROCEDURE Speichern(anfang,ende: CHAR; VAR mast: ZEIGER);
BEGIN
  NeuesElement(mast);
  WITH mast^ DO
    ab:=anfang; bis:=ende
  END
END Speichern;
PROCEDURE NeuesElement(VAR mast: ZEIGER);
VAR akt: ZEIGER;
BEGIN
  NEW(akt);
  akt^.vor:=NIL;
  akt^.rueck:=mast;
  IF mast<>NIL
    THEN mast^.vor:=akt
    ELSE anker:=akt
  END;
  mast:=akt
END NeuesElement;
PROCEDURE Vorgaenger(VAR position: ZEIGER);
BEGIN position:=position^.vor
END Vorgaenger;
PROCEDURE Nachfolger(VAR position: ZEIGER);
BEGIN position:=position^.rueck
END Nachfolger;
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
  Route(scheiben,anker,mast);  Initialisierung(scheiben); 
  Bildschirm(scheiben); SetPos(24,77); Cursor(TRUE); Lesen(weiter);
  Ziehen(scheiben,mast);
  ClearScreen; Ausgabe("Ende",4,17); Cursor(TRUE)
END Hanoi3.
