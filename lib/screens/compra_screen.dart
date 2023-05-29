import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/socket_service.dart';
import 'dart:developer';
import 'dart:math' hide log;

class CompraScreen extends StatefulWidget {
  const CompraScreen({Key? key}) : super(key: key);

  @override
  _CompraScreenState createState() => _CompraScreenState();
}

class _CompraScreenState extends State<CompraScreen> {
  List<ItemCompra> items = [];
  ComponenteCompra componente = ComponenteCompra(
      indice: 0,
      color: 0,
      nombre: "",
      subcomponente: [],
      id: "",
      tipo: "",
      propiedad_1: 0,
      propiedad_2: 0);

  List<ItemCompra> pendientes = [];
  List<ItemCompra> comprados = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    Map<String, dynamic> payload = {
      'id': socketService.idComponente,
      'tipo': socketService.tipoComponente,
    };

    socketService.emit('peticion-this-componente', {payload});

    socketService.socket.on('envio-this-componente-compra', (payload) {
      if (mounted) {
        setState(() {
          componente = ComponenteCompra.fromMap(payload);
          items = componente.subcomponente;
          pendientes =
              items.where((element) => element.estado == "pendiente").toList();
          comprados =
              items.where((element) => element.estado == "comprado").toList();
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
          title: const Text('Añadir producto'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nombre del producto:'),
                TextField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  controller: _nombreController,
                ),
                const SizedBox(height: 10),
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
                  'titulo': _nombreController.text,
                  "viaje_id": socketService.viaje.id,
                };
                Navigator.of(context).pop();
                socketService.emit('añadir-item-compra', payload);
                
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteItemDialog(ItemCompra item) {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Estás seguro?'),
          content: const Text('No podrás recuperar el item'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                 Navigator.pop(context);
                 setState(() {
                   
                 });
              },
            ),
            TextButton(
              child: const Text('Borrar'),
              onPressed: () {
                
                Map<String, dynamic> payload = {
                  'id': item.id,
                  'viaje_id': socketService.viaje.id,
                  "id_componente": componente.id,
                };
                Navigator.of(context).pop();
                socketService.emit('borrar-item-compra', payload);
                
              },
            ),
          ],
        );
      },
    );
  }

// quiero que las tiles puedan ser arrastradas a la derecha y que eso cambie el estado de la compra
//a: para hacer eso debes usar un Dismissible, que es un widget que permite arrastrar y borrar
//a: y en el onDismissed puedes cambiar el estado de la compra
// el codigo seria este:
// Dismissible(
//   key: UniqueKey(),
//   onDismissed: (direction) {
//     if (direction == DismissDirection.endToStart) {
//       //aqui cambias el estado de la compra
//     }
//   },
//   child: _buildItemTile(item),
// )

  Widget _buildItemTile(ItemCompra item) {
    return ListTile(
        title: Text(item.titulo),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _showDeleteItemDialog(item);
          },
        ));
  }

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
                             Navigator.pop(context);
                        socketService.emit('borrar-componente', payload);
                   
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
          'Productos pendientes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: pendientes.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            
            key: UniqueKey(),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                Map<String, dynamic> payload = {
                  'id': pendientes[index].id,
                  'id_componente': socketService.idComponente,
                  'viaje_id': socketService.viaje.id,
                };
                socketService.emit('actualizar-item-compra', payload);
              }
               if (direction == DismissDirection.endToStart) {
              _showDeleteItemDialog(pendientes[index]);
              }
            },

            background: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 10.0),
              color: Colors.green,
              child: Text(
                'Marcar como comprado',
                style: TextStyle(color: Colors.white),
              ),
            ),
            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 10.0),
              color: Colors.red,
              child: Text(
                'Borrar de la lista',
                style: TextStyle(color: Colors.white),
              ),
            ),
            child: Container(
              
              child: ListTile(
                title: Text(pendientes[index].titulo), // Asegúrate de que 'pendientes' tiene la propiedad 'nombre'
                // Agrega aquí más detalles si es necesario
              ),
            ),
          );
        },
      ),
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Productos comprados',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: comprados.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(comprados[index].titulo), // Asegúrate de que 'comprados' tiene la propiedad 'nombre'
            // Agrega aquí más detalles si es necesario
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
