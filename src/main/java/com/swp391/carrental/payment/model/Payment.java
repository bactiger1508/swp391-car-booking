package com.swp391.carrental.payment.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/*
 * Name: Payment
 * @Author: TungNLHE186756
 * Created: 23/05/2026 
 * Description: Model representing a payment transaction record in the database.
 * Version History:
 * - v1.0 (23/05/2026): Initial version.
 * - v1.1 (23/05/2026): refactor: apply project rules for controller packages and...
 * - v1.2 (19/06/2026): Refactor codebase to hybrid package-by-feature layout wit...
 * - v1.3 (16/07/2026): feat: implement automated VietQR payment processing syste...
 * - v1.4 (23/07/2026): Added Javadoc and method comments.
 */


/**
 * Represents a payment record.
 * Maps to the 'payments' table.
 */
public class Payment {

    private int paymentId;
    private int bookingId;
    private Integer contractId;
    private BigDecimal amount;
    private BigDecimal amountPaid; // actual amount received — may differ from amount (overpayment)
    private String paymentType;
    private String paymentMethod;
    private String status;
    private String transactionRef;
    private String notes;
    private LocalDateTime paidAt;
    private Integer recordedBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Payment() {
    }

    // --- Getters and Setters ---

    public int getPaymentId() { return paymentId; }
    public void setPaymentId(int paymentId) { this.paymentId = paymentId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public Integer getContractId() { return contractId; }
    public void setContractId(Integer contractId) { this.contractId = contractId; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public BigDecimal getAmountPaid() { return amountPaid; }
    public void setAmountPaid(BigDecimal amountPaid) { this.amountPaid = amountPaid; }

    public String getPaymentType() { return paymentType; }
    public void setPaymentType(String paymentType) { this.paymentType = paymentType; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getTransactionRef() { return transactionRef; }
    public void setTransactionRef(String transactionRef) { this.transactionRef = transactionRef; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }

    public Integer getRecordedBy() { return recordedBy; }
    public void setRecordedBy(Integer recordedBy) { this.recordedBy = recordedBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
