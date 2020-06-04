{$IFDEF DOS} {$N+} {$ENDIF}
UNIT Stdio;      (* (c) ALFWARE Bernd Schubert *)

INTERFACE

TYPE  CARDINT = {$IFDEF DOS} LONGINT    {$ELSE} INT64               {$ENDIF};
CONST MAXCARD = {$IFDEF DOS} MAXLONGINT {$ELSE} 9223372036854775807 {$ENDIF};
      KILO=1024; MEGA=1024*1024; GIGA=1024*1024*1024;

{$IFNDEF DOS}
VAR KEYBOARD_AN:BOOLEAN;
(* wird FALSE vorbelegt *)
{$ENDIF}

PROCEDURE TasteDummy;
(* liest von der Tastatur, auch ohne CRT, keine RÅckgabe *)

FUNCTION Taste0:CHAR;
(* liest von der Tastatur, auch ohne CRT *)

FUNCTION UpString(s:STRING):STRING;
(* wandelt den gesamten String im Gro·buchstaben *)

FUNCTION ReplaceInString(s:STRING; cvon,cnach:CHAR):STRING;
(*  ersetzt in s alle cvon durch cnach *)

FUNCTION DeleteInString(s:STRING; c:CHAR):STRING;
(*  lîschte in s alle c *)

FUNCTION Double2String(n:DOUBLE; de:INTEGER):STRING;
(* wandelt ein Double in einen String.
   Achtung, das Zwischenergebnis darf MaxLongint bzw. MaxInt64 nicht Åberschreiten *)

FUNCTION Str0(n,anz:INTEGER):STRING;
(* Integer fester LÑnge (mit Vornullen) *)

FUNCTION StrLong(n:LONGINT):STRING;
(* LongInt wird lesbarer mit . *)

FUNCTION Str0Long(n:LONGINT; anz:INTEGER):STRING;
(* LongInt fester LÑnge (mit Vornullen) *)

FUNCTION StrLiLong(n:LONGINT; anz:INTEGER):STRING;
(* LongInt fester LÑnge (linksbÅndig mit Nach-blanks) *)

FUNCTION StrReLong(n:LONGINT; anz:INTEGER):STRING;
(* LongInt fester LÑnge (rechtsbÅndig mit Vor-blanks) *)

{$IFNDEF DOS}
FUNCTION StrInt64(n:INT64):STRING;
(* Int64 wird lesbarer mit . *)

FUNCTION Str0Int64(n:INT64; anz:INTEGER):STRING;
(* Int64 fester LÑnge (mit Vornullen) *)
{$ENDIF}

FUNCTION StrCardInt(n: CARDINT):STRING;
(* Card: Long (DOS) bzw INT64 *)

FUNCTION Str0CardInt(n: CARDINT; anz:INTEGER):STRING;
(* Card: Long (DOS) bzw INT64 *)

FUNCTION StrDouble(n:DOUBLE):STRING;
(* Double wird lesbarer mit . *)

FUNCTION Str0Double(n:DOUBLE; anz:INTEGER):STRING;
(* Double fester LÑnge (mit Vornullen) *)

FUNCTION StrkDouble(n:DOUBLE; de:INTEGER):STRING;
(* Double wird lesbarer mit . MIT Komma *)

FUNCTION Str0kDouble(n:DOUBLE; anz,de:INTEGER):STRING;
(* Double fester LÑnge (mit Vornullen) MIT Komma *)

(* rufe diese Funktionen fÅr kleinere Double-Zahlen
   und spare den Numeric-Processor fÅr STR(n:anz:dec) *)
FUNCTION StrSoftReal(n:DOUBLE):STRING;
(* Double wird lesbarer mit . *)

FUNCTION Str0SoftReal(n:DOUBLE; anz:INTEGER):STRING;
(* Double fester LÑnge (mit Vornullen) *)

FUNCTION StrkSoftReal(n:DOUBLE; de:INTEGER):STRING;
(* Double wird lesbarer mit . MIT Komma *)

FUNCTION Str0kSoftReal(n:DOUBLE; anz,de:INTEGER):STRING;
(* Double fester LÑnge (mit Vornullen) MIT Komma *)

FUNCTION Str0Giga(wert: CARDINT):STRING;
(* CardInt mit ggf. K/M/G *)

IMPLEMENTATION

{$IFDEF DOS}

USES DOS;

CONST maxSoftReal: double = 2.1e9;
      tempDOS: String = '';

FUNCTION Taste0:CHAR;
VAR ch:CHAR;
    regs:REGISTERS;
BEGIN
   regs.AH:=$00; INTR($16,regs); ch:=CHR(regs.AL);
   Taste0:=ch;
END (* Taste0 *);

{$ELSE}

USES KeyBoard;

