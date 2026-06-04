class MainTabController {
  static void Function(int index)? _openTab;

  static void register(void Function(int index) callback) {
    _openTab = callback;
  }

  static void unregister() {
    _openTab = null;
  }

  static void openProfileTab() {
    _openTab?.call(3);
  }
}
