package com.swp391.carrental.model;

import java.time.LocalDateTime;

/**
 * Customer review for a completed rental.
 * Maps to the 'reviews' table.
 */
public class Review {

    private int reviewId;
    private int bookingId;
    private int customerId;
    private int carId;
    private int rating;
    private String comment;
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

    public int getCarId() { return carId; }
    public void setCarId(int carId) { this.carId = carId; }

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
