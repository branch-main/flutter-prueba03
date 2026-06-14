import 'package:flutter/material.dart';

import 'package:crud_withnodejs/widgets/company/company_card_skeleton.dart';

class CompanyListLoading extends StatelessWidget {
  const CompanyListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CompanyCardSkeleton(),
        SizedBox(height: 14),
        CompanyCardSkeleton(),
        SizedBox(height: 14),
        CompanyCardSkeleton(),
        SizedBox(height: 14),
        CompanyCardSkeleton(),
        SizedBox(height: 14),
        CompanyCardSkeleton(),
      ],
    );
  }
}
