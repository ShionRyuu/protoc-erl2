%% -------------------------------------------------------------------
%% protoc-erl: a wrapper for erlang-protobuffs
%%
%% Copyright (c) 2015-2016 Shion Ryuu (shionryuu@outlook.com)
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.
%% -------------------------------------------------------------------
-module('protoc-erl').
-author("Ryuu").

%% API
-export([
    main/1,
    generate_all/1
]).

%% @doc escript entry
main([ProtoPath, SrcOutput, IncludeOutput]) ->
    generate_all([ProtoPath, SrcOutput, IncludeOutput]),
    ok;
main(_) ->
    help().

%% @doc help message
help() ->
    io:format("usage:~n"),
    io:format("  ~s proto_path src_path include_path~n", [escript:script_name()]).

%% @doc generate protos
generate_all([ProtoPath, SrcOutput, IncludeOutput]) ->
    [ok = filelib:ensure_dir(Path ++ "/") || Path <- [ProtoPath, SrcOutput, IncludeOutput]],
    Options = [
        {output_include_dir, IncludeOutput},
        {output_src_dir, SrcOutput}
    ],
    AbsPath = filename:absname(ProtoPath),
    ProtoList = filelib:wildcard("*.proto", AbsPath),
    OutList = generate(ProtoList, AbsPath, Options, []),
    generate_pt(OutList, IncludeOutput).

generate([], _ProtoPath, _Options, Acc) ->
    lists:sort(lists:reverse(Acc));
generate([File | Next], ProtoPath, Options, Acc) ->
    FullName = filename:join([ProtoPath, File]),
    case generate_file(FullName, Options) of
        ok ->
            generate(Next, ProtoPath, Options, [File | Acc]);
        {error, Reason} ->
            error_logger:error_msg("failed to generate proto ~w, error ~w", [File, Reason]),
            {error, Reason}
    end.

%% @doc generate single proto file
generate_file(ProtoFile, Options) ->
    protobuffs_compile:scan_file_src(ProtoFile, Options).

%% @doc generate proto header file
generate_pt(OutList, IncludeOutput) ->
    PtName = filename:join(IncludeOutput, "protobuffs.hrl"),
    error_logger:info_msg("Writing header file to ~p\n", [PtName]),
    file:delete(PtName),
    {ok, IoDevice} = file:open(PtName, [write, append]),
    ok = file:write(IoDevice, "-ifndef(__PROTOBUFFS_HRL__).\n"),
    ok = file:write(IoDevice, "-define(__PROTOBUFFS_HRL__, 1).\n\n"),
    [begin
        Basename = filename:basename(File, ".proto"),
        HrlName = Basename ++ "_pb.hrl",
        ok = file:write(IoDevice, "-include(\"" ++ HrlName ++ "\").\n")
    end || File <- OutList],
    ok = file:write(IoDevice, "\n-endif."),
    file:close(IoDevice),
    ok.
