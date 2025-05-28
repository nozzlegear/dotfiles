function copy-files-from-git-patch
for file in (rg "Only in ../" < diff.patch | rg --invert-match "/(obj|bin)" | rg -o --replace '$2/$3' '(AuntiERP/?)(.*): (.*)$')
if echo "$file" | rg -q "^/"
set file (string sub --start 2 "$file")
end

set source (path normalize "../AuntiERP/$file")
set -l targetDir (path dirname "$file")

if not test -d "$targetDir"
echo "Creating directory $targetDir"
mkdir -p "$targetDir"
end

if path is -d "$source"
echo "Copying whole directory $source to ."
cp -R "$source" .
else
echo "Copying file $source to $targetDir"
cp "$source" "$targetDir"
end
end
end
