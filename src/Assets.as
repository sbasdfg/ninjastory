package  
{
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Assets 
	{
		
		[Embed(source = "assets/xml/levels/maptest.tmx", mimeType = "application/octet-stream")] public static const LEVEL1XML:Class;
		[Embed(source = "assets/gfx/tilemaps/tiles1.png")] public static const MAPTILES:Class;
		[Embed(source = "assets/gfx/tilemaps/tiles1.xml", mimeType = "application/octet-stream")] public static const MAPTILEXML:Class;
		[Embed(source = "assets/gfx/backgrounds/levelbg.png")] public static const LEVELBG:Class;
		
		//Fonts
		//[Embed(source="assets/gfx/fonts/ARIAL.TTF")]
		
	}

}