declare i32 @printf(ptr noundef, ...)
declare i32 @__isoc99_scanf(ptr noundef, ...)
@read_int = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@write_int = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@read_float = private unnamed_addr constant [3 x i8] c"%f\00", align 1
@write_float = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1


define i32 @fat(i32 %x) {
  %1 = icmp sle i32 %x, 0
  br i1 %1, label %retFim, label %retRec
retFim:
  ret i32 1
retRec:
  %2 = sub i32 %x, 1
  %3 = call i32 @fat(i32 %2)
  %4 = mul i32 %x, %3
  ret i32 %4
}

define i32 @main() {
    %1 = alloca i32
    %2 = call i32 (ptr, ...) @__isoc99_scanf(ptr @read_int, ptr %1)
    %3 = load i32, ptr %1
    %4 = call i32 @fat(i32 %3)
    %5 = call i32 (ptr, ...) @printf(ptr @write_int, i32 %4)
    ret i32 0
}
