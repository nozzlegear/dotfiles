# Source: https://stackoverflow.com/a/68119286
function get-version-changes -d "Attempts to parse out version changes from a changelog file" -a changelogVersion -a fileLocation
    if test -z "$version"
        set_color yellow
        echo "Usage:"
        echo "  getVersionChanges \"1.2.3\" [path/to/changelog.md]"
        echo
        set_color red
        echo "You must supply a version to search for"
        return 1
    end

    awk -v ver="$changelogVersion" '/^#+ \[/ { if (p) { exit }; if ($2 == "["ver"]") { p=1; next} } p && NF' "$fileLocation"
end
