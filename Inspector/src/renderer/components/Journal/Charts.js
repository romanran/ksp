import randomColor from 'randomcolor'
import Chart from 'chart.js'

export default class JournalChart {
	
	constructor($canvas, data, parent) {
		let x = [];

		this.title = data[0].SHIP ? data[0].SHIP : data[0].SPD;
		for (let key in data) {
			if (key == 0) {
				continue;
			}
			x.push(data[key].MISSIONTIME * 1000);
		}
		this.$canvas = $canvas;
		this.parent = parent;

		let opts = this.getType('line', x, _.takeRight(data, data.length - 1));
		this.chart = new Chart($canvas, opts);
	}
	
	getType(type, labels, data) {
		let dataset = [];
		let data_arr = [];
		let desc_arr = [];
		let status_arr = [];
		let data_l = data.length;
		let ai = 0;
		deb(data)
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
				if (['TIME', 'MISSIONTIME', 'FACING'].indexOf(key) >= 0) {
					return 0;
				}
				if (data_arr[key]) {
					data_arr[key].push(val);
				} else {
					data_arr[key] = [];
				}
			});
		});
		let r_colors = _.times(Object.keys(data_arr).length, randomColor)
		let ci = 0;
		_.forIn(data_arr, (arr, key) => {
			dataset.push({
				label: key,
				comment: desc_arr,
				fill: false,
				data: arr,
				title: key,
				borderColor: r_colors[ci],
				backgroundColor: r_colors[ci],
				chartColors: r_colors,
				borderWidth: 1,
				radius: 3,
				borderWidth: 1,
				tension: 0.3,
			});
			ci++;
		});

		return {
			type: type,
			data: {
				labels: labels,
				datasets: dataset,
			},
			backgroundColor: "red",
			options: {
				title: {
					display: true,
					fontColor: 'white',
					fontSize: 20,
					text: this.title
				},
				hover: {
					onHover: (e) => {
						this.parent.pointer = 0
					},
					animationDuration: 100
				},
				legend: {
					position: 'left',
					labels: {
						fontColor: 'white',
						fontStyle: 'bold',
					},
					onHover: (e) => {
						this.parent.pointer = 1					
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
							display: true,
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
						},
						time: {
							unit: 'second',
							unitStepSize: 5,
							displayFormats: {
								second: 'mm:ss'
							}
						},
						scaleLabel: {
							display: true,
							fontColor: 'white',
							labelString: 'MISSION TIME'
						}
					}]
				}
			}
		};
	}
	
}
