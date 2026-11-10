class ListUtils {
  /// 将 List<dynamic> 安全转换为 List<Map<String, dynamic>>
  static List<Map<String, dynamic>> toMapList(List<dynamic>? rawList) {
    if (rawList == null) return [];
    return rawList.map((item) {
      return item is Map<String, dynamic> ? item : <String, dynamic>{};
    }).toList();
  }
}
/// Map 安全操作工具类
class MapUtils {
  /// 从 Map 中安全获取 String 类型值
  /// [map]：源Map
  /// [key]：要获取的键
  /// [defaultValue]：获取失败时的默认值（默认空字符串）
  static String getString(
    Map<String, dynamic> map,
    String key, {
    String defaultValue = '',
  }) {
    // 1. 检查Map是否包含该key，或key对应值是否为null
    if (!map.containsKey(key) || map[key] == null) {
      return defaultValue;
    }
    // 2. 无论原值是什么类型，都转换为String并去除首尾空格
    return map[key].toString().trim();
  }

  // 配套的其他安全取值方法（补充说明，便于理解）
  /// 安全获取int类型值
  static int getInt(
    Map<String, dynamic> map,
    String key, {
    int defaultValue = 0,
  }) {
    if (!map.containsKey(key) || map[key] == null) {
      return defaultValue;
    }
    return int.tryParse(map[key].toString()) ?? defaultValue;
  }

  /// 安全获取bool类型值
  static bool getBool(
    Map<String, dynamic> map,
    String key, {
    bool defaultValue = false,
  }) {
    if (!map.containsKey(key) || map[key] == null) {
      return defaultValue;
    }
    if (map[key] is bool) {
      return map[key] as bool;
    }
    // 兼容字符串类型的bool（如接口返回"true"/"false"）
    return map[key].toString().toLowerCase() == 'true';
  }
}