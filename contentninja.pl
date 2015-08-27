#!/usr/bin/perl

use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT);
our $VERSION = "0.8.8.1";
use Text::Markdown 'markdown';
# use File::Copy::Recursive qw(dircopy);
use lib ("./lib");
use Time::HiRes qw(time);
use SPP;
use Date::Manip;
use POSIX qw(strftime);
use Getopt::Long;
use File::Path;

my ($debug, $t, $d, $td, $dt ) = 0 ;
my %h = ('debug' => \$debug, 't' => \$t, 'td' => \$td, 'dt' => \$dt);
GetOptions ( 'debug', 't' => \$t , 'd' => \$d, 'td' => \$td, 'dt' => \$dt);

if ( $t && $d ) { print "test deploy\n"; system("./rsync -t "); exit 0; }
if ( $t ) { print "test deploy\n"; system("./rsync -t "); exit 0; }
if ( $dt ) { print "test deploy\n"; system("./rsync -t "); exit 0; }
if ( $td ) { print "test deploy\n"; system("./rsync -t "); exit 0; }
if ( $d ) { system("./rsync "); exit 0; }

my $pstart = time;
my $spp = new SPP;
my $cfg = $spp->getthehash("cfg");

my $profiling = $cfg->{debug};
$profiling = 1 if ( $ENV{'DEBUG'} );
printf STDERR " Time: %.6fs\n", time - $pstart if($profiling);
$spp->logging(sprintf "Time: %.6fs", time - $pstart) if($profiling);
$spp->logging("Generate Page...");
rmtree("output");

###########################################r
# Pages generieren
#

$spp->logging("Generiere pages ...");
my @filelist = $spp->buildFileIndex();
foreach my $filename (@filelist) {
	my($dir, $filebase, $fileext) = $filename =~ /^source\/((?:[\w\-\.]+\/)*)([\w\-\.]+)\.(markdown|html)$/;
	my $post = $spp->loadpost("$filename");
	my $postheader = $spp->splitheader($post);
	my $postbody = $spp->splitcontent($post,1);
	# printf ("Test2: %s\n-------\n", $postbody);
  # Get the header Info Date, Title, Author, ....
	my $pheader = $spp->readheader($postheader);
	$spp->setthehash('pheader',$pheader);

	if ( $pheader->{"published"} =~ /false/ ) { print "Page published is false: $filename\n"; next; }
	my $content = $spp->include($pheader->{"layout"}.".html");
	$postbody = markdown($postbody);
	# printf ("Test: %s\n", $pheader->{"viewsource"});
	if ( $pheader->{"viewsource"} eq "true" ) {
		# printf ("Test2: %s\n", $postbody);
		$postbody = $postbody . "<pre><code>" . $postbody . "</code></pre>";
		# printf ("Test3: %s\n", $postbody);
	}
	$content =~ s/\{% content %\}/$spp->searchincludes($postbody)/eg;
	$content = $spp->searchincludes($spp->loadmodules($spp->contentparser($content)));
	my $page = $spp->loadlayout($pheader->{"layout"});
	$page = $spp->searchincludes($page);
	$page =~ s/\{% content %\}/$content/eg;
	$page = $spp->contentparser($page);
	my $namespace = $pheader->{namespace};
  my @namespaces = split(' ', $namespace);
	foreach my $keys (@namespaces) {
		printf ("\nkeys: %s\n", $keys) if($profiling);
		$page =~ s/\{% namespace %\}/$keys/eg if ( $keys ne "/" );
		if ( $pheader->{menu} ) {
			$spp->addsubmenuentry($pheader->{menu},$keys);
		}
	}
	print "spp->output $cfg->{public}/$dir/".$filebase.".html\n" if($profiling) ;

	$spp->output($page,$cfg->{public}."/$dir","$filebase.html");
	$pheader->{menu} = "";
	$pheader->{namespace} = "";
}
# print " OK \n";
$spp->logging(sprintf (" Time: %.6fs", time - $pstart)) if($profiling);

# navigation
# my $nav = $spp->include("navigation.html");
# my $navigation = $spp->{"menu"};
# $nav =~ s/\{% navigation %\}/$navigation/eg;
# $spp->output($nav,$cfg->{public},"/navigation.html");

foreach my $key (keys %{$spp->{"submenu"}}) {
 	# next if($key =~ /\//);
	printf ("\n\nNextRound\nKey: %s\n", $key) if($profiling);
	my $nav = $spp->include("navigation.html");
	my $navigation = $spp->{"submenu"}->{$key};
	print "navigation: $navigation\n" if($profiling);
	my @stopnamespace = split('/',$key);
	my $top = "";
	my $topcount = @stopnamespace;
	print "Top Count: $topcount\n" if($profiling);
	if ( $topcount >= 2 ) {
		for (my $i=1;$i<$topcount-1;$i++){
			print "XXX $stopnamespace[$i]\n" if($profiling);
			$top .= "/".$stopnamespace[$i];
			printf ("TOP: $top\n") if($profiling);
		}
	} else {
		$top = "/";
		print "1 Level Page $top\n" if($profiling);
	}
	if ( $top ne "/" ) {
		$top="/" if ( $top eq "" );
		print "WTF: $top - $key\n" if($profiling);
		$navigation = "<li><a href=\"$top\">Top</a></li>$navigation";
	}
	print "My Navigation: $navigation\n" if($profiling);
	$nav =~ s/\{% navigation %\}/$navigation/eg;
	my $pathkey = $key;
	my $delimiter = '/';
	$pathkey =~ s/-/$delimiter/eg;
	print "\t$cfg->{public}/$pathkey/navigation.html\n" if($profiling);
	$spp->output($nav,$cfg->{public},"$pathkey"."navigation.html");
}

$spp->logging("# copy all to public folder.");

#####################################
#
# copy all to public folder
#
### Other files
my $otherfiles = $spp->buildFileIndexNonMd();
foreach my $filename (@filelist) {
	my($dir, $filebase, $fileext) = $filename =~ /^source\/((?:[\w\-\.]+\/)*)([\w\-\.]+)\.(.*)$/;
	$spp->copyotherfiles($dir, $filebase.".".$fileext);
}

###
$spp->logging("Copy all files to public folder ");
$spp->copy2public();

$spp->logging(sprintf(" Time: %.6fs\n", time - $pstart)) if($profiling);

$spp->createtarball();

# system("./rsync");


