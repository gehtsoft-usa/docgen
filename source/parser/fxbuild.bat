@echo off

IF /i "%1" == "debug" (
    set config=Debug
) ELSE (
    set config=Release
)

msbuild docgen2.parser.csproj /p:Configuration=%config%
