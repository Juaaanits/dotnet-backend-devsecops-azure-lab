FROM mcr.microsoft.com/dotnet/sdk:8.0.425-bookworm-slim AS build
WORKDIR /src
COPY ["sakenny/sakenny.csproj", "sakenny/"]
RUN dotnet restore "sakenny/sakenny.csproj"
COPY . .
RUN dotnet publish "sakenny/sakenny.csproj" --configuration Release --output /app/publish --no-restore /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0.31-bookworm-slim AS runtime
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl libpcre2-8-0 \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "sakenny.dll"]
