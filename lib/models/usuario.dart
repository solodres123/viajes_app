import 'package:flutter/rendering.dart';

class Usuario {

  String correo;
  String nombre;
  String apellido_1;
  String apellido_2;
  Color color;

  Usuario(
      {
      required this.correo,
      required this.nombre,
      required this.apellido_1,
      required this.apellido_2,
      required this.color,
      });


  factory Usuario.fromMap(Map<String, dynamic> obj) => Usuario(
    correo: obj.containsKey('correo') ? obj['correo'] : 'no-correo', 
    nombre: obj.containsKey('nombre') ? obj['nombre'] : 'no-nombre',
    apellido_1: obj.containsKey('apellido_1') ? obj['apellido_1'] : 'no-primer_apellido',
    apellido_2: obj.containsKey('apellido_2') ? obj['apellido_2'] : 'no-segundo_apellido',
    color: obj.containsKey('color') ? colores[obj['color']] : colores[0],
);
}

final List<Color> colores = [
  Color(0xFFF4A460), // Brown
  Color(0xFF00CED1), // Turquoise
  Color(0xFFA52A2A), // Brown (dark)
  Color(0xFFDA70D6), // Orchid
  Color(0xFF00FA9A), // Medium Spring Green
  Color(0xFF7B68EE), // Medium Slate Blue
  Color(0xFF87CEEB), // Sky Blue
  Color(0xFFB22222), // Firebrick
  Color(0xFF20B2AA), // Light Sea Green
  Color(0xFF1E90FF), // Dodger Blue
];


