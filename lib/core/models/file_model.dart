enum FileAction { rename, delete, close, toggleReadOnly }

class FileEntity {
  final int id;
  final String name;
  final String? path;
  final String code;
  final bool saved;
  final List<int> cursor;
  final bool readOnly;

  const FileEntity({
    required this.id,
    required this.name,
    this.path,
    required this.code,
    this.saved = false,
    this.cursor = const [0, 0],
    this.readOnly = false,
  });

  factory FileEntity.fromJson(Map<String, dynamic> json) {
    return FileEntity(
      id: json["id"] ?? 0,
      name: json["Name"] ?? "ملف",
      path: json["Path"],
      code: json["Code"] ?? "",
      saved: json["Saved"] ?? false,
      cursor: List<int>.from(json["Cursor"] ?? [0, 0]),
      readOnly: json["ReadOnly"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "Name": name,
      "Path": path,
      "Code": code,
      "Saved": saved,
      "Cursor": cursor,
      "ReadOnly": readOnly,
    };
  }

  static FileEntity empty() => const FileEntity(id: -1, name: "", code: "");

  FileEntity copyWith({
    int? id,
    String? name,
    String? path,
    String? code,
    bool? saved,
    List<int>? cursor,
    bool? readOnly,
  }) {
    return FileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      code: code ?? this.code,
      saved: saved ?? this.saved,
      cursor: cursor ?? this.cursor,
      readOnly: readOnly ?? this.readOnly,
    );
  }
}
