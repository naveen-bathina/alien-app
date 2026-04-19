// Application layer: CQRS command and handler for deactivating user account
using AlienApp.Domain.Entities;
using AlienApp.Infrastructure.Repositories;
using AlienApp.Application.Abstractions;

namespace AlienApp.Application.Users
{
    public class DeactivateUserCommand : ICommand<bool>
    {
        public Guid UserId { get; set; }
    }

    public class DeactivateUserHandler : ICommandHandler<DeactivateUserCommand, bool>
    {
        private readonly IUserRepository _userRepository;
        public DeactivateUserHandler(IUserRepository userRepository)
        {
            _userRepository = userRepository;
        }
        public async Task<bool> Handle(DeactivateUserCommand command, CancellationToken cancellationToken)
        {
            var user = await _userRepository.GetByIdAsync(command.UserId);
            if (user == null) return false;
            user.IsActive = false;
            await _userRepository.UpdateAsync(user);
            return true;
        }
    }
}
