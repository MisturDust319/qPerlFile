#!/usr/bin/env perl

use strict;
use warnings;

my $defaultExt = shift(@ARGV);
#first command 
#is the default file save type
#	either .pl or .pm (a module)

sub ParseArgs {
	#first, make sure there are enough args
	#there should be at least one:
	#the hash arg
	if(@_ < 2) {
		return "No more arguments to parse.\n";
	}
	#check if a hash ref was passed as 1st val,
	#which is what will store parsed args
	unless(ref($_[0])) {
		return "The 1st argument should be a hash reference\n";
	}
	
	#get the hash to store args in
	my $argHash = shift;
	#get the current arg
	my $arg = shift;

	#set up some initial vals in the argHash	
	unless (%{$argHash}) { #...but only if argHash isn't empty
		%{$argHash} = (
			'files' => '', #files to make
			'extension' => '.pl', #extension to use
			'interative' => 0 #interactivity flag
		); 
	}
	
	#check if arg is a useable value
	#return if not
	return "No more arguments to parse.\n" unless ($arg);
	#check for extension override
	if($arg =~ /(?:-e|--extension)/) {
		$arg = shift(@_);
		#shift the next arg off the arg list
		#first, check if you got a value
		unless($arg) {
			return "No more arguments to parse.\n";
		}

		#if it matches a proper extension, use it
		if($arg =~ /(pl|pm)/) {
			print "setting default extension as $1.\n";
			$argHash->{'extension'} = ".$1";
			
			#now repeat w/ remaining arguments
			return ParseArgs(\%{$argHash}, @_);
		}

		#otherwise, put the arg back in the arg pile and repeat
		else {
			#now repeat w/ remaining arguments
			unshift(@_, $arg);
			return ParseArgs(\%{$argHash}, @_);
		}
	}

	#check for file w/ extension
	elsif($arg =~ /([a-zA-Z_\-.][a-zA-Z0-9_\-.]*\.(?:pl|pm))/g) {
		print "making file w/ provided extension: $1\n";
		$argHash->{'files'} = $argHash->{'files'} . $1 . ' ';
		#now repeat w/ remaining arguments
		return ParseArgs(\%{$argHash}, @_);
	}	

	#check for file w/o extension
	elsif($arg =~ /([a-zA-Z_\-.][a-zA-Z0-9_\-.]*)/g) {
		print "making file w/o provided extension: $1$argHash->{'extension'}\n";
		$argHash->{'files'} =  $argHash->{'files'} . $1 . $argHash->{'extension'} . ' ';
		#now repeat w/ remaining arguments
		return ParseArgs(\%{$argHash}, @_);
	}
	#lastly, a final test case	
	else {
		print "Something went wrong. Don't rightly know what. for now...\n";
	}
}

sub QuickWrite {
	my ($file, $text) = @_;
	#get the file and extension
	my $errorMessage = '';
	unless ($file) {
		$errorMessage = $errorMessage .  "no file provided to write to.\n";
	}
	unless ($text) {
		$errorMessage = $errorMessage . "no file provided to write to.\n";
	}


	#create a scalar var to hold the file data
	my $fileOut;
	
	#now open a file of the right type in current
	# directory
	#try to open a file
	#otherwise, return an error
	open($fileOut, '>', "./$file" ) or ($errorMessage = $errorMessage . "Couldn't open $file\n");
	
	if($errorMessage) {
		#print any error messages to STDERR, and return before
		#you hurt yourself
		print STDERR $errorMessage;
		return 0;
		#return false
	}

	print "Writing $file... ";

	#now append the custom header details
	print $fileOut "$text";
	
	close($fileOut);
	#close the file

	print " Finished writing file: $file\n";

	return 1;
	#return true
}

sub MakeFile {
	foreach my $file (@_) {
		print "processing $file. ";
	
		#every perl file should begin w/ this
		my $header =  "#!/usr/bin/env perl\nuse strict;\nuse warnings;\n\n";
		#write header file 
		QuickWrite($file, $header);
		
	}
}

#define a hash to hold processed command line args 
my %argHash;

