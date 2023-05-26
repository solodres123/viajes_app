// ignore_for_file: library_private_types_in_public_api

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cr_calendar/cr_calendar.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:viajes_app/screens/screens.dart';
import 'package:viajes_app/services/socket_service.dart';
import 'package:viajes_app/theme/app_theme.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Viaje> _viajes = [];
  List<Event> _events = [];
  Viaje _proxViaje = Viaje(
      nombre: 'No hay viajes próximos',
      urlImagen: 'https://viajes.es/static/img/no-trips.1b9b7b7.png',
      fechaInicio: DateTime.now(),
      fechaFin: DateTime.now(),
      estado: 'No hay viajes próximos',
       descripcion: '', 
       id: '');

  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketService>(context, listen: false);
    
    socketService.socket.emit('solicitud-viajes',socketService.correo);
    socketService.socket.emit("register-user",socketService.correo);

    socketService.socket.on("actualiza-viajes", (payload) =>
    setState(() {socketService.socket.emit('solicitud-viajes',socketService.correo);}));

    socketService.socket.on('envio-viajes',(payload) => {
              if (mounted)
                setState(() {
                  _viajes = (payload as List)
                      .map((viaje) => Viaje.fromMap(viaje))
                      .toList();
                  _events = (payload)
                      .map((viaje) => Event(
                          viaje: Viaje.fromMap(viaje),
                          title: viaje['nombre'],
                          startDate: DateTime.parse(
                                  viaje['fechaInicio'] + ' 00:00:00Z')
                              .add(const Duration(days: 1)),
                          endDate:
                              DateTime.parse(viaje['fechaFin'] + ' 00:00:00Z')
                                  .add(const Duration(days: 1))))
                      .toList();
                })
            });
    socketService.socket.on("añadido-a-viaje", (payload) =>
    setState(() {
      socketService.socket.emit('solicitud-viajes',socketService.correo);
    }));

    
  }

  void nuevoViajeDialog(BuildContext context) async {
    final socketService = Provider.of<SocketService>(context, listen: false);
    final _formKey = GlobalKey<FormState>();
    final _nombreController = TextEditingController();
    final _urlImagenController = TextEditingController();
    DateTime? _fechaInicio;
    DateTime? _fechaFin;

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              key: UniqueKey(),
              title: Text('Añadir nuevo viaje'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _nombreController,
                      decoration:
                          InputDecoration(labelText: 'Nombre del viaje'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _urlImagenController,
                      decoration:
                          InputDecoration(labelText: 'URL de la imagen'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una URL';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text("Fecha de inicio:",
                        style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54))),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            _fechaInicio = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            setState(() {});
                          },
                        ),
                        Text(_fechaInicio == null
                            ? 'Añadir fecha de inicio'
                            : DateFormat('yyyy-MM-dd').format(_fechaInicio!)),
                      ],
                    ),
                    Text("Fecha de fin:",
                        style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54))),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            _fechaFin = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            setState(() {});
                          },
                        ),
                        Text(_fechaFin == null
                            ? 'Añadir fecha de fin'
                            : DateFormat('yyyy-MM-dd').format(_fechaFin!)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Añadir'),
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _fechaInicio != null &&
                        _fechaFin != null) {
                      // Aquí debes implementar el envío de datos al servidor
                      socketService.emit("add-viaje", {
                        "correo": socketService.correo,
                        "nombre": _nombreController.text,
                        "urlImagen": _urlImagenController.text,
                        "fechaInicio": _fechaInicio!.toIso8601String(),
                        "fechaFin": _fechaFin!.toIso8601String(),
                      });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          });
        });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      return (event.startDate.isBefore(day) ||
              event.startDate.isAtSameMomentAs(day)) &&
          (event.endDate.isAfter(day) || event.endDate.isAtSameMomentAs(day));
    }).toList();
  }

  bool isInRange(DateTime day, Event event) {
    return day.isAfter(event.startDate) && day.isBefore(event.endDate);
  }

  bool isFirstInRange(DateTime day, Event event) {
    return (day.isAtSameMomentAs(event.startDate));
  }

  bool isLastInRange(DateTime day, Event event) {
    return (day.isAtSameMomentAs(event.endDate));
  }

  @override
  Widget build(BuildContext context) {
    _viajes.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));

    int index = _viajes
        .indexWhere((viaje) => viaje.fechaInicio.isAfter(DateTime.now()));

    if (index != -1) {
      _proxViaje = _viajes[index];
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 249, 249),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            //  const BarraSuperior(),
              const SizedBox(height: 10),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SiguientePlan(proxViaje: _proxViaje)),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TarjetaCalendario()),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text("Próximos viajes",
                                        style: GoogleFonts.lato(
                                            textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54))),
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            Carusel_viajes_futuros(),  
                          ],
                        ),
                      )
                      )
                      ),
             Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text("Viajes pasados",
                                        style: GoogleFonts.lato(
                                            textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54))),
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            Carusel_viajes_pasados(),  
                          ],
                        ),
                      )
                      )
                      ),
            
            ],
          ),
        ),
      ),
    floatingActionButton: FloatingActionButton(
    onPressed: () {
    nuevoViajeDialog(context);
    },
    child: const Icon(Icons.add),
    backgroundColor: AppTheme.primary,
    ),
    );
  }
