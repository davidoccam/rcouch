-module(spi_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([apply_after/3]).
%% ===================================================================
%% Application callbacks?
%% ===================================================================
  
start(_StartType, _StartArgs) ->
    spi_sup:start_link().

stop(_State) ->
    ok.

apply_after( Time_after, For, Led_num)->

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

 spi0_server:spi_on_after(0, For, Spi_ets, 1),
 spi0_server:spi_on_after(1000, For, Spi_ets, 2),
 spi0_server:spi_on_after(2000, For, Spi_ets, 3),
 spi0_server:spi_on_after(3000, For, Spi_ets, 4),
 spi0_server:spi_on_after(4000, For, Spi_ets, 5),
 spi0_server:spi_on_after(5000, For, Spi_ets, 6),
 spi0_server:spi_on_after(6000, For, Spi_ets, 7),
 spi0_server:spi_on_after(7000, For, Spi_ets, 8),
 spi0_server:spi_on_after(8000, For, Spi_ets, 9),
 spi0_server:spi_on_after(9000, For, Spi_ets, 10),
 spi0_server:spi_on_after(10000, For, Spi_ets, 11),
 spi0_server:spi_on_after(11000, For, Spi_ets, 12),
 spi0_server:spi_on_after(12000, For, Spi_ets, 13),
 spi0_server:spi_on_after(13000, For, Spi_ets, 14),
 spi0_server:spi_on_after(14000, For, Spi_ets, 15),
 spi0_server:spi_on_after(15000, For, Spi_ets, 16),
 spi0_server:spi_on_after(16000, For, Spi_ets, 17),
 spi0_server:spi_on_after(17000, For, Spi_ets, 18),
 spi0_server:spi_on_after(18000, For, Spi_ets, 19),
 spi0_server:spi_on_after(19000, For, Spi_ets, 20),
 spi0_server:spi_on_after(20000, For, Spi_ets, 21),
 spi0_server:spi_on_after(21000, For, Spi_ets, 22),
 spi0_server:spi_on_after(22000, For, Spi_ets, 23),
 spi0_server:spi_on_after(23000, For, Spi_ets, 24),
 spi0_server:spi_on_after(24000, For, Spi_ets, 25),
 spi0_server:spi_on_after(25000, For, Spi_ets, 26),
 spi0_server:spi_on_after(26000, For, Spi_ets, 27),
 spi0_server:spi_on_after(27000, For, Spi_ets, 28),
 spi0_server:spi_on_after(28000, For, Spi_ets, 29),
 spi0_server:spi_on_after(29000, For, Spi_ets, 30),
 spi0_server:spi_on_after(30000, For, Spi_ets, 31),
 spi0_server:spi_on_after(31000, For, Spi_ets, 32),
 spi0_server:spi_on_after(32000, For, Spi_ets, 33),
 spi0_server:spi_on_after(33000, For, Spi_ets, 34).
