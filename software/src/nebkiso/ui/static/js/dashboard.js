class DashboardController {
    constructor() {
        this.ws = null;
        this.chartContexts = new Map();
        this.charts = new Map();
        this.alertCount = 0;
        this.initializeWebSocket();
        this.initializeCharts();
        this.setupEventListeners();
    }

    initializeWebSocket() {
        this.ws = new WebSocket(`ws://${window.location.host}/ws/system`);
        this.ws.onmessage = (event) => this.handleWebSocketMessage(JSON.parse(event.data));
        this.ws.onclose = () => setTimeout(() => this.initializeWebSocket(), 1000);
    }

    initializeCharts() {
        // VOC Levels Chart
        this.createChart('vocChart', {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'VOC Levels (ppb)',
                    data: [],
                    borderColor: 'rgb(75, 192, 192)',
                    tension: 0.1
                }]
            },
            options: this.getChartOptions('VOC Levels')
        });

        // Air Quality Chart
        this.createChart('aqChart', {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Air Quality Index',
                    data: [],
                    borderColor: 'rgb(153, 102, 255)',
                    tension: 0.1
                }]
            },
            options: this.getChartOptions('Air Quality')
        });

        // System Status Gauge
        this.createGauge('statusGauge', {
            title: 'System Status',
            min: 0,
            max: 100,
            value: 100
        });
    }

    createChart(id, config) {
        const ctx = document.getElementById(id).getContext('2d');
        this.chartContexts.set(id, ctx);
        this.charts.set(id, new Chart(ctx, config));
    }

    createGauge(id, config) {
        const gauge = new Gauge(document.getElementById(id));
        gauge.setOptions({
            angle: 0.15,
            lineWidth: 0.44,
            radiusScale: 1,
            pointer: {
                length: 0.6,
                strokeWidth: 0.035,
                color: '#000000'
            },
            staticZones: [
                {strokeStyle: "#F03E3E", min: 0, max: 30},
                {strokeStyle: "#FFDD00", min: 30, max: 70},
                {strokeStyle: "#30B32D", min: 70, max: 100}
            ],
            limitMax: false,
            limitMin: false,
            highDpiSupport: true
        });
        gauge.setTextField(document.getElementById(`${id}Value`));
        this.charts.set(id, gauge);
        gauge.maxValue = config.max;
        gauge.setMinValue(config.min);
        gauge.set(config.value);
    }

    getChartOptions(title) {
        return {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: title
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        };
    }

    handleWebSocketMessage(data) {
        if (data.type === 'state_update') {
            this.updateDashboard(data.data);
        }
    }

    updateDashboard(data) {
        // Update charts
        const timestamp = new Date().toLocaleTimeString();

        // Update VOC chart
        const vocChart = this.charts.get('vocChart');
        if (vocChart && data.sensor_readings.voc) {
            this.updateChartData(vocChart, timestamp, data.sensor_readings.voc.value);
        }

        // Update AQ chart
        const aqChart = this.charts.get('aqChart');
        if (aqChart && data.sensor_readings.air_quality) {
            this.updateChartData(aqChart, timestamp, data.sensor_readings.air_quality.value);
        }

        // Update status gauge
        const statusGauge = this.charts.get('statusGauge');
        if (statusGauge) {
            const statusValue = data.safety_status ? 100 : 30;
            statusGauge.set(statusValue);
        }

        // Update system mode
        document.getElementById('systemMode').textContent = data.mode;

        // Update status indicators
        this.updateStatusIndicators(data);
    }

    updateChartData(chart, label, value) {
        const maxDataPoints = 50;
        
        chart.data.labels.push(label);
        chart.data.datasets[0].data.push(value);

        if (chart.data.labels.length > maxDataPoints) {
            chart.data.labels.shift();
            chart.data.datasets[0].data.shift();
        }

        chart.update('none');
    }

    updateStatusIndicators(data) {
        const indicators = {
            'safetyStatus': data.safety_status,
            'ventilation': data.sensor_readings.flow.valid,
            'pressure': data.sensor_readings.pressure.valid
        };

        for (const [id, status] of Object.entries(indicators)) {
            const element = document.getElementById(id);
            if (element) {
                element.className = `status-indicator ${status ? 'status-ok' : 'status-error'}`;
            }
        }
    }

    setupEventListeners() {
        document.getElementById('emergencyStop').addEventListener('click', async () => {
            try {
                const response = await fetch('/system/emergency-stop', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    }
                });
                
                if (!response.ok) {
                    throw new Error('Emergency stop failed');
                }
                
                this.showAlert('Emergency stop triggered', 'error');
            } catch (error) {
                console.error('Emergency stop error:', error);
                this.showAlert('Failed to trigger emergency stop', 'error');
            }
        });
    }

    showAlert(message, type = 'info') {
        const alertsContainer = document.getElementById('alertsContainer');
        const alert = document.createElement('div');
        alert.className = `alert alert-${type}`;
        alert.textContent = message;
        
        const closeBtn = document.createElement('button');
        closeBtn.className = 'close-alert';
        closeBtn.innerHTML = '&times;';
        closeBtn.onclick = () => alert.remove();
        
        alert.appendChild(closeBtn);
        alertsContainer.appendChild(alert);
        
        setTimeout(() => alert.remove(), 5000);
    }
}

// Initialize dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.dashboard = new DashboardController();
});