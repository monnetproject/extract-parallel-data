#!/usr/bin/perl
#mihael.arcan@yahoo.de
#22.10.2012

use strict;
use warnings;
use Benchmark;
use Data::Dumper;
$Data::Dumper::Useperl = 1;

my $t = time();

use utf8;
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
my $t0 = new Benchmark;

print "Time: ".gmtime(time())."\n\n";

my $ontology_file = shift;
open my $ontology, "<:utf8", $ontology_file or die "Error/read $!";

my %ontology;
my %hash;
my %dbpedia;

my %stopw_en = ("a" => 0, "about" => 0, "above" => 0, "after" => 0, "again" => 0, "against" => 0, "all" => 0, "am" => 0, "an" => 0, "and" => 0, "any" => 0, "are" => 0, "aren't" => 0, "as" => 0, "at" => 0, "be" => 0, "because" => 0, "been" => 0, "before" => 0, "being" => 0, "below" => 0, "between" => 0, "both" => 0, "but" => 0, "by" => 0, "can't" => 0, "cannot" => 0, "could" => 0, "couldn't" => 0, "did" => 0, "didn't" => 0, "do" => 0, "does" => 0, "doesn't" => 0, "doing" => 0, "don't" => 0, "down" => 0, "during" => 0, "each" => 0, "few" => 0, "for" => 0, "from" => 0, "further" => 0, "had" => 0, "hadn't" => 0, "has" => 0, "hasn't" => 0, "have" => 0, "haven't" => 0, "having" => 0, "he" => 0, "he'd" => 0, "he'll" => 0, "he's" => 0, "her" => 0, "here" => 0, "here's" => 0, "hers" => 0, "herself" => 0, "him" => 0, "himself" => 0, "his" => 0, "how" => 0, "how's" => 0, "i" => 0, "i'd" => 0, "i'll" => 0, "i'm" => 0, "i've" => 0, "if" => 0, "in" => 0, "into" => 0, "is" => 0, "isn't" => 0, "it" => 0, "it's" => 0, "its" => 0, "itself" => 0, "let's" => 0, "me" => 0, "more" => 0, "most" => 0, "mustn't" => 0, "my" => 0, "myself" => 0, "no" => 0, "nor" => 0, "not" => 0, "of" => 0, "off" => 0, "on" => 0, "once" => 0, "only" => 0, "or" => 0, "other" => 0, "ought" => 0, "our" => 0, "ours" => 0, "ourselves" => 0, "out" => 0, "over" => 0, "own" => 0, "same" => 0, "shan't" => 0, "she" => 0, "she'd" => 0, "she'll" => 0, "she's" => 0, "should" => 0, "shouldn't" => 0, "so" => 0, "some" => 0, "such" => 0, "than" => 0, "that" => 0, "that's" => 0, "the" => 0, "their" => 0, "theirs" => 0, "them" => 0, "themselves" => 0, "then" => 0, "there" => 0, "there's" => 0, "these" => 0, "they" => 0, "they'd" => 0, "they'll" => 0, "they're" => 0, "they've" => 0, "this" => 0, "those" => 0, "through" => 0, "to" => 0, "too" => 0, "under" => 0, "until" => 0, "up" => 0, "very" => 0, "was" => 0, "wasn't" => 0, "we" => 0, "we'd" => 0, "we'll" => 0, "we're" => 0, "we've" => 0, "were" => 0, "weren't" => 0, "what" => 0, "what's" => 0, "when" => 0, "when's" => 0, "where" => 0, "where's" => 0, "which" => 0, "while" => 0, "within" => 0, "who" => 0, "who's" => 0, "whom" => 0, "why" => 0, "why's" => 0, "with" => 0, "won't" => 0, "would" => 0, "wouldn't" => 0, "you" => 0, "you'd" => 0, "you'll" => 0, "you're" => 0, "you've" => 0, "your" => 0, "yours" => 0, "yourself" => 0, "yourselves" => 0);


while (my $line=<$ontology>) {
	chomp($line);
	$ontology{"original"}{lc($line)}=0;
	my @tokens = split(/\b\s*/,$line);
	foreach my $j (0 .. $#tokens-1) { 
		foreach my $i (0 .. $#tokens) {
			if ($i+$j <= $#tokens) {
				my $splited = join(" ",@tokens[$i..$i+$j]);
				$splited =~ s/\s+/ /g;
				if (not exists($stopw_en{lc($splited)})) {
					$ontology{"splited"}{$splited}=0;
					$hash{"struc1"}{$splited}{$line}=0;
					$hash{"struc2"}{$line}{$splited}=0;	
				}
			}
		}
	}
}

