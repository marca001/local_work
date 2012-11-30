#!/usr/bin/perl
#use strict;
#use warnings;

use Data::ICal;
use Data::Dumper;
use Date::Simple::D8;
use Email::MIME;
use LWP::Simple;
###
#Pull copy of calendar from online
$file = 'https://www.google.com/calendar/ical/mdsa99%40gmail.com/public/basic.ics';
#$file = 'https://www.google.com/calendar/ical/ucr.edu_oco3j655u9fflpeqgv7t4pe82o%40group.calendar.google.com/private-ed0fcfa22b88ab9fdc023d2d9de4ac25/basic.ics';
#$file = 'http://www.google.com/calendar/ical/ucr.edu_oco3j655u9fflpeqgv7t4pe82o%40group.calendar.google.com/public/basic.ics';
$text = get $file;
$calendar = Data::ICal->new(data => $text);

if(!$calendar){
	print "Calendar not found";
} 

$events = $calendar->entries;
$today = Date::Simple::d8($ARGV[0]);
#$today = Date::Simple->new();

foreach $entry(@$events){	

	$summaryProperty = $entry->property('summary');
	$summary = $summaryProperty->[0]->{'value'};
	@summarySplit = split('-',$summary);

	$dateStartProperty = $entry->property('dtstart');	
	$dateEndProperty = $entry->property('dtend');
	
	$dateStart = Date::Simple::d8($dateStartProperty->[0]->{'value'});
	$dateEnd = Date::Simple::d8($dateEndProperty->[0]->{'value'});
	
	if($dateStart <= "$today" and 
		$dateEnd > "$today" and
		$summarySplit[1] eq "CIS OnCall"){
		print $summarySplit[2]."\n";
	}
}