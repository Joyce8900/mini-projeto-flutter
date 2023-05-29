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
  List<dynamic> capitals = [];

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    try {
      final response =
          await http.get(Uri.parse('https://restcountries.com/v3.1/all'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          countries = data;
          currencies = data.map((country) => country['currencies']).toList();
          capitals = data.map((country) => country['capital']).toList();
        });
      }
    } catch (e) {
      print('Error loading countries: $e');
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
          return ListTile(
            leading: Image.network(flagUrl, width: 32, height: 32),
            title: Text(country['name']['official']),
            subtitle: Text(country['name']['common']),
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
            title: Text(currency.toString()),
          );
        },
      );
    }
  }

  Widget buildCapitalsPage() {
    if (capitals.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        itemCount: capitals.length,
        itemBuilder: (context, index) {
          final capital = capitals[index];
          final country = countries[index];
          final flagUrl = country['flags']['png'];
          return ListTile(
            leading: Image.network(flagUrl, width: 32, height: 32),
            title: Text(capital.toString()),
          );
        },
      );
    }
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
          title: Text('Countries App'),
        ),
        body: IndexedStack(
          index: currentIndex,
          children: [
            buildNationsPage(),
            buildCurrenciesPage(),
            buildCapitalsPage(),
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
              label: 'Nations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.money),
              label: 'Currencies',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_city),
              label: 'Capitals',
            ),
          ],
        ),
      ),
    );
  }
}
