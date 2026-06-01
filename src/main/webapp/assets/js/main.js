/**
 * Car Rental Management System — Main JavaScript
 */

// Sidebar toggle for mobile
function toggleSidebar() {
    const sidebar = document.querySelector('.sidebar');
    if (sidebar) {
        sidebar.classList.toggle('open');
    }
}

// Close sidebar when clicking outside on mobile
document.addEventListener('click', function (e) {
    const sidebar = document.querySelector('.sidebar');
    const toggleBtn = document.querySelector('.sidebar-toggle');
    if (sidebar && sidebar.classList.contains('open')) {
        if (!sidebar.contains(e.target) && (!toggleBtn || !toggleBtn.contains(e.target))) {
            sidebar.classList.remove('open');
        }
    }
});

// Confirm before delete actions
function confirmDelete(message) {
    return confirm(message || 'Are you sure you want to delete this item?');
}

// Format currency (VND)
function formatVND(amount) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(amount);
}

// Auto-dismiss alerts after 5 seconds
document.addEventListener('DOMContentLoaded', function () {
    const alerts = document.querySelectorAll('.alert[data-auto-dismiss]');
    alerts.forEach(function (alert) {
        setTimeout(function () {
            alert.style.transition = 'opacity 0.3s';
            alert.style.opacity = '0';
            setTimeout(function () { alert.remove(); }, 300);
        }, 5000);
    });
});

// Booking form auto calculation
function onCarSelected(selectElement) {
    const selectedOption = selectElement.options[selectElement.selectedIndex];
    const rate = selectedOption.getAttribute('data-rate');
    const dailyRateInput = document.getElementById('dailyRate');
    if (dailyRateInput) {
        dailyRateInput.value = rate || 0;
        calculateCost();
    }
}

function calculateCost() {
    const startDateStr = document.getElementById('startDate')?.value;
    const endDateStr = document.getElementById('endDate')?.value;
    const dailyRateStr = document.getElementById('dailyRate')?.value;
    const depositPctStr = document.getElementById('depositPercentage')?.value;

    if (startDateStr && endDateStr && dailyRateStr) {
        const start = new Date(startDateStr);
        const end = new Date(endDateStr);
        const rate = parseFloat(dailyRateStr);
        const depositPct = parseFloat(depositPctStr || '30');

        if (end >= start) {
            // Calculate days (minimum 1)
            const diffTime = Math.abs(end - start);
            let diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
            if (diffDays < 1) diffDays = 1;

            const totalAmount = rate * diffDays;
            const depositAmount = (totalAmount * depositPct) / 100;

            document.getElementById('rentalDaysDisplay').innerText = diffDays + ' ngày';
            document.getElementById('totalAmountDisplay').innerText = formatVND(totalAmount);
            document.getElementById('depositAmountDisplay').innerText = formatVND(depositAmount);
        } else {
            document.getElementById('rentalDaysDisplay').innerText = '0 ngày';
            document.getElementById('totalAmountDisplay').innerText = '0 VNĐ';
            document.getElementById('depositAmountDisplay').innerText = '0 VNĐ';
        }
    }
}

function toggleRejectForm() {
    const form = document.getElementById('rejectForm');
    if (form) {
        form.style.display = form.style.display === 'none' ? 'block' : 'none';
    }
}
