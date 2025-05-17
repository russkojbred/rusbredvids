import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russkiy_bred/app/app.dart';
import 'package:russkiy_bred/core/utils/app_bloc_observer.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация SQLite для Windows
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Настройка BLoC Observer для отладки
  Bloc.observer = AppBlocObserver();
  
  runApp(const RusskiyBredApp());
}
