{$IFDEF DOS} {$N+}
{$ELSE}      {$DEFINE ZEITOPT}
{$ENDIF}

UNIT Zeit;   (* (c) ALFWARE Bernd Schubert *)

interface

uses DOS, Stdio {$IFDEF X86_64}, SysUtils, DateUtils {$ENDIF};

type Moment = record
        wjahr, wmonat, wtag,
        wstunde, wminute, wsekunde,
        wmsek, wwotag                : word;
        jahr, monat, tag,
        stunde, minute, sekunde,
        msek, wotag                  : longint;
        abstag                       : longint;
        abssek                       : double;
        {$IFNDEF X86_64}
        absMS                        : double;
        {$ELSE}
        absDT                        : TDateTime;
        absTS                        : TTimeStamp;
        absMS                        : int64;
        {$ENDIF}
        heute_feiertag               : integer;
        welcher_feiertag             : array [1..5] of string[30];
     end;

     DiffMoment = record
        ijahr, imonat, itag,
        istunde, iminute, isekunde,
        imsek                        : longint;
        rjahr, rmonat, rwoche,
        rtag, rstunde, rminute,
        rsekunde                     : double;
     end;

var  Akt_Moment, Test_Moment         : Moment;
     Diff_Moment                     : DiffMoment;
     {$IFNDEF X86_64} 
     Summe_Moment                    : DiffMoment;
     {$ENDIF}
     Formate: record
        TT_MM_JJ, TT_MM_JJJJ,
        JJJJ_MM_TT, HH_MM_SS,
        HH_MM_SS_MS, Wochentag,
        Abs_MS, Abs_Tag, Datum_Zeit,
        Timestamp, FileStampDT,
        Ddatum, DdatumTzeit          : string;
     end;

     Diff_TimeStamp, Diff_TimeStamp24   : string;
     {$IFNDEF X86_64} 
     Summe_TimeStamp, Summe_TimeStamp24 : string; 
     {$ENDIF}
     Diff_Einzel, Diff_ABS,
     Diff_Abs_Jahre, Diff_Abs_Monate,
     Diff_Abs_Wochen, Diff_Abs_Tage,
     Diff_Abs_Stunden, Diff_Abs_Minuten,
     Diff_Abs_Sekunden               : string;

function StopUhr(Kommentar: string): string;
(* Neue StechUhr TimeStamp als Ausgabestring *)

function Intervall_Start(nr: integer): string;
(* Programmstart-Zeitpunkt *)

function Intervall_Stop(nr: integer): string;
(* Programmende-Zeitpunkt *)

function Intervall_Dauer(nr: integer): string;
(* Programmdauer Stop minus Start *)

function Intervall_Dauer24(nr: integer): string;
(* Programmdauer Stop minus Start aber Diff_TimeStamp24 *)

(* Falls mîglich, sollte Nr 0 nicht benutzt werden, sondern 1..10
   (KompatibilitÑt zu anderen Units, wo Funktionen ohne Nr auf die 0 zurÅckgefÅhrt werden)
   Hier ist die 0 sogar anderweitig belegt :-) *)

procedure Steche_Moment;
(* GetDate und GetTime *)

procedure Konvert_Timestamp(t: string);
(* erstellt den Moment aus String timestamp *)

procedure Formate_Moment(M: Moment);
(* Formatiert die Werte im Moment *)

procedure Zeige_Formate;
(* Zeigt die formatierten Werte im Moment an *)

{$IFNDEF X86_64}
procedure Normiere_Moment(var M: Moment);
(* Normieren des Momentes nach VerÑnderung *)

procedure Dezimale_Moment(var M: Moment);
(* Umrechnen Momente in absolute Zahlen *)

procedure Lese_W_Moment(VAR M: Moment);
(* weist die "normalen" Variablen den Word zu *)

procedure Schreibe_W_Moment(VAR M: Moment);
(* schreibt die word in die "normalen" Variablen *)

function Gueltig_Moment(var M: Moment): boolean;
(* Stehen im Moment gÅltige Werte? *)
{$ENDIF}

procedure Entpacke_Moment(var M: Moment);
(* rechnet die absoluten MS um in einen Zeitpunkt *)

function Gueltig_Werte(gjahr, gmonat, gtag, gstunde,
                       gminute, gsekunde, gmsek: longint): boolean;
(* Sind diese Werte gÅltig? *)

function  Historisch_Test_Moment: boolean;
(* Ist Test_Moment < Akt_Moment *)

