#!/usr/bin/env python3
# =============================================================================
# show_keybindings.py — Arch-Boki keybindings viewer
# Dear PyGui — Everforest theme — two tabs: SXHKD | Chadwm
# =============================================================================

import re
import sys
from pathlib import Path

try:
    import dearpygui.dearpygui as dpg
except ImportError:
    print("dearpygui not installed. Run: pip install dearpygui", file=sys.stderr)
    sys.exit(1)

# ── Paths ─────────────────────────────────────────────────────────────────────
HOME     = Path.home()
SXHKDRC  = HOME / ".config/chadwm-boki/sxhkd/sxhkdrc"
CONFIG_H = HOME / ".config/chadwm-boki/chadwm-boki/config.def.h"

# ── Everforest palette (RGBA 0-255) ───────────────────────────────────────────
BG      = (35,  42,  46,  255)   # #232a2e  — main background
BG2     = (45,  53,  59,  255)   # #2d353b  — secondary background
FG      = (168, 158, 136, 255)   # #a89e88  — foreground text
GREEN   = (167, 192, 128, 255)   # #a7c080  — key binding highlight
BLUE    = (127, 187, 179, 255)   # #7fbbb3  — accent
AQUA    = (131, 192, 146, 255)   # #83c092  — title
RED     = (230, 126, 128, 255)   # #e67e80  — warning
HEADER  = (56,  65,  71,  255)   # slightly lighter BG
SEL     = (60,  72,  67,  255)   # selection
BORDER  = (88,  104, 117, 255)   # #586375  — borders
DIM     = (120, 115, 100, 255)   # #787364  — dimmed text

# ── Parsers ───────────────────────────────────────────────────────────────────
def parse_sxhkdrc(path: Path) -> list[tuple[str, str]]:
    rows: list[tuple[str, str]] = []
    if not path.exists():
        return rows
    key = ""
    with open(path) as f:
        for raw in f:
            line = raw.rstrip("\n")
            if line.startswith("#") or line.strip() == "":
                continue
            if not line[0].isspace():
                key = line.strip()
            else:
                cmd = line.strip()
                if key and cmd:
                    rows.append((key, cmd))
    return rows


def parse_config_h(path: Path) -> list[tuple[str, str]]:
    rows: list[tuple[str, str]] = []
    if not path.exists():
        return rows
    pat = re.compile(
        r'\{\s*(MODKEY[^,]*?)\s*,\s*XK_([a-zA-Z0-9_]+)\s*,\s*([a-zA-Z0-9_]+)'
    )
    with open(path) as f:
        for line in f:
            m = pat.search(line)
            if m:
                mod = m.group(1).strip()
                key = m.group(2)
                cmd = m.group(3)
                rows.append((f"{mod} + {key}", cmd))
    return rows


# ── Global state ──────────────────────────────────────────────────────────────
_data:       dict[str, list[tuple[str, str]]] = {}
_table_tags: dict[str, int | str] = {}
_count_tags: dict[str, int | str] = {}


# ── Filter callback ───────────────────────────────────────────────────────────
def _on_filter(sender, app_data, user_data):
    tab_key = user_data
    query   = (app_data or "").lower().strip()
    table   = _table_tags[tab_key]

    # Remove all data rows (slot 1), keep column headers (slot 0)
    dpg.delete_item(table, children_only=True, slot=1)

    matched = 0
    for k, cmd in _data[tab_key]:
        if not query or query in k.lower() or query in cmd.lower():
            with dpg.table_row(parent=table):
                dpg.add_text(k,   color=GREEN)
                dpg.add_text(cmd, color=FG)
            matched += 1

    if _count_tags.get(tab_key):
        total = len(_data[tab_key])
        if query:
            dpg.set_value(_count_tags[tab_key], f"{matched} / {total} bindings")
        else:
            dpg.set_value(_count_tags[tab_key], f"{total} bindings")


