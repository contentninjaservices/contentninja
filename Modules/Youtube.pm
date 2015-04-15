package Modules::Youtube;

sub new{
	my $class = shift;
	my ($self) = {};
	bless $self, $class;
	return $self;
}

sub run{
	my ($self,$text) = @_;
	my $yid = $text;
	# print "Plugin Youtube loaded\n";
	my $y1 = '<div class="embed-video-container"><iframe src="http://www.youtube.com/embed/';
	my $y2 = '?HD=1;rel=0;showinfo=0;controls=0;autoplay=0" height=\"360\" width=\"640\" allowfullscreen></iframe></div>';
	$text =~ s/\{% youtube (.*?) %\}/$y1.$1.$y2/eg;
	return $text;
}

1;

