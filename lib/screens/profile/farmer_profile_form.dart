import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../models/auth_user_model.dart';
import '../../models/user_profile_model.dart';
import '../../providers/language_provider.dart';

class FarmerProfileForm extends StatefulWidget {
  const FarmerProfileForm({
    required this.user,
    required this.submitLabel,
    required this.onSubmit,
    this.initialProfile,
    this.loading = false,
    super.key,
  });

  final AuthUserModel user;
  final UserProfileModel? initialProfile;
  final String submitLabel;
  final bool loading;
  final Future<void> Function(UserProfileModel profile) onSubmit;

  @override
  State<FarmerProfileForm> createState() => _FarmerProfileFormState();
}

class _FarmerProfileFormState extends State<FarmerProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _villageController = TextEditingController();
  final _talukaController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _profilePhotoUrlController = TextEditingController();

  String _soilType = 'Loamy';
  String _irrigationMethod = 'Drip';
  String _waterSource = 'Borewell';

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

  static const _waterSources = [
    'Borewell',
    'Canal',
    'River',
    'Pond',
    'Rainwater',
    'Open well',
  ];

  @override
  void initState() {
    super.initState();
    _hydrateFields(widget.initialProfile);
  }

  @override
  void didUpdateWidget(covariant FarmerProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialProfile?.updatedAt !=
        widget.initialProfile?.updatedAt) {
      _hydrateFields(widget.initialProfile);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _villageController.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _farmSizeController.dispose();
    _profilePhotoUrlController.dispose();
    super.dispose();
  }

  void _hydrateFields(UserProfileModel? profile) {
    _nameController.text = profile?.name ?? widget.user.displayName ?? '';
    _mobileController.text =
        profile?.mobileNumber ?? widget.user.phoneNumber ?? '';
    _emailController.text = profile?.email ?? widget.user.email ?? '';
    _villageController.text = profile?.village ?? '';
    _talukaController.text = profile?.taluka ?? '';
    _districtController.text = profile?.district ?? '';
    _stateController.text = profile?.state ?? '';
    _farmSizeController.text = profile == null || profile.farmSize == 0
        ? ''
        : profile.farmSize.toString();
    _profilePhotoUrlController.text =
        profile?.profileImageUrl ?? widget.user.photoUrl ?? '';
    _soilType = _safeOption(_soilTypes, profile?.soilType, _soilType);
    _irrigationMethod = _safeOption(
      _irrigationMethods,
      profile?.irrigationMethod,
      _irrigationMethod,
    );
    _waterSource = _safeOption(
      _waterSources,
      profile?.waterSource,
      _waterSource,
    );
  }

  String _safeOption(List<String> options, String? value, String fallback) {
    if (value != null && options.contains(value)) {
      return value;
    }

    return fallback;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final existing = widget.initialProfile;
    final profile = UserProfileModel(
      id: widget.user.id,
      name: _nameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      email: _emailController.text.trim(),
      village: _villageController.text.trim(),
      taluka: _talukaController.text.trim(),
      district: _districtController.text.trim(),
      state: _stateController.text.trim(),
      farmSize: double.parse(_farmSizeController.text.trim()),
      soilType: _soilType,
      waterSource: _waterSource,
      irrigationMethod: _irrigationMethod,
      preferredLanguage: context.read<LanguageProvider>().language.code,
      profileImageUrl: _profilePhotoUrlController.text.trim().isEmpty
          ? null
          : _profilePhotoUrlController.text.trim(),
      profileCompleted: true,
      farmerCategory: existing?.farmerCategory,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await widget.onSubmit(profile);
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            icon: Icons.person_outline,
            title: strings.farmerDetails,
          ),
          _TextField(
            controller: _nameController,
            label: strings.fullName,
            icon: Icons.badge_outlined,
            validator: (value) =>
                Validators.required(value, fieldName: 'Full name'),
          ),
          _TextField(
            controller: _mobileController,
            label: strings.mobileNumber,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: Validators.mobileNumber,
          ),
          _TextField(
            controller: _emailController,
            label: strings.email,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: Icons.location_on_outlined,
            title: strings.location,
          ),
          _TextField(
            controller: _villageController,
            label: strings.village,
            icon: Icons.home_work_outlined,
            validator: (value) =>
                Validators.required(value, fieldName: 'Village'),
          ),
          _TextField(
            controller: _talukaController,
            label: strings.taluka,
            icon: Icons.map_outlined,
            validator: (value) =>
                Validators.required(value, fieldName: 'Taluka'),
          ),
          _TextField(
            controller: _districtController,
            label: strings.district,
            icon: Icons.location_city_outlined,
            validator: (value) =>
                Validators.required(value, fieldName: 'District'),
          ),
          _TextField(
            controller: _stateController,
            label: strings.state,
            icon: Icons.public_outlined,
            validator: (value) =>
                Validators.required(value, fieldName: 'State'),
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: Icons.agriculture_outlined,
            title: strings.farmProfile,
          ),
          _TextField(
            controller: _farmSizeController,
            label: strings.farmSize,
            icon: Icons.square_foot_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) =>
                Validators.positiveNumber(value, fieldName: 'Farm size'),
          ),
          _DropdownField(
            label: strings.soilType,
            icon: Icons.grass_outlined,
            value: _soilType,
            items: _soilTypes,
            onChanged: (value) => setState(() => _soilType = value),
          ),
          _DropdownField(
            label: strings.irrigationMethod,
            icon: Icons.water_drop_outlined,
            value: _irrigationMethod,
            items: _irrigationMethods,
            onChanged: (value) => setState(() => _irrigationMethod = value),
          ),
          _DropdownField(
            label: strings.waterSource,
            icon: Icons.waves_outlined,
            value: _waterSource,
            items: _waterSources,
            onChanged: (value) => setState(() => _waterSource = value),
          ),
          _TextField(
            controller: _profilePhotoUrlController,
            label: strings.profilePhotoUrl,
            icon: Icons.image_outlined,
            keyboardType: TextInputType.url,
            requiredField: false,
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
            label: Text(strings.saveProfile),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.requiredField = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: validator ??
            (requiredField
                ? (value) => Validators.required(value, fieldName: label)
                : null),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
            .toList(growable: false),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}
