import '../models/tasting_aroma.dart';
import '../models/tasting_palate.dart';
import '../models/tasting_overall.dart';
import '../models/tasting_appearance.dart';

class ScoringHelper {
  // 香气评分 (0-10)
  static double calcAromaScore(TastingAroma a) {
    return (a.intensity + a.complexity + a.purity + a.persistence) / 4.0;
  }

  // 口感评分 (0-10)
  // 酸度和单宁为描述性指标（不计入分数），平衡感已涵盖各要素协调性
  static double calcPalateScore(TastingPalate p) {
    return (p.body + p.balance + p.complexity + p.finishLength) / 4.0;
  }

  // 综合评分 (0-10)
  static double calcOverallScore(TastingOverall o) {
    return (o.typicality + o.enjoyment + o.value + o.agingPotential + o.repurchase) / 5.0;
  }

  // 计算100分制总分
  static int calcTotalScore100(
    double aromaScore,
    double palateScore,
    double overallScore,
    double aromaW,
    double palateW,
    double overallW,
  ) {
    double total = aromaScore * aromaW + palateScore * palateW + overallScore * overallW;
    // 转换为百分制 (0-10 → 0-100)
    double score100 = total * 10.0;
    return score100.round().clamp(0, 100);
  }

  // 生成品鉴笔记
  static String generateNote(
    TastingAppearance a,
    TastingAroma ar,
    List<String> flavors,
    TastingPalate p,
    TastingOverall o,
    int score100,
  ) {
    final StringBuffer note = StringBuffer();

    // 外观描述
    String appearancePart = '外观：';
    if (a.intensity?.isNotEmpty == true) {
      appearancePart += '呈${a.intensity}度';
    }
    if (a.color?.isNotEmpty == true) {
      appearancePart += '${a.color}色';
    }
    if (a.clarity?.isNotEmpty == true) {
      appearancePart += '，${a.clarity}';
    }
    note.writeln(appearancePart);

    // 香气描述
    String aromaPart = '香气：';
    aromaPart += '${describeIntensity(ar.intensity)}';
    if (flavors.isNotEmpty) {
      final mainFlavors = flavors.length > 3 ? flavors.sublist(0, 3) : flavors;
      aromaPart += '，以${mainFlavors.join('、')}为主';
      if (flavors.length > 3) {
        aromaPart += '等';
      }
    }
    note.writeln(aromaPart);

    // 口感描述
    String palatePart = '口感：';
    palatePart += '${describeBody(p.body)}体';
    if (p.acidity > 0) {
      palatePart += '，${describeAcidity(p.acidity)}';
    }
    if (p.tannin > 0) {
      palatePart += '，${describeTannin(p.tannin)}';
    }
    note.writeln('$palatePart，余味${describeFinish(p.finishLength)}。');

    // 整体描述
    String overallPart = '整体：';
    overallPart += '得分$score100/100';
    if (o.enjoyment > 0) {
      overallPart += '，${describeEnjoyment(o.enjoyment)}';
    }
    if (o.agingAdvice != null && o.agingAdvice!.isNotEmpty) {
      overallPart += '，${describeAgingInt(int.tryParse(o.agingAdvice!) ?? 0)}';
    }
    note.write(overallPart);

    return note.toString();
  }

  // ---------- 描述映射 ----------

  static const Map<String, String> _intensityMap = {
    '0': '无明显香气',
    '1': '香气微弱',
    '2': '香气较弱',
    '3': '香气中等偏弱',
    '4': '香气中等',
    '5': '香气中等偏强',
    '6': '香气较强',
    '7': '香气浓郁',
    '8': '香气非常浓郁',
    '9': '香气极其浓郁',
    '10': '香气爆炸性浓郁',
  };

  static const Map<String, String> _bodyMap = {
    '0': '酒体轻盈',
    '1': '酒体偏轻',
    '2': '酒体轻-中等之间',
    '3': '酒体中偏轻',
    '4': '酒体中等',
    '5': '酒体中偏饱满',
    '6': '酒体饱满偏中',
    '7': '酒体饱满',
    '8': '酒体非常饱满',
    '9': '酒体极其饱满',
    '10': '酒体厚重',
  };

  static const Map<String, String> _acidityMap = {
    '0': '酸度很低',
    '1': '酸度低',
    '2': '酸度偏低',
    '3': '酸度中低',
    '4': '酸度中等',
    '5': '酸度中高',
    '6': '酸度较高',
    '7': '酸度高',
    '8': '酸度很高',
    '9': '酸度极高',
    '10': '酸度尖锐',
  };

  static const Map<String, String> _tanninMap = {
    '0': '单宁很低',
    '1': '单宁低',
    '2': '单宁偏低',
    '3': '单宁中低',
    '4': '单宁中等',
    '5': '单宁中高',
    '6': '单宁较高',
    '7': '单宁高',
    '8': '单宁很高',
    '9': '单宁极高',
    '10': '单宁厚重',
  };

  static const Map<String, String> _finishMap = {
    '0': '很短',
    '1': '短',
    '2': '偏短',
    '3': '中短',
    '4': '中等',
    '5': '中长',
    '6': '较长',
    '7': '长',
    '8': '很长',
    '9': '极长',
    '10': '持久不散',
  };

  static const Map<String, String> _enjoymentMap = {
    '0': '非常不喜欢',
    '1': '很不喜欢',
    '2': '不喜欢',
    '3': '不太喜欢',
    '4': '一般',
    '5': '还算喜欢',
    '6': '喜欢',
    '7': '很喜欢',
    '8': '非常喜欢',
    '9': '极其喜欢',
    '10': '完美享受',
  };

  static const Map<String, String> _agingMap = {
    '0': '无需陈年',
    '1': '现在饮用即可',
    '2': '可短暫陳年',
    '3': '建议陈年1-2年',
    '4': '建议陈年2-3年',
    '5': '建议陈年3-5年',
    '6': '建议陈年5-8年',
    '7': '建议陈年8-12年',
    '8': '建议陈年12-15年',
    '9': '建议长期陈年',
    '10': '极具陈年潜力',
  };

  static String describeIntensity(int score) {
    return _intensityMap[score.toString()] ?? '香气中等';
  }

  static String describeBody(int score) {
    return _bodyMap[score.toString()] ?? '酒体中等';
  }

  static String describeAcidity(int score) {
    return _acidityMap[score.toString()] ?? '酸度中等';
  }

  static String describeTannin(int score) {
    return _tanninMap[score.toString()] ?? '单宁中等';
  }

  static String describeFinish(int score) {
    return _finishMap[score.toString()] ?? '余味中等';
  }

  static String describeEnjoyment(int score) {
    return _enjoymentMap[score.toString()] ?? '喜欢';
  }

  static String describeAging(int score) {
    return _agingMap[score.toString()] ?? '建议陈年';
  }

  static String describeAgingInt(int score) {
    return _agingMap[score.toString()] ?? '建议陈年';
  }
}
