# Backend Architecture: Alien App

## Overview

The backend for Alien App is designed using Clean Architecture and the CQRS (Command Query Responsibility Segregation) pattern. This ensures separation of concerns, testability, and scalability for future features.

## Layered Structure

- **Domain**: Core business logic and entities (e.g., `User`).
- **Application**: CQRS commands, queries, and handlers (e.g., `RegisterUserCommand`, `UpdateUserProfileCommand`).
- **Infrastructure**: Data access and repository implementations (e.g., `InMemoryUserRepository`).
- **Presentation**: API controllers (e.g., `UsersController`).

```
/Domain
    User.cs
/Application
    RegisterUserCommand.cs
    UpdateUserProfileCommand.cs
    ...
/Infrastructure
    UserRepository.cs
/Controllers
    UsersController.cs
```

## CQRS Pattern

- **Commands**: Write operations (e.g., register, update, deactivate user)
- **Queries**: Read operations (e.g., get user by email)
- **Handlers**: Each command/query has a handler implementing the business logic

## Dependency Injection

All handlers and repositories are registered with the DI container in `Program.cs` for loose coupling and testability.

## Example Flow: User Registration

1. API receives a POST `/api/users/register` request.
2. `UsersController` maps the request to a `RegisterUserCommand`.
3. `RegisterUserHandler` processes the command, checks for duplicates, hashes the password, and stores the user via `IUserRepository`.
4. The result (success or error) is returned to the client.

## Testing

- xUnit tests cover registration, profile update, deactivation, and password security.
- Tests use the in-memory repository for isolation and speed.

## Extensibility

- New features (e.g., interests, location, requests) should be added as new commands/queries and handlers in the Application layer, with corresponding changes in Domain, Infrastructure, and Presentation as needed.

## References

- [Clean Architecture](https://8thlight.com/blog/uncle-bob/2012/08/13/the-clean-architecture.html)
- [CQRS Pattern](https://martinfowler.com/bliki/CQRS.html)
