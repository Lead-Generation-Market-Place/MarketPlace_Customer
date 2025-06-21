class DateFormatHelper {
  String formatDate(String unformattedDate) {
    final planDateRaw = unformattedDate ?? '';
    if (planDateRaw.isNotEmpty) {
      final date = DateTime.tryParse(planDateRaw);
      if (date != null) {
        return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      }
    }
    return '';
  }
}
