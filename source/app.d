import std.stdio;
import std.process;
import std.datetime;

struct RestartStrategy {
  public int max_restart_frequency = 5;
}

void main() {
  immutable strategy = (new RestartStrategy).max_restart_frequency = 10;
  while(true) {
    immutable time0 = Clock.currTime();

  }
}
