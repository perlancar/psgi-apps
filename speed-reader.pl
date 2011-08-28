#!/usr/bin/perl

# created: 2011-08-26

# todo: autodetect chinese text

# saat ini jika kita submit chinese text, middleware Lint akan complaint 'body
# must be bytes, ...' karena itu kita disable aja Lint saat menjalankan ini,
# mis: 'plackup -E deployment speed-reader.pl'

use 5.010;
use strict;
use warnings;
use locale;
use utf8;

use Dancer;
use JSON ();
use Lingua::ZH::WordSegmenter;

my $json = JSON->new->allow_nonref->utf8;

my %latinpunc = (
    "，" => ", ",
    "、" => "、 ",
    "。" => ". ",
    "：" => ": ",
    "；" => "; ",
    "？" => "? ",
    "！" => "! ",
    "（" => "(",
    "）" => ")",
    "“" => "\"",
    "”" => "\"",
);

my $meta = <<_;
<!-- <meta http-equiv= "content-type" content="text/html;charset=utf-8" /> -->
_

get '/' => sub {
    return <<_;
<head>$meta</head>
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
    my $is_chinese = params->{is_chinese};

    my @words;
    if ($is_chinese) {
        state $seg = Lingua::ZH::WordSegmenter->new;
        #utf8::decode($text);
        #$text = Encode::encode('utf8', $text); # udah didecode sama something soalnya dan kalo 2x error
        #warn $text;
        $text = $seg->seg($text);
        my $latinre = "(?:".join("|", map { quotemeta } keys %latinpunc).")";
        $latinre =~ qr/$latinre/;
        $text =~ s/\s*($latinre)/$latinpunc{$1}/g;
        $text =~ s/\s{2}+/ /g;
    }
    @words = split /\s+/s, $text;

    my @chunks;
    while (@words) {
        my @chunk = splice @words, 0, $chunk_size;
        push @chunks, join(" ", @chunk);
    }

    unshift @chunks, "", "In 3...", "2...", "1...", "";

    return <<_;
<head>$meta</head>
<div style="height: 200px"></div>
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
setTimeout("display_chunk(0)", 0)
</script>

_
};

dance;
