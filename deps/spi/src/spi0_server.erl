-module(spi0_server).
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([spi_on_after/4, on/2, off/1]).

start_link() ->
        gen_server:start_link({local, spi0_server}, spi0_server, [], []).


init(_Args) ->
Tab = ets:new(?MODULE,[ordered_set, public, {write_concurrency, true}]),
         ets:insert(Tab, {0,[ 128,   0,   0,    0,   0 ]}),
        io:format("init spi0_server V1.01~nCreate I/O buffer Tab ~p~n", [Tab]),
           wpi:spi_setup(0, 500000),
           wpi:spi_get_fd(0),
        process_flag(trap_exit, true),
        {ok,{[ 128,   0,   0,    0,   0 ],Tab}}.

off(Send_to_spi) ->
      gen_server:call( ?MODULE, {off,Send_to_spi}).

on(For,Send_to_spi) -> 
     gen_server:call( ?MODULE, {on, For, Send_to_spi}).

spi_on_after(Time_after, For, Spi_ets, Num_led) when (Num_led < 34) -> 
     gen_server:call( ?MODULE, {spi_on_after, Time_after, For, Spi_ets, Num_led});
spi_on_after(_Time_after, _For, _Spi_ets, _Num_led)  ->io:format(">34",[]).
 %-------------------------------------------------------------


handle_call({on, For, Send_to_spi}, _From, {State,Tab}) ->
 %      io:format("spi on After timer for ~p~nState ~p~n", [For, State]),
        [{0,Buffer}] = ets:lookup(Tab,0),

io:format("~p~n",[xor_list(Buffer,Send_to_spi,[])]),

      wpi:spi_data_rw(0 ,erlang:list_to_binary(Send_to_spi)),
                  timer:apply_after(For, spi0_server, off,[Send_to_spi]),
       {reply, ok, {Send_to_spi,Tab}};

handle_call({off,Send_to_spi}, _From, {State,Tab}) ->
%       io:format("spi off After timer~n State ~p~n",[ State]),
        [{0,Buffer}] = ets:lookup(Tab,0),

io:format("~p~n",[xor_list(Buffer,Send_to_spi,[])]),

       wpi:spi_data_rw(0 ,erlang:list_to_binary([ 128,   0,   0,    0,   0 ])),
       {reply, ok,{[ 128,   0,   0,    0,   0 ],Tab}};

handle_call({spi_on_after, Time_after_which, For, Spi_ets, Num_led}, _From, {State,Tab}) ->
        [{_Num,Send_to_spi}] = ets:lookup(Spi_ets,Num_led),
        [{0,Buffer}] = ets:lookup(Tab,0),

io:format("~p~n",[xor_list(Buffer,Send_to_spi,[])]),

timer:apply_after(Time_after_which, spi0_server, on, [For, Send_to_spi]),

     %   io:format("~nspi_on_after timer for ~p~n State=  ~p~nSend_to_spi=~p~nBuffer~p~n",
      %             [Time_after_which,  State, 
%                   Send_to_spi,Buffer]),

        {reply,ok,{Send_to_spi,Tab}}.
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
%--- helpers -------------------------------
xor_list([],[],Accum)->
lists:reverse(Accum);

xor_list([H1|T1],[H2|T2],Accum)->
xor_list(T1, T2, [(H1 bxor H2)|Accum]).
