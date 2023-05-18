import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/socket_service.dart';
import 'dart:developer';
import 'dart:math' hide log;

class EquipajeGrupalScreen extends StatefulWidget {
  const EquipajeGrupalScreen({Key? key}) : super(key: key);

  @override
  _EquipajeGrupalScreenState createState() => _EquipajeGrupalScreenState();
}

class _EquipajeGrupalScreenState extends State<EquipajeGrupalScreen> {
  List<ItemGrupal> items = [];
  ComponenteItemsGrupales componente = ComponenteItemsGrupales(
      indice: 0, color: 0, nombre: "", subcomponente: [], id: "", tipo: "", propiedad_1: "0", propiedad_2: "0");
  List<Tarea> tareas = [];
  List<ItemGrupal> userItems = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    Map<String, dynamic> payload = {
      'id': socketService.idComponente,
      'tipo': socketService.tipoComponente,
    };

    socketService.emit('peticion-this-componente', {payload});

    socketService.socket.on('envio-this-componente-equipaje_grupal', (payload) {
      if (mounted) {
        setState(() {
          print("patatitas");
          componente = ComponenteItemsGrupales.fromMap(payload);
          items = componente.subcomponente;
        });
      }
    });
    super.initState();
  }

  void _showAddItemDialog() {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);
    TextEditingController _nombreController = TextEditingController();
    TextEditingController _cantidadController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Añadir item grupal'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nombre del item:'),
                TextField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  controller: _nombreController,
                ),
                const SizedBox(height: 10),
                const Text('Cantidad total:'),
                TextField(
                  controller: _cantidadController,
                  keyboardType: TextInputType.number,
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
              child: const Text('Añadir'),
              onPressed: () {
                Map<String, dynamic> payload = {
                  'id_componente': componente.id,
                  'nombre': _nombreController.text,
                  'cantidad_total': int.parse(_cantidadController.text),
                  "viaje_id": socketService.viaje.id,
                };

                socketService.emit('añadir-item-grupal', payload);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showItemDialog(ItemGrupal item) {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(item.nombre),
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirmar eliminación'),
                content: const Text('¿Estás seguro de que deseas eliminar este elemento?'),
                actions: [
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Eliminar'),
                    onPressed: () {
                      Map<String, dynamic> payload = {
                        'id_componente': componente.id,
                        'id': item.id,
                        'viaje_id': socketService.viaje.id,
                      };

                      socketService.emit('borrar-item-grupal', payload);

                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      
                    }
                  ),
                ],
              );
            }
          );
        },
      ),
    ],
  ),
                    
                  
                 
              
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Muestra el valor máximo del artículo y permite aumentar y disminuir
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Valor máximo:'),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              item.cantidadTotal =
                                  max(0, item.cantidadTotal - 1);
                            });
                          },
                        ),
                        Text('${item.cantidadTotal}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              item.cantidadTotal += 1;
                            });
                          },
                        ),
                      ],
                    ),

                    // Lista de asignaciones
                    Column(
                      children: item.asignaciones
                          .map((Asignacion asignacion) => ListTile(
                                title: Text(
                                    '${asignacion.asignado.nombre} ${asignacion.asignado.apellido_1}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          asignacion.cantidad =
                                              max(0, asignacion.cantidad - 1);
                                        });
                                      },
                                    ),
                                    Text('${asignacion.cantidad}'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          asignacion.cantidad += 1;
                                        });
                                      },
                                    ),
                                  ],
                                ),
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
                  child: const Text('Actualizar'),
                  onPressed: () {
                    Navigator.of(context).pop();

                    List<Map<String, dynamic>> updatedData = item.asignaciones
                        .map((asignacion) => {
                              'id_componente': componente.id,
                              "viaje_id": socketService.viaje.id,
                              'email': asignacion.asignado.correo,
                              'cantidad': asignacion.cantidad,
                              'id_item': item.id,
                              'cantidad_total':
                                  item.cantidadTotal, // Nueva propiedad añadida
                            })
                        .toList();

                    updatedData.forEach((element) {
                      //log(element.toString());
                      socketService.emit(
                          'modificar-asignacion-item-grupal', element);
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildItemTile(ItemGrupal item) {
    return ListTile(
      title: Text(item.nombre),
      trailing: Text('${item.cantidadActual}/${item.cantidadTotal}'),
      onTap: () {
        _showItemDialog(item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);
    userItems = [];
    for (int i = 0; i < items.length; i++) {
      for (int j = 0; j < items[i].asignaciones.length; j++) {
        if (items[i].asignaciones[j].asignado.correo == socketService.correo &&
            items[i].asignaciones[j].cantidad > 0) {
          userItems.add(items[i]);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(componente
            .nombre), //quiero un boton en la barra de arriba para borrar el componente
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Items comunes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  elevation: 8,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: _buildItemTile(items[index]),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Qué llevas tú',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userItems.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  elevation: 8,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text(userItems[index].nombre),
                    trailing:

                 Text('${userItems[index].asignaciones.firstWhere((element) => element.asignado.correo == socketService.correo).cantidad}')


                        
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