procedure Manuell_Moment(var M: Moment; mjahr, mmonat, mtag,
                         mstunde, mminute, msekunde, mmsek: longint);
(* dem Moment die Werte zuweisen *)

procedure Addiere_Moment(var M: Moment;
                         ajahr, amonat, atag, astunde, aminute, asekunde, amsek: longint);
(* dem Moment die Werte aufaddieren *)

procedure Differenz_Moment;
(* Diff_Moment = Akt_Moment - Test_Moment *)

{$IFNDEF X86_64}
procedure SetzeNull_Summe_Moment;
(* Setzt Summe_Moment auf Null *)

procedure Addiere_Summe_Moment;
(* Summe_Moment = Summe_Moment + Diff_Moment *)
{$ENDIF}

implementation

{$IFDEF DOS} uses TickTack; {$ENDIF}

const Wochen_Tage: array [0..7] of string[10] =
      ('Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
       'Freitag', 'Sonnabend', 'Sonntag');

      Monatsnamen: array [1..12] of string[9] =
      ('Januar', 'Februar', 'MÑrz', 'April','Mai','Juni','Juli',
       'August','September', 'Oktober', 'November','Dezember');

      Monatsende: array [0..13] of integer =
      (31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31);

{$IFDEF X86_64} EinTag: int64 = 1000 * 60 * 60 * 24; {$ENDIF}

var  Akt_Momente, Test_Momente: array[0..10] of Moment;

function schalt(jahr: longint): integer;
begin
   if (jahr mod 4 = 0) and
     ((jahr mod 100 <> 0) or (jahr mod 400 = 0))
      then schalt:=1
      else schalt:=0;
end (* schalt *);

{$IFNDEF X86_64}
procedure Normiere_Moment(var M: Moment);
var bmonat, bstunde,
    bminute, bsekunde, bmsek: longint;
begin
   with M do begin
      if jahr < 1 then exit;
      (* wenn wir hier negative Jahre angeboten bekommen,
         sind wir mit der Wissenschaft am Ende *)
      while msek < 0 do begin;
         msek:=msek + 100; dec(sekunde);
      end;
      while sekunde < 0 do begin;
         sekunde:=sekunde + 60; dec(minute);
      end;
      while minute < 0 do begin;
         minute:=minute+60; dec(stunde);
      end;
      while stunde < 0 do begin;
         stunde:=stunde + 24; dec(tag);
      end;
      while monat < 1 do begin;
         monat:=monat + 12; dec(jahr);
         if jahr<1 then exit;
      end;

      while tag < 1 do begin;
         Monatsende[2]:=28 + schalt(jahr);
         tag:=tag + Monatsende[monat-1];
         dec(monat);
         if monat < 1 then begin
            monat:=12; dec(jahr);
            if jahr < 1 then exit;
         end;
      end;

      bmsek:=    msek;
      msek:=     msek    mod 100;
      sekunde:=  sekunde + bmsek div 100;
      bsekunde:= sekunde;
      sekunde:=  sekunde mod 60;
      minute:=   minute  + bsekunde div 60;
      bminute:=  minute;
      minute:=   minute  mod 60;
      stunde:=   stunde  + bminute  div 60;
      bstunde:=  stunde;
      stunde:=   stunde  mod 24;
      tag:=      tag     + bstunde  div 24;
      bmonat:=   monat;
      monat:=    monat   mod 12;  if monat = 0 then monat:= 12;
      jahr:=     jahr    + ((bmonat - monat) div 12);
      Monatsende[2]:=28 + schalt(jahr);

      while (tag > Monatsende[monat]) do begin;
         tag:= tag - Monatsende[monat];
         if monat < 12
            then INC(monat)
            else begin; monat:=1; INC(jahr); end;
         Monatsende[2]:=28 + schalt(jahr);
      end;
      Dezimale_Moment(M);
      wotag:=(abstag mod 7) + 1;
   end;
end  (* Normiere_Moment *);

(* weist die "normalen" Variablen den Word zu *)
procedure Lese_W_Moment(VAR M: Moment);
begin
   with M do begin
      wjahr:=  jahr;   wmonat:= monat;  wtag:=    tag;     wwotag:=wotag;
      wstunde:=stunde; wminute:=minute; wsekunde:=sekunde; wmsek:= msek;
   end;
end;

(* schreibt die word in die "normalen" Variablen *)
procedure Schreibe_W_Moment(VAR M: Moment);
begin
   with M do begin
      jahr:=  wjahr;   monat:= wmonat;  tag:=    wtag;     wotag:=wwotag;
      stunde:=wstunde; minute:=wminute; sekunde:=wsekunde; msek:= wmsek;
   end;
