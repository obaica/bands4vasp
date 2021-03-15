MODULE MATH
IMPLICIT NONE
INTEGER, PARAMETER :: DP = KIND(0.0D0)
CONTAINS


 subroutine mat_print(a)
    class    (*), intent(in) :: a(:,:)
    integer                  :: i
    print*,' '
    do i=1,size(a,1)
      select type (a)
        type is (integer) ; print'(100i8  )',a(i,:)
        type is (real) ; print'(100f12.8)',a(i,:)
        type is (real(dp)) ; print'(100f22.16)',a(i,:)
      end select
    end do
    print*,' '
  end subroutine

 subroutine lat_print(a)
    class    (*), intent(in) :: a(:,:)
    integer                  :: i
    print*,' '
    do i=1,size(a,1)
      select type (a)
        type is (integer) ; print'(100i8  )',a(:,i)
        type is (real) ; print'(100f12.8)',a(:,i)
        type is (real(dp)) ; print'(100f22.16)',a(:,i)
      end select
    end do
    print*,' '
  end subroutine



subroutine vec_print(a)
 class    (*),dimension(:), intent(in) :: a
 integer                  :: i,n
 character(len=10) :: forma
 integer,dimension(:),allocatable :: xi
 real,dimension(:),allocatable :: x
 n=size(a,1)
 select type (a)
   type is (integer)
     if (maxval(a)<1000)then
        forma='(i3)'
     else if(maxval(a)<1000000)then
        forma='(i6)'
     else
        forma='(i9)'
     end if
     allocate(xi(n))
     xi=a
   type is (real)
     if(maxval(a)<1.0)then
        forma='(f11.8)'
     else
        forma='(f0.8)'
     end if
     allocate(x(n))
     x=a
   type is (real(dp))
     if(maxval(a)<1.0_dp)then
        forma='(f20.16)'
     else
        forma='(f0.16)'
     end if
     allocate(x(n))
     x=a
 end select

 write(*,'(A2)',advance='no') '( '
 do i=1,n
   if(allocated(x))then
     write(*,trim(forma),advance='no') x(i)
   else
     write(*,trim(forma),advance='no') xi(i)
   end if
   if(i<n)write(*,'(A2)',advance='no') '; '
 end do
 write(*,'(A2)') ' )'
 print*,' '
end subroutine vec_print




function dtranspose(A)
 real(dp),dimension(:,:), intent(in) :: A
 real(dp),dimension(size(A,2),size(A,1)) :: dtranspose
 integer :: i,j

 do i=1,size(A,1)
   do j=1,size(A,2)
     dtranspose(j,i)=A(i,j)
   end do
 end do

end function dtranspose


SUBROUTINE LR_ZERLEGUNG(A,X,PIVOT)
  REAL(KIND=DP), DIMENSION(:,:), INTENT(IN) :: A
  REAL(KIND=DP), DIMENSION(:,:), ALLOCATABLE :: X,L
  REAL(KIND=DP), DIMENSION(:), ALLOCATABLE :: WORK
  INTEGER, DIMENSION(:), ALLOCATABLE :: PIVOT
  INTEGER :: I,J,K,N,PIV,LI

  N=SIZE(A,1)
  IF(N/=SIZE(A,2)) THEN
          WRITE(*,*) 'ERROR: MATRIX A IS NOT SYMETRIC NXN!'
          RETURN
  END IF
  ALLOCATE(X(N,N),L(N,N),PIVOT(N),WORK(N))
  X=A
  FORALL(I=1:N)PIVOT(I)=I

  DO J=1,N-1
    PIV=J
    DO I=J+1,N
       IF(X(I,J)>X(PIV,J))PIV=I
    END DO
    IF(J/=PIV)THEN
      WORK(:)=X(PIV,:)
      X(PIV,:)=X(J,:)
      X(J,:)=WORK(:)
      LI=PIVOT(J)
      PIVOT(J)=PIVOT(PIV)
      PIVOT(PIV)=LI
      WORK(:)=L(PIV,:)
      L(PIV,:)=L(J,:)
      L(J,:)=WORK(:)
    END IF
    DO I=J+1,N
      L(I,J)=X(I,J)/X(J,J)
      DO K=J,N
        X(I,K)=X(I,K)-L(I,J)*X(J,K)
      END DO
    END DO
  END DO

  DO I=2,N
   DO J=1,I-1
     X(I,J)=L(I,J)
   END DO
  END DO

END SUBROUTINE LR_ZERLEGUNG


