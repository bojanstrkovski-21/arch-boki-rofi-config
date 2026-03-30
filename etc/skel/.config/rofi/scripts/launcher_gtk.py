#!/usr/bin/env python3
#
# To change the color scheme, use a GTK theme (e.g. with lxappearance or gnome-tweaks),
# or set custom CSS for this window using Gtk.CssProvider.
# For custom CSS, see the commented example at the bottom of this file.
import gi
import os
import configparser
import subprocess
from pathlib import Path

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GdkPixbuf, Gdk

CATEGORIES = [
    ("All", None),
    ("Utils", ["Utility", "Accessories"]),
    ("Dev", ["Development", "IDE"]),
    ("Net", ["Network", "WebBrowser", "Email"]),
    ("Media", ["AudioVideo", "Audio", "Video", "Music", "Player"]),
    ("Graphics", ["Graphics", "Photography"]),
    ("System", ["System", "Settings", "PackageManager"]),
    ("Office", ["Office"]),
]

ICON_SIZE = 48


class AppLauncher(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="App Launcher")
        self.set_border_width(16)
        self.set_default_size(900, 600)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_resizable(True)

        self.set_role("applauncher")
        self.connect("key-press-event", self.on_key_press)

        # Apply custom theme CSS (forceful selectors, before widget creation)
        from gi.repository import Gdk
        css = b'''
GtkWindow, window, * {
    background-color: #2d353b;
    color: #a89e88;
}
.app-hover {
    background: #a7c080;
    border-radius: 8px;
}
entry, button {
    background: #232a2e;
    color: #a89e88;
    border-radius: 6px;
}
button.suggested-action {
    background: #a7c080;
    color: #232a2e;
}
label {
    color: #a89e88;
}
'''
        self.set_opacity(0.9)  # 90% opacity for the window
        style_provider = Gtk.CssProvider()
        style_provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self.all_apps = self.load_all_apps()
        self.current_category = 0

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.add(vbox)

        # Search bar
        self.search_entry = Gtk.Entry()
        self.search_entry.set_placeholder_text("Search apps...")
        self.search_entry.connect("changed", self.on_search)
        vbox.pack_start(self.search_entry, False, False, 0)

        # Scrolled window for grid
        self.scrolled = Gtk.ScrolledWindow()
        vbox.pack_start(self.scrolled, True, True, 0)

        # App grid
        self.grid = Gtk.FlowBox()
        self.grid.set_max_children_per_line(7)
        self.grid.set_selection_mode(Gtk.SelectionMode.NONE)
        self.scrolled.add(self.grid)

        # Category buttons
        self.cat_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        vbox.pack_start(self.cat_box, False, False, 0)
        self.cat_buttons = []
        for idx, (name, _) in enumerate(CATEGORIES):
            btn = Gtk.Button(label=name)
            btn.connect("clicked", self.on_category_clicked, idx)
            self.cat_box.pack_start(btn, True, True, 0)
            self.cat_buttons.append(btn)

        self.update_category_buttons()
        self.populate_grid()

    def on_key_press(self, widget, event):
        # 65307 is the keyval for Escape
        if event.keyval == 65307:
            Gtk.main_quit()
            return True
        return False

    def load_all_apps(self):
        locations = [
            Path("/usr/share/applications"),
            Path("/usr/local/share/applications"),
            Path.home() / ".local/share/applications",
            Path("/var/lib/flatpak/exports/share/applications"),
            Path.home() / ".local/share/flatpak/exports/share/applications",
        ]
        desktop_files = []
        for loc in locations:
            if loc.exists():
                found = list(loc.glob("*.desktop"))
                print(f"Found {len(found)} .desktop files in {loc}")
                desktop_files.extend(found)
        print(f"Total .desktop files found: {len(desktop_files)}")
        apps = []
        seen = set()
        for df in desktop_files:
            app = self.parse_desktop_file(df)
            if app and app["name"] not in seen:
                apps.append(app)
                seen.add(app["name"])
        print(f"Total apps parsed: {len(apps)}")
        return sorted(apps, key=lambda x: x["name"].lower())

    def parse_desktop_file(self, filepath):
        config = configparser.ConfigParser(interpolation=None)
        try:
            config.read(filepath, encoding='utf-8')
        except:
            return None
        try:
            entry = config["Desktop Entry"]
            if entry.get("NoDisplay", "false").lower() == "true":
                return None
            if entry.get("Hidden", "false").lower() == "true":
                return None
            if entry.get("Type", "") != "Application":
                return None
            name = entry.get("Name", "")
            exec_cmd = entry.get("Exec", "")
            icon = entry.get("Icon", "")
            categories = entry.get("Categories", "").split(";")
            if not name or not exec_cmd:
                return None
            for code in ["%f", "%F", "%u", "%U", "%d", "%D", "%n", "%N", "%i", "%c", "%k", "%v", "%m"]:
                exec_cmd = exec_cmd.replace(code, "")
            return {
                "name": name,
                "exec": exec_cmd.strip(),
                "icon": icon,
                "categories": [c.strip() for c in categories if c.strip()],
                "file": str(filepath)
            }
        except:
            return None

    def populate_grid(self):
        for child in self.grid.get_children():
            self.grid.remove(child)
        apps = self.get_filtered_apps()
        print(f"Apps to display in grid: {len(apps)}")
        for app in apps:
            box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
            icon = self.get_icon_pixbuf(app["icon"])
            img = Gtk.Image.new_from_pixbuf(icon)
            label = Gtk.Label(label=app["name"])
            label.set_ellipsize(3)
            box.pack_start(img, False, False, 0)
            box.pack_start(label, False, False, 0)
            event = Gtk.EventBox()
            event.add(box)
            event.connect("button-press-event", self.on_app_clicked, app)
            event.connect("enter-notify-event", self.on_app_hover, True)
            event.connect("leave-notify-event", self.on_app_unhover, True)
            self.grid.add(event)
        self.grid.show_all()

    def on_app_hover(self, widget, event, *args):
        widget.get_window().set_cursor(Gdk.Cursor.new_for_display(widget.get_display(), Gdk.CursorType.POINTER))
        widget.get_style_context().add_class("app-hover")
        return False

    def on_app_unhover(self, widget, event, *args):
        widget.get_window().set_cursor(None)
        widget.get_style_context().remove_class("app-hover")
        return False