open my $in, "<:utf8", "data/category_labels_en.nt" or die "Error/read $!";
while (my $line=<$in>) {
	chomp($line);
	my ($conc, $lab) = $line =~ /.+?resource\/Category:(.+?)>\s<http.+?label>\s"(.+?)"\@en/;
	if ($conc && $lab) {
		if (exists($ontology{"original"}{lc($lab)})) {   # lc???
			$dbpedia{$lab}{"org"}{"concept"}=$conc;
			$hash{"lab2conc_full"}{$lab}=$conc;
			$hash{"conc2lab_full"}{$conc}=$lab;
		}
		if (exists($ontology{"splited"}{$lab})) {
			foreach my $orglab (keys %{$hash{"struc1"}{$lab}}) {
				$dbpedia{$orglab}{"splited"}{$lab}{"concept"}="$conc";
				$hash{"lab2conc_split"}{$lab}=$conc;
				$hash{"conc2lab_split"}{$conc}=$lab;
			}
		}
	}
}

open my $in_red_en, "<:utf8", "data/redirects_en.nt" or die "Error/read $!";
while (my $line=<$in_red_en>) {
	chomp($line);
	my ($syn, $red) = $line =~ /^<http:\/\/dbpedia.org\/resource\/(.+?)>\s<http:\/\/dbpedia.org\/ontology\/wikiPageRedirects>\s<http:\/\/dbpedia.org\/resource\/(.+?)>/;
	if ($syn && $red) {
		if (exists($hash{"conc2lab_full"}{$syn})) {
			$dbpedia{$hash{"conc2lab_full"}{$syn}}{"org"}{"redirect"}{$red}=0;
			$hash{"redirect_org"}{$red}{$hash{"conc2lab_full"}{$syn}}++;
		}
		if (exists($hash{"conc2lab_split"}{$syn})) {
			foreach my $orglab (keys %{$hash{"struc1"}{$hash{"conc2lab_split"}{$syn}}}) {
				$dbpedia{$orglab}{"splited"}{$hash{"conc2lab_split"}{$syn}}{"redirect"}{$red}++;
				$hash{"redirect_sp"}{$red}{$hash{"conc2lab_split"}{$syn}}++;
			}
		}	
	}
}


open my $indb, "<:utf8", "data/article_categories_en.nt" or die "Error/read $!";
while (my $line=<$indb>) {
	chomp($line);
	my ($conc, $category) = $line =~ /\/resource\/(.+?)>\s<http.+?resource\/Category:(.+?)>/;
	if ($conc) {
		if (exists($hash{"conc2lab_full"}{$conc})) {
			$dbpedia{$hash{"conc2lab_full"}{$conc}}{"org"}{"category"}{$category}++;
		}
		if (exists($hash{"redirect_org"}{$conc})) {
			foreach my $orglab (keys %{$hash{"redirect_org"}{$conc}}) {
				$dbpedia{$orglab}{"org"}{"category"}{$category}++;
			}
		}
		if (exists($hash{"conc2lab_split"}{$conc})) {
			foreach my $orglab (keys %{$hash{"struc1"}{$hash{"conc2lab_split"}{$conc}}}) {
				$dbpedia{$orglab}{"splited"}{$hash{"conc2lab_split"}{$conc}}{"category"}{$category}++;
			}
		}
		if (exists($hash{"redirect_sp"}{$conc})) {
			foreach my $sp (keys %{$hash{"redirect_sp"}{$conc}}) {
				foreach my $orglab(keys %{$hash{"struc1"}{$sp}}) {
					$dbpedia{$orglab}{"splited"}{$sp}{"category"}{$category}++;
				}
			}
		}
	}
}


