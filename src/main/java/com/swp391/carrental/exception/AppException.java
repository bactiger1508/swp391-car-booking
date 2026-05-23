package com.swp391.carrental.exception;

/**
 * Custom application exception for business logic errors.
 */
public class AppException extends RuntimeException {

    private int errorCode;

    public AppException(String message) {
        super(message);
    }

    public AppException(String message, Throwable cause) {
        super(message, cause);
    }

    public AppException(String message, int errorCode) {
        super(message);
        this.errorCode = errorCode;
    }

    public AppException(String message, int errorCode, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
    }

    public int getErrorCode() {
        return errorCode;
    }
}
