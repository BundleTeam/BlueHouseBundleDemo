package funkin.utils.numbers;

/* Maximum: 4294967295 Minimum: 0 */
#if cpp
typedef UInt32 = cpp.UInt32; // 32 bit unsigneds int
#else
typedef UInt32 = UInt;
#end
// this shouldnt cause issues because fnf can run on 32bit anyway
