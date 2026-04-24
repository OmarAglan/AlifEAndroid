class TerminalLine {
  final String text;
  final int sessionId;
  final bool? isError;
  final bool isSystem;

  TerminalLine({
    required this.text,
    required this.sessionId,
    this.isError,
    this.isSystem = false,
  });
}
