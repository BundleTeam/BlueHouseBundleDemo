package funkin.utils.numbers;

/* Maximum: 2147483647 Minimum: -2147483647 */
// like fast float but with ints
#if cpp
typedef Int32 = cpp.Int32; // 32 bit signed int
#else
typedef Int32 = haxe.Int32;
#end
