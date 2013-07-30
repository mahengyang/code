-module(ma).
-export([print_ts/1,init_table/0,query/1,qquery/1,read_all/1,print/1,trans/1]).
-include_lib("stdlib/include/qlc.hrl").

-record(ma,{id,name}).

% print table structure
print_ts(Table) ->
	Temp = mnesia:table_info(Table,cstruct),
	Table_structure = element(14,Temp).


init_table() ->
	mnesia:create_table(ma,[{attributes,record_info(fields,ma)}]).

query(Name) ->
	mnesia:transaction(
          fun() ->
	    mnesia:select(ma,[{#ma{id=Name,name='$1'},[],['$$']}])
        end).
%% use qlc to query
qquery(Table,Condition) ->
	mnesia:transaction(
	 fun() -> 
	  T = mnesia:table(Table),
	  QueryH = qlc:q([U#ma.name || U <- T, U#ma.id =:= Name]),
	  qlc:eval(QueryH)
        end).

read_all(Name) ->
	F = fun(Rec,_Acc) ->
	      io:format("~p~n",[Rec])
	    end,
	mnesia:transaction(
          fun() ->
	    mnesia:read_lock_table(Name),
	    mnesia:foldl(F,ok,Name)
          end).

%% 
print(S) ->
	fun(Text) ->
	  M = S ++ Text ++ S,
    io:format("result is: ~p.~n", [M])
  end.

trans(Operater) ->
	F = fun(Rec,_Acc) ->
	      io:format("~p~n",[Rec])
	    end,
  fun(Table) ->
	  mnesia:transaction(
      fun() ->
	      Operater(Table),
	      mnesia:foldl(F,ok,Table)
      end)
	end.
%mquery(Table) <- 
%	O = trans(fun mnesia:read_lock_table/1),
%	O(Table).
%
%insert() <- 
%	trans(fun mnesia:write_lock_table/1).
