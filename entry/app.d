import std.stdio;
import std.exception;
import std.conv;
import std.string;
import core.stdc.errno;
import deimos.zmq.zmq;

//testing
int main(string args[]) {
  if(args.length == 1) {
    writeln("Not enough arguments.");
    return 1;
  }
  string data = args[1];
  foreach(arg; args[2 .. $]) {
    data ~= (' ' ~ arg);
  }
  // Initialize zmq and zmq socket
  writeln(`Initializing zmq socket`);
  void* context = zmq_init(1);
  void* socket  = zmq_socket(context, ZMQ_REQ);

  writeln(`Done.`);
  writeln(`Connecting to zmq server`);
  // Connect to zmq server, mutates socket!
  zmq_connect(socket, toStringz(`tcp://localhost:67831`));
  writeln(`Done.`);

  int timeout = 2500;
  zmq_setsockopt(socket, ZMQ_SNDTIMEO, &timeout, timeout.sizeof);
  zmq_setsockopt(socket, ZMQ_RCVTIMEO, &timeout, timeout.sizeof);

  writeln(`Preparing request`);
  // Prepare mutable request variable
  zmq_msg_t msg;
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
  writeln("");
  writeln(`Done.`);
  writeln(`Sending request`);
  zmq_sendmsg(socket, &msg, 0);
  writeln(`Done.`);

  writeln(`Getting reply`);
  zmq_msg_t reply;
  zmq_msg_init(&reply);
  long bytes = zmq_recvmsg(socket, &reply, 0);
  if(bytes != -1) {
    writeln(`Reply length: `, to!string(bytes));
  } else {
    writeln(to!string(cast(char*)zmq_strerror(errno)));
  }
  zmq_msg_close(&reply);
  writeln(`Done.`);

  // That's it for Zmq
  zmq_close(socket);
  writeln(`Closed socket.`);
  //term never returns the control but why do we care, the process will terminate anyway.
  //zmq_term(context);
  //writeln(`Terminated context.`);

  writeln(`Pretty printing reply`);
  writeln(`:(`);
  writeln(`Done.`);
  return 0;
}
