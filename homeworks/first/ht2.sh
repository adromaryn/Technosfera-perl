perl -ne '$c--; @arr = split /;/, $_ ; if($arr[4] >= 1024*1024){$c++; print $arr[8];} }{ print "All strings: ".$..", > 1M: ".($.+$c)."\n"'< output1
