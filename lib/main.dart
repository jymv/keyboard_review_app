import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(KeyboardApp());
}

class KeyboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'Flutter Demo Home Page'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;
  String _content = "";
  late DatabaseReference _contentRef;
  var db = FirebaseDatabase();
  GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  void initState() {
    super.initState();
    auth.idTokenChanges().listen((User? user) {
      if (user == null) {
        print("User is currently signed out!");
      } else {
        print("User is signed in!");
      }
    });
  }

  void insert() {
    print("insert()");
    _contentRef = db.reference();
    _contentRef.child("test_sample").onValue.listen((event) {
      print(event.snapshot.value);
    });
    _contentRef.child("test_sample").set({"testkey3": "testvalue"});
  }

  void insertKeyboard() {
    print("insertKeyboard()");
    var ref = db.reference().child("keyboards");
    ref.push().set({
      "designer": "Bloop",
      "name": "Bloop65",
      "revision": "n/a",
      "size": "65%",
      "msrp": "280"
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_content',
            ),
            ElevatedButton(
                onPressed: () async {
                  var sign = await signInWithGoogle();
                  print(sign.user!.displayName);
                  print(sign.user!.uid);
                  var ref = db.reference().child("users/${sign.user!.uid}");
                  ref.set({
                    "display_name": sign.user!.displayName,
                    "uid": sign.user!.uid,
                  });
                },
                child: Text("Sign in with Google")),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                _googleSignIn.disconnect();
              },
              child: Text("Sign out"),
            ),
            ElevatedButton(
              onPressed: insertKeyboard,
              child: Text("Insert Keyboard"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: insert,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
