import 'package:flutter/material.dart';

import 'package:crud_withnodejs/models/company.dart';
import 'package:crud_withnodejs/utils/string_utils.dart';

class CompanyFormController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final taxIdController = TextEditingController();
  final addressController = TextEditingController();
  final businessLineController = TextEditingController();
  Company? company;
  bool _loadedArguments = false;

  bool get isEditing => company?.id != null;

  void loadArguments(Object? arguments) {
    if (_loadedArguments) return;

    if (arguments is Company) {
      company = arguments;
      nameController.text = arguments.name;
      taxIdController.text = arguments.taxId;
      addressController.text = arguments.address ?? '';
      businessLineController.text = arguments.businessLine ?? '';
    }

    _loadedArguments = true;
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  Company toCompany() {
    return Company(
      id: company?.id,
      name: nameController.text.trim(),
      taxId: taxIdController.text.trim(),
      address: optionalText(addressController.text),
      businessLine: optionalText(businessLineController.text),
      isActive: company?.isActive ?? true,
    );
  }

  void dispose() {
    nameController.dispose();
    taxIdController.dispose();
    addressController.dispose();
    businessLineController.dispose();
  }
}
