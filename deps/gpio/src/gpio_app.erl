-module(gpio_app).

-behaviour(application).

-include_lib("wpi/include/wpi.hrl").

%% Application callbacks
-export([start/2, stop/1]).
-export([
         dSPIN_Xfer/2,
         spi_test/2,
         random/1,
         test_gpio_on_off/2, 
         test_gpio_on/1, 
         test_gpio_off/1,
         test_gpio_all/2,
          exercise/2
         ]).
%% ===================================================================
%% Application callbacks
%% ===================================================================

%% sudo gpio load spi
%%  lsmod
%%----------------------------------------------------------------------

start(_StartType, _StartArgs) ->
io:format("gpio export pin 0(native 17) output~p~n",[os:cmd("gpio export 17 out")]),
io:format("gpio export pin 1(native 18) output~p~n",[os:cmd("gpio export 18 out")]),
io:format("gpio export pin 2(native 21) output~p~n",[os:cmd("gpio export 21 out")]),
io:format("gpio export pin 3(native 22) output~p~n",[os:cmd("gpio export 22 out")]),
io:format("gpio export pin 4(native 23) output~p~n",[os:cmd("gpio export 23 out")]),
io:format("gpio export pin 5(native 24) output~p~n",[os:cmd("gpio export 24 out")]),
io:format("gpio export pin 6(native 25) output~p~n",[os:cmd("gpio export 25 out")]),
io:format("gpio export pin 7(native 4) output~p~n",[os:cmd("gpio export   4 out")]),
           

io:format("load spi cmd issued~p~n~p~n~p~n",
           [re:split(os:cmd("/usr/local/bin/gpio load spi"),"\n"),
            re:split(os:cmd("/usr/local/bin/gpio readall"),"\n"),
            re:split(os:cmd("/bin/lsmod"),"\n")]),

    gpio_sup:start_link().
%%----------------------------------------------------------------------

stop(_State) ->
    ok.
%% SPI
%-export([spi_get_fd/1]).
%-export([spi_data_rw/2]).
%-export([spi_setup/2]).
%%----------------------------------------------------------------------

-define(Speed,500000).
-define(Channel,0).
-define(WriteData,<<"david's first raspi spi data is great">>).
-define(LOW,0).
-define(HIGH,1).
-define(SLAVE_SELECT_PIN,99).
%%----------------------------------------------------------------------

%// This simple function shifts a byte out over SPI and receives a byte over
%//  SPI. Unusually for SPI devices, the dSPIN requires a toggling of the
%//  CS (slaveSelect) pin after each byte sent. That makes this function
%//  a bit more reasonable, because we can include more functionality in it.

dSPIN_Xfer(Channel,MOSI_Data)->
  wpi:digital_write(?SLAVE_SELECT_PIN,?LOW),
  case  wpi:spi_data_rw(Channel, MOSI_Data ) of
        {ok,MISO_Data}->
            wpi:digital_write(?SLAVE_SELECT_PIN,?HIGH),
            MISO_Data;
        Any->
            io:format("error~p~n",[Any])
  end.
%%----------------------------------------------------------------------

% gpio_app:spi_test().


spi_test(Number_of_Iterations,Delay)->

Zero=0,

First_part = [
%<< 255:8, 255:8, 255:8, 255:8,  192:8 >>, %all set
<< 128:8, Zero:8, Zero:8, Zero:8, 32:8 >>,
<< 128:8, Zero:8, Zero:8,Zero:8,  64:8 >>,
<< 128:8, Zero:8, Zero:8,  0:8, 128:8 >>,
<< 128:8, Zero:8, Zero:8,  1:8, 0:8 >>,
<< 128:8, Zero:8, Zero:8,  2:8, 0:8 >>,
<< 128:8, Zero:8, Zero:8,  4:8, 0:8 >>,
<< 128:8, Zero:8, Zero:8,  8:8, 0:8 >>,
<< 128:8, Zero:8, Zero:8,  16:8, 0:8 >>,
<< 128:8, Zero:8, Zero:8,  32:8, 0:8 >>,
<< 128:8, Zero:8, Zero:8,  64:8, 0:8 >>,
<< 128:8, Zero:8, Zero:8,  128:8, 0:8 >>,
<< 128:8, Zero:8,  1:8,   Zero:8, 0:8 >>,
<< 128:8, Zero:8,  2:8,   Zero:8, 0:8 >>,
<< 128:8, Zero:8,  4:8,   Zero:8, 0:8 >>,
<< 128:8, Zero:8,  8:8,   Zero:8, 0:8 >>,
<< 128:8, Zero:8,  16:8,  Zero:8, 0:8 >>,
<< 128:8, Zero:8,  32:8,  Zero:8, 0:8 >>,
<< 128:8, Zero:8,  64:8,  Zero:8, 0:8 >>,
<< 128:8, Zero:8,  128:8, Zero:8, 0:8 >>,
<< 128:8,  1:8,   Zero:8, Zero:8, 0:8 >>,
<< 128:8,  2:8,   Zero:8, Zero:8, 0:8 >>,
<< 128:8,  4:8,   Zero:8, Zero:8, 0:8 >>,
<< 128:8,  8:8,   Zero:8, Zero:8, 0:8 >>,
<< 128:8,  16:8,  Zero:8, Zero:8, 0:8 >>,
<< 128:8,  32:8,  Zero:8, Zero:8, 0:8 >>,
<< 128:8,  64:8,  Zero:8, Zero:8, 0:8 >>,
<< 128:8, 128:8,  Zero:8, Zero:8, 0:8 >>,
<< 129:8,   Zero:8, Zero:8, Zero:8,  0:8 >>,
<< 130:8,      0:8, Zero:8, Zero:8, 0:8 >>,
<< 132:8,   Zero:8, Zero:8, Zero:8, 0:8 >>,
<< 136:8,   Zero:8, Zero:8, Zero:8, 0:8 >>,
<< 144:8,  Zero:8, Zero:8, Zero:8, 0:8 >>,
<< 160:8,  Zero:8, Zero:8, Zero:8, 0:8 >>,
<< 192:8,  Zero:8, Zero:8, Zero:8, 0:8 >>,
<< 128:8, Zero:8, Zero:8, Zero:8, 0:8 >>  %zero
],


           wpi:spi_setup(?Channel, ?Speed),
           wpi:spi_get_fd(?Channel),
