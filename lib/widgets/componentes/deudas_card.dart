import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/screens.dart';
import '../../services/socket_service.dart';
import 'partes_comunes.dart';

class DeudasComp extends StatelessWidget {
  final int size;
  final String name;
  final Color color;
  final String id;
  final int debes;
  final String tipo;
  final int teDeben;
  

  DeudasComp(
      {super.key,
      required this.size,
      required this.name,
      required this.color,
      required this.debes,
      required this.teDeben,
      required this.id,
      required this.tipo});

  final List<IconData> icons = [
    Icons.shopping_cart_rounded,
    Icons.calendar_month,
    Icons.list,
    Icons.map,
    Icons.queue_music_outlined,
    Icons.flight,
    Icons.bed,
    Icons.lightbulb,
    Icons.luggage,
    Icons.attach_money_outlined
  ];

  Color getIconColor(Color backgroundColor) {
    final hslColor = HSLColor.fromColor(backgroundColor);
    final saturation = hslColor.saturation;
    final lightness = hslColor.lightness;
    final targetLightness = lightness > 0.5 ? lightness * 0.6 : lightness * 1.4;
    final targetSaturation =
        saturation > 0.5 ? saturation * 0.6 : saturation * 1.4;
    final iconHslColor =
        HSLColor.fromAHSL(1, hslColor.hue, targetSaturation, targetLightness);
    final iconColor = iconHslColor.toColor();
    return iconColor;
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    Color iconColor = getIconColor(color);

    final cellWidth = size.toDouble();
    final cellHeight = (size / 0.724).toDouble();

    //padding entre cartas x2
    double paddingMarco = cellHeight * 0.04;

    final maxWidth = cellWidth - paddingMarco * 2;
    final maxHeight = cellHeight - paddingMarco * 2;

    double fuenteTitulo = maxHeight * 0.09;
    double fuenteSubTitulo = maxHeight * 0.095;
    double anduloEsquina = maxHeight * 0.08;
    double paddingIconoArriba = maxHeight * 0.06; //pading icono arriba
    double paddingIconoAbajo = maxHeight * 0.03; //pading icono abajos
    double tamanoCirculo = maxHeight * 0.44; //icono
    double tamanoIcono = maxHeight * 0.21; //no cuenta
    double tamanoTitulo = maxHeight * 0.12; //titulo
    double tamanoSubTitulo = maxHeight * 0.2; //texto 2 lineas
    double tamanoBarra = maxHeight * 0.04; //alto barra
    double paddingTextoBarra = maxHeight * 0.03; //padding texto-barra

    // ignore: avoid_print, prefer_interpolation_to_compose_strings
    print("widget:" + maxHeight.toString());
    return SizedBox(
        width: cellWidth,
        height: cellHeight,
        child: Padding(
            padding: EdgeInsets.all(paddingMarco),
            child: GestureDetector(
              onTap: () {
                socketService.setComponente(id, tipo);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PaymentsScreen()),
                );
              },
              child: Card(
                  margin: const EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(anduloEsquina)),
                  clipBehavior: Clip.antiAlias,
                  elevation: 8,
                  shadowColor: Colors.black,
                  child: Column(children: [
                    Padding(padding: EdgeInsets.only(top: paddingIconoArriba)),
                    Icono(
                        color: color,
                        iconColor: iconColor,
                        icon: Icons.attach_money_outlined,
                        maxWidth: maxWidth,
                        tamanoCirculo: tamanoCirculo,
                        tamanoIcono: tamanoIcono),
                    Padding(
                        padding: EdgeInsets.only(bottom: paddingIconoAbajo)),
                    Titulo(
                        tamanoTitulo: tamanoTitulo,
                        fuenteTitulo: fuenteTitulo,
                        titulo: name),
                    SubTitulo(
                        tamanoSubTitulo: tamanoSubTitulo,
                        fuenteSubTitulo: fuenteSubTitulo,
                        subTitulo: "Han gastado:" + "\n" + debes.toString() + "€"
                            ),
                    Padding(padding: EdgeInsets.only(top: paddingTextoBarra)),
                  ])),
            )));
  }
}
