-module(gpio5_server).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([direction/1,on/0,off/0,on_timed/1]).

start_link() ->
gen_server:start_link({local, gpio5_server}, gpio5_server, [], []).

on_timed(Time_on) -> gen_server:call( ?MODULE, {on_timed,Time_on}).


off() ->      gen_server:call( ?MODULE, {off}).

on() -> gen_server:call( ?MODULE, {on}).

direction(Reset_value) -> gen_server:call( ?MODULE, {direction, Reset_value}).

init(_Args) ->
io:format("init gpio5_server V1.0~n", []),
process_flag(trap_exit, true),
{ok,{}}.


handle_call({on_timed,Time_on}, _From, State) ->
wpi:pin_mode(5,output),
wpi:digital_write(5,1),
case timer:apply_after(Time_on, gpio5_server, off,[]) of
_Any->ok
end,
  {reply,ok, State};


handle_call({on}, _From, State) ->
wpi:pin_mode(5,output),
wpi:digital_write(5,1),
  {reply,ok, State};

handle_call({off}, _From, State) ->
wpi:digital_write(5,0),
  {reply,ok,State};

handle_call({direction, Reset_value},_From, State) ->
  {reply, ok, Reset_value }.


terminate(_Reason, State) ->
Reply = State,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
io:format("in handle_cast~n", []),
    {reply, State}.

handle_info(Info, State) ->
io:format("in handle_info ~p~n", [Info]),
    {reply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
