import 'package:flutter/material.dart';

import '../di/service_locator.dart';
import '../network/token_storage.dart';
import '../widgets/login_promt_sheet.dart';

class AuthGate {
  AuthGate._();

  static bool _isPromptOpen = false;

  static Future<bool> requireAuth(BuildContext _) async {
    final tokenStorage = sl<TokenStorage>();
    if (await tokenStorage.hasToken()) {
      return true;
    }

    if (_isPromptOpen) {
      return false;
    }

    _isPromptOpen = true;
    try {
      await LoginPromptSheet.showFromRoot();
    } finally {
      _isPromptOpen = false;
    }

    return await tokenStorage.hasToken();
  }
}
