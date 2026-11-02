subroutine runtime_probe() bind(C)
  use iso_c_binding
  real(c_double) :: value
  call random_number(value)
  if (value < 0.0_c_double .or. value >= 1.0_c_double) error stop 1
  print *, "Flang runtime passed"
end subroutine runtime_probe
