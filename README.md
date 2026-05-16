# Skills

A collection of custom skills for [GitHub Copilot in VS Code](https://code.visualstudio.com/docs/copilot/copilot-customization).

Each subdirectory is a self-contained skill identified by a `SKILL.md` file.

## Skills

| Skill | Description |
|-------|-------------|
| [my-todo-skill](./my-todo-skill/SKILL.md) | Manage your to-do list with natural language commands |

## Managing Skills

Use the included `skill.sh` script to install or uninstall skills into VS Code.

### Prerequisites

- macOS or Linux with Bash 3.2+
- VS Code with the GitHub Copilot extension

### Usage

```bash
# Show help
./skill.sh help

# List all skills and their installation status
./skill.sh list

# Install a specific skill
./skill.sh install my-todo-skill

# Install all skills
./skill.sh install all

# Interactive selection
./skill.sh install

# Uninstall a specific skill
./skill.sh uninstall my-todo-skill

# Uninstall all skills
./skill.sh uninstall all
```

### Install target

Skills are copied to `$VSCODE_USER_PROMPTS_FOLDER`, which defaults to:

```
~/Library/Application Support/Code/User/prompts   # macOS
```

You can override this by setting the environment variable before running the script:

```bash
VSCODE_USER_PROMPTS_FOLDER=/custom/path ./skill.sh install all
```

## Adding a New Skill

1. Create a new directory in the repo root (e.g. `my-new-skill/`)
2. Add a `SKILL.md` file inside it — this file is both the skill definition and the install marker
3. Run `./skill.sh install my-new-skill` to activate it in VS Code
