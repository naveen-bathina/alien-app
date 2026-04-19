// Domain layer: Contains core business logic, entities, and value objects
// Example entity for demonstration

namespace AlienApp.Domain.Entities
{
    public class User
    {
        public Guid Id { get; set; }
        public string? UserName { get; set; }
        public string? Email { get; set; }
        public string? PasswordHash { get; set; }
        public bool IsActive { get; set; }
    }
}
