{$IFDEF DOS} {$N+}
{$ELSE}      {$DEFINE ZEITOPT}
{$ENDIF}

UNIT Feiertag;   (* (c) ALFWARE Bernd Schubert *)

interface

uses DOS, Stdio, Zeit {$IFDEF X86_64}, SysUtils, DateUtils {$ENDIF};

type FT_FELD = record
        ftJAHR,ftANZAHL              : longint;
        FT : array[ 1..50] of record
           ftNAME                    : string[30];
           nTAG, nMONAT,
           nIMJAHR, nWOTAG           : longint;
           nWOCHENTAG, nKETTE        : string[10];
           ftRANG                    : longint;
        end;
        HappyKadaver,
        Reformationstag,
        AlleHeimlichen,
        DreiKoenige                  : boolean;
     end;

procedure Zeige_Feiertage;
(* Zeige die Feiertage zum aktuellen Moment *)

procedure Zeige_Alle_Feiertage;
(* Zeige alle Feiertage des aktuellen Jahres, sortiert :-) *)

procedure Loesche_Alle_Feiertage;
(* Lîsche alle Feiertage des aktuellen Jahres *)

function Feiertage_Bestimmen(OST_JAHR: integer): boolean;
(* Bestimmt fÅr ein Jahr die Feiertage... *)

procedure Feiertage_Eintragen(var M: Moment);
(* Schaut nach, ob in der Feiertagstabelle EintrÑge fÅr den Akt_Moment sind? *)

procedure Feiertage_Sortieren;
(* Sortiert die aktuellen Feiertage *)

procedure Neuer_Feiertag_Nach_Datum(F_TAG, F_MON: integer; F_NAME: string);
(* FÅgt einen neuen Feiertag hinzu mit TT.MM.JJJJ *)

procedure Neuer_Feiertag_Wochentag_ab_Datum(F_TAG, F_MON: integer; F_NAME, F_WOCHENTAG: string);
(* FÅgt einen neuen Feiertag hinzu, fester Wochentag ab TT.MM.JJJJ *)

procedure Neuer_Feiertag_Nach_AbsTag(F_ABS: integer; F_NAME: string);
(* FÅgt einen neuen Feiertag hinzu, "absoluter" Tag im Jahr *)
(* Der Tag kann natÅrlich wie bei Ostern/Pfingsten abhÑngig berechnet werden *)


implementation

{$IFDEF DOS} uses TickTack; {$ENDIF}

var  Feiertage: FT_FELD;
     Sicher_Moment: Moment;
     ii: integer;

procedure Zeige_Feiertage;
var f: integer;
begin
  with Akt_Moment do begin
     for f:=1 to heute_Feiertag do begin
        Write(welcher_Feiertag[f]);
        if f < heute_Feiertag then write(' und ');
  end end;
  if Akt_Moment.heute_Feiertag > 0 then WriteLn;
end; (* Zeige_Feiertage *)

procedure Zeige_Alle_Feiertage;
var f,i:integer;
begin
  with Feiertage do begin
     WriteLn('Jahr: ', ftJahr, ' Anzahl: ', ftANZAHL);
     for f:=1 to ftANZAHL do (* im Rang steht das sortierte nIMJAHR *)
        for i:=1 to ftANZAHL do with FT[i] do begin
           if ftRANG=f then
              WriteLn(f,':',ftNAME,' am ',nTAG,'.',nMONAT,'.',ftJAHR,
                        ' nIMJAHR=',nIMJAHR,' WT ',nWOCHENTAG,'(',nWOTAG,')',
                        ' kette=',nKETTE,' Rang=',ftRANG);
  end end;
end; (* Zeige_Alle_Feiertage *)

procedure Loesche_Alle_Feiertage;
var i: integer;
begin
  with Feiertage do begin
     ftJAHR:=0; ftANZAHL:=0;
     for i:=1 to 50 do with FT[i] do begin
        ftRANG:=0; ftNAME:='';
        nTAG:=0; nMONAT:=0; nIMJAHR:=0;
        nWOCHENTAG:=''; nWOTAG:=0; nKETTE:='';
  end end;
end; (* Loesche_Alle_Feiertage *)

function Feiertage_Bestimmen(OST_JAHR: integer): boolean;
var OST_N, OST_A, OST_B, OST_M, OST_Q, OST_W: integer;
    OST_TAG, OST_MON, OST_ABS, TAG_ABS: integer;
