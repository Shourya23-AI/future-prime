package com.futureprime.inventory.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.identity.entity.BusinessEntity;
import com.futureprime.inventory.entity.RackLocation;
import com.futureprime.master.entity.Product;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "stock_item")
@Getter
@Setter
public class StockItem extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_entity_id", nullable = false)
    private BusinessEntity businessEntity;

    private UUID warehouseId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rack_location_id", nullable = true)
    private RackLocation rackLocation;

    @Column(precision = 10, scale = 2)
    private BigDecimal quantityOnHand;

    @Column(precision = 10, scale = 2)
    private BigDecimal quantityReserved;

    @Column(precision = 10, scale = 2)
    private BigDecimal quantityAvailable;

    @Column(precision = 15, scale = 2)
    private BigDecimal averageLandedCost;

    private LocalDateTime lastMovementAt;
}
