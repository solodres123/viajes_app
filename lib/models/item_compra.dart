
import 'package:flutter/material.dart';
import 'package:viajes_app/models/models.dart';

class ItemCompra {
  @override
  String toString() {
    return 'ItemCompra(estado: $estado, id: $id, titulo: $titulo, componenteId: $componenteId)';
  }

  String estado;
  String id;
  String titulo;
  String componenteId;

  ItemCompra({
    required this.estado,
    required this.id,
    required this.titulo,
    required this.componenteId,
  });

  factory ItemCompra.fromMap(Map<String, dynamic> obj) =>
   ItemCompra(
      estado: obj.containsKey('estado') ? obj['estado'] : 'no-estado',
      id: obj.containsKey('id') ? obj['id'] : 'no-id',
      titulo: obj.containsKey('titulo') ? obj['titulo'] : 'no-titulo',
      componenteId: obj.containsKey('componenteId') ? obj['componenteId'] : 'no-componenteId',
    );
}
