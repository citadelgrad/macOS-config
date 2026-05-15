function npm --wraps npm --description "npm with 3-day publish age guard on install/add"
    # Pass through non-install commands immediately
    if not contains -- $argv[1] install i add
        command npm $argv
        return $status
    end

    set -l triples
    set -l skip_next false

    # Flags that consume the next argument (not a package name)
    set -l value_flags --workspace -w --prefix -C --registry --tag --otp \
        --userconfig --globalconfig --cache --proxy --https-proxy

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
        # Skip all flags
        string match -q -- '-*' $arg; and continue
        # Skip local paths and git/http URLs
        string match -qr -- '^(file:|git[+:]|https?:|\.\.?/|/)' $arg; and continue

        # Parse pkg@version — handle scoped packages (@scope/name[@ver])
        set -l pkg_name ""
        set -l pkg_ver ""
        if string match -qr -- '^@' $arg
            # @scope/name or @scope/name@version
            set -l body (string sub -s 2 $arg)         # strip leading @
            set -l parts (string split -m 1 '@' $body)
            set pkg_name "@$parts[1]"
            test (count $parts) -ge 2; and set pkg_ver $parts[2]
        else
            set -l parts (string split -m 1 '@' $arg)
            set pkg_name $parts[1]
            test (count $parts) -ge 2; and set pkg_ver $parts[2]
        end

        test -z "$pkg_name"; and continue
        set -a triples npm $pkg_name $pkg_ver
    end

    if test (count $triples) -eq 0
        command npm $argv
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
        echo "pkg-age-guard: blocked npm packages (too new): "(string join ', ' $blocked) >&2
        echo "  Override: PKG_AGE_BYPASS=1  |  Disable: PKG_AGE_MIN_DAYS=0" >&2
        set -q PKG_AGE_BYPASS; or return 1
        echo "  PKG_AGE_BYPASS set — continuing." >&2
    end

    command npm $argv
end
