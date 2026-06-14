package com.futureprime.service.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.service.entity.EquipmentUnit;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "free_service_entitlement")
@Getter
@Setter
public class FreeServiceEntitlement extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "equipment_unit_id", nullable = false)
    private EquipmentUnit equipmentUnit;

    private Integer totalFreeServices;

    private Integer usedFreeServices;

    private Integer remainingFreeServices;
}
