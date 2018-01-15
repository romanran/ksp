<script>
	import shc from 'string-hash-colour'
	import Color from 'color'
	import ChartZoom from 'chartjs-plugin-zoom'
	import { Line } from 'vue-chartjs'
	import { mixins } from 'vue-chartjs'
	const { reactiveProp } = mixins

	const generateColor = shc.convert;
	export class JournalChart {

		constructor(data) {
			let x = [];

			this.title = data[0].SHIP ? data[0].SHIP : data[0].SPD;
			for (let key in data) {
				if (key == 0) {
					continue;
				}
				x.push(data[key].MISSIONTIME);
			}

			this.opts = this.getType('line', x, _.takeRight(data, data.length - 1));
		}

		get getOpts() {
			return this.opts
		}

		getType(type, labels, data) {
			let dataset = [];
			let data_arr = [];
			let desc_arr = [];
			let status_arr = [];
			let data_l = data.length;
			let ai = 0;

			_.each(data, (obj, i) => {
				let obj_l = Object.keys(obj).length;
				let ni = 0;
				_.each(obj, (val, key) => {
					if (typeof (val) == "object") {
						return;
					}
					if (key === "DESC") {
						status_arr.push(val);
						return 0;
					}
					if (key === "STATUS") {
						const last_status = _.last(status_arr);
						if (last_status)
							desc_arr.push(`${last_status}, ${key}: ${val}`);
						return 0;
					}
					if (['TIME', 'FACING'].indexOf(key) >= 0) {
						return 0;
					}
					if (data_arr[key]) {
						data_arr[key].push(val);
					} else {
						data_arr[key] = [];
					}
				});
			});

			let last_color = '#FFF'
			_.forIn(data_arr, (arr, key) => {
				let color = generateColor(key, { avoid: last_color, proximity: 100 })
				last_color = color
				dataset.push({
					label: key,
					comment: desc_arr,
					fill: false,
					data: arr,
					title: key,
					borderColor: Color(color).fade(0.4).darken(0.2),
					backgroundColor: color,
					//				chartColors: r_colors,
					borderWidth: 1,
					radius: 3,
					borderWidth: 1,
					tension: 0.3,
				});
			});

			return {
				type: type,
				data: {
					labels: labels,
					datasets: dataset,
				},
				options: {
					responsive: true,
					maintainAspectRatio: false,
					title: {
						display: true,
						fontColor: 'white',
						fontSize: 20,
						text: this.title
					},
					hover: {
						onHover: (e) => {

						},
						animationDuration: 100
					},
					legend: {
						position: 'top',
						labels: {
							fontColor: 'white',
							fontStyle: 'bold',
						},
						onHover: (e) => {
			
						}
					},
					tooltips: {
						mode: 'index',
						intersect: true,
						yPadding: 10,
						xPadding: 10,
						callbacks: {
							title: (tooltipItem, data) => {
								let datasetLabel = data.datasets[0].comment[tooltipItem[0].index];
								return data.datasets[0].comment[tooltipItem[0].index];
							}
						}
					},
					animation: {
						duration: 100
					},
					scales: {
						yAxes: [{
							gridLines: {
								color: "rgba(195,235,255,0.15)",
							},
							ticks: {
								fontColor: 'white',
								beginAtZero: true
							},
							scaleLabel: {
								display: 1,
								//							stepSize: 10,
							}
						}],
						xAxes: [{
							gridLines: {
								color: "rgba(195,235,255,0.05)",
							},
							type: 'time',
							position: 'bottom',
							ticks: {
								fontColor: 'white',
								beginAtZero: true,
								//							maxTicksLimit: 30,
								autoSkipPadding: 10,
								autoSkip: 1
							},
							time: {
								min: 0,
								max: _.last(labels),
								unit: 'millisecond',
								displayFormats: {
									millisecond: 'mm:ss'
								}
							},
							scaleLabel: {
								display: true,
								fontColor: 'white',
								labelString: 'MISSION TIME'
							}
						}]
					},
					pan: {
						enabled: true,
						mode: 'xy'
					},
					zoom: {
						sensitivity:0.5,
						enabled: true,
						mode: 'xy',
						drag: true,
					}
				}
			};
		}
	}
	
	export const chart = {
		data() {
			return {}
		},
		extends: Line,
		mixins: [reactiveProp],
		props: ['chartData', 'options'],
		mounted () {
			this.renderChart(this.chartData, this.options)
		}
	}
	export default chart
</script>