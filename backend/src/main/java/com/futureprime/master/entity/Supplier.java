package com.futureprime.master.entity;

import com.futureprime.core.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "supplier")
@Getter
@Setter
public class Supplier extends BaseEntity {

    @Column(nullable = false)
    private String name;

    private String country;

    @Column(nullable = false)
    private boolean isMotherCompany = false;

    private String contactPerson;

    private String phone;

    private String email;

    @Column(columnDefinition = "TEXT")
    private String address;

    private String paymentTerms;

    private String currency;

    @Column(nullable = false)
    private boolean isActive = true;
}
