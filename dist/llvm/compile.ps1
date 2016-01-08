

$LLVM_ROOT = "C:\Tools\LLVM-3.5"
#$LLVM_ROOT = "C:\Tools\LLVM-3.7"

$GHDL_ROOT = "../.."
$GHDL_SRC = "$GHDL_ROOT/src"

$PATH = $env:Path

# promote llvm's binary folder to the path
$env:Path = $PATH + ";$LLVM_ROOT\bin"

# GCC programs
$GCC_GCC =			"gcc.exe"

# GNAT programs
$GNAT_MAKE =		"gnatmake.exe"
$GNAT_BINDER =	"gnatbind.exe"
$GNAT_LINKER =	"gnatlink.exe"

# LLVM programs
$LLVM_CLANG =		"$LLVM_ROOT\bin\clang.exe"
$LLVM_CLANGPP =	"$LLVM_ROOT\bin\clang++.exe"
$LLVM_CONFIG =	"$LLVM_ROOT\bin\llvm-config.exe"

Write-Host "Compiling GHDL with LLVM backend on Windows..." -ForegroundColor Cyan
Write-Host "Settings:"
Write-Host "  LLVM = $LLVM_ROOT"
Write-Host ""
Write-Host "Tests:"

Write-Host "  LLVM version = 3.5?  " -NoNewline
if ($true)
{	Write-Host "[-----]" -ForegroundColor Gray	}
else
{	Write-Host "[NOT FOUND]" -ForegroundColor Red
	exit 1
}

Write-Host "  llvm-config.exe      " -NoNewline
if (Test-Path $LLVM_CONFIG)
{	Write-Host "[FOUND]" -ForegroundColor Green	}
else
{	Write-Host "[NOT FOUND]" -ForegroundColor Red
	exit 1
}

Write-Host ""
Write-Host "Clean up..."
Remove-Item *.ali
Remove-Item *.o
Write-Host ""

# ==============================================================================
Write-Host "Compiling C++ source files..." -ForegroundColor Cyan
# disabled --includedir and --cflags
Write-Host "  Reading: '$LLVM_CONFIG --cxxflags'" -ForegroundColor Gray
$LLVM_CONFIG_RESULT = & $LLVM_CONFIG --cxxflags

Write-Host "  Command: '$LLVM_CLANGPP -c $LLVM_CONFIG_RESULT -o llvm-cbindings.o $GHDL_SRC\ortho\llvm\llvm-cbindings.cpp'" -ForegroundColor Gray
& $LLVM_CLANGPP -c $LLVM_CONFIG_RESULT -o llvm-cbindings.o $GHDL_SRC\ortho\llvm\llvm-cbindings.cpp

# ==============================================================================
Write-Host "Compiling source files..." -ForegroundColor Cyan
$COMPILE_OPTIONS = ("-c", "-gnaty3befhkmr", "-gnatwae", "-gnatf", "-gnat05", "-g", "-gnata")
$COMPILE_INC_PATHS = (
	"-I$GHDL_ROOT/",
	"-I$GHDL_SRC/ortho/llvm",
	"-I$GHDL_SRC/ortho",
	"-I$GHDL_SRC",
	"-I$GHDL_SRC/vhdl",
	"-I$GHDL_SRC/psl",
	"-I$GHDL_SRC/vhdl/translate",
	"-I$GHDL_SRC/ghdldrv",
	"-I$GHDL_SRC/grt",
	"-I$GHDL_SRC/ortho",
	"-I$GHDL_SRC/ortho/llvm"
)

