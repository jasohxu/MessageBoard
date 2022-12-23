% CMPSC-410 Assignment 7
% Sukhrob Ilyobekov, Jason Xu, Ismail Mikou

-module(test).
-export([test_client/0]).
-import(client, [start/0, signup/2, post/4]).

test_client() ->
    ServerPid = start(),
    signup("Sukhrob", "Test12345"),
    post(ServerPid, "Sukhrob", "Test12345", "First post!"),
    timer:sleep(2000),

    post(ServerPid, "Sukhrob", "Test12345", "Second post before the auto-logout."),
    timer:sleep(500),

    signup("Jason","TestTestTest"),
    post(ServerPid,"Jason","TestTestTest","A post from a new account."),
    timer:sleep(2000),

    post(ServerPid, "Sukhrob", "Test12345", "This will fail due to the auto-logout procedure."),
    signup("Sukhrob", "Test54321"),
    post(ServerPid, "Sukhrob", "Test54321", "Second registration due to the auto-logout."),
    timer:sleep(500),

    signup("Ismail","TestseT"),
    post(ServerPid,"Ismail","WRONGPASSWORD","This should fail due to an incorrect password."),
    post(ServerPid,"Ismail","TestseT","Correct password."),
    ok.