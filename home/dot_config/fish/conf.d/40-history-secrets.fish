# Prevent literal secret values from ever being recorded in fish history.
# Managed by chezmoi
#
# Uses the "sponge" fish plugin (meaningful-ooo/sponge): any command whose
# text matches one of these regexes is removed from history after
# $sponge_delay commands (see ~/.config/fish/conf.d/sponge.fish).
#
# Deliberately `--global` (not `--universal`): a global variable shadows a
# universal one of the same name for reads within a session, so this list
# always wins over sponge.fish's own empty-by-default universal variable,
# regardless of conf.d load order.
set --global sponge_regex_patterns \
    '(gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{50,})' \
    '[A-Za-z0-9]{14}\.atlasv1\.[A-Za-z0-9_-]{40,}' \
    '(AKIA|ASIA)[A-Z0-9]{16}' \
    '(?i)aws_secret_access_key[\s:="\x27]*[A-Za-z0-9/+]{40}' \
    '(?i)aws_session_token[\s:="\x27]*[A-Za-z0-9/+=]{100,}' \
    '(?i)bearer\s+[A-Za-z0-9._~+/-]{20,}=*' \
    'sk-(ant-|proj-)?[A-Za-z0-9_-]{20,}' \
    'xox[abprs]-[A-Za-z0-9-]{10,}' \
    'xapp-[A-Za-z0-9-]{10,}' \
    '-----BEGIN[A-Z ]*PRIVATE KEY-----' \
    'AIza[0-9A-Za-z_-]{35}' \
    'lin_api_[A-Za-z0-9]{20,}' \
    'pplx-[A-Za-z0-9]{20,}' \
    '[rs]k_(live|test)_[A-Za-z0-9]{20,}' \
    'AGE-SECRET-KEY-1[A-Z0-9]{50,}'
