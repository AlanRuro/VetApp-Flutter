import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vetapp/menu_page.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static Future<User?> loginWithEmailPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found for that email')));
      }
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();

    setState(() {
      email.text = "";
      password.text = "";
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign In"),
      ),
      body: Column(
        children: [
          Credential(label: "Email", controller: email, obscure: false),
          Credential(label: "Password", controller: password, obscure: true),
          RichText(
              text: TextSpan(children: [
            const TextSpan(
              text: 'If you have not already, ',
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
                text: 'register now',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SignUpForm()));
                  })
          ])),
          ElevatedButton(
              onPressed: () async {
                User? user = await loginWithEmailPassword(
                    email: email.text,
                    password: password.text,
                    context: context);
                if (user != null) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MenuPage()));
                }
              },
              child: const Text("Log In")),
        ],
      ),
    );
  }
}

class Credential extends StatelessWidget {
  const Credential({
    super.key,
    this.label,
    required this.controller,
    required this.obscure,
  });

  final String? label;
  final TextEditingController controller;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: TextField(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: label,
          ),
          controller: controller,
          obscureText: obscure,
        ));
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  static void createUserWithEmailPassword(
      {required String email,
      required String password,
      required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      final UserCredential user = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // print("USUARIO CREADO: ${user.user?.uid}");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(const SnackBar(content: Text('PASSWORD NOT VALID')));
      } else if (e.code == 'email-already-in-use') {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('USUARIO YA REGISTRADO')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    TextEditingController confirmPassword = TextEditingController();

    setState(() {
      email.text = "";
      password.text = "";
      confirmPassword.text = "";
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Wrap(
          children: [
            TextFormField(
              controller: email,
              autovalidateMode: AutovalidateMode.always,
              decoration: const InputDecoration(
                icon: Icon(Icons.email),
                labelText: 'Email',
              ),
              validator: (String? value) {
                return (value != null && value.isEmpty) ? 'Required *.' : null;
              },
            ),
            TextFormField(
              controller: password,
              decoration: const InputDecoration(
                icon: Icon(Icons.password),
                labelText: 'Password',
              ),
              obscureText: true,
              autovalidateMode: AutovalidateMode.always,
              validator: (String? value) {
                return (value != null && value.isEmpty) ? 'Required *.' : null;
              },
            ),
            TextFormField(
              controller: confirmPassword,
              decoration: const InputDecoration(
                icon: Icon(Icons.password_rounded),
                labelText: 'Confirm password',
              ),
              obscureText: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String? value) {
                return (value != null && value != password.text)
                    ? 'The password you entered is different'
                    : null;
              },
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        createUserWithEmailPassword(
                            email: email.text,
                            password: password.text,
                            context: context);

                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Sign Up")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
