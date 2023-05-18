import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/socket_service.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({Key? key}) : super(key: key);

  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  ComponenteAsistencia componente = ComponenteAsistencia(
      indice: 0, color: 0, nombre: "", subcomponente: [], id: "", tipo: "");

  Map<String, List<Usuario>> usuariosPorEstado = {
    'confirmado': [],
    'pendiente': [],
    'no asistira': [],
  };

  Map<String, List<Usuario>> obtenerUsuariosPorEstado(
      ComponenteAsistencia componente) {
    Map<String, List<Usuario>> usuarios = {
      'confirmado': [],
      'pendiente': [],
      'no asistira': [],
    };

    for (ConfirmacionAsistencia confirmacion in componente.subcomponente) {
      print(confirmacion.estado);
//q: quiero que se añada el usuario a la lista de usuarios que tiene el estado de la confirmacion
//a: prueba con: usuarios[confirmacion.estado]!.add(confirmacion.usuario);
      print(confirmacion.usuario);
      usuarios[confirmacion.estado]?.add(confirmacion.usuario as Usuario);
    }

    return usuarios;
  }

  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketService>(context, listen: false);
    Map<String, dynamic> payload = {
      'id': socketService.idComponente,
      'tipo': socketService.tipoComponente,
    };
    socketService.emit('peticion-this-componente', payload);

    socketService.socket.on(
        'envio-this-componente-confirmados',
        (payload) => {
              print("patata"),
              if (mounted)
                {
                  setState(() {
                    componente = ComponenteAsistencia.fromMap(payload);
                    usuariosPorEstado = obtenerUsuariosPorEstado(componente);
                  })
                }
            });
  }

  Widget buildUserList(List<Usuario> usuarios) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: usuarios.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: usuarios[index].color,
            child: Text(
              usuarios[index].nombre.substring(0, 1) +
                  usuarios[index].apellido_1.substring(0, 1),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          title:
              Text(usuarios[index].nombre + ' ' + usuarios[index].apellido_1),
          // onTap: () {
          //   socketService.socket.emit('new-vote', {'id': band.id});
          // },

          //   title: Text(usuarios[index]
          //       .nombre), // Asume que la clase Usuario tiene un atributo "nombre"
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text(componente.nombre)
      , //quiero un boton en la barra de arriba para borrar el componente
      actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
             showDialog(
               context: context,
               builder: (context) => AlertDialog(
                 title: const Text('¿Estás seguro?'),
                 content: const Text('No podrás recuperar el componente'),
                 actions: [
                   TextButton(
                     child: const Text('Cancelar'),
                     onPressed: () => Navigator.pop(context),
                   ),
                   TextButton(
                     child: const Text('Borrar'),
                     onPressed: () {
                       Map<String, dynamic> payload = {
                        'id': socketService.idComponente,
                        'viaje_id': socketService.viaje.id,
                    };
                    Navigator.pop(context);
                    socketService.emit('borrar-componente', payload);
                    Navigator.pop(context);
                     },
                   )
                 ],
               ),
             );

            
          },
        )
      ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pendiente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            buildUserList(usuariosPorEstado['pendiente']!),
            const Text('Confirmado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            buildUserList(usuariosPorEstado['confirmado']!),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            const Text('No asistirá',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            buildUserList(usuariosPorEstado['no asistira']!),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOptionsDialog(context),
        child: const Icon(Icons.edit),
      ),
    );
  }

  Future<void> _showOptionsDialog(BuildContext context) async {
    String? _selectedOption = 'pendiente';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar estado'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Pendiente'),
                    value: 'pendiente',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Confirmado'),
                    value: 'confirmado',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('No asistirá'),
                    value: 'no asistira',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Actualizar'),
              onPressed: () {
                final socketService =
                    Provider.of<SocketService>(context, listen: false);
                Map<String, dynamic> payload = {
                  'id_componente': socketService.idComponente,
                  "correo_usuario": socketService.correo,
                  "estado": _selectedOption,
                  "viaje_id": socketService.viaje.id,
                };
                socketService.emit('cambio-confirmacion', payload);
                Navigator.of(context).pop();
                initState();
              },
            ),
          ],
        );
      },
    );
  }
}
