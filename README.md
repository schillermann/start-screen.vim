# Vim Start Screen

A simple start screen plugin for vim to list the most important commands and shortcuts.

## Installation

Move this folder to your Vim package directory:
`~/.vim/pack/category_name/start/start-screen`

## Usage

### Commands

- `:StartScreen`: Manually open the start screen buffer.

### Configuration in Vim9Script

To configure the start screen, define `g:start_screen_blocks` in your `.vimrc`:

```vim
vim9script

g:start_screen_blocks = [
    { title: 'Welcome Back' },
    { items: [
        { description: 'Start Screen', command: ':StartScreen' },
        { description: 'New File', command: ':enew' },
        { description: 'Quit Vim', command: ':q' },
    ]},
    { title: 'Project', items: [
        { shortcut: 'f', description: 'Find File', command: ':Files' },
        { shortcut: 'g', description: 'Git Status', command: ':G' },
    ]}
]
```

### Configuration Options

Each block in `g:start_screen_blocks` is a dictionary with the following keys:

- `title` (optional): A string displayed as a centered, bold header.
- `items` (optional): A list of items. Each item can be either a dictionary (recommended) or a list.

#### Item as a Dictionary (Recommended)

Allows you to omit keys if they are not needed:
- `shortcut` (optional): The key combination to display.
- `description`: A short description of the action.
- `command` (optional): The Vim command to execute.