# ── Tab builder ───────────────────────────────────────────────────────────────
def _build_tab(label: str, icon: str, rows: list[tuple[str, str]]) -> None:
    tab_key = label
    _data[tab_key] = rows
    total = len(rows)

    with dpg.tab(label=f"{icon}  {label}  ({total})"):

        with dpg.group(horizontal=True):
            dpg.add_input_text(
                tag=f"filter_{tab_key}",
                hint="  Search keybindings…",
                width=-120,
                callback=_on_filter,
                user_data=tab_key,
            )
            dpg.add_spacer(width=8)
            _count_tags[tab_key] = dpg.add_text(
                f"{total} bindings",
                color=DIM,
            )

        dpg.add_spacer(height=6)

        if total == 0:
            dpg.add_text(
                f"  No file found — expected:\n  {SXHKDRC if 'SXHKD' in label else CONFIG_H}",
                color=RED,
            )
            return

        with dpg.table(
            tag=f"table_{tab_key}",
            header_row=True,
            borders_innerH=True,
            borders_innerV=True,
            borders_outerH=True,
            borders_outerV=True,
            row_background=True,
            resizable=True,
            scrollY=True,
            height=-1,
            policy=dpg.mvTable_SizingStretchProp,
        ) as tbl:
            _table_tags[tab_key] = tbl
            dpg.add_table_column(label="  Key Binding",      init_width_or_weight=0.38)
            dpg.add_table_column(label="  Command / Action", init_width_or_weight=0.62)

            for k, cmd in rows:
                with dpg.table_row():
                    dpg.add_text(k,   color=GREEN)
                    dpg.add_text(cmd, color=FG)


# ── Theme ─────────────────────────────────────────────────────────────────────
def _apply_theme() -> None:
    with dpg.theme() as global_theme:
        with dpg.theme_component(dpg.mvAll):
            # Backgrounds
            dpg.add_theme_color(dpg.mvThemeCol_WindowBg,          BG)
            dpg.add_theme_color(dpg.mvThemeCol_ChildBg,           BG2)
            dpg.add_theme_color(dpg.mvThemeCol_PopupBg,           BG2)
            dpg.add_theme_color(dpg.mvThemeCol_FrameBg,           BG2)
            dpg.add_theme_color(dpg.mvThemeCol_FrameBgHovered,    HEADER)
            dpg.add_theme_color(dpg.mvThemeCol_FrameBgActive,     SEL)
            # Title bar
            dpg.add_theme_color(dpg.mvThemeCol_TitleBg,           BG2)
            dpg.add_theme_color(dpg.mvThemeCol_TitleBgActive,     HEADER)
            # Scrollbar
            dpg.add_theme_color(dpg.mvThemeCol_ScrollbarBg,       BG)
            dpg.add_theme_color(dpg.mvThemeCol_ScrollbarGrab,     BORDER)
            dpg.add_theme_color(dpg.mvThemeCol_ScrollbarGrabHovered, BLUE)
            dpg.add_theme_color(dpg.mvThemeCol_ScrollbarGrabActive,  AQUA)
            # Buttons
            dpg.add_theme_color(dpg.mvThemeCol_Button,            BG2)
            dpg.add_theme_color(dpg.mvThemeCol_ButtonHovered,     HEADER)
            dpg.add_theme_color(dpg.mvThemeCol_ButtonActive,      SEL)
            # Headers (table column headers + selectable)
            dpg.add_theme_color(dpg.mvThemeCol_Header,            HEADER)
            dpg.add_theme_color(dpg.mvThemeCol_HeaderHovered,     SEL)
            dpg.add_theme_color(dpg.mvThemeCol_HeaderActive,      SEL)
            # Tabs
            dpg.add_theme_color(dpg.mvThemeCol_Tab,               BG2)
            dpg.add_theme_color(dpg.mvThemeCol_TabHovered,        SEL)
            dpg.add_theme_color(dpg.mvThemeCol_TabActive,         HEADER)
            dpg.add_theme_color(dpg.mvThemeCol_TabUnfocused,      BG2)
            dpg.add_theme_color(dpg.mvThemeCol_TabUnfocusedActive, HEADER)
            # Table
            dpg.add_theme_color(dpg.mvThemeCol_TableHeaderBg,     HEADER)
            dpg.add_theme_color(dpg.mvThemeCol_TableBorderStrong,  BORDER)
            dpg.add_theme_color(dpg.mvThemeCol_TableBorderLight,   BG2)
            dpg.add_theme_color(dpg.mvThemeCol_TableRowBg,         BG)
            dpg.add_theme_color(dpg.mvThemeCol_TableRowBgAlt,      BG2)
            # Text
            dpg.add_theme_color(dpg.mvThemeCol_Text,              FG)
            dpg.add_theme_color(dpg.mvThemeCol_TextSelectedBg,    SEL)
            dpg.add_theme_color(dpg.mvThemeCol_TextDisabled,       DIM)
            # Borders & separators
            dpg.add_theme_color(dpg.mvThemeCol_Border,            BORDER)
            dpg.add_theme_color(dpg.mvThemeCol_BorderShadow,      BG)
            dpg.add_theme_color(dpg.mvThemeCol_Separator,         BORDER)
            dpg.add_theme_color(dpg.mvThemeCol_SeparatorHovered,  BLUE)
            # Input cursor / check
            dpg.add_theme_color(dpg.mvThemeCol_CheckMark,         GREEN)
            dpg.add_theme_color(dpg.mvThemeCol_SliderGrab,        GREEN)
            # Rounding & spacing
            dpg.add_theme_style(dpg.mvStyleVar_WindowRounding,    8)
            dpg.add_theme_style(dpg.mvStyleVar_ChildRounding,     6)
            dpg.add_theme_style(dpg.mvStyleVar_FrameRounding,     5)
            dpg.add_theme_style(dpg.mvStyleVar_TabRounding,       6)
            dpg.add_theme_style(dpg.mvStyleVar_ScrollbarRounding, 4)
            dpg.add_theme_style(dpg.mvStyleVar_FramePadding,      8, 5)
            dpg.add_theme_style(dpg.mvStyleVar_ItemSpacing,       8, 5)
            dpg.add_theme_style(dpg.mvStyleVar_CellPadding,       8, 5)
            dpg.add_theme_style(dpg.mvStyleVar_WindowPadding,     12, 12)

    dpg.bind_theme(global_theme)


