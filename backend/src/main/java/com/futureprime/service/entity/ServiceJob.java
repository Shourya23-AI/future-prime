package com.futureprime.service.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.identity.entity.BusinessEntity;
import com.futureprime.master.entity.Customer;
import com.futureprime.service.entity.AmcContract;
import com.futureprime.service.entity.EquipmentUnit;
import com.futureprime.trade.entity.Invoice;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "service_job")
@Getter
@Setter
public class ServiceJob extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_entity_id", nullable = false)
    private BusinessEntity businessEntity;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipment_unit_id", nullable = false)
    private EquipmentUnit equipmentUnit;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    private String jobNumber;

    private String jobType;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "amc_contract_id", nullable = true)
    private AmcContract amcContract;

    @Column(columnDefinition = "TEXT")
    private String reportedIssue;

    @Column(columnDefinition = "TEXT")
    private String diagnosis;

    @Column(columnDefinition = "TEXT")
    private String resolution;

    @Column(nullable = false)
    private String status;

    private LocalDate scheduledDate;

    private LocalDate completedDate;

    @Column(nullable = false)
    private boolean isBillable = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "invoice_id", nullable = true)
    private Invoice invoice;
}
