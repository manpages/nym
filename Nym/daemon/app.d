import std.stdio;
import std.process;
import std.datetime;

int main() {
  auto max_restart_frequency = 10;
  auto max_restarts = 5;
  auto restarts = 0;
  while(true) {
    auto τ0 = Clock.currTime();
    auto pid = start_daemon();
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

Pid start_daemon() {
  try {
    return spawnProcess(`nym_node`);
  } catch {
    return spawnProcess(`bin/nym_node`);
  }
}
