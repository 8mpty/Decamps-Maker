import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  String? _fileName;
  PlatformFile? pickedFile;
  File? fileToDisplay;

  Future<void> _importJson() async {
    try {
      setState(() {
        _isLoading = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        _fileName = result.files.first.name;
        pickedFile = result.files.first;
        fileToDisplay = File(pickedFile!.path!);

        print('File picked: $_fileName');

        final bytes = pickedFile!.bytes;
        if (bytes != null) {
          String fileContents = utf8.decode(bytes);
          var jsonData = jsonDecode(fileContents);

          print('JSON Data: $jsonData');
        } else {
          print('File data is null');
        }
      } else {
        print('No file selected or file picker was canceled');
      }
    } catch (e) {
      print('Error during file picking: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Decamps Maker"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _fileName == null
              ? _buildEmptyState()
              : _buildFileImportedState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.file_upload_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Data',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Import Personnel JSON file to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _importJson,
              icon: const Icon(Icons.file_upload),
              label: const Text('Import JSON'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileImportedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.file_download_done,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'File Imported: $_fileName',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _importJson,
              icon: const Icon(Icons.file_upload),
              label: const Text('Import Another File'),
            ),
          ],
        ),
      ),
    );
  }
}
