# Troubleshooting Guide

Common issues and solutions for the dotfiles management system.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Module Issues](#module-issues)
- [Stow Issues](#stow-issues)
- [Dependency Issues](#dependency-issues)
- [Platform-Specific Issues](#platform-specific-issues)
- [Debugging Tips](#debugging-tips)

---

## Installation Issues

### "No modules found for hostname"

**Problem:** The installer can't find a matching machine profile for your hostname.

**Cause:** Your hostname doesn't match any entry in the `machines:` section of `config.yaml`.

**Solution:**

1. Check your hostname:
   ```bash
   hostname
   ```

2. Add a machine profile in `config.yaml`:
   ```yaml
   machines:
     - hostname: "your-actual-hostname"
       modules:
         - "terminal"
         - "editors"
   ```

3. Or use a glob pattern:
   ```yaml
   machines:
     - hostname: "*"  # Matches any hostname
       modules:
         - "essentials"
   ```

---

### "Could not detect a supported package manager"

**Problem:** The installer doesn't recognize your OS or package manager.

**Supported:** pacman (Arch), apt (Debian/Ubuntu), dnf (Fedora/RHEL), brew (macOS)

**Solution:**

Check your OS:
```bash
cat /etc/os-release  # Linux
uname -s             # macOS
```

If unsupported, manually install prerequisites:
- stow
- yq
- git
- python3-pip
- cargo (optional, for cargo: packages)

Then retry `./install.sh`.

---

### "stow not found" or "yq not found"

**Problem:** Required tools are missing and couldn't be auto-installed (need sudo).

**Solution:**

Install manually via your package manager:

```bash
# Arch
sudo pacman -S stow yq

# Debian/Ubuntu
sudo apt-get install stow yq

# Fedora
sudo dnf install stow yq

# macOS
brew install stow yq
```

Then retry `./install.sh`.

---

### "cargo not found"

**Problem:** Cargo is missing and auto-install failed.

**Solution:**

Install Rust manually:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Follow prompts, then reload shell
source "$HOME/.cargo/env"

# Retry install
./install.sh
```

---

### "pip not found"

**Problem:** Python pip is missing (can't auto-install without sudo).

**Solution:**

Install via package manager:
```bash
# Arch
sudo pacman -S python-pip

# Debian/Ubuntu
sudo apt-get install python3-pip

# Fedora
sudo dnf install python3-pip

# macOS
brew install python3  # includes pip
```

---

### "paru not found" (Arch only)

**Problem:** AUR helper is missing and auto-install failed.

**Solution:**

Install paru manually:
```bash
# Install build dependencies
sudo pacman -S --needed base-devel git

# Clone and build paru
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru
makepkg -si --noconfirm

# Retry install
cd ~/.local/share/dotfiles
./install.sh
```

---

## Module Issues

### "Module 'xyz' not found"

**Problem:** A module referenced in config.yaml doesn't exist.

**Cause:** Either the directory doesn't exist, or it has no `deps.yaml` file.

**Solution:**

1. Check if directory exists:
   ```bash
   ls -la ~/.local/share/dotfiles/xyz/
   ```

2. Check if `deps.yaml` exists:
   ```bash
   ls -la ~/.local/share/dotfiles/xyz/deps.yaml
   ```

3. If missing, either:
   - Create the module (see [Module Creation Guide](module-creation.md))
   - Remove the reference from `config.yaml`

---

### "Duplicate module 'xyz'"

**Problem:** Module referenced multiple times (via toolkits or direct references).

**Cause:** Module appears in multiple toolkits or listed both in toolkit and directly.

**Behavior:** Installer deduplicates and warns. Module installs only once.

**Solution (Optional):**

Remove duplicate references from `config.yaml`:

```yaml
# ❌ Before
toolkits:
  - name: "terminal"
    modules: ["bash", "fish", "zsh"]

machines:
  - hostname: "laptop"
    modules:
      - "terminal"  # Includes bash
      - "bash"      # Duplicate!

# ✅ After
machines:
  - hostname: "laptop"
    modules:
      - "terminal"  # Bash already included
```

---

### "Toolkit 'xyz' is empty"

**Problem:** A toolkit has no modules defined.

**Cause:** Toolkit's `modules:[]` array is empty or all modules are invalid.

**Solution:**

Check toolkit definition in `config.yaml`:
```yaml
toolkits:
  - name: "xyz"
    modules: []  # Empty!
```

Either add modules or remove the toolkit.

---

### Module deps.yaml invalid

**Problem:** Module's `deps.yaml` has syntax errors.

**Symptoms:** Installer fails with YAML parsing error.

**Solution:**

1. Validate YAML syntax:
   ```bash
   yq -r . module-name/deps.yaml
   ```

2. Common syntax errors:
   ```yaml
   # ❌ Missing colon
   provides starship

   # ✅ Correct
   provides: starship

   # ❌ Inconsistent indentation
   packages:
     arch:
       - git
      - nvim  # Wrong indent!

   # ✅ Correct (2 spaces per level)
   packages:
     arch:
       - git
       - nvim
   ```

3. Check for tabs (YAML requires spaces):
   ```bash
   cat -A module-name/deps.yaml | grep $'\t'
   ```

---

## Stow Issues

### "Stow conflicts"

**Problem:** Stow can't create symlinks because files already exist.

**Behavior:** Installer automatically backs up conflicting files to `~/.dotfiles-backup/TIMESTAMP/`.

**Solution:**

1. Check backup directory:
   ```bash
   ls -la ~/.dotfiles-backup/
   ```

2. Review backed up files:
   ```bash
   cat ~/.dotfiles-backup/20260224-143022/.bashrc
   ```

3. Merge any custom settings into the new config:
   ```bash
   # Compare old and new
   diff ~/.dotfiles-backup/20260224-143022/.bashrc ~/.bashrc
   ```

4. Delete backup if no longer needed:
   ```bash
   rm -rf ~/.dotfiles-backup/20260224-143022/
   ```

---

### Symlinks pointing to wrong location

**Problem:** Symlinks created but pointing to incorrect paths.

**Cause:** Wrong working directory when running stow, or incorrect module path.

**Solution:**

1. Check where symlinks point:
   ```bash
   ls -la ~/.bashrc
   # Should show: .bashrc -> ../.local/share/dotfiles/bash/.bashrc
   ```

2. If wrong, unstow and re-stow:
   ```bash
   cd ~/.local/share/dotfiles
   stow -D bash  # Unstow
   stow bash     # Re-stow
   ```

3. Verify symlink:
   ```bash
   ls -la ~/.bashrc
   readlink -f ~/.bashrc  # Show full path
   ```

---

### "Can't stow to system directories"

**Problem:** Module target is `/etc` or other system directory (needs sudo).

**Cause:** Target override requires root permissions.

**Solution:**

Stow with sudo:
```bash
cd ~/.local/share/dotfiles
sudo stow --target=/etc sddm
```

Or change target to user directory:
```yaml
# config.yaml
machines:
  - hostname: "laptop"
    modules:
      - name: "sddm"
        target: "$HOME/.config/sddm"  # User directory instead
```

---

### Files not showing up after stow

**Problem:** Ran install successfully but files don't appear in home directory.

**Cause:** Files might be excluded by `.stow-local-ignore`.

**Solution:**

1. Check `.stow-local-ignore` in module:
   ```bash
   cat module-name/.stow-local-ignore
   ```

2. Common ignore patterns:
   ```
   \.git
   ^/README.*
   deps\.yaml
   ```

3. Remove patterns if excluding too much.

4. Re-stow:
   ```bash
   ./install.sh
   ```

---

## Dependency Issues

### Package not found in repos

**Problem:** Native package manager can't find a package.

**Symptoms:** Error like "package 'xyz' not found".

**Solutions:**

**Option 1:** Update package lists
```bash
# Arch
sudo pacman -Sy

# Debian/Ubuntu
sudo apt-get update

# Fedora
sudo dnf check-update
```

**Option 2:** Use alternative source
```yaml
# deps.yaml - use cargo/pip instead
packages:
  arch:
    - ripgrep  # In repos
  debian:
    - cargo:ripgrep  # Not in Debian repos, use cargo
```

**Option 3:** Use custom install script
```yaml
packages:
  debian:
    - run: "curl -L https://github.com/.../releases/.../tool.deb -o /tmp/tool.deb && sudo dpkg -i /tmp/tool.deb"
      provides: tool
```

---

### AUR package installation fails

**Problem:** AUR package fails to build or install.

**Common Causes:**
- Missing build dependencies
- Outdated PKGBUILD
- Network issues

**Solutions:**

1. **Check build dependencies:**
   ```bash
   # Install base-devel group
   sudo pacman -S --needed base-devel
   ```

2. **Try manual install:**
   ```bash
   paru -S package-name
   # Review any errors
   ```

3. **Check AUR package page:**
   - Visit https://aur.archlinux.org/packages/package-name
   - Read comments for known issues
   - Check if package is orphaned/outdated

4. **Use alternative:**
   ```yaml
   # deps.yaml - use official repo or cargo instead
   packages:
     arch:
       - cargo:ripgrep  # Instead of aur:ripgrep
   ```

---

### Cargo package compilation fails

**Problem:** `cargo install` fails during compilation.

**Common Causes:**
- Missing system libraries
- Insufficient disk space
- Out of memory (on low-RAM systems)

**Solutions:**

1. **Check error message for missing libraries:**
   ```bash
   # Common: openssl-dev, pkg-config
   sudo pacman -S openssl pkg-config  # Arch
   sudo apt-get install libssl-dev pkg-config  # Debian
   ```

2. **Check disk space:**
   ```bash
   df -h ~/.cargo
   # Cargo target/ dirs can be large
   ```

3. **Use native package instead:**
   ```yaml
   packages:
     arch:
       - ripgrep  # Native package instead of cargo:ripgrep
   ```

4. **Increase swap for low-RAM systems:**
   ```bash
   # Temporarily increase swap
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

---

### Pip package installation fails

**Problem:** `pip install` fails.

**Common Causes:**
- Missing Python headers
- Conflicting versions
- Network issues

**Solutions:**

1. **Install Python development headers:**
   ```bash
   sudo pacman -S python-dev  # Arch
   sudo apt-get install python3-dev  # Debian
   ```

2. **Try upgrading pip:**
   ```bash
   pip install --user --upgrade pip
   ```

3. **Check Python version:**
   ```bash
   python3 --version
   # Some packages require Python 3.8+
   ```

4. **Install with specific version:**
   ```yaml
   packages:
     debian:
       - pip:pynvim==0.4.3  # Pin to working version
   ```

---

### Script installation fails

**Problem:** Custom install script in `deps.yaml` fails.

**Debugging:**

1. **Check script output:**
   - Installer captures script output
   - Look for errors in terminal output

2. **Run script manually:**
   ```bash
   # Copy script from deps.yaml and test
   curl -sS https://starship.rs/install.sh | sh -s -- --yes
   ```

3. **Check script requirements:**
   - Does it need sudo?
   - Does it need specific tools (curl, wget)?
   - Are network connections blocked?

4. **Add verbose output:**
   ```yaml
   packages:
     debian:
       - run: "set -x; curl -v ... | sh"  # Verbose mode
         provides: tool
   ```

---

## Platform-Specific Issues

### macOS: "Homebrew not found"

**Problem:** Homebrew is not installed.

**Solution:**

Install Homebrew:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Follow instructions to add brew to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Retry install
./install.sh
```

---

### Arch: "AUR helper conflicts"

**Problem:** Multiple AUR helpers installed (yay + paru).

**Solution:**

Installer prefers paru over yay. Either:

1. **Use paru:**
   ```bash
   sudo pacman -R yay
   paru -S paru  # Ensure paru is installed
   ```

2. **Keep both:** (Installer will use paru)
   No action needed.

---

### Debian: "Package has no installation candidate"

**Problem:** Package not available in Debian repos.

**Common Examples:**
- starship (use install script)
- Many language servers (use cargo/pip)
- Newer tools (use cargo/pip or manual install)

**Solution:**

Use alternative source in `deps.yaml`:
```yaml
packages:
  debian:
    - cargo:starship
    # or
    - run: "curl ... | sh"
      provides: starship
```

---

### Codespaces: "Permission denied"

**Problem:** Can't install packages (no sudo).

**Cause:** GitHub Codespaces have restricted permissions.

**Solution:**

Use user-level installs only:
```yaml
packages:
  debian:
    - cargo:ripgrep     # User install
    - pip:pynvim        # User install
    # Avoid: apt packages (need sudo)
```

---

## Debugging Tips

### Enable Verbose Output

Run installer with bash tracing:
```bash
bash -x ./install.sh 2>&1 | tee install.log
```

---

### Check Module Discovery

List discovered modules:
```bash
cd ~/.local/share/dotfiles
find . -name "deps.yaml" -exec dirname {} \; | sed 's|./||'
```

---

### Validate YAML Files

Check `config.yaml`:
```bash
yq -r . config.yaml
```

Check module `deps.yaml`:
```bash
yq -r . module-name/deps.yaml
```

---

### Test Stow Without Installing

Dry-run stow to see what would happen:
```bash
stow --simulate --verbose bash
```

---

### Check Installed Packages

**Arch:**
```bash
pacman -Q | grep ripgrep
```

**Debian:**
```bash
dpkg -l | grep ripgrep
```

**Cargo:**
```bash
cargo install --list | grep ripgrep
```

**Pip:**
```bash
pip list --user | grep pynvim
```

---

### View Install Summary

Installer prints summary at end showing:
- Modules stowed
- Packages installed
- Errors encountered
- Backup locations

Scroll up in terminal to review, or capture output:
```bash
./install.sh 2>&1 | tee install.log
# Review later: less install.log
```

---

### Check Git Status

See what changed:
```bash
cd ~/.local/share/dotfiles
git status
git diff
```

---

### Restore from Backup

If installation broke something:
```bash
# List backups
ls -la ~/.dotfiles-backup/

# Restore specific file
cp ~/.dotfiles-backup/20260224-143022/.bashrc ~/.bashrc

# Or restore everything
cp -r ~/.dotfiles-backup/20260224-143022/* ~/
```

---

## Getting Help

If you're still stuck:

1. **Check documentation:**
   - [Installation Guide](installation.md)
   - [Module Creation Guide](module-creation.md)
   - [deps.yaml Spec](deps-yaml-spec.md)
   - [config.yaml Spec](config-yaml-spec.md)

2. **Review design docs:**
   - [Architecture Overview](architecture.md)
   - [Design Documents](plans/)

3. **Check git history:**
   ```bash
   git log --oneline --graph
   git show <commit>  # See what changed
   ```

4. **Test on fresh system:**
   - Spin up a VM or container
   - Test clean install
   - Isolate the issue

5. **Simplify configuration:**
   - Start with minimal machine profile
   - Add modules one at a time
   - Identify which module causes issues
