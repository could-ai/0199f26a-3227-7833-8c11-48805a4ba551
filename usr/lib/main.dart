import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Formatter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const TextFormatterPage(),
    );
  }
}

class TextFormatterPage extends StatefulWidget {
  const TextFormatterPage({super.key});

  @override
  State<TextFormatterPage> createState() => _TextFormatterPageState();
}

class _TextFormatterPageState extends State<TextFormatterPage> {
  final TextEditingController _rawTextController = TextEditingController();
  String _formattedText = '';

  void _formatText() {
    final String rawText = _rawTextController.text;
    if (rawText.isEmpty) {
      setState(() {
        _formattedText = '';
      });
      return;
    }

    // Formatting logic:
    // 1. Normalize line endings and trim the whole text.
    String text = rawText.replaceAll('\r\n', '\n').trim();

    // 2. Split the text into blocks. A block is a paragraph, a section header,
    //    or a group of bullet points. Blocks are assumed to be separated by
    //    one or more empty lines.
    final blocks = text.split(RegExp(r'\n\s*\n'));

    // 3. Process each block: trim it and filter out empty blocks.
    final processedBlocks = blocks.map((block) => block.trim()).where((block) => block.isNotEmpty);

    // 4. Join the blocks back with double newlines. This creates a blank line
    //    between each major section, paragraph, or bullet group, which is
    //    rendered well in Excel cells with "Wrap Text" enabled.
    setState(() {
      _formattedText = processedBlocks.join('\n\n');
    });
  }

  void _copyToClipboard() {
    if (_formattedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _formattedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formatted text copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Description Formatter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Enter Raw Text from Excel:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rawTextController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Paste your raw product description here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _formatText,
                child: const Text('Format Text'),
              ),
              const SizedBox(height: 30),
              const Text(
                'Formatted Text:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.grey[100],
                ),
                child: SelectableText(
                  _formattedText.isEmpty ? 'Formatted text will appear here.' : _formattedText,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
