import 'dart:developer';

import 'package:viajes_app/models/item_compra.dart';
import 'package:viajes_app/models/models.dart';

abstract class Componente {
  String id; String tipo; int color;int indice;String nombre;
  dynamic subcomponente;dynamic propiedad_1;dynamic propiedad_2;

  Componente({
    required this.id,required this.tipo,required this.color,required this.indice,
    required this.nombre,required this.subcomponente,required this. propiedad_1,
    required this.propiedad_2,
  });

  factory Componente.fromMap(Map<String, dynamic> obj) {
    String tipo = obj.containsKey('tipo') ? obj['tipo'] : 'no-tipo';
    switch (tipo) {
      case 'habitaciones':
        return ComponenteHabitacion.fromMap(obj);
      case 'confirmaciones':
        return ComponenteAsistencia.fromMap(obj);
      case 'deudas':
        return ComponenteDeudas.fromMap(obj);
      case 'tareas':
        return ComponenteTareas.fromMap(obj);
      case 'equipaje_grupal':
        return ComponenteItemsGrupales.fromMap(obj);
      case 'calendario':
        return ComponenteCalendario.fromMap(obj);
      case "compra":
        return ComponenteCompra.fromMap(obj);
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
            nombre: nombre,
            propiedad_1: "0",
            propiedad_2: "0");

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
            nombre: nombre,
           propiedad_1: "0",
            propiedad_2: "0");

