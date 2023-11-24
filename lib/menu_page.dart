import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetapp/details_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final Stream<QuerySnapshot> _puppiesStream =
      FirebaseFirestore.instance.collection("puppies").snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DetailsPage(
                        previousWidget: IconButton,
                      )));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _puppiesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("ERROR AL HACER QUERY, FAVOR DE VERIFICAR");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: snapshot.data!.docs
                      .map((DocumentSnapshot doc) {
                        Map<String, dynamic> docActual =
                            doc.data()! as Map<String, dynamic>;

                        return Card(
                          color: Colors.white70,
                          child: ListTile(
                            title: Text(docActual['name']),
                            subtitle: Text(docActual['breed']),
                            onTap: () => {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DetailsPage(
                                        previousWidget: ListTile,
                                        docId: doc.id,
                                      )))
                            },
                          ),
                        );
                      })
                      .toList()
                      .cast(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
