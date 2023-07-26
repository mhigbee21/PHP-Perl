# PHP-Perl

PHP::Perl is very small mod_perl module that gives you the ability to embed Perl into html like PHP.

```
## Installation
The directions assume that you already have mod_perl 2 installed on your linux machine or container. 

```
## Files

```
Copy: startup.pl to /usr/local/apache/libs
Copy: the PHP dir to /usr/local/apache/libs

Add startup.pl to the Apache conf file

PerlRequire /usr/local/apache/libs/startup.pl

Add to virtual host record...

  PerlsetVar webconfig /{filepath}/{filename}
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
## Working with Forms..

```
See form.pl

Text
<input type="text" name="textbox1" value="<?perl $in{textbox1}?>">

Textarea
<textarea name="textarea1"><?perl $in{textarea1}?></textarea>


Selects
<select id="company" name="company">
<option <?perl if ($in{company} == 1 ){print 'selected';} ?> value="1">Apple</option>
<option <?perl if ($in{company} == 2 ){print 'selected';} ?> value="2">Samsung</option>
<option <?perl if ($in{company} == 3 ){print 'selected';} ?> value="3">HTC</option>
</select>

Checkboxs
<input type="checkbox" name="checkbox1" <?perl if($in{checkbox1} eq 'Y'){print 'checked';}?> value="Y">

Radios
<input type="radio" name="radio1" <?perl if($in{radio1} eq 'A'){print 'checked';}?> value="A">
<input type="radio" name="radio1" <?perl if($in{radio1} eq 'B'){print 'checked';}?> value="B">



```
## Config file

```

		You can use a config file for database, memcached or another configuration variables...

		# add the path to your config file in httpd.conf
		PerlsetVar webconfig /{filepath}/{filename}
	
		see web.config

```
## Database
    
```

	Set the database connection information in web config
	
	database=php_perl
	dbhost=localhost
	dbuser=root     
	dbpass=PerlRuleZ
	driver=DBI:mysql	

	Access the Database with the variable $dbh which is set in mod_perl handler


```

## Authors

* **Mark Higbee**  


## License

This project is licensed under the MIT License
