const Map<String, List<String>> roleCreatePermissions = {
  'owner': [
    'owner',
    'all_access',
    'developer',
    'tk',
    'pt',
    'moderator',
    'reseller',
    'vip',
    'member',
  ],
  'developer': [
    'owner',
    'all_access',
    'developer',
    'tk',
    'pt',
    'moderator',
    'reseller',
    'vip',
    'member',
  ],
  'all_access': ['owner', 'tk', 'pt', 'moderator', 'reseller', 'vip', 'member'],
  'tk': ['pt', 'moderator', 'reseller', 'vip', 'member'],
  'moderator': ['pt', 'reseller', 'vip', 'member'],
  'pt': ['reseller', 'vip', 'member'],
  'reseller': ['member'],
  'vip': ['member'],
  'member': [],
};

String normalizeRole(String role) {
  return role.trim().toLowerCase().replaceAll(' ', '_');
}

List<String> getCreatableRoles(String role) {
  final normalizedRole = normalizeRole(role);
  return List<String>.from(roleCreatePermissions[normalizedRole] ?? const []);
}

bool canOpenAccountManager(String role) {
  return getCreatableRoles(role).isNotEmpty;
}

bool canOpenSellerPanel(String role) {
  return normalizeRole(role) == 'reseller';
}

bool canOpenOwnerPanel(String role) {
  return normalizeRole(role) == 'owner';
}

bool canDeleteUsers(String role) {
  final normalizedRole = normalizeRole(role);
  return normalizedRole == 'owner' || normalizedRole == 'developer';
}
