package com.futureprime.imports.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.imports.entity.Shipment;
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
@Table(name = "customs_clearance")
@Getter
@Setter
public class CustomsClearance extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipment_id", nullable = false)
    private Shipment shipment;

    private String customsAgent;

    private String entryNumber;

    private LocalDate entryDate;

    @Column(precision = 15, scale = 2)
    private BigDecimal customsDuty;

    @Column(precision = 15, scale = 2)
    private BigDecimal vatOnImport;

    @Column(precision = 15, scale = 2)
    private BigDecimal otherCharges;

    @Column(precision = 15, scale = 2)
    private BigDecimal totalCustomsCost;

    private LocalDate clearanceDate;

    @Column(nullable = false)
    private String status;

    @Column(columnDefinition = "TEXT")
    private String notes;
}
