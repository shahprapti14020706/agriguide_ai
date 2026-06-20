abstract final class FileUtils {
  static String extensionFromPath(String path) {
    final index = path.lastIndexOf('.');
    if (index == -1 || index == path.length - 1) {
      return '';
    }

    return path.substring(index + 1).toLowerCase();
  }
}
