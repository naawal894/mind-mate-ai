import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mc_project/consts.dart'; 
import 'package:google_generative_ai/google_generative_ai.dart'; 

class DiaryEntryScreen extends StatefulWidget {
  const DiaryEntryScreen({super.key});

  @override
  _DiaryEntryScreenState createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  final TextEditingController _textController = TextEditingController(); 
  bool _isGenerating = false; 
  // Change to a late Future to track initialization state
  late Future<void> _initFuture; 
  late GenerativeModel _model;

  String _formattedDate = '';
  String _report = "";

  @override
  void initState() {
    super.initState();
    // Start initialization and date update
    _initFuture = _initModel(); 
    _updateDate();
  }
  
  // Initialize model here
  Future<void> _initModel() async {
    const apiKey = GOOGLE_API_KEY;
    // CRITICAL: Ensure the API Key is not empty. If it is, the constructor will throw.
    if (apiKey.isEmpty) {
        throw Exception("API Key constant is empty.");
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }
  
  // FUNCTION TO CALL GEMINI DIRECTLY (Cleaned up)
  Future<String> _callGeminiDirect(String diaryEntry) async {
    // 🛑 REMOVED: The problematic 'if (GOOGLE_API_KEY.isEmpty || ...)' block
    
    // Check if model initialization failed previously
    if (_model == null) {
      throw Exception("AI model not initialized.");
    }

    const promptTemplate = """
      Analyze the following diary entry for:
      - Emotional tone
      - Potential signs of stress or mental health indicators
      - A short, single actionable suggestion
      Format response in clean markdown.
    """;

    final response = await _model.generateContent([
      Content.text("$promptTemplate\n\nDiary Entry: \"$diaryEntry\"")
    ]);

    return response.text ?? "No analysis generated.";
  }

  // CORRECTED _saveEntry FUNCTION
  Future<void> _saveEntry() async {
    // Check if the initialization future is done
    if (_initFuture != null) {
        await _initFuture; // Await model initialization before proceeding
    }

    final diaryEntry = _textController.text;
    
    if (diaryEntry.trim().isEmpty) {
      setState(() {
        _report = "Please enter some text to generate a report.";
      });
      return; 
    }

    setState(() {
      _isGenerating = true; 
      _report = "Generating report...";
    });
    
    try {
      String reportText = await _callGeminiDirect(diaryEntry); 
      
      setState(() {
        _report = reportText;
      });
      
    } catch (e) {
      print('Exception: $e');
      
      String errorContent = 'AI Service Error. Check API key, network, and model identifier.';
      
      // Removed the confusing dialog box, relying on the state update
      setState(() {
        _report = "Network connection failed or API issue occurred. Check your key validity. Error: ${e.toString()}";
      });
      
    } finally {
      setState(() {
        _isGenerating = false; 
      });
    }
  }

  void _updateDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d, yyyy');
    setState(() {
      _formattedDate = formatter.format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder to wait for the model to initialize
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while the model is being set up
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          // Show error if model initialization failed (e.g., bad key)
          return Scaffold(
            appBar: AppBar(title: const Text('Diary Entry'),),
            body: Center(child: Text('Initialization Error: ${snapshot.error}')),
          );
        }
        // Once successful, show the main screen content
        return _buildDiaryContent();
      },
    );
  }

  // New method to clean up the build method
  Widget _buildDiaryContent() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Entry',style: TextStyle(color:Color.fromARGB(255, 58, 0, 0),fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Color.fromARGB(255, 58, 0, 0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.purple.shade100,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/diary_bg.png"),
          fit: BoxFit.fill, ),),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text(
                  'Today is $_formattedDate',
                  style: const TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 58, 0, 0),
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  style: const TextStyle(color: Color.fromARGB(255, 61, 10, 10)),
                  controller: _textController,
                  maxLines: 18,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Write your diary entry...',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isGenerating ? null : _saveEntry,
                  child: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      : const Text('Generate Report'),
                ),
                const SizedBox(height: 20),
                // Report Display Logic
                _report.isNotEmpty && !_isGenerating
                    ? RichText(
                        // ... (Rest of RichText logic remains the same)
                        text: TextSpan(
                          children: _report.split('\n').map((line) {
                            if (line.startsWith('**')) {
                              return TextSpan(
                                text: line
                                    .replaceFirst('**', '')
                                    .replaceFirst('**', ''),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 82, 33, 33),
                                ),
                              );
                            } else if (line.startsWith('*')) {
                              return TextSpan(
                                text:
                                    '\u2022 ${line.replaceFirst('', '').replaceAll('*', '')}\n',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color:
                                      Color.fromARGB(255, 111, 111, 111),
                                ),
                              );
                            } else {
                              return TextSpan(
                                text: '$line\n',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              );
                            }
                          }).toList(),
                        ),
                      )
                    : Container(),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: (_report.isNotEmpty && !_isGenerating) ? () {
                    Clipboard.setData(ClipboardData(text: _report));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report copied to clipboard')),
                    );
                  } : null,
                  child: const Text('Copy Report'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}