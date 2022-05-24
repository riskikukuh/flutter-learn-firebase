import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

final db = FirebaseFirestore.instance;
String? value;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Ngab',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  showBottomSheet(
      BuildContext context, bool isUpdate, DocumentSnapshot? documentSnapshot) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  label: Text(isUpdate ? "Update Todo" : "Add Todo"),
                  hintText: 'Enter An Item'),
              onChanged: (String _val) {
                value = _val;
              },
            ),
          ),
          TextButton(
            onPressed: () {
              if (isUpdate) {
                db
                    .collection('todos')
                    .doc(documentSnapshot?.id)
                    .update({'todo': value});
              } else {
                db.collection('todos').add({'todo': value});
              }
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.lightBlueAccent)),
            child: isUpdate
                ? const Text(
                    'UPDATE',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'ADD',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Ngab'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: db.collection("todos").snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, int i) {
              DocumentSnapshot documentSnapshot = snapshot.data.docs[i];
              return ListTile(
                title: Text(
                  documentSnapshot['todo'],
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return showBottomSheet(context, true, documentSnapshot);
                    },
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    db.collection("todos").doc(documentSnapshot.id).delete();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return showBottomSheet(context, false, null);
            },
          );
        },
        tooltip: 'Add Todos',
        child: const Icon(Icons.add),
      ),
    );
  }
}
