import 'dart:io';

import 'package:excel/excel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
      home: Home(title: 'Rotten Keyboards'),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

Future<void> testExcel() async {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel['SheetName'];

  CellStyle cellStyle = CellStyle(
      backgroundColorHex: "#1AFF1A",
      fontFamily: getFontFamily(FontFamily.Calibri));

  cellStyle.underline = Underline.Single; // or Underline.Double

  var cell = sheetObject.cell(CellIndex.indexByString("A1"));
  cell.value = 8; // dynamic values support provided;
  cell.cellStyle = cellStyle;

  // printing cell-type
  print("CellType: " + cell.cellType.toString());

  ///
  /// Inserting and removing column and rows

  // insert column at index = 8
  sheetObject.insertColumn(8);

  // remove column at index = 18
  sheetObject.removeColumn(18);

  // insert row at index = 82
  sheetObject.removeRow(82);

  // remove row at index = 80
  sheetObject.removeRow(80);
  final directory = await getApplicationDocumentsDirectory();
  var encoded = excel.encode();
  if (encoded == null) {
    return;
  }
  File(join(directory.path, "excel.xlsx"))
    ..createSync(recursive: true)
    ..writeAsBytesSync(encoded);
  await OpenFile.open(join(directory.path, "excel.xlsx"));
}

class Keyboard {
  String designer;
  String name;
  String msrp;

  Keyboard(this.designer, this.name, this.msrp);
}

class _HomeState extends State<Home> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;
  String _content = "";
  late DatabaseReference _contentRef;
  var db = FirebaseDatabase();
  GoogleSignIn _googleSignIn = GoogleSignIn();
  List<Keyboard> keyboards = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // body: Center(
      //   child: Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: StreamBuilder(
      //       stream: db.reference().child("keyboards").onValue,
      //       builder: (context, AsyncSnapshot<Event> snapshot) {
      //         if (snapshot.hasData) {
      //           keyboards.clear();
      //           DataSnapshot dataValues = snapshot.data!.snapshot;
      //           print(dataValues.value);
      //           Map<dynamic, dynamic> values = dataValues.value;
      //           values.forEach((key, v) {
      //             print(v);
      //             keyboards.add(new Keyboard(
      //               v["designer"],
      //               v["name"],
      //               v["msrp"],
      //             ));
      //           });
      //         }
      //         return new GridView.builder(
      //           // shrinkWrap: true,
      //           itemCount: keyboards.length,
      //           itemBuilder: (BuildContext context, int index) {
      //             return GestureDetector(
      //               onTap: () {
      //                 Navigator.push(
      //                   context,
      //                   MaterialPageRoute(
      //                     builder: (context) => ReviewsPage(
      //                         keyboards[index].name,
      //                         keyboardKey(
      //                           keyboards[index].designer,
      //                           keyboards[index].name,
      //                         )),
      //                   ),
      //                 );
      //               },
      //               child: Card(
      //                 child: Text(keyboards[index].name),
      //               ),
      //             );
      //           },
      //           gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      //             maxCrossAxisExtent: 300,
      //           ),
      //         );
      //       },
      //     ),
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        // onPressed: () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => KeyboardCreatePage()),
        //   );
        // },
        onPressed: testExcel,
        child: const Icon(Icons.add_sharp),
        backgroundColor: Colors.green,
      ),
    );
  }
}
