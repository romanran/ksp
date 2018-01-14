<template>
<div id="app">
  <router-view/>
	<router-link
				 to="/"
				 >Home</router-link>
  </div>
</template>

<script>
	export default {
		name: 'inspector'
	}

</script>

<style src="./styles/global.less" lang="less"></style>

<style lang="less">
	@import (css) url("https://fonts.googleapis.com/icon?family=Roboto");
	html,
	body {
		font-family: Roboto;
		font-weight: 300;
		background: #333844;
		color: white;
	}

</style>
