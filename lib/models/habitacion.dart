// ignore: camel_case_types

import 'package:viajes_app/models/models.dart';

class Habitacion {

  @override
  String toString() {
    return 'Habitacion(id: $id, nombre: $nombre, camas: $camas)';
  }
  
  String id;
  String nombre;
  List<Cama> camas;


  Habitacion(
      {
      required this.id,
      required this.nombre,
      required this.camas});

  factory Habitacion.fromMap(Map<String, dynamic> obj) => Habitacion(
      id: obj['id'],
      nombre: obj['nombre'],
      camas: obj.containsKey('camas')?
       (obj['camas'] as List).map((cama) => Cama.fromMap(cama)).toList(): []
  );
     
}
