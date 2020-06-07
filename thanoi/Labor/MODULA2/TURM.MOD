MODULE HANOI;

(****************************************************************************
 *                                                                          *
 *        M o d u l a  2    -    B e l e g                P T S   2         *
 *        ================================                                  *
 *                                                                          *
 *    Name:   Schubert, Bernd            PC 1715    Version 6.4 (05/90)     *
 *    SG:     88/08/01                   AT 386     Version 6.41 (06/92)    *
 *                                       (Top Speed Modula)                 *
 *                                                                          *
 *    Programm zur Veranschaulichung des Problems der "Tuerme von HANOI"    *
 *                                                                          *
 ****************************************************************************)

(* importierte E/A-Prozeduren *)
(* private E/A-Bibliothek *)
FROM Bild     IMPORT Ausgabe,Loeschen,Linie,Lesen,Zeichen,SetPos;
(* Standardbibliotheken *)
FROM IO       IMPORT WrCard,RdCard;
FROM Window   IMPORT Clear;

(*  Bildschirmpositionkonstanten *)
CONST start = 1;   pfahl1 = 14;   einzeile   = 20;  boden = 17;
      ziel  = 2;   pfahl2 = 40;   einspalte1 = 18;  rand  = 2;
      hilfe = 3;   pfahl3 = 66;   einspalte2 = 32;

TYPE  FELD = ARRAY[0..24] OF CHAR;     (* Platz fuer 1 Scheibe *)
      TURMTYP = RECORD
        oben:  CARDINAL;               (* Anzahl Scheiben je Turm *)
        etage: BITSET                  (* Scheibenspeicher *)
      END;
      SCHRITT = RECORD                 (* Darstellung einer codierten *)
        ab,bis: CHAR                   (* Scheibenbewegung *)
      END;
      KELLERTYP = RECORD
        aus,auf: CARDINAL              (* gemerkte Scheibenbewegung *)
      END;
      KRITERIUMSTYP = RECORD
        anker,leer,                    (* Positionstabelle fuer Zugvergleich *)
        boden,test,unten: CARDINAL
      END;
      LESEMASKE =    PROCEDURE(CHAR):CARDINAL;
      MASKENTYPE = (gerade,ungerade);

(* Globale Programmvariable  *)
VAR   turm:    ARRAY[1..3] OF TURMTYP;
      magazin: ARRAY[0..12] OF FELD;   (* alle verwendeten Scheiben *)
      scheiben,lauf,                   (* Scheiben- und Zuganzahl *)
      grenze,zeiger: CARDINAL;         (* Keller- und Zugzeiger *)
      weiter:        CHAR;             (* Einlesezeichen *)
      varungerade:      BOOLEAN;
      weg: ARRAY[1..4095] OF SCHRITT;  (* Feld fuer die berechneten Zuege *)
      keller: ARRAY[1..2048] OF KELLERTYP;
      kriterium: ARRAY[1..22] OF KRITERIUMSTYP;

(***************************************
 ***    Prozeduren fuer den Modul    ***
 ***************************************)

(* tauscht 2 Zahlen *)
PROCEDURE Tausch(VAR links,rechts: CARDINAL);
VAR hilfe: CARDINAL;
BEGIN
  hilfe:=links; links:=rechts; rechts:=hilfe
END Tausch;

(* berechnet Zweierpotenz *)
PROCEDURE Potenz(exponent: CARDINAL):CARDINAL;
BEGIN
  IF exponent=0 THEN RETURN 1 ELSE RETURN 2*Potenz(exponent-1)  END
END Potenz;

(* Suchen eines berechneten Zuges *)
PROCEDURE Rufen(VAR anfang,ende: CHAR; n: CARDINAL);
BEGIN
  WITH weg[n] DO
    anfang:=ab; ende:=bis
  END
END Rufen;

(* Schreiben eines berechneten Zuges *)
PROCEDURE Speichern(anfang,ende: CHAR; n: CARDINAL);
BEGIN
  WITH weg[n] DO
    ab:=anfang; bis:=ende
  END
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

PROCEDURE CharMaske(Richtung:MASKENTYPE; zeichen: CHAR):CHAR;
BEGIN
  IF Richtung=ungerade
    THEN  CASE zeichen OF
               "A": RETURN "E"  |  "E": RETURN "L"  |
               "L": RETURN "A"        ELSE
          END
    ELSE  CASE zeichen OF
               "A": RETURN "L"  |  "E": RETURN "A"  |
               "L": RETURN "E"        ELSE
          END
  END
END CharMaske;

