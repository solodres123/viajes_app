// ignore: camel_case_types

import 'package:viajes_app/models/models.dart';

class Evento {

  @override
  String toString() {
    return 'Evento(id: $id, inicio: $inicio, fin: $fin, usuario: $usuario, prioridad: $prioridad)';
  }
  
  DateTime inicio;
  DateTime fin;
  Usuario usuario;
  String id;
  int prioridad;


  Evento(
      {
      required this.inicio,
      required this.fin,
      required this.usuario,
      required this.id,
      required this.prioridad});
      

  factory Evento.fromMap(Map<String, dynamic> obj) => Evento(
      id: obj['id'],
      //q: como hago para que las fechas se vean en formato dia mes año
      //a: en el main.dart se agrega el import 'package:intl/intl.dart';
      //a: y se agrega el metodo DateFormat('dd/MM/yyyy').format(DateTime.parse(obj['inicio'] + ' 00:00:00Z').add(const Duration(days: 1))),
      inicio: DateTime.parse(obj['inicio'] + ' 00:00:00Z').add(const Duration(days: 1)),                      
      fin: DateTime.parse(obj['fin'] + ' 00:00:00Z').add(const Duration(days: 1)),                           
      usuario: Usuario.fromMap(obj['usuario']),
      prioridad: obj['prioridad']
  );
     
}
