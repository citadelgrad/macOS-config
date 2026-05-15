function uv --wraps uv --description "uv with 3-day publish age guard on add/pip install/tool install"
    # Determine if this is an install-like invocation
    # uv add <pkg>
    # uv pip install <pkg>
    # uv tool install <pkg>
    set -l is_install false
    set -l pkg_start 0   # argv index where packages begin

    if test "$argv[1]" = add
        set is_install true
        set pkg_start 2
    else if test "$argv[1]" = pip; and test "$argv[2]" = install
        set is_install true
        set pkg_start 3
    else if test "$argv[1]" = tool; and test "$argv[2]" = install
        set is_install true
        set pkg_start 3
    end

    if not $is_install
        command uv $argv
        return $status
    end

    set -l triples
    set -l skip_next false
    set -l value_flags -i --index-url --extra-index-url --index --find-links \
        -c --constraint -r --requirement --override --python -p \
        --extra --group --package -e --editable

    for i in (seq $pkg_start (count $argv))
        set -l arg $argv[$i]

        if $skip_next
            set skip_next false
            continue
        end
        if contains -- $arg $value_flags
            set skip_next true
            continue
        end
        string match -q -- '-*' $arg; and continue
        # Skip local paths, git URLs, file installs
        string match -qr -- '^(file:|git[+:]|https?:|\.\.?/|/)' $arg; and continue
        # Skip -r requirements files (already consumed by value_flags, but guard)
        test "$arg" = .; and continue

        # Parse name[extras]>=version or name==version etc.
        # Strip extras: name[extra1,extra2] -> name
        set -l pkg_name (string replace -r '\[.*\]' '' (string split -m 1 -r '[><=!~]' $arg)[1])
        set -l pkg_ver ""
        # Extract pinned version from ==x.y.z only (for exact registry lookup)
        if string match -qr -- '==' $arg
            set pkg_ver (string split '==' $arg)[2]
            # Strip any trailing specifiers
            set pkg_ver (string split -r '[,;]' $pkg_ver)[1]
        end

        test -z "$pkg_name"; and continue
        set -a triples pypi $pkg_name $pkg_ver
    end

    if test (count $triples) -eq 0
        command uv $argv
        return $status
    end

    set -l blocked
    set -l i 1
    while test $i -le (count $triples)
        if not _pkg_age_guard $triples[$i] $triples[(math $i+1)] $triples[(math $i+2)]
            set -a blocked $triples[(math $i+1)]
        end
        set i (math $i + 3)
    end

    if test (count $blocked) -gt 0
        echo "pkg-age-guard: blocked PyPI packages (too new): "(string join ', ' $blocked) >&2
        echo "  Override: PKG_AGE_BYPASS=1  |  Disable: PKG_AGE_MIN_DAYS=0" >&2
        set -q PKG_AGE_BYPASS; or return 1
        echo "  PKG_AGE_BYPASS set — continuing." >&2
    end

    command uv $argv
end
