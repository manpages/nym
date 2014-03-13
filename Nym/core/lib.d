module Nym.core.lib;
import vibe.data.json;
import std.stdio;
import std.typecons;

alias state = string[][string][string];
alias response = Tuple!(string, state);

response rpc_add(string[] args, state nym_state) @safe pure {
  if(args.length < 1) {
    return tuple("Add expects an argument.", cast(state)null);
  }
  if(string root = args[0].maybe_known(nym_state)) {
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
    return tuple("Main handle " ~ args[0] ~ " isn't in the local database.", cast(state)null);
  }
  if(string root = args[1].maybe_known(nym_state)) {
    return tuple(args[1] ~ " is already in the local database under main handle " ~ root, cast(state)null);
  }
  state result;
  result[args[0]] = ["handles": [args[1]]];
  return tuple("ok", result);
}

response rpc_info(string[] args, state nym_state) @safe pure {
  if(args.length < 3) {
    return tuple("Info expects at least three arguments.", cast(state)null);
  }
  if(!(args[0] in nym_state)) {
    return tuple("Main handle " ~ args[0] ~ " isn't in the local database.", cast(state)null);
  }
  if((args[1] in nym_state[args[0]]) && (in_array(args[2], nym_state[args[0]][args[1]]))) {
    return tuple("Value " ~ args[2] ~ " is already there.", cast(state)null);
  }
  state result;
  result[args[0]] = [args[1]: [args[2]]];
  return tuple("ok", result);
}

response rpc_get(string[] args, state nym_state) {
  if(args.length < 2) {
    return tuple("Get expects at least two arguments.", cast(state)null);
  }
  if(!(args[0] in nym_state)) {
    return tuple("Main handle " ~ args[0] ~ " isn't in the local database.", cast(state)null);
  }
  if(!(args[1] in nym_state[args[0]])) {
    return tuple("Property " ~ args[1] ~ " isn't tracked for " ~ args[0], cast(state)null);
  }
  return tuple(serializeToJson(nym_state[args[0]][args[1]]).toString, cast(state)null);
}

response rpc_who(string[] args, state nym_state) {
  if(args.length < 1) {
    return tuple("Get expects one argument.", cast(state)null);
  }
  args ~= "handles";
  return rpc_get(args, nym_state);
}

response rpc_default(string[] _nothing) @safe pure {
  return tuple("Not implemented", cast(state)null);
}

string maybe_known(string who, state where) @safe pure {
  return maybe_in("handles", who, where);
}
string maybe_in(string field, string needle, state haystack) @safe pure {
  if(needle in haystack)
    return needle;
  foreach(k, v; haystack) {
    foreach(handle; v[field]) {
      if(needle == handle)
        return k;
    }
  }
  return cast(string)null;
}

bool in_array(T)(T needle, T[] haystack) {
  foreach(v; haystack) {
    if(needle == v)
      return true;
  }
  return false;
}
