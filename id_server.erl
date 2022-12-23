% CMPSC-410 Assignment 7
% Sukhrob Ilyobekov, Jason Xu, Ismail Mikou

-module(id_server).
-export([start_server/0,autologout/2]).
-import(post_server, [start_post_server/0]).
-import(erlang,[send/2]).
-define(AUTOLOGOUT, 3000).

start_server() ->
    PostServerPid = start_post_server(),
    IdServerPid = spawn(fun() -> server_loop(PostServerPid, []) end),
    register(messageboard, IdServerPid),
    IdServerPid.

server_loop(PostServerPid, UsersList) ->
    receive
        {autologout,Name,Cookie} ->
            ExpiringUser = {Name,Cookie},
            UpdatedList = lists:delete(ExpiringUser,UsersList),
            server_loop(PostServerPid,UpdatedList);
        
        {ClientPid, signup, Name, Password} ->
            SignUpResult = signup(Name, Password, UsersList),

            case SignUpResult of 
                {ok, UpdatedList} ->
                    ClientPid ! {self(), {ok, UpdatedList}},
                    server_loop(PostServerPid, UpdatedList);
                    
                {duplicate, UpdatedList} ->
                    ClientPid ! {self(), {duplicate, UpdatedList}},
                    server_loop(PostServerPid, UpdatedList)
            end;
            
        {ClientPid, post, Name, Password, Text} -> 
            SignInResult = signin(Name, Password, UsersList),

            case SignInResult of
                {ok, _UsersList} ->
                    PostServerPid ! {ClientPid, post, Text}; % Send message to post server
                
                {false, _UsersList} ->
                    ClientPid ! {self(), error}
            end;

        {ClientPid, _} -> 
            ClientPid ! {self(), badrequest} % Bad request error
    end,
    server_loop(PostServerPid, UsersList).

signin(Name, Password, UsersList) ->
    Cookie = erlang:md5(Name ++ Password),
    ExistingUser = lists:search(fun(X) -> X =:= {Name, Cookie} end, UsersList),

    case  ExistingUser of
        {value, _} ->
            {ok, UsersList};
        false ->
            {false, UsersList}
    end.

signup(Name, Password, UsersList) -> 
    Cookie = erlang:md5(Name ++ Password),
    ExistingUser = lists:keyfind(Name, 1, UsersList),

    case  ExistingUser of
        false ->
            spawn(fun() -> autologout(Name,Cookie) end),
            {ok, [{Name, Cookie} | UsersList]};
        _ ->
            {duplicate, UsersList}
    end.

autologout(Name,Cookie) ->
    receive
        after ?AUTOLOGOUT ->
            send(messageboard,{autologout, Name, Cookie})
        end.