package SPP;
use vars qw($VERSION @ISA @EXPORT);
require Exporter;
our $VERSION = "0.8.5";

use Cwd;
use LWP::Simple;
use File::Copy qw(move);
use File::Basename;
use File::Path qw(remove_tree);
use Term::ANSIColor;
use Data::Dumper;
use Module::Find;
use Text::Markdown 'markdown';
use File::Copy::Recursive qw(dircopy);
use Archive::Tar;
use File::Find::Rule;
use Cwd;

sub new{
	my $class = shift;
	my $self = {
		"menu" => undef,
	};
	bless $self, $class;
	$self->readconfig();
	# rmtree(public);
	remove_tree( "public" );
	return $self;
}

#################################################################
#  /BEGIN
#  Config
#
sub readconfig {
  my ($self) = @_;
  $dir = cwd();
  my $hash = {};
  $cfg->{basename} = basename($dir);
  $cfg->{dirname} = dirname($dir);
  my $config_file = "source/ninja.config";
  local *CF;
  open(CF,'<'.$config_file) or die "Open $config_file: $!";
  read(CF, my $data, -s $config_file);
  close(CF);
  my @lines  = split(/\015\012|\012|\015/,$data);
  my $config = {};
  my $count  = 0;
  foreach my $line(@lines)
  {
    $count++;
    next if($line =~ /^\s*#/);
    next if($line !~ /^\s*\S+\s*=.*$/);
    my ($key,$value) = split(/=/,$line,2);
    $key   =~ s/^\s+//g;
    $key   =~ s/\s+$//g;
    $value =~ s/^\s+//g;
    $value =~ s/\s+$//g;
    die "Configuration option '$key' defined twice in line $count of configuration file '$file'" if($cfg->{$key});
    $cfg->{$key} = $value;
  }
  $cfg->{postdir} = "$cfg->{'dirname'}/$cfg->{'basename'}/$cfg->{'source'}/$cfg->{'posts'}";
  $cfg->{draftdir} = "$cfg->{'dirname'}/$cfg->{'basename'}/$cfg->{'source'}/$cfg->{'drafts'}";
  $cfg->{stashdir} = "$cfg->{'dirname'}/$cfg->{'basename'}/$cfg->{'source'}/$cfg->{'stash'}";
  $cfg->{public} = "$cfg->{'dirname'}/$cfg->{'basename'}/$cfg->{'public'}";
  $self->setthehash('cfg',$cfg);
  return $self;
}
#  /END
#  Config
#
#################################################################

#################################################################
#  /BEGIN
#  Hashes und Variables
#

sub getthehash{
  my ($self,$key) = @_; # shift;
  my $hash = $self->{$key};
  return $hash;
}
sub setthehash{
  my ($self,$key,$hash) = @_;
  $self->{$key} = $hash;
  return $self;
}
sub getfromhash{
  my ($self,$name,$key) = @_;
  my $h = $self->getthehash($name);
  return $h->{$key};
}
sub settohash{
  my ($self,$name,$key,$value) = @_;
  my $h = $self->getthehash($name);
  $h->{$key} = $value;
  return $self;
}

sub debugwait{
  my $self = shift;
  my $debug = $self->getfromhash('cfg','debug');
  if ( $debug eq 1 ) {
    printf "Debugwait: %s\n", $debug;
    $wait = <STDIN>;
  }
  return $self;
}
sub addmenuentry{
	my ($self,$menuentry) = @_;
	# printf ("test: $menuentry\n");
	my @arr = split(' ', $menuentry);
	$self->{"menu"} .= sprintf "<li><a href=\"%s\">%s</a></li>", $arr[0], $arr[1];
	return self;
}
sub toggledebug{
  my ($self) = @_;
  my $debug = $self->getfromhash('cfg','debug');
  $debug = $debug eq 0 ? 1 : 0;
  $self->settohash('cfg','debug',$debug);
  return $self;
}
#  /END
#  Hashes und Variables
#
#################################################################
sub load_default_page{
	my ($self) = @_;
	my $fh=new IO::File($self->getfromhash("cfg","default_index"),'r') || return('1 Error: Unable to read default_index file '.$self->getfromhash("cfg","default_index").': '.$!);
	my $page=join('',<$fh>);
	$fh->close();
	return $page;
}
sub loadpost{
	my ($self,$file) = @_;
	my $fh=new IO::File($file,'r') || return('2 Error: Unable to read file '.$file.': '.$!);
	my $post=join('',<$fh>);
	$fh->close();
	return $post;
}

sub loadlayout() {
	my ($self,$layout) = @_;
	my $cfg = $self->getthehash("cfg");
	$layout = "themes/" . $cfg->{theme} . "/_layout/".$layout.".html";
	my $fh=new IO::File($layout,'r') || die('3 Error: Unable to read file '.$layout.': '.$!);
	my $data=join('',<$fh>);
	$fh->close();
	return $data;
}
sub splitheader{
	my ($self, $page) = @_;
	$page =~ s/---(.*?)---(.*)/$1/gsm;
	return $page;
}
sub splitcontent{
	my ($self, $page) = @_;
	$page =~ s/---(.*?)---(.*)/$2/gsm;
	$page = $self->loadmodules($page);
	return $page;
}
sub postmore{
	my ($self, $postmore) = @_; 
  my $part2 = "<script type=\"text/javascript\">
      \$(document).ready(function(){
        /* Hier der jQuery-Code */
        \$('#part" . $count . "-einblenden').click(function(){
          jQuery('#part$count').toggle('slow');
        })
        \$('#part$count-ausblenden').click(function(){
          jQuery('#part$count-einblenden').fadeIn('slow');
          jQuery('#part$count').fadeOut('slow');
        })
        jQuery('#part$count').fadeOut();
      });
    </script>
    <div class=\"post_info\">
      <span id=\"part$count-einblenden\" title=\"Weiterlesen Octopress ade, jetzt kommt SPP \">Ganzen Artikel lesen hier klicken</span>
    </div>
    <div id=\"part$count\">" . markdown($postmore) . "</div>";
	return $part2;
}
#sub markdown{
#	my ($self,$content) = @_;
#	# $content = markdown($content);
#	# print "Content: $content\n";
#	return $content;
#}

sub readheader() {
  my ($self,$header) = @_;
  my @arr = split("\n\r",$header);
	# printf "Header: %s\n", $header;
  foreach (@arr) {
    my @text = split(/\015\012|\012|\015/,$_);  # split('\n', $_);
    shift(@text);
    foreach my $key ( @text ) {
			# if ( $key =~ m/^layout\:.*?/ ) {
	      my @cfg = split(":",$key);
    	  $cfg[1] =~ s/^\ //;
    	  $cfg[2] =~ s/^\ //;
    	  $cfg[3] =~ s/^\ //;
  	    $pheader->{$cfg[0]} = $cfg[1];
				$pheader->{$cfg[0]} .= ":".$cfg[2] if $cfg[2] ;
				$pheader->{$cfg[0]} .= ":".$cfg[3] if $cfg[3] ;
    	  # $layout =~ s/^\ //;
			# }
    }
  }
  return $pheader;
}

# rss entries 
sub rssentries{
	my ($self, $postsPerPage, @keys) = @_; 
	my $entry = "";
	my $cfg = $self->getthehash("cfg");
	my $rssposts = $self->getthehash("posts");
	my $rss=0;
	while($rss++ < $postsPerPage && @keys){
	  my $currentKey = shift @keys;
	  my $filename  = sprintf "%s", keys($rssposts->{$currentKey});
	  # $indexpage   .= "<div id=\"new_post\">\n" . $rssposts->{$currentKey}{$filename}{'content'} . "\n</div>\n";
	  my $author    = $rssposts->{$currentKey}{$filename}{'author'};
	  my $postdate  = $rssposts->{$currentKey}{$filename}{'postdate'};
	  my $posttitle = $rssposts->{$currentKey}{$filename}{'posttitle'};
	  my $posturl   = $rssposts->{$currentKey}{$filename}{'posturl'};
	  my $postpath  = $rssposts->{$currentKey}{$filename}{'postpath'};
	  my $postfile  = $rssposts->{$currentKey}{$filename}{'postfile'};
	  my $postimage = $rssposts->{$currentKey}{$filename}{'image'};
	  $posturl      = $rssposts->{$currentKey}{$filename}{'posturl'};
	  my $content       = $rssposts->{$currentKey}{$filename}{'content'};
	  my $siteurl = $cfg->{"site.url"};
	  # printf "Feed : %s\n", $posttitle;
	  $entry .= "   <entry>\n",
	  $entry .= "     <title type=\"html\"><![CDATA[" . $posttitle . "]]></title>\n";
	  $entry .= "     <link href=\"". $cfg->{"site.url"}."/".$posts->{$currentKey}{$filename}{'posturl'} . "\"/>\n",
	  $entry .= "     <updated>" . $posts->{$currentKey}{$filename}{'itemtime'} . "</updated>\n";
	  $entry .= "     <id>" . $cfg->{"site.url"}."/".$posturl . "</id>\n",
	  $entry .= "     <content type=\"html\"><![CDATA[" . $content . "]]></content>\n",
	  $entry .= "   </entry>\n";
	}
	return $entry; 
}

sub include() {
  my ($self,$file) = @_; 
	my $cfg = $self->getthehash("cfg");
  my $p    = "themes/" . $cfg->{theme} . "/_includes";
  my $fh=new IO::File($p.'/'.$file,'r') || return('4 Error: Unable to read file '.$p."/".$file.': '.$!);
  my $str=join('',<$fh>);
  $fh->close();
  $str = $self->searchincludes($str);
  return $str;
}
sub searchincludes() {
  my ($self,$data) = @_;
  $data =~ s/\{% include (.*) %\}/$self->include($1)/eg;
  return $data;
}

# Modules 
sub loadmodules{
	my ($self, $body) = @_;
	@found = usesub Modules;
	foreach (@found) {
  	print "Found: $_\n";
  	$modulname = $_;
  	eval "use $modulname";
  	my $mods->{$module} = $modulname->new();
		# print "Body: XXX" . $body . "XXX\n";
  	$body = $mods->{$module}->run($body);
	}
	return $body;
}
sub output{
	my ($self,$html,$path,$output) = @_;
	my $count =0;
	my $cwd = getcwd();
	# print "Next-------\nPath: $path Output: $output\n";
	my @folders = split /\/|\\/, $path;
	chdir "/";
	map { if ( $_ ne "" ) { mkdir $_; chdir $_; $count++ } } @folders;
	for $i ( 1 .. $count  ) { chdir ".."; }
	# printf ("Output: %s/%s\n", $path, $output);
  # printf "cwd: %s\n", $cwd;
	chdir($cwd);
	open(FH,">$path/$output");
	print FH $html;
	close FH;
	return $self;
}
sub getCatsTags{
	my ($self,$header,$name,$hash) = @_;
	my ($values) = $header =~ /\n$name:\s{0,}\n((?:\s+-\s+[^\n]*\n)*)/s;
	my @newvalues = $values =~ /-\s+([^\n]*)\n/sg;
	foreach my $val (@newvalues) {
		$hash->{$val}++;
		# push(@arr,$val);
		# printf "Counter für $val: %s\n" , $hash->{$val};
	}
	return $hash;	
}
sub uniqarray {
	my ($self,@array) = @_;
	my %hash   = map { $_, 1 } @array;
	my @unique = keys %hash;
	return @unique;
}

sub createdirectory {
	my ($self,$path) = @_;
  my $count =0;
  my $cwd = getcwd();
  chdir "/"; 
	# print "cwd: %s\n" , $cwd;
  my @folders = split /\/|\\/, $path;
	# printf ("Output: %s/%s\n", $path, $output);
  # map { mkdir $_; chdir $_; $count++ } @folders;
  map { if ( $_ ne "" ) { mkdir $_; chdir $_; $count++ } } @folders;
  for $i ( 1 .. $count  ) { chdir ".."; }
  chdir($cwd);
	return $self;
}

sub copyotherfiles {
	my ($self,$dir, $filename ) = @_;
	my $cfg = $self->getthehash("cfg");
	$todir = $cfg->{public} . $dir . "/$filename";
	dircopy('source/',$cfg->{public}) or die $!;
	return $self;
}


sub copy2public {
	my ($self,@array) = @_;
	print "Kopiere CSS und Images ...";
	my $cfg = $self->getthehash("cfg");
	$fromdir = "themes/" . $cfg->{theme} . '/themefiles';
	$todir = $cfg->{public} . '/themefiles';
	$self->createdirectory($todir);
	dircopy($fromdir,$todir) or die $!;
	print " OK \n";
}

sub buildFileIndexNonMd {
		my ($self) = @_;
		my $cwd = "source";
		my $filelist;
    my $excludeDirs = File::Find::Rule->directory
                              ->name('_posts', 'public', '_includes', '_layout', 'fancybox') # Provide specific list of directories to *not* scan
                              ->prune          # don't go into it
                              ->discard;       # don't report it
    my $includeFiles = File::Find::Rule->file
                             ->name('*.markdown', '*.html', '*.jpg'); # search by file extensions
    my @files = File::Find::Rule->or( $excludeDirs, $includeFiles )
                                ->in($cwd);
    return @files;
}

sub buildFileIndex {
		my ($self) = @_;
		my $cwd = "source";
		my $filelist;
    my $excludeDirs = File::Find::Rule->directory
                              ->name('_posts', 'public', '_includes', '_layout', 'fancybox') # Provide specific list of directories to *not* scan
                              ->prune          # don't go into it
                              ->discard;       # don't report it
    my $includeFiles = File::Find::Rule->file
                             ->name('*.markdown', '*.html'); # search by file extensions
    my @files = File::Find::Rule->or( $excludeDirs, $includeFiles )
                                ->in($cwd);
    return @files;
}

##### Generate Sidebar Links for Tags and categories.
sub sidebarTagCatLinks{
	my ($self,$categories,$tags) = @_;
	foreach my $catkey (sort keys $categories) {
  	$cat .= sprintf "<li><a href='/blog/categories/%s'>%s (%s)</a></li>", $catkey, $catkey, $categories->{$catkey};
	}
	foreach my $tagkey (sort keys $tags) {
  	$sidebartag .= sprintf "<a href='/blog/tags/%s'>%s (%s)</a> ", $tagkey, $tagkey, $tags->{$tagkey};
	}
	return ($cat,$sidebartag);
}

sub createtarball{
	my ($self) = @_;
  # Create a new tar object:
	my $tar = Archive::Tar->new();
	chdir("output");
	# Add some files:
	$tar->add_files( <*> );
	
	# Finished:
	$tar->write( 'file.tar' );
	
	# Now extract:
	# my $tar = Archive::Tar->new();
	# $tar->read( 'file.tar' );
	# $tar->extract();
	return $self;
}

1;
