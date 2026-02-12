# Kinoite Setup

My post-install setup for Fedora Kinoite with per-step confirmation. Layering heavy. Run system updates first.

## Usage

```
curl -sSL https://raw.githubusercontent.com/rudidev08/kinoite-setup/refs/heads/main/setup-1.sh | bash
# reboot
curl -sSL https://raw.githubusercontent.com/rudidev08/kinoite-setup/refs/heads/main/setup-2.sh | bash
```

To inspect before running:

```
curl -O https://raw.githubusercontent.com/rudidev08/kinoite-setup/refs/heads/main/setup-1.sh
curl -O https://raw.githubusercontent.com/rudidev08/kinoite-setup/refs/heads/main/setup-2.sh
```

## What It Does

### setup-1.sh (pre-reboot)

- Set hostname
- Disable Fedora flatpak remote, enable Flathub
- Add RPM Fusion free and nonfree repos

### setup-2.sh (post-reboot)

- Layer rpm-ostree packages: 1password, 1password-cli, VS Code, deskflow, distrobox, fish
  - Adds 1password and VS Code yum repos if those packages are selected
- AMD or Intel GPU video acceleration drivers with H.264/H.265 codec support (mesa-va-drivers-freeworld or intel-media-driver)
- Replace ffmpeg-free with full ffmpeg from RPM Fusion
- Remove pre-installed flatpaks: KMahjongg, KMines
- Install flatpaks from Flathub: Fastmail, Flatseal, Warehouse, Mission Center, Gear Lever, Lutris, Steam, Fedora Media Writer, Haruna, Kate, Krita, VLC
- Download Aurora wallpapers from ublue-os/artwork
- Lists AppImages to download manually: Helium Browser, Obsidian, pCloud, Todoist

Every step prompts for confirmation before running.

## Alternatives

Layering is a choice. Other approaches:

- [Universal Blue](https://universal-blue.org/) images: Aurora (KDE), Bazzite (gaming), Bluefin (GNOME)
- Build your own with [image-template](https://github.com/ublue-os/image-template) or [finpilot](https://github.com/projectbluefin/finpilot)
- Use Universal Blue's kinoite-main base image (unofficial but works well)
- Layer less, flatpak more

## Resources

- [1password layering](https://leopoldluley.de/posts/install-1password-with-rpm-ostree/)
- [Fedora setup script](https://nattdf.streamlit.app/)
- [Fedora post-install steps](https://github.com/wz790/Fedora-Noble-Setup)
