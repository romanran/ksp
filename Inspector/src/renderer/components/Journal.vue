/* TODO: switch the ticks with description or not scaling scales colors from hash /*
<template>
    <div class="journal fluid-wrap">
        <router-link
                     to="/"
                     >Home</router-link>
        <h1>{{filename}}</h1>
        <chart :style="{cursor: getCursor}" :chart-data="chart_data" :options="chart_opts"></chart>
<!--
        <vue-slider 
            class="slider"
            :min="slider_x_min"
            :max="slider_x_max"

            v-model="slider_x_val"
            @callback="updateChart">
        </vue-slider >
-->
    </div>
</template>

<script>
    import Journal from './Journal/Journal.js'
    import {chart, JournalChart} from './Journal/Chart'
    import vueSlider from 'vue-slider-component'
    
    export default {
        name: 'journal',
        data() {
            return {
                filename: '',
                pointer: 0,
                original_dataset: [],
                slider_x_val: [0, 0],
                slider_x_min: 0,
                slider_x_max: 1,
                chart_data: {},
                chart_opts: {}
            }
        },
        computed: {
            getCursor() {
                return this.pointer ? 'pointer' : 'default'
            }
        },
        components: { 
            vueSlider,
            chart
        },
        created() {
            global.App = this //for deb
            this.filename = this.$route.params.name
            this.Journal = new Journal(this.filename)
            this.Journal
                .fetchData(this.filename)
                .then(data => {
    //                this.Chart = new chart(data, this._data)
                    const chart_data = new JournalChart(data)
                    this.slider_x_val = 0.5
                    this.slider_x_min = 0
                    this.slider_x_max = 1
                    this.chart_data = chart_data.getOpts.data
                    this.chart_opts = chart_data.getOpts.opts
                })
        },
        methods: {
            updateChart: (e) => {
//                App.Chart.chart.update()
            }
        }
    }

</script>

<style scoped lang="less">


</style>
