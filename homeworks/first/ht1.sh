ls -l | perl -na -e 'if ($F[0] ne "total") { print join(";", @F[0..7]).";"; print substr($_, (index($_, $F[7]) + length($F[7]) + 1)); }' > output1