$COMPILE_FILES = (
	"ortho/llvm/ortho_code_main.adb",
	"ortho/llvm/llvm.ads",
	"ortho/llvm/llvm-analysis.ads",
	"ortho/llvm/llvm-bitwriter.ads",
	"ortho/llvm/llvm-core.ads",
	"ortho/llvm/llvm-executionengine.ads",
	"ortho/llvm/llvm-target.ads",
	"ortho/llvm/llvm-targetmachine.ads",
	"ortho/llvm/llvm-transforms.ads",
	"ortho/llvm/llvm-transforms-scalar.ads",
	"vhdl/translate/ortho_front.adb",
	"ortho/llvm/ortho_llvm.adb",
	"vhdl/back_end.adb",
	"bug.adb",
	"vhdl/canon.adb",
	"vhdl/disp_vhdl.adb",
	"vhdl/errorout.adb",
	"flags.adb",
	"vhdl/iirs.adb",
	"libraries.adb",
	"name_table.adb",
	"options.adb",
	"vhdl/sem.adb",
	"vhdl/std_package.adb",
	"vhdl/translate/trans_be.adb",
	"vhdl/translate/translation.adb",
	"types.ads",
	"ortho/llvm/ortho_ident.adb",
	"vhdl/iirs_utils.adb",
	"version.ads",
	"vhdl/iir_chains.adb",
	"psl/psl.ads",
	"psl/psl-build.adb",
	"psl/psl-nodes.adb",
	"psl/psl-rewrites.adb",
	"psl/psl-nfas.adb",
	"psl/psl-prints.adb",
	"std_names.adb",
	"str_table.adb",
	"vhdl/tokens.adb",
	"files_map.adb",
	"vhdl/scanner.adb",
	"lists.adb",
	"vhdl/nodes.adb",
	"vhdl/nodes_meta.adb",
	"vhdl/parse.adb",
	"tables.adb",
	"vhdl/disp_tree.adb",
	"psl/psl-dump_tree.adb",
	"vhdl/ieee.ads",
	"vhdl/ieee-std_logic_1164.adb",
	"vhdl/sem_assocs.adb",
	"vhdl/sem_decls.adb",
	"vhdl/sem_expr.adb",
	"vhdl/sem_inst.adb",
	"vhdl/sem_names.adb",
	"vhdl/sem_scopes.adb",
	"vhdl/sem_specs.adb",
	"vhdl/sem_stmts.adb",
	"vhdl/xrefs.adb",
	"vhdl/post_sems.adb",
	"ortho/llvm/ortho_nodes.ads",
	"vhdl/translate/trans.adb",
	"vhdl/translate/trans-chap1.adb",
	"vhdl/translate/trans-chap12.adb",
	"vhdl/translate/trans-chap2.adb",
	"vhdl/translate/trans-chap4.adb",
	"vhdl/translate/trans-chap7.adb",
	"vhdl/translate/trans-helpers2.adb",
	"vhdl/translate/trans-rtis.adb",
	"vhdl/translate/trans_decls.ads",
	"vhdl/iir_chain_handling.adb",
	"psl/psl-cse.adb",
	"psl/psl-disp_nfas.adb",
	"vhdl/psl-errors.ads",
	"psl/psl-nfas-utils.adb",
	"psl/psl-optimize.adb",
	"psl/psl-qm.adb",
	"psl/psl-hash.adb",
	"psl/psl-nodes_meta.adb",
	"psl/psl-priorities.ads",
	"vhdl/parse_psl.adb",
	"vhdl/evaluation.adb",
	"vhdl/sem_types.adb",
	"vhdl/sem_psl.adb",
	"vhdl/ieee-vital_timing.adb",
	"vhdl/translate/trans-chap3.adb",
	"vhdl/translate/trans-chap5.adb",
	"vhdl/translate/trans-chap6.adb",
	"vhdl/translate/trans-chap9.adb",
	"vhdl/configuration.adb",
	"vhdl/translate/trans-chap8.adb",
	"vhdl/translate/trans-chap14.adb",
	"vhdl/translate/trans-foreach_non_composite.adb",
	"psl/psl-subsets.adb",
	"vhdl/canon_psl.adb",
	"vhdl/translate/trans_analyzes.adb",
	"vhdl/iirs_walk.adb"
)

Write-Host "  Command: '$GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS -I- <File>'" -ForegroundColor Cyan
foreach ($File in $COMPILE_FILES)
{	Write-Host "  $GHDL_SRC/$File" -ForegroundColor Gray
	& $GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS -I- $GHDL_SRC/$File
}

# ==============================================================================
Write-Host "Binding source files..." -ForegroundColor Cyan
$BIND_OPTIONS = ("-aO.", "-E", "-x")
$BIND_INC_PATHS = (
	"-aI$GHDL_SRC",
	"-aI$GHDL_SRC/vhdl",
	"-aI$GHDL_SRC/psl",
	"-aI$GHDL_SRC/vhdl/translate",
	"-aI$GHDL_SRC/ghdldrv",
	"-aI$GHDL_SRC/grt",
	"-aI$GHDL_SRC/ortho",
	"-aI$GHDL_SRC/ortho/llvm"
)

Write-Host "  Command: '$GNAT_BINDER $BIND_INC_PATHS $BIND_OPTIONS ortho_code_main.ali'" -ForegroundColor Gray
& $GNAT_BINDER $BIND_INC_PATHS $BIND_OPTIONS ortho_code_main.ali

