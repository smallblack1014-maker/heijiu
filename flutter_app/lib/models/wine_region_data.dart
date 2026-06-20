/// 《世界葡萄酒地图》标准数据
/// 包含国家、产区、葡萄品种、名庄及经典混酿

class WineRegionData {
  /// 国家列表
  static const List<String> countries = [
    '法国', '意大利', '西班牙', '葡萄牙',
    '德国', '奥地利', '瑞士',
    '美国', '加拿大',
    '澳大利亚', '新西兰',
    '智利', '阿根廷', '乌拉圭',
    '南非', '纳米比亚',
    '中国', '日本', '印度',
    '希腊', '匈牙利', '罗马尼亚', '克罗地亚', '斯洛文尼亚', '保加利亚',
    '格鲁吉亚', '土耳其', '黎巴嫩', '以色列',
    '英格兰', '摩尔多瓦',
  ];

  /// 国家 → 产区映射
  static const Map<String, List<String>> countryRegions = {
    '法国': [
      '波尔多', '勃艮第', '香槟', '罗讷河谷', '阿尔萨斯',
      '卢瓦尔河谷', '普罗旺斯', '朗格多克-鲁西荣', '西南产区',
      '汝拉/萨瓦', '科西嘉', '博若莱',
    ],
    '意大利': [
      '托斯卡纳', '皮埃蒙特', '威尼托', '伦巴第', '艾米利亚-罗马涅',
      '西西里', '普利亚', '坎帕尼亚', '阿布鲁佐', '弗留利-威尼斯朱利亚',
      '特伦蒂诺-上阿迪杰', '马尔凯', '拉齐奥', '撒丁岛', '巴斯利卡塔',
    ],
    '西班牙': [
      '里奥哈', '里贝拉·杜埃罗', '普里奥拉托', '下海湾', '加泰罗尼亚',
      '安达卢西亚', '卢埃达', '杜埃罗河岸', '赫雷斯', '托罗',
      '纳瓦拉', '比埃尔索', '卡斯蒂利亚-拉曼恰', '佩内德斯', '蒙桑特',
    ],
    '葡萄牙': [
      '杜罗河谷', '阿连特茹', '绿酒产区', '马德拉', '塞图巴尔半岛',
      '百拉达', '里斯本', '阿尔加维', '达奥', '波特酒产区',
    ],
    '德国': [
      '摩泽尔', '莱茵高', '法尔兹', '巴登', '弗兰肯',
      '莱茵黑森', '那赫', '阿尔',
    ],
    '奥地利': ['瓦豪河谷', '布尔根兰', '坎普塔尔', '施泰尔马克', '维也纳'],
    '瑞士': ['瓦莱州', '沃州', '日内瓦'],
    '美国': [
      '纳帕谷', '索诺玛', '中央海岸', '俄罗斯河谷', '帕索罗布尔斯',
      '威拉米特谷', '哥伦比亚谷', '手指湖', '圣巴巴拉', '洛斯卡内罗斯',
      '利弗莫尔谷',
    ],
    '加拿大': [
      '尼亚加拉半岛', '奥肯那根谷', '魁北克', '诺瓦斯科舍',
    ],
    '澳大利亚': [
      '巴罗莎谷', '克莱尔谷', '雅拉谷', '猎人谷', '库拉瓦拉',
      '玛格丽特河', '麦克拉伦谷', '塔斯马尼亚', '阿德莱德山',
      '伊顿谷', '莫宁顿半岛',
    ],
    '新西兰': [
      '马尔堡', '中奥塔哥', '霍克斯湾', '马丁堡', '尼尔森',
      '坎特伯雷', '怀拉拉帕', '吉斯本',
    ],
    '智利': [
      '迈坡谷', '科尔查瓜谷', '卡萨布兰卡谷', '莫莱谷', '拉佩尔谷',
      '库里克谷', '比奥比奥谷', '圣安东尼奥谷', '利马里谷', '埃尔基谷',
    ],
    '阿根廷': [
      '门多萨', '萨尔塔', '巴塔哥尼亚', '圣胡安', '拉里奥哈',
      '乌科谷',
    ],
    '乌拉圭': ['卡内洛内斯', '马尔多纳多', '科洛尼亚'],
    '南非': [
      '斯特兰德', '弗朗斯胡克', '黑地', '康斯坦提亚', '沃克湾',
      '埃尔金', '罗伯森', '达尔令',
    ],
    '纳米比亚': ['涅拉斯'],
    '中国': [
      '宁夏贺兰山', '新疆', '山东烟台', '河北怀来', '云南香格里拉',
      '陕西', '甘肃', '北京房山', '山西',
    ],
    '日本': [
      '山梨县', '长野县', '北海道', '新潟县', '大阪',
      '山形县', '岩手县',
    ],
    '印度': ['纳西克', '卡纳塔克邦', '喜马偕尔邦'],
    '希腊': [
      '圣托里尼', '纳乌萨', '尼米亚', '阿提卡', '克里特岛',
      '曼提尼亚', '佩洛庞尼斯半岛',
    ],
    '匈牙利': ['托卡伊', '埃格尔', '维拉尼', '塞克萨德', '巴拉顿湖'],
    '罗马尼亚': ['摩尔多瓦', '德鲁马鲁', '穆法特拉', '科特纳里'],
    '克罗地亚': ['伊斯特拉', '达尔马提亚', '萨格勒布周边'],
    '斯洛文尼亚': ['普里莫尔斯卡', '波萨维耶', '波德拉维耶'],
    '保加利亚': ['多瑙河平原', '色雷斯谷', '斯特鲁马河'],
    '格鲁吉亚': ['卡赫季', '伊美列季', '拉查-列其胡米', '卡特利'],
    '土耳其': [
      '卡帕多西亚', '色雷斯', '爱琴海地区', '安纳托利亚东南',
    ],
    '黎巴嫩': ['贝卡山谷', '巴特龙'],
    '以色列': ['戈兰高地', '加利利', '萨姆松', '耶路撒冷山区'],
    '英格兰': ['萨塞克斯', '肯特', '汉普郡', '康沃尔', '东安格利亚'],
    '摩尔多瓦': ['克里科瓦', '普鲁特河', '德涅斯特河'],
  };

