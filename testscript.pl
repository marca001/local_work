#!/usr/bin/perl
use IO::File;
use Data::ICal;
use Date::Simple;
use iCal::Parser;
use LWP::Simple;
use Data::Dumper;

###############################################################
# CIS On Call iCalendar Check Test
#	This is a modified version of oncall.pl that returns the next
#	12+ people on call based on the passed in date.
###############################################################

# Synopsis

# - Write a copy of ical to a file
# - Create a calendar hash by parsing ical file
# - Compare events in calendar hash with today's date
# - If event summary is "CIS On Call", 
# - store in hash to be printed

###
# - Write a copy of ical to a file
###

$file = 'https://www.google.com/calendar/ical/ucr.edu_oco3j655u9fflpeqgv7t4pe82o%40group.calendar.google.com/private-ed0fcfa22b88ab9fdc023d2d9de4ac25/basic.ics';
$text = get $file;
$newfile = 'testcal.ics';
getstore($file,$newfile);
$calendar = Data::ICal->new(filename => $newfile);

#If there is trouble downloading the file, end script
if(!$calendar){
	print "Calendar not found.";
	exit 1;
}

###
# - Create a calendar hash by parsing ical file
###

#Only populate calendar hash with dates from last week to next 12 weeks
#$today = Date::Simple->new();
$today = Date::Simple::d8($ARGV[0]);
$lastWeek = $today - 7;
$nextWeek = $today + 7*12;


#Parse ical file to get calendar hash
$fh = IO::File->new("testcal.ics","r");
$parser=iCal::Parser->new(start => $lastWeek->as_d8, end => $nextWeek->as_d8);
$hash = $parser->parse($fh);
$thisCal = $hash->{'events'};


#The calendar hash is a hash of hashes. 
#Iterate through each hash to get events
foreach $year(values %$thisCal){	
	foreach $month(values %$year){
		foreach $day(values %$month){
			foreach $event(values %$day){				
				$dateStart = $event->{'DTSTART'}->ymd;
				$dateEnd = $event->{'DTEND'}->ymd;
				@summarySplit = split('-',$event->{'SUMMARY'});
				
				###
				# - If event summary is "CIS On Call", 
				# - store in hash to be printed
				###
				
				if($summarySplit[1] eq "CIS OnCall"){
					$current = @summarySplit[2];
					$val = "(".$event->{'DTSTART'}->ymd." - ".$event->{'DTEND'}->ymd.") ".$summarySplit[2]."\n";
					$finalHash{$dateStart} = $val;
				}
			}
		}
	}
}

#Sort hash and print
foreach $value(sort {$finalHash{$a} cmp $finalHash{$b} } keys %finalHash){
	print $finalHash{$value};
}

