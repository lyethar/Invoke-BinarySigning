function Sign-Binary {
    param (
        [Parameter(Mandatory=$true)]
        [string]$BinaryPath
    )

    $makeCertPath = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\MakeCert.exe"
    $pvk2pfxPath = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\pvk2pfx.exe"
    $signtoolPath = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe"

    # Create a self-signed root certificate
    & $makeCertPath -r -pe -n "CN=Microsoft Root Certificate Authority 2010, O=Microsoft Corporation, L=Redmond, S=Washington, C=US" -ss CA -sr CurrentUser -a sha256 -cy authority -sky signature -sv CA.pvk CA.cer

    # Create a self-signed code signing certificate
    & $makeCertPath -pe -n "CN=Microsoft Windows Production PCA 2011, O=Microsoft Corporation, L=Redmond, S=Washington, C=US" -a sha256 -cy end -sky signature -eku 1.3.6.1.5.5.7.3.3,1.3.6.1.4.1.311.10.3.24,1.3.6.1.4.1.311.10.3.6 -ic CA.cer -iv CA.pvk -sv SPC.pvk SPC.cer

    # Convert to PFX
    & $pvk2pfxPath -pvk SPC.pvk -spc SPC.cer -pfx SPC.pfx

    # Sign the binary
    & $signtoolPath sign /fd SHA256 /v /f SPC.pfx $BinaryPath
}

# Example usage:
# Sign-Binary -BinaryPath "path\to\your\binary.exe"
