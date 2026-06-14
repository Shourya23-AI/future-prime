package com.futureprime.identity.entity;

import com.futureprime.core.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "app_user")
@Getter
@Setter
public class AppUser extends BaseEntity {

    private String fullName;

    @Column(unique = true, nullable = false)
    private String email;

    private String passwordHash;

    private String phone;

    @Column(nullable = false)
    private boolean isActive = true;

    private LocalDateTime lastLoginAt;
}
