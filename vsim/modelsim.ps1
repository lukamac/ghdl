
[CmdletBinding()]
param(
	[string]	$BuildDirectory,
	[switch]	$Quiet = $false
)

$EnableDebug =		-not $Quiet -and (									$PSCmdlet.MyInvocation.BoundParameters["Debug"])
$EnableVerbose =	-not $Quiet -and ($EnableDebug	-or $PSCmdlet.MyInvocation.BoundParameters["Verbose"])

	
	

