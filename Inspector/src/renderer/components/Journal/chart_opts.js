import Color from 'color'
export default {
    title: {
        align: 'left'
    },
    subtitle: {
        align: 'left',
        text: 'Click and drag to zoom in. Hold down shift key to pan.'
    },
    boost: {
        useGPUTranslations: true
    },
    chart: {
        marginTop: 100,
        type: 'spline',
        zoomType: 'xy',
        pinchType: 'xy',
        animation: 0,
        backgroundColor: 'transparent',
        height: '800',
        panning: 1,
        style: {
            fontFamily: 'Roboto'
        },
        panKey: 'shift',
//        spacing:[0, 0, 5, 0]
    },
    credits: false,
    yAxis: {
        crosshair: {
            color: 'orange'
        },
        alternateGridColor: Color('black').fade(0.9).string(),
        gridLineColor: Color('#fff').fade(0.9).string(),
        gridLineWidth: 1
    },
    xAxis: {
        gridLineDashStyle: 'Dot',
        gridLineWidth: 1,
        description: 'seconds',
        gridLineColor: Color('#fff').fade(0.7).string(),
        title: {
            text: 'MISSION TIME'
        },
        categories: [],
        tickColor: 'white',
        labels: {
            style: {
                color: 'white'
            },
            y: 25
        },
        crosshair: {
            color: Color('lime').fade(0.95).string()
        },
        minorGridLineDashStyle: 'Dot',
        minorGridLineColor: Color('#fff').fade(0.9).string(),
    },
    legend: {
        align: 'center',
        verticalAlign: 'top',
        itemHoverStyle: {
            color: 'white',
        },
        itemStyle: {
            color: '#bbb',
            letterSpacing: '1',
            fontWeight: '300'
        },
        itemHiddenStyle: {
            color: '#955'
        },
        y: -10
    },
    tooltip: {
        padding: 10,
        useHTML: true,
        shared: true,
    },
}
