import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_reviews/utils.dart';

class KeyboardCreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => KeyboardCreatePageState();
}

class KeyboardCreatePageState extends State {
  // TextField controllers
  late TextEditingController _designerController;
  late TextEditingController _nameController;
  late TextEditingController _msrpController;
  late TextEditingController _sizeController;

  // Firebase components
  var db = FirebaseDatabase();

  // Required for form validation
  final _formKey = GlobalKey<FormState>();

  // private methods
  void _insertKeyboard() {
    print("insertKeyboard()");
    final designer = _designerController.text;
    final name = _nameController.text;
    var ref =
        db.reference().child("keyboards").child(keyboardKey(designer, name));
    ref.set({
      "designer": designer,
      "name": name,
      "size": _sizeController.text,
      "msrp": _msrpController.text,
    });
  }

  @override
  void initState() {
    super.initState();
    _designerController = TextEditingController();
    _nameController = TextEditingController();
    _msrpController = TextEditingController();
    _sizeController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a Keyboard"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
                controller: _designerController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Designer",
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Keyboard Name",
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Required";
                  } else if ((double.tryParse(value) == null) ||
                      double.parse(value) < 0) {
                    return "MSRP must be a positive number";
                  }
                  return null;
                },
                controller: _msrpController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "MSRP (USD)",
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Required";
                  }
                  return null;
                },
                controller: _sizeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Form Factor",
                ),
              ),
              // Spacer(),
              Row(
                children: [
                  Spacer(),
                  createStyledTextButton(
                    "Cancel",
                    () {
                      Navigator.pop(context);
                    },
                  ),
                  createStyledTextButton(
                    "Submit",
                    () {
                      if (_formKey.currentState!.validate()) {
                        _insertKeyboard();
                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
