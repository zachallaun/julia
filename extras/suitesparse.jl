module SuiteSparse

export ChmCommon,
       CholmodDense,                    # types
       CholmodFactor,
       CholmodSparse,
       CholmodTriplet,
       UmfpackLU,
                                        # methods
       chm_aat,
       chm_analyze,
       chm_check,
       chm_eye,
       chm_factorize,
       chm_ones,
       chm_print,
       chm_speye,
       chm_zeros,
       decrement,
       decrement!,
       increment,
       increment!,
       indtype,
       show_umf_ctrl,
       show_umf_info

#import Base.(*)
import Base.(\)
import Base.Ac_ldiv_B
import Base.At_ldiv_B
#import Base.BlasInt
import Base.SparseMatrixCSC
#import Base.blas_int
#import Base.cholfact
#import Base.cholfact!
#import Base.convert
#import Base.copy
#import Base.ctranspose
import Base.eltype
#import Base.lufact
#import Base.lufact!
import Base.nnz
#import Base.norm
import Base.show
import Base.size
import Base.solve
#import Base.transpose
#import Base.triu

include("suitesparse_h.jl")

type MatrixIllConditionedException <: Exception end
type CholmodException <: Exception end

function decrement!{T<:Integer}(A::AbstractArray{T})
    for i in 1:length(A) A[i] -= one(T) end
    A
end
function decrement{T<:Integer}(A::AbstractArray{T})
    B = similar(A)
    for i in 1:length(B) B[i] = A[i] - one(T) end
    B
end
function increment!{T<:Integer}(A::AbstractArray{T})
    for i in 1:length(A) A[i] += one(T) end
    A
end
function increment{T<:Integer}(A::AbstractArray{T})
    increment!(copy(A))
end

typealias CHMITypes Union(Int32,Int64)       # also ITypes for UMFPACK
typealias CHMVTypes Union(Complex64, Complex128, Float32, Float64)
typealias UMFVTypes Union(Float64,Complex128)
    
## UMFPACK

# the control and info arrays
const umf_ctrl = Array(Float64, UMFPACK_CONTROL)
ccall((:umfpack_dl_defaults, :libumfpack), Void, (Ptr{Float64},), umf_ctrl)
const umf_info = Array(Float64, UMFPACK_INFO)

function show_umf_ctrl(level::Real)
    old_prt::Float64 = umf_ctrl[1]
    umf_ctrl[1] = float64(level)
    ccall((:umfpack_dl_report_control, :libumfpack), Void, (Ptr{Float64},), umf_ctrl)
    umf_ctrl[1] = old_prt
end
show_umf_ctrl() = show_umf_ctrl(2.)

function show_umf_info(level::Real)
    old_prt::Float64 = umf_ctrl[1]
    umf_ctrl[1] = float64(level)
    ccall((:umfpack_dl_report_info, :libumfpack), Void,
          (Ptr{Float64}, Ptr{Float64}), umf_ctrl, umf_info)
    umf_ctrl[1] = old_prt
end
show_umf_info() = show_umf_info(2.)

# Wrapper for memory allocated by umfpack. Carry along the value and index types.
## type UmfpackPtr{Tv<:UMFVTypes,Ti<:CHMITypes}
##     val::Vector{Ptr{Void}} 
## end

type UmfpackLU{Tv<:UMFVTypes,Ti<:CHMITypes} <: Factorization{Tv}
    symbolic::Ptr{Void}
    numeric::Ptr{Void}
    m::Int
    n::Int
    colptr::Vector{Ti}                  # 0-based column pointers
    rowval::Vector{Ti}                  # 0-based row indices
    nzval::Vector{Tv}
end

function lud{Tv<:UMFVTypes,Ti<:CHMITypes}(S::SparseMatrixCSC{Tv,Ti})
    zerobased = S.colptr[1] == 0
    lu = UmfpackLU(C_NULL, C_NULL, S.m, S.n,
                   zerobased ? copy(S.colptr) : decrement(S.colptr),
                   zerobased ? copy(S.rowval) : decrement(S.rowval),
                   copy(S.nzval))
    umfpack_numeric!(lu)
end

function lud!{Tv<:UMFVTypes,Ti<:CHMITypes}(S::SparseMatrixCSC{Tv,Ti})
    zerobased = S.colptr[1] == 0
    UmfpackLU(C_NULL, C_NULL, S.m, S.n,
              zerobased ? S.colptr : decrement!(S.colptr),
              zerobased ? S.rowval : decrement!(S.rowval),
              S.nzval)
end

function show(io::IO, f::UmfpackLU)
    @printf(io, "UMFPACK LU Factorization of a %d-by-%d sparse matrix\n",
            f.m, f.n)
    if f.numeric != C_NULL println(f.numeric) end
end

### Solve with Factorization

