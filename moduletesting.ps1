$Data = @()
$ResourcesJsonFile = '.\EmpireModules.json'

if(Test-Path $ResourcesJsonFile)
{
    $ResourcesJsonContent = ConvertFrom-Json -InputObject (Get-Content $ResourcesJsonFile -raw)

    #### Data Stuff
    foreach($Module in $ResourcesJsonContent)
    {

        #Propertize the Module Objects
        $ModuleOptionsObject = @()
        $ModuleOptions = $Module.options 
        $Module.options 
        $ModuleOptionsNotes = $ModuleOptions | Get-Member -MemberType NoteProperty
        ForEach($Note in $ModuleOptionsNotes)
        {
            $ModuleOptionsObject = $ModuleOptionsObject +[PSCustomObject]@{
                Name=($Note.Name);
                Definition=($Note.Definition);
            }
        }


    }

}


