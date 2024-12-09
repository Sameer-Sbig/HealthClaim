import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

class PdfViewer extends StatefulWidget {
  final String blobUrl;

  PdfViewer({required this.blobUrl});

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  @override
  void initState() {
    super.initState();
    registerViewFactory(widget.blobUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: HtmlElementView(viewType: 'pdfViewer'),
    );
  }

  void registerViewFactory(String url) {
    ui.platformViewRegistry.registerViewFactory('pdfViewer', (int viewId) {
      final iframe = html.IFrameElement()
        ..width = '100%'
        ..height = '100%'
        ..src = url
        ..style.border = 'none';
      return iframe;
    });
  }
}