(\){T<:UMFVTypes}(fact::UmfpackLU{T}, b::Vector{T}) = umfpack_solve(fact, b)
(\){Ts<:UMFVTypes,Tb<:Number}(fact::UmfpackLU{Ts}, b::Vector{Tb}) = fact\convert(Vector{Ts},b)
  
### Solve directly with matrix

(\)(S::SparseMatrixCSC, b::Vector) = lud(S) \ b
At_ldiv_B{T<:UMFVTypes}(S::SparseMatrixCSC{T}, b::Vector{T}) = umfpack_solve(lud(S), b, UMFPACK_Aat)
function At_ldiv_B{Ts<:UMFVTypes,Tb<:Number}(S::SparseMatrixCSC{Ts}, b::Vector{Tb})
    ## should be more careful here in case Ts<:Real and Tb<:Complex
    At_ldiv_B(S, convert(Vector{Ts}, b))
end
Ac_ldiv_B{T<:UMFVTypes}(S::SparseMatrixCSC{T}, b::Vector{T}) = umfpack_solve(lud(S), b, UMFPACK_At)
function Ac_ldiv_B{Ts<:UMFVTypes,Tb<:Number}(S::SparseMatrixCSC{Ts}, b::Vector{Tb})
    ## should be more careful here in case Ts<:Real and Tb<:Complex
    Ac_ldiv_B(S, convert(Vector{Ts}, b))
end

## Wrappers around UMFPACK routines

for (f_sym_r, f_num_r, f_sym_c, f_num_c, itype) in
    (("umfpack_di_symbolic","umfpack_di_numeric","umfpack_zi_symbolic","umfpack_zi_numeric",:Int32),
     ("umfpack_dl_symbolic","umfpack_dl_numeric","umfpack_zl_symbolic","umfpack_zl_numeric",:Int64))
    @eval begin
        function umfpack_symbolic!{Tv<:Float64,Ti<:$itype}(U::UmfpackLU{Tv,Ti})
            if U.symbolic != C_NULL return U end
            tmp = Array(Ptr{Void},1)
            status = ccall(($f_sym_r, :libumfpack), Ti,
                           (Ti, Ti, Ptr{Ti}, Ptr{Ti}, Ptr{Tv}, Ptr{Void},
                            Ptr{Float64}, Ptr{Float64}),
                           U.m, U.n, U.colptr, U.rowval, U.nzval, tmp,
                           umf_ctrl, umf_info)
            if status != UMFPACK_OK; error("Error code $status from symbolic factorization"); end
            U.symbolic = tmp[1]
            finalizer(U.symbolic,umfpack_free_symbolic)
            U
        end
        
        function umfpack_symbolic!{Tv<:Complex128,Ti<:$itype}(U::UmfpackLU{Tv,Ti})
            if U.symbolic != C_NULL return U end
            tmp = Array(Ptr{Void},1)
            status = ccall(($f_sym_r, :libumfpack), Ti,
                           (Ti, Ti, Ptr{Ti}, Ptr{Ti}, Ptr{Float64}, Ptr{Float64}, Ptr{Void},
                            Ptr{Float64}, Ptr{Float64}),
                           U.m, U.n, U.colptr, U.rowval, real(U.nzval), imag(U.nzval), tmp,
                           umf_ctrl, umf_info)
            if status != UMFPACK_OK; error("Error code $status from symbolic factorization"); end
            U.symbolic = tmp[1]
            finalizer(U.symbolic,umfpack_free_symbolic)
            U
        end
        
        function umfpack_numeric!{Tv<:Float64,Ti<:$itype}(U::UmfpackLU{Tv,Ti})
            if U.numeric != C_NULL return U end
            if U.symbolic == C_NULL umfpack_symbolic!(U) end
            tmp = Array(Ptr{Void}, 1)
            status = ccall(($f_num_r, :libumfpack), Ti,
                           (Ptr{Ti}, Ptr{Ti}, Ptr{Float64}, Ptr{Void}, Ptr{Void}, 
                            Ptr{Float64}, Ptr{Float64}),
                           U.colptr, U.rowval, U.nzval, U.symbolic, tmp,
                           umf_ctrl, umf_info)
            if status > 0; throw(MatrixIllConditionedException); end
            if status != UMFPACK_OK; error("Error code $status from numeric factorization"); end
            U.numeric = tmp[1]
            finalizer(U.numeric,umfpack_free_numeric)
            U
        end
        
        function umfpack_numeric!{Tv<:Complex128,Ti<:$itype}(U::UmfpackLU{Tv,Ti})
            if U.numeric != C_NULL return U end
            if U.symbolic == C_NULL umfpack_symbolic!(U) end
            tmp = Array(Ptr{Void}, 1)
            status = ccall(($f_num_r, :libumfpack), Ti,
                           (Ptr{Ti}, Ptr{Ti}, Ptr{Float64}, Ptr{Float64}, Ptr{Void}, Ptr{Void}, 
                            Ptr{Float64}, Ptr{Float64}),
                           U.colptr, U.rowval, real(U.nzval), imag(U.nzval), U.symbolic, tmp,
                           umf_ctrl, umf_info)
            if status > 0; throw(MatrixIllConditionedException); end
            if status != UMFPACK_OK; error("Error code $status from numeric factorization"); end
            U.numeric = tmp[1]
            finalizer(U.numeric,umfpack_free_numeric)
            U
        end
    end
