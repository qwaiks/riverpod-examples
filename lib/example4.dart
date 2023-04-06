import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const Example4(),
    );
  }
}

const names = [
  'Jasmine Hines',
  'Sienna Walter',
  'Candice Everett',
  'Homer Christian',
  'Cade Rosario',
  'Faizan Berger',
  'Lee Mccoy',
  'Addie Hart',
  'Mahir Grimes',
  'Yaseen Brooks'
];

final tikcerProvider = StreamProvider((ref) {
  return Stream.periodic(
      const Duration(
        seconds: 1,
      ),
      (x) => x + 1);
});

final namesProvider = StreamProvider(
  (ref) => ref.watch(tikcerProvider.stream).map(
        (index) => names.getRange(0, index),
      ),
);

// Stream proivder using a timer using ticker
class Example4 extends ConsumerWidget {
  const Example4({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(namesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Retrieve With Stream builder'),
      ),
      body: names.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (_, index) => ListTile(
            title: Text(data.elementAt(index)),
          ),
        ),
        error: (_, __) => const Text('Error occured'),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
