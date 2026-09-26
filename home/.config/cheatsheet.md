# Workspace Cheatsheet

Usage: `cheat` (tutto), `cheat <sezione>` (es. `cheat git`), `cheat <termine>` (cerca in tutte le sezioni, es. `cheat rebase`), `cheat --list`. `TAB` completa le sezioni.

## shell
| Cosa | Come |
|---|---|
| Ricarica configurazione | `exec zsh` |
| NON salvare comando in history | prefisso uno spazio: ` env TOKEN=...` |
| Modifica .zshrc | `zed ~/.zshrc` (symlink al repo, vedi `cheat dotfiles`) |
| Verifica PATH | `echo $PATH \| tr ':' '\n'` |
| Accetta suggerimento grigio (dalla history) | `→` o `End` |
| Accetta solo la prossima parola | `Alt-F` (iTerm2: `Option-→` con Option come Esc+) |
| Colori mentre scrivi | verde = comando valido, rosso = comando inesistente |

## history
| Cosa | Come |
|---|---|
| Cerca fuzzy | `Ctrl-R` (fzf) |
| Storia condivisa tra finestre | automatico (`SHARE_HISTORY`) |
| Mostra con timestamp | `history -i` |
| Top 20 comandi più usati | `history -i 1 \| awk '{print $4}' \| sort \| uniq -c \| sort -rn \| head -20` |
| Dimensione | 1.000.000 entry |

## git
| Cosa | Come |
|---|---|
| Editor di commit | Zed (`zed --wait`) |
| Pull = rebase | automatico (`pull.rebase=true`) |
| Pull rifiuta non-fast-forward | automatico (`pull.ff=only`) |
| Push branch nuovo | `git push` (autoSetupRemote) |
| Default branch nuovi repo | `production` |
| Identità (name/email) | `~/.gitconfig.local`, non versionato: `git config --file ~/.gitconfig.local user.email ...` |
| Credenziali | macOS Keychain (`credential.helper=osxkeychain`) |
| Ignore globale | `~/.gitignore_global` |
| Auto-prune branch rimossi remoti | automatico (`fetch.prune=true`) |
| Memoria risoluzioni conflitti | `rerere.enabled=true` |
| PR / issue / repo da terminale | `gh pr create`, `gh pr checkout <n>`, `gh pr view --web` |

## mise — gestore versioni runtime
| Cosa | Come |
|---|---|
| Lista runtime installati | `mise ls` |
| Lista versioni disponibili | `mise ls-remote node` |
| Setta versione globale | `mise use -g node@lts` |
| Setta versione per progetto | `mise use node@20` (crea `mise.toml` nella dir) |
| Installa senza attivare | `mise install python@3.12` |
| Legge `.nvmrc` esistenti | sì, automatico |
| Config globale | `~/.config/mise/config.toml` |

## python — uv
| Cosa | Come |
|---|---|
| Nuovo progetto | `uv init` |
| Aggiungi dipendenza | `uv add <pkg>` (dev: `uv add --dev <pkg>`) |
| Esegui nel venv del progetto | `uv run <cmd>` |
| Tool CLI al volo, senza installarlo | `uvx <tool>` |
| Installa tool CLI globale | `uv tool install <tool>` |

## fzf — fuzzy finder
| Cosa | Come |
|---|---|
| Cerca history | `Ctrl-R` |
| Inserisci path file | `Ctrl-T` |
| cd in subdir | `Alt-C` (iTerm2: Option come Esc+) |
| Picker arbitrario | `<comando> \| fzf` |
| Kill processo | `kill -9 **<TAB>` |
| Apri da git | `git checkout **<TAB>` |

## zoxide — cd intelligente
| Cosa | Come |
|---|---|
| Vai a dir conosciuta | `z brewfile` (match parziale, frequenze) |
| Picker interattivo (richiede fzf) | `zi` |
| Lista dir con score | `zoxide query -ls` |
| Rimuovi una entry | `zoxide remove <path>` |

