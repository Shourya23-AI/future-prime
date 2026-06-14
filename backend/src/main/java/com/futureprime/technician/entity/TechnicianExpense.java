package com.futureprime.technician.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.identity.entity.BusinessEntity;
import com.futureprime.service.entity.ServiceJob;
import com.futureprime.technician.entity.Technician;
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
@Table(name = "technician_expense")
@Getter
@Setter
public class TechnicianExpense extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "service_job_id", nullable = false)
    private ServiceJob serviceJob;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "technician_id", nullable = false)
    private Technician technician;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_entity_id", nullable = false)
    private BusinessEntity businessEntity;

    private String expenseType;

    @Column(precision = 15, scale = 2)
    private BigDecimal amount;

    private LocalDate expenseDate;

    private String chargeTo;

    private String reference;

    @Column(columnDefinition = "TEXT")
    private String notes;
}
