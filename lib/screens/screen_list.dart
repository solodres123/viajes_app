import 'package:viajes_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:viajes_app/router/app_routes.dart';


class ScreenList extends StatelessWidget {
  const ScreenList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final menuOptions=AppRoutes.menuOptions;
    return Scaffold(
      appBar: AppBar(
        title: const Text('componentes en fluter'),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => ListTile(
          title:   Text(menuOptions[index].name),
          leading: Icon(menuOptions[index].icon, color: AppTheme.primary,),
          onTap: () {
            Navigator.pushNamed(context, menuOptions[index].route);
          },
        ),
        separatorBuilder: (_, __) => const Divider(),
        itemCount:menuOptions.length,
      ),
    );
  }
}

                  