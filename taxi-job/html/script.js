/* Taxi Job UI Script */

// Variables
let meterActive = false;
let baseFare = 0;
let totalFare = 0;
let distance = 0;
let isOnDuty = false;

// DOM Elements
const taxiUI = document.getElementById('taxi-ui');
const statusText = document.getElementById('status-text');
const baseFareElement = document.getElementById('base-fare');
const distanceElement = document.getElementById('distance');
const totalFareElement = document.getElementById('total-fare');
const toggleMeterButton = document.getElementById('toggle-meter');
const resetMeterButton = document.getElementById('reset-meter');
const collectPaymentButton = document.getElementById('collect-payment');
const dutyStatusElement = document.getElementById('duty-status');

// Event Listeners
toggleMeterButton.addEventListener('click', function() {
    if (meterActive) {
        // Stop meter
        fetch('https://taxi-job/stopMeter', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    } else {
        // Start meter
        fetch('https://taxi-job/startMeter', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
    }
});

resetMeterButton.addEventListener('click', function() {
    // Reset meter
    fetch('https://taxi-job/resetMeter', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
});

collectPaymentButton.addEventListener('click', function() {
    // Collect payment
    fetch('https://taxi-job/collectPayment', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
});

// Message Handler
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'toggleUI') {
        // Toggle UI visibility
        taxiUI.classList.toggle('hidden');
    } else if (data.type === 'updateUI') {
        // Update UI with new data
        updateUI(data.data);
    } else if (data.type === 'updateDuty') {
        // Update duty status
        updateDutyStatus(data.status);
    }
});

// Update UI Function
function updateUI(data) {
    if (data.meterActive !== undefined) {
        meterActive = data.meterActive;
        
        if (meterActive) {
            statusText.textContent = 'ACTIVE';
            statusText.classList.add('active');
            statusText.classList.remove('inactive');
            toggleMeterButton.textContent = 'Stop Meter';
            toggleMeterButton.classList.remove('start');
            toggleMeterButton.classList.add('stop');
        } else {
            statusText.textContent = 'INACTIVE';
            statusText.classList.add('inactive');
            statusText.classList.remove('active');
            toggleMeterButton.textContent = 'Start Meter';
            toggleMeterButton.classList.remove('stop');
            toggleMeterButton.classList.add('start');
        }
    }
    
    if (data.baseFare !== undefined) {
        baseFare = data.baseFare;
        baseFareElement.textContent = '$' + baseFare;
    }
    
    if (data.fare !== undefined) {
        totalFare = data.fare;
        totalFareElement.textContent = '$' + totalFare;
    }
    
    if (data.distance !== undefined) {
        distance = data.distance;
        distanceElement.textContent = distance.toFixed(2) + ' km';
    }
}

// Update Duty Status Function
function updateDutyStatus(status) {
    isOnDuty = status;
    
    if (isOnDuty) {
        dutyStatusElement.textContent = 'ON DUTY';
        dutyStatusElement.classList.add('on-duty');
    } else {
        dutyStatusElement.textContent = 'OFF DUTY';
        dutyStatusElement.classList.remove('on-duty');
    }
}

// Initialize UI with default values
function initializeUI() {
    // Set default values
    updateUI({
        meterActive: false,
        baseFare: 0,
        fare: 0,
        distance: 0
    });
    
    // Set default duty status
    updateDutyStatus(false);
}

// Initialize on load
document.addEventListener('DOMContentLoaded', initializeUI);