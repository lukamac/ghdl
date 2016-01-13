

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
$LLVM_CLANGCL =	"$LLVM_ROOT\bin\clang-cl.exe"
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
Write-Host "  Reading: '$LLVM_CONFIG --cxxflags'" -ForegroundColor Gray
$LLVM_CONFIG_RESULT = & $LLVM_CONFIG --cxxflags

Write-Host "  [WARNING] " -NoNewline -ForegroundColor Yellow
Write-Host "Disabled exception handling: -D_HAS_EXCEPTIONS=0"
Write-Host "    see: http://stackoverflow.com/questions/24197773/c-program-not-compiling-with-clang-and-visual-studio-2010-express"
Write-Host "    see: http://clang.llvm.org/docs/MSVCCompatibility.html"

# $params = @("-c")	#, "-v")
# $params += $LLVM_CONFIG_RESULT.Split(" ")
# $params += "-D_HAS_EXCEPTIONS=0"												# disable exception handling
# $params += "-o"
# $params += "llvm-cbindings2.o"
# $params += "$GHDL_SRC\ortho\llvm\llvm-cbindings.cpp"

# Write-Host "  Command: '$LLVM_CLANGCL $params'" -ForegroundColor Gray
# & $LLVM_CLANGCL $params

$params = "-c -IC:\Tools\LLVM-3.5\include -DWIN32 -D_WINDOWS -W3 -MP -D_CRT_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE -D_CRT_NONSTDC_NO_WARNINGS -D_SCL_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -D_HAS_EXCEPTIONS=0 -o llvm-cbindings.o $GHDL_SRC\ortho\llvm\llvm-cbindings.cpp"
Write-Host "  Command: '$LLVM_CLANGPP $params'" -ForegroundColor Gray
& $LLVM_CLANGPP $params.Split(" ")


# ==============================================================================
Write-Host "Compiling source files..." -ForegroundColor Cyan
Write-Host "  Reading: '$LLVM_CONFIG --libs --system-libs'" -ForegroundColor Gray
$LLVM_CONFIG_RESULT = & $LLVM_CONFIG --libs --system-libs
$LINKER_LIBS = $LLVM_CONFIG_RESULT.Split(" ")

# Windows llvm-config does not report --system-libs
# $LINKER_LIBS += @(
	# "-lz",
	# "-lpthread",
	# "-lffi",
	# "-ledit",
	# "-ltinfo",
	# "-ldl",
	# "-lm"
# )

$COMPILE_SRC_PATHS = (
	"-aI$GHDL_ROOT/",
	"-aI$GHDL_SRC/ortho/llvm",
	"-aI$GHDL_SRC/ortho",
	"-aI$GHDL_SRC",
	"-aI$GHDL_SRC/vhdl",
	"-aI$GHDL_SRC/psl",
	"-aI$GHDL_SRC/vhdl/translate",
	"-aI$GHDL_SRC/ghdldrv",
	"-aI$GHDL_SRC/grt",
	"-aI$GHDL_SRC/ortho",
	"-aI$GHDL_SRC/ortho/llvm"
)

$COMPILE_OPTIONS = @(
	"-v",
	"-o",
	"ghdl1-llvm"
)
$COMPILE_OPTIONS += $COMPILE_SRC_PATHS
$COMPILE_OPTIONS += @(
	"-gnaty3befhkmr",
	"-gnatwae",
	"-aO.",
	"-gnatf",
	"-gnat05",
	"-g",
	"-gnata",
	"ortho_code_main",
	"-bargs",
	"-E",
	"-largs",
	"llvm-cbindings.o",
	"--LINK=clang++"
)
$COMPILE_OPTIONS += $LINKER_LIBS

Write-Host "  Command: '$GNAT_MAKE $COMPILE_OPTIONS'" -ForegroundColor Cyan
& $GNAT_MAKE $COMPILE_OPTIONS



Write-Host "abort by script" -ForegroundColor Red
exit 1