PROCEDURE Fehlermeldung(VAR abbruch: BOOLEAN);
BEGIN
  Loeschen(24,24,1);
  Ausgabe("Das ist nicht erlaubt ! Soll ich weiter machen ? (n)/j ",24,15);
  Lesen(weiter,FALSE);  Loeschen(24,24,1);
  abbruch:=(CAP(weiter)="J")
END Fehlermeldung;

PROCEDURE Eingabe(Zeile,Spalte: CARDINAL):CARDINAL;
VAR c:CHAR;
BEGIN
  Zeichen(' ',TRUE,Zeile,Spalte);
  SetPos(Zeile,Spalte); Lesen(c,TRUE);
  RETURN ORD(c)-ORD('0');
END Eingabe;

PROCEDURE Statistik();
BEGIN
  Ausgabe("Zug von Pfahl    nach Pfahl",20,4); Ausgabe("Zuganzahl:",22,4)
END Statistik;

(* Anfangszustandsherstellung *)
PROCEDURE Initialisierung(anzahl: CARDINAL);
VAR i,zaehler,letzter,gross: CARDINAL;
    infeld:                  FELD;
    gerade:                  BOOLEAN;
    cc:                      CHAR;
BEGIN
  gross:=Potenz(anzahl)-1; zaehler:=gross;
  letzter:=2*anzahl-1;     gerade:=anzahl MOD 2 = 0;
  infeld:="            |            "; magazin[0]:=infeld;
  WITH turm[ziel] DO oben:=0; etage:={} END;
  turm[hilfe]:=turm[ziel];  lauf:=0; cc:="A";
  WITH turm[start] DO
    oben:=anzahl; etage:={};
    FOR i:=1 TO anzahl DO
      INCL(etage,i);
      infeld[12]:=cc; infeld[12-i]:="=";
      infeld[12+i]:="="; cc:=CHR(ORD(cc)+1);
      magazin[i]:=infeld;
      IF i<anzahl THEN
        zaehler:=zaehler-Potenz(i-1);
        WITH kriterium[i] DO
          IF gerade THEN leer:=2; test:=3
                    ELSE leer:=3; test:=2
          END;
          unten:=i; boden:=1; anker:=zaehler
        END;
        WITH kriterium[letzter-i] DO
          IF gerade THEN leer:=1; test:=3
                    ELSE leer:=3; test:=1
          END;
          unten:=i; boden:=2; anker:=gross-zaehler
        END;
        gerade:=NOT gerade
      END
    END
  END
END Initialisierung;

PROCEDURE Whg():BOOLEAN;
BEGIN
  Loeschen(20,24,1); Ausgabe("Noch ein Spiel ? (n)/j  ",23,22);
  Lesen(weiter,TRUE); RETURN CAP(weiter)="J"
END Whg;

(* Berechnung der Zugfolge *)
PROCEDURE Route(anzahl:CARDINAL);
VAR mitte,i,j: CARDINAL;
    Maske:     MASKENTYPE;
    neu,anfang,ende: CHAR;
BEGIN
  FOR i:=1 TO anzahl DO
    mitte:=Potenz(i-1);
    IF i MOD 2 = 1
      THEN Maske:=ungerade; neu:="A"
      ELSE Maske:=gerade; neu:="L"
    END;
    Speichern(neu,"E",mitte);
    FOR j:=1 TO (mitte-1) DO
      Rufen(anfang,ende,j);
      Speichern(CharMaske(Maske,anfang),CharMaske(Maske,ende),j+mitte)
    END
  END
END Route;

(* kleinste Scheibe auf Turm *)
PROCEDURE Minimum(index: CARDINAL):CARDINAL;
VAR k: CARDINAL;
BEGIN
  WITH turm[index] DO
  IF etage={} THEN RETURN 0 END;
    k:=1;
    REPEAT
      IF k IN etage
        THEN RETURN k
        ELSE INC(k)
      END
    UNTIL k=13
  END
END Minimum;

(* groesste Scheibe auf Turm *)
PROCEDURE Maximum(index: CARDINAL):CARDINAL;
VAR k:CARDINAL;
BEGIN
  WITH turm[index] DO
    IF etage={} THEN RETURN 0 END;
    k:=12;
    WHILE k>0 DO
      IF k IN etage
        THEN RETURN k
        ELSE DEC(k)
      END
    END
  END
END Maximum;

(* Anzahl der Scheiben auf Turm *)
PROCEDURE Hoehe(index: CARDINAL):CARDINAL;
VAR k,l: CARDINAL;
BEGIN
  WITH turm[index] DO
    IF etage={} THEN RETURN 0 END;
    l:=0;
    FOR k:=1 TO 12 DO
      IF k IN etage THEN INC(l) END
    END
  END;
  RETURN l
