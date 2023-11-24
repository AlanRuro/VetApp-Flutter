import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsPage extends StatefulWidget {
  final Type? previousWidget;
  final String? docId;

  const DetailsPage({super.key, this.previousWidget, this.docId});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    Widget form;
    switch (widget.previousWidget) {
      case IconButton:
        form = const NewPuppyForm();
        break;
      case ListTile:
        form = PuppyDetailsForm(puppyId: widget.docId);
        break;
      default:
        throw UnimplementedError('no widget for ${widget.previousWidget}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
      ),
      body: form,
    );
  }
}

class NewPuppyForm extends StatefulWidget {
  const NewPuppyForm({super.key});

  static void saveDocument({
    required GlobalKey<FormState> formKey,
    required Map<String, dynamic> doc,
    required BuildContext context,
  }) {
    if (formKey.currentState!.validate()) {
      FirebaseFirestore.instance
          .collection("puppies")
          .add(doc)
          .then((DocumentReference documento) =>
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Puppy added successfully'),
                    backgroundColor: Colors.green),
              ))
          .then((value) => {Navigator.of(context).pop()});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to add the puppy'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  State<NewPuppyForm> createState() => _NewPuppyFormState();
}

class _NewPuppyFormState extends State<NewPuppyForm> {
  final _formKey = GlobalKey<FormState>();

  RegExp get _numbers => RegExp(r'[1-9]+');

  RegExp get _letters => RegExp(r'[a-zA-Z]+');

  @override
  Widget build(BuildContext context) {
    TextEditingController _breed = TextEditingController();
    TextEditingController _age = TextEditingController();
    TextEditingController _name = TextEditingController();

    setState(() {
      _name.text = "";
      _breed.text = "";
      _age.text = "";
    });

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Wrap(
        children: [
          TextFormField(
            controller: _name,
            autovalidateMode: AutovalidateMode.always,
            decoration: const InputDecoration(
              icon: Icon(Icons.text_fields),
              labelText: 'Name',
            ),
            validator: (String? value) {
              return (value != null && _numbers.hasMatch(value))
                  ? 'Do not use numbers.'
                  : null;
            },
          ),
          TextFormField(
            controller: _breed,
            decoration: const InputDecoration(
              icon: Icon(Icons.pets),
              labelText: 'Breed',
            ),
            validator: (String? value) {
              return (value != null && _numbers.hasMatch(value))
                  ? 'Do not use numbers.'
                  : null;
            },
          ),
          TextFormField(
            controller: _age,
            decoration: const InputDecoration(
              icon: Icon(Icons.numbers),
              labelText: 'Age',
            ),
            validator: (String? value) {
              return (value != null && _letters.hasMatch(value))
                  ? 'Do not use letters.'
                  : null;
            },
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final puppy = <String, dynamic>{
                        "name": _name.text,
                        "breed": _breed.text,
                        "age": _age.text
                      };

                      NewPuppyForm.saveDocument(
                          formKey: _formKey, doc: puppy, context: context);
                    } on FirebaseException catch (e) {
                      print(e.code);
                    }
                  },
                  child: const Text("Register")),
            ),
          ),
        ],
      ),
    );
  }
}

class PuppyDetailsForm extends StatefulWidget {
  final String? puppyId;

  const PuppyDetailsForm({super.key, this.puppyId});

  @override
  State<PuppyDetailsForm> createState() => _PuppyDetailsFormState();
}

class _PuppyDetailsFormState extends State<PuppyDetailsForm> {
  late Stream<DocumentSnapshot> _puppyStream;

  @override
  void initState() {
    super.initState();
    _puppyStream = FirebaseFirestore.instance
        .collection("puppies")
        .doc(widget.puppyId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _puppyStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("ERROR AL HACER QUERY, FAVOR DE VERIFICAR");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          Map<String, dynamic> puppy =
              snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: Text('${puppy['name']}'),
                  subtitle: const Text('Name'),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.pets),
                  title: Text('${puppy['breed']}'),
                  subtitle: const Text('Breed'),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.numbers),
                  title: Text('${puppy['age']}'),
                  subtitle: const Text('Age'),
                ),
              ),
            ],
          );
        });
  }
}
