package com.futureprime.core.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Optional;

@Configuration
@EnableJpaAuditing(auditorAwareRef = "auditorProvider")
public class JpaConfig {

    @Bean
    public AuditorAware<String> auditorProvider() {
        return () -> {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if ( authentication == null || !authentication.isAuthenticated() ) {
                return Optional.of("system");
            }
            // Get current logged-in user's email from Spring Security context
            // Return "system" if not authenticated (e.g. during login itself)
            return Optional.of(authentication.getName());
        };
    }
}
