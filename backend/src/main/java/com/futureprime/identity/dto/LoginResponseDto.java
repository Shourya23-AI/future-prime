package com.futureprime.identity.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
public class LoginResponseDto {

    String accessToken;
    String refreshToken;
    long expiresIn;
    UserInfo user;

    @Getter
    @Setter
    public static class UserInfo{
        UUID id;
        String fullName;
        String email;
        String role;
        UUID activeEntityId;
        List<EntityInfo> accessibleEntities;
    }

    @Getter
    @Setter
    public static class EntityInfo{
        UUID id;
        String name;
        String shortCode;

    }
}
