module Nym.core.lib;
import std.stdio;
import std.typecons;

alias state = string[][string][string];
alias response = Tuple!(string, state);

response rpc_add(string[] args, state nym_state) @safe pure {
  if(args.length < 1) {
    return tuple("Add expects an argument.", cast(state)null);
  }
  if(string root = args[0].maybe_find_handle(nym_state)) {
    return tuple(args[0] ~ " is already in the local database under main handle " ~ root, cast(state)null);
  }
  state result;
  result[args[0]] = ["handles": [args[0]]];
  return tuple("ok", result);
}

response rpc_alias(string[] args, state nym_state) @safe pure {
  if(args.length < 2) {
    return tuple("Alias expects at least two arguments.", cast(state)null);
  }
  if(!(args[0] in nym_state)) {
    return tuple("Main handle " ~args[0] ~ " isn't in the local database.", cast(state)null);
  }
  if(string root = args[1].maybe_find_handle(nym_state)) {
    return tuple(args[1] ~ " is already in the local database under main handle " ~ root, cast(state)null);
  }
  state result;
  result[args[0]] = ["handles": [args[1]]];
  return tuple("ok", result);
}

response rpc_info(string[] _nothing, state nym_state) @safe pure {
  return tuple("Not implemented", cast(state)null);
}

response rpc_get(string[] _nothing, state nym_state) @safe pure {
  return tuple("Not implemented", cast(state)null);
}

response rpc_who(string[] _nothing, state nym_state) @safe pure {
  return tuple("Not implemented", cast(state)null);
}

response rpc_default(string[] _nothing) @safe pure {
  return tuple("Not implemented", cast(state)null);
}

string maybe_find_handle(string who, state where) @safe pure {
  if(who in where)
    return who;
  foreach(k, v; where) {
    foreach(handle; v["handles"]) {
      if(who == handle)
        return k;
    }
  }
  return cast(string)null;
}
