_TD.prototype.createCharts = function(){
	//	deb(this.journal1);
	this.journals_A = [];
	_.each(this.journals, (obj)=>{
		let $new_canvas = $('<canvas></canvas>');
		this.dom.$canvas_wrap.html($new_canvas);
		let journal = new JournalChart($new_canvas, obj);
		deb(journal);
		this.journals_A.push(obj);
	});
	let x = [];
};
class JournalChart {
	constructor($canvas, data){
		let x = [];
		this.title = data.entries[0].SHIP ? data.entries[0].SHIP : data.entries[0].SPD;
		for(let key in data.entries){
			if(key == 0){
				continue;
			}
			x.push( data.entries[key].MISSIONTIME*1000 );
		}
		this.$canvas = $canvas;
		deb(data.entries[0]);
		let opts = this.getType('line', x, _.takeRight(data.entries, data.entries.length-1) );
		this.chart = new Chart($canvas, opts);
	}
	getType(type, labels, data){
		let dataset = [];
		let data_arr = [];
		let desc_arr = [];
		let data_l = data.length;
		let ai = 0;
		_.each(data, (obj, i)=>{
			let obj_l = Object.keys(obj).length;
			let ni = 0;
			_.each(obj, (val, key)=>{
				if(typeof(val) == "object"){
					return;
				}
				if(key === "DESC"){
					desc_arr.push(val);
					return 0;
				}
				if(key === "TIME" || key === "MISSIONTIME" || key === "FACING"){
					return 0;
				}
				if(data_arr[key]){
					data_arr[key].push(val);
				}else{
					data_arr[key] = [];
				}
			});
		});
		let r_colors = random.colors(Object.keys(data_arr).length);
		let ci = 0;
		_.forIn(data_arr, (arr, key)=>{
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
				borderWidth:1,
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
					onHover: (e) =>{
						this.$canvas.css("cursor", e[0] ? "pointer" : "default");
					},
					animationDuration: 100
				},
				legend:{
					position:'left',
					labels:{
						fontColor: 'white',
						fontStyle: 'bold',
					},
					onHover: (e) =>{
						this.$canvas.css("cursor", e ? "pointer" : "default");
					}
				},
				tooltips:{
					mode: 'index',
					intersect: true,
					yPadding: 10,
					xPadding: 10,
					callbacks: {
						title: (tooltipItem, data)=>{
							let datasetLabel = data.datasets[0].comment[tooltipItem[0].index];
							return data.datasets[0].comment[tooltipItem[0].index];
						}
					}
				},
				animation:{
					duration: 100
				},
				scales: {
					yAxes: [{
						gridLines: {
							color: "rgba(195,235,255,0.15)",
						},
						ticks: {
							fontColor: 'white',
							beginAtZero:true
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
							beginAtZero:true,

						},
						time:{
							unit: 'second',
							unitStepSize: 5,
							displayFormats:	{
								second:'mm:ss'
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
};

Chart.plugins.register({
	beforeDraw: function(chartInstance) {
		var ctx = chartInstance.chart.ctx;
		ctx.fillStyle = "#303439";
		ctx.fillRect(0, 0, chartInstance.chart.width, chartInstance.chart.height);
	}
});
