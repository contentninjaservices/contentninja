#!/usr/bin/perl

use strict;
use warnings;
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

printf STDERR " Time: %.6fs\n", time - $pstart if($profiling);
print "Generate Page...\n";
###########################################r
# Pages generieren
#

print "Generiere pages ...";
my @filelist = $spp->buildFileIndex();
foreach my $filename (@filelist) {
	my($dir, $filebase, $fileext) = $filename =~ /^source\/((?:[\w\-\.]+\/)*)([\w\-\.]+)\.(markdown|html)$/;
	my $post = $spp->loadpost("$filename");
	my $postheader = $spp->splitheader($post);

  # Get the header Info Date, Title, Author, ....
	my $pheader = $spp->readheader($postheader);
	my $postlayout = $pheader->{"layout"}; # spp->readheader($postheader);
	my $posttitle = $pheader->{"title"};
	# printf "Page Layout: %s - %s\n", $postlayout, $posttitle; 
	$posttitle 		=~ s/\"//g;
	my $pagetitle = $posttitle;
	# my $posttitle2 = $pheader->{"title"};
	# $posttitle2 		=~ s/\"//g;
	my $author 		= $pheader->{"author"};
	my $postdate 	= $pheader->{"date"};
	my $published = $pheader->{"published"};
	my $posturl		="/todo.html";
	my $postpath	="/";
	my $postfile	="todo.html";
	my $itemtime	=	$pheader->{"date"};
	my $postimage = $pheader->{'image'};
	if ( ! $postimage ) { $postimage = "/images/2014/08/thkommentare.png"; }
	$itemtime 		=~ s/\ /T/g if ($itemtime);
	$itemtime 	 .= "+2:00";
	# ($tags) = $spp->getCatsTags($postheader,"tags",$tags);
	# ($categories) = $spp->getCatsTags($postheader,"categories",$categories);

	if ( $published =~ /false/ ) { print "Das teil ist auf False: $filename\n"; next; }
	if ( ! $author ) { $author = "Rüdiger Pretzlaff"; }
	if ( ! $itemtime ) { $itemtime=$pheader->{"itemtime"}; }
	my $postbody = $spp->splitcontent($post);
	my $content = $spp->include($pheader->{"layout"}.".html"); 
	$content =~ s/\{% content %\}/$spp->searchincludes(markdown($postbody))/eg;
	$posttitle = "<a href=\"$posturl\">$posttitle</a>";
	# $content =~ s/\{\{ title \}\}/$posttitle2/eg;
	# print "Test: $posttitle2\n";
	$content =~ s/\{\{ postauthor \}\}/$author/eg;
	$content =~ s/\{\{ postdate \}\}/$postdate/eg;
	$content =~ s/\{\{ posturl \}\}/$posturl/eg;
	$content =~ s/\{\{ postimage \}\}/$postimage/eg;
	$content =~ s/\{\{ title \}\}/$posttitle/eg;
	$content = $spp->loadmodules($content);
	$content = $spp->searchincludes($content); 
	my $page = $spp->loadlayout($postlayout);
	$page = $spp->searchincludes($page); 
	$page =~ s/\{% content %\}/$content/eg;
	my $pagnition = "";
	$page =~ s/\{% pagnition %\}/$pagnition/eg;
	$page =~ s/\{\{ pagetitle \}\}/$cfg->{sitetitle}/eg;
	$page =~ s/\{\{ pagesubtitle \}\}/$cfg->{sitesubtitle}/eg;
	$page =~ s/\<\^/chr(123)/eg;
	if ( $pheader->{menu} ) {
		$spp->addmenuentry($pheader->{menu});
	}
	$spp->output($page,$cfg->{public}."/$dir","$filebase.html");
	$pheader->{menu} = ""; 
}
print " OK \n";
printf STDERR " Time: %.6fs\n", time - $pstart if($profiling);

# navigation
my $nav = $spp->include("navigation.html"); 
my $navigation = $spp->{"menu"};
$nav =~ s/\{% navigation %\}/$navigation/eg;
$spp->output($nav,$cfg->{public},"/navigation.html");


print "# copy all to public folder \n";

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
print "Copy all files to public folder ";
$spp->copy2public();
print " OK ";
printf STDERR " Time: %.6fs\n", time - $pstart if($profiling);

$spp->createtarball();

# system("./rsync");


