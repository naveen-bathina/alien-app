using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using Xunit;
using Microsoft.AspNetCore.Mvc.Testing;

namespace AlienApp.Tests
{
    public class MeetupNotificationTests : IClassFixture<WebApplicationFactory<Program>>
    {
        private readonly HttpClient _client;
        public MeetupNotificationTests(WebApplicationFactory<Program> factory)  
        {
            _client = factory.CreateClient();
        }

        [Fact]
        public async Task AcceptingOrRejectingMeetupRequest_NotifiesSenderOfOutcome()
        {
            // Register sender
            var sender = new { Email = "sender2@example.com", Password = "SenderPass123!", DisplayName = "Sender2", Age = 30 };
            var senderResp = await _client.PostAsJsonAsync("/api/users/register", sender);
            senderResp.EnsureSuccessStatusCode();
            var senderResult = await senderResp.Content.ReadFromJsonAsync<UserRegistrationResult>();
            Assert.NotNull(senderResult);
            Assert.True(senderResult!.Success);
            var senderId = senderResult.UserId;
            Assert.False(string.IsNullOrEmpty(senderId));

            // Register recipient
            var recipient = new { Email = "recipient2@example.com", Password = "RecipientPass123!", DisplayName = "Recipient2", Age = 28 };
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
            Assert.True(meetupResp.IsSuccessStatusCode);
            var meetupResult = await meetupResp.Content.ReadFromJsonAsync<MeetupRequestResult>();
            Assert.NotNull(meetupResult);
            var meetupId = meetupResult.MeetupId;

            // Recipient accepts the request
            var acceptPayload = new { RequestId = meetupId, Action = "accept" };
            var acceptResp = await _client.PostAsJsonAsync("/api/meetups/respond", acceptPayload);
            Assert.True(acceptResp.IsSuccessStatusCode);

            // Check notifications for sender
            var notifResp = await _client.GetAsync($"/api/notifications/{senderId}");
            Assert.True(notifResp.IsSuccessStatusCode);
            var notifications = await notifResp.Content.ReadFromJsonAsync<NotificationResult[]>();
            Assert.Contains(notifications, n => n.Type == "MeetupAccepted" || n.Message.Contains("accepted"));

            // Repeat for rejection
            // Need a new request because the first one is no longer Pending
            var meetupRequest2 = new { SenderId = senderId, RecipientId = recipientId, Message = "Let's try again!" };
            var meetupResp2 = await _client.PostAsJsonAsync("/api/meetups/request", meetupRequest2);
            var meetupResult2 = await meetupResp2.Content.ReadFromJsonAsync<MeetupRequestResult>();
            var meetupId2 = meetupResult2!.MeetupId;

            var rejectPayload = new { RequestId = meetupId2, Action = "reject" };
            var rejectResp = await _client.PostAsJsonAsync("/api/meetups/respond", rejectPayload);
            Assert.True(rejectResp.IsSuccessStatusCode);
            var notifResp2 = await _client.GetAsync($"/api/notifications/{senderId}");
            Assert.True(notifResp2.IsSuccessStatusCode);
            var notifications2 = await notifResp2.Content.ReadFromJsonAsync<NotificationResult[]>();
            Assert.Contains(notifications2, n => n.Type == "MeetupRejected" || n.Message.Contains("rejected"));
        }
        
        [Fact]
        public async Task SendingMeetupRequest_CreatesNotificationForRecipient()
        {
            // Register sender
            var sender = new { Email = "sender@example.com", Password = "SenderPass123!", DisplayName = "Sender", Age = 30 };
            var senderResp = await _client.PostAsJsonAsync("/api/users/register", sender);
            senderResp.EnsureSuccessStatusCode();
            var senderResult = await senderResp.Content.ReadFromJsonAsync<UserRegistrationResult>();
            Assert.NotNull(senderResult);
            Assert.True(senderResult!.Success);
            var senderId = senderResult.UserId;
            Assert.False(string.IsNullOrEmpty(senderId));

            // Register recipient
            var recipient = new { Email = "recipient@example.com", Password = "RecipientPass123!", DisplayName = "Recipient", Age = 28 };
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
            Assert.True(meetupResp.IsSuccessStatusCode);

            // Check notifications for recipient
            var notifResp = await _client.GetAsync($"/api/notifications/{recipientId}");
            Assert.True(notifResp.IsSuccessStatusCode);
            var notifications = await notifResp.Content.ReadFromJsonAsync<NotificationResult[]>();
            Assert.Contains(notifications, n => (n.Type == "MeetupRequest" || n.Message.Contains("MeetupRequest")) && n.SenderId == senderId);
        }

        private class UserRegistrationResult
        {
            public bool Success { get; set; }
            public string? UserId { get; set; }
        }
        private class MeetupRequestResult
        {
            public bool Success { get; set; }
            public string MeetupId { get; set; } = string.Empty;
        }
        private class NotificationResult
        {
            public string Type { get; set; } = string.Empty;
            public string SenderId { get; set; } = string.Empty;
            public string Message { get; set; } = string.Empty;
        }
    }
}
