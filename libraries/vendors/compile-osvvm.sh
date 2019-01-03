#! /usr/bin/env bash
# EMACS settings: -*-	tab-width: 2; indent-tabs-mode: t -*-
# vim: tabstop=2:shiftwidth=2:noexpandtab
# kate: tab-width 2; replace-tabs off; indent-width 2;
# 
# ==============================================================================
#	Authors:						Patrick Lehmann
# 
#	Bash Script:				Script to compile the OSVVM library for GHDL on Linux
# 
# Description:
# ------------------------------------
#	This is a Bash script (executable) which:
#		- creates a subdirectory in the current working directory
#		- compiles all OSVVM packages 
#
# ==============================================================================
#	Copyright (C) 2017-2019 Patrick Lehmann - Boetzingen, Germany
#	Copyright (C) 2015-2016 Patrick Lehmann - Dresden, Germany
#	
#	GHDL is free software; you can redistribute it and/or modify it under
#	the terms of the GNU General Public License as published by the Free
#	Software Foundation; either version 2, or (at your option) any later
#	version.
#	
#	GHDL is distributed in the hope that it will be useful, but WITHOUT ANY
#	WARRANTY; without even the implied warranty of MERCHANTABILITY or
#	FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#	for more details.
#	
#	You should have received a copy of the GNU General Public License
#	along with GHDL; see the file COPYING.  If not, write to the Free
#	Software Foundation, 59 Temple Place - Suite 330, Boston, MA
#	02111-1307, USA.
# ==============================================================================

# Work around for Darwin (Mac OS)
READLINK=readlink; if [[ $(uname) == "Darwin" ]]; then READLINK=greadlink; fi

# Save working directory
WorkingDir=$(pwd)
ScriptDir="$(dirname $0)"
ScriptDir="$($READLINK -f $ScriptDir)"

# Source Bash utilities
source $ScriptDir/../../dist/ansi_color.sh
if [[ $? -ne 0 ]]; then echo 1>&2 -e "${COLORED_ERROR} While loading Bash utilities.${ANSI_NOCOLOR}"    ; exit 1; fi


# Command line argument processing
COMMAND=1
CLEAN=0
COMPILE_OSVVM=0
VERBOSE=0
DEBUG=0
FILTERING=0  # TODO: 1
SUPPRESS_WARNINGS=0
HALT_ON_ERROR=0
DestDir=""
SrcDir=""
while [[ $# > 0 ]]; do
	case "$1" in
		-c|--clean)
			COMMAND=3
			CLEAN=1
			;;
		-a|--all)
			COMMAND=2
			;;
		--osvvm)
			COMMAND=3
			COMPILE_OSVVM=1
			;;
		-v|--verbose)
			VERBOSE=1
			;;
		-d|--debug)
			VERBOSE=1
			DEBUG=1
			;;
		-h|--help)
			COMMAND=0
			break
			;;
		-n|--no-filter)
			FILTERING=0
			;;
		-N|--no-warnings)
			SUPPRESS_WARNINGS=1
			;;
		-H|--halt-on-error)
			HALT_ON_ERROR=1
			;;
		--ghdl)
			GHDL="$2"				# overwrite a potentially existing GHDL environment variable
			shift						# skip argument
			;;
		--src)
			SrcDir="$2"
			shift						# skip argument
			;;
		--out)
			DestDir="$2"
			shift						# skip argument
			;;
		*)		# unknown option
			echo 1>&2 -e "${COLORED_ERROR} Unknown command line option '$1'.${ANSI_NOCOLOR}"
			exit 1
			;;
	esac
	shift # parsed argument or value
done

SKIP_EXISTING_FILES=0  # Makes no sense to enable it for OSVVM
ERRORCOUNT=0
Libraries=()

