package com.swp391.carrental.payment.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/*
 * Name: WebhookTransaction
 * @Author: TungNLHE186756
 * Created: 16/07/2026 
 * Description: Normalized model representing transaction data received via payment webhook.
 * Version History:
 * - v1.0 (16/07/2026): Initial version.
 * - v1.1 (23/07/2026): Added Javadoc and method comments.
 */
public class WebhookTransaction {
    private String transferDescription;
    private BigDecimal amount;
    private String transactionRef;
    private LocalDateTime paymentTime;

    public WebhookTransaction() {
    }

    public WebhookTransaction(String transferDescription, BigDecimal amount, String transactionRef, LocalDateTime paymentTime) {
        this.transferDescription = transferDescription;
        this.amount = amount;
        this.transactionRef = transactionRef;
        this.paymentTime = paymentTime;
    }

    public String getTransferDescription() {
        return transferDescription;
    }

    public void setTransferDescription(String transferDescription) {
        this.transferDescription = transferDescription;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getTransactionRef() {
        return transactionRef;
    }

    public void setTransactionRef(String transactionRef) {
        this.transactionRef = transactionRef;
    }

    public LocalDateTime getPaymentTime() {
        return paymentTime;
    }

    public void setPaymentTime(LocalDateTime paymentTime) {
        this.paymentTime = paymentTime;
    }
}
