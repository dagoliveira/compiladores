mlir-opt array_add.mlir -finalize-memref-to-llvm -convert-scf-to-cf -convert-cf-to-llvm -convert-arith-to-llvm -convert-index-to-llvm -convert-func-to-llvm -reconcile-unrealized-casts -o array_add_opt.mlir
mlir-opt func_add.mlir -convert-arith-to-llvm -convert-func-to-llvm -reconcile-unrealized-casts -o func_add_opt.mlir

