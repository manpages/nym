module Nym.core.lib;
import std.stdio;
import std.typecons;

alias state = string[][string][string];
alias response = Tuple!(string, state);

response rpc_add(string[] args) {
  if(args.length != 1) {
    return tuple("Add takes one argument.", cast(state)null);
  }
  state result;
  result[args[0]] = ["handles": [args[0]]];
  return tuple("ok", result);
}

response rpc_alias(string[] _nothing) {
  writeln("core reports that it received: alias");
  return tuple("Not implemented", cast(state)null);
}

response rpc_info(string[] _nothing) {
  writeln("core reports that it received: info");
  return tuple("Not implemented", cast(state)null);
}

response rpc_default(string[] _nothing) {
  writeln("core reports that it received: default");
  return tuple("Not implemented", cast(state)null);
}
