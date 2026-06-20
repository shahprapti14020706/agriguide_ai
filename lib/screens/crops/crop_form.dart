import 'package:flutter/material.dart';

import '../../core/utils/validators.dart';
import '../../models/crop_model.dart';

class CropForm extends StatefulWidget {
  const CropForm({
    required this.userId,
    required this.submitLabel,
    required this.onSubmit,
    this.initialCrop,
    this.loading = false,
    super.key,
  });

  final String userId;
  final String submitLabel;
  final CropModel? initialCrop;
  final bool loading;
  final Future<void> Function(CropModel crop) onSubmit;

  @override
  State<CropForm> createState() => _CropFormState();
}

class _CropFormState extends State<CropForm> {
  final _formKey = GlobalKey<FormState>();
  final _cropNameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _areaController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _sowingDate;
  DateTime? _expectedHarvestDate;
  String _soilType = 'Loamy';
  String _irrigationMethod = 'Drip';

  static const _soilTypes = [
    'Loamy',
    'Clay',
    'Sandy',
    'Silty',
    'Black',
    'Red',
    'Alluvial',
  ];

  static const _irrigationMethods = [
    'Drip',
    'Sprinkler',
    'Flood',
    'Furrow',
    'Rainfed',
  ];

  @override
  void initState() {
    super.initState();
    final crop = widget.initialCrop;
    if (crop != null) {
      _cropNameController.text = crop.cropName;
      _varietyController.text = crop.variety;
      _areaController.text = crop.areaUnderCultivation.toString();
      _notesController.text = crop.notes ?? '';
      _sowingDate = crop.sowingDate;
      _expectedHarvestDate = crop.expectedHarvestDate;
      _soilType = _safeOption(_soilTypes, crop.soilType, _soilType);
      _irrigationMethod = _safeOption(
        _irrigationMethods,
        crop.irrigationMethod,
        _irrigationMethod,
      );
    }
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _varietyController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _safeOption(List<String> options, String value, String fallback) {
    return options.contains(value) ? value : fallback;
  }

  Future<void> _pickDate({
    required DateTime? initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
    );

    if (!mounted) {
      return;
    }

    if (selected != null) {
      onSelected(selected);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_sowingDate == null || _expectedHarvestDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select sowing and harvest dates')),
      );
      return;
    }

    if (!_expectedHarvestDate!.isAfter(_sowingDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harvest date must be after sowing date')),
      );
      return;
    }

    final now = DateTime.now();
    final existing = widget.initialCrop;
    final baseCrop = CropModel(
      id: existing?.id ?? 'crop_${now.microsecondsSinceEpoch}',
      userId: widget.userId,
      cropName: _cropNameController.text.trim(),
      variety: _varietyController.text.trim(),
      areaUnderCultivation: double.parse(_areaController.text.trim()),
      sowingDate: _sowingDate!,
      expectedHarvestDate: _expectedHarvestDate!,
      soilType: _soilType,
      irrigationMethod: _irrigationMethod,
      currentStage: existing?.currentStage ?? 'Germination',
      cropAgeDays: existing?.cropAgeDays ?? 0,
      status: existing?.status ?? 'active',
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await widget.onSubmit(baseCrop);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _cropNameController,
            decoration: const InputDecoration(
              labelText: 'Crop Name',
              prefixIcon: Icon(Icons.grass_outlined),
            ),
            validator: (value) =>
                Validators.required(value, fieldName: 'Crop name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _varietyController,
            decoration: const InputDecoration(
              labelText: 'Variety',
              prefixIcon: Icon(Icons.spa_outlined),
            ),
            validator: (value) =>
                Validators.required(value, fieldName: 'Variety'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _areaController,
            decoration: const InputDecoration(
              labelText: 'Area Under Cultivation',
              prefixIcon: Icon(Icons.square_foot_outlined),
              suffixText: 'acres',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) =>
                Validators.positiveNumber(value, fieldName: 'Area'),
          ),
          const SizedBox(height: 16),
          _DateTile(
            label: 'Sowing Date',
            date: _sowingDate,
            onTap: () => _pickDate(
              initialDate: _sowingDate,
              onSelected: (date) => setState(() => _sowingDate = date),
            ),
          ),
          const SizedBox(height: 12),
          _DateTile(
            label: 'Expected Harvest Date',
            date: _expectedHarvestDate,
            onTap: () => _pickDate(
              initialDate: _expectedHarvestDate,
              onSelected: (date) => setState(() => _expectedHarvestDate = date),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _soilType,
            decoration: const InputDecoration(
              labelText: 'Soil Type',
              prefixIcon: Icon(Icons.terrain_outlined),
            ),
            items: _soilTypes
                .map(
                  (soil) => DropdownMenuItem(
                    value: soil,
                    child: Text(soil),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                setState(() => _soilType = value);
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _irrigationMethod,
            decoration: const InputDecoration(
              labelText: 'Irrigation Method',
              prefixIcon: Icon(Icons.water_drop_outlined),
            ),
            items: _irrigationMethods
                .map(
                  (method) => DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                setState(() => _irrigationMethod = value);
              }
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.loading ? null : _submit,
            icon: widget.loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = date == null
        ? 'Select date'
        : '${date!.day.toString().padLeft(2, '0')}/'
            '${date!.month.toString().padLeft(2, '0')}/${date!.year}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(text),
      ),
    );
  }
}
