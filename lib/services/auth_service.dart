import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meetme/services/supabase_service.dart';
import 'package:meetme/repositories/mahasiswa_repository.dart';
import 'package:meetme/models/mahasiswa.dart';

class AuthService {
  final _auth = SupabaseService.auth;
  final _mahasiswaRepository = MahasiswaRepository();

  // Mendapatkan user saat ini
  User? get currentUser => _auth.currentUser;

  // Mendapatkan status login
  bool get isLoggedIn => _auth.currentUser != null;

  // Login dengan email dan password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithPassword(email: email, password: password);
  }

  // Mendaftar dengan email dan password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _auth.signUp(email: email, password: password);
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Mendapatkan data mahasiswa yang sedang login
  Future<Mahasiswa?> getCurrentMahasiswa() async {
    if (!isLoggedIn) return null;

    return await _mahasiswaRepository.getMahasiswaByUserId(currentUser!.id);
  }

  // Mendapatkan data pengguna dari database
  Future<Map<String, dynamic>?> getUserData(String userId) async {
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

      // Ambil data tambahan berdasarkan role
      if (user['role'] == 'dosen') {
        final dosenData = await getDosenData(userId);
        if (dosenData != null) {
          name = dosenData['nama'];
          // Tambahkan data dosen ke user data
          user['nama'] = name;
          user['name'] = name; // Untuk kompatibilitas
        }
      } else if (user['role'] == 'mahasiswa') {
        final mahasiswa = await getCurrentMahasiswa();
        if (mahasiswa != null) {
          name = mahasiswa.nama;
          // Tambahkan data mahasiswa ke user data
          user['nama'] = name;
          user['name'] = name; // Untuk kompatibilitas
        }
      }

      print('User data: $user'); // Debugging
      return user;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Mendapatkan data dosen dari database
  Future<Map<String, dynamic>?> getDosenData(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('dosen')
          .select()
          .eq('user_id', userId);

      // Jika response kosong, kembalikan null
      if (response.isEmpty) {
        return null;
      }

      // Jika ada data, kembalikan data pertama
      return response.first;
    } catch (e) {
      print('Error getting dosen data: $e');
      return null;
    }
  }
}
