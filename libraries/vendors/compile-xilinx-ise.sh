#! /bin/bash
# EMACS settings: -*-	tab-width: 2; indent-tabs-mode: t -*-
# vim: tabstop=2:shiftwidth=2:noexpandtab
# kate: tab-width 2; replace-tabs off; indent-width 2;
# 
# ==============================================================================
#	Bash Script:				Script to compile the simulation libraries from Xilinx ISE
#											for GHDL on Linux
# 
#	Authors:						Patrick Lehmann
# 
# Description:
# ------------------------------------
#	This is a Bash script (executable) which:
#		- creates a subdirectory in the current working directory
#		- compiles all Xilinx ISE simulation libraries and packages
#
# ==============================================================================
#	Copyright (C) 2015 Patrick Lehmann
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

# ---------------------------------------------
# save working directory
WorkingDir=$(pwd)

# source configuration file from GHDL's 'vendors' library directory
source config.sh
source shared.sh

NO_COMMAND=TRUE

# command line argument processing
while [[ $# > 0 ]]; do
	key="$1"
	case $key in
		-c|--clean)
		CLEAN=TRUE
		NO_COMMAND=FALSE
		;;
		-u|--unisim)
		UNISIM=TRUE
		NO_COMMAND=FALSE
		;;
		-U|--unimacro)
		UNIMACRO=TRUE
		NO_COMMAND=FALSE
		;;
		-s|--simprim)
		SIMPRIM=TRUE
		NO_COMMAND=FALSE
		;;
		-S|--secureip)
		SECUREIP=TRUE
		;;
		-l|--large)
		LARGE_PRIMITIVES=TRUE
		;;
		--skip-existing)
		SKIP_EXISTING_FILES=TRUE
		;;
		--no-warnings)
		SUPPRESS_WARNINGS=TRUE
		;;
		-v|--verbose)
		VERBOSE=TRUE
		;;
		-h|--help)
		HELP=TRUE
		NO_COMMAND=FALSE
		;;
		*)		# unknown option
		UNKNOWN_OPTION=TRUE
		;;
	esac
	shift # past argument or value
done

if [ "$NO_COMMAND" == "TRUE" ]; then
	HELP=TRUE
fi

if [ "$UNKNOWN_OPTION" == "TRUE" ]; then
	echo -e $COLORED_ERROR "Unknown command line option." $ANSI_RESET
	exit -1
elif [ "$HELP" == "TRUE" ]; then
	if [ "$NO_COMMAND" == "TRUE" ]; then
		echo -e $COLORED_ERROR " No command selected."
	fi
	echo ""
	echo "Synopsis:"
	echo "  Script to compile the simulation libraries from Xilinx ISE for GHDL on Linux"
	echo ""
	echo "Usage:"
	echo "  compile-xilinx-ise.sh [-v] [-c] [-u|--unisim] [-U|--unimacro] [-s|--simprim] [-S|--secureip] [-l|--large] [--skip-existing] [--no-warnings]"
	echo ""
	echo "Commands:"
	echo "  -h --help           Print this help page"
	echo "  -c --clean          Remove ALL generated files"
	echo "  -u --unisim         Compile the unisim library."
	echo "  -U --unimacro       Compile the unimacro library."
	echo "  -s --simprim        Compile the simprim library."
	echo "  -S --secureip       Compile the secureip library."
	echo ""
	echo "Compile options:"
	echo "  -l --large          Compile large entities like DSP and PCIe primitives."
	echo "     --skip-existing  Skip already compiled files."
	echo ""
	echo "Verbosity:"
	echo "  -v --verbose        Print more messages"
	echo "     --no-warnings    Suppress all warnings. Show only error messages."
	echo ""
	exit 0
fi

# extract data from configuration
SourceDir="${InstallationDirectory[XilinxISE]}/ISE_DS/ISE/vhdl/src"
DestinationDir="${DestinationDirectory[XilinxISE]}"
ScriptDir=".."

# define global GHDL Options


# create "Xilinx" directory and change to it
if [[ -d "$DestinationDir" ]]; then
	echo -e "${ANSI_YELLOW}Vendor directory '$DestinationDir' already exists." $ANSI_RESET
