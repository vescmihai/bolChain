import 'package:bolchain/di/locator.dart';
import 'package:bolchain/pages/home.dart';
import 'package:bolchain/pages/cuentas.dart';
import 'package:bolchain/pages/token_info.dart';
import 'package:bolchain/pages/historial_transferencias.dart';
import 'package:bolchain/pages/transferencia.dart';
import 'package:bolchain/services/servicio_cuenta.dart';
import 'package:bolchain/ui_helper/home_ui_helper.dart';
import 'package:bolchain/ui_helper/cuentas_ui_helper.dart';
import 'package:bolchain/ui_helper/historial_transferencias_ui_helper.dart';
import 'package:bolchain/ui_helper/transferencias_ui_helper.dart';
import 'package:bolchain/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
void main() async {
  setupDi();
  await Future.wait(
    [
      Hive.initFlutter(),
      dotenv.load(fileName: ".env"),
    ],
  );

  WidgetsFlutterBinding.ensureInitialized();
  bool loggedIn = await AccountService.isLogged();
  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => OnboardingPageUiHelper(),
        child: MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          title: "bolchain",
          home: loggedIn
              ? ChangeNotifierProvider(
                  create: (context) => getIt<HomePageUiHelper>(),
                  child: const HomePage(),
                )
              : OnboardingPage(),
          routes: {
            "/onboardingPage": (context) => const OnboardingPage(),
            "/homePage": (context) => ChangeNotifierProvider(
                  create: (context) => getIt<HomePageUiHelper>(),
                  child: const HomePage(),
                ),
            "/tokenInfoPage": (context) => const TokenInfoPage(),
            "/transactionHistory": (context) => ChangeNotifierProvider(
                create: (context) => TransactionHistoryPageUiHelper(),
                child: const TransactionHistoryPage()),
            "/transactionPage": (context) => ChangeNotifierProvider(
                create: (context) => TransactionPageUiHelper(),
                child: const TransactionPage()),
          },
        ));
  }
}
