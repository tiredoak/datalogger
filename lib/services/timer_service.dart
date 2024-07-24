import 'dart:async';

class TimerService {
  Timer? _timer;
  int _elapsedSeconds = 0;

  void startTimer(void Function(int) onTick) {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _elapsedSeconds++;
      onTick(_elapsedSeconds);
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
  }

  int get elapsedSeconds => _elapsedSeconds;
}
