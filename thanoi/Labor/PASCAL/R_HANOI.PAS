program Hanoi_rekursive;
uses crt;
type t_tower = (gold,silver,cupper);
     t_info = record source,target,help:t_tower; n:integer; end;
var x,x1:t_info;
procedure tower_io(t:t_tower);
begin
  case t of
    gold: write('GOLD'); silver: write('SILVER'); cupper: write('CUPPER');
end end;
procedure infobau(var x:t_info; is,it,ih:t_tower; bn:integer);
var x1:t_info;
begin x1.source:=is; x1.target:=it; x1.help:=ih; x1.n:=bn; x:=x1;
end;

procedure hanoi(x:t_info);
  var x1:t_info;
  procedure move(source,target:t_tower);
  begin
    tower_io(source); write('  '); tower_io(target); writeln;
  end;
  procedure swap(var x1,x2:t_tower);
  var temp:t_tower;
  begin temp:=x1; x1:=x2; x2:=temp;
  end;
begin
   if x.n = 1
     then move(x.source,x.target)
     else begin
            infobau(x1,x.source,x.help,x.target,x.n-1); hanoi(x1);
            move(x.source,x.target);
            infobau(x1,x.help,x.target,x.source,x.n-1); hanoi(x1);
end end;

begin
  write('Hight: '); readln(x.n); writeln;
  x.source:=gold; x.target:=silver; x.help:=cupper;
  hanoi(x); writeln('Host d”s gsehn?!');
end.
