
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:viajes_app/theme/app_theme.dart';
import 'package:viajes_app/ui/input_decorations.dart';
import 'package:viajes_app/widgets/componentes/partes_comunes.dart';
import '../models/models.dart';
import '../services/new_card_form.dart';
import '../services/socket_service.dart';
import '../widgets/widgets.dart';
import 'package:intl/intl.dart';



class ComponentesScreen extends StatefulWidget {
  const ComponentesScreen({Key? key}) : super(key: key);
  @override
  State<ComponentesScreen> createState() => _ComponentesScreen();
}

class _ComponentesScreen extends State<ComponentesScreen> {
  List<Componente> _componentes = [];
  Viaje _viaje = Viaje(
      id: '',
      nombre: '',
      descripcion: '',
      fechaInicio: DateTime.now(),
      fechaFin: DateTime.now(),
      estado: '',
      urlImagen: '');
  int _selectedColor = 0;
  final List<Color> pastelColors = [
    const Color.fromARGB(255, 189, 229, 163),
    const Color.fromARGB(255, 255, 183, 178),
    const Color.fromARGB(255, 255, 231, 174),
    const Color.fromARGB(255, 250, 213, 238),
    const Color.fromARGB(255, 213, 220, 249)
  ];
  final TextEditingController newUserController = TextEditingController();
  final Map<String, IconData> componentIconMap = {
    "confirmaciones": Icons.person_rounded,
    'habitaciones': Icons.bed,
    'deudas': Icons.attach_money_outlined,
    'tareas': Icons.list_alt,
    'equipaje_grupal': Icons.card_travel,
    'calendario': Icons.calendar_month,
    'compra': Icons.shopping_cart_rounded,
    'list': Icons.list,
    'map': Icons.map,
    'music': Icons.queue_music_outlined,
    'flight': Icons.flight,
    'lightbulb': Icons.lightbulb,
    'luggage': Icons.luggage,
    'default': Icons.question_mark_rounded,
  };


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final socketService = Provider.of<SocketService>(context, listen: true);
    socketService.socket
        .emit('solicitud-componentes-viaje', socketService.viaje.id);

    socketService.socket.on(
        'envio-viaje',
        (payload) => {
          print("abra cadabra tapate guarra"),
          if (mounted)
            {
              setState(() {
                _viaje = Viaje.fromMap(payload);
                 socketService.setViaje(_viaje);
              })
            }
        },
      );

