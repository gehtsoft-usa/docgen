if not exist obj nuget restore project.proj
dotnet build project.proj /t:CleanDoc
dotnet build project.proj /t:Scan,Raw
dotnet build project.proj /t:MakeDoc
