package PHP::Perl;
use strict;
use warnings;
our( %in, $dbh, $cache, $config );
use Apache2::Const qw(FORBIDDEN OK);
use Apache2::RequestUtil;
use Data::Dumper;
use Carp;
use IO::String;
use DBI;
use Cache::Memcached;
	
sub handler
{
	my $r = shift;

	return FORBIDDEN if ( $r->filename() !~ /\.perl$|\.pl/i );

	# define path to webconfig in httpd.conf
	# PerlSetVar webconfig /{filepath}/web.config
	my $webconfig = $r->dir_config('webconfig');

	if( $webconfig )
	{
		$config ||= parseWebConfig( $webconfig );
		#warn Dumper $config;
		
		if( exists $config->{'memcached'} )
		{ 
			$cache = new Cache::Memcached { 'servers' => [$config->{'memcached'}] };
		}	

		if( exists $config->{database} )
		{
			$dbh ||= dbconnect( $config );
		}
	}

	%in = ();	
 
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
  		my $str_fh = IO::String->new($result);
  		my $old_fh = select($str_fh);
	
		$result .= eval "$code";  

  		#reset default fh to previous value
  		select($old_fh) if defined $old_fh;

                if( $@ )
                {
                        Carp::cluck( "$@" );
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
		close( $FILE );
		return $contents;
	}

	return "The file " . "$path$file" . " doesn't exist"; 
}

sub parseWebConfig
{
	my $file = shift;

	my $conf = {};

	if ( -e $file  )
	{
		open( my $fh, '<', $file ); 

		while ( <$fh> )
		{
			$_ =~ s/(.*)\#.*/$1/;
			$_ =~ s/^\s*(.*?)\s*$/$1/;
			my ($l,$r) = split('=',$_) if (/=/);
			chomp $r;
			$conf->{$l} = $r if ($l);
		}
		close( $fh );
	}
	else
	{
		croak "The file $file doesn't exist";
	}

	return $conf;
}

sub dbconnect
{
	my $conf = shift;

	$conf->{'driver'} = "DBI:mysql" unless $conf->{'driver'};	
	
	return DBI->connect("$conf->{'driver'}:$conf->{'database'};host=$conf->{'dbhost'}"
		,"$conf->{'dbuser'}","$conf->{'dbpasswd'}"
		,{AutoCommit=>1,RaiseError=>1}) || carp("$DBI::errstr");	
}


=pod
	
	Quick START
	
	Add this to apache conf.

  PerlSetVar webconfig /{filepath}/web.config	
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
