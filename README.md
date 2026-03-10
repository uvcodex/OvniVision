# OvniVision

## Getting Started

### Clone repo
```bash
git clone --bare git@github.com:uvcodex/OvniVision.git OvniVision.worktree
cd OvniVision.worktree
git worktree add main main
git worktree add <feature-name> -b <feature/your-feature-name> <main>
git worktree add <feature-name> -b <feature/your-feature-name>
```
### Branch Naming
```bash
feature/your-feature-name    # New features
fix/bug-description          # Bug fixes
hotfix/critical-fix          # Urgent fixes
refactor/component-name      # Code refactoring
ktlo/keep-the-lights-on      
```