else
	echo -e "${ANSI_YELLOW}Creating vendor directory: '$DestinationDir'" $ANSI_RESET
	mkdir "$DestinationDir"
fi
cd $DestinationDir

STOPCOMPILING=TRUE

if [ "$SUPPRESS_WARNINGS" == "FALSE" ]; then
	GRCRulesFile="$ScriptDir/ghdl.grcrules"
else
	GRCRulesFile="$ScriptDir/ghdl.skipwarning.grcrules"
fi


# CLEANup directory
# ==============================================================================
if [ "$CLEAN" == "TRUE" ]; then
	echo -e "${ANSI_YELLOW}Cleaning up vendor directory ..." $ANSI_RESET
	rm *.o
fi

# Library unisim
# ==============================================================================
# compile unisim packages
if [ "$UNISIM" == "TRUE" ]; then
	echo -e "${ANSI_YELLOW}Compiling library 'unisim' ..." $ANSI_RESET
	Files=(
		$SourceDir/unisims/unisim_VPKG.vhd
		$SourceDir/unisims/unisim_VCOMP.vhd
	)

	for File in ${Files[@]}; do
		FileName=$(basename "$File")
		if [ "$SKIP_EXISTING_FILES" == "TRUE" ] && [ -e "${FileName%.*}.o" ]; then
			echo -n ""
#			echo -e "${ANSI_CYAN}Skipping package '$File'" $ANSI_RESET
		else
			echo -e "${ANSI_CYAN}Analyzing package '$File'" $ANSI_RESET
			ghdl -a -fexplicit -frelaxed-rules --warn-binding --mb-comments --no-vital-checks --ieee=synopsys --std=93c --work=unisim $File 2>&1 | grcat $GRCRulesFile
		fi
	done
fi

