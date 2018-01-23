<template>
  <div class="home">
    <h1>{{ msg }}</h1>
	  	<p>Sorted by modified date</p>
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
	import fs from 'fs-extra'
	import _ from 'lodash'
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
			glob('../flightlogs/*.json', {}, (err, files) => {
				files = files.map(file => {
					return {
						name: path.parse(file).name,
						link: file					}
				})
				let i = 0
				_.forEach(files, file => {
					fs.stat(file.link, (err, stat) => {
						if (err) deb(err)
						file.stat = stat
						files[i] = file
						i++
						if (i === files.length) {
							deb(files)
							this.journals = _.chain(files).sortBy('stat.mtime').reverse().value()
						}
					})
				})
				
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
