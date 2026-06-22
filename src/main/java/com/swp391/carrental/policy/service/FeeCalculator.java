package com.swp391.carrental.policy.service;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import com.swp391.carrental.vehicle.model.Car;

/*
 * Name: FeeCalculator
 * @Author: BacBXHE186736
 * Date: 21/06/2026
 * Version: 2.0
 * Description: Handles business logic and operations for FeeCalculator with multi-mode pricing, delivery and KM limits.
 */

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
            if (hoursLate < 1) {
                hoursLate = 1;
            }
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
     * Calculate extra kilometer fee with a custom rate.
     */
    public BigDecimal calculateExtraKmFeeWithRate(int startMileage, int endMileage, int kmLimit, BigDecimal extraKmRate) {
        int actualKm = endMileage - startMileage;
        if (actualKm > kmLimit) {
            int extraKm = actualKm - kmLimit;
            BigDecimal rate = extraKmRate != null ? extraKmRate : new BigDecimal("4000");
            return rate.multiply(BigDecimal.valueOf(extraKm));
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

    /**
     * Calculate base rental amount depending on the mode.
     */
    public BigDecimal calculateBaseAmount(Car car, String rentalMode, String pricingPackage, long days) {
        BigDecimal dailyRate = car.getDailyRate();
        if ("TRIP".equalsIgnoreCase(rentalMode)) {
            String markupPercentStr = policyService.getPolicyValue("TRIP_RATE_MULTIPLIER_PERCENT", "20");
            double markupMultiplier = 1.0 + (Double.parseDouble(markupPercentStr) / 100.0);
            return dailyRate.multiply(BigDecimal.valueOf(markupMultiplier));
        } else if ("COMBO".equalsIgnoreCase(rentalMode)) {
            if ("COMBO_10_DAYS".equalsIgnoreCase(pricingPackage)) {
                String discountPercentStr = policyService.getPolicyValue("COMBO_10_DISCOUNT_PERCENT", "20");
                double discountMultiplier = 1.0 - (Double.parseDouble(discountPercentStr) / 100.0);
                return dailyRate.multiply(BigDecimal.valueOf(10)).multiply(BigDecimal.valueOf(discountMultiplier));
            } else if ("COMBO_7_DAYS".equalsIgnoreCase(pricingPackage)) {
                String discountPercentStr = policyService.getPolicyValue("COMBO_7_DISCOUNT_PERCENT", "15");
                double discountMultiplier = 1.0 - (Double.parseDouble(discountPercentStr) / 100.0);
                return dailyRate.multiply(BigDecimal.valueOf(7)).multiply(BigDecimal.valueOf(discountMultiplier));
            } else if ("COMBO_30_DAYS".equalsIgnoreCase(pricingPackage)) {
                String discountPercentStr = policyService.getPolicyValue("COMBO_30_DISCOUNT_PERCENT", "30");
                double discountMultiplier = 1.0 - (Double.parseDouble(discountPercentStr) / 100.0);
                return dailyRate.multiply(BigDecimal.valueOf(30)).multiply(BigDecimal.valueOf(discountMultiplier));
            }
        }
        return dailyRate.multiply(BigDecimal.valueOf(days));
    }

    /**
     * Calculate tiered discount for daily rental based on duration.
     */
    public BigDecimal calculateTierDiscount(BigDecimal baseAmount, String rentalMode, long days) {
        if (!"DAILY".equalsIgnoreCase(rentalMode)) {
            return BigDecimal.ZERO;
        }
        double discountRate = 0.0;
        if (days >= 30) {
            String val = policyService.getPolicyValue("DISCOUNT_LONG_TIER", "20");
            discountRate = Double.parseDouble(val) / 100.0;
        } else if (days >= 10) {
            String val = policyService.getPolicyValue("DISCOUNT_MEDIUM_TIER", "10");
            discountRate = Double.parseDouble(val) / 100.0;
        } else if (days >= 5) {
            String val = policyService.getPolicyValue("DISCOUNT_SHORT_TIER", "5");
            discountRate = Double.parseDouble(val) / 100.0;
        }
        return baseAmount.multiply(BigDecimal.valueOf(discountRate));
    }

    /**
     * Calculate low mileage discount (5% of base price if estimated km < 50% of the limit).
     */
    public BigDecimal calculateLowMileageDiscount(BigDecimal baseAmount, int estimatedKm, int kmLimit) {
        if (kmLimit > 0 && estimatedKm > 0 && estimatedKm < (kmLimit / 2.0)) {
            String val = policyService.getPolicyValue("LOW_MILEAGE_DISCOUNT_PERCENT", "5");
            double discountRate = Double.parseDouble(val) / 100.0;
            return baseAmount.multiply(BigDecimal.valueOf(discountRate));
        }
        return BigDecimal.ZERO;
    }

    /**
     * Calculate delivery fee (15,000 VND / km).
     */
    public BigDecimal calculateDeliveryFee(String deliveryMethod, BigDecimal distance) {
        if ("DELIVERY".equalsIgnoreCase(deliveryMethod) && distance != null) {
            String val = policyService.getPolicyValue("DELIVERY_FEE_PER_KM", "15000");
            BigDecimal feePerKm = new BigDecimal(val);
            return distance.multiply(feePerKm);
        }
        return BigDecimal.ZERO;
    }

    /**
     * Calculate allowed KM limit for the booking.
     */
    public int calculateKmLimit(String rentalMode, String pricingPackage, long days) {
        if ("TRIP".equalsIgnoreCase(rentalMode)) {
            String val = policyService.getPolicyValue("TRIP_KM_LIMIT", "150");
            return Integer.parseInt(val);
        } else if ("COMBO".equalsIgnoreCase(rentalMode)) {
            if ("COMBO_10_DAYS".equalsIgnoreCase(pricingPackage)) {
                String val = policyService.getPolicyValue("COMBO_10_KM_LIMIT", "2000");
                return Integer.parseInt(val);
            } else if ("COMBO_7_DAYS".equalsIgnoreCase(pricingPackage)) {
                String val = policyService.getPolicyValue("COMBO_7_KM_LIMIT", "1500");
                return Integer.parseInt(val);
            } else if ("COMBO_30_DAYS".equalsIgnoreCase(pricingPackage)) {
                String val = policyService.getPolicyValue("COMBO_30_KM_LIMIT", "5000");
                return Integer.parseInt(val);
            }
        }
        String val = policyService.getPolicyValue("KM_LIMIT_PER_DAY", "250");
        return (int) (Integer.parseInt(val) * days);
    }

    /**
     * Get the surcharge rate per extra KM.
     */
    public BigDecimal calculateExtraKmRate(Car car, String pricingPackage) {
        String val = policyService.getPolicyValue("EXTRA_KM_FEE", "4000");
        return new BigDecimal(val);
    }

    /**
     * Estimate excess KM fee during booking creation.
     */
    public BigDecimal calculateEstimatedExtraKmFee(Car car, String pricingPackage, int estimatedKm, int kmLimit) {
        if (estimatedKm > kmLimit) {
            int extraKm = estimatedKm - kmLimit;
            BigDecimal rate = calculateExtraKmRate(car, pricingPackage);
            return rate.multiply(BigDecimal.valueOf(extraKm));
        }
        return BigDecimal.ZERO;
    }

    /**
     * Calculate Lunar New Year surcharge based on overlapping days.
     */
    public BigDecimal calculateTetSurcharge(Car car, java.time.LocalDateTime startDate, java.time.LocalDateTime endDate) {
        String startStr = policyService.getPolicyValue("TET_START_DATE", "2026-02-12");
        String endStr = policyService.getPolicyValue("TET_END_DATE", "2026-02-22");
        String surchargePctStr = policyService.getPolicyValue("TET_SURCHARGE_PERCENT", "20");
        
        try {
            java.time.LocalDate tetStart = java.time.LocalDate.parse(startStr);
            java.time.LocalDate tetEnd = java.time.LocalDate.parse(endStr);
            double surchargePct = Double.parseDouble(surchargePctStr) / 100.0;
            
            java.time.LocalDate rentStart = startDate.toLocalDate();
            long rentalDays = java.time.temporal.ChronoUnit.DAYS.between(startDate.toLocalDate(), endDate.toLocalDate());
            if (rentalDays < 1) {
                rentalDays = 1;
            }
            
            long overlapDays = 0;
            for (int i = 0; i < rentalDays; i++) {
                java.time.LocalDate current = rentStart.plusDays(i);
                if (!current.isBefore(tetStart) && !current.isAfter(tetEnd)) {
                    overlapDays++;
                }
            }
            
            if (overlapDays > 0) {
                BigDecimal dailyRate = car.getDailyRate();
                return dailyRate.multiply(BigDecimal.valueOf(overlapDays)).multiply(BigDecimal.valueOf(surchargePct));
            }
        } catch (Exception e) {
            // fallback
        }
        return BigDecimal.ZERO;
    }
}

