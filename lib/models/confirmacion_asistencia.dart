
import 'package:flutter/material.dart';
import 'package:viajes_app/models/models.dart';

class ConfirmacionAsistencia {
  @override
  String toString() {
    return 'ConfirmacionAsistencia(estado: $estado, correo: $usuario, componenteId: $componenteId)';
  }

  String estado;
  Usuario usuario;
  String componenteId;

  ConfirmacionAsistencia({
    required this.estado,
    required this.usuario,
    required this.componenteId,
  });

  factory ConfirmacionAsistencia.fromMap(Map<String, dynamic> obj) =>
    ConfirmacionAsistencia(
      estado: obj.containsKey('estado') ? obj['estado'] : 'no-estado',
      usuario: Usuario.fromMap(obj.containsKey('usuario') ? obj['usuario'] : 'no-usuario'),
      componenteId: obj.containsKey('componenteId') ? obj['componenteId'] : 'no-componenteId',
    );
}