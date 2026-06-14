import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/models/employee.dart';
import 'package:crud_withnodejs/widgets/employee/employee_meta.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasInlineDetails =
        employee.documentNumber != null || employee.email != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.blue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      employee.position ?? 'Sin cargo asignado',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opciones de empleado',
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ],
          ),
          if (hasInlineDetails) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 10,
              children: [
                if (employee.documentNumber != null)
                  EmployeeMeta(
                    icon: Icons.badge_outlined,
                    label: employee.documentNumber!,
                  ),
                if (employee.email != null)
                  EmployeeMeta(
                    icon: Icons.alternate_email_rounded,
                    label: employee.email!,
                  ),
              ],
            ),
          ],
          if (employee.phone != null) ...[
            SizedBox(height: hasInlineDetails ? 10 : 12),
            EmployeeMeta(icon: Icons.phone_outlined, label: employee.phone!),
          ],
        ],
      ),
    );
  }
}
