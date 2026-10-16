String formatIncidentNumber({
  required String number,
  required DateTime date,
  bool hideDateFormat = false,
}) {
  if (hideDateFormat) return number;
  final y4 = date.year.toString().padLeft(4, '0');
  final m2 = date.month.toString().padLeft(2, '0');
  final d2 = date.day.toString().padLeft(2, '0');
  return '/$y4$m2$d2/$number';
}
