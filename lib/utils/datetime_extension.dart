extension DateTimeExtension on DateTime {
  String toCustomString() {
    return "${this.month.toString().padLeft(2, '0')}-${this.day.toString().padLeft(2, '0')}-${this.year}";
  }
}
