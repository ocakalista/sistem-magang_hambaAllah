import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ini adalah alamat server Laravel lokalmu
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // Fungsi untuk menembak API Login
  static Future<Map<String, dynamic>> login(
    String emailOrNim,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email_or_nim': emailOrNim, 'password': password}),
      );

      // Mengembalikan jawaban dari Laravel (berupa token & pesan error/sukses)
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': 'Gagal terhubung ke server: $e'};
    }
  }
}
