-module(walk_app).

-behaviour(application).

-define(Microseconds, 1000000).
-define(Sublist_size, 5).
-define(Number_of_processes, 60).
-define(Host, "192.168.1.23").
-define(Port, 5984).
%newdb_big_one
-define(Database, "newdb4").
-define(b2l(V), binary_to_list(V)).
-define(l2b(V), list_to_binary(V)).
-define(MaxSize, 10000000000).%10Gb 10 000 000 000
-include_lib("kernel/include/file.hrl").

%% Application callbacks
-export([start/2, stop/1]).

-export([start/0, walk/1,play/2,check/1,version/0,write_ddocs/0]).

%% @doc Diagnostic start with observer

%% @spec start() -> ok
start() ->
    application:start(couchbeam),
    io:format("Starting Walk_app application using "
          "'erl -pa apps/*/ebin -boot start_sasl "
          "-s walk_app' ",
          []),
    application:start(walk_app).

%% ===================================================================
%% Application callbacks
%% ===================================================================

%% @doc normal otp start

start(_StartType, _StartArgs) ->
    error_logger:info_msg("Starting Walk_app application with '/media/15"
              "MiBGP/project_walk/rel/walk_app/bin/walk_app "
              "console' "),
    walk_sup:start_link().

stop(_State) -> ok.
%% @spec () -> Version
%%     Version = string()
%% @doc Return the version of the application.
version() ->
    {ok, Version} = application:get_key(couchbeam, vsn),
    Version.
%-------------------------------------------------------------------------------

handle_user_input(Db1,DesignName,ViewName,CommandBase,TailKey,Limit,Direction)->
    case io:get_chars("do you want to continue Enter|l|z",1) of
    "\n"->io:format("received~p~n",["carriage/ret"]);
    "l"->io:format("changing Limit to 10~p~n",["l"]),
    handle_user_input(Db1,DesignName,ViewName,CommandBase,TailKey,10,Direction);
    "z"->io:format("received~p get next group~n",["z"]),
    fetchData(Db1,DesignName,ViewName,CommandBase,TailKey,Limit,Direction);
        Anny1->io:format("received~p~n",[Anny1])       
    end.
    
handle_batch([],TailKey,Limit,Direction,Db1,DesignName,ViewName,CommandBase)->
io:format("handle_batch end of data~n",[]),
fetchData(Db1,DesignName,ViewName,CommandBase,TailKey,Limit,Direction);



handle_batch([Head|Rest],TailKey,Limit,Direction,Db1,DesignName,ViewName,CommandBase)->
%io:format("handle_batch Head, ~p~n Rest ~p~n",[Head,Rest]),
{[{<<"id">>,_},
               {<<"key">>,[FullFilePath,MimeInfo,FileSize]},
               {<<"value">>,_}]} = Head,
    io:format("~p ~p ~p~n",[?b2l(FullFilePath),?b2l(MimeInfo),FileSize]),
    FullFilePathL = ?b2l(FullFilePath),

     handle_user_input(Db1,DesignName,ViewName,CommandBase,TailKey,Limit,Direction),
 
     Command = CommandBase ++ "'" ++ FullFilePathL ++"'" ++ "&", 
     io:format("Command is ~p~n",[Command]),
       if 
         FileSize > 0 -> 
         case eunit_lib:command(Command) of
               {0, Result} ->
      io:format("Command processed successfully~n "
            "~p Result = ~p~n",
            [Command, Result]);
      Any5 -> io:format("Command gave errors   ~p", [Any5])
         end;
         true -> io:format("filesize ~p ZERO ~n",[FullFilePath])
       end, 

handle_batch(Rest,TailKey,Limit,Direction,Db1,DesignName,ViewName,CommandBase).

