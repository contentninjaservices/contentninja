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
	while ( $text =~ /\{% includecode (.*) %\}/g ) {
		my ($file) = $text =~ /\{% includecode (.*) %\}/; 
		my ($id,$file) = split(":", $file);
		$self->{id} = $id;
		my $code = $self->loadincludecode($file) ;
		$code = $self->replacer($code);
		$text =~s/\{% includecode ($self->{id}):(.*?) %\}/$code/gsm;
	}
	return $text;
}

sub loadincludecode{
	my ($self,$file) = @_;
	my $fh=new IO::File("source/$file",'r') || return('1 Error: Unable to read default_index file "<source/' . $file .'": '.$!);
  my $code=join('',<$fh>);
  $fh->close();
	return $code; 
}

sub replacer{
  my ($self,$code) = @_;
  my $enc = encode_base64($code);
  $enc =~ s/\n//eg;
  my $return = "<script>var decodedString$self->{id} = Base64.decode(\"$enc\"); document.write(\'<pre class=\"code\"><code class=\"code\">\'+ escapeHtml(decodedString$self->{id}) + \'<\/code><\/pre>\'); </script>";
  return $return;
}

1;
