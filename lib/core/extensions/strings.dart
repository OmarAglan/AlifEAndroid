import "../../constants.dart";

extension StringExtension on String {
  String get handelHomePath => replaceAll(kHomeDir, "~");
}
