import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertsScreen extends StatefulWidget {
  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  double _tempThreshold = 35;
  bool _rainAlert = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tempThreshold = prefs.getDouble('temp_alert') ?? 35;
      _rainAlert = prefs.getBool('rain_alert') ?? false;
    });
  }

  Future<void> _savePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('temp_alert', _tempThreshold);
    await prefs.setBool('rain_alert', _rainAlert);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather Alerts')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Temperature Alert Threshold (°C)',
                style: TextStyle(fontSize: 18)),
            Slider(
              value: _tempThreshold,
              min: -10,
              max: 50,
              divisions: 60,
              label: '${_tempThreshold.round()} °C',
              onChanged: (val) {
                setState(() => _tempThreshold = val);
              },
              onChangeEnd: (_) => _savePrefs(),
            ),
            SwitchListTile(
              title: Text('Notify when rain is expected'),
              value: _rainAlert,
              onChanged: (val) {
                setState(() => _rainAlert = val);
                _savePrefs();
              },
            ),
            SizedBox(height: 20),
            Text('Alerts will be triggered locally.\n(FCM can be added)',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
