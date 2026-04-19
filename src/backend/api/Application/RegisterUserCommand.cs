// Application layer: CQRS command and handler for registering a new user
using AlienApp.Domain.Entities;
using AlienApp.Infrastructure.Repositories;
using AlienApp.Application.Abstractions;

namespace AlienApp.Application.Users
{
    public class RegisterUserCommand : ICommand<Guid>
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string DisplayName { get; set; } = string.Empty;
        public int Age { get; set; }
    }

    public class RegisterUserHandler : ICommandHandler<RegisterUserCommand, Guid>
    {
        private readonly IUserRepository _userRepository;
        public RegisterUserHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }
        public async Task<Guid> Handle(RegisterUserCommand command, CancellationToken cancellationToken)
        {
            var existing = await _userRepository.GetByEmailAsync(command.Email);
            if (existing != null) throw new InvalidOperationException("User exists");

            // Simple password hash for demonstration (do not use in production)
            string passwordHash = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(command.Password));

            var user = new User
            {
                Id = Guid.NewGuid(),
                Email = command.Email,
                UserName = command.DisplayName,
                PasswordHash = passwordHash,
                IsActive = true
            };
            await _userRepository.AddAsync(user);
            return user.Id;
        }
    }
}
