import 'package:flutter/material.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/models/note_databse.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // text controller to access what the user typed
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    readNotes();
  }

  // create a note
  void createNote() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: _textFieldController,
              ),
              actions: [
                MaterialButton(
                    onPressed: () {
                      // add to db
                      context
                          .read<NoteDatabase>()
                          .addNote(_textFieldController.text);
                      // clear controller
                      _textFieldController.clear();

                      Navigator.pop(context);
                    },
                    child: const Text("Create"))
              ],
            ));
  }

  // read note
  void readNotes() {
    context.read<NoteDatabase>().fetchNotes();
  }

  // update a note
  void updateNote(Note note) {
    // pre-fill the current note text
    _textFieldController.text = note.text;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Update Note'),
          content: TextFormField(
            controller: _textFieldController,
          ),
          actions: [
            // update button
            MaterialButton(
              onPressed: () {
                context
                    .read<NoteDatabase>()
                    .updateNote(note.id, _textFieldController.text);
                // clear controller
                _textFieldController.clear();

                // pop dialog box
                Navigator.pop(context);
              },
              child: const Text("update"),
            )

            // update note in db
          ]),
    );
  }

  // delete a note
  void deleteNote(int id) {
    context.read<NoteDatabase>().deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    // note database
    final NoteDatabase notesDB = context.watch<NoteDatabase>();

    // current notes
    List<Note> currentNotes = notesDB.currentNotes;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createNote,
          child: const Icon(Icons.add),
        ),
        body: ListView.builder(
            itemCount: currentNotes == null ? 0 : currentNotes.length,
            itemBuilder: ((context, index) {
              // get the note from list of notes
              final note = currentNotes[index];
              return ListTile(
                title: Text(note.text),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // edit button
                    IconButton(
                      onPressed: () => updateNote(note),
                      icon: const Icon(Icons.edit),
                    ),

                    IconButton(
                      onPressed: () => deleteNote(note.id),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            })));
  }
}
