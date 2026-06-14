package com.futureprime.trade.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.master.entity.Product;
import com.futureprime.trade.entity.Quote;
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
@Table(name = "quote_line_item")
@Getter
@Setter
public class QuoteLineItem extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quote_id", nullable = false)
    private Quote quote;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(precision = 10, scale = 2, nullable = false)
    private BigDecimal quantity;

    @Column(precision = 15, scale = 2)
    private BigDecimal unitPrice;

    @Column(precision = 5, scale = 2)
    private BigDecimal discountPercent;

    @Column(nullable = false)
    private Boolean vatApplicable = true;

    @Column(precision = 15, scale = 2)
    private BigDecimal lineTotal;

    private Integer sortOrder;
}
