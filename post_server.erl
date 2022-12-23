% CMPSC-410 Assignment 7
% Sukhrob Ilyobekov, Jason Xu, Ismail Mikou

-module(post_server).
-export([start_post_server/0]).

start_post_server() ->
    spawn(fun() -> server_loop() end).

server_loop() ->
    receive 
        {Pid, post, Text} ->
            io:format("~p~n", [Text]),
            Pid ! {ok, "Posted successfully."}   
    end,
    server_loop().