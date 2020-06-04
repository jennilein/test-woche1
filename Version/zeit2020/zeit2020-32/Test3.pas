{$ifdef dos} {$n+} {$endif}
program test3;
uses zeit,feiertag,stdio {$ifdef x86_64} , sysutils {$endif};
var ms1: {$ifndef x86_64} double {$else} int64 {$endif};
    i: longint;
begin
   writeln(stopuhr('heute '));
   konvert_timestamp('22.02.2016 12:00:00,00');
   writeln(Diff_Abs_Sekunden);
   formate_moment(akt_moment);
   zeige_formate;   test_moment:=akt_moment;
   konvert_timestamp('01.01.2016 00:00:00,00');
   writeln(Diff_Abs_Sekunden);
   formate_moment(akt_moment);
   zeige_formate;
   for i:=1 to 300 do begin
      writeln('i=',i);
      writeln('vorher: ',{$ifndef x86_64} strdouble {$else} strint64 {$endif} (akt_moment.absMS));
      ms1:={$ifndef x86_64} 100 {$else} 1000 {$endif};
      with akt_moment do begin
         absMS:=absMS
               +                     1   (* 1 ms *) {$ifdef x86_64} * 10 {$endif}
               +                   ms1   (* 1 s  *)
               +              60 * ms1   (* 1 min *)
               +         60 * 60 * ms1   (* 1 h *)
               +       24 * 3600 * ms1   (* 1 Tag *)
               +      168 * 3600 * ms1   (* 1 Woche *)
               +  30 * 24 * 3600 * ms1   (* 1 Monat *)
               + 365 * 24 * 3600 * ms1;  (* 1 Jahr *)
         writeln('nachher:',{$ifndef x86_64} strdouble {$else} strint64 {$endif} (akt_moment.absMS));
         {$ifndef x86_64}
         entpacke_moment(akt_moment);
         {$else}
         absTS:=MSecsToTimeStamp(absMS);
         absDT:=TimeStampToDateTime(absTS);
         {$endif}
      end;
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      writeln(Diff_TimeStamp);
      writeln(Diff_TimeStamp24);
      writeln(Diff_Einzel);
      writeln(Diff_ABS);
      with akt_moment do begin
         absMS:=absMS
               +                         8  (* 1 ms *) {$ifdef x86_64} * 10 {$endif}
               +                   ms1 * 7  (* 1 s  *)
               +              60 * ms1 * 6  (* 1 min *)
               +         60 * 60 * ms1 * 5  (* 1 h *)
               +       24 * 3600 * ms1 * 4  (* 1 Tag *)
               +      168 * 3600 * ms1 * 3  (* 1 Woche *)
               +  30 * 24 * 3600 * ms1 * 2  (* 1 Monat *)
               + 365 * 24 * 3600 * ms1 * 1; (* 1 Jahr *)
         writeln('nachher:',{$ifndef x86_64} strdouble {$else} strint64 {$endif} (akt_moment.absMS));
         {$ifndef x86_64}
         entpacke_moment(akt_moment);
         {$else}
         absTS:=MSecsToTimeStamp(absMS);
         absDT:=TimeStampToDateTime(absTS);
         {$endif}
      end;
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      writeln(Diff_TimeStamp);
      writeln(Diff_TimeStamp24);
      writeln(Diff_Einzel);
      writeln(Diff_ABS);
   end;
   writeln(stopuhr('ende'));
   formate_moment(akt_moment);
   zeige_formate;
   differenz_moment;
   writeln(Diff_TimeStamp);
   writeln(Diff_TimeStamp24);
   writeln(Diff_Einzel);
   writeln(Diff_ABS);
end.
