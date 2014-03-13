import std.stdio;
import std.string;
import std.conv;
import std.typecons;
import deimos.zmq.zmq;
import vibe.data.json;
import Nym.core.data;
import Nym.persist.lib;
alias state = string[][string][string];
alias response = Tuple!(string, state);

void main() {
  writeln("Starting nym node");
  void* context = zmq_init(1);

  void* socket = zmq_socket(context, ZMQ_REP);
  zmq_bind(socket, toStringz(`tcp://*:67831`));

  state nym_state;
  nym_state = read!(string[][string])();

  while (true) {
    writeln("Initializing zmq message");
    zmq_msg_t req;
    zmq_msg_init(&req);
    writeln("Done.");
    writeln("Getting request");
    long bytes = zmq_recvmsg(socket, &req, 0);
    if(bytes == -1) {
      import core.stdc.errno; 
      writeln(to!string(cast(char*)zmq_strerror(errno)));
      return;
    }
    immutable string data = to!string((cast(char*)zmq_msg_data(&req))[0 .. bytes]);
    zmq_msg_close(&req);
    writeln("Done.");

    // todo: add fibers
    // infiber worker
    auto result = handle(data, nym_state);
    nym_state = Merge!state.merge(result[1], nym_state);

    // such debug much redundand code wow
    writeln("Got result! Status is “" ~ result[0] ~ "”");
    foreach(k, v; result[1]) {
      writeln(k);
      foreach(kk, vv; v) {
        writeln("  " ~ kk);
        foreach(vvv; vv) {
          writeln("    " ~ vvv);
        }
      }
    }
    writeln("Nym state is currently this:");
    foreach(k, v; nym_state) {
      writeln(k);
      foreach(kk, vv; v) {
        writeln("  " ~ kk);
        foreach(vvv; vv) {
          writeln("    " ~ vvv);
        }
      }
    }

    dump(nym_state);
    zmq_msg_t reply;
    zmq_msg_init_size(&reply, data.length);
    (zmq_msg_data(&reply))[0 .. data.length] = (cast(immutable(void*))data.ptr)[0 .. data.length];
    zmq_sendmsg(socket, &reply, 0);
    zmq_msg_close(&reply);
    // outfiber worker
    // infiber response server
    
    // outfiber response server
  }

  //zmq_close(socket);
  //zmq_term(context);
}

response handle(immutable string request, state nym_state) {
  import std.array;
  import Nym.core.lib;
  writeln("Handling request: " ~ request);
  auto rpc_args = deserializeJson!(string[])(request);
  mixin(gencode_dispatch([ "add", "alias", "info", "get", "who" ]));
  writeln("Done.");
  return dispatch(rpc_args, nym_state);
}

immutable string gencode_dispatch(immutable string[] verbs) @safe pure {  
  string code = `response dispatch(string[] x, state nym_state) {` ~
                `  response result;` ~
                `  switch(x[0]) {`;
  foreach(verb; verbs) {
    code ~=     `    case "` ~ verb ~ `": ` ~ 
                `      result = rpc_` ~ verb ~ `(x[1 .. $], nym_state);` ~
                `      break;`;
  }
  code ~=       `    default: result = rpc_default(x); }` ~
                `  return result; }`;
  return code;
}
