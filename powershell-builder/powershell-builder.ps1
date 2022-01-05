# PowerShell Builder Tool
#
# @author:  https://github.com/linusniederer
# @changes: 05.01.2022
# 

class Builder {

    # [array] $modules = @('ps2exe', 'Sorlov.PowerShell')
    [array] $modules = @('ps2exe')

    [string] $mergeName = "temp~merge.ps1"
    [string] $mergePath

    # Config
    [string] $name
    [string] $version
    [string] $title
    [string] $description
    [string] $type
    [string] $company
    [string] $author
    [string] $copyright
    [string] $icon

    [string] $outPath
    [string] $projectPath

    [array] $files

    # Constructor of class
    Builder() {
        $this.checkModule()
    }

    # Methode to build executable (*.exe)
    [void] buildExecutable() { 

        $params = @{
            'inputFile' = $this.mergePath;
            'outputFile' = $this.outPath;
            'title' = $this.title;
            'iconFile' = $this.icon;
            'description' = $this.description;
            'company' = $this.company;
            'copyright' = $this.copyright;
            'version' = $this.version;
        }
        
        Invoke-ps2exe @params
        Remove-Item -Path $this.mergePath -Force 
    }

    # Method to merge different project files
    [void] mergeFiles() {

        # create temp file in project folder
        $this.mergePath = "$($this.projectPath)$($this.mergeName)"
        New-Item -ItemType File -Path $this.mergePath -Force

        foreach( $file in $this.files | Sort-Object "position" ) {
            $filePath = "$($file.path)$($file.name)"
            $content = Get-Content -Path $filePath -Force
            Add-Content -Value $content -Path $this.mergePath
        }
    }

    # Method to load configuration file
    [void] loadConfig( $path ) {

        $config = Get-Content $path | ConvertFrom-Json
        
        $this.name          = $config.name
        $this.version       = $config.version
        $this.title         = $config.title
        $this.description   = $config.description
        $this.type          = $config.type
        $this.company       = $config.company
        $this.author        = $config.author
        $this.copyright     = $config.copyright
        $this.icon          = $config.icon

        $this.outPath       = $config.outPath
        $this.projectPath   = $config.projectPath

        $this.files = $config.files
    }

    # Method to check if required modules are installed
    hidden [void] checkModule() {

        foreach( $module in $this.modules ) {
            if(Get-Module -ListAvailable -Name $module) {
                Import-Module -Name $module -Force
            } else {
                Install-Module -Name $module -Force
            }
        }
    }
}

## Code starts here
$demoProject = [Builder]::new()
$demoProject.loadConfig("C:\Users\linusniederer\Downloads\demo-project\default-config.json") 
$demoProject.mergeFiles()
$demoProject.buildExecutable()