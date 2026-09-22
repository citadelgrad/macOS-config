# This function lives here, not in conf.d/30-interactive.fish, because a
# conf.d function definition shadows the autoload file of the same name:
# fish would never reach this file while conf.d/30-interactive.fish also
# defined `hermes`.
function hermes --wraps hermes --description 'Warm bd ready in beads repos, and keep the kitty keyboard protocol off while hermes runs'
    # Run bd ready automatically before Hermes in bd-managed repos
    set -l repo_root (command git rev-parse --show-toplevel 2>/dev/null)

    if test -n "$repo_root"
        and command -q bd
        and test -f "$repo_root/.beads/config.yaml"
        command bd ready --json >/dev/null 2>&1
    end

    # ponytail: disable kitty keyboard protocol before launching Hermes — it doesn't
    # handle kitty-encoded arrow keys (e.g. [1;1C) and displays them as literal text.
    # Restore kitty mode on exit so the rest of the WezTerm session is unaffected.
    set -l restore 0
    if isatty stdout
        set restore 1
        printf '\x1b[<u'
    end
    command hermes $argv
    set -l hermes_status $status
    test $restore -eq 1; and printf '\x1b[>1u'
    return $hermes_status
end
