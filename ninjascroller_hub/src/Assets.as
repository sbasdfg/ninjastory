package  
{
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Assets 
	{
		
		[Embed(source = "assets/xml/levels/hub.tmx", mimeType = "application/octet-stream")] public static const LEVEL1XML:Class;
		[Embed(source = "assets/gfx/tilemaps/tiles1.png")] public static const MAPTILES:Class;
		[Embed(source = "assets/gfx/tilemaps/tiles1.xml", mimeType = "application/octet-stream")] public static const MAPTILEXML:Class;
		[Embed(source = "assets/gfx/backgrounds/levelbg.png")] public static const LEVELBG:Class;
		
		//Graphics
		//HUD
		[Embed(source = "assets/gfx/hud/borderbar.png")] public static const HUDBARHORZ:Class;
		[Embed(source = "assets/gfx/hud/borderbarvert.png")] public static const HUDBARVERT:Class;
		[Embed(source = "assets/gfx/hud/corner.png")] public static const HUDCORNER:Class;
		[Embed(source = "assets/gfx/hud/infobar.png")] public static const HUDINFOBAR:Class;
		[Embed(source = "assets/gfx/hud/marque.png")] public static const HUDMARQUE:Class;
		[Embed(source = "assets/gfx/hud/skillbar.png")] public static const HUDSKILLBAR:Class;
		
		
		//Fonts
		//[Embed(source="assets/gfx/fonts/ARIAL.TTF")]
		
	}

}