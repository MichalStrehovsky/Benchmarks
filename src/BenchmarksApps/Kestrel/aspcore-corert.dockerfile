FROM mcr.microsoft.com/dotnet/nightly/sdk:6.0 AS build
RUN apt-get update
RUN apt-get -yqq install clang zlib1g-dev libkrb5-dev libtinfo5
WORKDIR /app
COPY PlatformBenchmarks .
ENV database PostgreSQL
ENV connectionstring Server=10.0.0.103;Database=hello_world;User Id=benchmarkdbuser;Password=benchmarkdbpass;Maximum Pool Size=18;Enlist=false;Max Auto Prepare=4;Multiplexing=true;Write Coalescing Buffer Threshold Bytes=1000
RUN dotnet publish -c Release -o out /p:MicrosoftNETCoreAppPackageVersion=6.0.0-preview.5.21301.5 /p:MicrosoftAspNetCoreAppPackageVersion=6.0.0-preview.5.21301.17 /p:BenchmarksNETStandardImplicitPackageVersion=6.0.0-preview.5.21301.17 /p:BenchmarksNETCoreAppImplicitPackageVersion=6.0.0-preview.5.21301.17 /p:BenchmarksRuntimeFrameworkVersion=6.0.0-preview.5.21301.5 /p:BenchmarksTargetFramework=net6.0 /p:BenchmarksAspNetCoreVersion=6.0.0-preview.5.21301.17 /p:MicrosoftAspNetCoreAllPackageVersion=6.0.0-preview.5.21301.17 /p:NETCoreAppMaximumVersion=99.9 /p:MicrosoftNETCoreApp50PackageVersion=6.0.0-preview.5.21301.5 /p:GenerateErrorForMissingTargetingPacks=false /p:MicrosoftNETPlatformLibrary=Microsoft.NETCore.App /p:RestoreNoCache=true --framework net6.0 --self-contained -r linux-x64 /p:IsDatabase=true

FROM mcr.microsoft.com/dotnet/nightly/aspnet:6.0 AS runtime
ENV ASPNETCORE_URLS http://+:5000
ENV DOTNET_SYSTEM_NET_SOCKETS_INLINE_COMPLETIONS 1
WORKDIR /app
COPY --from=build /app/out ./

EXPOSE 5000

ENTRYPOINT ["./PlatformBenchmarks"]
