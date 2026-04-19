class FileEntity {
  final int id;
  final String name;
  final String? path;
  final String code;
  final bool saved;

  factory FileEntity.fromJson(Map<String, dynamic> json) {
    return FileEntity(
      id: json["id"] ?? 0,
      name: json["Name"] ?? "ملف",
      path: json["Path"],
      code: json["Code"] ?? "",
      saved: json["Saved"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "Name": name, "Path": path, "Code": code, "Saved": saved};
  }

  FileEntity copyWith({
    int? id,
    String? name,
    String? path,
    String? code,
    bool? saved,
  }) {
    return FileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      code: code ?? this.code,
      saved: saved ?? this.saved,
    );
  }

  const FileEntity({
    required this.id,
    required this.name,
    this.path,
    required this.code,
    this.saved = false,
  });
}
