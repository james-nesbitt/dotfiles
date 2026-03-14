# distrobox plugin

This plugin adds aliases for [distrobox](https://github.com/89luca89/distrobox) (tested with 1.8.2.4), a tool to create and manage containers that integrate with the host OS.

To use it, add `distrobox` to the plugins array in your `.zshrc` file:

```zsh
plugins=(... distrobox)
```

## Aliases

| Alias   | Command                 | Description                                      |
| :------ | :---------------------- | :----------------------------------------------- |
| dba     | `distrobox assemble`    | Create containers from an assemble file          |
| dbc     | `distrobox create`      | Create a new container                           |
| dbe     | `distrobox enter`       | Enter a container (interactive shell)            |
| dbls    | `distrobox list`        | List containers (same as `distrobox ls`)         |
| dbrm    | `distrobox rm`          | Remove one or more containers                    |
| dbstop  | `distrobox stop`        | Stop one or more running containers              |
| dbup    | `distrobox upgrade`     | Upgrade a container to a new image                |
| dbep    | `distrobox ephemeral`   | Create an ephemeral container                    |
| dbge    | `distrobox generate-entry` | Generate a desktop entry for a container     |

The plugin does nothing if the `distrobox` command is not installed.
