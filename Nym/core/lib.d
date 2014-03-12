//module app.core.core;
import std.stdio;
alias state = string[][string][string];

state rpc_add(string[] _nothing) {
  writeln("core reports that it received: add");
  return ["result": "add"];
}

state rpc_alias(string[] _nothing) {
  writeln("core reports that it received: alias");
  return ["result": "alias"];
}

state rpc_info(string[] _nothing) {
  writeln("core reports that it received: info");
  return ["result": "info"];
}

state rpc_default(string[] _nothing) {
  writeln("core reports that it received: default");
  return ["result": "default"];
}
