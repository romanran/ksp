<template>
    <div class="journal fluid-wrap">
        <router-link
            to="/">
            Home
        </router-link>
        <h1>{{filename}}</h1>
        <button class="btn" @click="toggleSeries">Toggle series</button>
        <div @mousemove="moving">
            <vue-highcharts :Highcharts="Highcharts" :options="chart_opts" ref="lineChart"></vue-highcharts>
        </div>
        <p class="nice-text">
            <span>Set a serie as the x-axis</span>
            <select v-model="curr_x_axis" @change="changeX">
                <option class="btn x-button" v-for="serie in data.series" :style="'background:' + serie.color" >{{serie.name}}</option>
            </select>
        </p>
        <div v-for="res in data.resources" class="res_chart">
            <vue-highcharts :Highcharts="Highcharts" :options="res_chart_opts" :ref="'resChart_' + res.name"></vue-highcharts>
        </div>
    </div>
</template>

<script>
    import Journal from './Journal/Journal.js'
    import vueSlider from 'vue-slider-component'
    //    import Highcharts from 'Highcharts'
    import VueHighcharts from 'vue2-highcharts'
    import Highcharts from 'highcharts'
    import highchartsMore from 'highcharts/highcharts-more'
    import solidgauge from "highcharts/modules/solid-gauge"
    highchartsMore(Highcharts)
    solidgauge(Highcharts)
    import Color from 'color'
    import theme from './Journal/ChartTheme.js'
    import chart_opts from './Journal/chart_opts.js'
    import res_chart_opts from './Journal/res_chart_opts.js'

    export default {
        name: 'journal',
        data() {
            return {
                curr_x_axis: 'MISSIONTIME',
                filename: '',
                series_visible: 1,
                chart_opts: chart_opts,
                res_chart_opts: res_chart_opts,
                data: {},
                chart: {},
                Highcharts: Highcharts,
                resCharts: [],
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
            this.filename = this.$route.params.name
        },
        mounted() {
            let chart = this.$refs.lineChart.getChart();
            this.chart = chart;
            this.Journal = new Journal(this.filename)
            this.$refs.lineChart.showLoading('Loading...')
            this.Journal
                .fetchData(this.filename)
                .then(data => this.initCharts(data))
        },
        methods: {
            initCharts(data) {
                this.chart_opts.title = {
                    text: data.title
                }
                _.each(data.series, serie => this.$refs.lineChart.addSeries(serie))
                this.chart.update(this.chart_opts)
                this.$refs.lineChart.mergeOption(theme);
                this.data = data
                this.chart.hideLoading()
                
                this.$nextTick(() => {
                    _.each(data.resources, serie => {
                        const reschart = this.$refs[`resChart_${serie.name}`][0].getChart()
                        const max = _.max(serie.data)
                        this.resCharts[serie.name] = serie;
                        const a = _.cloneDeep(this.resCharts[serie.name])
                        a.data = [a.data[0]]
                        reschart.addSeries(a)
                        this.$refs[`resChart_${serie.name}`][0].mergeOption({
                            title: {
                                text: serie.name
                            },
                            yAxis: {
                                max: max
                            }
                        })
                    })
                }, 100)
            },
            changeX(e) {
                const serie = _.find(this.data.series, {
                    name: this.curr_x_axis
                })

                this.chart.xAxis[0].setCategories(serie.data)
                this.chart.update({
                    xAxis: {
                        title: {
                            text: this.curr_x_axis
                        }
                    }
                })
            },
            moving(e) {
                const curr_x = _.round(this.chart.xAxis[0].toValue(e.chartX));
                //                                deb(curr_x)
                //                deb(this.data)

                _.each(this.data.resources, serie => {
                    const reschart = this.$refs[`resChart_${serie.name}`][0].getChart()

                    let a = _.cloneDeep(serie)
                    if (serie.data[curr_x]) {
                        a.data = [serie.data[curr_x]]
//                        this.resCharts[serie.name] = a
//                        reschart.series[0].setData(serie.data[curr_x])
//                        deb()
                        reschart.update({series: a})
//                        reschart.redraw()
//                        reschart.series = a
//                        deb(this.resCharts[serie.name])
//                        reschart.addSeries(a)
                    }
                })
                //                deb(this.res)

            },
            toggleSeries(e) {
                this.series_visible = !this.series_visible;
                _.each(this.chart.series, serie => serie.setVisible(this.series_visible, false))
            }
        }

    }

</script>

<style scoped lang="less">
    .res_chart {
         float: left;   
    }
    .x-button {
         margin-right: 5px;   
         margin-bottom: 5px;   
    }
</style>
