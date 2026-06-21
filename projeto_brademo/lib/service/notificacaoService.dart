import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

late NotificationDetails notificationDetails;

Future<void> inicializarNotificacoes() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  const androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  const androidDetails = AndroidNotificationDetails(
    'brademo_channel',
    'Brademo Notificações',
    importance: Importance.max,
    priority: Priority.high,
  );

  notificationDetails = const NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

Future<void> mostrarNotificacao() async {
  await flutterLocalNotificationsPlugin.show(
    0,
    'Atenção! Não perca as novidades.',
    'Responda o formulário para receber novas sugestões.',
    notificationDetails,
  );
}