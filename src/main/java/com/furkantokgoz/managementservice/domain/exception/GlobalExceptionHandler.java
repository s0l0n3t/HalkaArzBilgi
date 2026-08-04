package com.furkantokgoz.managementservice.domain.exception;


//import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
        import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.nio.file.AccessDeniedException;
import java.util.HashMap;
import java.util.Map;


@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map> handleMethodArgumentNotValidException(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        for (FieldError fieldError : ex.getBindingResult().getFieldErrors()) {
            errors.put(fieldError.getField(), fieldError.getDefaultMessage());
        };
        return ResponseEntity.badRequest().body(errors);//linkto navigation will add.
    }

//    @ExceptionHandler(DataIntegrityViolationException.class)
//    public ResponseEntity<Map> handleDataIntegrityViolationException(DataIntegrityViolationException ex) {
//        Map<String, String> errors = new HashMap<>();
//        errors.put("message", ex.getMessage());
//        return ResponseEntity.badRequest().body(errors);
//    }
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<Map> handleAccessDeniedException(AccessDeniedException ex) {
        Map<String, String> errors = new HashMap<>();
        errors.put("message", ex.getMessage());//switch-case block for message personalization
        return ResponseEntity.badRequest().body(errors);
    }
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map> handleException(Exception ex) { //ERROR CODE 500
        Map<String, String> errors = new HashMap<>();
        errors.put("message", ex.getMessage());//switch-case block for message personalization
        return ResponseEntity.badRequest().body(errors);
    }
    //TODO:
    //Business exception
}
