# lpersonal dotfiles (chezmoi)

## Install

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <fork-owner>
```

The sanitized `lpersonal` baseline installs chezmoi, clones the repo, runs the
package bootstrap, and applies the reusable workstation config without
requiring the original maintainer's secrets, SSH material, or mail accounts.

Follow-up setup happens later:

1. Replace placeholder name/email values with your own identity.
2. Add your own SSH config and keys.
3. Add your Gmail accounts and app-password/secret wiring. 
4. Generate your own age keypair and reintroduce encrypted files when ready.

## Daily use

```bash
chezmoi update
chezmoi diff
chezmoi apply
```
