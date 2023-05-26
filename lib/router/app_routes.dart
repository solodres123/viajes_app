import 'package:viajes_app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:viajes_app/widgets/widgets.dart';
import '../screens/screens.dart';

class AppRoutes {
  static const initialRoute = 'login';

  static final menuOptions = <MenuOption>[

    MenuOption(
        route: 'list',
        name: 'Screen List',
        screen: const ScreenList(),
        icon: Icons.home),

    MenuOption(
        route: 'home',
        name: 'Home Screen',
        screen: const HomeScreen(),
        icon: Icons.house_rounded),
  

    MenuOption(
          route: 'componentes screen',
          name: 'Componentes Screen',
          screen: const ComponentesScreen(),
          icon: Icons.settings_input_component),

    MenuOption(
          route: 'login',
          name: 'Login Screen',
          screen: const LoginScreen(),
          icon: Icons.person),
      
    MenuOption(
          route: 'register',
          name: 'Inputs Screen',
          screen: const InputsScreen(),
          icon: Icons.input),

          
  ];

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};
    for (final option in menuOptions) {
      appRoutes.addAll({option.route: (BuildContext context) => option.screen});
    }
    return appRoutes;
  }

 static Route<dynamic> onGenerateRoute(RouteSettings settings) {
   return MaterialPageRoute(
     builder: (context) => const HomeScreen(),
   );
 }
}
