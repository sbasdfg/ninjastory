package entities.Climbers 
{
	import citrus.objects.CitrusSprite;
	import entities.Climbers.RopeAnchor;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class RopeVerticle extends Rope
	{
		
		public function RopeVerticle(name:String, params:Object = null) 
		{
			//widthSegment = 5;
			var ropeAnchor:RopeAnchor = new RopeAnchor("ropeanchor", { x:params.x, y:params.y - ((params.height-25)/2), width:25, height:25 } );

			super(name, null, ((params.height-25) / 2), (params.height) / 25);
			
			_ce.state.add(ropeAnchor);
			anchor = ropeAnchor;
		}
		
	}

}