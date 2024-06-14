import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(ExoticDiaryApp());
}

class ExoticDiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exotic Diary',
      theme: ThemeData(
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.yellow),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exotic Diary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.yellow,
              ),
              child: Text('개체 관리'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SpeciesScreen()),
                );
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.yellow,
              ),
              child: Text('알 관리'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EggScreen()),
                );
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.yellow,
              ),
              child: Text('할 일 관리'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ToDoScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SpeciesScreen extends StatefulWidget {
  @override
  _SpeciesScreenState createState() => _SpeciesScreenState();
}

class _SpeciesScreenState extends State<SpeciesScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController morphController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  List<Map<String, String>> speciesList = [];
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  _loadSpecies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? speciesData = prefs.getString('species');
    if (speciesData != null) {
      List<dynamic> speciesJson = jsonDecode(speciesData);
      setState(() {
        speciesList = speciesJson.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  _saveSpecies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String speciesData = jsonEncode(speciesList);
    prefs.setString('species', speciesData);
  }

  _addSpecies() {
    setState(() {
      speciesList.add({
        'name': nameController.text,
        'weight': weightController.text,
        'morph': morphController.text,
        'gender': genderController.text,
        'image': _image?.path ?? '',
      });
      _saveSpecies();
    });
    nameController.clear();
    weightController.clear();
    morphController.clear();
    genderController.clear();
    Navigator.pop(context);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      _image = pickedFile;
    });
  }

  _deleteSpecies(int index) {
    setState(() {
      speciesList.removeAt(index);
      _saveSpecies();
    });
  }

  _editSpecies(int index) {
    nameController.text = speciesList[index]['name']!;
    weightController.text = speciesList[index]['weight']!;
    morphController.text = speciesList[index]['morph']!;
    genderController.text = speciesList[index]['gender']!;
    _image = speciesList[index]['image']!.isNotEmpty ? XFile(speciesList[index]['image']!) : null;
    _addSpecies();
    _deleteSpecies(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('개체 관리'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: '무게'),
            ),
            TextField(
              controller: morphController,
              decoration: InputDecoration(labelText: 'Morph'),
            ),
            TextField(
              controller: genderController,
              decoration: InputDecoration(labelText: '성별'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.yellow),
                  child: Text('카메라'),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.yellow),
                  child: Text('갤러리'),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.yellow),
              child: Text('등록'),
              onPressed: _addSpecies,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: speciesList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: speciesList[index]['image']!.isNotEmpty
                        ? Image.file(File(speciesList[index]['image']!))
                        : null,
                    title: Text(speciesList[index]['name']!),
                    subtitle: Text(
                        '무게: ${speciesList[index]['weight']}, Morph: ${speciesList[index]['morph']}, 성별: ${speciesList[index]['gender']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editSpecies(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteSpecies(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EggScreen extends StatefulWidget {
  @override
  _EggScreenState createState() => _EggScreenState();
}

class _EggScreenState extends State<EggScreen> {
  final TextEditingController speciesController1 = TextEditingController();
  final TextEditingController morphController1 = TextEditingController();
  final TextEditingController genderController1 = TextEditingController();
  final TextEditingController speciesController2 = TextEditingController();
  final TextEditingController morphController2 = TextEditingController();
  final TextEditingController genderController2 = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  List<Map<String, String>> eggList = [];

  @override
  void initState() {
    super.initState();
    _loadEggs();
  }

  _loadEggs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? eggsData = prefs.getString('eggs');
    if (eggsData != null) {
      List<dynamic> eggsJson = jsonDecode(eggsData);
      setState(() {
        eggList = eggsJson.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  _saveEggs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String eggsData = jsonEncode(eggList);
    prefs.setString('eggs', eggsData);
  }

  _addEgg() {
    setState(() {
      eggList.add({
        'species1': speciesController1.text,
        'morph1': morphController1.text,
        'gender1': genderController1.text,
        'species2': speciesController2.text,
        'morph2': morphController2.text,
        'gender2': genderController2.text,
        'dateLaid': dateController.text,
      });
      _saveEggs();
    });
    speciesController1.clear();
    morphController1.clear();
    genderController1.clear();
    speciesController2.clear();
    morphController2.clear();
    genderController2.clear();
    dateController.clear();
    Navigator.pop(context);
  }

  _deleteEgg(int index) {
    setState(() {
      eggList.removeAt(index);
      _saveEggs();
    });
  }

  _editEgg(int index) {
    speciesController1.text = eggList[index]['species1']!;
    morphController1.text = eggList[index]['morph1']!;
    genderController1.text = eggList[index]['gender1']!;
    speciesController2.text = eggList[index]['species2']!;
    morphController2.text = eggList[index]['morph2']!;
    genderController2.text = eggList[index]['gender2']!;
    dateController.text = eggList[index]['dateLaid']!;
    _addEgg();
    _deleteEgg(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알 관리'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: speciesController1,
              decoration: InputDecoration(labelText: '부모1 종'),
            ),
            TextField(
              controller: morphController1,
              decoration: InputDecoration(labelText: '부모1 Morph'),
            ),
            TextField(
              controller: genderController1,
              decoration: InputDecoration(labelText: '부모1 성별'),
            ),
            TextField(
              controller: speciesController2,
              decoration: InputDecoration(labelText: '부모2 종'),
            ),
            TextField(
              controller: morphController2,
              decoration: InputDecoration(labelText: '부모2 Morph'),
            ),
            TextField(
              controller: genderController2,
              decoration: InputDecoration(labelText: '부모2 성별'),
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: '산란일 (YYYY-MM-DD)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.yellow),
              child: Text('등록'),
              onPressed: _addEgg,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: eggList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${eggList[index]['species1']} x ${eggList[index]['species2']}'),
                    subtitle: Text(
                        '부모1 Morph: ${eggList[index]['morph1']}, 성별: ${eggList[index]['gender1']}\n부모2 Morph: ${eggList[index]['morph2']}, 성별: ${eggList[index]['gender2']}\n산란일: ${eggList[index]['dateLaid']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editEgg(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteEgg(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  List<Map<String, dynamic>> toDoList = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool isNotificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadToDos();
  }

  _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  _loadToDos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? toDosData = prefs.getString('toDos');
    if (toDosData != null) {
      List<dynamic> toDosJson = jsonDecode(toDosData);
      setState(() {
        toDoList = toDosJson.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
  }

  _saveToDos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String toDosData = jsonEncode(toDoList);
    prefs.setString('toDos', toDosData);
  }

  _addToDo() {
    setState(() {
      toDoList.add({
        'title': titleController.text,
        'date': dateController.text,
        'time': timeController.text,
        'notification': isNotificationEnabled,
      });
      _saveToDos();
      if (isNotificationEnabled) {
        _scheduleNotification(titleController.text, dateController.text, timeController.text);
      }
    });
    titleController.clear();
    dateController.clear();
    timeController.clear();
    isNotificationEnabled = false;
    Navigator.pop(context);
  }

  _deleteToDo(int index) {
    setState(() {
      toDoList.removeAt(index);
      _saveToDos();
    });
  }

  _editToDo(int index) {
    titleController.text = toDoList[index]['title'];
    dateController.text = toDoList[index]['date'];
    timeController.text = toDoList[index]['time'];
    isNotificationEnabled = toDoList[index]['notification'];
    _addToDo();
    _deleteToDo(index);
  }

  Future<void> _scheduleNotification(String title, String date, String time) async {
    final scheduledDate = DateTime.parse('$date $time:00');
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        title,
        '할 일 알림',
        scheduledDate,
        platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('할 일 관리'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: '할 일'),
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: '날짜 (YYYY-MM-DD)'),
            ),
            TextField(
              controller: timeController,
              decoration: InputDecoration(labelText: '시간 (HH:MM)'),
            ),
            Row(
              children: [
                Checkbox(
                  value: isNotificationEnabled,
                  onChanged: (bool? value) {
                    setState(() {
                      isNotificationEnabled = value!;
                    });
                  },
                ),
                Text('알림 설정'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.yellow),
              child: Text('등록'),
              onPressed: _addToDo,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: toDoList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(toDoList[index]['title']),
                    subtitle: Text(
                        '날짜: ${toDoList[index]['date']}, 시간: ${toDoList[index]['time']}, 알림: ${toDoList[index]['notification'] ? '설정됨' : '설정 안됨'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editToDo(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteToDo(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
