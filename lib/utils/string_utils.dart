String? optionalText(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
