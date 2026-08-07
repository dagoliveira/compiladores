module {
  // Para usar o printf
  llvm.func @printf(!llvm.ptr, ...) -> i32

  // String de formatacao
  llvm.mlir.global private constant @fmt_msg_int("%d\0A\00")
  llvm.mlir.global private constant @fmt_msg_float("%f\0A\00")

  func.func @add_int(%a: i32, %b: i32) -> (i32){
    %r = arith.addi %a, %b : i32
    func.return %r : i32
  }

  func.func @add_float(%a: f32, %b: f32) -> (f32){
    %r = arith.addf %a, %b : f32
    func.return %r : f32
  }

  func.func @main() -> (i32){
    %c0 = arith.constant 5: i32
    %c1 = arith.constant 17: i32
    %c0f = arith.constant 5.5: f32
    %c1f = arith.constant 17.5: f32

    %rint = func.call @add_int(%c0, %c1) : (i32, i32) -> i32

    %fmt_ptr_int = llvm.mlir.addressof @fmt_msg_int : !llvm.ptr
    %pri = llvm.call @printf(%fmt_ptr_int, %rint) 
      vararg(!llvm.func<i32 (!llvm.ptr, ...)>) : (!llvm.ptr, i32) -> i32

    %rfloat = func.call @add_float(%c0f, %c1f) : (f32, f32) -> f32
    %rdouble = arith.extf %rfloat : f32 to f64

    %fmt_ptr_float = llvm.mlir.addressof @fmt_msg_float : !llvm.ptr
    %prf = llvm.call @printf(%fmt_ptr_float, %rdouble) 
      vararg(!llvm.func<i32 (!llvm.ptr, ...)>) : (!llvm.ptr, f64) -> i32
    return %rint : i32
  }
}
