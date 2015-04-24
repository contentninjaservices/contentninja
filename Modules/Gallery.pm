package Modules::Gallery;

#
# {% gallery %}
# /gallery/15783866983_27160395b9_b.jpg: Rodeo Dusk (_JonathanMitchellPhotography_)
# /gallery/10346743894_0cfda8ff7a_b.jpg|/gallery/MyThumb.jpg: Les papillons ont du chagrin (JMS')
# /gallery/14395875498_c43e5c4415_b.jpg: Chedder Gorge with goats looking (Si Photography)
# /gallery/15723733583_b4a7b52459_b.jpg: Pudacuo (OsvinC)
# {% endgallery %}

sub new{
	my $class = shift;
	my ($self) = {};
	bless $self, $class;
	return $self;
}

sub run{
  my ($self,$text) = @_;
  # my $yid = $text;
  while ( $text =~ /\{% gallery (.*) %\}/g ) {
    my ($file) = $text =~ /\{% gallery (.*) %\}/;
    my ($id,$file) = split(":", $file);
    $self->{id} = $id;
    my $gallery = $self->loadgallery($file) ;
		# printf ("Test: %s File: %s\n", $id, $file);
		my @lines  = split(/\015\012|\012|\015/,$gallery);
		foreach my $line (@lines) {
			my ($imagefile, $thumbnail) = ""; 
			my ($images,$alt) = split(":", $line);
			if ( $images =~ /\|/sm ) {
				($imagefile,$thumbnail) = split(/\|/, $images);
			} else {
				$imagefile = $images; 
			}
			my ($thumb,$ext) = $imagefile =~ /(.*?)\.(.*?)$/m;
			if ( $thumbnail eq "" ) { $thumbnail = $thumb."_m.".$ext; }
			# printf ("img: %s Thumb: %s, alt: %s\n", $imagefile, $thumbnail, $alt);
 		 	$output .= sprintf "<a href=\"%s\" class=\"fancybox\" rel=\"group%s\" title=\"%s\"><img src=\"%s\" alt=\"%s\" height=\"200\" /></a>\n", 
 		 			$imagefile, $self->{id}, $alt, $thumbnail, $alt;
 		 	my $styleprefix = "";
		}
		$output = "<div id=\"imagediv\"><ul>$output</div><div style=\"clear:left;\"></div>\n";
		# printf ("Test -> ID %s -> Output %s\n", $self->{id}, $output);
    $text =~s/\{% gallery ($self->{id}):(.*?) %\}/$output/gsm;
		$output = "";
  }
	$text = $text . "\n<script type=\"text/javascript\">\n	\$(document).ready(function() {\n    \$(\".fancybox\").fancybox();\n  });\n</script>\n";
  return $text;
}

sub loadgallery{
  my ($self,$file) = @_;
  my $fh=new IO::File("source/$file",'r') || return('1 Error: Unable to read default_index file "<source/' . $file .'": '.$!);
  my $gallery=join('',<$fh>);
  $fh->close();
  return $gallery;
}


1;
