// lib/screens/vacation/request_vacation_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/vacation_model.dart';
import '../../models/vacation_balance_model.dart';
import '../../theme/adaptive_colors.dart';

class RequestVacationDialog extends StatefulWidget {
  final VacationBalance? balance;
  final Function(VacationRequest) onSubmit;
  final VacationRequest? editRequest;

  const RequestVacationDialog({
    super.key,
    this.balance,
    required this.onSubmit,
    this.editRequest,
  });

  @override
  State<RequestVacationDialog> createState() => _RequestVacationDialogState();
}

class _RequestVacationDialogState extends State<RequestVacationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _startTime = Day.morning;
  String _endTime = Day.afternoon;
  String _vacationType = VacationType.annualLeave;

  @override
  void initState() {
    super.initState();
    if (widget.editRequest != null) {
      _initializeEditData();
    }
  }

  void _initializeEditData() {
    final request = widget.editRequest!;
    _startDate = DateTime.parse(request.startDate);
    _endDate = DateTime.parse(request.endDate);
    _startTime = request.startTime;
    _endTime = request.endTime;
    _vacationType = request.type;
    _reasonController.text = request.reason;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int _calculateDays() {
    if (_startDate == null || _endDate == null) return 0;

    int days = _endDate!.difference(_startDate!).inDays + 1;

    // Adjust for half days
    if (_startDate == _endDate) {
      if (_startTime == Day.afternoon || _endTime == Day.morning) {
        return 1; // Half day counts as 1
      }
    } else {
      if (_startTime == Day.afternoon) days--;
      if (_endTime == Day.morning) days--;
    }

    return days;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());

    final firstDate = isStart
        ? DateTime.now()
        : (_startDate ?? DateTime.now());

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select start and end dates'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final days = _calculateDays();
      if (widget.balance != null && days > widget.balance!.availableDays) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient balance. Available: ${widget.balance!.availableDays} days',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final request = VacationRequest(
        id: widget.editRequest?.id,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
        startTime: _startTime,
        endTime: _endTime,
        type: _vacationType,
        reason: _reasonController.text.trim(),
      );

      widget.onSubmit(request);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isEdit = widget.editRequest != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Vacation Request' : 'Request Vacation',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.balance != null) ...[
                  SizedBox(height: screenWidth * 0.02),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'Available balance: ${widget.balance!.availableDays} days',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: screenWidth * 0.04),

                // Vacation Type
                DropdownButtonFormField<String>(
                  value: _vacationType,
                  decoration: const InputDecoration(
                    labelText: 'Vacation Type',
                    border: OutlineInputBorder(),
                  ),
                  items: VacationType.displayNames.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _vacationType = value!;
                    });
                  },
                ),
                SizedBox(height: screenWidth * 0.04),

                // Date Selection
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _startDate != null
                                ? DateFormat('MMM dd, yyyy').format(_startDate!)
                                : 'Select date',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _endDate != null
                                ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                : 'Select date',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.04),

                // Time Selection
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _startTime,
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                        ),
                        items: Day.displayNames.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _startTime = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _endTime,
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                        ),
                        items: Day.displayNames.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _endTime = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.04),

                // Reason
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide a reason';
                    }
                    return null;
                  },
                ),

                if (_startDate != null && _endDate != null) ...[
                  SizedBox(height: screenWidth * 0.04),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.green),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'Total days: ${_calculateDays()}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: screenWidth * 0.04),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    ElevatedButton(
                      onPressed: _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdaptiveColors.primaryGreen,
                      ),
                      child: Text(isEdit ? 'Update' : 'Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}