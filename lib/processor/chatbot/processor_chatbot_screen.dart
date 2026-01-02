import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Chatbot for processor
// Input-output planner
// Suggest fertilizer production process

class ProcessorChatbotScreen extends StatefulWidget {
  const ProcessorChatbotScreen({super.key});

  @override
  State<ProcessorChatbotScreen> createState() => _ProcessorChatbotScreenState();
}

class _ProcessorChatbotScreenState extends State<ProcessorChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(
      ChatMessage(
        text: "👋 Hello! I'm your Processing Mentor. I can help with:\n\n• Fertilizer production planning\n• Input-output calculations\n• Best processing techniques\n• Quality control tips\n• Market pricing guidance",
        isBot: true,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isBot: false,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    // TODO: Call AI chatbot service
    await Future.delayed(const Duration(seconds: 2));

    String botResponse = _generateResponse(userMessage);

    setState(() {
      _messages.add(ChatMessage(
        text: botResponse,
        isBot: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });

    _scrollToBottom();
  }

  String _generateResponse(String question) {
    final lowerQuestion = question.toLowerCase();

    if (lowerQuestion.contains('vermicompost') || lowerQuestion.contains('production')) {
      return "🏭 Vermicompost Production Guide:\n\n• Input: 100 kg crop waste\n• Output: ~60 kg vermicompost\n• Time: 45-60 days\n• Add earthworms (Eisenia fetida)\n• Maintain 60-70% moisture\n• Turn every 7 days\n\nSelling price: ₹20-30/kg\nProfit margin: ~40%";
    } else if (lowerQuestion.contains('price') || lowerQuestion.contains('cost')) {
      return "💰 Fertilizer Pricing Guide:\n\n• Compost: ₹15-25/kg\n• Vermicompost: ₹20-30/kg\n• Bio-fertilizer: ₹35-50/kg\n• Organic Manure: ₹10-20/kg\n\nFactors:\n✓ Quality & certification\n✓ Processing time\n✓ Market demand\n✓ Packaging";
    } else if (lowerQuestion.contains('input') || lowerQuestion.contains('output')) {
      return "📊 Input-Output Planning:\n\n100 kg agricultural waste →\n• Compost: 40-50 kg\n• Vermicompost: 50-60 kg\n• Time: 30-60 days\n\nProfit calculation:\nCost: ₹500 (waste purchase)\nOutput: 50 kg × ₹25 = ₹1250\nProfit: ₹750\n\nROI: ~150%";
    } else {
      return "I can help you with:\n\n• Production planning\n• Input-output calculations\n• Processing techniques\n• Pricing strategies\n• Quality standards\n\nWhat would you like to know?";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Processing Mentor'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Analyzing...'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about production...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: AppTheme.primaryGreen,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isBot)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isBot
                    ? Colors.grey.shade200
                    : AppTheme.primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isBot ? 4 : 20),
                  bottomRight: Radius.circular(message.isBot ? 20 : 4),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  color: message.isBot ? Colors.black87 : Colors.white,
                ),
              ),
            ),
          ),
          if (!message.isBot)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}
