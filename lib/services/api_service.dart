import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/admin_model.dart';
import '../models/mitra_model.dart';
import '../models/application_model.dart';

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;
  static const Duration _timeout = Duration(seconds: 20);

  static Map<String, String> _headers(String? token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  static dynamic _decode(http.Response response) {
    dynamic body;
    try {
      body =
          response.body.isEmpty
              ? <String, dynamic>{}
              : jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Server mengirim respons yang tidak valid (${response.statusCode}).',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map ? body['message'] : null;
      throw Exception(
        message?.toString() ?? 'Permintaan gagal (${response.statusCode}).',
      );
    }
    return body;
  }

  static List<dynamic> _dataList(dynamic decoded) {
    final data = decoded is Map ? decoded['data'] : decoded;
    if (data is List) return data;
    throw Exception('Format data dari server tidak sesuai.');
  }

  static Future<Map<String, dynamic>> fetchCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: _headers(token),
    );
    final decoded = _decode(response);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return decoded.cast<String, dynamic>();
    throw Exception('Format profil pengguna tidak sesuai.');
  }

  static Future<List<Map<String, dynamic>>> fetchNotifications(
    String token,
  ) async {
    final response = await http
        .get(ApiConfig.uri('/notifications'), headers: _headers(token))
        .timeout(_timeout);
    return _dataList(
      _decode(response),
    ).whereType<Map>().map((item) => item.cast<String, dynamic>()).toList();
  }

  static Future<void> markNotificationAsRead(
    String token,
    String notificationId,
  ) async {
    final response = await http
        .patch(
          ApiConfig.uri('/notifications/$notificationId/read'),
          headers: _headers(token),
        )
        .timeout(_timeout);
    _decode(response);
  }

  static Future<void> markAllNotificationsAsRead(String token) async {
    final response = await http
        .patch(
          ApiConfig.uri('/notifications/read-all'),
          headers: _headers(token),
        )
        .timeout(_timeout);
    _decode(response);
  }

  static Future<Map<String, dynamic>> login(
    String emailOrNim,
    String password,
  ) async {
    final url = ApiConfig.uri('/login');
    try {
      final response = await http.post(
        url,
        headers: _headers(null),
        body: jsonEncode({'email_or_nim': emailOrNim, 'password': password}),
      );
      final decoded = _decode(response);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.cast<String, dynamic>();
      throw Exception('Format respons login tidak sesuai.');
    } catch (e) {
      return {'message': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      ApiConfig.uri('/register'),
      headers: _headers(null),
      body: jsonEncode(payload),
    );
    final decoded = _decode(response);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return decoded.cast<String, dynamic>();
    throw Exception('Format respons register tidak sesuai.');
  }

  static Future<List<Map<String, dynamic>>> fetchMitra() async {
    return _dataList(
      _decode(await http.get(ApiConfig.uri('/mitra'), headers: _headers(null))),
    ).whereType<Map>().map((item) => item.cast<String, dynamic>()).toList();
  }

  static Future<List<LowonganMitra>> fetchMitraLowongan(String? token) async {
    // Helper: try to find a List anywhere in the decoded payload
    List<Map<String, dynamic>>? extractList(dynamic node) {
      if (node == null) return null;
      if (node is List) {
        try {
          return node.cast<Map<String, dynamic>>();
        } catch (_) {
          return node.map((e) => e as Map<String, dynamic>).toList();
        }
      }
      if (node is Map<String, dynamic>) {
        for (final key in [
          'data',
          'lowongan',
          'lowongans',
          'items',
          'results',
        ]) {
          if (node.containsKey(key)) {
            final candidate = extractList(node[key]);
            if (candidate != null) return candidate;
          }
        }

        for (final value in node.values) {
          final candidate = extractList(value);
          if (candidate != null) return candidate;
        }
      }
      return null;
    }

    final response = await http
        .get(ApiConfig.uri('/mitra/lowongan'), headers: _headers(token))
        .timeout(_timeout);
    final decoded = _decode(response);
    final list = extractList(decoded);
    if (list == null) {
      throw Exception('Format daftar lowongan mitra tidak sesuai.');
    }
    return list.map(LowonganMitra.fromJson).toList();
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

  static Future<List<PendingLowongan>> fetchPublicLowonganForAdmin() async {
    final response = await http
        .get(ApiConfig.uri('/lowongan'), headers: _headers(null))
        .timeout(_timeout);
    return _dataList(_decode(response)).whereType<Map>().map((item) {
      final data = item.cast<String, dynamic>();
      return PendingLowongan.fromJson({...data, 'status_approval': 'approved'});
    }).toList();
  }

  static Future<List<StudentEnrollment>> fetchAdminEnrollments(
    String token,
  ) async {
    final response = await http
        .get(ApiConfig.uri('/admin/enrollments'), headers: _headers(token))
        .timeout(_timeout);
    return _dataList(_decode(response))
        .whereType<Map>()
        .map((item) => StudentEnrollment.fromJson(item.cast<String, dynamic>()))
        .toList();
  }

  static Future<Map<String, dynamic>> fetchAdminUserDetail(
    String token,
    String id,
  ) async {
    final response = await http
        .get(ApiConfig.uri('/admin/users/$id'), headers: _headers(token))
        .timeout(_timeout);
    final decoded = _decode(response);
    final data = decoded is Map ? decoded['data'] ?? decoded : decoded;
    if (data is Map) return data.cast<String, dynamic>();
    throw Exception('Format detail pengguna tidak sesuai.');
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
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 404) {
        response = await http.put(
          ApiConfig.uri('/admin/lowongan/$id/validasi'),
          headers: _headers(token),
          body: jsonEncode({'status_approval': 'approved'}),
        );
      }
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
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'reason': reason}),
      );
      if (response.statusCode == 404) {
        response = await http.put(
          ApiConfig.uri('/admin/lowongan/$id/validasi'),
          headers: _headers(token),
          body: jsonEncode({'status_approval': 'rejected'}),
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to reject lowongan: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Internship>> fetchLowonganMahasiswa(String? token) async {
    final url = Uri.parse('$baseUrl/lowongan');
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      final decoded = _decode(response);
      return _dataList(decoded)
          .whereType<Map>()
          .map((item) => Internship.fromJson(item.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchLowonganDetail(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/lowongan/$id'),
      headers: _headers(null),
    );
    final decoded = _decode(response);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return decoded.cast<String, dynamic>();
    throw Exception('Format detail lowongan tidak sesuai.');
  }

  static Future<List<Map<String, dynamic>>> fetchApplicationHistory(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pendaftaran/riwayat'),
      headers: _headers(token),
    );
    return _dataList(
      _decode(response),
    ).whereType<Map>().map((item) => item.cast<String, dynamic>()).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchLogbooks(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/logbook'),
      headers: _headers(token),
    );
    return _dataList(
      _decode(response),
    ).whereType<Map>().map((item) => item.cast<String, dynamic>()).toList();
  }

  static Future<Map<String, dynamic>> createLogbook({
    required String token,
    required String applicationId,
    required int week,
    required DateTime date,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logbook'),
      headers: _headers(token),
      body: jsonEncode({
        'id_pendaftaran': applicationId,
        'minggu_ke': week,
        'tanggal': date.toIso8601String().split('T').first,
        'deskripsi_kegiatan': description,
      }),
    );
    final decoded = _decode(response);
    return decoded is Map<String, dynamic>
        ? decoded
        : Map<String, dynamic>.from(decoded as Map);
  }

  static Future<List<Map<String, dynamic>>> fetchApplicants(
    String token,
    String lowonganId,
  ) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/lowongan/$lowonganId/pelamar'),
          headers: _headers(token),
        )
        .timeout(_timeout);
    return _dataList(_decode(response))
        .whereType<Map>()
        .map(
          (item) => <String, dynamic>{
            ...item.cast<String, dynamic>(),
            'id_lowongan': lowonganId,
          },
        )
        .toList();
  }

  static Future<void> updateApplicantStatus(
    String token,
    String applicationId,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pendaftaran/$applicationId/status'),
      headers: _headers(token),
      body: jsonEncode({'status': status}),
    );
    _decode(response);
  }

  static Future<void> updateLogbookStatus(
    String token,
    String logbookId,
    String status,
    String feedback,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/logbook/$logbookId/status'),
      headers: _headers(token),
      body: jsonEncode({'status_validasi': status, 'feedback_dosen': feedback}),
    );
    _decode(response);
  }

  static Future<LowonganMitra> createLowongan(
    String token,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lowongan'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );
    final decoded = _decode(response);
    final data = decoded is Map ? decoded['data'] : null;
    if (data is Map) {
      return LowonganMitra.fromJson(data.cast<String, dynamic>());
    }
    throw Exception('Server tidak mengembalikan data lowongan yang dibuat.');
  }

  static Future<Map<String, dynamic>> fetchAdminDashboard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard'),
      headers: _headers(token),
    );
    final decoded = _decode(response);
    final data = decoded is Map ? decoded['data'] : null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.cast<String, dynamic>();
    throw Exception('Format statistik admin tidak sesuai.');
  }

  static Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: _headers(token),
    );
    _decode(response);
  }

  static Future<List<dynamic>> fetchMahasiswaBimbingan(String? token) async {
    final response = await http
        .get(ApiConfig.uri('/dosen/bimbingan'), headers: _headers(token))
        .timeout(_timeout);
    return _dataList(_decode(response));
  }

  // Fungsi untuk mengirim lamaran dan menangkap pesan error asli dari Laravel
  static Future<Map<String, dynamic>> applyInternship({
    required String token,
    required String lowonganId,
    required String fullName,
    required String phone,
    required String semester,
    required String motivation,
    required List<int> cvBytes,
    required String cvFileName,
    List<int>? portfolioBytes,
    String? portfolioFileName,
    String? portfolioLink,
  }) async {
    final url = Uri.parse('$baseUrl/pendaftaran');
    try {
      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Data Teks
      request.fields['id_lowongan'] = lowonganId;
      request.fields['nama_lengkap'] = fullName;
      request.fields['no_telp'] = phone;
      request.fields['semester'] = semester;
      request.fields['motivasi'] = motivation;
      if (portfolioLink != null && portfolioLink.isNotEmpty) {
        request.fields['portofolio_link'] = portfolioLink;
      }

      // File CV
      request.files.add(
        http.MultipartFile.fromBytes(
          'berkas_cv',
          cvBytes,
          filename: cvFileName,
        ),
      );

      // File Portofolio
      if (portfolioBytes != null && portfolioFileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'berkas_portofolio',
            portfolioBytes,
            filename: portfolioFileName,
          ),
        );
      }

      final response = await request.send().timeout(_timeout);
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Lamaran terkirim!'};
      } else {
        return {
          'success': false,
          'message': 'Error ${response.statusCode}: $responseString',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi terputus / CORS: $e'};
    }
  }
}
