import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForecastScreen extends StatefulWidget {
  final String city;

  ForecastScreen({required this.city});

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final String _apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  Map<String, dynamic>? _forecastData;

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    final coordUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=${widget.city}&appid=$_apiKey';
    final coordRes = await http.get(Uri.parse(coordUrl));
    if (coordRes.statusCode != 200) return;

    final coordJson = json.decode(coordRes.body);
    final lat = coordJson['coord']['lat'];
    final lon = coordJson['coord']['lon'];

    final forecastUrl =
        'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,alerts&appid=$_apiKey&units=metric';
    final res = await http.get(Uri.parse(forecastUrl));
    if (res.statusCode == 200) {
      setState(() => _forecastData = json.decode(res.body));
    }
  }

  Widget _buildHourly() {
    final hourly = _forecastData!['hourly'].take(6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hourly Forecast', style: TextStyle(fontSize: 18)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: hourly
              .map<Widget>((h) => Column(
                    children: [
                      Text('${DateTime.fromMillisecondsSinceEpoch(h['dt'] * 1000).hour}h'),
                      Text('${h['temp'].toString()}°C'),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDaily() {
    final daily = _forecastData!['daily'].take(5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('5-Day Forecast', style: TextStyle(fontSize: 18)),
        ...daily.map((d) => ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text(
                  '${DateTime.fromMillisecondsSinceEpoch(d['dt'] * 1000).toLocal()}'),
              subtitle: Text(
                  'Min: ${d['temp']['min']}°C  Max: ${d['temp']['max']}°C'),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.city} Forecast')),
      body: _forecastData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildHourly(),
                  SizedBox(height: 20),
                  _buildDaily(),
                ],
              ),
            ),
    );
  }
}
