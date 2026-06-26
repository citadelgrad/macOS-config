function hermes
    # ponytail: disable kitty keyboard protocol before launching Hermes — it doesn't
    # handle kitty-encoded arrow keys (e.g. [1;1C) and displays them as literal text.
    # Restore kitty mode on exit so the rest of the WezTerm session is unaffected.
    printf '\x1b[<u'
    command hermes $argv
    printf '\x1b[>1u'
end
