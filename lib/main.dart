import 'package:flutter/material.dart';
import 'services/app_config.dart';
import 'services/session_service.dart';
import 'services/local_notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_page.dart';
import 'widgets/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();
  await LocalNotificationService.instance.init();
  final user = await SessionService().getUser();
  runApp(MyApp(userLoggedIn: user != null, userName: user?.fullName ?? 'Cliente'));
}

class MyApp extends StatelessWidget {
  final bool userLoggedIn;
  final String userName;
  const MyApp({super.key, required this.userLoggedIn, required this.userName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seguimiento Delicias',
      theme: AppTheme.light(),
      home: userLoggedIn ? AppShell(userName: userName) : const LoginPage(),
    );
  }
}
