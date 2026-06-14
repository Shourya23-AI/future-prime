package com.futureprime.master.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.identity.entity.BusinessEntity;
import com.futureprime.master.entity.Customer;
import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.util.UUID;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "customer_entity")
@Getter
@Setter
public class CustomerEntity {

    @EmbeddedId
    private Id id = new Id();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("customerId")
    @JoinColumn(name = "customer_id")
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("businessEntityId")
    @JoinColumn(name = "business_entity_id")
    private BusinessEntity businessEntity;

    @Embeddable
    @Getter
    @Setter
    public static class Id implements Serializable {

        @Column(name = "customer_id")
        private UUID customerId;

        @Column(name = "business_entity_id")
        private UUID businessEntityId;
    }
}
