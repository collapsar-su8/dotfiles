# ============================================================
# 帮助打印
# ============================================================
# 提示语里的调用者路径用 ${DOTCTL_SELF:-$0} 而不是裸 $0：
# Python 侧通过 `bash -c ... source install.sh` 调用，此时 $0 必须与
# BASH_SOURCE[0] 不同，否则 install.sh 顶层的「是否直接执行」守卫会误判成
# 直接执行并跑起 main，吃掉这次调用。
print_help() {
    cat <<EOF
sijin-xb's dotfiles 安装器 —— 版本 ${RICE_VERSION}

用法：
  ${DOTCTL_SELF:-$0}                     TUI 菜单
  ${DOTCTL_SELF:-$0} install             完整安装（7 步）
                                         默认不升级系统；FULL_UPGRADE=1 则先 pacman -Syu
  ${DOTCTL_SELF:-$0} update              增量同步文件层
  ${DOTCTL_SELF:-$0} rollback            还原到上次 install 之前
  ${DOTCTL_SELF:-$0} restore             撤销 rollback
  ${DOTCTL_SELF:-$0} archive [-o 路径]   打包配置、状态、缓存为 tar.gz
  ${DOTCTL_SELF:-$0} uninstall           卸载（可先存档）
  ${DOTCTL_SELF:-$0} status              部署状态：会话、清单、版本、快照、占用
  ${DOTCTL_SELF:-$0} doctor              环境体检：缺包、配置缺失、QML 模块
  ${DOTCTL_SELF:-$0} deps [--missing]    依赖包列表
  ${DOTCTL_SELF:-$0} theme               图标、光标、GTK 主题在 9 个位置的取值
  ${DOTCTL_SELF:-$0} clean [--all]       清理临时残留

status / doctor / deps / theme 只读。

单文件运行：
  只下载 install.sh 也能跑。它会 clone 仓库到 ~/.local/share/dotfiles-src，
  再用仓库里那份重新执行：

    curl -fsSL https://raw.githubusercontent.com/sijin-xb/dotfiles/main/install.sh \\
        | bash -s -- update

  DOTFILES_REPO_URL=...   换仓库地址
  DOTFILES_SRC_DIR=...    换缓存位置
  rm -rf ~/.local/share/dotfiles-src   重置缓存

环境变量：

  SESSION=end4pc
      选择会话。美化包只提供 end4pc：Hyprland + quickshell（end4-PC 底盘，
      本包的 collapsar-su8/end4-pC fork）。入口 ~/.config/hypr/hyprland.lua、
      ~/.config/quickshell/end4-pC。

      Caelestia QML 插件会编译到 ~/src/caelestia-build
      （end4-PC 的锁屏依赖 import Caelestia.Config）。

      旧值 caelestia / dms / niri 已移除，给了会警告并回退 end4pc。
      不设置时直接使用 end4pc。

  COMPOSITOR=hyprland
      旧写法，等价于 SESSION=end4pc；niri 不再支持。

  INSTALL_BOTH_COMPOSITORS=1
      两套合成器配置都部署。

  FONTS=0|1
      是否安装推荐字体（pacman 字体包、AUR 字体链、霞鹜臻楷 GB，并移除
      65-wqy-zenhei.conf）。

      不设置   到时交互询问 [Y/n]
      0        不碰任何字体包
      1        直接装

      非交互执行时兜底为 1。TUI 的「执行安装」页按 f 切换。

  FULL_UPGRADE=1
      安装时执行 pacman -Syu 全系统升级。默认只装缺失项。

update 选项：
  --dry-run          只打印计划，不写文件
  --pull             先 git pull
  --with-packages    补齐新增依赖（只补不卸）
  --no-prune         不清理仓库已删除的文件
  --force            版本号没变也执行
  --yes, -y          不交互确认

  部署清单记录新增 / 更新 / 删除，存放在
  ~/.local/state/dotfiles-backup/state/deployed-<shell>-<comp>.tsv。
  删除项移到 $BACKUP_ROOT/update-<时间戳>/removed/，不直接 rm。
  升级前自动快照，出问题用 rollback 还原。

archive 选项：
  -o PATH            输出路径
  --delete           打包后清理源文件

环境要求：
  Arch 系（/etc/arch-release 存在）
  Wayland 会话
  普通用户执行，需 sudo 权限装包

目录：
  ~/.config/hypr/hyprland.lua       Hyprland 入口
  ~/.config/hypr/custom/            用户差异层（blur、阴影等）
  ~/.config/hypr/hyprland/shellOverrides/   quickshell 设置面板写入的值
  ~/.config/quickshell/end4-pC/     quickshell 底盘与差异层
  ~/.config/quickshell/caelestia/   caelestia shell
  ~/.config/niri/config.kdl         niri 入口
  ~/.local/state/dotfiles-backup/   回档、卸载存档、备份

常见问题：
  回档后想回到 rice           → ${DOTCTL_SELF:-$0} restore
  存档默认位置                → ~/dotfiles-archive-YYYYMMDD-HHMMSS.tar.gz
  面板模糊太浓                → quickshell 设置 → Hyprland：模糊半径 10→8，活动不透明度 82→88

EOF
}
