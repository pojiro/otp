%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2004-2023. All Rights Reserved.
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
%%
%% %CopyrightEnd%
%%

-module(ct_hooks).

%% API Exports
-export([init/1]).
-export([groups/2]).
-export([all/2]).
-export([init_tc/3]).
-export([end_tc/5]).
-export([terminate/1]).
-export([on_tc_skip/2]).
-export([on_tc_fail/2]).

%% If you change this, remember to update ct_util:look -> stop clause as well.
-define(hooks_name, ct_hooks).
-define(hooks_order_name, ct_hooks_order).

%% All of the hooks which are to be started by default. Remove by issuing
%% -enable_builtin_hooks false to when starting common test.
-define(BUILTIN_HOOKS,[#ct_hook_config{ module = cth_log_redirect,
					opts = [],
					prio = ctfirst }]).

-record(ct_hook_config, {id, module, prio, scope, opts = [],
                         state = [], groups = []}).

%% -------------------------------------------------------------------------
%% Callbacks
%% -------------------------------------------------------------------------
-callback id(Opts) -> Id when Opts :: term(), Id :: term().

-callback init(Id, Opts) -> {ok, State} | {ok, State, Priority} when
      Id :: reference() | term(),
      Opts :: term(),
      State :: term(),
      Priority :: integer().

-callback on_tc_skip(SuiteName, TestName, Reason, CTHState) -> NewCTHState when
      SuiteName :: atom(),
      TestName :: init_per_suite | end_per_suite |
                  {init_per_group, GroupName} |
                  {end_per_group, GroupName} |
                  {FuncName, GroupName} |
                  FuncName,
      FuncName :: atom(),
      GroupName :: atom(),
      Reason :: {tc_auto_skip | tc_user_skip, term()},
      CTHState :: term(),
      NewCTHState :: term().

-callback on_tc_fail(SuiteName, TestName, Reason, CTHState) -> NewCTHState when
      SuiteName :: atom(),
      TestName :: init_per_suite | end_per_suite |
                  {init_per_group, GroupName} |
                  {end_per_group, GroupName} |
                  {FuncName, GroupName} |
                  FuncName,
      FuncName :: atom(),
      GroupName :: atom(),
      Reason :: term(),
      CTHState :: term(),
      NewCTHState :: term().

-callback post_end_per_suite(SuiteName, Config, Return, CTHState) -> Result when
      SuiteName :: atom(),
      Config :: [{Key,Value}],
      Return :: Config | SkipOrFail | term(),
      NewReturn :: Config | SkipOrFail | term(),
      SkipOrFail :: {fail,Reason} | {skip, Reason},
      CTHState :: term(),
      NewCTHState :: term(),
      Result :: {NewReturn, NewCTHState},
      Key :: atom(),
      Value :: term(),
      Reason :: term().

-callback pre_end_per_suite(SuiteName, EndData, CTHState) -> Result when
      SuiteName :: atom(),
      EndData :: Config | SkipOrFail,
      Config :: [{Key, Value}],
      NewConfig :: [{Key, Value}],
      CTHState :: term(),
      NewCTHState :: term(),
      Result :: {NewConfig | SkipOrFail,
                 NewCTHState},
      SkipOrFail :: {fail, Reason} | {skip, Reason},
      Key :: atom(),
      Value :: term(),
      Reason :: term().

-callback post_end_per_group(SuiteName, GroupName, Config, Return, CTHState) -> Result when
      SuiteName :: atom(),
      GroupName :: atom(),
      Config :: [{Key, Value}],
      Return :: Config | SkipOrFail | term(),
      NewReturn :: Config | SkipOrFail | term(),
      SkipOrFail :: {fail, Reason} | {skip, Reason},
      CTHState :: term(),
      NewCTHState :: term(),
      Result :: {NewReturn, NewCTHState},
      Key :: atom(),
      Value :: term(),
      Reason :: term().

-callback pre_end_per_group(SuiteName, GroupName, EndData, CTHState) -> Result when
      SuiteName :: atom(),
      GroupName :: atom(),
      EndData :: Config | SkipOrFail,
      Config :: [{Key, Value}],
      NewConfig :: [{Key, Value}],
      CTHState :: term(),
      NewCTHState :: term(),
      Result :: {NewConfig | SkipOrFail, NewCTHState},
      SkipOrFail :: {fail, Reason} | {skip, Reason},
      Key :: atom(),
      Value :: term(),
      Reason :: term().

