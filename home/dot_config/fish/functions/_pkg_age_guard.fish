# Registry age guard — shared utility for npm/uv/cargo/pip wrappers.
# Usage: _pkg_age_guard <npm|pypi|crates> <package-name> [version]
# Returns 0 if package is old enough, 1 if too new. Fails open on network errors.

function _pkg_age_guard --description "Check package publish age against registry"
    set -l ecosystem $argv[1]
    set -l pkg $argv[2]
    set -l pkg_ver ""
    test (count $argv) -ge 3; and set pkg_ver $argv[3]

    set -l min_days 3
    set -q PKG_AGE_MIN_DAYS; and set min_days $PKG_AGE_MIN_DAYS

    set -l data ""
    set -l publish_time ""

    switch $ecosystem
        case npm
            set -l encoded (string replace -a '/' '%2F' $pkg)
            set data (curl -sf --connect-timeout 4 --max-time 6 "https://registry.npmjs.org/$encoded" 2>/dev/null)
            test -z "$data"; and return 0
            set publish_time (echo "$data" | env _V="$pkg_ver" python3 -c "
import os, sys, json
v = os.environ.get('_V', '')
d = json.load(sys.stdin)
t = d.get('time', {})
if v:
    print(t.get(v, ''))
else:
    latest = d.get('dist-tags', {}).get('latest', '')
    print(t.get(latest, ''))
" 2>/dev/null)

        case pypi
            set data (curl -sf --connect-timeout 4 --max-time 6 "https://pypi.org/pypi/$pkg/json" 2>/dev/null)
            test -z "$data"; and return 0
            set publish_time (echo "$data" | env _V="$pkg_ver" python3 -c "
import os, sys, json
v = os.environ.get('_V', '')
d = json.load(sys.stdin)
if not v:
    v = d['info']['version']
releases = d.get('releases', {}).get(v, [])
print(releases[-1]['upload_time'] if releases else '')
" 2>/dev/null)

        case crates
            set data (curl -sf --connect-timeout 4 --max-time 6 \
                -H "User-Agent: pkg-age-guard/1.0 (personal)" \
                "https://crates.io/api/v1/crates/$pkg" 2>/dev/null)
            test -z "$data"; and return 0
            set publish_time (echo "$data" | env _V="$pkg_ver" python3 -c "
import os, sys, json
v = os.environ.get('_V', '')
d = json.load(sys.stdin)
versions = d.get('versions', [])
if v:
    versions = [x for x in versions if x['num'] == v]
print(versions[0]['created_at'] if versions else '')
" 2>/dev/null)
    end

    test -z "$publish_time"; and return 0

    set -l result (env _TS="$publish_time" _DAYS="$min_days" python3 -c "
import os
from datetime import datetime, timezone
ts = os.environ['_TS'].replace('Z', '+00:00')
min_days = int(os.environ['_DAYS'])
try:
    pub = datetime.fromisoformat(ts)
    if pub.tzinfo is None:
        pub = pub.replace(tzinfo=timezone.utc)
    age = datetime.now(timezone.utc) - pub
    if age.days >= min_days:
        print('ok')
    else:
        print(f'{age.days}d{age.seconds // 3600}h')
except Exception:
    print('ok')
" 2>/dev/null)

    test "$result" = ok; and return 0

    echo "pkg-age-guard: $ecosystem/$pkg$(test -n "$pkg_ver"; and echo "@$pkg_ver") is only $result old (minimum: {$min_days}d)" >&2
    return 1
end


# Shared logic: check a list of "ecosystem pkg [version]" triples, then run real command.
function _pkg_age_run --description "Check ages then exec. Args: real-cmd [check-args...] -- cmd-args..."
    set -l real_cmd $argv[1]
    set -l check_triples
    set -l cmd_args
    set -l in_cmd_args false

    for i in (seq 2 (count $argv))
        if test "$argv[$i]" = --
            set in_cmd_args true
            continue
        end
        if $in_cmd_args
            set -a cmd_args $argv[$i]
        else
            set -a check_triples $argv[$i]
        end
    end

    set -l blocked
    set -l i 1
    while test $i -le (count $check_triples)
        set -l ecosystem $check_triples[$i]
        set -l pkg $check_triples[(math $i + 1)]
        set -l pkg_ver ""
        if test (count $check_triples) -ge (math $i + 2)
            set pkg_ver $check_triples[(math $i + 2)]
        end
        if not _pkg_age_guard $ecosystem $pkg $pkg_ver
            set -a blocked "$pkg$(test -n "$pkg_ver"; and echo "@$pkg_ver")"
        end
        set i (math $i + 3)
    end

    if test (count $blocked) -gt 0
        echo "pkg-age-guard: blocked (too new): "(string join ', ' $blocked) >&2
        echo "  Override: PKG_AGE_BYPASS=1 or PKG_AGE_MIN_DAYS=0" >&2
        set -q PKG_AGE_BYPASS; or return 1
        echo "  PKG_AGE_BYPASS set — continuing." >&2
    end

    command $real_cmd $cmd_args
end
