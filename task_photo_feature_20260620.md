# 黑酒 APP - 拍照功能实现

## 目标
在品鉴记录中增加拍照功能：拍照记录酒款照片，品鉴时压缩存储，详情页展示。

## 修改文件清单

### 1. 数据库层 (`database_helper.dart`)
- 新增 `tasting_photos` 表（id, tastingId, photoPath, sortOrder, createdAt）
- 新增方法：`insertTastingPhoto()`、`getTastingPhotos()`、`deleteTastingPhoto()`

### 2. 图片工具 (`utils/image_utils.dart`，新建 1394 bytes)
- `ImageUtils.pickImage(ImageSource source)` — 拍照/相册选图
- `ImageUtils.compressAndSave(File file)` — 压缩至 800px 宽、80% 质量，存入 app 缓存目录

### 3. 品鉴表单 (`screens/tasting_form_screen.dart`, 51760 bytes)
- 导入 `dart:io`、`image_picker`
- 新增 `_photoFiles` 状态变量
- 新增 `_buildPhotoSection()` — 照片网格展示 + 添加按钮
- 新增 `_showPhotoSourceDialog()` — 选择拍照或相册
- `_saveTasting()` 中循环保存压缩照片
- 页面退出时清理 `_photoFiles`（File/deletion）

### 4. 品鉴详情页 (`screens/wine_detail_screen.dart`, 16520 bytes)
- 导入 `dart:io`
- `_loadData()` 加载每一条品鉴的 `photos`
- `_TastingRecordCard` 展开后展示横向滚动照片缩略图
- 点击照片弹出 `InteractiveViewer` 全屏看大图（支持双指缩放）
- `errorBuilder` 处理照片文件丢失情况

## 依赖
- `image_picker: ^1.1.0`（已在 pubspec.yaml）
- `flutter_image_compress: ^2.3.0`（新增）
- `path_provider: ^2.1.0`（已在）
- `uuid: ^4.4.0`（已在）

## 构建
当前环境 Flutter SDK 未安装，无法在此构建 APK。
需在本地 Flutter 环境下执行：
```bash
cd wine_journal_pro/flutter_app
flutter pub get
flutter build apk --release
```