CONST maxSoftReal: double = 9.2e18;

FUNCTION Taste0:CHAR;
VAR ch:CHAR;
    K:TKeyEvent;
BEGIN
   IF NOT KEYBOARD_AN THEN InitKeyboard;
   K:=GetKeyEvent;
   K:=TranslateKeyEvent(K);
   CASE GetKeyEventFlags(K) OF
   kbASCII : ch:=GetKeyEventChar(K);
   (* ESC, ENTER, BACKSPACE kommen als ASCII an *)
   kbFnKey :
      CASE GetKeyEventCode(K) OF
      65313 : ch:=CHR(200); (* up     *)
      65319 : ch:=CHR(208); (* down   *)
      65315 : ch:=CHR(203); (* left   *)
      65317 : ch:=CHR(205); (* right  *)
      65312 : ch:=CHR(199); (* pos1   *)
      65318 : ch:=CHR(207); (* end    *)
      65321 : ch:=CHR(210); (* insert *)
      65322 : ch:=CHR(211); (* delete *)
      65281..65292:         (* Funktionstasten *)
              ch:=CHR(GetKeyEventCode(K)-65094);
     ELSE ;
     END;
   ELSE ;
   END;
   IF NOT KEYBOARD_AN THEN DoneKeyboard;
   Taste0:=ch;
END (* Taste0 *);

{$ENDIF}

PROCEDURE TasteDummy;
{$IFDEF DOS} VAR ch:CHAR; {$ENDIF}
BEGIN
   {$IFDEF DOS} ch:= {$ENDIF} Taste0;
END (* TasteDummy *);

FUNCTION UpString(s:STRING):STRING;
VAR t:STRING;
BEGIN
   t:='';
   WHILE s<>'' DO BEGIN t:=t+UPCASE(s[1]); s:=COPY(s,2,LENGTH(s)-1); END;
   UpString:=t;
END; (* Upstring *)

FUNCTION ReplaceInString(s:STRING; cvon,cnach:CHAR):STRING;
VAR i:INTEGER; s0:STRING;
BEGIN
   s0:=s; i:=POS(cvon,s0);
   WHILE i>0 DO BEGIN
     s0:=COPY(s0,1,i-1)+cnach+COPY(s0,i+1,255);
     i:=POS(cvon,s0);
   END;
   ReplaceInString:=s0;
END;

FUNCTION DeleteInString(s:STRING; c:CHAR):STRING;
VAR i:INTEGER; s0:STRING;
BEGIN
   s0:=s; i:=POS(c,s0);
   WHILE i>0 DO BEGIN
     s0:=COPY(s0,1,i-1)+COPY(s0,i+1,255);
     i:=POS(c,s0);
   END;
   DeleteInString:=s0;
END;

FUNCTION Double2String(n:DOUBLE; de:INTEGER):STRING;
VAR s0,s1:STRING; vz:BOOLEAN; nk:DOUBLE; i:INTEGER; g:CARDINT;
BEGIN
   IF abs(n) > maxSoftReal THEN BEGIN Double2String:='SoftReal OFL'; EXIT; END;
   vz:=(n < 0.0); n:=ABS(n); 
   g:=TRUNC(n); STR(g,s0);
   IF vz THEN s0:='-' + s0;
   IF de > 0 THEN BEGIN
      nk:=n-g;
      FOR i:=1 TO de DO nk:=nk*10;
      g:=TRUNC(nk); s1:=Str0(g,de);
   END;
   IF de = 0
      THEN Double2String:=s0
      ELSE Double2String:=s0+','+s1;
END;

FUNCTION Str0(n,anz:INTEGER):STRING;
VAR s0,s1:STRING; i:INTEGER;
BEGIN
   STR(n,s0); s1:='';
   FOR i:=anz-LENGTH(s0) DOWNTO 1 DO s1:=s1+'0';
   Str0:=s1+s0;
END (* Str0 *);

FUNCTION StrLong(n:LONGINT):STRING;
VAR s0,s1:STRING; i,j:INTEGER; vzab:INTEGER;
BEGIN
   STR(n,s0); s1:=''; j:=0;
   vzab:=POS('-',s0);
   FOR i:=LENGTH(s0) DOWNTO 1 DO BEGIN
      IF i<>vzab THEN BEGIN
         IF (j MOD 3 = 0) AND (j>0) THEN s1:='.'+s1;
         INC(j);
      END;
      s1:=s0[i]+s1;
   END;
   StrLong:=s1;
END (* StrLong *);

FUNCTION Str0Long(n:LONGINT; anz:INTEGER):STRING;
VAR s0,s1:STRING; i:INTEGER;
BEGIN
   STR(n,s0); s1:='';
   FOR i:=anz-LENGTH(s0) DOWNTO 1 DO s1:=s1+'0';
   Str0Long:=s1+s0;