SUBROUTINE SOLVE_ES(A,B,X)
   REAL(KIND=DP), DIMENSION(:,:), INTENT(IN) :: A
   REAL(KIND=DP), DIMENSION(:), INTENT(IN) :: B
   REAL(KIND=DP), DIMENSION(:,:), ALLOCATABLE :: L,R
   REAL(KIND=DP), DIMENSION(:), ALLOCATABLE :: BN,X,Y
   INTEGER, DIMENSION(:), ALLOCATABLE :: PIVOT
   INTEGER :: I,J,N

   N=SIZE(A,1)

   CALL LR_ZERLEGUNG(A,R,PIVOT)
   ALLOCATE(X(N),Y(N),L(N,N),BN(N))

   FORALL(I=1:N) L(I,I)=1.0D0
   DO I=2,N
     DO J=1,I-1
        L(I,J)=R(I,J)
        R(I,J)=0.0D0
     END DO
   END DO
   FORALL(I=1:N) Y(I)=B(PIVOT(I))
   BN=Y
   DO I=2,N
     Y(I)=BN(I)-DOT_PRODUCT(Y(1:I-1),L(I,1:I-1))
   END DO

   X(N)=Y(N)/R(N,N)
   DO I=N-1,1,-1
   X(I)=(Y(I)-DOT_PRODUCT(X(I+1:N),R(I,I+1:N)))/R(I,I)
   END DO

   DEALLOCATE(Y,L,BN)

END SUBROUTINE SOLVE_ES



SUBROUTINE INVERT_MATRIX(A)
   real(kind=dp), dimension(:,:), intent(inout) :: A
   real(kind=dp), dimension(:,:), allocatable :: L,R,Ai
   real(kind=dp), dimension(:), allocatable :: bn,x,y
   integer, dimension(:), allocatable :: pivot
   integer :: i,j,n

   n=size(A,1)
   call lr_zerlegung(A,R,pivot)
   allocate(x(n),y(n),L(n,n),Ai(n,n),bn(n))

   forall(i=1:n) L(i,i)=1.0d0
   do i=2,n
     do j=1,i-1
        L(i,j)=R(i,j)
        R(i,j)=0.0d0
     end do
   end do
  do j=1,n
   y=0.0d0
   y(pivot(j))=1.0d0
   bn=y
   do i=2,n
     y(i)=bn(i)-dot_product(y(1:i-1),L(i,1:i-1))
   end do

   x(n)=y(n)/R(n,n)
   do i=n-1,1,-1
   x(i)=(y(i)-dot_product(x(i+1:n),R(i,i+1:n)))/R(i,i)
   end do
   Ai(:,j)=x(:)
 end do
 A=Ai
   deallocate(y,L,bn,Ai) 

END SUBROUTINE INVERT_MATRIX



SUBROUTINE GAUS_INTERPOL(XF,A)
  REAL(KIND=DP), DIMENSION(:,:), INTENT(IN) :: XF
  REAL(KIND=DP), DIMENSION(:), ALLOCATABLE :: A,F
  REAL(KIND=DP), DIMENSION(:,:), ALLOCATABLE :: X
  INTEGER :: I,J,N
  N=SIZE(XF,1)
  ALLOCATE(X(N,N),F(N))
  DO I=1,N
    DO J=1,N
      X(I,J)=XF(I,1)**(J-1)
    END DO
    F(I)=XF(I,2)
  END DO
  CALL SOLVE_ES(X,F,A)

END SUBROUTINE GAUS_INTERPOL

FUNCTION POLYNOM(A,X)
  REAL(KIND=DP),DIMENSION(:),INTENT(IN) :: A
  REAL(KIND=DP) :: X,F
  INTEGER :: I
  REAL(KIND=DP) :: POLYNOM

  F=0.0D0
  DO I=1,SIZE(A)
    F=F+A(I)*X**(I-1)
  END DO
  POLYNOM=F
END FUNCTION POLYNOM

FUNCTION POLYNOM_DISTANCE(A,X1,X2,N)
  REAL(DP),DIMENSION(:),INTENT(IN) :: A
  REAL(DP) :: X1,X2,X,DX,F1,F2,DIST
  INTEGER :: N,I
  REAL(DP) :: POLYNOM_DISTANCE

  DIST=0.0_DP
  X=X1
  DX=(X2-X1)/(N*1.0_DP)
  F1=POLYNOM(A,X)
  DO I=1,N
    X=X+DX
    F2=POLYNOM(A,X)
    DIST=DIST+SQRT(DX**2+(F2-F1)**2)
    F1=F2
  END DO
  POLYNOM_DISTANCE=DIST
END FUNCTION POLYNOM_DISTANCE


FUNCTION REGULAR_FALSI(A,X1,X2,E)
  REAL(KIND=DP),DIMENSION(:), INTENT(IN) :: A
  REAL(KIND=DP) :: X1,X2,F1,F2,E,Z,FZ
  REAL(KIND=DP) :: REGULAR_FALSI

  F1=0.0_DP
  F2=F1
  F1=POLYNOM(A,X1)
  F2=POLYNOM(A,X2)
  DO
    Z=X1-F1*((X2-X1)/(F2-F1))
    FZ=POLYNOM(A,Z)
    IF ( FZ*F2 < 0.0_DP )THEN
       X1=X2
       F1=F2
    ELSE
       F1=F1*F2/(F2+FZ)
    END IF
    X2=Z
    F2=FZ
    IF (ABS(X2-X1)<E)THEN !.OR.ABS(FZ)<E)THEN
          EXIT
    END IF
  END DO

  REGULAR_FALSI = (X1+X2)/2.0_DP

END FUNCTION REGULAR_FALSI


END MODULE