end

for (f_sol_r, f_sol_c, inttype) in
    (("umfpack_di_solve","umfpack_zi_solve",:Int32),
     ("umfpack_dl_solve","umfpack_zl_solve",:Int64))
    @eval begin
        function umfpack_solve{Tv<:Float64,Ti<:$inttype}(lu::UmfpackLU{Tv,Ti}, b::Vector{Tv}, typ::Integer)
            umfpack_numeric!(lu)
            x = similar(b)
            status = ccall(($f_sol_r, :libumfpack), Ti,
                           (Ti, Ptr{Ti}, Ptr{Ti}, Ptr{Float64}, Ptr{Float64},
                            Ptr{Float64}, Ptr{Void}, Ptr{Float64}, Ptr{Float64}),
                           typ, lu.colptr, lu.rowval, lu.nzval, x, b, lu.numeric, umf_ctrl, umf_info)
            if status != UMFPACK_OK; error("Error code $status in umfpack_solve"); end
            return x
        end
        
        function umfpack_solve{Tv<:Complex128,Ti<:$inttype}(lu::UmfpackLU{Tv,Ti}, b::Vector{Tv}, typ::Integer)
            umfpack_numeric!(lu)
            xr = similar(b, Float64)
            xi = similar(b, Float64)
            status = ccall(($f_sol_c, :libumfpack),
                           Ti,
                           (Ti, Ptr{Ti}, Ptr{Ti}, Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, 
                            Ptr{Float64}, Ptr{Float64}, Ptr{Void}, Ptr{Float64}, Ptr{Float64}),
                           typ, lu.colptr, lu.rowval, real(lu.nzval), imag(lu.nzval), 
                           xr, xi, real(b), imag(b), lu.num, umf_ctrl, umf_info)
            if status != UMFPACK_OK; error("Error code $status from umfpack_solve"); end
            return complex(xr,xi)
        end
    end
end

umfpack_solve(lu::UmfpackLU, b::Vector) = umfpack_solve(lu, b, UMFPACK_A)
 
## The C functions called by these Julia functions do not depend on
## the numeric and index types, even though the umfpack names indicate
## they do.  The umfpack_free_* functions can be called on C_NULL without harm.
function umfpack_free_symbolic(symb::Ptr{Void})
    tmp = [symb]
    ccall((:umfpack_dl_free_symbolic, :libumfpack), Void, (Ptr{Void},), tmp)
end

function umfpack_free_symbolic(lu::UmfpackLU)
    if lu.symbolic == C_NULL return lu end
    umfpack_free_numeric(lu)
    umfpack_free_symbolic(lu.symbolic)
    lu.symbolic = C_NULL
    lu
end

function umfpack_free_numeric(num::Ptr{Void})
    tmp = [num]
    ccall((:umfpack_dl_free_numeric, :libumfpack), Void, (Ptr{Void},), tmp)
end

function umfpack_free_symbolic(lu::UmfpackLU)
    if lu.numeric == C_NULL return lu end
    umfpack_free_numeric(lu.numeric)
    lu.numeric = C_NULL
    lu
end

function umfpack_report_symbolic(symb::Ptr{Void}, level::Real)
    old_prl::Float64 = umf_ctrl[UMFPACK_PRL]
    umf_ctrl[UMFPACK_PRL] = float64(level)
    status = ccall((:umfpack_dl_report_symbolic, :libumfpack), Int,
                   (Ptr{Void}, Ptr{Float64}), symb, umf_ctrl)
    umf_ctrl[UMFPACK_PRL] = old_prl
    if status != 0
        error("Error code $status from umfpack_report_symbolic")
    end
end

umfpack_report_symbolic(symb::Ptr{Void}) = umfpack_report_symbolic(symb, 4.)

function umfpack_report_symbolic(lu::UmfpackLU, level::Real)
    umfpack_report_symbolic(umfpack_symbolic!(lu).symbolic, level)
end

umfpack_report_symbolic(lu::UmfpackLU) = umfpack_report_symbolic(lu.symbolic,4.)
function umfpack_report_numeric(num::Ptr{Void}, level::Real)
    old_prl::Float64 = umf_ctrl[UMFPACK_PRL]
    umf_ctrl[UMFPACK_PRL] = float64(level)
    status = ccall((:umfpack_dl_report_numeric, :libumfpack), Int,
                   (Ptr{Void}, Ptr{Float64}), num, umf_ctrl)
    umf_ctrl[UMFPACK_PRL] = old_prl
    if status != 0
        error("Error code $status from umfpack_report_numeric")
    end
