/* TODO:
switch the ticks with description or not
scaling scales
colors from hash
 /*
<template>
    <div class="journal fluid-wrap">
        <router-link
           to="/"
         >Home</router-link>
        <h1>{{filename}}</h1>
        <canvas ref="canvas" :style="{cursor: getCursor}"></canvas>
    </div>
</template>

<script>
    import Journal from './Journal/Journal.js'
    import JournalChart from './Journal/Charts.js'
    
    export default {
        name: 'journal', 
        data() {
            return { 
                filename: '',
                pointer: 0
            }
        },
        computed: {
            getCursor () {
                return this.pointer ? 'pointer' : 'default'
            }
        },
        created() {
            this.filename = this.$route.params.name
            this.Journal = new Journal(this.filename)
            this.Journal.fetchData(this.filename).then(data => {
                this.Chart = new JournalChart(this.$refs.canvas, data, this._data)
            })
        },
    }
</script>

<style scoped lang="less"> 
     
</style> 