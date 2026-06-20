import 'package:flutter/material.dart';

class WineTypeHelper {
  static String getLabel(String type) {
    switch (type) {
      case 'red':
        return '红葡萄酒';
      case 'white':
        return '白葡萄酒';
      case 'rose':
        return '桃红葡萄酒';
      case 'sparkling':
        return '起泡酒';
      case 'sweet':
        return '甜酒';
      default:
        return type;
    }
  }

  static Color getColor(String type) {
    switch (type) {
      case 'red':
        return const Color(0xFF722F37);
      case 'white':
        return const Color(0xFFE8D5A3);
      case 'rose':
        return const Color(0xFFF4A6A6);
      case 'sparkling':
        return const Color(0xFFD4A853);
      case 'sweet':
        return const Color(0xFFD4956A);
      default:
        return Colors.grey;
    }
  }

  static IconData getIcon(String type) {
    switch (type) {
      case 'red':
        return Icons.wine_bar;
      case 'white':
        return Icons.wine_bar;
      case 'rose':
        return Icons.wine_bar;
      case 'sparkling':
        return Icons.wine_bar;
      case 'sweet':
        return Icons.wine_bar;
      default:
        return Icons.wine_bar;
    }
  }

  static List<String> getColorsForType(String type) {
    switch (type) {
      case 'red':
        return ['紫红色', '宝石红', '石榴红', '砖红色', '琥珀色', '深紫红', '浅宝石红'];
      case 'white':
        return ['青黄色', '柠檬黄', '浅黄色', '金黄色', '琥珀色', '稻草黄', '深金黄色'];
      case 'rose':
        return ['淡粉色', '三文鱼色', '玫瑰粉', '桃红色', '胭脂红', '橘粉色'];
      case 'sparkling':
        return ['青黄色', '浅柠檬黄', '金黄色', '淡粉色', '三文鱼色'];
      case 'sweet':
        return ['浅金黄色', '金黄色', '深金黄色', '琥珀色', '古铜色', '深褐色'];
      default:
        return ['浅色', '中等', '深色'];
    }
  }

  static List<String> getClarityOptions() {
    return ['清澈透亮', '清澈', '微浑', '浑浊', '极浑浊'];
  }

  static List<String> getIntensityOptions() {
    return ['浅', '中等偏浅', '中等', '中等偏深', '深'];
  }

  static List<String> getConditionOptions() {
    return ['健康', '轻微缺陷', '有缺陷', '严重缺陷'];
  }

  static List<String> getDevelopmentOptions() {
    return ['年轻 (Youthful)', '发展中 (Developing)', '成熟 (Mature)', '过熟/衰退 (Tired)'];
  }

  static List<String> getTanninTextureOptions() {
    return ['细腻丝滑', '柔顺', '中等', '粗糙', '生涩', '紧实', '柔和'];
  }

  static List<String> getFinishCharacterOptions() {
    return ['干净', '清爽', '温暖', '辛辣', '甜美', '苦涩', '持久', '矿物感'];
  }

  static List<String> getAgingAdviceOptions() {
    return ['现在饮用', '可陈年1-2年', '可陈年3-5年', '可陈年5-10年', '可陈年10年以上', '不宜久存'];
  }

  static List<String> getTearsOptions() {
    return ['无挂杯', '稀疏挂杯', '中等挂杯', '密集挂杯', '厚重挂杯'];
  }

  static List<String> getBubbleFinenessOptions() {
    return ['非常细腻', '细腻', '中等', '粗糙', '大泡'];
  }

  static List<String> getBubblePersistenceOptions() {
    return ['短暂', '较短', '中等', '持久', '非常持久'];
  }
}
