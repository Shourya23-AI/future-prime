package com.futureprime.identity.service;

import com.futureprime.identity.dto.LoginRequestDto;
import com.futureprime.identity.dto.LoginResponseDto;
import com.futureprime.identity.dto.RefreshTokenRequestDto;

public interface AuthService {

    LoginResponseDto login(LoginRequestDto request);

    LoginResponseDto refresh(RefreshTokenRequestDto request);

    void logout(String refreshToken);
}
