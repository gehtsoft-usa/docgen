msbuild ..\..\docgen.sln /p:Configuration=Release
del *.nupkg
nuget pack Gehtsoft.Build.DocGen.nuspec
copy *.nupkg ..\..\..\.nuget