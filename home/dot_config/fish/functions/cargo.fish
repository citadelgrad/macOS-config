function cargo --wraps cargo --description "cargo with 3-day publish age guard on add/install"
    # cargo add <crate>[@version]
    # cargo install <crate>[@version]
    if not contains -- $argv[1] add install
        command cargo $argv
        return $status
    end

    set -l triples
    set -l skip_next false
    set -l value_flags --version -v --vers --git --branch --tag --rev \
        --path --registry --features -F --target --root --bin --example \
        --manifest-path --color --config -Z

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
        # Skip local path installs
        string match -qr -- '^(\.|/)' $arg; and continue

        # Parse crate@version (cargo uses @ as separator)
        set -l parts (string split -m 1 '@' $arg)
        set -l crate_name $parts[1]
        set -l crate_ver ""
        test (count $parts) -ge 2; and set crate_ver $parts[2]

        test -z "$crate_name"; and continue
        set -a triples crates $crate_name $crate_ver
    end

    if test (count $triples) -eq 0
        command cargo $argv
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
        echo "pkg-age-guard: blocked crates (too new): "(string join ', ' $blocked) >&2
        echo "  Override: PKG_AGE_BYPASS=1  |  Disable: PKG_AGE_MIN_DAYS=0" >&2
        set -q PKG_AGE_BYPASS; or return 1
        echo "  PKG_AGE_BYPASS set — continuing." >&2
    end

    command cargo $argv
end