    socketService.socket.on(
        'lista-componentes',
        (payload) => {
              if (mounted)
                {
                  setState(() {
                    _componentes = (payload as List)
                        .map((componente) => Componente.fromMap(componente))
                        .toList();
                  })
                }
            });
  }

  Widget module(size, comp) {
    //log(comp.toString());
    switch (comp.tipo.toString()) {
      case "confirmaciones":
        Map<String, int> conteoEstados = comp.contarEstados();
        int confirmados = conteoEstados['confirmados'] ?? 0;
        int pendientes = conteoEstados['pendientes'] ?? 0;
        int noAsistiran = conteoEstados['noAsistiran'] ?? 0;
        return PersonasComp(
          tipo: comp.tipo.toString(),
          key: ValueKey(comp.id),
          size: size,
          name: comp.nombre,
          color: pastelColors[comp.color],
          actual: confirmados + noAsistiran,
          maximo: confirmados + pendientes + noAsistiran,
          id: comp.id,
        );
      case "habitaciones":
        int numCamas = 0;
        for (Habitacion habitacion in comp.subcomponente) {
          numCamas += habitacion.camas.length;
        }
        return HabitacionesComp(
          tipo: comp.tipo.toString(),
          id: comp.id,
          key: ValueKey(comp.id),
          size: size,
          name: comp.nombre,
          color: pastelColors[comp.color],
          dormitorios: comp.subcomponente.length,
          camas: numCamas,
        );
      case "deudas":
        return DeudasComp(
          tipo: comp.tipo.toString(),
          id: comp.id,
          key: ValueKey(comp.id),
          size: size,
          name: comp.nombre,
          color: pastelColors[comp.color],
          teDeben: 0,
          debes: comp.propiedad_1,
        );
      case "tareas":
        return TareasComp(
          tipo: comp.tipo.toString(),
          id: comp.id,
          key: ValueKey(comp.id),
          size: size,
          name: comp.nombre,
          color: pastelColors[comp.color],
          completadas: 0,
          total: 0,
        );
      case "equipaje_grupal":
        //print(comp.propiedad_1);
        //print(comp.propiedad_2);
        return EquipajeGrupalComp(
          tipo: comp.tipo.toString(),
          id: comp.id,
          key: ValueKey(comp.id),
          size: size,
          name: comp.nombre,
          color: pastelColors[comp.color],
          llevan: comp.propiedad_1,
          total: comp.propiedad_2,
        );

      case "calendario":
        return CalendarioComp(
            tipo: comp.tipo.toString(),
            id: comp.id,
            key: ValueKey(comp.id),
            size: size,
            name: comp.nombre,
            color: pastelColors[comp.color],
            inicio: DateFormat('dd/MM/yyy – kk:mm')
                .format(comp.propiedad_1)
                .substring(0, 10),
            fin: DateFormat('dd/MM/yyy – kk:mm')
                .format(comp.propiedad_2)
                .substring(0, 10));

      case "compra":
        return CompraComp(
          tipo: comp.tipo.toString(),
          id: comp.id,
          key: ValueKey(comp.id),
          size: size,
          name: comp.nombre,
          color: pastelColors[comp.color],
          actual: comp.propiedad_1,
          maximo: comp.propiedad_2,
        );

      default:
        Map<String, int> conteoEstados = comp.contarEstados();
        int confirmados = conteoEstados['confirmados'] ?? 0;
        int pendientes = conteoEstados['pendientes'] ?? 0;
        int noAsistiran = conteoEstados['noAsistiran'] ?? 0;
        return PersonasComp(
          tipo: comp.tipo.toString(),
          key: ValueKey(comp.id),
          size: size,
          name: comp.nombre,
          color: pastelColors[comp.color],
          actual: confirmados + noAsistiran,
          maximo: confirmados + pendientes + noAsistiran,
          id: comp.id,
        );
    }
  }

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.emit('solicitud-componentes-viaje', socketService.viaje.id);

    socketService.socket.on(
        'lista-componentes',
        (payload) => {
              if (mounted)
                {
                  setState(() {
                    _componentes = List.empty();
                    _componentes = (payload as List)
                        .map((componente) => Componente.fromMap(componente))
                        .toList();
                  })
                }
            });

      socketService.socket.on(
        'envio-viaje',
        (payload) => {
          if (mounted)
            {
              setState(() {
                _viaje = Viaje.fromMap(payload);
                 socketService.setViaje(_viaje);
              })
            }
        },
      );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int size = ((min(MediaQuery.of(context).size.width.floor(),
    MediaQuery.of(context).size.height.floor())) /3).floor();

    final socketService = Provider.of<SocketService>(context);
    final cardForm = Provider.of<NewCardFormProvider>(context);

    addCardToList(String nombre, String tipo, int color) {
      print('Agregando componente');
      print('Nombre: $nombre');
      print('Tipo: $tipo');
      print('Color: $color');
      Navigator.pop(context);
      socketService.socket.emit('creacion-nuevo-componente', {
        'tipo': tipo,
        'color': color,
        'nombre': nombre,
        'viaje_id': socketService.viaje.id
      });
    }

    addNewCard() {
      Color getIconColor(Color backgroundColor) {
        final hslColor = HSLColor.fromColor(backgroundColor);
        final saturation = hslColor.saturation;
        final lightness = hslColor.lightness;
        final targetLightness =
            lightness > 0.5 ? lightness * 0.6 : lightness * 1.4;
        final targetSaturation =
            saturation > 0.5 ? saturation * 0.6 : saturation * 1.4;
        final iconHslColor = HSLColor.fromAHSL(
            1, hslColor.hue, targetSaturation, targetLightness);
        final iconColor = iconHslColor.toColor();
        return iconColor;
      }

      final textController = TextEditingController();
      if (Platform.isAndroid) {
        return showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SizedBox(
                    width: 350,
                    height: 400,
                    child: AlertDialog(
                      title: const Text('Añadir nuevo componente'),
                      content: SingleChildScrollView(
                        // Ajusta la altura mínima según sea necesario
                        child: Column(
                          mainAxisSize: MainAxisSize
                              .min, // Asegúrate de que la columna ocupe el mínimo espacio necesario
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField(
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'habitaciones',
                                          child: Text(
                                              'Distribucion de habitaciones',
                                              style: TextStyle(fontSize: 14))),
                                      DropdownMenuItem(
                                          value: 'confirmaciones',
                                          child: Text('Asistencia',
                                              style: TextStyle(fontSize: 14))),
                                      DropdownMenuItem(
                                          value: 'deudas',
                                          child: Text('Deudas',
                                              style: TextStyle(fontSize: 14))),
                                      DropdownMenuItem(
                                          value: 'tareas',
                                          child: Text('Tareas',
                                              style: TextStyle(fontSize: 14))),
                                      DropdownMenuItem(
                                          value: 'equipaje_grupal',
                                          child: Text('Equipaje grupal',
                                              style: TextStyle(fontSize: 14))),
                                      DropdownMenuItem(
                                          value: 'calendario',
                                          child: Text('Calendario',
                                              style: TextStyle(fontSize: 14))),
                                      DropdownMenuItem(
                                          value: 'compra',
                                          child: Text('lista de la compra',
                                              style: TextStyle(fontSize: 14))),
                                      DropdownMenuItem(
                                          value: 'gatitos',
                                          child: Text('Gatitos',
                                              style: TextStyle(fontSize: 14))),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        print(cardForm.tipo);
                                        cardForm.tipo = value ?? 'habitaciones';
                                        IconData icon =
                                            componentIconMap[cardForm.tipo]!;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icono(
                                  color: pastelColors[_selectedColor],
                                  iconColor: getIconColor(
                                      pastelColors[_selectedColor]),
                                  icon: componentIconMap[cardForm.tipo] ??
                                      componentIconMap['default']!,
                                  maxWidth: 100,
                                  tamanoCirculo: 55,
                                  tamanoIcono: 40,
                                )
                              ],
                            ),
                            SizedBox(
                              child: TextFormField(
                                autofocus: true,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                autocorrect: false,
                                keyboardType: TextInputType.name,
                                decoration:
                                    InputDecorations.authInputDecoration(
                                        hintText: 'nombre del componente',
                                        labelText: 'nombre del componente',
                                        prefixIcon: Icons.abc),
                                onChanged: (value) => cardForm.nombre = value,
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                for (final color in pastelColors)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedColor =
                                            pastelColors.indexOf(color);
                                        print(_selectedColor);
                                      });
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: pastelColors[_selectedColor] ==
                                                  color
                                              ? Colors.black
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            addCardToList(
                                cardForm.nombre, cardForm.tipo, _selectedColor);
                          },
                          child: const Text('Añadir'),
                        )
                      ],
                    ),
                  );
                },
              );
            });
      }
    }

    Widget _buildUserTile(Usuario usuario) {
      
      final socketService = Provider.of<SocketService>(context, listen: false);
      return Column(children: [
        ListTile(
          title: Text(
            usuario.nombre +
                ' ' +
                usuario.apellido_1 +
                ' ' +
                usuario.apellido_2,
            style: TextStyle(fontSize: 15),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('¿Estás seguro?'),
                    actions: [
                      TextButton(
                        child: Text('Cancelar'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text('Borrar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          socketService.emit('borrar-usuario-de-viaje', {
                            'correo': usuario.correo,
                            'viaje_id': socketService.viaje.id
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        Divider(
          height: 3,
        ),
      ]);
    }

    void _showDetailsDialog(BuildContext context) {
  DialogoDeInfoViaje(context, socketService, _buildUserTile);
    }

    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        Componente row = _componentes.removeAt(oldIndex);
        _componentes.insert(newIndex, row);
      });
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 225, 225),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(children: [
        const Padding(
          padding: EdgeInsets.only(top: 0, left: 4, right: 4),
          child: TitleCard(),
        ),
        ReorderableWrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            onReorder: _onReorder,
            onNoReorder: (int index) {
              debugPrint(
                  '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
            },
            onReorderStarted: (int index) {
              debugPrint(
                  '${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
            },
            children: _componentes.map((comp) => module(size, comp)).toList()),
      ]))),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 70,
            right: 0,
            child: FloatingActionButton(
              onPressed: () {
                _showDetailsDialog(context);
              },
              child: const Icon(Icons.info_outline),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              onPressed: () {
                addNewCard();
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> DialogoDeInfoViaje(BuildContext context, SocketService socketService, Widget _buildUserTile(Usuario usuario)) {
    return showDialog(
  context: context,
  builder: (context) {
    DateTime? _startDate;
    DateTime? _endDate;
    String? tripName;
    String? tripStatus;
    final TextEditingController tripNameController =
        TextEditingController();

    void _showChangeTripNameDialog(StateSetter updateParent) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Cambiar nombre del viaje'),
            content: TextField(
              controller: tripNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del viaje',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  tripName = tripNameController.text;
                  updateParent(() {});
                  Navigator.pop(context);
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Información del viaje',
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('¿Estás seguro?'),
                        actions: [
                          TextButton(
                            child: Text('Cancelar'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text('Borrar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              socketService.emit('eliminar-viaje', {
                                'viaje_id': socketService.viaje.id
                              });
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete),
              ),
            ],
          ),



          
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre del viaje:',
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54))),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          tripName != null
                              ? tripName!
                              : socketService.viaje.nombre,
                          style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black))),
                    ),
                    IconButton(
                      onPressed: () => _showChangeTripNameDialog(setState),
                      icon: Icon(Icons.edit),
                    ),
                  ],
                ),
                    Text('Fechas:',
                        style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54))),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('  Inicio:'),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    _startDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now()
                                          .subtract(Duration(days: 365)),
                                      lastDate: DateTime.now()
                                          .add(Duration(days: 365 * 5)),
                                    );
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.calendar_today),
                                ),
                                Text(_startDate != null
                                    ? _startDate.toString().substring(0, 10)
                                    : socketService.viaje.fechaInicio
                                        .toString()
                                        .substring(0, 10)),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('  Fin:'),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    _endDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now()
                                          .subtract(Duration(days: 365)),
                                      lastDate: DateTime.now()
                                          .add(Duration(days: 365 * 5)),
                                    );
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.calendar_today),
                                ),
                                Text(_endDate != null
                                    ? _endDate.toString().substring(0, 10)
                                    : socketService.viaje.fechaFin
                                        .toString()
                                        .substring(0, 10)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text('Estado del Viaje:',
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54))),
                DropdownButton<String>(
                  
                  value: tripStatus ?? socketService.viaje.estado,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  underline: Container(
                    height: 2,
                    width: 400,
                    color: AppTheme.primary,
                  ),
                  isExpanded: true,

                  
                  onChanged: (String? newValue) {
                    setState(() {
                      tripStatus = newValue!;
                    });
                  },
                  items: <String>[
                    'Planificando',
                    'Planificado',
                    'En curso',
                    'Finalizado',
                    'Cancelado',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                    Row(
                      children: [
                        Text('Usuarios invitados:',
                            style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54))),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Invitar a un amigo'),
                                  content: TextFormField(
                                    autofocus: true,
                                    controller: newUserController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        labelText: 'Correo electrónico',
                                        hintText: 'Correo electrónico'),
                                  ),
                                  actions: [
                                     TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        print(socketService.viaje.id);
                                        socketService.emit(
                                            'añadir-usuario-a-viaje', {
                                          'correo': newUserController.text,
                                          'viaje_id': socketService.viaje.id
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Invitar'),
                                    ),
                                   
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.person_add),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                          socketService.usuariosViaje.length, (int index) {
                        return _buildUserTile(
                            socketService.usuariosViaje[index]);
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    socketService.socket.emit('actualizar-viaje', {
                  'id': socketService.viaje.id,
                  'nombre': tripName ?? socketService.viaje.nombre,
                  'fechaInicio': _startDate?.toIso8601String().substring(0,10) ??
                      socketService.viaje.fechaInicio.toIso8601String().substring(0,10),
                  'fechaFin': _endDate?.toIso8601String().substring(0,10) ??
                      socketService.viaje.fechaFin.toIso8601String().substring(0,10),
                  'estado': tripStatus ?? socketService.viaje.estado, 
                  "urlImagen": socketService.viaje.urlImagen,
                  "correo" : socketService.correo,
                
                    });
                    Navigator.of(context).pop();
                     socketService.socket.emit('solicitud-componentes-viaje', socketService.viaje.id);
                    
                  },
                  child: const Text('Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
