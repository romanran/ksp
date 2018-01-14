import fs from 'fs-extra'
import _ from 'lodash'

export default class Journal {
	constructor(path) {
		this.entries = [];
	}

	get getData() {
		return this.entries;
	}

	fetchData(path) {
		return new Promise(resolve => {
			fs.readJSON(`../flightlogs/${path}.json`, (err, data) => {
				const parsed = this.parseJSON(err, data)
				resolve(this.entries)
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

		return _.each(filtered_data, (item, i) => {
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
}
