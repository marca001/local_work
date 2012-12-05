#!/usr/bin/perl
use IO::File;
use Data::ICal;
use Date::Simple;
use iCal::Parser;
use LWP::Simple;
use Data::Dumper;
use strict;

###############################################################
# CIS On Call iCalendar Check Test
#	This is a modified version of oncall.pl that returns the next 12+ people on call
###############################################################

# Synopsis

# - Write a copy of ical to a file
# - Create a calendar hash by parsing ical file
# - Compare events in calendar hash with today's date
# - If event summary is "CIS On Call", 
# - store in hash to be printed

# Usage

# - arg0 : Optional parameter of specified date (YYYYMMDD). Otherwise, assumes today
# - ex. perl testscript.pl 20120703

###
# - Write a copy of ical to a file
###

my $file = 'https://www.google.com/calendar/ical/ucr.edu_oco3j655u9fflpeqgv7t4pe82o%40group.calendar.google.com/private-ed0fcfa22b88ab9fdc023d2d9de4ac25/basic.ics';
my $text = get $file;
my $newfile = 'testcal.ics';
getstore($file,$newfile);
my $calendar = Data::ICal->new(filename => $newfile);

#If there is trouble downloading the file, end script
if(!$calendar){
	print "Calendar not found.";
	exit 1;
}

###
# - Create a calendar hash by parsing ical file
###

#Only populate calendar hash with dates from last week to next 12 weeks
my $today = Date::Simple->new();
if($ARGV[0] ne ""){
	$today = Date::Simple::d8($ARGV[0]);
}
my $lastWeek = $today - 7;
my $nextWeek = $today + 7*12;


#Parse ical file to get calendar hash
my $fh = IO::File->new("testcal.ics","r");
my $parser=iCal::Parser->new(start => $lastWeek->as_d8, end => $nextWeek->as_d8);
my $hash = $parser->parse($fh);
my $thisCal = $hash->{'events'};

my %finalHash;

#The calendar hash is a hash of hashes. 
#Iterate through each hash to get events
foreach my $year(values %$thisCal){	
	foreach my $month(values %$year){
		foreach my $day(values %$month){
			foreach my $event(values %$day){				
				my $dateStart = $event->{'DTSTART'}->ymd;
				my $dateEnd = $event->{'DTEND'}->ymd;
				my @summarySplit = split('-',$event->{'SUMMARY'});
				
				###
				# - If event summary is "CIS On Call", 
				# - store in hash to be printed
				###
				
				if($summarySplit[1] eq "CIS OnCall"){
					my $val = "(".$event->{'DTSTART'}->ymd." - ".$event->{'DTEND'}->ymd.") ".$summarySplit[2]."\n";
					$finalHash{$dateStart} = $val;
				}
			}
		}
	}
}

#Sort hash and print
foreach my $value(sort {$finalHash{$a} cmp $finalHash{$b} } keys %finalHash){
	print $finalHash{$value};
}

