import 'package:meetme/services/supabase_service.dart';

class UserRepository {
  // Search for users with optional filtering
  Future<List<Map<String, dynamic>>> searchUsers({
    String? searchQuery,
    String? role,
    String? excludeUserId,
  }) async {
    try {
      print('Mencoba menggunakan fungsi SQL search_users');
      print(
        'Params: searchQuery=$searchQuery, role=$role, excludeUserId=$excludeUserId',
      );

      // Gunakan fungsi SQL untuk mencari pengguna
      final response = await SupabaseService.client.rpc(
        'search_users',
        params: {
          'search_query': searchQuery,
          'role_filter': role,
          'exclude_user_id': excludeUserId,
        },
      );

      print('Hasil dari fungsi SQL: ${response.length} pengguna ditemukan');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching users dengan fungsi SQL: $e');
      print('Beralih ke pendekatan alternatif...');

      // Jika fungsi SQL belum dibuat, gunakan pendekatan alternatif
      try {
        // Pendekatan alternatif: Ambil data langsung dari tabel
        print('Pendekatan alternatif: Ambil data langsung dari tabel');

        // Ambil semua data dosen
        print('Mengambil semua data dosen');
        final dosenResponse = await SupabaseService.client
            .from('dosen')
            .select('id, user_id, nama, profile_image_url');
        print('Data dosen: $dosenResponse');

        // Ambil semua data mahasiswa
        print('Mengambil semua data mahasiswa');
        final mahasiswaResponse = await SupabaseService.client
            .from('mahasiswa')
            .select('id, user_id, nama, profile_image_url');
        print('Data mahasiswa: $mahasiswaResponse');

        // Ambil semua data users
        print('Mengambil semua data users');
        final usersResponse = await SupabaseService.client
            .from('users')
            .select('id, email, role');
        print('Data users: $usersResponse');

        // Gabungkan data
        List<Map<String, dynamic>> allUsers = [];

        // Tambahkan dosen
        for (var dosen in dosenResponse) {
          // Cari data user yang sesuai
          final userData = usersResponse.firstWhere(
            (user) =>
                user['id'] == dosen['user_id'] || user['id'] == dosen['id'],
            orElse:
                () => {
                  'id': dosen['user_id'] ?? dosen['id'],
                  'role': 'dosen',
                  'email': '',
                },
          );

          if (excludeUserId != null && userData['id'] == excludeUserId) {
            continue; // Lewati user yang dikecualikan
          }

          if (role != null && role != 'all' && role != 'dosen') {
            continue; // Lewati jika filter role tidak sesuai
          }

          if (searchQuery != null &&
              searchQuery.isNotEmpty &&
              !dosen['nama'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              )) {
            continue; // Lewati jika nama tidak sesuai dengan pencarian
          }

          allUsers.add({
            'id': userData['id'],
            'name': dosen['nama'] ?? userData['email'],
            'role': 'dosen',
            'avatar': dosen['profile_image_url'],
          });
        }

        // Tambahkan mahasiswa
        for (var mahasiswa in mahasiswaResponse) {
          // Cari data user yang sesuai
          final userData = usersResponse.firstWhere(
            (user) =>
                user['id'] == mahasiswa['user_id'] ||
                user['id'] == mahasiswa['id'],
            orElse:
                () => {
                  'id': mahasiswa['user_id'] ?? mahasiswa['id'],
                  'role': 'mahasiswa',
                  'email': '',
                },
          );

          if (excludeUserId != null && userData['id'] == excludeUserId) {
            continue; // Lewati user yang dikecualikan
          }

          if (role != null && role != 'all' && role != 'mahasiswa') {
            continue; // Lewati jika filter role tidak sesuai
          }

          if (searchQuery != null &&
              searchQuery.isNotEmpty &&
              !mahasiswa['nama'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              )) {
            continue; // Lewati jika nama tidak sesuai dengan pencarian
          }

          allUsers.add({
            'id': userData['id'],
            'name': mahasiswa['nama'] ?? userData['email'],
            'role': 'mahasiswa',
            'avatar': mahasiswa['profile_image_url'],
          });
        }

        print('Total pengguna yang ditemukan: ${allUsers.length}');
        return allUsers;
      } catch (innerError) {
        print('Error in alternative search approach: $innerError');
        return [];
      }
    }
  }

