import std.stdio;
import std.exception;
import std.conv;
import std.string;
import core.stdc.errno;
import vibe.data.json;
import deimos.zmq.zmq;

//testing
int main(string[] args) {
  if(args.length == 1) {
    writeln("Not enough arguments.");
    return 1;
  }
  string data = serializeToJson(args[1 .. $]).toString;
  // Initialize zmq and zmq socket
  void* context = zmq_init(1);
  void* socket  = zmq_socket(context, ZMQ_REQ);

  // Connect to zmq server, mutates socket!
  zmq_connect(socket, toStringz(`tcp://localhost:67831`));

  int timeout = 2500;
  zmq_setsockopt(socket, ZMQ_SNDTIMEO, &timeout, timeout.sizeof);
  zmq_setsockopt(socket, ZMQ_RCVTIMEO, &timeout, timeout.sizeof);

  // Prepare mutable request variable
  zmq_msg_t msg;
  zmq_msg_init_size(&msg, data.length);
  // memcpy via slicing
  (zmq_msg_data(&msg))[0 .. data.length] = (cast(immutable(void*))data.ptr)[0 .. data.length];
  zmq_sendmsg(socket, &msg, 0);

  zmq_msg_t reply;
  zmq_msg_init(&reply);
  long bytes = zmq_msg_recv(&reply, socket, 0);
  if(bytes == -1) {
    import core.stdc.errno; 
    writeln("Error: " ~ to!string(cast(char*)zmq_strerror(errno)));
    return -1;
  }
  immutable string reply_data = to!string((cast(char*)zmq_msg_data(&reply))[0 .. bytes]);
  zmq_msg_close(&reply);
  writeln(reply_data);

  // That's it for Zmq
  zmq_close(socket);
  //term never returns the control but why do we care, the process will terminate anyway.
  zmq_ctx_destroy(context);

  return 0;
}
