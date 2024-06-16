package funkin.editors.ui;

/*
	.beui is just a JSON file but custom extension cause we cool
	beui stands for BundleEngine UI
 */
typedef BEUIFormat =
{
	/* 
		UI Array = [[id, sprite.x, sprite.y, uiAttributes]] 
		uiAttributes is currently saved as a string

		example objects:
		["rating",497,284,"{\"opacity\":1,\"rotation\":0,\"scale\":[1,1]}"]
		["comboNums",623,410,"{\"opacity\":1}"]]
	 */
	elements:Array<UIElement>,
	// Make arrows scroll down
	downScroll:Bool,
	// Use classic arrow note skin (bhb related)
	useClassicArrows:Bool,
	// Use classic healthbar instead of the modern layout
	useClassicHealthbar:Bool,
	// Show opponent notes
	opponentStrums:Bool,
	// Center your strumline to the middle of the screen
	middleScroll:Bool,
	hideHealthIcons:Bool,
	scoreTextZoom:Bool,
	timeBarType:String,
	noteHSV:Array<Array<Int>>,
	classicStrumline:Bool,
}
