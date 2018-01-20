import Color from 'color'
export default {
    chart: {
        animation: 0,
        type: 'solidgauge',
        backgroundColor: 'transparent',
        width: 200,
        height: 200,
        margin: [10, 0]
    },
    boost: {
        useGPUTranslations: true
    },
    title: {
        align: 'center',
        y: 5,
        style: {
            color: 'white',
            fontsize: '15px',
            fontWeight: '100',
            fontFamily: 'Roboto',
        }
    },
    credits: false,
    pane: {
        center: ['50%', '50%'],
        size: '75%',
        startAngle: -160,
        endAngle: 160
    },
    yAxis: {
        animation: 0,
        min: 0,
        minorTickLength:15,
        labels: {
            style: {
                fontFamily: 'Roboto',
                color: 'black'
            },
        },
        stops: [
            [0, Color('#DF5300').fade(0.3)], // red
            [0.1, Color('#DF5353').fade(0.5)], // red
            [0.7, Color('#DDDF0D').fade(0.5)], // yellow
            [0.5, Color('#99CF3B').fade(0.5)], // green
            [1, Color('#55BF3B').fade(0)], // green
        ],
    },
    plotOptions: {
        solidgauge: {
            innerRadius: '85%',
            animation: 0,
            borderWidth: 5,
            dataLabels: {
                y: -15,
                borderWidth: 0,
                useHTML: true,
                style: {
                    fontFamily: 'Roboto',
                    fontSize: '15px'
                },
            }
        }
    },
}
