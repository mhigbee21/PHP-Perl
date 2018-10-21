<p> PHP::Perl </p>

<p>
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
</p>
