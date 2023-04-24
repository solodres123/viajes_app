import 'package:flutter/material.dart';
import 'package:viajes_app/services/login_form_provider.dart';
import 'package:viajes_app/theme/app_theme.dart';
import 'package:viajes_app/ui/input_decorations.dart';
import 'package:viajes_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../services/socket_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AuthBackground(
            child: SingleChildScrollView(
      child: Column(children: [
        const SizedBox(height: 250),
        CardContainer(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Text('Login', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 30),
              ChangeNotifierProvider(
                  create: (_) => LoginFormProvider(), child: _LoginForm())
            ],
          ),
        ),
        const SizedBox(height: 50),
        const Text('Crear una nueva cuenta',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
      ]),
    )));
  }
}

class _LoginForm extends StatefulWidget {
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool _isButtonDisabled = true;
  bool _errorContrasena = false;

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
            
socketService.socket.on(
        'usuario-valido',
        (payload) => {
          print(payload.toString()),
              Navigator.pushReplacementNamed(context, 'home')
              
            });

    socketService.socket.on(
        'usuario-no-valido',
        (payload) => {
                setState(() {
                  _errorContrasena = true;
                })
            });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    final socketService = Provider.of<SocketService>(context);
    return Container(
      child: Form(
          key: loginForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'user@email.com',
                    labelText: 'correo electrónico',
                    prefixIcon: Icons.alternate_email_outlined),
                onChanged: (value) => loginForm.email = value,
                validator: (value) {
                  String pattern =
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                  RegExp regExp = new RegExp(pattern);

                  return regExp.hasMatch(value ?? '')
                      ? null
                      : 'El valor ingresado no parece un correo';
                },
              ),
              const SizedBox(height: 30),
              TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                obscureText: true,
                decoration: InputDecorations.authInputDecoration(
                    hintText: '*******',
                    labelText: 'contraseña',
                    prefixIcon: Icons.password),
                onChanged: (value) => loginForm.password = value,
                validator: (value) {
                  if (value != null && value.length >= 6) return null;
                  return 'la constraseña debe de ser de 6 caracteres';
                },
              ),
              const SizedBox(height: 30),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                disabledColor: Colors.grey,
                elevation: 0,
                color: AppTheme.primary,
                onPressed:  !(socketService.serverStatus == ServerStatus.Online)
                    ? null
                    : () {
                        
                          socketService.socket.emit('comprobar-usuario',
                              {'email': loginForm.email, 'password': loginForm.password});
                        
                      }, 

                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  child: Text(loginForm.isLoading ? 'espere' : 'Ingresar',
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
              if (_errorContrasena == true)
                Text(
                  'El usuario o la contraseña son incorrectos',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          )),
    );
  }
}
