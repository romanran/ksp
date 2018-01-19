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

	crawlData(obj, data_arr) {
		_.each(obj, (val, key) => {
			if (typeof (val) == "object") {
				return data_arr = _.merge(this.crawlData(val, data_arr), data_arr)
			}
			if (key === "DESC") {
				this.status_arr.push(val);
//				return 0;
			}
			if (key === "STATUS") {
				const last_status = _.last(this.status_arr);
				if (last_status)
					this.desc_arr.push(`${last_status}, ${key}: ${val}`);
//				return 0;
			}

			if (!_.has(data_arr, key)) {
				data_arr[key] = [];
			}
			data_arr[key].push(val);
		});

		return data_arr;
	}

	handleData(data) {
		const title = data[0].SHIP ? data[0].SHIP : data[0].SPD;
		data = _.takeRight(data, data.length - 1)
		let res_left = data.map(obj => obj.RES)
		res_left = _.takeRight(res_left, res_left.length - 1)
		let data_arr = [];
		let res_arr = [];

		this.status_arr = [];
		this.desc_arr = [];

		res_arr = this.crawlData(res_left, res_arr)
		data_arr = this.crawlData(data, data_arr)
		const series = this.buildSeries(data_arr);
		res_left = this.buildSeries(res_arr)

		return {
			series: series,
			title: title,
			resources: res_left
		}
	}

	buildSeries(obj) {
		let series = [];
		let last_color = '#FFF'
		_.forIn(obj, (arr, key) => {
			let color = generateColor(key, {
				avoid: last_color,
				proximity: 100
			})
			last_color = color
			series.push({
				name: key,
				description: this.desc_arr,
				data: arr,
				color: color,
				lineWidth: 1,
			});
		});
		return series;
	}
}
