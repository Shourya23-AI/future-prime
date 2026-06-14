package com.futureprime.technician.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.service.entity.ServiceJob;
import com.futureprime.technician.entity.Technician;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "travel_record")
@Getter
@Setter
public class TravelRecord extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "service_job_id", nullable = false)
    private ServiceJob serviceJob;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "technician_id", nullable = false)
    private Technician technician;

    private String fromLocation;

    private String toLocation;

    private LocalDate departureDate;

    private LocalDate returnDate;

    private String mode;

    private Integer nightsStay;
}
