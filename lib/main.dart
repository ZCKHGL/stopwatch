// ===================================
// IMPORT LIBRARIES
// ===================================
// Library untuk membuat UI Flutter
import 'package:flutter/material.dart';
// Library untuk menangani input keyboard
import 'package:flutter/services.dart';
// Library untuk Timer (menjalankan stopwatch)
import 'dart:async';

// ===================================
// FUNGSI UTAMA APLIKASI
// ===================================
// Fungsi main adalah entry point aplikasi
void main() {
  runApp(const MainApp());
}

// ===================================
// CLASS UTAMA APLIKASI (STATELESS)
// ===================================
// MainApp adalah widget root yang mengatur tema dan halaman utama
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Menyembunyikan banner debug di pojok kanan atas
      debugShowCheckedModeBanner: false,
      // Mengatur tema aplikasi dengan mode gelap
      theme: ThemeData(
        brightness: Brightness.dark,
        // Warna background utama (hitam gelap)
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        // Skema warna untuk elemen UI
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00E5FF), // Cyan untuk highlight
          secondary: const Color(0xFF1A1A1A), // Abu gelap
        ),
      ),
      // Halaman pertama yang ditampilkan
      home: const StopwatchScreen(),
    );
  }
}

// ===================================
// HALAMAN STOPWATCH (STATEFUL)
// ===================================
// StatefulWidget karena UI berubah saat stopwatch berjalan
class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  // ===================================
  // VARIABEL STATE
  // ===================================
  Timer? _timer;              // Timer untuk menjalankan stopwatch setiap 10ms
  int _milliseconds = 0;      // Waktu yang sudah berjalan (dalam milliseconds)
  bool _isRunning = false;    // Status stopwatch (jalan/pause)
  List<int> _laps = [];       // Daftar waktu lap yang disimpan       // Daftar waktu lap yang disimpan

  // ===================================
  // FUNGSI: TAMBAH LAP
  // ===================================
  // Menyimpan waktu saat ini ke dalam daftar lap (hanya jika stopwatch berjalan)
  void _addLap() {
    if (_isRunning) {
      setState(() {
        // Insert di index 0 agar lap terbaru muncul di atas
        _laps.insert(0, _milliseconds);
      });
    }
  }

  // ===================================
  // FUNGSI: START/PAUSE STOPWATCH
  // ===================================
  // Toggle antara mulai dan pause stopwatch
  void _startStop() {
    if (_isRunning) {
      // Jika sedang berjalan, hentikan timer
      _timer?.cancel();
    } else {
      // Jika tidak berjalan, mulai timer yang update setiap 10ms
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() {
          _milliseconds += 10; // Tambah waktu setiap 10ms
        });
      });
    }
    setState(() {
      _isRunning = !_isRunning; // Toggle status running
    });
  }

  // ===================================
  // FUNGSI: RESET STOPWATCH
  // ===================================
  // Mengembalikan stopwatch ke 0 dan menghapus semua lap
  void _reset() {
    _timer?.cancel();          // Hentikan timer
    setState(() {
      _milliseconds = 0;       // Reset waktu ke 0
      _isRunning = false;      // Status jadi tidak berjalan
      _laps.clear();           // Hapus semua lap
    });
  }

  // ===================================
  // FUNGSI: FORMAT WAKTU UTAMA
  // ===================================
  // Mengubah milliseconds menjadi format MM:SS:MS (contoh: 01:23:45)
  String _formatTime() {
    int minutes = (_milliseconds ~/ 60000);        // Konversi ke menit
    int seconds = ((_milliseconds % 60000) ~/ 1000); // Sisa ke detik
    int milliseconds = ((_milliseconds % 1000) ~/ 10); // Sisa ke milidetik (dalam 1/100 detik)

    // PadLeft(2, '0') = tambahkan 0 di depan jika kurang dari 2 digit
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${milliseconds.toString().padLeft(2, '0')}';
  }

  // ===================================
  // FUNGSI: FORMAT WAKTU LAP
  // ===================================
  // Sama seperti _formatTime tapi untuk waktu lap
  String _formatLapTime(int ms) {
    int minutes = (ms ~/ 60000);
    int seconds = ((ms % 60000) ~/ 1000);
    int milliseconds = ((ms % 1000) ~/ 10);

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${milliseconds.toString().padLeft(2, '0')}';
  }

  // ===================================
  // DISPOSE: BERSIHKAN RESOURCE
  // ===================================
  // Dipanggil saat widget dihancurkan, untuk menghentikan timer
  @override
  void dispose() {
    _timer?.cancel(); // Hentikan timer agar tidak memory leak
    super.dispose();
  }

  // ===================================
  // BUILD UI: TAMPILAN UTAMA
  // ===================================
  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      // ===================================
      // KEYBOARD LISTENER: KONTROL KEYBOARD
      // ===================================
      // Agar bisa dikontrol dengan keyboard (tombol Space)
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        // Jika tombol Space ditekan, jalankan/pause stopwatch
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.space) {
          _startStop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        // ===================================
        // CONTAINER: BACKGROUND GRADIENT
        // ===================================
        body: Container(
          decoration: BoxDecoration(
            // Gradient radial dari tengah untuk efek visual
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                const Color(0xFF1A1A1A).withOpacity(0.3),
                const Color(0xFF0A0A0A),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1), // Spacer untuk memberi jarak atas // Spacer untuk memberi jarak atas

                // ===================================
                // SECTION: TAMPILAN STOPWATCH (LINGKARAN)
                // ===================================
                Container(
                  // Container luar - lingkaran dengan border cyan
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Border cyan dengan opacity
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withOpacity(0.3),
                      width: 2,
                    ),
                    // Shadow untuk efek glow
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Container(
                    // Container dalam - tempat teks waktu
                    padding: const EdgeInsets.all(60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A1A1A).withOpacity(0.5),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Teks waktu utama (MM:SS:MS)
                        Text(
                          _formatTime(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                            color: const Color(0xFF00E5FF),
                            shadows: [
                              Shadow(
                                color: const Color(0xFF00E5FF).withOpacity(0.5),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Label format waktu
                        Text(
                          'MIN : SEC : MS',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 1), // Spacer untuk memberi jarak tengah // Spacer untuk memberi jarak tengah

                // ===================================
                // SECTION: DAFTAR LAP (HANYA MUNCUL JIKA ADA LAP)
                // ===================================
                if (_laps.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    // ListView untuk menampilkan daftar lap secara scrollable
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _laps.length, // Jumlah lap yang ditampilkan
                      itemBuilder: (context, index) {
                        // Setiap item lap
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0A0A).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF00E5FF).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Bagian kiri: Icon bendera + nomor lap
                              Row(
                                children: [
                                  Icon(
                                    Icons.flag_rounded,
                                    color: const Color(
                                      0xFF00E5FF,
                                    ).withOpacity(0.6),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Lap ${_laps.length - index}', // Nomor lap dari besar ke kecil
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF666666),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              // Bagian kanan: Waktu lap
                              Text(
                                _formatLapTime(_laps[index]),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: const Color(0xFF00E5FF),
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const Spacer(flex: 1), // Spacer sebelum tombol kontrol // Spacer sebelum tombol kontrol

                // ===================================
                // SECTION: TOMBOL KONTROL (LAP, START/PAUSE, STOP)
                // ===================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ===================================
                      // TOMBOL LAP (BENDERA)
                      // ===================================
                      // Untuk menyimpan waktu lap saat ini
                      _buildControlButton(
                        icon: Icons.flag_rounded,
                        label: 'LAP',
                        onPressed: _addLap,
                        // Warna kuning jika berjalan, abu jika tidak
                        color: _isRunning
                            ? const Color(0xFFFFB300)
                            : const Color(0xFF666666),
                        isGlowing: _isRunning, // Efek glow saat berjalan
                      ),

                      // ===================================
                      // TOMBOL START/PAUSE (UTAMA)
                      // ===================================
                      // Icon dan label berubah tergantung status
                      _buildControlButton(
                        icon: _isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        label: _isRunning ? 'PAUSE' : 'START',
                        onPressed: _startStop,
                        color: const Color(0xFF00E5FF), // Warna cyan
                        isPrimary: true, // Ukuran lebih besar
                      ),

                      // ===================================
                      // TOMBOL STOP (RESET)
                      // ===================================
                      // Untuk menghentikan dan reset stopwatch
                      _buildControlButton(
                        icon: Icons.stop_rounded,
                        label: 'STOP',
                        onPressed: () {
                          // Jika sedang berjalan, pause dulu
                          if (_isRunning) {
                            _startStop();
                          }
                          // Kemudian reset
                          _reset();
                        },
                        // Warna merah jika berjalan, abu jika tidak
                        color: _isRunning 
                            ? const Color(0xFFFF1744)
                            : const Color(0xFF666666),
                        isGlowing: _isRunning, // Efek glow saat berjalan
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1), // Spacer untuk memberi jarak bawah
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================================
  // WIDGET: BUILDER TOMBOL KONTROL
  // ===================================
  // Fungsi reusable untuk membuat tombol kontrol dengan efek visual
  Widget _buildControlButton({
    required IconData icon,        // Icon yang ditampilkan
    required String label,         // Label teks di bawah tombol
    required VoidCallback onPressed, // Fungsi yang dipanggil saat tombol ditekan
    required Color color,          // Warna tombol
    bool isPrimary = false,        // Apakah tombol utama (ukuran lebih besar)
    bool isGlowing = false,        // Apakah ada efek glow
  }) {
    return Column(
      children: [
        Container(
          // Container luar untuk efek shadow/glow
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Shadow hanya jika isPrimary atau isGlowing
            boxShadow: isPrimary || isGlowing
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            // InkWell untuk efek ripple saat ditekan
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              splashColor: color.withOpacity(0.3),
              child: Container(
                // Ukuran tombol berbeda untuk primary dan non-primary
                width: isPrimary ? 80 : 64,
                height: isPrimary ? 80 : 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A1A1A).withOpacity(0.6),
                  border: Border.all(
                    color: color.withOpacity(isPrimary ? 0.6 : 0.3),
                    width: isPrimary ? 2 : 1,
                  ),
                ),
                // Icon di tengah tombol
                child: Icon(icon, color: color, size: isPrimary ? 40 : 28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Label teks di bawah tombol
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: color.withOpacity(0.7),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}
