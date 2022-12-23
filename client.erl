% CMPSC-410 Assignment 7
% Sukhrob Ilyobekov, Jason Xu, Ismail Mikou

-module(client).
-export([start/0, signup/2, post/4]).
-import(erlang, [send/2]).
-import(id_server, [start_server/0]).

start() -> 
    start_server().

signup(Name, Password) ->
    send(messageboard, {self(), signup, Name, Password}),
    receive
        {_Pid, Response} -> io:format("~p~n", [Response])
    end.

post(ServerPid, Name, Password, Text) ->
    send(ServerPid, {self(), post, Name, Password, Text}),
    receive
        {_Pid, Response} -> io:format("~p~n", [Response])
    end.
