using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Xunit;
using Microsoft.AspNetCore.Mvc.Testing;

namespace AlienApp.Tests;

public class UserAccountDeactivationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public UserAccountDeactivationTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task UserCanDeactivateAccount()
    {
        // Register a new user
        var newUser = new { Email = "deactivate@example.com", Password = "TestPassword123!", DisplayName = "To Be Deleted", Age = 25 };
        var registerResponse = await _client.PostAsJsonAsync("/api/users/register", newUser);
        registerResponse.EnsureSuccessStatusCode();
        var registerResult = await registerResponse.Content.ReadFromJsonAsync<UserRegistrationResult>();
        Assert.NotNull(registerResult);
        Assert.True(registerResult!.Success);
        var userId = registerResult.UserId;
        Assert.False(string.IsNullOrEmpty(userId));

        // Deactivate (delete) the account
        var deleteResponse = await _client.DeleteAsync($"/api/users/{userId}");
        deleteResponse.EnsureSuccessStatusCode();
        var deleteResult = await deleteResponse.Content.ReadFromJsonAsync<UserDeactivationResult>();
        Assert.NotNull(deleteResult);
        Assert.True(deleteResult!.Success);

        // Try to update profile after deletion (should fail)
        var updateRequest = new { UserId = userId, DisplayName = "Should Not Work" };
        var updateResponse = await _client.PutAsJsonAsync($"/api/users/profile", updateRequest);
        Assert.False(updateResponse.IsSuccessStatusCode);
    }

    private class UserRegistrationResult
    {
        public bool Success { get; set; }
        public string? UserId { get; set; }
    }

    private class UserDeactivationResult
    {
        public bool Success { get; set; }
    }
}
