

import 'package:viajes_app/models/models.dart';

abstract class Componente {
  String id;
  String tipo;
  int color;
  int indice;
  String nombre;
  dynamic subcomponente;

  Componente({
    required this.id,
    required this.tipo,
    required this.color,
    required this.indice,
    required this.nombre,
    required this.subcomponente,
  });

  factory Componente.fromMap(Map<String, dynamic> obj) {
    String tipo = obj.containsKey('tipo') ? obj['tipo'] : 'no-tipo';
    switch (tipo) {
      case 'habitaciones':
        return ComponenteHabitacion.fromMap(obj);
        
      case 'confirmaciones':
        return ComponenteAsistencia.fromMap(obj);
        
      default:
        return ComponenteHabitacion.fromMap(obj);
        
    }
  }
}

class ComponenteHabitacion extends Componente {
  @override
  String toString() {
    return 'ComponenteHabitacion(id: $id, tipo: $tipo, color: $color, indice: $indice, nombre: $nombre, habitaciones: $subcomponente)';
  }

  ComponenteHabitacion({
    required String id,
    required String tipo,
    required int indice,
    required int color,
    required String nombre,
    required subcomponente,
  }) : super(
            id: id,
            subcomponente: subcomponente,
            tipo: 'habitaciones',
            color: color,
            indice: indice,
            nombre: nombre);

  factory ComponenteHabitacion.fromMap(Map<String, dynamic> obj) {
    List<Habitacion> habitacionesList = obj.containsKey('subcomponente')
        ? (obj['subcomponente'] as List)
            .map((habitaciones) => Habitacion.fromMap(habitaciones))
            .toList()
        : [];
// Agrega esta línea

    return ComponenteHabitacion(
        id: obj['id'],
        tipo: obj['tipo'],
        color: obj['color'],
        indice: obj['indice'],
        nombre: obj['nombre'],
        subcomponente: habitacionesList);
  }
}

class ComponenteAsistencia extends Componente {
  @override
  String toString() {
    return 'ComponenteConfirmados(id: $id, tipo: $tipo, color: $color, indice: $indice, nombre: $nombre, confirmados: $subcomponente)';
  }

  ComponenteAsistencia({
    required String id,
    required String tipo,
    required int indice,
    required int color,
    required String nombre,
    required subcomponente,
  }) : super(
            id: id,
            subcomponente: subcomponente,
            tipo: 'confirmados',
            color: color,
            indice: indice,
            nombre: nombre);

  factory ComponenteAsistencia.fromMap(Map<String, dynamic> obj) {
    List<ConfirmacionAsistencia> confirmadosList = obj.containsKey('subcomponente')?
    (obj['subcomponente'] as List).map((confirmados) => 
    ConfirmacionAsistencia.fromMap(confirmados)).toList(): [];

    return ComponenteAsistencia(
        id: obj['id'],
        tipo: obj['tipo'],
        color: obj['color'],
        indice: obj['indice'],
        nombre: obj['nombre'],
        subcomponente: confirmadosList);
  }

  Map<String, int> contarEstados() {
    int confirmados = 0;
    int pendientes = 0;
    int noAsistiran = 0;

    for (ConfirmacionAsistencia confirmacion in subcomponente) {
      switch (confirmacion.estado) {
        case 'confirmado':
          confirmados++;
          break;
        case 'pendiente':
          pendientes++;
          break;
        case 'no asistira':
          noAsistiran++;
          break;
      }
    }

    return {
      'confirmados': confirmados,
      'pendientes': pendientes,
      'noAsistiran': noAsistiran,
    };
  }
}