---
title: 'Create Pull Request'
read_only: true
type: 'command'
---

Create a GitHub pull request for the current branch with minimal description and appropriate labels.

## Description

This command creates a pull request by analyzing the commits on the current branch, generating a concise summary of changes, and applying relevant labels from the repository.

- Keep descriptions minimal and focused
- Do NOT add emojis to PR titles or descriptions
- Add appropriate labels based on the changes (e.g., logging, development, feature request, bug, etc.)

## Usage
`pull-request`

## Steps
1. Run `git log master..HEAD --oneline` to see commits in the branch
2. Run `git diff master...HEAD --stat` to understand scope of changes
3. Run `gh label list` to see available labels
4. Analyze the commits and changes to create a summary
5. Create PR with `gh pr create` including:
   - Short, descriptive title
   - One-paragraph description of the changes
   - Brief bullet-point summary (if applicable)
   - Appropriate labels based on the nature of changes

## Example
```bash
gh pr create --title "Upgrade Sentry browser packages and configuration" --body "$(cat <<'EOF'
This PR upgrades Sentry's browser packages to the latest versions and configures the latest integrations for improved error tracking. It also adds user data to the initial scope and wires up server-side Sentry configuration for view rendering.

- Upgrade @sentry/browser and related packages
- Add latest Sentry integrations
- Configure user scope data
EOF
)" --label "logging,development"
```

## Notes
- Ensure the branch is pushed to remote before creating PR
- Use comma-separated labels: `--label "label1,label2"`
- Keep summaries concise and technical
- No emojis in PR content
