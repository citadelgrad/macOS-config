function pip --wraps pip --description "pip with 3-day publish age guard on install"
    if test "$argv[1]" != install
        command pip $argv
        return $status
    end

    set -l triples
    set -l skip_next false
    set -l value_flags -i --index-url --extra-index-url --find-links \
        -c --constraint -r --requirement -t --target --root --prefix \
        --python-version --implementation --abi --platform \
        --progress-bar --log --proxy --retries --timeout --exists-action \
        --trusted-host --cert --client-cert --cache-dir --build \
        --src --upgrade-strategy --install-option --global-option \
        -e --editable

    for i in (seq 2 (count $argv))
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
        string match -qr -- '^(file:|git[+:]|https?:|\.\.?/|/)' $arg; and continue
        test "$arg" = .; and continue

        set -l pkg_name (string replace -r '\[.*\]' '' (string split -m 1 -r '[><=!~]' $arg)[1])
        set -l pkg_ver ""
        if string match -qr -- '==' $arg
            set pkg_ver (string split '==' $arg)[2]
            set pkg_ver (string split -r '[,;]' $pkg_ver)[1]
        end

        test -z "$pkg_name"; and continue
        set -a triples pypi $pkg_name $pkg_ver
    end

    if test (count $triples) -eq 0
        command pip $argv
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

    command pip $argv
end
