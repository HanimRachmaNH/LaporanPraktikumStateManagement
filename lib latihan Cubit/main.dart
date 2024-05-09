import 'package:flutter/material.dart'; // Paket yang menyediakan berbagai widget dan alat UI untuk membangun aplikasi Flutter
import 'package:http/http.dart' as http; // Paket untuk melakukan HTTP request
import 'dart:convert'; // Paket untuk mengonversi data dari dan ke format JSON
import 'package:flutter_bloc/flutter_bloc.dart'; // Paket untuk menggunakan BLoC (Business Logic Component) dalam aplikasi Flutter

class University { // Kelas untuk merepresentasikan data universitas
  final String name; // Properti untuk menyimpan nama universitas
  final String website; // Properti untuk menyimpan alamat website universitas

  University({required this.name, required this.website}); // Konstruktor untuk inisialisasi properti

  factory University.fromJson(Map<String, dynamic> json) { // Factory method untuk membuat instance University dari JSON
    return University(
      name: json['name'], // Mendapatkan nama universitas dari JSON
      website: json['web_pages'][0], // Mendapatkan alamat website universitas dari JSON
    );
  }
}

class UniversityCubit extends Cubit<List<University>> { // Cubit untuk mengelola state negara dan daftar universitas
  UniversityCubit() : super([]); // Constructor untuk menginisialisasi state dengan daftar universitas kosong

  Future<void> fetchUniversityData(String country) async { // Fungsi untuk mengambil data universitas dari API berdasarkan negara
    final response = await http.get(Uri.parse('http://universities.hipolabs.com/search?country=$country')); // Mengirimkan HTTP request untuk mendapatkan data universitas berdasarkan negara
    if (response.statusCode == 200) { // Jika respons berhasil
      List<dynamic> data = json.decode(response.body); // Mendekode JSON respons
      emit(data.map((json) => University.fromJson(json)).toList()); // Memperbarui state dengan daftar universitas yang telah diterima
    } else { // Jika respons gagal
      throw Exception('Failed to load university data'); // Melontarkan pengecualian
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University List', // Judul aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema warna primer aplikasi
      ),
      home: BlocProvider(
        create: (context) => UniversityCubit(), // Membuat instance UniversityCubit dan menyediakannya ke dalam widget-tree
        child: UniversityList(), // Menampilkan widget UniversityList sebagai halaman utama
      ),
    );
  }
}

class UniversityList extends StatefulWidget {
  @override
  _UniversityListState createState() => _UniversityListState();
}

class _UniversityListState extends State<UniversityList> {
  late String _selectedCountry; // Variabel untuk menyimpan negara yang dipilih
  late UniversityCubit _universityCubit; // Variabel untuk mengelola data universitas
  final List<String> countries = [ // Daftar negara-negara ASEAN
    'Indonesia',
    'Malaysia',
    'Singapore',
    'Thailand',
    'Vietnam'
  ];

  @override
  void initState() { // Override method initState() dari State untuk melakukan inisialisasi state
    super.initState();
    _selectedCountry = countries[0]; // Set negara awal menjadi Indonesia
    _universityCubit = BlocProvider.of<UniversityCubit>(context); // Mengambil instance UniversityCubit dari BlocProvider
    _universityCubit.fetchUniversityData(_selectedCountry); // Memanggil fungsi untuk mengambil data universitas
  }

  @override
  Widget build(BuildContext context) { // Override method build() untuk merender tampilan widget
    return Scaffold( // Widget untuk tata letak dasar aplikasi
      appBar: AppBar( // AppBar (bilah aplikasi) yang menampilkan judul aplikasi
        title: Text('University List'), // Judul AppBar
        actions: [ // Aksi AppBar
          DropdownButton<String>( // DropdownButton untuk memilih negara
            value: _selectedCountry, // Nilai default DropdownButton
            items: countries.map((String value) { // Mengonversi daftar negara menjadi daftar DropdownMenuItem
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) { // Ketika nilai DropdownButton berubah
              if (newValue != null) { // Jika nilai baru tidak null
                setState(() {
                  _selectedCountry = newValue; // Memperbarui negara yang dipilih
                });
                _universityCubit.fetchUniversityData(newValue); // Mengambil data universitas baru berdasarkan negara yang dipilih
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<UniversityCubit, List<University>>( // Membangun widget berdasarkan state UniversityCubit
        builder: (context, universities) { // Builder untuk merender widget
          return universities.isEmpty // Jika daftar universitas kosong
              ? Center(child: CircularProgressIndicator()) // Menampilkan indikator progres
              : ListView.builder( // ListView untuk menampilkan daftar universitas
                  itemCount: universities.length, // Jumlah item di ListView
                  itemBuilder: (context, index) { // Builder untuk setiap item di ListView
                    return ListTile( // ListTile untuk menampilkan setiap universitas dalam daftar
                      title: Text(universities[index].name), // Nama universitas
                      subtitle: Text(universities[index].website), // Alamat website universitas
                    );
                  },
                );
        },
      ),
    );
  }
}

void main() {
  runApp(MyApp()); // Memulai aplikasi Flutter
}