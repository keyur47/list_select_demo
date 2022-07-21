import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_select_demo/aswS3_image/controller.dart';

class asw extends StatefulWidget {
  @override
  State<asw> createState() => _aswState();
}

class _aswState extends State<asw> {
  Controller controller = Get.put(Controller());

  ImagePicker pick = ImagePicker();
  String? imagePath;
  String? imageName;
  XFile? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          GestureDetector(
              onTap: () {
                getFromGallery();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Icon(Icons.add),
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding:  EdgeInsets.only(left: 2,right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundImage: FileImage(File(imagePath ?? "")),
                            backgroundColor: Colors.blue.withOpacity(0.3),
                            radius: 20,
                            child: IconButton(
                              onPressed: () {
                                getFromGallery();
                              },
                              icon: Icon(
                                Icons.add,
                                size: 15,
                                color: imagePath != null
                                    ? Colors.transparent
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Text(imageName??"not")),
                        Icon(Icons.arrow_forward_ios_outlined,size: 14,)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                )
              ],
            );
          },
        ),
      ),
    );
  }

  getFromGallery() async {
    try {
      XFile? image = await pick.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        if (kDebugMode) {
          setState(() {
            log("message-------${image.path}");
            imagePath = image.path;
            imageName = image.name;
            log("--------------${imagePath}");
            log("--------------${image.name}");
          });
          print("--------------${imageFile?.path}");
        }
      }
    } catch (e) {
      log("error--->${e.toString()}");
    }
  }
}

// Padding(
//   padding: const EdgeInsets.only(left: 30,right: 30),
//   child: TextFormField(
//     controller: controller.fileNameController,
//     readOnly: true,
//     decoration: InputDecoration(
//       suffixIcon: GestureDetector(
//           onTap: ()async{
//            // controller.result = await FilePicker.platform.pickFiles(type: FileType.image);
//            // controller.fileNameController.text = controller.result!.files.single.path!.split("/").last;
//              getFromGallery();
//             log("Name --->2${controller.fileNameController.text}");
//           },
//           child: Icon(Icons.add)),
//         border: InputBorder.none,
//         filled: true,
//         fillColor: Colors.blue.withOpacity(0.4)),
//   ),
// ),

// Center(
// child: imagePath != null ? Container(
// child: Image.file(
// File(imagePath ?? ""),
// fit: BoxFit.contain,
// height: 100,
// width: 100,
// ),
// ): SizedBox(),
// )
