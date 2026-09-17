using System.Reflection;
using Microsoft.AspNetCore.Authorization;
using sakenny.API.Controllers;
using sakenny.Controllers;
using Xunit;

namespace Sakenny.Tests;

public class AuthorizationMetadataTests
{
    [Theory]
    [InlineData(typeof(ServicesController), nameof(ServicesController.Add))]
    [InlineData(typeof(ServicesController), nameof(ServicesController.Update))]
    [InlineData(typeof(ServicesController), nameof(ServicesController.Delete))]
    [InlineData(typeof(TypeController), nameof(TypeController.Add))]
    [InlineData(typeof(TypeController), nameof(TypeController.Update))]
    [InlineData(typeof(TypeController), nameof(TypeController.Delete))]
    public void LookupMutationsRequireAdmin(Type controllerType, string actionName)
    {
        var action = controllerType.GetMethod(actionName);
        Assert.NotNull(action);
        var authorize = action!.GetCustomAttribute<AuthorizeAttribute>();
        Assert.NotNull(authorize);
        Assert.Equal("Admin", authorize!.Roles);
    }

    [Theory]
    [InlineData(typeof(ServicesController), nameof(ServicesController.GetAllServices))]
    [InlineData(typeof(TypeController), nameof(TypeController.GetAll))]
    public void LookupReadsRemainPublic(Type controllerType, string actionName)
    {
        var action = controllerType.GetMethod(actionName);
        Assert.NotNull(action);
        Assert.Null(action!.GetCustomAttribute<AuthorizeAttribute>());
    }

    [Fact]
    public void DashboardControllerRequiresAdmin()
    {
        var authorize = typeof(DashboardController).GetCustomAttribute<AuthorizeAttribute>();
        Assert.NotNull(authorize);
        Assert.Equal("Admin", authorize!.Roles);
    }

    [Fact]
    public void AdminRegistrationRequiresExistingAdmin()
    {
        var action = typeof(adminController).GetMethod(nameof(adminController.registerAdmin));
        Assert.NotNull(action);
        var authorize = action!.GetCustomAttribute<AuthorizeAttribute>();
        Assert.NotNull(authorize);
        Assert.Equal("Admin", authorize!.Roles);
    }
}
