program Hanoi_iterative;
uses crt;
const size=50;
type t_tower = (gold,silver,cupper);
     t_info = record source,target,help:t_tower; n:integer; end;
     t_call = (first_call,second_call);
     t_state = record call:t_call; x:t_info; end;
     t_stack = record index:integer; e_array:array[1..size] of t_state; end;
var s:t_stack;
    x:t_info;
    n:integer;
procedure push(e:t_state);
begin
  if s.index > size then halt;
  s.e_array[s.index]:=e; inc(s.index); 
end;
procedure top(var e:t_state);
begin e:=s.e_array[s.index-1];
end;
function is_empty:boolean;
begin is_empty:=s.index=1
end;
procedure pop;
begin if not is_empty then dec(s.index);
end;
procedure init(var s:t_stack);
begin s.index:=1;
end;
procedure tower_io(t:t_tower);
begin
  case t of
    gold: write('GOLD'); silver: write('SILVER'); cupper: write('CUPPER');
end end;
procedure infobau(var x:t_info; is,it,ih:t_tower; bn:integer);
var x1:t_info;
begin x1.source:=is; x1.target:=it; x1.help:=ih; x1.n:=bn; x:=x1;
end;
procedure statebau(var bstate:t_state; bcall:t_call; bx:t_info);
begin bstate.x:=bx; bstate.call:=bcall;
end;

procedure hanoi(x:t_info);
var top_down:boolean;
    x1:t_info;
    state:t_state;
  procedure move(source,target:t_tower);
  begin
    tower_io(source); write('  '); tower_io(target); writeln;
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
  write('Hight: '); readln(n); writeln;
  infobau(x,gold,silver,cupper,n);
  hanoi(x); writeln('Host d”s gsehn?!');
end.
