package com.futureprime.finance.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.identity.entity.AppUser;
import com.futureprime.identity.entity.BusinessEntity;
import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "tally_export_log")
@Getter
@Setter
public class TallyExportLog extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "business_entity_id", nullable = false)
    private BusinessEntity businessEntity;

    private String exportType;

    private LocalDate fromDate;

    private LocalDate toDate;

    private LocalDateTime exportedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exported_by", nullable = false)
    private AppUser exportedBy;

    @Column(name = "file_s3_key")
    private String fileS3Key;

    private Integer recordCount;
}
