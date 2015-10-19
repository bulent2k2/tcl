foreach cmd {
    {info script}
    {set argv0}
} {
    puts "$cmd returns [eval $cmd]"
}

