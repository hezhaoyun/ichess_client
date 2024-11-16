class ManualInfo {
  final String file;
  final int count;
  final String event;

  ManualInfo({
    required this.file,
    required this.count,
    required this.event,
  });

  factory ManualInfo.fromJson(Map<String, dynamic> json) {
    return ManualInfo(
      file: json['file'] as String,
      count: json['count'] as int,
      event: json['event'] as String,
    );
  }
}
