// ignore: camel_case_types

import 'package:viajes_app/models/models.dart';

class Deuda {
  @override
  String toString() {
    return 'Deudas(id: $id, nombre: $nombre, deudor: $deudores, acreedor: $acreedor)';
  }

  String id;
  String nombre;
  List<Usuario> deudores;
  Usuario acreedor;
  double cantidad;
  List<DeudaPequena> deudasPequenas;

  Deuda(
      {required this.id,
      required this.nombre,
      required this.deudores,
      required this.acreedor,
      required this.cantidad,
      required this.deudasPequenas});

  factory Deuda.fromMap(Map<String, dynamic> obj) => Deuda(

      cantidad: double.parse(obj['cantidad']),
      id: obj['id'].toString(),
      nombre: obj['nombre'],
      deudores: obj['deudores']
          .map<Usuario>((usuario) => Usuario.fromMap(usuario))
          .toList(),
      acreedor: Usuario.fromMap(obj['acreedor']),
      deudasPequenas: obj['deudasPequenas']
          .map<DeudaPequena>((deudaPequena) => DeudaPequena.fromMap(deudaPequena))
          .toList()
      );
      
}
