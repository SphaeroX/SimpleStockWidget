import 'package:intl/intl.dart';

final _price = NumberFormat('#,##0.00', 'de_DE');

String formatPrice(double value) => _price.format(value);

String formatSigned(double value) => _price.format(value);
