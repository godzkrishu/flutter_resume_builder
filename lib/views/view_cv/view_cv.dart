import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_resume_template/flutter_resume_template.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:resume_builder_app/views/widgets/app_bar.dart';
import 'package:pdf/widgets.dart' as pw;

class ViewCv extends StatefulWidget {
  const ViewCv({super.key,required this.templateData});
  final TemplateData templateData;

  @override
  State<ViewCv> createState() => _ViewCvState();
}

class _ViewCvState extends State<ViewCv> {
  GlobalKey key=GlobalKey();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: CustomAppBar().build(context, "CV"),
      body: RepaintBoundary(
        key: key,
        child: FlutterResumeTemplate(
            data: widget.templateData,
            templateTheme: TemplateTheme.technical,
            imageHeight: 100,
            imageWidth: 100,
            emailPlaceHolder: 'Email:',
            telPlaceHolder: 'No:',
            experiencePlaceHolder: 'Experience',
            educationPlaceHolder: 'Education',
            languagePlaceHolder: 'Skills',
            aboutMePlaceholder: 'About Me',
            hobbiesPlaceholder: 'Hobbies',
            mode: TemplateMode.onlyEditableMode,
            showButtons: true,
            imageBoxFit: BoxFit.fitHeight,
            backgroundColorLeftSection: Colors.blue,
            enableDivider: false,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          try {
            final pdf = pw.Document();

            // Capture the widget as an image
            final image = await _capturePng(key);
            final memoryImage=pw.MemoryImage(image);

            // Add the image to a PDF page
            pdf.addPage(
              pw.Page(
                pageFormat:  PdfPageFormat(memoryImage.width?.toDouble() ?? 200 ,memoryImage.height?.toDouble()?? 700,marginAll: 0.0),
                margin: pw.EdgeInsets.zero, // Removes the default margin
                build: (pw.Context context) {
                  return pw.Center(
                    child: pw.Image(memoryImage, fit: pw.BoxFit.contain,),
                  );
                },
              ),
            );

            // Get the temporary directory and save the file
            final output = await getTemporaryDirectory();
            final file = File("${output.path}/resume.pdf");
            print(file.path);
            await file.writeAsBytes(await pdf.save());

            // Optionally, share or print the PDF
            await Printing.sharePdf(bytes: await pdf.save(), filename: 'resume.pdf');
          } catch (e) {
            print('Error generating PDF: $e');
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<Uint8List> _capturePng(GlobalKey key) async {
    RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage(pixelRatio: 4.0);
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}