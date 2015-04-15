package Modules::Gallery;

sub new{
	my $class = shift;
	my ($self) = {};
	bless $self, $class;
	return $self;
}

sub run{
	my ($self,$text) = @_;
	my $output = "";
	# return $text; 
	# print "Plugin: Gallery loaded.\n";
	my $gallery = $text;
	# $gallery =~ s/\{% gallery %\}\n(.*\n)\{% endgallery %\}/$1/gs;
	# my (@i,@a) = $gallery =~ /\{% gallery %\}(.*?\.(jpg|gif|jpeg|png)):(.*?)\{% endgallery %\}/gm;
  # add multi galleries, regex with /gm; ist creapy. 
	my (@i,@a) = $gallery =~ /\{% gallery %\}(.*?\.(jpg|gif|jpeg|png)):(.*?)\{% endgallery %\}/m;

	# printf "Gal: %s - %s\n", @i, @a;
	# printf "Gal:\n%s\n", $gallery;
	
	my @lines  = split(/\015\012|\012|\015/,$gallery);
	foreach (@lines) {
		# printf "Line: %s\n", $_;
	  my ($file, $ext, $alt) = $_ =~ /(.*?\.(jpg|gif|jpeg|png)): (.*?)$/m;
	  # printf "File: %s \nAlt %s\n", $file, $alt;
	  my ($thumb) = $file =~ /(.*?)\..*?$/m;
	  # printf "Thumb: %s - %s \n" , $thumb, $ext;
	  # printf "<a href=\"%s\" class=\"fancybox\" title=\"%s\"><img src=\"%s_m%s\" alt=\"%s\" height=\"200\" /></a>\n", $file, $alt, $thumb, $ext, $alt;
		if ( $file ) {
	  	$output .= sprintf "<a href=\"%s\" class=\"fancybox\" rel=\"group\" title=\"%s\"><img src=\"%s_m.%s\" alt=\"%s\" height=\"200\" /></a>\n", $file, $alt, $thumb, $ext, $alt;
		}
	}
# 	my $stylefix = "<!-- Fix FancyBox style for OctoPress -->
# <style type=\"text/css\">
#   .fancybox-wrap { position: fixed !important; }
#   .fancybox-opened {
#     -webkit-border-radius: 4px !important;
#        -moz-border-radius: 4px !important;
#             border-radius: 4px !important;
#   }
#   .fancybox-close, .fancybox-prev span, .fancybox-next span {
#     background-color: transparent !important;
#     border: 0 !important;
#   }
# </style>";
	my $styleprefix = ""; 
	$output = "<div id=\"imagediv\"><ul>$output</div><div style=\"clear:left;\"></div>\n";
	$output = $output . "\n<script>\$(document).ready(function() {\n    \$(\".fancybox\").fancybox();\n  });\n</script>\n";
	$text =~ s/(\{% gallery %\}.*\{% endgallery %\})/$stylefix $output/sm;
	# print "Gallery ... $text"; 
	# print "Text "  . $text . "\n";
	return $text;
}

1;
