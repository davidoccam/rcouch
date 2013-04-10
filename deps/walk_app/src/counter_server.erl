-module(counter_server).
-behaviour(gen_server).

-export([start_link/0,init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([add/1,subtract/1,reset_to/1]).

start_link() ->
gen_server:start_link({local, counter_server}, counter_server, [], []).


add(Num) ->      gen_server:call( ?MODULE, {add,      Num}).

subtract(Num) -> gen_server:call( ?MODULE, {subtract, Num}).

reset_to(Reset_value) -> gen_server:call( ?MODULE, {reset_to, Reset_value}).

init(_Args) ->
Tab = ets:new(?MODULE,[ordered_set, public, {write_concurrency, true}]),
io:format("~nin counter_server init, ~ncreated ets table ~p~n", [Tab]),
process_flag(trap_exit, true),
{ok, {0,Tab}}.

handle_call({add, {Num_to_add, F}}, _From, {State,Tab}) -> 
_Response = ets:insert(Tab,{F}),
  {reply, {State + Num_to_add,Tab}, {State + Num_to_add,Tab}};
% {reply, Reply,              Newstate}
  
handle_call({subtract, Num_to_sub}, _From, {State,Tab}) -> 
  {reply, {State - Num_to_sub,Tab}, {State - Num_to_sub,Tab}};
  
handle_call({reset_to, Reset_value}, _From, {_State,Tab}) -> 
  {reply, {Reset_value,Tab}, {Reset_value,Tab}}.


terminate(_Reason, State) ->
Reply = State,
    {reply, Reply, State}.
    
handle_cast(_Msg, State) ->
io:format("in handle_cast~n", []),
    {noreply, State}.

handle_info(Info, State) ->
io:format("in handle_info ~p~n", [Info]),
    {noreply, State}.
    
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
    


 
