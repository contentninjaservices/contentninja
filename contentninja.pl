#!/usr/bin/perl

use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT);
our $VERSION = "0.8.7";
use Text::Markdown 'markdown';
# use File::Copy::Recursive qw(dircopy);
use lib ("./lib");
use Time::HiRes qw(time);
use SPP;
use Date::Manip;
use POSIX qw(strftime);
use Getopt::Long;

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

#printf STDERR " Time: %.6fs\n", time - $pstart if($profiling);
$spp->logging(sprintf "Time: %.6fs", time - $pstart) if($profiling);
$spp->logging("Generate Page...");
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
	$page =~ s/\{% namespace %\}/$namespaces[1]/eg if ( $namespaces[1] );
	if ( $pheader->{menu} ) {
		if ( $namespaces[0] eq "ROOT" ) {
			$spp->addmenuentry($pheader->{menu}) 
		} 
    #elsif ( $namespaces[0] ne "ROOT" ) {
			$spp->addsubmenuentry($pheader->{menu},$namespaces[1]); 
		#}
	}

	$spp->output($page,$cfg->{public}."/$dir","$filebase.html");
	$pheader->{menu} = ""; 
	$pheader->{namespace} = ""; 
}
# print " OK \n";
$spp->logging(sprintf (" Time: %.6fs", time - $pstart)) if($profiling);

# navigation
my $nav = $spp->include("navigation.html"); 
my $navigation = $spp->{"menu"};
$nav =~ s/\{% navigation %\}/$navigation/eg;
$spp->output($nav,$cfg->{public},"/navigation.html");

foreach my $key (keys %{$spp->{"submenu"}}) {
 	next if($key =~ /\//);
	my $nav = $spp->include("navigation.html"); 
	my $navigation = $spp->{"submenu"}->{$key};
	$nav =~ s/\{% navigation %\}/$navigation/eg;
	$spp->output($nav,$cfg->{public},"/$key"."/navigation.html");
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


