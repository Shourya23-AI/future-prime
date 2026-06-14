package com.futureprime.trade.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.master.entity.Product;
import com.futureprime.trade.entity.SalesOrder;
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
@Table(name = "sales_order_line_item")
@Getter
@Setter
public class SalesOrderLineItem extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sales_order_id", nullable = false)
    private SalesOrder salesOrder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(precision = 10, scale = 2)
    private BigDecimal quantityOrdered;

    @Column(precision = 10, scale = 2)
    private BigDecimal quantityDelivered;

    @Column(precision = 15, scale = 2)
    private BigDecimal unitPrice;

    @Column(precision = 5, scale = 2)
    private BigDecimal discountPercent;

    @Column(nullable = false)
    private Boolean vatApplicable = true;
}
