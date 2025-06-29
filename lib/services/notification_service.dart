import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('NotificationService: Iniciando inicialização...');

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (Platform.isAndroid) {
        print('NotificationService: Verificando permissões no Android...');
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _notifications
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        if (androidImplementation != null) {
          final bool areEnabled =
              await androidImplementation.areNotificationsEnabled() ?? false;
          print(
            'NotificationService: Notificações Android habilitadas: $areEnabled',
          );

          if (!areEnabled) {
            print(
              'NotificationService: Notificações não habilitadas no Android',
            );
          }
        }
      }

      if (Platform.isIOS) {
        print('NotificationService: Solicitando permissões no iOS...');
        await _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }

      _isInitialized = true;
      print('NotificationService inicializado com sucesso');
    } catch (e) {
      print('Erro na inicialização do NotificationService: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notificação tocada: ${response.payload}');
  }

  Future<void> scheduleTaskNotification({
    required int taskId,
    required String taskTitle,
    required DateTime dueDate,
    required int reminderMinutes,
  }) async {
    if (!_isInitialized) {
      print('NotificationService não inicializado');
      return;
    }

    final notificationTime = dueDate.subtract(
      Duration(minutes: reminderMinutes),
    );

    if (notificationTime.isBefore(DateTime.now())) {
      print('Tempo de notificação já passou');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'task_reminders',
          'Lembretes de Tarefas',
          channelDescription: 'Notificações de lembretes de tarefas',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(''),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        taskId,
        'Lembrete de Tarefa',
        'Sua tarefa "$taskTitle" vence em ${reminderMinutes} minutos!',
        notificationDetails,
        payload: taskId.toString(),
      );
      print('Notificação de teste mostrada para tarefa $taskId');
    } catch (e) {
      print('Erro ao mostrar notificação: $e');
    }
  }

  Future<void> cancelTaskNotification(int taskId) async {
    if (!_isInitialized) return;

    try {
      await _notifications.cancel(taskId);
      print('Notificação cancelada para tarefa $taskId');
    } catch (e) {
      print('Erro ao cancelar notificação: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;

    try {
      await _notifications.cancelAll();
      print('Todas as notificações canceladas');
    } catch (e) {
      print('Erro ao cancelar todas as notificações: $e');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) return [];

    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('Erro ao obter notificações pendentes: $e');
      return [];
    }
  }

  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) return false;

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  Future<void> testNotification() async {
    if (!_isInitialized) {
      print('NotificationService: Não inicializado para teste');
      return;
    }

    try {
      print('NotificationService: Testando notificação...');

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'test_channel',
            'Teste',
            channelDescription: 'Canal para testes de notificação',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        999,
        'Teste de Notificação',
        'Esta é uma notificação de teste do To Do Bem!',
        notificationDetails,
        payload: 'test',
      );

      print('NotificationService: Notificação de teste enviada com sucesso');
    } catch (e) {
      print('NotificationService: Erro ao enviar notificação de teste: $e');
    }
  }
}
