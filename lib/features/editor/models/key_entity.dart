class KeyEntity {
  final int id;
  final String name;
  final String insert;
  final String? closing;
  int usageCount;

  KeyEntity({
    this.id = 0,
    required this.name,
    String? insert,
    this.closing,
    this.usageCount = 0,
  }) : insert = insert ?? name;
}

class SymbolData {
  final String insert;
  final String? closing;
  SymbolData(this.insert, {this.closing});
}