-module(spi1_server).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([]).

start_link() ->
gen_server:start_link({local, spi1_server}, spi1_server, [], []).


init(_Args) ->
io:format("init spi1_server V1.0~n", []),
process_flag(trap_exit, true),
{ok,{}}.

off() ->      gen_server:call( ?MODULE, {off}).

on() -> gen_server:call( ?MODULE, {on}).

on_timed(Time_on) -> gen_server:call( ?MODULE, {on_timed,Time_on}).

handle_call({on_timed,Time_on}, {From, State},_) ->
case timer:apply_after(Time_on, spi0_server, off,[]) of
Any->ok
%io:format("After ~p~n",[Any])
end,
  {reply,ok, State};

handle_call({on}, {From, State},_) ->
  {reply,ok, State};

handle_call({off}, {From, State},_) ->
  {reply,ok,State}.

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


