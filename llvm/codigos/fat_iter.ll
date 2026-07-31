declare i32 @printf(ptr noundef, ...)
declare i32 @__isoc99_scanf(ptr noundef, ...)
@read_int = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@write_int = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

define i32 @fat(i32 %x) {
    %i.0 = add i32 1, 0
    %fat.0 = add i32 1, 0
    br label %while_header
while_header:
    %i.1 = phi i32 [%i.0, %0], [%i.2, %while_body]
    %fat.1 = phi i32 [%fat.0, %0], [%fat.2, %while_body]
    %1 = icmp sle i32 %i.1, %x
    br i1 %1, label %while_body, label %while_exit
while_body:
    %fat.2 = mul i32 %fat.1, %i.1
    %i.2 = add i32 %i.1, 1
    br label %while_header
while_exit:
  ret i32 %fat.1
}

define i32 @main() {
    %1 = alloca i32
    %2 = call i32 (ptr, ...) @__isoc99_scanf(ptr @read_int, ptr %1)
    %3 = load i32, ptr %1
    %4 = call i32 @fat(i32 %3)
    %5 = call i32 (ptr, ...) @printf(ptr noundef @write_int, i32 %4)
    ret i32 0
}
