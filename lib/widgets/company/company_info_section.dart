import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/models/company.dart';
import 'package:crud_withnodejs/widgets/common/section_card.dart';
import 'package:crud_withnodejs/widgets/company/company_detail_item.dart';

class CompanyInfoSection extends StatelessWidget {
  final Company company;

  const CompanyInfoSection({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Información',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompanyDetailItem(
            icon: Icons.location_on_outlined,
            label: 'Dirección',
            value: company.address ?? 'Sin dirección',
          ),
          const Divider(height: 22, color: AppColors.line),
          CompanyDetailItem(
            icon: Icons.storefront_rounded,
            label: 'Rubro',
            value: company.businessLine ?? 'Sin rubro',
          ),
        ],
      ),
    );
  }
}
