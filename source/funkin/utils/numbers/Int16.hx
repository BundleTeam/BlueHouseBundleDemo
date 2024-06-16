package funkin.utils.numbers;

/* Maximum: 32767 Minimum: -32768 */
#if cpp
typedef Int16 = cpp.Int16; // 16 bit signed int
#else
typedef Int16 = haxe.Int32;
#end
