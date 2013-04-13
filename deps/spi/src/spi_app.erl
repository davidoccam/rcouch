-module(spi_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([apply_after/4]).
%% ===================================================================
%% Application callbacks?
%% ===================================================================
  
start(_StartType, _StartArgs) ->
    spi_sup:start_link().

stop(_State) ->
    ok.
%   spi_app:apply_after( 100, 100, 0, 100).
apply_after( Time_after, For, Led_num, Increment)->

Spi_list = [
{0,  [ 128,   0,   0,    0,   0]    },
{ 1, [ 128,   0,   0,    0,  32 ]  },
{ 2, [ 128,   0,   0,    0,  64 ]  },
{ 3, [ 128,   0,   0,    0, 128 ]  },
{ 4, [ 128,   0,   0,    1,   0 ]  },
{ 5, [ 128,   0,   0,    2,   0 ]  },
{ 6, [ 128,   0,   0,    4,   0 ]  },
{ 7, [ 128,   0,   0,    8,   0 ]  },
{ 8, [ 128,   0,   0,   16,   0 ]  },
{ 9, [ 128,   0,   0,   32,   0 ]  },
{ 10, [ 128,   0,   0,   64,   0 ]  },
{ 11, [ 128,   0,   0,  128,   0 ]  },
{ 12, [ 128,   0,   1,    0,   0 ]  },
{ 13, [ 128,   0,   2,    0,   0 ]  },
{ 14, [ 128,   0,   4,    0,   0 ]  },
{ 15, [ 128,   0,   8,    0,   0 ]  },
{ 16, [ 128,   0,  16,    0,   0 ]  },
{ 17, [ 128,   0,  32,    0,   0 ]  },
{ 18, [ 128,   0,  64,    0,   0 ]  },
{ 19, [ 128,   0, 128,    0,   0 ]  },
{ 20, [ 128,   1,   0,    0,   0 ]  },
{ 21, [ 128,   2,   0,    0,   0 ]  },
{ 22, [ 128,   4,   0,    0,   0 ]  },
{ 23, [ 128,   8,   0,    0,   0 ]  },
{ 24, [ 128,  16,   0,    0,   0 ]  },
{ 25, [ 128,  32,   0,    0,   0 ]  },
{ 26, [ 128,  64,   0,    0,   0 ]  },
{ 27, [ 128, 128,   0,    0,   0 ]  },
{ 28, [ 129,   0,   0,    0,   0 ]  },
{ 29, [ 130,   0,   0,    0,   0 ]  },
{ 30, [ 132,   0,   0,    0,   0 ]  },
{ 31, [ 136,   0,   0,    0,   0 ]  },
{ 32, [ 144,   0,   0,    0,   0 ]  },
{ 33, [ 160,   0,   0,    0,   0 ]  },
{ 34, [ 192,   0,   0,    0,   0 ]  }
%{ 35, [ 255, 255, 255, 255,  192 ]  } not enough power for this at moment
],

    Spi_ets = ets:new(spi_ets,[ordered_set, public]),
    lists:foreach(fun (E) -> 
                  ets:insert(Spi_ets, E) end,
           Spi_list),

lists:foreach(fun(Y)->
              spi0_server:spi_on_after(Y+(Increment*Y), For, Spi_ets, Y)
              end,
              lists:seq(1,34,1)).

