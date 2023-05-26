import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/models.dart';
import '../services/socket_service.dart';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:intl/intl.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({Key? key}) : super(key: key);
  @override
  _CalendarioScreenState createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  List<bool> _userCheckboxStates = [];
  List<Usuario> allUsers = [];
  List<Evento> _events = [];
  DateTimeRange? fechaViaje;

  List<Evento> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      int userIndex =
          allUsers.indexWhere((user) => user.correo == event.usuario.correo);
      return (userIndex == -1 || _userCheckboxStates[userIndex]) &&
          event.inicio.isBefore(day.add(const Duration(days: 1))) &&
          event.fin.isAfter(day.subtract(const Duration(days: 1)));
    }).toList();
  }

  bool isInRange(DateTime day, Evento event) {
    return day.isAfter(event.inicio) && day.isBefore(event.fin);
  }

  bool isFirstInRange(DateTime day, Evento event) {
    return (day.isAtSameMomentAs(event.inicio));
  }

  bool isFirstInRange2(DateTime day, DateTimeRange fechaViaje) {
    return (day.isAtSameMomentAs(fechaViaje.start));
  }

  bool isLastInRange(DateTime day, Evento event) {
    return (day.isAtSameMomentAs(event.fin));
  }

  bool isLastInRang2e(DateTime day, DateTimeRange fechaViaje) {
    return (day.isAtSameMomentAs(fechaViaje.end));
  }

  ComponenteCalendario componente = ComponenteCalendario(
      indice: 0,
      color: 0,
      nombre: "",
      subcomponente: [],
      id: "",
      tipo: "",
      propiedad_1: DateTime.now(),
      propiedad_2: DateTime.now());

  Widget _buildEventTile(Evento event) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Column(children: [
      ListTile(
        title: Text(
          '${DateFormat('dd/MM/yyy – kk:mm').format(event.inicio).substring(0, 10)} - ${DateFormat('dd/MM/yyy – kk:mm').format(event.fin).substring(0, 10)}',
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  key: UniqueKey(),
                  title: Text('¿Estás seguro?'),
                  content: Text('No podrás recuperar este evento'),
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
                        Map<String, dynamic> payload = {
                          "viaje_id": socketService.viaje.id,
                          'id': event.id,
                          'id_componente': socketService.idComponente,
                        };

                        Navigator.of(context).pop();
                        socketService.emit('borrar-evento', payload);
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

  void _showEditTravelDateDialog() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    DateTimeRange? newDateRange;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          key: UniqueKey(),
          title: const Text('Editar fecha del viaje'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () async {
                  final DateTimeRange? pickedDateRange =
                      await showDateRangePicker(
                    context: context,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDateRange != null) {
                    newDateRange = pickedDateRange;
                  }
                },
                child: Text(newDateRange != null
                    ? 'Fecha seleccionada: ${newDateRange!.start.toLocal()} - ${newDateRange!.end.toLocal()}'
                    : 'Seleccione un rango de fechas'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            //el boton solo se activa si se ha seleccionado un rango de fechas
            // para que no se pueda actualizar con fechas vacias o null
            // escribe esto:
            //
            TextButton(
              child: const Text('Actualizar'),
              onPressed: () {
                if (newDateRange != null) {
                  setState(() {
                    Map<String, dynamic> payload = {
                      'fecha_inicio': newDateRange!.start.toIso8601String(),
                      'fecha_final': newDateRange!.end.toIso8601String(),
                      'id_componente': socketService.idComponente,
                      "viaje_id": socketService.viaje.id,
                    };

                    socketService.emit('actualizar-fechas', payload);
                    Navigator.of(context).pop();
                    fechaViaje = newDateRange;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  TableCalendar<dynamic> calendario() {
    return TableCalendar(
      calendarStyle: const CalendarStyle(
        isTodayHighlighted: false,
        todayDecoration: BoxDecoration(
          color: Colors.transparent, // Sin color de fondo
          shape: BoxShape.rectangle, // Sin forma de círculo
        ),
        todayTextStyle: TextStyle(
          // Estilo del texto igual a los otros días
          color: Colors.black,
          fontSize: 16,
        ),
        selectedTextStyle: TextStyle(
          // Estilo del texto del día seleccionado igual a los otros días
          color: Colors.black,
          fontSize: 16,
        ),
        selectedDecoration: BoxDecoration(
          // Sin color de fondo ni forma en el día seleccionado
          color: Colors.transparent,
          shape: BoxShape.rectangle,
        ),
        tablePadding: EdgeInsets.symmetric(horizontal: 8),
      ),
      availableGestures: AvailableGestures.horizontalSwipe,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, focusedDay) {
          bool isGreenDay = fechaViaje != null &&
              day.isAfter(
                  fechaViaje!.start.subtract(const Duration(days: 1))) &&
              day.isBefore(fechaViaje!.end.add(const Duration(days: 1)));

          Widget? circleEvent;

          for (Evento event in _getEventsForDay(day)) {
            if (isInRange(day, event)) {
              circleEvent = Center(
                  child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: event.prioridad == 1
                      ? Colors.red
                      : const Color.fromRGBO(252, 180, 8, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ));

              break;
            }
            if (isFirstInRange(day, event)) {
              circleEvent = Center(
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: event.prioridad == 1
                        ? Colors.red
                        : const Color.fromRGBO(252, 180, 8, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
              break;
            }
            if (isLastInRange(day, event)) {
              circleEvent = Center(
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: event.prioridad == 1
                        ? Colors.red
                        : const Color.fromRGBO(252, 180, 8, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
              break;
            }
          }

          return Stack(
            children: [
              if (isGreenDay)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: isFirstInRange2(day, fechaViaje!)
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(500),
                              bottomLeft: Radius.circular(500))
                          : isLastInRang2e(day, fechaViaje!)
                              ? const BorderRadius.only(
                                  topRight: Radius.circular(500),
                                  bottomRight: Radius.circular(500))
                              : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(day.day.toString()),
                  ),
                ),
              if (circleEvent != null) circleEvent,
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(day.day.toString()),
                ),
              ),
            ],
          );
        },
      ),
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      selectedDayPredicate: (day) => isSameDay(DateTime.now(), day),
      focusedDay: DateTime.now(),
    );
  }

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    Map<String, dynamic> payload = {
      'id': socketService.idComponente,
      'tipo': socketService.tipoComponente,
    };

    socketService.emit('peticion-this-componente', {payload});
    _userCheckboxStates =
        List<bool>.filled(socketService.usuariosViaje.length, true);
    socketService.socket.on('envio-this-componente-calendario', (payload) {
      if (mounted) {
        setState(() {
          componente = ComponenteCalendario.fromMap(payload);
          if (componente.id == socketService.idComponente) {
            _events = componente.subcomponente;
            print(componente.propiedad_1);
            print(componente.propiedad_2);
            fechaViaje = DateTimeRange(
                start: componente.propiedad_1, end: componente.propiedad_2);
            print("eventos");
            print(_events);
          }
        });
      }
    });
    super.initState();
  }

  void _showAddEventDialog() {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);
    DateTime? _fechaInicio;
    DateTime? _fechaFinal;
    TextEditingController _prioridadController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            key: UniqueKey(),
            title: const Text('Añadir evento'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha de inicio:'),
                  TextButton(
                    onPressed: () async {
                      final DateTime? fechaInicioSeleccionada =
                          await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (fechaInicioSeleccionada != null) {
                        setState(() {
                          _fechaInicio = fechaInicioSeleccionada;
                        });
                      }
                    },
                    child: Text(_fechaInicio != null
                        ? 'Fecha seleccionada: ${_fechaInicio?.toLocal()}'
                        : 'Seleccione una fecha'),
                  ),
                  const SizedBox(height: 10),
                  const Text('Fecha final:'),
                  TextButton(
                    onPressed: () async {
                      final DateTime? fechaFinalSeleccionada =
                          await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (fechaFinalSeleccionada != null) {
                        setState(() {
                          _fechaFinal = fechaFinalSeleccionada;
                        });
                      }
                    },
                    child: Text(_fechaFinal != null
                        ? 'Fecha seleccionada: ${_fechaFinal?.toLocal()}'
                        : 'Seleccione una fecha'),
                  ),
                  const SizedBox(height: 10),
                  const Text('Prioridad (0 o 1):'),
                  TextField(
                    controller: _prioridadController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-1]')),
                    ],
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
                    'fecha_inicio': _fechaInicio?.toIso8601String(),
                    'fecha_final': _fechaFinal?.toIso8601String(),
                    'prioridad': int.parse(_prioridadController.text),
                    'id_componente': socketService.idComponente,
                    'correo': socketService.correo,
                    "viaje_id": socketService.viaje.id,
                  };

                  socketService.emit('añadir-evento', payload);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  Column _buildUserCheckboxes() {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);
    allUsers = socketService.usuariosViaje;

    return Column(
      children: allUsers.asMap().entries.map<Widget>((entry) {
        int index = entry.key;
        Usuario user = entry.value;
        print(_userCheckboxStates);
        return CheckboxListTile(
          title: Text('${user.nombre} ${user.apellido_1} ${user.apellido_2}'),
          value: _userCheckboxStates[index],
          onChanged: (bool? value) {
            setState(() {
              _userCheckboxStates[index] = value!;
            });
          },
        );
      }).toList(),
    );
  }

// Lista de asignaciones

  @override
  Widget build(BuildContext context) {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);

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
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Text("Fechas de todos:",
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)))),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 8,
                    child: Column(
                      children: [
                        calendario(),
                        Divider(
                          thickness: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child:
                                    //q: si fecha viaje es 1901-01-02 el texto sera patata
                                    //a: si fecha viaje es null el texto sera patata
                                    //a: si fecha viaje no es null el texto sera la fecha
                                    Text(
                                        fechaViaje!.start
                                                    .toIso8601String()
                                                    .substring(0, 10) ==
                                                "1901-01-02"
                                            ? 'Fecha para el plan sin asignar'
                                            : '${DateFormat('dd/MM/yyy – kk:mm').format(fechaViaje!.start).substring(0, 10)}' +
                                                ' - ' +
                                                '${DateFormat('dd/MM/yyy – kk:mm').format(fechaViaje!.end).substring(0, 10)}',
                                        style: GoogleFonts.lato(
                                            textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54))),
                              ),
                              Spacer(),
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blue,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit),
                                    color: Colors.white,
                                    onPressed: _showEditTravelDateDialog,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ))),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 8,
                  child: _buildUserCheckboxes(),
                )),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text("Tus otros planes:",
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54))),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                        children: List.generate(_events.length, (int index) {
                      return _buildEventTile(_events[index]);
                    })))),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
