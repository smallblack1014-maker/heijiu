# Web 适配完成 & GitHub 仓库初始化

## 2026-06-20

## 完成的工作

### 1. 修复 `sqflite_web` 包名错误
- 原 `sqflite_web: ^0.4.0+1` 不存在，替换为正确的 `sqflite_common_ffi_web: ^1.0.0`
- 因 `web` 包版本冲突，同步升级 `share_plus: ^10.0.0`

### 2. main.dart 更新
- `sqflite_web` → `sqflite_common_ffi_web/sqflite_ffi_web.dart`
- `databaseFactoryWeb` → `databaseFactoryFfiWeb`

### 3. 运行 Web 设置
- `flutter pub run sqflite_common_ffi_web:setup --force` 成功
- 生成 `web/sqflite_sw.js` (255KB) + `web/sqlite3.wasm` (713KB)
- sqflite 浏览器端通过 IndexedDB 持久化，共享 Worker 实现跨标签页安全

### 4. Web 构建 ✅
- `flutter build web --release` 成功
- 完整的构建产物在 `build/web/`
- 包含 PWA service worker、CanvasKit、字体摇树优化

### 5. PWA 配置
- `web/manifest.json` 创建：standalone 模式，酒红色主题
- `web/index.html` 自定义：启动加载动画（酒杯 emoji + spinner）

### 6. GitHub 仓库初始化
- `.gitignore` 创建
- GitHub Actions 工作流 `.github/workflows/deploy.yml`：push main 时自动 build web → deploy 到 GitHub Pages
- Git 已 init + commit（commit 002e6d3）

## pubspec.yaml 最终依赖变动
- ❌ `sqflite_web: ^0.4.0+1` → ✅ `sqflite_common_ffi_web: ^1.0.0`
- ❌ `flutter_image_compress` → 已移除（不再需要）
- 🔼 `share_plus: ^9.0.0` → `^10.0.0`（解决 `web` 包版本冲突）

## 项目路径
- 源码: `C:\Users\86150\.qclaw\workspace\wine_journal_pro\flutter_app`
- Git: `C:\Users\86150\.qclaw\workspace\wine_journal_pro`
- 构建产物: `flutter_app\build\web\`

## 下一步（用户需操作）
1. 在 GitHub 创建新仓库（public），仓库名建议 `heijiu`
2. 推送本地仓库：
   ```
   git remote add origin https://github.com/<你的用户名>/heijiu.git
   git push -u origin main
   ```
3. 在 GitHub 仓库 Settings → Pages 中：
   - Source 选 "GitHub Actions"（而非分支）
4. 等待 Actions 自动构建完成，即可通过 `https://<用户名>.github.io/heijiu/` 访问