# ==============================================================================
# Write-Host "Compiling source files..." -ForegroundColor Cyan
# $COMPILE_OPTIONS = ("-c", "-gnaty3befhkmr", "-gnatwae", "-gnatf", "-gnat05", "-g", "-gnata")
# $COMPILE_INC_PATHS = (
	# "-I$GHDL_ROOT/",
	# "-I$GHDL_SRC",
	# "-I$GHDL_SRC/vhdl",
	# "-I$GHDL_SRC/psl",
	# "-I$GHDL_SRC/vhdl/translate",
	# "-I$GHDL_SRC/ghdldrv",
	# "-I$GHDL_SRC/grt",
	# "-I$GHDL_SRC/ortho",
	# "-I$GHDL_SRC/ortho/llvm"
# )

# $COMPILE_FILES = (
	# "$GHDL_ROOT/dist/llvm/windows/windows_default_path.ads",
	# "$GHDL_ROOT/dist/llvm/windows/default_pathes.ads",
	# "$GHDL_SRC/ghdldrv/ghdl_llvm.adb",
	# "$GHDL_SRC/ghdldrv/ghdl_llvm.adb",
	# "$GHDL_SRC/ghdldrv/ghdldrv.adb",
	# "$GHDL_SRC/ghdldrv/ghdllocal.adb",
	# "$GHDL_SRC/ghdldrv/ghdlmain.adb",
	# "$GHDL_SRC/ghdldrv/ghdlprint.adb"
# )

# Write-Host "  Command: '$GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS -I- <File>'" -ForegroundColor Cyan
# foreach ($File in $COMPILE_FILES)
# {	Write-Host "  $File" -ForegroundColor Yellow
	# & $GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS -I- $File
# }


# ==============================================================================
# Write-Host "Binding source files..." -ForegroundColor Cyan
# Write-Host "  Command: '$GNAT_BINDER $BIND_INC_PATHS $BIND_OPTIONS ghdl_llvm.ali'" -ForegroundColor Gray
# & $GNAT_BINDER $BIND_INC_PATHS $BIND_OPTIONS ghdl_llvm.ali

# ==============================================================================
# Write-Host "Linking object files..." -ForegroundColor Cyan
# Write-Host "  Command: '$GNAT_LINKER ghdl_llvm.ali -g'" -ForegroundColor Gray
# & $GNAT_LINKER ghdl_llvm.ali -g


# ==============================================================================
# Write-Host "Compiling source files..." -ForegroundColor Cyan
# Write-Host "  $GHDL_SRC\src\grt\config\jumps.c" -ForegroundColor Yellow
# & $GCC_GCC -c -g -o jump.o "$GHDL_SRC\grt\config\jumps.c"
# Write-Host "  $GHDL_SRC\grt\config\times.c" -ForegroundColor Yellow
# & $GCC_GCC -c -g -o times.o "$GHDL_SRC\grt\config\times.c"
# Write-Host "  $GHDL_SRC\grt\grt-cbinding.c" -ForegroundColor Yellow
# & $GCC_GCC -c -g -o grt-cbinding.o "$GHDL_SRC\grt\grt-cbinding.c"
# Write-Host "  $GHDL_SRC\grt\grt-cvpi.c" -ForegroundColor Yellow
# & $GCC_GCC -c -g -o grt-cvpi.o "$GHDL_SRC\grt\grt-cvpi.c"
# Write-Host "  src\grt\fst\fstapi.c" -ForegroundColor Yellow
# & $GCC_GCC -c -g -o fstapi.o "-I$GHDL_SRC\grt\fst src\grt\fst\fstapi.c"
# Write-Host "  $GHDL_SRC\grt\fst\lz4.c" -ForegroundColor Yellow
# & $GCC_GCC -c -g -o lz4.o "$GHDL_SRC\grt\fst\lz4.c"
# Write-Host "  $GHDL_SRC\grt\fst\fastlz.c" -ForegroundColor Yellow
# & $GCC_GCC -c -g -o fastlz.o "$GHDL_SRC\grt\fst\fastlz.c"

# gnatmake -c -aI./src/grt -gnatec./src/grt/grt.adc -gnat05 \
  # ghdl_main  -cargs -g







# ==============================================================================
# Write-Host "Compiling source files..." -ForegroundColor Cyan
# $COMPILE_OPTIONS = ("-c", "-gnat05", "-g", "-gnatec$GHDL_SRC/grt/grt.adc")
# $COMPILE_INC_PATHS = (
	# "-I$GHDL_ROOT/",
	# "-I$GHDL_SRC/grt"
# )

