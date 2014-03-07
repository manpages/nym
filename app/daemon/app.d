import std.stdio;
import std.process;
import std.datetime;

int main() {
  auto max_restart_frequency = 10;
  auto max_restarts = 5;
  auto restarts = 0;
  while(true) {
    auto τ0 = Clock.currTime();
    auto pid = spawnProcess(`nym_node 2>/dev/null || bin/nym_node`);
    writeln(pid.osHandle);
    wait(pid);
    if ((Clock.currTime() - τ0) < dur!"msecs"(1000/max_restart_frequency)) {
      if(++restarts >= max_restarts) {
        writeln("Too many restarts");
        return 1;
      }
    } else {
      restarts = 0;
    }
  }
}
