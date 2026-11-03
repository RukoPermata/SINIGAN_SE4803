import 'package:flutter/material.dart';

import 'app.dart';
import 'data/mock_data_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Muat data lokal (atau seed data tiruan saat pertama kali dijalankan)
  // sebelum aplikasi dirender.
  try {
    await MockDataStore.instance.load();
  } catch (error) {
    debugPrint('Gagal memuat data lokal: $error');
  }

  runApp(const SiniGanApp());
}
