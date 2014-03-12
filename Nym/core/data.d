module Nym.core.data;

import std.typecons;
import std.traits;

void patch_axioms(ContainerT, PatchT)(ContainerT c, PatchT p) {
  assert((c.patch(p)).revert(p) == c);
}

void merge_axioms(ContainerT)(ContainerT c, ContainerT m) {
  assert(c.merge(m) == m.merge(c));
}

T[U] patch(T, U)(T[U] c, Tuple!(T[U], T[U]) p) {
  import std.string;
  c = c.dup;
  foreach (key, value; p[1]) { // First delete entities
    if(key in c && c[key] == value) {
      c.remove(key);
    } else {
      throw new Exception(format("Deletion failed: key %s not found.", key));
    }
  }
  foreach (key, value; p[0]) { // Now add entities
    if(key !in c) {
      c[key] = value;
    } else {
      throw new Exception(format("Insertion failed: key %s already exists.", key));
    }
  }
  return c;
}
T[U] revert(T, U)(T[U] c, Tuple!(T[U], T[U]) p) {
  return patch!(T, U)(c, tuple(p[1], p[0]));
}

template Merge(T) {
  static if(isAssociativeArray!T) {
    static if(!isAssociativeArray!(ValueType!T)) {
      ValueT[KeyT] merge(KeyT, ValueT)(ValueT[KeyT] x, ValueT[KeyT] y) {
        x = x.dup;
        foreach(k, v; y) {
          if(k in x)
            x[k] = Merge!ValueT.merge(x[k], v);
          else
            x[k] = v;
        }
        return x;
      }
    } else {
      ValueT[Key1T][Key0T] merge(Key0T, Key1T, ValueT)(ValueT[Key1T][Key0T] x, ValueT[Key1T][Key0T] y) {
        x = x.dup;
        foreach(k, v; y) {
          if(k in x)
            x[k] = Merge!(ValueT[Key1T]).merge(x[k], v);
          else
            x[k] = v;
        }
        return x;
      }
    }
  } else static if(isArray!T) {
    T merge(T x, T y) @safe pure {
      x = x.dup;
      return (x ~= y);
    }
  }
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

  string[string] container = [ "aaa":  "1", "aab":  "2", "aac":  "3",
                               "aba":  "4", "abb":  "5", "abc":  "6",
                               "aca":  "7", "acb":  "8", "acc":  "9",
                               "baa": "10",              "bac": "12" ];
  string[string] plus  = [ "aaa": "42", "bab": "11", "ccc": "30" ];
  string[string] minus = [ "aaa":  "1", "aca":  "7", "eee": "-1" ];
  writeln("Assert exception:");
  assertThrown!(Exception)(patch_axioms(container, tuple(plus, minus)), "Deletion failed: key eee not found. Strict patching failed");
  minus.remove("eee");
  writeln("Patching " ~ fmtarr(container) ~ "\nwith +++ " ~ fmtarr(plus) ~ "\nand  --- " ~ fmtarr(minus));
  writeln("Patched: " ~ fmtarr((container).patch(tuple(plus, minus))));
  writeln("Patching " ~ fmtarr(container) ~ "\nwith +++ " ~ fmtarr(plus) ~ "\nand  --- " ~ fmtarr(minus));
  patch_axioms(container, tuple(plus, minus));
  writeln(Merge!string.merge("a", "b"));
  writeln("Merged cont and plus: " ~ fmtarr(Merge!(string[string]).merge(container, plus)));
  string[string][string] deeper;
  deeper["deeper"] = container;
  string[string][string] deeper_plus;
  deeper_plus["deeper"] = plus;
  deeper = Merge!(string[string][string]).merge(deeper, deeper_plus);
  writeln("Merged deeper field of string[string][string] " ~ fmtarr(deeper["deeper"]));
}