//caroussel con todos los viajes
  CarouselSlider Carusel_viajes_futuros() {
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 0.4,
        initialPage: 0,
        pageSnapping: false,
        enableInfiniteScroll: true,
        reverse: false,
        enlargeCenterPage: false,
        scrollDirection: Axis.horizontal,
        height: 230,
      ),
    items: _viajes.where((viaje) => viaje.fechaInicio.isAfter(DateTime.now()))
          .map((viaje) => ViajeCard(
                viaje: viaje,
              ))
          .toList()
    );
  }
  //carrousel con los viajes futuros
  CarouselSlider Carusel_viajes_pasados() {
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 0.4,
        initialPage: 0,
        pageSnapping: false,
        enableInfiniteScroll: true,
        reverse: false,
        enlargeCenterPage: false,
        scrollDirection: Axis.horizontal,
        height: 230,
      ),
      items: _viajes.where((viaje) => viaje.fechaFin.isBefore(DateTime.now()))
          .map((viaje) => ViajeCard(
                viaje: viaje,
              ))
          .toList()
    );
  }

  Card TarjetaCalendario() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
              child: calendario(),
            ),
          ),
        ],
      ),
    );
  }

  TableCalendar<dynamic> calendario() {
    return TableCalendar(
      calendarStyle: const CalendarStyle(
          tablePadding: EdgeInsets.symmetric(horizontal: 8)),
      availableGestures: AvailableGestures.horizontalSwipe,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, focusedDay) {
          for (Event event in _events) {
            if (isInRange(day, event)) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: _getEventsForDay(day).length == 1
                          ? const Color.fromARGB(255, 252, 180, 8)
                          : Colors.red),
                  alignment: Alignment.center,
                  child: Text(day.day.toString()),
                ),
              );
            }
            if (isFirstInRange(day, event)) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _getEventsForDay(day).length == 1
                        ? const Color.fromARGB(255, 252, 180, 8)
                        : Colors.red,
                    borderRadius: _getEventsForDay(day).length == 1
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(500),
                            bottomLeft: Radius.circular(500))
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(day.day.toString()),
                ),
              );
            }
            if (isLastInRange(day, event)) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: _getEventsForDay(day).length == 1
                          ? const Color.fromARGB(255, 252, 180, 8)
                          : Colors.red,
                      borderRadius: _getEventsForDay(day).length == 1
                          ? const BorderRadius.only(
                              topRight: Radius.circular(500),
                              bottomRight: Radius.circular(500))
                          : null),
                  alignment: Alignment.center,
                  child: Text(day.day.toString()),
                ),
              );
            }
          }
          return null;
        },
      ),
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      selectedDayPredicate: (day) => isSameDay(DateTime.now(), day),
      focusedDay: DateTime.now(),
      eventLoader: _getEventsForDay,
      onDaySelected: (selectedDay, focusedDay) {
        List<Event> selectedEvents = _getEventsForDay(selectedDay);
        if (selectedEvents.length > 1) {
          //q:como hago un pop up con los eventos del dia
          //a:

          mostrarEventos(selectedEvents);
          print(selectedEvents[0].viaje.nombre);
        } else if (selectedEvents.length == 1) {
          final socketService =
              Provider.of<SocketService>(context, listen: false);
          socketService.setViaje(selectedEvents[0].viaje);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ComponentesScreen()),
          );
        }
      },
    );
  }

  mostrarEventos(List<Event> selectedEvents) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    final textController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0),
          title: const Text('eventos:'),
          content: Container(
            width: 200,
            height: 200,
            color: Colors.white,
            child: ListView.separated(
              itemBuilder: (context, index) => ListTile(
                title: Text(selectedEvents[index].viaje.nombre),
                leading: const Icon(
                  Icons.airplanemode_active,
                  color: Colors.blue,
                ),
                onTap: () {
                  socketService.setViaje(selectedEvents[index].viaje);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ComponentesScreen()),
                  );
                },
              ),
              separatorBuilder: (_, __) => const Divider(),
              itemCount: selectedEvents.length,
            ),
          ),
        );
      },
    );
  }
}

