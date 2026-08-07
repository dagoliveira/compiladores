; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

@fmt_int = private constant [4 x i8] c"%d \00"
@fmt_newline = private constant [2 x i8] c"\0A\00"

declare i32 @printf(ptr, ...)

define void @array_add(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, ptr %5, ptr %6, i64 %7, i64 %8, i64 %9, ptr %10, ptr %11, i64 %12, i64 %13, i64 %14) {
  %16 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %10, 0
  %17 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %16, ptr %11, 1
  %18 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %17, i64 %12, 2
  %19 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %18, i64 %13, 3, 0
  %20 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %19, i64 %14, 4, 0
  %21 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %5, 0
  %22 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %21, ptr %6, 1
  %23 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %22, i64 %7, 2
  %24 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %23, i64 %8, 3, 0
  %25 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %24, i64 %9, 4, 0
  %26 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %0, 0
  %27 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %26, ptr %1, 1
  %28 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %27, i64 %2, 2
  %29 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %28, i64 %3, 3, 0
  %30 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %29, i64 %4, 4, 0
  br label %31

31:                                               ; preds = %34, %15
  %32 = phi i64 [ %44, %34 ], [ 0, %15 ]
  %33 = icmp slt i64 %32, 10
  br i1 %33, label %34, label %45

34:                                               ; preds = %31
  %35 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %30, 1
  %36 = getelementptr inbounds nuw i32, ptr %35, i64 %32
  %37 = load i32, ptr %36, align 4
  %38 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %25, 1
  %39 = getelementptr inbounds nuw i32, ptr %38, i64 %32
  %40 = load i32, ptr %39, align 4
  %41 = add i32 %37, %40
  %42 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %20, 1
  %43 = getelementptr inbounds nuw i32, ptr %42, i64 %32
  store i32 %41, ptr %43, align 4
  %44 = add i64 %32, 1
  br label %31

45:                                               ; preds = %31
  ret void
}

define void @array_init(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4) {
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %0, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, ptr %1, 1
  %8 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, i64 %2, 2
  %9 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %8, i64 %3, 3, 0
  %10 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %9, i64 %4, 4, 0
  br label %11

11:                                               ; preds = %14, %5
  %12 = phi i64 [ %18, %14 ], [ 0, %5 ]
  %13 = icmp slt i64 %12, 10
  br i1 %13, label %14, label %19

14:                                               ; preds = %11
  %15 = trunc i64 %12 to i32
  %16 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %10, 1
  %17 = getelementptr inbounds nuw i32, ptr %16, i64 %12
  store i32 %15, ptr %17, align 4
  %18 = add i64 %12, 1
  br label %11

19:                                               ; preds = %11
  ret void
}

define void @array_print(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4) {
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %0, 0
  %7 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, ptr %1, 1
  %8 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %7, i64 %2, 2
  %9 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %8, i64 %3, 3, 0
  %10 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %9, i64 %4, 4, 0
  br label %11

11:                                               ; preds = %14, %5
  %12 = phi i64 [ %19, %14 ], [ 0, %5 ]
  %13 = icmp slt i64 %12, 10
  br i1 %13, label %14, label %20

14:                                               ; preds = %11
  %15 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %10, 1
  %16 = getelementptr inbounds nuw i32, ptr %15, i64 %12
  %17 = load i32, ptr %16, align 4
  %18 = call i32 (ptr, ...) @printf(ptr @fmt_int, i32 %17)
  %19 = add i64 %12, 1
  br label %11

20:                                               ; preds = %11
  %21 = call i32 (ptr, ...) @printf(ptr @fmt_newline)
  ret void
}

define i32 @main() {
  %1 = alloca i32, i64 10, align 4
  %2 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %1, 0
  %3 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %2, ptr %1, 1
  %4 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %3, i64 0, 2
  %5 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %4, i64 10, 3, 0
  %6 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %5, i64 1, 4, 0
  %7 = alloca i32, i64 10, align 4
  %8 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %7, 0
  %9 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %8, ptr %7, 1
  %10 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %9, i64 0, 2
  %11 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %10, i64 10, 3, 0
  %12 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %11, i64 1, 4, 0
  %13 = alloca i32, i64 10, align 4
  %14 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } poison, ptr %13, 0
  %15 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %14, ptr %13, 1
  %16 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %15, i64 0, 2
  %17 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %16, i64 10, 3, 0
  %18 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %17, i64 1, 4, 0
  %19 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 0
  %20 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 1
  %21 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 2
  %22 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 3, 0
  %23 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 4, 0
  call void @array_init(ptr %19, ptr %20, i64 %21, i64 %22, i64 %23)
  %24 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %12, 0
  %25 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %12, 1
  %26 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %12, 2
  %27 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %12, 3, 0
  %28 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %12, 4, 0
  call void @array_init(ptr %24, ptr %25, i64 %26, i64 %27, i64 %28)
  %29 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 0
  %30 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 1
  %31 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 2
  %32 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 3, 0
  %33 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 4, 0
  call void @array_print(ptr %29, ptr %30, i64 %31, i64 %32, i64 %33)
  %34 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 0
  %35 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 1
  %36 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 2
  %37 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 3, 0
  %38 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %6, 4, 0
  %39 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %12, 0
  %40 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %12, 1
  %41 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %12, 2
  %42 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %12, 3, 0
  %43 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %12, 4, 0
  %44 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %18, 0
  %45 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %18, 1
  %46 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %18, 2
  %47 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %18, 3, 0
  %48 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %18, 4, 0
  call void @array_add(ptr %34, ptr %35, i64 %36, i64 %37, i64 %38, ptr %39, ptr %40, i64 %41, i64 %42, i64 %43, ptr %44, ptr %45, i64 %46, i64 %47, i64 %48)
  %49 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %18, 0
  %50 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %18, 1
  %51 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %18, 2
  %52 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %18, 3, 0
  %53 = extractvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %18, 4, 0
  call void @array_print(ptr %49, ptr %50, i64 %51, i64 %52, i64 %53)
  ret i32 0
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
