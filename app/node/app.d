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
    writeln("Initializing zmq message");
    zmq_msg_t req;
    zmq_msg_init(&req);
    writeln("Done.");
    writeln("Getting request");
    string fuckyeah;
    /*
    foreach(i; 0 .. zmq_recvmsg(socket, &req, 0)) {
      fuckyeah = to!string(cast(char*)zmq_msg_data(&req));
      write((cast(char*)zmq_msg_data(&req))[i]);
    }
    */
    ulong bytes = zmq_recvmsg(socket, &req, 0);
    fuckyeah = "Received: " ~ to!string((cast(char*)zmq_msg_data(&req))[0 .. bytes]);
    writeln("");
    writeln("Fuck yeah ", fuckyeah);
    zmq_msg_close(&req);
    writeln("Done.");

    // todo: add fibers
    zmq_msg_t reply;
    zmq_msg_init_size(&reply, fuckyeah.length);
    (zmq_msg_data(&reply))[0 .. fuckyeah.length] = (cast(immutable(void*))fuckyeah.ptr)[0 .. fuckyeah.length];
    zmq_sendmsg(socket, &reply, 0);
    zmq_msg_close(&reply);
  }

  //zmq_close(socket);
  //zmq_term(context);
}
