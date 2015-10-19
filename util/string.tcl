proc string_trim {str {chars " "}} { ; # 'string trim' only trims prefix and suffix. We want to trim all interior chars, too
    regsub -all $chars $str ""
}
