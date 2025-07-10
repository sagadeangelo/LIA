class SpeechToText {
  Future<bool> initialize({Function(String)? onStatus, Function(String)? onError}) async {
    return true;
  }

  void listen({required Function onResult}) {}

  void stop() {}
}