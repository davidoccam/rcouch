-module(walk_server).

-behaviour(gen_server).

-export([start_link/0, walk/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    {ok, []}.
    


%diagnostic start
walk() ->  
walk:start("/home/david/Malcs").

%% callbacks


handle_call(_Request, _From, State) ->
io:format("in handle_call1~n", []),
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
io:format("in handle_cast~n", []),
    {noreply, State}.

handle_info(Info, State) ->
io:format("in handle_info ~p~n", [Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