# $COMPILE_FILES = (
	# "grt/ghdl_main.adb",
	# "grt/grt.ads",
	# "grt/grt-errors.adb",
	# "grt/grt-main.adb",
	# "grt/grt-options.adb",
	# "grt/grt-rtis_binding.ads",
	# "grt/grt-std_logic_1164.adb",
	# "grt/grt-types.ads",
	# "grt/grt-astdio.adb",
	# "grt/grt-backtraces.adb",
	# "grt/grt-hooks.adb",
	# "grt/grt-stdio.ads",
	# "grt/grt-change_generics.adb",
	# "grt/grt-disp.adb",
	# "grt/grt-disp_signals.adb",
	# "grt/grt-files.adb",
	# "grt/grt-images.adb",
	# "grt/grt-lib.adb",
	# "grt/grt-modules.adb",
	# "grt/grt-names.adb",
	# "grt/grt-processes.adb",
	# "grt/grt-shadow_ieee.adb",
	# "grt/grt-signals.adb",
	# "grt/grt-stats.adb",
	# "grt/grt-values.adb",
	# "grt/grt-rtis.adb",
	# "grt/grt-c.ads"
# )

# Write-Host "  Command: '$GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS -I- $GHDL_SRC/<File>.adb'" -ForegroundColor Cyan
# foreach ($File in $COMPILE_FILES)
# {	Write-Host "  $GHDL_SRC/$File" -ForegroundColor Yellow
	# & $GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS -I- $GHDL_SRC/$File
# }

# Write-Host "  $GHDL_ROOT/dist/llvm/windows/grt-backtraces-impl.ads" -ForegroundColor Yellow
# & $GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS $GHDL_ROOT/dist/llvm/windows/grt-backtraces-impl.ads

# $COMPILE_FILES = (
	# "grt/grt-callbacks.adb",
	# "grt/grt-avhpi.adb",
	# "grt/grt-avhpi_utils.adb",
	# "grt/grt-rtis_addr.adb",
	# "grt/grt-rtis_utils.adb",
	# "grt/grt-vstrings.adb",
	# "grt/grt-table.adb",
	# "grt/grt-disp_rti.adb",
	# "grt/grt-disp_tree.adb",
	# "grt/grt-fst.adb",
	# "grt/grt-vcd.adb",
	# "grt/grt-vcdz.adb",
	# "grt/grt-vital_annotate.adb",
	# "grt/grt-vpi.adb",
	# "grt/grt-waves.adb",
	# "grt/grt-threads.ads",
	# "grt/grt-stack2.adb",
	# "grt/grt-rtis_types.adb",
	# "grt/grt-backtraces-jit.adb",
	# "grt/grt-fst_api.ads",
	# "grt/grt-zlib.ads",
	# "grt/grt-sdf.adb",
	# "grt/grt-avls.adb",
	# "grt/grt-unithread.adb"
# )

# foreach ($File in $COMPILE_FILES)
# {	Write-Host "  $GHDL_SRC/$File" -ForegroundColor Yellow
	# & $GCC_GCC $COMPILE_OPTIONS $COMPILE_INC_PATHS -I- $GHDL_SRC/$File
# }

# ==============================================================================
# Write-Host "Binding source files..." -ForegroundColor Cyan
# Write-Host "  Command: '$GNAT_BINDER -Lgrt_ -o run-bind.adb -n ghdl_main.ali'" -ForegroundColor Gray
# & $GNAT_BINDER -Lgrt_ -o run-bind.adb -n ghdl_main.ali

# ==============================================================================
# Write-Host "Compiling source files..." -ForegroundColor Cyan
# Write-Host "  $GCC_GCC -c -g -gnatec$GHDL_SRC/grt/grt.adc -gnat05 -o run-bind.o run-bind.adb" -ForegroundColor Gray
# & $GCC_GCC -c -g -gnatec$GHDL_SRC/grt/grt.adc -gnat05 -o run-bind.o run-bind.adb
# Write-Host "  $GCC_GCC -c -g -gnatec$GHDL_SRC/grt/grt.adc -gnat05 -o main.o $GHDL_SRC/grt/main.adb" -ForegroundColor Gray
# & $GCC_GCC -c -g -gnatec$GHDL_SRC/grt/grt.adc -gnat05 -o main.o $GHDL_SRC/grt/main.adb



# restore Path
$env:Path = $PATH


