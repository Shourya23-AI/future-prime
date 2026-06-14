package com.futureprime.imports.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.imports.entity.PurchaseOrderLineItem;
import com.futureprime.imports.entity.Shipment;
import com.futureprime.master.entity.Product;
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
@Table(name = "landed_cost_allocation")
@Getter
@Setter
public class LandedCostAllocation extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipment_id", nullable = false)
    private Shipment shipment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "purchase_order_line_item_id", nullable = false)
    private PurchaseOrderLineItem purchaseOrderLineItem;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(precision = 10, scale = 2, nullable = false)
    private BigDecimal quantity;

    @Column(precision = 15, scale = 2)
    private BigDecimal supplierCostNpr;

    @Column(precision = 15, scale = 2)
    private BigDecimal allocatedShipmentCost;

    @Column(precision = 15, scale = 2)
    private BigDecimal landedCostPerUnit;
}
