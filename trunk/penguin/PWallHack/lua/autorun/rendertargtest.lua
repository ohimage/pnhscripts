// This example is based off the GMDMPickup code (Pickups in the GMDeathmatch mode by garry)
/*
customRT = GetRenderTarget("rtTest",128,128,true); // Create a RenderTarget with a size of 128x128 in additive render mode and call it "rtTest"
 
local OldRT = render.GetRenderTarget()
local w, h = ScrW(), ScrH() // These functions return the size of the CURRENT render target, so we'll want to save them
render.SetRenderTarget( customRT ) // Change the RenderTarget, so all drawing will be redirected to our new RT
 
	render.SetViewPort( 0, 0, 128, 128 )	
	render.Clear( 0, 0, 0, 255, true ) // Floodfill with black color
 
		cam.Start2D()
			draw.SimpleText( "Test", "ScoreboardHead", 64,60, Color(255,0,0,255), TEXT_ALIGN_CENTER )
		cam.End2D()
 
	render.SetViewPort( 0, 0, w, h )
 
render.SetRenderTarget( OldRT ) // Resets the RenderTarget to our screen
*/