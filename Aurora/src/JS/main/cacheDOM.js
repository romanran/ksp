class dom {
	constructor(){
	}
	//Cache elements here
	getElements() {
		let elements ={
			canvas_wrap:{
				selector: "[charts]",
			},
		};
		return elements;
	}
	//--
	//caching script
	cache(){
		let els = this.getElements();
		_.each(els, this.append.bind(this));
	}
	append(val, key){
		if( this['$' + key] === undefined){
			if( val.selector.indexOf('[') >=0 ){
				val.selector = val.selector.replace('[', '[data-');
				this['$' + key] = $(val.selector);
			}else{
				this['$' + key] = $(val.selector);
			}
		}
		if (val.children) {
			_.each(val.children, (val, key)=>{
				if( this['$' + key] === undefined){
					if( val.indexOf('[') >=0 ){
						val = val.replace('[', '[data-');
						this['$' + key] = $(val);
					}else{
						this['$' + key] = $(val);
					}
				}
			});
		}
	}
}