end

umfpack_report_numeric(num::Ptr{Void}) = umfpack_report_numeric(num, 4.)
function umfpack_report_numeric(lu::UmfpackLU, level::Real)
    umfpack_report_numeric(umfpack_numeric!(lu).symbolic, level)
end

umfpack_report_numeric(lu::UmfpackLU) = umfpack_report_numeric(lu.symbolic,4.)

## CHOLMOD

const chm_com_sz = ccall((:jl_cholmod_common_size,:libsuitesparse_wrapper),Int,())
const chm_com    = Array(Uint8, chm_com_sz)
ccall((:cholmod_start, :libcholmod), Int32, (Ptr{Uint8},), chm_com)

### A way of examining some of the fields in chm_com
### Probably better to make this a Dict{ASCIIString,Tuple} and
### save the offsets and the lengths and the types.  Then the names can be checked.
type ChmCommon
    dbound::Float64
    maxrank::Int
    supernodal_switch::Float64
    supernodal::Int32
    final_asis::Int32
    final_super::Int32
    final_ll::Int32
    final_pack::Int32
    final_monotonic::Int32
    final_resymbol::Int32
    prefer_zomplex::Int32               # should always be false
    prefer_upper::Int32
    print::Int32                        # print level. Default: 3
    precise::Int32                      # print 16 digits, otherwise 5
    nmethods::Int32                     # number of ordering methods
    selected::Int32
    postorder::Int32
    itype::Int32
    dtype::Int32
end

### These offsets should be reconfigured to be less error-prone in matches
const chm_com_offsets = Array(Int, length(ChmCommon.types))
ccall((:jl_cholmod_common_offsets, :libsuitesparse_wrapper),
      Void, (Ptr{Uint8},), chm_com_offsets)
const chm_prt_inds = (1:4) + chm_com_offsets[13]
const chm_ityp_inds = (1:4) + chm_com_offsets[18] 
                                              
### there must be an easier way but at least this works.
function ChmCommon(aa::Array{Uint8,1})
    typs = ChmCommon.types
    sz = map(sizeof, typs)
    args = map(i->reinterpret(typs[i], aa[chm_com_offsets[i] + (1:sz[i])])[1], 1:length(sz))
    eval(Expr(:call, unshift!(args, :ChmCommon), Any))
end
function chm_itype{Tv<:CHMVTypes,Ti<:CHMITypes}(S::SparseMatrixCSC{Tv,Ti})
    int32(Ti<:Int64 ? CHOLMOD_LONG : CHOLMOD_INT)
end
function chm_xtype{T<:CHMVTypes}(S::SparseMatrixCSC{T})
    int32(T<:Complex ? CHOLMOD_COMPLEX : CHOLMOD_REAL)
end
function chm_dtype{T<:CHMVTypes}(S::SparseMatrixCSC{T})
    int32(T<:Union(Float32, Complex64) ? CHOLMOD_SINGLE : CHOLMOD_DOUBLE)
end

function set_chm_prt_lev(cm::Array{Uint8}, lev::Integer)
    cm[(1:4) + chm_com_offsets[13]] = reinterpret(Uint8, [int32(lev)])
end

## cholmod_dense pointers passed to or returned from C functions are of Julia type
## Ptr{c_CholmodDense}.  The CholmodDense type contains a c_CholmodDense object and other
## fields then ensure the memory pointed to is freed when it should be and not before.
type c_CholmodDense{T<:CHMVTypes}
    m::Int
    n::Int
    nzmax::Int
    lda::Int
    xpt::Ptr{T}
    zpt::Ptr{Void}
    xtype::Int32
    dtype::Int32
end

type CholmodDense{T<:CHMVTypes}
    c::c_CholmodDense
    mat::Matrix{T}
end

function CholmodDense{T<:CHMVTypes}(aa::VecOrMat{T})
    m = size(aa,1); n = size(aa,2)
    CholmodDense(c_CholmodDense{T}(m, n, m*n, stride(aa,2),
                                   convert(Ptr{T}, aa), C_NULL,
                                   T<:Complex ? CHOLMOD_COMPLEX : CHOLMOD_REAL,
                                   T<:Union(Float32,Complex64) ? CHOLMOD_SINGLE : CHOLMOD_DOUBLE),
                 aa)
end

function CholmodDense{T<:CHMVTypes}(c::Ptr{c_CholmodDense{T}})
    cp = unsafe_ref(c)
    if cp.lda != cp.m || cp.nzmax != cp.m * cp.n
        error("overallocated cholmod_sparse returned object of size $(cp.m) by $(cp.n) with leading dim $(cp.lda) and nzmax $(cp.nzmax)")
    end
    ## the true in the call to pointer_to_array means Julia will free the memory
    val = CholmodDense(cp, pointer_to_array(cp.xpt, (cp.m,cp.n), true))
    c_free(c)
    val
