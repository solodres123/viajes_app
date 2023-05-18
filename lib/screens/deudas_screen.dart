import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import 'dart:developer';
import 'dart:math' hide log;

import '../services/socket_service.dart'; // Asegúrate de importar tus modelos aquí.

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  ComponenteDeudas componente = ComponenteDeudas(
      indice: 0, color: 0, nombre: "", subcomponente: [], id: "", tipo: "", propiedad_1: 0);
  int displayIndex = 0;
  List<Deuda> deudas = []; // Asegúrate de obtener la lista de deudas aquí.
  late List<DeudaPequena> deudasPequenas;
  late List<DeudaPequena> deudasSimplificadas = [];
  late double balance;
  List<DeudaPequena> deudasUsuario = [];

  List<DeudaPequena> simplifyDebts(List<DeudaPequena> debts) {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);
    Map<String, double> balances = {};

    for (var debt in debts) {
      String giverId = debt.deudor.correo;
      String receiverId = debt.acreedor.correo;
      double amount = debt.cantidadPP;

      balances.putIfAbsent(giverId, () => 0);
      balances.putIfAbsent(receiverId, () => 0);

      balances[giverId] = balances[giverId]! - amount;
      balances[receiverId] = balances[receiverId]! + amount;
    }

    List<MapEntry<String, double>> creditors =
        balances.entries.where((entry) => entry.value > 0).toList();
    List<MapEntry<String, double>> debtors =
        balances.entries.where((entry) => entry.value < 0).toList();

    List<DeudaPequena> simplifiedDebts = [];

    int creditorIndex = 0;
    int debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      MapEntry<String, double> creditor = creditors[creditorIndex];
      MapEntry<String, double> debtor = debtors[debtorIndex];

      double transactionAmount = min(creditor.value, -debtor.value);


      if (transactionAmount > 0.01)
      simplifiedDebts.add(DeudaPequena(
          deudor: socketService.usuariosViaje
              .firstWhere((element) => element.correo == debtor.key),
          acreedor: socketService.usuariosViaje
              .firstWhere((element) => element.correo == creditor.key),
          cantidadPP: double.parse(transactionAmount.toStringAsFixed(2)),
          idDeudaPadre: ""));

      double patata = 0;
      patata = patata +
          deudasPequenas
              .where((deuda) => deuda.acreedor.correo == socketService.correo)
              .toList()
              .fold(
                  0,
                  (previousValue, element) =>
                      previousValue + element.cantidadPP) -
          deudasPequenas
              .where((deuda) => deuda.deudor.correo == socketService.correo)
              .toList()
              .fold(
                  0,
                  (previousValue, element) =>
                      previousValue + element.cantidadPP);
