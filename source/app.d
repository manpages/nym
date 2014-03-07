import std.stdio;
import std.exception;
import std.conv;
import std.string;
import deimos.zmq.zmq;

int main(string args[]) {
  if(args.length == 1) {
    writeln("Not enough arguments.");
    return 1;
  }
  string data = args[1];
  foreach(arg; args[2 .. $]) {
    data ~= (' ' ~ arg);
  }
  writeln(`We want to send "`, data, `" of length `, data.length);
  // Initialize zmq and zmq socket
  writeln(`Initializing zmq socket`);
  void* context = zmq_init(1);
  void* socket  = zmq_socket(context, ZMQ_REQ);
  writeln(`Done.`);
  writeln(`Connecting to zmq server`);
  // Connect to zmq server, mutates socket!
  zmq_connect(socket, toStringz(`tcp://localhost:67831`));
  writeln(`Done.`);

  writeln(`Preparing request`);
  // Prepare mutable request variable
  zmq_msg_t msg;
  //zmq_msg_init_data(&msg, cast(void*)data.ptr, data.length);
  zmq_msg_init_size(&msg, data.length);
  // memcpy via slicing
  (zmq_msg_data(&msg))[0 .. data.length] = (cast(immutable(void*))data.ptr)[0 .. data.length];
  // let's make sure that shit works
  /*** This code:
   ***  foreach(j; 0 .. 2){
   ***    writeln(j);
   ***  }
   *** prints
   ***  0
   ***  1
   *** The more you learn.
   ***/
  foreach(i; 0 .. data.length) {
    writeln(i);
    char character = (cast(ubyte*)zmq_msg_data(&msg))[i];
    writeln(character);
  }
  writeln(`Done.`);
  writeln(`Sending request`);
  zmq_sendmsg(socket, &msg, 0);
  zmq_msg_close(&msg);
  writeln(`Done.`);

  writeln(`Getting reply`);
  zmq_msg_t reply;
  zmq_msg_init(&reply);
  ulong bytes = zmq_recvmsg(socket, &reply, 0);
  writeln(`Reply length: `, to!string(bytes));
  zmq_msg_close(&reply);
  writeln(`Done.`);

  // That's it for Zmq
  zmq_close(socket);
  zmq_term(context);

  writeln(`Pretty printing reply`);
  writeln(`:(`);
  writeln(`Done.`);
  return 0;
}
