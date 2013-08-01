-module(test).
-export([example/1,select/2,operater/3,operater/2,clean_table/1,delete/1,qengin/1,paste/2,insert/1,qquery/2,parse/1]).
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
table_st(Table) ->
  Temp = mnesia:table_info(Table,cstruct),
  Table_structure = element(14,Temp),
  io:format("==== table structure ====~n~p~n",[Table_structure]).

replace(A, [{qs,_},B]) ->
	[A | B];
replace(A, B) ->
  [A | B].

qengin(Table_info) ->
	receive
		{st,Table} ->
      Temp = mnesia:table_info(Table,cstruct),
      Table_structure = element(14,Temp),
	    io:format("==== table structure ====~n~p~n",[Table_structure]),
      qengin([{name,Table},{structure,Table_structure}]);
    {qs,Condition} ->
      Table_st = proplists:get_value(structure,Table_info),
			Table_name = proplists:get_value(name,Table_info),
	    Temp = lists:map(fun(X)->string:to_upper(atom_to_list(X)) end,Table_st),
      QS = "[{" ++ paste(Temp,",") ++ "}||{" ++ 
          paste([atom_to_list(Table_name) | Temp],",") ++ 
          "} <- mnesia:table(" ++ atom_to_list(Table_name) ++ 
          ")," ++ atom_to_list(Condition) ++ "].",
      io:format("~p~n",[QS]),
			% store new query condition 
			qengin(replace({qs,QS},Table_info));
			do ->
				QS = proplists:get_value(qs,Table_info),
        F = fun() ->
          QueryH = qlc:string_to_handle(QS), 
          qlc:eval(QueryH)
          end,
        {atomic,Result} = mnesia:transaction(F),
        io:format("==== result ====~n",[]),
        lists:foreach(fun(X) -> io:format("~p~n",[X]) end,Result),
				qengin(Table_info)
  end.

		  
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

select(Table,Key) ->
  operater(fun mnesia:read/1,{Table,Key}).
example(Table) ->
  {atomic,K} = operater(fun mnesia:first/1,Table),
  {atomic,Recoder} = select(Table,K),
	[H | _] = Recoder,
	table_st(Table),
	H.
insert(Value) ->
  operater(fun mnesia:write/1,Value).

delete(Record) ->
	operater(fun mnesia:delete_object/1,Record).
  
clean_table(Table) ->
  {_,T1,_} = erlang:now(),
  First_key = operater(fun mnesia:first/1,Table),
	io:format("first key ~p~n",[First_key]),
  delete_all(Table,First_key),
  {_,T2,_} = erlang:now(),
  T2 - T1.

delete_all(Table,{atomic,'$end_of_table'}) ->
  over;
delete_all(Table,{atomic,K}) ->
	io:format("delete: ~p~n",[K]),
	Next_key = operater(fun mnesia:next/2,Table,K),
	operater(fun mnesia:delete/1,{Table,K}),
	delete_all(Table,Next_key).

operater(Op,Table,K) ->
  F = fun() ->
        Op(Table,K)
  end,
  mnesia:transaction(F).
	
operater(Op,Object) ->
  F = fun() ->
        Op(Object)
  end,
  mnesia:transaction(F).

