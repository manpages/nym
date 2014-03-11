//module app.core.core;
import std.stdio;

string[string] rpc_add(string[] _nothing) {
  writeln("core reports that it received: add");
  return ["result": "add"];
}

string[string] rpc_alias(string[] _nothing) {
  writeln("core reports that it received: alias");
  return ["result": "alias"];
}

string[string] rpc_info(string[] _nothing) {
  writeln("core reports that it received: info");
  return ["result": "info"];
}

string[string] rpc_default(string[] _nothing) {
  writeln("core reports that it received: default");
  return ["result": "default"];
}
