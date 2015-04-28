package Modules::Vimeo;

#
# https://www.youtube.com/watch?v=4tzhyfWHdLo
#
# {% soundcloud 189542558 %}
# <iframe src="https://player.vimeo.com/video/19021533" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <p><a href="https://vimeo.com/19021533">GH1 Vivaldi Summer Theme Guitar Cover</a> from <a href="https://vimeo.com/user5788631">joe&amp;dan films</a> on <a href="https://vimeo.com">Vimeo</a>.</p>
sub new{
	my $class = shift;
	my ($self) = {};
	bless $self, $class;
	return $self;
}

sub run{
	my ($self,$text) = @_;
	my $yid = $text;
	my $vimeo1 = '<iframe src="https://player.vimeo.com/video/';
	my $vimeo2 = '" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>';
	$text =~ s/\{% soundcloud (.*?) %\}/$vimeo1.$1.$vimeo2/eg;
	return $text;
}

1;

