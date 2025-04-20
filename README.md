# Minimalist Neovim Zettelkasten for Un Kyu Lee's Microjournal Rev 2

A lightweight, distraction-free Neovim configuration optimized for Zettelkasten note-taking on the [Microjournal Rev 2 cyberdeck](https://github.com/unkyulee/micro-journal) by Un Kyu Lee. This setup provides robust markdown editing with AI assistance through Claude 3.7 Sonnet, while maintaining excellent performance on the resource-constrained Raspberry Pi Zero 2W that powers this unique cyberdeck.

![Microjournal Rev 2 Cyberdeck](https://raw.githubusercontent.com/yourusername/your-repo/main/images/microjournal.jpg)

## About the Microjournal Rev 2

The Microjournal Rev 2 is a compact distraction-free writing device created by Un Kyu Lee. As described in the [original repository](https://github.com/unkyulee/micro-journal/blob/main/micro-journal-rev-2-revamp/readme.md), it features:

- A clamshell form-factor with an ultrawide screen
- An ortholinear mechanical keyboard
- Powered by a Raspberry Pi Zero 2W
- Designed for focused writing without distractions
- Portable design with a compact footprint

This configuration is specifically tailored to enhance the Microjournal Rev 2's capabilities by adding a powerful Zettelkasten note-taking system with AI assistance while respecting the device's hardware limitations.

## Features

- **Distraction-free writing environment** optimized for console-only operation
- **Zettelkasten workflow** with timestamp IDs, backlinks, and tag-based organization
- **AI-powered assistance** through Claude 3.7 Sonnet integration via Avante.nvim
- **Resource-efficient design** with minimal plugins and optimized performance
- **Console-friendly UI** with 16-color terminal compatibility
- **Reliable syntax highlighting** using Treesitter for markdown

## Table of Contents

- [Installation](#installation)
- [Core Plugins](#core-plugins)
- [Zettelkasten Features](#zettelkasten-features)
- [AI Integration](#ai-integration)
- [File Structure](#file-structure)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Performance Optimizations](#performance-optimizations)
- [Troubleshooting](#troubleshooting)
- [Customization](#customization)

## Installation

### 1. Prerequisites

First, ensure your Microjournal Rev 2 is running the latest version of its Raspberry Pi OS. Then install the necessary dependencies:

```bash
sudo apt update
sudo apt install git curl ripgrep build-essential
```

### 2. Install Neovim

Since the Raspberry Pi Zero 2W comes with an older version of Neovim, you can install a newer version using Snap:

```bash
sudo apt install snapd
sudo snap install nvim --classic
```

Add snap binaries to your PATH if needed:

```bash
echo 'export PATH="$PATH:/snap/bin"' >> ~/.bashrc
source ~/.bashrc
```

Verify installation:

```bash
nvim --version
```

### 3. Set Up Configuration

```bash
# Create Neovim config directory
mkdir -p ~/.config/nvim/lua
mkdir -p ~/.config/nvim/templates

# Clone this repository (or download files manually)
git clone https://github.com/yourusername/microjournal-neovim-zettelkasten.git
cd microjournal-neovim-zettelkasten

# Copy configuration files
cp init.lua ~/.config/nvim/
cp lua/*.lua ~/.config/nvim/lua/
cp templates/*.md ~/.config/nvim/templates/
```

### 4. Set Up Anthropic API Key

For Claude integration, you need an Anthropic API key:

```bash
# Add to your .bashrc or .profile
echo 'export ANTHROPIC_API_KEY="your_api_key_here"' >> ~/.bashrc
source ~/.bashrc
```

### 5. First Run

Launch Neovim to automatically install plugins:

```bash
nvim
```

The lazy.nvim package manager will automatically install the configured plugins on first launch. This may take some time on the Raspberry Pi Zero 2W.

## Core Plugins

This configuration uses a minimal set of plugins for optimal performance:

- **lazy.nvim**: Efficient plugin manager
- **srcery-vim**: Console-friendly colorscheme
- **nvim-treesitter**: Improved syntax highlighting
- **vim-markdown**: Lightweight markdown support
- **auto-pairs**: Automatic bracket closing
- **avante.nvim**: AI-powered editing with Claude 3.7 Sonnet

## Zettelkasten Features

### Core Functionality

- **Timestamp-based IDs**: Automatically generate IDs in format YYYYMMDDHHMM
- **Backlinks system**: Find all notes that reference the current note
- **Tag navigation**: Search for notes with specific tags
- **Quick capture**: Create fleeting notes without disrupting workflow
- **Daily notes**: Generate dated journal entries with a consistent format
- **Extract as Zettel**: Convert selected text into a new note with backlink

### Creating Notes

- `<leader>zn`: Create a new Zettelkasten note with timestamp ID
- `<leader>zq`: Quick capture a fleeting thought
- `<leader>zd`: Create or open today's daily note
- `<leader>n`: Create regular markdown note (no ID)

### Navigation and Organization

- `<leader>zf`: Fuzzy find notes by content
- `<leader>zb`: Find backlinks to current note
- `<leader>zt`: Find notes with specific tag
- `<leader>ff`: Basic file finder
- `<leader>fb`: List and navigate buffers

### Visual Selection Actions

- `<leader>ze`: Extract selected text as a new Zettelkasten note

## AI Integration

This configuration integrates Claude 3.7 Sonnet through Avante.nvim for AI-assisted writing, optimized for the limited resources of the Microjournal Rev 2.

### Basic AI Interaction

- `<leader>aa`: Ask Claude about the current text
- `<leader>ae`: Edit selected text with Claude
- `<leader>ar`: Refresh Claude's response

### Zettelkasten-Specific AI Features

- `<leader>ae`: Expand on the current paragraph/selection
- `<leader>ap`: Transform fleeting note to permanent note
- `<leader>aq`: Generate related questions
- `<leader>as`: Summarize the current note
- `<leader>ac`: Suggest connections to other notes/concepts
- `<leader>ab`: Break down text into atomic notes

## File Structure

```
~/.config/nvim/
├── init.lua              # Main configuration file
├── lua/
│   ├── zettelkasten.lua  # Zettelkasten functionality
│   └── ai_enhance.lua    # AI integration features
└── templates/
    ├── skeleton.md       # Basic note template
    └── zettel.md         # Zettelkasten note template
```

## Keyboard Shortcuts

### General Navigation

- `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>`: Navigate between splits
- `<leader>bn`, `<leader>bp`: Navigate buffers (next/previous)
- `<leader>bd`: Delete buffer
- `<leader>h`: Clear search highlighting
- `<leader>w`: Save file
- `<leader>q`: Quit
- `<leader>sr`: Manually refresh syntax highlighting

### Markdown Editing

- `<leader>n`: Create new markdown file with basic template
- `<leader>t`: Apply template to current file
- `;l`: Insert markdown link `[]()`
- `;w`: Insert wiki link `[[]]`
- `<leader>gq`: Format current paragraph

### Zettelkasten-Specific

- `<leader>zn`: Create new Zettelkasten note with ID
- `<leader>zq`: Quick capture note
- `<leader>zd`: Create/open daily note
- `<leader>zb`: Find backlinks to current note
- `<leader>zt`: Find notes with specific tag
- `<leader>zf`: Find notes by content
- `<leader>ze`: (Visual mode) Extract selection as new note

### AI Assistance

- `<leader>aa`: Ask AI about selected text or current buffer
- `<leader>ae`: Edit text with AI assistance
- `<leader>ar`: Refresh AI response
- `<leader>ap`: Transform fleeting note to permanent
- `<leader>aq`: Generate related questions
- `<leader>as`: Summarize current note
- `<leader>ac`: Suggest connections
- `<leader>ab`: Generate atomic notes from longer text

## Performance Optimizations

This configuration includes several optimizations for the Raspberry Pi Zero 2W that powers the Microjournal Rev 2:

- **Minimal Plugin Set**: Only essential plugins are included
- **Disabled Features**: Many built-in Vim plugins are disabled to save resources
- **Console-Friendly UI**: No fancy UI elements that consume resources
- **Lightweight Alternatives**: Simple grep-based searches instead of heavy fuzzy finders
- **Syntax Optimizations**: Reasonable column limits for syntax highlighting
- **Memory Controls**: Settings to limit memory usage for pattern matching
- **Lazy Loading**: Plugins load only when needed

## Troubleshooting

### Common Issues on Microjournal Rev 2

1. **Slow startup time**:
   - Make sure you're using the snap version of Neovim for better performance
   - Consider disabling some features if still too slow

2. **Syntax highlighting issues**:
   - Press `<leader>sr` to manually refresh syntax highlighting
   - If problems persist, try increasing `synmaxcol` value in init.lua

3. **Claude API not working**:
   - Check your internet connection (Microjournal Rev 2 needs WiFi setup)
   - Ensure your API key is set correctly with `echo $ANTHROPIC_API_KEY`

4. **Screen rendering issues**:
   - The Microjournal Rev 2 has an ultrawide screen; adjust your wrap settings if text layout looks strange

5. **Low memory issues**:
   - Add swap space if experiencing out-of-memory errors:
     ```bash
     sudo fallocate -l 512M /swapfile
     sudo chmod 600 /swapfile
     sudo mkswap /swapfile
     sudo swapon /swapfile
     echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
     ```

6. **Keyboard layout issues**:
   - The Microjournal Rev 2 uses an ortholinear keyboard; you may need to adjust key mappings

## Customization

### Modifying Templates

Edit or create templates in `~/.config/nvim/templates/`:

```bash
nvim ~/.config/nvim/templates/zettel.md
```

### Adding Custom Functions

Add your own Lua functions to `~/.config/nvim/lua/zettelkasten.lua`.

### Adjusting Performance Settings

If your Microjournal is struggling with performance, you can further optimize settings in `init.lua`:

```lua
-- For lower performance devices
vim.opt.maxmempattern = 1000          -- Decreased for less memory usage
vim.opt.synmaxcol = 100               -- Syntax highlight fewer columns
```

## Credits and Resources

This configuration is specifically designed for Un Kyu Lee's Microjournal Rev 2 cyberdeck. For more information about the Microjournal project, visit:

- [Microjournal GitHub Repository](https://github.com/unkyulee/micro-journal)
- [Un Kyu Lee's Tindie Store](https://www.tindie.com/stores/unkyulee/)

## License

MIT

---

*Note: This configuration is specifically optimized for the Microjournal Rev 2 cyberdeck with its Raspberry Pi Zero 2W and ultrawide screen. The keyboard shortcuts and visual layout are designed to work well with the device's ortholinear keyboard and limited screen real estate.*
