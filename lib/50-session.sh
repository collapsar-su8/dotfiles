# ============================================================
# 会话选择（美化包只保留 end4pc）与 FONTS 交互
# ============================================================
# ---------- 会话选择：合成器 + 桌面 Shell ----------
# 美化包精简后只提供一套会话：
#   end4-pC   Hyprland + quickshell（end4-PC 底盘，本包的 collapsar-su8/end4-pC fork）
#             入口 ~/.config/hypr/hyprland.lua + ~/.config/quickshell/end4-pC
#
# Caelestia QML 插件（end4-pC 锁屏的硬依赖）：源码在
# ~/src/caelestia-plugin-src，编译到 ~/src/caelestia-build。
# fish/config.fish 与 start_quickshell.sh 两处读 QML2_IMPORT_PATH，
# 换位置要同步改这两处。
#
# 环境变量预设：SESSION=end4pc ./install.sh install
# 旧值 caelestia / dms / niri 已移除，给了会警告并回退 end4pc。
SESSION="${SESSION:-}"        # end4pc
COMPOSITOR="${COMPOSITOR:-}"  # hyprland（由 SESSION 派生，部署过滤/卸载仍用它）
QS_SHELL="${QS_SHELL:-}"      # end4-pC（由 SESSION 派生）

# 1=装 / 0=跳过 / 空=执行时询问。脚本化时用 FONTS=0。
FONTS="${FONTS:-}"
FONTS_ASKED=0                 # 1 = 已经问过/已定，choose_fonts 不再重复问

# SESSION → COMPOSITOR + QS_SHELL。
# COMPOSITOR 仍被部署过滤、卸载范围、完成指引使用，必须从 SESSION 派生。
# 未知值不静默吞掉：显式警告并回退默认。
session_to_parts() {
    case "$SESSION" in
        end4pc)    COMPOSITOR=hyprland; QS_SHELL=end4-pC ;;
        *)
            [[ -n "$SESSION" ]] && warn "未知的 SESSION 预设值 '$SESSION'（美化包只支持 end4pc），按默认 end4pc 处理"
            SESSION=end4pc; COMPOSITOR=hyprland; QS_SHELL=end4-pC ;;
    esac
}

choose_session() {
    # 美化包只提供 end4pc 会话。旧的 caelestia / dms / niri 预设值给警告并回退。
    if [[ "$SESSION" == caelestia || "$SESSION" == dms ]]; then
        warn "美化包已移除 caelestia / dms 会话，回退 end4pc"
        SESSION=""
    fi
    if [[ "$COMPOSITOR" == niri ]]; then
        warn "美化包已移除 niri/DMS 会话，回退 end4pc"
        COMPOSITOR=""
    fi
    if [[ -z "$SESSION" && -n "$COMPOSITOR" ]]; then
        SESSION=end4pc
    fi
    session_to_parts
    echo "    会话: $SESSION → 合成器 $COMPOSITOR + shell $QS_SHELL"
}

# ---------- 字体开关（FONTS=1 装 / 0 跳过 / 空=询问） ----------
fonts_enabled() { [[ "${FONTS:-1}" == "1" ]]; }

fonts_label() {
    if fonts_enabled; then printf '安装推荐字体'; else printf '跳过（不改动系统字体）'; fi
}

fonts_toggle() {
    if fonts_enabled; then FONTS=0; else FONTS=1; fi
    FONTS_ASKED=1
}

# 只问一次：FONTS 预设 → 非 tty 兜底 → 交互询问。
# 问过就把 FONTS_ASKED 置 1，TUI 与 cmd_install 共用同一个选择，不会问两遍。
choose_fonts() {
    if ((FONTS_ASKED)); then return 0; fi
    FONTS_ASKED=1
    case "${FONTS,,}" in
        1|y|yes|true)  FONTS=1; echo "    字体: 安装推荐字体（FONTS 预设）"; return 0 ;;
        0|n|no|false)  FONTS=0; echo "    字体: 跳过，不改动系统字体（FONTS 预设）"; return 0 ;;
    esac
    # 非交互（管道 / 重定向 / 后台执行）不能停下来问，默认装、显式 FONTS=0 可关。
    if [[ ! -t 0 ]]; then
        FONTS=1
        echo "    字体: 非交互运行，默认安装（FONTS=0 可跳过）"
        return 0
    fi
    local ans=""
    printf '    安装推荐字体？（MiSans / Maple Mono NF / 霞鹜文楷 / Noto CJK，约 200MB）[Y/n] '
    read_answer ans
    case "${ans,,}" in
        n|no) FONTS=0; echo "    字体: 跳过，不改动系统字体" ;;
        *)    FONTS=1; echo "    字体: 安装推荐字体" ;;
    esac
}

# 会话推断（原在 lib/83-cmd-status.sh，status 迁到 Python 后挪过来 ——
# doctor / deps 仍在 bash 侧共用它）。
# 会话来源：优先读部署时写下的 deployed-session —— 那才代表**机器现状**；
# 环境变量只是「这次想装什么」，没有部署记录时才退回它推断。
# 副作用：会把 QS_SHELL / COMPOSITOR 设成当前生效值，后续函数（manifest_path
# 等）依赖它们，所以每个命令开头都要先调一次。
status_resolve_session() {
    local sp; sp="$(session_path)"
    if [[ -s "$sp" ]]; then
        IFS='|' read -r QS_SHELL COMPOSITOR < "$sp"
    else
        session_to_parts
    fi
}

status_session_label() {
    case "${QS_SHELL:-}:${COMPOSITOR:-}" in
        end4-pC:hyprland)  printf 'end4pc（Hyprland + quickshell end4-PC）' ;;
        caelestia:hyprland) printf 'caelestia（Hyprland + caelestia shell）' ;;
        dms:niri)          printf 'dms（niri + DankMaterialShell）' ;;
        *)                 printf '%s + %s' "${QS_SHELL:-未知}" "${COMPOSITOR:-未知}" ;;
    esac
}
