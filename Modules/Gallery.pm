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
	my $output = "";
	my $gallery = $text;
	# while ( $gallery =~ /\{% gallery (.*)%\}(.*)\{% endgallery %\}/g ) {
		my ($groupid,$lines) = $gallery =~ /\{% gallery (.*?|)%\}(.*?)\{% endgallery %\}/gsm;
		my @lines  = split(/\015\012|\012|\015/,$lines);
		# print "$id - $lines\n";
		foreach my $line (@lines) {
			# printf ("oneline: %s\n", $line);
			my (@id,@files,@alttext) = $gallery =~ /\{% gallery (.*?|)%\}(.*?(\|.*?|)):(.*?)\{% endgallery %\}/gsm;
	  		my ($file, $ext, $alt) = $line =~ /(.*?\.(jpg|gif|jpeg|png)): (.*?)$/m;
			my ($imagefile,$thumbfile) = split(/\|/, $file);
			# printf "Img: %s, th: %s ext: %s alt: %s\n", $file, $thumbfile, $ext, $alt if ($file ne "" );
	 		my ($thumb) = $file =~ /(.*?)\..*?$/m;
			if ( $thumbfile eq "" ) { $thumbfile = $thumb."_m.".$ext; }
			if ( $file ) {
	  			$output .= sprintf "<a href=\"%s\" class=\"fancybox\" rel=\"group%s\" title=\"%s\"><img src=\"%s\" alt=\"%s\" height=\"200\" /></a>\n", 
	  			$imagefile, $groupid, $alt, $thumbfile, $alt;
			}
		}
	# }
	my $styleprefix = "";
	$output = "<div id=\"imagediv\"><ul>$output</div><div style=\"clear:left;\"></div>\n";
	$output = $output . "\n<script>\$(document).ready(function() {\n    \$(\".fancybox\").fancybox();\n  });\n</script>\n";
	$text =~ s/(\{% gallery (.*?|)%\}.*\{% endgallery %\})/$stylefix $output/sm;
	# print "Gallery ... $text";
	# print "Text "  . $text . "\n";
	return $text;
}

1;
