package com.futureprime.finance.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.identity.entity.BusinessEntity;
import com.futureprime.inventory.entity.InterCompanyTransfer;
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
@Table(name = "inter_company_invoice")
@Getter
@Setter
public class InterCompanyInvoice extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "from_entity_id", nullable = false)
    private BusinessEntity fromEntity;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "to_entity_id", nullable = false)
    private BusinessEntity toEntity;

    private String invoiceNumber;

    private LocalDate invoiceDate;

    @Column(precision = 15, scale = 2)
    private BigDecimal amount;

    @Column(nullable = false)
    private String status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inter_company_transfer_id", nullable = false)
    private InterCompanyTransfer interCompanyTransfer;
}
