import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import 'dart:developer';
import 'dart:math' hide log;

import '../services/socket_service.dart'; // Asegúrate de importar tus modelos aquí.

class TareasScreen extends StatefulWidget {
  const TareasScreen({Key? key}) : super(key: key);

  @override
  _TareasScreenState createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  ComponenteTareas componente = ComponenteTareas(
      indice: 0, color: 0, nombre: "", subcomponente: [], id: "", tipo: "", propiedad_1: "", propiedad_2: "");
  List<Tarea> tareas = [];

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
        'envio-this-componente-tareas',
        (payload) => {
              if (mounted)
                {
                  setState(() {
                    componente = ComponenteTareas.fromMap(payload);
                    tareas = componente.subcomponente;
                  })
                }
            });
  }
void _showDebtInfoDialog(Tarea tarea) {
  SocketService socketService =
      Provider.of<SocketService>(context, listen: false);

  String _tempEstado = tarea.estado;

  Widget _estadoContainer(String estado, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempEstado = estado;
        });
      },
      child: Container(
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _tempEstado == estado ? Colors.orange : Colors.grey,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(estado),
      ),
    );
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(tarea.nombre),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("Estado:"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _estadoContainer("Pendiente", setState),
                      _estadoContainer("Terminada", setState),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Encargados:'),
                  const SizedBox(height: 10),
                  Column(
                    children: tarea.encargados
                        .map((encargado) => Row(
                              children: [
                                Text(
                                    '${encargado.nombre} ${encargado.apellido_1} ${encargado.apellido_2}'),
                              ],
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Borrar'),
                onPressed: () {
                  socketService.socket.emit('borrar-tarea', {
                    "viaje_id": socketService.viaje.id,
                    'id_tarea': tarea.id,
                    'id_componente': socketService.idComponente,
                  });
                  Navigator.of(context).pop();
                  initState();
                },
              ),
              TextButton(
                child: const Text('Actualizar'),
                onPressed: () {
                  socketService.socket.emit('actualizar-tarea', {
                    "viaje_id": socketService.viaje.id,
                    'id_tarea': tarea.id,
                    'id_componente': socketService.idComponente,
                    'estado': _tempEstado,
                  });
                  Navigator.of(context).pop();
                  initState();
                },
              ),
            ],
          );
        },
      );
    },
  );
}
 

  Widget _buildDebtTile(Tarea tarea) {
    final socketService = Provider.of<SocketService>(context, listen: false);
         return ListTile(

            title: Text("${tarea.nombre}", style: GoogleFonts.lato( fontSize: 20, fontWeight: FontWeight.bold)),


            subtitle: Wrap(
              spacing: 8.0,
              children: tarea.encargados
                  .map(
                    (Usuario usuario) => CircleAvatar(
                      radius: 15,
                      backgroundColor: usuario.color,
                      child: Text(
                        '${usuario.nombre.substring(0, 1)}${usuario.apellido_1.substring(0, 1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            trailing:IconButton(
              iconSize: 40,
              icon: const Icon(Icons.edit_note_sharp),
              onPressed: () {
                 _showDebtInfoDialog(tarea);
                
              },
            ));
  }

  void _showAddPaymentDialog() {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tareaName = '';
        List<Usuario> encargados = [];
        List<Usuario> allUsers = socketService.usuariosViaje;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Nueva tarea'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextFormField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la tarea',
                      ),
                      onChanged: (value) {
                        tareaName = value;
                      },
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: allUsers.map((Usuario user) {
                          return CheckboxListTile(
                            title: Text(user.nombre),
                            value: encargados.contains(user),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value!) {
                                  encargados.add(user);
                                } else {
                                  encargados.remove(user);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ]
                      .map(
                        (Widget widget) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: widget,
                        ),
                      )
                      .toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Añadir'),
                  onPressed: () {
                    socketService.socket.emit('add-tarea', {
                      "viaje_id": socketService.viaje.id,
                      'nombre': tareaName,
                      'encargados': encargados
                          .map((Usuario user) => user.correo)
                          .toList(),
                      'id_componente': socketService.idComponente,
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SocketService socketService =Provider.of<SocketService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(componente
            .nombre), //quiero un boton en la barra de arriba para borrar el componente
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('¿Estás seguro?'),
                  content: Text('No podrás recuperar el componente'),
                  actions: [
                    TextButton(
                      child: Text('Cancelar'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text('Borrar'),
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
      body: Column(
  children: [
    Text('Pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ListView.builder(
        shrinkWrap: true,
        itemCount: tareas.where((tarea) => tarea.estado == 'Pendiente').length,
        itemBuilder: (BuildContext context, int index) {
          Tarea tarea = tareas.where((tarea) => tarea.estado == 'Pendiente').toList()[index];
          return Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: _buildDebtTile(tarea),
          );
        },
      ),
    Text('Terminadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    
       ListView.builder(
        shrinkWrap: true,
        itemCount: tareas.where((tarea) => tarea.estado == 'Terminada').length,
        itemBuilder: (BuildContext context, int index) {
          Tarea tarea = tareas.where((tarea) => tarea.estado == 'Terminada').toList()[index];
          return Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: _buildDebtTile(tarea),
          );
        },
      ),
    
  ],
),
floatingActionButton: FloatingActionButton(
  onPressed: _showAddPaymentDialog,
  child: const Icon(Icons.add),
),
    );
  }
}
