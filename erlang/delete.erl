-module(delete).
-export([delete/1,batch_delete/2]).
-include_lib("stdlib/include/qlc.hrl").
-record(md,{id,name}).

batch_delete(Id,Limit) ->
				Match_head = #md{id='$1',name='$2'},
				Guard = {'<','$1',Id},
				Result = '$_',
				{Record,Cont} = mnesia:activity(async_dirty, fun mnesia:select/4,[md,[{Match_head,[Guard],[Result]}],Limit,read]),
				delete_next({Record,Cont}).

delete_next('$end_of_table') ->
				over;
delete_next({Record,Cont}) ->
				delete(Record),
				delete_next(mnesia:activity(async_dirty, fun mnesia:select/1,[Cont])).

delete(Records) ->
     %io:format("delete(~p)~n",[Records]),
     batch(fun mnesia:delete_object/1,Records).   

batch(Op,Object) ->
  F = fun() ->
        [Op(O) || O <- Object]
  end,
  mnesia:transaction(F).
