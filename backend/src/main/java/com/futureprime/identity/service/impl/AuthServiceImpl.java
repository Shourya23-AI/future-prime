package com.futureprime.identity.service.impl;

import com.futureprime.core.exception.BusinessException;
import com.futureprime.core.exception.ResourceNotFoundException;
import com.futureprime.core.util.JwtUtil;
import com.futureprime.identity.dto.LoginRequestDto;
import com.futureprime.identity.dto.LoginResponseDto;
import com.futureprime.identity.dto.RefreshTokenRequestDto;
import com.futureprime.identity.entity.AppUser;
import com.futureprime.identity.entity.RefreshToken;
import com.futureprime.identity.entity.UserEntityRole;
import com.futureprime.identity.repository.AppUserRepository;
import com.futureprime.identity.repository.RefreshTokenRepository;
import com.futureprime.identity.repository.UserEntityRoleRepository;
import com.futureprime.identity.service.AuthService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;


@Service
public class AuthServiceImpl implements AuthService {

    private final AppUserRepository appUserRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final UserEntityRoleRepository userEntityRoleRepository;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.jwt.refresh-expiration-ms}")
    private long refreshExpirationMs;

    @Value("${app.jwt.expiration-ms}")
    private long expirationMs;

    public AuthServiceImpl(AppUserRepository appUserRepository, RefreshTokenRepository refreshTokenRepository, UserEntityRoleRepository userEntityRoleRepository, JwtUtil jwtUtil, PasswordEncoder passwordEncoder) {
        this.appUserRepository = appUserRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.userEntityRoleRepository = userEntityRoleRepository;
        this.jwtUtil = jwtUtil;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public LoginResponseDto login(LoginRequestDto request) {
        AppUser user = appUserRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("User", null));
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new BusinessException("Invalid credentials");
        }
        if (!user.isActive()) {
            throw new BusinessException("Account is deactivated");
        }
        List<UserEntityRole> userRoles = userEntityRoleRepository.findByUserAndIsActive(user, true);
        if (null == userRoles || userRoles.isEmpty()) {
            throw new BusinessException("No entity access configured for this user");
        }
        List<UUID> accessibleEntityIds = userRoles.stream().map(uer -> uer.getBusinessEntity().getId()).toList();
        String token = jwtUtil.generateAccessToken(user, userRoles.getFirst().getBusinessEntity().getId(), accessibleEntityIds, userRoles.getFirst().getRole().getName());
        String refreshToken = jwtUtil.generateRefreshToken(user);
        RefreshToken tokenEntity = new RefreshToken();
        tokenEntity.setUser(user);
        tokenEntity.setToken(refreshToken);
        tokenEntity.setExpiresAt(LocalDateTime.now().plusSeconds(refreshExpirationMs / 1000));
        tokenEntity.setRevoked(false);
        refreshTokenRepository.save(tokenEntity);
        return loginResponseDto(user, userRoles, token, refreshToken);
    }

    @Override
    @Transactional
    public LoginResponseDto refresh(RefreshTokenRequestDto request) {
        // 1. Find RefreshToken by token string — throw BusinessException if not found
        RefreshToken refreshToken = refreshTokenRepository.findByToken(request.getRefreshToken()).orElseThrow(() -> new BusinessException("Invalid refresh token"));
        // 2. Check isRevoked — throw BusinessException if true
        if (refreshToken.isRevoked()) {
            throw new BusinessException("Refresh token has been revoked");
        }
        // 3. Check expiresAt — throw BusinessException if expired
        if (LocalDateTime.now().isAfter(refreshToken.getExpiresAt())) {
            throw new BusinessException("Refresh token has expired");
        }
        // 4. Get user from token entity
        AppUser user = refreshToken.getUser();
        // 5. Get userRoles for that user
        List<UserEntityRole> userRoles = userEntityRoleRepository.findByUserAndIsActive(user, true);
        // 6. Generate new access token
        String token = jwtUtil.generateAccessToken(user, userRoles.getFirst().getBusinessEntity().getId(), userRoles.stream().map(uer -> uer.getBusinessEntity().getId()).toList(), userRoles.getFirst().getRole().getName());
        String newRefreshToken = jwtUtil.generateRefreshToken(user);
        // 7. Build and return LoginResponseDto with new access token, same refresh token string
        return loginResponseDto(user, userRoles, token, newRefreshToken);
    }

    private LoginResponseDto loginResponseDto(AppUser user, List<UserEntityRole> userRoles, String token, String refreshToken) {
        LoginResponseDto loginResponseDto = new LoginResponseDto();
        LoginResponseDto.UserInfo userInfo = new LoginResponseDto.UserInfo();
        userInfo.setId(user.getId());
        userInfo.setRole(userRoles.getFirst().getRole().getName());
        userInfo.setEmail(user.getEmail());
        List<LoginResponseDto.EntityInfo> accessibleEntities = userRoles.stream()
                .map(uer -> {
                    LoginResponseDto.EntityInfo info = new LoginResponseDto.EntityInfo();
                    info.setId(uer.getBusinessEntity().getId());
                    info.setName(uer.getBusinessEntity().getName());
                    info.setShortCode(uer.getBusinessEntity().getShortCode());
                    return info;
                })
                .toList();
        userInfo.setAccessibleEntities(accessibleEntities);
        userInfo.setActiveEntityId(userRoles.getFirst().getBusinessEntity().getId());
        userInfo.setFullName(user.getFullName());
        loginResponseDto.setUser(userInfo);
        loginResponseDto.setAccessToken(token);
        loginResponseDto.setExpiresIn(expirationMs / 1000);
        loginResponseDto.setRefreshToken(refreshToken);
        return loginResponseDto;
    }

    @Override
    @Transactional
    public void logout(String refreshToken) {
        // Find by token string
        // If present — set revoked true, save
        refreshTokenRepository.findByToken(refreshToken).ifPresent(token -> {
            token.setRevoked(true);
            refreshTokenRepository.save(token);
        });
        // If not found — do nothing (ifPresent handles this naturally)
    }
}
