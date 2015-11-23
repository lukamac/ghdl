param(
	[switch]$All =				$true
)

# ---------------------------------------------
# save working directory
$WorkingDir = Get-Location

. $PSScriptRoot\config.ps1
. $PSScriptRoot\shared.ps1

# extract data from configuration
$SourceDir =			$InstallationDirectory["OSVVM"]
$DestinationDir = $DestinationDirectory["OSVVM"]

# define global GHDL Options
$GlobalOptions = ("-a", "-fexplicit", "-frelaxed-rules", "--mb-comments", "--warn-binding", "--no-vital-checks", "--std=08")

# create "osvvm" directory and change to it
Write-Host "Creating vendor directory: '$DestinationDir'" -ForegroundColor Yellow
mkdir $DestinationDir -ErrorAction SilentlyContinue | Out-Null
cd $DestinationDir

if (-not $All)
{	$All =				$false	}
elseif ($All -eq $true)
{	# nothing to configure
}

$StopCompiling = $false

# compile osvvm library
if (-not $StopCompiling)
{	Write-Host "Compiling library 'osvvm' ..." -ForegroundColor Yellow
	$Options = $GlobalOptions
	$Files = (
		"$SourceDir\NamePkg.vhd",
		"$SourceDir\OsvvmGlobalPkg.vhd",
		"$SourceDir\TextUtilPkg.vhd",
		"$SourceDir\TranscriptPkg.vhd",
		"$SourceDir\AlertLogPkg.vhd",
		"$SourceDir\MemoryPkg.vhd",
		"$SourceDir\MessagePkg.vhd",
		"$SourceDir\SortListPkg_int.vhd",
		"$SourceDir\RandomBasePkg.vhd",
		"$SourceDir\RandomPkg.vhd",
		"$SourceDir\CoveragePkg.vhd",
		"$SourceDir\OsvvmContext.vhd")
	foreach ($File in $Files)
	{	Write-Host "Analysing file '$File'" -ForegroundColor Cyan
		$InvokeExpr = "ghdl.exe " + ($Options -join " ") + " --work=osvvm " + $File + " 2>&1"
		#Write-Host ("InvokeExpr=" + $InvokeExpr)
			
		$Output = Invoke-Expression $InvokeExpr -ErrorVariable Errors | Out-Null
		$StopCompiling = ($LastExitCode -ne 0)
		if ($Errors)
		{	Write-Host ("InvokeExpr= '" + $InvokeExpr + "'")
			foreach ($Err in $Errors)
			{ $Line = $Err.ToString()
				if ($Line.Contains("warning"))
				{	Write-Host "WARNING: "	-NoNewline -ForegroundColor Yellow	}
				else
				{	Write-Host "ERROR: "		-NoNewline -ForegroundColor Red			}
				Write-Host $Line
			}
		}
		elseif ($Output)
		{	foreach ($Line in $Output)
			{	if ($Line -eq "")	{	continue	}
				if ($Line.Contains("warning"))
				{	Write-Host "WARNING: "	-NoNewline -ForegroundColor Yellow	}
				else
				{	Write-Host "ERROR: "		-NoNewline -ForegroundColor Red			}
				Write-Host $Line
			}
		}
		if ($StopCompiling)	{ break		}
	}
}

Write-Host "--------------------------------------------------------------------------------"
Write-Host "Compiling OSVVM libraries " -NoNewline
if ($StopCompiling)
{	Write-Host "[FAILED]" -ForegroundColor Red				}
else
{	Write-Host "[SUCCESSFUL]" -ForegroundColor Green	}

# restore working directory
cd $WorkingDir
