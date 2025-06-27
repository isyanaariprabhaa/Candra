import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../database/database_helper.dart';
import '../providers/auth_providers.dart';

class AddReviewScreen extends StatefulWidget {
  final int kulinerId;
  final String kulinerName;
  const AddReviewScreen(
      {super.key, required this.kulinerId, required this.kulinerName});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  int _rating = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Review for: ${widget.kulinerName}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: List.generate(
                    5,
                    (index) => IconButton(
                          icon: Icon(
                              _rating > index ? Icons.star : Icons.star_border,
                              color: Colors.amber),
                          onPressed: () => setState(() => _rating = index + 1),
                        )),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reviewController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Your review',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter your review'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate() || _rating == 0) {
      if (_rating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a rating')));
      }
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user =
          Provider.of<AuthProvider>(context, listen: false).currentUser;
      final myReview = Review(
        kulinerId: widget.kulinerId,
        userId: user!.id!,
        rating: _rating,
        comment: _reviewController.text.trim(),
        createdAt: DateTime.now(),
        username: user.username,
      );
      await DatabaseHelper.instance.insertReview(myReview);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Review added!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }
}
