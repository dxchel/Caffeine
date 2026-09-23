# Caffeine Plasmoid

A Plasma 6 applet that keeps your system awake with one click. Prevents sleep, screen locking, and the screensaver from kicking in.

Created because original Plasma5 applet doesn't work in Plasma6 and found no Plasma6 plasmoid

## Features

- **One-click toggle** — Click the panel icon to enable/disable caffeine mode
- **Systemd integration** — Uses `systemd-inhibit` to reliably block sleep, idle, and lid-switch actions
- **Visual feedback** — Different icons for active/inactive states with smooth animations
- **Lightweight** — Pure QML implementation, no compiled code required
- **Plasma 6 native** — Built for Plasma 6 with Kirigami and PlasmaCore

## Installation

### From the KDE Store (recommended)

1. Open **System Settings → Appearance → Plasma → Widgets → Get New Widgets**
2. Search for "Caffeine"
3. Click **Install**

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/dxchel/com.github.dxchel.caffeine.git

# Install to local user plasmoid directory
mkdir -p ~/.local/share/plasma/plasmoids
cp -r com.github.dxchel.caffeine ~/.local/share/plasma/plasmoids/

# Restart Plasma (or log out/in)
kquitapp6 plasmashell && kstart6 plasmashell
```

### From Source (Plasma 6)

```bash
# Using kpackagetool6
kpackagetool6 --type Plasma/Applet --install com.github.dxchel.caffeine
```

## Usage

1. Add the widget to your panel: Right-click panel → **Add Widgets** → **Caffeine**
2. Click the coffee cup icon to toggle:
   - ![Active cup](https://github.com/dxchel/Caffeine/blob/main/contents/icons/caffeine.svg) = Active (system kept awake)
   - ![Inactive cup](https://github.com/dxchel/Caffeine/blob/main/contents/icons/caffeine_inactive.svg) = Inactive (normal sleep behavior)
3. Hover for visual feedback, click to toggle

## How It Works

The plasmoid uses `systemd-inhibit` via a transient systemd user unit to request inhibitor locks for:
- `idle` — Prevents idle detection
- `sleep` — Prevents system sleep/suspend
- `handle-lid-switch` — Prevents sleep on laptop lid close

When activated, it runs:
```bash
systemd-run --user --unit=org.kde.caffeine --collect \
  --description='Caffeine: keep system awake' -- \
  systemd-inhibit --what=idle:sleep:handle-lid-switch \
  --who=Caffeine --why='Requested by user' --mode=block sleep infinity
```

## Requirements

- **Plasma 6** (KDE Frameworks 6)
- **systemd** (with user session support)
- **Qt 6** / **Kirigami**

## Configuration

No configuration required — works out of the box.

## Development

### Project Structure

```
com.github.dxchel.caffeine/
├── metadata.json          # Plasmoid metadata (name, version, author, etc.)
├── LICENSE                # MIT License
├── README.md              # This file
├── CHANGELOG.md           # Version history
├── .gitignore
└── contents/
    ├── ui/
    │   └── main.qml       # Main QML UI logic
    ├── icons/
    │   ├── caffeine.svg         # Active state icon
    │   └── caffeine_inactive.svg # Inactive state icon
    └── config/
        └── main.xml       # Configuration schema (empty for now)
```

### Testing Locally

```bash
# Quick test with plasmoidviewer
plasmoidviewer --applet com.github.dxchel.caffeine
```

### Building/Validating Metadata

```bash
# Validate metadata.json
kpackagetool6 --type Plasma/Applet --list | grep caffeine
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure the metadata.json version is bumped
5. Submit a Pull Request

## License

MIT License — see [LICENSE](LICENSE) for details.

## Author

**David Xchel Morales Hurtado**  
Email: davidxchelmh@gmail.com  
GitHub: [@dxchel](https://github.com/dxchel)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
