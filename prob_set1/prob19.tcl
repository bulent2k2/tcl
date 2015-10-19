# prob 19 - Counting sundays (:-) days, weeks, years..
# How many Sundays fell on the first of the month during the twentieth century (1 Jan 1901 to 31 Dec 2000)?

proc answer {} {
    # for each month in each year from/to
    #   count days from from last month
    #   if sunday, incr
    lassign [first_monday] ref_day ref_month ref_year
    set days [days_in_year $ref_year]
    set from 1901; set to 2001
    assert [expr $from - $ref_year] 1 "<test args>"
    set sundays 0
    for {set year $from} {$year < $to} {incr year} {
	foreach month [months] {
	    if {"sun" == [what_day_of_week $days]} {
		incr sundays
	    }
	    incr days [day_count $month $year]
	}
    }
    return $sundays
}
proc first_monday {} { return "1 jan 1900" }
proc months {} { list jan feb mar apr may jun jul aug sep oct nov dec }
proc what_day_of_week {num_days_after_ref} {
    set day_of_week [lindex [days_in_week] [expr $num_days_after_ref % 7]]
}
proc days_in_week {} { return "mon tue wed thu fri sat sun" }
proc days_in_year {year} {
    variable table
    set days [day_count feb $year]
    foreach month [array names table] {
	incr days [day_count $month]
    }
    return $days
}

variable table
array set table {
    jan 31 mar 31 may 31 jul 31 aug 31 oct 31 dec 31
    apr 30 jun 30 sep 30 nov 30
}

proc day_count {month {year 0}} {
    variable table
    set elem table($month)
    if {[info exists $elem]} { return [set $elem] }
    if {$month != "feb"} { error "Got month=< $month >. Expecting one of [lsort [concat feb [array names table]]]." }
    if {$year == 0} { error "Need to know year for February!" }
    if {$year % 4 == 0} { ; # leap?
	if {$year % 100 == 0} {
	    if {$year % 400 == 0} { return 29 }
	    return 28
	}
	return 29
    }
    return 28
}

proc unit_tests {} {

    foreach {year count} {
	1600 29 2000 29
	1700 28 1800 28 1900 28 2100 28
	1904 29 1996 29 2004 29 2008 29
	1901 28 1902 28 1903 28 1905 28
    } {
	assert $count [day_count feb $year] "<day_count> year=$year"
    }

}

unit_tests