# ==============================================================================
Write-Host "Linking object files..." -ForegroundColor Cyan
$LINKER_LIBS = (
	"-lLLVMLTO",
	"-lLLVMObjCARCOpts",
	"-lLLVMLinker",
	"-lLLVMipo",
	"-lLLVMVectorize",
	"-lLLVMBitWriter",
	"-lLLVMIRReader",
	"-lLLVMAsmParser",
	"-lLLVMR600CodeGen",
	"-lLLVMR600Desc",
	"-lLLVMR600Info",
	"-lLLVMR600AsmPrinter",
	"-lLLVMSystemZDisassembler",
	"-lLLVMSystemZCodeGen",
	"-lLLVMSystemZAsmParser",
	"-lLLVMSystemZDesc",
	"-lLLVMSystemZInfo",
	"-lLLVMSystemZAsmPrinter",
	"-lLLVMHexagonCodeGen",
	"-lLLVMHexagonAsmPrinter",
	"-lLLVMHexagonDesc",
	"-lLLVMHexagonInfo",
	"-lLLVMNVPTXCodeGen",
	"-lLLVMNVPTXDesc",
	"-lLLVMNVPTXInfo",
	"-lLLVMNVPTXAsmPrinter",
	"-lLLVMCppBackendCodeGen",
	"-lLLVMCppBackendInfo",
	"-lLLVMMSP430CodeGen",
	"-lLLVMMSP430Desc",
	"-lLLVMMSP430Info",
	"-lLLVMMSP430AsmPrinter",
	"-lLLVMXCoreDisassembler",
	"-lLLVMXCoreCodeGen",
	"-lLLVMXCoreDesc",
	"-lLLVMXCoreInfo",
	"-lLLVMXCoreAsmPrinter",
	"-lLLVMMipsDisassembler",
	"-lLLVMMipsCodeGen",
	"-lLLVMMipsAsmParser",
	"-lLLVMMipsDesc",
	"-lLLVMMipsInfo",
	"-lLLVMMipsAsmPrinter",
	"-lLLVMAArch64Disassembler",
	"-lLLVMAArch64CodeGen",
	"-lLLVMAArch64AsmParser",
	"-lLLVMAArch64Desc",
	"-lLLVMAArch64Info",
	"-lLLVMAArch64AsmPrinter",
	"-lLLVMAArch64Utils",
	"-lLLVMARMDisassembler",
	"-lLLVMARMCodeGen",
	"-lLLVMARMAsmParser",
	"-lLLVMARMDesc",
	"-lLLVMARMInfo",
	"-lLLVMARMAsmPrinter",
	"-lLLVMPowerPCDisassembler",
	"-lLLVMPowerPCCodeGen",
	"-lLLVMPowerPCAsmParser",
	"-lLLVMPowerPCDesc",
	"-lLLVMPowerPCInfo",
	"-lLLVMPowerPCAsmPrinter",
	"-lLLVMSparcDisassembler",
	"-lLLVMSparcCodeGen",
	"-lLLVMSparcAsmParser",
	"-lLLVMSparcDesc",
	"-lLLVMSparcInfo",
	"-lLLVMSparcAsmPrinter",
	"-lLLVMTableGen",
	"-lLLVMDebugInfo",
	"-lLLVMOption",
	"-lLLVMX86Disassembler",
	"-lLLVMX86AsmParser",
	"-lLLVMX86CodeGen",
	"-lLLVMSelectionDAG",
	"-lLLVMAsmPrinter",
	"-lLLVMX86Desc",
	"-lLLVMX86Info",
	"-lLLVMX86AsmPrinter",
	"-lLLVMX86Utils",
	"-lLLVMJIT",
	"-lLLVMLineEditor",
	"-lLLVMMCAnalysis",
	"-lLLVMMCDisassembler",
	"-lLLVMInstrumentation",
	"-lLLVMInterpreter",
	"-lLLVMCodeGen",
	"-lLLVMScalarOpts",
	"-lLLVMInstCombine",
	"-lLLVMTransformUtils",
	"-lLLVMipa",
	"-lLLVMAnalysis",
	"-lLLVMProfileData",
	"-lLLVMMCJIT",
	"-lLLVMTarget",
	"-lLLVMRuntimeDyld",
	"-lLLVMObject",
	"-lLLVMMCParser",
	"-lLLVMBitReader",
	"-lLLVMExecutionEngine",
	"-lLLVMMC",
	"-lLLVMCore",
	"-lLLVMSupport",
	"-lz",
	"-lpthread",
	"-lffi",
	"-ledit",
	"-ltinfo",
	"-ldl",
	"-lm"
)

