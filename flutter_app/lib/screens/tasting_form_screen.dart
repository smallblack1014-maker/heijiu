import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/wine.dart';
import '../models/tasting.dart';
import '../models/tasting_appearance.dart';
import '../models/tasting_aroma.dart';
import '../models/tasting_palate.dart';
import '../models/tasting_overall.dart';
import '../models/tasting_flavor.dart';
import '../models/flavor.dart';
import '../models/weight_config.dart';
import '../models/wine_region_data.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/scoring_helper.dart';
import '../utils/wine_type_helper.dart';
import '../utils/image_utils.dart';
import '../widgets/rating_slider.dart';
import '../widgets/flavor_chip.dart';

class TastingFormScreen extends StatefulWidget {
  final String wineType;

  const TastingFormScreen({super.key, this.wineType = 'red'});

  @override
  State<TastingFormScreen> createState() => _TastingFormScreenState();
}

class _TastingFormScreenState extends State<TastingFormScreen> {
  static const Duration _animDuration = Duration(milliseconds: 300);
  static const Curve _animCurve = Curves.easeInOut;

  // ─── Wine Info ───
  final _nameController = TextEditingController();
  String? _selectedCountry = '';
  String? _selectedRegion = '';
  String? _selectedVariety = '';
  String? _selectedVintage = 'NV (无年份)';
  List<String> _availableRegions = [];
  final _wineryController = TextEditingController();
  final _alcoholController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _drinkingDate;
  DateTime? _purchaseDate;
  final _venueController = TextEditingController();

  // ─── Blind Tasting ───
  bool _isBlind = false;
  String _scoringMode = 'standard';

  // ─── Appearance ───
  String? _appearanceColor;
  String? _appearanceClarity;
  String? _appearanceIntensity;
  String? _appearanceCondition;
  String? _appearanceTears;
  String? _appearanceBubbleFineness;
  String? _appearanceBubblePersistence;

  // ─── Aroma ───
  double? _aromaIntensity;
  double? _aromaCondition;
  double? _aromaDevelopment;

  // ─── Flavors ───
  List<String> _selectedFlavors = [];
  String _flavorSearch = '';
  String _flavorCategory = '全部';
  final _newFlavorController = TextEditingController();

  // ─── Palate ───
  double? _palateAcidity;
  double? _palateTannin;
  double? _palateBody;
  double? _palateBalance;
  double? _palateComplexity;
  double? _palateFinish;
  double? _palateTexture;
  double? _palateCharacter;
  double? _palateAlcohol;

  // ─── Overall ───
  double? _overallTypicality;
  double? _overallEnjoyment;
  double? _overallValue;
  double? _overallAging;
  double? _overallRepurchase;
  String? _overallAgingAdvice;

  // ─── Flavor Data ───
  List<String> _availableFlavors = [];
  List<Flavor> _flavors = [];
  WeightConfig _weightConfig = WeightConfig();

  // ─── Photos ───
  List<Uint8List> _photoFiles = [];

  // ─── Saving State ───
  bool _isSaving = false;