  /// 经典葡萄品种（按类别分组）
  static const Map<String, List<String>> grapeCategories = {
    '国际红葡萄': [
      '赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)', '黑皮诺 (Pinot Noir)',
      '西拉/西拉子 (Syrah/Shiraz)', '品丽珠 (Cabernet Franc)', '马尔贝克 (Malbec)',
      '小维多 (Petit Verdot)', '佳美娜 (Carmenère)', '慕合怀特 (Mourvèdre)',
      '歌海娜 (Grenache/Garnacha)', '内比奥罗 (Nebbiolo)', '桑娇维塞 (Sangiovese)',
      '丹魄 (Tempranillo)', '仙粉黛 (Zinfandel)', '佳美 (Gamay)',
      '巴贝拉 (Barbera)', '多姿桃 (Dolcetto)', '科维纳 (Corvina)',
      '艾格尼科 (Aglianico)', '蒙特普齐亚诺 (Montepulciano)', '黑达沃拉 (Nero d\'Avola)',
    ],
    '国际白葡萄': [
      '霞多丽 (Chardonnay)', '雷司令 (Riesling)', '长相思 (Sauvignon Blanc)',
      '白诗南 (Chenin Blanc)', '赛美蓉 (Sémillon)', '琼瑶浆 (Gewürztraminer)',
      '灰皮诺 (Pinot Grigio/Pinot Gris)', '维欧尼 (Viognier)',
      '玛珊 (Marsanne)', '瑚珊 (Roussanne)', '阿尔巴利诺 (Albariño)',
      '维黛荷 (Verdejo)', '特雷比亚诺 (Trebbiano)', '麝香 (Muscat)',
      '绿维特利纳 (Grüner Veltliner)', '弗德乔 (Furmint)',
    ],
    '西班牙特色': [
      '丹魄 (Tempranillo)', '歌海娜 (Garnacha)', '格拉西亚诺 (Graciano)',
      '佳利酿 (Cariñena/Carignan)', '阿尔巴利诺 (Albariño)',
      '维黛荷 (Verdejo)', '帕洛米诺 (Palomino)',
    ],
    '意大利特色': [
      '内比奥罗 (Nebbiolo)', '桑娇维塞 (Sangiovese)', '巴贝拉 (Barbera)',
      '多姿桃 (Dolcetto)', '科维纳 (Corvina)', '普里米蒂沃 (Primitivo)',
      '黑达沃拉 (Nero d\'Avola)', '艾格尼科 (Aglianico)',
      '蒙特普齐亚诺 (Montepulciano)', '普洛塞克 (Glera - Prosecco)',
      '灰皮诺 (Pinot Grigio)', '莫斯卡托 (Moscato)',
    ],
    '法国特色': [
      '赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)', '黑皮诺 (Pinot Noir)',
      '歌海娜 (Grenache)', '慕合怀特 (Mourvèdre)',
      '品丽珠 (Cabernet Franc)', '马尔贝克 (Malbec)', '小维多 (Petit Verdot)',
      '霞多丽 (Chardonnay)', '白诗南 (Chenin Blanc)',
      '琼瑶浆 (Gewürztraminer)', '维欧尼 (Viognier)', '玛珊 (Marsanne)',
      '瑚珊 (Roussanne)', '赛美蓉 (Sémillon)',
    ],
    '新世界特色': [
      '马尔贝克 (Malbec)', '佳美娜 (Carmenère)', '仙粉黛 (Zinfandel)',
      '白诗南 (Chenin Blanc)', '皮诺塔吉 (Pinotage)',
    ],
    '德国/奥地利特色': [
      '雷司令 (Riesling)', '白皮诺 (Weissburgunder)', '灰皮诺 (Grauburgunder)',
      '黑皮诺 (Spätburgunder)', '西万尼 (Silvaner)', '绿维特利纳 (Grüner Veltliner)',
      '茨威格特 (Zweigelt)',
    ],
    '葡萄牙特色': [
      '国家杜丽佳 (Touriga Nacional)', '红罗利兹 (Tinta Roriz)',
      '法兰卡杜丽佳 (Touriga Franca)', '巴加 (Baga)',
      '阿林图 (Alvarinho)', '葡萄牙绿酒混酿 (Vinho Verde Blend)',
    ],
    '中国本土': [
      '蛇龙珠 (Cabernet Gernischt)', '赤霞珠 (Cabernet Sauvignon)',
      '梅洛 (Merlot)', '马瑟兰 (Marselan)', '黑皮诺 (Pinot Noir)',
      '雷司令 (Riesling)', '霞多丽 (Chardonnay)',
      '白玉霓 (Ugni Blanc)', '水晶 (Shuijing)',
    ],
  };

