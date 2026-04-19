using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Xunit;
using Microsoft.AspNetCore.Mvc.Testing;

namespace AlienApp.Tests;

public class UserPasswordSecurityTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public UserPasswordSecurityTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task RegisterUser_DoesNotReturnPassword()
    {
        var newUser = new { Email = "securepass@example.com", Password = "SuperSecret123!", DisplayName = "Secure User", Age = 25 };
        var response = await _client.PostAsJsonAsync("/api/users/register", newUser);
        response.EnsureSuccessStatusCode();
        var json = await response.Content.ReadAsStringAsync();
        Assert.DoesNotContain("SuperSecret123!", json);
        Assert.DoesNotContain("Password", json, System.StringComparison.OrdinalIgnoreCase);
    }
}