-callback post_end_per_testcase(SuiteName, TestcaseName, Config, Return, CTHState) -> Result when
      SuiteName :: atom(),
      TestcaseName :: atom(),
      Config :: [{Key, Value}],
      Return :: Config | SkipOrFail | term(),
      NewReturn :: Config | SkipOrFail | term(),
      SkipOrFail :: {fail, Reason} |
                    {skip, Reason},
      CTHState :: term(),
      NewCTHState :: term(),
      Result :: {NewReturn, NewCTHState},
      Key :: atom(),
      Value :: term(),
      Reason :: term().

-callback pre_end_per_testcase(SuiteName, TestcaseName, EndData, CTHState) -> Result when
      SuiteName :: atom(),
      TestcaseName :: atom(),
      EndData :: Config,
      Config :: [{Key, Value}],
      NewConfig :: [{Key, Value}],
      CTHState :: term(),
      NewCTHState :: term(),
      Result :: {NewConfig, NewCTHState},
      Key :: atom(),
      Value :: term().

-callback post_init_per_testcase(SuiteName, TestcaseName, Config, Return, CTHState) -> Result when
      SuiteName :: atom(),
      TestcaseName :: atom(),
      Config :: [{Key, Value}],
      Return :: Config | SkipOrFail | term(),
      NewReturn :: Config | SkipOrFail | term(),
      SkipOrFail :: {fail, Reason} |
                    {skip, Reason},
      CTHState :: term(),
      NewCTHState :: term(),
      Result :: {NewReturn, NewCTHState},
      Key :: atom(),
      Value :: term(),
      Reason :: term().

-callback pre_init_per_testcase(SuiteName, TestcaseName, InitData, CTHState) -> Result when
      SuiteName :: atom(),
      TestcaseName :: atom(),
      InitData :: Config | SkipOrFail,
      Config :: [{Key, Value}],
      NewConfig :: [{Key, Value}],
      CTHState :: term(),
      NewCTHState :: term(),
      Result :: {NewConfig | SkipOrFail, NewCTHState},
      SkipOrFail :: {fail, Reason} |
                    {skip, Reason},
      Key :: atom(),
      Value :: term(),
      Reason :: term().

-callback post_init_per_group(SuiteName, GroupName, Config, Return, CTHState) -> Result when
      SuiteName :: atom(),
      GroupName :: atom(),
      Config :: [{Key, Value}],
      Return :: Config | SkipOrFail | term(),
      NewReturn :: Config | SkipOrFail | term(),
      SkipOrFail :: {fail, Reason} | {skip, Reason},
      CTHState :: term(),
      NewCTHState :: term(),
      Result :: {NewReturn, NewCTHState},
      Key :: atom(),
      Value :: term(),
      Reason :: term().

-callback pre_init_per_group(SuiteName, GroupName, InitData, CTHState) -> Result when
      SuiteName :: atom(),
      GroupName :: atom(),
      InitData :: Config | SkipOrFail,
      Config :: [{Key, Value}],
      NewConfig :: [{Key, Value}],
      CTHState :: term(),
      NewCTHState :: term(),
      Result :: {NewConfig | SkipOrFail,
                 NewCTHState},
      SkipOrFail :: {fail, Reason} | {skip, Reason},
      Key :: atom(),
      Value :: term(),
      Reason :: term().

-callback post_init_per_suite(SuiteName, Config, Return, CTHState) -> Result when
      SuiteName :: atom(),
      Config :: [{Key, Value}],
      Return :: Config | SkipOrFail | term(),
      NewReturn :: Config | SkipOrFail | term(),
      SkipOrFail :: {fail, Reason} |
                    {skip, Reason} |
                    term(),
      CTHState :: term(),
      NewCTHState :: term(),
      Result :: {NewReturn, NewCTHState},
      Key :: atom(),
      Value :: term(),
      Reason :: term().

-callback pre_init_per_suite(SuiteName, InitData, CTHState) -> Result when
      SuiteName :: atom(),
      InitData :: Config | SkipOrFail,
      Config :: [{Key, Value}],
      NewConfig :: [{Key, Value}],
      CTHState :: term(),
      NewCTHState :: term(),
      Result :: {Return, NewCTHState},
      Return :: NewConfig | SkipOrFail,
      SkipOrFail :: {fail, Reason} | {skip, Reason},
      Key :: atom(),
      Value :: term(),
      Reason :: term().

