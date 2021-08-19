import 'package:intl/intl.dart';

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(10000);
}
final DateFormat dateFormat = DateFormat('MMM dd, yyyy, hh:mm');
