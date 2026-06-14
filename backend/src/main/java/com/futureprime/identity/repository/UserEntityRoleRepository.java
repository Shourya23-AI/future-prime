package com.futureprime.identity.repository;

import com.futureprime.identity.entity.AppUser;
import com.futureprime.identity.entity.BusinessEntity;
import com.futureprime.identity.entity.UserEntityRole;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserEntityRoleRepository extends JpaRepository<UserEntityRole, UUID> {

    List<UserEntityRole> findByUserAndIsActive(AppUser user, boolean isActive);
    Optional<UserEntityRole> findByUserAndBusinessEntityAndIsActive(AppUser user, BusinessEntity businessEntity, boolean isActive);
}
