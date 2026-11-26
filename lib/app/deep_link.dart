/// Deep-Links aus dem Widget in die App (`simplestock://chart?symbol=NVDA`).
const chartHost = 'chart';

Uri chartUriFor(String symbol) => Uri(scheme: 'simplestock', host: chartHost, queryParameters: {'symbol': symbol});

String? chartSymbolFromUri(Uri? uri) {
  if (uri == null || uri.host != chartHost) return null;
  final s = uri.queryParameters['symbol'];
  return (s == null || s.isEmpty) ? null : s;
}