END Hoehe;

(* Bewegung auf Bildschirm darstellen *)
PROCEDURE Transport(von,nach,kleinster: CARDINAL);
VAR tvon,tnach: CARDINAL;
BEGIN
    tvon:=boden-1-turm[von].oben;
    tnach:=boden-turm[nach].oben;
    Ausgabe(magazin[0],tvon,(von-1)*26+rand);
    Ausgabe(magazin[kleinster],tnach,(nach-1)*26+rand);
    lauf:=lauf+1; SetPos(22,14); WrCard(lauf,5);
END Transport;

(* Internes Verschieben *)
PROCEDURE Merken(von,nach,kleinster: CARDINAL);
BEGIN
  WITH turm[von] DO
    EXCL(etage,kleinster); DEC(oben)
  END;
  WITH turm[nach] DO
    INCL(etage,kleinster); INC(oben)
  END
END Merken;

(* Ausfuehren eines Zuges *)
PROCEDURE Setzen(von,nach: CARDINAL);
VAR kleinster: CARDINAL;
BEGIN
  kleinster:=Minimum(von);          (* zu transportierende Scheibe *)
  Merken(von,nach,kleinster);       (* internes Verschieben *)
  Transport(von,nach,kleinster);    (* Darstellung auf dem Bildschirm *)
  SetPos(einzeile,einspalte1); WrCard(von,1);
  SetPos(einzeile,einspalte2); WrCard(nach,1);
END Setzen;

PROCEDURE Kellerleer():BOOLEAN;
BEGIN
  RETURN grenze=0
END Kellerleer;

PROCEDURE Push(von,bis: CARDINAL);
BEGIN
  INC(grenze);
  WITH keller[grenze] DO
    aus:=von; auf:=bis
  END
END Push;

PROCEDURE Pop(VAR von,bis: CARDINAL);
BEGIN
  WITH keller[grenze] DO
    von:=aus; bis:=auf
  END;
  DEC(grenze)
END Pop;

(* simuliert interne Turmbewegung *)
PROCEDURE Simulation(zahl,anfang,ende,lager: CARDINAL);
BEGIN
   IF zahl=1
     THEN Push(anfang,ende)
     ELSE Simulation(zahl-1,anfang,lager,ende);
          Push(anfang,ende);
          Simulation(zahl-1,lager,ende,anfang)
  END
END Simulation;

PROCEDURE Legal(von,nach: CARDINAL):BOOLEAN;
BEGIN
  IF (nach=von) OR (von>3) OR (nach>3) OR (von*nach=0) THEN RETURN FALSE END;
  IF Minimum(von)=0 THEN RETURN FALSE END;
  RETURN  (Minimum(nach)=0) OR (Minimum(von)<Minimum(nach))
END Legal;

(* 1 Turm leer *)
PROCEDURE Notwendig(VAR pleer:CARDINAL):BOOLEAN;
VAR y:CARDINAL;
BEGIN
  FOR y:=1 TO 3 DO
    IF turm[y].etage={} THEN
      pleer:=y; RETURN TRUE
    END
  END;
  RETURN FALSE;
END Notwendig;

(* Turm ist "dicht" gestapelt *)
PROCEDURE Dicht(index: CARDINAL):BOOLEAN;
BEGIN
  RETURN (Maximum(index)-Minimum(index)+1=Hoehe(index))
END Dicht;

(* Spielende erreicht *)
PROCEDURE Ziel():BOOLEAN;
BEGIN
  RETURN (turm[1].etage={}) AND (turm[3].etage={})
END Ziel;

(* bekannter Spielstand *)
PROCEDURE Etappe(anzahl,laenge:CARDINAL; VAR grenze,reset: CARDINAL;
                 VAR varungerade: BOOLEAN; VAR Maske: LESEMASKE):BOOLEAN;
VAR pleer,pboden,ptest,y,i: CARDINAL;
    gefunden:               BOOLEAN;
