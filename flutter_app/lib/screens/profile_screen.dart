import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../database/database_helper.dart';
import '../providers/app_state.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../utils/image_utils.dart';
import 'weight_setting_screen.dart';
import 'cellar_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadProfile();
    });
  }

  Future<void> _showAvatarPicker(AppState appState) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('更换头像'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            child: const ListTile(
              leading: Icon(Icons.camera_alt, color: AppTheme.wineRed),
              title: Text('拍照'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            child: const ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.wineRed),
              title: Text('从相册选择'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (appState.userProfile.avatarPath != null)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, null),
              child: const ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('移除头像'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );

    if (source == null) {
      if (appState.userProfile.avatarPath != null) {
        appState.updateProfile(appState.userProfile.copyWith(avatarPath: null));
      }
      return;
    }

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final compressed = ImageUtils.compressBytes(bytes, maxWidth: 256, quality: 80);
        final avatarPath = ImageUtils.bytesToDataUrl(compressed);

        appState.updateProfile(appState.userProfile.copyWith(avatarPath: avatarPath));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('头像更新成功'), duration: Duration(seconds: 1)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择头像失败: $e')),
        );
      }
    }
  }

  Future<void> _showNicknameEditDialog(AppState appState) async {
    final controller = TextEditingController(text: appState.userProfile.nickname ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改昵称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入您的昵称',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      appState.updateProfile(appState.userProfile.copyWith(nickname: result));
    }
  }

  Future<void> _exportData() async {
    final format = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('导出数据'),
        children: [
          const SimpleDialogOption(
            child: ListTile(
              leading: Icon(Icons.description, color: AppTheme.wineRed),
              title: Text('导出为 JSON'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );

    if (format == null) return;

    try {
      if (kIsWeb) throw UnsupportedError('导出功能在浏览器版中不可用');
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: '选择导出位置',
        fileName: 'wine_journal_export.json',
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        await _db.exportToJson(outputFile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('数据已导出到: $outputFile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  Future<void> _importData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入数据'),
        content: const Text('导入将覆盖当前所有数据，此操作不可撤销。确定继续？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确认导入', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (kIsWeb) throw UnsupportedError('导入功能在浏览器版中不可用');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        await _db.importFromJson(result.files.single.path!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('数据导入成功！')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  Future<void> _backupDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('备份数据库'),
        content: const Text('将创建当前数据库的完整备份文件。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('开始备份')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (kIsWeb) throw UnsupportedError('备份功能在浏览器版中不可用');
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: '保存备份文件',
        fileName: 'wine_journal_backup.db',
        allowedExtensions: ['db'],
      );

      if (outputFile != null) {
        await _db.backupDatabase(outputFile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('备份已保存到: $outputFile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('备份失败: $e')),
        );
      }
    }
  }

  Future<void> _restoreDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('警告：恢复数据库'),
        content: const Text('恢复操作将覆盖所有当前数据且不可撤销！\n\n请确认您已经备份了当前数据。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认恢复', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (kIsWeb) throw UnsupportedError('恢复功能在浏览器版中不可用');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowedExtensions: ['db'],
      );

      if (result != null && result.files.single.path != null) {
        await _db.restoreDatabase(result.files.single.path!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('数据库恢复成功！请重启应用')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('恢复失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final profile = appState.userProfile;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 头像和昵称（可编辑）
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _showAvatarPicker(context.read<AppState>()),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppTheme.wineRed.withValues(alpha: 0.1),
                        backgroundImage: profile.avatarPath != null
                            ? _resolveAvatar(profile.avatarPath!)
                            : null,
                        child: profile.avatarPath == null
                            ? Text(
                                (profile.nickname ?? '?')[0],
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.wineRed,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.wineRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showNicknameEditDialog(context.read<AppState>()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        profile.nickname ?? '品酒爱好者',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
                if (profile.userId != null)
                  Text(
                    'ID: ${profile.userId}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                const SizedBox(height: 24),

                // 功能菜单
                _buildMenuSection('数据管理', [
                  _buildMenuItem(Icons.file_upload, '导出数据', () => _exportData()),
                  _buildMenuItem(Icons.file_download, '导入数据', () => _importData()),
                  _buildMenuItem(Icons.backup, '备份数据库', () => _backupDatabase()),
                  _buildMenuItem(Icons.restore, '恢复数据库', () => _restoreDatabase()),
                ]),
                const SizedBox(height: 12),
                _buildMenuSection('设置', [
                  _buildMenuItem(Icons.tune, '权重设置', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WeightSettingScreen()));
                  }),
                  _buildMenuItem(Icons.wine_bar, '酒窖管理', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CellarScreen()));
                  }),
                ]),
                const SizedBox(height: 12),
                _buildMenuSection('关于', [
                  _buildMenuItem(Icons.info, '关于黑酒', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                  }),
                ]),
                const SizedBox(height: 32),
                Text(
                  '黑酒 Wine Journal v1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Get the appropriate ImageProvider for avatar (data URL only)
  ImageProvider<Object> _resolveAvatar(String path) {
    if (ImageUtils.isDataUrl(path)) {
      return MemoryImage(ImageUtils.dataUrlToBytes(path));
    }
    return MemoryImage(Uint8List(0));
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          ...items,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.wineRed),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
