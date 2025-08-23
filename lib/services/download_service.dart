import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DownloadService {
  Future<String> downloadToLocal(String url, String filename) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200)
      throw Exception('Download failed: ${res.statusCode}');

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(res.bodyBytes);
    return file.path;
  }

  Future<void> deleteLocal(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
