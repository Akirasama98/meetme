import 'package:meetme/models/mahasiswa.dart';
import 'package:meetme/services/supabase_service.dart';

class MahasiswaRepository {
  final _mahasiswaTable = SupabaseService.client.from('mahasiswa');

  // Mendapatkan data mahasiswa berdasarkan ID
  Future<Mahasiswa?> getMahasiswaById(String id) async {
    try {
      final response = await _mahasiswaTable.select().eq('id', id);

      // Jika response kosong, kembalikan null
      if (response.isEmpty) {
        return null;
      }

      // Jika ada data, kembalikan data pertama
      return Mahasiswa.fromJson(response.first);
    } catch (e) {
      print('Error getting mahasiswa: $e');
      return null;
    }
  }

  // Mendapatkan data mahasiswa berdasarkan NIM
  Future<Mahasiswa?> getMahasiswaByNim(String nim) async {
    try {
      final response = await _mahasiswaTable.select().eq('nim', nim);

      // Jika response kosong, kembalikan null
      if (response.isEmpty) {
        return null;
      }

      // Jika ada data, kembalikan data pertama
      return Mahasiswa.fromJson(response.first);
    } catch (e) {
      print('Error getting mahasiswa by NIM: $e');
      return null;
    }
  }

  // Mendapatkan data mahasiswa berdasarkan user ID (untuk autentikasi)
  Future<Mahasiswa?> getMahasiswaByUserId(String userId) async {
    try {
      final response = await _mahasiswaTable.select().eq('user_id', userId);

      // Jika response kosong, kembalikan null
      if (response.isEmpty) {
        return null;
      }

      // Jika ada data, kembalikan data pertama
      return Mahasiswa.fromJson(response.first);
    } catch (e) {
      print('Error getting mahasiswa by user ID: $e');
      return null;
    }
  }

  // Mendapatkan jadwal bimbingan mahasiswa
  Future<List<Map<String, dynamic>>> getJadwalBimbingan(
    String mahasiswaId,
  ) async {
    try {
      final response = await SupabaseService.client
          .from('jadwal_bimbingan')
          .select('*, dosen(*)')
          .eq('mahasiswa_id', mahasiswaId)
          .order('tanggal', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting jadwal bimbingan: $e');
      return [];
    }
  }
}
