package com.futureprime.inventory.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.finance.entity.InterCompanyInvoice;
import com.futureprime.identity.entity.BusinessEntity;
import com.futureprime.master.entity.Product;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "inter_company_transfer")
@Getter
@Setter
public class InterCompanyTransfer extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "from_entity_id", nullable = false)
    private BusinessEntity fromEntity;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "to_entity_id", nullable = false)
    private BusinessEntity toEntity;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(precision = 10, scale = 2, nullable = false)
    private BigDecimal quantity;

    @Column(precision = 15, scale = 2)
    private BigDecimal transferPrice;

    private LocalDate transferDate;

    @Column(nullable = false)
    private String status;

    private UUID fromStockMovementId;

    private UUID toStockMovementId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inter_company_invoice_id", nullable = true)
    private InterCompanyInvoice interCompanyInvoice;

    @Column(columnDefinition = "TEXT")
    private String notes;
}