//truncar a dos decimales
      //truncar double a dos decimales
      // el codigo seria
      balance = double.parse(patata.toStringAsFixed(2));

      creditors[creditorIndex] =
          MapEntry(creditor.key, creditor.value - transactionAmount);
      debtors[debtorIndex] =
          MapEntry(debtor.key, debtor.value + transactionAmount);

      if (creditors[creditorIndex].value == 0) creditorIndex++;
      if (debtors[debtorIndex].value == 0) debtorIndex++;
    }

    return simplifiedDebts;
  }

  @override
  void initState() {
    super.initState();
    balance = 0;
    final socketService = Provider.of<SocketService>(context, listen: false);
    Map<String, dynamic> payload = {
      'id': socketService.idComponente,
      'tipo': socketService.tipoComponente,
    };
    socketService.emit('peticion-this-componente', payload);

    socketService.socket.on(
        'envio-this-componente-deudas',
        (payload) => {
              print("patata"),
              if (mounted)
                {
                  setState(() {
                    componente = ComponenteDeudas.fromMap(payload);
                    deudas = componente.subcomponente;
                    deudasPequenas =
                        deudas.expand((deuda) => deuda.deudasPequenas).toList();
                    deudasSimplificadas = simplifyDebts(deudasPequenas);
                    deudasSimplificadas.forEach((deuda) {
                      print(
                          '${deuda.deudor} debe ${deuda.cantidadPP} a ${deuda.acreedor}');
                    });
                    //log(deudasPequenas.toString());
                    //log(deudasSimplificadas.toString());
                  })
                }
            });
  }

  void _showPayDebtDialog(DeudaPequena deuda) {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pagar deuda'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Cantidad: ${deuda.cantidadPP}€'),
                Text(
                    'Para: ${deuda.acreedor.nombre} ${deuda.acreedor.apellido_1} ${deuda.acreedor.apellido_2}'),
                const SizedBox(height: 20),
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
              child: const Text('Pagar'),
              onPressed: () {
                socketService.socket.emit('añadir-deuda-grande', {
                  'acreedor': socketService.correo,
                  'cantidad': deuda.cantidadPP,
                  'nombre': "Pago deuda",
                  'id_componente': socketService.idComponente,
                  'cantidadPorPersona': deuda.cantidadPP,
                  "viaje_id": socketService.viaje.id,
                  'deudores': [deuda.acreedor.correo]
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDebtInfoDialog(Deuda deuda) {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(deuda.nombre),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Cantidad: ${deuda.cantidad}€'),
                const SizedBox(height: 20),
                const Text('Deudores:'),
                const SizedBox(height: 10),
                Column(
                  children: deuda.deudasPequenas
                      .map((deudaPequena) => Row(
                            children: [
                              Text(
                                  '${deudaPequena.deudor.nombre} ${deudaPequena.deudor.apellido_1} ${deudaPequena.deudor.apellido_2}'),
                              const Spacer(),
                              Text('   ${deudaPequena.cantidadPP}€'),
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
                socketService.socket.emit('borrar-deuda', {
                  'viaje_id': socketService.viaje.id,
                  'id_deuda': deuda.id,
                  'id_componente': socketService.idComponente,
                });
                Navigator.of(context).pop();
                initState();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDebtTile(Deuda deuda) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return GestureDetector(
        onTap: () {
          _showDebtInfoDialog(deuda);
        },
        child: ListTile(
            leading: CircleAvatar(
              backgroundColor: deuda.acreedor.color,
              child: Text(
                '${deuda.acreedor.nombre.substring(0, 1)}${deuda.acreedor.apellido_1.substring(0, 1)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            title: Text("${deuda.nombre}  Total: ${deuda.cantidad}€"),
            subtitle: Wrap(
              spacing: 8.0,
              children: deuda.deudores
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
            trailing: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: deuda.acreedor.correo == socketService.correo &&
                      deuda.deudores.any(
                          (element) => element.correo == socketService.correo)
                  ? Column(children: [
                      const Text("Te deben:"),
                      Text(
                        "${((deuda.cantidad / deuda.deudores.length) * (deuda.deudores.length - 1)).toStringAsFixed(2)}€",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 20),
                      ),
                    ])
                  :
                  //usuario es deudor y no es acreedor
                  deuda.deudores.any((element) =>
                              element.correo == socketService.correo) &&
                          deuda.acreedor.correo != socketService.correo
                      ? Column(children: [
                          const Text("Debes:"),
                          Text(
                            "${(deuda.cantidad / deuda.deudores.length).toStringAsFixed(2)}€",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 20),
                          ),
                        ])
                      :
                      // usuario es acreedor y no es deudor
                      deuda.acreedor.correo == socketService.correo &&
                              !deuda.deudores.any((element) =>
                                  element.correo == socketService.correo)
                          ? Column(children: [
                              const Text("Te deben:"),
                              Text(
                                "${deuda.cantidad.toStringAsFixed(2)}€",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 20),
                              ),
                            ])
                          :
//usuario no es acreedor ni deudor
                          Column(children: const [Text("No participaste")]),
            )));
  }

  void _showAddPaymentDialog() {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String paymentName = '';
        double paymentAmount = 0.0;
        List<Usuario> selectedDebtors = [];
        Usuario payer = socketService.usuariosViaje
            .firstWhere((element) => element.correo == socketService.correo);
        List<Usuario> allUsers = socketService.usuariosViaje;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Nuevo pago'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextFormField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del pago',
                      ),
                      onChanged: (value) {
                        paymentName = value;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        paymentAmount = double.tryParse(value) ?? 0.0;
                      },
                    ),
                    DropdownButton<Usuario>(
                      value: payer,
                      onChanged: (Usuario? newValue) {
                        setState(() {
                          payer = newValue!;
                        });
                      },
                      items: allUsers.map<DropdownMenuItem<Usuario>>(
                        (Usuario user) {
                          return DropdownMenuItem<Usuario>(
                            value: user,
                            child: Text(user.nombre),
                          );
                        },
                      ).toList(),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: allUsers.map((Usuario user) {
                          return CheckboxListTile(
                            title: Text(user.nombre),
                            value: selectedDebtors.contains(user),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value!) {
                                  selectedDebtors.add(user);
                                } else {
                                  selectedDebtors.remove(user);
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
                    Navigator.of(context).pop();
                    socketService.socket.emit('añadir-deuda-grande', {
                      'acreedor': payer.correo,
                      'cantidad': paymentAmount,
                      'nombre': paymentName,
                      'viaje_id': socketService.viaje.id,
                      'id_componente': socketService.idComponente,
                      'cantidadPorPersona':
                          paymentAmount / selectedDebtors.length,
                      'deudores': selectedDebtors.map((e) => e.correo).toList(),
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

  @override
  Widget build(BuildContext context) {
    SocketService socketService =
        Provider.of<SocketService>(context, listen: false);
    deudasUsuario = deudasSimplificadas
        .where((deuda) => deuda.deudor.correo == socketService.correo)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(componente.nombre), //quiero un boton en la barra de arriba para borrar el componente
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
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      displayIndex = 0;
                    });
                  },
                  child: Container(
                    color: displayIndex == 0 ? Colors.orange : Colors.grey,
                    height: 40,
                    child: const Center(
                      child: Text('Gastos',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      displayIndex = 1;
                    });
                  },
                  child: Container(
                    color: displayIndex == 1 ? Colors.orange : Colors.grey,
                    height: 40,
                    child: const Center(
                      child: Text('Balance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: displayIndex == 0
                ? ListView.builder(
                    itemCount: deudas.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 8,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: _buildDebtTile(deudas[index]),
                      );
                    },
                  )
                : Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: balance >0
                        ? Column(children: [
                            const Text('Te deben:',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            Text('$balance €',
                                style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green))
                          ])
                        :  balance == 0
                          ? Column(children: [
                            const Text('Balance',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            const Text('0.00 €',
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black))
                          ])
                          :
                        Column(children: [
                            const Text('Debes:',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            Text('$balance €',
                                style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red))
                          ])),

// ahora un espacio
                const SizedBox(height: 20),

                const Text('Tus Deudas:',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
                deudasUsuario.isEmpty
                    ? Card (
                      elevation: 4,
                      child : Container(
                        height: 50,
                        width: double.infinity,
                      child: const Center( child: Text('No tienes deudas pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),),
                      ))
                    :       
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: deudasUsuario.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      elevation: 4,
                       child: ListTile(
                        title: Text(
                            ("${deudasUsuario[index].deudor.nombre} debe ${deudasUsuario[index].cantidadPP.toStringAsFixed(2)}€ a ${deudasUsuario[index].acreedor.nombre}"),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),

                        //el leading debe ser un boton que al pulsarlo abra un pop up con la informacion de la deuda y una accion para pagarla
                        trailing: IconButton(
                          iconSize: 40,
                          icon: const Icon(Icons.add_card_rounded),
                          onPressed: () {
                            _showPayDebtDialog(deudasUsuario[index]);
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text('Todas las Deudas:',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: deudasSimplificadas.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                        elevation: 4,
                        child: ListTile(
                      title: Text(
                        //como dejo un double con 2 decimales?
                        //deudasSimplificadas[index].cantidadPP.toStringAsFixed(2)

                        ("${deudasSimplificadas[index].deudor.nombre} debe ${deudasSimplificadas[index]
                                .cantidadPP
                                .toStringAsFixed(2)}€ a ${deudasSimplificadas[index].acreedor.nombre}"),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ));
                  },
                ),
              ],
            ), // el código para la segunda pantalla (displayIndex == 1) va aquí,
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


