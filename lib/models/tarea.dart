// ignore: camel_case_types

import 'package:viajes_app/models/models.dart';

class Tarea {
  @override
  String toString() {
    return 'Tarea(id: $id, nombre: $nombre, encargados: $encargados, estado: $estado)';
  }

  String id;
  String nombre;
  List<Usuario> encargados;
  String estado;

  Tarea(
      {
      required this.id,
      required this.nombre,
      required this.encargados,
      required this.estado
      });
  factory Tarea.fromMap(Map<String, dynamic> obj) => Tarea(

      id: obj['id'].toString(),
      nombre: obj['nombre'],
      encargados: obj['encargados']
          .map<Usuario>((usuario) => Usuario.fromMap(usuario))
          .toList(),
      estado: obj['estado']
      );
      
}
