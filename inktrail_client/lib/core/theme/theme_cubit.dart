import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const _storageKey = 'theme_mode';

  final FlutterSecureStorage _storage;

  ThemeCubit(this._storage) : super(const ThemeState());

  Future<void> load() async {
    final saved = await _storage.read(key: _storageKey);
    if (saved == 'dark') {
      emit(state.copyWith(themeMode: ThemeMode.dark));
      return;
    }
    if (saved == 'light') {
      emit(state.copyWith(themeMode: ThemeMode.light));
    }
  }

  Future<void> setDarkMode(bool value) async {
    final mode = value ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(themeMode: mode));
    await _storage.write(key: _storageKey, value: value ? 'dark' : 'light');
  }
}

