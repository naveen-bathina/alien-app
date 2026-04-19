using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;

namespace AlienApp.Api.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest request)
        {
            // For demo: accept any user, return JWT with userId as claim
            if (string.IsNullOrWhiteSpace(request.Email))
                return BadRequest(new { Success = false, Error = "Email required" });
            var userId = request.UserId ?? Guid.NewGuid().ToString();
            var token = GenerateJwtToken(userId, request.Email);
            return Ok(new { Success = true, Token = token, UserId = userId });
        }

        private string GenerateJwtToken(string userId, string email)
        {
            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, userId),
                new Claim(JwtRegisteredClaimNames.Email, email)
            };
            // Key must be at least 32 chars (256 bits) for HS256
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("super_secret_key_1234567890_super_secret_key!"));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var token = new JwtSecurityToken(
                issuer: "alien-app",
                audience: "alien-app",
                claims: claims,
                expires: DateTime.UtcNow.AddHours(1),
                signingCredentials: creds);
            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }

    public class LoginRequest
    {
        public string Email { get; set; } = string.Empty;
        public string? UserId { get; set; }
    }
}
