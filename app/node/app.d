import std.stdio;
import std.string;
import std.conv;
import deimos.zmq.zmq;

void main() {
  writeln("Starting nym node");
  void* context = zmq_init(1);

  void* socket = zmq_socket(context, ZMQ_REP);
  zmq_bind(socket, toStringz(`tcp://*:67831`));

  while (true) {
    zmq_msg_t req;
    zmq_msg_init(&req);
    size_t msg_size = zmq_recvmsg(socket, &req, 0);

    // todo: add fibers
    string data = (`ok:` ~ asString((cast(ubyte*)zmq_msg_data(&req))[0 .. msg_size]));
    writeln(`Seinding "`, data, `" of length `, data.length);
    zmq_msg_close(&req);
    
    zmq_msg_t reply;
    zmq_msg_init_size(&reply, data.length);
    (zmq_msg_data(&reply))[0 .. data.length] = (cast(immutable(void*))data.ptr)[0 .. data.length];
    zmq_sendmsg(socket, &reply, 0);
    zmq_msg_close(&reply);
  }

  //zmq_close(socket);
  //zmq_term(context);
}

char[] asString(ubyte[] data) @safe pure {
    auto s = cast(typeof(return)) data;
    import std.utf: validate;
    validate(s);
    return s;
}
