import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/app_state.dart';

class PresetsScreen extends ConsumerStatefulWidget {
  const PresetsScreen({super.key});

  @override
  ConsumerState<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends ConsumerState<PresetsScreen> {
  @override
  Widget build(BuildContext context) {
    final presetsService = ref.watch(presetsServiceProvider);
    final presets = presetsService.getPresets();
    
    // Reverse keys to show newest first
    final keys = presets.keys.toList().reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Presets'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: presets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhosphorIcon(
                    PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.duotone),
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No presets saved yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final key = keys[index];
                final preset = presets[key];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PhosphorIcon(
                        PhosphorIcons.play(PhosphorIconsStyle.fill),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Apps: ${(preset["selectedApps"] as Map).length}, Texts: ${(preset["texts"] as List).length}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await presetsService.deletePreset(key);
                        setState(() {}); // Rebuild to remove it from list
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Preset "$key" deleted!')),
                        );
                      },
                    ),
                    onTap: () {
                      // Load preset to state
                      final selApps = Map<String, bool>.from(preset['selectedApps']);
                      ref.read(selectedAppsProvider.notifier).setSelection(selApps);
                      
                      final texts = (preset['texts'] as List).map((e) => Map<String, String>.from(e)).toList();
                      ref.read(notificationTextsProvider.notifier).setTexts(texts);
                      
                      ref.read(loopProvider.notifier).state = preset['loop'];
                      ref.read(delayProvider.notifier).state = preset['delay'].toDouble();
                      ref.read(countProvider.notifier).state = preset['count'];
                      ref.read(randomSelectionProvider.notifier).state = preset['random'];
                      
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Preset "$key" loaded!')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
