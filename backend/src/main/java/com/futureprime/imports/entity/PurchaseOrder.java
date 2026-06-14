package com.futureprime.imports.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.identity.entity.BusinessEntity;
import com.futureprime.master.entity.Supplier;
import com.futureprime.trade.entity.SalesOrder;
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
@Table(name = "purchase_order")
@Getter
@Setter
public class PurchaseOrder extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_entity_id", nullable = false)
    private BusinessEntity businessEntity;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "supplier_id", nullable = false)
    private Supplier supplier;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sales_order_id", nullable = true)
    private SalesOrder salesOrder;

    private String poNumber;

    private LocalDate poDate;

    private String supplierCurrency;

    @Column(precision = 10, scale = 4)
    private BigDecimal exchangeRate;

    @Column(nullable = false)
    private String status;

    private String paymentTerms;

    @Column(nullable = false)
    private Boolean lcRequired = false;

    @Column(columnDefinition = "TEXT")
    private String notes;
}
