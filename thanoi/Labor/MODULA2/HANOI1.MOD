MODULE Hanoi1;
FROM Bild IMPORT Ausgabe,Linie,Cursor,Loeschen,Lesen;
FROM Consol IMPORT ClearScreen,SetPos,SetPosRel,WriteString,WriteCard,ReadCard;
CONST start = 1;   pfahl1 = 14;   boden = 18;
      ziel  = 2;   pfahl2 = 40;   rand  = 2;
      hilfe = 3;   pfahl3 = 66;
TYPE  FELD = ARRAY[0..24] OF CHAR;
      TURMTYP = RECORD
          oben: CARDINAL;
          etage: ARRAY[1..12] OF FELD
      END;
VAR   turm: ARRAY[1..3] OF TURMTYP;
      leer,voll: FELD;
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
      Cursor(FALSE); Transport(von,FALSE);
      Merken(von,nach); Transport(nach,TRUE);
      SetPos(21,18); WriteCard(von,1);
      SetPos(21,32); WriteCard(nach,1);
      INC(lauf); SetPos(23,14); WriteCard(lauf,5);
      SetPos(24,77); Cursor(TRUE); Lesen(weiter);
      IF weiter=33C THEN HALT END 
END Setzen;
PROCEDURE Transport(reihe: CARDINAL; schalter: BOOLEAN);
BEGIN
  WITH turm[reihe] DO
    SetPos(boden-oben,rand);
    SetPosRel(0,(reihe-1)*26);
    IF schalter
      THEN voll:=etage[oben];
           WriteString(voll) 
      ELSE WriteString(leer)
    END
  END
END Transport;
PROCEDURE Merken(von,nach: CARDINAL);
VAR hilfsfeld: FELD;
BEGIN  
  WITH turm[von] DO
    hilfsfeld:=etage[oben];
    etage[oben]:=leer;
    DEC(oben)
  END;    
  WITH turm[nach] DO
    INC(oben);
    etage[oben]:=hilfsfeld
  END
END Merken;
PROCEDURE Initialisierung(anzahl: CARDINAL);
VAR h,i: CARDINAL;
    infeld: FELD;
    cc: CHAR;
BEGIN  
  turm[2].oben:=0; turm[3].oben:=0; turm[1].oben:=anzahl; h:=1;
  lauf:=0; cc:="A"; leer:="            |            "; infeld:=leer;  
  FOR i:=anzahl TO 1 BY -1 DO
      turm[2].etage[i]:=leer;
      turm[3].etage[i]:=leer; 
      infeld[12]:=cc; infeld[12-h]:="=";
      infeld[12+h]:="=";
      turm[1].etage[i]:=infeld;
      INC(h);  cc:=CHR(ORD(cc)+1)
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
  WITH turm[1] DO
    FOR i:=anzahl TO 1 BY -1 DO
      Ausgabe(etage[anzahl+1-i],h+i,rand)
    END
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
END Hanoi1.