end;

procedure Dezimale_Moment(var M: Moment);
var dmonate,djahre:longint;
begin
   with M do begin
      abstag:= tag - 1;
      dmonate:=monat - 1;
      djahre:= jahr - 1;
      Monatsende[2]:=28 + schalt(jahr);

      while dmonate > 0 do begin;
         abstag:=abstag + Monatsende[dmonate];
         dec(dmonate);
      end;
      while djahre > 0 do begin;
         abstag:=abstag + 365 + schalt(djahre);
         dec(djahre);
      end;

      absMS:=abstag;
      absMS:=absMS   * 8640000 +
             stunde  *  360000 +
             minute  *    6000 +
             sekunde *     100 +
             msek;
      abssek:=INT(absMS/100.00);
      wotag:=(abstag mod 7) + 1;
   end;
end (* Dezimale_Moment *);

(* rechnet die absoluten MS um in einen Zeitpunkt *)
procedure Entpacke_Moment(var M: Moment);
var etag, nbis : longint; sicher, {$IFDEF ZEITOPT} rest {$ELSE} schwelle {$ENDIF} : double;
begin
   with M do begin
      sicher:=absMS;
   {$IFDEF ZEITOPT}
      (* (hoffentlich) verlustarmer Gleitkomma Modulus :-)
         ca 10% schneller als die do-whiles mit dem Schwellwert.
         Leider werden die TRUNC/ROUND-Zwischenergebnisse fÅr 16bit zu gro·,
         so da· dieses extra fÅr DOS entworfene Verfahren doch nicht verwendet
         werden kann unter Turbo-Pascal. *)
      rest:=(absMS / 100.0) - TRUNC(absMS / 100.0);
      msek:=ROUND(100.0 * rest);
      absMS:=(absMS - msek) / 100.0;
      rest:=(absMS / 60.0) - TRUNC(absMS / 60.0);
      sekunde:=ROUND(60.0 * rest);
      absMS:=(absMS - sekunde) / 60.0;
      rest:=(absMS / 60.0) - TRUNC(absMS / 60.0);
      minute:=ROUND(60.0 * rest);
      absMS:=(absMS - minute) / 60.0;
      rest:=(absMS / 24.0) - TRUNC(absMS / 24.0);
      stunde:=ROUND(24.0 * rest);
      absMS:=(absMS - stunde) / 24.0;
      etag:=TRUNC(absMS);
   {$ELSE}
      etag:=0;
      schwelle:=1000. * 24 * 3600 * 100.;
      while absMS >= schwelle  do begin
         inc(etag, 1000); absMS:=absMS - schwelle;
      end;
      schwelle:=24 * 3600 * 100.;
      while absMS >= schwelle  do begin
         inc(etag); absMS:=absMS - schwelle;
      end;
      stunde:=0;
      schwelle:=3600 * 100;
      while absMS >= schwelle  do begin
         inc(stunde); absMS:=absMS - schwelle;
      end;
      minute:=0;
      schwelle:=60 * 100;
      while absMS >= schwelle  do begin
         inc(minute); absMS:=absMS - schwelle;
      end;
      sekunde:=0;
      schwelle:=100;
      while absMS >= schwelle  do begin
         inc(sekunde); absMS:=absMS - schwelle;
      end;
      msek:=TRUNC(absMS);
   {$ENDIF}
      absMS:=sicher;
      jahr:=1; monat:=1; tag:=1;
      monatsende[2]:=28 + schalt(jahr);
      while etag > 0 do begin
         nbis:=monatsende[monat] - tag + 1;
         if nbis > etag then nbis:=1;
         inc(tag, nbis); (* bevorzugt ganze Monate :-) *)
         if tag > monatsende[monat] then begin
            inc(monat); tag:=1;
            if monat > 12 then begin
               inc(jahr); monat:=1;
               monatsende[2]:=28 + schalt(jahr);
            end;
         end;
         dec(etag, nbis);
      end;
   end;
   Dezimale_Moment(M);
end; (* Entpacke_Moment *)

{$ELSE}

(* entpacke das DT in Word und weise sie in die "normalen" Variablen *)
procedure Entpacke_Moment(VAR M: Moment);
begin
   with M do begin
      DecodeDate(absDT, wjahr, wmonat, wtag);
      DecodeTime(absDT, wstunde, wminute, wsekunde, wmsek);

      wwotag:=DayOfWeek(absDT) - 1; if wwotag=0 then wwotag:=7;
      jahr:=  wjahr;   monat:= wmonat;  tag:=    wtag;     wotag:=wwotag;
      stunde:=wstunde; minute:=wminute; sekunde:=wsekunde; msek:= wmsek;
   end;