  /// 展开的品种扁平列表（含类别标签 - 用于Dropdown须去重）
  static List<String> get allGrapeVarieties {
    final seen = <String>{};
    final result = <String>[];
    for (final list in grapeCategories.values) {
      for (final v in list) {
        if (seen.add(v)) result.add(v);
      }
    }
    return result;
  }

  /// 名庄参考（按产区）
  static const Map<String, Map<String, List<String>>> famousWineries = {
    '法国': {
      '波尔多': ['拉菲古堡', '拉图酒庄', '玛歌酒庄', '木桐酒庄', '侯伯王酒庄',
                 '帕图斯', '白马酒庄', '欧颂酒庄', '金钟酒庄', '雄狮酒庄',
                 '碧尚女爵', '玫瑰酒庄', '凯隆世家', '靓茨伯', '大宝酒庄'],
      '勃艮第': ['罗曼尼康帝', '勒桦酒庄', '亨利·贾叶', '武若园', '卢米酒庄',
                 '彭寿酒庄', '里贝伯爵', '阿曼·卢梭', '杜雅克', '西万尼'],
      '香槟': ['库克', '唐培里侬', '沙龙香槟', '凯歌', '酩悦',
               '堡林爵', '路易王妃', '玛姆', '泰亭哲', '罗兰百悦'],
      '罗讷河谷': ['吉佳乐世家', '夏伯帝', '博卡斯特尔', '稀雅丝', '佩高',
                   '莎普蒂尔', '嘉宝酒庄', '德拉斯', '圣柯斯姆'],
      '卢瓦尔河谷': ['帝姆酒庄', '迪迪埃·达格诺', '博马尔', '亨利·布约', '希侬'],
    },
    '意大利': {
      '托斯卡纳': ['安东尼世家', '西施佳雅', '索拉雅', '天娜', '奥瑞莉亚',
                   '碧安帝-山迪', '卡萨诺瓦', '蒙塔奇诺名庄联盟'],
      '皮埃蒙特': ['嘉雅', '孔特诺', '大Q', '雷纳多·拉蒂', '维埃蒂',
                   '埃尔维奥·科诺', '阿德里的马可', '玛格丽'],
      '威尼托': ['昆达莱利', '朱塞佩·昆达莱利', '阿尔贝托·卢凯', '马西酒庄',
                 '托马索', '圣玛格丽特'],
    },
    '西班牙': {
      '里奥哈': ['皇室田园', '橡树河畔', '穆嘉酒庄', '天使之路', '洛佩兹·埃雷蒂亚',
                 '孔德·德·阿尔代瓦', '瑞格尔侯爵', '阿塔迪'],
      '里贝拉·杜埃罗': ['贝加西西里亚', '阿里昂', '平古斯', 'Pesquera'],
      '普里奥拉托': ['伊拉姆', '克罗莫尔', '马赛托', '天籁之心'],
      '赫雷斯': ['佩德罗·多梅克', '冈萨雷·比亚斯', '奥苏那', '雷伊'],
    },
    '德国': {
      '摩泽尔': ['伊贡·穆勒', '约翰山酒庄', '普朗酒庄', '海格', '雷布霍兹'],
      '莱茵高': ['约翰山城堡', '罗伯特·威尔', '库姆勒', '布罗伊尔', 'Bercher'],
    },
    '美国': {
      '纳帕谷': ['啸鹰酒庄', '哈兰酒庄', '拉瑟家族', '作品一号', '思福酒庄',
                 '卡内罗斯', '多米诺斯', '寇金酒庄', '钻石溪谷', '活灵魂'],
      '索诺玛': ['肯德-杰克逊', '鹦鹉螺', '威廉姆斯·塞利姆', '约瑟夫·菲尔普斯'],
      '威拉米特谷': ['杜鲁安', '雷克斯山', '艾尔·万达', '凯勒酒庄'],
    },
    '澳大利亚': {
      '巴罗莎谷': ['奔富', '翰斯科', '托布雷酒庄', '圣哈利特', '洛克福酒庄',
                   '格林诺克', '罗伯特·奥特利'],
      '雅拉谷': ['吉拉德', '雅拉优伶', '山度富', '塔森酒庄'],
      '玛格丽特河': ['莫斯伍德', '李·温', '露纹酒庄', '沃特曼', '皮埃尔'],
      '克莱尔谷': ['泰拉贝尔', '植物学者', '格罗塞特', '瑞尔登'],
    },
    '新西兰': {
      '马尔堡': ['云雾之湾', '蚝湾', '维拉', '克拉吉', '圣克莱尔',
                 '艾伦·斯科特', '猎人之家'],
      '中奥塔哥': ['飞腾酒庄', '黑脊酒庄', '螺旋森林', '贝尔山', '查尔斯·怀菲尔德'],
    },
    '智利': {
      '迈坡谷': ['活灵魂', '碧桃丝', '圣丽塔', '卡米诺', '康查·依·托罗'],
      '科尔查瓜谷': ['蒙特斯', '拉贝尔', '拉帕斯托', '克拉罗·拉古纳'],
    },
    '阿根廷': {
      '门多萨': ['卡地娜酒庄', '柏图斯', '奇卡纳', '诺顿', '特雷斯·桑托斯',
                 '阿里斯特'],
    },
    '南非': {
      '斯特兰德': ['美景酒庄', '穆勒酒庄', '卡农·科普', '维利尔酒庄',
                  '格伦卡洛', '鲁斯滕堡'],
    },
    '中国': {
      '宁夏贺兰山': ['张裕摩塞尔', '长城天赋', '银色高地', '贺兰晴雪', '迦南美地',
                   '蒲尚酒庄', '博纳佰馥', '类人首', '鲁南酒庄'],
      '新疆': ['中信国安尼雅', '乡都酒业', '楼兰酒庄', '天塞酒庄', '中葡酒业'],
      '山东烟台': ['张裕', '长城', '威龙', '君顶酒庄', '华东百利'],
    },
  };

