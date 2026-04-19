using AlienApp.Application.Notifications;
using AlienApp.Domain.Entities;
using AlienApp.Infrastructure.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace AlienApp.Api.Controllers
{
    /// <summary>
    /// Handles notification retrieval for users.
    /// </summary>
    [ApiController]
    [Route("api/notifications")]
    public class NotificationsController : ControllerBase
    {
        private readonly INotificationService _notificationService;
        public NotificationsController(INotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        /// <summary>
        /// Gets all notifications for a user.
        /// </summary>
        /// <param name="userId">The recipient user's unique identifier.</param>
        /// <returns>List of notifications for the user.</returns>
        [HttpGet("{userId}")]
        public async Task<IActionResult> GetNotifications(Guid userId)
        {
            var notifications = await _notificationService.GetNotificationsAsync(userId);
            return Ok(notifications.Select(n => new
            {
                n.Type,
                n.SenderId,
                n.Message
            }));
        }
    }
}