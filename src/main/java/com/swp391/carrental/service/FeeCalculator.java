package com.swp391.carrental.service;

import com.swp391.carrental.exception.AppException;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;

/**
 * Utility service for calculating rental fees.
 * BR-07: Return fee includes late fee, extra km fee, damage fee, cleaning fee, lost item fee.
 */
public class FeeCalculator {

    private final PolicyService policyService = new PolicyService();

    /**
     * Calculate late return fee.
     * Based on hours late × LATE_FEE_PER_HOUR policy.
     */
    public BigDecimal calculateLateFee(LocalDateTime expectedReturn, LocalDateTime actualReturn) {
        if (actualReturn.isAfter(expectedReturn)) {
            long hoursLate = Duration.between(expectedReturn, actualReturn).toHours();
            if (hoursLate < 1) hoursLate = 1; // Minimum 1 hour charge
            BigDecimal feePerHour = new BigDecimal(
                    policyService.getPolicyValue("LATE_FEE_PER_HOUR", "100000"));
            return feePerHour.multiply(BigDecimal.valueOf(hoursLate));
        }
        return BigDecimal.ZERO;
    }

    /**
     * Calculate extra kilometer fee.
     * Based on (actual - allowed) km × EXTRA_KM_FEE policy.
     */
    public BigDecimal calculateExtraKmFee(int startMileage, int endMileage, int rentalDays) {
        String kmLimitStr = policyService.getPolicyValue("KM_LIMIT_PER_DAY", "300");
        int kmLimit = Integer.parseInt(kmLimitStr) * rentalDays;
        int actualKm = endMileage - startMileage;

        if (actualKm > kmLimit) {
            int extraKm = actualKm - kmLimit;
            BigDecimal feePerKm = new BigDecimal(
                    policyService.getPolicyValue("EXTRA_KM_FEE", "5000"));
            return feePerKm.multiply(BigDecimal.valueOf(extraKm));
        }
        return BigDecimal.ZERO;
    }

    /**
     * Calculate deposit amount based on total rental amount.
     */
    public BigDecimal calculateDeposit(BigDecimal totalAmount) {
        String percentStr = policyService.getPolicyValue("DEPOSIT_PERCENTAGE", "30");
        BigDecimal percentage = new BigDecimal(percentStr);
        return totalAmount.multiply(percentage).divide(BigDecimal.valueOf(100));
    }

    /**
     * Calculate total additional fees.
     * BR-07: Sum of late fee, extra km fee, damage fee, cleaning fee, lost item fee.
     */
    public BigDecimal calculateAdditionalFees(BigDecimal lateFee, BigDecimal extraKmFee,
                                               BigDecimal damageFee, BigDecimal cleaningFee,
                                               BigDecimal lostItemFee) {
        return lateFee.add(extraKmFee).add(damageFee).add(cleaningFee).add(lostItemFee);
    }

    /**
     * Calculate total rental amount (days × daily rate).
     */
    public BigDecimal calculateRentalAmount(BigDecimal dailyRate, int rentalDays) {
        return dailyRate.multiply(BigDecimal.valueOf(rentalDays));
    }
}
