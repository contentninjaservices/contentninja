package Modules::Includecode;

#
# {% includecode 1:path/to/codefilea.code %}
# {% includecode 2:path/to/codefileb.code %}
# {% includecode 3:path/to/codefilec.code %}
#

use MIME::Base64;

sub new{
	my $class = shift;
	my ($self) = {
		'count' => 0,
	};
	bless $self, $class;
	return $self;
}

sub run{
	my ($self,$text) = @_;
	# my $yid = $text;
	while ( $text =~ /\{% Contentinclude (.*) %\}/g ) {
		my ($file) = $text =~ /\{% Contentinclude (.*) %\}/; 
		# my ($id,$file) = split(":", $file);
		# $self->{id} = $id;
		my $include = $self->loadinclude($file) ;
		# $include = $self->replacer($content);
		# $text =~s/\{% Contentinclude ($self->{id}):(.*?) %\}/$include/gsm;
		$text =~s/\{% Contentinclude (.*?) %\}/$include/gsm;
	}
	return $text;
}

sub loadinclude() {
  my ($self,$file) = @_;
  my $cfg = $self->getthehash("cfg");
  my $fh=new IO::File($file,'r') || return('4 Error: Unable to read file '.$file.': '.$!);
  my $str=join('',<$fh>);
  $fh->close();
  $str = $self->searchincludes($str);
  return $str;
}
# sub searchincludes() {
#   my ($self,$data) = @_;
#   $data =~ s/\{% include (.*) %\}/$self->include($1)/eg;
#   return $data;
# }

1;
