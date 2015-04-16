package Modules::Codeblock;

use MIME::Base64;

sub new{
	my $class = shift;
	my ($self) = {};
	bless $self, $class;
	return $self;
}

sub replacer{
	my ($self,@value) = @_;
	my ($enc,$code,$return) = '';
	foreach my $text (@value) {
		$code = $code . $text;
	}
	$enc = encode_base64($code);
	$enc =~ s/\n//eg;
	$return = "<script>var decodedString = Base64.decode(\"$enc\"); document.write(\'<pre class=\"code\"><code class=\"code\">\'+ escapeHtml(decodedString) + \'<\/code><\/pre>\'); </script>";
	return $return; 
}

sub run{
	my ($self,$text) = @_;
	# print "Plugin: Codeblock loaded.\n";
  my $vals = $text; 	
	my (@codeblock) = $vals=~ /\{% codeblock %\}(.*?)\{% endcodeblock %\}/gsm;
	$replaced = $self->replacer(@codeblock);
	$text =~s/\{% codeblock.*?%\}(.*?)\{% endcodeblock %\}/$replaced/gsm;
	return $text;
}

1;
