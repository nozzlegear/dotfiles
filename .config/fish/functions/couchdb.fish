function couchdb --argument command
switch $command
case "compact"
echo "Running compact operation."
case "*"
echo "Invalid command \"$command\"."
end

argparse --min-args 3 \
    'url=!test -n "$_flag_value"' \
    'u/user=!test -n "$_flag_value"' \
    'p/password=!test -n "$_flag_value"' \
    -- $argv
or return

end
