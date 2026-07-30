! UNSUPPORTED: offload-cuda

! Reads two NAMELIST records whose scalar LOGICAL item has an empty
! assignment — first `l_flag=` with no spaces around the `=`, then
! `l_flag = ` with surrounding whitespace — and checks that in both
! cases l_flag keeps its .false. default while i_count picks up 7
! from the following assignment.  Covers the Flang NAMELIST
! empty-scalar extension listed in flang/docs/Extensions.md.

! RUN: %flang %isysroot -L"%libdir" %s -o %t
! RUN: env LD_LIBRARY_PATH="$LD_LIBRARY_PATH:%libdir" %t | FileCheck %s

! CHECK: l_flag=F
! CHECK-NEXT: i_count=7
! CHECK-NEXT: l_flag=F
! CHECK-NEXT: i_count=7
program p
  implicit none
  logical :: l_flag = .false.
  integer :: i_count = 42
  namelist /test_nml/ l_flag, i_count
  character(len=64) :: buf_tight  = "&test_nml l_flag= i_count=7 /"
  character(len=64) :: buf_spaced = "&test_nml l_flag = i_count = 7 /"

  read(buf_tight, nml=test_nml)
  print '(a,l1)', 'l_flag=', l_flag
  print '(a,i0)', 'i_count=', i_count

  ! Reset the defaults and re-read from the whitespace-decorated form.
  l_flag = .false.
  i_count = 42
  read(buf_spaced, nml=test_nml)
  print '(a,l1)', 'l_flag=', l_flag
  print '(a,i0)', 'i_count=', i_count
end program
