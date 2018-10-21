<?perl include="header.pl"?>

<p> PHP::Perl Forms... </p>

PHP::Perl can remember form values.


<form action="" method="post">
<input type="hidden" name="cmd" value="printFormValues">

<br>
textbox1
<input type="text" name="textbox1" value="<?perl $in{textbox1}?>">

<br><br>
company
<select id="company" name="company">
<option <?perl if ($in{company} == 1 ){print 'selected';} ?> value="1">Apple</option>
<option <?perl if ($in{company} == 2 ){print 'selected';} ?> value="2">Samsung</option>
<option <?perl if ($in{company} == 3 ){print 'selected';} ?> value="3">HTC</option>
</select>

<br><br>
checkbox1
<input type="checkbox" name="checkbox1" <?perl if($in{checkbox1} eq 'Y'){print 'checked';}?> value="Y">

<br><br>
radio1

<input type="radio" name="radio1" <?perl if($in{radio1} eq 'A'){print 'checked';}?> value="A">
<input type="radio" name="radio1" <?perl if($in{radio1} eq 'B'){print 'checked';}?> value="B">

<br><br>
<button type="submit">Submit</button>

</form>

<p>
<?perl
	use Data::Dumper;

  	# %in is populated in the mod_perl handler 

	if( $in{cmd} eq "printFormValues" )
	{
		printFormValues();
	}

	sub printFormValues
	{
		print "<pre>";
		print Dumper %{in};
		print "</pre>";
	}
?>
</p>


