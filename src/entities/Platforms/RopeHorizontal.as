package entities.Platforms 
{
	import entities.Climbers.RopeAnchor;
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class RopeHorizontal extends Rope 
	{
		
		public function RopeHorizontal(name:String, params:Object = null) 
		{
			var ropeAnchorRight:RopeAnchor;
			var ropeAnchorLeft:RopeAnchor;
			
			ropeAnchorLeft = new RopeAnchor("ropeanchor", { x:params.x - ((params.width - 25) / 2), y:params.y, height:25, width:25 } );
			ropeAnchorRight = new RopeAnchor("ropeanchor", { x:params.x + ((params.width - 25) / 2), y:params.y, height:25, width:25 } );
			
			super(name, null, (params.width -50)/2, params.width /25);
			
			_ce.state.add(ropeAnchorLeft);
			_ce.state.add(ropeAnchorRight);
		}
		
	}

}