# ── Screen helpers ───────────────────────────────────────────────────────────
def _screen_center(vp_w: int, vp_h: int) -> tuple[int, int]:
    """Return (x, y) to center a viewport of vp_w×vp_h on the primary screen."""
    import subprocess
    try:
        out = subprocess.check_output(["xrandr", "--current"], text=True)
        m = re.search(r"current (\d+) x (\d+)", out)
        if m:
            sw, sh = int(m.group(1)), int(m.group(2))
            return (sw - vp_w) // 2, (sh - vp_h) // 2
    except Exception:
        pass
    return 100, 100


# ── Font loader ───────────────────────────────────────────────────────────────
def _try_load_font() -> None:
    candidates = [
        Path("/usr/share/fonts/TTF/MesloLGS NF Regular.ttf"),
        Path("/usr/share/fonts/TTF/MesloLGSNFRegular.ttf"),
        Path.home() / ".local/share/fonts/MesloLGS NF Regular.ttf",
        Path("/usr/share/fonts/nerd-fonts-complete/Meslo/MesloLGS NF Regular.ttf"),
    ]
    # Broad search fallback
    for search_dir in [Path("/usr/share/fonts"), Path.home() / ".local/share/fonts"]:
        if search_dir.exists() and not any(p.exists() for p in candidates):
            matches = list(search_dir.rglob("MesloLGS*Regular*.ttf"))
            if matches:
                candidates.insert(0, matches[0])
                break

    with dpg.font_registry():
        for p in candidates:
            if p.exists():
                try:
                    font = dpg.add_font(str(p), 15)
                    dpg.bind_font(font)
                    return
                except Exception:
                    continue


# ── Main ──────────────────────────────────────────────────────────────────────
def main() -> None:
    sxhkd_rows  = parse_sxhkdrc(SXHKDRC)
    chadwm_rows = parse_config_h(CONFIG_H)

    dpg.create_context()
    _apply_theme()
    _try_load_font()

    with dpg.window(tag="primary", no_title_bar=True, no_move=True,
                    no_resize=False, no_scrollbar=True):

        dpg.add_text("  Arch-Boki — Keybindings", color=AQUA)
        dpg.add_separator()
        dpg.add_spacer(height=6)

        with dpg.tab_bar():
            _build_tab("SXHKD",  "", sxhkd_rows)
            _build_tab("Chadwm", "", chadwm_rows)

    vp_w, vp_h = 960, 640
    cx, cy = _screen_center(vp_w, vp_h)
    dpg.create_viewport(
        title="Arch-Boki — Keybindings",
        width=vp_w,
        height=vp_h,
        x_pos=cx,
        y_pos=cy,
        min_width=600,
        min_height=400,
        clear_color=list(BG[:3]) + [255],
    )
    dpg.setup_dearpygui()
    dpg.show_viewport()
    dpg.set_primary_window("primary", True)

    with dpg.handler_registry():
        dpg.add_key_press_handler(dpg.mvKey_Escape, callback=lambda: dpg.stop_dearpygui())

    while dpg.is_dearpygui_running():
        dpg.render_dearpygui_frame()

    dpg.destroy_context()


if __name__ == "__main__":
    main()
