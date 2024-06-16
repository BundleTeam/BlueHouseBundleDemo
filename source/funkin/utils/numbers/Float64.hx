package funkin.utils.numbers;

/* more accurate than Float32 but for things that need to be as accurate as possible use normal haxe Float class */
#if cpp
typedef Float64 = cpp.Float64;
#elseif hl
typedef Float64 = hl.F64;
#elseif java
typedef Float64 = Single;
#else
typedef Float64 = Float;
#end
