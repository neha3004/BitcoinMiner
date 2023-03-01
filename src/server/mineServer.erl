-module(mineServer).
-import(string,[to_lower/1]).
-import(string,[sub_string/3]).
-export([start_server/0, server/1]).

server(K)->
  receive
    hello ->
      io:format("someonesays Hello~n");
    {i_am_worker, WorkerPid} ->
      io:format("Server Received a Worker~n"),
      io:format("Worker Node ~p ~n",[WorkerPid]),
      WorkerPid ! hello;
    {got_coin, {Coin, Hash}} ->
      io:format("Bitcoin generated is ---> ~p~n~nHashed String is---> :  ~p~n",[Coin,Hash]);
    {mine, WPid} ->
      WPid ! {zcount, K};
    {time,CPU,REAL, RATIO} ->
      io:format("CPU TIME : ~p REAL TIME : ~p RATIO : ~p",[CPU,REAL, RATIO]);
    terminate ->
      exit("Exited")
  end,
  server(K).

start_server() ->
  {ok, K} = io:read("Enter a number of leading zeroes: "),
  io:format("Entered No.of leading zeroes : ~p~n",[K]),
  register(serverPid,spawn(mineServer, server,[K])),
  {_,_}=statistics(runtime),
  {_,_}=statistics(wall_clock).
