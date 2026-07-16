package com.swp391.carrental.auth.service;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class EmailService {
    private static final Properties config = new Properties();

    static {
        try (InputStream input = EmailService.class
                .getClassLoader()
                .getResourceAsStream("mail.properties")) {

            if (input == null) {
                throw new RuntimeException("Cannot find mail.properties");
            }

            config.load(input);

        } catch (IOException e) {
            throw new RuntimeException("Failed to load mail.properties", e);
        }
    }

    public static void sendForgotPasswordEmail(
            String toEmail,
            String newPassword) throws Exception {

        String fromEmail = config.getProperty("mail.username");
        String appPassword = config.getProperty("mail.password");
        String smtpHost = config.getProperty("mail.smtp.host");
        String smtpPort = config.getProperty("mail.smtp.port");

        Properties props = new Properties();

        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);

        Session session = Session.getInstance(
                props,
                new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(
                                fromEmail,
                                appPassword
                        );
                    }
                });

        Message message = new MimeMessage(session);

        message.setFrom(new InternetAddress(fromEmail));

        message.setRecipients(
                Message.RecipientType.TO,
                InternetAddress.parse(toEmail)
        );

        message.setSubject("CarPro - Password Reset");

        String content =
                "Xin chào,\n\n"
                + "Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản CarPro.\n\n"
                + "Mật khẩu mới của bạn là:\n\n"
                + newPassword
                + "\n\n"
                + "Vui lòng đăng nhập và đổi mật khẩu ngay sau khi đăng nhập thành công.\n\n"
                + "Trân trọng,\n"
                + "CarPro Team";

        message.setText(content);

        Transport.send(message);
    }
}