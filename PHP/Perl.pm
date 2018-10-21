package PHP::Perl;
use strict;
use warnings;
our( %GLOBAL, %in );
use Apache2::Const qw(FORBIDDEN OK);
use Apache2::RequestUtil;
use Data::Dumper;
use CGI;
use Carp;

sub handler
{
	my $r = shift;

	return FORBIDDEN if ( $r->filename() !~ /\.perl$|\.pl/i );
	 
	if( $r->method eq 'POST' )
        {
                my $post_data  = $r->content;
                my @nvp = split( /&/, $post_data );

                foreach my $nvp ( @nvp )
                {
                        my( $name, $value ) = split( /=/, $nvp );
                        $in{$name} = $value;
                }
        }
        elsif ( $r->method eq 'GET' )
        {
                my $query_string = $r->args;  # GET data
                my @nvp = split( /&/, $query_string );
                foreach my $nvp ( @nvp )
                {
                        my( $name, $value ) = split( /=/, $nvp );
                        $in{$name} = $value;
                }
        }

  	my $html = ${ $r->slurp_filename() };

	my $path = $ENV{'DOCUMENT_ROOT'};
	$path .= '/' unless ( $path =~ /\/$/ );
	
	$html = process( $html, $path );

	$r->content_type('text/html');
	$r->print( $html );
	return OK;
}

sub mergeIncludes
{
	my ( $html, $path ) = @_;

	my @fields = ( $html =~ m/<\?perl include="(.*?)"\?>/sg );

	foreach my $file( @fields )
        {
		my $tmp;
		$tmp = "$file is an Illegal File name! Supported files are (.pl .perl .htm .html)" if( $file !~ /\.pl$|\.perl$|\.html$|\.htm$/ );
                $tmp = getfile( $file, $path) unless $tmp;
                $html =~ s/<\?perl include="$file"\?>/$tmp/s;
        }

	return $html;
}

sub process
{
	my ( $html, $path ) = @_;

	$html = mergeIncludes( $html, $path );

	while( $html =~ /<\?perl/g )
	{
		$html =~ m/<\?perl(.*?)\?>/s;
                my $code = $1;
		
		# set STDOUT to a scalar...
		
		my $result;
		open my $fh, '>', \$result;
		my $stdout = select $fh;
		$result .= eval "$code";	
		close( $fh );                

                if( $@ )
                {
                        carp( "$@" );
                        $html =~ s/<\?perl(.*?)\?>/$@/s;
                }
                else
                {
			# remove the 1 from successful perl code blocks (prints)
			$result =~ s/1$//;
                        $html =~ s/<\?perl(.*?)\?>/$result/s;
                }
        }

	return $html;
}

sub getfile
{
	my ( $file, $path ) = @_;

	if( -e "$path$file" )
	{
		local $/;	
		open(my $FILE, "<", "$path$file") || carp "Can't Open file $path$file $!";
		my $contents = <$FILE>;
		return $contents;
	}

	return "The file " . "$path$file" . " doesn't exist"; 
}

=pod
	
	Quick START
	
	Add this to apache conf.
	
  PerlModule PHP::Perl
  <LocationMatch ^/([^?.&=%+]+).pl$ >
        SetHandler perl-script
        PerlHandler PHP::Perl
  </LocationMatch>

	
	add test.pl in your web app home dir...
	retart apache
	point browser to http://yourdomain.com/test.pl

<?perl 

	use Data::Dumper;
        use Config qw(myconfig);

        print "<pre>";
        print Dumper %ENV;
        print "</pre>";

        print "<br><br>";
        
        print "<pre>";
        print myconfig();
        print "</pre>";
?>


=cut

1;
