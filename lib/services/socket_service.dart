// ignore_for_file: constant_identifier_names, avoid_print, library_prefixes, unnecessary_this

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../models/models.dart';

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  String _nombre = '';
  String _primerApellido = '';
  String _segundoApellido = '';
  String _correo = '';
  late Viaje _viaje;
  Viaje get viaje => this._viaje;

  late List<Usuario> _usuariosViaje;
  List<Usuario> get usuariosViaje => this._usuariosViaje;

  late String _idComponente;
  String get idComponente => this._idComponente;

   late String _tipoComponente;
  String get tipoComponente => this._tipoComponente;

  String get nombre => this._nombre;
  String get primerApellido => this._primerApellido;
  String get segundoApellido => this._segundoApellido;
  String get correo => this._correo;

  ServerStatus _serverStatus = ServerStatus.Connecting;
  ServerStatus get serverStatus => this._serverStatus;
  late IO.Socket _socket;
  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;
//q: como accedo a esta funcion desde otras clases
//a: con el provider

  void setViaje(Viaje viajeRecibido) {
    this._viaje = viajeRecibido;
    notifyListeners();
  }

  void setComponente(String idComponenteRecibido, String tipoComponenteRecibido) {
    this._idComponente = idComponenteRecibido;
    this._tipoComponente = tipoComponenteRecibido;
    notifyListeners();
  }


  SocketService() {
    this._initConfig();
  }
//

  void _initConfig() {
    // Dart client
    _socket = IO.io('http://viajesapp.ddns.net:3000/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.onConnect((_) {
      print('connect');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      print('disconnect');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    _socket.on('usuario-valido', (payload) {
      _nombre = payload.containsKey('nombre') ? payload['nombre'] : 'no hay';
      _primerApellido =
          payload.containsKey('apellido_1') ? payload['apellido_1'] : 'no hay';
      _segundoApellido =
          payload.containsKey('apellido_2') ? payload['apellido_2'] : 'no hay';
      _correo = payload.containsKey('correo') ? payload['correo'] : 'no hay';

      notifyListeners();
    });

    _socket.on(
        'lista-usuarios',
        (payload) => {   
        _usuariosViaje = (payload as List)
                        .map((usuario) => Usuario.fromMap(usuario))
                        .toList()
        });


    _socket.on('mensaje-enviado-por-server', (payload) {
      print('nuevo-mensaje:');
      print('nombre:' + payload['nombre']);
      print('mensaje:' + payload['mensaje']);
      print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'no hay');
    });
  }
}
