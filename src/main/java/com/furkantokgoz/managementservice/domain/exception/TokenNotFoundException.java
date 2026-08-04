package com.furkantokgoz.managementservice.domain.exception;

import org.springframework.http.HttpStatus;

public class TokenNotFoundException extends RuntimeException {
    public TokenNotFoundException() {
        super(HttpStatus.UNAUTHORIZED.toString());
    }
    public TokenNotFoundException(String message) {
        super(message);
    }
    public TokenNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }
}
