import 'package:provider/provider.dart';
import 'package:viajes_app/router/app_routes.dart';
import 'package:viajes_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'services/new_card_form.dart';
import 'services/socket_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: ( _ ) => SocketService()),
        ChangeNotifierProvider(create: ( _ ) => NewCardFormProvider()),
      ], 
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
    
     initialRoute: AppRoutes.initialRoute,
     routes: AppRoutes.getAppRoutes(),
     onGenerateRoute: AppRoutes.onGenerateRoute,
     theme: AppTheme.lightTheme
    ))
    ;
  }
}