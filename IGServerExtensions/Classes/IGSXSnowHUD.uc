/***************************************************************************************************
 *
 *  IGSRVEXT. IG Generation 3 server extension by Zeropoint.
 *
 *  $CLASS        IGSXSnowHUD
 *  $VERSION      1.02 (6-12-2008 14:51)
 *  $AUTHOR       Daan 'Defrost' Scheerens  initial version
 *  $CONTACT      d.scheerens@gmail.com
 *  $DESCRIPTION  The snow effect enhanced CTF score board.
 *
 **************************************************************************************************/ 
class IGSXSnowHUD extends NexgenHUDExtension;

#exec texture import name=snowFlake1 file="Resources\SnowFlake1.pcx" mips=off flags=2
#exec texture import name=snowFlake2 file="Resources\SnowFlake2.pcx" mips=off flags=2
#exec texture import name=snowFlake3 file="Resources\SnowFlake3.pcx" mips=off flags=2
#exec texture import name=snowFlake4 file="Resources\SnowFlake4.pcx" mips=off flags=2
#exec texture import name=snowFlake5 file="Resources\SnowFlake5.pcx" mips=off flags=2
#exec texture import name=snowFlake6 file="Resources\SnowFlake6.pcx" mips=off flags=2
#exec texture import name=snowFlake7 file="Resources\SnowFlake7.pcx" mips=off flags=2
#exec texture import name=snowFlake8 file="Resources\SnowFlake8.pcx" mips=off flags=2
#exec texture import name=snowFlake9 file="Resources\SnowFlake9.pcx" mips=off flags=2
#exec texture import name=snowFlake10 file="Resources\SnowFlake10.pcx" mips=off flags=2
#exec texture import name=snowFlake11 file="Resources\SnowFlake11.pcx" mips=off flags=2
#exec texture import name=snowFlake12 file="Resources\SnowFlake12.pcx" mips=off flags=2
#exec texture import name=snowFlake13 file="Resources\SnowFlake13.pcx" mips=off flags=2
#exec texture import name=snowFlake14 file="Resources\SnowFlake14.pcx" mips=off flags=2
#exec texture import name=snowFlake15 file="Resources\SnowFlake15.pcx" mips=off flags=2
#exec texture import name=snowFlake16 file="Resources\SnowFlake16.pcx" mips=off flags=2

struct ParticleInfo {                   // Snow particle description struct.
	var int spriteNum;                  // The snow flake sprite to use.
	var float cx;                       // Horizontal offset.
	var float cy;                       // Vertical offset.
	var float ct;                       // Time offset.
	var float waveFreq;                 // Particle wave frequency.
	var float waveAmplitude;            // Amplitude of the wave.
	var float dy;                       // Vertical base velocity.
	var float dx;                       // Horizontal base velocity.
	var color col;                      // Color of the particle.
};

var color baseColor;                    // Base color of the snow flakes.
var bool bSnowInitialized;              // Whether the particles have been initialized.
var Texture sprites[16];                // Snow flake sprites.
var ParticleInfo particles[100];        // Current particles displayed.
var float lastUpdateTime;               // Last time the particles were rendered.

var float minDX;                        // Minimum horizontal base velocity.
var float maxDX;                        // Maximum horizontal base velocity.
var float minDY;                        // Minimum vertical base velocity.
var float maxDY;                        // Maximum vertical base velocity.
var float minWaveAmplitude;             // Minimum wave amplitude.
var float maxWaveAmplitude;             // Maximum wave amplitude.

// Non scaled constants.
const minWaveFreq = 0.25;               // Minimum wave frequency.
const maxWaveFreq = 1.0;                // Maximum wave frequency.
const minGlow = 0.40;                   // Minimum snow flake sprite glow.
const maxGlow = 1.00;                   // Maximum snow flake sprite glow.

