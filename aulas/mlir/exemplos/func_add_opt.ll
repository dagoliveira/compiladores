; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

@fmt_msg_int = private constant [4 x i8] c"%d\0A\00"
@fmt_msg_float = private constant [4 x i8] c"%f\0A\00"

declare i32 @printf(ptr, ...)

define i32 @add_int(i32 %0, i32 %1) {
  %3 = add i32 %0, %1
  ret i32 %3
}

define float @add_float(float %0, float %1) {
  %3 = fadd float %0, %1
  ret float %3
}

define i32 @main() {
  %1 = call i32 @add_int(i32 5, i32 17)
  %2 = call i32 (ptr, ...) @printf(ptr @fmt_msg_int, i32 %1)
  %3 = call float @add_float(float 5.500000e+00, float 1.750000e+01)
  %4 = fpext float %3 to double
  %5 = call i32 (ptr, ...) @printf(ptr @fmt_msg_float, double %4)
  ret i32 %1
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
