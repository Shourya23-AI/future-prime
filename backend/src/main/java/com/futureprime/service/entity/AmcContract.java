package com.futureprime.service.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.identity.entity.BusinessEntity;
import com.futureprime.master.entity.Customer;
import com.futureprime.service.entity.EquipmentUnit;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "amc_contract")
@Getter
@Setter
public class AmcContract extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_entity_id", nullable = false)
    private BusinessEntity businessEntity;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipment_unit_id", nullable = false)
    private EquipmentUnit equipmentUnit;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    private String contractNumber;

    private LocalDate startDate;

    private LocalDate endDate;

    @Column(precision = 15, scale = 2)
    private BigDecimal amount;

    private String paymentStatus;

    private Integer visitsIncluded;

    private Integer visitsUsed;

    @Column(nullable = false)
    private String status;
}