// Scaled constants (set for a resolution of 1280x1024 px).
const scaleMinDX = -20.0;
const scaleMaxDX = 20.0;
const scaleMinDY = 100.0;
const scaleMaxDY = 300.0;
const scaleMinWaveAmplitude = 8;
const scaleMaxWaveAmplitude = 22;
const scaleWidth = 1280;
const scaleHeight = 1024;



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the HUD. Called before anything of the game HUD has been drawn. This
 *                function is only called if the Nexgen HUD is enabled.
 *  $PARAM        c  Canvas object that provides the drawing capabilities.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function preRender(Canvas c) {
	if (client.player.bShowScores) {
		renderSnow(c);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Renders the snow particles.
 *  $PARAM        c  The canvas on which the rendering should be performed.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function renderSnow(Canvas c) {
	local int index;
	local Texture sprite;
	local float cx, cy;
	
	// Update position of each particle.
	updateSnow(c);
	
	// Draw each particle.
	c.style = ERenderStyle.STY_Translucent;
	for (index = 0; index < arrayCount(particles); index++) {
		// Set position.
		cx = particles[index].cx;
		cy = particles[index].cy;
		cx += sin(particles[index].ct * particles[index].waveFreq * 2 * pi) * particles[index].waveAmplitude;
		c.setPos(cx, cy);
		
		// Draw particle sprite.
		c.drawColor = particles[index].col;
		sprite = sprites[particles[index].spriteNum];
		c.drawTile(sprite, sprite.uSize, sprite.vSize, 0, 0, sprite.uSize, sprite.vSize);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Updates the positions of the snow particles.
 *  $PARAM        c  The canvas on which the rendering should be performed.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function updateSnow(Canvas c) {
	local float deltaTime;
	local int index;
	
	// Prepare for update.
	setupScalars(c);
	if (!bSnowInitialized) {
		initializeSnow(c);
	}
	deltaTime = fMin(0.5, client.timeSeconds - lastUpdateTime);
	
	// Move each particle.
	for (index = 0; index < arrayCount(particles); index++) {
		particles[index].cx += particles[index].dx * deltaTime;
		particles[index].cy += particles[index].dy * deltaTime;
		particles[index].ct += deltaTime / level.timeDilation;
		
		// Check if particle has left the screen.
		if (particles[index].cy > c.clipY) {
			// It has, reset particle.
			initializeParticle(index, c, true);
		}
	}
	lastUpdateTime = client.timeSeconds;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes all snow particles.
 *  $PARAM        c  The canvas on which the rendering should be performed.
 *  $REQUIRE      c != none
 *  $ENSURE       bSnowInitialized
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function initializeSnow(Canvas c) {
	local int index;
	bSnowInitialized = true;
	
	// Initialize each particle.
	for (index = 0; index < arrayCount(particles); index++) {
		initializeParticle(index, c);
	}
	lastUpdateTime = client.timeSeconds;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Initializes the specified particle.
 *  $PARAM        index   The particle that is to be initialized.
 *  $PARAM        c       The canvas on which the rendering should be performed.
 *  $PARAM        bReset  Reset particle to the top of the screen.
 *  $REQUIRE      0 <= index && index <= arrayCount(particles) && c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function initializeParticle(int index, Canvas c, optional bool bReset) {
	particles[index].spriteNum = rand(arrayCount(sprites));
	particles[index].cx = fRand() * c.clipX;
	if (bReset) {
		particles[index].cy = -sprites[particles[index].spriteNum].vSize;
	} else {
		particles[index].cy = fRand() * c.clipY;
	}	
	particles[index].ct = 0.0;
	particles[index].dx = fRand() * (maxDX - minDX) + minDX;
	particles[index].dy = fRand() * (maxDY - minDY) + minDY;
	particles[index].waveFreq = fRand() * (maxWaveFreq - minWaveFreq) + minWaveFreq;
	particles[index].waveAmplitude = fRand() * (maxWaveAmplitude - minWaveAmplitude) + minWaveAmplitude;
	particles[index].waveFreq *= particles[index].dy / maxDY;
	particles[index].waveAmplitude *= particles[index].dy / maxDY;
	
	if (level.month == 12 && level.day == 31 || level.month == 1 && level.day == 1) {
		particles[index].col.r = rand(256);
		particles[index].col.g = rand(256);
		particles[index].col.b = rand(256);
	} else {
		particles[index].col = baseColor * (fRand() * (maxGlow - minGlow) + minGlow);
	}
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Computes the absolute values of the scaled settings.
 *  $PARAM        c  The canvas on which the rendering should be performed.
 *  $REQUIRE      c != none
 *  $OVERRIDE
 *
 **************************************************************************************************/
simulated function setupScalars(Canvas c) {
	minDX = scaleMinDX / scaleWidth * c.clipX;
	maxDX = scaleMaxDX / scaleWidth * c.clipX;
	minDY = scaleMinDY / scaleHeight * c.clipY;
	maxDY = scaleMaxDY / scaleHeight * c.clipY;
	minWaveAmplitude = scaleMinWaveAmplitude / scaleWidth * c.clipX;
	maxWaveAmplitude = scaleMaxWaveAmplitude / scaleWidth * c.clipX;
}



/***************************************************************************************************
 *
 *  $DESCRIPTION  Default properties block.
 *
 **************************************************************************************************/
defaultproperties {
	baseColor=(r=255,g=255,b=255)
	sprites(0)=Texture'snowFlake1'
	sprites(1)=Texture'snowFlake2'
	sprites(2)=Texture'snowFlake3'
	sprites(3)=Texture'snowFlake4'
	sprites(4)=Texture'snowFlake5'
	sprites(5)=Texture'snowFlake6'
	sprites(6)=Texture'snowFlake7'
	sprites(7)=Texture'snowFlake8'
	sprites(8)=Texture'snowFlake9'
	sprites(9)=Texture'snowFlake10'
	sprites(10)=Texture'snowFlake11'
	sprites(11)=Texture'snowFlake12'
	sprites(12)=Texture'snowFlake13'
	sprites(13)=Texture'snowFlake14'
	sprites(14)=Texture'snowFlake15'
	sprites(15)=Texture'snowFlake16'
}

