import 'package:flutter/material.dart';

class Icono extends StatelessWidget {
  const Icono({
    super.key,
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.maxWidth,
    required this.tamanoCirculo,
    required this.tamanoIcono,
  });

  final Color color;
  final Color iconColor;
  final IconData icon;
  final double maxWidth;
  final double tamanoCirculo;
  final double tamanoIcono;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(maxWidth))),
        height: tamanoCirculo,
        width: tamanoCirculo,
        child: Icon(
          icon,
          color: iconColor,
          size: tamanoIcono,
        ));
  }
}

class Titulo extends StatelessWidget {
  const Titulo({
    super.key,
    required this.tamanoTitulo,
    required this.fuenteTitulo,
    required this.titulo,
  });

  final double tamanoTitulo;
  final double fuenteTitulo;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: tamanoTitulo,
        child: Center(
          child: Text(
            titulo,
            style: TextStyle(
                color: Colors.black,
                fontSize: fuenteTitulo,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class SubTitulo extends StatelessWidget {
  const SubTitulo({
    super.key,
    required this.tamanoSubTitulo,
    required this.fuenteSubTitulo,
    required this.subTitulo,
  });

  final double tamanoSubTitulo;
  final double fuenteSubTitulo;
  final String subTitulo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: tamanoSubTitulo,
        //  color: Colors.amber,
        child: Text(
          subTitulo,
          style: TextStyle(
              color: Colors.black45,
              fontSize: fuenteSubTitulo,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class BarraProgreso extends StatelessWidget {
  const BarraProgreso({
    super.key,
    required this.paddingTextoBarra,
    required this.maxWidth,
    required this.tamanoBarra,
    required this.actual,
    required this.maximo,
  });

  final double paddingTextoBarra;
  final double maxWidth;
  final double tamanoBarra;
  final int actual;
  final int maximo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTextoBarra),
      child: SizedBox(
          width: maxWidth,
          height: tamanoBarra,
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(maxWidth)),
              child: LinearProgressIndicator(
                value: actual / maximo,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                backgroundColor: Colors.black26,
              ))),
    );
  }
}
