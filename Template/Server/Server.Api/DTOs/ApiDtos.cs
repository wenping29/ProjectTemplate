namespace Server.Api.DTOs;

// ---- 认证 ----
public record LoginRequest(string Username, string Password);
public record RegisterRequest(string Username, string Email, string Password, string? DisplayName, string? Phone);

// ---- 角色 ----
public record RoleDto(Guid Id, string Name, string? Description, DateTime CreatedAt);
public record RoleUpsertRequest(string Name, string? Description);

// ---- 用户 ----
public record UserDto(Guid Id, string Username, string Email, string? DisplayName, string? AvatarUrl, string? Phone, Guid RoleId, short Status);
public record UserUpsertRequest(string Username, string Email, string? DisplayName, string? AvatarUrl, string? Phone, Guid RoleId, short Status, string? Password);
public record UpdateProfileRequest(string? DisplayName, string? AvatarUrl, string? Phone);

// ---- 菜单 ----
public record MenuDto(Guid Id, Guid? ParentId, string Name, short Type, string? Path, string? Icon, string? Component, string? Permission, int Sort, short Status);
public record MenuUpsertRequest(Guid? ParentId, string Name, short Type, string? Path, string? Icon, string? Component, string? Permission, int Sort, short Status);

// ---- 功能 ----
public record PermissionDto(Guid Id, string Code, string Name, Guid? MenuId, string? Description);
public record PermissionUpsertRequest(string Code, string Name, Guid? MenuId, string? Description);

// ---- 系统配置 ----
public record SystemConfigDto(Guid Id, string ConfigKey, string? ConfigValue, string? ConfigGroup, short IsPublic, string? Description);
public record SystemConfigUpsertRequest(string ConfigKey, string? ConfigValue, string? ConfigGroup, short IsPublic, string? Description);

// ---- 角色授权 ----
public record RoleGrantRequest(List<Guid> MenuIds, List<Guid> PermissionIds);
