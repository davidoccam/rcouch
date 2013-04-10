-module(soft_pcm_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    soft_pcm_sup:start_link().

stop(_State) ->
    ok.
