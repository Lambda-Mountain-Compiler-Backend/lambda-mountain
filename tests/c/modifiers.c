
typedef int Integer;
typedef Integer(*f1)();
typedef Integer(f2)(Integer x);
extern f1 f3(){}
static f2 f4;
_Thread_local int f5;
_Thread_local int f6;
const int f7;
volatile int f8;
_Atomic int f9;

int f10(int *restrict a1, int ** restrict a2, int * restrict * a3) {};
inline int f11(int *restrict a1, int ** restrict a2, int * restrict * a3) {};
_Noreturn int f12(int *restrict a1, int ** restrict a2, int * restrict * a3);

int main(){
   auto int f13;
   register int f14;
}