-callback post_all(SuiteName, Return, GroupDefs) -> NewReturn when
      SuiteName :: atom(),
      Return :: Tests | {skip, Reason},
      NewReturn :: Tests | {skip, Reason},
      Tests :: [TestCase |
                {testcase, TestCase, TCRepeatProps} |
                {group, GroupName} |
                {group, GroupName, Properties} |
                {group, GroupName, Properties, SubGroups}],
      TestCase :: atom(),
      TCRepeatProps :: [{repeat, N} |
                        {repeat_until_ok, N} |
                        {repeat_until_fail, N}],
      GroupName :: atom(),
      Properties :: GroupProperties | default,
      SubGroups :: [{GroupName, Properties} |
                    {GroupName, Properties, SubGroups}],
      Shuffle :: shuffle | {shuffle, Seed},
      Seed :: {integer(), integer(), integer()},
      GroupRepeatType ::
        repeat | repeat_until_all_ok |
        repeat_until_all_fail |
        repeat_until_any_ok |
        repeat_until_any_fail,
      N :: integer() | forever,
      GroupDefs :: [Group],
      Group ::
        {GroupName, GroupProperties,
         GroupsAndTestCases},
      GroupProperties ::
          [parallel | sequence | Shuffle |
           {GroupRepeatType, N}],
      GroupsAndTestCases ::
            [Group | {group, GroupName} | TestCase],
      Reason :: term().

-callback post_groups(SuiteName, GroupDefs) -> NewGroupDefs when
      SuiteName :: atom(),
      GroupDefs :: [Group],
      NewGroupDefs :: [Group],
      Group ::
        {GroupName, Properties,
         GroupsAndTestCases},
      GroupName :: atom(),
      Properties :: [parallel | sequence | Shuffle | {GroupRepeatType, N}],
      GroupsAndTestCases :: [Group |
                             {group, GroupName} |
                             TestCase |
                             {testcase, TestCase, TCRepeatProps}],
      TestCase :: atom(),
      TCRepeatProps :: [{repeat, N} |
                        {repeat_until_ok, N} |
                        {repeat_until_fail, N}],
      Shuffle :: shuffle | {shuffle, Seed},
      Seed :: {integer(), integer(), integer()},
      GroupRepeatType ::
        repeat | repeat_until_all_ok |
        repeat_until_all_fail |
        repeat_until_any_ok |
        repeat_until_any_fail,
      N :: integer() | forever.

-callback terminate(CTHState) -> term() when CTHState :: term().

-optional_callbacks(
   [id/1,
    on_tc_fail/4,
    on_tc_skip/4,
    post_all/3,
    post_end_per_group/5,
    post_end_per_suite/4,
    post_end_per_testcase/5,
    post_groups/2,
    post_init_per_group/5,
    post_init_per_suite/4,
    post_init_per_testcase/5,
    pre_end_per_group/4,
    pre_end_per_suite/3,
    pre_end_per_testcase/4,
    pre_init_per_group/4,
    pre_init_per_suite/3,
    pre_init_per_testcase/4,
    terminate/1]).

%% -------------------------------------------------------------------------
%% API Functions
%% -------------------------------------------------------------------------

-spec init(State :: term()) -> ok |
			       {fail, Reason :: term()}.
init(Opts) ->
    process_hooks_order(?FUNCTION_NAME, Opts),
    call(get_builtin_hooks(Opts) ++ get_new_hooks(Opts, undefined),
	 ok, init, []).

%% Call the post_groups/2 hook callback
groups(Mod, Groups) ->
    Info = try proplists:get_value(ct_hooks, Mod:suite(), []) of
               CTHooks when is_list(CTHooks) ->
                   [{?hooks_name,CTHooks}];
               CTHook when is_atom(CTHook) ->
                   [{?hooks_name,[CTHook]}]
           catch _:_ ->
                   %% since this might be the first time Mod:suite()
                   %% is called, and it might just fail or return
                   %% something bad, we allow any failure here - it
                   %% will be caught later if there is something
                   %% really wrong.
                   [{?hooks_name,[]}]
           end,
    case call(fun call_generic/3, Info ++ [{'$ct_groups',Groups}], [post_groups, Mod]) of
        [{'$ct_groups',NewGroups}] ->
            NewGroups;
        Other ->
            Other
    end.

