class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  Stream<String?> get onNotificationTap => const Stream<String?>.empty();

  Future<void> init() async {}

  Future<void> show({
    required String title,
    required String body,
    String? payload,
  }) async {}
}
