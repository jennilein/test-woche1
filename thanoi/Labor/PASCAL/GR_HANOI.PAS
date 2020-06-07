program Hanoi_rekursive;
uses crt,mengen;
type t_tower = (gold,silver,cupper);
     t_info = record source,target,help:t_tower; n:integer; end;
var x,x1:t_info;
    tower:array[0..2] of bitset;
    x0n,i,j:byte;
procedure infobau(var x:t_info; is,it,ih:t_tower; bn:integer);
var x1:t_info;
begin x1.source:=is; x1.target:=it; x1.help:=ih; x1.n:=bn; x:=x1;
end;

procedure hanoi(x:t_info);
  var x1:t_info;
  procedure move(source,target:t_tower);
  var ring,floor:byte;
  begin floor:=bcard(tower[ord(source)]);
        ring:=bcomp(tower[ord(source)],1);
        gotoxy(15+(ord(source)*25)-ring,23-floor);
        for j:=1 to 2*ring+1 do write(' ');
        bexcl(tower[ord(source)],ring); bincl(tower[ord(target)],ring);
        floor:=bcard(tower[ord(target)]);
        gotoxy(15+(ord(target)*25)-ring,23-floor);
        for j:=1 to 2*ring+1 do
          if j=ring+1 then write(chr(ord('A')+ring-1)) else write('=');
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
  clrscr;
  write('Hight: '); repeat readln(x.n); until x.n in [1..12];
  clrscr; gotoxy(1,24); for i:=1 to 80 do write('-'); writeln;
  tower[0]:=[]; tower[1]:=[]; tower[2]:=[]; x0n:=x.n;
  for i:=x.n downto 1 do begin
    bincl(tower[0],i); gotoxy(15-i,22-x.n+i);
    for j:=1 to 2*i+1 do
      if j=i+1 then write(chr(ord('A')+i-1)) else write('=');
  end;
  x.source:=gold; x.target:=silver; x.help:=cupper;
  hanoi(x); gotoxy(1,25); write('Host d”s gsehn?!'); readln;
end.