Write-Host "  Command: '$GNAT_LINKER ortho_code_main.ali -o ghdl1-llvm -g llvm-cbindings.o --LINK=clang++ -L$LLVM_ROOT/lib $LINKER_LIBS'" -ForegroundColor Gray
& $GNAT_LINKER ortho_code_main.ali -o ghdl1-llvm -g llvm-cbindings.o --LINK=clang++ -L$LLVM_ROOT/lib $LINKER_LIBS


# ==============================================================================
Write-Host "Compiling source files..." -ForegroundColor Cyan
$COMPILE_OPTIONS = ("-c", "-gnaty3befhkmr", "-gnatwae", "-gnatf", "-gnat05", "-g", "-gnata")
$COMPILE_INC_PATHS = (
	"-I$GHDL_ROOT/",
	"-I$GHDL_SRC",
	"-I$GHDL_SRC/vhdl",
	"-I$GHDL_SRC/psl",
	"-I$GHDL_SRC/vhdl/translate",
	"-I$GHDL_SRC/ghdldrv",
	"-I$GHDL_SRC/grt",
	"-I$GHDL_SRC/ortho",
	"-I$GHDL_SRC/ortho/llvm"
)

$COMPILE_FILES = (
	"$GHDL_ROOT/dist/llvm/windows/windows_default_path.ads",
	"$GHDL_ROOT/dist/llvm/windows/default_pathes.ads",
	"$GHDL_SRC/ghdldrv/ghdl_llvm.adb",
	"$GHDL_SRC/ghdldrv/ghdl_llvm.adb",
	"$GHDL_SRC/ghdldrv/ghdldrv.adb",
	"$GHDL_SRC/ghdldrv/ghdllocal.adb",
	"$GHDL_SRC/ghdldrv/ghdlmain.adb",
	"$GHDL_SRC/ghdldrv/ghdlprint.adb"
)

Write-Host "  Command: '$GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS -I- <File>'" -ForegroundColor Cyan
foreach ($File in $COMPILE_FILES)
{	Write-Host "  $File" -ForegroundColor Yellow
	& $GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS -I- $File
}


# ==============================================================================
Write-Host "Binding source files..." -ForegroundColor Cyan
Write-Host "  Command: '$GNAT_BINDER $BIND_INC_PATHS $BIND_OPTIONS ghdl_llvm.ali'" -ForegroundColor Gray
& $GNAT_BINDER $BIND_INC_PATHS $BIND_OPTIONS ghdl_llvm.ali

# ==============================================================================
Write-Host "Linking object files..." -ForegroundColor Cyan
Write-Host "  Command: '$GNAT_LINKER ghdl_llvm.ali -g'" -ForegroundColor Gray
& $GNAT_LINKER ghdl_llvm.ali -g


# ==============================================================================
Write-Host "Compiling source files..." -ForegroundColor Cyan
Write-Host "  $GHDL_SRC\src\grt\config\jumps.c" -ForegroundColor Yellow
& $GCC_GCC -c -g -o jump.o "$GHDL_SRC\grt\config\jumps.c"
Write-Host "  $GHDL_SRC\grt\config\times.c" -ForegroundColor Yellow
& $GCC_GCC -c -g -o times.o "$GHDL_SRC\grt\config\times.c"
Write-Host "  $GHDL_SRC\grt\grt-cbinding.c" -ForegroundColor Yellow
& $GCC_GCC -c -g -o grt-cbinding.o "$GHDL_SRC\grt\grt-cbinding.c"
Write-Host "  $GHDL_SRC\grt\grt-cvpi.c" -ForegroundColor Yellow
& $GCC_GCC -c -g -o grt-cvpi.o "$GHDL_SRC\grt\grt-cvpi.c"
Write-Host "  src\grt\fst\fstapi.c" -ForegroundColor Yellow
& $GCC_GCC -c -g -o fstapi.o "-I$GHDL_SRC\grt\fst src\grt\fst\fstapi.c"
Write-Host "  $GHDL_SRC\grt\fst\lz4.c" -ForegroundColor Yellow
& $GCC_GCC -c -g -o lz4.o "$GHDL_SRC\grt\fst\lz4.c"
Write-Host "  $GHDL_SRC\grt\fst\fastlz.c" -ForegroundColor Yellow
& $GCC_GCC -c -g -o fastlz.o "$GHDL_SRC\grt\fst\fastlz.c"

# gnatmake -c -aI./src/grt -gnatec./src/grt/grt.adc -gnat05 \
  # ghdl_main  -cargs -g







