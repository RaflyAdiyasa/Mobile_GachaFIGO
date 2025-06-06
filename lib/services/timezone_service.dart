class TimeZoneService {
  static DateTime convertTimeZone(DateTime originalTime, String targetZone) {
    final originalUtc = originalTime.toUtc();

    switch (targetZone) {
      case 'WIB':
        return originalUtc.add(Duration(hours: 7));
      case 'WITA':
        return originalUtc.add(Duration(hours: 8));
      case 'WIT':
        return originalUtc.add(Duration(hours: 9));
      case 'LONDON':
        return originalUtc.add(Duration(hours: 1));
      case 'USA':
        return originalUtc.add(Duration(hours: -5));
      case 'JEPANG':
        return originalUtc.add(Duration(hours: 9));
      default:
        return originalTime;
    }
  }

  static String getTimeZoneAbbreviation(String zone) {
    switch (zone) {
      case 'WIB':
        return 'WIB (UTC+7)';
      case 'WITA':
        return 'WITA (UTC+8)';
      case 'WIT':
        return 'WIT (UTC+9)';
      case 'LONDON':
        return 'LONDON (UTC+1)';
      case 'USA':
        return 'EST (UTC-5)';
      case 'JEPANG':
        return 'JST (UTC+9)';
      default:
        return 'WIB (UTC+7)';
    }
  }
}
