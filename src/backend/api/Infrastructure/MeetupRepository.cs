// Infrastructure layer: Meetup repository interface and stub implementation
using AlienApp.Domain.Entities;

namespace AlienApp.Infrastructure.Repositories
{
    public interface IMeetupRepository
    {
        Task<Meetup?> GetByIdAsync(Guid id);
        Task AddAsync(Meetup meetup);
        Task UpdateAsync(Meetup meetup);
        Task<IEnumerable<Meetup>> GetByUserIdAsync(Guid userId);
    }

    // Stub implementation for demonstration
    public class InMemoryMeetupRepository : IMeetupRepository
    {
        private readonly List<Meetup> _meetups = new();
        public Task<Meetup?> GetByIdAsync(Guid id) => Task.FromResult(_meetups.FirstOrDefault(m => m.Id == id));
        public Task AddAsync(Meetup meetup) { _meetups.Add(meetup); return Task.CompletedTask; }
        public Task UpdateAsync(Meetup meetup)
        {
            var idx = _meetups.FindIndex(m => m.Id == meetup.Id);
            if (idx >= 0)
            {
                _meetups[idx] = meetup;
            }
            return Task.CompletedTask;
        }
        public Task<IEnumerable<Meetup>> GetByUserIdAsync(Guid userId) => Task.FromResult(_meetups.Where(m => m.SenderId == userId || m.RecipientId == userId).AsEnumerable());
    }
}