  // ─── Flavor Category Filter Options ───
  List<String> get _flavorCategories => ['全部', '水果', '花香', '香料', '植物', '橡木'];

  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final db = DatabaseHelper();
    // Load flavors for the selected wine type
    final flavors = await db.getFlavorsForWineType(widget.wineType);
    final weightConfig = await db.getWeightConfig();
    if (mounted) {
      setState(() {
        _flavors = flavors;
        _availableFlavors = flavors.map((f) => f.name).toList();
        _weightConfig = weightConfig;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wineryController.dispose();
    _alcoholController.dispose();
    _priceController.dispose();
    _venueController.dispose();
    _notesController.dispose();
    _newFlavorController.dispose();
    super.dispose();
  }

  // ─── Score Preview ───

  double? get _previewScore {
    if (_scoringMode == 'quick') {
      // Quick mode: use overall enjoyment × 10
      if (_overallEnjoyment != null) {
        return (_overallEnjoyment! * 10).roundToDouble();
      }
      return null;
    }

    // Standard / Professional mode
    final double aromaScore;
    final double palateScore;
    final double overallScore;

    if (_aromaIntensity != null || _aromaCondition != null || _aromaDevelopment != null) {
      aromaScore = ((_aromaIntensity ?? 0) + (_aromaCondition ?? 0) + (_aromaDevelopment ?? 0)) / 3.0;
    } else {
      aromaScore = 0;
    }

    if (_palateAcidity != null || _palateTannin != null || _palateBody != null) {
      palateScore = ((_palateAcidity ?? 0) +
              (_palateTannin ?? 0) +
              (_palateBody ?? 0) +
              (_palateBalance ?? 0) +
              (_palateComplexity ?? 0) +
              (_palateFinish ?? 0)) /
          6.0;
    } else {
      palateScore = 0;
    }

    if (_overallTypicality != null || _overallEnjoyment != null) {
      overallScore = ((_overallTypicality ?? 0) +
              (_overallEnjoyment ?? 0) +
              (_overallValue ?? 0) +
              (_overallAging ?? 0) +
              (_overallRepurchase ?? 0)) /
          5.0;
    } else {
      overallScore = 0;
    }

    final total = aromaScore * _weightConfig.aromaWeight +
        palateScore * _weightConfig.palateWeight +
        overallScore * _weightConfig.overallWeight;

    if (total > 0) {
      return (total * 10).roundToDouble();
    }
    return null;
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${WineTypeHelper.getLabel(widget.wineType)} - 品鉴记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '评分说明',
            onPressed: _showScoringGuide,
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── TOP BAR: Wine type tag + Blind + Scoring Mode ───
                _buildTopBar(),
                const SizedBox(height: 16),

                // ─── PHOTO SECTION ───
                _buildSectionTitle('拍照记录'),
                _buildPhotoSection(),
                const SizedBox(height: 12),

                // ─── WINE INFO SECTION ───
                _buildSectionTitle('酒款信息'),
                AnimatedSize(
                  duration: _animDuration,
                  curve: _animCurve,
                  alignment: Alignment.topCenter,
                  child: _isBlind
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              label: '酒款名称',
                              hint: '输入葡萄酒名称',
                              icon: Icons.wine_bar,
                              required: true,
                            ),
                            _buildCountryField(),
                            _buildRegionField(),
                            _buildWineryField(),
                            _buildVarietyField(),
                            _buildVintageField(),
                            _buildAlcoholPriceRow(),
                            _buildDateRow(),
                            _buildTextField(
                              controller: _venueController,
                              label: '品鉴场所',
                              hint: '餐厅/酒庄/家中...',
                              icon: Icons.place,
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),

                // ─── APPEARANCE SCORING ───
                _buildSectionTitle('外观评分'),
                _buildAppearanceSection(),
                const SizedBox(height: 12),

                // ─── AROMA SCORING ───
                if (_scoringMode != 'quick') ...[
                  _buildSectionTitle('香气评分'),
                  _buildAromaSection(),
                  const SizedBox(height: 12),
                ],

                // ─── FLAVOR WORDS ───
                if (_scoringMode != 'quick') ...[
                  _buildSectionTitle('风味词（可选）'),
                  _buildFlavorSection(),
                  const SizedBox(height: 12),
                ],

                // ─── PALATE SCORING ───
                _buildSectionTitle('口感评分'),
                _buildPalateSection(),
                const SizedBox(height: 12),

                // ─── OVERALL SCORING ───
                _buildSectionTitle('综合评分'),
                _buildOverallSection(),
                const SizedBox(height: 12),

                // ─── SCORE PREVIEW ───
                if (_previewScore != null) _buildScorePreview(),

                // ─── NOTES ───
                _buildSectionTitle('品鉴笔记'),
                _buildNoteSection(),
                const SizedBox(height: 16),

                // ─── SAVE BUTTON ───
                _buildSaveButton(),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Top Bar ───

  Widget _buildTopBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                // Wine type tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: WineTypeHelper.getColor(widget.wineType),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    WineTypeHelper.getLabel(widget.wineType),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // Blind mode
                const Text('盲品', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Switch(
                  value: _isBlind,
                  onChanged: (v) => setState(() => _isBlind = v),
                  activeColor: AppTheme.wineRed,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Scoring mode selector
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'quick', label: Text('快速'), icon: Icon(Icons.speed)),
                ButtonSegment(value: 'standard', label: Text('标准'), icon: Icon(Icons.tune)),
                ButtonSegment(value: 'professional', label: Text('专业'), icon: Icon(Icons.science)),
              ],
              selected: {_scoringMode},
              onSelectionChanged: (v) => setState(() => _scoringMode = v.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppTheme.wineRed.withValues(alpha: 0.15),
                selectedForegroundColor: AppTheme.wineRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Photo Section ───

  Widget _buildPhotoSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._photoFiles.map((f) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  f,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => setState(() => _photoFiles.remove(f)),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
        GestureDetector(
          onTap: _showPhotoSourceDialog,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 28, color: Colors.grey),
                SizedBox(height: 4),
                Text('添加照片', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPhotoSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('添加照片', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.wineRed,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('拍照'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.wineRed,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('从相册选择'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final result = await ImageUtils.pickImage(source);
      if (result != null && mounted) {
        final compressed = ImageUtils.compressBytes(result.bytes);
        setState(() => _photoFiles.add(compressed));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择照片失败: $e')),
        );
      }
    }
  }

  // ─── Section Title ───

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.wineRed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Text Field ───

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String hint = '',
    IconData? icon,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: AppTheme.wineRed) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.wineRed, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ─── Dropdown Field ───

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return AnimatedSize(
      duration: _animDuration,
      curve: _animCurve,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          menuMaxHeight: 320,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: icon != null ? Icon(icon, color: AppTheme.wineRed) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.wineRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ─── Country ───

  Widget _buildCountryField() {
    return _buildDropdownField(
      label: '国家',
      value: _selectedCountry,
      items: WineRegionData.countries,
      icon: Icons.public,
      onChanged: (v) {
        setState(() {
          _selectedCountry = v;
          _selectedRegion = '';
          _wineryController.clear();
          _availableRegions = v != null ? WineRegionData.getRegionsForCountry(v) : [];
        });
      },
    );
  }

  // ─── Region ───

  Widget _buildRegionField() {
    return _buildDropdownField(
      label: '产区',
      value: _selectedRegion,
      items: _availableRegions,
      icon: Icons.terrain,
      onChanged: (v) {
        setState(() {
          _selectedRegion = v;
          _selectedVariety = '';
          _wineryController.clear();
        });
      },
    );
  }

  // ─── Winery ───

  Widget _buildWineryField() {
    return _buildTextField(
      controller: _wineryController,
      label: '酒庄/酒厂',
      hint: '输入酒庄名称',
      icon: Icons.business,
    );
  }

  /// 动态品种选项：基础品种 + 根据当前国家/产区推荐的混酿
  List<String> get _varietyOptions {
    final varieties = [...WineRegionData.allGrapeVarieties];
    final country = _selectedCountry ?? '';
    final region = _selectedRegion;
    // 推荐混酿名称（如'波尔多红混酿'）作为选项加入
    final blends = WineRegionData.getRecommendedBlends(
      country.isNotEmpty ? country : '',
      (region != null && region.isNotEmpty) ? region : null,
    );
    for (final b in blends) {
      if (!varieties.contains(b)) varieties.add(b);
    }
    // 也加入所有混酿名称（方便手动选其他混酿）
    for (final b in WineRegionData.classicBlends.keys) {
      if (!varieties.contains(b)) varieties.add(b);
    }
    varieties.sort();
    return varieties;
  }

  // ─── Variety ───

  Widget _buildVarietyField() {
    return _buildDropdownField(
      label: '葡萄品种',
      value: _selectedVariety,
      items: _varietyOptions,
      icon: Icons.agriculture,
      onChanged: (v) {
        setState(() => _selectedVariety = v);
      },
    );
  }

  // ─── Vintage ───

  Widget _buildVintageField() {
    return _buildDropdownField(
      label: '年份',
      value: _selectedVintage,
      items: WineRegionData.getVintageYears(),
      icon: Icons.calendar_today,
      onChanged: (v) => setState(() => _selectedVintage = v),
    );
  }

  // ─── Alcohol + Price Row ───

  Widget _buildAlcoholPriceRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _alcoholController,
            label: '酒精度',
            hint: '如: 13.5',
            icon: Icons.percent,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTextField(
            controller: _priceController,
            label: '价格 (元)',
            hint: '如: 298',
            icon: Icons.monetization_on,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
      ],
    );
  }

  // ─── Date Row ───

  Widget _buildDateRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildDateField(
              label: '购买日期',
              value: _purchaseDate,
              onChanged: (v) => setState(() => _purchaseDate = v),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDateField(
              label: '品鉴日期',
              value: _drinkingDate,
              onChanged: (v) => setState(() => _drinkingDate = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1980),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppTheme.wineRed,
                  ),
            ),
            child: child!,
          ),
        );
        if (date != null) onChanged(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.date_range, color: AppTheme.wineRed),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.wineRed, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Text(
          value != null ? DateFormat('yyyy-MM-dd').format(value) : '选择日期',
          style: TextStyle(
            color: value != null ? AppTheme.textPrimary : Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ─── Appearance Section ───

  Widget _buildAppearanceSection() {
    final wineType = widget.wineType;
    final isSparkling = wineType == 'sparkling';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color
            _buildAppearanceDropdown(
              label: '颜色',
              value: _appearanceColor,
              options: WineTypeHelper.getColorsForType(wineType),
              onChanged: (v) => setState(() => _appearanceColor = v),
            ),
            // Clarity
            _buildAppearanceDropdown(
              label: '清澈度',
              value: _appearanceClarity,
              options: WineTypeHelper.getClarityOptions(),
              onChanged: (v) => setState(() => _appearanceClarity = v),
            ),
            // Intensity
            _buildAppearanceDropdown(
              label: '浓度',
              value: _appearanceIntensity,
              options: WineTypeHelper.getIntensityOptions(),
              onChanged: (v) => setState(() => _appearanceIntensity = v),
            ),
            // Condition
            _buildAppearanceDropdown(
              label: '状态',
              value: _appearanceCondition,
              options: WineTypeHelper.getConditionOptions(),
              onChanged: (v) => setState(() => _appearanceCondition = v),
            ),
            // Tears (for still wines)
            if (!isSparkling)
              _buildAppearanceDropdown(
                label: '挂杯',
                value: _appearanceTears,
                options: WineTypeHelper.getTearsOptions(),
                onChanged: (v) => setState(() => _appearanceTears = v),
              ),
            // Sparkling-specific
            if (isSparkling) ...[
              _buildAppearanceDropdown(
                label: '气泡细腻度',
                value: _appearanceBubbleFineness,
                options: WineTypeHelper.getBubbleFinenessOptions(),
                onChanged: (v) => setState(() => _appearanceBubbleFineness = v),
              ),
              _buildAppearanceDropdown(
                label: '气泡持久度',
                value: _appearanceBubblePersistence,
                options: WineTypeHelper.getBubblePersistenceOptions(),
                onChanged: (v) => setState(() => _appearanceBubblePersistence = v),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: options.contains(value) ? value : null,
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Aroma Section ───

  Widget _buildAromaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRatingSlider(
              label: '香气浓度',
              value: _aromaIntensity,
              onChanged: (v) => setState(() => _aromaIntensity = v.toDouble()),
            ),
            _buildRatingSlider(
              label: '香气复杂度',
              value: _aromaCondition,
              onChanged: (v) => setState(() => _aromaCondition = v.toDouble()),
            ),
            _buildRatingSlider(
              label: '香气持久度',
              value: _aromaDevelopment,
              onChanged: (v) => setState(() => _aromaDevelopment = v.toDouble()),
            ),
            if (_scoringMode == 'professional') ...[
              const SizedBox(height: 8),
              _buildAppearanceDropdown(
                label: '发展状态',
                value: null,
                options: WineTypeHelper.getDevelopmentOptions(),
                onChanged: (v) {
                  // Development stage in professional mode
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Rating Slider ───

  Widget _buildRatingSlider({
    required String label,
    required double? value,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppTheme.wineRed,
                inactiveTrackColor: AppTheme.wineRed.withValues(alpha: 0.2),
                thumbColor: AppTheme.wineRed,
                overlayColor: AppTheme.wineRed.withValues(alpha: 0.1),
                valueIndicatorColor: AppTheme.wineRed,
                valueIndicatorTextStyle: const TextStyle(color: Colors.white),
              ),
              child: Slider(
                value: (value ?? 0),
                min: 0,
                max: 10,
                divisions: 10,
                label: (value ?? 0).toStringAsFixed(0),
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showScoreInputDialog(label, (value ?? 0).toInt(), onChanged),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (value ?? 0) > 0 ? AppTheme.wineRed.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (value ?? 0).toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: (value ?? 0) > 0 ? AppTheme.wineRed : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScoreInputDialog(String label, int currentValue, ValueChanged<int> onChanged) {
    final controller = TextEditingController(text: currentValue.toString());
    showDialog(
      context: context,
      builder: (ctx) {
        // Controller lifecycle managed within dialog builder
        return AlertDialog(
          title: Text('输入$label分数'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '输入 0-10 的数字',
              suffixText: '/ 10',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final val = int.tryParse(controller.text);
                if (val != null && val >= 0 && val <= 10) {
                  onChanged(val);
                }
                Navigator.pop(ctx);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    ).then((_) {
      controller.dispose();
    });
  }

  // ─── Flavor Section ───

  Widget _buildFlavorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: '搜索风味词...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _flavorSearch = v),
            ),
            const SizedBox(height: 8),
            // Category filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _flavorCategories.map((cat) {
                  final isSelected = _flavorCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
                      selected: isSelected,
                      selectedColor: AppTheme.wineRed,
                      onSelected: (v) => setState(() => _flavorCategory = cat),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Flavor chips
            FlavorChipBuilder(
              flavors: _flavors.where((f) {
                if (_flavorCategory != '全部' && f.category != _flavorCategory) return false;
                if (_flavorSearch.isNotEmpty &&
                    !f.name.toLowerCase().contains(_flavorSearch.toLowerCase())) return false;
                return true;
              }).toList(),
              selectedIds: _flavors
                  .where((f) => _selectedFlavors.contains(f.name) && f.id != null)
                  .map((f) => f.id!)
                  .toList(),
              onSelectionChanged: (ids) {
                setState(() {
                  _selectedFlavors = _flavors
                      .where((f) => f.id != null && ids.contains(f.id))
                      .map((f) => f.name)
                      .toList();
                });
              },
              searchQuery: _flavorSearch,
              onAddCustom: _showAddCustomFlavorDialog,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddCustomFlavorDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('自定义风味词'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newFlavorController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '输入风味词名称',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_newFlavorController.text.trim().isNotEmpty) {
                Navigator.pop(ctx, _newFlavorController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.wineRed),
            child: const Text('添加', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final db = DatabaseHelper();
        final newFlavor = Flavor(
          name: result,
          category: _flavorCategory == '全部' ? '水果' : _flavorCategory,
          subcategory: null,
          wineType: widget.wineType,
          isBuiltin: 0,
          createdAt: DateTime.now(),
        );
        final id = await db.insertFlavor(newFlavor);
        if (mounted) {
          setState(() {
            _flavors.add(Flavor(
              id: id,
              name: result,
              category: _flavorCategory == '全部' ? '水果' : _flavorCategory,
              wineType: widget.wineType,
              isBuiltin: 0,
              createdAt: DateTime.now(),
            ));
            _selectedFlavors.add(result);
            _newFlavorController.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加风味词失败: $e')),
          );
        }
      }
    }
  }

  // ─── Palate Section ───

  Widget _buildPalateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRatingSlider(
              label: '酸度',
              value: _palateAcidity,
              onChanged: (v) => setState(() => _palateAcidity = v.toDouble()),
            ),
            _buildRatingSlider(
              label: '单宁',
              value: _palateTannin,
              onChanged: (v) => setState(() => _palateTannin = v.toDouble()),
            ),
            _buildRatingSlider(
              label: '酒体',
              value: _palateBody,
              onChanged: (v) => setState(() => _palateBody = v.toDouble()),
            ),
            _buildRatingSlider(
              label: '平衡感',
              value: _palateBalance,
              onChanged: (v) => setState(() => _palateBalance = v.toDouble()),
            ),
            _buildRatingSlider(
              label: '复杂度',
              value: _palateComplexity,
              onChanged: (v) => setState(() => _palateComplexity = v.toDouble()),
            ),
            _buildRatingSlider(
              label: '余味长度',
              value: _palateFinish,
              onChanged: (v) => setState(() => _palateFinish = v.toDouble()),
            ),
            if (_scoringMode == 'professional') ...[
              _buildRatingSlider(
                label: '口感质地',
                value: _palateTexture,
                onChanged: (v) => setState(() => _palateTexture = v.toDouble()),
              ),
              _buildRatingSlider(
                label: '品种特色',
                value: _palateCharacter,
                onChanged: (v) => setState(() => _palateCharacter = v.toDouble()),
              ),
              _buildRatingSlider(
                label: '酒精感',
                value: _palateAlcohol,
                onChanged: (v) => setState(() => _palateAlcohol = v.toDouble()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Overall Section ───

  Widget _buildOverallSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRatingSlider(
              label: '典型性',
              value: _overallTypicality,
              onChanged: (v) => setState(() => _overallTypicality = v.toDouble()),
            ),
            _buildRatingSlider(
              label: '享受程度',
              value: _overallEnjoyment,
              onChanged: (v) => setState(() => _overallEnjoyment = v.toDouble()),
            ),
            _buildRatingSlider(
              label: '性价比',
              value: _overallValue,
              onChanged: (v) => setState(() => _overallValue = v.toDouble()),
            ),
            _buildRatingSlider(
              label: '陈年潜力',
              value: _overallAging,
              onChanged: (v) => setState(() => _overallAging = v.toDouble()),
            ),
            _buildRatingSlider(
              label: '回购意愿',
              value: _overallRepurchase,
              onChanged: (v) => setState(() => _overallRepurchase = v.toDouble()),
            ),
            if (_scoringMode == 'professional') ...[
              const SizedBox(height: 8),
              _buildAppearanceDropdown(
                label: '陈年建议',
                value: _overallAgingAdvice,
                options: WineTypeHelper.getAgingAdviceOptions(),
                onChanged: (v) => setState(() => _overallAgingAdvice = v),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Score Preview ───

  Widget _buildScorePreview() {
    final score = _previewScore ?? 0;
    return Card(
      color: AppTheme.wineRed.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text(
                  '预估总分',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  score.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.wineRed,
                  ),
                ),
                const Text(
                  '/ 100',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Notes Section ───

  Widget _buildNoteSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: '输入品鉴笔记（可选）\n提示: 保存后将根据评分自动生成笔记',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.wineRed, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Save Button ───

  Widget _buildSaveButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveTasting,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save),
        label: Text(_isSaving ? '保存中...' : '保存品鉴记录'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.wineRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.wineRed.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ─── Scoring Guide ───

  void _showScoringGuide() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('评分说明'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('评分体系', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text('• 快速模式：仅综合评分（1个维度）'),
              Text('• 标准模式：香气 + 口感 + 综合（3个维度）'),
              Text('• 专业模式：含香气发展状态、口感质地等'),
              SizedBox(height: 12),
              Text('评分规则', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text('各项满分 10 分，加权计算后转换为百分制：'),
              SizedBox(height: 4),
              Text('• 香气权重: 30%'),
              Text('• 口感权重: 40%'),
              Text('• 综合权重: 30%'),
              SizedBox(height: 4),
              Text('可在「个人中心 → 评分权重设置」中调整'),
              SizedBox(height: 12),
              Text('评分范围', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text('• 0-3: 不受欢迎/有缺陷'),
              Text('• 4-5: 普通/可以接受'),
              Text('• 6-7: 良好/推荐'),
              Text('• 8-9: 优秀/强烈推荐'),
              Text('• 10: 完美/卓越之作'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  // ─── Save Tasting ───

  Future<void> _saveTasting() async {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入酒款名称'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = DatabaseHelper();

      // 1. Save wine
      final wineId = await db.insertWine(Wine(
        name: _nameController.text.trim(),
        winery: _wineryController.text.isNotEmpty ? _wineryController.text.trim() : null,
        country: _selectedCountry,
        region: _selectedRegion,
        variety: _selectedVariety,
        vintage: _selectedVintage != null && _selectedVintage != 'NV (无年份)'
            ? int.tryParse(_selectedVintage!)
            : null,
        alcohol: double.tryParse(_alcoholController.text),
        price: double.tryParse(_priceController.text),
        wineType: widget.wineType,
        photoPath: null,
        createdAt: DateTime.now(),
        isDeleted: 0,
      ));

      // 2. Save tasting
      final tasting = Tasting(
        wineId: wineId,
        scoringMode: _scoringMode,
        isBlind: _isBlind ? 1 : 0,
        isRevealed: _isBlind ? 0 : 1,
        drinkingDate: _drinkingDate,
        purchaseDate: _purchaseDate,
        venue: _venueController.text.isNotEmpty ? _venueController.text.trim() : null,
        score100: _previewScore?.round(),
        notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
        createdAt: DateTime.now(),
        isDeleted: 0,
      );
      final tastingId = await db.insertTasting(tasting);

      // 3. Save appearance scoring
      if (_appearanceColor != null ||
          _appearanceClarity != null ||
          _appearanceIntensity != null ||
          _appearanceCondition != null) {
        final appearance = TastingAppearance(
          tastingId: tastingId,
          color: _appearanceColor,
          clarity: _appearanceClarity,
          intensity: _appearanceIntensity,
          condition: _appearanceCondition,
          tears: _appearanceTears,
          bubbleFineness: _appearanceBubbleFineness,
          bubblePersistence: _appearanceBubblePersistence,
        );
        await db.insertAppearance(appearance);
      }

      // 4. Save aroma scoring
      if (_aromaIntensity != null || _aromaCondition != null || _aromaDevelopment != null) {
        final aroma = TastingAroma(
          tastingId: tastingId,
          intensity: _aromaIntensity?.round() ?? 0,
          complexity: _aromaCondition?.round() ?? 0,
          persistence: _aromaDevelopment?.round() ?? 0,
          purity: ((_aromaIntensity ?? 0) + (_aromaCondition ?? 0) + (_aromaDevelopment ?? 0) / 3)
              .round(),
          development: null,
        );
        await db.insertAroma(aroma);
      }

      // 5. Save flavor selections
      if (_selectedFlavors.isNotEmpty) {
        final flavorIds = _flavors
            .where((f) => f.id != null && _selectedFlavors.contains(f.name))
            .map((f) => f.id!)
            .toList();
        if (flavorIds.isNotEmpty) {
          await db.addTastingFlavors(tastingId, flavorIds);
        }
      }

      // 6. Save palate scoring
      if (_palateAcidity != null ||
          _palateTannin != null ||
          _palateBody != null ||
          _palateBalance != null ||
          _palateComplexity != null ||
          _palateFinish != null) {
        final palate = TastingPalate(
          tastingId: tastingId,
          acidity: _palateAcidity?.round() ?? 0,
          tannin: _palateTannin?.round() ?? 0,
          body: _palateBody?.round() ?? 0,
          balance: _palateBalance?.round() ?? 0,
          complexity: _palateComplexity?.round() ?? 0,
          finishLength: _palateFinish?.round() ?? 0,
        );
        await db.insertPalate(palate);
      }

      // 7. Save overall scoring
      if (_overallTypicality != null ||
          _overallEnjoyment != null ||
          _overallValue != null ||
          _overallAging != null ||
          _overallRepurchase != null) {
        final overall = TastingOverall(
          tastingId: tastingId,
          typicality: _overallTypicality?.round() ?? 0,
          enjoyment: _overallEnjoyment?.round() ?? 0,
          value: _overallValue?.round() ?? 0,
          agingPotential: _overallAging?.round() ?? 0,
          agingAdvice: _overallAgingAdvice,
          repurchase: _overallRepurchase?.round() ?? 0,
        );
        await db.insertOverall(overall);
      }

      // 8. Save photos as data URLs
      for (int i = 0; i < _photoFiles.length; i++) {
        final dataUrl = ImageUtils.bytesToDataUrl(_photoFiles[i]);
        await db.insertTastingPhoto(tastingId, dataUrl, sortOrder: i);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存成功！'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
