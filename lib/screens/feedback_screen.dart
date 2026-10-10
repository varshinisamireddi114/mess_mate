
import 'package:flutter/material.dart';
import '../services/mess_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _service = MessService();
  final _controller = TextEditingController();

  double _rating = 4;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback.')),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      await _service.submitFeedback(
        rating: _rating,
        message: _controller.text,
      );

      _controller.clear();

      if (mounted) {
        setState(() => _rating = 4);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your feedback was submitted.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(
          Icons.rate_review_outlined,
          size: 64,
          color: Color(0xFF16856B),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your Feedback Matters!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Help us make your mess experience better.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        const Text(
          'Rate the food',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Slider(
          value: _rating,
          min: 1,
          max: 5,
          divisions: 4,
          label: '${_rating.round()} stars',
          onChanged: (value) => setState(() => _rating = value),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Icon(
                index < _rating.round() ? Icons.star : Icons.star_border,
                color: Colors.amber.shade700,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _controller,
          maxLines: 5,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: 'Your suggestions or complaints',
            hintText: 'Tell us what you liked or what can improve...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _sending ? null : _submit,
          icon: const Icon(Icons.send),
          label: Text(_sending ? 'Submitting...' : 'Submit Feedback'),
        ),
      ],
    );
  }
}
