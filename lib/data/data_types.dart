class FileEntity {
  int? id;
  String name;
  String? path;
  String code;
  bool? saved;

  factory FileEntity.fromJson(Map<String, dynamic> json) {
    return FileEntity(
      id: json['id'],
      name: json['Name'],
      path: json['Path'],
      code: json['Code'],
      saved: json['Saved'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'Name': name, 'Path': path, 'Code': code, 'Saved': saved};
  }

  FileEntity({
    this.id,
    required this.name,
    this.path,
    required this.code,
    this.saved = false,
  });
}
