_TD.prototype.createCharts = function(){
	let $new_canvas = $('<canvas></canvas>');
	this.dom.$canvas_wrap.append($new_canvas);
//	deb(this.journal1);
	let x = [];
	let y1 = [];
	let y2 = [];
	let y3 = [];
	for(let key in this.journal1.entries){
		if(key == 0){
			continue;
		}
		x.push( this.journal1.entries[key].MISSIONTIME );
		y1.push( this.journal1.entries[key].ALT );
		y2.push( this.journal1.entries[key].SURV );
		y3.push( this.journal1.entries[key].VERTICALSPEED );
	}
	new Chart($new_canvas, this.getType('bar', x, this.journal1.entries ));
};
_TD.prototype.getType = function(type, labels, data){
	let dataset = [];
	let data_arr = [];
	deb(data.length);
	let data_l = data.length;
	let ai = 0;
	_.each(data, (obj, i)=>{
		let ni = 0;
		let obj_l = obj.length;
		_.each(obj, (val, key)=>{
			ni++;
			if(typeof(val) == "object"){
				return;
			}
			if(data_arr[key]){
				data_arr[key].push(val);
			}else{
				data_arr[key] = []; ai++;
			}
		});
		if(ni==obj_l){
			ai++;
			deb("obj end");
		}
		if(ai == data_l){
			deb("finish end");
		}
	});
	_.each(data_arr, (arr, key)=>{
		ai++;
		dataset.push({
			label: key,
			fill: false,
			data: arr,
			borderColor: [
				Tools.strToColor(key)
			],
			borderWidth: 1
		});
	});
//	deb(dataset);
	return 0;
	switch(type){
		case 'bar':
			return {
				type: 'line',
				data: {
					labels: labels,
					datasets: dataset
				},
				options: {
					scales: {
						yAxes: [{
							ticks: {
								beginAtZero:true
							},
							scaleLabel: {
								display: true,
								labelString: 'ATITUDE'
							  }
						}],
						xAxes: [{
							ticks: {
								beginAtZero:true
							},
							scaleLabel: {
								display: true,
								labelString: 'MISSION TIME'
							  }
						}]
					}
				}
			};
			break;
	}
};
