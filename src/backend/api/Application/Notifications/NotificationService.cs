using AlienApp.Domain.Entities;
using AlienApp.Infrastructure.Repositories;

namespace AlienApp.Application.Notifications
{
    public interface INotificationService
    {
        Task NotifyMeetupRequestAsync(Guid recipientId, string senderId, string message);
        Task<List<Notification>> GetNotificationsAsync(Guid recipientId);
    }

    public class NotificationService : INotificationService
    {
        private readonly INotificationRepository _repo;
        public NotificationService(INotificationRepository repo)
        {
            _repo = repo;
        }
        public async Task NotifyMeetupRequestAsync(Guid recipientId, string senderId, string message)
        {
            var notification = new Notification
            {
                Id = Guid.NewGuid(),
                RecipientId = recipientId,
                Type = "MeetupRequest",
                SenderId = senderId,
                Message = message,
                CreatedAt = DateTime.UtcNow
            };
            await _repo.AddAsync(notification);
        }
        public Task<List<Notification>> GetNotificationsAsync(Guid recipientId)
        {
            return _repo.GetByRecipientIdAsync(recipientId);
        }
    }
}