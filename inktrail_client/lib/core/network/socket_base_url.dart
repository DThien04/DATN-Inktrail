/// Derives Socket.IO base URL from REST [apiBaseUrl] (strips trailing `/api`).
String? socketBaseUrlFromApiBase(String? apiBaseUrl) {
  final raw = (apiBaseUrl ?? '').trim();
  if (raw.isEmpty) return null;
  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;

  var path = uri.path;
  if (path.endsWith('/api')) {
    path = path.substring(0, path.length - 4);
  } else if (path.endsWith('/api/')) {
    path = path.substring(0, path.length - 5);
  }
  if (path == '/') path = '';

  return uri.replace(path: path, query: '', fragment: '').toString();
}
