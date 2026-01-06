import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddProjectSheet extends StatefulWidget {
  const AddProjectSheet({super.key});

  @override
  State<AddProjectSheet> createState() => _AddProjectSheetState();
}

class _AddProjectSheetState extends State<AddProjectSheet> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;

  // Function to pick date
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF), // Purple
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E2C),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161621),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(top: BorderSide(color: Color(0xFFFF5252), width: 1)), // Red border for deadlines
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),

          const Text("INITIATE LONG-TERM OPERATION", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),

          // Title Input
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "Operation Name (e.g. Build Portfolio)",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: const Color(0xFF1E1E2C),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),

          const SizedBox(height: 20),

          // Date Picker Button
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _selectedDate == null ? Colors.transparent : const Color(0xFFFF5252)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: _selectedDate == null ? Colors.grey : const Color(0xFFFF5252), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate == null
                        ? "Select Deadline Date"
                        : DateFormat('MMMM d, yyyy').format(_selectedDate!),
                    style: TextStyle(
                      color: _selectedDate == null ? Colors.grey : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_titleController.text.isEmpty || _selectedDate == null) return;

                // Return Data
                Navigator.pop(context, {
                  'title': _titleController.text,
                  'date': _selectedDate,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252), // Red for Action
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                shadowColor: const Color(0xFFFF5252).withOpacity(0.4),
                elevation: 10,
              ),
              child: const Text(
                "CONFIRM DEADLINE",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}