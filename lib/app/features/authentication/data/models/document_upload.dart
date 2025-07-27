import 'dart:io';

class DocumentUpload {
  final String type;
  final File? file;

  DocumentUpload({
    required this.type,
    this.file,
  });
}
