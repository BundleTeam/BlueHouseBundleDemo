package funkin.utils.numbers;

/* Maximum: 9,223,372,036,854,775,807 Minimum: -9,223,372,036,854,775,808 */
#if cpp
typedef Int64 = cpp.Int64; // 32 bit signed int
#else
typedef Int64 = haxe.Int64;
#end
