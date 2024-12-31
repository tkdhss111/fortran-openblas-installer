program test_blas95
    use blas95, only: dot
    implicit none

    ! Declare variables
    real(8), allocatable :: x(:), y(:)
    real(8) :: result
    integer :: n, i

    ! Initialize vector size
    n = 5

    ! Allocate vectors
    allocate(x(n), y(n))

    ! Initialize vectors
    do i = 1, n
        x(i) = real(i, kind=8)     ! x = [1.0, 2.0, 3.0, 4.0, 5.0]
        y(i) = real(n - i + 1, 8)  ! y = [5.0, 4.0, 3.0, 2.0, 1.0]
    end do

    ! Compute dot product using BLAS95 interface
    result = dot(x, y)  ! ddot computes the dot product of two vectors

    ! Print the result
    print *, "Dot product of x and y: ", result

    ! Deallocate vectors
    deallocate(x, y)
end program test_blas95
