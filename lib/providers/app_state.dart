import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/native_api.dart';
import 'dart:convert';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

// All Installed Apps
final installedAppsProvider = FutureProvider<List<InstalledApp>>((ref) async {
  final showSystem = ref.watch(showSystemAppsProvider);
  return await NativeApi.getInstalledApps(includeSystem: showSystem);
});

// Show System Apps Toggle
final showSystemAppsProvider = StateProvider<bool>((ref) => false);

// Random Selection Toggle
final randomSelectionProvider = StateProvider<bool>((ref) => false);

// Loop Toggle
final loopProvider = StateProvider<bool>((ref) => false);

// Delay Time (seconds)
final delayProvider = StateProvider<double>((ref) => 0.5);

// Number of Notifications
final countProvider = StateProvider<int>((ref) => 1);

// Running State
final isRunningProvider = StateProvider<bool>((ref) => false);

// Selected Apps
class SelectedAppsNotifier extends StateNotifier<Map<String, bool>> {
  SelectedAppsNotifier() : super({});

  void toggleApp(String packageName, bool selected) {
    state = {...state, packageName: selected};
  }

  void selectAll(List<InstalledApp> apps) {
    final newState = <String, bool>{};
    for (var app in apps) {
      newState[app.packageName] = true;
    }
    state = newState;
  }
  
  void deselectAll() {
    state = {};
  }

  void setSelection(Map<String, bool> selection) {
    state = selection;
  }
}

final selectedAppsProvider = StateNotifierProvider<SelectedAppsNotifier, Map<String, bool>>((ref) {
  return SelectedAppsNotifier();
});

// Notification Texts
class NotificationTextsNotifier extends StateNotifier<List<Map<String, String>>> {
  NotificationTextsNotifier() : super([{'id': DateTime.now().millisecondsSinceEpoch.toString(), 'title': '', 'text': ''}]);

  void addText(String title, String text) {
    state = [...state, {'id': DateTime.now().millisecondsSinceEpoch.toString(), 'title': title, 'text': text}];
  }

  void updateText(int index, String title, String text) {
    final newState = List<Map<String, String>>.from(state);
    final oldId = newState[index]['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    newState[index] = {'id': oldId, 'title': title, 'text': text};
    state = newState;
  }

  void removeText(int index) {
    final newState = List<Map<String, String>>.from(state);
    newState.removeAt(index);
    state = newState;
  }
  
  void setTexts(List<Map<String, String>> texts) {
    final withIds = texts.map((t) {
      if (!t.containsKey('id')) {
        t['id'] = DateTime.now().microsecondsSinceEpoch.toString() + t.hashCode.toString();
      }
      return t;
    }).toList();
    state = withIds;
  }
}

final notificationTextsProvider = StateNotifierProvider<NotificationTextsNotifier, List<Map<String, String>>>((ref) {
  return NotificationTextsNotifier();
});

// Presets Logic
class PresetsService {
  final SharedPreferences prefs;
  PresetsService(this.prefs);

  Future<void> savePreset(String name, Map<String, bool> selectedApps, List<Map<String, String>> texts, bool loop, double delay, int count, bool random) async {
    final presetsStr = prefs.getString('presets') ?? '{}';
    final presets = jsonDecode(presetsStr) as Map<String, dynamic>;
    
    presets[name] = {
      'selectedApps': selectedApps,
      'texts': texts,
      'loop': loop,
      'delay': delay,
      'count': count,
      'random': random,
    };
    
    await prefs.setString('presets', jsonEncode(presets));
  }

  Future<void> deletePreset(String name) async {
    final presetsStr = prefs.getString('presets') ?? '{}';
    final presets = jsonDecode(presetsStr) as Map<String, dynamic>;
    if (presets.containsKey(name)) {
      presets.remove(name);
      await prefs.setString('presets', jsonEncode(presets));
    }
  }

  Map<String, dynamic> getPresets() {
    final presetsStr = prefs.getString('presets') ?? '{}';
    return jsonDecode(presetsStr) as Map<String, dynamic>;
  }
}

final presetsServiceProvider = Provider<PresetsService>((ref) {
  return PresetsService(ref.watch(sharedPreferencesProvider));
});
