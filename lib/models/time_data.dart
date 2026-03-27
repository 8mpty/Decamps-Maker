class TimeData {
  final int hour;
  final int minute;
  final int second;

  TimeData(this.hour, this.minute, this.second);

  int toSeconds() {
    return hour * 3600 + minute * 60 + second;
  }

  String formatTime() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return formatTime();
  }

  static TimeData? fromStrings(String hourStr, String minuteStr, String secondStr) {
    final hour = int.tryParse(hourStr);
    final minute = int.tryParse(minuteStr);
    final second = int.tryParse(secondStr);
    
    if (hour == null || minute == null || second == null) {
      return null;
    }
    
    return TimeData(hour, minute, second);
  }
}
