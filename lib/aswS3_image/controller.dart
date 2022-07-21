import 'dart:io';
import 'package:aws_s3/aws_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class Controller extends GetxController {
  String aWSBucketName = 'demo-dev-s3';
  RxString uploadedUrl = ''.obs;
  TextEditingController fileNameController = TextEditingController();
  FilePickerResult? result;


  Future createDoc(File file) async {
    final AwsS3 awsS3 = AwsS3(
      awsFolderPath: "",
      file: file,
      fileNameWithExt: file.path.split("/").last,
      poolId: '',
      region: Regions.US_WEST_2,
      bucketName: aWSBucketName,
    );
    try {
      final String? uploadedFileName = await awsS3.uploadFile;
      uploadedUrl.value = 'https://demo-s3.s3.us-west-2.amazonaws.com/$uploadedFileName';
      print("image:- ${uploadedUrl}");
      fileNameController.text = awsS3.fileNameWithExt;
    } catch (e) {
      rethrow;
    }
  }
}