end;
{$ENDIF}

procedure Steche_Moment;
begin
   with Akt_Moment do begin
   {$IFNDEF X86_64}
      GetDate(wjahr, wmonat, wtag, wwotag);
      {$IFDEF DOS}
         GetTimeDOS(wstunde, wminute, wsekunde, wmsek);
      {$ELSE}
         GetTime(wstunde, wminute, wsekunde, wmsek);
      {$ENDIF}
      Schreibe_W_Moment(Akt_Moment);
      Dezimale_Moment(Akt_Moment);
   {$ELSE}
      absDT:=now;
      absTS:=DateTimeToTimeStamp(absDT);
      absMS:=int64(TimeStampToMSecs(absTS));
   {$ENDIF}
   end;
end (* Steche_Moment *);

function StopUhr(Kommentar: string): string;
var KM:string;
begin
   KM:=Kommentar; if KM=':' then KM:='StopUhr:';
   Steche_Moment;
   Formate_Moment(Akt_Moment);
   StopUhr:=KM+Formate.TimeStamp;
end (* Stop_Uhr *);

function Intervall_Start(nr: integer): string;
begin
   Intervall_Start:=StopUhr('Start:');
   Akt_Momente[nr]:=Akt_Moment;
   Test_Momente[nr]:=Akt_Moment;
end;

function Intervall_Stop(nr: integer): string;
begin
   Intervall_Stop:=StopUhr('Stop: ');
   Akt_Momente[nr]:=Akt_Moment;
   Test_Moment:=Test_Momente[nr];
end;

function Intervall_Dauer(nr: integer):string;
var dauer:string;
begin
   Akt_Momente[0]:=Akt_Moment; Test_Momente[0]:=Test_Moment;
   Akt_Moment:=Akt_Momente[nr]; Test_Moment:=Test_Momente[nr];
   Differenz_Moment;
   if Diff_Moment.rsekunde >= 0
      then dauer:=COPY(Diff_TimeStamp, 10, 255)
      else dauer:='Negativ??? :-)';
   if Diff_Moment.rtag >= 1
      then dauer:=StrLong(Trunc(Diff_Moment.rtag))+'T '+dauer;
   Intervall_dauer:='Dauer:'+dauer;
   Akt_Moment:=Akt_Momente[0]; Test_Moment:=Test_Momente[0];
end;

function Intervall_Dauer24(nr: integer):string;
begin
   Akt_Momente[0]:=Akt_Moment; Test_Momente[0]:=Test_Moment;
   Akt_Moment:=Akt_Momente[nr]; Test_Moment:=Test_Momente[nr];
   Differenz_Moment;
   Intervall_dauer24:=Diff_TimeStamp24;
   Akt_Moment:=Akt_Momente[0]; Test_Moment:=Test_Momente[0];
end;

procedure Konvert_Timestamp(t: string);
var 
    {$IFNDEF X86_64} 
    kjahr, kmonat, ktag, kstunde, kminute, ksekunde, kmsek: longint;
    w: word;
    {$ELSE}          
    i, k, e: word;
    {$ENDIF}
begin
   {$IFNDEF X86_64}
   val(copy(t,1,2),  ktag, w);     val(copy(t,4,2),  kmonat, w);  val(copy(t,7,4),  kjahr, w);
   val(copy(t,12,2), kstunde, w);  val(copy(t,15,2), kminute, w); val(copy(t,18,2), ksekunde ,w);
   val(copy(t,21,2), kmsek, w);
   Manuell_Moment(Akt_Moment, kjahr, kmonat, ktag, kstunde, kminute, ksekunde, kmsek);
   {$ELSE}
   with Akt_Moment do begin
      (* StrToDateTime geht schlampig mit den ms um,
        daher: machen wir sie hier mindestens dreistellig *)
      k:=POS(',', t); e:=length(t);
      if k > 0 then
         for i:=e+1 to k+3 do t:=t+'0';

      absDT:=StrToDateTime(t);
      absTS:=DateTimeToTimeStamp(absDT);
      absMS:=int64(TimeStampToMSecs(absTS));
   end;
   {$ENDIF}
   Formate_Moment(Akt_Moment);
end;

