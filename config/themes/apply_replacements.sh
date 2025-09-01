#!/bin/bash
while read old new; do
    find /home/harri/.config/themes/test -type f -exec sed -i "s/$old/$new/gI" {} +
done < /home/harri/.config/themes/replacements.txt

