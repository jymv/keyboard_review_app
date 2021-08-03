import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_reviews/add_review_page.dart';
import 'package:keyboard_reviews/review_detail.dart';

class ReviewsPage extends StatefulWidget {
  // members
  final String keyboardName;
  final String keyboardKey;

  // constructor
  const ReviewsPage(this.keyboardName, this.keyboardKey);

  @override
  State<StatefulWidget> createState() => ReviewsPageState();
}

class ReviewPreview {
  final String title;
  final String reviewer;

  ReviewPreview(this.title, this.reviewer);
}

class ReviewsPageState extends State<ReviewsPage> {
  // Firebase components
  var db = FirebaseDatabase();

  // members
  List<ReviewPreview> _reviewPreviews = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.keyboardName),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: StreamBuilder(
          stream: db.reference().child("reviews/${widget.keyboardKey}").onValue,
          builder: (context, AsyncSnapshot<Event> snapshot) {
            if (snapshot.hasData) {
              _reviewPreviews.clear();
              DataSnapshot dataValues = snapshot.data!.snapshot;
              print(dataValues.value);
              Map<dynamic, dynamic> values = dataValues.value ?? {};
              values.forEach((key, v) {
                print(v);
                _reviewPreviews.add(new ReviewPreview(v["title"], key));
              });
            }
            return new ListView.builder(
              itemExtent: 100,
              itemCount: _reviewPreviews.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewDetail(
                          widget.keyboardName,
                          widget.keyboardKey,
                          _reviewPreviews[index].reviewer,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _reviewPreviews[index].title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          Text(_reviewPreviews[index].reviewer),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddReviewPage(
                widget.keyboardName,
                widget.keyboardKey,
              ),
            ),
          );
        },
        child: const Icon(Icons.add_sharp),
        backgroundColor: Colors.green,
      ),
    );
  }
}
