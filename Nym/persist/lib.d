module Nym.persist.lib;
import vibe.data.json;
import std.stdio;

immutable bool dump(T)(T[string] data) @safe pure {
  auto fh = file.open("~/.nym/nym.json", "w");
  fh.write(serializeToJson(data).toString);
  fh.close;
}
