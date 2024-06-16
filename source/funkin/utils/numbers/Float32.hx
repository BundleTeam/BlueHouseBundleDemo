package funkin.utils.numbers;

/* extremely inaccurate float, dont use for anything needed to be 100% accurate! */
#if cpp
typedef Float32 = cpp.Float32;
#elseif hl
typedef Float32 = hl.F32;
#elseif java
typedef Float32 = Single;
#else
typedef Float32 = Float;
#end
