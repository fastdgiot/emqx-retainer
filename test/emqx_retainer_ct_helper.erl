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
-module(emqx_retainer_ct_helper).


%% API
-export([ensure_start/0, ensure_stop/0]).
-ifdef(EMQX_ENTERPRISE).
ensure_start() ->
    %% for enterprise edition, retainer is started by modules
    application:stop(emqx_modules),
    ensure_stop(),
    init_conf(),
    emqx_ct_helpers:start_apps([emqx_retainer]),
    ok.

-else.

ensure_start() ->
    init_conf(),
    ensure_stop(),
    emqx_ct_helpers:start_apps([emqx_retainer]),
    ok.

-endif.

ensure_stop() ->
    emqx_ct_helpers:stop_apps([emqx_retainer]).


init_conf() ->
    application:set_env(emqx_retainer, expiry_interval, 0),
    application:set_env(emqx_retainer, max_payload_size, 1024000),
    application:set_env(emqx_retainer, max_retained_messages, 0),
    application:set_env(emqx_retainer, storage_type, ram),
    ok.
