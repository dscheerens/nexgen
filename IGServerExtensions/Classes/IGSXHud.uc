/***************************************************************************************************
 *
 *  IGSRVEXT. IG Generation 3 server extension by Zeropoint.
 *
 *  $CLASS        IGSXHud
 *  $VERSION      1.01 (10-8-2008 12:03)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  IG 3 extended HUD.
 *
 **************************************************************************************************/
class IGSXHud extends Mutator;

//#exec TEXTURE IMPORT NAME=ig3logo     FILE=Resources\IG3Logo.pcx              GROUP="GFX" FLAGS=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=ig3logoP1   FILE=Resources\IG3LogoP1.pcx            GROUP="GFX" FLAGS=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=ig3logoP2   FILE=Resources\IG3LogoP2.pcx            GROUP="GFX" FLAGS=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=loadingbar  FILE=Resources\ProgressBar.pcx          GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=readybar    FILE=Resources\ProgressBar2.pcx         GROUP="GFX" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=segment     FILE=Resources\ProgressBarSegment.pcx   GROUP="GFX" FLAGS=2 MIPS=OFF

var IGSXClient xClient;                 // The extended client controller.

var bool bLoadingComplete;              // Whether Nexgen has been loaded.
var bool bDone;                         // Set to true if the loading / ready animation is done.
var float finishAnimTimeStamp;          // Time at which the finish animation is started.

var float timeSeconds;                  // Game speed independent level.timeSeconds.

var color logoBaseColor;                // The base server logo color.
var color loadingColor;                 // Loading progress bar animation color.
var color readyColor;                   // Ready progress bar animation color.

const minimumLoadingTime = 1.0;         // Minimum time loading state is active.

const logoTextureWidth = 512;           // Width of the logo texture.
const logoTextureHeight = 64;           // Height of the logo texture.
const progressbarTextureWidth = 256;    // Width of the progress bar texture.
const progressbarTextureHeight = 16;    // Height of the progress bar texture.
const segmentTextureWidth = 16;         // Width of the progress bar segment texture.
const segmentTextureHeight = 16;        // Height of the progress bar segment texture.

const progressBarHOffset = 192;         // Horizontal progress bar offset relative to logo.
const progressBarVOffset = 68;          // Vertical progress bar offset relative to logo.

const segmentHOffset = 261;             // First segment horizontal offset relative to logo.
const segmentDistance = 14;             // Distance between segments.

const numSegments = 13;                 // Number of progress bar segments.
const animCycleTime = 0.7;              // Progress indicator animation cycle time.
const trailsize = 5;                    // Length of the progress indicator.

const finishAnimationTime = 0.75;       // Amount of time required for the finish animation to complete.



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the HUD extension.
 *  $REQUIRE      owner != none && owner.isA('IGSXClient')
 *  $ENSURE       client != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function postBeginPlay() {
	super.postBeginPlay();
	xClient = IGSXClient(owner);
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Game tick. Enabled support for game speed independent timing. Also attemps to
 *                register this IGSXHud instance as a HUD mutator.
 *  $OVERRIDE
 *
 **************************************************************************************************/
function tick(float deltaTime) {
	// Game speed independent timing support.
	timeSeconds += deltaTime / level.timeDilation;
	
	// Register as HUD mutator if not already done. Note this may fail several times.
	if (!bHUDMutator) registerHUDMutator();
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the extended Nexgen HUD.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
function postRender(Canvas c) {
	local int baseX, baseY;
	local float animIndex;
	local int position;
	local int nextPosition;
	local int index;
	local float phase;
	local color segmentColor;
	local Texture progressBarTexture;
	
	// Let other HUD mutators do their job first.
	if (nextHUDMutator != none) {
		nextHUDMutator.postRender(c);
	}
	
	// Don't render anything if animation is complete.
	if (bDone) return;
	
	// Check if the loading animation is completed.
	if (!bLoadingComplete && xClient.client != none && !xClient.client.bNetWait && timeSeconds > minimumLoadingTime) {
		bLoadingComplete = true;
	}
	
	// Check whether the finish animation is to be started.
	if (finishAnimTimeStamp <= 0 && bLoadingComplete && xClient.client.gInf.gameState > xClient.client.gInf.GS_Ready) {
		finishAnimTimeStamp = timeSeconds;
	}
	
	// Render logo.
	baseX = (c.clipX - logoTextureWidth) / 2;
	baseY = c.clipY * 0.75 - logoTextureHeight /2;
	
	if (finishAnimTimeStamp > 0) {
		animIndex = (timeSeconds - finishAnimTimeStamp) / finishAnimationTime;
		
		if (animIndex > 1) {
			bDone = true;
			return;
		}
		
		baseX += (animIndex * animIndex) * (c.clipX - baseX);
	}
	
	c.style = ERenderStyle.STY_Translucent;
	c.drawColor = logoBaseColor;
	
	c.setPos(baseX, baseY);
	//c.drawTile(Texture'ig3logo', logoTextureWidth, logoTextureHeight, 0.0, 0.0, logoTextureWidth, logoTextureHeight);
	c.drawTile(Texture'ig3logoP1', logoTextureWidth / 2, logoTextureHeight, 0.0, 0.0, logoTextureWidth / 2, logoTextureHeight);
	c.setPos(baseX + logoTextureWidth / 2, baseY);
	c.drawTile(Texture'ig3logoP2', logoTextureWidth / 2, logoTextureHeight, 0.0, 0.0, logoTextureWidth / 2, logoTextureHeight);


	// Render progress bar.
	if (finishAnimTimeStamp > 0) return;
	if (bLoadingComplete) {
		segmentColor = readyColor;
		progressBarTexture = Texture'readybar';
	} else {
		segmentColor = loadingColor;
		progressBarTexture = Texture'loadingbar';
	}
	
	c.setPos(baseX + progressBarHOffset, baseY + progressBarVOffset);
	c.drawTile(progressBarTexture, progressbarTextureWidth, progressbarTextureHeight, 0.0, 0.0, progressbarTextureWidth, progressbarTextureHeight);

	// Rander progress bar animation.
	animIndex = (timeSeconds % animCycleTime) / animCycleTime;
	nextPosition = int(animIndex * numSegments);
	phase = (animIndex * numSegments) % 1.0;
	for (index = 0; index <= trailsize; index++) {
		position = nextPosition - index;
		if (position < 0) position += numSegments;
		
		if (index == 0) {
			c.drawColor = segmentColor * phase;
		} else {
			c.drawColor = segmentColor * fClamp(((trailsize - index + 1) / trailsize) - phase / trailsize, 0.0, 1.0);
		}
		c.setPos(baseX + segmentHOffset + position * segmentDistance, baseY + progressBarVOffset);
		c.drawTile(Texture'segment', segmentTextureWidth, segmentTextureHeight, 0.0, 0.0, segmentTextureWidth, segmentTextureHeight);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	remoteRole=ROLE_None
	bAlwaysTick=true
	logoBaseColor=(R=255,G=255,B=255)
	loadingColor=(R=0,G=0,B=255)
	readyColor=(R=0,G=255,B=0)
}