##
# To use a custom color scheme, add this at the end of the file and uncomment:
#
# from gi.repository import Gtk, Gdk
# css = b'''
# .app-hover { background: #3c474d; border-radius: 8px; }
# window { background: #232a2e; color: #a89e88; }
# entry, button { background: #2d353b; color: #a89e88; }
# }'''
# style_provider = Gtk.CssProvider()
# style_provider.load_from_data(css)
# Gtk.StyleContext.add_provider_for_screen(
#     Gdk.Screen.get_default(),
#     style_provider,
#     Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
# )

    # --- Everforest Center rasi Matching CSS ---
    from gi.repository import Gtk, Gdk
    css = b'''
    window {
        background-color: rgba(45,53,59,0.90); /* #2d353b, 90% */
        color: #a89e88;
    }
    .app-hover {
        background: rgba(167,192,128,0.3); /* #a7c080, 30% opacity */
        border-radius: 8px;
    }
    entry, button {
        background: #232a2e; /* background2 */
        color: #a89e88;
        border-radius: 6px;
    }
    button.suggested-action {
        background: #a7c080;
        color: #232a2e;
    }
    label {
        color: #a89e88;
    }
    '''
    style_provider = Gtk.CssProvider()
    style_provider.load_from_data(css)
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(),
        style_provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )
    # --- End Everforest Center CSS ---

    def get_icon_pixbuf(self, icon_name):
        theme = Gtk.IconTheme.get_default()
        try:
            if os.path.isabs(icon_name) and os.path.exists(icon_name):
                return GdkPixbuf.Pixbuf.new_from_file_at_size(icon_name, ICON_SIZE, ICON_SIZE)
            if theme.has_icon(icon_name):
                return theme.load_icon(icon_name, ICON_SIZE, 0)
        except:
            pass
        # fallback
        return theme.load_icon("application-x-executable", ICON_SIZE, 0)

    def get_filtered_apps(self):
        cat_name, cat_filter = CATEGORIES[self.current_category]
        search = self.search_entry.get_text().lower()
        filtered = []
        for app in self.all_apps:
            if cat_filter is None or any(c in app["categories"] for c in cat_filter):
                if search in app["name"].lower():
                    filtered.append(app)
        return filtered

    def on_category_clicked(self, btn, idx):
        self.current_category = idx
        self.update_category_buttons()
        self.populate_grid()

    def update_category_buttons(self):
        for i, btn in enumerate(self.cat_buttons):
            if i == self.current_category:
                btn.get_style_context().add_class("suggested-action")
            else:
                btn.get_style_context().remove_class("suggested-action")

    def on_search(self, entry):
        self.populate_grid()

    def on_app_clicked(self, widget, event, app):
        if event.type == 4:  # left click
            try:
                subprocess.Popen(["gtk-launch", Path(app["file"]).name],
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            except:
                subprocess.Popen(app["exec"], shell=True,
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            Gtk.main_quit()

if __name__ == "__main__":
    win = AppLauncher()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()
