using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Xunit;
using Microsoft.AspNetCore.Mvc.Testing;

namespace AlienApp.Tests;

public class UserProfileTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public UserProfileTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task UserCanEditProfileDisplayName()
    {
        // Register a new user
        var newUser = new { Email = "editprofile@example.com", Password = "TestPassword123!", DisplayName = "Original Name", Age = 25 };
        var registerResponse = await _client.PostAsJsonAsync("/api/users/register", newUser);
        registerResponse.EnsureSuccessStatusCode();
        var registerResult = await registerResponse.Content.ReadFromJsonAsync<UserRegistrationResult>();
        Assert.NotNull(registerResult);
        Assert.True(registerResult!.Success);
        var userId = registerResult.UserId;
        Assert.False(string.IsNullOrEmpty(userId));

        // Edit profile (change display name)
        var updateRequest = new { UserId = userId, DisplayName = "Updated Name" };
        var updateResponse = await _client.PutAsJsonAsync($"/api/users/profile", updateRequest);
        updateResponse.EnsureSuccessStatusCode();
        var updateResult = await updateResponse.Content.ReadFromJsonAsync<UserProfileResult>();
        Assert.NotNull(updateResult);
        Assert.True(updateResult!.Success);
        Assert.Equal("Updated Name", updateResult.DisplayName);
    }

    private class UserRegistrationResult
    {
        public bool Success { get; set; }
        public string? UserId { get; set; }
    }

    private class UserProfileResult
    {
        public bool Success { get; set; }
        public string? DisplayName { get; set; }
    }
}