  /// 获取国家的产区列表(含推荐标注)
  static List<String> getRegionsForCountry(String country) {
    return countryRegions[country] ?? [];
  }

  /// 获取经典年份列表
  static List<String> getVintageYears() {
    final years = <String>['NV (无年份)'];
    for (int y = 1980; y <= 2026; y++) {
      years.add(y.toString());
    }
    return years;
  }

  /// 经典混酿配方 — 全面覆盖世界各大产区典型混酿
  static const Map<String, List<String>> classicBlends = {
    // ═══════ 法国 ═══════
    '波尔多红混酿': ['赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)', '品丽珠 (Cabernet Franc)', '小维多 (Petit Verdot)', '马尔贝克 (Malbec)'],
    '波尔多左岸混酿': ['赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)', '品丽珠 (Cabernet Franc)', '小维多 (Petit Verdot)'],
    '波尔多右岸混酿': ['梅洛 (Merlot)', '品丽珠 (Cabernet Franc)', '赤霞珠 (Cabernet Sauvignon)'],
    '波尔多白混酿': ['长相思 (Sauvignon Blanc)', '赛美蓉 (Sémillon)', '密斯卡岱 (Muscadelle)'],
    '波尔多甜白(苏玳)混酿': ['赛美蓉 (Sémillon)', '长相思 (Sauvignon Blanc)', '密斯卡岱 (Muscadelle)'],
    '勃艮第红混酿': ['黑皮诺 (Pinot Noir)', '佳美 (Gamay)'],
    '勃艮第白混酿': ['霞多丽 (Chardonnay)'],
    '香槟混酿': ['黑皮诺 (Pinot Noir)', '霞多丽 (Chardonnay)', '莫尼耶皮诺 (Pinot Meunier)'],
    '勃艮第起泡(Crémant)混酿': ['黑皮诺 (Pinot Noir)', '霞多丽 (Chardonnay)', '佳美 (Gamay)'],
    'GSM混酿': ['歌海娜 (Grenache)', '西拉 (Syrah)', '慕合怀特 (Mourvèdre)'],
    '教皇新堡混酿': ['歌海娜 (Grenache)', '西拉 (Syrah)', '慕合怀特 (Mourvèdre)', '神索 (Cinsault)'],
    '罗讷河白混酿': ['玛珊 (Marsanne)', '瑚珊 (Roussanne)', '维欧尼 (Viognier)', '白歌海娜 (Grenache Blanc)'],
    '朗格多克混酿': ['歌海娜 (Grenache)', '西拉 (Syrah)', '神索 (Cinsault)', '慕合怀特 (Mourvèdre)', '佳丽酿 (Carignan)'],
    '普罗旺斯桃红混酿': ['歌海娜 (Grenache)', '神索 (Cinsault)', '西拉 (Syrah)', '慕合怀特 (Mourvèdre)', '提布伦 (Tibouren)'],
    '阿尔萨斯混酿(Edelzwicker)': ['雷司令 (Riesling)', '琼瑶浆 (Gewürztraminer)', '灰皮诺 (Pinot Gris)', '麝香 (Muscat)'],
    '西南产区混酿': ['马尔贝克 (Malbec)', '赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)', '丹娜 (Tannat)'],

    // ═══════ 意大利 ═══════
    '基安蒂混酿': ['桑娇维塞 (Sangiovese)', '卡内奥罗 (Canaiolo)', '赤霞珠 (Cabernet Sauvignon)', '品丽珠 (Cabernet Franc)'],
    '古典基安蒂混酿': ['桑娇维塞 (Sangiovese)', '卡内奥罗 (Canaiolo)', '科罗里诺 (Colorino)'],
    '蒙塔奇诺布鲁奈罗': ['桑娇维塞·格罗索 (Brunello - Sangiovese Grosso)'],
    '桑娇维塞混酿': ['桑娇维塞 (Sangiovese)', '赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)'],
    '超级托斯卡纳': ['赤霞珠 (Cabernet Sauvignon)', '桑娇维塞 (Sangiovese)', '梅洛 (Merlot)', '西拉 (Syrah)'],
    '瓦波利切拉混酿': ['科维纳 (Corvina)', '科维诺内 (Corvinone)', '罗蒂内拉 (Rondinella)', '莫利纳拉 (Molinara)'],
    '阿玛罗尼混酿': ['科维纳 (Corvina)', '罗蒂内拉 (Rondinella)', '莫利纳拉 (Molinara)'],
    '巴罗洛/巴巴莱斯科': ['内比奥罗 (Nebbiolo)'],
    '巴贝拉混酿': ['巴贝拉 (Barbera)', '内比奥罗 (Nebbiolo)', '多姿桃 (Dolcetto)'],
    '朗格混酿(Nebbiolo为主)': ['内比奥罗 (Nebbiolo)', '巴贝拉 (Barbera)', '赤霞珠 (Cabernet Sauvignon)'],
    '弗朗齐亚科达混酿': ['霞多丽 (Chardonnay)', '黑皮诺 (Pinot Noir)', '白皮诺 (Pinot Bianco)'],
    '普洛赛克混酿': ['格雷拉 (Glera)', '维蒂索 (Verdiso)', '白特雷维佐 (Bianchetta Trevigiana)'],
    '图拉斯混酿': ['艾格尼科 (Aglianico)', '赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)'],
    '蒙特普齐亚诺混酿': ['蒙特普齐亚诺 (Montepulciano)', '桑娇维塞 (Sangiovese)'],
    '黑达沃拉混酿': ['黑达沃拉 (Nero d\'Avola)', '西拉 (Syrah)', '赤霞珠 (Cabernet Sauvignon)'],
    '普利亚混酿(Primitivo为主)': ['普里米蒂沃 (Primitivo)', '黑达沃拉 (Nero d\'Avola)', '马尔贝克 (Malbec)'],

    // ═══════ 西班牙 ═══════
    '里奥哈红混酿': ['丹魄 (Tempranillo)', '歌海娜 (Garnacha)', '格拉西亚诺 (Graciano)', '马苏埃洛 (Mazuelo)'],
    '里奥哈白混酿': ['维尤拉 (Viura)', '玛卡贝奥 (Macabeo)', '马尔瓦西亚 (Malvasía)'],
    '里奥哈珍藏白混酿': ['维尤拉 (Viura)', '霞多丽 (Chardonnay)', '长相思 (Sauvignon Blanc)'],
    '里贝拉·杜埃罗混酿': ['丹魄 (Tempranillo)', '赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)'],
    '杜埃罗河岸混酿': ['丹魄 (Tempranillo)', '歌海娜 (Garnacha)', '赤霞珠 (Cabernet Sauvignon)'],
    '普里奥拉托混酿': ['歌海娜 (Garnacha)', '佳利酿 (Cariñena)', '赤霞珠 (Cabernet Sauvignon)', '西拉 (Syrah)'],
    '卡瓦混酿': ['马家婆 (Macabeo)', '沙雷洛 (Xarel·lo)', '帕雷亚达 (Parellada)', '霞多丽 (Chardonnay)', '黑皮诺 (Pinot Noir)'],
    '下海湾(阿尔巴利诺)': ['阿尔巴利诺 (Albariño)'],
    '卢埃达混酿': ['维黛荷 (Verdejo)', '长相思 (Sauvignon Blanc)'],
    '托罗混酿': ['丹魄 (Tempranillo)', '歌海娜 (Garnacha)'],
    '纳瓦拉混酿': ['歌海娜 (Garnacha)', '丹魄 (Tempranillo)', '赤霞珠 (Cabernet Sauvignon)'],
    '比埃尔索混酿': ['门西亚 (Mencía)', '赤霞珠 (Cabernet Sauvignon)'],
    '雪莉酒混酿': ['帕洛米诺 (Palomino)', '佩德罗·希梅内斯 (Pedro Ximénez)', '莫斯卡特 (Moscatel)'],

    // ═══════ 葡萄牙 ═══════
    '杜罗河谷混酿': ['国家杜丽佳 (Touriga Nacional)', '法兰卡杜丽佳 (Touriga Franca)', '红罗利兹 (Tinta Roriz)'],
    '波特混酿': ['国家杜丽佳 (Touriga Nacional)', '法兰卡杜丽佳 (Touriga Franca)', '红罗利兹 (Tinta Roriz)', '索沙奥 (Tinta Barroca)'],
    '白波特混酿': ['古维欧 (Gouveio)', '马尔瓦西亚·菲纳 (Malvasia Fina)', '维欧新荷 (Viosinho)'],
    '绿酒混酿': ['阿林图 (Alvarinho)', '洛雷罗 (Loureiro)', '阿瑞图 (Arinto)', '阿瓦里诺 (Avesso)'],
    '马德拉混酿': ['马尔姆西 (Malmsey)', '布阿尔 (Bual)', '维尔迪霍 (Verdelho)', '赛希尔 (Sercial)'],
    '阿连特茹混酿': ['特林加岱拉 (Trincadeira)', '阿拉哥斯 (Aragonez)', '西拉 (Syrah)', '赤霞珠 (Cabernet Sauvignon)'],
    '百拉达混酿': ['巴加 (Baga)', '国家杜丽佳 (Touriga Nacional)', '赤霞珠 (Cabernet Sauvignon)'],

    // ═══════ 德国/奥地利 ═══════
    '德国白混酿(Liebfraumilch)': ['雷司令 (Riesling)', '西万尼 (Silvaner)', '穆勒图高 (Müller-Thurgau)'],
    '德国黑皮诺混酿': ['黑皮诺 (Spätburgunder)', '茨威格特 (Zweigelt)', '丹菲特 (Dornfelder)'],
    '维也纳混酿(Gemischter Satz)': ['雷司令 (Riesling)', '绿维特利纳 (Grüner Veltliner)', '白皮诺 (Weissburgunder)', '西万尼 (Silvaner)'],
    '奥地利绿维特利纳混酿': ['绿维特利纳 (Grüner Veltliner)', '雷司令 (Riesling)', '霞多丽 (Chardonnay)'],
    '奥地利红混酿': ['茨威格特 (Zweigelt)', '蓝佛朗克 (Blaufränkisch)', '黑皮诺 (Spätburgunder)'],

    // ═══════ 美国 ═══════
    '加州梅里蒂奇混酿': ['赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)', '品丽珠 (Cabernet Franc)', '小维多 (Petit Verdot)', '马尔贝克 (Malbec)'],
    '加州GSM混酿': ['歌海娜 (Grenache)', '西拉 (Syrah)', '慕合怀特 (Mourvèdre)'],
    '索诺玛仙粉黛混酿': ['仙粉黛 (Zinfandel)', '小西拉 (Petite Sirah)', '佳美娜 (Carmenère)'],
    '加州波尔多风格白混酿': ['长相思 (Sauvignon Blanc)', '赛美蓉 (Sémillon)'],
    '威拉米特谷黑皮诺': ['黑皮诺 (Pinot Noir)'],
    '手指湖雷司令混酿': ['雷司令 (Riesling)', '霞多丽 (Chardonnay)', '琼瑶浆 (Gewürztraminer)'],

    // ═══════ 澳大利亚 ═══════
    '巴罗莎混酿': ['西拉子 (Shiraz)', '赤霞珠 (Cabernet Sauvignon)', '慕合怀特 (Mourvèdre)'],
    '澳大利亚GSM混酿': ['歌海娜 (Grenache)', '西拉子 (Shiraz)', '慕合怀特 (Mourvèdre)'],
    '玛格丽特河混酿': ['赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)', '品丽珠 (Cabernet Franc)', '小维多 (Petit Verdot)'],
    '猎人谷赛美蓉': ['赛美蓉 (Sémillon)'],
    '克莱尔谷雷司令': ['雷司令 (Riesling)'],
    '雅拉谷起泡混酿': ['黑皮诺 (Pinot Noir)', '霞多丽 (Chardonnay)'],
    '库纳瓦拉赤霞珠': ['赤霞珠 (Cabernet Sauvignon)'],

    // ═══════ 新西兰 ═══════
    '霍克斯湾混酿': ['赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)', '品丽珠 (Cabernet Franc)', '马尔贝克 (Malbec)'],
    '马尔堡长相思': ['长相思 (Sauvignon Blanc)'],
    '中奥塔哥黑皮诺': ['黑皮诺 (Pinot Noir)'],

    // ═══════ 南美 ═══════
    '门多萨马尔贝克混酿': ['马尔贝克 (Malbec)', '赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)', '西拉 (Syrah)'],
    '智利波尔多风格混酿': ['赤霞珠 (Cabernet Sauvignon)', '佳美娜 (Carmenère)', '梅洛 (Merlot)', '品丽珠 (Cabernet Franc)'],
    '智利佳美娜为主混酿': ['佳美娜 (Carmenère)', '赤霞珠 (Cabernet Sauvignon)', '西拉 (Syrah)'],
    '乌拉圭丹娜混酿': ['丹娜 (Tannat)', '赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)'],

    // ═══════ 南非 ═══════
    '斯特兰德波尔多风格混酿': ['赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)', '品丽珠 (Cabernet Franc)', '马尔贝克 (Malbec)'],
    '皮诺塔吉混酿': ['皮诺塔吉 (Pinotage)', '赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)'],
    '开普白混酿': ['白诗南 (Chenin Blanc)', '霞多丽 (Chardonnay)', '长相思 (Sauvignon Blanc)'],

    // ═══════ 其他 ═══════
    '中国蛇龙珠混酿': ['蛇龙珠 (Cabernet Gernischt)', '赤霞珠 (Cabernet Sauvignon)', '梅洛 (Merlot)', '马瑟兰 (Marselan)'],
    '希腊圣托里尼阿西尔提可': ['阿西尔提可 (Assyrtiko)', '艾达尼 (Aidani)', '阿斯里 (Athiri)'],
    '希腊尼米亚圣乔治混酿': ['圣乔治 (Agiorgitiko)', '赤霞珠 (Cabernet Sauvignon)'],
    '匈牙利托卡伊混酿': ['弗德乔 (Furmint)', '哈斯莱威路 (Hárslevelű)', '萨格穆斯克诺特 (Sárga Muskotály)'],
    '匈牙利公牛血混酿': ['卡达卡 (Kadarka)', '蓝佛朗克 (Kékfrankos)', '赤霞珠 (Cabernet Sauvignon)'],
    '格鲁吉亚萨别拉维混酿': ['萨别拉维 (Saperavi)', '霞多丽 (Chardonnay)', '赤霞珠 (Cabernet Sauvignon)'],
    '黎巴嫩贝卡混酿': ['赤霞珠 (Cabernet Sauvignon)', '西拉 (Syrah)', '神索 (Cinsault)'],
  };

