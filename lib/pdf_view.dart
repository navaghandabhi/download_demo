import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfView extends StatelessWidget {
  final String path;

  const PdfView({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pdf View"),
      ),
      body: PDFView(
        filePath: path,
      ),
    );
  }
}
