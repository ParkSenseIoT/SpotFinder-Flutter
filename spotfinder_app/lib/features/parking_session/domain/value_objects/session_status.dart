enum SessionStatus {
  active,
  closed,
  unknown;

  static SessionStatus fromString(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'ACTIVE':
        return SessionStatus.active;
      case 'CLOSED':
        return SessionStatus.closed;
      default:
        return SessionStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case SessionStatus.active:
        return 'Active';
      case SessionStatus.closed:
        return 'Closed';
      case SessionStatus.unknown:
        return 'Unknown';
    }
  }
}
