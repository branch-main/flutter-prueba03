import 'package:flutter/material.dart';

import 'package:crud_withnodejs/utils/validators.dart';
import 'package:crud_withnodejs/widgets/app_field_label.dart';
import 'package:crud_withnodejs/widgets/app_text_form_field.dart';

class CompanyFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController taxIdController;
  final TextEditingController addressController;
  final TextEditingController businessLineController;
  final VoidCallback onSubmitted;

  const CompanyFormFields({
    super.key,
    required this.nameController,
    required this.taxIdController,
    required this.addressController,
    required this.businessLineController,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFieldLabel('Nombre'),
        AppTextFormField(
          controller: nameController,
          hint: 'Ej. Nova Comercial SAC',
          icon: Icons.apartment_rounded,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              requiredTextValidator(value, 'El nombre es obligatorio.'),
        ),
        const SizedBox(height: 16),
        AppFieldLabel('RUC'),
        AppTextFormField(
          controller: taxIdController,
          hint: 'Número de RUC',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              requiredTextValidator(value, 'El RUC es obligatorio.'),
        ),
        const SizedBox(height: 16),
        AppFieldLabel('Dirección'),
        AppTextFormField(
          controller: addressController,
          hint: 'Dirección fiscal o sede principal',
          icon: Icons.location_on_outlined,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        AppFieldLabel('Rubro'),
        AppTextFormField(
          controller: businessLineController,
          hint: 'Ej. Tecnología, retail, servicios',
          icon: Icons.storefront_rounded,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmitted(),
        ),
      ],
    );
  }
}
