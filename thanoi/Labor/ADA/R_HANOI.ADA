with TEXT_IO,iio; use TEXT_IO,iio;

procedure test_hanoi is
  type T_TOWER is (gold,silver,cupper);
  n:NATURAL;

  package tower_io is new enumeration_io(T_TOWER);
  use tower_io;
  
  procedure hanoi_rekursive (source,target,help:T_TOWER; n:NATURAL) is

    procedure move (source,target:T_TOWER) is
    begin
	PUT(source); PUT(" "); PUT(target);
        NEW_LINE;
    end;

  begin
 
    if n=1
      then move(source,target);
      else hanoi_rekursive(source,help,target,n-1);
           move(source,target);
	   hanoi_rekursive(help,target,source,n-1);
    end if;  

  end hanoi_rekursive;

begin
  PUT("Hight: "); GET(n); NEW_LINE;
  hanoi_rekursive(gold,silver,cupper,n);
end;          
