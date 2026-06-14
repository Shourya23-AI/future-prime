package com.futureprime.master.entity;

import com.futureprime.core.entity.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "spare_part_mapping")
@Getter
@Setter
public class SparePartMapping extends BaseEntity {

    private UUID equipmentProductId;

    private UUID sparePartProductId;

    @Column(nullable = false)
    private Boolean isCritical = false;

    @Column(precision = 10, scale = 2)
    private BigDecimal minStockQuantity;
}
