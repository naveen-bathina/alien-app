using AlienApp.Application.Notifications;
using AlienApp.Domain.Entities;
using AlienApp.Infrastructure.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace AlienApp.Api.Controllers
{
    /// <summary>
    /// Handles meetup request creation and related notifications.
    /// </summary>
    [ApiController]
    [Route("api/meetups")]
    public class MeetupsController : ControllerBase
    {
        private readonly INotificationService _notificationService;
        private readonly IMeetupRepository _meetupRepository;
        public MeetupsController(INotificationService notificationService, IMeetupRepository meetupRepository)
        {
            _notificationService = notificationService;
            _meetupRepository = meetupRepository;
        }

        /// <summary>
        /// Sends a meetup request and notifies the recipient.
        /// </summary>
        /// <param name="dto">Meetup request details (SenderId, RecipientId, Message).</param>
        /// <returns>Success if notification is sent.</returns>
        [HttpPost("request")]
        public async Task<IActionResult> RequestMeetup([FromBody] MeetupRequestDto dto)
        {
            // In a real app, would validate sender/recipient, check auth, etc. 
            var meetup = new Meetup
            {
                Id = Guid.NewGuid(),
                SenderId = Guid.Parse(dto.SenderId),
                RecipientId = Guid.Parse(dto.RecipientId),
                Message = dto.Message,
                CreatedAt = DateTime.UtcNow,
                Status = "Pending"
            };
            await _meetupRepository.AddAsync(meetup);
            await _notificationService.NotifyMeetupRequestAsync(Guid.Parse(dto.RecipientId), dto.SenderId, dto.Message);
            return Ok(new { Success = true, MeetupId = meetup.Id });
        }

        /// <summary>
        /// Schedule a time and venue for a meetup.
        /// </summary>
        [HttpPost("schedule")]
        public async Task<IActionResult> ScheduleMeetup([FromBody] ScheduleMeetupDto dto)
        {
            var meetup = await _meetupRepository.GetByIdAsync(Guid.Parse(dto.MeetupId));
            if (meetup == null)
                return NotFound(new { Error = "Meetup not found" });
            meetup.ScheduledTime = dto.ScheduledTime;
            meetup.Venue = dto.Venue;
            meetup.Status = "Scheduled";
            await _meetupRepository.UpdateAsync(meetup);
            return Ok(new { Success = true });
        }

        /// <summary>
        /// Accept or reject a meetup request.
        /// </summary>
        [HttpPost("respond")]
        public async Task<IActionResult> RespondToMeetup([FromBody] RespondMeetupDto dto)
        {
            var meetup = await _meetupRepository.GetByIdAsync(Guid.Parse(dto.RequestId));
            if (meetup == null)
                return NotFound(new { Error = "Meetup not found" });
            if (meetup.Status != "Pending")
                return BadRequest(new { Error = "Meetup already responded to" });
            if (dto.Action == "accept")
            {
                meetup.Status = "Accepted";
                // Optionally: set scheduled time/venue here if provided        
            }
            else if (dto.Action == "reject")
            {
                meetup.Status = "Rejected";
            }
            else
            {
                return BadRequest(new { Error = "Invalid action" });
            }
            await _meetupRepository.UpdateAsync(meetup);
            // Notify sender
            var notificationType = dto.Action == "accept" ? "MeetupAccepted" : "MeetupRejected";
            var message = dto.Action == "accept" ? "Your meetup request was accepted." : "Your meetup request was rejected.";
            await _notificationService.NotifyMeetupRequestAsync(meetup.SenderId, meetup.RecipientId.ToString(), message);
            return Ok(new { Success = true });
        }
    }

    /// <summary>
    /// DTO for sending a meetup request.
    /// </summary>
    public class MeetupRequestDto
    {
        /// <summary>Sender's user ID.</summary>
        public string SenderId { get; set; } = string.Empty;
        /// <summary>Recipient's user ID.</summary>
        public string RecipientId { get; set; } = string.Empty;
        /// <summary>Message to send with the request.</summary>
        public string Message { get; set; } = string.Empty;
    }

    public class ScheduleMeetupDto
    {
        public string MeetupId { get; set; } = string.Empty;
        public DateTime ScheduledTime { get; set; }
        public string Venue { get; set; } = string.Empty;
    }

    public class RespondMeetupDto
    {
        public string RequestId { get; set; } = string.Empty;
        public string Action { get; set; } = string.Empty; // "accept" or "reject"
    }
}
