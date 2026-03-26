import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  runApp(MyApp());
  tz.initializeTimeZones();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TrackerPage(),
    );
  }
}

DateTime scheduleTime = DateTime.now();

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final _medicationTimeController = TextEditingController();
  final _sleepTimeController = TextEditingController();
  final _wakeUpTimeController = TextEditingController();
  bool _isMedicationTaken = false;
  bool _isSlept = false;
  var medicationDateTime = DateTime.now();
  var sleepTime = DateTime.now();
  var wakeUpTime = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Monitor'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: _medicationTimeController,
                decoration: const InputDecoration(
                  labelText: 'Medication 1 Time',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (timeOfDay != null) {
                    setState(() {
                      _medicationTimeController.text =
                          '${timeOfDay.hour}:${timeOfDay.minute}';
                    });
                    medicationDateTime = DateTime.now().copyWith(
                      hour: timeOfDay.hour,
                      minute: timeOfDay.minute,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _sleepTimeController,
                decoration: const InputDecoration(
                  labelText: 'Sleep Time',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (timeOfDay != null) {
                    setState(() {
                      _sleepTimeController.text =
                          '${timeOfDay.hour}:${timeOfDay.minute}';
                    });
                    sleepTime = DateTime.now().copyWith(
                      hour: timeOfDay.hour,
                      minute: timeOfDay.minute,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _wakeUpTimeController,
                decoration: const InputDecoration(
                  labelText: 'Wake Up Time',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (timeOfDay != null) {
                    setState(() {
                      _wakeUpTimeController.text =
                          '${timeOfDay.hour}:${timeOfDay.minute}';
                    });
                    wakeUpTime = DateTime.now().copyWith(
                      hour: timeOfDay.hour,
                      minute: timeOfDay.minute,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  debugPrint(_medicationTimeController.text);

                  print(medicationDateTime);
                  NotificationService().scheduleNotification(
                      id: 0,
                      title: 'Medication Reminder',
                      body: 'Time to take the meds!',
                      channel_id: 'medication_channel',
                      channel_name: 'Medication Channel',
                      scheduledNotificationDateTime: medicationDateTime);
                  print(sleepTime);
                  debugPrint(_sleepTimeController.text);
                  NotificationService().scheduleNotification(
                      id: 1,
                      title: 'Sleep Reminder',
                      body: 'Time to sleep!',
                      channel_id: "bedtime_channel",
                      channel_name: "Bed Time Channel",
                      scheduledNotificationDateTime: sleepTime);
                  print(wakeUpTime);
                  debugPrint(_wakeUpTimeController.text);
                  NotificationService().scheduleNotification(
                      id: 2,
                      title: 'Wakeup Reminder',
                      body: 'Time to wake up!',
                      channel_id: "wakeup_channel",
                      channel_name: "Wake Up Channel",
                      scheduledNotificationDateTime: wakeUpTime);
                },
                child: const Text('Set Reminders'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isMedicationTaken = true;
                  });
                },
                child: const Text('Medication Taken'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isSlept = true;
                  });
                },
                child: const Text('Slept'),
              ),
              const SizedBox(height: 20),
              Text(
                _isMedicationTaken
                    ? 'Medication taken'
                    : 'Medication not taken',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                _isSlept ? 'Slept' : 'Not slept',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduleBtn extends StatelessWidget {
  const ScheduleBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Schedule notifications'),
      onPressed: () {
        debugPrint('Notification Scheduled for $scheduleTime');
        NotificationService().scheduleNotification(
            id: 0,
            title: 'Scheduled Notification',
            body: '$scheduleTime',
            channel_id: "",
            channel_name: "",
            scheduledNotificationDateTime: scheduleTime);
      },
    );
  }
}