BEGIN
  IF (Hoehe(start)=anzahl) OR (Hoehe(hilfe)=anzahl) THEN
    IF Hoehe(start)=anzahl
      THEN varungerade:=anzahl MOD 2 = 1;  (* von vorn *)
      ELSE varungerade:=anzahl MOD 2 = 0;  (* von hinten *)
    END;
    IF varungerade THEN Maske:=Lesenungerade ELSE Maske:=Lesengerade END;
    reset:=Potenz(anzahl)-1; grenze:=0;
    RETURN TRUE
  END;
  IF NOT Notwendig(pleer) THEN RETURN FALSE END;
  pboden:=pleer MOD 3 + 1; ptest:=(pleer+1) MOD 3 + 1; gefunden:=FALSE;
  IF NOT(Dicht(pboden) AND Dicht(ptest)) THEN RETURN FALSE END;
  IF Maximum(pboden)#anzahl THEN Tausch(pboden,ptest) END;
  FOR y:=1 TO laenge DO
    WITH kriterium[y] DO
      IF (boden=pboden) THEN
        IF (leer=pleer) AND (test=ptest) AND (Maximum(ptest)=unten)
          THEN  reset:=anker; gefunden:=TRUE;
                varungerade:=anzahl MOD 2 = 1     (* normal *)
        ELSIF (Maximum(start)#anzahl) AND (test=pleer) AND
              (leer=ptest) AND (Maximum(ptest)=unten)
          THEN  reset:=anker; gefunden:=TRUE;
                varungerade:=anzahl MOD 2 = 0     (* dual *)
        END;
        IF gefunden THEN
          IF varungerade THEN Maske:=Lesenungerade ELSE Maske:=Lesengerade END;
          grenze:=0; RETURN TRUE
        END
      END
    END
  END;
  IF Minimum(pboden)-1=Hoehe(ptest) THEN
    reset:=Potenz(anzahl)-Potenz(Maximum(ptest));
    grenze:=0; varungerade:=anzahl MOD 2 = 0;
    IF pboden#hilfe THEN varungerade:=NOT varungerade END;
    IF varungerade THEN Maske:=Lesenungerade ELSE Maske:=Lesengerade END;
    Simulation(Maximum(ptest),pleer,ptest,pboden);
    RETURN TRUE
  END;
  RETURN FALSE
END Etappe;

PROCEDURE Info();
BEGIN
Clear;  Ausgabe("Tuerme von HANOI",1,22);
Ausgabe("================",2,22);
Ausgabe("Es sollen die sich auf einem Pfahl (1) befindlichen Scheiben",6,8);
Ausgabe("auf einen anderen (2) umgesteckt werden.",7,8);
Ausgabe("Dabei darf nur immer eine Scheibe bewegt und auf einen leeren",9,8);
Ausgabe("Pfahl oder auf eine jeweils groessere Scheibe gesetzt werden.",10,8);
Ausgabe("Als Zwischenspeicher kann man einen weiteren Pfahl (3) nutzen.",11,8);
Ausgabe("Bei n Scheiben sind im guenstigsten Fall 2^n -1 Scheiben-",13,8);
Ausgabe("bewegungen fuer die Umlagerung erforderlich.",14,8);
Ausgabe("Wieviele Scheiben sollen aufgelegt werden (1..12) ?  ",17,8);
END Info;

PROCEDURE Bildschirm(anzahl: CARDINAL);
VAR i,h: CARDINAL;
BEGIN
  Loeschen(6,19,1); Linie("-",boden,1,boden,78);
  h:=boden-anzahl-1;
  Linie("|",h,pfahl1,boden-1,pfahl1);
  Linie("|",h,pfahl2,boden-1,pfahl2);
  Linie("|",h,pfahl3,boden-1,pfahl3);
  FOR i:=anzahl TO 1 BY -1 DO
    Ausgabe(magazin[i],h+i,rand)
  END;
  Ausgabe("1 ",boden+1,pfahl1); Ausgabe("2 ",boden+1,pfahl2);
  Ausgabe("3 ",boden+1,pfahl3)
END Bildschirm;

(* Abarbeitung einer Scheibenbewegungsfolge *)
PROCEDURE Ziehen(index: CARDINAL; varungerade,pause: BOOLEAN);
VAR i:           INTEGER;
    Maske:       LESEMASKE;
    anfang,ende: CHAR;
BEGIN
  IF varungerade THEN Maske:=Lesenungerade ELSE Maske:=Lesengerade END;
  IF pause
    THEN
         FOR i:=INTEGER(index) TO 1 BY -1 DO
           Rufen(anfang,ende,CARDINAL(i));
           Setzen(Maske(anfang),Maske(ende));
           SetPos(24,77); Lesen(weiter,TRUE);
           IF weiter=33C THEN RETURN END
         END
    ELSE
         FOR i:=INTEGER(index) TO 1 BY -1 DO
           Rufen(anfang,ende,CARDINAL(i));
           Setzen(Maske(anfang),Maske(ende));
         END
  END
END Ziehen;

(* Demonstration der optimalen Variante *)
PROCEDURE Demo();
BEGIN
  Loeschen(20,24,1); Statistik;
  Ausgabe("ESC = Ende, sonst naechster Zug  ",24,45);
  Ziehen(zeiger,varungerade,TRUE)
END Demo;

(* Nutzer kann selbst die Tuerme bewegen *)
PROCEDURE Spiel();
VAR abbruch,abnorm,step: BOOLEAN;
    anfang,ende:         CHAR;      (* codierte Zuege *)
    von,nach,                       (* Scheiben *)
    zaehler,reset:       CARDINAL;  (* zur Keller- und Sprungorganisation *)
    Maske:               LESEMASKE;
BEGIN
  abbruch:=FALSE; abnorm:=FALSE;
  zaehler:=2*(scheiben-1); grenze:=0;
  Loeschen(21,24,1);  Statistik;
  IF varungerade THEN Maske:=Lesenungerade ELSE Maske:=Lesengerade END;
  Ausgabe('Mit einem "falschen" Zug koennen ',21,44);
  Ausgabe("Sie Ihre Versuche jederzeit beenden.",22,44);
  REPEAT
    von:=Eingabe(einzeile,einspalte1);
    nach:=Eingabe(einzeile,einspalte2);
    IF Legal(von,nach)
      THEN   (* eingegebener Zug erlaubt *)
        Rufen(anfang,ende,zeiger);   (* berechneter Zug *)
        IF abnorm OR NOT((von=Maske(anfang)) AND (nach=Maske(ende))) THEN
          (* anderen Zug eingegeben als berechnet *)
          IF Kellerleer() THEN  abnorm:=TRUE END;
          Push(von,nach)    (* Merken abweichenden Zug *)
        END;
        Setzen(von,nach);   (* Ausfuehren eingegebenen Zug *)
        IF NOT abnorm THEN DEC(zeiger) END;
        IF abnorm AND Etappe(scheiben,zaehler,grenze,reset,varungerade,Maske)
          THEN (* bekannte Stellung trotz Umweg erreicht *)
          zeiger:=reset;  (* auf neue Stellung eingestellt *)
          IF Kellerleer() THEN abnorm:=FALSE END
        END;
      ELSE Fehlermeldung(abbruch)
    END
  UNTIL Ziel() OR abbruch;
  Loeschen(21,22,44);
  IF abbruch THEN    (* noch gekellerte Zuege auszufuehren *)
    IF zeiger+grenze>9 THEN
      Ausgabe("Nur noch",24,15); WrCard(grenze+zeiger,5);
      Ausgabe(" Zuege. Wollen Sie die wirklich sehen ? (n)/j  ",24,28);
      Lesen(weiter,TRUE); Loeschen(24,24,1);
      IF NOT (CAP(weiter)="J") THEN RETURN END;
      Ausgabe(" Schrittbetrieb (S) oder Schnellgang [(R)]  ",24,28);
      Lesen(weiter,TRUE); Loeschen(24,24,1);
      step:=(CAP(weiter)="S");
    END;
    IF step THEN Ausgabe("ESC = Ende, sonst naechster Zug  ",24,45) END;
    WHILE NOT Kellerleer() DO
      Pop(von,nach);
      Setzen(nach,von);  (* Ausfuehren gekellerten Zug *)
      IF step THEN SetPos(24,77); Lesen(weiter,TRUE); END
    END;
    Ziehen(zeiger,varungerade,step)
  END;
  Loeschen(24,24,1); Ausgabe("bel. Taste:  ",24,60); Lesen(weiter,FALSE)
END Spiel;

(* Auswahl Programmfunktion *)
PROCEDURE Funktion();
VAR korrekt: BOOLEAN;
BEGIN
  Loeschen(20,24,1);
  Ausgabe("Moechten Sie es selbst versuchen (S) oder soll ",22,13);
  Ausgabe("der Computer die optimalste Variante demonstrieren (D) ?   ",23,13);
  REPEAT
    SetPos(23,73); Lesen(weiter,TRUE); korrekt:=TRUE;
    CASE weiter OF
      "s","S" : Spiel
    | "d","D" : Demo
    ELSE korrekt:=FALSE
    END
  UNTIL korrekt;
END Funktion;

(***************************************
 ***    Beginn des Hauptprogramms    ***
 ***************************************)

BEGIN

REPEAT

 Info;
 REPEAT
    Loeschen(17,17,61);  SetPos(17,61);  scheiben:=RdCard()
 UNTIL (scheiben>0) AND (scheiben<13);
 Route(scheiben);    Initialisierung(scheiben);   Bildschirm(scheiben);
 zeiger:=Potenz(scheiben)-1; varungerade:=scheiben MOD 2 = 1;
 Funktion

UNTIL NOT Whg();

Clear; Ausgabe("Ende",4,17);

END HANOI.