%% Call the post_all/3 hook callback
all(Mod, Tests) ->
    Info = try proplists:get_value(ct_hooks, Mod:suite(), []) of
               CTHooks when is_list(CTHooks) ->
                   [{?hooks_name,CTHooks}];
               CTHook when is_atom(CTHook) ->
                   [{?hooks_name,[CTHook]}]
           catch _:_ ->
                   %% just allow any failure here - it will be caught
                   %% later if there is something really wrong.
                   [{?hooks_name,[]}]
           end,
    case call(fun call_generic/3, Info ++ [{'$ct_all',Tests}], [post_all, Mod]) of
        [{'$ct_all',NewTests}] ->
            NewTests;
        Other ->
            Other
    end.

%% Called after all suites are done.
-spec terminate(Hooks :: term()) ->
    ok.
terminate(Hooks) ->
    call([{HookId, fun call_terminate/3}
	  || #ct_hook_config{id = HookId} <- Hooks],
	 ct_hooks_terminate_dummy, terminate, Hooks),
    ok.

-spec init_tc(Mod :: atom(),
	      FuncSpec :: atom() | 
			  {ConfigFunc :: init_per_testcase | end_per_testcase,
			   TestCase :: atom()} |
			  {ConfigFunc :: init_per_group | end_per_group,
			   GroupName :: atom(),
			   Properties :: list()},
	      Args :: list()) ->
    NewConfig :: proplists:proplist() |
		 {skip, Reason :: term()} |
		 {auto_skip, Reason :: term()} |
		 {fail, Reason :: term()}.

init_tc(Mod, init_per_suite, Config) ->
    Info = try proplists:get_value(ct_hooks, Mod:suite(),[]) of
	       List when is_list(List) -> 
		   [{?hooks_name,List}];
	       CTHook when is_atom(CTHook) ->
		   [{?hooks_name,[CTHook]}]
	   catch error:undef ->
		   [{?hooks_name,[]}]
	   end,
    call(fun call_generic/3, Config ++ Info, [pre_init_per_suite, Mod]);

init_tc(Mod, end_per_suite, Config) ->
    call(fun call_generic/3, Config, [pre_end_per_suite, Mod]);
init_tc(Mod, {init_per_group, GroupName, Properties}, Config) ->
    maybe_start_locker(Mod, GroupName, Properties),
    call(fun call_generic_fallback/3, Config,
         [pre_init_per_group, Mod, GroupName]);
init_tc(Mod, {end_per_group, GroupName, _}, Config) ->
    call(fun call_generic_fallback/3, Config,
         [pre_end_per_group, Mod, GroupName]);
init_tc(Mod, {init_per_testcase,TC}, Config) ->
    call(fun call_generic_fallback/3, Config, [pre_init_per_testcase, Mod, TC]);
init_tc(Mod, {end_per_testcase,TC}, Config) ->
    call(fun call_generic_fallback/3, Config, [pre_end_per_testcase, Mod, TC]);
init_tc(Mod, TC = error_in_suite, Config) ->
    call(fun call_generic_fallback/3, Config, [pre_init_per_testcase, Mod, TC]).

-spec end_tc(Mod :: atom(),
	     FuncSpec :: atom() |  
			 {ConfigFunc :: init_per_testcase | end_per_testcase,
			  TestCase :: atom()} |
			 {ConfigFunc :: init_per_group | end_per_group,
			  GroupName :: atom(),
			  Properties :: list()},
	     Args :: list(),
	     Result :: term(),
	     Return :: term()) ->
    NewConfig :: proplists:proplist() |
		 {skip, Reason :: term()} |
		 {auto_skip, Reason :: term()} |
		 {fail, Reason :: term()} |
		 ok | '$ct_no_change'.

end_tc(Mod, init_per_suite, Config, _Result, Return) ->
    call(fun call_generic/3, Return, [post_init_per_suite, Mod, Config],
	 '$ct_no_change');
end_tc(Mod, end_per_suite, Config, Result, _Return) ->
    call(fun call_generic/3, Result, [post_end_per_suite, Mod, Config],
	'$ct_no_change');
end_tc(Mod, {init_per_group, GroupName, _}, Config, _Result, Return) ->
    call(fun call_generic_fallback/3, Return,
         [post_init_per_group, Mod, GroupName, Config], '$ct_no_change');
end_tc(Mod, {end_per_group, GroupName, Properties}, Config, Result, _Return) ->
    Res = call(fun call_generic_fallback/3, Result,
	       [post_end_per_group, Mod, GroupName, Config], '$ct_no_change'),
    maybe_stop_locker(Mod, GroupName, Properties),
    Res;
end_tc(Mod, {init_per_testcase,TC}, Config, Result, _Return) ->
    call(fun call_generic_fallback/3, Result,
         [post_init_per_testcase, Mod, TC, Config], '$ct_no_change');
end_tc(Mod, {end_per_testcase,TC}, Config, Result, _Return) ->
    call(fun call_generic_fallback/3, Result,
         [post_end_per_testcase, Mod, TC, Config], '$ct_no_change');
end_tc(Mod, TC = error_in_suite, Config, Result, _Return) ->
    call(fun call_generic_fallback/3, Result,
         [post_end_per_testcase, Mod, TC, Config], '$ct_no_change').


%% Case = TestCase | {TestCase,GroupName}
on_tc_skip(How, {Suite, Case, Reason}) ->
    call(fun call_cleanup/3, {How, Reason}, [on_tc_skip, Suite, Case]).

%% Case = TestCase | {TestCase,GroupName}
on_tc_fail(_How, {Suite, Case, Reason}) ->
    call(fun call_cleanup/3, Reason, [on_tc_fail, Suite, Case]).

%% -------------------------------------------------------------------------
%% Internal Functions
%% -------------------------------------------------------------------------
call_id(#ct_hook_config{ module = Mod, opts = Opts} = Hook, Config, Scope) ->
    Id = catch_apply(Mod,id,[Opts], make_ref()),
    {Config, Hook#ct_hook_config{ id = Id, scope = scope(Scope)}}.
	
call_init(#ct_hook_config{ module = Mod, opts = Opts, id = Id, prio = P} = Hook,
	  Config, _Meta) ->
    case Mod:init(Id, Opts) of
	{ok, NewState} when P =:= undefined ->
	    {Config, Hook#ct_hook_config{ state = NewState, prio = 0 } };
	{ok, NewState} ->
	    {Config, Hook#ct_hook_config{ state = NewState } };
	{ok, NewState, Prio} when P =:= undefined ->
	    %% Only set prio if not already set when installing hook
	    {Config, Hook#ct_hook_config{ state = NewState, prio = Prio } };
	{ok, NewState, _} ->
	    {Config, Hook#ct_hook_config{ state = NewState } };
	NewState -> %% Keep for backward compatibility reasons
	    {Config, Hook#ct_hook_config{ state = NewState } }
    end.    

call_terminate(#ct_hook_config{ module = Mod, state = State} = Hook, _, _) ->
    catch_apply(Mod,terminate,[State], ok),
    {[],Hook}.

call_cleanup(#ct_hook_config{ module = Mod, state = State} = Hook,
	     Reason, [Function | Args]) ->
    NewState = catch_apply(Mod,Function, Args ++ [Reason, State],
			   State, true),
    {Reason, Hook#ct_hook_config{ state = NewState } }.

call_generic(Hook, Value, Meta) ->
    do_call_generic(Hook, Value, Meta, false).

call_generic_fallback(Hook, Value, Meta) ->
    do_call_generic(Hook, Value, Meta, true).

do_call_generic(#ct_hook_config{ module = Mod} = Hook,
                [{'$ct_groups',Groups}], [post_groups | Args], Fallback) ->
    NewGroups = catch_apply(Mod, post_groups, Args ++ [Groups],
                            Groups, Fallback),
    {[{'$ct_groups',NewGroups}], Hook#ct_hook_config{ groups = NewGroups } };

do_call_generic(#ct_hook_config{ module = Mod, groups = Groups} = Hook,
                [{'$ct_all',Tests}], [post_all | Args], Fallback) ->
    NewTests = catch_apply(Mod, post_all, Args ++ [Tests, Groups],
                           Tests, Fallback),
    {[{'$ct_all',NewTests}], Hook};

do_call_generic(#ct_hook_config{ module = Mod, state = State} = Hook,
                Value, [Function | Args], Fallback) ->
    {NewValue, NewState} = catch_apply(Mod, Function, Args ++ [Value, State],
				       {Value,State}, Fallback),
    {NewValue, Hook#ct_hook_config{ state = NewState } }.

%% Generic call function
call(Fun, Config, [CFunc | _] = Meta) ->
    maybe_lock(),
    Hooks = get_hooks(),
    Calls = get_new_hooks(Config, Fun) ++
	[{HookId,Fun} || #ct_hook_config{id = HookId} <- Hooks],
    Order = process_hooks_order(CFunc, Config),
    Res = call(resort(Calls,Hooks,Meta, Order),
	       remove([?hooks_name, ?hooks_order_name], Config),
               Meta, Hooks),
    maybe_unlock(),
    Res.

call(Fun, Config, Meta, NoChangeRet) when is_function(Fun) ->
    case call(Fun,Config,Meta) of
	Config -> NoChangeRet;
	NewReturn -> NewReturn
    end;
call([{Hook, call_id, NextFun} | Rest], Config, Meta, Hooks) ->
    try
	{Config, #ct_hook_config{ id = NewId } = NewHook} =
	    call_id(Hook, Config, Meta),
	{NewHooks, NewRest} = 
	    case lists:keyfind(NewId, #ct_hook_config.id, Hooks) of
		false when NextFun =:= undefined ->
		    {Hooks ++ [NewHook],
		     Rest ++ [{NewId, call_init}]};
		ExistingHook when is_tuple(ExistingHook) ->
		    {Hooks, Rest};
                _ when hd(Meta)=:=post_groups; hd(Meta)=:=post_all ->
                    %% If CTH is started because of a call from
                    %% groups/2 or all/2, CTH:init/1 must not be
                    %% called (the suite scope should be used).
                    {Hooks ++ [NewHook],
		     Rest ++ [{NewId,NextFun}]};
		_ ->
		    {Hooks ++ [NewHook],
		     Rest ++ [{NewId, call_init}, {NewId,NextFun}]}
	    end,
        Order = get_hooks_order(),
	call(resort(NewRest, NewHooks, Meta, Order), Config, Meta,
             NewHooks)
    catch Error:Reason:Trace ->
	    ct_logs:log("Suite Hook","Failed to start a CTH: ~tp:~tp",
			[Error,{Reason,Trace}]),
	    call([], {fail,"Failed to start CTH, "
		      "see the CT Log for details"}, Meta, Hooks)
    end;
call([{HookId, call_init} | Rest], Config, Meta, Hooks) ->
    call([{HookId, fun call_init/3} | Rest], Config, Meta, Hooks);
call([{HookId, Fun} | Rest], Config, Meta, Hooks) ->
    try
        Hook = lists:keyfind(HookId, #ct_hook_config.id, Hooks),
        {NewConf, NewHook} =  Fun(Hook, Config, Meta),
        NewCalls = get_new_hooks(NewConf, Fun),
        NewHooks = lists:keyreplace(HookId, #ct_hook_config.id, Hooks, NewHook),
        Order = get_hooks_order(),
        call(resort(NewCalls ++ Rest, NewHooks,
                    Meta, Order), %% Resort if call_init changed prio
	     remove([?hooks_name, ?hooks_order_name], NewConf), Meta,
             terminate_if_scope_ends(HookId, Meta, NewHooks))
    catch throw:{error_in_cth_call,Reason} ->
            call(Rest, {fail, Reason}, Meta,
                 terminate_if_scope_ends(HookId, Meta, Hooks))
    end;
call([], Config, _Meta, Hooks) ->
    save_suite_data_async(Hooks),
    Config.

remove([], List) when is_list(List) ->
    List;
remove([Key|T], List) when is_list(List) ->
    NewList = remove(Key, List),
    remove(T, NewList);
remove(Key,List) when is_list(List) ->
    [Conf || Conf <- List, is_tuple(Conf) =:= false
		 orelse element(1, Conf) =/= Key];
remove(_, Else) ->
    Else.

%% Translate scopes, i.e. is_tuplenit_per_group,group1 -> end_per_group,group1 etc
scope([pre_init_per_testcase, SuiteName, TC|_]) ->
    [post_init_per_testcase, SuiteName, TC];
scope([pre_end_per_testcase, SuiteName, TC|_]) ->
    [post_end_per_testcase, SuiteName, TC];
scope([pre_init_per_group, SuiteName, GroupName|_]) ->
    [post_end_per_group, SuiteName, GroupName];
scope([post_init_per_group, SuiteName, GroupName|_]) ->
    [post_end_per_group, SuiteName, GroupName];
scope([pre_init_per_suite, SuiteName|_]) ->
    [post_end_per_suite, SuiteName];
scope([post_init_per_suite, SuiteName|_]) ->
    [post_end_per_suite, SuiteName];
scope([post_groups, SuiteName|_]) ->
    [post_groups, SuiteName];
scope([post_all, SuiteName|_]) ->
    [post_all, SuiteName];
scope(init) ->
    none.

strip_config([post_init_per_testcase, SuiteName, TC|_]) ->
    [post_init_per_testcase, SuiteName, TC];
strip_config([post_end_per_testcase, SuiteName, TC|_]) ->
    [post_end_per_testcase, SuiteName, TC];
strip_config([post_init_per_group, SuiteName, GroupName|_]) ->
    [post_init_per_group, SuiteName, GroupName];
strip_config([post_end_per_group, SuiteName, GroupName|_]) ->
    [post_end_per_group, SuiteName, GroupName];
strip_config([post_init_per_suite, SuiteName|_]) ->
    [post_init_per_suite, SuiteName];
strip_config([post_end_per_suite, SuiteName|_]) ->
    [post_end_per_suite, SuiteName];
strip_config(Other) ->
    Other.


terminate_if_scope_ends(HookId, [on_tc_skip,Suite,{end_per_group,Name}],
			Hooks) ->
    terminate_if_scope_ends(HookId, [post_end_per_group, Suite, Name], Hooks);
terminate_if_scope_ends(HookId, [on_tc_skip,Suite,end_per_suite], Hooks) ->
    terminate_if_scope_ends(HookId, [post_end_per_suite, Suite], Hooks);
terminate_if_scope_ends(HookId, Function0, Hooks) ->
    Function = strip_config(Function0),
    case lists:keyfind(HookId, #ct_hook_config.id, Hooks) of
        #ct_hook_config{ id = HookId, scope = Function} = Hook ->
            case Function of
                [AllOrGroup,_] when AllOrGroup=:=post_all;
                                    AllOrGroup=:=post_groups ->
                    %% The scope only contains one function (post_all
                    %% or post_groups), and init has not been called,
                    %% so skip terminate as well.
                    ok;
                _ ->
                    terminate([Hook])
            end,
            lists:keydelete(HookId, #ct_hook_config.id, Hooks);
        _ ->
            Hooks
    end.

%% Fetch hook functions
get_new_hooks(Config, Fun) ->
    lists:map(fun(NewHook) when is_atom(NewHook) ->
		      {#ct_hook_config{ module = NewHook }, call_id, Fun};
		 ({NewHook,Opts}) ->
		      {#ct_hook_config{ module = NewHook,
					opts = Opts}, call_id, Fun};
		 ({NewHook,Opts,Prio}) ->
		      {#ct_hook_config{ module = NewHook,
					opts = Opts,
					prio = Prio }, call_id, Fun}
		end, get_new_hooks(Config)).

get_new_hooks(Config) when is_list(Config) ->
    lists:flatmap(fun({?hooks_name, HookConfigs}) when is_list(HookConfigs) ->
			  HookConfigs;
		     ({?hooks_name, HookConfig}) when is_atom(HookConfig) ->
			  [HookConfig];
		     (_) ->
			  []
		  end, Config);
get_new_hooks(_Config) ->
    [].

get_builtin_hooks(Opts) ->
    case proplists:get_value(enable_builtin_hooks,Opts) of
	false ->
	    [];
	_Else ->
	    [{HookConf, call_id, undefined} || HookConf <- ?BUILTIN_HOOKS]
    end.

save_suite_data_async(Hooks) ->
    ct_util:save_suite_data_async(?hooks_name, Hooks).

get_hooks() ->
    lists:keysort(#ct_hook_config.prio,ct_util:read_suite_data(?hooks_name)).

%% Sort all calls in this order:
%% call_id < call_init < ctfirst < Priority 1 < .. < Priority N < ctlast
%% If Hook Priority is equal, check when it has been installed and
%% sort on that instead.
%% If we are doing a cleanup call i.e. {post,pre}_end_per_*, all priorities
%% are reversed. Probably want to make this sorting algorithm pluginable
%% as some point...
resort(Calls, Hooks, [CFunc|_R], HooksOrder) ->
    Resorted = resort(Calls, Hooks),
    ReversedHooks =
        case HooksOrder of
            config ->
                %% reversed order for all post hooks (config centric order)
                %% ct_hooks_order is 'config'
                [post_init_per_testcase,
                 post_end_per_testcase,
                 post_init_per_group,
                 post_end_per_group,
                 post_init_per_suite,
                 post_end_per_suite];
            _ ->
                %% reversed order for all end hooks (testcase centric order)
                %% default or when ct_hooks_order is 'test'
                [pre_end_per_testcase,
                 post_end_per_testcase,
                 pre_end_per_group,
                 post_end_per_group,
                 pre_end_per_suite,
                 post_end_per_suite]
        end,
    case lists:member(CFunc, ReversedHooks) of
        true ->
            lists:reverse(Resorted);
        _ ->
            Resorted
    end;
resort(Calls,Hooks,_Meta, _HooksOrder) ->
    resort(Calls,Hooks).

resort(Calls, Hooks) ->
    lists:sort(
      fun({_,_,_},_) ->
	      true;
	 (_,{_,_,_}) ->
	      false;
	 ({_,call_init},_) ->
	      true;
	 (_,{_,call_init}) ->
	      false;
	 ({Id1,_},{Id2,_}) ->
	      P1 = (lists:keyfind(Id1, #ct_hook_config.id, Hooks))#ct_hook_config.prio,
	      P2 = (lists:keyfind(Id2, #ct_hook_config.id, Hooks))#ct_hook_config.prio,
	      if
		  P1 == P2 ->
		      %% If priorities are equal, we check the position in the
		      %% hooks list
		      pos(Id1,Hooks) < pos(Id2,Hooks);
		  P1 == ctfirst ->
		      true;
		  P2 == ctfirst ->
		      false;
		  P1 == ctlast ->
		      false;
		  P2 == ctlast ->
		      true;
		  true ->
		      P1 < P2
	      end
      end,Calls).

pos(Id,Hooks) ->
    pos(Id,Hooks,0).
pos(Id,[#ct_hook_config{ id = Id}|_],Num) ->
    Num;
pos(Id,[_|Rest],Num) ->
    pos(Id,Rest,Num+1).


catch_apply(M,F,A, Default) ->
    catch_apply(M,F,A,Default,false).
catch_apply(M,F,A, Default, Fallback) ->
    not erlang:module_loaded(M) andalso (catch M:module_info()),
    case erlang:function_exported(M,F,length(A)) of
        false when Fallback ->
            catch_apply(M,F,tl(A),Default,false);
        false ->
            Default;
        true ->
            catch_apply(M,F,A)
    end.

catch_apply(M,F,A) ->
    try
        erlang:apply(M,F,A)
    catch _:Reason:Trace ->
            ct_logs:log("Suite Hook","Call to CTH failed: ~w:~tp",
                            [error,{Reason,Trace}]),
            throw({error_in_cth_call,
                   lists:flatten(
                     io_lib:format("~w:~tw/~w CTH call failed",
                                   [M,F,length(A)]))})
    end.

process_hooks_order(init, Return) when is_list(Return) ->
    maybe_save_hooks_order(Return);
process_hooks_order(_Stage, Return) when is_list(Return) ->
    case get_hooks_order() of
        undefined ->
            maybe_save_hooks_order(Return);
        StoredOrder ->
            StoredOrder
    end;
process_hooks_order(_Stage, _) ->
    nothing_to_save.

get_hooks_order() ->
    ct_util:read_suite_data(?hooks_order_name).

maybe_save_hooks_order(Return) ->
    case proplists:get_value(?hooks_order_name, Return) of
        Order when Order == config ->
            ct_util:save_suite_data_async(?hooks_order_name, Order),
            Order;
        _ ->
            test
    end.

%% We need to lock around the state for parallel groups only. This is because
%% we will get several processes reading and writing the state for a single
%% cth at the same time.
maybe_start_locker(Mod,GroupName,Opts) ->
    case lists:member(parallel,Opts) of
	true ->
	    {ok, _Pid} = ct_hooks_lock:start({Mod,GroupName}),
	    ok;
	false ->
	    ok
    end.

maybe_stop_locker(Mod,GroupName,Opts) ->
    case lists:member(parallel,Opts) of
	true ->
	    stopped = ct_hooks_lock:stop({Mod,GroupName});
	false ->
	    ok
    end.


maybe_lock() ->
    locked = ct_hooks_lock:request().

maybe_unlock() ->
    unlocked = ct_hooks_lock:release().
