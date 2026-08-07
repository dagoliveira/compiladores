module {
  llvm.func @printf(!llvm.ptr, ...) -> i32
  llvm.mlir.global private constant @fmt_msg_int("%d\0A\00") {addr_space = 0 : i32}
  llvm.mlir.global private constant @fmt_msg_float("%f\0A\00") {addr_space = 0 : i32}
  llvm.func @add_int(%arg0: i32, %arg1: i32) -> i32 {
    %0 = llvm.add %arg0, %arg1 : i32
    llvm.return %0 : i32
  }
  llvm.func @add_float(%arg0: f32, %arg1: f32) -> f32 {
    %0 = llvm.fadd %arg0, %arg1 : f32
    llvm.return %0 : f32
  }
  llvm.func @main() -> i32 {
    %0 = llvm.mlir.constant(5 : i32) : i32
    %1 = llvm.mlir.constant(17 : i32) : i32
    %2 = llvm.mlir.constant(5.500000e+00 : f32) : f32
    %3 = llvm.mlir.constant(1.750000e+01 : f32) : f32
    %4 = llvm.call @add_int(%0, %1) : (i32, i32) -> i32
    %5 = llvm.mlir.addressof @fmt_msg_int : !llvm.ptr
    %6 = llvm.call @printf(%5, %4) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr, i32) -> i32
    %7 = llvm.call @add_float(%2, %3) : (f32, f32) -> f32
    %8 = llvm.fpext %7 : f32 to f64
    %9 = llvm.mlir.addressof @fmt_msg_float : !llvm.ptr
    %10 = llvm.call @printf(%9, %8) vararg(!llvm.func<i32 (ptr, ...)>) : (!llvm.ptr, f64) -> i32
    llvm.return %4 : i32
  }
}

