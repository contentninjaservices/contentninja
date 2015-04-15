package Modules::Codeblock;

sub new{
	my $class = shift;
	my ($self) = {};
	bless $self, $class;
	return $self;
}

sub replacer{
	my ($self,$val) = @_;
	# my $ret = $val =~ s/\{/\&\#123;/gsm;
	# my $ret = $ret =~ s/\&/\&lt;/gsm;
	my $and = '{';
	my $lt = '<';
	$val =~ s/\{/$and;/gsx;
	$val =~ s/\&/$lt;/gsx;
	print "Test: $val\n";
	return $val
}

sub run{
	my ($self,$text) = @_;
	# print "Plugin: Codeblock loaded.\n";
	# $txext =~s/\{% codeblock.*?%\}(.*?)\{% endcodeblock %\}/<pre class="code"><code class="code">$self->replacer($1)<\/code><\/pre>/gsx;
  $val = $text; 	
	$val =~ s/\{% codeblock.*?%\}(.*?)\{% endcodeblock %\}/$1/eg;
	## # printf "Val: %s\n Text: %s\n", $val; 
	$replaced = $self->replacer($val);
	## # printf "Replaced: %s\n" , $replaced;
	# $text =~s/\{% codeblock.*?%\}(.*?)\{% endcodeblock %\}/<pre class="code"><code class="code">$1<\/code><\/pre>/gsm;
	$text =~s/\{% codeblock.*?%\}(.*?)\{% endcodeblock %\}/<pre class="code"><code class="code">$replaced<\/code><\/pre>/gsm;
	## print $text;
	return $text;
}

1;
