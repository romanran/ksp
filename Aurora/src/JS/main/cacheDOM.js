class dom {
	constructor(){
	}
	cache(){
		let els = this.getElements();
		_.each(els, this.append.bind(this));
	}
	append(val, key){
		if( this['$' + key] === undefined){
			this['$' + key] = $(val.selector);
		}
		if (val.children) {
			_.each(val.children, (val, key)=>{
				if( this['$' + key] === undefined){
					this['$' + key] = $(val);
				}
			});
		}
	}
	getElements() {
		let elements ={
			graph:{
				selector: "[graph]",
			},
		};
		return elements;
	}
}
