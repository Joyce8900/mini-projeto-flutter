import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0;
  List<dynamic> countries = [];
  List<dynamic> currencies = [];
  List<dynamic> populations = [];

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    try {
      final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          countries = data;
          currencies = data.map((country) => country['currencies']).toList();
          populations = data.map((country) => country['population']).toList();
        });

        // Traduzindo os nomes dos países
        await translateCountryNames();
      }
    } catch (e) {
      print('Error loading countries: $e');
    }
  }

  Future<void> translateCountryNames() async {
    for (var i = 0; i < countries.length; i++) {
      final country = countries[i];
      final name = country['name']['official'];
      final translation = await _translateName(name);
      setState(() {
        countries[i]['name']['official'] = translation;
      });
    }
  }

  Future<String> _translateName(String name) async {
    final response = await http.get(
      Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=pt_BR&dt=t&q=${Uri.encodeQueryComponent(name)}',
      ),
    );

    if (response.statusCode == 200) {
      final translation = jsonDecode(response.body);
      return translation[0][0][0];
    } else {
      throw Exception('Failed to translate text.');
    }
  }

  String formatPopulation(int population) {
    if (population >= 1000000000) {
      final billionPopulation = (population / 1000000000).toStringAsFixed(1);
      return '$billionPopulation bilhões';
    } else if (population >= 1000000) {
      final millionPopulation = (population / 1000000).toStringAsFixed(1);
      return '$millionPopulation milhões';
    } else if (population >= 1000) {
      final thousandPopulation = (population / 1000).toStringAsFixed(1);
      return '$thousandPopulation mil';
    } else {
      return population.toString();
    }
  }

  Widget buildNationsPage() {
    if (countries.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        itemCount: countries.length,
        itemBuilder: (context, index) {
          final country = countries[index];
          final flagUrl = country['flags']['png'];
          final officialName = country['name']['official'];
          final commonName = country['name']['common'];
          final population = populations[index];
          final formattedPopulation = formatPopulation(population);
          return ListTile(
            leading: Image.network(flagUrl, width: 32, height: 32),
            title: FutureBuilder<String>(
              future: _translateName(officialName),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(snapshot.data!),
                      Text(
                        formattedPopulation,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Translation Error');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            subtitle: Text(commonName),
          );
        },
      );
    }
  }

  Widget buildCurrenciesPage() {
    if (currencies.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final currency = currencies[index];
          final country = countries[index];
          final flagUrl = country['flags']['png'];
          return ListTile(
            leading: Image.network(flagUrl, width: 32, height: 32),
            title: Text(
              currency != null && currency.isNotEmpty
                  ? currency.values
                      .map((c) => "Moeda: ${c["name"]}\nSímbolo: ${c["symbol"]} \n")
                      .join(" - ")
                  : "---",
            ),
          );
        },
      );
    }
  }

  
  void loadCountriesForContinent(String continent) async {
    String apiUrl;
    if (continent == 'Europa') {
      apiUrl = 'https://restcountries.com/v3.1/region/europe';
    } else if (continent == 'Ásia') {
      apiUrl = 'https://restcountries.com/v3.1/region/asia';
    } else if (continent == 'Oceania') {
      apiUrl = 'https://restcountries.com/v3.1/region/oceania';
    } else if (continent == 'África') {
      apiUrl = 'https://restcountries.com/v3.1/region/africa';
    } else if (continent == 'América') {
      apiUrl = 'https://restcountries.com/v3.1/region/america';
    } else {
      return;
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          countries = data;
          currencies = data.map((country) => country['currencies']).toList();
          populations = data.map((country) => country['population']).toList();
          currentIndex = 0; // Reset the current index to display the Nations page
        });

        // Traduzindo os nomes dos países
        await translateCountryNames();
      }
    } catch (e) {
      print('Error loading countries for continent $continent: $e');
    }
  }

  Widget buildDevelopersPage() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Desenvolvedores:',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 20),
        Text(
          'Gabriel José - gabriel.aquino.069@ufrn.edu.br',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 10),
        Text(
          'Joyce Santos - joyce.santos.709@ufrn.edu.br',
          style: TextStyle(fontSize: 16),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countries App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Exploração Geográfica'),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        body: IndexedStack(
          index: currentIndex,
          children: [
            buildNationsPage(),
            buildCurrenciesPage(),
            buildDevelopersPage(), // Página de Desenvolvedores adicionada
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.public),
              label: 'Países',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.money),
              label: 'Moeda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.developer_mode), // Ícone para a página de desenvolvedores
              label: 'Desenvolvedores', // Rótulo para a página de desenvolvedores
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Europa'),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  loadCountriesForContinent('Europa');
                },
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Ásia'),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  loadCountriesForContinent('Ásia');
                },
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Oceania'),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  loadCountriesForContinent('Oceania');
                },
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('África'),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  loadCountriesForContinent('África');
                },
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('América'),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  loadCountriesForContinent('América');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
