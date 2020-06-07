program Hanoi_Iterative;

uses crt;

const size=50;
type bitset = set of byte;
     t_tower = (gold,silver,cupper);
     t_info =  record
                 source,target,help:t_tower; n:integer;
               end;
     t_call =  (first_call,second_call);
     t_state = record
                 call:t_call; x:t_info;
               end;
     t_stack = record
                 index:integer; e_array:array[1..size] of t_state;
               end;

var x,x1:t_info;
    tower:array[0..2] of bitset;
    x0n,i,j:byte;
    var s:t_stack;

function bcard(m:bitset):byte;
var b,s:BYTE;
begin
  s:=0; for b:=0 to 255 do if b in m then inc(s);
  bcard:=s;
end;

function bcomp(m:bitset; nr:byte):byte;
var b,s:byte;
begin
  s:=bcard(m); if (nr>s)  or (nr=0) then bcomp:=0
  else begin
    s:=nr; b:=0;
    repeat if b in m then dec(s); inc(b) until s=0;
    bcomp:=b-1
end end;

procedure push(e:t_state);
begin
  if s.index > size then halt;
  s.e_array[s.index]:=e; inc(s.index);
end;

procedure top(var e:t_state);
begin
  e:=s.e_array[s.index-1];
end;

function is_empty:boolean;
begin
  is_empty:=s.index=1
end;

procedure pop;
begin
  if not is_empty then dec(s.index);
end;

procedure init(var s:t_stack);
begin
  s.index:=1;
end;

procedure infobau(var x:t_info; is,it,ih:t_tower; bn:integer);
var x1:t_info;
begin
  x1.source:=is; x1.target:=it; x1.help:=ih; x1.n:=bn;
  x:=x1;
end;
procedure statebau(var bstate:t_state; bcall:t_call; bx:t_info);
begin
  bstate.x:=bx; bstate.call:=bcall;
end;

procedure hanoi(x:t_info);
var top_down:boolean;
    x1:t_info;
    state:t_state;

  procedure move(source,target:t_tower);
  var ring,floor:byte;
  begin floor:=bcard(tower[ord(source)]);
        ring:=bcomp(tower[ord(source)],1);
        gotoxy(15+(ord(source)*25)-ring,23-floor);
        for j:=1 to 2*ring+1 do write(' ');
        tower[ord(source)]:=tower[ord(source)]-[ring];
        tower[ord(target)]:=tower[ord(target)]+[ring];
        floor:=bcard(tower[ord(target)]);
        gotoxy(15+(ord(target)*25)-ring,23-floor);
        for j:=1 to 2*ring+1 do
          if j=ring+1 then write(chr(ord('A')+ring-1)) else write('=');
  end;

begin
  x1:=x; top_down:=true; init(s);
  statebau(state,first_call,x); push(state);
  while not is_empty do begin;
    if top_down
      then begin
        if x1.n > 1
            then begin
               top(state);
               if state.call=first_call
                 then infobau(x1,x1.source,x1.help,x1.target,x1.n-1)
                 else infobau(x1,x1.help,x1.target,x1.source,x1.n-1);
               statebau(state,first_call,x1); push(state);
             end
             else begin
               pop;
               top_down:=false;
               move(x1.source,x1.target);
            end
      end
      else begin
        top(state);
        pop;
        if state.call=first_call
          then begin
            x1:=state.x;
            move(state.x.source,state.x.target);
            state.call:=second_call;
            push(state);
            top_down:=true;
end end end end;

begin
  clrscr; write('Hight: ');
  repeat readln(x.n); until x.n in [1..12];
  clrscr; gotoxy(1,24); for i:=1 to 80 do write('-'); writeln;
  tower[0]:=[]; tower[1]:=[]; tower[2]:=[]; x0n:=x.n;
  for i:=x.n downto 1 do begin
    tower[0]:=tower[0]+[i]; gotoxy(15-i,22-x.n+i);
    for j:=1 to 2*i+1 do
      if j=i+1 then write(chr(ord('A')+i-1)) else write('=');
  end;
  x.source:=gold; x.target:=silver; x.help:=cupper;
  hanoi(x); gotoxy(1,25); write('Host d”s gsehn?!'); readln;
end.
