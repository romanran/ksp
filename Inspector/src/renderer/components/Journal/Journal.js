import fs from 'fs-extra'
import _ from 'lodash'
import shc from 'string-hash-colour'
import Color from 'color'

const generateColor = shc.convert

export default class Journal {
	constructor(path) {
		this.entries = [];
	}


	fetchData(path) {
		return new Promise(resolve => {
			fs.readJSON(`../flightlogs/${path}.json`, (err, data) => {
				this.parseJSON(err, data)
				const opts = this.handleData(this.entries)
				resolve(opts)
			});
		})
	}

	parseJSON(err, data) {
		if (err) {
			return err
		}

		let filtered_data = _.filter(data.entries, (item, i) => {
			return i % 2 == 1;
		});

		_.each(filtered_data, (item, i) => {
			if (item.entries) {
				return this.crawlObject(item.entries, false);
			}
		});
	}

	crawlObject(src_obj, nested) {
		let obj = {};
		_.each(src_obj, (item, i) => {
			if (i % 2) {
				if (item.entries) {
					obj[src_obj[i - 1]] = this.crawlObject(item.entries, true);
				} else {
					obj[src_obj[i - 1]] = item;
				}
			}
		});

		if (nested) {
			return obj;
		} else {
			this.entries.push(obj);
		}
	}


	handleData(data) {
		let x = [];

		const title = data[0].SHIP ? data[0].SHIP : data[0].SPD;
		for (let key in data) {
			if (key == 0) {
				continue;
			}
			x.push(data[key].MISSIONTIME);
		}

		const [type, labels] = ['line', x];

		data = _.takeRight(data, data.length - 1)

		let series = [];
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
//				if (['TIME', 'FACING'].indexOf(key) >= 0) {
//					return 0;
//				}
				if (data_arr[key]) {
					data_arr[key].push(val);
				} else {
					data_arr[key] = [];
				}
			});
		});

		let last_color = '#FFF'
		_.forIn(data_arr, (arr, key) => {
			let color = generateColor(key, {
				avoid: last_color,
				proximity: 100
			})
			last_color = color
			series.push({
				name: key,
				description: desc_arr,
				data: arr,
				color: color,
				lineWidth: 1,
			});
		});

		return {
			series: series,
			labels: labels,
			title: title
		}
	}
}
