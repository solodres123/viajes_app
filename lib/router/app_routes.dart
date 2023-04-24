import 'package:viajes_app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:viajes_app/widgets/widgets.dart';
import '../screens/screens.dart';

class AppRoutes {
  static const initialRoute = 'list';

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
          route: 'inputs',
          name: 'Inputs Screen',
          screen: const InputsScreen(),
          icon: Icons.input),

          
          
//  MenuOption(
//      route: 'listview1',
//      name: 'Listview1',
//      screen: const Listview1Screen(),
//      icon: Icons.list),
//  MenuOption(
//      route: 'listview2',
//      name: 'Listview2',
//      screen: const Listview2Screen(),
//      icon: Icons.list),
//  MenuOption(
//      route: 'alert',
//      name: 'Alertas - Alerts',
//      screen: const AlertScreen(),
//      icon: Icons.warning_amber),
//  MenuOption(
//      route: 'card',
//      name: 'Tarjetas - Cards',
//      screen: const CardScreen(),
//      icon: Icons.sd_card),
   // MenuOption(
   //     route: 'test',
   //     name: 'Test Screen',
   //     screen: TestScreen(),
   //     icon: Icons.science),
    
  //  MenuOption(
  //      route: 'slider',
  //      name: 'Sliders and checks',
  //      screen: const SliderScreen(),
  //      icon: Icons.sledding_rounded),
//
  //  MenuOption(
  //      route: 'listviewbuilder',
  //      name: 'Infinite scroll and pull to refresh',
  //      screen: const ListViewBuilderScreen(),
  //      icon: Icons.build_rounded),
//
  // 
  ];

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};
    for (final option in menuOptions) {
      appRoutes.addAll({option.route: (BuildContext context) => option.screen});
    }
    return appRoutes;
  }

  // static Map<String, Widget Function(BuildContext)> routes = {
  //'home': (BuildContext context) => const HomeScreen(),
  //////'listview2': (BuildContext context) => const Listview2Screen(),
  //////'listview1': (BuildContext context) => const Listview1Screen(),
  //////'alert': (BuildContext context) => const AlertScreen(),
  //////'card': (BuildContext context) => const CardScreen(),
//  };
 static Route<dynamic> onGenerateRoute(RouteSettings settings) {
   return MaterialPageRoute(
     builder: (context) => const HomeScreen(),
   );
 }
}
