import 'package:flutter/material.dart';
import 'package:list_select_demo/list/list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListSelect(),
    );
  }
}
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   static int _len = 10;
//   List<bool> isChecked = List.generate(_len, (index) => false);
//
//   String _getTitle() =>
//       "Checkbox Demo : Checked = ${isChecked.where((check) => check == true).length}, Unchecked = ${isChecked.where((check) => check == false).length}";
//   String _title = "Checkbox Demo";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$_title'),
//       ),
//       body: ListView.builder(
//         itemCount: _len,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text("Item $index"),
//             trailing: Checkbox(
//                 onChanged: (checked) {
//                   setState(
//                     () {
//                       isChecked[index] = checked!;
//                       _title = _getTitle();
//                     },
//                   );
//                 },
//                 value: isChecked[index]),
//           );
//         },
//       ),
//     );
//   }
// }
