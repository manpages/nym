//module app.core.core;
import std.stdio;

string rpc_add(string[] _nothing) {
  writeln("core reports that it received: add");
  return "add";
}

string rpc_alias(string[] _nothing) {
  writeln("core reports that it received: alias");
  return "alias";
}

string rpc_info(string[] _nothing) {
  writeln("core reports that it received: info");
  return "infp";
}

string rpc_default(string[] _nothing) {
  writeln("core reports that it received: default");
  return "default";
}
