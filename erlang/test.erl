-module(test).
-export([init_table/2,example/1,select/2,next_n/4,operater/3,operater/2,clean_table/1,delete/1,qengin/1,paste/2,insert/1,parse/1]).
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

select(Table,Key) ->
  operater(fun mnesia:read/1,{Table,Key}).

example(Table) ->
  {atomic,K} = operater(fun mnesia:first/1,Table),
	{atomic,[Recoder | _]} = select(Table,K),
	table_st(Table),
	Recoder.

init_table(Table,1) ->
	insert({Table,1,over});
init_table(Table,N) ->
	insert({Table,N,a}),
	init_table(Table,N - 1).

insert(Value) ->
  operater(fun mnesia:write/1,Value).

delete(Record) ->
	operater(fun mnesia:delete_object/1,Record).
  
clean_table(Table) ->
  First_key = operater(fun mnesia:first/1,Table),
	io:format("first key ~p~n",[First_key]),
  delete_all(Table,First_key).

delete_all(Table,{atomic,'$end_of_table'}) ->
  over;
delete_all(Table,{atomic,K}) ->
	Next_key = operater(fun mnesia:next/2,Table,K),
	operater(fun mnesia:delete/1,{Table,K}),
	delete_all(Table,Next_key).

next_n(Table,K,1,All_key) ->
				{atomic,Next_key} = operater(fun mnesia:next/2,Table,K),
				[Next_key | All_key];
next_n(Table,K,N,All_key) ->
				{atomic,Next_key} = operater(fun mnesia:next/2,Table,K),
				io:format("next key : ~p~n",[Next_key]),
				next_n(Table,Next_key,N-1,[Next_key | All_key]).
   
operater(Op,Table,Keys) ->
  F = fun() ->
			  Op(Table,Keys)
  end,
  mnesia:transaction(F).
	
operater(Op,Object) ->
  F = fun() ->
        Op(Object)
  end,
  mnesia:transaction(F).

