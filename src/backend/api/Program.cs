using System.Collections.Concurrent;
using AlienApp.Infrastructure.Repositories;
using AlienApp.Application.Users;

var builder = WebApplication.CreateBuilder(args);
// ...existing code...
builder.Services.AddTransient<DeactivateUserHandler>();

// Add Swagger/Swashbuckle support
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add JWT authentication
builder.Services.AddAuthentication("Bearer")
    .AddJwtBearer("Bearer", options =>
    {
        options.TokenValidationParameters = new Microsoft.IdentityModel.Tokens.TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = "alien-app",
            ValidAudience = "alien-app",
            IssuerSigningKey = new Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes("super_secret_key_1234567890_super_secret_key!"))
        };
    });

// Register notification infrastructure
builder.Services.AddSingleton<INotificationRepository, InMemoryNotificationRepository>();
builder.Services.AddTransient<AlienApp.Application.Notifications.INotificationService, AlienApp.Application.Notifications.NotificationService>();

// Add services to the container.
builder.Services.AddOpenApi();
builder.Services.AddControllers();

// Register Clean Architecture dependencies
builder.Services.AddSingleton<IUserRepository, InMemoryUserRepository>();
builder.Services.AddSingleton<IMeetupRepository, InMemoryMeetupRepository>();
builder.Services.AddTransient<RegisterUserHandler>();
builder.Services.AddTransient<GetUserByEmailHandler>();
builder.Services.AddTransient<UpdateUserProfileHandler>();

var app = builder.Build();


// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.MapOpenApi(); // keep minimal API OpenAPI if needed
}

app.UseHttpsRedirection();
app.UseAuthentication();
app.MapControllers();

// (Optional) Keep weather endpoint for demo
var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};
app.MapGet("/weatherforecast", () =>
{
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");


// ...existing code...
// ...existing code...

app.Run();

// (Optional) Keep records for weather endpoint
record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
