-module(test).
-export([paste/2,qquery/2,parse/1]).
-include_lib("stdlib/include/qlc.hrl").

parse(S) ->
    {ok,Scanned,_} = erl_scan:string(S),
    {ok,Parsed} = erl_parse:parse_exprs(Scanned),
    {value, Value,_} = erl_eval:exprs(Parsed,[]),
    Value. 

%% ["ID","NAME"] --> "ID,NAME"
paste([A | []],Sep) ->
  A;
paste([A | Rest],Sep) ->
  T = string:concat(A,Sep),
  string:concat(T, paste(Rest,Sep)).

%% use qlc to query, Condition is an atom
qquery(Table,Condition) ->
  % get table fields
  Temp = mnesia:table_info(Table,cstruct),
  Table_structure = element(14,Temp),
	io:format("==== table structure ====~n~p~n",[Table_structure]),
  {ok,Ts,_} = erl_scan:string(atom_to_list(Condition)),
  [{_,_,Col} | _] = Ts,
	% [id,name] --> ["ID","NAME"]
	Field = lists:map(fun(X)->string:to_upper(atom_to_list(X)) end,Table_structure),
  % building query string for qlc
  QS = "[{" ++ paste(Field,",") ++ "}||{" ++ 
          paste([atom_to_list(Table) | Field],",") ++ 
          "} <- mnesia:table(" ++ atom_to_list(Table) ++ 
          ")," ++ atom_to_list(Condition) ++ "].",
  io:format("~p~n",[QS]),
  F = fun() ->
    QueryH = qlc:string_to_handle(QS), 
    qlc:eval(QueryH)
    end,
  {atomic,Result} = mnesia:transaction(F),
	io:format("==== result ====~n",[]),
	lists:foreach(fun(X) -> io:format("~p~n",[X]) end,Result).

