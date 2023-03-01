-module(mineWorker).
-import(string,[to_lower/1]).
-import(string,[sub_string/3]).
-export([ findMatchingBitcoins/1, worker/1, create_worker/2, start_worker/2, spawn_slaves/2, listen/2]).


%This function is used to check leading zeroes in the prefixed and encrypted string.
findMatchingBitcoins(K) ->
  receive
    {mine, From, SNode} ->
      CurrentCoin = generateNewBitcoin(),
      Hash = to_lower(hashBitcoin(CurrentCoin)),
      HashLength = string:len(Hash),
      if
        HashLength =< (64-K) ->
          io:format("Found a Coin with ~p zeroes ~n",[K]),
          %Imitating the server that a matching bitcoin has been mined and sending back the corresponding bitcoin and hash.
          {From, SNode} ! {got_coin,{CurrentCoin, zeroPrefixingForComparison(K)++Hash}};
        true ->
          spawn(mineWorker, findMatchingBitcoins,[K]) ! {mine, From, SNode}
      end
  end.

%This function generates string with number of zeroes matching command line input and is used for subsequent string comparison.
zeroPrefixingForComparison(0) -> "";
zeroPrefixingForComparison(N) ->
  "0"++zeroPrefixingForComparison(N-1).


%This function will encrypt the bitcoin mined using SHA256 key based encryption algorithm.
hashBitcoin(Coin) ->
  Hashed_string=integer_to_list(binary:decode_unsigned(crypto:hash(sha256,Coin)),16),
  Hashed_string.


%This function is used to generate bitcoin and prefix it with author's names/UFID.
generateNewBitcoin() ->
  CharactersAllowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789;!@#$%^&*()+-_=",
  RandomString = generateRandomString(256, CharactersAllowed),
  AuthorID = "priyaneha;",
  Bitcoin = RandomString ++ AuthorID,
  Bitcoin.


%This function generates random strings for bitcoin mining.
generateRandomString(Length, CharacterOptions) ->
  lists:foldl(fun(_, Acc) -> [lists:nth(rand:uniform(length(CharacterOptions)), CharacterOptions)] ++ Acc end,
    [], lists:seq(1, Length)).


%Worker function spawns other processes to mine bitcoins
worker(SNode) ->
  {serverPid, SNode} ! {mine, self()},
  receive
    {zcount, K} ->
      spawn(mineWorker, findMatchingBitcoins,[K]) ! {mine, serverPid, SNode}
  end.

%Spawn slaves function recursively spawns more workers to mine bitcoins
spawn_slaves(1, SNode) ->
  spawn(mineWorker, worker, [SNode]);
spawn_slaves(N, SNode) ->
  spawn(mineWorker, worker, [SNode]),
  spawn_slaves(N-1, SNode).


%start_worker pings the server that worker is available
start_worker(S,C) ->
  register(client,spawn(mineWorker,create_worker,[S,C])).


%Does the runtime evaluation of worker's CPU utilization
create_worker(SNode, C) ->
  {_,_}=statistics(runtime),
  {_,_}=statistics(wall_clock),
  io:format("Creating Worker~n"),
  %{ok, C} = io:read("Enter a number: "),
  spawn_slaves(C, SNode),
  listen(1,SNode).


%Listen function sends the CPU utilization reports back to the server
listen(N,SNode) ->
  io:format("N : ~p ~n", [N]),
  receive
    got ->
      io:format("B : ~p" , [N]),
      if
        N == 5 ->
          {_,CPU}=statistics(runtime),
          {_,REAL}=statistics(wall_clock),
          {serverPid,SNode} ! {time, CPU, REAL, CPU/REAL};
        true ->
          listen(N+1,SNode)

      end
  end.
