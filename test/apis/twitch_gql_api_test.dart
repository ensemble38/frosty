import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/apis/twitch_gql_api.dart';
import 'package:frosty/models/playback_access_token.dart';
import 'package:frosty/models/playback_mode.dart';

void main() {
  late TwitchGqlApi api;

  setUp(() => api = TwitchGqlApi(Dio()));

  group('playback mode configuration', () {
    test('maps each mode to the expected token parameters', () {
      expect(PlaybackMode.frosty.platform, 'web');
      expect(PlaybackMode.frosty.playerBackend, 'mediaplayer');
      expect(PlaybackMode.frosty.playerType, 'site');

      for (final mode in [PlaybackMode.s0undToken, PlaybackMode.s0undFull]) {
        expect(mode.platform, 'android');
        expect(mode.playerBackend, 'mediaplayer');
        expect(mode.playerType, 'mobile');
      }
    });

    test('maps modes to the expected Usher path', () {
      expect(PlaybackMode.frosty.usherPath, '/api/v2/channel/hls/');
      expect(PlaybackMode.s0undToken.usherPath, '/api/v2/channel/hls/');
      expect(PlaybackMode.s0undFull.usherPath, '/api/channel/hls/');
    });
  });

  group('buildHlsUrl', () {
    const token = PlaybackAccessToken(
      value: '{"a":"space & slash/plus+"}',
      signature: 'signature-value',
    );

    test('Frosty mode preserves the existing v2 URL and parameters', () {
      final url = api.buildHlsUrl(
        login: 'channel',
        token: token,
        randomValue: 42,
        sessionId: '0123456789abcdef0123456789abcdef',
      );

      expect(
        url,
        startsWith('https://usher.ttvnw.net/api/v2/channel/hls/channel.m3u8'),
      );
      final uri = Uri.parse(url);
      expect(uri.queryParameters['sig'], token.signature);
      expect(uri.queryParameters['token'], token.value);
      expect(uri.queryParameters['platform'], 'web');
      expect(uri.queryParameters['player_backend'], 'mediaplayer');
      expect(uri.queryParameters['p'], '42');
      expect(url, contains('%26'));
      expect(url, contains('%2F'));
      expect(url, isNot(contains(token.value)));
    });

    test('S0und Token changes token params but keeps the Frosty Usher URL', () {
      final url = api.buildHlsUrl(
        login: 'channel',
        token: token,
        mode: PlaybackMode.s0undToken,
        randomValue: 7,
        sessionId: 'session',
      );

      expect(Uri.parse(url).path, '/api/v2/channel/hls/channel.m3u8');
    });

    test('S0und Full uses the beta 146 Usher shape', () {
      final uri = Uri.parse(
        api.buildHlsUrl(
          login: 'channel',
          token: token,
          mode: PlaybackMode.s0undFull,
          randomValue: 9,
        ),
      );

      expect(uri.path, '/api/channel/hls/channel.m3u8');
      expect(uri.queryParameters, {
        'player': 'twitchweb',
        'token': token.value,
        'sig': token.signature,
        'allow_audio_only': 'true',
        'allow_source': 'true',
        'playlist_include_framerate': 'true',
        'type': 'any',
        'p': '9',
      });
    });
  });
}
