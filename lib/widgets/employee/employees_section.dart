import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/models/employee.dart';
import 'package:crud_withnodejs/widgets/common/section_card.dart';
import 'package:crud_withnodejs/widgets/employee/employee_card.dart';
import 'package:crud_withnodejs/widgets/employee/empty_employees.dart';

class EmployeesSection extends StatelessWidget {
  final List<Employee> employees;
  final ValueChanged<Employee> onEdit;
  final ValueChanged<Employee> onDelete;

  const EmployeesSection({
    super.key,
    required this.employees,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Equipo (${employees.length})',
      child: employees.isEmpty
          ? const EmptyEmployees()
          : Column(
              children: [
                for (final entry in employees.indexed) ...[
                  EmployeeCard(
                    employee: entry.$2,
                    onEdit: () => onEdit(entry.$2),
                    onDelete: () => onDelete(entry.$2),
                  ),
                  if (entry.$1 != employees.length - 1)
                    const Divider(height: 26, color: AppColors.line),
                ],
              ],
            ),
    );
  }
}
