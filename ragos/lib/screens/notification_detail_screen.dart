// lib/screens/notification_detail_screen.dart
import 'package:flutter/material.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({Key? key, required this.notification})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Notification'),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.headphones, size: 28),
            onPressed: () {
              // Handle headphones icon tap
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Larger notification type indicator image
            Image.asset(
              notification['type'] == 'Positive'
                  ? 'assets/images/positive_notification.png'
                  : notification['type'] == 'Negative'
                  ? 'assets/images/negative_notification.png'
                  : 'assets/images/normal_notification.png',
              height: 200, // Increased from 120
              width: 320, // Increased from 120
            ),
            const SizedBox(height: 10),

            // Conversation card with scrollable content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Conversation:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildConversationBubble(
                            'Caregiver',
                            'Hi there, superstar! How was your day today?',
                          ),
                          _buildConversationBubble(
                            'Child',
                            'It was awesome! We had art class and I painted a rainbow.',
                          ),
                          _buildConversationBubble(
                            'Caregiver',
                            'A rainbow? That sounds beautiful. Can you tell me more about it?',
                          ),
                          _buildConversationBubble(
                            'Child',
                            'Sure! I used all the colors—red, orange, yellow, green, blue, and purple. My teacher said it was the brightest one she\'d ever seen.',
                          ),
                          _buildConversationBubble(
                            'Caregiver',
                            'Wow, that\'s amazing! You must have worked hard on those colors. How did that make you feel?',
                          ),
                          _buildConversationBubble(
                            'Child',
                            'I felt really proud. Everyone in class said they loved it.',
                          ),
                          // Add more conversation bubbles as needed
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationBubble(String speaker, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$speaker:',
            style: TextStyle(
              color: speaker == 'Caregiver' ? Colors.blue : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16, // Slightly larger font
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15, // Slightly larger font
            ),
          ),
        ],
      ),
    );
  }
}
