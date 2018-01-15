/* TODO: switch the ticks with description or not scaling scales colors from hash /*
<template>
<div class="journal fluid-wrap">
    <router-link
                 to="/"
                 >Home</router-link>
    <h1>{{filename}}</h1>
    <canvas ref="canvas" :style="{cursor: getCursor}"></canvas>
    <vue-slider 
        class="slider"
        :min="slider_x_min"
        :max="slider_x_max"

        v-model="slider_x_val"
        @callback="updateChart">
    </vue-slider >
    </div>
</template>

<script>
    import Journal from './Journal/Journal.js'
    import JournalChart from './Journal/Charts.js'
    import vueSlider from 'vue-slider-component'

    export default {
        name: 'journal',
        data() {
            return {
                filename: '',
                pointer: 0,
                original_dataset: [],
                slider_x_val: [0, 100],
                slider_x_min: 0,
                slider_x_max: 100
            }
        },
        computed: {
            getCursor() {
                return this.pointer ? 'pointer' : 'default'
            }
        },
        components: { 
            vueSlider
        },
        created() {
            global.App = this //for deb
            this.filename = this.$route.params.name
            this.Journal = new Journal(this.filename)
            this.Journal
                .fetchData(this.filename)
                .then(data => {
                this.Chart = new JournalChart(this.$refs.canvas, data, this._data)
                //                    this.original_dataset = this.Chart.opts
                //                deb( App.Chart.opts)
                this.slider_x_val = [0, App.Chart.opts.options.scales.xAxes[0].time.max]
                this.slider_x_min = App.Chart.opts.options.scales.xAxes[0].time.min
                this.slider_x_max = App.Chart.opts.options.scales.xAxes[0].time.max
            })
        },
        methods: {
            updateChart: (e) => {
                App.Chart.opts.options.scales.xAxes[0].time.min = e[0]
                App.Chart.opts.options.scales.xAxes[0].time.max = e[1]
                App.Chart.chart.update()
            }
        }
    }

</script>

<style scoped lang="less">


</style>
