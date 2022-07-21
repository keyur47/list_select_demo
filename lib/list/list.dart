import 'package:flutter/material.dart';

class ListSelect extends StatefulWidget {
  ListSelect({Key? key}) : super(key: key);

  @override
  State<ListSelect> createState() => _ListSelectState();
}

class _ListSelectState extends State<ListSelect> {
  final GlobalKey<PopupMenuButtonState<int>> _key = GlobalKey();
  String? _string;
  int? Index = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        actions: [
          PopupMenuButton<int>(
            key: _key,
            onSelected: (value) {
              setState(() {
                if (value == 1) {
                  setState((){
                    for(var i = 0; i < data.length; i++) {
                      data[i].value = true;
                      _string = i.toString();
                    }
                  });
                } else if (value == 2) {
                  setState((){
                    for(var i = 0; i < data.length; i++){
                      data[i].value = false;
                      _string = i.toString();
                    }
                  });
                } else {}
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Text("Select all"),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text("Unselect all"),
              ),
            ],
          )
          // Padding(
          //   padding: const EdgeInsets.only(right: 15),
          //   child: Row(
          //     children: [
          //       GestureDetector(
          //           onTap: () {
          //             setState(() {
          //               for(var i = 0; i < data.length; i++) {
          //                 data[i].index = true;
          //               }
          //             });
          //           },
          //           child: const Icon(Icons.select_all)),
          //      const SizedBox(width: 20,),
          //       GestureDetector(
          //           onTap: () {
          //             setState(() {
          //               for(var i = 0; i < data.length; i++) {
          //                 data[i].index = false;
          //               }
          //             });
          //           },
          //           child: const Icon(Icons.tab_unselected)),
          //     ],
          //   ),
          // )
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        setState(() {
                          data[index].value = true;
                          _string = data[index].Index.toString();
                        });
                      },
                      onTap: () {
                        setState(() {
                          data[index].value = false;
                          _string = data[index].Index.toString();
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color:
                                data[index].value! ? Colors.blue.withOpacity(0.5) : Colors.black12,
                            // color: Colors.black12,
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("( ${index.toString()} )",
                                  style: TextStyle(
                                      color: data[index].value!
                                          ? Colors.black
                                          : Colors.black)),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Text(
                                data[index].text ?? "Not",
                                style: TextStyle(
                                    color: data[index].value!
                                        ? Colors.black
                                        : Colors.black),
                              )),
                              Checkbox(
                                  value: data[index].value,
                                  onChanged: (v) {
                                    setState(() {
                                      data[index].value = v;
                                    });
                                  }),
                              data[index].value!
                                  ? const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    )
                                  : const SizedBox(),
                              // GestureDetector(
                              //     onTap: () {
                              //       setState(() {
                              //         select = !select;
                              //       });
                              //     },
                              //     child: select
                              //         ? const Icon(Icons.check_box)
                              //         : const Icon(Icons.check_box_outline_blank_outlined))
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Model {
  String? text;
  bool? value = false;
  int? Index = 1;

  Model({this.text, required this.value, this.Index});
}

List<Model> data = [
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),
  Model(value: false),

  // Model(value: false,Index: 1),
  // Model(value: false,Index: 2),
  // Model(value: false,Index: 3),
  // Model(value: false,Index: 4),
  // Model(value: false,Index: 5),
  // Model(value: false,Index: 6),
  // Model(value: false,Index: 7),
  // Model(value: false,Index: 8),
  // Model(value: false,Index: 9),
  // Model(value: false,Index: 10),
  // Model(value: false,Index: 11),
  // Model(value: false,Index: 12),
  // Model(value: false,Index: 13),
  // Model(value: false,Index: 14),
  // Model(value: false,Index: 15),
  // Model(value: false,Index: 16),
];
