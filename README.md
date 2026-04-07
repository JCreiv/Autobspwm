# Autobspwm

**Autobspwm** is an automation script designed to configure and personalize a tiling window manager setup using **bspwm**, **kitty**, and **sxhkd** on Debian/Ubuntu-based systems.


## Features

- Automatic installation of `bspwm`, `kitty`, and `sxhkd`
- Custom terminal setup using `powerlevel10k` and other enhancements
- Preconfigured keybindings via `sxhkd`
- Script for easily changing wallpapers
- Font and theme setup for a visually appealing desktop

## Compatibility

This script has been tested on the following VMware Linux distributions:

- ✅ Parrot OS

It is designed for Debian-based systems. Use on other distributions may require modifications.

## Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/JCreiv/Autobspwm.git
    cd Autobspwm
    ```

2. Make the installer executable

    ```bash
    chmod +x install.sh
    ```

3. Run the installer

    ```bash
    ./install.sh
    ```

4. Follow the prompts during installation to complete the setup.

## Usage

After installation, log out of your current session and choose **bspwm** as your window manager from your display manager.

![](ANEXOS/Pasted%20image%2020250531132556.png)


## Configuration

- All configuration files are located in the `.config/` directory:
    
    - `bspwmrc` (for bspwm)
        
    - `sxhkdrc` (for keybindings)
        
    - `kitty.conf` (for terminal appearance)
        
- Wallpapers are stored in the `Wallpapers/` directory. You can add your own images there.

## Wallpaper Management

To change the desktop wallpaper, this project includes a script called `wallpaper.sh`.  
It provides a simple interactive menu to select from predefined wallpapers located in the `Wallpapers/` directory.

### Usage

```bash
chmod +x wallpaper.sh
./wallpaper.sh
```

# [THEMES]

## Archkali
![](Wallpapers/archkali.png)

## Arch
![](Wallpapers/arch.png)

## BlackArch
![](Wallpapers/blackArch.png)

## Lsd
![](Wallpapers/lsd.jpg)

## Parrot
![](Wallpapers/parrot.jpg)

## Purple
![](Wallpapers/purple.png)

## Ninja
![](Wallpapers/s4vitar.png)

## Shortcuts & Useful Commands

A quick reference guide for the keyboard shortcuts and commands used in this setup.

### ⌨️ Window Management (`bspwm` + `sxhkd`)

| Key Combination | Action |
| :--- | :--- |
| `Super + Enter` | Launch the terminal. |
| `Ctrl + Super + Alt` | Preselect part of the screen. Release `Alt` and use mouse + `Ctrl + Super` to resize the window. |
| `Super + Shift + [1–8]` | Move the current window to another workspace. |
| `Super + S` | Toggle floating mode for the selected window (move with `Super` + drag). |
| `Super + Alt + Arrow Keys / Shift` | Resize windows in tiled mode. |
| `Super + Shift + V` | Launch Flameshot GUI for screenshots. |
| `Super + Shift + X` | Lock the screen using `i3lock-fancy`. |

### Kitty Terminal Shortcuts

| Key Combination | Action |
| :--- | :--- |
| `Ctrl + Shift + Enter` | Open a new `kitty` session inside the current terminal. |
| `Ctrl + Shift + R` | Resize the current `kitty` window. |
| `Ctrl + Shift + W` | Close the current `kitty` window. |
| `Ctrl + Shift + T` | Open a new tab in `kitty`. |
| `Ctrl + Shift + Alt + T` | Rename the current tab. |
| `Ctrl + Shift + ,` / `.` | Switch between tabs. |
| `Ctrl + Shift + Z` | Zoom the current `kitty` window (toggle). |
| `Ctrl + Shift + H` | Filter current output (search mode). |
| `Ctrl + Shift + L` | Change `kitty` keyboard layout. |

### Shell Productivity (Zsh)

| Key Combination / Command | Action |
| :--- | :--- |
| `Ctrl + T` | Fuzzy search for files by name. |
| `Ctrl + R` | Search command history. |
| `Alt + .` | Insert the last argument from the previous command. |
| `echo ' ' > ~/.zsh_history` | Clear Zsh history. |

### File Manager

| Command | Description |
| :--- | :--- |
| `ranger` | Launch the terminal file manager. |

### Function Keys (Copy & Paste)

| Key Combination | Action |
| :--- | :--- |
| `F1` + `F3` | Copy |
| `F2` + `F4` | Paste |

## Tools Installation Script

This repository also includes an optional script to automate the installation of common **pentesting and recon tools**, intended to be used alongside the bspwm environment.

### Features

- Automatic installation of:
  - **Go** (latest version)
  - **Docker** and Docker Compose
  - Go-based recon tools such as:
    - Amass
    - Subfinder
    - Httpx
  - **BloodHound** for Active Directory enumeration
  - Rust-based tools like **RustHound**
- Automatic dependency handling
- PATH configuration for Go
- Designed for Debian-based systems

### Compatibility

### Usage

1. Make the tools installer executable:

    ```bash
    chmod +x install-tools.sh
    ```

2. Run the script:

    ```bash
    ./tools.sh
    ```

3. Follow the on-screen instructions.  
   The script will install and configure all selected tools automatically.