procedure Formate_Moment(M: Moment);
begin
   with M do begin
   {$IFNDEF X86_64} Lese_W_Moment(M);
   {$ELSE}          Entpacke_Moment(M);
   {$ENDIF}
      Formate.Wochentag    := Wochen_Tage[wwotag];
      Formate.TT_MM_JJ     := str0(wtag, 2) +'.'+
                              str0(wmonat, 2) +'.'+
                              str0(wjahr mod 100, 2);
      Formate.TT_MM_JJJJ   := str0(wtag ,2) + '.'+
                              str0(wmonat, 2) +'.'+
                              str0(wjahr, 4);
      Formate.JJJJ_MM_TT   := str0(wjahr, 4) +'-'+
                              str0(wmonat, 2) +'-'+
                              str0(wtag, 2);
      Formate.HH_MM_SS     := str0(wstunde, 2) +':'+
                              str0(wminute, 2) +':'+
                              str0(wsekunde, 2);
      Formate.HH_MM_SS_MS  := str0(wstunde, 2) +':'+
                              str0(wminute, 2) +':'+
                              str0(wsekunde, 2) +','+
                              str0(wmsek, {$IFNDEF X86_64} 2 {$ELSE} 3 {$ENDIF} );
      Formate.Timestamp    := str0(wtag, 2) +'.'+
                              str0(wmonat, 2) +'.'+
                              str0(wjahr, 4) +' '+
                              Formate.HH_MM_SS_MS;
      Formate.FileStampDT  := 'd'+str0(M.jahr,4)+
                              str0(M.monat,2)+
                              str0(M.tag,2)+
                              '_t'+str0(M.stunde,2)+
                              str0(M.minute,2)+
                              str0(M.sekunde,2)+
                              str0(M.msek,2);
      Formate.DdatumTzeit  := 'D'+str0(wjahr, 4)+
                              str0(wmonat, 2)+
                              str0(wtag, 2)+
                              'T'+str0(wstunde, 2)+
                              str0(wminute, 2)+
                              str0(wsekunde, 2)+
                              str0(wmsek, {$IFNDEF X86_64} 2 {$ELSE} 3 {$ENDIF} );
      Formate.Ddatum       := 'D'+str0(wjahr, 4)+
                              str0(wmonat, 2)+
                              str0(wtag, 2);
      Formate.Datum_Zeit   := Formate.Wochentag +', '+
                              str0(wtag, 2) +'.'+
                              Monatsnamen[wmonat] +' '+
                              str0(wjahr, 4) +', ' +
                              Formate.HH_MM_SS;
      Formate.Abs_Tag      := {$IFNDEF X86_64} strlong(abstag);
                              {$ELSE}          strlong(absTS.date-1);
                              {$ENDIF}
      Formate.Abs_MS       := {$IFDEF DOS}         strdouble(absMS);
                              {$ELSE}    
                                  {$IFNDEF X86_64} strsoftreal(absMS);
                                  {$ELSE}          strint64(absMS-EinTag);
                                  {$ENDIF}
                              {$ENDIF}
   end;
end (* Formate_Moment *);

procedure Zeige_Formate;
begin
   WriteLn('Wochentag     = ',Formate.Wochentag);
   WriteLn('TT.MM.JJ      = ',Formate.TT_MM_JJ);
   WriteLn('TT.MM.JJJJ    = ',Formate.TT_MM_JJJJ);
   WriteLn('JJJJ-MM-TT    = ',Formate.JJJJ_MM_TT);
   WriteLn('HH:MM:SS      = ',Formate.HH_MM_SS);
   WriteLn('HH:MM:SS,MS   = ',Formate.HH_MM_SS_MS);
   WriteLn('Timestamp     = ',Formate.Timestamp);
   WriteLn('Datum/Zeit    = ',Formate.Datum_Zeit);
   WriteLn('absolute Zeit = ',Formate.Abs_Tag,' Tage == ',
                              Formate.Abs_ms, {$IFNDEF X86_64} ' HS' {$ELSE} ' ms' {$ENDIF} );
end (* Zeige_Format *);

{$IFNDEF X86_64}
(* Diese Funktion ist exclusiv fÅr TOLLZEIT :-) *)
function Gueltig_Moment(var M: Moment): boolean;
begin
   with M do Gueltig_Moment:=
      Gueltig_Werte(jahr, monat, tag, stunde, minute, sekunde, msek);
end (* Gueltig_Moment *);
{$ENDIF}

