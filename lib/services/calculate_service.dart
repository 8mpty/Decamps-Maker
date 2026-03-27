import '../models/time_data.dart';

class CalculateService {
  static String calculateActivation(TimeData? assignTime, TimeData? enrouteTime) {
    if (assignTime == null || enrouteTime == null) {
      return "CC";
    }
    return _calculateTimeDifference(assignTime, enrouteTime);
  }

  static String calculateResponse(TimeData? assignTime, TimeData? arriveTime) {
    if (assignTime == null || arriveTime == null) {
      return "CC";
    }
    return _calculateTimeDifference(assignTime, arriveTime);
  }

  static String _calculateTimeDifference(TimeData startTime, TimeData endTime) {
    int startTotalSeconds = startTime.toSeconds();
    int endTotalSeconds = endTime.toSeconds();
    
    int difference;
    if (endTotalSeconds >= startTotalSeconds) {
      difference = endTotalSeconds - startTotalSeconds;
    } else {
      difference = (endTotalSeconds + 24 * 3600) - startTotalSeconds;
    }
    
    return _formatDuration(difference);
  }

  static String _formatDuration(int totalSeconds) {
    if (totalSeconds < 60) {
      return "${totalSeconds}s";
    } else {
      int minutes = totalSeconds ~/ 60;
      int seconds = totalSeconds % 60;
      return "${minutes}m ${seconds}s";
    }
  }
}