## eza — alias ls
| Cosa | Come |
|---|---|
| Long listing | `l` |
| Con dotfile | `la` |
| Tree (2 livelli) | `lt` |
| ls POSIX puro | `\ls` o `/bin/ls` |

## cli — tool da riga di comando
| Cosa | Come |
|---|---|
| Cerca testo nei file | `rg <pattern>` (rispetta .gitignore; `-uu` include ignorati/hidden) |
| Trova file per nome | `fd <pattern>` (`-H` include hidden) |
| cat con syntax highlight | `bat <file>` |
| JSON: pretty print / query | `jq . file.json`, `jq '.items[].name' file.json` |
| Esempi pratici di un comando | `tldr <cmd>` |
| Render markdown | `glow file.md` |
| Uso disco interattivo | `dua i` |
| Dischi montati | `duf` |
| Metriche container | `ctop` |
| Download riprendibile | `aria2c -c <url>` |

## k8s — kubectl, kubectx, k9s, helm
| Cosa | Come |
|---|---|
| Contesto corrente | `kubectl config current-context` |
| Cambia contesto | `kubectx` (picker fzf) o `kubectx <nome>` |
| Torna al contesto precedente | `kubectx -` |
| Cambia namespace | `kubens` o `kubens <ns>` |
| TUI del cluster | `k9s` (`:pods`, `:deploy`, `/` filtra, `?` help) |
| Log di un pod | `kubectl logs -f <pod> [-c <container>]` |
| Shell in un pod | `kubectl exec -it <pod> -- sh` |
| Port-forward | `kubectl port-forward svc/<svc> 8080:80` |
| Release helm | `helm list -A` |
| Kubeconfig cluster Scaleway | `scw k8s kubeconfig install <cluster-id>` |

## iterm2
| Cosa | Come |
|---|---|
| Salta a prompt precedente | `Cmd+Shift+↑` |
| Salta a prompt successivo | `Cmd+Shift+↓` |
| Toggle Toolbelt | `Cmd+Shift+B` |
| Lista comandi storici | Toolbelt → Command History |
| Cwd visitate di recente | Toolbelt → Recent Directories |
| Installa Shell Integration | menu iTerm2 → Install Shell Integration |
| Hotkey window globale | Preferences → Keys → Hotkey |

## iterm2-autosave
Salva l'arrangement "Work" ogni 5 minuti via Python API iTerm2. Skip se iTerm2 non attivo. Backup ruotato (ultimi 20). Installato da `scripts/setup-iterm2-autosave.sh` (lo lancia `install.sh`).
| Cosa | Come |
|---|---|
| Save manuale (in qualsiasi momento) | `iterm2-save-arrangement.sh` |
| Log | `~/Library/Logs/iterm2-arrangement-save.log` |
| Backup dei save precedenti | `~/.local/share/iterm2-arrangement-backups/` |
| Stato del LaunchAgent | `launchctl print gui/$(id -u)/com.padipierro.iterm2-save-arrangement` |
| Disattiva temporaneamente | `launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.padipierro.iterm2-save-arrangement.plist` |
| Riattiva | `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.padipierro.iterm2-save-arrangement.plist` |
| Modifica frequenza | edita `StartInterval` in `launchd/com.padipierro.iterm2-save-arrangement.plist` nel repo, poi `scripts/setup-iterm2-autosave.sh` |
| Save manuale dalla GUI | `Cmd+Shift+S` → Invio → Sì |

## iterm2-restore
Ripristina un arrangement iTerm2 da un backup precedente. **Prerequisito: iTerm2 deve essere chiuso** (al `Cmd+Q` sovrascrive il plist con lo stato corrente, quindi cancellerebbe il restore appena fatto).

Workflow:
1. In iTerm2 fai `Cmd+Q` per chiudere
2. Apri **Terminal.app** (o altra app terminale che NON sia iTerm2)
3. Lancia `iterm2-restore-arrangement.sh` → picker fzf con i backup ordinati per data
4. Seleziona il timestamp da cui ripristinare
5. Riapri iTerm2: ricarica l'arrangement ripristinato

