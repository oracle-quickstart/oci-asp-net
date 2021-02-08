

echo 'Hello from terraform. Creating a simple website' > C:\hello_from_terraform_1234567890.txt
Start-Process powershell -Verb runAs

# Unzip the project
# Unzip the project
mkdir C:\Project
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "C:\Temp\App.zip" "C:\Application"
Move-Item -Path C:\Application\App\* -Destination C:\Project

# Install windows features
Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools
Import-Module WebAdministration
Get-WebSite -Name "Default Web Site" | Remove-WebSite -Confirm:$false -Verbose
New-Website -Name venkatatest -ApplicationPool DefaultAppPool -IPAddress * -PhysicalPath C:\Project -Port 80
iisreset

# Quick way to download the Windows Hosting Bundle installers which are
# then be executed on the VM ...
function Perform-Download-Install {
  param($installUrl)
   Write-Output "Downloading and Installing $installUrl"
   $temp_path = "C:\temp\"

   if( ![System.IO.Directory]::Exists( $temp_path ))
   {
      Write-Output "Path not found ($temp_path), create the directory and try again"
      mkdir C:\temp
   }

   $whb_installer_file = $temp_path + [System.IO.Path]::GetFileName($installUrl)

   Try
   {
      Invoke-WebRequest -Uri $installUrl -OutFile $whb_installer_file
      Write-Output "Installer downloaded"
      Write-Output "- Execute the $whb_installer_file to install the ASP.Net Core Runtime"
      $args = New-Object -TypeName System.Collections.Generic.List[System.String]
      $args.Add("/quiet")
      $args.Add("/install")
      $args.Add("/norestart")
      $Output = Start-Process -FilePath $whb_installer_file -ArgumentList $args -NoNewWindow -Wait -PassThru
      If($Output.Exitcode -eq 0)
      {
        Write-Output "Successfully installed"
      }
      else
      {
        Write-Error "`t`t Something went wrong with the installation. Errorlevel: ${Output.ExitCode}"
        Exit 1
      }
   }
   Catch
   {
      Write-Output ( $_.Exception.ToString() )
      Break
   }
}

## Perform-Download-Install -installUrl "https://download.visualstudio.microsoft.com/download/pr/75483251-b77a-41a9-9ea2-05fb1668e148/2c27ea12ec2c93434c447f4009f2c2d2/dotnet-sdk-5.0.102-win-x64.exe"
Perform-Download-Install -installUrl "https://download.visualstudio.microsoft.com/download/pr/43ea9d7a-39c9-467a-83e6-548b3faf832d/5e7d573d9c4f40d0c1192aa2319f07c5/dotnet-hosting-5.0.2-win.exe"



