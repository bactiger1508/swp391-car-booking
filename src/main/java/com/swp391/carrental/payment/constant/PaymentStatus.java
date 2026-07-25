package com.swp391.carrental.payment.constant;

/*
 * Name: PaymentStatus
 * @Author: TungNLHE186756
 * Created: 23/05/2026 
 * Description: Holds constants representing the lifecycle status of a payment transaction.
 * Version History:
 * - v1.0 (23/05/2026): Initial version.
 * - v1.1 (23/05/2026): refactor: apply project rules for controller packages and...
 * - v1.2 (19/06/2026): Refactor codebase to hybrid package-by-feature layout wit...
 * - v1.3 (23/07/2026): Added Javadoc and method comments.
 */

/**
 * Payment status values.
 */
public class PaymentStatus {
    public static final String PENDING   = "PENDING";
    public static final String COMPLETED = "COMPLETED";
    public static final String FAILED    = "FAILED";
    public static final String REFUNDED  = "REFUNDED";

    private PaymentStatus() {
    }
}
