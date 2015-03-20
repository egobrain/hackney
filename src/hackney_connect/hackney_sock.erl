-module(hackney_sock).

-export([messages/1,
         connect/4, connect/5,
         recv/3, recv/2,
         send/2,
         setopts/2,
         controlling_process/2,
         peername/1,
         close/1,
         shutdown/2,
         sockname/1]).

-include("hackney_sock.hrl").

-type hackney_sock() :: #hackney_sock{}.
-type sock_messages() :: {atom(), atom(), atom()}.

-export_type([hackney_sock/0,
              sock_messages/0]).


%% @doc Atoms used to identify messages in {active, once | true} mode.
-spec messages(hackney_sock()) -> sock_messages().
messages(#hackney_sock{transport=Transport, sock=Sock}) ->
    Transport:messages(Sock).

%% @doc connect to a Port using a specific transport.
-spec connect(atom(), list(), non_neg_integer(), list()) ->
    {ok, hackney_sock()}
    | {error, term()}.
connect(Transport, Host, Port, Opts) ->
    connect(Transport, Host, Port, Opts, infinity).

-spec connect(atom(), list(), non_neg_integer(), list(), timeout()) ->
    {ok, hackney_sock()}
    | {error, term()}.
connect(Transport, Host, Port, Opts, Timeout) ->
    case Transport:connect(Host, Port, Opts, Timeout) of
        {ok, Sock} ->
            {ok, #hackney_sock{transport=Transport,
                               sock=Sock}};
        Error ->
            Error
    end.

-spec recv(hackney_sock(), non_neg_integer()) ->
    {ok, any()} | {error, closed | atom()}.
recv(HS, Length) ->
    recv(HS, Length, infinity).

%% @doc Receive a packet from a socket in passive mode.
-spec recv(hackney_sock(), non_neg_integer(), timeout()) ->
    {ok, any()} | {error, closed | atom()}.
recv(#hackney_sock{transport=T, sock=S}, Length, Timeout) ->
    T:recv(S, Length, Timeout).

%% @doc Send a packet on a socket.
-spec send(hackney_sock(), iolist()) -> ok | {error, atom()}.
send(#hackney_sock{transport=T, sock=S}, Packet) ->
    T:send(S, Packet).

%% @doc Set one or more options for a socket.
%% @see inet:setopts/2
-spec setopts(hackney_sock(), list()) -> ok | {error, atom()}.
setopts(#hackney_sock{transport=T, sock=S}, Opts) ->
    T:setopts(S, Opts).

%% @doc Assign a new controlling process <em>Pid</em> to <em>Socket</em>.
-spec controlling_process(hackney_sock(), pid())
	-> ok | {error, closed | not_owner | atom()}.
controlling_process(#hackney_sock{transport=T, sock=S}, Pid) ->
	T:controlling_process(S, Pid).

%% @doc Return the address and port for the other end of a connection.
-spec peername(hackney_sock())
	-> {ok, {inet:ip_address(), inet:port_number()}} | {error, atom()}.
peername(#hackney_sock{transport=T, sock=S}) ->
	T:peername(S).

%% @doc Close a TCP socket.
-spec close(hackney_sock()) -> ok.
close(#hackney_sock{transport=T, sock=S}) ->
    T:close(S).

%% @doc Immediately close a socket in one or two directions.
-spec shutdown(hackney_sock(), read | write | read_write) -> ok.
shutdown(#hackney_sock{transport=T, sock=S}, How) ->
    T:shutdown(S, How).

%% @doc Get the local address and port of a socket
-spec sockname(hackney_sock())
	-> {ok, {inet:ip_address(), inet:port_number()}} | {error, atom()}.
sockname(#hackney_sock{transport=T, sock=S}) ->
    T:sockname(S).
