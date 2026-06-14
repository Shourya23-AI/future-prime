package com.futureprime.imports.entity;

import com.futureprime.core.entity.BaseEntity;
import com.futureprime.imports.entity.PurchaseOrder;
import com.futureprime.imports.entity.Shipment;
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
@Table(name = "shipment_purchase_order")
@Getter
@Setter
public class ShipmentPurchaseOrder {

    @EmbeddedId
    private Id id = new Id();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("shipmentId")
    @JoinColumn(name = "shipment_id")
    private Shipment shipment;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("purchaseOrderId")
    @JoinColumn(name = "purchase_order_id")
    private PurchaseOrder purchaseOrder;

    @Embeddable
    @Getter
    @Setter
    public static class Id implements Serializable {

        @Column(name = "shipment_id")
        private UUID shipmentId;

        @Column(name = "purchase_order_id")
        private UUID purchaseOrderId;
    }
}
