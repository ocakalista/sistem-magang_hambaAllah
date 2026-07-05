import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/admin_model.dart';
import '../models/mitra_model.dart';

class ApiService {
  // Gunakan 10.0.2.2 untuk Android emulator, 127.0.0.1 untuk platform lain.
  // Set base API URL. Use your Railway deployment as default.
  // If you still need to run against a local emulator use the localUrl instead.
  static final String productionUrl =
      'https://sistem-maganghambaallah-production.up.railway.app/api';
  static final String baseUrl = productionUrl;

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

  static Future<List<LowonganMitra>> fetchMitraLowongan(String? token) async {
    final url = Uri.parse('$baseUrl/mitra/lowongan');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final decoded = jsonDecode(response.body);
      final data =
          decoded is Map && decoded.containsKey('data')
              ? decoded['data']
              : decoded;

      if (data is List) {
        return data
            .cast<Map<String, dynamic>>()
            .map(LowonganMitra.fromJson)
            .toList();
      }

      throw Exception('Invalid response format for Mitra lowongan');
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<PendingLowongan>> fetchAdminLowongan(String? token) async {
    final url = Uri.parse('$baseUrl/admin/lowongan');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final decoded = jsonDecode(response.body);
      final data =
          decoded is Map && decoded.containsKey('data')
              ? decoded['data']
              : decoded;

      if (data is List) {
        return data
            .cast<Map<String, dynamic>>()
            .map(PendingLowongan.fromJson)
            .toList();
      }

      throw Exception('Invalid response format for admin lowongan');
    } catch (e) {
      rethrow;
    }
  }

  static Future<AdminProfile> fetchAdminProfile(String? token) async {
    final url = Uri.parse('$baseUrl/admin/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final decoded = jsonDecode(response.body);
      final data =
          decoded is Map && decoded.containsKey('data')
              ? decoded['data']
              : decoded;

      if (data is Map<String, dynamic>) {
        return AdminProfile.fromJson(data);
      }

      if (data is Map) {
        return AdminProfile.fromJson(data.cast<String, dynamic>());
      }

      throw Exception('Invalid response format for Admin profile');
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<UserAccount>> fetchUsers(String? token) async {
    final url = Uri.parse('$baseUrl/admin/users');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final decoded = jsonDecode(response.body);
      final data =
          decoded is Map && decoded.containsKey('data')
              ? decoded['data']
              : decoded;

      if (data is List) {
        return data
            .cast<Map<String, dynamic>>()
            .map(UserAccount.fromJson)
            .toList();
      }

      throw Exception('Invalid response format for users list');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> approveLowongan(String? token, String id) async {
    final url = Uri.parse('$baseUrl/admin/lowongan/$id/approve');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to approve lowongan: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> rejectLowongan(
    String? token,
    String id,
    String reason,
  ) async {
    final url = Uri.parse('$baseUrl/admin/lowongan/$id/reject');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to reject lowongan: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
