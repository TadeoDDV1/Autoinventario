import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> saveTicketPdf(List<int> bytes, String filename) async {
  Directory dir;
  if (Platform.isAndroid) {
    dir = (await getExternalStorageDirectory()) ??
        await getApplicationDocumentsDirectory();
  } else {
    dir = await getApplicationDocumentsDirectory();
  }
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes);
  return file.path;
}
