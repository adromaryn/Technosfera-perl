package MusicLib::Helper::Image;

use strict;
use warnings;
use utf8;
use feature ':5.10';
use Exporter 'import';

use MIME::Base64;

sub track_image {
  my $id = shift;
  my $res = '';
  my $format = '';
  if (-e "users/$id.png") {
    open (IMAGE, "users/$id.png") and $format = 'png';
  } elsif (-e "users/$id.jpg") {
    open (IMAGE, "users/$id.jpg") and $format = 'jpg';
  }
  if ($format) {
    my $string = do{ local $/ = undef; <IMAGE>; };
    $res = "data:image/$format;base64," . encode_base64( $string );
  }
  return $res;
}

our @EXPORT = qw(track_image);

1;
