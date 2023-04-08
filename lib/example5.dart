import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

@immutable
class Person {
  final String? name;
  final int? age;
  final String? uuid;

  //Creating a constructor to initialize props
  Person({
    required this.name,
    required this.age,
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v4();

  //Immutable classes should always return a new instance of the class
  // when props are updated
  Person updated([String? name, int? age]) => Person(
        name: name ?? this.name,
        age: age ?? this.age,
        uuid: uuid,
      );
  String get displayName => '$name ($age years old)';

  //override equality operator to check quality based of prop uuid
  @override
  bool operator ==(covariant Person other) => uuid == other.uuid;

  // once you override equality you need to override hashcode in order to
  // hash the fields that you use to check quality
  // if you are using all/ multiple field you should use the
  // Object.hash(prop1,prop2) or Object.hashAll([prop1, prop2])
  @override
  int get hashCode => uuid.hashCode;

  //override toString  to return props of class instead of class instance
  @override
  String toString() => 'Persons(name: $name, age: $age, uuid: $uuid)';
}

class DataModel extends ChangeNotifier {
  final List<Person> _people = [];

  int get count => people.length;

  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);

  void add(Person newPerson) {
    _people.add(newPerson);
    notifyListeners();
  }

  void update(Person existingPerson) {
    final index = _people.indexOf(existingPerson);
    if (index != -1) {
      final person = _people.elementAt(index);
      _people[index] = person.updated(existingPerson.name, existingPerson.age);
    }
    notifyListeners();
  }
}

final dataModelProvider = ChangeNotifierProvider<DataModel>((ref) {
  return DataModel();
});

class Example5 extends ConsumerWidget {
  const Example5({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Person manager With Change notifier'),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final person = await createOrAddPersonDialog(context);
            if (person != null) {
              final dataModel = ref.read(dataModelProvider);
              dataModel.add(person);
            }
          },
        ),
        body: Consumer(builder: (_, ref, __) {
          final dataModel = ref.watch(dataModelProvider);
          return ListView.builder(
              itemCount: dataModel.count,
              itemBuilder: (context, index) {
                final existingPerson = dataModel.people[index];
                return ListTile(
                  title: Text(existingPerson.displayName),
                  onTap: () async {
                    final updatedPerson =
                        await createOrAddPersonDialog(context, existingPerson);

                    if (updatedPerson != null &&
                        (updatedPerson.age != existingPerson.age ||
                            updatedPerson.name != existingPerson.name)) {
                      dataModel.update(updatedPerson);
                    }
                  },
                );
              });
        }));
  }
}

Future<Person?> createOrAddPersonDialog(BuildContext context,
    [Person? existingPerson]) {
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  String? name = existingPerson?.name;
  int? age = existingPerson?.age;

  nameController.text = name ?? '';
  ageController.text = age?.toString() ?? '';

  return showDialog<Person>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create or save person '),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Enter name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(hintText: 'Enter age'),
                onChanged: (value) => age = int.tryParse(value),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (existingPerson != null) {
                  final updatedPerson = existingPerson.updated(name, age);
                  Navigator.of(context).pop(updatedPerson);
                } else {
                  Navigator.pop(context, Person(name: name, age: age));
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      });
}