END (* Str0Long *);

FUNCTION StrLiLong(n:LONGINT; anz:INTEGER):STRING;
VAR s0,s1:STRING; i:INTEGER;
BEGIN
   STR(n,s0); s1:='';
   FOR i:=anz-LENGTH(s0) DOWNTO 1 DO s1:=s1+' ';
   StrLiLong:=s0+s1;
END (* StrLiLong *);

FUNCTION StrReLong(n:LONGINT; anz:INTEGER):STRING;
VAR s0,s1:STRING; i:INTEGER;
BEGIN
   STR(n,s0); s1:='';
   FOR i:=anz-LENGTH(s0) DOWNTO 1 DO s1:=s1+' ';
   StrReLong:=s1+s0;
END (* StrReLong *);

{$IFNDEF DOS}
FUNCTION StrInt64(n:INT64):STRING;
VAR s0,s1:STRING; i,j:INTEGER; vzab:INTEGER;
BEGIN
   STR(n,s0); s1:=''; j:=0;
   vzab:=POS('-',s0);
   FOR i:=LENGTH(s0) DOWNTO 1 DO BEGIN
      IF i<>vzab THEN BEGIN
         IF (j MOD 3 = 0) AND (j>0) THEN s1:='.'+s1;
         INC(j);
      END;
      s1:=s0[i]+s1;
   END;
   StrInt64:=s1;
END (* StrInt64 *);

FUNCTION Str0Int64(n:INT64; anz:INTEGER):STRING;
VAR s0,s1:STRING; i:INTEGER;
BEGIN
   STR(n,s0); s1:='';
   FOR i:=anz-LENGTH(s0) DOWNTO 1 DO s1:=s1+'0';
   Str0Int64:=s1+s0;
END (* Str0Int64 *);
{$ENDIF}

FUNCTION StrCardInt(n: CARDINT):STRING;
BEGIN
   StrCardInt:={$IFDEF DOS} StrLong {$ELSE} StrInt64 {$ENDIF} (n);
END;

FUNCTION Str0CardInt(n: CARDINT; anz:INTEGER):STRING;
BEGIN
   Str0CardInt:={$IFDEF DOS} Str0Long {$ELSE} Str0Int64 {$ENDIF} (n,anz);
END;

FUNCTION StrDouble(n:DOUBLE):STRING;
VAR s0,s1:STRING; i,j:INTEGER; vzab:INTEGER;
BEGIN
   STR(n:1:0,s0); s1:=''; j:=0;
   vzab:=POS('-',s0);
   FOR i:=LENGTH(s0) DOWNTO 1 DO BEGIN
      IF i<>vzab THEN BEGIN
         IF (j MOD 3 = 0) AND (j>0) THEN s1:='.'+s1;
         INC(j);
      END;
      s1:=s0[i]+s1;
   END;
   StrDouble:=s1;
END (* StrDouble *);

FUNCTION Str0Double(n:DOUBLE; anz:INTEGER):STRING;
VAR s0,s1:STRING; i:INTEGER;
BEGIN
   STR(n:1:0,s0); s1:='';
   FOR i:=anz-LENGTH(s0) DOWNTO 1 DO s1:=s1+'0';
   Str0Double:=s1+s0;
END (* Str0Double *);

FUNCTION StrkDouble(n:DOUBLE; de:INTEGER):STRING;
VAR s0,s1:STRING; i,j:INTEGER; dzp,vzab:INTEGER;
BEGIN
   STR(n:1:de,s0); s1:=''; j:=0;
   s0:=ReplaceInString(s0,'.',',');
   vzab:=POS('-',s0); dzp:=POS(',',s0);
   FOR i:=LENGTH(s0) DOWNTO 1 DO BEGIN
      IF ((i<dzp) or (dzp=0)) AND (i<>vzab) THEN BEGIN
        IF (j MOD 3 = 0) AND (j>0) THEN s1:='.'+s1;
        INC(j);
      END;
      s1:=s0[i]+s1;
   END;
   StrkDouble:=s1;
END (* StrkDouble *);

FUNCTION Str0kDouble(n:DOUBLE; anz,de:INTEGER):STRING;
VAR s0,s1:STRING; i:INTEGER;
BEGIN
   STR(n:1:de,s0); s1:='';
   s0:=ReplaceInString(s0,'.',',');
   FOR i:=anz-LENGTH(s0) DOWNTO 1 DO s1:=s1+'0';
   Str0kDouble:=s1+s0;
END (* Str0kDouble *);

