import 'dart:ffi';
import 'dart:io';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:viajes_app/models/componente.dart';
import 'package:viajes_app/widgets/componentes/equipaje_individual/equipaje_individual_card.dart';
import 'package:viajes_app/widgets/widgets.dart';
import '../models/models.dart';
import '../services/login_form_provider.dart';
import '../services/new_card_form.dart';
import '../services/socket_service.dart';
import '../ui/input_decorations.dart';
import '../widgets/componentes/partes_comunes.dart';
import 'componentes_screen.dart';

class ComponentesScreen extends StatefulWidget {
  const ComponentesScreen({Key? key}) : super(key: key);
  @override
  State<ComponentesScreen> createState() => _ComponentesScreen();
}

class _ComponentesScreen extends State<ComponentesScreen> {
  List<Componente> _componentes = [];
  int _selectedColor = 0;
  final List<Color> pastelColors = [
    const Color.fromARGB(255, 189, 229, 163),
    const Color.fromARGB(255, 255, 183, 178),
    const Color.fromARGB(255, 255, 231, 174),
    const Color.fromARGB(255, 250, 213, 238),
    const Color.fromARGB(255, 213, 220, 249)
  ];
  final Map<String, IconData> componentIconMap = {
    "confirmaciones": Icons.person_rounded,
    'habitaciones': Icons.bed,
    'shopping': Icons.shopping_cart_rounded,
    'calendar': Icons.calendar_month,
    'list': Icons.list,
    'map': Icons.map,
    'music': Icons.queue_music_outlined,
    'flight': Icons.flight,
    'lightbulb': Icons.lightbulb,
    'luggage': Icons.luggage,
    'default': Icons.question_mark_rounded,
  };
  
  Widget module(size, comp) {
      log(comp.toString());
      switch (comp.tipo.toString()) {
        case "confirmaciones":
          Map<String, int> conteoEstados = comp.contarEstados();
          int confirmados = conteoEstados['confirmados'] ?? 0;
          int pendientes = conteoEstados['pendientes'] ?? 0;
          int noAsistiran = conteoEstados['noAsistiran'] ?? 0;
          print('Confirmados: $confirmados');
          print('Por confirmar: $pendientes');
          print('Confirmado que no: $noAsistiran');
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
        case "equipaje_grupal":
          return EquipajeIndividualComp(
            key: ValueKey(comp.id),
            size: size,
            name: comp.nombre,
            color: pastelColors[comp.color],
            llevas: 1,
            necesitas: 1,
          );
        case "carpeta":
          return Carpeta(
            key: ValueKey(comp.id),
          );
        default:
          Map<String, int> conteoEstados = comp.contarEstados();
          int confirmados = conteoEstados['confirmados'] ?? 0;
          int pendientes = conteoEstados['pendientes'] ?? 0;
          int noAsistiran = conteoEstados['noAsistiran'] ?? 0;
          print('Confirmados: $confirmados');
          print('Por confirmar: $pendientes');
          print('Confirmado que no: $noAsistiran');
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
    socketService.socket
        .emit('solicitud-componentes-viaje', socketService.viaje.id);
    socketService.socket.on(
        'lista-componentes',
        (payload) => {
              if (mounted)
                {
                  _componentes = (payload as List)
                      .map((componente) => Componente.fromMap(componente))
                      .toList(),
                  setState(() {})
                }
            });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int size = ((min(MediaQuery.of(context).size.width.floor(),
                MediaQuery.of(context).size.height.floor())) /3).floor();

    final socketService = Provider.of<SocketService>(context);
    final cardForm = Provider.of<NewCardFormProvider>(context);

    void addCardToList(String nombre, String tipo, int color) {
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
                                          child: Text('habitaciones')),
                                      DropdownMenuItem(
                                          value: 'confirmaciones',
                                          child: Text('confirmaciones')),
                                      DropdownMenuItem(
                                          value: 'deudas',
                                          child: Text('deudas')),
                                      DropdownMenuItem(
                                          value: 'gatitos',
                                          child: Text('gatitos')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
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
                            addCardToList(cardForm.nombre, cardForm.tipo, _selectedColor);
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

    

    

    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        Componente row = _componentes.removeAt(oldIndex);
        _componentes.insert(newIndex, row);
      });
    }

    return Scaffold(
//como le digo al wrap si borro un componente durante un reorder
//a: para que el wrap sepa que el componente se ha borrado en lugar de reordenado y no lo ponga en la posicion que le corresponde debes hacer lo siguiente:
//1: en el onReorderStarted: (int index) { debes guardar el index en una variable global
//2: en el onReorder: (int oldIndex, int newIndex) { debes comprobar si el oldIndex es igual al index guardado en el paso 1 y si es asi no hacer nada
//3: en el onNoReorder: (int index) { debes comprobar si el index es igual al index guardado en el paso 1 y si es asi borrar el componente

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
      floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.close,
          ),
          onPressed: () {      
            addNewCard();
          }),
    );
  }
}

class TitleCard extends StatelessWidget {
  const TitleCard({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      elevation: 10,
      shadowColor: Colors.black,
      child: Container(
          height: 100,
          width: double.infinity,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 200,
                child: Text(
                  "${socketService.viaje.nombre}",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                  height: 50,
                  width: 180,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 252, 180, 8),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Center(
                      child: Text('${socketService.viaje.estado}',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 20,
                              fontWeight: FontWeight.bold))))
            ],
          )),
    );
  }
}
