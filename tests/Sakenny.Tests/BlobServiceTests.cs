using Microsoft.Extensions.Configuration;
using sakenny.Application.Services;
using Xunit;

namespace Sakenny.Tests;

public class BlobServiceTests
{
    [Fact]
    public void ConstructorDoesNotConnectToStorage()
    {
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["AzureBlobStorage:ConnectionString"] = "UseDevelopmentStorage=true",
                ["AzureBlobStorage:ContainerName"] = "images"
            })
            .Build();

        var exception = Record.Exception(() => new BlobService(configuration));
        Assert.Null(exception);
    }
}