begin
   with Feiertage do begin
      ftJAHR:=OST_JAHR; ftANZAHL:=0;
      if (OST_JAHR < 1900 ) or (OST_JAHR > 2099) then begin;
         ftANZAHL:=0; Feiertage_Bestimmen:=false; exit
      end;
      OST_N  := OST_JAHR - 1900;
      OST_A  := OST_N mod 19;
      OST_B  :=( 7*OST_A + 1) div 19;
      OST_M  :=(11*OST_A + 4 - OST_B) mod 29;
      OST_Q  := OST_N div 4;
      OST_W  :=(OST_N + OST_Q + 31 - OST_M) mod 7;
      OST_TAG:= 25 - OST_M - OST_W;
      if OST_TAG < 1
         then begin OST_MON:=3; OST_TAG:=OST_TAG+31; end
         else       OST_MON:=4;
      Feiertage_Bestimmen:=true;
      Neuer_Feiertag_Nach_Datum(OST_TAG, OST_MON, 'Ostersonntag');
      OST_ABS:=FT[1].nIMJAHR;
      Neuer_Feiertag_Nach_ABSTag(OST_ABS +  1, 'Ostermontag');
      Neuer_Feiertag_Nach_ABSTag(OST_ABS -  2, 'Karfreitag');
      Neuer_Feiertag_Nach_ABSTag(OST_ABS + 39, 'Himmelfahrt');
      Neuer_Feiertag_Nach_ABSTag(OST_ABS - 52, 'Weiberfastnacht');
      Neuer_Feiertag_Nach_ABSTag(OST_ABS - 48, 'Rosenmontag');
      Neuer_Feiertag_Nach_ABSTag(OST_ABS - 47, 'Fastnacht');
      Neuer_Feiertag_Nach_ABSTag(OST_ABS - 46, 'Aschermittwoch');
      Neuer_Feiertag_Nach_ABSTag(OST_ABS + 49, 'Pfingstsonntag');
      Neuer_Feiertag_Nach_ABSTag(OST_ABS + 50, 'Pfingstmontag');
      if HappyKadaver then Neuer_Feiertag_Nach_ABSTag(OST_ABS + 60, 'Happy Kadaver');
      if Reformationstag then Neuer_Feiertag_Nach_Datum(31, 10, 'Reformationstag');
      if AlleHeimlichen then Neuer_Feiertag_Nach_Datum(1 ,11, 'AlleHeimlichen');
      if DreiKoenige then Neuer_Feiertag_Nach_Datum(6, 1, '3 Kînige');
      Neuer_Feiertag_Nach_Datum( 1,  7, 'Geburtstag');
      Neuer_Feiertag_Nach_Datum( 1,  5, '1.Mai');
      Neuer_Feiertag_Nach_Datum( 3, 10, '3.Oktober');
      Neuer_Feiertag_Nach_Datum( 1,  1, 'Neujahr');
      Neuer_Feiertag_Nach_Datum(31, 12, 'Silvester');
      Neuer_Feiertag_Nach_Datum(24, 12, 'Heiligabend');
      Neuer_Feiertag_Nach_Datum(25, 12, '1.Weihnachtstag');
      Neuer_Feiertag_Nach_Datum(26, 12, '2.Weihnachtstag');
      Neuer_Feiertag_Wochentag_ab_Datum( 8 , 5, 'Muttertag', 'Sonntag');
      Neuer_Feiertag_Wochentag_ab_Datum(18, 12, '4.Advent', 'Sonntag');
      TAG_ABS:=FT[ftANZAHL].nIMJAHR;
      Neuer_Feiertag_Nach_ABSTag(TAG_ABS -21, '1.Advent');
      Neuer_Feiertag_Nach_ABSTag(TAG_ABS -14, '2.Advent');
      Neuer_Feiertag_Nach_ABSTag(TAG_ABS  -7, '3.Advent');
      Feiertage_Sortieren;
end end (* Feiertage bestimmen *);

procedure Feiertage_Sortieren;
var sor_I, sor_K, sor_INDEX, sor_MINIMUM: integer;
begin
   with Feiertage do begin
   for sor_I:=1 to ftANZAHL do with FT[sor_I] do ftRANG:=0;
   for sor_I:=1 to ftANZAHL do with FT[sor_I] do begin;
      sor_MINIMUM:=999; sor_INDEX:=0;
      for sor_K:=1 to ftANZAHL do with FT[sor_K] do begin;
         if (nIMJAHR<sor_MINIMUM) and (ftRANG=0) then begin
            sor_INDEX:=sor_K; sor_MINIMUM:=nIMJAHR;
         end;
      end;
      FT[sor_INDEX].ftRANG:=sor_I;
   end end;
end (* Feiertage_Sortieren *);

procedure Neuer_Feiertag_Nach_Datum(F_TAG, F_MON: integer; F_NAME: string);
begin
   Sicher_Moment:=Akt_Moment;
   inc(Feiertage.ftANZAHL); if Feiertage.ftANZAHL > 50 then Feiertage.ftANZAHL:=1;
   with Feiertage do with FT[ftANZAHL] do begin
      Manuell_Moment(Akt_Moment, ftJAHR, F_MON, F_TAG, 0, 0, 0, 0);
      Manuell_Moment(Test_Moment ,ftJAHR, 1, 1, 0, 0, 0, 0);
      Differenz_Moment;
      Formate_Moment(Akt_Moment);
      with Akt_Moment do with Formate do begin
         ftNAME:=F_NAME; nIMJAHR:=TRUNC(Diff_Moment.rtag) + 1; ftRANG:=0;
         {$IFNDEF X86_64} Lese_W_Moment(Akt_Moment);
         {$ELSE}          Entpacke_Moment(Akt_Moment);
         {$ENDIF}
         nTAG:=wtag; nMONAT:=wmonat; nKETTE:=TT_MM_JJJJ;
         nWOTAG:=wwotag; nWOCHENTAG:=Formate.WochenTag; nKETTE:=TT_MM_JJJJ;
   end end;
   Akt_Moment:=Sicher_Moment;
