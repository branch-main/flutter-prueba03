import 'package:crud_withnodejs/models/company.dart';
import 'package:crud_withnodejs/providers/company_provider.dart';
import 'package:crud_withnodejs/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _businessLineController = TextEditingController();
  Company? _company;
  bool _loadedArguments = false;

  bool get _isEditing => _company?.id != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadedArguments) return;

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Company) {
      _company = arguments;
      _nameController.text = arguments.name;
      _taxIdController.text = arguments.taxId;
      _addressController.text = arguments.address ?? '';
      _businessLineController.text = arguments.businessLine ?? '';
    }

    _loadedArguments = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxIdController.dispose();
    _addressController.dispose();
    _businessLineController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final company = Company(
      name: _nameController.text.trim(),
      taxId: _taxIdController.text.trim(),
      address: _optionalText(_addressController.text),
      businessLine: _optionalText(_businessLineController.text),
    );

    final companyProvider = context.read<CompanyProvider>();
    final success = _isEditing
        ? await companyProvider.update(_company!.id!, company)
        : await companyProvider.add(company);

    if (!mounted) return;

    if (!success) {
      _showError(companyProvider.errorMessage ?? 'No se pudo guardar.');
      return;
    }

    Navigator.pop(context, true);
  }

  String? _optionalText(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar empresa' : 'Nueva empresa'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _IntroCard(isEditing: _isEditing, companyName: _company?.name),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.line),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FieldLabel('Nombre'),
                  _InputField(
                    controller: _nameController,
                    hint: 'Ej. Nova Comercial SAC',
                    icon: Icons.apartment_rounded,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'El nombre es obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('RUC'),
                  _InputField(
                    controller: _taxIdController,
                    hint: 'Número de RUC',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'El RUC es obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Dirección'),
                  _InputField(
                    controller: _addressController,
                    hint: 'Dirección fiscal o sede principal',
                    icon: Icons.location_on_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Rubro'),
                  _InputField(
                    controller: _businessLineController,
                    hint: 'Ej. Tecnología, retail, servicios',
                    icon: Icons.storefront_rounded,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: companyProvider.isLoading ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: AppColors.blue,
              ),
              icon: companyProvider.isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(_isEditing ? 'Guardar cambios' : 'Crear empresa'),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final bool isEditing;
  final String? companyName;

  const _IntroCard({required this.isEditing, required this.companyName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isEditing ? Icons.edit_rounded : Icons.add_business_rounded,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Actualiza la ficha' : 'Ficha empresarial',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 5),
                Text(
                  isEditing
                      ? 'Ajusta los datos de ${companyName ?? 'la empresa'}.'
                      : 'Guarda los datos principales de la empresa.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
      validator: validator,
    );
  }
}
