class Journal {
	constructor(path) {
		this.readJSON(path);
		this.entries = [];
		this.q = $.Deferred();
	}
	
	get getData() {
		return this.entries;
	}
	
	readJSON(path) {
		$.getJSON("flightlogs/" + path, this.parseJSON.bind(this));
	}
	
	parseJSON(data) {
		let filtered_data = _.filter(data.entries, (item, i) => {
			return i % 2 == 1;
		});
		_.each(filtered_data, (item, i) => {
			if (item.entries) {
				this.crawlObject(item.entries, false);
			}
		});
		this.q.resolve();
	}
	
	crawlObject(src_obj, nested) {
		let obj = {};
		//		deb(src_obj);
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
