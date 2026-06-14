import 'package:crud_withnodejs/models/employee.dart';

class Company {
  final int? id;
  final String name;
  final String taxId;
  final String? address;
  final String? businessLine;
  final bool isActive;
  final List<Employee> employees;

  Company({
    this.id,
    required this.name,
    required this.taxId,
    this.address,
    this.businessLine,
    this.isActive = true,
    this.employees = const [],
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    final employeesJson = json['employees'];

    return Company(
      id: json['id'],
      name: json['name'],
      taxId: json['taxId'],
      address: json['address'],
      businessLine: json['businessLine'],
      isActive: json['isActive'] ?? true,
      employees: employeesJson is List
          ? employeesJson
                .map(
                  (employee) =>
                      Employee.fromJson(Map<String, dynamic>.from(employee)),
                )
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'taxId': taxId,
    'address': address,
    'businessLine': businessLine,
    'isActive': isActive,
  };
}
