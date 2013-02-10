module GMP

export BigInt, BigFloat

import
    Base.*,
    Base.+,
    Base.-,
    Base./,
    Base.<,
    Base.<<,
    Base.>>,
    Base.<=,
    Base.==,
    Base.>,
    Base.>=,
    Base.^,
    Base.binomial,
    Base.ceil,
    Base.cmp,
    Base.convert,
    Base.div,
    Base.factorial,
    Base.floor,
    Base.gcd,
    Base.gcdx,
    Base.isinf,
    Base.isnan,
    Base.ndigits,
    Base.promote_rule,
    Base.rem,
    Base.show,
    Base.showcompact,
    Base.sqrt,
    Base.string,
    Base.trunc

function gmp_free(p::Ptr)
    a = Ptr{Void}[0]
    ccall((:__gmp_get_memory_functions,:libgmp), Void,
        (Ptr{Void},Ptr{Void},Ptr{Ptr{Void}}), C_NULL, C_NULL, a)
    ccall(a[1], Void, (Ptr{Void},Uint), p, 0)
end

function gmp_printf(format::ByteString, p)
    a = Ptr{Uint8}[0]
    ccall((:__gmp_asprintf, :libgmp), Int32,
        (Ptr{Ptr{Uint8}},Ptr{Uint8},Ptr{Void}), a, format, p)
    s = a[1]
    ret = bytestring(s)
    gmp_free(s)
    ret
end

include("bigint.jl")
include("bigfloat.jl")

end # module
