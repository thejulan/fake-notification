import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:math';
import '../providers/app_state.dart';
import '../services/native_api.dart';
import '../data/static_groups.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _presetNameController = TextEditingController();
  final _scrollController = ScrollController();
  int _selectedDelayTrigger = 0; // 0 for 'Now', 10, 20... 100

  @override
  void dispose() {
    _presetNameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showAppSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppSelectionModal(),
    );
  }

  void _showStaticGroupsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const StaticGroupsModal(),
    );
  }

  void _triggerNotifications(int delaySeconds) async {
    final isRunning = ref.read(isRunningProvider);
    if (isRunning) {
      ref.read(isRunningProvider.notifier).state = false;
      return;
    }

    final texts = ref.read(notificationTextsProvider);
    final selectedApps = ref.read(selectedAppsProvider);
    final isRandom = ref.read(randomSelectionProvider);
    final count = ref.read(countProvider);
    final isLoop = ref.read(loopProvider);
    final delayBetween = (ref.read(delayProvider) * 1000).toInt();

    final appsAsyncValue = ref.read(installedAppsProvider);
    final apps = appsAsyncValue.valueOrNull ?? [];

    List<InstalledApp> targetApps = [];
    if (isRandom) {
      if (apps.isNotEmpty) {
        targetApps = apps;
      }
    } else {
      targetApps = apps.where((app) => selectedApps[app.packageName] == true).toList();
    }

    if (targetApps.isEmpty || texts.isEmpty || texts[0]['title']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one app and enter text.')),
      );
      return;
    }

    ref.read(isRunningProvider.notifier).state = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(delaySeconds == 0 ? 'Sending notifications...' : 'Notifications scheduled in ${delaySeconds} seconds.')),
    );

    Future.delayed(Duration(seconds: delaySeconds), () async {
      final rand = Random();
      final totalCount = isLoop ? 999999 : count;
      
      for (int i = 0; i < totalCount; i++) {
        if (!ref.read(isRunningProvider)) break; // STOP requested

        final textObj = texts[rand.nextInt(texts.length)];
        final targetApp = targetApps[rand.nextInt(targetApps.length)];
        
        await NativeApi.sendFakeNotification(
          packageName: targetApp.packageName,
          appName: targetApp.name,
          title: textObj['title'] ?? 'Title',
          text: textObj['text'] ?? 'Text',
        );

        if (i < totalCount - 1) {
          // Wait between notifications, but check stop flag frequently
          for (int w = 0; w < delayBetween; w += 100) {
            if (!ref.read(isRunningProvider)) break;
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      }
      
      // Auto stop when done
      if (ref.read(isRunningProvider)) {
        ref.read(isRunningProvider.notifier).state = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRandom = ref.watch(randomSelectionProvider);
    final selectedApps = ref.watch(selectedAppsProvider);
    final texts = ref.watch(notificationTextsProvider);
    final isLoop = ref.watch(loopProvider);
    final delay = ref.watch(delayProvider);
    final count = ref.watch(countProvider);
    final isRunning = ref.watch(isRunningProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Fake Notification', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.listBullets()),
            onPressed: () => Navigator.pushNamed(context, '/presets'),
            tooltip: 'Saved Presets',
          ),
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.info()),
            onPressed: () => Navigator.pushNamed(context, '/info'),
            tooltip: 'Info',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Selection
            _buildSectionHeader('Target Apps', PhosphorIcons.appWindow()),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Random App Selection'),
                      subtitle: const Text('Ignores specific app selection'),
                      value: isRandom,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (val) => ref.read(randomSelectionProvider.notifier).state = val,
                    ),
                    if (!isRandom) ...[
                      const Divider(),
                      ListTile(
                        title: Text('${selectedApps.values.where((v) => v).length} Apps Selected'),
                        trailing: ElevatedButton(
                          onPressed: _showAppSelectionModal,
                          child: const Text('Select Apps'),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notification Text (Horizontal UX)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Content Variations', PhosphorIcons.textT()),
                TextButton.icon(
                  onPressed: _showStaticGroupsModal,
                  icon: PhosphorIcon(PhosphorIcons.magicWand(), size: 18),
                  label: const Text('Auto Fill'),
                ),
              ],
            ),
            Container(
              height: 350,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: texts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == texts.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextButton.icon(
                          onPressed: () => ref.read(notificationTextsProvider.notifier).addText('', ''),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Another Variation'),
                        ),
                      );
                    }

                    final txt = texts[index];
                    final uniqueId = txt['id'] ?? index.toString();
                    return Card(
                      key: ValueKey(uniqueId),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  TextFormField(
                                    initialValue: txt['title'],
                                    decoration: const InputDecoration(labelText: 'Title', hintText: 'WhatsApp'),
                                    onChanged: (v) => ref.read(notificationTextsProvider.notifier).updateText(index, v, txt['text']!),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    initialValue: txt['text'],
                                    decoration: const InputDecoration(labelText: 'Message', hintText: 'Hello there!'),
                                    onChanged: (v) => ref.read(notificationTextsProvider.notifier).updateText(index, txt['title']!, v),
                                  ),
                                ],
                              ),
                            ),
                            if (texts.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => ref.read(notificationTextsProvider.notifier).removeText(index),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Timing & Count
            _buildSectionHeader('Configuration', PhosphorIcons.sliders()),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Delay (s): '),
                        Expanded(
                          child: Slider(
                            value: delay,
                            min: 0.5,
                            max: 10.0,
                            divisions: 19,
                            label: delay.toStringAsFixed(1),
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (v) => ref.read(delayProvider.notifier).state = v,
                          ),
                        ),
                        Text(delay.toStringAsFixed(1)),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Count:      '),
                        Expanded(
                          child: Slider(
                            value: count.toDouble(),
                            min: 1,
                            max: 50,
                            divisions: 49,
                            label: count.toString(),
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: isLoop ? null : (v) => ref.read(countProvider.notifier).state = v.toInt(),
                          ),
                        ),
                        Text(count.toString()),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text('Loop Notifications'),
                      contentPadding: EdgeInsets.zero,
                      value: isLoop,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: count > 1 ? null : (val) => ref.read(loopProvider.notifier).state = val,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Save Preset'),
                      content: TextField(
                        controller: _presetNameController,
                        decoration: const InputDecoration(hintText: 'Preset Name'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () async {
                            final name = _presetNameController.text;
                            if (name.isNotEmpty) {
                              await ref.read(presetsServiceProvider).savePreset(
                                name,
                                ref.read(selectedAppsProvider),
                                ref.read(notificationTextsProvider),
                                ref.read(loopProvider),
                                ref.read(delayProvider),
                                ref.read(countProvider),
                                ref.read(randomSelectionProvider)
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preset saved!')));
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
                icon: PhosphorIcon(PhosphorIcons.floppyDisk()),
                label: const Text('Save as Preset'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Trigger Buttons
            _buildSectionHeader('Trigger Timer', PhosphorIcons.clock()),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedDelayTrigger,
                        isExpanded: true,
                        items: List.generate(11, (index) {
                          final val = index * 10;
                          return DropdownMenuItem(
                            value: val,
                            child: Text(val == 0 ? 'Now' : '${val} Seconds'),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedDelayTrigger = val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _triggerNotifications(_selectedDelayTrigger),
                icon: PhosphorIcon(isRunning ? PhosphorIcons.stopCircle() : PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.fill)),
                label: Text(isRunning ? 'Stop' : 'Start', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRunning ? Colors.redAccent : null,
                  foregroundColor: isRunning ? Colors.white : null,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          PhosphorIcon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class AppSelectionModal extends ConsumerWidget {
  const AppSelectionModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsyncValue = ref.watch(installedAppsProvider);
    final selectedApps = ref.watch(selectedAppsProvider);
    final showSystem = ref.watch(showSystemAppsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Select Apps', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  if (appsAsyncValue.hasValue) {
                    ref.read(selectedAppsProvider.notifier).selectAll(appsAsyncValue.value!);
                  }
                },
                child: const Text('Select All'),
              )
            ],
          ),
          SwitchListTile(
            title: const Text('Show System Apps'),
            value: showSystem,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (v) {
              ref.read(showSystemAppsProvider.notifier).state = v;
            },
          ),
          const Divider(),
          Expanded(
            child: appsAsyncValue.when(
              data: (apps) {
                if (apps.isEmpty) return const Center(child: Text('No apps found.'));
                return ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    final isSelected = selectedApps[app.packageName] == true;
                    return CheckboxListTile(
                      title: Text(app.name),
                      subtitle: Text(app.packageName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      secondary: app.icon.isNotEmpty 
                        ? Image.memory(app.icon, width: 40, height: 40)
                        : const Icon(Icons.android, size: 40),
                      value: isSelected,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (val) {
                        ref.read(selectedAppsProvider.notifier).toggleApp(app.packageName, val ?? false);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class StaticGroupsModal extends ConsumerWidget {
  const StaticGroupsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Auto-Fill Data', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: staticGroups.length,
              itemBuilder: (context, index) {
                final group = staticGroups[index];
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardTheme.color,
                    foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        final ctr = TextEditingController();
                        return AlertDialog(
                          title: const Text('How many variations?'),
                          content: TextField(
                            controller: ctr,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'e.g. 15'),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            ElevatedButton(
                              onPressed: () {
                                final count = int.tryParse(ctr.text) ?? group.notifications.length;
                                final List<Map<String, String>> newTexts = [];
                                final rand = Random();
                                for(int i = 0; i < count; i++) {
                                  String rawText = group.notifications[i % group.notifications.length];
                                  if (count > group.notifications.length) {
                                    final rNum = rand.nextInt(9000) + 1000;
                                    rawText = "$rawText #$rNum";
                                  }
                                  newTexts.add({'title': group.name, 'text': rawText});
                                }
                                ref.read(notificationTextsProvider.notifier).setTexts(newTexts);
                                Navigator.pop(ctx);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${group.name} notifications loaded!')),
                                );
                              },
                              child: const Text('Load'),
                            )
                          ]
                        );
                      }
                    );
                  },
                  child: Text(group.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
