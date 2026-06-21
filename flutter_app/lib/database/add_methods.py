import sys
sys.stdout.reconfigure(encoding='utf-8')

content = '''  // ==================== Delete Methods (for edit mode) ====================

  Future<void> deleteAppearance(int tastingId) async {
    final db = await database;
    await db.delete('tasting_appearance', where: 'tastingId = ?', whereArgs: [tastingId]);
  }

  Future<void> deleteAroma(int tastingId) async {
    final db = await database;
    await db.delete('tasting_aroma', where: 'tastingId = ?', whereArgs: [tastingId]);
  }

  Future<void> deletePalate(int tastingId) async {
    final db = await database;
    await db.delete('tasting_palate', where: 'tastingId = ?', whereArgs: [tastingId]);
  }

  Future<void> deleteOverall(int tastingId) async {
    final db = await database;
    await db.delete('tasting_overall', where: 'tastingId = ?', whereArgs: [tastingId]);
  }

  Future<void> deleteTastingFlavors(int tastingId) async {
    final db = await database;
    await db.delete('tasting_flavors', where: 'tastingId = ?', whereArgs: [tastingId]);
  }

  Future<Wine?> findWineByName(String name) async {
    final db = await database;
    final maps = await db.query(
      'wines',
      where: 'name = ? AND isDeleted = 0',
      whereArgs: [name],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Wine.fromMap(maps.first);
  }

  Future<void> deleteTastingPhotos(int tastingId) async {
    final db = await database;
    await db.delete('tasting_photos', where: 'tastingId = ?', whereArgs: [tastingId]);
  }
'''

with open(r'C:\Users\86150\.qclaw\workspace\wine_journal_pro\flutter_app\lib\database\add_methods.txt', 'w', encoding='utf-8') as f:
    f.write(content)
print("Written successfully")