  /// 产区推荐混酿 — 根据国家和产区快速查找应推荐的典型混酿
  /// 结构: {国家: {产区: [混酿名称, ...]}}
  static const Map<String, Map<String, List<String>>> regionRecommendedBlends = {
    '法国': {
      '波尔多': ['波尔多红混酿', '波尔多左岸混酿', '波尔多右岸混酿', '波尔多白混酿', '波尔多甜白(苏玳)混酿'],
      '勃艮第': ['勃艮第红混酿', '勃艮第白混酿', '勃艮第起泡(Crémant)混酿'],
      '香槟': ['香槟混酿'],
      '罗讷河谷': ['GSM混酿', '教皇新堡混酿', '罗讷河白混酿'],
      '卢瓦尔河谷': ['勃艮第白混酿'],  // 卢瓦尔多以单一品种为主
      '阿尔萨斯': ['阿尔萨斯混酿(Edelzwicker)'],
      '朗格多克-鲁西荣': ['朗格多克混酿', 'GSM混酿', '教皇新堡混酿'],
      '普罗旺斯': ['普罗旺斯桃红混酿', 'GSM混酿'],
      '西南产区': ['西南产区混酿', '波尔多红混酿'],
      '博若莱': ['勃艮第红混酿'],
    },
    '意大利': {
      '托斯卡纳': ['基安蒂混酿', '古典基安蒂混酿', '蒙塔奇诺布鲁奈罗', '桑娇维塞混酿', '超级托斯卡纳'],
      '皮埃蒙特': ['巴罗洛/巴巴莱斯科', '巴贝拉混酿', '朗格混酿(Nebbiolo为主)'],
      '威尼托': ['瓦波利切拉混酿', '阿玛罗尼混酿', '普洛赛克混酿'],
      '伦巴第': ['弗朗齐亚科达混酿'],
      '西西里': ['黑达沃拉混酿'],
      '坎帕尼亚': ['图拉斯混酿'],
      '普利亚': ['普利亚混酿(Primitivo为主)'],
      '阿布鲁佐': ['蒙特普齐亚诺混酿'],
    },
    '西班牙': {
      '里奥哈': ['里奥哈红混酿', '里奥哈白混酿', '里奥哈珍藏白混酿'],
      '里贝拉·杜埃罗': ['里贝拉·杜埃罗混酿'],
      '杜埃罗河岸': ['杜埃罗河岸混酿', '里贝拉·杜埃罗混酿'],
      '普里奥拉托': ['普里奥拉托混酿'],
      '加泰罗尼亚': ['卡瓦混酿', '普里奥拉托混酿'],
      '下海湾': ['下海湾(阿尔巴利诺)'],
      '卢埃达': ['卢埃达混酿'],
      '托罗': ['托罗混酿'],
      '纳瓦拉': ['纳瓦拉混酿'],
      '比埃尔索': ['比埃尔索混酿'],
      '赫雷斯': ['雪莉酒混酿'],
      '佩内德斯': ['卡瓦混酿'],
    },
    '葡萄牙': {
      '杜罗河谷': ['杜罗河谷混酿', '波特混酿', '白波特混酿'],
      '绿酒产区': ['绿酒混酿'],
      '马德拉': ['马德拉混酿'],
      '阿连特茹': ['阿连特茹混酿'],
      '百拉达': ['百拉达混酿'],
    },
    '德国': {
      '摩泽尔': ['德国白混酿(Liebfraumilch)'],
      '莱茵高': ['德国白混酿(Liebfraumilch)'],
      '法尔兹': ['德国白混酿(Liebfraumilch)'],
      '巴登': ['德国黑皮诺混酿'],
    },
    '奥地利': {
      '维也纳': ['维也纳混酿(Gemischter Satz)'],
      '瓦豪': ['奥地利绿维特利纳混酿'],
      '布尔根兰': ['奥地利红混酿', '奥地利绿维特利纳混酿'],
    },
    '美国': {
      '纳帕谷': ['加州梅里蒂奇混酿', '加州波尔多风格白混酿'],
      '索诺玛': ['加州梅里蒂奇混酿', '索诺玛仙粉黛混酿', '加州GSM混酿'],
      '中央海岸': ['加州GSM混酿', '索诺玛仙粉黛混酿'],
      '威拉米特谷': ['威拉米特谷黑皮诺'],
      '手指湖': ['手指湖雷司令混酿'],
    },
    '澳大利亚': {
      '巴罗莎谷': ['巴罗莎混酿', '澳大利亚GSM混酿'],
      '麦拉伦维尔': ['澳大利亚GSM混酿', '巴罗莎混酿'],
      '雅拉谷': ['雅拉谷起泡混酿', '威拉米特谷黑皮诺'],  // 雅拉谷以黑皮诺和起泡闻名
      '玛格丽特河': ['玛格丽特河混酿'],
      '猎人谷': ['猎人谷赛美蓉'],
      '克莱尔谷': ['克莱尔谷雷司令'],
      '库纳瓦拉': ['库纳瓦拉赤霞珠', '玛格丽特河混酿'],
    },
    '新西兰': {
      '马尔堡': ['马尔堡长相思'],
      '中奥塔哥': ['中奥塔哥黑皮诺'],
      '霍克斯湾': ['霍克斯湾混酿'],
    },
    '智利': {
      '迈坡谷': ['智利波尔多风格混酿'],
      '科尔查瓜谷': ['智利佳美娜为主混酿', '智利波尔多风格混酿'],
      '卡萨布兰卡谷': ['智利波尔多风格混酿'],
    },
    '阿根廷': {
      '门多萨': ['门多萨马尔贝克混酿'],
    },
    '乌拉圭': {
      '卡内洛内斯': ['乌拉圭丹娜混酿'],
    },
    '南非': {
      '斯特兰德': ['斯特兰德波尔多风格混酿', '皮诺塔吉混酿', '开普白混酿'],
      '弗兰谷': ['斯特兰德波尔多风格混酿', '开普白混酿'],
    },
    '中国': {
      '宁夏贺兰山': ['中国蛇龙珠混酿'],
      '新疆': ['中国蛇龙珠混酿'],
      '山东烟台': ['中国蛇龙珠混酿'],
      '河北怀来': ['中国蛇龙珠混酿'],
      '云南香格里拉': ['中国蛇龙珠混酿'],
    },
    '希腊': {
      '圣托里尼': ['希腊圣托里尼阿西尔提可'],
      '尼米亚': ['希腊尼米亚圣乔治混酿'],
      '纳乌萨': ['巴罗洛/巴巴莱斯科'],  // 希腊西诺玛诺以类似内比奥罗风格闻名
    },
    '匈牙利': {
      '托卡伊': ['匈牙利托卡伊混酿'],
      '埃格尔': ['匈牙利公牛血混酿'],
    },
    '格鲁吉亚': {
      '卡赫季': ['格鲁吉亚萨别拉维混酿'],
    },
    '黎巴嫩': {
      '贝卡山谷': ['黎巴嫩贝卡混酿'],
    },
  };

  /// 获取推荐的混酿列表 — 根据国家+产区返回推荐的典型混酿名称
  /// 返回的混酿名称可通过 classicBlends 获取其配方成分
  static List<String> getRecommendedBlends(String country, [String? region]) {
    final countryData = regionRecommendedBlends[country];
    if (countryData == null) return [];
    if (region != null && countryData[region] != null) {
      return countryData[region]!;
    }
    // 返回该国所有推荐混酿（去重）
    final blends = <String>{};
    for (final list in countryData.values) {
      blends.addAll(list);
    }
    return blends.toList()..sort();
  }

  /// 获取名庄(按国家和产区)
  static List<String> getWineries(String country, [String? region]) {
    final countryData = famousWineries[country];
    if (countryData == null) return [];
    if (region != null && countryData[region] != null) {
      return countryData[region]!;
    }
    // 返回该国所有名庄
    return countryData.values.expand((list) => list).toSet().toList()..sort();
  }
}
