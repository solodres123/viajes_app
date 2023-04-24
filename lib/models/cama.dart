import 'package:viajes_app/models/models.dart';

class Cama {

  @override
  String toString() {
    return 'Cama(id: $id, tipo: $tipo, usuarios: $usuarios)';
  }
  
  String id;
  String tipo;
  List<Usuario> usuarios=[];


  Cama(
      {
      required this.id,
      required this.tipo,
      required this.usuarios});


  factory Cama.fromMap(Map<String, dynamic> obj) => Cama(

      id: obj['id'],
      tipo: obj['tipo'],
      usuarios: obj.containsKey('usuarios')?
       (obj['usuarios'] as List).map((usuario) => Usuario.fromMap(usuario)).toList(): []
  );  

}
