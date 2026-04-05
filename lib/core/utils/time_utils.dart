class TimeUtils {
  /// Formats seconds into a compact string like "1h 45m" or "2d 4h" or "45m"
  static String formatDuration(int totalSeconds) {
    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    }

    final int days = totalSeconds ~/ (24 * 3600);
    final int hours = (totalSeconds % (24 * 3600)) ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;

    List<String> parts = [];

    if (days > 0) {
      parts.add('${days}d');
      if (hours > 0) parts.add('${hours}h');
      // If we have days, we usually drop minutes to keep it compact
    } else if (hours > 0) {
      parts.add('${hours}h');
      if (minutes > 0) parts.add('${minutes}m');
    } else {
      parts.add('${minutes}m');
    }

    return parts.join(' ');
  }
}
