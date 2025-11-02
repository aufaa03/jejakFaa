import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jejak_faa_new/features/sync/providers/sync_provider.dart';

// 1. Definisikan Enum untuk status visual (agar lebih mudah dibaca)
enum SyncStatusVisual {
  idle, // Tidak terjadi apa-apa
  loading,
  success,
  error,
}

class SyncIndicator extends ConsumerStatefulWidget {
  final Widget? child;
  
  // Jika ditaruh di AppBar, kita butuh ikon saja. Jika ditaruh di list, kita butuh child.
  const SyncIndicator({super.key, this.child});

  @override
  ConsumerState<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends ConsumerState<SyncIndicator> {
  // Simpan status sinkronisasi terakhir untuk memicu efek satu kali (SnackBar)
  AsyncValue<void>? _previousState; 

  @override
  Widget build(BuildContext context) {
    // 2. Tonton (watch) Sync Provider
    final syncState = ref.watch(syncProvider);
    // Dapatkan Notifier untuk memanggil method
    final syncNotifier = ref.read(syncProvider.notifier);

    // 3. Tangani Efek Samping (Side Effect) - Menampilkan SnackBar
    ref.listen<AsyncValue<void>>(syncProvider, (previous, next) {
      if (next.isLoading && !previous!.isLoading) {
        // Abaikan saat mulai loading
      } else if (next.hasError) {
        // Tampilkan Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sinkronisasi Gagal: ${next.error}"),
            backgroundColor: Colors.red,
          ),
        );
      } else if (next.hasValue && previous!.isLoading) {
        // Tampilkan Sukses (hanya setelah selesai loading)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sinkronisasi Berhasil!"),
            backgroundColor: Colors.green,
          ),
        );
      }
      _previousState = previous;
    });

    // 4. Konversi status provider ke status visual untuk UI
    final status = syncState.when(
      data: (_) => SyncStatusVisual.idle,
      loading: () => SyncStatusVisual.loading,
      error: (_, __) => SyncStatusVisual.error,
    );
    
    // 5. Tampilkan UI berdasarkan Status
    Widget indicatorIcon;
    Color iconColor;
    String tooltipText;

    switch (status) {
      case SyncStatusVisual.loading:
        indicatorIcon = const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
        );
        iconColor = Colors.blue;
        tooltipText = 'Sedang Sinkronisasi...';
        break;
      case SyncStatusVisual.error:
        indicatorIcon = const Icon(Icons.sync_problem_outlined);
        iconColor = Colors.red;
        tooltipText = 'Sinkronisasi Gagal. Klik untuk coba lagi.';
        break;
      case SyncStatusVisual.success:
      case SyncStatusVisual.idle:
      default:
        indicatorIcon = const Icon(Icons.sync_outlined);
        iconColor = Colors.grey[600]!;
        tooltipText = 'Sinkronisasi. Klik untuk memulai.';
        break;
    }

    // 6. Kembalikan tombol (dengan fungsionalitas syncNow())
    return IconButton(
      icon: indicatorIcon,
      color: iconColor,
      tooltip: tooltipText,
      // Panggil syncNow() saat ditekan (hanya jika tidak sedang loading)
      onPressed: status == SyncStatusVisual.loading 
          ? null 
          : () => syncNotifier.syncNow(),
    );
  }
}