| Cosa | Come |
|---|---|
| Picker interattivo | `iterm2-restore-arrangement.sh` |
| Restore da file specifico | `iterm2-restore-arrangement.sh <path>` |
| Lista backup disponibili | `ls -lt ~/.local/share/iterm2-arrangement-backups/` |
| Annulla l'ultimo restore | il restore stesso crea un `Work.before-restore.<TS>.plist` → ri-restoralo per annullare |
| Lo script di restore | `~/.local/bin/iterm2-restore-arrangement.sh` |

Safety: prima del restore, lo script salva sempre lo stato corrente in `Work.before-restore.<TS>.plist` nella backup dir. Quindi puoi sempre tornare indietro di un passo.

## brew — ambiente riproducibile
| Cosa | Come |
|---|---|
| Reinstalla tutto da file (+ dotfiles) | `~/Home/DEV/Brewfile/install.sh` |
| Solo pacchetti, niente dotfiles | `./install.sh --skip-dotfiles` |
| Con cleanup pacchetti rimossi dal file | `./install.sh --cleanup` (mostra la lista e chiede conferma) |
| Cosa manca rispetto al file | `brew bundle check --verbose --file=~/Home/DEV/Brewfile/Brewfile_current` |
| Cosa verrebbe rimosso (dry-run) | `brew bundle cleanup --file=~/Home/DEV/Brewfile/Brewfile_current` |
| Update + upgrade tutto | `brew update && brew upgrade` |
| Chi dipende da un pacchetto | `brew uses --installed <nome>` |
| Pacchetti non più referenziati | `brew autoremove --dry-run` |
| Formule più pesanti su disco | `du -sh "$(brew --cellar)"/* \| sort -h \| tail -20` |
| rsync | **non** installarlo da brew: export Xcode / App Store Connect vogliono `/usr/bin/rsync` |

## dotfiles — come funziona il repo
I file in `~/Home/DEV/Brewfile/home/` sono symlinkati nello stesso path sotto `~`. Modificare `~/.zshrc` modifica il file nel repo: poi basta un commit.
| Cosa | Come |
|---|---|
| Applica / ripara i symlink | `~/Home/DEV/Brewfile/scripts/link-dotfiles.sh` |
| Aggiungi un nuovo dotfile | copialo in `home/<path relativo a ~>`, poi `scripts/link-dotfiles.sh` |
| File sostituiti dal link | salvati come `<file>.backup.<timestamp>` accanto all'originale |
| Cosa è cambiato | `git -C ~/Home/DEV/Brewfile status` |
| Test degli script | `~/Home/DEV/Brewfile/tests/run.sh` |

## config — dove guardare
| File | Cosa |
|---|---|
| `~/.zshrc` | shell interattiva (history, completion, prompt, alias) |
| `~/.zprofile` | login shell (brew shellenv, PATH, orbstack) |
| `~/.gitconfig` | git globale |
| `~/.gitconfig.local` | identità git (non versionato) |
| `~/.gitignore_global` | ignore globale |
| `~/.config/mise/config.toml` | versioni runtime globali |
| `~/.config/cheatsheet.md` | questo file |
| `~/.local/bin/cheat` | il comando `cheat` |
| `~/.local/share/iterm2-save/save_arrangement.py` | script Python che salva l'arrangement |
| `~/.local/bin/iterm2-save-arrangement.sh` | wrapper bash (backup + run python) |
| `~/.local/bin/iterm2-restore-arrangement.sh` | restore arrangement da backup |
| `~/Library/LaunchAgents/com.padipierro.iterm2-save-arrangement.plist` | scheduler ogni 5 min (generato dal template in `launchd/`) |
| `~/Home/DEV/Brewfile/Brewfile_current` | lista pacchetti in uso (`Brewfile_iliad` = storico) |
| `~/Home/DEV/Brewfile/install.sh` | applica Brewfile + dotfiles |
