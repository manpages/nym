module Nym.core.data;

import std.typecons;

void axioms(ContainerT, PatchT)(ContainerT c, PatchT p) {
  assert((c.patch(p)).revert(p) == c);
}

T[U] patch(T, U)(T[U] c, Tuple!(T[U], T[U]) p) {
  c = c.dup;
  foreach (key, value; p[1]) { // First delete entities
    if(key in c && c[key] == value) {
      c.remove(key);
    } else {
      import std.string;
      throw new Exception(format("Key %s not found. Strict patching failed", key));
    }
  }
  foreach (key, value; p[0]) { // Now add entities
    c[key] = value;
  }
  return c;
}
T[U] revert(T, U)(T[U] c, Tuple!(T[U], T[U]) p) {
  return patch!(T, U)(c, tuple(p[1], p[0]));
}
unittest {
  import std.stdio;
  import std.exception;

  string fmtarr(T, U)(T[U] a) {
    import std.conv;
    string result =  `[`;
    foreach(k, v; a) {
      result ~=      `  ` ~ to!string(k) ~ `: ` ~ to!string(v) ~ `,`;
    }
    return (result ~ `]`);
  }

  int[string] container = [ "aaa":  1, "aab":  2, "aac":  3,
                            "aba":  4, "abb":  5, "abc":  6,
                            "aca":  7, "acb":  8, "acc":  9,
                            "baa": 10,            "bac": 12 ];
  int[string] plus  = [ "aaa": 42, "bab": 11, "ccc": 30 ];
  int[string] minus = [ "aaa":  1, "aca":  7, "eee": -1 ];
  writeln("Assert exception:");
  assertThrown!(Exception)(axioms(container, tuple(plus, minus)), "Key eee not found. Strict patching failed");
  minus.remove("eee");
  writeln("Patching " ~ fmtarr(container) ~ "\nwith +++ " ~ fmtarr(plus) ~ "\nand  --- " ~ fmtarr(minus));
  writeln("Patched: " ~ (container).patch(tuple(plus, minus)).fmtarr);
  writeln("Patching " ~ fmtarr(container) ~ "\nwith +++ " ~ fmtarr(plus) ~ "\nand  --- " ~ fmtarr(minus));
  axioms(container, tuple(plus, minus));
}
