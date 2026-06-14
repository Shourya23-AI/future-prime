package com.futureprime.master.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.identity.entity.BusinessEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "customer")
@Getter
@Setter
public class Customer extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "primary_entity_id", nullable = false)
    private BusinessEntity primaryEntity;

    @Column(nullable = false)
    private String name;

    private String type;

    private String panNumber;

    private String vatNumber;

    @Column(columnDefinition = "TEXT")
    private String billingAddress;

    @Column(columnDefinition = "TEXT")
    private String shippingAddress;

    private String phone;

    private String email;

    @Column(precision = 15, scale = 2)
    private BigDecimal creditLimit;

    private Integer creditDays;

    @Column(nullable = false)
    private boolean isActive = true;
}
