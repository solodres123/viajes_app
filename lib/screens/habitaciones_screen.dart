import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:viajes_app/models/models.dart';
import '../services/socket_service.dart';

class HabitacionesScreen extends StatefulWidget {
  const HabitacionesScreen({Key? key}) : super(key: key);

  @override
  _HabitacionesScreenState createState() => _HabitacionesScreenState();
}

class _HabitacionesScreenState extends State<HabitacionesScreen> {
  ComponenteHabitacion componente = ComponenteHabitacion(
      indice: 0, color: 0, nombre: "", subcomponente: [], id: "", tipo: "");

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    Map<String, dynamic> payload = {
      'id': socketService.idComponente,
      'tipo': socketService.tipoComponente,
    };

    socketService.emit('peticion-this-componente', payload);

    socketService.socket.on(
        'envio-this-componente',
        (payload) => {
              if (mounted)
                {
                  setState(() {
                    componente = ComponenteHabitacion.fromMap(payload);
                    print("componente inicializado");
                  })
                }
            });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     final socketService = Provider.of<SocketService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(componente.nombre),
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
          Expanded(
            child: ListView.builder(
              itemCount: componente.subcomponente.length,
              itemBuilder: (context, index) {
                Habitacion habitacion = componente.subcomponente[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      //a la misma altura que el texto de la habitacion quiero un icono de borrado de habitacion
                      //child: row con el texto y el icono
                      child: Row(
                        children: [
                          Text(
                            habitacion.nombre,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ), 
                          //el icono lo quiero a la derecha
                          Spacer(),
                          IconButton(
                            onPressed: () {
                             showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('¿Estás seguro?'),
                                  content: Text('No podrás recuperar la habitación'),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancelar'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: Text('Borrar'),
                                      onPressed: () {

                                        Map<String, dynamic> payload = {
                                          'id_habitacion': habitacion.id,
                                          'viaje_id': socketService.viaje.id,
                                          "id_componente": socketService.idComponente,
                                        };
                                        Navigator.pop(context);
                                        socketService.emit('borrar-habitacion', payload);
                                        
                                      },
                                    )
                                  ],
                                ),
                              );
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                    CarouselSlider.builder(
                      itemCount: habitacion.camas.length + 1,
                      itemBuilder: (context, index, realIndex) {
                        if (index == habitacion.camas.length) {
                          return GestureDetector(
                            onTap: () => _addCamaDialog(context, habitacion.id),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Card(
                                color: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5,
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      'Añadir cama',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          Cama cama = habitacion.camas[index];
                          return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: GestureDetector(
                                onTap: () => _modCamaDialog(
                                    context, habitacion.id, cama),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey[100],
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Cama ${cama.tipo}',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        ...cama.usuarios.map(
                                          (usuario) => ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(0),
                                            horizontalTitleGap: 2,
                                            leading: CircleAvatar(
                                              maxRadius: 15,
                                              backgroundColor: usuario.color,
                                              child: Text(
                                                usuario.nombre.substring(0, 1) +
                                                    usuario.apellido_1
                                                        .substring(0, 1),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    fontFamily: 'Roboto'),
                                              ),
                                            ),
                                            title: Text(usuario.nombre +
                                                ' ' +
                                                usuario.apellido_1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ));
                        }
                      },
                      options: CarouselOptions(
                        viewportFraction: 0.4,
                        disableCenter: true,
                        padEnds: false,
                        pageSnapping: false,
                        enableInfiniteScroll: false,
                        reverse: false,
                        enlargeCenterPage: false,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () => _addHabitacionDialog(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Añadir habitación',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//q: cual es el problema con el size
//a: el problema es que el size es el de la pantalla, no el del dialog
//q: como se soluciona
//a: se le pasa un size al dialog

  Future<void> _modCamaDialog(context, id_habitacion, Cama cama) async {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          //quiero que a la misma altura que el titulo se vea un icono para borrar la cama
          title: Row(
            children: [
              const Text('Modificar cama'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                 //al pular el boton de borrar se abre un dialogo de confirmacion
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('¿Estás seguro?'),
                      content: const Text(
                          'Se eliminará la cama y todos los usuarios que estén en ella'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            socketService.emit('borrar-cama', {
                              'id_cama': cama.id,
                              'id_viaje': socketService.viaje.id,
                              'id_componente': socketService.idComponente,
                            });
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Borrar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ), 
          content: SizedBox(
              height: 300,
              width: 300,
              child: ListView(
                children: cama.usuarios
                    .map(
                      (usuario) => SizedBox(
                        height: 40,
                        width: 150,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          horizontalTitleGap: 2,
                          leading: CircleAvatar(
                            maxRadius: 15,
                            backgroundColor: usuario.color,
                            child: Text(
                              usuario.nombre.substring(0, 1) +
                                  usuario.apellido_1.substring(0, 1),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFamily: 'Roboto'),
                            ),
                          ),
                          title:
                              Text(usuario.nombre + ' ' + usuario.apellido_1),
                        ),
                      ),
                    )
                    .toList(),
              )),
          actions: [
            TextButton(
              child: const Text('Añadirme'),
              onPressed: cama.usuarios.any((usuario) => usuario.correo == socketService.correo) ? null : () {
                socketService.socket.emit('añadir-usuario-cama',
                    {'id_cama': cama.id, 'correo': socketService.correo, 'viaje_id,': socketService.viaje.id, 'id_componente': socketService.idComponente});
                    Navigator.of(context).pop();
              },
            ),

            TextButton(
              child: const Text('Eliminarme'),
              onPressed: cama.usuarios.any((usuario) => usuario.correo == socketService.correo) ? () {
                socketService.socket.emit('borrar-usuario-cama',
                     {'id_cama': cama.id, 'correo': socketService.correo, 'viaje_id,': socketService.viaje.id, 'id_componente': socketService.idComponente});
                     Navigator.of(context).pop();
              }: null,
            ),
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addCamaDialog(BuildContext context, String habitacionId) async {
    final socketService = Provider.of<SocketService>(context, listen: false);
    TextEditingController _tipoCamaController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Añadir cama'),
          content: TextField(
            controller: _tipoCamaController,
            decoration: const InputDecoration(labelText: 'Tipo de cama'),
          ),
          actions: [
            TextButton(
              child: const Text('Añadir'),
              onPressed: () {
                String tipoCama = _tipoCamaController.text.trim();
                Map<String, dynamic> payload = {
                  'id_componente': socketService.idComponente,
                  'id_habitacion': habitacionId,
                  'tipo_cama': tipoCama,
                  "viaje_id": socketService.viaje.id
                };
                socketService.emit('creacion-nueva-cama', payload);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addHabitacionDialog(BuildContext context) async {
    final socketService = Provider.of<SocketService>(context, listen: false);
    TextEditingController _nombreHabitacionController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Añadir habitación'),
          content: TextField(
            controller: _nombreHabitacionController,
            decoration:
                const InputDecoration(labelText: 'Nombre de la habitación'),
          ),
          actions: [
            TextButton(
              child: const Text('Añadir'),
              onPressed: () {
                String nombreHabitacion =
                    _nombreHabitacionController.text.trim();
                Map<String, dynamic> payload = {
                  'id_componente': socketService.idComponente,
                  'viaje_id': socketService.viaje.id,
                  'nombre': nombreHabitacion,
                };
                socketService.emit('creacion-nueva-habitacion', payload);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
