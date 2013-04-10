-module(gpio1_server).
-behaviour(gen_server).

-export([start_link/0,init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([direction/1,on/0,off/0,on_timed/1]).

start_link() ->
gen_server:start_link({local, gpio1_server}, gpio1_server, [], []).

on_timed(Time_on) -> gen_server:call( ?MODULE, {on_timed,Time_on}).

off() ->      gen_server:call( ?MODULE, {off}).

on() -> gen_server:call( ?MODULE, {on}).

direction(Reset_value) -> gen_server:call( ?MODULE, {direction, Reset_value}).

init(_Args) ->
io:format("init gpio1_server V1.0~n", []),
process_flag(trap_exit, true),
{ok,{}}.

handle_call({on_timed,Time_on}, {From, State},_) ->
wpi:pin_mode(1,output),
wpi:digital_write(1,1),
case timer:apply_after(Time_on, gpio1_server, off,[]) of
Any->ok
%io:format("After ~p~n",[Any])
end,
  {reply,ok, State};


handle_call({on}, {From, State},_) ->
%io:format("Pin1 = ~p on ",[1]),
wpi:pin_mode(1,output),
wpi:digital_write(1,1),
  {reply,ok, State};

handle_call({off}, {From, State},_) ->
%io:format("Pin1 = ~p off ",[1]),
wpi:digital_write(1,0),
  {reply,ok,State};

handle_call({direction, Reset_value}, {From, State},_) ->
%io:format("Gpio2 Reset_value = ~p~n,From =  ~p~n,State ~p~n",[Reset_value, From, State]),
  {reply,ok,Reset_value }.


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
