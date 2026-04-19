// Domain layer: Meetup entity for scheduling meetups
namespace AlienApp.Domain.Entities
{
    public class Meetup
    {
        public Guid Id { get; set; }
        public Guid SenderId { get; set; }
        public Guid RecipientId { get; set; }
        public string Message { get; set; } = string.Empty;
        public DateTime? ScheduledTime { get; set; } // New: scheduled time
        public string? Venue { get; set; } // New: venue
        public string Status { get; set; } = "Pending"; // e.g., Pending, Accepted, Rejected, Cancelled
        public DateTime CreatedAt { get; set; }
    }
}