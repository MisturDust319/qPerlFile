===============================================================================
||                                                                           ||
||                      MisturDust319's qPerlFile                            ||
||                                                                           ||
||                   a perl script that                                      ||
||                              makes other perl scripts!                    || 
||                                                                           ||
===============================================================================
qPerlFile is a script that takes terminal arguments and makes perl scripts with
the same name and a little bit of boilerplate code in them

default behavior:
	takes the provided argument, and makes a .pl file w/ the follwing
	boilerplate:

	#!/usr/bin/env perl

	use warnings;
	use strict;

	if the file already has a provided extension, that extension is used 
	instead

options:
	-e --extension 
		changes the default extension based on the following extra
		parameters:
		.pm OR pm
			used to set default file extension to .pm,
			a perl module
		.pl OR pl
			used to set the default file extension to .pl,
			a normal Perl script.

		NOTE: the way the arguments are parsed, you can change the 
		default repeatedly for different sections
		EX:
			qPerlFile -e pm asdf fdsa -e pl ffff aaaa
		will make asdf.pm, fdsa.pm, ffff.pl, and aaaa.pl

		NOTE 2: if an extension is given in the terminal arg,
		that extension will override the new default extension

known bugs:
	1. More an error w/ the perl parser setup, the first passed argument
		won't always be recognized. This is due to how some setups
		handle terminal arguments.

todo:
	1. add interactive mode:
		this already partly exists in the code. basically, I want to
		add the option to monitor overwriting already used filenames
	2. a verbosity toggle:
		right now, some of the output can be lengthy, given the
		function. I hope to add the ability to toggle this output.

