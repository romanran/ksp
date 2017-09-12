class dom {
	constructor($parent) {
		this.$parent = $parent;
	}
	//--cache elements here
	getElements() {
		return this.elements;
	}
	setElements(elements) {
		if (!_.isEmpty(this.$parent)) {
			elements = {
				parent: {
					selector: "",
					children: elements
				}
			};
		}
		this.elements = elements;

	}

	//caching script
	cache(elements) {
		if (elements) {
			this.setElements(elements);
		}
		_.each(this.getElements(), (val, key) => {
			this.append(val, key, this.$parent);
		});
	}
	append(val, key, $parent) {

		if (this['$' + key] === undefined) {
			if (val.hasOwnProperty('selector')) {
				val.selector = this._checkVal(val.selector);
				this._add(val.selector, key, $parent);
			} else {
				val = this._checkVal(val);
				this._add(val, key, $parent);
			}
		}

		if (val.children) {

			_.each(val.children, (cval, ckey) => {

				this.append(cval, ckey, this['$' + key]);

			});
		}
	}
	_add(val, key, $parent) {
		this['$' + key] = _.isEmpty($parent) ? $(val) : $parent.find(val);
	}
	_checkVal(val) {
		return val.indexOf('[') >= 0 ? val.replace('[d-', '[data-') : val;
	}
}

module.exports = dom;
