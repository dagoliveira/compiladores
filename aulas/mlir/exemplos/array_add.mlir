module {
  // Para usar o printf
  llvm.func @printf(!llvm.ptr, ...) -> i32

  // String de formatacao
  llvm.mlir.global private constant @fmt_int("%d \00")
  llvm.mlir.global private constant @fmt_newline("\0A\00")

  func.func @array_add(%arg0: memref<10xi32>, %arg1: memref<10xi32>, %arg2: memref<10xi32>) {
    %c0 = arith.constant 0 : index
    %c10 = arith.constant 10 : index
    %c1 = arith.constant 1 : index

    scf.for %arg3 = %c0 to %c10 step %c1 {
      %0 = memref.load %arg0[%arg3] : memref<10xi32>
      %1 = memref.load %arg1[%arg3] : memref<10xi32>
      %2 = arith.addi %0, %1 : i32
      memref.store %2, %arg2[%arg3] : memref<10xi32>
    }

    return
  }

  func.func @array_init(%arg0: memref<10xi32>) {
    %c0 = arith.constant 0 : index
    %c10 = arith.constant 10 : index
    %c1 = arith.constant 1 : index

    scf.for %arg3 = %c0 to %c10 step %c1 {
      %arg3_i32 = index.casts %arg3 : index to i32
      memref.store %arg3_i32, %arg0[%arg3] : memref<10xi32>
    }

    return
  }

  func.func @array_print(%arg0: memref<10xi32>) {
    %c0 = arith.constant 0 : index
    %c10 = arith.constant 10 : index
    %c1 = arith.constant 1 : index

    %fmt_ptr = llvm.mlir.addressof @fmt_int : !llvm.ptr
    scf.for %arg3 = %c0 to %c10 step %c1 {
      %0 = memref.load %arg0[%arg3] : memref<10xi32>
      %pr = llvm.call @printf(%fmt_ptr, %0) 
        vararg(!llvm.func<i32 (!llvm.ptr, ...)>) : (!llvm.ptr, i32) -> i32
    }
    %fmt_nl = llvm.mlir.addressof @fmt_newline : !llvm.ptr
      %pr = llvm.call @printf(%fmt_nl) 
        vararg(!llvm.func<i32 (!llvm.ptr, ...)>) : (!llvm.ptr) -> i32

    return
  }

  func.func @main() -> (i32){
    %c0 = arith.constant 0 : i32

    %A = memref.alloca() : memref<10xi32>
    %B = memref.alloca() : memref<10xi32>
    %C = memref.alloca() : memref<10xi32>

    func.call @array_init(%A) : (memref<10xi32>) -> ()
    func.call @array_init(%B) : (memref<10xi32>) -> ()

    func.call @array_print(%A) : (memref<10xi32>) -> ()

    func.call @array_add(%A, %B, %C) : (memref<10xi32>, memref<10xi32>, memref<10xi32>) -> ()

    func.call @array_print(%C) : (memref<10xi32>) -> ()

    return %c0 : i32
  }
}
