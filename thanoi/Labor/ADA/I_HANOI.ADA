-- Rekursive Programme  Aufgabe 6, Blatt 3
-- "Tuerme von Hanoi"
-- Dr. Dziolloá  TU Dresden

generic
   type T_ELEMENT is private;

package generic_stack is
  type T_STACK (size:NATURAL) is private;
  procedure push (e:T_ELEMENT; stack:in out T_STACK);
  function is_empty (stack:T_STACK) return BOOLEAN;
  procedure pop (stack:in out T_STACK);
  function top (stack:T_STACK) return T_ELEMENT;
  procedure init (stack:in out T_STACK);
  stack_overflow:exception;
private
  type T_ARRAY is array(NATURAL RANGE <>) of T_ELEMENT;
  type T_STACK (size:NATURAL) is record
                   index:NATURAL;
                   e_array:T_ARRAY(1..size);
       end record;

end generic_stack;

package body generic_stack is

procedure push (e:T_ELEMENT; stack:in out T_STACK) is
begin
  if stack.index > stack.e_array'LAST
    then raise stack_overflow;
    else stack.e_array(stack.index):=e;
         stack.index:=stack.index+1;
  end if;
end push;

function top (stack:T_STACK) return T_ELEMENT is
begin
  return stack.e_array(stack.index-1);
end top;

function is_empty (stack:T_STACK) return BOOLEAN is
begin
  return (stack.index=1);
end is_empty;

procedure pop (stack:in out T_STACK) is
begin
  if not is_empty(stack)
    then stack.index:=stack.index-1;
  end if;
end pop;

procedure init (stack:in out T_STACK) is 
begin
  stack.index:=1;
end init;

end generic_stack;

with TEXT_IO,iio,generic_stack; use TEXT_IO,iio;

procedure test_hanoi is
  type T_TOWER is (gold,silver,cupper);
  type T_INFO is record  
      source,target,help:T_TOWER; n:NATURAL;
  end record;
  type T_CALL is (first_call,second_call);
  type T_STATE is record  call:T_CALL; x:T_INFO; end record;
  n:NATURAL;

  package tower_io is new enumeration_io(T_TOWER);
  use tower_io;
  package stack_i is new generic_stack(T_STATE);
  use stack_i;
  s:T_STACK(50);
  
  procedure hanoi_iterative (x:T_INFO) is
    state:T_STATE;
    x1:T_INFO:=x;
    top_down:BOOLEAN:=true;

    procedure move (source,target:T_TOWER) is
    begin
  	NEW_LINE; 
	PUT(source); PUT(" "); PUT(target);
        NEW_LINE;
    end;

  begin
    init(s);
    push((first_call,x),s);
    while not is_empty(s) loop
      if top_down
	then if x1.n > 1
               then if top(s).call = first_call
		      then x1:=(x1.source,x1.help,x1.target,x1.n-1);
                      else x1:=(x1.help,x1.target,x1.source,x1.n-1);
                    end if;
                    push((first_call,x1),s);
               else
                   pop(s);
                   top_down:=false;
                   move(x1.source,x1.target);
             end if;
        else
            state:=top(s);
            pop(s);
            if state.call = first_call
              then x1:=state.x;
                   move(state.x.source,state.x.target);
                   state.call:=second_call;
                   push(state,s);
                   top_down:=true;
	    end if;
      end if;
    end loop;
  end hanoi_iterative;

begin
  PUT("Hight: "); GET(n); NEW_LINE(2);
  hanoi_iterative((gold,silver,cupper,n));
end;          
