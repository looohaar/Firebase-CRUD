import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Text editing controllers
  final TextEditingController _continentController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();
  // the below code represents the collectioin which we had created in the firestore
  final CollectionReference _continentAndCountry =
      FirebaseFirestore.instance.collection('ContinentAndCounrty');

//  create method

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _continentController,
                  decoration: const InputDecoration(labelText: "Continent"),
                ),
                TextField(
                  controller: _rankController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  decoration: const InputDecoration(
                    labelText: "Rank",
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final String continent = _continentController.text;
                    final double? rank = double.tryParse(_rankController.text);

                    if (rank != null) {
                      await _continentAndCountry
                          .add({"Continent": continent, "Rank": rank});
                      _continentController.text = '';
                      _rankController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          );
        });
  }

  // update method
  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _continentController.text = documentSnapshot['Continent'];
      _rankController.text = documentSnapshot['Rank'].toString();
    }
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                controller: _continentController,
                decoration: const InputDecoration(labelText: "Continent"),
              ),
              TextField(
                controller: _rankController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(
                  labelText: "Rank",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final String continent = _continentController.text;
                  final double? rank = double.tryParse(_rankController.text);
                  if (rank != null) {
                    await _continentAndCountry
                        .doc(documentSnapshot!.id)
                        .update({"Continent": continent, "Rank": rank});
                    _continentController.text = '';
                    _rankController.text = '';
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  "Update",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Delete method
  Future<void> _delete(String coitinentId) async {
    await _continentAndCountry.doc(coitinentId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          'Item deleted',
          style: TextStyle(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Firestore CRUD',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // a streambuilder helps us to create a persistant connection with the firestore and app
      // we will get the updated data immedeatly using a streambuilder
      body: StreamBuilder(
        // the below snapshots are coming from continetandcountry table which we created in the firestore

        stream: _continentAndCountry.snapshots(),
        // streamsnapshot will have all the data available in the database

        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = streamSnapshot
                    .data!.docs[index]; // docs refers to the rows in that table
                return Card(
                  color: Colors.deepPurple,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      documentSnapshot['Continent'],
                      style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    subtitle: Text(
                      documentSnapshot['Rank'].toString(),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => _update(documentSnapshot),
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white70,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _delete(documentSnapshot.id),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            );
          }
        },
      ),
      // create a new item
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
