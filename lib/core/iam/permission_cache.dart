import 'package:athar/core/iam/models/role_enums.dart';
import 'package:injectable/injectable.dart';

@singleton
class PermissionCache {
  // تخزين الدور: { spaceId : SpaceRole }
  final Map<String, SpaceRole> _roleCache = {};

  void setRole(String spaceId, SpaceRole role) {
    _roleCache[spaceId] = role;
  }

  SpaceRole? getRole(String spaceId) {
    return _roleCache[spaceId];
  }

  void invalidate(String? spaceId) {
    if (spaceId == null) {
      _roleCache.clear();
    } else {
      _roleCache.remove(spaceId);
    }
  }

  bool hasKey(String spaceId) => _roleCache.containsKey(spaceId);
}
