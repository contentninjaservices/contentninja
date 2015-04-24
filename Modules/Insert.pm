package Modules::Insert;

#
# {% Insert path/to/filea.markdown %}
# {% insert path/to/fileb.code %}
# {% insert path/to/filec.html %}
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
	while ( $text =~ /\{% insert (.*) %\}/g ) {
		my ($file) = $text =~ /\{% insert (.*) %\}/; 
		#my ($id,$file) = split(":", $file);
		#$self->{id} = $id;
		my $code = $self->loadinsert($file) ;
		$code = $self->replacer($code);
		$text =~s/\{% insert (.*?) %\}/$code/gsm;
	}
	return $text;
}

sub loadinsert{
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
