# Uninstalling Omarchy Power Actions

## Recommended method

Remove the plugin through Omarchy's plugin manager:

```bash
omarchy plugin remove siob.power-actions --yes
```

This removes the installed plugin and its bar configuration. Omarchy Shell
should reload the change automatically.

## Manual removal

Use this only if the plugin manager cannot remove the plugin.

First disable the widget so its entry is removed from the bar configuration:

```bash
omarchy plugin disable siob.power-actions
```

Then remove its installed directory:

```bash
rm -rf ~/.config/omarchy/plugins/siob.power-actions
```

If the power icon remains visible, restart Omarchy Shell:

```bash
omarchy restart shell
```

Removing the installed plugin does not delete a separate Git checkout. If you
cloned this repository elsewhere, delete that checkout separately when it is
no longer needed.
