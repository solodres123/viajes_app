// ignore: camel_case_types

import 'package:viajes_app/models/models.dart';

class ItemGrupal {
  @override
  String toString() {
    return 'ItemGrupal(id: $id, nombre: $nombre, asignaciones: $asignaciones, cantidad_total: $cantidadTotal)';
  }

  String id;
  String nombre;
  List<Asignacion> asignaciones;
  int cantidadTotal;
  int cantidadActual;

  ItemGrupal(
      {
      required this.id,
      required this.nombre,
      required this.asignaciones,
      required this.cantidadTotal,
      required this.cantidadActual});
      

  factory ItemGrupal.fromMap(Map<String, dynamic> obj) => ItemGrupal(
      id: obj['id'],
      nombre: obj['nombre'],
      asignaciones: List<Asignacion>.from(
          obj['asignaciones'].map((x) => Asignacion.fromMap(x))),
      cantidadTotal: obj['cantidad_total'],
      cantidadActual: obj['actual'],
        );
  
}
