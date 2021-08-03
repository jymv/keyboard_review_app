import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewDetail extends StatefulWidget {
  final String keyboardName;
  final String keyboardKey;
  final String reviewerName;

  ReviewDetail(this.keyboardName, this.keyboardKey, this.reviewerName);

  @override
  State<StatefulWidget> createState() => ReviewDetailState();
}

class ReviewDetailState extends State<ReviewDetail> {
  // firebase
  var db = FirebaseDatabase();

  @override
  void initState() {
    super.initState();
    Query q = db
        .reference()
        .child("reviews/${widget.keyboardKey}")
        .equalTo(widget.reviewerName);
    print(q.get());
  }

  @override
  Widget build(BuildContext context) {
    print(widget.keyboardKey);
    print(widget.keyboardName);
    print(widget.reviewerName);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.keyboardName),
      ),
      body: StreamBuilder(
        stream: db
            .reference()
            .child("reviews/${widget.keyboardKey}/${widget.reviewerName}")
            .onValue,
        builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
          if (snapshot.hasError) {
            return Text("Error");
          }
          if (snapshot.hasData) {
            DataSnapshot dataValues = snapshot.data!.snapshot;
            print(dataValues.value.toString());
            return Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    createLabeledRating(
                        "Design", dataValues.value["designRating"]),
                    createLabeledRating(
                        "Build Quality", dataValues.value["buildRating"]),
                    createLabeledRating(
                        "Sound", dataValues.value["soundRating"]),
                    createLabeledRating("Feel", dataValues.value["feelRating"]),
                    createLabeledRating(
                        "Features", dataValues.value["featuresRating"]),
                    createLabeledRating(
                        "Value", dataValues.value["valueRating"]),
                    Text(dataValues.value["title"]),
                    Text("review by ${dataValues.key}"),
                    Text(dataValues.value["reviewText"]),
                  ],
                ));
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

Widget createLabeledRating(String label, int rating) {
  return Row(
    children: [
      Spacer(),
      Text(label),
      RatingBarIndicator(
        itemBuilder: (context, index) => Icon(Icons.star, color: Colors.amber),
        itemCount: 5,
        itemSize: 30.0,
        direction: Axis.horizontal,
        rating: rating.toDouble(),
      ),
    ],
  );
}
