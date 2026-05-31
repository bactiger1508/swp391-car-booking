/*
 * Name: MaintenanceDAO
 * @Author: TinhNVHE160000 (Vehicle Module)
 * Date: 31/05/2026
 * Version: 1.0
 * Description: Data Access Object for Maintenance Schedule entity
 */
package com.swp391.carrental.dao;

import com.swp391.carrental.model.MaintenanceSchedule;
import com.swp391.carrental.util.DBContext;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Maintenance Schedule operations.
 * Handles all database operations related to maintenance schedules.
 */
public class MaintenanceDAO {

    /**
     * Get all maintenance schedules.
     */
    public List<MaintenanceSchedule> getAllMaintenanceSchedules() throws SQLException {
        List<MaintenanceSchedule> schedules = new ArrayList<>();
        String sql = "SELECT * FROM maintenance_schedules ORDER BY scheduled_date ASC";
        
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                schedules.add(mapRow(rs));
            }
        }
        return schedules;
    }

    /**
     * Get maintenance schedules for a specific vehicle.
     */
    public List<MaintenanceSchedule> getMaintenanceByVehicle(int vehicleId) throws SQLException {
        List<MaintenanceSchedule> schedules = new ArrayList<>();
        String sql = "SELECT * FROM maintenance_schedules WHERE car_id = ? ORDER BY scheduled_date ASC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    schedules.add(mapRow(rs));
                }
            }
        }
        return schedules;
    }

    /**
     * Get scheduled maintenance (not yet completed).
     */
    public List<MaintenanceSchedule> getScheduledMaintenance() throws SQLException {
        List<MaintenanceSchedule> schedules = new ArrayList<>();
        String sql = "SELECT * FROM maintenance_schedules WHERE status = 'SCHEDULED' " +
                    "AND scheduled_date <= CAST(GETDATE() AS DATE) ORDER BY scheduled_date ASC";
        
        try (Connection conn = DBContext.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                schedules.add(mapRow(rs));
            }
        }
        return schedules;
    }

    /**
     * Get maintenance schedule by ID.
     */
    public MaintenanceSchedule getMaintenanceById(int maintenanceId) throws SQLException {
        String sql = "SELECT * FROM maintenance_schedules WHERE maintenance_id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, maintenanceId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    /**
     * Create new maintenance schedule.
     */
    public int createMaintenance(MaintenanceSchedule maintenance) throws SQLException {
        String sql = "INSERT INTO maintenance_schedules (car_id, maintenance_type, scheduled_date, " +
                    "status, description, cost, notes, created_by, created_at) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, maintenance.getVehicleId());
            ps.setString(2, maintenance.getMaintenanceType());
            ps.setDate(3, java.sql.Date.valueOf(maintenance.getScheduledDate()));
            ps.setString(4, maintenance.getStatus() != null ? maintenance.getStatus() : "SCHEDULED");
            ps.setString(5, maintenance.getDescription());
            ps.setDouble(6, maintenance.getCost());
            ps.setString(7, maintenance.getNotes());
            ps.setString(8, maintenance.getCreatedBy());
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Update maintenance schedule.
     */
    public boolean updateMaintenance(MaintenanceSchedule maintenance) throws SQLException {
        String sql = "UPDATE maintenance_schedules SET maintenance_type = ?, scheduled_date = ?, " +
                    "description = ?, cost = ?, notes = ?, updated_by = ?, updated_at = GETDATE() " +
                    "WHERE maintenance_id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, maintenance.getMaintenanceType());
            ps.setDate(2, java.sql.Date.valueOf(maintenance.getScheduledDate()));
            ps.setString(3, maintenance.getDescription());
            ps.setDouble(4, maintenance.getCost());
            ps.setString(5, maintenance.getNotes());
            ps.setString(6, maintenance.getUpdatedBy());
            ps.setInt(7, maintenance.getMaintenanceId());
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Complete maintenance.
     */
    public boolean completeMaintenance(int maintenanceId, String completedBy) throws SQLException {
        String sql = "UPDATE maintenance_schedules SET status = 'COMPLETED', " +
                    "completed_date = CAST(GETDATE() AS DATE), updated_by = ?, updated_at = GETDATE() " +
                    "WHERE maintenance_id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, completedBy);
            ps.setInt(2, maintenanceId);
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Cancel maintenance.
     */
    public boolean cancelMaintenance(int maintenanceId, String cancelledBy) throws SQLException {
        String sql = "UPDATE maintenance_schedules SET status = 'CANCELLED', " +
                    "updated_by = ?, updated_at = GETDATE() WHERE maintenance_id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, cancelledBy);
            ps.setInt(2, maintenanceId);
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete maintenance schedule.
     */
    public boolean deleteMaintenance(int maintenanceId) throws SQLException {
        String sql = "DELETE FROM maintenance_schedules WHERE maintenance_id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, maintenanceId);
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Map ResultSet row to MaintenanceSchedule object.
     */
    private MaintenanceSchedule mapRow(ResultSet rs) throws SQLException {
        MaintenanceSchedule maintenance = new MaintenanceSchedule();
        maintenance.setMaintenanceId(rs.getInt("maintenance_id"));
        maintenance.setVehicleId(rs.getInt("car_id"));
        maintenance.setMaintenanceType(rs.getString("maintenance_type"));
        
        Date scheduledDate = rs.getDate("scheduled_date");
        if (scheduledDate != null) {
            maintenance.setScheduledDate(scheduledDate.toLocalDate());
        }
        
        Date completedDate = rs.getDate("completed_date");
        if (completedDate != null) {
            maintenance.setCompletedDate(completedDate.toLocalDate());
        }
        
        maintenance.setStatus(rs.getString("status"));
        maintenance.setDescription(rs.getString("description"));
        maintenance.setCost(rs.getDouble("cost"));
        maintenance.setNotes(rs.getString("notes"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            maintenance.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            maintenance.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        maintenance.setCreatedBy(rs.getString("created_by"));
        maintenance.setUpdatedBy(rs.getString("updated_by"));
        
        return maintenance;
    }
}
