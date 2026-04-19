// Application layer: Example CQRS query and handler for getting user by email
using AlienApp.Domain.Entities;
using AlienApp.Infrastructure.Repositories;
using AlienApp.Application.Abstractions;

namespace AlienApp.Application.Users
{
    public class GetUserByEmailQuery : IQuery<User?>
    {
        public string Email { get; set; } = string.Empty;
    }

    public class GetUserByEmailHandler : IQueryHandler<GetUserByEmailQuery, User?>
    {
        private readonly IUserRepository _userRepository;
        public GetUserByEmailHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }
        public async Task<User?> Handle(GetUserByEmailQuery query, CancellationToken cancellationToken)
        {
            return await _userRepository.GetByEmailAsync(query.Email);
        }
    }
}
