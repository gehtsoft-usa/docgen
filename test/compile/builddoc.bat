if not exist obj nuget restore project.proj
msbuild project.proj /t:CleanDoc,MakeDoc