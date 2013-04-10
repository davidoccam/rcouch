-module(gpio_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================


init([]) ->
Children = [
             ?CHILD(gpio7_server, worker),
             ?CHILD(gpio6_server, worker), 
             ?CHILD(gpio5_server, worker),
             ?CHILD(gpio4_server, worker),
             ?CHILD(gpio3_server, worker),
            ?CHILD(gpio2_server, worker),
            ?CHILD(gpio1_server, worker), 
            ?CHILD(gpio0_server, worker)
           ],
    {ok, { {one_for_one, 5, 10}, Children} }.
