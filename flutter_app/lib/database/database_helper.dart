import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';

import '../models/wine.dart';
import '../models/tasting.dart';
import '../models/tasting_appearance.dart';
import '../models/tasting_aroma.dart';
import '../models/tasting_palate.dart';
import '../models/tasting_overall.dart';
import '../models/flavor.dart';
import '../models/weight_config.dart';
import '../models/user_profile.dart';
import '../models/storage_location.dart';
import '../models/cellar.dart';
import '../models/cellar_transaction.dart';
import '../models/tasting_flavor.dart';
import '../utils/scoring_helper.dart';
import '../utils/file_backup.dart' as backup;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;
  static DatabaseHelper get Instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = p.join(await getDatabasesPath(), 'wine_journal_pro.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // 酒款表
    await db.execute('''
      CREATE TABLE wines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        winery TEXT,
        country TEXT,
        region TEXT,
        variety TEXT,
        vintage INTEGER,
        alcohol REAL,
        price REAL,
        wineType TEXT NOT NULL,
        photoPath TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        isDeleted INTEGER DEFAULT 0
      )
    ''');

    // 品鉴表
    await db.execute('''
      CREATE TABLE tastings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wineId INTEGER NOT NULL,
        scoringMode TEXT DEFAULT 'standard',
        isBlind INTEGER DEFAULT 0,
        isRevealed INTEGER DEFAULT 0,
        drinkingDate TEXT,
        purchaseDate TEXT,
        venue TEXT,
        score100 INTEGER,
        notes TEXT,
        customNote TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        isDeleted INTEGER DEFAULT 0,
        FOREIGN KEY (wineId) REFERENCES wines(id)
      )
    ''');

    // 外观评分表
    await db.execute('''
      CREATE TABLE tasting_appearance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tastingId INTEGER NOT NULL,
        color TEXT,
        clarity TEXT,
        intensity TEXT,
        condition TEXT,
        tears TEXT,
        bubbleFineness TEXT,
        bubblePersistence TEXT,
        FOREIGN KEY (tastingId) REFERENCES tastings(id)
      )
    ''');

    // 香气评分表
    await db.execute('''
      CREATE TABLE tasting_aroma (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tastingId INTEGER NOT NULL,
        intensity INTEGER DEFAULT 0,
        complexity INTEGER DEFAULT 0,
        purity INTEGER DEFAULT 0,
        persistence INTEGER DEFAULT 0,
        development TEXT,
        FOREIGN KEY (tastingId) REFERENCES tastings(id)
      )
    ''');

    // 口感评分表
    await db.execute('''
      CREATE TABLE tasting_palate (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tastingId INTEGER NOT NULL,
        acidity INTEGER DEFAULT 0,
        tannin INTEGER DEFAULT 0,
        tanninTexture TEXT,
        body INTEGER DEFAULT 0,
        balance INTEGER DEFAULT 0,
        complexity INTEGER DEFAULT 0,
        finishLength INTEGER DEFAULT 0,
        finishCharacter TEXT,
        alcoholPerception INTEGER,
        FOREIGN KEY (tastingId) REFERENCES tastings(id)
      )
    ''');

    // 综合评分表
    await db.execute('''
      CREATE TABLE tasting_overall (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tastingId INTEGER NOT NULL,
        typicality INTEGER DEFAULT 0,
        enjoyment INTEGER DEFAULT 0,
        value INTEGER DEFAULT 0,
        agingPotential INTEGER DEFAULT 0,
        agingAdvice TEXT,
        repurchase INTEGER DEFAULT 0,
        FOREIGN KEY (tastingId) REFERENCES tastings(id)
      )
    ''');

    // 风味词表
    await db.execute('''
      CREATE TABLE flavors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        subcategory TEXT,
        wineType TEXT NOT NULL,
        isBuiltin INTEGER DEFAULT 1,
        createdAt TEXT
      )
    ''');

    // 品鉴-风味关联表
    await db.execute('''
      CREATE TABLE tasting_flavors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tastingId INTEGER NOT NULL,
        flavorId INTEGER NOT NULL,
        FOREIGN KEY (tastingId) REFERENCES tastings(id),
        FOREIGN KEY (flavorId) REFERENCES flavors(id)
      )
    ''');

    // 权重配置表
    await db.execute('''
      CREATE TABLE weight_config (
        id INTEGER PRIMARY KEY DEFAULT 1,
        aromaWeight REAL DEFAULT 0.3,
        palateWeight REAL DEFAULT 0.4,
        overallWeight REAL DEFAULT 0.3,
        updatedAt TEXT
      )
    ''');

    // 用户配置表
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY DEFAULT 1,
        nickname TEXT,
        avatarPath TEXT,
        userId TEXT,
        darkMode INTEGER DEFAULT 0
      )
    ''');

    // 存储位置表
    await db.execute('''
      CREATE TABLE storage_locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sortOrder INTEGER DEFAULT 0,
        createdAt TEXT
      )
    ''');

    // 酒窖表
    await db.execute('''
      CREATE TABLE cellar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wineId INTEGER NOT NULL,
        storageLocationId INTEGER NOT NULL,
        entryDate TEXT,
        quantity INTEGER DEFAULT 1,
        purchasePrice REAL,
        purchaseDate TEXT,
        drinkFrom INTEGER,
        drinkTo INTEGER,
        notes TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        FOREIGN KEY (wineId) REFERENCES wines(id),
        FOREIGN KEY (storageLocationId) REFERENCES storage_locations(id)
      )
    ''');

    // 酒窖变动日志表
    await db.execute('''
      CREATE TABLE cellar_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cellarId INTEGER NOT NULL,
        tastingId INTEGER,
        transType TEXT NOT NULL,
        quantity INTEGER DEFAULT 1,
        transDate TEXT,
        notes TEXT,
        createdAt TEXT,
        FOREIGN KEY (cellarId) REFERENCES cellar(id),
        FOREIGN KEY (tastingId) REFERENCES tastings(id)
      )
    ''');

    // 品鉴照片表
    await db.execute('''
      CREATE TABLE tasting_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tastingId INTEGER NOT NULL,
        photoPath TEXT NOT NULL,
        sortOrder INTEGER DEFAULT 0,
        createdAt TEXT,
        FOREIGN KEY (tastingId) REFERENCES tastings(id) ON DELETE CASCADE
      )
    ''');

    // 插入种子数据
    await _insertSeedData(db);
  }

  Future<void> _insertSeedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // 红葡萄酒风味词 (28个)
    final redFlavors = [
      // 水果 - 黑色
      ['黑醋栗', '水果', '黑色水果', 'red'],
      ['黑莓', '水果', '黑色水果', 'red'],
      ['黑樱桃', '水果', '黑色水果', 'red'],
      ['桑葚', '水果', '黑色水果', 'red'],
      ['蓝莓', '水果', '黑色水果', 'red'],
      // 水果 - 红色
      ['覆盆子', '水果', '红色水果', 'red'],
      ['草莓', '水果', '红色水果', 'red'],
      ['红樱桃', '水果', '红色水果', 'red'],
      ['蔓越莓', '水果', '红色水果', 'red'],
      ['红李子', '水果', '红色水果', 'red'],
      // 水果 - 干果
      ['无花果', '水果', '干果', 'red'],
      ['西梅干', '水果', '干果', 'red'],
      // 香料
      ['黑胡椒', '香料', '', 'red'],
      ['肉桂', '香料', '', 'red'],
      ['丁香', '香料', '', 'red'],
      ['香草', '香料', '', 'red'],
      ['甘草', '香料', '', 'red'],
      // 植物
      ['青椒', '植物', '', 'red'],
      ['薄荷', '植物', '', 'red'],
      ['桉树', '植物', '', 'red'],
      ['烟叶', '植物', '', 'red'],
      // 橡木/陈年
      ['橡木', '橡木', '', 'red'],
      ['雪松', '橡木', '', 'red'],
      ['烟熏', '橡木', '', 'red'],
      ['皮革', '橡木', '', 'red'],
      ['咖啡', '橡木', '', 'red'],
      ['巧克力', '橡木', '', 'red'],
      ['焦糖', '橡木', '', 'red'],
    ];

    // 白葡萄酒风味词 (27个)
    final whiteFlavors = [
      // 水果 - 柑橘
      ['柠檬', '水果', '柑橘类', 'white'],
      ['青柠', '水果', '柑橘类', 'white'],
      ['葡萄柚', '水果', '柑橘类', 'white'],
      ['橙子', '水果', '柑橘类', 'white'],
      ['橘子', '水果', '柑橘类', 'white'],
      // 水果 - 热带
      ['菠萝', '水果', '热带水果', 'white'],
      ['芒果', '水果', '热带水果', 'white'],
      ['木瓜', '水果', '热带水果', 'white'],
      ['荔枝', '水果', '热带水果', 'white'],
      ['百香果', '水果', '热带水果', 'white'],
      // 水果 - 核果
      ['桃子', '水果', '核果', 'white'],
      ['杏子', '水果', '核果', 'white'],
      ['苹果', '水果', '核果', 'white'],
      ['梨', '水果', '核果', 'white'],
      // 花香
      ['白花', '花香', '', 'white'],
      ['橙花', '花香', '', 'white'],
      ['槐花', '花香', '', 'white'],
      ['蜂蜜', '花香', '', 'white'],
      // 植物
      ['青草', '植物', '', 'white'],
      ['青苹果', '植物', '', 'white'],
      ['芦笋', '植物', '', 'white'],
      ['矿物', '植物', '', 'white'],
      ['湿石头', '植物', '', 'white'],
      // 橡木/陈年
      ['橡木', '橡木', '', 'white'],
      ['黄油', '橡木', '', 'white'],
      ['吐司', '橡木', '', 'white'],
      ['坚果', '橡木', '', 'white'],
    ];

    // 桃红葡萄酒风味词
    final roseFlavors = [
      ['草莓', '水果', '红色水果', 'rose'],
      ['覆盆子', '水果', '红色水果', 'rose'],
      ['红樱桃', '水果', '红色水果', 'rose'],
      ['西瓜', '水果', '红色水果', 'rose'],
      ['柑橘', '水果', '柑橘类', 'rose'],
      ['葡萄柚', '水果', '柑橘类', 'rose'],
      ['白花', '花香', '', 'rose'],
      ['玫瑰', '花香', '', 'rose'],
      ['蜂蜜', '花香', '', 'rose'],
      ['薄荷', '植物', '', 'rose'],
      ['矿物', '植物', '', 'rose'],
    ];

    // 起泡酒风味词
    final sparklingFlavors = [
      ['青苹果', '水果', '核果', 'sparkling'],
      ['梨', '水果', '核果', 'sparkling'],
      ['柠檬', '水果', '柑橘类', 'sparkling'],
      ['青柠', '水果', '柑橘类', 'sparkling'],
      ['葡萄柚', '水果', '柑橘类', 'sparkling'],
      ['桃子', '水果', '核果', 'sparkling'],
      ['白花', '花香', '', 'sparkling'],
      ['蜂蜜', '花香', '', 'sparkling'],
      ['烤面包', '橡木', '', 'sparkling'],
      ['饼干', '橡木', '', 'sparkling'],
      ['奶油', '橡木', '', 'sparkling'],
      ['坚果', '橡木', '', 'sparkling'],
      ['矿物', '植物', '', 'sparkling'],
      ['酵母', '橡木', '', 'sparkling'],
    ];

    // 甜酒风味词
    final sweetFlavors = [
      ['蜂蜜', '花香', '', 'sweet'],
      ['杏子', '水果', '核果', 'sweet'],
      ['桃子', '水果', '核果', 'sweet'],
      ['芒果', '水果', '热带水果', 'sweet'],
      ['菠萝', '水果', '热带水果', 'sweet'],
      ['橘子酱', '水果', '柑橘类', 'sweet'],
      ['葡萄干', '水果', '干果', 'sweet'],
      ['无花果', '水果', '干果', 'sweet'],
      ['枣子', '水果', '干果', 'sweet'],
      ['焦糖', '橡木', '', 'sweet'],
      ['太妃糖', '橡木', '', 'sweet'],
      ['坚果', '橡木', '', 'sweet'],
      ['生姜', '香料', '', 'sweet'],
      ['藏红花', '香料', '', 'sweet'],
    ];

    for (final f in redFlavors) {
      await db.insert('flavors', {
        'name': f[0], 'category': f[1], 'subcategory': f[2]!.isEmpty ? null : f[2],
        'wineType': f[3], 'isBuiltin': 1, 'createdAt': now,
      });
    }
    for (final f in whiteFlavors) {
      await db.insert('flavors', {
        'name': f[0], 'category': f[1], 'subcategory': f[2]!.isEmpty ? null : f[2],
        'wineType': f[3], 'isBuiltin': 1, 'createdAt': now,
      });
    }
    for (final f in roseFlavors) {
      await db.insert('flavors', {
        'name': f[0], 'category': f[1], 'subcategory': f[2]!.isEmpty ? null : f[2],
        'wineType': f[3], 'isBuiltin': 1, 'createdAt': now,
      });
    }
    for (final f in sparklingFlavors) {
      await db.insert('flavors', {
        'name': f[0], 'category': f[1], 'subcategory': f[2]!.isEmpty ? null : f[2],
        'wineType': f[3], 'isBuiltin': 1, 'createdAt': now,
      });
    }
    for (final f in sweetFlavors) {
      await db.insert('flavors', {
        'name': f[0], 'category': f[1], 'subcategory': f[2]!.isEmpty ? null : f[2],
        'wineType': f[3], 'isBuiltin': 1, 'createdAt': now,
      });
    }

    // 默认存储位置
    final locations = ['酒柜A区', '酒柜B区', '酒窖1层', '酒窖2层', '客厅展示架', '厨房储物柜'];
    for (int i = 0; i < locations.length; i++) {
      await db.insert('storage_locations', {
        'name': locations[i],
        'sortOrder': i,
        'createdAt': now,
      });
    }

    // 默认权重配置
    await db.insert('weight_config', {
      'id': 1,
      'aromaWeight': 0.3,
      'palateWeight': 0.4,
      'overallWeight': 0.3,
      'updatedAt': now,
    });

    // 默认用户配置
    await db.insert('user_profile', {
      'id': 1,
      'nickname': '品酒爱好者',
      'userId': 'wine_${DateTime.now().millisecondsSinceEpoch}',
      'darkMode': 0,
    });
  }

  // ==================== Wine CRUD ====================

  Future<int> insertWine(Wine wine) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('wines', {
      ...wine.toMap(),
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<Wine?> getWine(int id) async {
    final db = await database;
    final maps = await db.query('wines', where: 'id = ? AND isDeleted = 0', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Wine.fromMap(maps.first);
  }

  Future<List<Wine>> getAllWines({String? orderBy}) async {
    final db = await database;
    String? order = orderBy ?? 'updatedAt DESC';
    final maps = await db.query('wines', where: 'isDeleted = 0', orderBy: order);
    return maps.map((m) => Wine.fromMap(m)).toList();
  }

  Future<int> updateWine(Wine wine) async {
    final db = await database;
    return await db.update(
      'wines',
      {...wine.toMap(), 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [wine.id],
    );
  }

  Future<int> softDeleteWine(int id) async {
    final db = await database;
    return await db.update(
      'wines',
      {'isDeleted': 1, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Tasting CRUD ====================

  Future<int> insertTasting(Tasting tasting) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('tastings', {
      ...tasting.toMap(),
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<Tasting?> getTasting(int id) async {
    final db = await database;
    final maps = await db.query('tastings', where: 'id = ? AND isDeleted = 0', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Tasting.fromMap(maps.first);
  }

  Future<List<Tasting>> getTastingsForWine(int wineId) async {
    final db = await database;
    final maps = await db.query(
      'tastings',
      where: 'wineId = ? AND isDeleted = 0',
      whereArgs: [wineId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => Tasting.fromMap(m)).toList();
  }

  Future<List<Tasting>> getAllTastings() async {
    final db = await database;
    final maps = await db.query('tastings', where: 'isDeleted = 0', orderBy: 'createdAt DESC');
    return maps.map((m) => Tasting.fromMap(m)).toList();
  }

  Future<int> updateTasting(Tasting tasting) async {
    final db = await database;
    return await db.update(
      'tastings',
      {...tasting.toMap(), 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [tasting.id],
    );
  }

  // ==================== Appearance CRUD ====================

  Future<int> insertAppearance(TastingAppearance appearance) async {
    final db = await database;
    return await db.insert('tasting_appearance', appearance.toMap());
  }

  Future<TastingAppearance?> getAppearance(int tastingId) async {
    final db = await database;
    final maps = await db.query('tasting_appearance', where: 'tastingId = ?', whereArgs: [tastingId]);
    if (maps.isEmpty) return null;
    return TastingAppearance.fromMap(maps.first);
  }

  Future<int> updateAppearance(TastingAppearance appearance) async {
    final db = await database;
    return await db.update(
      'tasting_appearance',
      appearance.toMap(),
      where: 'id = ?',
      whereArgs: [appearance.id],
    );
  }

  // ==================== Aroma CRUD ====================

  Future<int> insertAroma(TastingAroma aroma) async {
    final db = await database;
    return await db.insert('tasting_aroma', aroma.toMap());
  }

  Future<TastingAroma?> getAroma(int tastingId) async {
    final db = await database;
    final maps = await db.query('tasting_aroma', where: 'tastingId = ?', whereArgs: [tastingId]);
    if (maps.isEmpty) return null;
    return TastingAroma.fromMap(maps.first);
  }

  Future<int> updateAroma(TastingAroma aroma) async {
    final db = await database;
    return await db.update(
      'tasting_aroma',
      aroma.toMap(),
      where: 'id = ?',
      whereArgs: [aroma.id],
    );
  }

  // ==================== Palate CRUD ====================

  Future<int> insertPalate(TastingPalate palate) async {
    final db = await database;
    return await db.insert('tasting_palate', palate.toMap());
  }

  Future<TastingPalate?> getPalate(int tastingId) async {
    final db = await database;
    final maps = await db.query('tasting_palate', where: 'tastingId = ?', whereArgs: [tastingId]);
    if (maps.isEmpty) return null;
    return TastingPalate.fromMap(maps.first);
  }

  Future<int> updatePalate(TastingPalate palate) async {
    final db = await database;
    return await db.update(
      'tasting_palate',
      palate.toMap(),
      where: 'id = ?',
      whereArgs: [palate.id],
    );
  }

  // ==================== Overall CRUD ====================

  Future<int> insertOverall(TastingOverall overall) async {
    final db = await database;
    return await db.insert('tasting_overall', overall.toMap());
  }

  Future<TastingOverall?> getOverall(int tastingId) async {
    final db = await database;
    final maps = await db.query('tasting_overall', where: 'tastingId = ?', whereArgs: [tastingId]);
    if (maps.isEmpty) return null;
    return TastingOverall.fromMap(maps.first);
  }

  Future<int> updateOverall(TastingOverall overall) async {
    final db = await database;
    return await db.update(
      'tasting_overall',
      overall.toMap(),
      where: 'id = ?',
      whereArgs: [overall.id],
    );
  }

  // ==================== Flavor CRUD ====================

  Future<int> insertFlavor(Flavor flavor) async {
    final db = await database;
    return await db.insert('flavors', flavor.toMap());
  }

  Future<List<Flavor>> getFlavorsForWineType(String wineType) async {
    final db = await database;
    final maps = await db.query(
      'flavors',
      where: 'wineType = ?',
      whereArgs: [wineType],
      orderBy: 'category, name',
    );
    return maps.map((m) => Flavor.fromMap(m)).toList();
  }

  Future<List<Flavor>> getAllFlavors() async {
    final db = await database;
    final maps = await db.query('flavors', orderBy: 'wineType, category, name');
    return maps.map((m) => Flavor.fromMap(m)).toList();
  }

  // ==================== TastingFlavor CRUD ====================

  Future<void> addTastingFlavors(int tastingId, List<int> flavorIds) async {
    final db = await database;
    final batch = db.batch();
    for (final fid in flavorIds) {
      batch.insert('tasting_flavors', {
        'tastingId': tastingId,
        'flavorId': fid,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<int>> getTastingFlavors(int tastingId) async {
    final db = await database;
    final maps = await db.query(
      'tasting_flavors',
      where: 'tastingId = ?',
      whereArgs: [tastingId],
    );
    return maps.map((m) => m['flavorId'] as int).toList();
  }

  Future<List<String>> getTastingFlavorNames(int tastingId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT f.name FROM tasting_flavors tf
      JOIN flavors f ON tf.flavorId = f.id
      WHERE tf.tastingId = ?
    ''', [tastingId]);
    return maps.map((m) => m['name'] as String).toList();
  }

  // ==================== Weight Config ====================

  Future<WeightConfig> getWeightConfig() async {
    final db = await database;
    final maps = await db.query('weight_config', where: 'id = 1');
    if (maps.isEmpty) {
      return WeightConfig();
    }
    return WeightConfig.fromMap(maps.first);
  }

  Future<int> updateWeightConfig(WeightConfig config) async {
    final db = await database;
    await db.update(
      'weight_config',
      {
        ...config.toMap(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = 1',
    );

    // 重新计算所有已有品鉴的总分
    await _recalculateAllScores(config);
    return 1;
  }

  Future<void> _recalculateAllScores(WeightConfig config) async {
    final db = await database;
    final tastings = await db.query('tastings', where: 'isDeleted = 0');
    for (final t in tastings) {
      final tastingId = t['id'] as int;

      final aromaMaps = await db.query('tasting_aroma', where: 'tastingId = ?', whereArgs: [tastingId]);
      final palateMaps = await db.query('tasting_palate', where: 'tastingId = ?', whereArgs: [tastingId]);
      final overallMaps = await db.query('tasting_overall', where: 'tastingId = ?', whereArgs: [tastingId]);

      if (aromaMaps.isNotEmpty && palateMaps.isNotEmpty && overallMaps.isNotEmpty) {
        final aroma = TastingAroma.fromMap(aromaMaps.first);
        final palate = TastingPalate.fromMap(palateMaps.first);
        final overall = TastingOverall.fromMap(overallMaps.first);

        final aromaScore = ScoringHelper.calcAromaScore(aroma);
        final palateScore = ScoringHelper.calcPalateScore(palate);
        final overallScore = ScoringHelper.calcOverallScore(overall);

        final total = ScoringHelper.calcTotalScore100(
          aromaScore, palateScore, overallScore,
          config.aromaWeight, config.palateWeight, config.overallWeight,
        );

        await db.update(
          'tastings',
          {'score100': total},
          where: 'id = ?',
          whereArgs: [tastingId],
        );
      }
    }
  }

  // ==================== User Profile ====================

  Future<UserProfile> getUserProfile() async {
    final db = await database;
    final maps = await db.query('user_profile', where: 'id = 1');
    if (maps.isEmpty) {
      return UserProfile();
    }
    return UserProfile.fromMap(maps.first);
  }

  Future<int> updateUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = 1',
    );
  }

  // ==================== Storage Location ====================

  Future<List<StorageLocation>> getStorageLocations() async {
    final db = await database;
    final maps = await db.query('storage_locations', orderBy: 'sortOrder ASC');
    return maps.map((m) => StorageLocation.fromMap(m)).toList();
  }

  Future<int> insertStorageLocation(StorageLocation location) async {
    final db = await database;
    return await db.insert('storage_locations', location.toMap());
  }

  // ==================== Cellar CRUD ====================

  Future<int> insertCellar(Cellar cellar) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final id = await db.insert('cellar', {
      ...cellar.toMap(),
      'createdAt': now,
      'updatedAt': now,
    });
    // 记录入库事务
    await db.insert('cellar_transactions', {
      'cellarId': id,
      'transType': 'add',
      'quantity': cellar.quantity,
      'transDate': cellar.entryDate?.toIso8601String() ?? now,
      'createdAt': now,
    });
    return id;
  }

  Future<List<Map<String, dynamic>>> getCellarItems() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT c.*, w.name as wineName, w.vintage as wineVintage, 
             w.winery as wineWinery, w.wineType as wineType,
             sl.name as locationName
      FROM cellar c
      JOIN wines w ON c.wineId = w.id
      LEFT JOIN storage_locations sl ON c.storageLocationId = sl.id
      WHERE w.isDeleted = 0
      ORDER BY c.updatedAt DESC
    ''');
    return maps;
  }

  Future<Map<String, dynamic>?> getCellarByWineId(int wineId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT c.*, w.name as wineName, w.vintage as wineVintage,
             w.winery as wineWinery, w.wineType as wineType,
             sl.name as locationName
      FROM cellar c
      JOIN wines w ON c.wineId = w.id
      LEFT JOIN storage_locations sl ON c.storageLocationId = sl.id
      WHERE c.wineId = ? AND w.isDeleted = 0
      LIMIT 1
    ''', [wineId]);
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<int> updateCellar(Cellar cellar) async {
    final db = await database;
    return await db.update(
      'cellar',
      {...cellar.toMap(), 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [cellar.id],
    );
  }

  Future<int> deleteCellar(int id) async {
    final db = await database;
    return await db.delete('cellar', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Cellar Transaction ====================

  Future<int> insertCellarTransaction(CellarTransaction transaction) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('cellar_transactions', {
      ...transaction.toMap(),
      'createdAt': now,
    });
  }

  Future<List<CellarTransaction>> getTransactionsForCellar(int cellarId) async {
    final db = await database;
    final maps = await db.query(
      'cellar_transactions',
      where: 'cellarId = ?',
      whereArgs: [cellarId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => CellarTransaction.fromMap(m)).toList();
  }

  // ==================== 统计查询 ====================

  Future<int> getTotalTastings() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tastings WHERE isDeleted = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getAvgScore() async {
    final db = await database;
    final result = await db.rawQuery('SELECT AVG(score100) as avg FROM tastings WHERE isDeleted = 0 AND score100 IS NOT NULL');
    final val = result.first['avg'];
    if (val == null) return 0.0;
    return (val as num).toDouble();
  }

  Future<Map<String, dynamic>?> getHighestScoreWine() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT t.score100, w.name, w.id as wineId
      FROM tastings t
      JOIN wines w ON t.wineId = w.id
      WHERE t.isDeleted = 0 AND w.isDeleted = 0 AND t.score100 IS NOT NULL
      ORDER BY t.score100 DESC
      LIMIT 1
    ''');
    if (result.isEmpty) return null;
    return result.first;
  }

  Future<String?> getFavoriteCountry() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT w.country, COUNT(*) as cnt
      FROM tastings t
      JOIN wines w ON t.wineId = w.id
      WHERE t.isDeleted = 0 AND w.isDeleted = 0 AND w.country IS NOT NULL
      GROUP BY w.country
      ORDER BY cnt DESC
      LIMIT 1
    ''');
    if (result.isEmpty) return null;
    return result.first['country'] as String?;
  }

  Future<String?> getFavoriteRegion() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT w.region, COUNT(*) as cnt
      FROM tastings t
      JOIN wines w ON t.wineId = w.id
      WHERE t.isDeleted = 0 AND w.isDeleted = 0 AND w.region IS NOT NULL
      GROUP BY w.region
      ORDER BY cnt DESC
      LIMIT 1
    ''');
    if (result.isEmpty) return null;
    return result.first['region'] as String?;
  }

  Future<String?> getFavoriteVariety() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT w.variety, COUNT(*) as cnt
      FROM tastings t
      JOIN wines w ON t.wineId = w.id
      WHERE t.isDeleted = 0 AND w.isDeleted = 0 AND w.variety IS NOT NULL
      GROUP BY w.variety
      ORDER BY cnt DESC
      LIMIT 1
    ''');
    if (result.isEmpty) return null;
    return result.first['variety'] as String?;
  }

  Future<double> getTotalSpent() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(price) as total FROM wines WHERE isDeleted = 0');
    final val = result.first['total'];
    if (val == null) return 0.0;
    return (val as num).toDouble();
  }

  Future<List<Map<String, dynamic>>> getScoreTrend() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT strftime('%Y-%m', createdAt) as month,
             AVG(score100) as avgScore,
             COUNT(*) as count
      FROM tastings
      WHERE isDeleted = 0 AND score100 IS NOT NULL
      GROUP BY strftime('%Y-%m', createdAt)
      ORDER BY month ASC
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getCountryDistribution() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT w.country, COUNT(*) as count
      FROM wines w
      WHERE w.isDeleted = 0 AND w.country IS NOT NULL
      GROUP BY w.country
      ORDER BY count DESC
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getRegionDistribution() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT w.region, COUNT(*) as count
      FROM wines w
      WHERE w.isDeleted = 0 AND w.region IS NOT NULL
      GROUP BY w.region
      ORDER BY count DESC
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getVarietyDistribution() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT w.variety, COUNT(*) as count
      FROM wines w
      WHERE w.isDeleted = 0 AND w.variety IS NOT NULL
      GROUP BY w.variety
      ORDER BY count DESC
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getPriceScoreData() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT w.price, t.score100
      FROM tastings t
      JOIN wines w ON t.wineId = w.id
      WHERE t.isDeleted = 0 AND w.isDeleted = 0
        AND w.price IS NOT NULL AND t.score100 IS NOT NULL
      ORDER BY w.price ASC
    ''');
    return result;
  }

  // ==================== Tasting Photo CRUD ====================

  Future<int> insertTastingPhoto(int tastingId, String photoPath, {int sortOrder = 0}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('tasting_photos', {
      'tastingId': tastingId,
      'photoPath': photoPath,
      'sortOrder': sortOrder,
      'createdAt': now,
    });
  }

  Future<List<Map<String, dynamic>>> getTastingPhotos(int tastingId) async {
    final db = await database;
    return await db.query(
      'tasting_photos',
      where: 'tastingId = ?',
      whereArgs: [tastingId],
      orderBy: 'sortOrder ASC',
    );
  }

  /// 获取某款酒所有品鉴关联的照片（跨所有品鉴记录）
  Future<List<Map<String, dynamic>>> getAllPhotosForWine(int wineId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT tp.*, t.drinkingDate
      FROM tasting_photos tp
      INNER JOIN tastings t ON tp.tastingId = t.id
      WHERE t.wineId = ? AND t.isDeleted = 0
      ORDER BY t.drinkingDate DESC, tp.sortOrder ASC
    ''', [wineId]);
  }

  /// 批量获取多款酒的第一张照片路径
  /// 返回 Map<wineId, firstPhotoPath>
  Future<Map<int, String?>> getFirstPhotoForWines(List<int> wineIds) async {
    if (wineIds.isEmpty) return {};
    final db = await database;
    // 用子查询取每个 wineId 的第一张照片
    final placeholders = wineIds.map((_) => '?').join(',');
    final rows = await db.rawQuery('''
      SELECT t.wineId, MIN(tp.id) as firstPhotoId, tp.photoPath
      FROM tasting_photos tp
      INNER JOIN tastings t ON tp.tastingId = t.id
      WHERE t.wineId IN ($placeholders) AND t.isDeleted = 0
      GROUP BY t.wineId
    ''', wineIds);
    final result = <int, String?>{};
    for (final row in rows) {
      result[row['wineId'] as int] = row['photoPath'] as String?;
    }
    return result;
  }

  Future<void> deleteTastingPhoto(int id) async {
    final db = await database;
    await db.delete('tasting_photos', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== 搜索 ====================

  Future<List<Wine>> searchWines(String query) async {
    final db = await database;
    final pattern = '%$query%';
    final maps = await db.query(
      'wines',
      where: 'isDeleted = 0 AND (name LIKE ? OR winery LIKE ? OR country LIKE ? OR region LIKE ? OR variety LIKE ?)',
      whereArgs: [pattern, pattern, pattern, pattern, pattern],
      orderBy: 'name ASC',
    );
    return maps.map((m) => Wine.fromMap(m)).toList();
  }

  // ==================== 导出/导入 ====================

  Future<void> exportToJson(String path) async {
    final db = await database;
    await backup.exportToJson(db, path);
  }

  Future<void> importFromJson(String path) async {
    final db = await database;
    await backup.importFromJson(db, path);
  }

  // ==================== 备份/恢复 ====================

  Future<void> backupDatabase(String path) async {
    await backup.backupDatabase(path,
      getDbPath: () async => p.join(await getDatabasesPath(), 'wine_journal_pro.db'),
    );
  }

  Future<void> restoreDatabase(String path) async {
    // 关闭当前数据库连接
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final dbPath = p.join(await getDatabasesPath(), 'wine_journal_pro.db');
    await backup.restoreDatabase(path,
      getDbPath: () async => dbPath,
      openDb: (dbPath) async => await openDatabase(dbPath),
    );
    // 重新打开
    _database = await openDatabase(dbPath);
  }
}
