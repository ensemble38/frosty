import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/models/playback_mode.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/screens/settings/widgets/settings_list_select.dart';
import 'package:frosty/screens/settings/widgets/settings_list_switch.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:frosty/widgets/settings_page_layout.dart';

class VideoSettings extends StatelessWidget {
  final SettingsStore settingsStore;

  const VideoSettings({super.key, required this.settingsStore});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => SettingsPageLayout(
        children: [
          const SectionHeader('Player', isFirst: true),
          SettingsListSwitch(
            title: 'Show video player',
            value: settingsStore.showVideo,
            onChanged: (newValue) => settingsStore.showVideo = newValue,
          ),
          if (settingsStore.showVideo)
            SettingsListSwitch(
              title: 'Native player',
              subtitle: const Text(
                'Picture-in-Picture, quality selection, and lower latency. Turn off to use the legacy WebView player.',
              ),
              value: settingsStore.useNativePlayer,
              onChanged: (newValue) => settingsStore.useNativePlayer = newValue,
            ),
          SettingsListSelect(
            title: 'Playback mode',
            subtitle:
                'Changing mode closes the active player and fetches a fresh token.',
            selectedOption: playbackModeNames[settingsStore.playbackMode]!,
            options: PlaybackMode.values
                .map((mode) => playbackModeNames[mode]!)
                .toList(),
            onChanged: (name) => settingsStore.playbackMode = playbackModeNames
                .entries
                .firstWhere((entry) => entry.value == name)
                .key,
          ),
          if (!Platform.isIOS || isIPad())
            SettingsListSwitch(
              title: 'Default to highest quality',
              value: settingsStore.defaultToHighestQuality,
              onChanged: (newValue) =>
                  settingsStore.defaultToHighestQuality = newValue,
            ),
          if (Platform.isAndroid)
            SettingsListSwitch(
              title: 'Use fast video rendering',
              subtitle: const Text(
                'Uses a faster WebView rendering method. Disable if you experience crashes while watching streams.',
              ),
              value: settingsStore.useTextureRendering,
              onChanged: (newValue) =>
                  settingsStore.useTextureRendering = newValue,
            ),
          const SectionHeader('Overlay'),
          SettingsListSwitch(
            title: 'Use custom video overlay',
            subtitle: const Text(
              'Replaces Twitch\'s default web overlay with a mobile-friendly version.',
            ),
            value: settingsStore.showOverlay,
            onChanged: (newValue) => settingsStore.showOverlay = newValue,
          ),
          SettingsListSwitch(
            title: 'Toggle overlay on long-press',
            subtitle: const Text(
              'Switch between Twitch\'s overlay and the custom overlay.',
            ),
            value: settingsStore.toggleableOverlay,
            onChanged: (newValue) => settingsStore.toggleableOverlay = newValue,
          ),
          SettingsListSwitch(
            title: 'Show latency',
            subtitle: const Text(
              'Displays the stream latency in the video overlay.',
            ),
            value: settingsStore.showLatency,
            onChanged: (newValue) => settingsStore.showLatency = newValue,
          ),
          const SectionHeader('Playback debug'),
          ListTile(
            title: Text(
              'Mode: ${playbackModeNames[settingsStore.playbackMode]}',
            ),
            subtitle: Text(
              'Last Channel: ${settingsStore.playbackDebugLastChannel}\n'
              'Token Params: ${settingsStore.playbackDebugTokenParams}\n'
              'Usher Mode: ${settingsStore.playbackDebugUsherMode}\n'
              'Master Playlist HTTP status: ${settingsStore.playbackDebugHttpStatus}\n'
              'Playback Start Result: ${settingsStore.playbackDebugStartResult}\n'
              'Last Error: ${settingsStore.playbackDebugLastError}',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.copy_rounded),
            title: const Text('Copy playback log'),
            subtitle: Text(
              settingsStore.playbackDebugLog.isEmpty
                  ? 'No playback events yet.'
                  : '${settingsStore.playbackDebugLog.split('\n').length} events (secrets redacted)',
            ),
            enabled: settingsStore.playbackDebugLog.isNotEmpty,
            onTap: () async {
              await Clipboard.setData(
                ClipboardData(text: settingsStore.playbackDebugLog),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Playback log copied')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
