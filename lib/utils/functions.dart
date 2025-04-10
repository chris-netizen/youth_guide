// Function to toggle play and pause
import 'package:youth_guide/service/providers/tts_provider.dart';

void togglePlayPause(dynamic ttsProvider) {
  if (ttsProvider.state == TtsState.playing) {
    ttsProvider.pause();
  } else if (ttsProvider.state == TtsState.paused) {
    ttsProvider.resume();
  } else if (ttsProvider.state == TtsState.stopped) {
    ttsProvider.start();
  }
}