end
show(io::IO, cd::CholmodDense) = show(io, cd.mat)

function chm_check{T<:CHMVTypes}(cd::CholmodDense{T})
    status = ccall((:cholmod_check_dense, :libcholmod), Int32,
                   (Ptr{c_CholmodDense{T}}, Ptr{Uint8}), &cd.c, chm_com)
    if status != CHOLMOD_TRUE throw(CholmodException) end
end

function chm_ones{T<:Union(Float64,Complex128)}(m::Integer, n::Integer, t::T)
    CholmodDense(ccall((:cholmod_ones, :libcholmod), Ptr{c_CholmodDense{T}},
                       (Int, Int, Int32, Ptr{Uint8}),
                       m, n,
                       T<:Complex ? CHOLMOD_COMPLEX : CHOLMOD_REAL,
                       chm_com))
end
chm_ones(m::Integer, n::Integer) = chm_ones(m, n, 1.)

function chm_zeros{T<:Union(Float64,Complex128)}(m::Integer, n::Integer, t::T)
    CholmodDense(ccall((:cholmod_zeros, :libcholmod), Ptr{c_CholmodDense{T}},
                       (Int, Int, Int32, Ptr{Uint8}),
                       m, n,
                       T<:Complex ? CHOLMOD_COMPLEX : CHOLMOD_REAL,
                       chm_com))
end
chm_zeros(m::Integer, n::Integer) = chm_zeros(m, n, 1.)

function chm_eye{T<:Union(Float64,Complex128)}(m::Integer, n::Integer, t::T)
    CholmodDense(ccall((:cholmod_eye, :libcholmod), Ptr{c_CholmodDense{T}},
                       (Int, Int, Int32, Ptr{Uint8}),
                       m, n,
                       T<:Complex ? CHOLMOD_COMPLEX : CHOLMOD_REAL,
                       chm_com))
end
chm_eye(m::Integer, n::Integer) = chm_eye(m, n, 1.)
chm_eye(n::Integer) = chm_eye(n, n, 1.)
 
 
function chm_print{T<:CHMVTypes}(cd::CholmodDense{T}, lev::Integer, nm::ASCIIString)
    orig = chm_com[chm_prt_inds]
    chm_com[chm_prt_inds] = reinterpret(Uint8, [int32(lev)])
    status = ccall((:cholmod_print_dense, :libcholmod), Int32,
                   (Ptr{c_CholmodDense{T}}, Ptr{Uint8}, Ptr{Uint8}),
                   &cd.c, nm, chm_com)
    chm_com[chm_prt_inds] = orig
    if status != CHOLMOD_TRUE throw(CholmodException) end
end
chm_print(cd::CholmodDense, lev::Integer) = chm_print(cd, lev, "")
chm_print(cd::CholmodDense) = chm_print(cd, int32(4), "")

type c_CholmodSparse{Tv<:CHMVTypes,Ti<:CHMITypes}
    m::Int
    n::Int
    nzmax::Int
    ppt::Ptr{Ti}
    ipt::Ptr{Ti}
    nzpt::Ptr{Void}
    xpt::Ptr{Tv}
    zpt::Ptr{Void}
    stype::Int32
    itype::Int32
    xtype::Int32
    dtype::Int32
    sorted::Int32
    packed::Int32
end

type CholmodSparse{Tv<:CHMVTypes,Ti<:CHMITypes}
    c::c_CholmodSparse{Tv,Ti}
    colptr0::Vector{Ti}
    rowval0::Vector{Ti}
    nzval::Vector{Tv}
end

function CholmodSparse{Tv<:CHMVTypes,Ti<:CHMITypes}(A::SparseMatrixCSC{Tv,Ti})
    colptr0 = decrement(A.colptr)
    rowval0 = decrement(A.rowval)
    nzval = copy(A.nzval)
    CholmodSparse{Tv,Ti}(c_CholmodSparse{Tv,Ti}(size(A,1),size(A,2),
                                                int(colptr0[end]),
                                                convert(Ptr{Ti}, colptr0),
                                                convert(Ptr{Ti}, rowval0), C_NULL,
                                                convert(Ptr{Tv}, nzval), C_NULL,
                                                int32(0), chm_itype(A),
                                                chm_xtype(A), chm_dtype(A),
### Assuming that a SparseMatrixCSC always has sorted row indices. Need to check.
                                                CHOLMOD_TRUE, CHOLMOD_TRUE),
                         colptr0, rowval0, nzval)
end

function cmn{Ti<:CHMITypes}(i::Ti)
    chm_com[chm_ityp_inds] =
        reinterpret(Uint8, [Ti<:Int64 ? CHOLMOD_LONG : CHOLMOD_INT])
    chm_com