#remove the scriptname from @ARGV

#pass %args to ParseArgs to get processed args
ParseArgs(\%argHash, @ARGV);

#make files based on data from %args
#test whether MakeFile is working

my @files = split(/\s/, $argHash{'files'});
MakeFile(@files);

my $TEST = 0;
if($TEST) {
	#testing section
	#use Test::More tests => 15;

	#tests for argument input
	#	w/ all options set

	my %testHash;
	is(ParseArgs(), "No more arguments to parse.\n", "Does it handle too few arguments?");
	is(ParseArgs('asdf', 'fdsa'), "The 1st argument should be a hash reference\n", "Check how it handles a non hash ref as 1st arg");
	#undef %testHash btwn tests, otherwise, output is messed up
	undef %testHash;

	ParseArgs(\%testHash, 'asdf', 'fdsa');
	is($testHash{'files'}, 'asdf.pl fdsa.pl ', "Check basic input");
	#undef %testHash btwn tests, otherwise, output is messed up
	undef %testHash;

	ParseArgs(\%testHash, 'asdf', 'fdsa', '-e', 'pm');
	is($testHash{'files'}, 'asdf.pl fdsa.pl ', "Check -e pm after file input");
	#undef %testHash btwn tests, otherwise, output is messed up
	undef %testHash;

	ParseArgs(\%testHash, '-e', 'pm', 'asdf', 'fdsa');
	is($testHash{'files'}, 'asdf.pm fdsa.pm ', "Check -e pm before file input");
	#undef %testHash btwn tests, otherwise, output is messed up
	undef %testHash;

	ParseArgs(\%testHash, 'asdf', 'fdsa', '-e');
	is($testHash{'files'}, 'asdf.pl fdsa.pl ', "Check faulty -e input: terminal -e");
	#undef %testHash btwn tests, otherwise, output is messed up
	undef %testHash;

	ParseArgs(\%testHash, '-e', 'asdf', 'fdsa');
	is($testHash{'files'}, 'asdf.pl fdsa.pl ', "Check faulty -e input: no valid extension after -e");
	#undef %testHash btwn tests, otherwise, output is messed up
	undef %testHash;

	ParseArgs(\%testHash, '--extension', 'pm', 'asdf', 'fdsa');
	is($testHash{'files'}, 'asdf.pm fdsa.pm ', "Check --extension pm");
	#undef %testHash btwn tests, otherwise, output is messed up
	undef %testHash;

	ParseArgs(\%testHash, 'asdf', 'fdsa', '--extension', 'pl');
	is($testHash{'files'}, 'asdf.pl fdsa.pl ', "Check --extension pl");
	#undef %testHash btwn tests, otherwise, output is messed up
	undef %testHash;

	ParseArgs(\%testHash, 'asdf', 'fdsa', '-e', 'pl', 'jjjj.pm', 'kkkk.pm');
	is($testHash{'files'}, 'asdf.pl fdsa.pl jjjj.pm kkkk.pm ', "Check -e if using opposite explicit extension");
	#undef %testHash btwn tests, otherwise, output is messed up
	undef %testHash;

	ParseArgs(\%testHash, '--extension', 'asdf', 'fdsa');
	is($testHash{'files'}, 'asdf.pl fdsa.pl ', "Check faulty --extension input\n");
	#undef %testHash btwn tests, otherwise, output is messed up
	undef %testHash;

	#tests for file writing
	#prototype: QuickWrite($file, $text)
	is(QuickWrite('',''), 0,'Check if QuickWrite can catch no input');
	
	my $testFile = '.test.QuickWrite.txt';
	is(QuickWrite($testFile, "testing\nQuickWrite"), 1, "Check if QuickWrite runs to end");
	#next, use the output of THIS test to test if QuickWrite actually wrote
	is(-e "./$testFile", 1, "Check if QuickWrite actually made a file");

	open( my $testFileHandle, '<', $testFile);
	is(<$testFileHandle>, "testing\n", 'Check if QuickWrite wrote to $testFile properly');
	close($testFileHandle);

}
