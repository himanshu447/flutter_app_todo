import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'package:flutter/foundation.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ths is metrilaApp Title',
      home: TodoAppState(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoAppState extends StatefulWidget {
  TodoList createState() => TodoList();
}

class TodoList extends State<TodoAppState> {

  final mainReference = Firestore.instance.collection('toDo');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('this is appBar Title'),
      ),
      body: entireList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _pushNewScreen,
        tooltip: 'add task',
        child: Icon(Icons.add),
      ),
      backgroundColor: Colors.red,
    );
  }

  void _pushNewScreen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("new screen title"),
        ),
        body: TextField(
          onSubmitted: (val) {
            _addItem(val);
            Navigator.pop(context);
          },
          decoration: InputDecoration(
              hintText: "enter your ToDo Item",
              contentPadding: EdgeInsets.all(16.0)),
          style: TextStyle(fontSize: 16.0, color: Colors.black),
          cursorColor: Colors.greenAccent,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textAlign: TextAlign.center,
        ),
      );
    }));
  }

  void _addItem(String text) {
    if (text.length > 0) {
      setState(() {
        Firestore.instance
            .collection('toDo')
            .document()
            .setData({'title': text, 'isCompleted': true});
      });
    }
  }

  Widget entireList() {
    return new StreamBuilder(
        stream: mainReference.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) return new Text('Loading...');
          return ListView(
            children: snap.data.documents.map((doc) {
              var id = doc.documentID.toString();
              debugPrint("id is ${id}");
              return new ListTile(
                title: Text(doc['title']),
                onTap: () => _pushUpdateScreen(id, doc['title']),
                onLongPress: () => _removeItem(id),
              );
            }).toList(),
          );
        });
  }

  void _removeItem(String id) {
    setState(() {
      mainReference.document(id).delete();
    });
  }

  void _updateItem(String text, String index) {
    setState(() {
      mainReference
          .document(index)
          .setData({'title': text, 'isCompleted': true});
    });
  }

  void _pushUpdateScreen(String id, String ttle) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("new screen title"),
        ),
        body: TextField(
          onSubmitted: (val) {
            _updateItem(val, id);
            Navigator.pop(context);
          },
          decoration: InputDecoration(
              // ignore: unnecessary_brace_in_string_interps
              hintText: "${ttle}",
              contentPadding: EdgeInsets.all(16.0)),
          style: TextStyle(fontSize: 16.0, color: Colors.black),
          cursorColor: Colors.greenAccent,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textAlign: TextAlign.center,
        ),
      );
    }));
  }
}

/**
 *
 * with dynamic string todo
 *
 */
/*void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ToDoList(),
    );
  }
}

class ToDoList extends StatefulWidget {
  ToDoListState createState() => ToDoListState();
}

class ToDoListState extends State<ToDoList> {
  List<String> _toDoItems = [];

  // Instead of autogenerating a todo item, _addTodoItem now accepts a string
  void _addTodoItem(String task) {
    // Only add the task if the user actually entered something
    if (task.length > 0) {
      setState(() => _toDoItems.add(task));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Todo List')),
      body: _buildTodoList(),
      floatingActionButton: new FloatingActionButton(
          onPressed: _pushAddTodoScreen,
          // pressing this button now opens the new screen
          tooltip: 'Add task',
          child: new Icon(Icons.add)),
    );
  }

  // Build the whole list of todo items
  Widget _buildTodoList() {
    return ListView.builder(itemBuilder: (context, index) {
      if (index < _toDoItems.length) {
        return _buildTodoItem(_toDoItems[index], index);
      }
    });
  }

  // Build a single todo item
  Widget _buildTodoItem(String text, int index) {
    return ListTile(
      title: Text(text),
      onTap: () => _promptRemoveTodoItem(index),
      onLongPress: () => _pushUpdateScreen(index),
    );
  }

  // Much like _addTodoItem, this modifies the array of todo strings and
  // notifies the app that the state has changed by using setState

  void _removeToDoItem(int index) {
    setState(() {
      _toDoItems.removeAt(index);
    });
  }

  void _promptRemoveTodoItem(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("mark  ${_toDoItems[index]}  as done ?"),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('CANCLE')),
              new FlatButton(
                  onPressed: () {
                    _removeToDoItem(index);
                    Navigator.of(context).pop();
                  },
                  child: Text('Make it done'))
            ],
          );
        });
  }

  void _pushAddTodoScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
        // MaterialPageRoute will automatically animate the screen entry, as well
        // as adding a back button to close it
        new MaterialPageRoute(builder: (context) {
      return Scaffold(
          appBar: new AppBar(title: new Text('Add a new task')),
          body: new TextField(
            autofocus: true,
            onSubmitted: (val) {
              _addTodoItem(val);
              Navigator.pop(context);
            },
            decoration: new InputDecoration(
                hintText: 'Enter something to do...',
                contentPadding: EdgeInsets.all(16.0)),
          ));
    }));
  }

  void __updateToDoitems(String task, int index) {
    setState(() {
      _toDoItems.removeAt(index);
      _toDoItems.insert(index, task);
    });
  }

  void _pushUpdateScreen(int index) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('update ${_toDoItems[index]}'),
        ),
        body: TextField(
          autofocus: true,
          onSubmitted: (val) {
            __updateToDoitems(val, index);
            Navigator.pop(context);
          },
          decoration: InputDecoration(
              hintText: _toDoItems[index],
              contentPadding: EdgeInsets.all(16.0)),
        ),
      );
    }));
  }
}*/

/**
 *
 * with auto number todo list
 *
 */
/*
class ToDoList extends StatefulWidget {
  ToDoListState createState() => ToDoListState();
}

class ToDoListState extends State<ToDoList> {

  List<String> _toDoItems = [];

  void _addToDoItem() {
    setState(() {
      int index = _toDoItems.length;
      _toDoItems.add('item ' + index.toString());
    });
  }

// Build the whole list of todo items
  Widget _buildToDoList() {
    return new ListView.builder(itemBuilder: (context, index) {

      // itemBuilder will be automatically be called as many times as it takes for the
      // list to fill up its available space, which is most likely more than the
      // number of todo items we have. So, we need to check the index is OK.

      if (index < _toDoItems.length) {
        return _buidToDoItem(_toDoItems[index]);
      }
    });
  }

  // Build a single todo item
  Widget _buidToDoItem(String todoText) {
    return new ListTile(
      title: new Text(todoText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('this is appBar Title'),
        textTheme: TextTheme(display1: Theme.of(context).textTheme.display1),
      ),
      body: _buildToDoList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _addToDoItem,
        tooltip: 'add items',
        child: new Icon(Icons.add),
      ),
    );
  }
}
*/
