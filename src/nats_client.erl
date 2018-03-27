%%%-------------------------------------------------------------------
%%% File        : enats_client.erl
%%% Author      : Matthew Brace <ismarc31@gmail.com>
%%% Description : Module for providing NATS pub/sub functionality as 
%%%               a client in erlang
%%% Created     : May 02, 2011
%%%-------------------------------------------------------------------
-module(nats_client).

-behaviour(gen_server).

-define(SERVER, ?MODULE).

%% API
-export([start_link/0, connect/2, disconnect/0, publish/2]).

%% gen_server callbacks
-export([init/1]).

-record(state, {subscriptions=[], user=undefined, pass=undefined, 
                pending_requests=[], sid=1}).

%%====================================================================
%% API
%%====================================================================
%%--------------------------------------------------------------------
%% Function: start_link() -> {ok, Pid} | ignore | {error, Error}
%% Description: Starts the server
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%--------------------------------------------------------------------
%% Function: connect({Address, Port}, {Username, Password}) -> none
%% Description: Establishes a connection to the specified server/port 
%%              and authenticates with the supplied username/password
%%              if authentication is requested from the server.
%%--------------------------------------------------------------------
connect({Address, Port}, {Username, Password}) ->
    gen_server:cast(?SERVER, {connect, {Address, Port}, 
                              {Username, Password}}).
%%--------------------------------------------------------------------
%% Function: disconnect() -> none
%% Description: Disconnect from the server
%%--------------------------------------------------------------------
disconnect() ->
    gen_server:cast(?SERVER, {disconnect}).

%%--------------------------------------------------------------------
%% Function: publish(Subject, Message) -> none
%% Description: Publishes a message to the server with the supplied 
%%              subject and message.
%%--------------------------------------------------------------------
publish(Subject, Message) ->
    gen_server:cast(?SERVER, {publish, Subject, Message}).

%%====================================================================
%% gen_server callbacks
%%====================================================================
%%--------------------------------------------------------------------
%% Function: init(Config) -> {ok, State}
%% Description: Initializes the configuration to be used and passed in
%%              callbacks.
%%--------------------------------------------------------------------
init(_Config) ->
    enats_raw_connection:start_link(fun receive_message/1),
    {ok, #state{}}.