FUNCTION StrSoftReal(n:DOUBLE):STRING;
VAR s0,s1:STRING; i,j:INTEGER; vzab:INTEGER;
BEGIN
   IF abs(n) > maxSoftReal THEN BEGIN StrSoftReal:='SoftReal OFL'; EXIT; END;
   s0:=Double2String(n,0); s1:=''; j:=0;
   vzab:=POS('-',s0);
   FOR i:=LENGTH(s0) DOWNTO 1 DO BEGIN
      IF i<>vzab THEN BEGIN
         IF (j MOD 3 = 0) AND (j>0) THEN s1:='.'+s1;
         INC(j);
      END;
      s1:=s0[i]+s1;
   END;
   StrSoftReal:=s1;
END (* StrSoftReal *);

FUNCTION Str0SoftReal(n:DOUBLE; anz:INTEGER):STRING;
VAR s0,s1:STRING; i:INTEGER;
BEGIN
   IF abs(n) > maxSoftReal THEN BEGIN Str0SoftReal:='SoftReal OFL'; EXIT; END;
   s0:=Double2String(n,0); s1:='';
   FOR i:=anz-LENGTH(s0) DOWNTO 1 DO s1:=s1+'0';
   Str0SoftReal:=s1+s0;
END (* Str0SoftReal *);

FUNCTION StrkSoftReal(n:DOUBLE; de:INTEGER):STRING;
VAR s0,s1:STRING; i,j:INTEGER; dzp,vzab:INTEGER;
BEGIN
   IF abs(n) > maxSoftReal THEN BEGIN StrkSoftReal:='SoftReal OFL'; EXIT; END;
   s0:=Double2String(n,de); s1:=''; j:=0;
   vzab:=POS('-',s0); dzp:=POS(',',s0);
   FOR i:=LENGTH(s0) DOWNTO 1 DO BEGIN
      IF ((i<dzp) or (dzp=0)) AND (i<>vzab) THEN BEGIN
        IF (j MOD 3 = 0) AND (j>0) THEN s1:='.'+s1;
        INC(j);
      END;
      s1:=s0[i]+s1;
   END;
   StrkSoftReal:=s1;
END (* StrkSoftReal *);

FUNCTION Str0kSoftReal(n:DOUBLE; anz,de:INTEGER):STRING;
VAR s0,s1:STRING; i:INTEGER;
BEGIN
   IF abs(n) > maxSoftReal THEN BEGIN Str0kSoftReal:='SoftReal OFL'; EXIT; END;
   s0:=Double2String(n,de); s1:='';
   FOR i:=anz-LENGTH(s0) DOWNTO 1 DO s1:=s1+'0';
   Str0kSoftReal:=s1+s0;
END (* Str0kSoftReal*);

FUNCTION Str0Giga(wert: CARDINT):STRING;
VAR zahl: DOUBLE;
BEGIN
   zahl:=wert;
   IF wert < 0 THEN Str0Giga:='NEGATIV ' + Str0Long( wert, 0)
   ELSE
      {$IFDEF DOS}
      IF (wert >= 0)    AND (wert < KILO)
         THEN Str0Giga:=Str0Long( wert, 0) ELSE
      IF (wert >= KILO) AND (wert < MEGA)
         THEN Str0Giga:=Double2String( zahl / KILO ,3) + ' K' ELSE
      IF (wert >= MEGA) AND (wert < GIGA)
         THEN Str0Giga:=Double2String( zahl / MEGA ,3) + ' M'
         ELSE Str0Giga:=Double2String( zahl / GIGA ,3) + ' G';
      {$ELSE}
      CASE wert OF
        0    .. KILO-1 : Str0Giga:=Str0Long( wert, 0);
        KILO .. MEGA-1 : Str0Giga:=Double2String( zahl / KILO ,3) + ' K';
        MEGA .. GIGA-1 : Str0Giga:=Double2String( zahl / MEGA ,3) + ' M';
        ELSE             Str0Giga:=Double2String( zahl / GIGA ,3) + ' G';
      END;
      {$ENDIF}
END;

BEGIN
   {$IFNDEF DOS}
   KEYBOARD_AN:=FALSE;
   (* Die Variable nicht TRUE setzen,
      im Hauptprogramm mÅ·te sonst so gesteuert werden:

      IF KEYBOARD_AN THEN InitKeyBoard;

      ... (Programmablauf)

      IF KEYBOARD_AN THEN DoneKeyBoard;

      Mit FALSE wird in Taste0 jedesmal automatisch InitKeyBoard
      und DoneKeyBoard aufgerufen.
   *)
   {$ELSE}
   (* irgendein Start-Problem hat dieser N+ unter DOS :-( *)
   tempDOS:=Double2String(17.41, 3);     (* Writeln(tempDOS); *)
   tempDOS:=Double2String(22.84972, 3);  (* Writeln(tempDOS); *)
   {$ENDIF}
END (* Stdio.TPU *).
