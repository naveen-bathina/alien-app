using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Xunit;
using Microsoft.AspNetCore.Mvc.Testing;
using System;

namespace AlienApp.Tests;

public class MeetupSchedulingTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    public MeetupSchedulingTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task CanScheduleMeetupTimeAndVenue()
    {
        // Register sender
        var sender = new { Email = "sender3@example.com", Password = "SenderPass123!", DisplayName = "Sender3", Age = 30 };
        var senderResp = await _client.PostAsJsonAsync("/api/users/register", sender);
        senderResp.EnsureSuccessStatusCode();
        var senderResult = await senderResp.Content.ReadFromJsonAsync<UserRegistrationResult>();
        Assert.NotNull(senderResult);
        Assert.True(senderResult!.Success);
        var senderId = senderResult.UserId;
        Assert.False(string.IsNullOrEmpty(senderId));

        // Register recipient
        var recipient = new { Email = "recipient3@example.com", Password = "RecipientPass123!", DisplayName = "Recipient3", Age = 28 };
        var recipientResp = await _client.PostAsJsonAsync("/api/users/register", recipient);
        recipientResp.EnsureSuccessStatusCode();
        var recipientResult = await recipientResp.Content.ReadFromJsonAsync<UserRegistrationResult>();
        Assert.NotNull(recipientResult);
        Assert.True(recipientResult!.Success);
        var recipientId = recipientResult.UserId;
        Assert.False(string.IsNullOrEmpty(recipientId));

        // Send meetup request
        var meetupRequest = new { SenderId = senderId, RecipientId = recipientId, Message = "Let's meet!" };
        var meetupResp = await _client.PostAsJsonAsync("/api/meetups/request", meetupRequest);
        meetupResp.EnsureSuccessStatusCode();
        var meetupResult = await meetupResp.Content.ReadFromJsonAsync<MeetupRequestResult>();
        Assert.NotNull(meetupResult);
        Assert.True(meetupResult.Success);
        var meetupId = meetupResult.MeetupId;
        Assert.False(string.IsNullOrEmpty(meetupId));

        // Schedule time and venue
        var schedulePayload = new { MeetupId = meetupId, ScheduledTime = DateTime.UtcNow.AddDays(1), Venue = "Central Park" };
        var scheduleResp = await _client.PostAsJsonAsync("/api/meetups/schedule", schedulePayload);
        scheduleResp.EnsureSuccessStatusCode();
        var scheduleResult = await scheduleResp.Content.ReadFromJsonAsync<ScheduleMeetupResult>();
        Assert.NotNull(scheduleResult);
        Assert.True(scheduleResult.Success);
    }

    public class UserRegistrationResult
    {
        public bool Success { get; set; }
        public string UserId { get; set; } = string.Empty;
    }
    public class MeetupRequestResult
    {
        public bool Success { get; set; }
        public string MeetupId { get; set; } = string.Empty;
    }
    public class ScheduleMeetupResult
    {
        public bool Success { get; set; }
    }
}
