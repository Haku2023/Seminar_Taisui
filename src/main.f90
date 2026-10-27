program main
    implicit none(external)
    integer, parameter:: dp = selected_real_kind(15), k5 = selected_int_kind(5)
    ! real(dp), dimension(15)::a, a_new, x
    real(dp), dimension(200)::a, a_new, x
    real(dp):: dt, dx, u, courant, D
    integer(k5)::i, n, io, io2, io3, io4
    character(50) ::filename, flag
    !-if change length, change all 200 to n, and refine the a_init, also change 199 to n-1
    !-Also the loops n should be changed

    flag = "CIP-tan_d" !upwind | central | high_upwind | CIP | CIP-tan
    print '(2(A,I0,X))', "dp: ", dp, "k5: ", k5
    ! a = 0.0_dp; a(3:5) = 1.0_dp
    !-P3
    a = 0.0_dp; a(5:8) = 1.0_dp; a(9:11) = 1.2_dp; a(12:15) = 1.0_dp; D = 0.00_dp
    !-2D Comparision
    ! a = 0.0_dp; a(5:7) = 50.0_dp; D = 0.00_dp
    ! x = [(i, i=1, 15)]
    x = [(i, i=1, 200)]
    dt = 1.0_dp; dx = 5.0_dp; u = 1.5_dp; n = 1
    select case (flag)
    case ("upwind", "high_upwind", "CIP", "CIP_d", "CIP-tan_d")
        courant = dt*u/dx
    case ("central")
        courant = dt*u/dx
    end select
    print "(A,f4.1)", "Courant: ", courant
    print '(A)', "Initial Setting: "
    print '(3(A,f4.1,X),A,I0)', "dt: ", dt, "dx: ", dx, "u: ", u, "n: ", n
    print '(A,200(f7.2,X))', "a:     ", a
    ! write (filename, '(A,I0,A,I0,A,f3.1,A,f3.1,A)') "B-"//trim(flag)//"_dt-", int(dt), "_dx-", int(dx), "_u-", u, "_C-", courant, ".dat"!upwind_dt-1_dx-2_u-2.5.dat
    ! write (filename, '(A,I0,A,I0,A,3(f3.1,A))') "C-"//trim(flag)//"_dt-", int(dt), "_dx-", &
    !-T:test
    write (filename, '(A,I0,A,I0,A,3(f3.1,A))') "T1.0v2-"//trim(flag)//"_dt-", int(dt), "_dx-", &
        int(dx), "_u-", u, "_C-", courant, "_D-", D, ".dat"!upwind_dt-1_dx-2_u-2.5_C-1.0_D-1.0.dat
    open (newunit=io, file="../data/"//filename, status="unknown")
    open (newunit=io2, file="../data/ALL-"//filename, status="unknown")
    open (newunit=io3, file="../data/StarValue-"//filename, status="unknown")
    open (newunit=io4, file="../data/StarDeri-"//filename, status="unknown")
    write (io, '(199(f10.3,","),f10.3)') a
    write (io2, '(I0,f10.3)') n, sum(a)

    select case (flag)
    case ("upwind")
        call upwind_method()
    case ("central")
        call central_method()
    case ("high_upwind")
        call high_upwind_method()
    case ("CIP")
        call CIP_method()
    case ("CIP_d")
        ! call CIP_method()
        call CIP_method_with_diffusion()
    case ("CIP-tan_d")
        call CIP_tangent_method_with_diffusion()
    end select
! {{{
    close (io)
    close (io2)
    close (io3)
    close (io4)! }}}

CONTAINS
    subroutine central_method
        do i = 0, 150
            a_new = a - u*dt/2.0_dp/dx*(eoshift(a, 1, 0.0_dp) - eoshift(a, -1, 0.0_dp))
            a = a_new
            print '(A,I0)', "n: ", n
            print '(A,200(f7.2,X))', "a_new: ", a_new
            write (io, '(199(f10.3,","),f10.3)') a_new
            n = n + 1
        end do

    end subroutine central_method

    subroutine upwind_method

        do i = 0, 150
            a_new = a - u*dt/dx*(a - eoshift(a, -1, 0.0_dp))
            a = a_new
            print '(A,I0)', "n: ", n
            print '(A,200(f7.2,X))', "a_new: ", a_new
            write (io, '(199(f10.3,","),f10.3)') a_new
            n = n + 1
        end do
    end subroutine upwind_method

    subroutine high_upwind_method
        do i = 0, 150
            a_new = a - u*dt/dx/6.0_dp* &
                    (2.0_dp*eoshift(a, -2, 0.0_dp) - 10.0_dp*eoshift(a, -1, 0.0_dp) + &
                     9.0_dp*a - 2.0_dp*eoshift(a, 1, 0.0_dp) + eoshift(a, 2, 0.0_dp))
            a = a_new
            print '(A,I0)', "n: ", n
            print '(A,200(f7.2,X))', "a_new: ", a_new
            write (io, '(199(f10.3,","),f10.3)') a_new
            n = n + 1
        end do
    end subroutine high_upwind_method
    subroutine CIP_method
        real(dp), dimension(200):: va, vb, vc, vd
        real(dp), dimension(200)::da, da_new
        !-Step 1: get differential
        da = 0.0_dp; va = 0.0_dp; vb = 0.0_dp; vc = 0.0_dp; vd = 0.0_dp
        da = (eoshift(a, 1, 0.0_dp) - eoshift(a, -1, 0.0_dp))/2.0_dp/dx
        da(1) = 0.0_dp
        da(size(a)) = 0.0_dp
        print '(A,200(f7.2,X))', "da:    ", da
        do i = 0, 150
            !-Step 2: get a b c d
            da_new = 0.0_dp; a_new = 0.0_dp
            va = (2.0_dp*(eoshift(a, -1, 0.0_dp) - a) + dx*(da + eoshift(da, -1, 0.0_dp)))/dx**3
            vb = (3.0_dp*(eoshift(a, -1, 0.0_dp) - a) + &
                  dx*(eoshift(da, -1, 0.0_dp) + 2.0_dp*da))/dx**2
            vc = da
            vd = a
            a_new = va*(-u*dt)**3 + vb*(-u*dt)**2 + vc*(-u*dt) + vd
            da_new = 3.0_dp*va*(-u*dt)**2 + 2.0_dp*vb*(-u*dt) + vc - &
                     (eoshift(a, 1, 0.0_dp) - eoshift(a, -1, 0.0_dp))/2.0_dp/dx* &
                     (eoshift(da, 1, 0.0_dp) - eoshift(da, -1, 0.0_dp))/2.0_dp/dx &
                     *dt
            a = a_new
            da = da_new
            print '(A,I0)', "n: ", n
            print '(A,200(f7.2,X))', "a_new: ", a_new
            write (io, '(199(f10.3,","),f10.3)') a_new
            n = n + 1
        end do

    end subroutine CIP_method
    subroutine CIP_method_with_diffusion
        real(dp), dimension(200):: va, vb, vc, vd
        real(dp), dimension(200)::da, da_new, da_star, a_star
        !-Step 1: initial get differential
        da = 0.0_dp; va = 0.0_dp; vb = 0.0_dp; vc = 0.0_dp; vd = 0.0_dp
        da = (eoshift(a, 1, 0.0_dp) - eoshift(a, -1, 0.0_dp))/2.0_dp/dx
        da(1) = 0.0_dp
        da(size(a)) = 0.0_dp
        print '(A,200(f7.2,X))', "da:    ", da
        do i = 0, 150
            !-Step 2: get C,Cx star
            da_new = 0.0_dp; a_new = 0.0_dp; a_star = 0.0_dp; da_star = 0.0_dp
            va = (2.0_dp*(eoshift(a, -1, 0.0_dp) - a) + dx*(da + eoshift(da, -1, 0.0_dp)))/dx**3
            vb = (3.0_dp*(eoshift(a, -1, 0.0_dp) - a) + &
                  dx*(eoshift(da, -1, 0.0_dp) + 2.0_dp*da))/dx**2
            vc = da
            vd = a
            !-step 1 : advection c_star
            a_star = va*(-u*dt)**3 + vb*(-u*dt)**2 + vc*(-u*dt) + vd
            da_star = 3.0_dp*va*(-u*dt)**2 + 2.0_dp*vb*(-u*dt) + vc - &
                      (eoshift(a, 1, 0.0_dp) - eoshift(a, -1, 0.0_dp))/2.0_dp/dx* &
                      (eoshift(da, 1, 0.0_dp) - eoshift(da, -1, 0.0_dp))/2.0_dp/dx &
                      *dt
            !-step 2 : rest minus
            ! where (a_star <= 0.0_dp)
            !     a_star = 0.0_dp
            ! end where
            ! a_star = merge(a_star, 0.0_dp, a_star > 0.0_dp)
            !-step 3 : diffusion c_new
            a_new = a_star + (D*dt/dx**2)* &
                    (eoshift(a_star, 1, 0.0_dp) - 2*a_star + eoshift(a_star, -1, 0.0_dp))
            da_new = da_star + (eoshift(a_new, 1, 0.0_dp) - eoshift(a_star, 1, 0.0_dp) &
                                - eoshift(a_new, -1, 0.0_dp) + eoshift(a_star, -1, 0.0_dp)) &
                     /2.0_dp/dx
            a = a_new
            da = da_new
            print '(A,I0)', "n: ", n
            print '(A,200(f7.2,X))', "a_new: ", a_new
            write (io, '(199(f10.3,","),f10.3)') a_new
            n = n + 1

            ! mass balance
            print '(A,f10.3)', "=> ALL: ", sum(a_new)
            write (io2, '(I0,f10.3)') n, sum(a_new)
        end do

    end subroutine CIP_method_with_diffusion

    subroutine CIP_tangent_method_with_diffusion
        real(dp), dimension(200):: va, vb, vc, vd
        real(dp), dimension(200)::dh, dh_new, dh_star, h, h_new, h_star
        real(dp), parameter:: pi = 3.1415926535897932384626433_dp, tanfac = 0.9_dp
        real(dp):: h_b, a_max
        !-Step 1: initial get differential
        a_max = 1.0_dp

        !-haku test
        where (a > a_max)
            a = a_max
        end where
        !-
        h_b = tan(tanfac*pi*(-0.5_dp))
        h = tan(tanfac*pi*(a/a_max - 0.5_dp))
        ! write (io2, '(199(f10.3,","),f10.3)') h
        dh = 0.0_dp; va = 0.0_dp; vb = 0.0_dp; vc = 0.0_dp; vd = 0.0_dp
        dh = (eoshift(h, 1, h_b) - eoshift(h, -1, h_b))/2.0_dp/dx
        write (io3, '(199(f10.3,","),f10.3)') h
        write (io4, '(199(f10.3,","),f10.3)') dh
        ! print *, "dh(1): ", dh(1)
        dh(1) = 0.0_dp
        dh(size(a)) = 0.0_dp
        print '(A,200(f7.2,X))', "dh:    ", dh
        do i = 0, 150
            !-Step 2: get C,Cx star
            dh_new = 0.0_dp; h_new = h_b; h_star = h_b; dh_star = 0.0_dp
            va = (2.0_dp*(eoshift(h, -1, h_b) - h) + dx*(dh + eoshift(dh, -1, 0.0_dp)))/dx**3
            vb = (3.0_dp*(eoshift(h, -1, h_b) - h) + &
                  dx*(eoshift(dh, -1, 0.0_dp) + 2.0_dp*dh))/dx**2
            vc = dh
            vd = h
            h_star = va*(-u*dt)**3 + vb*(-u*dt)**2 + vc*(-u*dt) + vd
            dh_star = 3.0_dp*va*(-u*dt)**2 + 2.0_dp*vb*(-u*dt) + vc - &
                      (eoshift(h, 1, h_b) - eoshift(h, -1, h_b))/2.0_dp/dx* &
                      (eoshift(dh, 1, 0.0_dp) - eoshift(dh, -1, 0.0_dp))/2.0_dp/dx &
                      *dt
            !-step 3 : diffusion c_new
            ! a_new = a_star + (D*dt/dx**2)* &
            !         (eoshift(a_star, 1, 0.0_dp) - 2*a_star + eoshift(a_star, -1, 0.0_dp))
            ! da_new = da_star + (eoshift(a_new, 1, 0.0_dp) - eoshift(a_star, 1, 0.0_dp) &
            !                     - eoshift(a_new, -1, 0.0_dp) + eoshift(a_star, -1, 0.0_dp)) &
            !          /2.0_dp/dx
            h = h_star
            dh = dh_star
            ! a_new = (atan(h_star)/(pi*tanfac) + 0.5_dp)*50.0_dp
            a_new = (atan(h_star)/(pi*tanfac) + 0.5_dp)*a_max
            print '(A,I0)', "n: ", n
            print '(A,200(f7.2,X))', "a_new: ", a_new
            write (io, '(199(f10.3,","),f10.3)') a_new
            n = n + 1
            !haku test
            print *, "h_star(4): ", h_star(4)
            print *, "atan(h_star(4))", atan(h_star(4))
            print *, "atan(h_star(4))/pi", atan(h_star(4))/pi
            print *, "atan(h_star(4))/pi/0.9", atan(h_star(4))/pi/0.9_dp
            print *, "a_new(4): ", a_new(4)
            print *, "h_b: ", h_b

            ! mass balance
            ! print '(A,f10.3)', "=> ALL: ", sum(a_new)
            write (io2, '(I0,f10.3)') n, sum(a_new, mask=a_new > 0.0_dp)
            write (io3, '(199(f10.3,","),f10.3)') h_star
            write (io4, '(199(f10.3,","),f10.3)') dh_star
            ! if (n == 10) stop
            ! stop
        end do

    end subroutine CIP_tangent_method_with_diffusion
end program main

