# quick and dirty script to download and rework highlight.js github themes to
# allow switching between dark and light

# assumption is, all css definitions are in the same order


function extract_hex {
    grep -e 'background:' -e 'color:' $1 | sed 's/;$//g' | awk '{print$NF}'
}


function format_vars {
    extract_hex $1 | cat -n | sed 's/^[ ]*/    --color-/g;s/\t/: /g;s/$/;/g'
}


src=https://raw.githubusercontent.com/highlightjs/highlight.js/main/src/styles
wget -qq $src/github.css
wget -qq $src/github-dark-dimmed.css

echo '/*
 * source themes downloaded from:
 * https://github.com/highlightjs/highlight.js/tree/main/src/styles
 * and merged to account for the theme switch
 */'
echo

echo ':root, .theme-dimmed {'
format_vars github-dark-dimmed.css
echo '}'
echo

echo '.theme-light {'
format_vars github.css
echo '}'
echo

awk '/.hljs/,0' github-dark-dimmed.css > .tmp-theme

format_vars github-dark-dimmed.css | while read line; do
    var=$(awk '{print$1}' <<< $line | sed 's/://g')
    hex=$(awk '{print$2}' <<< $line | sed 's/;//g')
    sed -i "s/$hex/var\($var\)/" .tmp-theme
done
cat .tmp-theme

rm .tmp-theme github*.css
