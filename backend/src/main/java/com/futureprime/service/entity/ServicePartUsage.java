package com.futureprime.service.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.master.entity.Product;
import com.futureprime.service.entity.ServiceVisit;
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
@Table(name = "service_part_usage")
@Getter
@Setter
public class ServicePartUsage extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "service_visit_id", nullable = false)
    private ServiceVisit serviceVisit;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(precision = 10, scale = 2, nullable = false)
    private BigDecimal quantity;

    @Column(precision = 15, scale = 2)
    private BigDecimal unitCost;

    @Column(nullable = false)
    private boolean isBillable = true;

    private String chargeTo;
}