# ==============================================================================
Write-Host "Compiling source files..." -ForegroundColor Cyan
$COMPILE_OPTIONS = ("-c", "-gnat05", "-g", "-gnatec$GHDL_SRC/grt/grt.adc")
$COMPILE_INC_PATHS = (
	"-I$GHDL_ROOT/",
	"-I$GHDL_SRC/grt"
)

$COMPILE_FILES = (
	"grt/ghdl_main.adb",
	"grt/grt.ads",
	"grt/grt-errors.adb",
	"grt/grt-main.adb",
	"grt/grt-options.adb",
	"grt/grt-rtis_binding.ads",
	"grt/grt-std_logic_1164.adb",
	"grt/grt-types.ads",
	"grt/grt-astdio.adb",
	"grt/grt-backtraces.adb",
	"grt/grt-hooks.adb",
	"grt/grt-stdio.ads",
	"grt/grt-change_generics.adb",
	"grt/grt-disp.adb",
	"grt/grt-disp_signals.adb",
	"grt/grt-files.adb",
	"grt/grt-images.adb",
	"grt/grt-lib.adb",
	"grt/grt-modules.adb",
	"grt/grt-names.adb",
	"grt/grt-processes.adb",
	"grt/grt-shadow_ieee.adb",
	"grt/grt-signals.adb",
	"grt/grt-stats.adb",
	"grt/grt-values.adb",
	"grt/grt-rtis.adb",
	"grt/grt-c.ads"
)

Write-Host "  Command: '$GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS -I- $GHDL_SRC/<File>.adb'" -ForegroundColor Cyan
foreach ($File in $COMPILE_FILES)
{	Write-Host "  $GHDL_SRC/$File" -ForegroundColor Yellow
	& $GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS -I- $GHDL_SRC/$File
}

Write-Host "  $GHDL_ROOT/dist/llvm/windows/grt-backtraces-impl.ads" -ForegroundColor Yellow
& $GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS $GHDL_ROOT/dist/llvm/windows/grt-backtraces-impl.ads

$COMPILE_FILES = (
	"grt/grt-callbacks.adb",
	"grt/grt-avhpi.adb",
	"grt/grt-avhpi_utils.adb",
	"grt/grt-rtis_addr.adb",
	"grt/grt-rtis_utils.adb",
	"grt/grt-vstrings.adb",
	"grt/grt-table.adb",
	"grt/grt-disp_rti.adb",
	"grt/grt-disp_tree.adb",
	"grt/grt-fst.adb",
	"grt/grt-vcd.adb",
	"grt/grt-vcdz.adb",
	"grt/grt-vital_annotate.adb",
	"grt/grt-vpi.adb",
	"grt/grt-waves.adb",
	"grt/grt-threads.ads",
	"grt/grt-stack2.adb",
	"grt/grt-rtis_types.adb",
	"grt/grt-backtraces-jit.adb",
	"grt/grt-fst_api.ads",
	"grt/grt-zlib.ads",
	"grt/grt-sdf.adb",
	"grt/grt-avls.adb",
	"grt/grt-unithread.adb"
)

foreach ($File in $COMPILE_FILES)
{	Write-Host "  $GHDL_SRC/$File" -ForegroundColor Yellow
	& $GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS -I- $GHDL_SRC/$File
}

# ==============================================================================
Write-Host "Binding source files..." -ForegroundColor Cyan
Write-Host "  Command: '$GNAT_BINDER -Lgrt_ -o run-bind.adb -n ghdl_main.ali'" -ForegroundColor Gray
& $GNAT_BINDER -Lgrt_ -o run-bind.adb -n ghdl_main.ali

# ==============================================================================
Write-Host "Compiling source files..." -ForegroundColor Cyan
Write-Host "  $GCC_GCC -c -g -gnatec$GHDL_SRC/grt/grt.adc -gnat05 -o run-bind.o run-bind.adb" -ForegroundColor Gray
& $GCC_GCC -c -g -gnatec$GHDL_SRC/grt/grt.adc -gnat05 -o run-bind.o run-bind.adb
Write-Host "  $GCC_GCC -c -g -gnatec$GHDL_SRC/grt/grt.adc -gnat05 -o main.o $GHDL_SRC/grt/main.adb" -ForegroundColor Gray
& $GCC_GCC -c -g -gnatec$GHDL_SRC/grt/grt.adc -gnat05 -o main.o $GHDL_SRC/grt/main.adb



# restore Path
$env:Path = $PATH

















