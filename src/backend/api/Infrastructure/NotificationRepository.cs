using AlienApp.Domain.Entities;

namespace AlienApp.Infrastructure.Repositories
{
    public interface INotificationRepository
    {
        Task AddAsync(Notification notification);
        Task<List<Notification>> GetByRecipientIdAsync(Guid recipientId);
    }

    public class InMemoryNotificationRepository : INotificationRepository
    {
        private readonly List<Notification> _notifications = new();
        public Task AddAsync(Notification notification)
        {
            _notifications.Add(notification);
            return Task.CompletedTask;
        }
        public Task<List<Notification>> GetByRecipientIdAsync(Guid recipientId)
        {
            var result = _notifications.Where(n => n.RecipientId == recipientId).ToList();
            return Task.FromResult(result);
        }
    }
}