import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viajes_app/widgets/widgets.dart';

import '../services/socket_service.dart';
import '../widgets/custom_input_field.dart';

class InputsScreen extends StatefulWidget {
  const InputsScreen({Key? key}) : super(key: key);

  @override
  State<InputsScreen> createState() => _InputsScreenState();
}

class _InputsScreenState extends State<InputsScreen> {
  @override
  
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on(
        'solicitud-nuevo-usuario',
        (payload) => {
              setState(() {
              })
            });
             super.initState();
  }

    @override
    Widget build(BuildContext context) {
       final socketService = Provider.of<SocketService>(context, listen: false);
      final myFormKey = GlobalKey<FormState>();
      final Map<String, String> formValues = {
        'nombre': '',
        'primer apellido': '',
        'segundo apellido': '',
        'correo': '',
        'contraseña': '',
      };
      return Scaffold(
          appBar: AppBar(
            title: const Text('inputs y forms'),
          ),
          body: Form(
            key: myFormKey,
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  CustomInputField(
                      labelText: 'nombre',
                      hintText: 'nombre',
                      formProperty: 'nombre',
                      formValues: formValues),
                  const SizedBox(height: 30),
                  CustomInputField(
                      labelText: 'primer apellido',
                      hintText: 'primer apellido',
                      formProperty: 'primer_apellido',
                      formValues: formValues),
                  const SizedBox(height: 30),
                  CustomInputField(
                      labelText: 'segundo apellido',
                      hintText: 'segundo apellido',
                      formProperty: 'segundo_apellido',
                      formValues: formValues),
                  const SizedBox(height: 30),
                  CustomInputField(
                      labelText: 'email',
                      hintText: 'correo del usuario',
                      keyboard: TextInputType.emailAddress,
                      formProperty: 'correo',
                      formValues: formValues),
                  const SizedBox(height: 30),
                  CustomInputField(
                      labelText: 'contraseña',
                      hintText: 'introduzca su contraseña',
                      censured: true,
                      keyboard: TextInputType.visiblePassword,
                      formProperty: 'contraseña',
                      formValues: formValues),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed:  
                       !(socketService.serverStatus == ServerStatus.Online)
                    ? null
                    : () {
                      socketService.socket.emit('form_submit', formValues);
                      //quita el teclado
                      FocusScope.of(context).requestFocus(FocusNode());
                      if (!myFormKey.currentState!.validate()) {}
                      // ignore: avoid_print
                      print(formValues);
                    },
                    child: const SizedBox(
                        width: double.infinity,
                        child: Center(child: Text('Guardar'))),
                  )
                ],
              ),
            )),
          ));
    }
  }

