import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  /* Counter app using state nofifier */

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
      home: const Example2(),
    );
  }
}

extension OptionalInfixAddition<T extends num> on T? {
  T? operator +(T? other) {
    final shadow = this;
    if (shadow != null) {
      return shadow + (other ?? 0) as T;
    }
    return null;
  }

  T? operator -(T? other) {
    final shadow = this;
    if (shadow != null) {
      return shadow - (other ?? 0) as T;
    }
    return null;
  }
}

class Counter extends StateNotifier<int?> {
  Counter() : super(null);
  void incremenet() => state = state == null ? 1 : state + 1;
  int? get value => state;
  void decrement() => state = state! < 1 ? 0 : state - 1;
}

final counterProvider =
    StateNotifierProvider<Counter, int?>((ref) => Counter());

class Example2 extends ConsumerWidget {
  const Example2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Counter with state notifier'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 16,
            ),
            Consumer(
              builder: (context, ref, child) {
                final count = ref.watch(counterProvider);
                return Center(
                    child: Text(
                  count == null ? "Press the button" : count.toString(),
                  style: Theme.of(context).textTheme.titleLarge,
                ));
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: ref.read(counterProvider.notifier).incremenet,
                child: const Text('Increment')),
            const SizedBox(
              height: 10,
            ),
            TextButton(
                onPressed: ref.read(counterProvider.notifier).decrement,
                child: const Text('Decrement')),
          ],
        ));
  }
}
