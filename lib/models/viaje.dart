// ignore: camel_case_types

class Viaje {
  String id;
  String nombre;
  String descripcion;
  DateTime fechaInicio;
  DateTime fechaFin;
  String estado;
  String urlImagen;

  Viaje(
      {required this.id,
      required this.nombre,
      required this.descripcion,
      required this.fechaInicio,
      required this.fechaFin,
      required this.estado,
      required this.urlImagen});

  factory Viaje.fromMap(Map<String, dynamic> obj) => Viaje(
      id: obj['id'],
      nombre: obj['nombre'],
      descripcion: obj['descripcion'],
      fechaInicio: DateTime.parse(obj['fechaInicio']+ ' 00:00:00Z').add(Duration(days:1)),
      fechaFin: DateTime.parse(obj['fechaFin']+ ' 00:00:00Z').add(Duration(days:1)),
      estado: obj['estado'],
      urlImagen: obj['urlImagen']);
}
