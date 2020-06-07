IMPLEMENTATION MODULE Bild;

 (**************************************************************************
 *                                                                         *
 *                   privater E/A-Modul                                    *
 *                                                                         *
 *       Programmierer: B.Schubert, SG 88/08/01  IZ  TU Dresden            *
 *                                                                         *
 ***************************************************************************)

FROM IO       IMPORT WrChar,RdChar,WrStr,RdStr,RdKey;
FROM Window   IMPORT GotoXY;
FROM MathLib0 IMPORT real;

PROCEDURE Lesen(VAR Code: CHAR; out: BOOLEAN);
BEGIN
  Code:=RdKey();  IF Code = 0C THEN Code:=RdKey(); out:=FALSE; END;
  IF ((Code >= 40C) AND (Code <= 176C)) AND out THEN WrChar(Code) END;
END Lesen;

PROCEDURE SetPos(Spalte,Zeile: CARDINAL);
BEGIN GotoXY(Zeile,Spalte);
END SetPos;

PROCEDURE Zeichen(Code: CHAR; posit: BOOLEAN; Zeile,Spalte: CARDINAL);
BEGIN
  IF posit THEN SetPos(Zeile,Spalte) END;
  WrChar(Code);
END Zeichen;

PROCEDURE Ausgabe(Kette: ARRAY OF CHAR; Zeile,Spalte: CARDINAL);
BEGIN  SetPos(Zeile,Spalte); WrStr(Kette);
END Ausgabe;

PROCEDURE Eingabe(VAR Kette: ARRAY OF CHAR; Zeile,Spalte: CARDINAL);
BEGIN  SetPos(Zeile,Spalte); RdStr(Kette);
END Eingabe;

PROCEDURE Loeschen(Anfang,Ende,Spalte: CARDINAL);
VAR i,j: CARDINAL;
BEGIN
   FOR i:=Anfang TO Ende DO
      SetPos(i,Spalte);
      FOR j:=Spalte+1 TO 80 DO WrChar(' ') END;
   END;
END Loeschen;

PROCEDURE Zurueck();
BEGIN  WrChar(10C); WrChar(' '); WrChar(10C);
END Zurueck;

PROCEDURE Linie(Zeichen: CHAR; AnfZl,AnfSp,EndZl,EndSp: INTEGER);
  VAR Anstieg,Diff,F1,F2:    REAL;
      Zeile,Spalte,Abstand:  INTEGER;
  PROCEDURE Normieren(VAR Zahl: INTEGER; Art: CHAR);
  BEGIN
      IF (Art="S") AND (Zahl>80) THEN Zahl:=80 END;
      IF (Art="Z") AND (Zahl>24) THEN Zahl:=24 END;
      IF Zahl<1 THEN Zahl:=1 END
  END Normieren;
  PROCEDURE Aus(Azeichen: CHAR; Zl,Sp: INTEGER);
  BEGIN SetPos(Zl,Sp); WrChar(Azeichen)
  END Aus;
  PROCEDURE Tausch(VAR Wa,Wb: INTEGER);
  VAR Wh: INTEGER;
  BEGIN
      Wh:=Wa; Wa:=Wb; Wb:=Wh
  END Tausch;
  PROCEDURE Rund(Zahl: REAL; VAR Wert: INTEGER);
  VAR Merke: BOOLEAN;
      Hilfe: CARDINAL;
      Anteil: REAL;
  BEGIN
    Merke:=Zahl<0.0000000E0; IF Merke THEN Zahl:=-Zahl END;
    Hilfe:=TRUNC(Zahl); Anteil:=FLOAT(Hilfe);
    IF Zahl-Anteil>0.5000000E0 THEN Hilfe:=Hilfe+1 END;
    Wert:=Hilfe; IF Merke THEN Wert:=-Wert END
  END Rund;
  BEGIN
  Normieren(AnfZl,"Z"); Normieren(EndZl,"Z");
  Normieren(AnfSp,"S"); Normieren(EndSp,"S");
  IF AnfSp=EndSp
    THEN
         IF AnfZl>EndZl THEN Tausch(AnfZl,EndZl) END;
         FOR Zeile:=AnfZl TO EndZl DO
            Aus(Zeichen,Zeile,AnfSp)
         END
    ELSE
         IF AnfSp>EndSp THEN
           Tausch(AnfSp,EndSp);
           Tausch(AnfZl,EndZl)
         END;
         F1:=real(EndZl-AnfZl);
         F2:=real(EndSp-AnfSp);
         Anstieg:=F1/F2; Diff:=0.0000000E0;
         Spalte:=AnfSp+1; Aus(Zeichen,AnfZl,AnfSp);
         WHILE (Spalte<=EndSp) DO
            Diff:=Diff+Anstieg;
            Rund(Diff,Abstand);
            Zeile:=AnfZl+Abstand;
            IF Zeile<1 THEN Zeile:=1 END;
            Aus(Zeichen,Zeile,Spalte);
            Spalte:=Spalte+1
         END
  END;
END Linie;

PROCEDURE Flaeche(Zeichen: CHAR; AnfZl,AnfSp,Zeilen,Spalten: INTEGER);
VAR Setzen,i: INTEGER;
BEGIN
  IF AnfZl<1 THEN AnfZl:=1 END;
  IF AnfSp<1 THEN AnfSp:=1 END;
  IF AnfZl+Zeilen>25 THEN Zeilen:=25-AnfZl END;
  IF AnfSp+Spalten>81 THEN Spalten:=81-AnfSp END;
  FOR Setzen:=AnfZl TO (AnfZl+Zeilen-1) DO
     SetPos(Setzen,AnfSp);
     FOR i:=1 TO Spalten DO WrChar(Zeichen) END
  END;
END Flaeche;

BEGIN

END Bild.