end
cmn{Tv,Ti<:CHMITypes}(A::CholmodSparse{Tv,Ti}) = cmn(one(Ti))
cmn{Tv,Ti<:CHMITypes}(a::c_CholmodSparse{Tv,Ti}) = cmn(one(Ti)) 
cmn{Tv,Ti<:CHMITypes}(ap::Ptr{c_CholmodSparse{Tv,Ti}}) = cmn(one(Ti)) 
 
function CholmodSparse{Tv<:CHMVTypes,Ti<:CHMITypes}(cp::Ptr{c_CholmodSparse{Tv,Ti}})
    csp = unsafe_ref(cp)
    colptr0 = pointer_to_array(csp.ppt, (csp.n + 1,), true)
    nnz = colptr0[end]
    cms = CholmodSparse{Tv,Ti}(csp, colptr0,
                               pointer_to_array(csp.ipt, (nnz,), true),
                               pointer_to_array(csp.xpt, (nnz,), true))
    c_free(cp)
    cms
end

for (chk,prt,itype) in
    ((:cholmod_check_sparse, :cholmod_print_sparse, :Int32),
     (:cholmod_l_check_sparse, :cholmod_l_print_sparse, :Int64))
    @eval begin
        function chm_check{Tv<:CHMVTypes}(cs::CholmodSparse{Tv,$itype})
            status = ccall(($(string(chk)),:libcholmod), Int32,
                           (Ptr{c_CholmodSparse{Tv,$itype}}, Ptr{Uint8}),
                           &cs.c, cmn(cs))
            if status != CHOLMOD_TRUE throw(CholmodException) end
        end
        function chm_print{Tv<:CHMVTypes}(cs::CholmodSparse{Tv,$itype},lev,nm)
            orig = chm_com[chm_prt_inds]
            chm_com[chm_prt_inds] = reinterpret(Uint8, [int32(lev)])
            status = ccall(($(string(prt)),:libcholmod), Int32,
                           (Ptr{c_CholmodSparse{Tv,$itype}}, Ptr{Uint8}, Ptr{Uint8}),
                           &cs.c, nm, cmn(cs))
            chm_com[chm_prt_inds] = orig
            if status != CHOLMOD_TRUE throw(CholmodException) end
        end
    end
end

chm_print(cd::CholmodSparse, lev::Integer) = chm_print(cd, lev, "")
chm_print(cd::CholmodSparse) = chm_print(cd, int32(4), "")

nnz{Tv<:CHMVTypes,Ti<:CHMITypes}(cp::CholmodSparse{Tv,Ti}) = int(cp.colptr0[end])
size{Tv<:CHMVTypes,Ti<:CHMITypes}(cp::CholmodSparse{Tv,Ti}) = (int(cp.c.m), int(cp.c.n))
function size{Tv<:CHMVTypes,Ti<:CHMITypes}(cp::CholmodSparse{Tv,Ti}, d::Integer)
    d == 1 ? cp.c.m : (d == 2 ? cp.c.n : 1)
end

function chm_speye{Tv<:Union(Float64,Complex128),Ti<:Int32}(m::Integer, n::Integer, t::Tv, i::Ti)
    CholmodSparse(ccall((:cholmod_speye, :libcholmod), Ptr{c_CholmodSparse{Tv,Ti}},
                       (Int, Int, Int32, Ptr{Uint8}),
                       m, n,
                       Tv<:Complex ? CHOLMOD_COMPLEX : CHOLMOD_REAL,
                       cmn(one(Ti))))
end
 
function chm_speye{Tv<:Union(Float64,Complex128),Ti<:Int64}(m::Integer, n::Integer, t::Tv, i::Ti)
    CholmodSparse(ccall((:cholmod_l_speye, :libcholmod), Ptr{c_CholmodSparse{Tv,Ti}},
                       (Int, Int, Int32, Ptr{Uint8}),
                       m, n,
                       Tv<:Complex ? CHOLMOD_COMPLEX : CHOLMOD_REAL,
                       cmn(one(Ti))))
end
chm_speye(m::Integer, n::Integer) = chm_speye(m, n, 1., 1)
chm_speye(n::Integer) = chm_speye(n, n, 1., 1)

