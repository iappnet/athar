import 'package:athar/core/iam/models/role_enums.dart';
import 'package:athar/core/iam/permission_cache.dart';
import 'package:athar/core/iam/role_service.dart';
import 'package:athar/features/space/data/models/delegation_mode.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/space/data/models/module_permission_model.dart';
import 'package:athar/features/space/data/models/space_member_model.dart';
import 'package:athar/features/space/data/models/space_model.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class PermissionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final RoleService _roleService;
  final PermissionCache _cache; // ✅ حقن الكاش

  PermissionService(this._roleService, this._cache); // ✅ تحديث الكونستركتور

  String? get currentUserId => _supabase.auth.currentUser?.id;

  // ================================================================
  // 1. نظام الصلاحيات العام (نظام ديناميكي - Async)
  // ================================================================

  Future<bool> hasPermission(
    String action, {
    String? spaceId,
    String? resourceType,
    ModuleModel? module,
    bool allowSpaceDelegation = false,
    String? resourceOwnerId,
  }) async {
    // 1. الموارد الشخصية مسموحة دائماً
    if (spaceId == null) return true;

    // 2. جلب الدور الحقيقي من الكاش عبر المحرك الجديد
    // final role = await _roleService.getCurrentUserRole(spaceId);

    // ⚡ الخطوة الذكية: التحقق من الكاش أولاً
    SpaceRole role;
    if (_cache.hasKey(spaceId)) {
      role = _cache.getRole(spaceId)!;
    } else {
      role = await _roleService.getCurrentUserRole(spaceId);
      _cache.setRole(spaceId, role); // تخزين في الكاش للاستخدام القادم
    }

    // 3. المالك والمدير (God Mode)
    if (role == SpaceRole.owner || role == SpaceRole.admin) return true;

    // 4. منطق الأعضاء (Members)
    if (role == SpaceRole.member) {
      return _checkMemberLogic(
        action: action,
        resourceType: resourceType,
        module: module,
        allowSpaceDelegation: allowSpaceDelegation,
        resourceOwnerId: resourceOwnerId,
      );
    }

    return false;
  }

  // ✅ استعادة كافة الدوال المساعدة (Converted to Future)
  Future<bool> canCreate(
    String resource, {
    String? spaceId,
    ModuleModel? module,
    bool allowSpaceDelegation = false,
    String? resourceOwnerId,
  }) => hasPermission(
    'create',
    spaceId: spaceId,
    resourceType: resource,
    module: module,
    allowSpaceDelegation: allowSpaceDelegation,
    resourceOwnerId: resourceOwnerId,
  );

  Future<bool> canEdit(
    String resource, {
    String? spaceId,
    ModuleModel? module,
    bool allowSpaceDelegation = false,
    String? resourceOwnerId,
  }) => hasPermission(
    'update_core',
    spaceId: spaceId,
    resourceType: resource,
    module: module,
    allowSpaceDelegation: allowSpaceDelegation,
    resourceOwnerId: resourceOwnerId,
  );

  Future<bool> canDelete(
    String resource, {
    String? spaceId,
    ModuleModel? module,
    bool allowSpaceDelegation = false,
    String? resourceOwnerId,
  }) => hasPermission(
    'delete',
    spaceId: spaceId,
    resourceType: resource,
    module: module,
    allowSpaceDelegation: allowSpaceDelegation,
    resourceOwnerId: resourceOwnerId,
  );

  // ═══════════════════════════════════════════════════════════
  // ⚙️ منطق الأعضاء التفصيلي (Internal Logic)
  // ═══════════════════════════════════════════════════════════

  bool _checkMemberLogic({
    required String action,
    String? resourceType,
    ModuleModel? module,
    required bool allowSpaceDelegation,
    String? resourceOwnerId,
  }) {
    // منطق الأصول
    if (resourceType == 'asset') {
      if (action == 'read' ||
          action == 'create_log' ||
          action == 'add_attachment') {
        return true;
      }
      return _evaluateDelegation(module, allowSpaceDelegation);
    }

    // منطق الصحة (العمليات البسيطة مسموحة للجميع)
    if (resourceType == 'health_op') return true;

    // منطق الصحة الجوهري (قاعدة الملكية)
    if (resourceType == 'health_core') {
      if (action == 'read') return true;
      if (resourceOwnerId != null && resourceOwnerId == currentUserId) {
        return true;
      }
      return _evaluateDelegation(module, allowSpaceDelegation);
    }

    // منطق القوائم
    if (resourceType == 'list_item_op') return true;
    if (resourceType == 'list_core') {
      if (resourceOwnerId != null && resourceOwnerId == currentUserId) {
        return true;
      }
      return _evaluateDelegation(module, allowSpaceDelegation);
    }

    return false;
  }

  // دالة لتحديث الكاش لمساحة معينة فور تغيير الرتبة
  void refreshPermissions(String spaceId) {
    _cache.invalidate(spaceId);
  }

  // تحسين canEditTask لمنع تغيير رتبة المالك (Owner)
  bool canChangeRole({
    required String targetMemberRole,
    required bool isCurrentUserOwner,
  }) {
    // سيناريو "تضارب الأدوار": لا يمكن لأحد (حتى المدير) تخفيض رتبة المالك
    if (targetMemberRole == 'owner') return false;
    return isCurrentUserOwner;
  }

  bool _evaluateDelegation(ModuleModel? module, bool allowSpaceDelegation) {
    if (module != null) {
      switch (module.delegationMode) {
        case DelegationMode.enabled:
          return true;
        case DelegationMode.disabled:
          return false;
        case DelegationMode.inherit:
          return allowSpaceDelegation;
      }
    }
    return allowSpaceDelegation;
  }

  // ================================================================
  // 2. صلاحيات المساحة (Space Level)
  // ================================================================

  /// هل أنا مالك أو مدير المساحة؟
  bool isSpaceAdmin(SpaceModel space, SpaceMemberModel? myMemberRecord) {
    if (currentUserId == null) return false;
    if (space.ownerId == currentUserId) return true;
    if (myMemberRecord == null) return false;
    final role = SpaceRole.fromString(myMemberRecord.role);
    return role == SpaceRole.owner || role == SpaceRole.admin;
  }

  // ================================================================
  // 3. صلاحيات الموديول (Module Level)
  // ================================================================

  /// هل أنا مدير الموديول؟
  bool isModuleAdmin(ModuleModel module, ModulePermissionModel? myModulePerm) {
    if (currentUserId == null) return false;
    if (module.creatorId == currentUserId) return true;
    if (myModulePerm == null) return false;
    return ModuleRole.fromString(myModulePerm.role) == ModuleRole.admin;
  }

  /// هل يمكنني رؤية الموديول؟
  bool canViewModule(
    ModuleModel module,
    SpaceMemberModel? spaceMember,
    ModulePermissionModel? modulePerm,
  ) {
    if (spaceMember == null) return false;
    if (module.visibility == 'public') return true;
    if (isSpaceAdmin(SpaceModel()..ownerId = 'temp', spaceMember)) {
      return true;
    }
    return modulePerm != null;
  }

  // ================================================================
  // 4. صلاحيات المهام (Task Level)
  // ================================================================

  /// 1. هل يمكنني رؤية المهمة؟
  bool canViewTask({
    required TaskModel task,
    required bool isSpaceAdmin,
    required bool isModuleAdmin,
  }) {
    if (currentUserId == null) return false;
    if (task.spaceId == null) {
      return task.userId == currentUserId;
    }
    if (isSpaceAdmin || isModuleAdmin) return true;
    if (task.userId == currentUserId) return true;
    if (task.assigneeId == currentUserId) return true;
    if (task.visibility == 'public') return true;
    return false;
  }

  /// 2. هل يمكنني تعديل المحتوى أو الإنجاز؟
  bool canEditTask({
    required TaskModel task,
    required bool isSpaceAdmin,
    required bool isModuleAdmin,
  }) {
    if (currentUserId == null) return false;
    if (task.spaceId == null) return task.userId == currentUserId;
    if (isSpaceAdmin || isModuleAdmin) return true;
    if (task.userId == currentUserId) return true;
    if (task.assigneeId == currentUserId) return true;
    return false;
  }

  /// 3. هل يمكنني حذف المهمة؟
  bool canDeleteTask({
    required TaskModel task,
    required bool isSpaceAdmin,
    required bool isModuleAdmin,
  }) {
    if (currentUserId == null) return false;
    if (task.spaceId == null) return task.userId == currentUserId;
    if (isSpaceAdmin || isModuleAdmin) return true;
    if (task.userId == currentUserId) return true;
    // ❌ المسند إليه لا يحذف
    return false;
  }

  /// 4. ✅ دالة التحقق من صلاحية الإسناد (Delegation)
  bool canAssignTask({
    required TaskModel task,
    required SpaceModel space,
    required ModuleModel? module,
    required bool isSpaceAdmin,
    required bool isModuleAdmin,
  }) {
    if (currentUserId == null) return false;
    if (isSpaceAdmin || isModuleAdmin) return true;
    if (task.userId == currentUserId) return true;
    if (task.assigneeId == currentUserId && !task.isReassignable) return false;

    bool isAllowed;
    if (module != null) {
      switch (module.delegationMode) {
        case DelegationMode.enabled:
          isAllowed = true;
          break;
        case DelegationMode.disabled:
          isAllowed = false;
          break;
        case DelegationMode.inherit:
          isAllowed = space.allowMemberDelegation;
          break;
      }
    } else {
      isAllowed = space.allowMemberDelegation;
    }
    return isAllowed;
  }

  // دالة لتنظيف الكاش عند تغيير المساحة أو تسجيل الخروج
  void clearPermissionsCache() => _cache.invalidate(null);
}
