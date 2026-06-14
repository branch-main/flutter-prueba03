import 'package:flutter/material.dart';

import 'package:crud_withnodejs/widgets/company/detail_info_skeleton.dart';
import 'package:crud_withnodejs/widgets/company/detail_summary_skeleton.dart';
import 'package:crud_withnodejs/widgets/employee/detail_employees_skeleton.dart';

class DetailLoading extends StatelessWidget {
  const DetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
      children: const [
        DetailSummarySkeleton(),
        SizedBox(height: 16),
        DetailInfoSkeleton(),
        SizedBox(height: 16),
        DetailEmployeesSkeleton(),
      ],
    );
  }
}
