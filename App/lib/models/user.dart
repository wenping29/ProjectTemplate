class User {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? phone;
  final String roleId;

  const User({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.phone,
    required this.roleId,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'],
        username: j['username'],
        displayName: j['displayName'],
        avatarUrl: j['avatarUrl'],
        phone: j['phone'],
        roleId: j['roleId'],
      );

  User copyWith({String? displayName, String? avatarUrl, String? phone}) => User(
        id: id,
        username: username,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        phone: phone ?? this.phone,
        roleId: roleId,
      );
}
