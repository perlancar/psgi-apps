#!/usr/bin/perl

# created: 2011-08-26

# todo: autodetect chinese text

use 5.010;
use strict;
use warnings;

use Dancer;
use JSON ();
use Lingua::ZH::WordSegmenter;

my $json = JSON->new->allow_nonref->utf8;

get '/' => sub {
    return <<'_';
<form method=POST>
Speed (WPM):<br><input name=wpm value=300><p>
Words per chunk:<br><select name=chunk_size><option>1<option>2<option>3<option>4<option>5</select><p>
Text:<br><textarea name=text cols=80 rows=14></textarea><p>
This is Chinese text (will split using special segmenter):<br><input type=checkbox name=is_chinese><p>
<input type=submit>
</form>
_
};

post '/' => sub {
    my $text   = params->{text};
    my $wpm    = params->{wpm};
    my $chunk_size = params->{chunk_size};

    my @words  = split /\s+/s, $text;
    my @chunks;
    while (@words) {
        my @chunk = splice @words, 0, $chunk_size;
        push @chunks, join(" ", @chunk);
    }
    return <<_;
<div id=display style="margin-left: auto; margin-right: auto; font-size: ${\(int(48-$chunk_size*3))}pt; text-align: center"></div>
<script>
var chunks = ${\($json->encode(\@chunks))}
var ms     = ${\(60/$wpm*1000)} // = $wpm wpm

function display_chunk(i) {
  if (i >= chunks.length) return
  chunk = chunks[i]
  document.getElementById("display").innerHTML = chunk
  setTimeout("display_chunk("+(i+1)+")", ms*${\($chunk_size)})
}
setTimeout("display_chunk(0)", 1000)
</script>

_
};

dance;
