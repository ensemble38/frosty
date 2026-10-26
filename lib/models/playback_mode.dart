enum PlaybackMode { frosty, s0undToken, s0undFull }

const playbackModeNames = <PlaybackMode, String>{
  PlaybackMode.frosty: 'Frosty',
  PlaybackMode.s0undToken: 'S0und Token',
  PlaybackMode.s0undFull: 'S0und Full',
};

extension PlaybackModeConfig on PlaybackMode {
  String get platform => this == PlaybackMode.frosty ? 'web' : 'android';

  String get playerBackend => 'mediaplayer';

  String get playerType => this == PlaybackMode.frosty ? 'site' : 'mobile';

  String get usherPath => this == PlaybackMode.s0undFull
      ? '/api/channel/hls/'
      : '/api/v2/channel/hls/';

  String get usherMode =>
      this == PlaybackMode.s0undFull ? 'S0und v1' : 'Frosty v2';
}
