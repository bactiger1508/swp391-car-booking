package com.swp391.carrental.auth.service;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/*
 * Name: EmailService
 * @Author: AnhNNHE160896
 * Date: 17/07/2026
 * Version: 1.1
 * Description: Email sending utility supporting forgotten password verification emails and environment variable configs.
 */
public class EmailService {
    private static final Properties config = new Properties();

    static {
        try (InputStream input = EmailService.class
                .getClassLoader()
                .getResourceAsStream("mail.properties")) {

            if (input != null) {
                config.load(input);
            } else {
                System.out.println("Warning: mail.properties not found on classpath, relying entirely on Environment Variables.");
            }

        } catch (IOException e) {
            System.err.println("Warning: Failed to load mail.properties: " + e.getMessage());
        }
    }

    public static void sendForgotPasswordEmail(
            String toEmail,
            String newPassword) throws Exception {

        String fromEmail = System.getenv("MAIL_USERNAME") != null ? System.getenv("MAIL_USERNAME") : config.getProperty("mail.username");
        String appPassword = System.getenv("MAIL_PASSWORD") != null ? System.getenv("MAIL_PASSWORD") : config.getProperty("mail.password");
        String smtpHost = System.getenv("MAIL_SMTP_HOST") != null ? System.getenv("MAIL_SMTP_HOST") : config.getProperty("mail.smtp.host", "smtp.gmail.com");
        String smtpPort = System.getenv("MAIL_SMTP_PORT") != null ? System.getenv("MAIL_SMTP_PORT") : config.getProperty("mail.smtp.port", "587");

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