package Modules::Soundcloud;

#
# https://www.youtube.com/watch?v=4tzhyfWHdLo
#
# {% soundcloud 189542558 %}
#
sub new{
	my $class = shift;
	my ($self) = {};
	bless $self, $class;
	return $self;
}

sub run{
	my ($self,$text) = @_;
	my $yid = $text;
	my $sc1 = '<iframe width="100%" height="450" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/';
	my $sc2= '&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false&amp;visual=true"></iframe>';
	$text =~ s/\{% soundcloud (.*?) %\}/$sc1.$1.$sc2/eg;
	return $text;
}

1;

