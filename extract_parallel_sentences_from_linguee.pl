#!/usr/bin/perl
#mihael.arcan@deri.org
#28.02.2013

use strict;
use warnings;
use Benchmark;
use Data::Dumper;

use LWP::Simple;

use utf8;
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
my $t0 = new Benchmark;

my $file = shift;
my $source = shift;
my $target = shift;

open my $in, "<:utf8", $file or die "Error/read $!";

open my $out_src, ">:utf8", "parallel_data_linguee.$source" or die "Error/read $!";
open my $out_trg, ">:utf8", "parallel_data_linguee.$target" or die "Error/read $!";

my $src;
my $trg;
if ($source eq "de") {
	$src = "german";
} elsif ($source eq "en") {
	$src = "english";
}

if ($target eq "de") {
	$trg = "german";
} elsif ($target eq "en") {
	$trg = "english";
}

while (my $line=<$in>) {
	chomp($line);
	my ($term) = $line =~ /(.+?)$/;
	if ($term) {
		
		$term =~ s/\s,/,/g;
		$term =~ s/\// /g;
		$term =~ s/\s/+/g;	
		my $url = 'http://www.linguee.com/'.$src.'-'.$trg.'/search?source=auto&query="'.$term.'"&moreResults=1';
		my $html = get $url;
		
		if ($html) {
			while ($html =~ /(<tr id.+?\/tr>)/sg) {
				my $pair = $1;
				my ($s, $t) = $pair =~ /<td class='sentence left'.+?<div class='wrap'>(.+?)<div class='source_url_spacer'>.+?\/td>.+?<td class='sentence right.+?<div class='wrap'>(.+?)<div class='source_url_spacer'>.+?\/td>/s;
				if ($s && $t) {
					$s =~ s/\r\n//g;
					$t =~ s/\r\n//g;
					if ($s =~ /\[\.\.\.\]/) {
						my ($x) = $s =~ /<span class='tooltip_help' title='(.+?)'>/;
						$s =~ s/<span class='tooltip_help' title='.+?\/span>/$x/g;
					}
					if ($t =~ /\[\.\.\.\]/) {
						my ($x) = $t =~ /<span class='tooltip_help' title='(.+?)'>/;
						$t =~ s/<span class='tooltip_help' title='.+?\/span>/$x/g;
					}
					$s =~ s/\<.+?\>//g;
					$s =~ s/&quot;/"/g;
					$s =~ s/&#039;/'/g;
					
					$t =~ s/\<.+?\>//g;
					$t =~ s/&quot;/"/g;
					$t =~ s/&#039;/'/g;
					
					
					print $out_src "$s\n";
					print $out_trg "$t\n";
				}
			}
		} 
	}
}

#-----------------------------------------
print "\n--------------------\nthe code took: ", timestr(timediff(new Benchmark, $t0)), "\n";