  // Get user details by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      // Ambil data user dasar
      final userResponse = await SupabaseService.client
          .from('users')
          .select('id, email, role')
          .eq('id', userId);

      // Jika response kosong, kembalikan null
      if (userResponse.isEmpty) {
        return null;
      }

      // Ambil data user
      final user = userResponse.first;
      String? name;
      String? avatar;

      // Ambil data tambahan berdasarkan role
      if (user['role'] == 'dosen') {
        final dosenData = await getDosenDetails(userId);
        if (dosenData != null) {
          name = dosenData['nama'];
          avatar = dosenData['profile_image_url'];
        }
      } else if (user['role'] == 'mahasiswa') {
        final mahasiswaData = await getMahasiswaDetails(userId);
        if (mahasiswaData != null) {
          name = mahasiswaData['nama'];
          avatar = mahasiswaData['profile_image_url'];
        }
      }

      // Gabungkan data
      return {
        'id': user['id'],
        'email': user['email'],
        'role': user['role'],
        'name': name ?? user['email'],
        'avatar': avatar,
      };
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Get dosen details
  Future<Map<String, dynamic>?> getDosenDetails(String userId) async {
    try {
      print('Mencoba mendapatkan data dosen dengan user_id: $userId');

      // Coba dengan user_id
      var response = await SupabaseService.client
          .from('dosen')
          .select('*')
          .eq('user_id', userId);

      // Jika response kosong, coba dengan id
      if (response.isEmpty) {
        print('Data dosen tidak ditemukan dengan user_id, mencoba dengan id');
        response = await SupabaseService.client
            .from('dosen')
            .select('*')
            .eq('id', userId);
      }

      // Jika masih kosong, tampilkan semua data dosen untuk debugging
      if (response.isEmpty) {
        print('Data dosen masih tidak ditemukan, menampilkan semua data dosen');
        final allDosen = await SupabaseService.client.from('dosen').select('*');
        print('Semua data dosen: $allDosen');

        // Tampilkan struktur tabel dosen
        print('Mencoba mendapatkan struktur tabel dosen');
        try {
          final dosenTable = await SupabaseService.client.rpc(
            'get_table_columns',
            params: {'table_name': 'dosen'},
          );
          print('Struktur tabel dosen: $dosenTable');
        } catch (e) {
          print('Tidak bisa mendapatkan struktur tabel: $e');
        }

        return null;
      }

      // Jika ada data, kembalikan data pertama
      print('Data dosen ditemukan: ${response.first}');
      return response.first;
    } catch (e) {
      print('Error getting dosen details: $e');
      return null;
    }
  }

  // Get mahasiswa details
  Future<Map<String, dynamic>?> getMahasiswaDetails(String userId) async {
    try {
      print('Mencoba mendapatkan data mahasiswa dengan user_id: $userId');

      // Coba dengan user_id
      var response = await SupabaseService.client
          .from('mahasiswa')
          .select('*')
          .eq('user_id', userId);

      // Jika response kosong, coba dengan id
      if (response.isEmpty) {
        print(
          'Data mahasiswa tidak ditemukan dengan user_id, mencoba dengan id',
        );
        response = await SupabaseService.client
            .from('mahasiswa')
            .select('*')
            .eq('id', userId);
      }

      // Jika masih kosong, tampilkan semua data mahasiswa untuk debugging
      if (response.isEmpty) {
        print(
          'Data mahasiswa masih tidak ditemukan, menampilkan semua data mahasiswa',
        );
        final allMahasiswa = await SupabaseService.client
            .from('mahasiswa')
            .select('*');
        print('Semua data mahasiswa: $allMahasiswa');
        return null;
      }

      // Jika ada data, kembalikan data pertama
      print('Data mahasiswa ditemukan: ${response.first}');
      return response.first;
    } catch (e) {
      print('Error getting mahasiswa details: $e');
      return null;
    }
  }
}
