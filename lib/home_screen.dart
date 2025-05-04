import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _city = 'New York';
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;

  final TextEditingController _controller = TextEditingController();
  final String _apiKey = '4f37f28ac10045668b6c8a5e6d90db2f'; 

  @override
  void initState() {
    super.initState();
    _fetchWeather(_city);
  }

  Future<void> _fetchWeather(String city) async {
    setState(() => _isLoading = true);
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weatherData = data;
          _city = city;
        });
      } else {
        throw Exception('City not found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildWeatherInfo() {
    if (_weatherData == null) return Text('No data');

    final temp = _weatherData!['main']['temp'];
    final desc = _weatherData!['weather'][0]['description'];
    final icon = _weatherData!['weather'][0]['icon'];

    return Column(
      children: [
        Image.network('http://openweathermap.org/img/wn/$icon@2x.png'),
        Text(
          '${temp.toString()} °C',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          desc.toString().toUpperCase(),
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weatherly')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter city name',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _fetchWeather(_controller.text.trim()),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : _buildWeatherInfo(),
          ],
        ),
      ),
    );
  }
}
