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
