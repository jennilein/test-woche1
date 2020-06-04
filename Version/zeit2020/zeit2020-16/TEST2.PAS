program zeitest;
uses zeit,feiertag;
var i:longint;
var merke:string;
    sicher_moment:moment;
begin
   merke:=stopuhr('');
   writeln(stopuhr('vorher '));
   for i:=1 to 1000000000 do;
   writeln(stopuhr('nachher '));
   konvert_timestamp(merke);
   formate_moment(akt_moment);
   zeige_formate;
   konvert_timestamp('08.02.2016 00:42:17,98');
   loesche_alle_feiertage;
   if feiertage_bestimmen(2016) then writeln('FT OK') else writeln('ôîî');
   neuer_feiertag_nach_datum(8,2,'Blue Monday');
   feiertage_sortieren;
   (*zeige_alle_feiertage;*)
   feiertage_eintragen(Akt_Moment);
   formate_moment(akt_moment);
   zeige_formate;
   zeige_feiertage;
   konvert_timestamp('01.07.1966 00:42:17,98');
   test_moment:=akt_moment;
   konvert_timestamp('01.07.2016 00:42:17,97');
   differenz_moment;
   WriteLn(Diff_TimeStamp);
   WriteLn(Diff_TimeStamp24);
   WriteLn(diff_einzel);
   loesche_alle_feiertage;
   if feiertage_bestimmen(1) then writeln('FT OK') else writeln('ôîî');
   zeige_alle_feiertage;
   konvert_timestamp('01.01.0001 00:00:00,00');
   feiertage_eintragen(Akt_Moment);
   formate_moment(akt_moment);
   zeige_formate;
   zeige_feiertage;
   sicher_moment:=akt_moment;
   loesche_alle_feiertage;
   if feiertage_bestimmen(1966) then writeln('FT OK') else writeln('ôîî');
   (*zeige_alle_feiertage;*)
   konvert_timestamp('01.01.1966 00:42:17,97');
   neuer_feiertag_nach_datum(1,1,'SH');
   feiertage_sortieren;
   feiertage_eintragen(Akt_Moment);
   formate_moment(akt_moment);
   zeige_formate;
   zeige_feiertage;
   test_moment:=sicher_moment;
   differenz_moment;
   WriteLn(Diff_TimeStamp);
   WriteLn(Diff_TimeStamp24);
   WriteLn(diff_einzel);

   (*merke:=stopuhr('');*)

   konvert_timestamp('22.02.2016 12:00:00,00');
   formate_moment(akt_moment);
   zeige_formate;

   formate_moment(akt_moment);
   zeige_formate;
   (* Immer wieder zurÅcksetzen ... *)
   test_moment:=akt_moment;
   for i:=1 to 10 do begin
      addiere_moment(akt_moment,1,0,0,0,0,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   akt_moment:=test_moment;
   for i:=1 to 13 do begin
      addiere_moment(akt_moment,0,1,0,0,0,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   akt_moment:=test_moment;
   for i:=1 to 31 do begin
      addiere_moment(akt_moment,0,0,1,0,0,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   akt_moment:=test_moment;
   for i:=1 to 26 do begin
      addiere_moment(akt_moment,0,0,0,1,0,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   akt_moment:=test_moment;
   for i:=1 to 66 do begin
      addiere_moment(akt_moment,0,0,0,0,1,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   akt_moment:=test_moment;
   for i:=1 to 66 do begin
      addiere_moment(akt_moment,0,0,0,0,0,1,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   akt_moment:=test_moment;
   for i:=1 to 1001 do begin
      addiere_moment(akt_moment,0,0,0,0,0,0,1);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   (* Hin ... *)
   akt_moment:=test_moment;
   for i:=1 to 10 do begin
      addiere_moment(akt_moment,1,0,0,0,0,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   for i:=1 to 13 do begin
      addiere_moment(akt_moment,0,1,0,0,0,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   for i:=1 to 31 do begin
      addiere_moment(akt_moment,0,0,1,0,0,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   for i:=1 to 26 do begin
      addiere_moment(akt_moment,0,0,0,1,0,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   for i:=1 to 66 do begin
      addiere_moment(akt_moment,0,0,0,0,1,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   for i:=1 to 66 do begin
      addiere_moment(akt_moment,0,0,0,0,0,1,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   for i:=1 to 1001 do begin
      addiere_moment(akt_moment,0,0,0,0,0,0,1);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   (* Und wieder zurÅck ... *)
   for i:=1 to 10 do begin
      addiere_moment(akt_moment,-1,0,0,0,0,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   for i:=1 to 13 do begin
      addiere_moment(akt_moment,0,-1,0,0,0,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   for i:=1 to 31 do begin
      addiere_moment(akt_moment,0,0,-1,0,0,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   for i:=1 to 26 do begin
      addiere_moment(akt_moment,0,0,0,-1,0,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   for i:=1 to 66 do begin
      addiere_moment(akt_moment,0,0,0,0,-1,0,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   for i:=1 to 66 do begin
      addiere_moment(akt_moment,0,0,0,0,0,-1,0);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   for i:=1 to 1001 do begin
      addiere_moment(akt_moment,0,0,0,0,0,0,-1);
      formate_moment(akt_moment);
      zeige_formate;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   writeln('HEUREKA!!! wieder heute :-)');
   writeln('éhm... wieso fehlen da 2 Tage?!');
   writeln('Weil wir nicht symmetrisch wieder abgezogen haben');
   writeln('Sondern in der Reihenfolge J-M-T-S-M-S-T...');
   writeln('Das hei·t, wir sind beim Tage abziehen an einer anderen');
   writeln('Monatsgrenze!!! - Die Schalttage haben damit nix zu tun,');
   writeln('ausnahmsweise mal nicht...');
   konvert_timestamp('30.12.2015 23:23:00,00');
   loesche_alle_feiertage;
   if feiertage_bestimmen(2016) then writeln('FT OK') else writeln('ôîî');
   zeige_alle_feiertage;
   for i:=1 to 370 do begin
      addiere_moment(akt_moment,0,0,1,1,1,1,1{$ifdef x86_64} * 10 {$endif});
      feiertage_eintragen(akt_moment);
      formate_moment(akt_moment);
      zeige_formate;
      zeige_feiertage;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   {$ifdef x86_64}
   WriteLn(StopUhr('jetzt mit X64 millisekunden'));
   for i:=1 to 370 do begin
      addiere_moment(akt_moment,0,0,1,1,1,1,1);
      feiertage_eintragen(akt_moment);
      formate_moment(akt_moment);
      zeige_formate;
      zeige_feiertage;
      differenz_moment;
      WriteLn(Diff_TimeStamp);
      WriteLn(Diff_TimeStamp24);
      WriteLn(diff_einzel);
   end;
   {$endif}
end.
