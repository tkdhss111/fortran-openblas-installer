program test_lapack95
    use lapack95
    implicit none

    ! Declare variables
    integer, parameter :: n = 3        ! Matrix size (3x3)
    real(8), allocatable :: A(:,:), b(:)
    integer, allocatable :: ipiv(:)    ! Pivot indices
    integer :: info                    ! Output status from LAPACK routines

    ! Allocate arrays
    allocate(A(n, n), b(n), ipiv(n))

    ! Initialize matrix A and vector b
    A = reshape([ &
        3.0d0, 1.0d0, 2.0d0, &
        6.0d0, 3.0d0, 4.0d0, &
        3.0d0, 1.0d0, 5.0d0], shape(A))

    b = [10.0d0, 22.0d0, 15.0d0]   ! Right-hand side vector

    ! Solve the system A * x = b using LAPACK's gesv routine
    call gesv(A, b, ipiv, info)

    ! Check for success
    if (info == 0) then
        print *, "Solution vector x:"
        print *, b
    else
        print *, "LAPACK gesv failed with info = ", info
    end if

    ! Deallocate arrays
    deallocate(A, b, ipiv)
end program test_lapack95
