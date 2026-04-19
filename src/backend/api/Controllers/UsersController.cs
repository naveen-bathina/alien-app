
using AlienApp.Application.Users;
using AlienApp.Infrastructure.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace AlienApp.Api.Controllers
{
    /// <summary>
    /// Handles user registration, profile management, and account deactivation.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly GetUserByEmailHandler _getUserByEmailHandler;
        private readonly UpdateUserProfileHandler _updateUserProfileHandler;
        private readonly DeactivateUserHandler _deactivateUserHandler;
        private readonly RegisterUserHandler _registerUserHandler;

        public UsersController(RegisterUserHandler registerUserHandler, GetUserByEmailHandler getUserByEmailHandler, UpdateUserProfileHandler updateUserProfileHandler, DeactivateUserHandler deactivateUserHandler)
        {
            _registerUserHandler = registerUserHandler;
            _getUserByEmailHandler = getUserByEmailHandler;
            _updateUserProfileHandler = updateUserProfileHandler;
            _deactivateUserHandler = deactivateUserHandler;
        }

        /// <summary>
        /// Deactivates (soft-deletes) a user account by userId.
        /// </summary>
        /// <param name="userId">The user's unique identifier.</param>
        /// <returns>Success if deactivation is performed.</returns>
        [HttpDelete("{userId}")]
        public async Task<IActionResult> Deactivate(Guid userId)
        {
            var result = await _deactivateUserHandler.Handle(new DeactivateUserCommand { UserId = userId }, default);
            if (!result) return NotFound();
            return Ok(new { Success = true });
        }

        /// <summary>
        /// Updates the display name of a user profile.
        /// </summary>
        /// <param name="command">Profile update command (UserId, DisplayName).</param>
        /// <returns>Success and updated display name if found.</returns>
        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateUserProfileCommand command)
        {
            var result = await _updateUserProfileHandler.Handle(command, default);
            if (!result) return NotFound();
            return Ok(new { Success = true, DisplayName = command.DisplayName });
        }

        /// <summary>
        /// Registers a new user account.
        /// </summary>
        /// <param name="command">Registration command (Email, Password, DisplayName, Age).</param>
        /// <returns>Success and new UserId, or error if user exists.</returns>
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterUserCommand command)
        {
            try
            {
                var userId = await _registerUserHandler.Handle(command, default);
                return Ok(new { Success = true, UserId = userId });
            }
            catch (InvalidOperationException)
            {
                return BadRequest(new { Success = false, Error = "User already exists" });
            }
        }

        /// <summary>
        /// Gets a user by email address.
        /// </summary>
        /// <param name="email">The user's email address.</param>
        /// <returns>User details if found.</returns>
        [HttpGet("by-email")]
        public async Task<IActionResult> GetByEmail([FromQuery] string email)
        {
            var user = await _getUserByEmailHandler.Handle(new GetUserByEmailQuery { Email = email }, default);
            if (user == null) return NotFound();
            return Ok(user);
        }
        /// <summary>
        /// Browse user profiles filtered by interests and location (stub).
        /// </summary>
        [HttpGet("browse")]
        public IActionResult BrowseProfiles([FromQuery] string? interest = null, [FromQuery] string? location = null)
        {
            // Simulate user data (in real app, fetch from repository)
            var users = new[]
            {
                new { Id = Guid.NewGuid(), UserName = "Alice", Location = "NYC", Interests = new[] { "music", "tech" } },
                new { Id = Guid.NewGuid(), UserName = "Bob", Location = "SF", Interests = new[] { "sports", "tech" } }
            };
            var filtered = users.AsEnumerable();
            if (!string.IsNullOrEmpty(interest))
            {
                filtered = filtered.Where(u => u.Interests != null && u.Interests.Contains(interest));
            }
            if (!string.IsNullOrEmpty(location))
            {
                filtered = filtered.Where(u => u.Location == location);
            }
            return Ok(filtered);
        }
    }
}