function chm_aat{Tv<:CHMVTypes,Ti<:Int64}(A::CholmodSparse{Tv,Ti})
    cm = cmn(A)
    aa = Array(Ptr{c_CholmodSparse{Tv,Ti}}, 1)
    aa[1] = ccall((:cholmod_l_aat, :libcholmod), Ptr{c_CholmodSparse{Tv,Ti}},
                  (Ptr{c_CholmodSparse{Tv,Ti}}, Ptr{Void}, Int, Int32, Ptr{Uint8}),
                  &A.c, C_NULL, 0, 1, cm)
    res = CholmodSparse(ccall((:cholmod_l_copy, :libcholmod),
                              Ptr{c_CholmodSparse{Tv,Ti}},
                              (Ptr{c_CholmodSparse{Tv,Ti}}, Int32, Int32, Ptr{Uint8}),
                              aa[1], 1, 1, cm))
    status = ccall((:cholmod_l_free_sparse, :libcholmod), Int32,
                   (Ptr{Ptr{c_CholmodSparse{Tv,Ti}}}, Ptr{Uint8}), aa, cm)
    if status != CHOLMOD_TRUE throw(CholmodException) end
    res
end
chm_aat{Tv<:CHMVTypes,Ti<:Int64}(A::SparseMatrixCSC{Tv,Ti}) = chm_aat(CholmodSparse(A))

type c_CholmodFactor{Tv<:CHMVTypes,Ti<:CHMITypes}
    n::Int
    minor::Int
    Perm::Ptr{Ti}
    ColCount::Ptr{Ti}
    nzmax::Int
    p::Ptr{Ti}
    i::Ptr{Ti}
    x::Ptr{Tv}
    z::Ptr{Void}
    nz::Ptr{Ti}
    next::Ptr{Ti}
    prev::Ptr{Ti}
    nsuper::Int
    ssize::Int
    xsize::Int
    maxcsize::Int
    maxesize::Int
    super::Ptr{Ti}
    pi::Ptr{Ti}
    px::Ptr{Tv}
    s::Ptr{Ti}
    ordering::Int32
    is_ll::Int32
    is_super::Int32
    is_monotonic::Int32
    itype::Int32
    xtype::Int32
    dtype::Int32
end

type CholmodFactor{Tv<:CHMVTypes,Ti<:CHMITypes}
    c::c_CholmodFactor{Tv,Ti}
    Perm::Vector{Ti}
    ColCount::Vector{Ti}
    p::Vector{Ti}
    i::Vector{Ti}
    x::Vector{Tv}
    nz::Vector{Ti}
    next::Vector{Ti}
    prev::Vector{Ti}
    super::Vector{Ti}
    pi::Vector{Ti}
    px::Vector{Tv}
    s::Vector{Ti}
end

cmn{Tv<:CHMVTypes,Ti<:CHMITypes}(L::CholmodFactor{Tv,Ti}) = cmn(one(Ti))
cmn{Tv<:CHMVTypes,Ti<:CHMITypes}(l::c_CholmodFactor{Tv,Ti}) = cmn(one(Ti))
cmn{Tv<:CHMVTypes,Ti<:CHMITypes}(lp::Ptr{c_CholmodFactor{Tv,Ti}}) = cmn(one(Ti))

function CholmodFactor{Tv<:CHMVTypes,Ti<:CHMITypes}(cp::Ptr{c_CholmodFactor{Tv,Ti}})
    cfp = unsafe_ref(cp)
    Perm = pointer_to_array(cfp.Perm, (cfp.n,), true)
    ColCount = pointer_to_array(cfp.ColCount, (cfp.n,), true)
    p = pointer_to_array(cfp.p, (cfp.p == C_NULL ? 0 : cfp.n + 1,), true)
    i = pointer_to_array(cfp.i, (cfp.i == C_NULL ? 0 : cfp.nzmax,), true)
    x = pointer_to_array(cfp.x, (cfp.x == C_NULL ? 0 : cfp.nzmax,), true)
    nz = pointer_to_array(cfp.nz, (cfp.nz == C_NULL ? 0 : cfp.n,), true)
    next = pointer_to_array(cfp.next, (cfp.next == C_NULL ? 0 : cfp.n + 2,), true)
    prev = pointer_to_array(cfp.prev, (cfp.prev == C_NULL ? 0 : cfp.n + 2,), true)
    super = pointer_to_array(cfp.super, (cfp.super == C_NULL ? 0 : cfp.nsuper + 1,), true)
    pi = pointer_to_array(cfp.pi, (cfp.pi == C_NULL ? 0 : cfp.nsuper + 1,), true)
    px = pointer_to_array(cfp.px, (cfp.px == C_NULL ? 0 : cfp.nsuper + 1,), true)
    s = pointer_to_array(cfp.s, (cfp.s == C_NULL ? 0 : cfp.ssize + 1,), true)
    cf = CholmodFactor{Tv,Ti}(cfp, Perm, ColCount, p, i, x, nz, next, prev,
                              super, pi, px, s)
    c_free(cp)
    cf
end