foreach my $orglab (keys %dbpedia) {
	foreach my $cat (keys %{$dbpedia{$orglab}{"org"}{"category"}}) {
		$hash{"category"}{$cat}{"i1"} +=5;
		$hash{"category_summ_all"}++;
		$hash{"category"}{$cat}{"diff"}{$orglab}++;
	}
	foreach my $sp (keys %{$dbpedia{$orglab}{"splited"}}) {
		foreach my $cat_sp (keys %{$dbpedia{$orglab}{"splited"}{$sp}{"category"}}) {
			$hash{"category_summ_all"}++;
			$hash{"category"}{$cat_sp}{"i1"}++;
			$hash{"category"}{$cat_sp}{"diff"}{$sp}++;
		}
	}
	foreach my $cat (keys %{$dbpedia{$orglab}{"org"}{"category"}}) {
		$hash{"category"}{$cat}{"i2"}=$hash{"category"}{$cat}{"i1"} / scalar(keys %{$hash{"category"}{$cat}{"diff"}});
		$hash{"category"}{$cat}{"i3"}=scalar(keys %{$hash{"category"}{$cat}{"diff"}}) / $hash{"category"}{$cat}{"i1"};
		$hash{"category"}{$cat}{"i4"}=scalar(keys %{$hash{"category"}{$cat}{"diff"}}) * $hash{"category"}{$cat}{"i1"};
		$hash{"category"}{$cat}{"i5"}=$hash{"category"}{$cat}{"i1"} ** scalar(keys %{$hash{"category"}{$cat}{"diff"}});
	}
}


open my $inca, "<:utf8", "data/article_categories_en.nt" or die "Error/read $!";
while (my $line=<$inca>) {
	my ($art, $cat) = $line =~ /<http:\/\/dbpedia.org\/resource\/(.+?)> <http:\/\/purl.org\/dc\/terms\/subject> <http:\/\/dbpedia.org\/resource\/Category:(.+?)>/;
	if ($cat && $art) {
		if (($hash{"category"}{$cat})&&($hash{"category"}{$cat}{"i1"} >  ($hash{"category_summ_all"} / scalar(keys %{$hash{"category"}})*3))) {
			$hash{"article"}{$art}++;
		}
	}
}


open my $inpl, "<:utf8", "data/page_links_en.nt" or die "Error/read $!";
my $stop=0;
while (my $line=<$inpl>) {
	chomp($line);
	my ($page, $link) = $line =~ /<http:\/\/dbpedia.org\/resource\/(.+?)>.+?<http:\/\/dbpedia.org\/resource\/(.+?)>/;
	if ($page && $link) {
		if ($link =~ /^Category:(.+?)$/) {
			my $cat = $1;
			$hash{"pages"}{$page}{"category"}{$cat}=0;
		} else {
			$hash{"pages"}{$page}{"resource"}{$link}=0;
		}
	}
}


foreach my $art (keys %{$hash{"article"}}) {
	foreach my $cat (keys %{$hash{"pages"}{$art}{"category"}}) {
		$hash{"categories_final"}{$cat} +=3;
		$hash{"categories_final_sum"}++;
	}
	foreach my $link (keys %{$hash{"pages"}{$art}{"resource"}}) {
		foreach my $cat (keys %{$hash{"pages"}{$link}{"category"}}) {
			$hash{"categories_final"}{$cat}++;
			$hash{"categories_final_sum"}++;
		}
	}
}


open my $inca2, "<:utf8", "data/article_categories_en.nt" or die "Error/read $!";
while (my $line=<$inca2>) {
	my ($art, $cat) = $line =~ /<http:\/\/dbpedia.org\/resource\/(.+?)> <http:\/\/purl.org\/dc\/terms\/subject> <http:\/\/dbpedia.org\/resource\/Category:(.+?)>/;
	if ($cat && $art) {
		if ((exists($hash{"categories_final"}{$cat}))&&($hash{"categories_final"}{$cat} > ($hash{"categories_final_sum"} / scalar(keys %{$hash{"categories_final"}})*10))) {
			$hash{"article_final"}{$art}++;
		}
	}
}



open my $inlde, "<:utf8", "data/interlanguage_links_en.nt" or die "Error/read $!";
while (my $line=<$inlde>) {
	my ($art, $de) = $line =~ /<http:\/\/dbpedia.org\/resource\/(.+?)> <http:\/\/dbpedia.org\/ontology\/wikiPageInterLanguageLink> <http:\/\/de.dbpedia.org\/resource\/(.+?)>/;
	if ($art && $de) {
		if (exists($hash{"article_final"}{$art})) {
			$hash{"final"}{$art}{$de}++;
		}
	}
} 
open my $out, ">:utf8", "wikipedia_en_de.dict" or die "Error/read $!";
print $out Dumper \%{$hash{"final"}};

print "\n--------------------\nthe code took: ", timestr(timediff(new Benchmark, $t0)), "\n";
