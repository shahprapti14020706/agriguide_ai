import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/reminder_provider.dart';

class ReminderFormScreen extends StatefulWidget {
  const ReminderFormScreen({this.reminderId, super.key});

  final String? reminderId;

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'Irrigation';
  String _priority = 'normal';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  bool _hydrated = false;

  static const _types = [
    'Irrigation',
    'Fertilizer',
    'Disease Inspection',
    'Spraying',
    'Harvesting',
    'Market Check',
    'Scheme Deadline',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) {
      return;
    }
    _hydrated = true;
    final reminderId = widget.reminderId;
    if (reminderId != null) {
      final reminder = context.read<ReminderProvider>().byId(reminderId);
      if (reminder != null) {
        _titleController.text = reminder.title;
        _descriptionController.text = reminder.description;
        _type = reminder.type;
        _priority = reminder.priority;
        _dueDate = reminder.scheduledAt;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      return;
    }
    final provider = context.read<ReminderProvider>();
    final existing =
        widget.reminderId == null ? null : provider.byId(widget.reminderId!);
    final reminder = existing == null
        ? provider.create(
            userId: user.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            type: _type,
            dueDate: _dueDate,
            priority: _priority,
          )
        : existing.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            type: _type,
            scheduledAt: _dueDate,
            priority: _priority,
          );
    if (existing == null) {
      await provider.saveReminder(reminder);
    } else {
      await provider.updateReminder(reminder);
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reminderId == null
              ? strings.addReminder
              : strings.editReminder,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: strings.title),
                validator: (value) => value == null || value.trim().isEmpty
                    ? strings.title
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: strings.description),
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(labelText: strings.reminderType),
                items: _types
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _type = value ?? _type),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: InputDecoration(labelText: strings.priority),
                items: const [
                  DropdownMenuItem(value: 'normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (value) =>
                    setState(() => _priority = value ?? _priority),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.dueDate),
                subtitle:
                    Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (!mounted) {
                    return;
                  }
                  if (selected != null) {
                    setState(() => _dueDate = selected);
                  }
                },
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_outlined),
                label: Text(strings.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
