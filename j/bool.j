## boolean conversions ##

convert(::Type{Bool}, x::Number) = (x!=0)

# promote Bool to any other numeric type
promote_rule{T<:Number}(::Type{Bool}, ::Type{T}) = T

bool(x) = true
bool(x::Bool) = x
bool(x::Number) = convert(Bool, x)

sizeof(::Type{Bool}) = 1

## boolean operations ##

!(x::Bool) = eq_int(unbox8(x),trunc8(0))
isequal(x::Bool, y::Bool) = eq_int(unbox8(x),unbox8(y))

(~)(x::Bool) = !x
(&)(x::Bool, y::Bool) = eq_int(and_int(unbox8(x),unbox8(y)),trunc8(1))
(|)(x::Bool, y::Bool) = eq_int( or_int(unbox8(x),unbox8(y)),trunc8(1))
($)(x::Bool, y::Bool) = (x!=y)

any() = false
all() = true
count() = 0

any(x::Bool)  = x
all(x::Bool)  = x
count(x::Bool) = (x ? 1 : 0)

any(x::Bool, y::Bool) = x | y
all(x::Bool, y::Bool) = x & y
count(x::Bool, y::Bool) = count(x) + count(y)

count(x::Integer, y::Bool) = x + count(y)
count(x::Bool, y::Integer) = count(x) + y

## do arithmetic as Int ##

<(x::Bool, y::Bool) = y&!x
==(x::Bool, y::Bool) = eq_int(unbox8(x),unbox8(y))

-(x::Bool) = -int(x)

+(x::Bool, y::Bool) = int(x)+int(y)
-(x::Bool, y::Bool) = int(x)-int(y)
*(x::Bool, y::Bool) = int(x)*int(y)
/(x::Bool, y::Bool) = int(x)/int(y)
^(x::Bool, y::Bool) = int(x)^int(y)

div(x::Bool, y::Bool) = div(int(x),int(y))
fld(x::Bool, y::Bool) = fld(int(x),int(y))
rem(x::Bool, y::Bool) = rem(int(x),int(y))
mod(x::Bool, y::Bool) = mod(int(x),int(y))
