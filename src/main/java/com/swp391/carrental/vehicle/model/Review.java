package com.swp391.carrental.vehicle.model;

import java.time.LocalDateTime;

/*
 * Name: Review
 * @Author: TamTTMHE190340
 * Date: 23/05/2026
 * Version: 1.0
 * Description: Customer review for a completed rental.
 */

public class Review {

    private int reviewId;
    private int bookingId;
    private int customerId;
    private int vehicleId;
    private int rating;
    private String comment;
    private String customerName;
    private boolean isVisible;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Review() {
    }

    public int getReviewId() { return reviewId; }
    public void setReviewId(int reviewId) { this.reviewId = reviewId; }

    public int getBookingId() { return bookingId; }
    public void setBookingId(int bookingId) { this.bookingId = bookingId; }

    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }

    public int getVehicleId() { return vehicleId; }
    public void setVehicleId(int vehicleId) { this.vehicleId = vehicleId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public boolean isVisible() { return isVisible; }
    public void setVisible(boolean visible) { isVisible = visible; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
