import 'package:viajes_app/models/models.dart';

class DeudaPequena {
  @override
  String toString() {
    return 'DeudaPequena(idDeudaPadre: $idDeudaPadre, deudor: $deudor, acreedor: $acreedor, cantidad: $cantidadPP)';
  }

  String idDeudaPadre;
  Usuario deudor;
  Usuario acreedor;
  double cantidadPP;
 
  DeudaPequena(
      {required this.idDeudaPadre,
      required this.deudor,
      required this.acreedor,
      required this.cantidadPP});
      

  factory DeudaPequena.fromMap(Map<String, dynamic> obj) => DeudaPequena(
      cantidadPP: double.parse(obj['cantidadPP']),
      idDeudaPadre: obj['padre_id'].toString(),
      deudor: Usuario.fromMap(obj['deudor']),
      acreedor: Usuario.fromMap(obj['acreedor']));
}