write_5450(Number_of_Iterations,Delay,First_part).

write_5450(0,_Delay,_First_part)->ok;

write_5450(Number_of_Iterations,Delay,First_part)->

 lists:foreach(
    fun(Words)->
      timer:sleep(Delay),
      case  wpi:spi_data_rw(?Channel, Words ) of
         {ok,_P}->ok;
               Q->io:format("write is ~p~n",[Q])
      end 
    end,
 First_part),
%timer:apply_after(Time_on, gpio0_server, off,[])
write_5450(Number_of_Iterations-1,Delay,First_part).

%%----------------------------------------------------------------------

%io:format("<<~s>>", [[io_lib:format("~1.2.0B",[X1]) || <<X1:1>> <= P ]]).
%%----------------------------------------------------------------------
print_bits(Bits)->
lists:foreach(fun(Y)->ok,
io:format("<<~s>>", [[io_lib:format("~1.2.0B",[X]) || <<X:1>> <= Y ]]),
             io:format("~p~n",[Y]) 
              end,
            Bits).

%---  gpio_app:test_gpio_on_off(0,1000). --------------------------------------------------------------------


random(Max)->
gpio0_server:on_timed(random:uniform(Max)),
gpio1_server:on_timed(random:uniform(Max)),
gpio2_server:on_timed(random:uniform(Max)),
gpio3_server:on_timed(random:uniform(Max)),
gpio4_server:on_timed(random:uniform(Max)),
gpio5_server:on_timed(random:uniform(Max)),
gpio6_server:on_timed(random:uniform(Max)),
gpio7_server:on_timed(random:uniform(Max)).
%%----------------------------------------------------------------------

test_gpio_on_off(0,Time_on)->
io:format("Pin = ~p Time_on = ~p ",[0,Time_on]),
gpio0_server:on_timed(Time_on).
%%----------------------------------------------------------------------

test_gpio_on(Pin)->
%io:format("Pin = ~p on ",[Pin]),
wpi:pin_mode(Pin,output),
wpi:digital_write(Pin,?HIGH).
%%----------------------------------------------------------------------

test_gpio_off(Pin)->
%io:format("Pin = ~p off ",[Pin]),
wpi:pin_mode(Pin,output),
wpi:digital_write(Pin,?LOW).
%%----------------------------------------------------------------------

%    gpio_app:test_gpio_on(0).
%    gpio_app:test_gpio_off(0).
%    gpio_app:test_gpio_all().

test_gpio_all(_,0)->ok;
test_gpio_all(Delay,Count)->
test_gpio_on(0),
timer:sleep(Delay),
test_gpio_off(0),

test_gpio_on(1),
timer:sleep(Delay),
test_gpio_off(1),

test_gpio_on(2),
timer:sleep(Delay),
test_gpio_off(2),
test_gpio_all(Delay,Count-1).
%%----------------------------------------------------------------------

exercise(_,0)->ok;
exercise(0,_)->ok;
exercise(Delay1,Count)->
gpio0_server:on(),
gpio1_server:on(),
gpio2_server:on(),
timer:sleep(Delay1),
gpio0_server:off(),
gpio1_server:off(),
gpio2_server:off(),

gpio0_server:on(),
timer:sleep(Delay1*2),
gpio0_server:off(),
timer:sleep(Delay1*2),
exercise(Delay1-1,Count-1).
%%----------------------------------------------------------------------