function Gueltig_Werte(gjahr, gmonat, gtag, gstunde, gminute, gsekunde, gmsek: longint): boolean;
begin
   Gueltig_Werte:=true;
   if gjahr <= 0 then Gueltig_Werte:=false;
   Monatsende[2]:=28 + schalt(gjahr);
   if (gtag < 1) or
      (gmonat < 1) or (gmonat > 12) or
      (gtag > Monatsende[gmonat])        then Gueltig_Werte:=false;
   if (gstunde  < 0) or (gstunde  > 23)  then Gueltig_Werte:=false;
   if (gminute  < 0) or (gminute  > 59)  then Gueltig_Werte:=false;
   if (gsekunde < 0) or (gsekunde > 59)  then Gueltig_Werte:=false;
   if (gmsek    < 0) or (gmsek    > 99)  then Gueltig_Werte:=false;
end (* Gueltig_Werte *);

function Historisch_Test_Moment: boolean;
begin
   {$IFNDEF X86_64} 
   Dezimale_Moment(Test_Moment);
   Dezimale_Moment(Akt_Moment);
   {$ENDIF}
   Historisch_Test_Moment:=(Test_Moment.absMS < Akt_Moment.absMS);
end (* Historisch_Moment *);

procedure Manuell_Moment(var M: Moment;
                         mjahr, mmonat, mtag, mstunde, mminute, msekunde, mmsek: longint);
begin
   with M do begin
      {$IFNDEF X86_64}
      jahr:=  mjahr;   monat:= mmonat;  tag:=    mtag;
      stunde:=mstunde; minute:=mminute; sekunde:=msekunde; msek:=mmsek;
      Normiere_Moment(M);
      {$ELSE}
      absDT:=StrToDateTime(str0long(mtag, 2) +'.'+
             str0long(mmonat, 2) +'.'+
             str0long(mjahr, 4) +' '+
             str0long(mstunde, 2) +':'+
             str0long(mminute, 2) +':'+
             str0long(msekunde, 2) +','+
             str0long(mmsek, 3));
      absTS:=DateTimeToTimeStamp(absDT);
      absMS:=int64(TimeStampToMSecs(absTS));
      {$ENDIF}
   end;
end (* Manuell_Moment *);

procedure Addiere_Moment(var M: Moment;
                         ajahr, amonat, atag, astunde, aminute, asekunde, amsek: longint);
begin
   with M do begin
      {$IFNDEF X86_64}
      if ajahr <> 0    then jahr:=   jahr    + ajahr;
      if amonat <> 0   then monat:=  monat   + amonat;
      if atag <> 0     then tag:=    tag     + atag;
      if astunde <> 0  then stunde:= stunde  + astunde;
      if aminute <> 0  then minute:= minute  + aminute;
      if asekunde <> 0 then sekunde:=sekunde + asekunde;
      if amsek <> 0    then msek:=   msek    + amsek;
      Normiere_Moment(M);
      {$ELSE}
      if ajahr <> 0    then absDT:=IncYear(absDT, ajahr);
      if amonat <> 0   then absDT:=IncMonth(absDT, amonat);
      if atag <> 0     then absDT:=IncDay(absDT, atag);
      if astunde <> 0  then absDT:=IncHour(absDT, astunde);
      if aminute <> 0  then absDT:=IncMinute(absDT, aminute);
      if asekunde <> 0 then absDT:=IncSecond(absDT, asekunde);
      if amsek <> 0    then absDT:=IncMilliSecond(absDT, amsek);
      absTS:=DateTimeToTimeStamp(absDT);
      absMS:=int64(TimeStampToMSecs(absTS));
      {$ENDIF}
   end;
end (* Addiere_Moment *);

procedure Differenz_Moment;
var reverse: boolean;
    von, bis: Moment;
