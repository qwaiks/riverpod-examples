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
      home: const Example3(),
    );
  }
}

enum City { stockholm, paris, tokyo, accra, newyork }

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City? city) {
  return Future.delayed(
    const Duration(seconds: 1),
    () =>
        {
          City.stockholm: "🌧️",
          City.paris: "❄️",
          City.tokyo: "🌤️",
          City.accra: "☀️",
        }[city] ??
        '⁉️',
  );
}

// this provider will be changeed by the UI
final currentCityProvider = StateProvider<City?>((ref) {
  return null;
});
// UI reads this
final weatherProvider = FutureProvider<WeatherEmoji>(
  (ref) async {
    final city = ref.watch(currentCityProvider);
    return getWeather(city);
  },
);

class Example3 extends ConsumerWidget {
  const Example3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Weather with Future builder '),
        ),
        body: Column(
          children: [
            currentWeather.when(
                data: (data) => Text(
                      data,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                error: (_, __) => const Text('Error loading file'),
                loading: () => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator.adaptive(),
                    )),
            Expanded(
              child: ListView.builder(
                itemCount: City.values.length,
                itemBuilder: (_, index) {
                  final city = City.values[index];
                  final isSelected = city == ref.read(currentCityProvider);
                  return ListTile(
                    title: Text(city.toString()),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () =>
                        ref.read(currentCityProvider.notifier).state = city,
                  );
                },
              ),
            )
          ],
        ));
  }
}
