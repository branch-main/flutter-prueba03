class Employee {
  final int? id;
  final int? companyId;
  final String fullName;
  final String? documentNumber;
  final String? position;
  final String? email;
  final String? phone;
  final bool isActive;

  Employee({
    this.id,
    this.companyId,
    required this.fullName,
    this.documentNumber,
    this.position,
    this.email,
    this.phone,
    this.isActive = true,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id'],
    companyId: json['companyId'],
    fullName: json['fullName'],
    documentNumber: json['documentNumber'],
    position: json['position'],
    email: json['email'],
    phone: json['phone'],
    isActive: json['isActive'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'documentNumber': documentNumber,
    'position': position,
    'email': email,
    'phone': phone,
    'isActive': isActive,
  };
}