  factory ComponenteAsistencia.fromMap(Map<String, dynamic> obj) {
    List<ConfirmacionAsistencia> confirmadosList = obj
            .containsKey('subcomponente')
        ? (obj['subcomponente'] as List)
            .map((confirmados) => ConfirmacionAsistencia.fromMap(confirmados))
            .toList()
        : [];

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

class ComponenteDeudas extends Componente {
  @override
  String toString() {
    return 'ComponenteHabitacion(id: $id, tipo: $tipo, color: $color, indice: $indice, nombre: $nombre, habitaciones: $subcomponente)';
  }

  ComponenteDeudas({
    required String id,
    required String tipo,
    required int indice,
    required int color,
    required String nombre,
    required subcomponente,
    required int propiedad_1,
  }) : super(
            id: id,
            subcomponente: subcomponente,
            tipo: 'deudas',
            color: color,
            indice: indice,
            nombre: nombre,
            propiedad_1: propiedad_1,
            propiedad_2: "0");

  factory ComponenteDeudas.fromMap(Map<String, dynamic> obj) {
    List<Deuda> habitacionesList = obj.containsKey('subcomponente')
        ? (obj['subcomponente'] as List)
            .map((deudas) => Deuda.fromMap(deudas))
            .toList()
        : [];
// Agrega esta línea

    return ComponenteDeudas(
        id: obj['id'],
        tipo: obj['tipo'],
        color: obj['color'],
        indice: obj['indice'],
        nombre: obj['nombre'],
        propiedad_1: obj['propiedad_1'],
        subcomponente: habitacionesList);
  }
}

class ComponenteTareas extends Componente {
  @override
  String toString() {
    return 'ComponenteHabitacion(id: $id, tipo: $tipo, color: $color, indice: $indice, nombre: $nombre, habitaciones: $subcomponente)';
  }

  ComponenteTareas({
    required String id,
    required String tipo,
    required int indice,
    required int color,
    required String nombre,
    required String propiedad_1,
    required String propiedad_2,
    required subcomponente,
  }) : super(
            id: id,
            subcomponente: subcomponente,
            tipo: 'tareas',
            color: color,
            indice: indice,
            nombre: nombre,
            propiedad_1: propiedad_1,
            propiedad_2: propiedad_2);

  factory ComponenteTareas.fromMap(Map<String, dynamic> obj) {
    List<Tarea> tareasList = obj.containsKey('subcomponente')
        ? (obj['subcomponente'] as List)
            .map((deudas) => Tarea.fromMap(deudas))
            .toList()
        : [];

    return ComponenteTareas(
        id: obj['id'],
        tipo: obj['tipo'],
        color: obj['color'],
        indice: obj['indice'],
        nombre: obj['nombre'],
        propiedad_1: obj['propiedad_1'].toString(),
        propiedad_2: obj['propiedad_2'].toString(),
        subcomponente: tareasList);
  }
}

  class ComponenteItemsGrupales extends Componente {
  ComponenteItemsGrupales({
    required String id,required String tipo,required int indice,required int color,required String nombre,
    required subcomponente,required String propiedad_1,required String propiedad_2,}) 
    : super(
            id: id,
            subcomponente: subcomponente,
            tipo: 'equipaje_grupal',
            color: color,
            indice: indice,
            nombre: nombre,
            propiedad_1: propiedad_1,
            propiedad_2: propiedad_2);

  factory ComponenteItemsGrupales.fromMap(Map<String, dynamic> obj) {
    List<ItemGrupal> itemsList = obj.containsKey('subcomponente')
        ? (obj['subcomponente'] as List)
            .map((items) => ItemGrupal.fromMap(items))
            .toList(): [];
      return ComponenteItemsGrupales(
          id: obj['id'],
          tipo: obj['tipo'],
          color: obj['color'],
          indice: obj['indice'],
          nombre: obj['nombre'],
          propiedad_1: obj['propiedad_1'].toString(),
          propiedad_2: obj['propiedad_2'].toString(),
          subcomponente: itemsList);
    }
  }

  class ComponenteCalendario extends Componente {
  @override
  String toString() {
    return 'ComponenteCalendario(id: $id, tipo: $tipo, color: $color, indice: $indice, nombre: $nombre, items: $subcomponente)';
  }

  ComponenteCalendario({
    required String id,
    required String tipo,
    required int indice,
    required int color,
    required String nombre,
    required subcomponente,
   required DateTime propiedad_1,
   required DateTime propiedad_2,

  }) : super(
            id: id,
            subcomponente: subcomponente,
            tipo: 'calendario',
            color: color,
            indice: indice,
            nombre: nombre,
            propiedad_1: propiedad_1,
            propiedad_2: propiedad_2);

  factory ComponenteCalendario.fromMap(Map<String, dynamic> obj) {
    List<Evento> eventosList = obj.containsKey('subcomponente')
        ? (obj['subcomponente'] as List)
            .map((evento) => Evento.fromMap(evento))
            .toList()
        : [];

      return ComponenteCalendario(
          id: obj['id'],
          tipo: obj['tipo'],
          color: obj['color'],
          indice: obj['indice'],
          nombre: obj['nombre'],
          propiedad_1: DateTime.parse(obj['propiedad_1'] + ' 00:00:00Z').add(const Duration(days: 1)),
          propiedad_2: DateTime.parse(obj['propiedad_2'] + ' 00:00:00Z').add(const Duration(days: 1)),
          subcomponente: eventosList);
    }
  }

  class ComponenteCompra extends Componente {
  @override
  String toString() {
    return 'ComponenteCompra(id: $id, tipo: $tipo, color: $color, indice: $indice, nombre: $nombre, items: $subcomponente)';
  }

  
  ComponenteCompra({
    required String id,
    required String tipo,
    required int indice,
    required int color,
    required String nombre,
    required subcomponente,
   required int propiedad_1,
   required int propiedad_2,

  }) : super(
            id: id,
            subcomponente: subcomponente,
            tipo: 'compra',
            color: color,
            indice: indice,
            nombre: nombre,
            propiedad_1: propiedad_1,
            propiedad_2: propiedad_2);

  factory ComponenteCompra.fromMap(Map<String, dynamic> obj) {
    List<ItemCompra> compraList = obj.containsKey('subcomponente')
        ? (obj['subcomponente'] as List)
            .map((items) => ItemCompra.fromMap(items))
            .toList()
        : [];
      return ComponenteCompra(
          id: obj['id'],
          tipo: obj['tipo'],
          color: obj['color'],
          indice: obj['indice'],
          nombre: obj['nombre'],
          propiedad_1: obj['propiedad_1'],
          propiedad_2: obj['propiedad_2'],
          subcomponente: compraList);
    }
  }