package Modules::Codeblock;

use MIME::Base64;

sub new{
	my $class = shift;
	my ($self) = {};
	bless $self, $class;
	return $self;
}

sub replacer{
	my ($self,$value) = @_;
	# my $ret = $val =~ s/\{/\&\#123;/gsm;
	# my $ret = $ret =~ s/\&/\&lt;/gsm;
	# my $and = chr(60).chr(94); # '{';
	# my $lt = '<';
	# $val =~ s/\{/$and/gsx;
	# $val =~ s/\&/$lt/gsx;
	print "Test: $value\n";
	my $enc = encode_base64($value);
	$enc =~ s/\n//eg;
	$return = "<script>var decodedString = Base64.decode(\"$enc\"); document.write(\'<pre class=\"code\"><code class=\"code\">\'+ escapeHtml(decodedString) + \'<\/code><\/pre>\'); </script>";
	return $return; 
}

sub run{
	my ($self,$text) = @_;
	# print "Plugin: Codeblock loaded.\n";
	# $txext =~s/\{% codeblock.*?%\}(.*?)\{% endcodeblock %\}/<pre class="code"><code class="code">$self->replacer($1)<\/code><\/pre>/gsx;
  my $val = $text; 	
	$val =~ s/\{% codeblock.*?%\}(.*?)\{% endcodeblock %\}/$1/gsx;
	# $replaced =~ s/\{% codeblock.*?%\}(.*?)\{% endcodeblock %\}/$self->replacer($1)/eg;
	## # printf "Val: %s\n Text: %s\n", $val; 
	$replaced = $self->replacer($val);
	## # printf "Replaced: %s\n" , $replaced;
	# $text =~s/\{% codeblock.*?%\}(.*?)\{% endcodeblock %\}/<pre class="code"><code class="code">$1<\/code><\/pre>/gsm;
	# $text =~s/\{% codeblock.*?%\}(.*?)\{% endcodeblock %\}/<pre class="code"><code class="code">$replaced<\/code><\/pre>/gsm;
	$text =~s/\{% codeblock.*?%\}(.*?)\{% endcodeblock %\}/$replaced/gsm;
	## print $text;
	return $text;
}

1;
