import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/wine.dart';
import '../models/cellar.dart';
import '../models/storage_location.dart';
import '../theme/app_theme.dart';

class CellarAddScreen extends StatefulWidget {
  final Wine? prefilledWine;

  const CellarAddScreen({super.key, this.prefilledWine});

  @override
  State<CellarAddScreen> createState() => _CellarAddScreenState();
}

class _CellarAddScreenState extends State<CellarAddScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  final _searchController = TextEditingController();

  Wine? _selectedWine;
  List<Wine> _searchResults = [];
  List<StorageLocation> _locations = [];
  int? _selectedLocationId;
  DateTime? _purchaseDate;
  DateTime? _entryDate;
  int? _drinkFrom;
  int? _drinkTo;
  bool _isNewWine = false;
  bool _isLoading = true;

  // 新建酒款字段
  final _newNameController = TextEditingController();
  final _newWineryController = TextEditingController();
  final _newVarietyController = TextEditingController();
  String _newWineType = 'red';

  @override
  void initState() {
    super.initState();
    _entryDate = DateTime.now();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _searchController.dispose();
    _newNameController.dispose();
    _newWineryController.dispose();
    _newVarietyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final locations = await _db.getStorageLocations();
    setState(() {
      _locations = locations;
      _selectedLocationId = locations.isNotEmpty ? locations.first.id : null;
      _selectedWine = widget.prefilledWine;
      _isLoading = false;
    });
  }

  Future<void> _searchWines(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final results = await _db.searchWines(query);
    setState(() => _searchResults = results);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    int wineId;

    if (_isNewWine) {
      // 新建酒款
      if (_newNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入酒名'), backgroundColor: Colors.red),
        );
        return;
      }
      wineId = await _db.insertWine(Wine(
        name: _newNameController.text.trim(),
        winery: _newWineryController.text.isNotEmpty ? _newWineryController.text : null,
        variety: _newVarietyController.text.isNotEmpty ? _newVarietyController.text : null,
        wineType: _newWineType,
      ));
    } else if (_selectedWine != null) {
      wineId = _selectedWine!.id!;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择或新建酒款'), backgroundColor: Colors.red),
      );
      return;
    }

    final qty = int.tryParse(_quantityController.text) ?? 1;
    final price = double.tryParse(_priceController.text);

    await _db.insertCellar(Cellar(
      wineId: wineId,
      storageLocationId: _selectedLocationId ?? 1,
      entryDate: _entryDate,
      quantity: qty,
      purchasePrice: price,
      purchaseDate: _purchaseDate,
      drinkFrom: _drinkFrom,
      drinkTo: _drinkTo,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('入库成功！')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('新增入库')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('新增入库'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 酒款选择
              if (widget.prefilledWine == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('选择已有酒款'),
                        selected: !_isNewWine,
                        onSelected: (v) => setState(() => _isNewWine = !v),
                        selectedColor: AppTheme.wineRed,
                        labelStyle: TextStyle(color: !_isNewWine ? Colors.white : null),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('新建酒款'),
                        selected: _isNewWine,
                        onSelected: (v) => setState(() => _isNewWine = v),
                        selectedColor: AppTheme.wineRed,
                        labelStyle: TextStyle(color: _isNewWine ? Colors.white : null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              if (_isNewWine) ...[
                // 新建酒款表单
                TextFormField(
                  controller: _newNameController,
                  decoration: const InputDecoration(labelText: '酒名 *', prefixIcon: Icon(Icons.wine_bar)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? '请输入酒名' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _newWineryController,
                        decoration: const InputDecoration(labelText: '酒庄'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _newVarietyController,
                        decoration: const InputDecoration(labelText: '品种'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _newWineType,
                  decoration: const InputDecoration(labelText: '类型', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'red', child: Text('红葡萄酒')),
                    DropdownMenuItem(value: 'white', child: Text('白葡萄酒')),
                    DropdownMenuItem(value: 'rose', child: Text('桃红葡萄酒')),
                    DropdownMenuItem(value: 'sparkling', child: Text('起泡酒')),
                    DropdownMenuItem(value: 'sweet', child: Text('甜酒')),
                  ],
                  onChanged: (v) => setState(() => _newWineType = v ?? 'red'),
                ),
              ] else ...[
                // 搜索已有酒款
                if (widget.prefilledWine == null) ...[
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索酒款...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: _searchWines,
                  ),
                  const SizedBox(height: 8),
                  if (_searchResults.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView(
                        children: _searchResults.map((w) => RadioListTile<Wine>(
                          title: Text(w.name),
                          subtitle: w.winery != null ? Text(w.winery!) : null,
                          value: w,
                          groupValue: _selectedWine,
                          onChanged: (v) {
                            setState(() {
                              _selectedWine = v;
                              _searchResults = [];
                              _searchController.clear();
                            });
                          },
                        )).toList(),
                      ),
                    ),
                ],
                if (_selectedWine != null) ...[
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_bar, color: AppTheme.wineRed),
                      title: Text(_selectedWine!.name),
                      subtitle: Text('${_selectedWine!.winery ?? ""} ${_selectedWine!.vintage ?? ""}'),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 20),

              // 入库信息
              const Text('入库信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: '数量', prefixIcon: Icon(Icons.numbers)),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return '请输入数量';
                        final n = int.tryParse(v);
                        if (n == null || n <= 0) return '数量必须大于0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: '单价',
                        prefixIcon: Icon(Icons.attach_money),
                        hintText: '¥',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 存储位置
              DropdownButtonFormField<int>(
                value: _selectedLocationId,
                decoration: const InputDecoration(
                  labelText: '存储位置',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                items: _locations.map((l) =>
                  DropdownMenuItem(value: l.id, child: Text(l.name)),
                ).toList(),
                onChanged: (v) => setState(() => _selectedLocationId = v),
              ),
              const SizedBox(height: 12),

              // 购买日期
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _purchaseDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _purchaseDate = date);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '购买日期',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _purchaseDate != null
                        ? '${_purchaseDate!.year}-${_purchaseDate!.month.toString().padLeft(2, '0')}-${_purchaseDate!.day.toString().padLeft(2, '0')}'
                        : '请选择',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 饮用窗口
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: '最早饮用年份',
                        hintText: '如: 2025',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _drinkFrom = int.tryParse(v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: '最晚饮用年份',
                        hintText: '如: 2030',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _drinkTo = int.tryParse(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 备注
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '备注',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // 保存按钮
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('确认入库', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
