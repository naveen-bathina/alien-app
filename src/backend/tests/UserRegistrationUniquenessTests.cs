using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Xunit;
using Microsoft.AspNetCore.Mvc.Testing;

namespace AlienApp.Tests;

public class UserRegistrationUniquenessTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public UserRegistrationUniquenessTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task RegisterUser_WithDuplicateEmail_ReturnsBadRequest()
    {
        var newUser = new { Email = "unique@example.com", Password = "TestPassword123!", DisplayName = "First User", Age = 25 };
        var response1 = await _client.PostAsJsonAsync("/api/users/register", newUser);
        response1.EnsureSuccessStatusCode();
        var result1 = await response1.Content.ReadFromJsonAsync<UserRegistrationResult>();
        Assert.NotNull(result1);
        Assert.True(result1!.Success);

        // Try to register again with the same email
        var response2 = await _client.PostAsJsonAsync("/api/users/register", newUser);
        Assert.False(response2.IsSuccessStatusCode);
        var result2 = await response2.Content.ReadFromJsonAsync<UserRegistrationResult>();
        Assert.NotNull(result2);
        Assert.False(result2!.Success);
    }

    private class UserRegistrationResult
    {
        public bool Success { get; set; }
        public string? UserId { get; set; }
    }
}
