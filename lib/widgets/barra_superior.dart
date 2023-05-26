

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viajes_app/services/socket_service.dart';
class TitleCard extends StatelessWidget {
  const TitleCard({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      elevation: 10,
      shadowColor: Colors.black,
      child: Container(
          height: 100,
          width: double.infinity,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 200,
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    "${socketService.viaje.nombre}",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  margin: EdgeInsets.only(right: 10),
                    height: 50,
                    width: 150,
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 252, 180, 8),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Center(
                        child: Text('${socketService.viaje.estado}',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 20,
                                fontWeight: FontWeight.bold)))),

              ],
            ),
          )),
    );
  }
}
