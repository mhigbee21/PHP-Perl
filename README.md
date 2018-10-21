# PHP-Perl

PHP::Perl is very small mod_perl module that gives you the ablility to embed perl into html like PHP... 

```
## Installation
The directions assume that you already have mod_perl 2 installed on your linux machine or container... 

```
## Files

```
Copy: startup.pl to /usr/local/apache/libs
Copy: the PHP dir to /usr/local/apache/libs

Add startup.pl to the Apache conf file

PerlRequire /usr/local/apache/libs/startup.pl

Add to virtual host record...

  PerlModule PHP::Perl
  <LocationMatch ^/([^?.&=%+]+).pl$ >
        SetHandler perl-script
        PerlHandler PHP::Perl
  </LocationMatch>

Copy test.pl, header.pl, footer.pl to the home dir of your app...

Restart apache...

goto to http://yourwebapp.com/test.pl

```
## Usage

```
Place perl code inside php like tags...

<?perl 
		print "Hello World!";
?>

Include files

<?perl include="header.pl"?>


<?perl include="footer.html"?>

Supports form posts just like normal...

<form action="" method="post">
<input type="hidden" name="cmd" value="env">
<button type="submit">Get Env</button>
</form>

<p>
<?perl

	use Data::Dumper;
	use Config qw(myconfig);

  	# %in is populated by the mod_perl handler

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


```

## Authors

* **Mark Higbee**  


## License

This project is licensed under the MIT License
