# collapsar-su8 美化包（Hyprland + Quickshell）

基于 [sijin-xb/dotfiles](https://github.com/sijin-xb/dotfiles) 与
[pctrade/end4-PC](https://github.com/pctrade/end4-PC)（上游
[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)）深度整合精简的
**Arch + Wayland 美化包**，只保留一套会话：

> **end4pc** — Hyprland + Quickshell（end4-PC 底盘）

## 与上游的差异（本包存在的理由）

### 架构：深度整合 + 双仓库

- [collapsar-su8/end4-pC](https://github.com/collapsar-su8/end4-pC) — **底盘 fork**：
  完整 shell，包含本包的美化修复（下节）
- [collapsar-su8/dotfiles](https://github.com/collapsar-su8/dotfiles)（本仓库）—
  **差异层 + 主题 + 安装器**：
  - 删掉了与上游逐字节相同的 747 个 vendor 文件（安装时从底盘 fork 拉取，瘦 61%）
  - 只保留真正改过的 117 个文件 + 362 个自研模块（灵动岛、仪表盘、桌面歌词等）
  - 删掉 caelestia / dms（niri）两套会话的全部配置内容，安装器会话固定 end4pc
  - 删掉约 250 MB 内置壁纸 → [docs/WALLPAPERS.md](docs/WALLPAPERS.md) 外链清单
  - 安装器底盘 URL 指向自己的 end4-pC fork

### 可读性修复（默认生效）

原版玻璃效果在亮壁纸上文字几乎不可读，本包做了三层修复，全部经过
WCAG 对比度实测：

1. **玻璃加厚**：面板底色 alpha 0.4 → **0.7**（`glassContentTransparency 0.6 → 0.3`）。
   这是白字灾难的总根因——原版自动透明度会把玻璃调到 10% 不透明度。
2. **关闭自动透明度**：出厂 config.json 固定 `contentTransparency: 0.3`，
   不再被自动模式拉薄。
3. **数字统一固定墨色**（深浅主题各一档）：
   - 深色主题 `#DDE1E6`，浅色主题 `#2E3238`
   - 实测对玻璃（alpha 0.7）叠黑/白/中灰壁纸的合成底，对比度全部 ≥4.6（WCAG AA 4.5）
   - 玻璃关闭（实体面板）时自动回退主题原色
   - 实现位置：`Appearance.colors.numberInkOnGlass`（底盘 + 差异层各一份）、
     `StyledText` 默认色、`custom-island/Theme.qml` 的 `numberInk`

### 侧栏半高

右侧栏从整屏高改为 **可用区上半（约半屏）**（`height: parent.height * 0.5`）。
比例式高度在 200% 等缩放下自动正确（QML 逻辑像素缩放无关）。
通知区本身是内部滚动的 ListView，固定区块超出半屏时由新加的
Flickable 兜底滚动；编辑模式（拖拽排序）下滚动自动禁用。

### 移除在线壁纸源

壁纸选择器只保留本地目录（Unsplash / Pexels / Wallhaven / Blapples / NA-ive
五个在线源已删除，含对应 service 文件）。壁纸请按
[docs/WALLPAPERS.md](docs/WALLPAPERS.md) 手动下载到 `~/Pictures/Wallpapers/`。

## 安装

```bash
git clone https://github.com/collapsar-su8/dotfiles.git
cd dotfiles
./install.sh              # TUI 菜单
./install.sh install      # 完整安装（7 步，开始前自动快照）
```

- 壁纸外链：按 [docs/WALLPAPERS.md](docs/WALLPAPERS.md) 下载
- 字体可选：`FONTS=0` 不碰任何字体包
- 旧的 `SESSION=caelestia / dms / niri` 已移除，给了会警告并回退 end4pc

## 日常使用

| 命令 | 作用 |
|---|---|
| `./install.sh update` | 增量同步文件层（日常升级用这个，**不要重跑 install**） |
| `./install.sh rollback` | 还原到 pre-install 快照 |
| `./install.sh restore` | 撤销回档 |
| `./install.sh status` / `doctor` / `deps` / `theme` | 只读体检四件套 |
| `./install.sh archive` / `uninstall` / `clean` | 打包 / 卸载 / 清理 |

`update` 选项：`--dry-run`（只打印计划）、`--with-packages`（补齐新增依赖）、
`--pull`（先 git pull）等，完整见 `./install.sh --help`。

## 测试

改 `install.sh` 或 `lib/` 之后跑（无需 sudo / 网络 / 真实包管理器）：

```bash
bash tests/install-sh-behaviour-test.sh
bash tests/install-sh-dryrun.sh
bash tests/install-sh-cli-test.sh
bash tests/install-sh-prompt-test.sh
bash tests/install-sh-tmpfiles-test.sh
bash tests/install-sh-archive-test.sh
python3 -m unittest discover -s tests -p 'test_*.py' -t .
```

## 致谢与许可证

- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) — 上游的上游
- [pctrade/end4-PC](https://github.com/pctrade/end4-PC) — 直接上游（底盘）
- [sijin-xb/dotfiles](https://github.com/sijin-xb/dotfiles) — 本仓库的直接来源，
  安装器/快照/测试体系与自研 Quickshell 模块均出自该项目
- [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia) —
  锁屏移植来源；[soramanew/m3shapes](https://github.com/soramanew/m3shapes) —
  形变动画依赖

许可证 [GPL-3.0](LICENSE)，与全部上游一致。作为衍生作品保留上游版权与致谢，
对修改部分负责。
