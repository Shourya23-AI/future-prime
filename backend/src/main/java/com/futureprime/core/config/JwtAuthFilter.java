package com.futureprime.core.config;

import com.futureprime.core.util.JwtUtil;
import com.futureprime.identity.entity.AppUser;
import com.futureprime.identity.repository.AppUserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    // inject JwtUtil and AppUserRepository via constructor
    private final JwtUtil jwtUtil;
    private final AppUserRepository appUserRepository;

    public JwtAuthFilter(JwtUtil jwtUtil, AppUserRepository appUserRepository){
        this.jwtUtil = jwtUtil;
        this.appUserRepository = appUserRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        // 1. Get Authorization header
        String authHeader = request.getHeader("Authorization");
        // 2. Check it starts with "Bearer " — if not, continue filter chain and return
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }
        // 3. Extract token (substring after "Bearer ")
        String token = authHeader.substring(7);
        // 4. Validate token using jwtUtil.validateToken(token)
        if (!jwtUtil.validateToken(token)) {
            filterChain.doFilter(request, response);
            return;
        }
        // 5. Get email from token using jwtUtil.getEmailFromToken(token)
        String email = jwtUtil.getEmailFromToken(token);
        // 6. Load user from AppUserRepository by email
        AppUser user = appUserRepository.findByEmail(email).orElse(null);
        if (null == user) {
            filterChain.doFilter(request, response);
            return;
        }
        // 7. Create UsernamePasswordAuthenticationToken with user, null, empty authorities
        UsernamePasswordAuthenticationToken authToken =
                new UsernamePasswordAuthenticationToken(user, null, List.of());
        // 8. Set details: authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request))
        authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

        // 9. Set in SecurityContext: SecurityContextHolder.getContext().setAuthentication(authToken)
        SecurityContextHolder.getContext().setAuthentication(authToken);

        // 10. Continue filter chain
        filterChain.doFilter(request, response);

    }
}
