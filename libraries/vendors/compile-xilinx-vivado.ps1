# EMACS settings: -*-	tab-width: 2; indent-tabs-mode: t -*-
# vim: tabstop=2:shiftwidth=2:noexpandtab
# kate: tab-width 2; replace-tabs off; indent-width 2;
# 
# ==============================================================================
#	PowerShell Script:	Script to compile the simulation libraries from Xilinx
#											Vivado for GHDL on Windows
# 
#	Authors:						Patrick Lehmann
# 
# Description:
# ------------------------------------
#	This is a PowerShell script (executable) which:
#		- creates a subdirectory in the current working directory
#		- compiles all Xilinx Vivado simulation libraries and packages
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

# .SYNOPSIS
# This CmdLet compiles the simulation libraries from Xilinx.
# 
# .DESCRIPTION
# This CmdLet:
#   (1) creates a subdirectory in the current working directory
#   (2) compiles all Xilinx Vivado simulation libraries and packages
#       - unisim (incl. secureip)
#       - unimacro
# 
[CmdletBinding()]
param(
	# Compile all libraries and packages.
	[switch]$All =			$null,
	
	# Compile the Xilinx simulation library.
	[switch]$Unisim =		$false,
	
	# Compile the Xilinx macro library.
	[switch]$Unimacro =	$false,
	
	# Compile the Xilinx secureip library.
	[switch]$SecureIP =	$false,
	
	# Skip warning messages. (Show errors only.)
	[switch]$SuppressWarnings = $false
)

# ---------------------------------------------
# save working directory
$WorkingDir = Get-Location

# load modules from GHDL's 'vendors' library directory
Import-Module $PSScriptRoot\config.psm1
Import-Module $PSScriptRoot\shared.psm1

# extract data from configuration
$SourceDir =			$InstallationDirectory["XilinxVivado"] + "\data\vhdl\src"
$DestinationDir = $DestinationDirectory["XilinxVivado"]

# define global GHDL Options
$GlobalOptions = ("-a", "-fexplicit", "-frelaxed-rules", "--warn-binding", "--mb-comments")

# create "Vivado" directory and change to it
Write-Host "Creating vendor directory: '$DestinationDir'" -ForegroundColor Yellow
mkdir $DestinationDir -ErrorAction SilentlyContinue | Out-Null
cd $DestinationDir

if (-not $All)
{	$All =			$false	}
elseif ($All -eq $true)
{	$Unisim =		$true
	$Simprim =	$true
	$Unimacro =	$true
	$SecureIP =	$true
}
$StopCompiling = $false

# Library UNISIM
# ==============================================================================
# compile unisim packages
if ((-not $StopCompiling) -and $Unisim)
{	Write-Host "Compiling library 'unisim' ..." -ForegroundColor Yellow
	$Options = $GlobalOptions
	$Options += "--no-vital-checks"
	$Options += "--ieee=synopsys"
	$Options += "--std=93c"
	$Files = (
		"$SourceDir\unisims\unisim_VPKG.vhd",
		"$SourceDir\unisims\unisim_VCOMP.vhd",
		"$SourceDir\unisims\retarget_VCOMP.vhd",
		"$SourceDir\unisims\unisim_retarget_VCOMP.vhd")
	foreach ($File in $Files)
	{	Write-Host "Analyzing package '$File'" -ForegroundColor Cyan
		$InvokeExpr = "ghdl.exe " + ($Options -join " ") + " --work=unisim " + $File + " 2>&1"
		$ErrorRecordFound = Invoke-Expression $InvokeExpr | Restore-NativeCommandStream | Write-ColoredGHDLLine $SuppressWarnings
		$StopCompiling = ($LastExitCode -ne 0)
		if ($StopCompiling)	{ break }
	}
}

# compile unisim primitives
if ((-not $StopCompiling) -and $Unisim)
{	$Options = $GlobalOptions
	$Options += "--no-vital-checks"
	$Options += "--ieee=synopsys"
	$Options += "--std=93c"
	$Files = dir "$SourceDir\unisims\primitive\*.vhd*"
	foreach ($File in $Files)
	{	Write-Host "Analyzing primitive '$($File.FullName)'" -ForegroundColor Cyan
		$InvokeExpr = "ghdl.exe " + ($Options -join " ") + " --work=unisim " + $File.FullName + " 2>&1"
		$ErrorRecordFound = Invoke-Expression $InvokeExpr | Restore-NativeCommandStream | Write-ColoredGHDLLine $SuppressWarnings
		$StopCompiling = ($LastExitCode -ne 0)
		if ($StopCompiling)	{ break }
	}
}

