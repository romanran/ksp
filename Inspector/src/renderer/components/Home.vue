<template>
  <div class="home">
    <h1>{{ msg }}</h1>
		  <ul>
			  <li v-for="obj in journals">
				  <router-link
							   :to="{ name: 'journal', params: { name: `${obj.name}` }}"
					 class="truncate btn-flat waves-effect waves-teal"
				   >{{obj.name}}</router-link>
				</li>
		</ul>
	</div>
</template>

<script>
	global.deb = console.log
	import glob from 'glob'
	import path from 'path'
	export default {
		name: 'inspector',
		data() {
			return {
				msg: 'Welcome to Aurora Journal Inspector',
				journals: []
			}
		},
		methods: {},
		created() {
			glob('../flightlogs/*.json', {}, (err, res) => {
				res = res.map(file => {
					return {
						name: path.parse(file).name,
						link: file
					}
				})
				this.journals = res
			})
			this.msg = 'Flight journals'
		}
	}
</script>

<style scoped lang="less">
	h1 {
		text-align: center;
		font-weight: 300;
		color: white;
	}

</style>
