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
			content:{
				selector: "[data-content]",
				children: {
				 	contact: ".sow-contact-form",
				 	panels: ".panel-grid" 
				}
			},
			header:{
				selector: "[data-header]",
				children: {
					mobile_toggle: "[data-menu-toggle]"
				}
				
			}
		}; 
		return elements;
	}
}