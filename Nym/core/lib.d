module Nym.core.lib;
import vibe.data.json;
import std.stdio;
import std.typecons;
import std.string;

alias state = string[][string][string];
alias response = Tuple!(string, state);

response rpc_add(string[] args, state nym_state) @safe pure {
  if(args.length < 1) {
    return tuple("Add expects one argument.", cast(state)null);
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
    return tuple("Alias expects two arguments.", cast(state)null);
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
    return tuple("Info expects three arguments.", cast(state)null);
  }
  string name = args[0];
  string field = args[1].toLower();
  string data = args[2];
  if(!(name in nym_state)) {
    return tuple("Main handle " ~ name ~ " isn't in the local database.", cast(state)null);
  }
  if((field in nym_state[name]) && (in_array(data, nym_state[name][field]))) {
    return tuple("Value " ~ data ~ " is already there.", cast(state)null);
  }
  state result;
  result[name] = [field: [data]];
  return tuple("ok", result);
}

response rpc_get(string[] args, state nym_state) {
  if(args.length < 2) {
    return tuple("Get expects two arguments.", cast(state)null);
  }
  string name = args[0];
  string field = args[1].toLower();
  if(!(name in nym_state)) {
    return tuple("Main handle " ~ name ~ " isn't in the local database.", cast(state)null);
  }
  if(!(field in nym_state[name])) {
    return tuple("Property " ~ field ~ " isn't tracked for " ~ name, cast(state)null);
  }
  return tuple(serializeToJson(nym_state[name][field]).toString, cast(state)null);
}

response rpc_who(string[] args, state nym_state) {
  if(args.length < 1) {
    return tuple("Get expects one argument.", cast(state)null);
  }
  args ~= "handles";
  return rpc_get(args, nym_state);
}

response rpc_default(string[] _nothing, state nym_state) @safe pure {
  return tuple("Invalid RPC call.", cast(state)null);
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