begin
   {$IFDEF X86_64}
   Entpacke_Moment(Akt_Moment);
   Entpacke_Moment(Test_Moment);
   {$ENDIF}
   if Historisch_Test_Moment
      then begin
         reverse:=false;
         von:=Test_Moment; bis:=Akt_Moment;
      end
      else begin
         reverse:=true;
         von:=Akt_Moment; bis:=Test_Moment;
      end;

   with Diff_Moment do begin
      if bis.msek > von.msek-1
         then imsek:=bis.msek - von.msek
         else begin;
            imsek:=bis.msek - von.msek + {$IFNDEF X86_64} 100 {$ELSE} 1000 {$ENDIF} ;
            dec(bis.sekunde)
      end;
      if bis.sekunde > von.sekunde-1
         then isekunde:=bis.sekunde - von.sekunde
         else begin;
            isekunde:=bis.sekunde + 60 - von.sekunde;
            dec(bis.minute)
      end;
      if bis.minute > von.minute-1
         then iminute:=bis.minute - von.minute
         else begin;
            iminute:=bis.minute + 60 - von.minute;
            dec(bis.stunde)
      end;
      if bis.stunde > von.stunde-1
         then istunde:=bis.stunde - von.stunde
         else begin;
            istunde:=bis.stunde + 24 - von.stunde;
            dec(bis.tag)
      end;
      Monatsende[2]:=28 + schalt(von.jahr);
      if bis.tag > von.tag-1
         then itag:=bis.tag - von.tag
         else begin;
            if reverse
               then itag:=bis.tag + Monatsende[von.monat] - von.tag
               else itag:=bis.tag + Monatsende[bis.monat-1] - von.tag;
            dec(bis.monat)
      end;
      if bis.monat > von.monat-1
         then imonat:=bis.monat - von.monat
         else begin;
            imonat:=bis.monat+ 12 -von.monat;
            dec(bis.jahr)
      end;
      ijahr:=bis.jahr - von.jahr;

      if reverse then begin
         ijahr:=-ijahr; imonat:=-imonat; itag:=-itag;
         istunde:=-istunde; iminute:=-iminute; isekunde:=-isekunde; imsek:=-imsek;
      end;
      rsekunde:= Akt_Moment.absMS - Test_Moment.absMS;
      rsekunde:= rsekunde / {$IFNDEF X86_64} 100.00 {$ELSE} 1000.0 {$ENDIF} ;
      rminute:=  rsekunde / 60.00;
      rstunde:=  rminute  / 60.00;
      rtag:=     rstunde  / 24.00;
      rjahr:=    rtag     / 365.22;
      rmonat:=   rjahr    * 12.00;
      rwoche:=   rtag     / 7.00;

      if rsekunde >= 0
         then begin
            Diff_TimeStamp:=str0long(itag, 2) +'.'+
                            str0long(imonat, 2) +'.'+
                            str0long(ijahr, 2) +' '+
                            str0long(istunde, 2) +':'+
                            str0long(iminute, 2) +':'+
                            str0long(isekunde, 2) +','+
                            str0long(imsek, {$IFNDEF X86_64} 2 {$ELSE} 3 {$ENDIF} );
            (* die Monate/Jahre vernachlÑssigen wir hier bis zum Beweis des Gegenteils *)
            Diff_TimeStamp24:=str0long(istunde + 24*itag, 2) +':'+
                              str0long(iminute, 2) +':'+
                              str0long(isekunde, 2) +','+
                              str0long(imsek, {$IFNDEF X86_64} 2 {$ELSE} 3 {$ENDIF} );
            Diff_Einzel:=str0long(ijahr, 2) +' Jahre '+
                         str0long(imonat ,2) +' Monate '+
                         str0long(itag, 2) +' Tage, '+
                         str0long(istunde, 2) +':'+
                         str0long(iminute, 2) +':'+
                         str0long(isekunde, 2) +','+
                         str0long(imsek, {$IFNDEF X86_64} 2 {$ELSE} 3 {$ENDIF} );
         end
         else begin
            Diff_TimeStamp:=strlong(itag) +'/'+
                            strlong(imonat) +'/'+
                            strlong(ijahr) +' '+
                            strlong(istunde) +'/'+
                            strlong(iminute) +'/'+
                            strlong(isekunde )+'/'+
                            strlong(imsek);
            (* die Monate/Jahre vernachlÑssigen wir hier bis zum Beweis des Gegenteils *)
            Diff_TimeStamp24:=strlong(istunde + 24*itag) +'/'+
                              strlong(iminute) +'/'+
                              strlong(isekunde) +'/'+
                              strlong(imsek);
            Diff_Einzel:=strlong(ijahr) +' Jahre '+
                         strlong(imonat) +' Monate '+
                         strlong(itag) +' Tage, '+
                         strlong(istunde) +'/'+
                         strlong(iminute) +'/'+
                         strlong(isekunde) +'/'+
                         strlong(imsek);
      end;
      {$IFDEF DOS}
      Diff_Abs_Sekunden:=strkdouble(rsekunde,2) +' s';
      Diff_Abs_Jahre:=strkdouble(rjahr,3) +' Jahre';
      Diff_Abs_Monate:=strkdouble(rmonat,3) +' Monate';
      Diff_Abs_Wochen:=strkdouble(rwoche,3) +' Wochen';
      Diff_Abs_Tage:=strkdouble(rtag,3)+' Tage';
      Diff_Abs_Stunden:=strkdouble(rstunde,3) +' h';
      Diff_Abs_Minuten:=strkdouble(rminute,3) +' min';
      {$ELSE}
      Diff_Abs_Sekunden:=strksoftreal(rsekunde, {$IFNDEF X86_64} 2 {$ELSE} 3 {$ENDIF} ) +' s';
      Diff_Abs_Jahre:=strksoftreal(rjahr,3) +' Jahre';
      Diff_Abs_Monate:=strksoftreal(rmonat,3) +' Monate';
      Diff_Abs_Wochen:=strksoftreal(rwoche,3) +' Wochen';
      Diff_Abs_Tage:=strksoftreal(rtag,3)+' Tage';
      Diff_Abs_Stunden:=strksoftreal(rstunde,3) +' h';
      Diff_Abs_Minuten:=strksoftreal(rminute,3) +' min';
      {$ENDIF}
      Diff_Abs:=Diff_Abs_Jahre +' / '+
                Diff_Abs_Monate +' / '+
                Diff_Abs_Wochen +' / '+
                Diff_Abs_Tage +' / '+
                Diff_Abs_Stunden +' / '+
                Diff_Abs_Minuten +' / '+
                Diff_Abs_Sekunden;
   end; (* with Diff_Moment *)
