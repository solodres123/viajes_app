import 'package:viajes_app/models/models.dart';

class Asignacion {
  @override
  String toString() {
    return 'Asignacion(padre_id: $padre_id, asignado: $asignado, cantidad: $cantidad)';
  }

  String padre_id;
  Usuario asignado;
  int cantidad;

  Asignacion(
      {required this.padre_id,
      required this.asignado,
      required this.cantidad});

  factory Asignacion.fromMap(Map<String, dynamic> obj) => Asignacion(
      cantidad: obj['cantidad'],
      padre_id: obj['padre_id'].toString(),
      asignado: Usuario.fromMap(obj['asignado']));
}
