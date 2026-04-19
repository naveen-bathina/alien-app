// Application layer: CQRS command and handler for updating user profile
using AlienApp.Domain.Entities;
using AlienApp.Infrastructure.Repositories;
using AlienApp.Application.Abstractions;

namespace AlienApp.Application.Users
{
    public class UpdateUserProfileCommand : ICommand<bool>
    {
        public Guid UserId { get; set; }
        public string DisplayName { get; set; } = string.Empty;
    }

    public class UpdateUserProfileHandler : ICommandHandler<UpdateUserProfileCommand, bool>
    {
        private readonly IUserRepository _userRepository;
        public UpdateUserProfileHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }
        public async Task<bool> Handle(UpdateUserProfileCommand command, CancellationToken cancellationToken)
        {
            var user = await _userRepository.GetByIdAsync(command.UserId);
            if (user == null || !user.IsActive) return false;
            user.UserName = command.DisplayName;
            await _userRepository.UpdateAsync(user);
            return true;
        }
    }
}

