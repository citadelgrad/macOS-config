function uv --wraps uv --description "uv with 3-day publish age guard on add, pip install, tool install and run --with"
    set -l value_flags --index --index-url -i --extra-index-url --default-index \
        --find-links -f -r --requirements -c --constraints --overrides \
        --build-constraints -p --python --project --directory --package \
        --group --extra --optional --marker --tag --branch --rev \
        -e --editable --index-strategy --keyring-provider --exclude-newer \
        --cache-dir --config-file --link-mode --resolution --prerelease \
        --target --prefix --from --with-requirements --with-editable \
        --refresh-package --no-binary-package --no-build-package \
        --upgrade-package -P --reinstall-package --python-platform \
        --config-setting -C --env-file --script --color

    # Pass 1: find the subcommand words and any `run --with` values.
    set -l words
    set -l with_vals
    set -l skip_next false
    set -l want_with false

    for arg in $argv
        if $skip_next
            set skip_next false
            if $want_with
                set want_with false
                set -a with_vals $arg
            end
            continue
        end
        if test "$arg" = --with
            set skip_next true
            set want_with true
            continue
        end
        if string match -q -- '--with=*' $arg
            set -a with_vals (string replace -- '--with=' '' $arg)
            continue
        end
        if contains -- $arg $value_flags
            set skip_next true
            continue
        end
        string match -q -- '-*' $arg; and continue
        set -a words $arg
        # `uv run <cmd> ...`: later flags belong to the command, not to uv.
        test "$words[1]" = run -a (count $words) -ge 2; and break
    end

    # Pass 2: decide which tokens are package specs.
    set -l specs
    switch "$words[1]"
        case add
            set specs $words[2..-1]
        case pip tool
            if test "$words[2]" = install
                set specs $words[3..-1]
            end
        case run
            for v in $with_vals
                set -a specs (string split ',' -- $v)
            end
    end

    if test (count $specs) -eq 0
        command uv $argv
        return $status
    end

    set -l triples
    for arg in $specs
        string match -qr -- '^(\.|/|~|file:|git[+:]|https?:|ssh:)' $arg; and continue
        string match -q -- '*/*' $arg; and continue
        string match -qr -- '@\s*\S' $arg; and continue

        set -l pkg_name (string replace -r '^\s*([A-Za-z0-9._-]+).*$' '$1' -- $arg)
        set -l pkg_ver ""
        set -l pinned (string match -r -- '[A-Za-z0-9_\]]\s*==\s*([^,;\s=*]+)(?:[,;\s]|$)' $arg)
        test (count $pinned) -ge 2; and set pkg_ver $pinned[2]

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
