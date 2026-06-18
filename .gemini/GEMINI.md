# Personal Preferences

- **Non-Interactive CLI Flags**: Always prioritize using non-interactive flags for commands (e.g., `jj describe -m "..."`, `git commit -m "..."`, `jj squash --use-description-from @`) to avoid triggering a TUI editor (like Neovim) that requires user intervention.
- **Jujutsu Changesets**: Always use a new `jj` changeset (`jj new`) at the start of each new feature/fix/plan phase, or where it makes the most logical sense.
