package com.swp391.carrental.payment.constant;

/*
 * Name: PaymentType
 * @Author: TungNLHE186756
 * Created: 23/05/2026 
 * Description: Holds constants representing the types of payment transactions in the system.
 * Version History:
 * - v1.0 (23/05/2026): Initial version.
 * - v1.1 (23/05/2026): refactor: apply project rules for controller packages and...
 * - v1.2 (19/06/2026): Refactor codebase to hybrid package-by-feature layout wit...
 * - v1.3 (23/07/2026): Added Javadoc and method comments.
 */

/**
 * Payment type values.
 */
public class PaymentType {
    public static final String DEPOSIT        = "DEPOSIT";
    public static final String RENTAL         = "RENTAL";
    public static final String ADDITIONAL_FEE = "ADDITIONAL_FEE";
    public static final String REFUND         = "REFUND";

    private PaymentType() {
    }
}
