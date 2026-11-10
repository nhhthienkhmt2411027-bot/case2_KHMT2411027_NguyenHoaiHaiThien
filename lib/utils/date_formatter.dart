import 'package:intl/intl.dart';

class DateFormatter {
  static final _date = DateFormat('dd/MM/yyyy');
  static final _dateTime = DateFormat('dd/MM/yyyy HH:mm');

  static DateTime? parse(dynamic v) =>
      v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

  static String date(DateTime? d) => d == null ? '—' : _date.format(d);
  static String dateTime(DateTime? d) => d == null ? '—' : _dateTime.format(d);
}
