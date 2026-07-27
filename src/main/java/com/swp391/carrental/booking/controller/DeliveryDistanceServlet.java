package com.swp391.carrental.booking.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/*
 * Name: DeliveryDistanceServlet
 * @Author: BacBXHE186736
 * Date: 21/07/2026
 * Version: 1.0
 * Description: Calculates real road driving distance between Showroom and destination using OpenRouteService (ORS) API.
 * 
 * IMPORTANT DEPLOYMENT NOTE:
 * Do NOT hardcode ORS_API_KEY in source code or commit keys to git repository.
 * Set the ORS_API_KEY environment variable on your deployment platform:
 * - Azure App Service: Settings -> Configuration -> Application settings -> Add ORS_API_KEY
 * - Local Environment: Set OS environment variable or IDE Run Configuration -> Environment variables -> ORS_API_KEY=your_key
 */
@WebServlet(name = "DeliveryDistanceServlet", urlPatterns = {"/bookings/delivery-distance"})
public class DeliveryDistanceServlet extends HttpServlet {

    // Hanoi Branch
    private static final double HN_LAT = 21.028511;
    private static final double HN_LNG = 105.804817;

    // HCM Branch
    private static final double HCM_LAT = 10.776889;
    private static final double HCM_LNG = 106.700806;

    /** Calculates real driving distance from showroom to delivery address via OpenRouteService API */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");

        try {
            String destLatStr = request.getParameter("destLat");
            String destLngStr = request.getParameter("destLng");

            if (destLatStr == null || destLatStr.trim().isEmpty() ||
                destLngStr == null || destLngStr.trim().isEmpty()) {
                response.getWriter().write("{\"success\":false,\"fallback\":true}");
                return;
            }

            double destLat = Double.parseDouble(destLatStr);
            double destLng = Double.parseDouble(destLngStr);

            // Determine nearest branch
            double distToHN = calculateHaversine(HN_LAT, HN_LNG, destLat, destLng);
            double distToHCM = calculateHaversine(HCM_LAT, HCM_LNG, destLat, destLng);

            double startLat = HN_LAT;
            double startLng = HN_LNG;
            if (distToHCM < distToHN) {
                startLat = HCM_LAT;
                startLng = HCM_LNG;
            }

            String apiKey = System.getenv("ORS_API_KEY");
            if (apiKey == null || apiKey.trim().isEmpty()) {
                // Fallback: Try loading from db.properties (ignored by git)
                try (java.io.InputStream input = DeliveryDistanceServlet.class.getClassLoader().getResourceAsStream("db.properties")) {
                    if (input != null) {
                        java.util.Properties props = new java.util.Properties();
                        props.load(input);
                        apiKey = props.getProperty("ors.api.key");
                    }
                } catch (Exception e) {
                    // Ignore property load error
                }
            }

            if (apiKey == null || apiKey.trim().isEmpty()) {
                response.getWriter().write("{\"success\":false,\"fallback\":true}");
                return;
            }

            // ORS API takes start=LNG,LAT and end=LNG,LAT
            // Use Locale.US so floating point numbers use '.' without altering the comma separator between LNG and LAT
            String cleanApiKey = apiKey.trim();
            String apiUrl = String.format(
                java.util.Locale.US,
                "https://api.openrouteservice.org/v2/directions/driving-car?api_key=%s&start=%.6f,%.6f&end=%.6f,%.6f",
                cleanApiKey,
                startLng, startLat,
                destLng, destLat
            );

            URL url = new URL(apiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", cleanApiKey);
            conn.setRequestProperty("Accept", "application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8");
            conn.setConnectTimeout(5000); // 5 seconds
            conn.setReadTimeout(5000);    // 5 seconds

            int responseCode = conn.getResponseCode();
            if (responseCode != 200) {
                System.err.println("DeliveryDistanceServlet: ORS API returned HTTP " + responseCode + " for URL: " + apiUrl);
                try (BufferedReader errReader = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8))) {
                    StringBuilder errContent = new StringBuilder();
                    String errLine;
                    while ((errLine = errReader.readLine()) != null) {
                        errContent.append(errLine);
                    }
                    System.err.println("DeliveryDistanceServlet: Error response body: " + errContent.toString());
                } catch (Exception ignored) {}
                response.getWriter().write("{\"success\":false,\"fallback\":true}");
                return;
            }

            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
            StringBuilder content = new StringBuilder();
            String inputLine;
            while ((inputLine = in.readLine()) != null) {
                content.append(inputLine);
            }
            in.close();
            conn.disconnect();

            String jsonResponse = content.toString();
            System.out.println("DeliveryDistanceServlet: ORS Response: " + jsonResponse);

            // Robust regex matching for "distance": <number>
            java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("\"distance\"\\s*:\\s*([0-9]+(?:\\.[0-9]+)?)");
            java.util.regex.Matcher matcher = pattern.matcher(jsonResponse);

            if (matcher.find()) {
                double distanceMeters = Double.parseDouble(matcher.group(1));
                double distanceKm = Math.round((distanceMeters / 1000.0) * 10.0) / 10.0;
                if (distanceKm < 0.1) distanceKm = 0.1; // minimum distance 0.1 km

                System.out.println("DeliveryDistanceServlet: Calculated distanceKm = " + distanceKm + " km");
                response.getWriter().write(String.format(java.util.Locale.US, "{\"success\":true,\"distanceKm\":%.1f}", distanceKm));
                return;
            }

            System.err.println("DeliveryDistanceServlet: Could not find distance field in ORS JSON response.");
            response.getWriter().write("{\"success\":false,\"fallback\":true}");

        } catch (Exception e) {
            System.err.println("DeliveryDistanceServlet Exception: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("{\"success\":false,\"fallback\":true}");
        }
    }

    private static double calculateHaversine(double lat1, double lon1, double lat2, double lon2) {
        double R = 6371; // km
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}