# compile unisim primitives
if [ "$UNISIM" == "TRUE" ]; then
	Files=$SourceDir/unisims/primitive/*.vhd
	for File in $Files; do
		FileName=$(basename "$File")
		if [ "$SKIP_EXISTING_FILES" == "TRUE" ] && [ -e "${FileName%.*}.o" ]; then
			echo -n ""
#			echo -e "${ANSI_CYAN}Skipping package '$File'" $ANSI_RESET
		else
			echo -e "${ANSI_CYAN}Analyzing primitive '$File'" $ANSI_RESET
			ghdl -a -fexplicit -frelaxed-rules --warn-binding --mb-comments --no-vital-checks --ieee=synopsys --std=93c --work=unisim $File 2>&1 | grcat $GRCRulesFile
		fi
	done
fi

# compile unisim secureip primitives
if [ "$UNISIM" == "TRUE" ] && [ "$SECUREIP" == "TRUE" ]; then
	echo -e "${ANSI_YELLOW}Compiling library secureip primitives" $ANSI_RESET
	Files=$SourceDir/unisims/secureip/*.vhd
	for File in $Files; do
		FileName=$(basename "$File")
		if [ "$SKIP_EXISTING_FILES" == "TRUE" ] && [ -e "${FileName%.*}.o" ]; then
			echo -n ""
#			echo -e "${ANSI_CYAN}Skipping package '$File'" $ANSI_RESET
		else
			echo -e "${ANSI_CYAN}Analyzing primitive '$File'" $ANSI_RESET
			ghdl -a -fexplicit -frelaxed-rules --warn-binding --mb-comments --no-vital-checks --ieee=synopsys --std=93c --work=secureip $File 2>&1 | grcat $GRCRulesFile
		fi
	done
fi

# Library unimacro
# ==============================================================================
# compile unimacro packages
if [ "$UNIMACRO" == "TRUE" ]; then
	echo -e "${ANSI_YELLOW}Compiling library 'unimacro' ..." $ANSI_RESET

	Files=(
		$SourceDir/unimacro/unimacro_VCOMP.vhd
	)
	for File in ${Files[@]}; do
		FileName=$(basename "$File")
		if [ "$SKIP_EXISTING_FILES" == "TRUE" ] && [ -e "${FileName%.*}.o" ]; then
			echo -n ""
#			echo -e "${ANSI_CYAN}Skipping package '$File'" $ANSI_RESET
		else
			echo -e "${ANSI_CYAN}Analyzing package '$File'" $ANSI_RESET
			ghdl -a -fexplicit -frelaxed-rules --warn-binding --mb-comments --no-vital-checks --ieee=synopsys --std=93c --work=unimacro $File 2>&1 | grcat $GRCRulesFile
		fi
	done
fi
	
# compile unimacro macros
if [ "$UNIMACRO" == "TRUE" ]; then
	Files=$SourceDir/unimacro/*_MACRO.vhd*
	for File in $Files; do
		FileName=$(basename "$File")
		if [ "$SKIP_EXISTING_FILES" == "TRUE" ] && [ -e "${FileName%.*}.o" ]; then
			echo -n ""
#			echo -e "${ANSI_CYAN}Skipping package '$File'" $ANSI_RESET
		else
			echo -e "${ANSI_CYAN}Analyzing primitive '$File'" $ANSI_RESET
			ghdl -a -fexplicit -frelaxed-rules --warn-binding --mb-comments --no-vital-checks --ieee=synopsys --std=93c --work=unisim $File 2>&1 | grcat $GRCRulesFile
		fi
	done
fi

# Library simprim
# ==============================================================================
# compile simprim packages
if [ "$SIMPRIM" == "TRUE" ]; then
	echo -e "${ANSI_YELLOW}Compiling library 'simprim' ..." $ANSI_RESET

	Files=(
		$SourceDir/simprims/simprim_Vpackage.vhd
		$SourceDir/simprims/simprim_Vcomponents.vhd
	)
	for File in ${Files[@]}; do
		FileName=$(basename "$File")
		if [ "$SKIP_EXISTING_FILES" == "TRUE" ] && [ -e "${FileName%.*}.o" ]; then
			echo -n ""
#			echo -e "${ANSI_CYAN}Skipping package '$File'" $ANSI_RESET
		else
			echo -e "${ANSI_CYAN}Analyzing package '$File'" $ANSI_RESET
			ghdl -a -fexplicit -frelaxed-rules --warn-binding --mb-comments --no-vital-checks --ieee=synopsys --std=93c --work=simprim $File 2>&1 | grcat $GRCRulesFile
		fi
	done
fi

# compile UNISIM primitives
if [ "$SIMPRIM" == "TRUE" ]; then
	Files=$SourceDir/simprims/primitive/other/*.vhd*
	for File in $Files; do
		FileName=$(basename "$File")
		if [ "$SKIP_EXISTING_FILES" == "TRUE" ] && [ -e "${FileName%.*}.o" ]; then
			echo -n ""
#			echo -e "${ANSI_CYAN}Skipping package '$File'" $ANSI_RESET
		else
			echo -e "${ANSI_CYAN}Analyzing primitive '$File'" $ANSI_RESET
			ghdl -a -fexplicit -frelaxed-rules --warn-binding --mb-comments --no-vital-checks --ieee=synopsys --std=93c --work=simprim $File 2>&1 | grcat $GRCRulesFile
		fi
	done
fi

# compile UNISIM secureip primitives
if [ "$SIMPRIM" == "TRUE" ] && [ "$SECUREIP" == "TRUE" ]; then
	Files=`ls -v $SourceDir/simprims/secureip/other/*.vhd*`
	for File in $Files; do
		FileName=$(basename "$File")
		if [ "$SKIP_EXISTING_FILES" == "TRUE" ] && [ -e "${FileName%.*}.o" ]; then
			echo -n ""
#			echo -e "${ANSI_CYAN}Skipping package '$File'" $ANSI_RESET
		else
			echo -e "${ANSI_CYAN}Analyzing primitive '$File'" $ANSI_RESET
			ghdl -a -fexplicit -frelaxed-rules --warn-binding --mb-comments --no-vital-checks --ieee=synopsys --std=93c --work=simprim $File 2>&1 | grcat $GRCRulesFile
		fi
	done
fi
	
echo "--------------------------------------------------------------------------------"
echo -n "Compiling Xilinx ISE libraries "
if [ "$STOPCOMPILING" == "TRUE" ]; then
	echo -e $COLORED_FAILED
else
	echo -e $COLORED_SUCCESSFUL
fi

cd $WorkingDir
