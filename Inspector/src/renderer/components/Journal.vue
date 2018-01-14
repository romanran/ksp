<template>
    <div class="journal">
        Journal {{filename}}
        <router-link
           to="/"
         >Home</router-link>
    </div>
</template>

<script>
    export default {
        name: 'journal',
        data: {
            filename: 's'
        }
    }
</script>

<style scoped lang="less">
</style>