class Event {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final Viaje viaje;

  Event(
      {required this.title,
      required this.startDate,
      required this.endDate,
      required this.viaje});
}

class SiguientePlan extends StatelessWidget {
  final Viaje proxViaje;

  const SiguientePlan({
    super.key,
    required this.proxViaje,
  });

  @override
  Widget build(BuildContext context) {
    print(proxViaje.urlImagen);
    return GestureDetector(
      onTap: () {
        final socketService =
            Provider.of<SocketService>(context, listen: false);

        socketService.setViaje(proxViaje);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ComponentesScreen()),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("Tú próximo plan",
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54))),
                ),
              ),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                      height: 80,
                      width: 80,
                      child: Image(
                        image: NetworkImage(proxViaje.urlImagen),
                        fit: BoxFit.cover,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(proxViaje.nombre,
                              style: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)))),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                            "Faltan " +
                                (proxViaje.fechaInicio
                                    .difference(DateTime.now())
                                    .inDays + 1)
                                    .toString() +
                                " días",
                            style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54))),
                      ),
                    ],
                  ),
                ),
              ])
            ]),
          ),
        ),
      ),
    );
  }
}

class BarraSuperior extends StatelessWidget {
  const BarraSuperior({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Container(
      height: 50,
      width: double.infinity,
      color: const Color.fromARGB(255, 252, 180, 8),
      child: Row(children: [
        const SizedBox(width: 10),
        Align(
            alignment: Alignment.centerLeft,
            child: Text("Bienvenido ${socketService.nombre}",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto'))),
      ]),
    );
  }
}

class ViajeCard extends StatelessWidget {
  Viaje viaje;
  ViajeCard({
    required this.viaje,
  });

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return GestureDetector(
      onTap: () {
        socketService.setViaje(viaje);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ComponentesScreen()),
        );
      },
      child: Container(
        child: Container(
            width: 210,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                      width: 200,
                      height: 135,
                      child: FadeInImage(
                        image: NetworkImage(viaje.urlImagen),
                        placeholder: const AssetImage('assets/jar-loading.gif'),
                        width: 200,
                        height: 230,
                        fit: BoxFit.cover,
                      )),
                ),
                Container(
                  height: 40,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      viaje.nombre,
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 252, 180, 8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(viaje.estado,
                            style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black))),
                      ),
                    ),
                  ],
                )
              ]),
            )),
      ),
    );
  }
}
