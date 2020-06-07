PROGRAM Turm_von_Hanoi(INPUT,OUTPUT);
(****************************************************************************
 ****************************************************************************
 **                                                                        **
 **                  |                |                |                   **
 **               ===3===             |                |                   **
 **              ====4====            |               =1=                  **
 **            ======6======        ==2==         =====5=====              **
 **      -----------------------------------------------------------       **
 **                                                                        **
 ****************************************************************************
 **                                                                        **
 **   Schubert, Bernd                      Turbo-Pascal 5.5                **
 **   UniversitÑt Rostock                  Version: 6.47 (04/91)           **
 **                                                                        **
 **   Programm zur Veranschaulichung des Problems der "TÅrme von HANOI"    **
 **                                                                        **
 ****************************************************************************
 ****************************************************************************)

USES CRT;

(*  Bildschirmpositionkonstanten *)
CONST start = 1;   pfahl1 = 14;   einzeile   = 20;  boden = 17;
      ziel  = 2;   pfahl2 = 40;   einspalte1 = 18;  rand  = 2;
      hilfe = 3;   pfahl3 = 66;   einspalte2 = 33;

TYPE  FELD = ARRAY[0..24] OF CHAR;     (* Platz fÅr 1 Scheibe *)
      TEXT = STRING[80];
      BITSET = SET OF 0..15;
      TURMTYP = RECORD
        oben: INTEGER;                 (* Anzahl Scheiben je Turm *)
        etage: BITSET                  (* Scheibenspeicher *)
      END;
      SCHRITT = RECORD                 (* Darstellung einer codierten *)
        ab,bis: CHAR                   (* Scheibenbewegung *)
      END;
      KELLERTYP = RECORD
        aus,auf: INTEGER               (* gemerkte Scheibenbewegung *)
      END;
      KRITERIUMSTYP = RECORD
        anker,leer,                    (* Positionstabelle fÅr Zugvergleich *)
        boden,test,unten: INTEGER
      END;

(* Globale Programmvariable  *)
VAR   turm:    ARRAY[1..3] OF TURMTYP;
      magazin: ARRAY[0..12] OF FELD;   (* alle verwendeten Scheiben *)
      scheiben,lauf,                   (* Scheiben- und Zuganzahl *)
      grenze,zeiger: INTEGER;          (* Keller- und Zugzeiger *)
      weiter:        CHAR;             (* Einlesezeichen *)
      ungerade:      BOOLEAN;
      weg: ARRAY[1..4095] OF SCHRITT;  (* Feld fÅr die berechneten ZÅge *)
      keller: ARRAY[1..2048] OF KELLERTYP;
      kriterium: ARRAY[1..22] OF KRITERIUMSTYP;

(***************************************
 ***    Prozeduren fÅr den Modul    ***
 ***************************************

 *** Allgemeine Prozeduren ***)