for (anl,fac,slv,spslv,itype) in
    ((:cholmod_analyse,:cholmod_factorize,:cholmod_solve,:cholmod_spsolve,:Int32),
     (:cholmod_l_analyze,:cholmod_l_factorize,:cholmod_l_solve,:cholmod_l_spsolve,:Int64))
    @eval begin
        function chm_analyze{Tv<:CHMVTypes}(a::c_CholmodSparse{Tv,$itype})
            ccall(($(string(anl)),:libcholmod), Ptr{c_CholmodFactor{Tv,$itype}},
                  (Ptr{c_CholmodSparse{Tv,$itype}}, Ptr{Uint8}), &a, cmn(a))
        end
        function chm_factorize{Tv<:CHMVTypes}(a::c_CholmodSparse{Tv,$itype},
                                              l::c_CholmodFactor{Tv,$itype})
            status = ccall(($(string(fac)),:libcholmod), Int32,
                           (Ptr{c_CholmodSparse{Tv,$itype}},
                            Ptr{c_CholmodFactor{Tv,$itype}}, Ptr{Uint8}),
                           &a, &l, cmn(a))
            if status != CHOLMOD_TRUE throw(CholmodException) end
        end
    end
end
chm_analyze(ap::Ptr{c_CholmodSparse}) = chm_analyze(unsafe_ref(ap))
chm_analyze(A::CholmodSparse) = chm_analyze(A.c)
chm_analyze(A::SparseMatrixCSC) = chm_analyze(CholmodSparse(A).c) 

function chm_factorize{Tv<:CHMVTypes,Ti<:CHMITypes}(ap::Ptr{c_CholmodSparse{Tv,Ti}},lp::Ptr{c_CholmodFactor{Tv,Ti}})
    chm_factorize(unsafe_ref{ap}, unsafe_ref{lp})
end
function chm_factorize{Tv<:CHMVTypes,Ti<:CHMITypes}(A::CholmodSparse{Tv,Ti},lp::Ptr{c_CholmodFactor{Tv,Ti}})
    chm_factorize(A.c,unsafe_ref(lp))
end
function chm_factorize{Tv<:CHMVTypes,Ti<:CHMITypes}(A::CholmodSparse{Tv,Ti},L::c_CholmodFactor{Tv,Ti})
    chm_factorize(A.c,unsafe_ref(lp))
end
function chm_factorize(a::c_CholmodSparse)
    lp = chm_analyze(a)
    chm_factorize(a, unsafe_ref(lp))
    CholmodFactor(lp)
end
chm_factorize(A::SparseMatrixCSC) = chm_factorize(CholmodSparse(A).c)
chm_factorize(A::CholmodSparse) = chm_factorize(A.c)

type c_CholmodTriplet{Tv<:CHMVTypes,Ti<:CHMITypes}
    m::Int
    n::Int
    nzmax::Int
    nnz::Int
    i::Ptr{Ti}
    j::Ptr{Ti}
    x::Ptr{Tv}
    z::Ptr{Void}
    stype:Int32
    itype::Int32
    xtype::Int32
    dtype::Int32
end

type CholmodTriplet{Tv<:CHMVTypes,Ti<:CHMITypes}
    c::c_CholmodTriplet{Tv,Ti}
    i::Vector{Ti}
    j::Vector{Ti}
    x::Vector{Tv}
end

if false  
    for (fac,den,sp,trip,itype) in
        ((:cholmod_free_factor,:cholmod_free_sparse,:cholmod_free_triplet,:Int32),
         (:cholmod_l_free_factor,:cholmod_l_free_sparse,:cholmod_l_free_triplet,:Int64))
        @eval begin
            function chm_free{Tv<:CHMVTypes}(l::c_CholmodFactor{Tv,$itype})
                status = ccall(($(string(fac)), :libcholmod), Int32,
                               (Ptr{Ptr{c_CholmodFactor{Tv,$itype}}}, Ptr{Uint8}), [&l], cmn(l))
                if status != CHOLMOD_TRUE throw(CholmodException) end
            end
            function chm_free{Tv<:CHMVTypes}(s::c_CholmodSparse{Tv,$itype})
                status = ccall(($(string(sp)), :libcholmod), Int32,
                               (Ptr{Ptr{c_CholmodSparse{Tv,$itype}}}, Ptr{Uint8}), [&s], cmn(s))
                if status != CHOLMOD_TRUE throw(CholmodException) end
            end
            function chm_free{Tv<:CHMVTypes}(t::c_CholmodTriplet{Tv,$itype})
                status = ccall(($(string(trip)), :libcholmod), Int32,
                               (Ptr{Ptr{c_CholmodTriplet{Tv,$itype}}}, Ptr{Uint8}), [&t], cmn(t))
                if status != CHOLMOD_TRUE throw(CholmodException) end
            end
        end
    end
    chm_free(lp::Ptr{CholmodFactor}) = chm_free(unsafe_ref{lp})
    chm_free(sp::Ptr{CholmodSparse}) = chm_free(unsafe_ref{sp})
    chm_free(tp::Ptr{CholmodTriplet}) = chm_free(unsafe_ref{tp})
end
end #module
