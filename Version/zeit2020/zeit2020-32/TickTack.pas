Unit
   TickTack;     {origin idea: some unknown programmer from Vologda}

Interface

const
   Frequency=1193180;

   DefaultDiv=1193;

   procedure StartTimer;

   procedure StopTimer;

   function GetTime : real;

   function GetTicks : longint;

   function GetStart : longint;

   function GetFinish : longint;

   procedure SetDivider ( d : word );

   procedure SetKorrektur ( k : integer );

   procedure GetTimeDOS(var aktH, aktM, aktS, aktMS: word);
 
   function GetTimeStampDOS: string;
 
   function Error : real;

const
   Epsilon : real = 0.00005;

Implementation

uses
   dos, stdio;
var
   WasStarted, WasUsed : boolean;
   StartYear, FinishYear,
   StartMonth,FinishMonth,
   StartDay,  FinishDay : word;
   StartTime, FinishTime : longint;
   AktTime : longint;
   FullTick,  MoreTick : longint;
   Timer : real;
   Tick : real;
   Korrektur : integer;
   Divider : word;
   Temp : longint;

   function UntilTick : longint;
   var
      t : byte;
      i : longint;
   begin
      t := Mem[Seg0040:$006c];
      i := 0;
      while t = Mem[Seg0040:$006c] do
         i := i+1;
      UntilTick := i;
   end;

   procedure StartTimer;
   var
      tmp : word;
      a : array [0..3] of byte absolute StartTime;
   begin
      WasStarted := true;
      Temp := UntilTick;
      GetDate ( StartYear, StartMonth, StartDay, tmp );
      Temp := UntilTick;
      a[0] := Mem[Seg0040:$006c];
      a[1] := Mem[Seg0040:$006d];
      a[2] := Mem[Seg0040:$006e];
      a[3] := 0;
   end;

   procedure NextDate (var Year, Month, Day : word );
   var
      DaysInMonth : integer;
   begin
      case Month of
         1,3,5,7,8,10,12 : DaysInMonth := 31;
         4,6,9,11 : DaysInMonth := 30;
         02 : if (Year mod 4 = 0) and (Year mod 100 <> 0)
            or (Year mod 400 = 0) then
               DaysInMonth := 29
            else
               DaysInMonth := 28;
      end;
      if Day < DaysInMonth then
         Day := Day + 1
      else begin
         Day := 1;
         Month := (Month mod 12) + 1;
         if Month = 1 then
            Year := Year + 1;
      end;
   end;

   function GetDays : longint;
   var
      Days : longint;
      NextYear,
      NextMonth,
      NextDay : word;
   begin
      NextDay := StartDay;
      NextMonth := StartMonth;
      NextYear := StartYear;
      Days := 0;
      while (NextDay <> FinishDay) or
            (NextMonth <> FinishMonth) or
            (NextYear <> FinishYear) do begin
         Days := Days + 1;
         NextDate ( NextYear, NextMonth, NextDay );
      end;
      GetDays := Days;
   end;

   procedure StopTimer;
   var
      tmp : word;
      a : array [0..3] of byte absolute FinishTime;
   begin
      if WasStarted then begin
         MoreTick := UntilTick;
         GetDate ( FinishYear, FinishMonth, FinishDay, tmp );
         a[0] := Mem[Seg0040:$006c];
         a[1] := Mem[Seg0040:$006d];
         a[2] := Mem[Seg0040:$006e];
         a[3] := 0;
         if StartTime = 0 then
            NextDate ( StartYear, StartMonth, StartDay );
         WasStarted := false;
         WasUsed := true;
         Timer := -Tick * MoreTick / FullTick +
                  Tick * ( FinishTime - StartTime ) +
                  86400.0 * GetDays;
         if Timer < 0 then
            Timer := 0;
      end;
   end;

   function GetTimeStampDOS: string;
   var 
      aktY, aktMo, aktD, aktH, aktM, aktS, aktMS, aktX: word;
   begin
      GetDate(aktY, aktMo, aktD, aktX);
      GetTimeDOS(aktH, aktM, aktS, aktMS);
      GetTimeStampDOS:= str0long(aktD,2)  + '.' +
                        str0long(aktMo,2) + '.' +
                        str0long(aktY,4)  + ' ' +
                        str0long(aktH,2)  + ':' +
                        str0long(aktM,2)  + ':' +
                        str0long(aktS,2)  + ',' +
                        str0long(aktMS,2) ;
   end;

   procedure GetTimeDOS(var aktH, aktM, aktS, aktMS: word);
   var
      a : array [0..3] of byte absolute AktTime;
      h, m, s, x : longint;
      rest, ms: real;
   begin
      a[0] := Mem[Seg0040:$006c];
      a[1] := Mem[Seg0040:$006d];
      a[2] := Mem[Seg0040:$006e];
      a[3] := 0;

      AktTime:= AktTime + Korrektur;

      x:=a[2]; x:=x*256; x:=x+a[1]; x:=x*256; x:=x+a[0]; 
      h:=a[1]; h:=h*256; h:=h+a[0]; 
      {writeln(a[3],' ', a[2], ' ', a[1], ' ', a[0]);}
      {writeln('berechnet: ', x, '=', a[2], '/', h);}

      rest:= h / 65535.;

      m:=trunc(rest * 60);
      s:=trunc(rest * 3600) - m * 60;

      ms:= m * 60 + s;
      ms:=ms / 3600;
      ms:=rest - ms;
      ms:=ms * 3600 * 100;

      aktH:=a[2];
      aktM:=m;
      aktS:=s;
      aktMS:=trunc(ms);
   end;

   function GetTime : real;
   begin
      if WasUsed then
         GetTime := Timer
      else
         GetTime := -1;
   end;

   function GetStart : longint;
   begin
      if WasUsed then
         GetStart := StartTime
      else
         GetStart := -1;
   end;

   function GetFinish : longint;
   begin
      if WasUsed then
         GetFinish := FinishTime
      else
         GetFinish := -1;
   end;

   function GetTicks : longint;
   begin
      if WasUsed then
         GetTicks := trunc ( Timer * Frequency / Divider )
      else
         GetTicks := -1;
   end;

   procedure SetDivider( d : word );
   begin
      if d > 0 then
         Divider := d;
   end;

   procedure SetKorrektur( k : integer );
   begin
      if (k > -32767) and (k < 32768) then
         korrektur:= k;
   end;

   function Error : real;
   var
      i : integer;
      a : real;
   begin
      if ( not WasUsed ) or ( Timer = 0 ) then
         Error := -1
      else begin
         a := Epsilon / Timer;
         i := 0;
         while a < 1 do begin
            i := i + 1;
            a := a * 10;
         end;
         a := round ( a );
         while i > 0 do begin
            i := i - 1;
            a := a / 10;
         end;
         Error := 100 * a;
      end;
   end;

begin
   Tick := 65536 / Frequency;
   WasStarted := false;
   WasUsed := false;
   SetDivider ( DefaultDiv );
   SetKorrektur (0);
   Temp := UntilTick;
   Temp := UntilTick;
   FullTick := UntilTick;
end.