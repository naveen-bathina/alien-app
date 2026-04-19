// Infrastructure layer: User repository interface and stub implementation
using AlienApp.Domain.Entities;

namespace AlienApp.Infrastructure.Repositories
{
    public interface IUserRepository
    {
        Task<User?> GetByIdAsync(Guid id);
        Task<User?> GetByEmailAsync(string email);
        Task AddAsync(User user);
        Task UpdateAsync(User user);
    }

    // Stub implementation for demonstration
    public class InMemoryUserRepository : IUserRepository
    {
        private readonly List<User> _users = new();
        public Task<User?> GetByIdAsync(Guid id) => Task.FromResult(_users.FirstOrDefault(u => u.Id == id));
        public Task<User?> GetByEmailAsync(string email) => Task.FromResult(_users.FirstOrDefault(u => u.Email == email));
        public Task AddAsync(User user) { _users.Add(user); return Task.CompletedTask; }
        public Task UpdateAsync(User user)
        {
            var idx = _users.FindIndex(u => u.Id == user.Id);
            if (idx >= 0)
            {
                _users[idx] = user;
            }
            return Task.CompletedTask;
        }
    }
}
