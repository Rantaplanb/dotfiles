# Workspace and mrconfig

The sanitized `lpersonal` baseline does not ship bundled personal or work
workspace definitions. Create your own `dev/*/dot_mrconfig` files as needed.

**Source:** `dev/` directory within the chezmoi repo (not deployed to target)

## Directory Structure

Add workspace definitions under `dev/` only after deciding which repos belong in
your own baseline. Each workspace can have a `dot_mrconfig` that gets deployed
by chezmoi to `~/.mrconfig` (or included from it).

## mrconfig Format

[myrepo](https://myrepo.net/) uses INI-style sections where each `[section]` defines a repo checkout:

```ini
[reponame]
checkout = git clone <url> reponame
```

## Static Checkouts

Static checkouts are explicit `[section]` entries with `checkout = git clone ...`.
The sanitized baseline intentionally leaves repo choices to you.

## mr Commands

Common operations with the configured workspaces:

| Command | Action |
|---|---|
| `mr checkout` | Clone all repos (static + dynamically discovered) |
| `mr update` | Pull all repos |
| `mr status` | Show status of all repos |
| `mr run <cmd>` | Run a command in each repo |

## References
- `mr` manual page
- Any user-defined `dev/*/dot_mrconfig`
