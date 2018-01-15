<template>
<div id="app">
  <router-view/>
  </div>
</template>

<script>
	export default {
		name: 'inspector'
	}

</script>

<style src="./styles/global.less" lang="less"></style>

<style lang="less">
	@import (css) url("https://fonts.googleapis.com/css?family=Roboto:100,300,400");
	@import (css) url("https://fonts.googleapis.com/css?family=Unica+One:300,400");
	html,
	body {
		font-family: Roboto;
		font-weight: 300;
		background: #333844;
		color: white;
	}

</style>