%% @doc get first result of a view
%%  <pre>parameter can be images | sounds | videos</pre>
%%  <p>Db: a db record</p>
%%  <p>ViewName: 'all_docs' to get all docs or {DesignName,
%%  ViewName}</p>
%%  <pre>Options :: view_options() [{key, binary()} | {start_docid, binary()}
%%    | {end_docid, binary()} | {start_key, binary()}
%%    | {end_key, binary()} | {limit, integer()}
%%    | {stale, stale()}
%%    | descending
%%    | {skip, integer()}
%%    | group | {group_level, integer()}
%%    | {inclusive_end, boolean()} | {reduce, boolean()} | reduce | include_docs | conflicts
%%    | {keys, list(binary())}</pre>
%% <p>See {@link couchbeam_view:stream/4} for more information about
%% options.</p>
%% <p>Return: {ok, Row} or {error, Error}</p>


play(Parameter, Direction)->
    % setup logfile
    {ok, Clog} = setup_logfile("../Wlog.txt"),
    %setup database
    Db1 = setup_couchdb_database(?Database, Clog),



    case Parameter of
       video->DesignName="2",ViewName="video_full_path",CommandBase="mplayer ";
        image->DesignName="3",ViewName="images",         CommandBase="eog ";
        sound->DesignName="4", ViewName="sound",          CommandBase="play ";
        pdf->DesignName="5",   ViewName="pdf",            CommandBase="evince ";
    opendoc->DesignName="6",ViewName="opendocument_text",CommandBase="soffice ";
        iso->DesignName="7",ViewName="iso_image",CommandBase="nautilus ";
        _Other->DesignName=ViewName=CommandBase=""
    end,
    io:format("Parameter is ~p~nDesignName~p~nViewName ~p~nDirection ~p~n", 
               [Parameter,DesignName,ViewName,Direction]),
               Limit=50,
               
               case  Direction of
                   down -> Options = [descending];
                   _Any ->                    Options = []
               end,
     
              case  couchbeam_view:first(Db1,{DesignName,ViewName},Options) of
                  {ok,{[{<<"id">>,_},{<<"key">>,Key},{<<"value">>,_}]}} ->
                      io:format("couchbeam_view:first~p~n",[Key]);
                  Other->Key=[],io:format("couchbeam_view:first~p~n",[Other])
              end,

    fetchData(Db1,DesignName,ViewName,CommandBase,Key,Limit,Direction). 

%-------------------------------------------------------------------------------
fetchData(_Db1,_DesignName,_ViewName,_CommandBase,[],_Limit,_Direction)->
io:format("end of data~n",[]);

fetchData(Db1,DesignName,ViewName,CommandBase,Key,Limit,Direction)-> 
io:format("fetchData~n",[]),
               case  Direction of
               down -> Options = [{limit, Limit},{startkey, Key},descending];
               _Any ->        Options = [{limit, Limit},{startkey, Key}]
               end,
               
     case couchbeam_view:fetch
     (Db1,{DesignName,ViewName},Options) of
         {ok,Rows}->ok;
         {error, Error}->Rows=[],io:format("in play Error~p~n",[Error]);
         Any1->Rows=[],io:format("in play - no such view? ~p~n",[Any1])
     end,
     LenR = length(Rows),
     
     if 
         LenR > 1  -> {Body,Tail} = lists:split(length(Rows)-1,Rows);
         LenR == 1 -> Body=Rows, Tail=[];
         LenR < 1 -> Body=Tail=[]
     end,
     %tail of tails can be []
      case Tail of
           [{[{<<"id">>,_},{<<"key">>,TailKey},{<<"value">>,_}]}]->ok;
           []->io:format("tail of tails can be []~n",[]),TailKey=[];
           Any09->io:format("tail of tails can be [] but weird here~p~n",[Any09]),TailKey=[]
     end,
     handle_batch(Body,TailKey,Limit,Direction,Db1,DesignName,ViewName,CommandBase),

fetchData(Db1,DesignName,ViewName,CommandBase,TailKey,Limit,Direction).


%

%-------------------------------------------------------------------------------

walk_check_common(F)->
    % setup logfile
    {ok, Clog} = setup_logfile("../Wlog.txt"),
    %setup database
    Db1 = setup_couchdb_database(?Database, Clog),
    % load mimetypes file and produce list
    case
      httpd_conf:load_mime_types("/media/15MiBGP/project_walk/mime.types")
    of
      {ok, MimeTypes} -> ok;
      {error, Reason1} ->
      io:format("error ~p~n", [Reason1]), MimeTypes = []
    end,
    % form ets of mimetypes by file extension
    Mime_ets = ets:new(mime_ets,
               [ordered_set, public, {write_concurrency, true}]),
    lists:foreach(fun (E) -> ets:insert(Mime_ets, E) end,
          MimeTypes),
    % setup ets1 for processed file list
    Working_ets = ets:new(working_ets,
              [duplicate_bag, public, {write_concurrency, true}]),

    TZero1 = now(),
    counter_server:reset_to(0),
    
    try parallelFileTreeWalk(F, Clog, Mime_ets, Db1, Working_ets) of 
    _->ok
     catch
     error:Error->io:format("Error~p~n", [Error])
     end,


    
    {Clog,Db1,TZero1,Working_ets}.
    
%-------------------------------------------------------------------------------
write_ddocs()-> %design doc to index in filename order
    % setup logfile
    {ok, Clog} = setup_logfile("../Wlog.txt"),
Db1 = setup_couchdb_database(?Database, Clog),
DesignDoc = {[
        {<<"_id">>, <<"_design/byfilename">>},
        {<<"language">>,<<"javascript">>},
        {<<"views">>,
            {[{<<"filename">>,
                {[
                {<<"map">>,
                    <<"function (doc) {\n emit(doc.filename, 1);\n}">>
                },
                {<<"reduce">>,
                    <<"function (keys,values,rereduce) {\n  return sum(values);\n}">>
                }
                ]}
            }]}
        }
    ]},
 case couchbeam:save_doc(Db1, DesignDoc) of
     {ok, DesignDoc1}->ok;
     {error,conflict}->
         io:format("conflict error~p~n", [DesignDoc]),DesignDoc1=DesignDoc;
     Any->io:format("error~p~n", [Any]),DesignDoc1=DesignDoc
 end,
io:format("DesignDoc1~p~n", [DesignDoc1]).
%-------------------------------------------------------------------------------
check(F)->
{Clog,Db1,TZero1,Working_ets} = walk_check_common(F),
%The_file_list = ets:tab2list(Working_ets),
io:format("check parameters F~p~n,Clog,~p~nDb1,~p~nTZero1,~p~nWorking_ets~p~n", [F,Clog,Db1,TZero1,Working_ets]),


    {Count, Tab} = counter_server:add({0, ""}),
    
    %ets:i(Working_ets),
    %ets:i(),
    
   
    {Matched,Unmatched}=ets:foldr(fun(X1,{Acc0,Acc1})->
     {[{<<"file_name">>,Filename},{<<"filesize">>,Filesize},
       {<<"full_file_path">>,Full_file_path},{<<"mimetype">>,Mimetype},
       {<<"mode_bits">>,Mode_bits},{<<"links">>,Links},
       {<<"major_dev">>,Major_dev},{<<"minor_dev">>,Minor_dev},
       {<<"inode">>,Inode},{<<"user_id">>,User_id},
       {<<"group_id">>,Group_id},{<<"access_time">>,Access_time},
       {<<"mod_time">>,Mod_time},
       {<<"change_or_create_time">>,Change_or_create_time},
       {<<"file_access">>,File_access},{<<"file_type">>,File_type}]}=X1,
       % ,[{limit, 100},{startkey, ""}]
       
         case couchbeam_view:fetch
     (Db1,{"byfilename","filename"},[{limit, 500},{startkey, Filename},{endkey, Filename},{reduce,false}]) of
         {ok,Rows}->ok;
         {error, Error}->Rows=[],io:format("in play Error~p~n",[Error]);
         Any1->Rows=[],io:format("in play - no such view? ~p~n",[Any1])
     end,
     
     io:format("length Rows = ~p ~p~n ",[length(Rows),Filename]),
     
    Filedetails = {Filename, Filesize, Full_file_path, Mimetype, Mode_bits, 
Links, Major_dev, Minor_dev, Inode, User_id, Group_id, Access_time, 
Mod_time, Change_or_create_time, File_access, File_type},

      process_rows(Rows,Db1,Clog,Acc0,Acc1,Filedetails)

    end,{0,0},Working_ets),
    
    Elapsed = timer:now_diff(now(), TZero1) /
        (?Microseconds),
    io:format("walk took  = ~p seconds~n~p files~n~p "
          "files per second~nMatched=~p~nUnmatched=~p~n",
          [Elapsed, Count, Count / Elapsed,Matched,Unmatched]),
          print_question(Tab,Working_ets).
%-------------------------------------------------------------------------------
process_rows([],_Db1,_Clog,Acc0,Acc1,Filedetails)->
    io:format("~p ~p noMatch []  ~p ~n~n",[Acc0,Acc1,Filedetails]),
    {Acc0, Acc1+1};

process_rows([HeadOfRows|Rows],Db1,Clog,Acc0,Acc1,Filedetails)->

{Filename, Filesize, Full_file_path, Mimetype, Mode_bits, 
Links, Major_dev, Minor_dev, Inode, User_id, Group_id, _Access_time, 
Mod_time, Change_or_create_time, File_access, File_type} = Filedetails,

     
     {[{<<"id">>,Id},{<<"key">>,_Key},{<<"value">>,_Val}]} = HeadOfRows,

     
     case couchbeam:open_doc(Db1, Id) of
 {ok,{
   [{<<"_id">>,_Ida},
          {<<"_rev">>,_Reva},
          {<<"file_name">>,Filenamea},
          {<<"filesize">>,Filesizea},
          {<<"full_file_path">>,Full_file_patha},
          {<<"mimetype">>,Mimetypea},
          {<<"mode_bits">>,Mode_bitsa},
          {<<"links">>,Linksa},
          {<<"major_dev">>,Major_deva},
          {<<"minor_dev">>,Minor_deva},
          {<<"inode">>,Inodea},
          {<<"user_id">>,User_ida},
          {<<"group_id">>,Group_ida},
          {<<"access_time">>,_Access_timea},
          {<<"mod_time">>,Mod_timea},
          {<<"change_or_create_time">>,Change_or_create_timea},
          {<<"file_access">>,File_accessa},
          {<<"file_type">>,File_typea}
          ]
          }}->ok;
  Any2->Filenamea = Filesizea = Full_file_patha = Mimetypea = Mode_bitsa = 
Linksa = Major_deva = Minor_deva = Inodea = User_ida = Group_ida = _Access_timea = 
Mod_timea = Change_or_create_timea = File_accessa = File_typea = [],io:format("any1 ~p~n",[Any2])
     end,
     
         if (Filename == Filenamea) ->F1=true;
            true->F1=false%,io:format(Clog,"noMatch ~p =/= ~p~n",[Filename,Filenamea])
         end,
         if (Filesize == Filesizea) ->F2=true;
            true->F2=false%, io:format(Clog,"noMatch ~p =/= ~p~n",[Filesize,Filesizea])
         end,
         if (Full_file_path == Full_file_patha) ->_F3=true;
            true->_F3=false%, io:format(Clog,"noMatch ~p =/= ~p~n",[Full_file_path,Full_file_patha])
         end,
         if (Mimetype == Mimetypea) ->F4=true;
            true->F4=false%, io:format(Clog,"noMatch ~p =/= ~p~n",[Mimetype,Mimetypea])
         end,
         if (Mode_bits == Mode_bitsa) ->F5=true;
            true->F5=false%, io:format(Clog,"noMatch ~p =/= ~p~n",[Mode_bits,Mode_bitsa])
         end,
         if (Links == Linksa) ->F6=true;
            true->F6=false%, io:format(Clog,"noMatch ~p =/= ~p~n",[Links,Linksa])
         end,
         if (Major_dev == Major_deva) ->F7=true;
            true->F7=false%, io:format(Clog,"noMatch ~p =/= ~p~n",[Major_dev,Major_deva])
         end,
         if (Minor_dev == Minor_deva) ->F8=true;
            true->F8=false%, io:format(Clog,"noMatch ~p =/= ~p~n",[Minor_dev,Minor_deva])
         end,
         if (Inode == Inodea) ->F9=true;
            true-> F9=false%,io:format(Clog,"noMatch ~p =/= ~p~n",[Inode,Inodea])
         end,
         if (User_id == User_ida) ->F10=true;
            true-> F10=false%,io:format(Clog,"noMatch ~p =/= ~p~n",[User_id,User_ida])
         end,
         if (Group_id == Group_ida) ->F11=true;
            true-> F11=false%,io:format(Clog,"noMatch ~p =/= ~p~n",[Group_id,Group_ida])
         end,
 %        if (Access_time == Access_timea) ->F12=true;
 %           true->F12=false, io:format(Clog,"noMatch ~p =/= ~p~n",[Access_time,Access_timea])
 %        end,
         if (Mod_time == Mod_timea) ->F13=true;
            true->F13=false%, io:format(Clog,"noMatch ~p =/= ~p~n",[Mod_time,Mod_timea])
         end,
         if (Change_or_create_time == Change_or_create_timea) ->F14=true;
            true->F14=false%, io:format(Clog,"noMatch ~p =/= ~p~n",[Change_or_create_time,Change_or_create_timea])
         end,
         if (File_access == File_accessa) ->F15=true;
            true->F15=false%, io:format(Clog,"noMatch ~p =/= ~p~n",[File_access,File_accessa])
         end,
         if (File_type == File_typea) ->F16=true;
            true->F16=false%, io:format(Clog,"noMatch ~p =/= ~p~n",[File_type,File_typea])
         end,


if (F1 and 
    F2 and 
%    F3 and  %Full_file_path
    F4 and  
    F5 and  
    F6 and  
    F7 and  
    F8 and  
    F9 and  
    F10 and  
    F11 and  
% F12 and   %Access_time
    F13 and  
    F14 and  
    F15 and  
    F16 )-> io:format("~p ~p Match  ~p == ~p~n",[Acc0,Acc1,Full_file_path,Full_file_patha]),
           {Acc0+1, Acc1};
    true->%io:format("~p ~p noMatch detail above  ~p =/= ~p~n~n",[Acc0,Acc1,Full_file_path,Full_file_patha]),
           process_rows(Rows,Db1,Clog,Acc0,Acc1+1,Filedetails)
    end.
%-------------------------------------------------------------------------------
walk(F) ->
{Clog,Db1,TZero1,Working_ets} = walk_check_common(F),
The_file_list = ets:tab2list(Working_ets),
    _Resp = batchSend(Clog, Db1, 10000, The_file_list),
    % io:format(Clog,"Response~p~n", [Resp]),

    {Count, Tab} = counter_server:add({0, ""}),
    Elapsed = timer:now_diff(now(), TZero1) /
        (?Microseconds),
    io:format("walk took  = ~p seconds~n~p files~n~p "
          "files per second~n",
          [Elapsed, Count, Count / Elapsed]),
          print_question(Tab,Working_ets).
%-------------------------------------------------------------------------------
print_question(Tab,Working_ets)->
    {ok, [X]} =
    io:fread("do you want to print out ets? y/n: ", "~s"),
    if X == "y" ->
       ets:foldl(fun (X2, _Dontcare) ->
                 {A} = X2, io:format("~p~n", [A])
             end,
             [], Tab),
       ets:foldl(fun (X1, _Dontcare1) ->
                 {A1} = X1, io:format("~p~n", [A1])
             end,
             [], Working_ets);
       X == "n" -> ok;
       true -> io:format("you typed ~p not a 'y' or a 'n' ~n",[X]),
       print_question(Tab,Working_ets)
    end.
%-------------------------------------------------------------------------------
batchSend(Clog, Db1, Quantity, L) ->
    batchSend(Clog, Db1, Quantity, L, []).

batchSend(Clog, Db1, Quantity, List, R) when length(List) >= Quantity ->
    case lists:split(Quantity, List) of
      {List1, List2} ->
      Response = couchbeam:save_docs(Db1, List1),
      io:format("Response next ~p~n", [Quantity]),
      {ok, Response1} = Response,
      batchSend(Clog, Db1, Quantity, List2, Response1 ++ R);
      Any -> io:format(Clog, "error here~p~n", [Any])
    end;
batchSend(_Clog, Db1, Quantity, List, R) when length(List) < Quantity ->
    Response = couchbeam:save_docs(Db1, List),
    {ok, Response1} = Response,
    Response1 ++
      R.
%-------------------------------------------------------------------------------
setup_logfile(Logfile) ->
    case file:open(Logfile, [write, {encoding, utf8}]) of
      {ok, Clog} ->
      io:format("setup_logfile file:open ~p ok ~p~n",
            [Logfile, Clog]),
      {ok, Clog};
      Any1 ->
      io:format("setup_logfile file:open ~p failed ~p~n",
            [Logfile, Any1]),
      {error, []}
    end.

%-------------------------------------------------------------------------------
setup_couchdb_database(Db, Clog) ->
    io:format(Clog, "in my module ~p, ", [?MODULE]),
    %%create a connection to a server machine:
    (?Host) = "192.168.1.23",
    (?Port) = 5984,
    Prefix = "",
    UserName = "david",
    Password = "occam123",
    Options = [{basic_auth, {UserName, Password}}],
    S1 = couchbeam:server_connection(?Host, ?Port, Prefix,
                     Options),
    Any = couchbeam:server_info(S1),
    io:format(Clog,
          "couchbeam:server_info = ~n~p~n couchbeam:vers"
          "ion = ~p db= ~p~n",
          [Any, couchbeam:version(), Db]),
    case couchbeam:open_or_create_db(S1, Db, Options) of
      {ok, Db1} -> io:format(Clog, "Db1=~p~n", [Db1]), Db1;
      {error, {conn_failed, {error, econnrefused}}} ->
      io:format(Clog, "error ~p~n",
            [{conn_failed, {error, econnrefused}}]),
      [];
      Any -> io:format(Clog, "Any=~p~n", [Any]), []
    end.

%-------------------------------------------------------------------------------

iso_8601_fmt(DateTime) ->
    {{Year, Month, Day}, {Hour, Min, Sec}} = DateTime,
    io_lib:format("~4.10.0B-~2.10.0B-~2.10.0B ~2.10.0B:~2.10.0B:"
          "~2.10.0B",
          [Year, Month, Day, Hour, Min, Sec]).

%-------------------------------------------------------------------------------
%industrial strength parallelFileTreeWalk
parallelFileTreeWalk(F, Clog, Mime_ets, Db1,Working_ets) ->
    case file:read_link_info(F) of
      {ok,
       #file_info{type = regular, gid = Gid, inode = Inode,
          links = Links, major_device = Major_device,
          minor_device = Minor_device, mode = Mode, size = Size,
          uid = Uid} =
       FileInfo} ->
      {Filename, Ext} = prepare_doc(F, FileInfo),
      {_Count, _Tab} = counter_server:add({1, F}),
      % lookup extension in ets  to get mimetype
      case ets:lookup(Mime_ets, Ext) of
        [] -> % use shell command to get mimetype (inefficient)
        Command = "mimetype -b -M " ++ "\"" ++ F ++ "\"",
        case eunit_lib:command(Command) of
          {0, Mimetype} -> % mimetype is in ets lookup
              % io:format(Clog, "no ext in ets lookup ~p ~p~n",
              %                     [Ext, string:strip(Mimetype, right, $\n)]),
              % write tuple of info
              {F, string:strip(Mimetype, right, $\n), FileInfo};
          Error1 -> % error in ets lookup
              Mimetype = "error_in_mimetype_lookup",
              io:format(Clog,
                "error_in_mimetype_lookup = ~p Command "
                "= ~p~n",
                [Error1, Command]),
              % write tuple of info
              {F, Mimetype, FileInfo}
        end;
        [{Ext, Mimetype}] -> % write tuple of info
        {F, Mimetype, FileInfo};
        Anny ->
        Mimetype = "",
        io:format("any***********~p~n", [Anny]),
        {F, [], FileInfo}
      end,
      % check if file too big
      if Size < ?MaxSize -> ok;
         true -> io:format("file ~p too big, ~p~n", [F, Size])
      end,
      %Set up initial document for db
      %io:format("utc_random() = ~p~n",   [utc_random()]),
      FileNameb = (?l2b(Filename)),
      Fb = (?l2b(F)),
      Mimetypes = string:strip(Mimetype, right, $\n),
      Doc = {[{<<"file_name">>, FileNameb},
          {<<"filesize">>, Size}, {<<"full_file_path">>, Fb},
          {<<"mimetype">>, ?l2b(Mimetypes)},
          {<<"mode_bits">>, Mode}, {<<"links">>, Links},
          {<<"major_dev">>, Major_device},
          {<<"minor_dev">>, Minor_device}, {<<"inode">>, Inode},
          {<<"user_id">>, Uid}, {<<"group_id">>, Gid},
          {<<"access_time">>,
           ?l2b((lists:flatten(iso_8601_fmt(FileInfo#file_info.atime))))},
          {<<"mod_time">>,
           ?l2b((lists:flatten(iso_8601_fmt(FileInfo#file_info.mtime))))},
          {<<"change_or_create_time">>,
           ?l2b((lists:flatten(iso_8601_fmt(FileInfo#file_info.ctime))))},
          {<<"file_access">>,
           ?l2b((atom_to_list(FileInfo#file_info.access)))},
          {<<"file_type">>,
           ?l2b((atom_to_list(FileInfo#file_info.type)))}]},
      % put file data in Working_ets for processing outside this process
      ets:insert(Working_ets, Doc);
      %------------------------------------------
      {error, eacces} ->
      ok, io:format("eacces error here yay eacces ~p~n", [F]);
      {error, eisdir} ->
      io:format("eisdir error here eisdir ~p~n", [F]);
      {error, eloop} ->
      ok, io:format("eloop error here yay loop ~p~n", [F]);
      {error, enoent} ->
      ok, io:format("enoent error here yay enoent ~p~n", [F]);
      {error, einval} ->
      ok, io:format("einval error here yay enoent ~p~n", [F]);
      {error, eio} ->
      ok, io:format("eio error here yay enoent ~p~n", [F]);
      {ok, #file_info{type = undefined}} ->
      io:format("file ~p is undefined~n", [F]);
      {ok, #file_info{type = device}} ->
      ok, io:format("file ~p is device~n", [F]);
      {ok, #file_info{type = other}} ->
      ok, io:format("file ~p is other~n", [F]);
      {ok, #file_info{type = symlink}} -> ok;
      %        io:format("file ~p is symlink~n", [F]);
      %-------------------------------------------------
      {ok, #file_info{type = directory}} ->
      % io:format("file ~p is directory~n",[F]),
      case re:run(F,
              %        "/\.gvfs/david-amdx2 on otperlcouchdbclo|"
              %         "/\.gvfs/david on 330x86-64|"
              %         "/\.gvfs/david on archx6|"
              "/.gvfs/david on bulldozer1",
              %.gvfs points to other machines
              %        "\.gvfs",
              [{capture, none}])
          of
        match -> ok;  % do not process it is not required
        nomatch ->   % process this directory it is ok!
        case file:list_dir(F) of
          {ok, Filenames} ->
              plists:foreach(fun (X) ->
                         if F == "/" ->
                            parallelFileTreeWalk(F ++ X,
                                     Clog,
                                     Mime_ets,
                                     Db1,
                                     Working_ets);
                        true ->
                            parallelFileTreeWalk(F ++
                                       "/"
                                         ++
                                         X,
                                     Clog,
                                     Mime_ets,
                                     Db1,
                                     Working_ets)
                         end
                     end,
                     %if
                     %fun
                     Filenames,
                     [?Sublist_size,
                      {processes, ?Number_of_processes}]);
          {error, eacces} -> ok;
          %             io:format("error list_dir with reason  ~p~n", [Reason])
          {error, Reason} ->
              io:format("error list_dir with reason  ~p~n", [Reason])
        end
      end;
      %file:list_dir
      %re
      %-------------------------------------
      Any ->
      io:format("Error ~p in ~p~n",
            [Any, F])%-------------------------------------
    end.

        %file:read_link_info
%-------------------------------------------------------------------------------
prepare_doc(F, _FileInfo) ->
    % get file name and extension
    Split = re:split(F, "/", [{return, list}, trim]),
    if Split =/= [] -> FileName = lists:last(Split);
       true -> FileName = "/"
    end,
    Ext = lists:last(re:split(FileName, "[.]",
                  [{return, list}, trim])),
    {FileName, Ext}.
