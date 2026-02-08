---
layout: default
title: "WayVNC Server"
parent: Modules
---

# WayVNC Remote Desktop Module

Secure remote desktop access for Hyprland using WayVNC with PAM authentication and TLS encryption.

## Overview

This module configures [WayVNC](https://github.com/any1/wayvnc) to provide secure VNC remote desktop access to your Hyprland Wayland session. It implements multiple layers of security:

- **PAM Authentication**: Uses your system login credentials
- **TLS Encryption**: All VNC traffic is encrypted
- **Localhost Binding**: Only accepts connections from 127.0.0.1 by default
- **SSH Tunneling**: Recommended method for remote access

## Security Model

### Three Layers of Security

1. **Network Layer**: Binds to localhost (127.0.0.1) only, preventing direct network access
2. **Transport Layer**: TLS encryption protects against eavesdropping and man-in-the-middle attacks
3. **Authentication Layer**: PAM authentication requires valid system credentials

### Why SSH Tunneling?

SSH tunneling is recommended because it provides:
- **Defense in depth**: Requires SSH authentication before VNC authentication
- **Battle-tested security**: Leverages mature SSH protocol
- **No firewall changes**: VNC port stays closed to external access
- **Encrypted transport**: SSH adds another layer of encryption

## Installation

### 1. Deploy the Module

Ensure the wayvnc module is listed in your `config.yaml`:

```yaml
- name: "wayvnc"
  path: "wayvnc"
  hosts:
    - HOME-DESKTOP
```

Then deploy using the main installer:

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

This will symlink the configuration files to your home directory:
- `~/.config/wayvnc/` - Configuration directory
- `~/.local/bin/configure-wayvnc` - Setup script

### 2. Run the Configuration Script

```bash
configure-wayvnc
```

The script will:
1. Check that wayvnc and openssl are installed
2. Verify PAM support in wayvnc
3. Prompt for network binding preference (default: all interfaces)
4. Prompt for VNC port (default: 5900)
5. Generate TLS certificates valid for 10 years
6. Create the configuration file with secure permissions
7. Install PAM authentication config (requires sudo)
8. Install sudoers rule for passwordless `sudo wayvnc` (scoped to `/usr/bin/wayvnc` only)
9. Display next steps

### 3. Startup via Hyprland

The wayvnc module provides a drop-in config at `~/.config/hypr/conf.d/wayvnc.conf` that is automatically sourced by Hyprland. It contains:

```conf
exec-once = start-wayvnc
monitor = wayvnc, 1920x1080@60, auto, 1
```

The `start-wayvnc` script runs wayvnc as root via sudo, which is required for PAM authentication to read `/etc/shadow`. No manual Hyprland config editing is needed.

After running `configure-wayvnc` and deploying the module, reload Hyprland or logout/login.

### 4. Verify WayVNC is Running

```bash
pgrep -a wayvnc
```

You should see:
```
root ... /usr/bin/wayvnc --log-level=trace -C /home/user/.config/wayvnc/config
```

## Process Management

```bash
# Check if running
pgrep -a wayvnc

# Stop
sudo pkill -x wayvnc

# Start manually (normally handled by Hyprland exec-once)
start-wayvnc &

# Quick switch binding address
configure-wayvnc --all        # Switch to all interfaces (0.0.0.0)
configure-wayvnc --localhost   # Switch to localhost only (127.0.0.1)
```

## Quick Start

### Local Testing (Same Machine)

```bash
# Install a VNC client
sudo pacman -S tigervnc

# Connect to localhost
vncviewer localhost:5900

# Authenticate with your system credentials
# Username: [your username]
# Password: [your system password]
```

### Remote Access (Different Machine)

**On your remote machine:**

```bash
# Create SSH tunnel to forward VNC port
ssh -L 5900:localhost:5900 user@hyprland-host

# Keep this terminal open and in another terminal, connect VNC client
vncviewer localhost:5900

# Authenticate with system credentials when prompted
```

**Alternative: Use a single command:**

```bash
ssh -L 5900:localhost:5900 user@hyprland-host vncviewer localhost:5900
```

## Configuration Options

The configuration file is located at `~/.config/wayvnc/config`. See `~/.config/wayvnc/config.example` for all available options.

### Common Customizations

#### Change Keyboard Layout

Edit `~/.config/wayvnc/config` and add:

```ini
xkb_layout=us
xkb_variant=
xkb_model=pc105
```

#### Change Binding Address

To allow direct remote access (less secure):

```ini
address=0.0.0.0
```

**Warning**: This exposes VNC to your network. Ensure firewall is configured:

```bash
sudo ufw allow 5900/tcp
```

#### Change Port

```ini
port=5901  # or any other port
```

Remember to adjust SSH tunnel and firewall rules accordingly.

## PAM Authentication Configuration

WayVNC uses PAM (Pluggable Authentication Modules) for authentication, which means it authenticates using your system username and password.

### PAM Configuration File

The PAM config is stored at `/etc/pam.d/wayvnc` and is installed automatically by `configure-wayvnc`.

**Proper configuration:**
```
#%PAM-1.0
auth    include system-auth
account include system-auth
```

This configuration uses the standard system authentication stack, the same as `login`, `sudo`, and `ssh`.

### Manual Installation

If you need to manually install or fix the PAM config:

```bash
# Copy from dotfiles
sudo cp /path/to/dotfiles/wayvnc/pam.d/wayvnc /etc/pam.d/wayvnc

# Or run the configuration script again
configure-wayvnc
```

### Common PAM Issues

**Problem: Authentication fails with "Authentication service cannot retrieve authentication info"**

This usually means the PAM config has invalid options. Check `/etc/pam.d/wayvnc`:

```bash
cat /etc/pam.d/wayvnc
```

If you see invalid options like `deny=3` or `unlock_time=600` with `pam_unix.so`, the config needs to be fixed. Run:

```bash
sudo cp /path/to/dotfiles/wayvnc/pam.d/wayvnc /etc/pam.d/wayvnc
sudo pkill -x wayvnc && start-wayvnc &
```

**Problem: "User not known to the underlying authentication module"**

This means the username doesn't exist on the system. Use your actual system username (check with `whoami`).

## Troubleshooting

### WayVNC Not Starting

```bash
# Check if the process is running
pgrep -a wayvnc

# Try running manually to see errors
sudo /usr/bin/wayvnc --log-level=trace -C ~/.config/wayvnc/config

# Check if the drop-in config is deployed
ls -la ~/.config/hypr/conf.d/wayvnc.conf
```

**Common issues:**
- Config file doesn't exist: Run `configure-wayvnc`
- Certificate files missing: Run `configure-wayvnc` to regenerate
- Port already in use: Change port in config file or stop conflicting service
- Sudoers rule missing: Run `configure-wayvnc` to reinstall
- Drop-in not deployed: Run `./install.sh` from dotfiles directory

### Connection Refused

**If connecting locally:**

```bash
# Check if wayvnc is running
ps aux | grep wayvnc

# Check if port is listening
ss -tlnp | grep 5900
```

**If connecting remotely:**

```bash
# Verify SSH tunnel is active
netstat -an | grep 5900

# Try connecting with verbose mode
ssh -v -L 5900:localhost:5900 user@host
```

### Authentication Fails

**Check PAM configuration first:**

```bash
# View PAM config
cat /etc/pam.d/wayvnc

# Run wayvnc manually to see PAM errors in real time
sudo /usr/bin/wayvnc --log-level=trace -C ~/.config/wayvnc/config
```

If you see errors like "unrecognized option" or "Authentication service cannot retrieve authentication info", reinstall the PAM config:

```bash
configure-wayvnc  # Will detect and fix broken PAM config
```

**Verify PAM support:**

```bash
ldd $(which wayvnc) | grep pam
```

Should output: `libpam.so.0 => /usr/lib/libpam.so.0`

**Check credentials:**
- Username must be your system username (check with `whoami`)
- Password must be your system password (same as `sudo` password)

### Certificate Warnings

VNC clients may show security warnings about self-signed certificates. This is **normal and expected**.

**To accept the certificate:**
- Click "Accept" or "Trust" when prompted
- Some clients allow saving the certificate for future connections

**To regenerate certificates:**

```bash
configure-wayvnc
# Choose to regenerate certificates when prompted
```

### Performance Issues

**Adjust display settings in Hyprland:**

```conf
# In hyprland.conf, reduce the wayvnc monitor resolution
monitor=wayvnc,1280x720@30,auto,1
```

**Or disable animations when using VNC:**

Create a script to toggle animations and bind it to a key.

## Advanced Usage

### Using Different VNC Clients

**TigerVNC (Linux):**
```bash
vncviewer localhost:5900
```

**Remmina (Linux GUI):**
1. Open Remmina
2. Create new connection
3. Protocol: VNC
4. Server: localhost:5900
5. Username: [your username]
6. Password: [your password]

**RealVNC Viewer (Windows/Mac/Linux):**
1. Open RealVNC Viewer
2. Enter: localhost:5900
3. Accept certificate warning
4. Enter credentials when prompted

### Port Forwarding via Router

For access from outside your local network:

1. Configure router to forward port 5900 to your machine
2. Use dynamic DNS if your public IP changes
3. Connect using: `vnc://your-public-ip:5900`

**Warning**: This is less secure than SSH tunneling. Only do this if you understand the security implications.

### Multiple WayVNC Instances

To run multiple VNC servers on different monitors:

```bash
wayvnc -C ~/.config/wayvnc/config1 -o DP-1
wayvnc -C ~/.config/wayvnc/config2 -o HDMI-1
```

Create separate config files with different ports.

## Maintenance

### Reconfigure WayVNC

```bash
configure-wayvnc
```

The script will detect existing configuration and offer to reconfigure. Your old config will be backed up.

### Regenerate Certificates

Certificates are valid for 10 years. To regenerate:

```bash
configure-wayvnc
# Choose to regenerate certificates when prompted
```

### Check Certificate Expiration

```bash
openssl x509 -in ~/.config/wayvnc/tls_cert.pem -noout -enddate
```

### Disable VNC

1. Stop the running process:
   ```bash
   sudo pkill -x wayvnc
   ```
2. Remove the drop-in config to prevent autostart:
   ```bash
   rm ~/.config/hypr/conf.d/wayvnc.conf
   ```
3. Or comment out exec-once in the drop-in:
   ```conf
   # exec-once = start-wayvnc
   ```

## File Permissions

The setup script automatically sets secure permissions:

| File | Permissions | Reason |
|------|-------------|--------|
| `~/.config/wayvnc/config` | 600 (rw-------) | Contains authentication settings |
| `~/.config/wayvnc/tls_key.pem` | 600 (rw-------) | Private key must be secret |
| `~/.config/wayvnc/tls_cert.pem` | 644 (rw-r--r--) | Certificate is public |

**Never** commit these files to git. The `.gitignore` file protects against accidental commits.

## Dependencies

### Required

- **wayvnc**: VNC server for Wayland (with PAM support)
- **openssl**: For generating TLS certificates

### Optional

- **tigervnc**: VNC client for testing
- **remmina**: GUI VNC/RDP client
- **openssh**: For SSH tunneling (usually pre-installed)

### Installation

```bash
# Arch Linux / CachyOS
sudo pacman -S wayvnc openssl tigervnc

# Ubuntu / Debian
sudo apt install wayvnc openssl tigervnc-viewer

# Fedora
sudo dnf install wayvnc openssl tigervnc
```

## Related Documentation

- [WayVNC GitHub](https://github.com/any1/wayvnc)
- [WayVNC Man Page](https://man.archlinux.org/man/wayvnc.1.en)
- [Hyprland Module README](../hyprland/README.md)
- [VNC Protocol Documentation](https://www.rfc-editor.org/rfc/rfc6143)

## Security Considerations

### Strengths

- **PAM Authentication**: No separate passwords to manage or store
- **TLS Encryption**: Protects against packet sniffing
- **Localhost Binding**: Prevents unauthorized network access
- **File Permissions**: Config and keys are protected at filesystem level
- **SSH Tunneling**: Adds additional authentication and encryption layer

### Limitations

- **Self-signed certificates**: VNC clients will show warnings
- **PAM password**: Same as system password, so compromise affects both
- **No 2FA**: PAM authentication doesn't support 2FA by default
- **Certificate validity**: 10-year certificates are convenient but long-lived
- **Runs as root**: WayVNC runs via sudo for PAM `/etc/shadow` access; the sudoers rule is scoped to `/usr/bin/wayvnc` only

### Best Practices

1. **Always use SSH tunneling** for remote access
2. **Keep system packages updated**, especially wayvnc and openssl
3. **Use strong system password** (since VNC uses it)
4. **Monitor access logs** periodically
5. **Disable VNC when not needed** for extended periods
6. **Don't expose port 5900** directly to the internet

## Contributing

This module is part of the dotfiles repository. To suggest improvements:

1. Test your changes thoroughly
2. Update this README if configuration changes
3. Ensure backward compatibility
4. Submit a pull request or open an issue

## License

This configuration follows the same license as the main dotfiles repository.
