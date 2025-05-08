import 'package:flutter/material.dart';
import 'package:meetme/services/supabase_service.dart';

class DatabaseViewerPage extends StatefulWidget {
  const DatabaseViewerPage({super.key});

  @override
  State<DatabaseViewerPage> createState() => _DatabaseViewerPageState();
}

class _DatabaseViewerPageState extends State<DatabaseViewerPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _usersData = [];
  List<Map<String, dynamic>> _dosenData = [];
  List<Map<String, dynamic>> _mahasiswaData = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Ambil data dari tabel users
      final usersResponse = await SupabaseService.client.from('users').select('*');
      
      // Ambil data dari tabel dosen
      final dosenResponse = await SupabaseService.client.from('dosen').select('*');
      
      // Ambil data dari tabel mahasiswa
      final mahasiswaResponse = await SupabaseService.client.from('mahasiswa').select('*');

      setState(() {
        _usersData = List<Map<String, dynamic>>.from(usersResponse);
        _dosenData = List<Map<String, dynamic>>.from(dosenResponse);
        _mahasiswaData = List<Map<String, dynamic>>.from(mahasiswaResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Viewer'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTableSection('Users Table', _usersData),
                      const SizedBox(height: 24),
                      _buildTableSection('Dosen Table', _dosenData),
                      const SizedBox(height: 24),
                      _buildTableSection('Mahasiswa Table', _mahasiswaData),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTableSection(String title, List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        data.isEmpty
            ? const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No data found'),
                ),
              )
            : Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: _getColumns(data.first),
                    rows: _getRows(data),
                  ),
                ),
              ),
      ],
    );
  }

  List<DataColumn> _getColumns(Map<String, dynamic> firstRow) {
    return firstRow.keys.map((key) => DataColumn(label: Text(key))).toList();
  }

  List<DataRow> _getRows(List<Map<String, dynamic>> data) {
    return data.map((row) {
      return DataRow(
        cells: row.values.map((value) => DataCell(Text(value?.toString() ?? 'null'))).toList(),
      );
    }).toList();
  }
}
