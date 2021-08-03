import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_reviews/utils.dart';

class AddReviewPage extends StatefulWidget {
  final String keyboardName;
  final String keyboardKey;

  AddReviewPage(this.keyboardName, this.keyboardKey);

  @override
  State<StatefulWidget> createState() => AddReviewPageState();
}

class AddReviewPageState extends State<AddReviewPage> {
  late int _designRating;
  late int _buildRating;
  late int _soundRating;
  late int _feelRating;
  late int _featuresRating;
  late int _valueRating;
  late XFile? _imageFile;

  TextEditingController _reviewController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  var db = FirebaseDatabase();
  final FirebaseAuth auth = FirebaseAuth.instance;

  final picker = ImagePicker();

  // private methods
  void pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  void _insertReview() {
    print("_insertReview()");
    print(auth.currentUser!.uid);

    var ref = db
        .reference()
        .child("reviews/${widget.keyboardKey}/${auth.currentUser!.uid}");
    ref.set({
      "designRating": _designRating,
      "buildRating": _buildRating,
      "soundRating": _soundRating,
      "feelRating": _feelRating,
      "featuresRating": _featuresRating,
      "valueRating": _valueRating,
      "reviewText": _reviewController.text,
      "title": _titleController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviewing the ${widget.keyboardName}"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              createLabeledRatingBar(
                "Design - How good does it look?",
                (rating) {
                  _designRating = rating.floor();
                },
              ),
              createLabeledRatingBar(
                "Build Quality - How well does it go together?",
                (rating) {
                  _buildRating = rating.floor();
                },
              ),
              createLabeledRatingBar(
                "Sound - How good does it sound?",
                (rating) {
                  _soundRating = rating.floor();
                },
              ),
              createLabeledRatingBar(
                "Feel - How good does it feel?",
                (rating) {
                  _feelRating = rating.floor();
                },
              ),
              createLabeledRatingBar(
                "Features - Does it do more?",
                (rating) {
                  _featuresRating = rating.floor();
                },
              ),
              createLabeledRatingBar(
                "Value - Is it worth its price?",
                (rating) {
                  _valueRating = rating.floor();
                },
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Title",
                ),
              ),
              TextFormField(
                controller: _reviewController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Written Review",
                ),
              ),
              Text("Thumbnail"),
              TextButton(onPressed: pickImage, child: Text("attach")),
              createStyledTextButton(
                "Cancel",
                () {
                  Navigator.pop(context);
                },
              ),
              createStyledTextButton(
                "Submit",
                () {
                  _insertReview();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

createLabeledRatingBar(String label, void Function(double) onUpdate) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      RatingBar.builder(
        glow: false,
        initialRating: 0,
        minRating: 1,
        direction: Axis.horizontal,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
        onRatingUpdate: onUpdate,
      )
    ],
  );
}
