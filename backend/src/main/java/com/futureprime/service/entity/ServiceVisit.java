package com.futureprime.service.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.service.entity.ServiceJob;
import com.futureprime.technician.entity.Technician;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.time.LocalTime;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "service_visit")
@Getter
@Setter
public class ServiceVisit extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "service_job_id", nullable = false)
    private ServiceJob serviceJob;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "technician_id", nullable = false)
    private Technician technician;

    private LocalDate visitDate;

    private LocalTime timeIn;

    private LocalTime timeOut;

    @Column(columnDefinition = "TEXT")
    private String workDone;

    @Column(columnDefinition = "TEXT")
    private String partsUsed;

    @Column(nullable = false)
    private boolean followUpRequired = false;
}
