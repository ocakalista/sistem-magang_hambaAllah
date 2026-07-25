class ApiConfig {
  ApiConfig._();

  static const String baseUrl =
      'https://sistem-maganghambaallah-production-5b92.up.railway.app/api';

  static Uri uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }
}
