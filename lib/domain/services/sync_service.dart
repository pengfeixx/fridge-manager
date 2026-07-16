/// 多设备同步服务抽象接口——预留，不实现。
///
/// 未来接入后端时，实现此接口并通过 Riverpod provider 替换。
/// 现阶段所有方法抛 [UnimplementedError]。
abstract class SyncService {
  /// 是否已登录。
  bool get isLoggedIn => false;

  /// 登录（预留）。
  Future<void> login(String username, String password) {
    throw UnimplementedError('云端同步尚未上线');
  }

  /// 推送本地变更到云端（预留）。
  Future<void> push() {
    throw UnimplementedError('云端同步尚未上线');
  }

  /// 从云端拉取数据（预留）。
  Future<void> pull() {
    throw UnimplementedError('云端同步尚未上线');
  }

  /// 登出（预留）。
  Future<void> logout() {
    throw UnimplementedError('云端同步尚未上线');
  }
}
