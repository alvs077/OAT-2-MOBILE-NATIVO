/// Modelo de usuário com suporte a Firebase UID e telefone.
class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? firebaseUid;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.firebaseUid,
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? firebaseUid,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      firebaseUid: firebaseUid ?? this.firebaseUid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'firebaseUid': firebaseUid,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      firebaseUid: map['firebaseUid'],
    );
  }
}