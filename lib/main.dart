import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ToDoList(),
    BackgroundChanger(),
    AudioPlayerWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Upchuck"),
          actions: [
           
          ],
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.checklist_rounded), label: 'To-Do'),
            BottomNavigationBarItem(icon: Icon(Icons.gradient), label: 'Theme'),
            BottomNavigationBarItem(icon: Icon(Icons.music_note_rounded), label: 'Music'),
          ],
        ),
      ),
    );
  }
}

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<Map<String, dynamic>> tasks = [];
  TextEditingController taskController = TextEditingController();
  DateTime? selectedDueDate;

  void _pickDueDate(BuildContext context, Function(DateTime) onDateSelected) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  void _addTask() {
    if (taskController.text.isNotEmpty && selectedDueDate != null) {
      setState(() {
        tasks.add({
          "task": taskController.text,
          "completed": false,
          "dueDate": DateFormat.yMMMd().format(selectedDueDate!),
        });
        taskController.clear();
        selectedDueDate = null;
      });
    }
  }

  void _editTask(int index) {
    TextEditingController editController = TextEditingController(text: tasks[index]["task"]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Task"),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(labelText: "Task"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tasks[index]["task"] = editController.text;
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _editDueDate(int index) {
    _pickDueDate(context, (pickedDate) {
      setState(() {
        tasks[index]["dueDate"] = DateFormat.yMMMd().format(pickedDate);
      });
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: "Enter task",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _pickDueDate(context, (date) {
                      setState(() {
                        selectedDueDate = date;
                      });
                    }),
                    child: Text(selectedDueDate == null ? "Pick Due Date" : DateFormat.yMMMd().format(selectedDueDate!)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addTask,
                    child: Text("Add Task"),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? Center(child: Text("No tasks available. Add one!"))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(tasks[index]["task"],
                            style: TextStyle(
                                decoration: tasks[index]["completed"]
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none)),
                        subtitle: Text("Due: ${tasks[index]["dueDate"]}"),
                        leading: Checkbox(
                          value: tasks[index]["completed"],
                          onChanged: (bool? value) {
                            setState(() {
                              tasks[index]["completed"] = value ?? false;
                            });
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.date_range, color: Colors.blue),
                              onPressed: () => _editDueDate(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editTask(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}


class BackgroundChanger extends StatefulWidget {
  @override
  _BackgroundChangerState createState() => _BackgroundChangerState();
}

class _BackgroundChangerState extends State<BackgroundChanger> {
  Color _backgroundColor = Colors.white;
  double _startX = 0;

  void _changeBackground(bool isSwipeLeft) {
    setState(() {
      _backgroundColor = isSwipeLeft ? Colors.blue : const Color.fromARGB(255, 255, 0, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _startX = details.globalPosition.dx;
      },
      onHorizontalDragUpdate: (details) {
        double delta = details.globalPosition.dx - _startX;
        if (delta < -50) {
          _changeBackground(true);
        } else if (delta > 50) {
          _changeBackground(false);
        }
      },
     child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        color: _backgroundColor,
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swipe, size: 50, color: Colors.white70),
            SizedBox(height: 10),
            Text(
              "Swipe left or right to change background",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class AudioPlayerWidget extends StatefulWidget {
  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentSongIndex = 0;

  final List<String> _songs = [
    'audio/dark.mp3',
    'audio/AboutYou.mp3',
    'audio/WalangPasok.mp3'
  ];

  final List<String> _songTitles = [
    "Random Music",
    "About You - 1975",
    "Meme"
  ];

  final List<String> _songImages = [
    'assets/audio/image/ship.jpg',
    'assets/audio/image/about.jpg',
    'assets/audio/image/shrek.jpg'
  ];

  @override
  void initState() {
    super.initState();

    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _nextSong();
    });
  }

  void _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(AssetSource(_songs[_currentSongIndex]));
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      print("Audio error: $e");
    }
  }

  void _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });
  }

  void _nextSong() async {
    setState(() {
      _currentSongIndex = (_currentSongIndex + 1) % _songs.length;
      _isPlaying = false;
      _position = Duration.zero;
    });
    await _audioPlayer.stop();
    _playPause();
  }

  void _prevSong() async {
    setState(() {
      _currentSongIndex =
          (_currentSongIndex - 1 + _songs.length) % _songs.length;
      _isPlaying = false;
      _position = Duration.zero;
    });
    await _audioPlayer.stop();
    _playPause();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  _songImages[_currentSongIndex],
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Now Playing: ${_songTitles[_currentSongIndex]}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(_formatDuration(_duration),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                min: 0,
                max: _duration.inSeconds.toDouble(),
                value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                onChanged: (value) async {
                  await _audioPlayer.seek(Duration(seconds: value.toInt()));
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   IconButton(
                    icon: Icon(Icons.stop, size: 40, color: Colors.red),
                    onPressed: _stop,
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_previous, size: 40, color: Colors.blue),
                    onPressed: _prevSong,
                  ),
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      size: 60,
                      color: Colors.blue,
                    ),
                    onPressed: _playPause,
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next, size: 40, color: Colors.blue),
                    onPressed: _nextSong,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}