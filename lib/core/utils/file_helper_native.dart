import 'dart:io';

class FileHelper {
  static bool fileExists(String path) => File(path).existsSync();
}
