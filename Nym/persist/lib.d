module Nym.persist.lib;
import vibe.data.json;
import std.stdio;
import std.string;
import std.file;

void dump(T)(T[string] data) {
  auto fh = File("/home/sweater/.nym/nym.json", "w+");
  fh.write(serializeToJson(data).toString);
  fh.close;
}

T[string] read(T)() {
  auto fh = File("/home/sweater/.nym/nym.json", "r");
  string json;
  while(!fh.eof()) {
    json ~= chomp(fh.readln());
  }
  writeln("Got " ~ json ~ " from storage");
  if(json == "")
    json = "{}";
  return deserializeJson!(T[string])(json);
  //T[string] result = deserializeJson!(T[string])(json);
  //return result;
}