end (* Neuer_Feiertag_Nach_Datum *);

procedure Neuer_Feiertag_Wochentag_ab_Datum(F_TAG, F_MON: integer; F_NAME, F_WOCHENTAG: string);
begin
   Sicher_Moment:=Akt_Moment;
   inc(Feiertage.ftANZAHL); if Feiertage.ftANZAHL > 50 then Feiertage.ftANZAHL:=1;
   with Feiertage do with FT[ftANZAHL] do begin
      Manuell_Moment(Akt_Moment, ftJAHR, F_MON, F_TAG, 0, 0, 0, 0);
      Manuell_Moment(Test_Moment,ftJAHR, 1, 1, 0, 0, 0, 0);
      Differenz_Moment;
      Formate_Moment(Akt_Moment);
      nIMJAHR:=TRUNC(Diff_Moment.rtag) + 1;
      repeat
         Formate_Moment(Akt_Moment);
         with Akt_Moment do with Formate do begin
            ftNAME:=F_NAME;  ftRANG:=0;
            {$IFNDEF X86_64} Lese_W_Moment(Akt_Moment);
            {$ELSE}          Entpacke_Moment(Akt_Moment);
            {$ENDIF}
            nTAG:=wtag; nMONAT:=wmonat; nKETTE:=TT_MM_JJJJ;
            nWOTAG:=wwotag; nWOCHENTAG:=Formate.WochenTag;
            if nWOCHENTAG <> F_WOCHENTAG then begin;
               Addiere_Moment(Akt_Moment, 0, 0, 1, 0, 0, 0, 0);
               inc(nIMJAHR);
            end
         end
      until (nWOCHENTAG = F_WOCHENTAG) or ((nTAG = 31) and (nMONAT = 12));
   end;
   Akt_Moment:=Sicher_Moment;
end (* Neuer_Feiertag_Wochentage_ab_Datum *);

procedure Neuer_Feiertag_Nach_AbsTag(F_ABS: integer; F_NAME: string);
begin
   Sicher_Moment:=Akt_Moment;
   inc(Feiertage.ftANZAHL); if Feiertage.ftANZAHL > 50 then Feiertage.ftANZAHL:=1;
   with Feiertage do with FT[ftANZAHL] do begin
      Manuell_Moment(Akt_Moment, ftJAHR, 1, 1, 0, 0, 0, 0);
      Addiere_Moment(Akt_Moment,0, 0, F_ABS - 1, 0, 0, 0, 0);
      Formate_Moment(Akt_Moment);
      with Akt_Moment do with Formate do begin
         ftNAME:=F_NAME; nIMJAHR:=F_ABS; ftRANG:=0;
         {$IFNDEF X86_64} Lese_W_Moment(Akt_Moment);
         {$ELSE}          Entpacke_Moment(Akt_Moment);
         {$ENDIF}
         nTAG:=wtag; nMONAT:=wmonat; nKETTE:=TT_MM_JJJJ;
         nWOTAG:=wwotag; nWOCHENTAG:=Formate.WochenTag;
      end
   end;
   Akt_Moment:=Sicher_Moment;
end (* Neuer_Feiertag_Nach_AbsTag *);

procedure Feiertage_Eintragen(var M: Moment);
var jj:integer;
begin
   with M do with Feiertage do begin;
      heute_feiertag:=0;
      for jj:=1 to ftANZAHL do with FT[jj] do
      with M do begin
         {$IFNDEF X86_64} Lese_W_Moment(M);
         {$ELSE}          Entpacke_Moment(M);
         {$ENDIF}
         if (wjahr = ftJAHR) and (wtag = nTAG) and (wmonat = nMONAT)
         then begin;
            inc(heute_feiertag);
            if heute_feiertag > 5 then heute_feiertag:=1;
            welcher_feiertag[heute_feiertag]:=ftNAME;
         end;
   end; end;
end (* Feiertage eintragen *);

begin
   {$IFDEF DOS} Setkorrektur(-130);
   {$ENDIF}
   {$IFDEF ZEITOPT} (* Writeln('Unit Zeit Gleitkomma-Modulus aktiv');       *)
   {$ELSE}         (* Writeln('Unit Zeit Gleitkomma-Modulus nicht aktiv'); *)
   {$ENDIF}

   Feiertage.HappyKadaver:=true;
   Feiertage.Reformationstag:=true;
   Feiertage.AlleHeimlichen:=true;
   Feiertage.DreiKoenige:=true;
   Akt_Moment.heute_feiertag:=0;
   Test_Moment.heute_feiertag:=0;
   for ii:=1 to 5 do begin
      Akt_Moment.welcher_feiertag[ii]:='';
      Test_Moment.welcher_feiertag[ii]:='';
   end;
   with Feiertage do begin ftJAHR:=1966; ftANZAHL:=0; end;
end (* Feiertag.TPU *).
