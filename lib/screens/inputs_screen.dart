import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/socket_service.dart';

class InputsScreen extends StatefulWidget {
  const InputsScreen({Key? key}) : super(key: key);

  @override
  State<InputsScreen> createState() => _InputsScreenState();
}

class _InputsScreenState extends State<InputsScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController primerApellidoController = TextEditingController();
  final TextEditingController segundoApellidoController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmarContrasenaController = TextEditingController();

  int? selectedColorIndex;

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket
        .on('solicitud-nuevo-usuario', (payload) => {setState(() {})});
    super.initState();
  }

  @override
  void dispose() {
    nombreController.dispose();
    primerApellidoController.dispose();
    segundoApellidoController.dispose();
    correoController.dispose();
    contrasenaController.dispose();
    confirmarContrasenaController.dispose();
    super.dispose();
  }

  final List<Color> colorList = [
  Color(0xFFF4A460), // Brown
  Color(0xFF00CED1), // Turquoise
  Color(0xFFA52A2A), // Brown (dark)
  Color(0xFFDA70D6), // Orchid
  Color(0xFF00FA9A), // Medium Spring Green
  Color(0xFF7B68EE), // Medium Slate Blue
  Color(0xFF87CEEB), // Sky Blue
  Color(0xFFB22222), // Firebrick
  Color(0xFF20B2AA), // Light Sea Green
  Color(0xFF1E90FF), // Dodger Blue
];

  Widget buildColorCircles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List<Widget>.generate(colorList.length, (int index) {
        return InkWell(
          onTap: () {
            setState(() {
              selectedColorIndex = index;
            });
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorList[index],
              shape: BoxShape.circle,
              border: Border.all(
                color: selectedColorIndex == index
                    ? Colors.black
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    final myFormKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inputs y forms'),
      ),
      body: Form(
        key: myFormKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                TextFormField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Nombre',
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: primerApellidoController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Primer apellido',
                    hintText: 'Primer apellido',
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: segundoApellidoController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Segundo apellido',
                    hintText: 'Segundo apellido',
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Correo del usuario',
                  ),
                  validator: (String? value) {
                    final pattern =r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[\w-]{2,4}$';
                final regex = RegExp(pattern);
                if (!regex.hasMatch(value!)) {
                  return 'Por favor, introduce un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: contrasenaController,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                hintText: 'Introduzca su contraseña',
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: confirmarContrasenaController,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                hintText: 'Confirme su contraseña',
              ),
              validator: (String? value) {
                if (value != contrasenaController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            buildColorCircles(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (myFormKey.currentState!.validate()) {
                  // Procesar la información

                  socketService.emit('crear-usuario', {
                    'nombre': nombreController.text,
                    'primerApellido': primerApellidoController.text,
                    'segundoApellido': segundoApellidoController.text,
                    'correo': correoController.text,
                    'contrasena': contrasenaController.text,
                    'color': selectedColorIndex,
                  });
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    ),
  ),
);
}
}