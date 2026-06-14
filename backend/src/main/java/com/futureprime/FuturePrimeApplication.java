package com.futureprime;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.TimeZone;

@SpringBootApplication
public class FuturePrimeApplication {

	public static void main(String[] args) {
		TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
		SpringApplication.run(FuturePrimeApplication.class, args);
	}

	@Bean
	public CommandLineRunner generateHash(PasswordEncoder passwordEncoder) {
		return args -> {
			System.out.println("HASH: " + passwordEncoder.encode("password123"));
		};
	}
}
