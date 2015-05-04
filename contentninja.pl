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
	my $postbody = $spp->splitcontent($post);
  # Get the header Info Date, Title, Author, ....
	my $pheader = $spp->readheader($postheader);
	$spp->setthehash('pheader',$pheader);

	if ( $pheader->{"published"} =~ /false/ ) { print "Page published is false: $filename\n"; next; }
	my $content = $spp->include($pheader->{"layout"}.".html"); 
	$content =~ s/\{% content %\}/$spp->searchincludes(markdown($postbody))/eg;
	$content = $spp->searchincludes($spp->loadmodules($spp->contentparser($content))); 
	
	my $page = $spp->loadlayout($pheader->{"layout"});
	$page = $spp->searchincludes($page); 
	$page =~ s/\{% content %\}/$content/eg;
	# my $pagnition = "";
	$page = $spp->contentparser($page);
	$spp->addmenuentry($pheader->{menu}) if ( $pheader->{menu} );
	$spp->output($page,$cfg->{public}."/$dir","$filebase.html");
	$pheader->{menu} = ""; 
}
# print " OK \n";
$spp->logging(sprintf (" Time: %.6fs", time - $pstart)) if($profiling);

# navigation
my $nav = $spp->include("navigation.html"); 
my $navigation = $spp->{"menu"};
$nav =~ s/\{% navigation %\}/$navigation/eg;
$spp->output($nav,$cfg->{public},"/navigation.html");


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


