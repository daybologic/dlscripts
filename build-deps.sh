perl -ne 'next if /^#/; $p=(s/^Build-Depends-Indep:\s*/ / or (/^ / and $p)); s/,|\n|\([^)]+\)//mg; print if $p' < debian/control
