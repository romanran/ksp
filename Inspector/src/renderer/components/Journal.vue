/* TODO: switch the ticks with description or not scaling scales colors from hash /*
<template>
    <div class="journal fluid-wrap">
        <router-link
                     to="/"
                     >Home</router-link>
        <h1>{{filename}}</h1>
        <vue-highcharts :options="chart_opts" ref="lineCharts"></vue-highcharts>
        <p class="nice-text">
            <span>Set a serie as the x-axis</span>
            <button class="btn" v-for="serie in data.series" @click="changeX(serie.name)">{{serie.name}}</button>
        </p>
    </div>
</template>

<script>
    import Journal from './Journal/Journal.js'
    import vueSlider from 'vue-slider-component'
    import Highcharts from 'Highcharts'
    import VueHighcharts from 'vue2-highcharts'
    import Color from 'color'
    //    import Drilldown from '../../../node_modules/highcharts/modules/Drilldown.js'
    //    import Highcharts from 'highcharts'
    //    Drilldown(Highcharts);
    import theme from './Journal/ChartTheme.js'

    export default {
        name: 'journal',
        data() {
            return {
                filename: '',
                chart_opts: {
                    title: {
                        align: 'left'
                    },
                    subtitle: {
                        align: 'left',
                        text: 'Click and drag to zoom in. Hold down shift key to pan.'
                    },
                    chart: {
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
                        panKey: 'shift'
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
                            //                            color: 'orange'
                        },
                        minorTickWidth: 1,
                        minorTickInterval: 1,
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
                        }
                    },
                    tooltip: {
                        padding: 10,
                        useHTML: true,
                        shared: true,
//                        pointFormatter: (e, p) => {
//                            deb(this)
//                        } 
                        positioner: function () {
                            return { x: 10, y: 35 };
                        },
                        headerFormat: "<div>{point.series.name}:{point.x}{}, value: {point.y} {point.description}<div><br>"
                    },
                },
                data: {}
            }
        },
        computed: {
            getCursor() {
                return this.pointer ? 'pointer' : 'default'
            }
        },
        components: {
            vueSlider,
            VueHighcharts
        },
        created() {
            global.App = this //for deb
            //            lineCharts.delegateMethod('showLoading', 'Loading...');
            this.filename = this.$route.params.name
        },
        mounted() {
            let chart = this.$refs.lineCharts.getChart();
            this.chart = chart;
            let highchart = this.$refs.lineCharts;
            this.Journal = new Journal(this.filename)
            this.Journal
                .fetchData(this.filename)
                .then(data => {
                    this.chart_opts.title = {
                        text: data.title
                    }
                    this.chart_opts.series = data.series;
                    _.each(data.series, serie => this.$refs.lineCharts.addSeries(serie))
                    chart.update(this.chart_opts)
                    highchart.mergeOption(theme);
                    this.data = data
                    chart.xAxis[0].setCategories(data.labels)
                })
        },
        methods: {
            changeX(e) {
                const serie = _.find(this.data.series, {
                    name: e
                })
                deb(serie)
                this.chart.xAxis[0].setCategories(serie.data)
                this.chart.update({
                    xAxis: {
                        title: {
                            text: e
                        }
                    }
                })
            }
        }

    }

</script>

<style scoped lang="less">


</style>
