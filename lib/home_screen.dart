import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class PdfGeneratorScreen extends StatefulWidget {
  @override
  _PdfGeneratorScreenState createState() => _PdfGeneratorScreenState();
}

class _PdfGeneratorScreenState extends State<PdfGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  File? _pdfFile;

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _images = selectedImages;
      });
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _textController.text,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xff333333),
                ),
              ),
              pw.SizedBox(height: 20),
              ..._images.map(
                    (image) => pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 10),
                  child: pw.Image(
                    pw.MemoryImage(File(image.path).readAsBytesSync()),
                    width: 300,
                    height: 200,
                    fit: pw.BoxFit.cover,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());
    setState(() {
      _pdfFile = file;
    });

    if (_pdfFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(file: _pdfFile!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Enter Text',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImages,
              child: Text('Pick Images'),
            ),
            SizedBox(height: 20),
            _images.isNotEmpty
                ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _images
                  .map((image) => Image.file(
                File(image.path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ))
                  .toList(),
            )
                : Text('No images selected'),
            Spacer(),
            ElevatedButton(
              onPressed: _generatePdf,
              child: Text('Generate PDF'),
            ),
          ],
        ),
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final File file;

  PdfViewerScreen({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: file.path,
      ),
    );
  }
}