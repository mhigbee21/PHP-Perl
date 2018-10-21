<?perl include="header.pl"?>

<p> PHP::Perl Form Test...</p>

<form action="" method="post">
<input type="hidden" name="cmd" value="env">
<button type="submit">Get Env</button>
</form>


<p>
<?perl

	use Data::Dumper;
	use Config qw(myconfig);
	# use CGI;

	# my $q = CGI->new;
  	# my %in = $q->Vars;	
	# moved this to the mod perl handler so all script tags will have access to the %in parameters

	if( $in{cmd} eq "env" )
	{
		printEnv();
	}

	sub printEnv
	{
		print "<pre>";
		print Dumper %ENV;
		print "</pre>";

		print "<br><br>";
	
		print "<pre>";
		print myconfig();
		print "</pre>";
	}

?>
</p>


