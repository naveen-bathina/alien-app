// Domain layer: Notification entity
namespace AlienApp.Domain.Entities
{
    public class Notification
    {
        public Guid Id { get; set; }
        public Guid RecipientId { get; set; }
        public string Type { get; set; } = string.Empty;
        public string SenderId { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }
}