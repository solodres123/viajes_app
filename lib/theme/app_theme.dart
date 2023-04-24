import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color.fromARGB(255, 252, 180, 8);

  static final ThemeData lightTheme = ThemeData.light().copyWith(        
    //color primario
        
        //appBar Theme
        appBarTheme: const AppBarTheme(
          color: primary,
          elevation: 0,
          centerTitle: true
        ),
        //textbutton theme
        textButtonTheme: TextButtonThemeData(
        style:TextButton.styleFrom(
              foregroundColor: primary
              ),      
        ),
         //textbutton theme
         floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppTheme.primary,
         ),
        // elevated button
        elevatedButtonTheme:ElevatedButtonThemeData(
         style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape: const StadiumBorder(),
            elevation: 0,
          ),
        ),
        //TEMA TEXTO INPUT
        inputDecorationTheme:const InputDecorationTheme(
          floatingLabelStyle: TextStyle(color: AppTheme.primary),

          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.primary),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            ),

          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))
            )
        )
  );
       
}
