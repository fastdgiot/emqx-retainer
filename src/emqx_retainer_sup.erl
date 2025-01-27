%%--------------------------------------------------------------------
%% Copyright (c) 2020-2022 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emqx_retainer_sup).

-behaviour(supervisor).

-export([start_link/1]).

-export([init/1]).

start_link(Env) ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, [Env]).

init([Env]) ->
	{ok, {{one_for_one, 10, 3600},
          [#{id       => retainer,
             start    => {emqx_retainer, start_link, [Env]},
             restart  => permanent,
             shutdown => 5000,
             type     => worker,
             modules  => [emqx_retainer]} || not is_managed_by_modules()]}}.

-ifdef(EMQX_ENTERPRISE).

is_managed_by_modules() ->
    try
        case supervisor:get_childspec(emqx_modules_sup, emqx_retainer) of
            {ok, _} -> true;
            _ -> false
        end
    catch
        exit : {noproc, _} ->
            false
    end.

-else.

is_managed_by_modules() ->
    %% always false for opensource edition
    false.

-endif.
