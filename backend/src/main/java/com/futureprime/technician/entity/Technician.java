package com.futureprime.technician.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.master.entity.Supplier;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "technician")
@Getter
@Setter
public class Technician extends BaseEntity {

    @Column(nullable = false)
    private String name;

    private String technicianType;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "supplier_id", nullable = true)
    private Supplier supplier;

    private String phone;

    private String email;

    private String country;

    private String specialization;

    @Column(nullable = false)
    private boolean isActive = true;
}
