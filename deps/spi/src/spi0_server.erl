-module(spi0_server).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([spi_on_after/4, on/2, off/0]).

start_link() ->
        gen_server:start_link({local, spi0_server}, spi0_server, [], []).


init(_Args) ->
        io:format("init spi0_server V1.01~n", []),
        process_flag(trap_exit, true),
        {ok,{}}.

off() ->
      gen_server:call( ?MODULE, {off}).

on(For,Send_to_spi) -> 
     gen_server:call( ?MODULE, {on, For, Send_to_spi}).

spi_on_after(Time_after, For, Spi_ets, Num_led) when (Num_led < 34) -> 
     gen_server:call( ?MODULE, {spi_on_after, Time_after, For, Spi_ets, Num_led});
spi_on_after(Time_after, For, Spi_ets, Num_led)  ->io:format(">34",[]).
 %-------------------------------------------------------------


handle_call({on, For, Send_to_spi}, {From, State},_) ->
       io:format("spi on After timer for ~p~n timer From ~p~n return = ~p~n",
                 [For, From,
                  timer:apply_after(For, spi0_server, off,[])]),
      wpi:spi_data_rw(0 ,erlang:list_to_binary(Send_to_spi)),
       {reply,ok, State};

handle_call({off}, {From, State},_) ->
       io:format("spi off After timer From ~p~n State ~p~n",[From, State]),
       wpi:spi_data_rw(0 ,erlang:list_to_binary([ 128,   0,   0,    0,   0 ])),
       {reply,ok,State};

handle_call({spi_on_after, Time_after_which, For, Spi_ets, Num_led}, {From, State},_) ->
           wpi:spi_setup(0, 500000),
           wpi:spi_get_fd(0),
[{Num,Send_to_spi}] = ets:lookup(Spi_ets,Num_led),
        io:format("~nspi on After ~p~n timer for ~p~n State=  ~p~ntimer return = ~p~nSend_to_spi=~p~n",
                   [From, Time_after_which,  State, 
                   timer:apply_after(Time_after_which, spi0_server, on, [For, Send_to_spi]), 
                   Send_to_spi]),
        {reply,ok,State}.
%-------------------------------------------------------------
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