FUNCTION Taste(ECHO:BOOLEAN):CHAR;
VAR c:CHAR;
BEGIN
      REPEAT UNTIL KEYPRESSED; c:=READKEY;
      IF (c=#0) THEN c:=READKEY;
      IF ECHO AND (c IN [' '..'~']) THEN Write(c);
      Taste:=c
END; (* Taste *)

PROCEDURE Ausgabe(Kette: TEXT; ypos,xpos: INTEGER);
BEGIN
  Gotoxy(xpos,ypos); Write(Kette)
END; (* Ausgabe *)

PROCEDURE Waage(Zei: CHAR; zeile,anfspalte,endspalte: INTEGER);
VAR i: INTEGER;
BEGIN
  FOR i:=anfspalte TO endspalte DO BEGIN
    Gotoxy(i,zeile); Write(Zei)
  END (* FOR *)
END; (* Waage *)

PROCEDURE Loeschen(i,j: INTEGER);
VAR k:INTEGER;
BEGIN
 FOR k:=i TO j DO BEGIN
   Gotoxy(1,k); ClrEol
 END (* FOR *)
END; (* Loeschen *)

PROCEDURE Senke(Zei: CHAR; spalte,anfzeile,endzeile: INTEGER);
VAR i:INTEGER;
BEGIN
  FOR i:=anfzeile TO endzeile DO BEGIN
    Gotoxy(spalte,i); Write(Zei)
  END (* FOR *)
END; (* Senke *)

(*** Prozeduren zur Kellerverwaltung der ZÅge ***)

FUNCTION Kellerleer:BOOLEAN;
BEGIN
  Kellerleer:=(grenze=0)
END; (* Kellerleer *)

PROCEDURE Push(von,bis: INTEGER);
BEGIN
  grenze:=grenze+1;
  WITH keller[grenze] DO BEGIN
    aus:=von; auf:=bis
  END (* WITH *)
END; (* Push *)

PROCEDURE Pop(VAR von,bis: INTEGER);
BEGIN
  WITH keller[grenze] DO BEGIN
    von:=aus; bis:=auf
  END; (* WITH *)
  grenze:=grenze-1
END; (* Pop *)

(*** Hilfsprozeduren ***)

(* simuliert interne Turmbewegung *)
PROCEDURE Simulation(zahl,anfang,ende,lager: INTEGER);
BEGIN
   IF zahl=1
     THEN Push(anfang,ende)
     ELSE BEGIN
            Simulation(zahl-1,anfang,lager,ende);
            Push(anfang,ende);
            Simulation(zahl-1,lager,ende,anfang)
          END (* ELSE *)
END; (* Simulation *)

(* tauscht 2 Zahlen *)
PROCEDURE Tausch(VAR links,rechts: INTEGER);
VAR hilfe: INTEGER;
BEGIN
  hilfe:=links; links:=rechts; rechts:=hilfe
END; (* Tausch *)

(* berechnet Zweierpotenz *)
FUNCTION Potenz(exponent: INTEGER):INTEGER;
BEGIN
  IF exponent=0 THEN Potenz:=1 ELSE Potenz:=2*Potenz(exponent-1)
END; (* Potenz *)

(* Suchen eines berechneten Zuges *)
PROCEDURE Rufen(VAR anfang,ende: CHAR; n: INTEGER);
BEGIN
  WITH weg[n] DO BEGIN
    anfang:=ab; ende:=bis
  END (* WITH *)
END;  (* Rufen *)

(* Schreiben eines berechneten Zuges *)
PROCEDURE Speichern(anfang,ende: CHAR; n: INTEGER);
BEGIN
  WITH weg[n] DO BEGIN
    ab:=anfang; bis:=ende
  END (* WITH *)
END;  (* Speichern *)

(*** Codetabellen ***)

FUNCTION Lesen(zeichen,steuer: CHAR):INTEGER;
BEGIN
  CASE zeichen OF
        'A': IF steuer='u'
               THEN Lesen:=1
               ELSE Lesen:=3;
        'E': Lesen:=2;
        'L': IF Steuer='u'
               THEN Lesen:=3
               ELSE Lesen:=1;
  END (* CASE *)
END; (* Lesen *)

FUNCTION  Schreiben(zeichen,steuer: CHAR):CHAR;
BEGIN
  CASE zeichen OF
        'A': IF steuer='u'
               THEN Schreiben:='E'
               ELSE Schreiben:='L';
        'E': IF steuer='u'
               THEN Schreiben:='L'
               ELSE Schreiben:='A';
        'L': IF steuer='u'
               THEN Schreiben:='A'
               ELSE Schreiben:='E';
  END (* CASE *)
END; (* Schreiben *)

(*** Prozeduren zum Bestimmen des Spielstandes ***

 * kleinste Scheibe auf Turm *)
FUNCTION Minimum(index: INTEGER):INTEGER;
LABEL EXIT2;
VAR k: INTEGER;
BEGIN
  WITH turm[index] DO BEGIN
    IF etage=[]
      THEN k:=0
      ELSE
        BEGIN
           k:=1;
           REPEAT
            IF k IN etage
              THEN GOTO EXIT2
              ELSE k:=k+1;
           UNTIL FALSE
        END (* ELSE *)
  END; (* WITH *)
  EXIT2: Minimum:=k
END; (* Minimum *)

(* grî·te Scheibe auf Turm *)
FUNCTION Maximum(index: INTEGER):INTEGER;
LABEL EXIT3;
VAR k: INTEGER;
BEGIN
  WITH turm[index] DO BEGIN
    IF etage=[]
      THEN k:=0
      ELSE
        BEGIN
           k:=12;
           REPEAT
            IF k IN etage
              THEN GOTO EXIT3
              ELSE k:=k-1
           UNTIL FALSE
        END (* ELSE *)
  END; (* WITH *)
  EXIT3: Maximum:=k
END; (* Maximum *)

(* Anzahl der Scheiben auf Turm *)
FUNCTION Hoehe(index:INTEGER):INTEGER;
VAR k,l: INTEGER;
BEGIN
  WITH turm[index] DO BEGIN
    IF etage=[]
      THEN l:=0
      ELSE
        BEGIN
            l:=0;
            FOR k:=1 TO 12 DO  IF k IN etage THEN l:=l+1
        END (* ELSE *)
  END; (* WITH *)
  Hoehe:=l
END; (* Hoehe *)

(*** Prozeduren fÅr die Scheibenmanipulation ***)

(* Bewegung auf Bildschirm darstellen *)
PROCEDURE Transport(von,nach,kleinster: INTEGER);
VAR tvon,tnach: INTEGER;
BEGIN
    tvon:=boden-1-turm[von].oben;
    tnach:=boden-turm[nach].oben;
    Ausgabe(magazin[0],tvon,(von-1)*26+rand);
    Ausgabe(magazin[kleinster],tnach,(nach-1)*26+rand);
    lauf:=lauf+1; Gotoxy(14,22); Write(lauf:5)
END; (* Transport *)

(* Internes Verschieben *)
PROCEDURE Merken(von,nach,kleinster: INTEGER);
BEGIN
  WITH turm[von] DO BEGIN
    etage:=etage-[kleinster]; oben:=oben-1
  END; (* WITH *)
  WITH turm[nach] DO BEGIN
    etage:=etage+[kleinster]; oben:=oben+1
  END; (* WITH *)
END; (* Merken *)

(* AusfÅhren eines Zuges *)
PROCEDURE Setzen(von,nach:INTEGER);
VAR kleinster: INTEGER;
BEGIN
  kleinster:=Minimum(von);          (* zu transportierende Scheibe *)
  Merken(von,nach,kleinster);       (* internes Verschieben *)
  Transport(von,nach,kleinster);    (* Darstellung auf dem Bildschirm *)
  Gotoxy(einspalte1,einzeile); Write(von:1);
  Gotoxy(einspalte2,einzeile); Write(nach:1);
END; (* Setzen *)

(* Abarbeitung einer Scheibenbewegungsfolge *)
PROCEDURE Ziehen(index: INTEGER; ungerade,pause: BOOLEAN; fix:INTEGER);
LABEL EXIT;
VAR i:           INTEGER;
    Maske,anfang,ende: CHAR;
BEGIN
  IF ungerade THEN Maske:='u' ELSE Maske:='g';
  IF pause
    THEN
         FOR i:=index DOWNTO 1 DO BEGIN
           Rufen(anfang,ende,i);
           Setzen(Lesen(anfang,Maske),Lesen(ende,Maske));
           Gotoxy(77,24); weiter:=Taste(TRUE);
           IF weiter IN ['e','E','a','A','n','N'] THEN GOTO EXIT
         END (* FOR *)
    ELSE
         FOR i:=index DOWNTO 1 DO BEGIN
           Rufen(anfang,ende,i);    DELAY(13*fix);
           Setzen(Lesen(anfang,Maske),Lesen(ende,Maske))
         END; (* FOR *)
EXIT: END; (* Ziehen *)

(* Berechnung der Zugfolge *)
PROCEDURE Route(anzahl:INTEGER);
VAR mitte,i,j: INTEGER;
    Maske,neu,anfang,ende: CHAR;
BEGIN
  FOR i:=1 TO anzahl DO BEGIN
    mitte:=Potenz(i-1);
    IF i MOD 2 = 1
      THEN BEGIN Maske:='u'; neu:='A' END
      ELSE BEGIN Maske:='g'; neu:='L' END;
    Speichern(neu,'E',mitte);
    FOR j:=1 TO (mitte-1) DO BEGIN
      Rufen(anfang,ende,j);
      Speichern(Schreiben(anfang,Maske),Schreiben(ende,Maske),j+mitte)
    END (* FOR *)
  END (* FOR *)
END;  (* Route *)

(* Anfangszustandsherstellung *)
PROCEDURE Initialisierung(anzahl: INTEGER);
VAR i,zaehler,letzter,gross: INTEGER;
    infeld:                  FELD;
    gerade:                  BOOLEAN;
    cc:                      CHAR;
BEGIN
  gross:=Potenz(anzahl)-1; zaehler:=gross;
  letzter:=2*anzahl-1;     gerade:=anzahl MOD 2 = 0;
  infeld:='            |            '; magazin[0]:=infeld;
  WITH turm[ziel] DO BEGIN oben:=0; etage:=[] END;
  turm[hilfe]:=turm[ziel];  lauf:=0; cc:='A';
  WITH turm[start] DO BEGIN
    oben:=anzahl; etage:=[];
    FOR i:=1 TO anzahl DO BEGIN
      etage:=etage+[i];
      infeld[12]:=cc; infeld[12-i]:='=';
      infeld[12+i]:='='; cc:=CHR(ORD(cc)+1);
      magazin[i]:=infeld;
      IF i<anzahl THEN BEGIN
        zaehler:=zaehler-Potenz(i-1);
        WITH kriterium[i] DO BEGIN
          IF gerade THEN BEGIN leer:=2; test:=3 END
                    ELSE BEGIN leer:=3; test:=2 END;
          unten:=i; boden:=1; anker:=zaehler
        END; (* WITH *)
        WITH kriterium[letzter-i] DO BEGIN
          IF gerade THEN BEGIN leer:=1; test:=3 END
                    ELSE BEGIN leer:=3; test:=1 END;
          unten:=i; boden:=2; anker:=gross-zaehler
        END; (* WITH *)
        gerade:=NOT gerade
      END (* IF *)
    END (* FOR *)
  END (* WITH *)
END; (* Initialisierung *)

FUNCTION Whg:BOOLEAN;
BEGIN
   Loeschen(20,24); Ausgabe('Noch ein Spiel ? (n)/j  ',23,22);
   weiter:=Taste(TRUE); Whg:=weiter IN ['j','J']
END; (* Whg *)

(*** Prozeduren zur Eingabe eines Zuges ***)

PROCEDURE Eingabe(VAR index:INTEGER;zeile,spalte: INTEGER);
VAR ch:CHAR;
BEGIN
    REPEAT
      Gotoxy(spalte,zeile); Write(' ');
      Gotoxy(spalte,zeile); ch:=Taste(TRUE);
    UNTIL ch IN ['1'..'3'];
    index:=ORD(ch)-ORD('0')
END; (* Eingabe *)

FUNCTION Legal(von,nach: INTEGER):BOOLEAN;
BEGIN
  IF (nach=von) OR (Minimum(von)=0)
    THEN Legal:=FALSE
    ELSE Legal:=(Minimum(nach)=0) OR (Minimum(von)<Minimum(nach))
END; (* Legal *)

PROCEDURE Fehlermeldung(VAR abbruch: BOOLEAN);
BEGIN
  Gotoxy(1,24); ClrEol;
  Ausgabe('Das ist nicht erlaubt ! Soll ich weiter machen ? (n)/j ',24,15);
  weiter:=Taste(TRUE); Gotoxy(1,24); ClrEol;
  abbruch:=weiter IN ['J','j']
END; (* Fehlermeldung *)

(*** Prozeduren zur Bestimmung von Kriterien fÅr bekannte SpielstÑnde ***

 * 1 Turm leer *)
FUNCTION Notwendig(VAR pleer:INTEGER):BOOLEAN;
LABEL EXIT4;
VAR y: INTEGER;
BEGIN
  FOR y:=1 TO 3 DO
    IF turm[y].etage=[] THEN
      BEGIN pleer:=y; Notwendig:=TRUE; GOTO EXIT4
  END; (* IF & FOR *)
  Notwendig:=FALSE;
EXIT4: END; (* Notwendig *)

(* Turm ist "dicht" gestapelt *)
FUNCTION Dicht(index: INTEGER):BOOLEAN;
BEGIN
  Dicht:=(Maximum(index)-Minimum(index)+1=Hoehe(index))
END; (* Dicht *)

(* bekannter Spielstand *)

FUNCTION Etappe(anzahl,laenge:INTEGER; VAR grenze,reset: INTEGER;
                 VAR ungerade: BOOLEAN; VAR Maske: CHAR):BOOLEAN;
LABEL EXIT5;
VAR pleer,pboden,ptest,y,i: INTEGER;
    gefunden:               BOOLEAN;
BEGIN
  IF (Hoehe(start)=anzahl) OR (Hoehe(hilfe)=anzahl) THEN BEGIN
    IF Hoehe(start)=anzahl
      THEN ungerade:=(anzahl MOD 2 = 1)   (* von vorn *)
      ELSE ungerade:=(anzahl MOD 2 = 0);  (* von hinten *)
    IF ungerade THEN Maske:='u' ELSE Maske:='g';
    reset:=Potenz(anzahl)-1; grenze:=0;
    Etappe:=TRUE; GOTO EXIT5
  END; (* IF1 *)
  IF NOT Notwendig(pleer) THEN BEGIN Etappe:=FALSE; GOTO EXIT5 END;
  pboden:=pleer MOD 3 + 1; ptest:=(pleer+1) MOD 3 + 1; gefunden:=FALSE;
  IF NOT(Dicht(pboden) AND Dicht(ptest))
    THEN BEGIN Etappe:=FALSE; GOTO EXIT5 END;
  IF Maximum(pboden)<>anzahl THEN Tausch(pboden,ptest);
  FOR y:=1 TO laenge DO BEGIN
    WITH kriterium[y] DO BEGIN
      IF (boden=pboden) THEN BEGIN
        IF (leer=pleer) AND (test=ptest) AND (Maximum(ptest)=unten)
          THEN  BEGIN
                 reset:=anker; gefunden:=TRUE;
                 ungerade:=anzahl MOD 2 = 1    (* normal *)
                END
          ELSE  IF (Maximum(start)<>anzahl) AND (test=pleer) AND
                     (leer=ptest) AND (Maximum(ptest)=unten)
                    THEN BEGIN
                           reset:=anker; gefunden:=TRUE;
                           ungerade:=anzahl MOD 2 = 0    (* dual *)
                         END; (* IF3 & IF4 *)
        IF gefunden THEN BEGIN
          IF ungerade THEN Maske:='u' ELSE Maske:='g';
          grenze:=0; Etappe:=TRUE; GOTO EXIT5
        END (* IF5 *)
      END (* IF2 *)
    END (* WITH *)
  END; (* FOR *)
  IF Minimum(pboden)-1=Hoehe(ptest) THEN BEGIN
    reset:=Potenz(anzahl)-Potenz(Maximum(ptest)); grenze:=0;
    ungerade:=anzahl MOD 2 = 0;
    IF pboden<>hilfe THEN ungerade:=NOT ungerade;
    IF ungerade THEN Maske:='u' ELSE Maske:='g';
    Simulation(Maximum(ptest),pleer,ptest,pboden);
    Etappe:=TRUE; GOTO EXIT5
  END;
  Etappe:=FALSE;
EXIT5: END; (* Etappe *)

(*** Bildschirmgestaltung ***)

PROCEDURE Statistik;
BEGIN
  Ausgabe('Zug von Pfahl     nach Pfahl',20,4); Ausgabe('Zuganzahl:',22,4);
END; (* Statistik *)

PROCEDURE Info;
BEGIN
ClrScr; Ausgabe('TÅrme von HANOI',1,22);
Ausgabe('===============',2,22);
Ausgabe('Es sollen die sich auf einem Pfahl (1) befindlichen Scheiben',6,8);
Ausgabe('auf einen anderen (2) umgesteckt werden.',7,8);
Ausgabe('Dabei darf nur immer eine Scheibe bewegt und auf einen leeren',9,8);
Ausgabe('Pfahl oder auf eine jeweils grî·ere Scheibe gesetzt werden.',10,8);
Ausgabe('Als Zwischenspeicher kann man einen weiteren Pfahl (3) nutzen.',11,8);
Ausgabe('Bei n Scheiben sind im gÅnstigsten Fall 2^n -1 Scheiben-',13,8);
Ausgabe('bewegungen fÅr die Umlagerung erforderlich.',14,8);
Ausgabe('Wieviele Scheiben sollen aufgelegt werden (1..12) ?  ',17,8);
END; (* Info *)

PROCEDURE Bildschirm(anzahl:INTEGER);
VAR i,h: INTEGER;
BEGIN
  Loeschen(6,19);
  Waage('-',boden,1,78);
  h:=boden-anzahl-1;
  Senke('|',pfahl1,h,boden-1);
  Senke('|',pfahl2,h,boden-1);
  Senke('|',pfahl3,h,boden-1);
  FOR i:=anzahl DOWNTO 1 DO Ausgabe(magazin[i],h+i,rand);
  Ausgabe('1 ',boden+1,pfahl1); Ausgabe('2 ',boden+1,pfahl2);
  Ausgabe('3 ',boden+1,pfahl3)
END; (* Bildschirm *)

(***   Programmfunktionen   ***)

(* Demonstration der optimalen Variante *)
PROCEDURE Demo;
BEGIN
  Loeschen(21,24); Statistik;
  Ausgabe('"E" = Ende, sonst nÑchster Zug  ',24,44);
  Ziehen(zeiger,ungerade,TRUE,0)
END; (* Demo *)

(* Nutzer kann selbst die TÅrme bewegen *)

PROCEDURE Spiel;
LABEL EXIT1;
VAR abbruch,abnorm,step: BOOLEAN;   (* Steuervariable *)
    Maske,anfang,ende:   CHAR;      (* codierte ZÅge *)
    von,nach,                       (* Scheiben *)
    zaehler,reset:       INTEGER ;  (* zur Keller- und Sprungorganisation *)
    fix:                 INTEGER;
    ch:                  CHAR;
BEGIN
  abbruch:=FALSE; abnorm:=FALSE;
  zaehler:=2*(scheiben-1); grenze:=0;
  Loeschen(21,24); Statistik;
  IF ungerade THEN Maske:='u' ELSE Maske:='g';
  Ausgabe('Mit einem "falschen" Zug kînnen ',21,44);
  Ausgabe('Sie Ihre Versuche jederzeit beenden.',22,44);
  REPEAT
    Eingabe(von,einzeile,einspalte1);
    Eingabe(nach,einzeile,einspalte2);
    IF Legal(von,nach) THEN BEGIN   (* eingegebener Zug erlaubt *)
      Rufen(anfang,ende,zeiger);   (* berechneter Zug *)
      IF abnorm OR  NOT((von=Lesen(anfang,Maske)) AND (nach=Lesen(ende,Maske)))
        THEN  BEGIN (* anderen Zug eingegeben als berechnet *)
                IF Kellerleer THEN  abnorm:=TRUE;
                Push(von,nach)    (* Merken abweichenden Zug *)
      END; (* IF *)
      Setzen(von,nach);   (* AusfÅhren eingegebenen Zug *)
      IF NOT abnorm THEN zeiger:=zeiger-1;
      IF abnorm AND Etappe(scheiben,zaehler,grenze,reset,ungerade,Maske)
        THEN BEGIN (* bekannte Stellung trotz Umweg erreicht *)
          zeiger:=reset;  (* auf neue Stellung eingestellt *)
          IF Kellerleer THEN abnorm:=FALSE
      END (* IF *)
    END (* THEN *)
    ELSE Fehlermeldung(abbruch);
  UNTIL (Hoehe(ziel)=scheiben) OR abbruch;
  IF abbruch THEN  BEGIN  (* noch gekellerte ZÅge auszufÅhren *)
    Gotoxy(44,21); ClrEol;  Gotoxy(44,22); ClrEol;
    IF zeiger+grenze>0 THEN BEGIN
      Ausgabe('Nur noch',24,15); Write((grenze+zeiger):5);
      Ausgabe(' ZÅge. Wollen Sie die wirklich sehen ? (n)/j  ',24,28);
      weiter:=Taste(TRUE); Gotoxy(1,24); ClrEol;
      IF NOT (weiter IN ['j','J']) THEN GOTO EXIT1;
      Ausgabe(' Schrittbetrieb (S) oder im Schnellgang [(R)] ',24,28);
      weiter:=Taste(TRUE); Gotoxy(1,24); ClrEol;
      step:=(weiter IN ['s','S']);
      IF NOT step THEN BEGIN
        Ausgabe(' Geschwindigkeit 1..(9) ',24,48);
        ch:=Taste(TRUE); Gotoxy(1,24); ClrEol;
      END;
    END; (* IF *)
    IF step THEN Ausgabe('"E" = Ende, sonst nÑchster Zug  ',24,44);
    IF NOT Kellerleer THEN REPEAT
      Pop(von,nach);
      Setzen(nach,von);  (* AusfÅhren gekellerten Zug *)
      Gotoxy(77,24); IF step THEN weiter:=Taste(FALSE);
    UNTIL Kellerleer OR (weiter IN ['e','E']);
    CASE ch OF
     '1'..'8': fix:=9-(ORD(ch)-ORD('0'));
     ELSE      fix:=0;
    END;
    Ziehen(zeiger,ungerade,step,fix)
  END; (* IF *)
  Gotoxy(1,24); ClrEol;
  Ausgabe('>ENTER<  ',24,60); weiter:=Taste(FALSE);
EXIT1: END; (* Spiel *)

(* Auswahl Programmfunktion *)
PROCEDURE Funktion;
VAR korrekt: BOOLEAN;
BEGIN
  Ausgabe('Mîchten Sie es selbst versuchen (S) oder soll ',22,13);
  Ausgabe('der Computer die optimalste Variante demonstrieren (D) ?   ',23,13);
  REPEAT
    weiter:=Taste(TRUE); korrekt:=TRUE;
    CASE weiter OF
      's','S' : Spiel;
      'd','D' : Demo;
    ELSE BEGIN
           Gotoxy (72,23); korrekt:=FALSE
         END (* ELSE *)
    END (* CASE *)
  UNTIL korrekt
END; (* Funktion *)

(***************************************
 ***    Beginn des Hauptprogramms    ***
 ***************************************)

BEGIN

REPEAT

 Info;
 REPEAT
   Gotoxy(61,17);  ClrEol;
   {$i-} ReadLn(scheiben); IF ioresult<>0 THEN scheiben:=0; {$i+}
 UNTIL (scheiben IN [1..12]);
 Route(scheiben);    Initialisierung(scheiben);   Bildschirm(scheiben);
 zeiger:=Potenz(scheiben)-1; ungerade:=scheiben MOD 2 = 1;
 Funktion;

UNTIL (NOT Whg);

ClrScr; Ausgabe('Ende',4,17);

END.  (* Turm *)