if [[ $COMMAND -le 1 ]]; then
	test $COMMAND -eq 1 && echo 1>&2 -e "\n${COLORED_ERROR} No command selected.${ANSI_NOCOLOR}"
	echo ""
	echo "Synopsis:"
	echo "  A script to compile the simulation library 'OSVVM' for GHDL on Linux."
	echo "  A library folder 'osvvm/v08' will be created relative to the current"
	echo "  working directory."
	echo ""
	echo "  Use the adv. options or edit 'config.sh' to supply paths and default params."
	echo ""
	echo "Usage:"
	echo "  compile-osvvm.sh [<verbosity>] <common command>|<library> [<options>] [<adv. options>]"
	echo ""
	echo "Common commands:"
	echo "  -h --help                Print this help page"
	echo "  -c --clean               Remove all generated files"
	echo ""
	echo "Libraries:"
	echo "  -a --all                 Compile all libraries."
	echo "     --osvvm               Compile library osvvm."
	# echo "     --osvvm-vip           Compile OSVVM Verification IPs (VIPs)."
	# echo ""
	# echo "Verification IPs:"
	# echo "     --osvvm-vip-axi       ARM AMBA AXI4"
	echo ""
	echo "Library compile options:"
	echo "  -H --halt-on-error       Halt on error(s)."
	echo ""
	echo "Advanced options:"
	echo "     --ghdl <GHDL binary>  Path to GHDL's executable, e.g. /usr/local/bin/ghdl"
	echo "     --out <dir name>      Name of the output directory, e.g. osvvm"
	echo "     --src <Path to OSVVM> Path to the sources."
	echo ""
	echo "Verbosity:"
	echo "  -v --verbose             Print verbose messages."
	echo "  -d --debug               Print debug messages."
#	echo "  -n --no-filter           Disable output filtering scripts."
	echo "  -N --no-warnings         Suppress all warnings. Show only error messages."
	echo ""
	exit $COMMAND
fi

if [[ $COMMAND -eq 2 ]]; then
	COMPILE_OSVVM=1
#	COMPILE_OSVVM_VIP=1
fi
# if [[ $COMPILE_OSVVM_VIP -eq 1 ]]; then
	# COMPILE_OSVVM_VIP_AXI=1
# fi


# Source configuration file from GHDL's 'vendors' library directory
source $ScriptDir/config.sh
if [[ $? -ne 0 ]]; then echo 1>&2 -e "${COLORED_ERROR} While loading configuration.${ANSI_NOCOLOR}"     ; exit 1; fi
source $ScriptDir/shared.sh
if [[ $? -ne 0 ]]; then echo 1>&2 -e "${COLORED_ERROR} While loading further procedures.${ANSI_NOCOLOR}"; exit 1; fi

# -> $SourceDirectories
# -> $DestinationDirectories
# -> $SrcDir
# -> $DestDir
# <= $SourceDirectory
# <= $DestinationDirectory
SetupDirectories OSVVM "OSVVM"

# Create "osvvm" directory and change to it
# => $DestinationDirectory
CreateDestinationDirectory
cd $DestinationDirectory


# => $SUPPRESS_WARNINGS
# <= $GRC_COMMAND
SetupGRCat


# Extend global GHDL Options
Analyze_Parameters+=(
	-fexplicit
	--no-vital-checks
	-Wbinding
	-Wno-hide
	-Wno-others
	-Wno-static
	--std=08
	-P$DestinationDirectory
)
VHDLVersion="v08"


# Cleanup directory
# ==============================================================================
if [[ $CLEAN -eq 1 ]]; then
	echo -e "${ANSI_YELLOW}Cleaning up directory ...${ANSI_NOCOLOR}"
	rm *.o 2> /dev/null
	rm *.cf 2> /dev/null
fi


# Library osvvm
# ==============================================================================
StructName="OSVVM"
Files=(
	NamePkg.vhd
	OsvvmGlobalPkg.vhd
	VendorCovApiPkg.vhd
	TranscriptPkg.vhd
	TextUtilPkg.vhd
	AlertLogPkg.vhd
	MessagePkg.vhd
	SortListPkg_int.vhd
	RandomBasePkg.vhd
	RandomPkg.vhd
	CoveragePkg.vhd
	MemoryPkg.vhd
	ScoreboardGenericPkg.vhd
	ScoreboardPkg_slv.vhd
	ScoreboardPkg_int.vhd
	ResolutionPkg.vhd
	TbUtilPkg.vhd
	OsvvmContext.vhd
)
CreateLibraryStruct $StructName "osvvm" "." $VHDLVersion "${Files[@]}"
test $COMPILE_OSVVM -eq 1 && Libraries+=($StructName)

# for VIPName in ${VIPNames[*]}; do
	# VarName="COMPILE_OSVVM_${VIPName}"
	# if [[ ${!VarName} -eq 1 ]]; then
		# Libraries="$Libraries $VIPName"
	# fi
# done

# Compile libraries
if [[ "$Libraries" != "" ]]; then
	Compile "$SourceDirectory" "${Libraries[*]}"
	
	echo "--------------------------------------------------------------------------------"
	echo -e "Compiling OSVVM packages and VIPs $(test $ERRORCOUNT -eq 0 && echo $COLORED_SUCCESSFUL || echo $COLORED_FAILED)"
else
	echo -e "${ANSI_RED}Neither OSVVM packages nor VIPs selected.${ANSI_NOCOLOR}"
fi