end (* Differenz_Moment *);

{$IFNDEF X86_64}
procedure Addiere_Summe_Moment;
begin
   with Summe_Moment do begin
      imsek   := imsek    + Diff_Moment.imsek;
      isekunde:= isekunde + Diff_Moment.isekunde;
      iminute := iminute  + Diff_Moment.iminute;
      istunde := istunde  + Diff_Moment.istunde;
      itag    := itag     + Diff_Moment.itag;
      imonat  := imonat   + Diff_Moment.imonat;
      ijahr   := ijahr    + Diff_Moment.ijahr;
      while imsek>99 do begin
         dec(imsek,100); inc(isekunde);
      end;
      while isekunde>59 do begin
         dec(isekunde,60); inc(iminute);
      end;
      while iminute>59 do begin
         dec(iminute,60); inc(istunde);
      end;
      while istunde>23 do begin
         dec(istunde,24); inc(itag);
      end;
      while itag>30 do begin
         dec(itag,31); inc(imonat);
      end;
      while imonat>11 do begin
         dec(imonat,12); inc(ijahr);
      end;
      rsekunde:= imsek    * 1.0;
      rsekunde:= rsekunde / 100.00;
      rminute:=  rsekunde / 60.00;
      rstunde:=  rminute  / 60.00;
      rtag:=     rstunde  / 24.00;
      rjahr:=    rtag     / 365.22;
      rmonat:=   rjahr    * 12.00;
      rwoche:=   rtag     / 7.00;
      Summe_TimeStamp:=str0long(itag, 2) +'.'+
                       str0long(imonat, 2) +'.'+
                       str0long(ijahr, 4) +' '+
                       str0long(istunde, 2) +':'+
                       str0long(iminute, 2) +':'+
                       str0long(isekunde, 2) +','+
                       str0long(imsek,2);
      (* die Monate/Jahre vernachlÑssigen wir hier bis zum Beweis des Gegenteils *)
      Summe_TimeStamp24:=str0long(istunde+ 24*itag, 2) +':'+
                         str0long(iminute, 2) +':'+
                         str0long(isekunde, 2) +','+
                         str0long(imsek, 2);
   end;
end (* Addiere_Summe_Moment *);

procedure SetzeNull_Summe_Moment;
begin
   with Summe_Moment do begin
      imsek:= 0; isekunde:= 0; iminute:= 0; istunde:= 0;
      itag:= 0;  imonat:= 0;   ijahr:= 0;
      rsekunde:= 0.0; rminute:= 0.0; rstunde:= 0.0;
      rtag:= 0.0;     rjahr:= 0.0;   rmonat:= 0.0; rwoche:= 0.0;
      Summe_TimeStamp:='00.00.0000 00:00:00,00';
      (* die Monate/Jahre vernachlÑssigen wir hier bis zum Beweis des Gegenteils *)
      Summe_TimeStamp24:='00:00:00,00';
   end;
end (* SetzeNull_Summe_Moment *);
{$ENDIF}

begin
   {$IFDEF DOS} Setkorrektur(-130);
   {$ENDIF}
   {$IFDEF ZEITOPT} (* Writeln('Unit Zeit Gleitkomma-Modulus aktiv');       *)
   {$ELSE}          (* Writeln('Unit Zeit Gleitkomma-Modulus nicht aktiv'); *)
   {$ENDIF}
end (* Zeit.TPU *).
