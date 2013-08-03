-module(smx).

-export([travel_read/2, travel_write/2, travel_print/1, travel_delete/2, travel_change/3]).

travel_read(Tab, FunReadRec) ->
    F = fun() ->
        mnesia:read_lock_table(Tab),
        mnesia:foldl(FunReadRec, ok, Tab)
    end,
    mnesia:transaction(F).

travel_write(Tab, FunWriteRec) ->
    F = fun() ->
            mnesia:write_lock_table(Tab),
            mnesia:foldl(FunWriteRec, ok, Tab)
        end,
    mnesia:transaction(F).

travel_print(Tab) ->
    F = fun(Rec, _Acc) ->
            io:format("~p~n", [Rec])
        end,
    travel_read(Tab, F).

%% Guard is a Fun with one parameter.
%% Sample usage:
%%    smx:travel_delete(passwd,
%%                      fun(Rec) ->
%%                          #passwd{us = {Name, _Host}} = Rec,
%%                          Name =:= "smx"
%%                      end).
travel_delete(Tab, Guard) ->
    F = fun(Rec, _Acc) ->
            case Guard(Rec) of
            true ->
                mnesia:delete_object(Rec);
            _ ->
                ok
            end
        end,
    travel_write(Tab, F).

%% Guard is a Fun with one parameter.
%% GetNew is a Fun with one parameter.
%% Sample usage:
%%    smx:travel_change(passwd,
%%                      fun(Rec) ->
%%                          #passwd{us = {Name, _Host}} = Rec,
%%                          Name =:= "smx"
%%                      end,
%%                      fun(Rec) ->
%%                          New = Rec#passwd{password = "asdf"}
%%                      end).
travel_change(Tab, Guard, GetNew) ->
    F = fun(Rec, _Acc) ->
            case Guard(Rec) of
            true ->
                New = GetNew(Rec),
                mnesia:write(New);
            _ ->
                ok
            end
        end,
    travel_write(Tab, F).


