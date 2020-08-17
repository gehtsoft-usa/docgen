if not exist obj nuget restore project.proj
msbuild project.proj /t:CleanDoc
msbuild project.proj /t:Scan,Raw
msbuild project.proj /t:MakeDoc
