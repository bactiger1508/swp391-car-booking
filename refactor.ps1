$baseDir = "c:\Users\bacb4\Documents\NetBeansProjects\car-rental-management\src\main\java\com\swp391\carrental"
$dateStr = Get-Date -Format "dd/MM/yyyy"

$authors = @{
    "AnhNNHE160896" = @("Login", "Register", "Logout", "Profile", "User", "Role", "Auth")
    "TinhHNHE172394" = @("VehicleList", "VehicleDetail", "VehicleManage", "VehicleAvail", "Maintenance", "Car")
    "BacBXHE186736" = @("Home", "CreateBooking", "MyBookings", "BookingEdit", "BookingCalendar", "Booking", "Availability")
    "TungNLHE186756" = @("BookingApproval", "Contract", "Payment", "Policy", "TaxInvoice")
    "TamTTMHE190340" = @("Handover", "Return", "AdditionalFee", "Revenue", "Utilization", "Review", "Audit", "FeeCalculator", "Report")
}

$controllerMap = @{
    "auth" = @("LoginServlet", "RegisterServlet", "LogoutServlet")
    "user" = @("ProfileServlet", "UserManagementServlet", "RolePermissionsServlet")
    "vehicle" = @("VehicleListServlet", "VehicleDetailServlet", "VehicleManagementServlet", "VehicleAvailabilityServlet", "MaintenanceScheduleServlet")
    "booking" = @("HomeServlet", "CreateBookingServlet", "MyBookingsServlet", "BookingEditServlet", "BookingCalendarServlet", "BookingManagementServlet", "BookingApprovalServlet")
    "contract" = @("ContractManagementServlet", "ContractDetailServlet")
    "payment" = @("PaymentRecordServlet", "TaxInvoiceSettingsServlet")
    "handover" = @("VehicleHandoverServlet", "VehicleReturnServlet", "AdditionalFeesServlet")
    "report" = @("RevenueReportServlet", "VehicleUtilizationReportServlet")
    "policy" = @("PolicySettingsServlet")
    "common" = @("TestDatabaseServlet")
}

function Get-Author($fileName) {
    foreach ($key in $authors.Keys) {
        foreach ($keyword in $authors[$key]) {
            if ($fileName -match $keyword) {
                return $key
            }
        }
    }
    return "BacBXHE186736" # Default
}

# 1. Create sub-packages for controllers
foreach ($sub in $controllerMap.Keys) {
    $dir = Join-Path "$baseDir\controller" $sub
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

# 2. Process all Java files
$javaFiles = Get-ChildItem -Path $baseDir -Recurse -Filter "*.java"

foreach ($file in $javaFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $fileName = $file.Name
    $className = $file.BaseName
    $author = Get-Author $fileName
    
    # Check if already has comment header
    if ($content -notmatch "\/\*\s*\n\s*\*\s*Name:") {
        $desc = "Handles business logic and operations for $className."
        if ($fileName -match "Servlet") { $desc = "Handles HTTP requests and responses for $className." }
        if ($fileName -match "DAO") { $desc = "Handles database operations for $className." }
        if ($fileName -match "Service") { $desc = "Contains business logic for $className." }

        $header = "/*
 * Name: $className
 * @Author: $author
 * Date: $dateStr
 * Version: 1.0
 * Description: $desc
 */
"
        $content = $header + $content
    }

    # If it's a controller in the root controller folder, update package and move
    if ($file.Directory.Name -eq "controller") {
        $targetSub = ""
        foreach ($sub in $controllerMap.Keys) {
            if ($controllerMap[$sub] -contains $fileName) {
                $targetSub = $sub
                break
            }
        }
        
        if ($targetSub -ne "") {
            # Update package
            $content = $content -replace "package com.swp391.carrental.controller;", "package com.swp391.carrental.controller.$targetSub;"
            
            # Save file
            [System.IO.File]::WriteAllText($file.FullName, $content)
            
            # Move file
            $targetDir = Join-Path "$baseDir\controller" $targetSub
            Move-Item -Path $file.FullName -Destination $targetDir -Force
            Write-Host "Moved $fileName to $targetSub"
            continue
        }
    }
    
    # Save file with header
    [System.IO.File]::WriteAllText($file.FullName, $content)
}

Write-Host "Refactoring completed successfully!"