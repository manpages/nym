import std.stdio;
import std.exception;
import std.conv;
import std.string;
import deimos.zmq.zmq;

int main(string args[]) {
  if(! args[1]) {
    writeln("Not enough arguments.");
    return 1;
  }
  string data = args[1];
  foreach(arg; args[2 .. $]) {
    data ~= (' ' ~ arg);
  }
  // Initialize zmq and zmq socket
  void* context = zmq_init(1);
  void* socket  = zmq_socket(context, ZMQ_REQ);
  // Connect to zmq server, mutates socket!
  zmq_connect(socket, toStringz(`tcp://localhost:67831`));

  // Prepare mutable request variable
  zmq_msg_t msg;
  //zmq_msg_init_data(&msg, cast(void*)data.ptr, data.length);
  zmq_msg_init_size(&msg, data.length);
  // memcpy via slicing
  (zmq_msg_data(&msg))[0 .. data.length] = (cast(immutable(void*))data.ptr)[0 .. data.length];
  zmq_sendmsg(socket, &msg, 0);
  zmq_msg_close(&msg);

  zmq_msg_t reply;
  zmq_msg_init(&reply);
  int bytes = zmq_recvmsg(socket, &reply, 0);
  zmq_msg_close(&reply);

  // That's it for Zmq
  zmq_term(context);

  pretty_print(reply, bytes);
  return 0;
}

void pretty_print(zmq_msg_t msg, const int length) {
  string data = to!string(zmq_msg_data(&msg));
  writeln(data);
}
