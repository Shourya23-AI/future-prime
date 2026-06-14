package com.futureprime.master.entity;

import com.futureprime.core.entity.BaseEntity;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "unit_of_measure")
@Getter
@Setter
public class UnitOfMeasure extends BaseEntity {

    private String name;

    private String abbreviation;
}