# compile unisim retarget primitives
if ((-not $StopCompiling) -and $Unisim)
{	$Options = $GlobalOptions
	$Options += "--no-vital-checks"
	$Options += "--ieee=synopsys"
	$Options += "--std=93c"
	$Files = dir "$SourceDir\unisims\retarget\*.vhd*"
	foreach ($File in $Files)
	{	Write-Host "Analyzing retarget primitive '$($File.FullName)'" -ForegroundColor Cyan
		$InvokeExpr = "ghdl.exe " + ($Options -join " ") + " --work=unisim " + $File.FullName + " 2>&1"
		$ErrorRecordFound = Invoke-Expression $InvokeExpr | Restore-NativeCommandStream | Write-ColoredGHDLLine $SuppressWarnings
		$StopCompiling = ($LastExitCode -ne 0)
		#if ($StopCompiling)	{ break }
	}
}

# compile unisim secureip primitives
if ((-not $StopCompiling) -and $Unisim -and $SecureIP)
{	Write-Host "Compiling library secureip primitives ..." -ForegroundColor Yellow
	$Options = $GlobalOptions
	$Options += "--ieee=synopsys"
	$Options += "--std=93c"
	$Files = dir "$SourceDir\unisims\secureip\*.vhd*"
	foreach ($File in $Files)
	{	Write-Host "Analyzing primitive '$($File.FullName)'" -ForegroundColor Cyan
		$InvokeExpr = "ghdl.exe " + ($Options -join " ") + " --work=secureip " + $File.FullName + " 2>&1"
		$ErrorRecordFound = Invoke-Expression $InvokeExpr | Restore-NativeCommandStream | Write-ColoredGHDLLine $SuppressWarnings
		$StopCompiling = ($LastExitCode -ne 0)
		if ($StopCompiling)	{ break }
	}
}

# Library UNIMACRO
# ==============================================================================
# compile unimacro packages
if ((-not $StopCompiling) -and $Unimacro)
{	Write-Host "Compiling library 'unimacro' ..." -ForegroundColor Yellow
	$Options = $GlobalOptions
	$Options += "--no-vital-checks"
	$Options += "--ieee=synopsys"
	$Options += "--std=93c"
	$Files = @(
		"$SourceDir\unimacro\unimacro_VCOMP.vhd")
	foreach ($File in $Files)
	{	Write-Host "Analyzing package '$File'" -ForegroundColor Cyan
		$InvokeExpr = "ghdl.exe " + ($Options -join " ") + " --work=unimacro " + $File + " 2>&1"
		$ErrorRecordFound = Invoke-Expression $InvokeExpr | Restore-NativeCommandStream | Write-ColoredGHDLLine $SuppressWarnings
		$StopCompiling = ($LastExitCode -ne 0)
		if ($StopCompiling)	{ break }
	}
}

# compile unimacro macros
if ((-not $StopCompiling) -and $Unimacro)
{	$Options = $GlobalOptions
	$Options += "--no-vital-checks"
	$Options += "--ieee=synopsys"
	$Options += "--std=93c"
	$Files = dir "$SourceDir\unimacro\*_MACRO.vhd*"
	foreach ($File in $Files)
	{	Write-Host "Analyzing primitive '$($File.FullName)'" -ForegroundColor Cyan
		$InvokeExpr = "ghdl.exe " + ($Options -join " ") + " --work=unimacro " + $File.FullName + " 2>&1"
		$ErrorRecordFound = Invoke-Expression $InvokeExpr | Restore-NativeCommandStream | Write-ColoredGHDLLine $SuppressWarnings
		$StopCompiling = ($LastExitCode -ne 0)
		#if ($StopCompiling)	{ break }
	}
}

# Library UNIFAST
# ==============================================================================
# TODO:

Write-Host "--------------------------------------------------------------------------------"
Write-Host "Compiling Xilinx Vivado libraries " -NoNewline
if ($StopCompiling)
{	Write-Host "[FAILED]" -ForegroundColor Red				}
else
{	Write-Host "[SUCCESSFUL]" -ForegroundColor Green	}

# unload PowerShell modules
Remove-Module shared
Remove-Module config

# restore working directory
cd $WorkingDir

