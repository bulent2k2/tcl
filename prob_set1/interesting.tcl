source u.tcl

Doc Quadratic Formula {
    # ax2 + bx + c = 0
     Soln: (1/2a) * (-b +/- sqrt(b^2 - 4ac))
    # p := golden ratio:
    Rectangle with a height of 1 and length of p:
      p^2 - p - 1 = 0
    # fibonacci: fib(N+1) = p * fib(N) when N->inf!
    Soln: a=1 b=-1 c=-1 =>
       = 0.5 * (1 + sqrt(5))              sqrt(5) = 2.236
       = 1.618
}
