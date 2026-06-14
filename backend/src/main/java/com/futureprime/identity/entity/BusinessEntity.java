package com.futureprime.identity.entity;

import com.futureprime.core.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "business_entity")
@Getter
@Setter
public class BusinessEntity extends BaseEntity {

    @Column(nullable = false)
    private String name;

    private String shortCode;

    @Column(columnDefinition = "TEXT")
    private String address;

    private String panNumber;

    private String vatNumber;

    private String phone;

    private String email;

    @Column(name = "logo_s3_key")
    private String logoS3Key;

    @Column(nullable = false)
    private Boolean isActive = true;
}
